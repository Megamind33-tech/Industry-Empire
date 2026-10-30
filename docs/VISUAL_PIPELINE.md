# Visual pipeline and performance plan

Target: a look close to the reference renders (warm sun, real materials, dust, water, snow, living ports and mines) while holding 60 fps on mid-range Android phones and at least 30 fps on small ones (2–3 GB RAM, Mali-G52 / Adreno 610 class).

## Core decision: render offline, play 2.5D

Blender and Unreal Engine run on a build machine, never on the phone. They render each model from the fixed isometric angle into 32bpp sprites. The phone only blits pre-lit images, so a scene that takes Unreal seconds per frame costs the phone almost nothing.

| Stage | Tool | Output |
| --- | --- | --- |
| Modelling, UVs, rigging of vehicles and buildings | Blender 4.x (`blender -b`, scripted with Python) | `.blend` source, `.fbx` export |
| Look development and hero lighting (sun, GI, dust, water, snow) | Unreal Engine 5 headless (`UnrealEditor-Cmd -RenderOffscreen`, Movie Render Queue, path tracer) | 8 view angles × N animation frames, RGBA + mask passes |
| Fallback renderer for bulk assets (trees, houses, terrain) | Blender Cycles / EEVEE headless | Same passes, cheaper to batch on CI |
| Sprite post-process | Python (Pillow): crop, align to tile offsets, company-colour mask, downscale per zoom | PNG sheets |
| Packing | NML → NewGRF / base set | `.grf` loaded by the game |

The camera is a fixed orthographic dimetric angle (30° elevation, 45° yaw) matching the engine's tile grid. Vehicles render at 8 directions. Animated objects (cranes, excavators, ships, smoke) get 4–8 looped frames.

## Phone performance budget

| Item | Low tier (30 fps) | High tier (60 fps) |
| --- | --- | --- |
| Max zoom shipped | 2× (64 px tile) | 4× (128 px tile) |
| Sprite cache | 128 MB | 384 MB |
| Animated frames per object | 4 | 8 |
| Vehicle directions | 8 | 8 |
| Ambient effects (dust, smoke, birds) | Off or sparse | On |
| Day/night tint | Single viewport colour multiply | Same, plus light-sprite overlays at night |

Rules that keep it fast:
1. **No real-time lighting, shadows or post-processing on device.** Shadows and GI are baked into the sprites.
2. **The APK ships only the zoom levels the device tier needs.** The game picks a tier on first launch from RAM and GPU and downloads the 4× pack only for high tier. That keeps the base APK under about 150 MB.
3. **Sprites use the 32bpp-optimised blitter with run-length transparency.** Large flat areas (water, sand) use tiling textures, not unique sprites.
4. **"Alive" comes from cheap motion.** Pedestrians and small traffic are 2–4 frame sprites drawn only inside the visible viewport and capped per screen. Water shimmer uses the engine's existing palette and mask animation. Nothing simulates off screen.
5. **A frame cap setting (30 or 60)** and an automatic drop to 30 when the frame time stays above 20 ms or the phone is hot.
6. **A performance gate in CI.** A scripted benchmark save runs on a low-end emulator profile. A change fails if median frame time goes above 33 ms on low tier.

## What the references translate to in-game

- Desert mine and quarry: excavator and dump-truck animations, dust sprites, layered rock-cliff terrain sets.
- Port: container cranes (animated), stacked container yards, ships with 8-direction wakes.
- Snow climate: re-rendered snow terrain, pines, snow-covered rails.
- Logging and town: sawmill with log piles, tree-lined avenues, parked cars as town decoration.

Close-up cinematic shots like the references become the loading screens, menu backgrounds and store art. They come from the same Unreal scenes, so they match the game.

## Order of work

1. Set up the pipeline: a scripted Blender scene with the engine camera, a tile calibration grid, and one test road vehicle rendered and loaded in-game.
2. Terrain and climate sets (temperate, desert, snow), then roads, rails and water.
3. Starter vehicles (car, van, bus, truck), then the industries in the references (mine, port, sawmill).
4. Towns and buildings, then ambient life.
5. Unreal hero lighting pass and menu and loading art.

## Constraints to know

- Unreal Engine needs an Epic Games account linked to GitHub to get the engine. Its EULA charges royalties on games, and whether that applies when Unreal is only used to render art for a non-Unreal game should be confirmed with Epic before release. Blender has no such terms, so the pipeline works with Blender alone, and Unreal is optional for hero assets.
- The sprite art is new work and can carry its own licence. The game code stays GPL-2.0.
