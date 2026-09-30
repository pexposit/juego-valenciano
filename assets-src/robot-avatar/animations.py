"""
[robot-avatar] Genera (o regenera) les animacions del robot sobre robot_avatar.blend.

Ús (des d'aquesta carpeta):
    blender -b robot_avatar.blend --python animations.py      # rebake + desa el .blend
    blender -b robot_avatar.blend --python export_glb.py      # exporta el GLB per al frontend

Cada clip és una funció f(t) (t en [0,1)) que retorna la pose dels ossos:
    {os: dict(rot=[(eix_món, graus), ...], loc=(x,y,z) desplaçament en món, scl=(ample, alt, fons))}
Les funcions són periòdiques, així els bucles no tenen salts. Capes (han de coincidir amb
frontend/src/features/robot-avatar/states.ts):
    body_*  → root, body, head, antenna, arm_L, arm_R
    eyes_*  → eye_L, eye_R
    mouth_* → mouth
Eixos del món (Blender, Z amunt): X dreta del robot vist de front, Y cap al fons, Z amunt.
Braç dret: angle negatiu sobre Y l'alça cap a fora; braç esquerre: angle positiu.
"""
import math
import bpy
from mathutils import Matrix, Vector

rig = bpy.data.objects["Robot_Rig"]
bpy.context.scene.render.fps = 30
TAU = 2 * math.pi


def S(t, k=1, ph=0.0):
    return math.sin(TAU * k * t + ph)


def C(t, k=1, ph=0.0):
    return math.cos(TAU * k * t + ph)


def pulse(t, c, w=0.035):
    return max(0.0, 1 - abs(t - c) / w)


def smooth(x):
    x = min(1.0, max(0.0, x))
    return x * x * (3 - 2 * x)


AX = {"X": Vector((1, 0, 0)), "Y": Vector((0, 1, 0)), "Z": Vector((0, 0, 1))}
BODY = ["root", "body", "head", "antenna", "arm_L", "arm_R"]
EYES = ["eye_L", "eye_R"]
MOUTH = ["mouth"]


# ── Cos ────────────────────────────────────────────────────────────────────
def body_idle(t):  # respiració suau, mira al voltant
    return {"body": dict(loc=(0, 0, 0.035 * S(t)), rot=[("Y", 1.5 * S(t, 1, 1))]),
            "head": dict(rot=[("Z", 5 * S(t)), ("Y", 3 * S(t, 1, 0.7)), ("X", 2 * S(t, 2))]),
            "antenna": dict(rot=[("X", 8 * S(t, 2)), ("Y", 6 * S(t, 1, 1))]),
            "arm_L": dict(rot=[("Y", 4 * S(t))]), "arm_R": dict(rot=[("Y", -4 * S(t, 1, 0.5))])}


def body_wave(t):  # saluda amb la mà dreta
    return {"body": dict(loc=(0, 0, 0.03 * S(t, 2)), rot=[("Y", 3)]),
            "head": dict(rot=[("Y", 6 + 2 * S(t, 2)), ("Z", 6)]),
            "antenna": dict(rot=[("Y", 12 * S(t, 2, 0.6))]),
            "arm_L": dict(rot=[("Y", 6 + 2 * S(t))]),
            "arm_R": dict(rot=[("Y", -118 + 22 * S(t, 2))])}


def body_happy(t):  # bot d'alegria (una sola vegada)
    h = math.sin(math.pi * (t - 0.15) / 0.7) if 0.15 <= t <= 0.85 else 0.0
    sq = max(pulse(t, 0.07, 0.08), pulse(t, 0.93, 0.08))
    up = smooth((t - 0.05) / 0.2) * (1 - smooth((t - 0.8) / 0.18))
    return {"root": dict(loc=(0, 0, 0.5 * h), scl=(1 + 0.08 * sq, 1 - 0.14 * sq, 1 + 0.08 * sq)),
            "body": dict(rot=[("Y", 4 * S(t))]),
            "head": dict(rot=[("X", -10 * h), ("Y", 6 * S(t))]),
            "antenna": dict(rot=[("X", -25 * h + 10 * sq)]),
            "arm_L": dict(rot=[("Y", 125 * up)]), "arm_R": dict(rot=[("Y", -125 * up)])}


def body_confused(t):  # inclina el cap i es rasca prop de l'orella
    return {"body": dict(loc=(0, 0, 0.02 * S(t)), rot=[("Y", -3)]),
            "head": dict(rot=[("Y", -13 + 3 * S(t)), ("Z", -8 + 4 * S(t, 1, 1))]),
            "antenna": dict(rot=[("X", 22 + 5 * S(t, 2))]),
            "arm_L": dict(rot=[("Y", 14 + 2 * S(t))]),
            "arm_R": dict(rot=[("Y", -108 + 9 * S(t, 3))])}


def body_thinking(t):  # mira amunt i balanceja l'antena en cercle
    return {"body": dict(loc=(0, 0, 0.02 * S(t)), rot=[("Y", 2 * S(t))]),
            "head": dict(rot=[("X", -6), ("Y", -8 + 3 * S(t)), ("Z", 10 * S(t))]),
            "antenna": dict(rot=[("X", 10 * C(t, 2)), ("Y", 10 * S(t, 2))]),
            "arm_L": dict(rot=[("Y", 8 + 2 * S(t))]), "arm_R": dict(rot=[("Y", -8 - 2 * S(t))])}


# ── Ulls ───────────────────────────────────────────────────────────────────
def eyes(t, sx, sz, dx, dz, blinks):
    b = max([pulse(t, c) for c in blinks] + [0])
    return {"eye_L": dict(loc=(dx[0], 0, dz[0]), scl=(sx[0], sz[0] * (1 - 0.9 * b), 1)),
            "eye_R": dict(loc=(dx[1], 0, dz[1]), scl=(sx[1], sz[1] * (1 - 0.9 * b), 1))}


def eyes_neutral(t):
    g = 0.025 * S(t)
    return eyes(t, (1, 1), (1, 1), (g, g), (0, 0), [0.62])


def eyes_happy(t):
    p = 1.12 + 0.06 * S(t, 2)
    return eyes(t, (p, p), (p, p), (0, 0), (0.02, 0.02), [0.8])


def eyes_confused(t):
    g = 0.035 * S(t)
    return eyes(t, (0.9, 1.1), (0.7, 1.15), (g, g), (-0.02, 0.015), [0.7])


def eyes_thinking(t):
    g = 0.02 * S(t)
    return eyes(t, (0.9, 0.9), (0.9, 0.9), (0.06 + g, 0.06 + g), (0.07, 0.07), [0.5])


# ── Boca ───────────────────────────────────────────────────────────────────
def mouth(sx, sz, dx=0.0, rot=0.0):
    return {"mouth": dict(loc=(dx, 0, 0), scl=(sx, sz, 1), rot=[("Y", rot)])}


def mouth_neutral(t): return mouth(1, 1 + 0.05 * S(t))
def mouth_happy(t): return mouth(1.35 + 0.03 * S(t, 2), 1.6 + 0.08 * S(t, 2))
def mouth_confused(t): return mouth(0.8, -0.55, 0.02 * S(t), 10 + 3 * S(t))
def mouth_thinking(t): return mouth(0.55 + 0.05 * S(t), 0.35, 0.08)


def mouth_talk(t):
    o = abs(0.6 * S(t, 1) + 0.4 * S(t, 3, 0.8))
    return mouth(1 - 0.15 * o, 0.35 + 1.1 * o)


# (nom, funció, frames a 30 fps, ossos, bucle)
CLIPS = [
    ("body_idle", body_idle, 120, BODY, True), ("body_wave", body_wave, 60, BODY, True),
    ("body_happy", body_happy, 45, BODY, False), ("body_confused", body_confused, 90, BODY, True),
    ("body_thinking", body_thinking, 120, BODY, True),
    ("eyes_neutral", eyes_neutral, 150, EYES, True), ("eyes_happy", eyes_happy, 90, EYES, True),
    ("eyes_confused", eyes_confused, 120, EYES, True), ("eyes_thinking", eyes_thinking, 120, EYES, True),
    ("mouth_neutral", mouth_neutral, 60, MOUTH, True), ("mouth_happy", mouth_happy, 60, MOUTH, True),
    ("mouth_confused", mouth_confused, 90, MOUTH, True), ("mouth_thinking", mouth_thinking, 90, MOUTH, True),
    ("mouth_talk", mouth_talk, 24, MOUTH, True),
]


def apply(pb, spec):
    r0 = rig.data.bones[pb.name].matrix_local.to_3x3()
    ri = r0.inverted()
    rw = Matrix.Identity(3)
    for ax, deg in spec.get("rot", []):
        rw = Matrix.Rotation(math.radians(deg), 3, AX[ax]) @ rw
    pb.rotation_quaternion = (ri @ rw @ r0).to_quaternion()
    pb.location = ri @ Vector(spec.get("loc", (0, 0, 0)))
    pb.scale = spec.get("scl", (1, 1, 1))  # eix local Y = direcció de l'os (vertical)


def bake():
    rig.animation_data_create()
    for tr in list(rig.animation_data.nla_tracks):
        rig.animation_data.nla_tracks.remove(tr)
    names = {c[0] for c in CLIPS}
    for a in list(bpy.data.actions):
        if a.name.split(".")[0] in names:
            bpy.data.actions.remove(a)
    for pb in rig.pose.bones:
        pb.rotation_mode = 'QUATERNION'
    for name, fn, n, bones, loop in CLIPS:
        act = bpy.data.actions.new(name)
        act.use_fake_user = True
        rig.animation_data.action = act
        for f in range(n + 1):
            spec = fn((f % n) / n if loop else f / n)
            for b in bones:
                pb = rig.pose.bones[b]
                apply(pb, spec.get(b, {}))
                for dp in ("location", "rotation_quaternion", "scale"):
                    pb.keyframe_insert(dp, frame=f + 1)
        tr = rig.animation_data.nla_tracks.new()
        tr.name = name
        tr.strips.new(name, 1, act)
        tr.mute = True
        rig.animation_data.action = None
    for pb in rig.pose.bones:
        pb.location = (0, 0, 0)
        pb.rotation_quaternion = (1, 0, 0, 0)
        pb.scale = (1, 1, 1)


bake()
if bpy.data.filepath:
    bpy.ops.wm.save_mainfile()
print("[robot-avatar] clips:", [c[0] for c in CLIPS])
