# Art pipeline

Blender (4.2 LTS, headless) renders every model from the game's fixed camera. The phone only draws the finished sprites. See `docs/VISUAL_PIPELINE.md`.

- `blender/te_render.py` sets up the scene: an orthographic camera at 30° elevation and 45° yaw (the engine's 2:1 tile), a warm sun, sky light and a shadow catcher. It renders 8 directions at 4x zoom, then a company-colour mask pass.
- `blender/models/*.py` hold procedural models. Paint that takes the company colour sets `te_company_colour` on its material.
- `tools/pack_vehicle.py` crops, computes offsets, downscales to 2x and 1x, writes the 8bpp company-colour masks and an 8bpp fallback, and generates the NML templates.
- `grf/` holds the NML source and the packed sprite sheets. `build.sh` runs the whole chain into `build/transport_empire.grf`.

Requirements: Blender 4.2+, Python 3 with Pillow, `nml` (`pip install nml`), and `cpp`.

## Fast workflow

1. `assets.csv` lists every asset the game needs (381 rows, from `tools/inventory.py`). Set `model` and `status` there.
2. Drop a model in `models/<id>/` and set `model` to `models/<id>/file.glb;yaw=90;paint=Body`. `yaw` turns its front to +X; `paint` is a regex of material names that take the company colour. The importer scales it to game size by category.
3. Run `BLENDER=... python3 -I tools/render_all.py --draft` for quick 16-sample checks, then without `--draft` for final renders. Renders run in parallel and unchanged assets are skipped by hash.
4. Run `build.sh` to compile the NewGRF.

A draft render of one vehicle (8 directions plus mask) takes about 15 s on 2 cores. Final quality takes about 45 s.
