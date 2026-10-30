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
    scene.render.use_persistent_data = True  # keep BVH and textures between the 8 direction renders
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
    for obj in list(root.children_recursive):
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


# Target length in tiles per asset category, used to normalise imported models.
CATEGORY_LENGTH = {"road_vehicle": 0.42, "train_engine": 0.9, "train_wagon": 0.9, "ship": 0.9, "aircraft": 0.8}


def import_model(path, category, yaw_deg, paint_re):
    """Import a downloaded .glb/.gltf/.fbx/.obj/.blend, scale it to game size and mark company paint."""
    import re
    before = set(bpy.data.objects)
    ext = os.path.splitext(path)[1].lower()
    if ext in (".glb", ".gltf"):
        bpy.ops.import_scene.gltf(filepath=path)
    elif ext == ".fbx":
        bpy.ops.import_scene.fbx(filepath=path)
    elif ext == ".obj":
        bpy.ops.wm.obj_import(filepath=path)
    elif ext == ".blend":
        with bpy.data.libraries.load(path) as (src, dst):
            dst.objects = src.objects
        for o in dst.objects:
            bpy.context.scene.collection.objects.link(o)
    meshes = [o for o in set(bpy.data.objects) - before if o.type == "MESH"]
    root = bpy.data.objects.new("Imported", None)
    bpy.context.scene.collection.objects.link(root)
    for o in meshes:
        mw = o.matrix_world.copy()
        o.parent = root
        o.matrix_world = mw
    bpy.context.view_layer.update()
    from mathutils import Vector
    pts = [o.matrix_world @ Vector(c) for o in meshes for c in o.bound_box]
    lo = Vector((min(p.x for p in pts), min(p.y for p in pts), min(p.z for p in pts)))
    hi = Vector((max(p.x for p in pts), max(p.y for p in pts), max(p.z for p in pts)))
    length = max(hi.x - lo.x, hi.y - lo.y)
    scale = CATEGORY_LENGTH.get(category, 0.5) / length
    centre = Vector(((lo.x + hi.x) / 2, (lo.y + hi.y) / 2, lo.z))
    for o in meshes:
        o.location = (o.location - centre)
    bpy.context.view_layer.update()
    pivot = bpy.data.objects.new("Model", None)
    bpy.context.scene.collection.objects.link(pivot)
    root.parent = pivot
    root.scale = (scale,) * 3
    root.rotation_euler = (0, 0, math.radians(yaw_deg))
    rx = re.compile(paint_re, re.I)
    for o in meshes:
        for slot in o.material_slots:
            if slot.material and rx.search(slot.material.name):
                slot.material["te_company_colour"] = True
    return pivot


def main():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    ap = argparse.ArgumentParser()
    ap.add_argument("--model", required=True, help="procedural module name, or a path to a model file")
    ap.add_argument("--category", default="road_vehicle")
    ap.add_argument("--yaw", type=float, default=0, help="degrees to turn an imported model so its front faces +X")
    ap.add_argument("--paint", default="paint|body|carpaint|livery", help="regex for company-colour materials")
    ap.add_argument("--out", required=True)
    ap.add_argument("--samples", type=int, default=96)
    args = ap.parse_args(argv)
    os.makedirs(args.out, exist_ok=True)

    scene = reset_scene()
    scene.cycles.samples = args.samples
    add_camera(scene)
    add_lighting(scene)
    if os.path.exists(args.model):
        root = import_model(os.path.abspath(args.model), args.category, args.yaw, args.paint)
    else:
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
