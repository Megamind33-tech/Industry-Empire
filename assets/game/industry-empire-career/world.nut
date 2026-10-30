// SPDX-License-Identifier: GPL-2.0-only
function min(a, b) { return a < b ? a : b; }
function max(a, b) { return a > b ? a : b; }

function CareerNeighbours(tile)
{
    local out = [];
    local x = GSMap.GetTileX(tile), y = GSMap.GetTileY(tile);
    foreach (d in [[1,0], [0,1], [-1,0], [0,-1]]) {
        local nx = x + d[0], ny = y + d[1];
        if (nx < 1 || ny < 1 || nx >= GSMap.GetMapSizeX() - 1 || ny >= GSMap.GetMapSizeY() - 1) continue;
        out.append(GSMap.GetTileIndex(nx, ny));
    }
    return out;
}

function CareerStopSites(industry, cargo, accepting)
{
    local out = [];
    local tile = GSIndustry.GetLocation(industry);
    local x = GSMap.GetTileX(tile), y = GSMap.GetTileY(tile);
    for (local dx = -4; dx <= 7; dx++) for (local dy = -4; dy <= 7; dy++) {
        if (x + dx < 1 || y + dy < 1 || x + dx >= GSMap.GetMapSizeX() - 1 || y + dy >= GSMap.GetMapSizeY() - 1) continue;
        local t = GSMap.GetTileIndex(x + dx, y + dy);
        if (!GSTile.IsBuildable(t) || GSTile.GetSlope(t) != GSTile.SLOPE_FLAT) continue;
        if (accepting ? GSTile.GetCargoAcceptance(t, cargo, 1, 1, 3) < 8 : GSTile.GetCargoProduction(t, cargo, 1, 1, 3) < 1) continue;
        out.append(t);
    }
    return out;
}

// This constructs starter infrastructure; vehicle routing remains OpenTTD's pathfinder.
function CareerRoadPath(start, goals)
{
    local queue = [start], head = 0, previous = {};
    previous[start] <- -1;
    while (head < queue.len() && head < 10000) {
        local tile = queue[head++];
        if (tile in goals) {
            local path = [];
            while (tile != -1) { path.append(tile); tile = previous[tile]; }
            path.reverse();
            return path;
        }
        foreach (next in CareerNeighbours(tile)) {
            if (next in previous) continue;
            if (GSMap.DistanceManhattan(start, next) > 85) continue;
            if (GSTile.GetSlope(next) != GSTile.SLOPE_FLAT) continue;
            if (!GSTile.IsBuildable(next) && !GSRoad.IsRoadTile(next)) continue;
            previous[next] <- tile;
            queue.append(next);
        }
    }
    return null;
}

function CareerBuildWorld()
{
    local cargo = -1;
    local cargos = GSCargoList();
    foreach (c, value in cargos) if (GSCargo.GetCargoLabel(c) == "GRAI") cargo = c;
    if (cargo == -1) { GSLog.Error("Career requires temperate grain cargo."); return null; }
    local farms = GSIndustryList_CargoProducing(cargo);
    local receivers = GSIndustryList_CargoAccepting(cargo);
    local pairs = [];
    foreach (f, fv in farms) foreach (r, rv in receivers) {
        local distance = GSMap.DistanceManhattan(GSIndustry.GetLocation(f), GSIndustry.GetLocation(r));
        if (distance >= 8 && distance <= 70) pairs.append({farm=f, receiver=r, distance=distance});
    }
    pairs.sort(function(a,b) { return a.distance == b.distance ? (a.farm == b.farm ? a.receiver-b.receiver : a.farm-b.farm) : a.distance-b.distance; });
    // Provision infrastructure before normalizing starting funds, never grant funds on reload.
    local original_balance = GSCompany.GetBankBalance(0);
    if (!GSCompany.ChangeBankBalance(0, 1000000, GSCompany.EXPENSES_OTHER, GSMap.TILE_INVALID)) return null;
    local result = null;
    {
        local mode = GSCompanyMode(0);
        GSRoad.SetCurrentRoadType(GSRoad.ROADTYPE_ROAD);
        foreach (pair in pairs) {
            local starts = CareerStopSites(pair.farm, cargo, false);
            local ends = CareerStopSites(pair.receiver, cargo, true);
            local goals = {};
            foreach (t in ends) goals[t] <- true;
            foreach (start in starts) {
                local path = CareerRoadPath(start, goals);
                if (path == null || path.len() < 5) continue;
                local last = path.len() - 1;
                local test_ok = true;
                {
                    local test = GSTestMode();
                    if (!GSRoad.BuildRoadStation(path[0], path[1], GSRoad.ROADVEHTYPE_TRUCK, GSStation.STATION_NEW)) test_ok = false;
                    if (!GSRoad.BuildRoadStation(path[last], path[last-1], GSRoad.ROADVEHTYPE_TRUCK, GSStation.STATION_NEW)) test_ok = false;
                    for (local i = 1; i < last - 1 && test_ok; i++) {
                        if (!GSRoad.AreRoadTilesConnected(path[i], path[i+1]) && !GSRoad.BuildRoad(path[i], path[i+1])) test_ok = false;
                    }
                }
                if (!test_ok) continue;
                local depot = -1, front = -1;
                for (local i = 2; i < last - 1 && depot == -1; i++) foreach (t in CareerNeighbours(path[i])) {
                    if (path.find(t) != null || !GSTile.IsBuildable(t) || GSTile.GetSlope(t) != GSTile.SLOPE_FLAT) continue;
                    local test = GSTestMode();
                    if (GSRoad.BuildRoadDepot(t, path[i])) { depot=t; front=path[i]; break; }
                }
                if (depot == -1) continue;
                local built = GSRoad.BuildRoadStation(path[0], path[1], GSRoad.ROADVEHTYPE_TRUCK, GSStation.STATION_NEW);
                built = GSRoad.BuildRoadStation(path[last], path[last-1], GSRoad.ROADVEHTYPE_TRUCK, GSStation.STATION_NEW) && built;
                for (local i = 1; i < last - 1; i++) if (!GSRoad.AreRoadTilesConnected(path[i], path[i+1])) built = GSRoad.BuildRoad(path[i], path[i+1]) && built;
                // Connect road end tiles to each bay's entrance.
                built = (GSRoad.AreRoadTilesConnected(path[1], path[0]) || GSRoad.BuildRoad(path[1], path[0])) && built;
                built = (GSRoad.AreRoadTilesConnected(path[last-1], path[last]) || GSRoad.BuildRoad(path[last-1], path[last])) && built;
                built = GSRoad.BuildRoadDepot(depot, front) && built;
                built = (GSRoad.AreRoadTilesConnected(front, depot) || GSRoad.BuildRoad(front, depot)) && built;
                if (!built) { GSLog.Warning("Career infrastructure command failed: " + GSError.GetLastErrorString()); continue; }
                result = { cargo=cargo, farm=pair.farm, receiver=pair.receiver, farm_stop=path[0], receiver_stop=path[last], depot=depot };
                GSLog.Info("CAREER_WORLD farm=" + pair.farm + " receiver=" + pair.receiver + " depot=" + depot);
                break;
            }
            if (result != null) break;
        }
        // Remove inherited startup debt before the career cash normalization.
        if (result != null) GSCompany.SetLoanAmount(0);
    }
    GSCompany.ChangeBankBalance(0, original_balance - GSCompany.GetBankBalance(0), GSCompany.EXPENSES_OTHER, GSMap.TILE_INVALID);
    return result;
}

function CareerBuyTruck(world)
{
    local mode = GSCompanyMode(0);
    local engines = GSEngineList(GSVehicle.VT_ROAD);
    local selected = -1, price = 0;
    foreach (e, value in engines) {
        if (!GSEngine.IsBuildable(e) || !GSEngine.CanRunOnRoad(e, GSRoad.ROADTYPE_ROAD)) continue;
        if (GSEngine.GetCargoType(e) != world.cargo && !GSEngine.CanRefitCargo(e, world.cargo)) continue;
        local cost = GSEngine.GetPrice(e);
        if (selected == -1 || cost < price) { selected=e; price=cost; }
    }
    if (selected == -1) return null;
    local before = GSCompany.GetBankBalance(0);
    local vehicle = GSVehicle.BuildVehicleWithRefit(world.depot, selected, world.cargo);
    if (!GSVehicle.IsValidVehicle(vehicle)) return null;
    local ok = GSOrder.AppendOrder(vehicle, world.farm_stop, GSOrder.OF_FULL_LOAD_ANY);
    ok = GSOrder.AppendOrder(vehicle, world.receiver_stop, GSOrder.OF_UNLOAD | GSOrder.OF_NO_LOAD) && ok;
    if (!ok || !GSVehicle.StartStopVehicle(vehicle)) {
        GSLog.Warning("Purchased truck needs manual orders in depot: " + vehicle);
    }
    return {vehicle=vehicle, cost=before-GSCompany.GetBankBalance(0)};
}
