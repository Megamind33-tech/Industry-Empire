# Art pipeline

Blender (4.2 LTS, headless) renders every model from the game's fixed camera. The phone only draws the finished sprites. See `docs/VISUAL_PIPELINE.md`.

- `blender/te_render.py` sets up the scene: an orthographic camera at 30° elevation and 45° yaw (the engine's 2:1 tile), a warm sun, sky light and a shadow catcher. It renders 8 directions at 4x zoom, then a company-colour mask pass.
- `blender/models/*.py` hold procedural models. Paint that takes the company colour sets `te_company_colour` on its material.
- `tools/pack_vehicle.py` crops, computes offsets, downscales to 2x and 1x, writes the 8bpp company-colour masks and an 8bpp fallback, and generates the NML templates.
- `grf/` holds the NML source and the packed sprite sheets. `build.sh` runs the whole chain into `build/transport_empire.grf`.

Requirements: Blender 4.2+, Python 3 with Pillow, `nml` (`pip install nml`), and `cpp`.
