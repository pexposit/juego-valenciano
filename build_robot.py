import bpy
from math import radians, cos, sin, pi
from mathutils import Vector

# --- clean up: default cube and any previous robot -------------------------
for name in ("Cube",):
    o = bpy.data.objects.get(name)
    if o:
        bpy.data.objects.remove(o, do_unlink=True)
old = bpy.data.collections.get("Robot")
if old:
    for o in list(old.objects):
        bpy.data.objects.remove(o, do_unlink=True)
    bpy.data.collections.remove(old)

col = bpy.data.collections.new("Robot")
bpy.context.scene.collection.children.link(col)
layer_col = bpy.context.view_layer.layer_collection.children[col.name]
bpy.context.view_layer.active_layer_collection = layer_col


# --- materials ---------------------------------------------------------------
def mat(name, color, rough=0.4, metal=0.0, emit=0.0):
    m = bpy.data.materials.get(name) or bpy.data.materials.new(name)
    if m.node_tree is None:
        m.use_nodes = True
    bsdf = next(n for n in m.node_tree.nodes if n.type == 'BSDF_PRINCIPLED')
    bsdf.inputs["Base Color"].default_value = (*color, 1)
    bsdf.inputs["Roughness"].default_value = rough
    bsdf.inputs["Metallic"].default_value = metal
    if emit:
        bsdf.inputs["Emission Color"].default_value = (*color, 1)
        bsdf.inputs["Emission Strength"].default_value = emit
    m.diffuse_color = (*color, 1)
    return m

WHITE  = mat("Robot_White",  (0.80, 0.80, 0.82), rough=0.35)
METAL  = mat("Robot_Metal",  (0.55, 0.57, 0.60), rough=0.3, metal=0.9)
SCREEN = mat("Robot_Screen", (0.008, 0.012, 0.035), rough=0.15)
FACE   = mat("Robot_Face",   (0.45, 0.80, 0.95), rough=0.3, emit=0.4)
CHEEK  = mat("Robot_Cheek",  (0.95, 0.30, 0.38), rough=0.5, emit=0.2)
YELLOW = mat("Robot_Yellow", (0.85, 0.65, 0.10), rough=0.4)
RED    = mat("Robot_Red",    (0.80, 0.02, 0.02), rough=0.35)
BLUE   = mat("Robot_Blue",   (0.02, 0.12, 0.60), rough=0.35)
BALL   = mat("Robot_Ball",   (1.00, 0.30, 0.30), rough=0.3)
GOLD   = mat("Flag_Gold",    (0.90, 0.62, 0.05), rough=0.4)
FRED   = mat("Flag_Red",     (0.75, 0.03, 0.02), rough=0.4)
FBLUE  = mat("Flag_Blue",    (0.03, 0.10, 0.55), rough=0.4)


# --- helper ------------------------------------------------------------------
def add(prim, name, loc, scale=(1, 1, 1), rot=(0, 0, 0), m=None, bevel=0.0, segs=6, **kw):
    getattr(bpy.ops.mesh, f"primitive_{prim}_add")(location=loc, rotation=rot, **kw)
    o = bpy.context.active_object
    o.name = name
    o.scale = scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    if bevel:
        b = o.modifiers.new("Bevel", 'BEVEL')
        b.width = bevel
        b.segments = segs
        b.limit_method = 'ANGLE'
    if m:
        o.data.materials.append(m)
    bpy.ops.object.shade_smooth_by_angle()
    return o


# --- body --------------------------------------------------------------------
add("cylinder", "Base", (0, 0, 0.06), m=BLUE, bevel=0.04, radius=0.5, depth=0.12, vertices=64)
add("cylinder", "Body", (0, 0, 0.80), m=WHITE, bevel=0.32, segs=10, radius=0.68, depth=1.35, vertices=64)
add("cylinder", "Neck", (0, 0, 1.55), m=METAL, bevel=0.03, radius=0.28, depth=0.25, vertices=48)

# arms (shoulder joint, upper arm, hand)
for side in (-1, 1):
    sx = "L" if side < 0 else "R"
    add("cylinder", f"Shoulder.{sx}", (side * 0.68, 0, 1.15), rot=(0, pi / 2, 0),
        m=METAL, bevel=0.02, radius=0.11, depth=0.12, vertices=32)
    add("uv_sphere", f"Arm.{sx}", (side * 0.84, 0, 0.84), scale=(0.15, 0.15, 0.36),
        rot=(0, -side * 0.3, 0), m=WHITE, segments=32, ring_count=16)
    add("uv_sphere", f"Hand.{sx}", (side * 0.97, -0.02, 0.45), m=YELLOW,
        radius=0.2, segments=32, ring_count=16)

# Valencian senyera badge on the chest
fx, fz, fw, fh = -0.05, 0.95, 0.50, 0.42
add("cube", "Flag_Plate", (fx, -0.66, fz), scale=(fw / 2, 0.03, fh / 2), m=GOLD, bevel=0.02, size=1 * 2)
band = fh / 9
for i in range(4):
    z = fz + fh / 2 - band * (1.5 + 2 * i)
    add("cube", f"Flag_Stripe.{i}", (fx + 0.06, -0.695, z), scale=((fw - 0.12) / 2 - 0.02, 0.01, band / 2),
        m=FRED, size=2)
add("cube", "Flag_Blue", (fx - fw / 2 + 0.07, -0.695, fz), scale=(0.05, 0.01, fh / 2 - 0.02), m=FBLUE, size=2)


# --- head --------------------------------------------------------------------
add("cube", "Head", (0, 0, 2.30), scale=(0.95, 0.60, 0.675), m=WHITE, bevel=0.32, segs=10, size=2)
add("cube", "Screen", (0, -0.58, 2.30), scale=(0.725, 0.05, 0.475), m=SCREEN, bevel=0.12, segs=8, size=2)

for side in (-1, 1):
    sx = "L" if side < 0 else "R"
    add("uv_sphere", f"Eye.{sx}", (side * 0.32, -0.625, 2.42), scale=(0.12, 0.03, 0.17),
        m=FACE, segments=32, ring_count=16)
    add("uv_sphere", f"Cheek.{sx}", (side * 0.52, -0.628, 2.20), scale=(0.09, 0.015, 0.06),
        m=CHEEK, segments=24, ring_count=12)
    # ears: yellow disc + red button
    add("cylinder", f"Ear.{sx}", (side * 0.99, 0, 2.30), rot=(0, pi / 2, 0),
        m=YELLOW, bevel=0.04, radius=0.27, depth=0.14, vertices=48)
    add("cylinder", f"EarButton.{sx}", (side * 1.07, 0, 2.30), rot=(0, pi / 2, 0),
        m=RED, bevel=0.025, radius=0.12, depth=0.06, vertices=32)

# smile as a bevelled curve arc
cu = bpy.data.curves.new("Smile", 'CURVE')
cu.dimensions = '3D'
cu.bevel_depth = 0.025
cu.bevel_resolution = 4
cu.use_fill_caps = True
sp = cu.splines.new('POLY')
n = 20
sp.points.add(n - 1)
for i in range(n):
    a = radians(200 + 140 * i / (n - 1))
    sp.points[i].co = (0.2 * cos(a), -0.635, 2.30 + 0.2 * sin(a), 1)
smile = bpy.data.objects.new("Smile", cu)
col.objects.link(smile)
cu.materials.append(FACE)

# antenna
add("cylinder", "Antenna_Base", (0, 0, 2.99), m=METAL, bevel=0.02, radius=0.12, depth=0.08, vertices=32)
add("cylinder", "Antenna_Rod", (0, 0, 3.16), m=METAL, radius=0.025, depth=0.3, vertices=16)
add("torus", "Antenna_Ring", (0, 0, 3.22), rot=(pi / 2, 0, 0), m=METAL,
    major_radius=0.07, minor_radius=0.018)
add("uv_sphere", "Antenna_Ball", (0, 0, 3.36), m=BALL, radius=0.08, segments=32, ring_count=16)


# --- camera, lights, world ---------------------------------------------------
scene = bpy.context.scene
scene.render.resolution_x = scene.render.resolution_y = 1024

cam = bpy.data.objects.get("Camera")
if cam:
    cam.location = (-2.6, -7.6, 2.4)
    cam.data.lens = 55
    aim_target = (0, 0, 1.72)
    scene.camera = cam

def aim(obj, target=(0, 0, 1.7)):
    d = Vector(target) - obj.location
    obj.rotation_euler = d.to_track_quat('-Z', 'Y').to_euler()

if cam:
    aim(cam, aim_target)
scene.view_settings.view_transform = 'Standard'

key = bpy.data.objects.get("Light")
if key:
    key.data.type = 'AREA'
    key.data.energy = 600
    key.data.size = 4
    key.location = (3.5, -5, 6)
    aim(key)

fill_data = bpy.data.lights.new("Robot_Fill", 'AREA')
fill_data.energy = 250
fill_data.size = 5
fill = bpy.data.objects.new("Robot_Fill", fill_data)
col.objects.link(fill)
fill.location = (-5, -4, 3)
aim(fill)

world = scene.world or bpy.data.worlds.new("World")
scene.world = world
if world.node_tree is None:
    world.use_nodes = True
bg = next(n for n in world.node_tree.nodes if n.type == 'BACKGROUND')
bg.inputs["Color"].default_value = (0.9, 0.9, 0.9, 1)
bg.inputs["Strength"].default_value = 0.5

print("Robot built")

