class FirstRoute extends GSController {
	skipped = false;
	route_done = false;
	chapter = 1;
	page = -1;
	goal_bus = -1;
	goal_profit = -1;
	skip_button = -1;
	replay_button = -1;
	sample_buses = 0;
	camera = -1;
	showcase = false;
	contract_started = false;
	contract_skipped = false;
	contract_done = false;
	contract_page = -1;
	goal_truck = -1;
	goal_cargo = -1;
	contract_skip_button = -1;
	contract_replay_button = -1;
	trucks_at_start = 0;
	industry_camera = -1;
	contract_cargo_name = "cargo";
}

function FirstRoute::Start()
{
	this.Sleep(1);
	this.BuildShowcase();
	this.BuildPages();
	while (true) {
		this.PollEvents();
		if (this.chapter == 1 && !this.skipped && !this.route_done) this.CheckRouteProgress();
		else if (this.chapter == 2 && !this.contract_skipped && !this.contract_done) this.CheckContractProgress();
		this.Sleep(74);
	}
}

function FirstRoute::BuildPages()
{
	this.page = GSStoryPage.New(GSCompany.COMPANY_INVALID, "Your first bus route");
	if (this.showcase) {
		GSStoryPage.NewElement(this.page, GSStoryPage.SPET_TEXT, 0,
			"Coastal Valley is a small temperate map: hills, a western sea, a river inlet, forests, and a handful of towns.");
		GSStoryPage.NewElement(this.page, GSStoryPage.SPET_TEXT, 0,
			"A sample bus route is already built. Look for the road, two stops, the depot, and the bus.");
		GSStoryPage.NewElement(this.page, GSStoryPage.SPET_TEXT, 0,
			"1. Open the depot on that road and buy a second bus. Give it orders for both stops and start it.");
		GSStoryPage.NewElement(this.page, GSStoryPage.SPET_TEXT, 0,
			"2. Open Finances and wait until passenger income appears. Then the First Contract chapter opens.");
	} else {
		GSStoryPage.NewElement(this.page, GSStoryPage.SPET_TEXT, 0,
			"Industry Empire starts you next to a few towns. You do not need every toolbar button yet.");
		GSStoryPage.NewElement(this.page, GSStoryPage.SPET_TEXT, 0,
			"1. Open the road tool and drag a road between two nearby towns.");
		GSStoryPage.NewElement(this.page, GSStoryPage.SPET_TEXT, 0,
			"2. Place a bus stop in each town, touching that road. Place a bus depot on the road.");
		GSStoryPage.NewElement(this.page, GSStoryPage.SPET_TEXT, 0,
			"3. Open the depot, buy a bus, and give it orders for both stops. Start the bus.");
		GSStoryPage.NewElement(this.page, GSStoryPage.SPET_TEXT, 0,
			"4. Open Finances and wait until passenger income appears. Then the First Contract chapter opens.");
	}
	local skip_ref = GSStoryPage.MakePushButtonReference(GSStoryPage.SPBC_YELLOW, GSStoryPage.SPBF_NONE);
	local replay_ref = GSStoryPage.MakePushButtonReference(GSStoryPage.SPBC_LIGHT_BLUE, GSStoryPage.SPBF_NONE);
	this.skip_button = GSStoryPage.NewElement(this.page, GSStoryPage.SPET_BUTTON_PUSH, skip_ref, "Skip tutorial");
	this.replay_button = GSStoryPage.NewElement(this.page, GSStoryPage.SPET_BUTTON_PUSH, replay_ref, "Replay tutorial");

	local bus_goal = this.showcase ? "Buy a second bus and send it to the two stops." : "Buy a bus and send it to two stops.";
	this.goal_bus = GSGoal.New(GSCompany.COMPANY_FIRST, bus_goal, GSGoal.GT_STORY_PAGE, this.page);
	this.goal_profit = GSGoal.New(GSCompany.COMPANY_FIRST, "Earn passenger income.", GSGoal.GT_STORY_PAGE, this.page);
	this.skipped = false;
	this.route_done = false;
	this.ScrollToTown();
}

function FirstRoute::ScrollToTown()
{
	if (this.camera != -1 && GSMap.IsValidTile(this.camera)) {
		GSViewport.ScrollTo(this.camera);
		return;
	}
	local towns = GSTownList();
	if (towns.Count() == 0) return;
	towns.Valuate(GSTown.GetPopulation);
	towns.Sort(GSList.SORT_BY_VALUE, false);
	local town = towns.Begin();
	if (!GSTown.IsValidTown(town)) return;
	GSViewport.ScrollTo(GSTown.GetLocation(town));
}

function FirstRoute::ScrollToIndustry()
{
	if (this.industry_camera != -1 && GSMap.IsValidTile(this.industry_camera)) {
		GSViewport.ScrollTo(this.industry_camera);
		return;
	}
	this.ScrollToTown();
}

function FirstRoute::BeginContractChapter()
{
	if (this.skipped || this.contract_skipped) return;
	this.contract_started = true;
	this.chapter = 2;
	local industry = PickShowcaseIndustry();
	this.industry_camera = industry == -1 ? -1 : GSIndustry.GetLocation(industry);
	this.contract_cargo_name = "cargo";
	if (industry != -1) {
		local produced = GSIndustryType.GetProducedCargo(GSIndustry.GetIndustryType(industry));
		if (produced != null && produced.Count() > 0) {
			local cargo = produced.Begin();
			if (GSCargo.IsValidCargo(cargo)) this.contract_cargo_name = GSCargo.GetName(cargo);
		}
	}
	this.BuildContractPages(industry);
	this.trucks_at_start = CargoRoadVehicleCount();
	this.ScrollToIndustry();
}

function FirstRoute::BuildContractPages(industry)
{
	local title = industry == -1 ? "Your first contract" : ("Your first contract: " + GSIndustry.GetName(industry));
	this.contract_page = GSStoryPage.New(GSCompany.COMPANY_INVALID, title);
	GSStoryPage.NewElement(this.contract_page, GSStoryPage.SPET_TEXT, 0,
		"Passenger routes are only the start. Industries produce " + this.contract_cargo_name + " and pay you to move it.");
	if (industry != -1) {
		GSStoryPage.NewElement(this.contract_page, GSStoryPage.SPET_TEXT, 0,
			"The map is centered on " + GSIndustry.GetName(industry) + ". Build truck stops at the industry and at a town or station that accepts the cargo.");
	} else {
		GSStoryPage.NewElement(this.contract_page, GSStoryPage.SPET_TEXT, 0,
			"Find a producing industry on the map. Build truck stops at the industry and at a town or station that accepts the cargo.");
	}
	GSStoryPage.NewElement(this.contract_page, GSStoryPage.SPET_TEXT, 0,
		"1. Open a road depot, buy a truck, and give it orders to load full at the industry and unload at the destination.");
	GSStoryPage.NewElement(this.contract_page, GSStoryPage.SPET_TEXT, 0,
		"2. When the truck earns a profit from that delivery, the contract chapter is complete.");
	local skip_ref = GSStoryPage.MakePushButtonReference(GSStoryPage.SPBC_YELLOW, GSStoryPage.SPBF_NONE);
	local replay_ref = GSStoryPage.MakePushButtonReference(GSStoryPage.SPBC_LIGHT_BLUE, GSStoryPage.SPBF_NONE);
	this.contract_skip_button = GSStoryPage.NewElement(this.contract_page, GSStoryPage.SPET_BUTTON_PUSH, skip_ref, "Skip contract");
	this.contract_replay_button = GSStoryPage.NewElement(this.contract_page, GSStoryPage.SPET_BUTTON_PUSH, replay_ref, "Replay contract");
	this.goal_truck = GSGoal.New(GSCompany.COMPANY_FIRST, "Buy a truck for cargo deliveries.", GSGoal.GT_STORY_PAGE, this.contract_page);
	this.goal_cargo = GSGoal.New(GSCompany.COMPANY_FIRST, "Earn a profit on a cargo delivery.", GSGoal.GT_STORY_PAGE, this.contract_page);
}

function FirstRoute::PollEvents()
{
	while (true) {
		local event = GSEventController.GetNextEvent();
		if (event == null) return;
		if (event.GetEventType() != GSEvent.ET_STORYPAGE_BUTTON_CLICK) continue;
		local click = GSEventStoryPageButtonClick.Convert(event);
		if (click.GetElementID() == this.skip_button) {
			this.skipped = true;
			this.contract_skipped = true;
			this.RemoveRouteGoals();
			this.RemoveContractGoals();
		} else if (click.GetElementID() == this.replay_button) {
			this.RemoveRouteGoals();
			local bus_goal = this.showcase ? "Buy a second bus and send it to the two stops." : "Buy a bus and send it to two stops.";
			this.goal_bus = GSGoal.New(GSCompany.COMPANY_FIRST, bus_goal, GSGoal.GT_STORY_PAGE, this.page);
			this.goal_profit = GSGoal.New(GSCompany.COMPANY_FIRST, "Earn passenger income.", GSGoal.GT_STORY_PAGE, this.page);
			this.skipped = false;
			this.route_done = false;
			this.chapter = 1;
			this.RemoveContractGoals();
			this.contract_started = false;
			this.contract_skipped = false;
			this.contract_done = false;
			this.ScrollToTown();
		} else if (click.GetElementID() == this.contract_skip_button) {
			this.contract_skipped = true;
			this.RemoveContractGoals();
		} else if (click.GetElementID() == this.contract_replay_button) {
			this.RemoveContractGoals();
			this.contract_skipped = false;
			this.contract_done = false;
			this.trucks_at_start = CargoRoadVehicleCount();
			this.goal_truck = GSGoal.New(GSCompany.COMPANY_FIRST, "Buy a truck for cargo deliveries.", GSGoal.GT_STORY_PAGE, this.contract_page);
			this.goal_cargo = GSGoal.New(GSCompany.COMPANY_FIRST, "Earn a profit on a cargo delivery.", GSGoal.GT_STORY_PAGE, this.contract_page);
			this.ScrollToIndustry();
		}
	}
}

function FirstRoute::RemoveRouteGoals()
{
	if (GSGoal.IsValidGoal(this.goal_bus)) GSGoal.Remove(this.goal_bus);
	if (GSGoal.IsValidGoal(this.goal_profit)) GSGoal.Remove(this.goal_profit);
	this.goal_bus = -1;
	this.goal_profit = -1;
}

function FirstRoute::RemoveContractGoals()
{
	if (GSGoal.IsValidGoal(this.goal_truck)) GSGoal.Remove(this.goal_truck);
	if (GSGoal.IsValidGoal(this.goal_cargo)) GSGoal.Remove(this.goal_cargo);
	this.goal_truck = -1;
	this.goal_cargo = -1;
}

function IsRoadVehicle(vehicle_id, vehicle_type)
{
	return GSVehicle.GetVehicleType(vehicle_id) == vehicle_type;
}

function AbsInt(n)
{
	return n < 0 ? -n : n;
}

function RoadVehicleCount()
{
	local buses = GSVehicleList(IsRoadVehicle, GSVehicle.VT_ROAD);
	return buses.Count();
}

function IsCargoRoadVehicle(vehicle_id, vehicle_type)
{
	if (vehicle_type != GSVehicle.VT_ROAD) return false;
	local cargo = GSVehicle.GetCargoType(vehicle_id);
	if (!GSCargo.IsValidCargo(cargo)) return false;
	local label = GSCargo.GetCargoLabel(cargo);
	return label != "PASS";
}

function CargoRoadVehicleCount()
{
	local trucks = GSVehicleList(IsCargoRoadVehicle, GSVehicle.VT_ROAD);
	return trucks.Count();
}

function CargoVehicleProfit()
{
	local profit = 0;
	local trucks = GSVehicleList(IsCargoRoadVehicle, GSVehicle.VT_ROAD);
	for (local v = trucks.Begin(); !trucks.IsEnd(); v = trucks.Next()) {
		profit += GSVehicle.GetProfitThisYear(v);
	}
	return profit;
}

function PickShowcaseIndustry()
{
	local best = -1;
	local best_score = 1000000;
	local industries = GSIndustryList();
	for (local i = industries.Begin(); !industries.IsEnd(); i = industries.Next()) {
		if (!GSIndustry.IsValidIndustry(i)) continue;
		local produced = GSIndustryType.GetProducedCargo(GSIndustry.GetIndustryType(i));
		if (produced == null || produced.Count() == 0) continue;
		local cargo = produced.Begin();
		if (!GSCargo.IsValidCargo(cargo)) continue;
		local label = GSCargo.GetCargoLabel(cargo);
		if (label == "PASS" || label == "MAIL") continue;
		local loc = GSIndustry.GetLocation(i);
		local towns = GSTownList();
		local near_town = false;
		for (local t = towns.Begin(); !towns.IsEnd(); t = towns.Next()) {
			if (GSMap.DistanceManhattan(loc, GSTown.GetLocation(t)) <= 48) {
				near_town = true;
				break;
			}
		}
		if (!near_town) continue;
		local score = 1000000;
		for (local t = towns.Begin(); !towns.IsEnd(); t = towns.Next()) {
			local d = GSMap.DistanceManhattan(loc, GSTown.GetLocation(t));
			if (d < score) score = d;
		}
		if (score < best_score) {
			best_score = score;
			best = i;
		}
	}
	return best;
}

function FindPassengerCargo()
{
	local cargos = GSCargoList();
	for (local c = cargos.Begin(); !cargos.IsEnd(); c = cargos.Next()) {
		if (GSCargo.GetCargoLabel(c) == "PASS") return c;
	}
	return -1;
}

function FindBusEngine(cargo)
{
	local engines = GSEngineList(GSVehicle.VT_ROAD);
	for (local e = engines.Begin(); !engines.IsEnd(); e = engines.Next()) {
		if (!GSEngine.IsBuildable(e)) continue;
		if (GSEngine.GetVehicleType(e) != GSVehicle.VT_ROAD) continue;
		if (!GSEngine.CanRunOnRoad(e, GSRoad.ROADTYPE_ROAD)) continue;
		if (GSEngine.GetCargoType(e) != cargo && !GSEngine.CanRefitCargo(e, cargo)) continue;
		return e;
	}
	return -1;
}

function PickTownPair()
{
	local ids = [];
	local towns = GSTownList();
	for (local t = towns.Begin(); !towns.IsEnd(); t = towns.Next()) ids.append(t);
	local best_a = -1;
	local best_b = -1;
	local best_score = 1000000;
	for (local i = 0; i < ids.len(); i++) {
		for (local j = i + 1; j < ids.len(); j++) {
			local d = GSMap.DistanceManhattan(GSTown.GetLocation(ids[i]), GSTown.GetLocation(ids[j]));
			if (d < 16 || d > 70) continue;
			local score = AbsInt(d - 32);
			if (score < best_score) {
				best_score = score;
				best_a = ids[i];
				best_b = ids[j];
			}
		}
	}
	if (best_a == -1) return null;
	return [best_a, best_b];
}

function NeighbourTile(tile, dx, dy)
{
	local x = GSMap.GetTileX(tile) + dx;
	local y = GSMap.GetTileY(tile) + dy;
	local next = GSMap.GetTileIndex(x, y);
	if (!GSMap.IsValidTile(next)) return -1;
	if (GSMap.DistanceManhattan(tile, next) != 1) return -1;
	return next;
}

function TryStep(cur, dest)
{
	local cx = GSMap.GetTileX(cur);
	local cy = GSMap.GetTileY(cur);
	local dx = GSMap.GetTileX(dest) - cx;
	local dy = GSMap.GetTileY(dest) - cy;
	local options = [];
	if (dx != 0) options.append(NeighbourTile(cur, dx > 0 ? 1 : -1, 0));
	if (dy != 0) options.append(NeighbourTile(cur, 0, dy > 0 ? 1 : -1));
	options.append(NeighbourTile(cur, 1, 0));
	options.append(NeighbourTile(cur, -1, 0));
	options.append(NeighbourTile(cur, 0, 1));
	options.append(NeighbourTile(cur, 0, -1));
	foreach (opt in options) {
		if (opt == -1) continue;
		if (RoadsConnect(cur, opt)) return [opt, 0];
		if (GSRoad.BuildRoad(cur, opt)) return [opt, 1];
	}
	return null;
}

function WalkRoad(start, dest)
{
	local cur = start;
	local built = 0;
	local guard = 0;
	while (GSMap.DistanceManhattan(cur, dest) > 1 && guard < 220) {
		guard++;
		local step = TryStep(cur, dest);
		if (step == null) return [cur, built];
		cur = step[0];
		built += step[1];
		if ((guard % 6) == 0) GSController.Sleep(1);
	}
	return [cur, built];
}

function TryBayStop(road)
{
	local dirs = [[1, 0], [-1, 0], [0, 1], [0, -1]];
	foreach (d in dirs) {
		local spot = NeighbourTile(road, d[0], d[1]);
		if (spot == -1) continue;
		if (GSRoad.IsRoadTile(spot)) continue;
		if (GSTile.GetSlope(spot) != GSTile.SLOPE_FLAT) continue;
		if (GSRoad.BuildRoadStation(spot, road, GSRoad.ROADVEHTYPE_BUS, GSStation.STATION_NEW)) return spot;
	}
	return -1;
}

function FindRoadNear(tile)
{
	local x = GSMap.GetTileX(tile);
	local y = GSMap.GetTileY(tile);
	for (local r = 1; r <= 14; r++) {
		for (local dx = -r; dx <= r; dx++) {
			for (local dy = -r; dy <= r; dy++) {
				if (AbsInt(dx) != r && AbsInt(dy) != r) continue;
				local t = GSMap.GetTileIndex(x + dx, y + dy);
				if (!GSMap.IsValidTile(t)) continue;
				if (GSRoad.IsRoadTile(t)) return t;
			}
		}
	}
	return -1;
}

function FindBayStop(origin)
{
	local x = GSMap.GetTileX(origin);
	local y = GSMap.GetTileY(origin);
	for (local r = 1; r <= 16; r++) {
		for (local dx = -r; dx <= r; dx++) {
			for (local dy = -r; dy <= r; dy++) {
				if (AbsInt(dx) != r && AbsInt(dy) != r) continue;
				local road = GSMap.GetTileIndex(x + dx, y + dy);
				if (!GSMap.IsValidTile(road) || !GSRoad.IsRoadTile(road)) continue;
				local spot = TryBayStop(road);
				if (spot != -1) return spot;
			}
		}
	}
	return -1;
}

function FindDepot(origin)
{
	local x = GSMap.GetTileX(origin);
	local y = GSMap.GetTileY(origin);
	for (local r = 0; r <= 16; r++) {
		for (local dx = -r; dx <= r; dx++) {
			for (local dy = -r; dy <= r; dy++) {
				if (AbsInt(dx) != r && AbsInt(dy) != r) continue;
				local road = GSMap.GetTileIndex(x + dx, y + dy);
				if (!GSMap.IsValidTile(road) || !GSRoad.IsRoadTile(road)) continue;
				local dirs = [[1, 0], [-1, 0], [0, 1], [0, -1]];
				foreach (d in dirs) {
					local spot = NeighbourTile(road, d[0], d[1]);
					if (spot == -1) continue;
					if (GSRoad.IsRoadTile(spot)) continue;
					if (GSTile.GetSlope(spot) != GSTile.SLOPE_FLAT) continue;
					if (GSRoad.BuildRoadDepot(spot, road)) return spot;
				}
			}
		}
	}
	return -1;
}

function RoadsConnect(a, b)
{
	if (a == -1 || b == -1) return false;
	if (!GSMap.IsValidTile(a) || !GSMap.IsValidTile(b)) return false;
	if (GSMap.DistanceManhattan(a, b) != 1) return false;
	return GSRoad.AreRoadTilesConnected(a, b);
}

function FindStraightRoad(tile)
{
	local x = GSMap.GetTileX(tile);
	local y = GSMap.GetTileY(tile);
	for (local r = 0; r <= 10; r++) {
		for (local dx = -r; dx <= r; dx++) {
			for (local dy = -r; dy <= r; dy++) {
				if (AbsInt(dx) != r && AbsInt(dy) != r) continue;
				local t = GSMap.GetTileIndex(x + dx, y + dy);
				if (!GSMap.IsValidTile(t)) continue;
				if (!GSRoad.IsRoadTile(t)) continue;
				if (RoadsConnect(t, NeighbourTile(t, 1, 0)) || RoadsConnect(t, NeighbourTile(t, -1, 0))) return [t, 1, 0];
				if (RoadsConnect(t, NeighbourTile(t, 0, 1)) || RoadsConnect(t, NeighbourTile(t, 0, -1))) return [t, 0, 1];
			}
		}
	}
	return null;
}

function FirstRoute::BuildShowcase()
{
	if (RoadVehicleCount() > 0) {
		this.sample_buses = RoadVehicleCount();
		this.showcase = true;
		GSLog.Info("Sample buses already present: " + this.sample_buses);
		return;
	}
	local pair = PickTownPair();
	if (pair == null) {
		GSLog.Warning("No town pair for the sample route");
		return;
	}
	if (GSCompany.ResolveCompanyID(GSCompany.COMPANY_FIRST) == GSCompany.COMPANY_INVALID) {
		GSLog.Warning("No company yet; sample route skipped");
		return;
	}
	local cargo = FindPassengerCargo();
	local engine = cargo == -1 ? -1 : FindBusEngine(cargo);
	if (engine == -1) {
		GSLog.Warning("No buildable bus");
		return;
	}

	GSCompany.ChangeBankBalance(GSCompany.COMPANY_FIRST, 2000000, GSCompany.EXPENSES_OTHER, GSTown.GetLocation(pair[0]));
	local mode = GSCompanyMode(GSCompany.COMPANY_FIRST);
	GSRoad.SetCurrentRoadType(GSRoad.ROADTYPE_ROAD);

	local start = FindRoadNear(GSTown.GetLocation(pair[0]));
	local dest = FindRoadNear(GSTown.GetLocation(pair[1]));
	if (start == -1 || dest == -1) {
		GSLog.Error("No town road to start the sample route");
		return;
	}
	GSLog.Error("Sample route from " + GSTown.GetName(pair[0]) + " to " + GSTown.GetName(pair[1]));
	local walked = WalkRoad(start, dest);
	local end_tile = walked[0];
	local built = walked[1];
	local gap = GSMap.DistanceManhattan(end_tile, dest);
	GSLog.Error("Road tiles touched " + built + ", gap " + gap);

	local stop_a = FindBayStop(GSTown.GetLocation(pair[0]));
	this.Sleep(1);
	local stop_b = FindBayStop(GSTown.GetLocation(pair[1]));
	this.Sleep(1);
	if (stop_a == -1 || stop_b == -1) {
		GSLog.Error("Stop failed a=" + stop_a + " b=" + stop_b + " " + GSError.GetLastErrorString());
		return;
	}

	local depot = FindDepot(end_tile);
	if (depot == -1) depot = FindDepot(start);
	if (depot == -1) {
		GSLog.Error("Depot failed " + GSError.GetLastErrorString());
		return;
	}
	this.Sleep(1);

	local vehicle = GSVehicle.BuildVehicle(depot, engine);
	if (!GSVehicle.IsValidVehicle(vehicle)) {
		GSLog.Error("Bus purchase failed " + GSError.GetLastErrorString());
		return;
	}
	GSOrder.AppendOrder(vehicle, stop_a, GSOrder.OF_NONE);
	GSOrder.AppendOrder(vehicle, stop_b, GSOrder.OF_NONE);
	GSVehicle.StartStopVehicle(vehicle);
	this.camera = stop_a;
	this.sample_buses = RoadVehicleCount();
	this.showcase = this.sample_buses > 0;
	GSLog.Error("Sample route built, buses=" + this.sample_buses);
}

function FirstRoute::CheckRouteProgress()
{
	if (!GSGoal.IsValidGoal(this.goal_bus)) return;
	local buses = RoadVehicleCount();
	if (buses > this.sample_buses && !GSGoal.IsCompleted(this.goal_bus)) {
		GSGoal.SetCompleted(this.goal_bus, true);
	}
	local income = GSCompany.GetQuarterlyIncome(GSCompany.COMPANY_FIRST, 0);
	if (income > 0 && GSGoal.IsValidGoal(this.goal_profit) && !GSGoal.IsCompleted(this.goal_profit)) {
		GSGoal.SetCompleted(this.goal_profit, true);
		this.route_done = true;
		if (!this.contract_started) this.BeginContractChapter();
	}
}

function FirstRoute::CheckContractProgress()
{
	if (!GSGoal.IsValidGoal(this.goal_truck)) return;
	local trucks = CargoRoadVehicleCount();
	if (trucks > this.trucks_at_start && !GSGoal.IsCompleted(this.goal_truck)) {
		GSGoal.SetCompleted(this.goal_truck, true);
	}
	if (CargoVehicleProfit() > 0 && GSGoal.IsValidGoal(this.goal_cargo) && !GSGoal.IsCompleted(this.goal_cargo)) {
		GSGoal.SetCompleted(this.goal_cargo, true);
		this.contract_done = true;
	}
}
