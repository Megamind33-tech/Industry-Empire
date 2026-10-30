"""Transport Empire sprite renderer.

Run headless:
  blender -b -P art/blender/te_render.py -- --model starter_car --out art/build/starter_car

Builds the model, then renders it from the game's fixed dimetric camera in the
8 vehicle directions at 4x zoom, plus a company-colour mask for each direction.
Lighting, shadows and GI are baked here so the phone only blits images.
"""
import argparse
import importlib
import math
import os
import sys

import bpy

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "models"))

# 4x zoom: one tile (1 Blender unit) is 256 px wide on screen.
PX_PER_UNIT = 256 / math.sqrt(2)
FRAME_PX = 192

# Game direction order N, NE, E, SE, S, SW, W, NW as (dx, dy) in game axes.
# Game +x is screen down-left, +y is screen down-right; Blender uses the same axes.
DIRECTIONS = [(-1, -1), (-1, 0), (-1, 1), (0, 1), (1, 1), (1, 0), (1, -1), (0, -1)]


def reset_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    scene = bpy.context.scene
    scene.render.engine = "CYCLES"
    scene.cycles.device = "CPU"
    scene.cycles.samples = 96
    scene.cycles.use_denoising = True
    scene.render.film_transparent = True
    scene.render.resolution_x = scene.render.resolution_y = FRAME_PX
    scene.render.image_settings.file_format = "PNG"
    scene.render.image_settings.color_mode = "RGBA"
    scene.view_settings.view_transform = "AgX"
    scene.view_settings.look = "AgX - Punchy"
    return scene


def add_camera(scene):
    cam_data = bpy.data.cameras.new("TE_Camera")
    cam_data.type = "ORTHO"
    cam_data.ortho_scale = FRAME_PX / PX_PER_UNIT
    cam = bpy.data.objects.new("TE_Camera", cam_data)
    # Elevation 30 deg gives the engine's exact 2:1 tile diamond; yaw puts +x down-left.
    cam.rotation_euler = (math.radians(60), 0, math.radians(135))
    d = 10
    cam.location = (d * math.cos(math.radians(30)) / math.sqrt(2),) * 2 + (d * math.sin(math.radians(30)),)
    scene.collection.objects.link(cam)
    scene.camera = cam


def add_lighting(scene):
    # Late-afternoon sun from the upper left of the screen: shadows fall lower-right, as in the engine.
    sun = bpy.data.objects.new("TE_Sun", bpy.data.lights.new("TE_Sun", "SUN"))
    sun.data.energy = 4.5
    sun.data.angle = math.radians(2.5)
    sun.data.color = (1.0, 0.93, 0.82)
    sun.rotation_euler = (math.radians(48), 0, math.radians(15))
    scene.collection.objects.link(sun)
    # Real sky light from a CC0 Poly Haven HDRI gives natural bounce and reflections.
    world = bpy.data.worlds.new("TE_Sky")
    world.use_nodes = True
    nt = world.node_tree
    bg = nt.nodes["Background"]
    bg.inputs["Strength"].default_value = 0.7
    env = nt.nodes.new("ShaderNodeTexEnvironment")
    env.image = bpy.data.images.load(os.path.join(HERE, "hdri", "kloofendal_48d_partly_cloudy_puresky_1k.hdr"))
    nt.links.new(env.outputs["Color"], bg.inputs["Color"])
    scene.world = world
    # Shadow catcher: soft contact shadows baked into the sprite alpha.
    bpy.ops.mesh.primitive_plane_add(size=3)
    ground = bpy.context.active_object
    ground.is_shadow_catcher = True


def mask_materials(root, on):
    """Swap every material to flat white (company paint) or black for the mask pass."""
    for obj in [root] + list(root.children_recursive):
        for slot in getattr(obj, "material_slots", []):
            mat = slot.material
            if mat is None:
                continue
            if on:
                mat["te_saved"] = mat.name
                paint = mat.get("te_company_colour", False)
                slot.material = _flat(1.0 if paint else 0.0)
    return root


_flat_cache = {}


def _flat(v):
    if v not in _flat_cache:
        m = bpy.data.materials.new(f"TE_Flat_{v}")
        m.use_nodes = True
        nt = m.node_tree
        nt.nodes.clear()
        em = nt.nodes.new("ShaderNodeEmission")
        em.inputs["Color"].default_value = (v, v, v, 1)
        out = nt.nodes.new("ShaderNodeOutputMaterial")
        nt.links.new(em.outputs[0], out.inputs[0])
        _flat_cache[v] = m
    return _flat_cache[v]


def render_directions(scene, root, out_dir, prefix):
    for i, (dx, dy) in enumerate(DIRECTIONS):
        root.rotation_euler = (0, 0, math.atan2(dy, dx))
        scene.render.filepath = os.path.join(out_dir, f"{prefix}_{i}.png")
        bpy.ops.render.render(write_still=True)


def main():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    ap = argparse.ArgumentParser()
    ap.add_argument("--model", required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--samples", type=int, default=96)
    args = ap.parse_args(argv)
    os.makedirs(args.out, exist_ok=True)

    scene = reset_scene()
    scene.cycles.samples = args.samples
    add_camera(scene)
    add_lighting(scene)
    root = importlib.import_module(args.model).build()
    render_directions(scene, root, args.out, "rgba")

    # Mask pass: no lighting, no shadow, no AA blur beyond 1 sample.
    scene.cycles.samples = 1
    scene.cycles.use_denoising = False
    scene.render.filter_size = 0.01
    scene.view_settings.view_transform = "Standard"
    scene.view_settings.look = "None"
    for o in scene.objects:
        if o.is_shadow_catcher:
            o.hide_render = True
    mask_materials(root, True)
    render_directions(scene, root, args.out, "mask")


if __name__ == "__main__":
    main()
