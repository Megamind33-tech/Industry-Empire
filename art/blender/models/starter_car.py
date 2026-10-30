"""The player's first vehicle: a compact hatchback, built procedurally.

Scale: 1 Blender unit = 1 tile. Front of the car points along +X.
The body paint carries `te_company_colour` so the mask pass marks it for recolouring.
"""
import bpy

L, W, H = 0.42, 0.19, 0.145   # overall length, width, height
WHEEL_R, WHEEL_W = 0.034, 0.024
CLEAR = 0.012                  # ground clearance under the sills


def mat(name, color, metallic=0.0, rough=0.5, emit=None, coat=0.0, transmission=0.0, company=False):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    p = m.node_tree.nodes["Principled BSDF"]
    p.inputs["Base Color"].default_value = (*color, 1)
    p.inputs["Metallic"].default_value = metallic
    p.inputs["Roughness"].default_value = rough
    p.inputs["Coat Weight"].default_value = coat
    p.inputs["Transmission Weight"].default_value = transmission
    if emit:
        p.inputs["Emission Color"].default_value = (*emit, 1)
        p.inputs["Emission Strength"].default_value = 6.0
    if company:
        m["te_company_colour"] = True
    return m


def box(name, size, loc, material, bevel=0.0, segments=3, parent=None):
    bpy.ops.mesh.primitive_cube_add(size=1, location=loc)
    o = bpy.context.active_object
    o.name = name
    o.scale = size
    bpy.ops.object.transform_apply(scale=True)
    if bevel:
        b = o.modifiers.new("bevel", "BEVEL")
        b.width = bevel
        b.segments = segments
        b.limit_method = "ANGLE"
    o.data.materials.append(material)
    bpy.ops.object.shade_smooth()
    o.parent = parent
    return o


def taper_top(o, front_in, rear_in, side_in):
    """Pull the top face's vertices inwards to form a sloped greenhouse."""
    zs = [v.co.z for v in o.data.vertices]
    top = max(zs)
    for v in o.data.vertices:
        if abs(v.co.z - top) < 1e-6:
            v.co.x -= front_in if v.co.x > 0 else -rear_in
            v.co.y *= 1 - side_in


def build():
    paint = mat("TE_Paint", (0.42, 0.42, 0.42), metallic=0.55, rough=0.28, coat=1.0, company=True)
    glass = mat("TE_Glass", (0.03, 0.05, 0.07), rough=0.05, metallic=0.2)
    trim = mat("TE_Trim", (0.02, 0.02, 0.02), rough=0.6)
    rubber = mat("TE_Tyre", (0.015, 0.015, 0.015), rough=0.85)
    rim = mat("TE_Rim", (0.7, 0.7, 0.72), metallic=1.0, rough=0.25)
    head = mat("TE_Headlight", (0.9, 0.9, 0.85), emit=(1.0, 0.95, 0.8))
    tail = mat("TE_Taillight", (0.5, 0.02, 0.02), emit=(0.8, 0.02, 0.01))
    chrome = mat("TE_Chrome", (0.9, 0.9, 0.9), metallic=1.0, rough=0.1)

    root = bpy.data.objects.new("StarterCar", None)
    bpy.context.scene.collection.objects.link(root)

    body_h = 0.065
    body_z = CLEAR + WHEEL_R * 0.6 + body_h / 2
    box("Body", (L, W, body_h), (0, 0, body_z), paint, bevel=0.018, segments=4, parent=root)

    # Cabin: glass block with a painted roof and pillars, tapered for windscreen and hatch.
    cab_h = H - (body_z + body_h / 2)
    cab_z = body_z + body_h / 2 + cab_h / 2
    cab = box("Cabin", (L * 0.58, W * 0.9, cab_h), (-L * 0.06, 0, cab_z), glass, bevel=0.01, parent=root)
    taper_top(cab, front_in=0.06, rear_in=0.025, side_in=0.12)
    roof = box("Roof", (L * 0.42, W * 0.8, 0.008), (-L * 0.075, 0, H - 0.004), paint, bevel=0.004, parent=root)
    roof.scale = (1, 1, 1)

    # Bumpers, sills, grille.
    for sx in (1, -1):
        box(f"Bumper{sx}", (0.02, W * 1.01, 0.022), (sx * (L / 2 - 0.006), 0, body_z - body_h * 0.32), trim, bevel=0.006, parent=root)
    for sy in (1, -1):
        box(f"Sill{sy}", (L * 0.62, 0.006, 0.012), (0, sy * W / 2, CLEAR + 0.02), trim, bevel=0.003, parent=root)
        box(f"Mirror{sy}", (0.012, 0.016, 0.01), (L * 0.13, sy * (W / 2 + 0.008), body_z + body_h / 2 + 0.01), paint, bevel=0.003, parent=root)
    box("Grille", (0.004, W * 0.45, 0.018), (L / 2 + 0.001, 0, body_z + 0.004), chrome, parent=root)

    # Lights.
    for sy in (1, -1):
        box(f"Head{sy}", (0.006, 0.035, 0.014), (L / 2 - 0.001, sy * W * 0.36, body_z + 0.01), head, bevel=0.003, parent=root)
        box(f"Tail{sy}", (0.006, 0.03, 0.02), (-L / 2 + 0.001, sy * W * 0.38, body_z + 0.012), tail, bevel=0.003, parent=root)

    # Wheels.
    for sx in (1, -1):
        for sy in (1, -1):
            x, y = sx * L * 0.31, sy * (W / 2 - WHEEL_W / 2 + 0.003)
            bpy.ops.mesh.primitive_cylinder_add(radius=WHEEL_R, depth=WHEEL_W, vertices=32,
                                                location=(x, y, WHEEL_R), rotation=(1.5708, 0, 0))
            t = bpy.context.active_object
            t.data.materials.append(rubber)
            bpy.ops.object.shade_smooth()
            t.parent = root
            bpy.ops.mesh.primitive_cylinder_add(radius=WHEEL_R * 0.62, depth=WHEEL_W * 1.06, vertices=24,
                                                location=(x, y, WHEEL_R), rotation=(1.5708, 0, 0))
            r = bpy.context.active_object
            r.data.materials.append(rim)
            r.parent = root
    return root
