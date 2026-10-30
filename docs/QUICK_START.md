# Quick Start and the 6,144 towns

OpenTTD does not store a fixed town count for the Normal, Low, and High settings. It scales a small base by the map area. The base for Normal is 23 plus a random 0–7. On a 256×256 map that is a few dozen towns. On a 4096×4096 map the same Normal setting is 5,888–7,680 towns. 6,144 is that formula with a random add of 1:

`ceil(24 << (12 + 12 - 12) / 16) = 6144`

The generation window prints that number under "Town generation" as `current / total`. It is the number of towns being placed, not a separate bug in the counter.

Quick Start opens the Coastal Valley scenario when that file is in the install. The scenario is a 256×256 temperate heightmap with a coast, a river inlet, hills, forests, towns, and a sample bus route. The First Route chapter asks you to buy a second bus; when that pays off, the First Contract chapter asks you to run a truck cargo delivery. If the scenario file is missing, Quick Start generates a new map instead:

- 256×256 temperate map
- Low town density, about 15 towns
- Normal industries
- Hilly terrain, high variety, medium rivers, and forests that grow in place but do not spread across open ground
- No rival companies and no vehicle breakdowns
- Year 1950
- The First Route game script

World Generation is still on the main menu. If the chosen settings would place more than about 150 towns, the game asks before it starts. The town dropdown shows the estimate, for example `Normal (about 6144 towns)` on a 4096 map.

The tutorial is a game script in the APK at `game/industry-empire-tutorial`. Source lives in `assets/game-scripts/industry-empire-tutorial`. On Coastal Valley it points at the sample route and asks for a second bus, then passenger income, then a cargo contract with a nearby industry. On a generated map the bus goals are the same without the pre-built route. Skip tutorial, Replay tutorial, Skip contract, and Replay contract are on the story pages.

An upgrade deletes the previous `openttd.cfg` so an old 4096×4096 setting does not come back. Saved games are left in place.

Version 1.2 draws that world with OpenGFX2 Classic. OpenGFX 7.1 remains selectable in Game Options. The graphics audit, the High Def size blocker, and the Linux SDL measurements are in `docs/GRAPHICS.md`.

1.2 APK SHA-256: `ba98e9ee3d0162e4c44dbe38110d52c3d8259545d95464f0ba862817c2feba45`
