# Graphics audit for 1.2

Transport Empire 1.2 keeps the OpenTTD 14.1 simulation and changes the art the player sees. The pictures below were taken from the Linux SDL build of this same source. They are not captures from an Android framebuffer. The emulator guest in this environment never reached adb.

## What shipped

OpenGFX2 Classic 0.8.1 is the default base graphics set. OpenGFX 7.1 stays in the APK. Game Options can switch back to OpenGFX without another install. The 1.0 and 1.1 APKs are still in `dist/`.

Classic is a complete 8bpp redraw at the normal zoom this engine actually displays. Its `opengfx2_8.obg` says `blitter = 8bpp` and `palette = DOS`. On this 14.1 port the default viewport is `ZOOM_LVL_OUT_4X`, and a GRF zoom byte of 0 is that view. Classic's sprites are zoom byte 0, so they are the sprites the game draws. A side-by-side of one saved map, Chenfingfield on 25 February 1950, same camera, changed about 86 percent of the playfield pixels. Mean absolute difference was about 34, 31, and 31 per channel.

Quick Start loads `scenario/Coastal Valley.scn` when that file is present. The scenario is a 256×256 temperate heightmap: a western coast, a river inlet, two hill masses, forests, fields, and towns. A sample bus route, with two stops, a depot, and one bus, runs between Brindhattan Springs and Chenfingfield. The First Route story then asks for a second bus. If the scenario file is missing, Quick Start still generates a 256×256 map.

World generation was not turned up to the maximum of every slider:

- Terrain type is hilly, not alpine.
- Terrain variety is high (4), not the maximum (5).
- Rivers are medium (2), not many (3).
- The improved tree placer clumps forests. In-game tree spread is "grow but don't spread", so open ground stays open. That is the opposite of filling the map with trees.
- Town density stays low. The 6,144-town figure is still what Normal does on a 4096 map. World Generation still shows the estimate and still asks before placing more than about 150 towns.

## OpenGFX2 High Def, not shipped

OpenGFX2 High Def 0.8.1 is GPL-2.0 and is the higher-resolution set. It was not put in the APK.

- The published High Def archive is about 367 MB compressed and about 383 MB uncompressed. `extra.grf` alone is about 255 MB.
- GitHub rejects a file over 100 MB. This 1.2 APK is 91 MB with Classic included. High Def does not fit.
- High Def's published `.obg` checksums match Classic's, but the GRF files do not. The High Def set is 32bpp extra-zoom and is incomplete for vehicles and houses. Landscape and infrastructure are the parts that are mostly filled in, with 8bpp fallbacks.
- This engine can use zoom byte 0 as the normal view, and High Def does contain 32bpp sprites at that byte. That is a reason it might draw, not a test. High Def was not loaded in a running game here. Classic was.

## NewGRFs that were checked and left out

These files are from the OpenGFX2 project, GPL-2.0, and were not stacked on Classic:

| File | Size | Why it is not in the APK |
| --- | --- | --- |
| `ogfx2_landscape.grf` | 238 MB | Over the 100 MB file limit, and it repeats baseset terrain. |
| `ogfx2_trees.grf` | 6.3 MB | Classic already redraws the trees. A second tree set would replace them again. |
| `ogfx2_objects.grf` | 1.7 MB | Decorative objects. They do not appear until something places them. |
| `ogfx2_stations.grf` | 28 KB | Extra station styles. They do not change a map until a station of that class is built. |
| `ogfx2_trams.grf` | 41 KB | Tram tracks and vehicles. They do not appear until a tram line is built. All 8bpp, zoom 0. |

Both Classic and OpenGFX use the baseset shortname `ogfx`. The config selects Classic by the name `OpenGFX2 Classic`.

## Measurements

These numbers are from the Linux SDL binary of this source, 1280×720, not from a phone.

- In the Coastal Valley save with OpenGFX2, the `fps` console reported a game loop of 37.04 fps, which matched the expected loop rate, a drawing rate of 60 fps against an expected 33.33, and video output of 59.99 fps against an expected 60. Viewport drawing time was about 0.3 ms. Game-script time was 0.00 ms on that sample.
- Resident memory in that same session was 213,352 KB, and the high-water mark was the same.
- A later title-screen launch, with the basesets already in the page cache, passed 80 MB resident in under 230 ms for both sets. About two seconds later OpenGFX2 was 232,056 KB and OpenGFX was 230,512 KB. That is not a cold-phone install time.

No Android frame time or Android memory figure was measured.
