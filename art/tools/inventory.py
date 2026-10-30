"""Write art/assets.csv: every asset the engine ships that Transport Empire must replace.

usage: python3 -I art/tools/inventory.py <openttd-src-dir> art/assets.csv

Named items (vehicles, industries, houses, cargo) come from the English strings.
Rows already in the CSV keep their status, model and owner columns.
"""
import csv
import os
import re
import sys

NAMED = [
    # prefix in english.txt, category, directions, frames, kind
    ("STR_VEHICLE_NAME_TRAIN_ENGINE_", "train_engine", 8, 1, "vehicle"),
    ("STR_VEHICLE_NAME_TRAIN_WAGON_", "train_wagon", 8, 1, "vehicle"),
    ("STR_VEHICLE_NAME_ROAD_VEHICLE_", "road_vehicle", 8, 1, "vehicle"),
    ("STR_VEHICLE_NAME_SHIP_", "ship", 8, 1, "vehicle"),
    ("STR_VEHICLE_NAME_AIRCRAFT_", "aircraft", 8, 1, "vehicle"),
    ("STR_INDUSTRY_NAME_", "industry", 1, 4, "building"),
    ("STR_TOWN_BUILDING_NAME_", "house", 1, 1, "building"),
    ("STR_CARGO_PLURAL_", "cargo_icon", 1, 1, "icon"),
]

# Unnamed sprite families. Counts are base-set sprite counts per climate set.
FAMILIES = [
    ("terrain", "ground_slopes", "19 slopes x grass/rough/rocky/fields/snow/desert/bare", 1, 1, "tile", "P1"),
    ("terrain", "water_coast_rivers", "water, 19 coast slopes, river and canal edges, locks", 1, 4, "tile", "P1"),
    ("terrain", "trees", "temperate 19, sub-arctic 19, tropic 18, toyland 9; 7 growth stages", 1, 1, "billboard", "P1"),
    ("terrain", "farm_fields_fences", "fields, hedges, fences", 1, 1, "tile", "P2"),
    ("road", "road_pieces", "16 road bits x 19 slopes, town and company styles, tram tracks", 1, 1, "tile", "P1"),
    ("road", "road_stops_depots", "bus and truck stops (drive-in and drive-through), depots, 4 directions", 4, 1, "building", "P1"),
    ("rail", "track_pieces", "rail, mono, maglev: straight, diagonal, slopes, crossings", 1, 1, "tile", "P1"),
    ("rail", "signals", "semaphore and light signals, all types, red and green", 8, 2, "prop", "P2"),
    ("rail", "stations_depots_waypoints", "station platforms, roofs, depots, waypoints", 2, 1, "building", "P1"),
    ("infrastructure", "bridges", "13 bridge types, ramps, pillars", 2, 1, "building", "P2"),
    ("infrastructure", "tunnels", "rail and road portals", 4, 1, "building", "P2"),
    ("infrastructure", "docks_airports", "docks, buoys, 9 airport layouts, hangars, radar, windsock", 1, 4, "building", "P2"),
    ("infrastructure", "objects", "transmitter, lighthouse, company HQ (5 sizes), statue, owned land", 1, 1, "building", "P2"),
    ("effects", "smoke_steam_sparks", "steam, diesel smoke, electric sparks, smoke from industries", 1, 8, "effect", "P2"),
    ("effects", "explosions_disasters", "explosions, UFO, crashed vehicles", 1, 8, "effect", "P3"),
    ("gui", "toolbar_icons", "main toolbar, build toolbars, window widgets", 1, 1, "icon", "P1"),
    ("gui", "cursors", "build cursors and animated cursors", 1, 2, "icon", "P2"),
    ("gui", "company_faces", "president face parts", 1, 1, "icon", "P3"),
    ("gui", "fonts", "small, medium, large, mono", 1, 1, "font", "P1"),
    ("gui", "logo_title", "title logo, loading screen, menu background", 1, 1, "art", "P1"),
    ("audio", "sound_effects", "73 effects", 0, 0, "audio", "P3"),
    ("audio", "music", "title and in-game playlist", 0, 0, "audio", "P3"),
]

FIELDS = ["category", "id", "name", "directions", "frames", "kind", "priority", "model", "status", "notes"]


def main(src, out):
    old = {}
    if os.path.exists(out):
        with open(out, newline="") as f:
            old = {r["id"]: r for r in csv.DictReader(f)}
    rows = []
    with open(os.path.join(src, "lang", "english.txt"), encoding="utf-8") as f:
        lang = f.read().splitlines()
    for prefix, cat, dirs, frames, kind in NAMED:
        for line in lang:
            m = re.match(rf"({prefix}\w+)\s*:(.*)", line)
            if not m:
                continue
            rid = m.group(1)[len("STR_"):].lower()
            name = re.sub(r"\{[^}]*\}", "", m.group(2)).strip()
            prio = "P1" if cat in ("road_vehicle", "house", "industry", "cargo_icon") else "P2"
            rows.append(dict(category=cat, id=rid, name=name, directions=dirs, frames=frames, kind=kind, priority=prio))
    for cat, rid, notes, dirs, frames, kind, prio in FAMILIES:
        rows.append(dict(category=cat, id=rid, name=rid.replace("_", " "), directions=dirs, frames=frames, kind=kind,
                         priority=prio, notes=notes))
    rows.insert(0, dict(category="road_vehicle", id="starter_car", name="Hatchback Taxi", directions=8, frames=1,
                        kind="vehicle", priority="P0", notes="the player's first car"))
    for r in rows:
        prev = old.get(r["id"], {})
        r["model"] = prev.get("model", "")
        r["status"] = prev.get("status") or "todo"
        r.setdefault("notes", prev.get("notes", ""))
    with open(out, "w", newline="") as f:
        w = csv.DictWriter(f, FIELDS)
        w.writeheader()
        w.writerows(rows)
    by = {}
    for r in rows:
        by[r["category"]] = by.get(r["category"], 0) + 1
    print(len(rows), "rows:", ", ".join(f"{k} {v}" for k, v in by.items()))


if __name__ == "__main__":
    main(*sys.argv[1:3])
