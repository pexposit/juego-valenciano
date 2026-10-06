"""
[robot-avatar] Versions del robot amb roba d'escenari.

    blender -b --factory-startup --python robot_outfits.py -- mercat            # GLB  -> robot-mercat.glb
    blender -b robot_avatar.blend --python robot_outfits.py -- mercat --png     # imatge -> robot-mercat.webp

Roba disponible: vegeu OUTFITS al final (una entrada per escenari).
El GLB es fa a partir de robot.glb (no toca el .blend). Cada peça va enganxada a un os
del rig, així que seguix totes les animacions. La imatge es renderitza amb la càmera i
les llums del .blend, igual que robot.png (és la que es veu mentre carrega el 3D).
"""
import os
import sys
import bpy

OUT_DIR = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                        "..", "..", "frontend", "public", "avatar-robot"))
SRC = os.path.join(OUT_DIR, "robot.glb")
# Malles comprimides amb Draco, igual que robot.glb (export_glb.py); el frontend les
# descomprimix amb DRACOLoader. Les imatges de càrrega es desen en WebP (pesen ~5 vegades menys).
DRACO = dict(export_draco_mesh_compression_enable=True, export_draco_mesh_compression_level=7,
             export_draco_position_quantization=14, export_draco_normal_quantization=10,
             export_draco_texcoord_quantization=12)


def mat(name, color, rough=0.6, metal=0.0, emit=0.0):
    m = bpy.data.materials.new(name)
    if m.node_tree is None:
        m.use_nodes = True
    b = next(n for n in m.node_tree.nodes if n.type == 'BSDF_PRINCIPLED')
    b.inputs["Base Color"].default_value = (*color, 1)
    b.inputs["Roughness"].default_value = rough
    b.inputs["Metallic"].default_value = metal
    if emit:
        b.inputs["Emission Color"].default_value = (*color, 1)
        b.inputs["Emission Strength"].default_value = emit
    return m


class Builder:
    """Crea peces en posició de repòs i les enganxa a un os del rig."""

    def __init__(self, rig):
        self.rig = rig
        rig.data.pose_position = 'REST'
        bpy.context.view_layer.update()
        coll = rig.users_collection[0]
        for o in bpy.context.view_layer.objects:
            o.select_set(False)
        bpy.context.view_layer.active_layer_collection = next(
            (lc for lc in bpy.context.view_layer.layer_collection.children if lc.collection == coll),
            bpy.context.view_layer.layer_collection)

    def mesh(self, prim, name, loc, m, scale=(1, 1, 1), rot=(0, 0, 0), bevel=0.0, segs=4, **kw):
        getattr(bpy.ops.mesh, f"primitive_{prim}_add")(location=loc, rotation=rot, **kw)
        o = bpy.context.active_object
        o.name = name
        o.scale = scale
        bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
        if bevel:
            bm = o.modifiers.new("Bevel", 'BEVEL'); bm.width = bevel; bm.segments = segs; bm.limit_method = 'ANGLE'
        o.data.materials.append(m)
        return o

    def cut(self, o, loc, half_size):
        """Resta una caixa a `o` (aplica els modificadors i esborra la caixa)."""
        bpy.ops.mesh.primitive_cube_add(location=loc, size=2)
        cutter = bpy.context.active_object
        cutter.scale = half_size
        bool_mod = o.modifiers.new("Tall", 'BOOLEAN'); bool_mod.object = cutter; bool_mod.operation = 'DIFFERENCE'
        bpy.context.view_layer.objects.active = o
        for mod in list(o.modifiers):
            bpy.ops.object.modifier_apply(modifier=mod.name)
        bpy.data.objects.remove(cutter, do_unlink=True)

    def band(self, name, target, z, height, m, thick=0.03, n=96):
        """Cinta que envolta una malla del robot a l'altura `z`: mesura la secció amb rajos
        des del centre i fa un anell gruixut just per fora (p. ex. una cinta al cap)."""
        from math import pi, cos, sin
        from mathutils import Vector
        # la malla avaluada (amb modificadors), que és la que es veu
        tgt = bpy.data.objects[target].evaluated_get(bpy.context.evaluated_depsgraph_get())
        inv = tgt.matrix_world.inverted()
        def ring(zz, off):
            pts = []
            for i in range(n):
                a = 2 * pi * i / n
                d = Vector((cos(a), sin(a), 0))
                o = Vector((0, 0, zz))
                ok, loc, _, _ = tgt.ray_cast(inv @ o, (inv.to_3x3() @ d).normalized())
                r = ((tgt.matrix_world @ loc) - o).length if ok else 0.9
                pts.append(o + d * (r + off))
            return pts
        # diversos anells en l'altura (per fora, de baix a dalt, i per dins, de dalt a baix)
        # perquè la cinta seguisca la corba de la malla i no la travesse pel mig
        levels = [z - height / 2 + height * t / 4 for t in range(5)]
        rings = [ring(zz, thick) for zz in levels] + [ring(zz, -0.01) for zz in reversed(levels)]
        verts = [v for r in rings for v in r]
        faces = []
        nr = len(rings)
        for k in range(nr):
            a0, a1 = k * n, ((k + 1) % nr) * n
            for i in range(n):
                j = (i + 1) % n
                faces.append((a0 + i, a0 + j, a1 + j, a1 + i))
        me = bpy.data.meshes.new(name)
        me.from_pydata(verts, [], faces)
        me.update()
        o = bpy.data.objects.new(name, me)
        self.rig.users_collection[0].objects.link(o)
        bpy.ops.object.select_all(action='DESELECT')
        bpy.context.view_layer.objects.active = o
        bpy.ops.object.mode_set(mode='EDIT'); bpy.ops.mesh.normals_make_consistent(inside=False); bpy.ops.object.mode_set(mode='OBJECT')
        o.data.materials.append(m)
        return o

    def star(self, name, loc, m, size=0.06, depth=0.015, rot=(0, 0, 0)):
        """Estrella de cinc puntes, plana i amb gruix, de cara a -Y (cap a la càmera)."""
        from math import pi, sin, cos
        pts = []
        for i in range(10):
            r = size if i % 2 == 0 else size * 0.45
            a = pi / 2 + i * pi / 5
            pts.append((r * cos(a), r * sin(a)))
        verts = [(x, -depth / 2, z) for x, z in pts] + [(x, depth / 2, z) for x, z in pts]
        faces = [tuple(range(10)), tuple(range(19, 9, -1))] + [(i, (i + 1) % 10, 10 + (i + 1) % 10, 10 + i) for i in range(10)]
        me = bpy.data.meshes.new(name)
        me.from_pydata(verts, [], faces)
        me.update()
        o = bpy.data.objects.new(name, me)
        self.rig.users_collection[0].objects.link(o)
        o.location = loc
        o.rotation_euler = rot
        bpy.context.view_layer.update()
        o.data.materials.append(m)
        return o

    def attach(self, o, bone):
        bpy.context.view_layer.objects.active = o
        o.select_set(True)
        bpy.ops.object.shade_smooth_by_angle()
        o.select_set(False)
        mw = o.matrix_world.copy()
        o.parent = self.rig; o.parent_type = 'BONE'; o.parent_bone = bone
        bpy.context.view_layer.update()
        o.matrix_world = mw
        return o

    def add(self, prim, name, loc, bone, m, **kw):
        return self.attach(self.mesh(prim, name, loc, m, **kw), bone)

    def done(self):
        self.rig.data.pose_position = 'POSE'


# --- mercat: barret de palla, mocador, davantal i taronja ---------------------
def outfit_mercat(b):
    palla    = mat("Palla",         (0.78, 0.55, 0.22), 0.85)
    cinta    = mat("Cinta_Barret",  (0.75, 0.03, 0.02), 0.5)
    davantal = mat("Davantal_Verd", (0.05, 0.30, 0.12), 0.75)
    butxaca  = mat("Butxaca",       (0.08, 0.40, 0.17), 0.75)
    mocador  = mat("Mocador",       (0.03, 0.12, 0.55), 0.6)
    taronja  = mat("Taronja",       (0.95, 0.35, 0.02), 0.45)
    fulla    = mat("Fulla",         (0.10, 0.45, 0.08), 0.5)
    llapis   = mat("Llapis",        (0.95, 0.75, 0.10), 0.5)

    # barret de palla (os head); la bola de l'antena ix per dalt
    b.add("cylinder", "Barret_Ala",   (0, 0, 2.80), "head", palla, bevel=0.015, radius=1.08, depth=0.04, vertices=64)
    b.add("cylinder", "Barret_Copa",  (0, 0, 2.93), "head", palla, bevel=0.06, radius=0.50, depth=0.28, vertices=48)
    b.add("cylinder", "Barret_Cinta", (0, 0, 2.865), "head", cinta, radius=0.515, depth=0.07, vertices=48)

    # mocador al coll (os body)
    b.add("torus", "Mocador_Coll", (0, 0, 1.22), "body", mocador, scale=(1, 1, 0.8),
          major_radius=0.27, minor_radius=0.06, major_segments=48, minor_segments=12)
    b.add("uv_sphere", "Mocador_Nus", (0, -0.33, 1.21), "body", mocador, scale=(0.08, 0.05, 0.07), segments=24, ring_count=12)
    for side in (-1, 1):
        b.add("cone", f"Mocador_Punta.{'E' if side < 0 else 'D'}", (side * 0.06, -0.36, 1.12), "body", mocador,
              scale=(0.06, 0.015, 0.09), rot=(0, side * 0.35, 0), radius1=1, depth=2, vertices=3)

    # davantal de mitja cintura (os body), per davall de la insígnia de la senyera
    b.add("cube", "Davantal_Cinta", (0, 0, 0.39), "body", davantal, scale=(0.695, 0.545, 0.035), bevel=0.22, segs=6, size=2)
    b.add("cube", "Davantal",       (0, -0.545, 0.21), "body", davantal, scale=(0.56, 0.02, 0.18), bevel=0.03, size=2)
    b.add("cube", "Davantal_Butxaca", (0.24, -0.57, 0.17), "body", butxaca, scale=(0.15, 0.012, 0.09), bevel=0.02, size=2)
    b.add("cylinder", "Llapis", (0.30, -0.575, 0.29), "body", llapis, rot=(0, 0.25, 0), radius=0.018, depth=0.2, vertices=6)
    for side in (-1, 1):  # llaç a l'esquena
        b.add("uv_sphere", f"Davantal_Llaç.{'E' if side < 0 else 'D'}", (side * 0.09, 0.56, 0.39), "body", davantal,
              scale=(0.09, 0.03, 0.05), segments=16, ring_count=8)

    # taronja a la mà esquerra (os arm_L)
    b.add("uv_sphere", "Taronja", (-1.0, -0.22, 0.26), "arm_L", taronja, radius=0.15, segments=32, ring_count=16)
    b.add("uv_sphere", "Taronja_Fulla", (-0.96, -0.24, 0.42), "arm_L", fulla, scale=(0.07, 0.025, 0.035),
          rot=(0, -0.5, 0), segments=16, ring_count=8)


# --- farmacia: bata blanca oberta, creu verda, ulleres i caixa de medicaments --
def outfit_farmacia(b):
    from math import pi
    bata    = mat("Bata_Blanca",     (0.95, 0.96, 0.97), 0.9)
    verd    = mat("Verd_Farmacia",   (0.00, 0.55, 0.22), 0.5)
    creu    = mat("Creu_Farmacia",   (0.05, 0.85, 0.30), 0.4, emit=2.0)
    montura = mat("Montura_Ulleres", (0.06, 0.06, 0.08), 0.3, metal=0.6)
    caixa   = mat("Caixa_Medicament", (0.92, 0.92, 0.90), 0.5)
    boli    = mat("Boli",            (0.05, 0.20, 0.65), 0.4)
    camisa  = mat("Camisa_Turquesa", (0.10, 0.45, 0.45), 0.7)

    # bata: una capa una mica més gran que el cos, oberta per davant (es veu la senyera)
    shell = b.mesh("cube", "Bata", (0, 0, 0.60), bata, scale=(0.715, 0.565, 0.545), bevel=0.24, segs=6, size=2)
    b.cut(shell, (0, -0.6, 0.62), (0.33, 0.2, 0.6))
    b.attach(shell, "body")
    # camisa de color davall de la bata: fa contrast amb el blanc; la senyera queda damunt
    b.add("cube", "Camisa", (0, -0.535, 0.60), "body", camisa, scale=(0.335, 0.01, 0.53), size=2)
    for side in (-1, 1):  # vores verdes de l'obertura
        b.add("cube", f"Bata_Vora.{'E' if side < 0 else 'D'}", (side * 0.345, -0.568, 0.60), "body", verd,
              scale=(0.018, 0.012, 0.52), size=2)
    b.add("torus", "Bata_Coll", (0, 0, 1.19), "body", verd, scale=(1, 1, 0.7),
          major_radius=0.30, minor_radius=0.05, major_segments=48, minor_segments=12)
    # punys verds a les mànegues (els braços són blancs com la bata)
    for side, bone in ((-1, "arm_L"), (1, "arm_R")):
        b.add("torus", f"Bata_Puny.{'E' if side < 0 else 'D'}", (side * 0.964, 0, 0.368), bone, verd,
              rot=(0, -side * 0.385, 0), major_radius=0.13, minor_radius=0.03, major_segments=32, minor_segments=8)

    # creu verda de farmàcia (lluminosa) al pit dret i butxaca amb bolígraf a baix a l'esquerra
    b.add("cube", "Creu_V", (0.52, -0.575, 0.93), "body", creu, scale=(0.04, 0.01, 0.12), size=2)
    b.add("cube", "Creu_H", (0.52, -0.575, 0.93), "body", creu, scale=(0.12, 0.01, 0.04), size=2)
    b.add("cube", "Bata_Butxaca", (-0.52, -0.575, 0.30), "body", bata, scale=(0.13, 0.012, 0.11), bevel=0.02, size=2)
    b.add("cube", "Bata_Butxaca_Vora", (-0.52, -0.582, 0.405), "body", verd, scale=(0.13, 0.008, 0.012), size=2)
    b.add("cylinder", "Boli", (-0.47, -0.585, 0.43), "body", boli, radius=0.016, depth=0.16, vertices=8)

    # ulleres rodones al voltant dels ulls de la pantalla (os head)
    for side in (-1, 1):
        b.add("torus", f"Ulleres_Cercle.{'E' if side < 0 else 'D'}", (side * 0.33, -0.845, 2.12), "head", montura,
              rot=(pi / 2, 0, 0), scale=(1, 1, 1.15), major_radius=0.21, minor_radius=0.016,
              major_segments=48, minor_segments=8)
    b.add("cylinder", "Ulleres_Pont", (0, -0.845, 2.22), "head", montura, rot=(0, pi / 2, 0),
          radius=0.014, depth=0.26, vertices=8)

    # caixa de medicaments a la mà esquerra (os arm_L)
    b.add("cube", "Caixa", (-1.02, -0.17, 0.12), "arm_L", caixa, scale=(0.1, 0.05, 0.07), bevel=0.012, size=2)
    b.add("cube", "Caixa_Creu_V", (-1.02, -0.222, 0.12), "arm_L", verd, scale=(0.014, 0.004, 0.045), size=2)
    b.add("cube", "Caixa_Creu_H", (-1.02, -0.222, 0.12), "arm_L", verd, scale=(0.045, 0.004, 0.014), size=2)


# --- forn: gorro de forner, davantal de pitet i barra de pa -------------------
def outfit_forn(b):
    from math import pi, sin, cos
    from mathutils import Vector
    gorro   = mat("Gorro_Forner",   (0.95, 0.94, 0.90), 0.95)
    davant  = mat("Davantal_Marro", (0.30, 0.13, 0.05), 0.85)
    tira    = mat("Tira_Marro",     (0.14, 0.06, 0.02), 0.8)
    crosta  = mat("Pa_Crosta",      (0.62, 0.30, 0.05), 0.6)
    molla   = mat("Pa_Tall",        (0.95, 0.80, 0.50), 0.8)
    fusta   = mat("Fusta",          (0.62, 0.42, 0.22), 0.6)

    # gorro de forner bombat (os head); baixet perquè la bola de l'antena isca per dalt
    b.add("cylinder", "Gorro_Banda", (0, 0, 2.82), "head", gorro, bevel=0.02, radius=0.52, depth=0.14, vertices=48)
    b.add("uv_sphere", "Gorro_Bombo", (0, 0, 2.93), "head", gorro, scale=(0.56, 0.56, 0.2), segments=32, ring_count=16)
    for i in range(6):
        a = i * pi / 3 + pi / 6
        b.add("uv_sphere", f"Gorro_Plec.{i}", (0.34 * cos(a), 0.34 * sin(a), 2.97), "head", gorro,
              scale=(0.24, 0.24, 0.16), segments=24, ring_count=12)

    # davantal de pitet (os body): darrere de la insígnia, que queda com un pegat damunt
    b.add("cube", "Davantal_Falda", (0, -0.535, 0.33), "body", davant, scale=(0.55, 0.01, 0.27), bevel=0.02, size=2)
    b.add("cube", "Davantal_Pitet", (0, -0.535, 0.80), "body", davant, scale=(0.37, 0.01, 0.21), bevel=0.02, size=2)
    for side in (-1, 1):
        s = 'E' if side < 0 else 'D'
        b.add("cube", f"Davantal_Tirant.{s}", (side * 0.31, -0.54, 1.08), "body", tira,
              scale=(0.03, 0.008, 0.09), size=2)
        b.add("cube", f"Davantal_Tirant_Dalt.{s}", (side * 0.27, -0.35, 1.18), "body", tira,
              scale=(0.03, 0.19, 0.008), rot=(0, 0, side * 0.2), size=2)
    # butxaca amb cullera de fusta
    b.add("cube", "Davantal_Butxaca", (0.26, -0.55, 0.25), "body", tira, scale=(0.15, 0.008, 0.1), bevel=0.015, size=2)
    b.add("cylinder", "Cullera_Mànec", (0.22, -0.552, 0.40), "body", fusta, rot=(0, 0.2, 0), radius=0.015, depth=0.26, vertices=8)
    b.add("uv_sphere", "Cullera_Cap", (0.25, -0.556, 0.54), "body", fusta, scale=(0.045, 0.012, 0.06), segments=16, ring_count=8)

    # barra de pa a la mà esquerra (os arm_L), inclinada cap a fora
    centre, rot_y = Vector((-1.06, -0.2, 0.48)), -0.6
    b.add("uv_sphere", "Barra_Pa", centre, "arm_L", crosta, scale=(0.095, 0.095, 0.62), rot=(0.15, rot_y, 0),
          segments=32, ring_count=24)
    eix = Vector((sin(rot_y), 0, cos(rot_y)))
    for i, t in enumerate((-0.36, -0.18, 0.0, 0.18, 0.36)):  # talls de la crosta, cap a la càmera
        p = centre + eix * t + Vector((0, -0.088, 0))
        b.add("uv_sphere", f"Barra_Tall.{i}", p, "arm_L", molla, scale=(0.035, 0.015, 0.085), rot=(0, rot_y - 0.6, 0),
              segments=12, ring_count=6)


# --- peces compartides ----------------------------------------------------------
def jaqueta_oberta(b, tela, camisa, nom="Americana", nom_camisa="Camisa", manegues=True):
    """Jaqueta oberta per davant (os body), amb mànegues o sense (armilla); a l'obertura,
    una camisa o samarreta de color. La senyera queda damunt de la camisa."""
    shell = b.mesh("cube", nom, (0, 0, 0.60), tela, scale=(0.715, 0.565, 0.545), bevel=0.24, segs=6, size=2)
    b.cut(shell, (0, -0.6, 0.62), (0.33, 0.2, 0.6))
    b.attach(shell, "body")
    b.add("cube", nom_camisa, (0, -0.535, 0.60), "body", camisa, scale=(0.335, 0.01, 0.53), size=2)
    for side in ((-1, 1) if manegues else ()):  # mànegues sobre els braços (mateixa forma i inclinació)
        b.add("uv_sphere", f"Mànega.{'E' if side < 0 else 'D'}", (side * 0.87, 0, 0.60), "arm_L" if side < 0 else "arm_R",
              tela, scale=(0.175, 0.175, 0.36), rot=(0, -side * 0.385, 0), segments=32, ring_count=16)


def americana_oberta(b, tela, solapa, camisa, botons):
    """Americana: jaqueta oberta amb solapes i dos botons."""
    from math import pi
    jaqueta_oberta(b, tela, camisa)
    for side in (-1, 1):  # solapes: triangles a la vora de l'obertura, amb la punta cap avall
        b.add("cone", f"Solapa.{'E' if side < 0 else 'D'}", (side * 0.38, -0.572, 0.97), "body", solapa,
              scale=(0.07, 0.008, 0.2), rot=(pi, 0, 0), radius1=1, depth=2, vertices=3)
    for i, z in enumerate((0.45, 0.28)):  # botons a la banda esquerra de l'obertura
        b.add("cylinder", f"Botó.{i}", (-0.40, -0.57, z), "body", botons, rot=(pi / 2, 0, 0),
              radius=0.03, depth=0.015, vertices=16)


def pestanyes(b):
    """Tres pestanyes a dalt i a fora de cada ull (ossos eye_L / eye_R): segueixen
    parpelleigs i gestos. Usen el material dels ulls, que el motor recoloreja segons l'estat."""
    from math import sin, cos, atan2, radians
    from mathutils import Vector
    ull = bpy.data.materials.get("Ull_Brillant") or mat("Ull_Brillant", (0.6, 0.9, 1.0), 0.3, emit=1.0)
    for side, bone, angles in ((-1, "eye_L", (105, 130, 155)), (1, "eye_R", (75, 50, 25))):
        cx, cz, ea, eb = side * 0.33, 2.12, 0.12, 0.19
        for j, deg in enumerate(angles):
            t = radians(deg)
            nn = Vector((cos(t) / ea, 0, sin(t) / eb)).normalized()
            p = Vector((cx + ea * cos(t), -0.835, cz + eb * sin(t))) + nn * 0.045
            b.add("cylinder", f"Pestanya.{'E' if side < 0 else 'D'}{j}", p, bone, ull,
                  rot=(0, atan2(nn.x, nn.z), 0), radius=0.013, depth=0.08, vertices=8)


# --- oficina: americana blava oberta, camisa, mocador de butxaca, targeta i tassa de café --
def outfit_oficina(b):
    from math import pi
    americana = mat("Americana_Blava", (0.02, 0.04, 0.12), 0.6)
    solapa    = mat("Solapa_Fosca",    (0.008, 0.015, 0.05), 0.5)
    camisa    = mat("Camisa_Celeste",  (0.55, 0.70, 0.85), 0.7)
    blanc     = mat("Blanc_Coll",      (0.93, 0.93, 0.95), 0.6)
    roig      = mat("Mocador_Butxaca", (0.65, 0.03, 0.04), 0.5)
    daurat    = mat("Botó_Daurat",     (0.80, 0.60, 0.20), 0.3, metal=0.9)
    foto      = mat("Targeta_Foto",    (0.10, 0.30, 0.60), 0.5)
    tassa     = mat("Tassa",           (0.95, 0.95, 0.95), 0.3)
    cafe      = mat("Cafe",            (0.12, 0.05, 0.02), 0.2)

    americana_oberta(b, americana, solapa, camisa, daurat)
    b.add("torus", "Camisa_Coll", (0, 0, 1.19), "body", blanc, scale=(1, 1, 0.7),
          major_radius=0.30, minor_radius=0.06, major_segments=48, minor_segments=12)

    # butxaca de pit amb mocador roig i targeta d'identificació penjada
    b.add("cube", "Butxaca_Vora", (0.52, -0.572, 0.93), "body", solapa, scale=(0.12, 0.008, 0.012), size=2)
    b.add("cone", "Mocador_Butxaca", (0.50, -0.568, 0.97), "body", roig,
          scale=(0.07, 0.008, 0.05), rot=(0, 0.15, 0), radius1=1, depth=2, vertices=3)
    b.add("cube", "Targeta_Pinça", (0.56, -0.575, 0.88), "body", daurat, scale=(0.012, 0.006, 0.04), size=2)
    b.add("cube", "Targeta", (0.56, -0.578, 0.76), "body", blanc, scale=(0.08, 0.006, 0.1), bevel=0.01, size=2)
    b.add("cube", "Targeta_Foto", (0.56, -0.586, 0.79), "body", foto, scale=(0.04, 0.003, 0.04), size=2)
    b.add("cube", "Targeta_Nom", (0.56, -0.586, 0.71), "body", solapa, scale=(0.05, 0.003, 0.008), size=2)

    # tassa de café a la mà esquerra (os arm_L)
    b.add("cylinder", "Tassa", (-1.03, -0.2, 0.30), "arm_L", tassa, bevel=0.012, radius=0.1, depth=0.2, vertices=32)
    b.add("cylinder", "Tassa_Cafe", (-1.03, -0.2, 0.395), "arm_L", cafe, radius=0.085, depth=0.012, vertices=32)
    b.add("torus", "Tassa_Nansa", (-1.14, -0.2, 0.30), "arm_L", tassa, rot=(pi / 2, 0, 0),
          major_radius=0.05, minor_radius=0.015, major_segments=24, minor_segments=8)


# --- a2_identificacio (festa d'aniversari de Núria, adulta): elegant:
#     americana granat, pestanyes, arracades i collar de perles, i copa de cava --------------
def outfit_festa(b):
    from math import pi, sin, cos, atan2, radians
    from mathutils import Vector
    americana = mat("Americana_Granat", (0.30, 0.02, 0.07), 0.5)
    solapa = mat("Solapa_Granat",    (0.16, 0.01, 0.04), 0.35)
    top    = mat("Top_Xampany",      (0.85, 0.74, 0.58), 0.4)
    daurat = mat("Daurat_Festa",     (0.85, 0.62, 0.15), 0.3, metal=0.8)
    perla  = mat("Perla",            (0.95, 0.93, 0.88), 0.15)
    gemma  = mat("Gemma_Roja",       (0.70, 0.02, 0.06), 0.1, metal=0.2)
    cava   = mat("Cava",             (0.95, 0.75, 0.25), 0.1, emit=0.2)
    vidre  = mat("Vidre_Copa",       (0.70, 0.85, 0.95), 0.05)
    bsdf = next(n for n in vidre.node_tree.nodes if n.type == 'BSDF_PRINCIPLED')
    bsdf.inputs["Alpha"].default_value = 0.5
    for attr, val in (("surface_render_method", 'BLENDED'), ("blend_method", 'BLEND')):
        try: setattr(vidre, attr, val)
        except (AttributeError, TypeError): pass

    pestanyes(b)

    # arracades de perla penjant de les orelles (os head)
    for side in (-1, 1):
        s = 'E' if side < 0 else 'D'
        b.add("torus", f"Arracada_Anella.{s}", (side * 0.98, -0.12, 1.71), "head", daurat, rot=(pi / 2, 0, 0),
              major_radius=0.035, minor_radius=0.011, major_segments=16, minor_segments=6)
        b.add("uv_sphere", f"Arracada_Perla.{s}", (side * 0.98, -0.12, 1.60), "head", perla,
              radius=0.075, segments=16, ring_count=8)

    # collar de perles al voltant del coll (os body)
    for i in range(26):
        a = 2 * pi * i / 26
        b.add("uv_sphere", f"Perla.{i}", (0.34 * cos(a), 0.34 * sin(a), 1.21), "body", perla,
              radius=0.036, segments=12, ring_count=6)

    # americana granat oberta amb top xampany; el fermall va a la solapa dreta
    americana_oberta(b, americana, solapa, top, daurat)
    b.add("cylinder", "Fermall", (0.50, -0.578, 0.93), "body", daurat, rot=(pi / 2, 0, 0), radius=0.045, depth=0.015, vertices=24)
    b.add("uv_sphere", "Fermall_Gemma", (0.50, -0.588, 0.93), "body", gemma, scale=(0.028, 0.012, 0.028), segments=16, ring_count=8)

    # copa de cava a la mà esquerra (os arm_L)
    x, y = -0.98, -0.26
    b.add("cylinder", "Copa_Peu", (x, y, 0.06), "arm_L", vidre, radius=0.08, depth=0.016, vertices=24)
    b.add("cylinder", "Copa_Tija", (x, y, 0.19), "arm_L", vidre, radius=0.016, depth=0.26, vertices=12)
    b.add("cone", "Copa", (x, y, 0.47), "arm_L", vidre, radius1=0.045, radius2=0.085, depth=0.3, vertices=24, end_fill_type='NOTHING')
    b.add("cone", "Copa_Cava", (x, y, 0.42), "arm_L", cava, radius1=0.038, radius2=0.07, depth=0.19, vertices=24)


# --- a2_casa (Xavi, nou company de pis): dessuadora oberta, gorra i claus ---------
def outfit_casa(b):
    from math import pi
    dessuadora = mat("Dessuadora_Oliva", (0.20, 0.28, 0.10), 0.85)
    canale     = mat("Canale_Oliva",     (0.12, 0.17, 0.06), 0.9)
    samarreta  = mat("Samarreta_Antracita", (0.06, 0.06, 0.07), 0.8)
    cordo      = mat("Cordo_Blanc",      (0.92, 0.92, 0.90), 0.7)
    cremallera = mat("Cremallera",       (0.60, 0.62, 0.65), 0.3, metal=0.9)
    gorra      = mat("Gorra_Roja",       (0.55, 0.03, 0.03), 0.6)
    llauto     = mat("Llautó_Claus",     (0.80, 0.60, 0.25), 0.3, metal=0.9)
    acer       = mat("Acer_Clauer",      (0.70, 0.72, 0.75), 0.25, metal=1.0)

    # dessuadora oberta amb samarreta fosca (os body)
    jaqueta_oberta(b, dessuadora, samarreta, nom="Dessuadora", nom_camisa="Samarreta")
    for side in (-1, 1):
        s = 'E' if side < 0 else 'D'
        b.add("cube", f"Cremallera.{s}", (side * 0.343, -0.568, 0.60), "body", cremallera,
              scale=(0.012, 0.01, 0.52), size=2)
        # cordons blancs que pengen del caputxó, amb puntera
        b.add("cylinder", f"Cordo.{s}", (side * 0.39, -0.575, 1.0), "body", cordo, radius=0.014, depth=0.3, vertices=8)
        b.add("cylinder", f"Cordo_Puntera.{s}", (side * 0.39, -0.575, 0.84), "body", cremallera,
              radius=0.018, depth=0.04, vertices=8)
        # butxaques laterals: una vora de canalé a cada panell
        b.add("cube", f"Butxaca.{s}", (side * 0.53, -0.572, 0.30), "body", canale,
              scale=(0.11, 0.008, 0.014), rot=(0, side * 0.5, 0), size=2)
        # punys de canalé a les mànegues
        b.add("torus", f"Puny.{s}", (side * 0.964, 0, 0.368), "arm_L" if side < 0 else "arm_R", canale,
              rot=(0, -side * 0.385, 0), major_radius=0.13, minor_radius=0.035, major_segments=32, minor_segments=8)
    # caputxó arrugat darrere del coll
    b.add("torus", "Caputxo_Coll", (0, 0.04, 1.22), "body", dessuadora, scale=(1, 1, 0.75),
          major_radius=0.36, minor_radius=0.09, major_segments=48, minor_segments=12)
    b.add("uv_sphere", "Caputxo", (0, 0.42, 1.12), "body", dessuadora, scale=(0.38, 0.14, 0.22), segments=24, ring_count=12)

    # gorra amb visera cap avant, per damunt de la pantalla (os head); l'antena ix pel botó de dalt
    b.add("uv_sphere", "Gorra", (0, 0, 2.78), "head", gorra, scale=(0.56, 0.56, 0.28), segments=40, ring_count=20)
    b.add("cylinder", "Gorra_Visera", (0, -0.80, 2.79), "head", gorra, scale=(1, 0.65, 1), rot=(0.22, 0, 0),
          bevel=0.012, radius=0.40, depth=0.04, vertices=40)
    b.add("cylinder", "Gorra_Botó", (0, 0, 3.06), "head", gorra, radius=0.05, depth=0.03, vertices=16)

    # clauer amb dues claus penjant de la mà esquerra (os arm_L)
    x, y = -1.0, -0.2
    b.add("torus", "Clauer", (x, y, 0.07), "arm_L", acer, rot=(pi / 2, 0, 0),
          major_radius=0.065, minor_radius=0.012, major_segments=24, minor_segments=6)
    for k, ang in enumerate((0.25, -0.3)):
        from mathutils import Matrix, Vector
        rot = Matrix.Rotation(ang, 3, 'Y')
        top = Vector((x, y, 0.02))
        def at(dz):
            return top + rot @ Vector((0, 0, dz))
        b.add("cylinder", f"Clau_Cap.{k}", at(-0.055), "arm_L", llauto, rot=(pi / 2, 0, 0),
              radius=0.05, depth=0.015, vertices=20)
        b.add("cube", f"Clau_Tija.{k}", at(-0.17), "arm_L", llauto, rot=(0, ang, 0), scale=(0.016, 0.006, 0.075), size=2)
        b.add("cube", f"Clau_Dents.{k}", top + rot @ Vector((0.024, 0, -0.2)), "arm_L", llauto, rot=(0, ang, 0),
              scale=(0.012, 0.006, 0.028), size=2)


# --- a2_activitats (Toni, amic del gimnàs): samarreta de tirants, pantaló curt, cinta al
#     cap, tovallola a l'espatla, canellera i pesa -------------------------------------------
def outfit_gimnas(b):
    from math import pi
    tirants  = mat("Samarreta_Blau_Electric", (0.02, 0.25, 0.75), 0.6)
    pantalo  = mat("Pantalo_Negre",  (0.03, 0.03, 0.035), 0.7)
    blanc    = mat("Blanc_Esport",   (0.93, 0.93, 0.93), 0.7)
    roig     = mat("Roig_Esport",    (0.75, 0.03, 0.03), 0.8)
    tovallola = mat("Tovallola",     (0.92, 0.92, 0.90), 0.95)
    disc     = mat("Disc_Pesa",      (0.05, 0.05, 0.06), 0.4, metal=0.3)
    barra    = mat("Barra_Pesa",     (0.70, 0.72, 0.75), 0.25, metal=1.0)

    # samarreta de tirants i pantaló curt (os body); la senyera queda com un estampat
    b.add("cube", "Samarreta_Tirants", (0, 0, 0.755), "body", tirants, scale=(0.70, 0.548, 0.425), bevel=0.24, segs=6, size=2)
    b.add("cube", "Pantalo", (0, 0, 0.17), "body", pantalo, scale=(0.705, 0.553, 0.16), bevel=0.24, segs=6, size=2)
    b.add("cube", "Pantalo_Cintura", (0, 0, 0.33), "body", blanc, scale=(0.71, 0.558, 0.02), bevel=0.24, segs=6, size=2)
    for side in (-1, 1):  # franges blanques als costats del pantaló
        b.add("cube", f"Pantalo_Franja.{'E' if side < 0 else 'D'}", (side * 0.708, 0, 0.17), "body", blanc,
              scale=(0.008, 0.05, 0.15), size=2)

    # cinta suadora al cap, per damunt de la pantalla (os head)
    b.attach(b.band("Cinta_Cap", "Cap", 2.61, 0.11, roig), "head")

    # tovallola blanca damunt de l'espatla dreta, amb la punta penjant per davant (os body)
    b.add("cube", "Tovallola_Espatla", (0.48, -0.05, 1.19), "body", tovallola, scale=(0.13, 0.52, 0.025), bevel=0.02, size=2)
    b.add("cube", "Tovallola_Davant", (0.48, -0.57, 0.92), "body", tovallola, scale=(0.13, 0.022, 0.28), bevel=0.02, size=2)
    b.add("cube", "Tovallola_Darrere", (0.48, 0.57, 0.98), "body", tovallola, scale=(0.13, 0.022, 0.22), bevel=0.02, size=2)
    for k, z in enumerate((0.72, 0.76)):  # ratlles roges a la punta
        b.add("cube", f"Tovallola_Ratlla.{k}", (0.48, -0.594, z), "body", roig, scale=(0.13, 0.003, 0.01), size=2)

    # canellera roja al braç dret (os arm_R)
    b.add("torus", "Canellera", (0.964, 0, 0.368), "arm_R", roig, rot=(0, -0.385, 0),
          major_radius=0.135, minor_radius=0.045, major_segments=32, minor_segments=10)

    # pesa a la mà esquerra (os arm_L): barra travessant la mà i un disc a cada costat
    b.add("cylinder", "Pesa_Barra", (-1.0, -0.02, 0.22), "arm_L", barra, rot=(0, pi / 2, 0),
          radius=0.022, depth=0.5, vertices=16)
    for k, x in enumerate((-0.79, -1.21)):
        b.add("cylinder", f"Pesa_Disc.{k}", (x, -0.02, 0.22), "arm_L", disc, rot=(0, pi / 2, 0),
              bevel=0.01, radius=0.15, depth=0.08, vertices=32)
        b.add("torus", f"Pesa_Anella.{k}", (x, -0.02, 0.22), "arm_L", roig, rot=(0, pi / 2, 0),
              major_radius=0.15, minor_radius=0.014, major_segments=32, minor_segments=6)


# --- a2_menjar (Empar, propietària del restaurant): armilla negra, brusa blanca, fular roig,
#     pestanyes, arracades d'anella i la carta a la mà ------------------------------------
def outfit_restaurant(b):
    from math import pi
    armilla = mat("Armilla_Negra",  (0.035, 0.035, 0.045), 0.45)
    brusa   = mat("Brusa_Blanca",   (0.93, 0.93, 0.92), 0.6)
    fular   = mat("Fular_Roig",     (0.65, 0.03, 0.04), 0.5)
    daurat  = mat("Daurat_Restaurant", (0.85, 0.62, 0.15), 0.3, metal=0.9)
    carta   = mat("Carta_Granat",   (0.30, 0.03, 0.06), 0.5)

    pestanyes(b)

    # arracades d'anella daurada penjant de les orelles (os head)
    for side in (-1, 1):
        b.add("torus", f"Arracada.{'E' if side < 0 else 'D'}", (side * 0.98, -0.12, 1.66), "head", daurat,
              rot=(pi / 2, 0, 0), major_radius=0.075, minor_radius=0.013, major_segments=32, minor_segments=8)

    # armilla negra sense mànegues sobre una brusa blanca; botons daurats a la vora esquerra
    jaqueta_oberta(b, armilla, brusa, nom="Armilla", nom_camisa="Brusa", manegues=False)
    for i, z in enumerate((0.62, 0.45, 0.28)):
        b.add("cylinder", f"Botó.{i}", (-0.40, -0.57, z), "body", daurat, rot=(pi / 2, 0, 0),
              radius=0.028, depth=0.015, vertices=16)
    for side in (-1, 1):  # puntes del coll de la brusa
        b.add("cone", f"Brusa_Coll.{'E' if side < 0 else 'D'}", (side * 0.17, -0.40, 1.19), "body", brusa,
              scale=(0.09, 0.012, 0.06), rot=(-0.6, 0, side * 0.5), radius1=1, depth=2, vertices=3)

    # fular roig al coll amb nus i puntes (os body)
    b.add("torus", "Fular_Coll", (0, 0, 1.22), "body", fular, scale=(1, 1, 0.8),
          major_radius=0.27, minor_radius=0.055, major_segments=48, minor_segments=12)
    b.add("uv_sphere", "Fular_Nus", (0.0, -0.33, 1.20), "body", fular, scale=(0.075, 0.05, 0.065), segments=24, ring_count=12)
    for side in (-1, 1):
        b.add("cone", f"Fular_Punta.{'E' if side < 0 else 'D'}", (side * 0.07, -0.37, 1.10), "body", fular,
              scale=(0.065, 0.015, 0.1), rot=(0, side * 0.4, 0), radius1=1, depth=2, vertices=3)

    # la carta del restaurant a la mà esquerra (os arm_L): tapa granat amb vora daurada
    x, y, z, w, h = -1.04, -0.24, 0.32, 0.18, 0.24  # mitja amplària i mitja altura
    b.add("cube", "Carta", (x, y, z), "arm_L", carta, scale=(w, 0.025, h), bevel=0.012, size=2)
    m = 0.03  # marge de la vora daurada
    for k, (dx, dz, sx, sz) in enumerate(((0, h - m, w - m, 0.007), (0, -(h - m), w - m, 0.007),
                                          (w - m, 0, 0.007, h - m), (-(w - m), 0, 0.007, h - m))):
        b.add("cube", f"Carta_Vora.{k}", (x + dx, y - 0.026, z + dz), "arm_L", daurat, scale=(sx, 0.003, sz), size=2)
    b.add("cube", "Carta_Titol", (x, y - 0.026, z + h * 0.45), "arm_L", daurat, scale=(w * 0.5, 0.003, 0.016), size=2)


# --- a2_servicis (Lídia, dependenta dels grans magatzems): rebeca lila, cinta mètrica al
#     coll, placa amb el nom i pestanyes ---------------------------------
def outfit_botiga(b):
    from math import pi
    rebeca  = mat("Rebeca_Lila",    (0.30, 0.10, 0.55), 0.85)
    top     = mat("Top_Blanc",      (0.93, 0.93, 0.92), 0.6)
    nacre   = mat("Botó_Nacre",     (0.95, 0.93, 0.88), 0.2)
    metre   = mat("Cinta_Metrica",  (0.95, 0.78, 0.10), 0.5)
    marca   = mat("Marques_Metre",  (0.05, 0.05, 0.05), 0.6)
    metall  = mat("Metall_Puntera", (0.70, 0.72, 0.75), 0.25, metal=1.0)
    placa   = mat("Placa_Nom",      (0.85, 0.65, 0.20), 0.3, metal=0.9)

    pestanyes(b)

    # rebeca lila oberta amb top blanc; botons de nacre a la vora esquerra
    jaqueta_oberta(b, rebeca, top, nom="Rebeca", nom_camisa="Top")
    for i, z in enumerate((0.78, 0.58, 0.38)):
        b.add("uv_sphere", f"Botó.{i}", (-0.40, -0.57, z), "body", nacre, scale=(0.028, 0.012, 0.028),
              segments=12, ring_count=6)
    # placa amb el nom al pit dret
    b.add("cube", "Placa_Nom", (0.54, -0.572, 0.95), "body", placa, scale=(0.09, 0.006, 0.035), bevel=0.008, size=2)
    b.add("cube", "Placa_Nom_Text", (0.54, -0.579, 0.95), "body", marca, scale=(0.06, 0.002, 0.007), size=2)

    # cinta mètrica groga al voltant del coll, amb les puntes penjant per davant (os body)
    b.add("torus", "Metre_Coll", (0, 0, 1.21), "body", metre, scale=(1, 1, 0.25),
          major_radius=0.34, minor_radius=0.05, major_segments=48, minor_segments=8)
    for side, llarg in ((-1, 0.42), (1, 0.30)):
        s = 'E' if side < 0 else 'D'
        x, z0 = side * 0.44, 1.18
        zc = z0 - llarg / 2
        b.add("cube", f"Metre_Punta.{s}", (x, -0.575, zc), "body", metre, scale=(0.05, 0.004, llarg / 2), size=2)
        for k in range(int(llarg / 0.05)):  # marques de centímetres
            b.add("cube", f"Metre_Marca.{s}{k}", (x - 0.02, -0.58, z0 - 0.03 - k * 0.05), "body", marca,
                  scale=(0.028, 0.002, 0.004), size=2)
        b.add("cube", f"Metre_Final.{s}", (x, -0.575, z0 - llarg - 0.008), "body", metall,
              scale=(0.052, 0.007, 0.012), size=2)


# --- a2_faena (Sílvia, antiga companya de l'institut, pel carrer): jaqueta texana, top de
#     ratlles, ulleres de sol al cap, pestanyes, bossa a l'espatla i mòbil ----------------
def outfit_carrer(b):
    from math import pi
    texa     = mat("Texa",            (0.08, 0.18, 0.38), 0.9)
    cosit    = mat("Cosit_Texa",      (0.70, 0.45, 0.15), 0.8)
    coure    = mat("Botó_Coure",      (0.70, 0.40, 0.20), 0.3, metal=0.9)
    top      = mat("Top_Ratlles",     (0.93, 0.93, 0.92), 0.7)
    ratlla   = mat("Ratlla_Marina",   (0.03, 0.05, 0.15), 0.7)
    lent     = mat("Lent_Ulleres_Sol", (0.02, 0.02, 0.03), 0.05, metal=0.3)
    montura  = mat("Montura_Sol",     (0.25, 0.12, 0.05), 0.3)
    pell     = mat("Pell_Bossa",      (0.45, 0.25, 0.12), 0.5)
    mobil    = mat("Mobil",           (0.03, 0.03, 0.035), 0.2, metal=0.5)
    pantalla = mat("Pantalla_Mobil",  (0.20, 0.45, 0.85), 0.2, emit=0.8)

    pestanyes(b)

    # jaqueta texana oberta amb top blanc de ratlles marines (la senyera queda al mig)
    jaqueta_oberta(b, texa, top, nom="Jaqueta_Texana", nom_camisa="Top")
    for k, z in enumerate((1.10, 0.98, 0.32, 0.20, 0.08)):  # ratlles visibles per damunt i per davall de la insígnia
        b.add("cube", f"Top_Ratlla.{k}", (0, -0.547, z), "body", ratlla, scale=(0.33, 0.003, 0.018), size=2)
    b.add("torus", "Jaqueta_Coll", (0, 0, 1.2), "body", texa, scale=(1, 1, 0.7),
          major_radius=0.31, minor_radius=0.065, major_segments=48, minor_segments=12)
    for side in (-1, 1):
        s = 'E' if side < 0 else 'D'
        # tapes de les butxaques de pit amb pespunt i botó de coure
        b.add("cube", f"Butxaca_Tapa.{s}", (side * 0.53, -0.572, 0.93), "body", texa, scale=(0.12, 0.012, 0.045), bevel=0.01, size=2)
        b.add("cube", f"Butxaca_Pespunt.{s}", (side * 0.53, -0.585, 0.90), "body", cosit, scale=(0.11, 0.002, 0.004), size=2)
        b.add("cylinder", f"Butxaca_Botó.{s}", (side * 0.53, -0.587, 0.915), "body", coure, rot=(pi / 2, 0, 0),
              radius=0.02, depth=0.01, vertices=12)
        # pespunts a les vores de l'obertura
        b.add("cube", f"Vora_Pespunt.{s}", (side * 0.355, -0.57, 0.60), "body", cosit, scale=(0.004, 0.006, 0.5), size=2)
    for i, z in enumerate((0.70, 0.50, 0.30)):
        b.add("cylinder", f"Botó.{i}", (-0.40, -0.57, z), "body", coure, rot=(pi / 2, 0, 0),
              radius=0.026, depth=0.015, vertices=16)

    # ulleres de sol alçades damunt del cap, a la vora de dalt de la pantalla (os head)
    for side in (-1, 1):
        b.add("uv_sphere", f"Ulleres_Sol_Lent.{'E' if side < 0 else 'D'}", (side * 0.25, -0.66, 2.73), "head", lent,
              scale=(0.16, 0.02, 0.11), rot=(-0.9, 0, 0), segments=24, ring_count=12)
        b.add("torus", f"Ulleres_Sol_Montura.{'E' if side < 0 else 'D'}", (side * 0.25, -0.665, 2.73), "head", montura,
              scale=(1.45, 1, 1), rot=(pi / 2 - 0.9, 0, 0), major_radius=0.11, minor_radius=0.012,
              major_segments=32, minor_segments=6)
    b.add("cylinder", "Ulleres_Sol_Pont", (0, -0.665, 2.76), "head", montura, rot=(0, pi / 2, 0),
          radius=0.012, depth=0.18, vertices=8)

    # bossa de pell penjada a l'espatla dreta (os body): corretja per la banda dreta, no tapa la senyera
    b.add("cube", "Bossa_Corretja", (0.55, -0.565, 0.82), "body", pell, scale=(0.018, 0.008, 0.36), size=2)
    b.add("cube", "Bossa_Corretja_Dalt", (0.55, -0.15, 1.185), "body", pell, scale=(0.018, 0.42, 0.008), size=2)
    b.add("cube", "Bossa_Espatla", (0.56, -0.62, 0.36), "body", pell, scale=(0.13, 0.045, 0.1), bevel=0.02, size=2)
    b.add("cube", "Bossa_Tapa", (0.56, -0.667, 0.40), "body", pell, scale=(0.13, 0.004, 0.06), bevel=0.01, size=2)
    b.add("cylinder", "Bossa_Tancat", (0.56, -0.673, 0.36), "body", coure, rot=(pi / 2, 0, 0), radius=0.018, depth=0.008, vertices=12)

    # mòbil a la mà esquerra (os arm_L), amb la pantalla encesa
    b.add("cube", "Mobil", (-1.02, -0.2, 0.30), "arm_L", mobil, scale=(0.065, 0.012, 0.12), bevel=0.012, size=2)
    b.add("cube", "Mobil_Pantalla", (-1.02, -0.213, 0.30), "arm_L", pantalla, scale=(0.055, 0.002, 0.105), size=2)


# --- a2_clima (Liam, amic irlandés): impermeable verd, jersei de punt irlandés, gorra
#     plana de tweed i paraigua tancat -----------------------------------------------------
def outfit_irlanda(b):
    from math import pi
    impermeable = mat("Impermeable_Verd", (0.02, 0.25, 0.12), 0.45)
    jersei   = mat("Jersei_Cru",        (0.85, 0.78, 0.62), 0.95)
    trena    = mat("Jersei_Trena",      (0.70, 0.62, 0.46), 0.95)
    tweed    = mat("Tweed_Gorra",       (0.30, 0.25, 0.18), 0.95)
    fusta    = mat("Fusta_Fosca",       (0.30, 0.17, 0.08), 0.5)
    cordo    = mat("Cordo_Fosc",        (0.10, 0.08, 0.06), 0.7)
    tela     = mat("Tela_Paraigua",     (0.05, 0.10, 0.30), 0.5)
    metall   = mat("Metall_Paraigua",   (0.70, 0.72, 0.75), 0.25, metal=1.0)

    # impermeable obert sobre un jersei de punt amb trenes; coll alt de punt
    jaqueta_oberta(b, impermeable, jersei, nom="Impermeable", nom_camisa="Jersei")
    for k, x in enumerate((-0.27, -0.14, 0.14, 0.27)):  # trenes verticals (queden darrere de la insígnia)
        b.add("cube", f"Jersei_Trena.{k}", (x, -0.547, 0.60), "body", trena, scale=(0.018, 0.004, 0.52), size=2)
    b.add("torus", "Jersei_Coll", (0, 0, 1.22), "body", jersei, scale=(1, 1, 1.1),
          major_radius=0.29, minor_radius=0.075, major_segments=48, minor_segments=12)
    for i, z in enumerate((0.78, 0.56, 0.34)):  # alamars: botó de fusta i cordó
        b.add("cylinder", f"Alamar.{i}", (-0.40, -0.575, z), "body", fusta, rot=(0, pi / 2, 0),
              radius=0.016, depth=0.09, vertices=10)
        b.add("cube", f"Alamar_Cordo.{i}", (-0.37, -0.57, z), "body", cordo, scale=(0.05, 0.004, 0.006), size=2)
    for side in (-1, 1):  # tapes de les butxaques
        b.add("cube", f"Butxaca_Tapa.{'E' if side < 0 else 'D'}", (side * 0.53, -0.572, 0.36), "body", impermeable,
              scale=(0.12, 0.012, 0.045), bevel=0.01, size=2)

    # gorra plana de tweed (os head); l'antena ix per dalt
    b.add("uv_sphere", "Gorra_Plana", (0, -0.08, 2.80), "head", tweed, scale=(0.62, 0.66, 0.17), segments=40, ring_count=20)
    b.add("cylinder", "Gorra_Plana_Visera", (0, -0.82, 2.78), "head", tweed, scale=(1, 0.5, 1), rot=(0.3, 0, 0),
          bevel=0.012, radius=0.40, depth=0.04, vertices=40)

    # paraigua tancat dret a la mà esquerra (os arm_L): mànec de fusta baix, tela plegada amunt
    x, y = -1.0, -0.22
    b.add("cylinder", "Paraigua_Tija", (x, y, 0.65), "arm_L", metall, radius=0.016, depth=1.0, vertices=8)
    b.add("cone", "Paraigua_Tela", (x, y, 0.82), "arm_L", tela, rot=(pi, 0, 0), radius1=0.11, radius2=0.03,
          depth=0.62, vertices=8)
    b.add("cone", "Paraigua_Punta", (x, y, 1.19), "arm_L", metall, radius1=0.016, radius2=0.0, depth=0.09, vertices=8)
    b.add("torus", "Paraigua_Manec", (x + 0.05, y, 0.15), "arm_L", fusta, rot=(pi / 2, 0, 0),
          major_radius=0.06, minor_radius=0.02, major_segments=24, minor_segments=8)


# --- a2_viatges (Jordi, recepcionista de l'Hotel Mar Blau): uniforme gris amb ribets
#     daurats, camisa blanca, corbata de llacet, placa i clau de l'habitació -------------
def outfit_hotel(b):
    from math import pi
    uniforme = mat("Uniforme_Gris",   (0.10, 0.10, 0.12), 0.5)
    solapa   = mat("Solapa_Uniforme", (0.05, 0.05, 0.06), 0.35)
    camisa   = mat("Camisa_Blanca",   (0.93, 0.93, 0.95), 0.6)
    daurat   = mat("Ribet_Daurat",    (0.85, 0.62, 0.15), 0.3, metal=0.9)
    llacet   = mat("Corbata_Llacet",  (0.40, 0.02, 0.06), 0.45)
    clauer   = mat("Clauer_Habitacio", (0.40, 0.02, 0.06), 0.35)
    fosc     = mat("Text_Fosc",       (0.05, 0.05, 0.05), 0.6)

    # americana d'uniforme amb camisa blanca, ribets daurats a l'obertura i punys
    americana_oberta(b, uniforme, solapa, camisa, daurat)
    for side in (-1, 1):
        s = 'E' if side < 0 else 'D'
        b.add("cube", f"Ribet.{s}", (side * 0.345, -0.568, 0.60), "body", daurat, scale=(0.01, 0.01, 0.52), size=2)
        b.add("torus", f"Puny_Daurat.{s}", (side * 0.964, 0, 0.368), "arm_L" if side < 0 else "arm_R", daurat,
              rot=(0, -side * 0.385, 0), major_radius=0.13, minor_radius=0.022, major_segments=32, minor_segments=8)
    b.add("torus", "Camisa_Coll", (0, 0, 1.19), "body", camisa, scale=(1, 1, 0.7),
          major_radius=0.30, minor_radius=0.06, major_segments=48, minor_segments=12)

    # corbata de llacet al coll (os body)
    b.add("cube", "Llacet_Nus", (0, -0.38, 1.19), "body", llacet, scale=(0.04, 0.025, 0.04), bevel=0.01, size=2)
    for side in (-1, 1):
        b.add("cone", f"Llacet_Ala.{'E' if side < 0 else 'D'}", (side * 0.11, -0.375, 1.19), "body", llacet,
              scale=(0.08, 0.022, 0.07), rot=(0, -side * pi / 2, 0), radius1=1, depth=2, vertices=3)

    # placa amb el nom i agulla en forma de clau a la solapa dreta
    b.add("cube", "Placa_Nom", (0.54, -0.572, 0.80), "body", daurat, scale=(0.09, 0.006, 0.035), bevel=0.008, size=2)
    b.add("cube", "Placa_Nom_Text", (0.54, -0.579, 0.80), "body", fosc, scale=(0.06, 0.002, 0.007), size=2)
    b.add("torus", "Agulla_Clau_Cap", (0.50, -0.578, 0.97), "body", daurat, rot=(pi / 2, 0, 0),
          major_radius=0.022, minor_radius=0.007, major_segments=16, minor_segments=6)
    b.add("cube", "Agulla_Clau_Tija", (0.555, -0.578, 0.97), "body", daurat, scale=(0.035, 0.004, 0.006), size=2)
    b.add("cube", "Agulla_Clau_Dent", (0.58, -0.578, 0.958), "body", daurat, scale=(0.006, 0.004, 0.012), size=2)

    # clau de l'habitació amb clauer gran a la mà esquerra (os arm_L), alçada com si l'entregara
    x, y, k = -1.03, -0.25, 1.5  # k: escala del conjunt
    b.add("uv_sphere", "Clauer", (x, y, 0.36), "arm_L", clauer, scale=(0.075 * k, 0.02 * k, 0.13 * k), segments=24, ring_count=12)
    b.add("cylinder", "Clauer_Numero", (x, y - 0.03, 0.33), "arm_L", daurat, rot=(pi / 2, 0, 0),
          radius=0.04 * k, depth=0.006, vertices=20)
    b.add("cube", "Clauer_Numero_Text", (x, y - 0.036, 0.33), "arm_L", fosc, scale=(0.02 * k, 0.002, 0.012 * k), size=2)
    b.add("torus", "Clauer_Anella", (x, y, 0.36 + 0.15 * k), "arm_L", daurat, rot=(pi / 2, 0, 0),
          major_radius=0.025 * k, minor_radius=0.007 * k, major_segments=16, minor_segments=6)
    b.add("cylinder", "Clau_Cap", (x, y, 0.36 + 0.2 * k), "arm_L", daurat, rot=(pi / 2, 0, 0),
          radius=0.04 * k, depth=0.012 * k, vertices=20)
    b.add("cube", "Clau_Tija", (x, y, 0.36 + 0.3 * k), "arm_L", daurat, scale=(0.012 * k, 0.005 * k, 0.07 * k), size=2)
    b.add("cube", "Clau_Dents", (x + 0.018 * k, y, 0.36 + 0.33 * k), "arm_L", daurat, scale=(0.01 * k, 0.005 * k, 0.025 * k), size=2)


# --- ajuntament (Amparo, funcionària d'atenció ciutadana): americana blau petroli, brusa,
#     collaret d'or, ulleres rectangulars, pestanyes, arracades i carpeta de documents ---
def outfit_ajuntament(b):
    from math import pi
    americana = mat("Americana_Petroli", (0.02, 0.18, 0.25), 0.5)
    solapa    = mat("Solapa_Petroli",    (0.01, 0.10, 0.14), 0.4)
    brusa     = mat("Brusa_Crema",       (0.90, 0.85, 0.74), 0.6)
    daurat    = mat("Daurat_Ajuntament", (0.85, 0.62, 0.15), 0.3, metal=0.9)
    montura   = mat("Montura_Roja",      (0.60, 0.03, 0.05), 0.35)
    carpeta   = mat("Carpeta_Blava",     (0.05, 0.15, 0.45), 0.5)
    paper     = mat("Paper",             (0.95, 0.95, 0.93), 0.8)
    goma      = mat("Goma_Carpeta",      (0.05, 0.05, 0.06), 0.6)

    pestanyes(b)

    # arracades: un puntet d'or davall de cada orella (os head)
    for side in (-1, 1):
        b.add("uv_sphere", f"Arracada.{'E' if side < 0 else 'D'}", (side * 0.98, -0.12, 1.70), "head", daurat,
              radius=0.04, segments=16, ring_count=8)

    # ulleres rectangulars roges al voltant dels ulls de la pantalla (os head)
    for side in (-1, 1):
        s = 'E' if side < 0 else 'D'
        cx, cz, hw, hh, t = side * 0.33, 2.13, 0.165, 0.215, 0.013  # centre, mitja amplària/altura, gruix
        for k, (dx, dz, sx, sz) in enumerate(((0, hh, hw + t, t * 1.6), (0, -hh, hw + t, t),
                                              (hw, 0, t, hh), (-hw, 0, t, hh))):
            b.add("cube", f"Ulleres_Montura.{s}{k}", (cx + dx, -0.845, cz + dz), "head", montura,
                  scale=(sx, 0.012, sz), bevel=0.006, size=2)
    b.add("cube", "Ulleres_Pont", (0, -0.845, 2.22), "head", montura, scale=(0.165 - 0.013, 0.01, 0.011), size=2)

    # americana blau petroli oberta amb brusa crema i botons daurats
    americana_oberta(b, americana, solapa, brusa, daurat)
    # collaret d'or fi amb un penjoll al davant (os body)
    b.add("torus", "Collaret", (0, 0, 1.205), "body", daurat, major_radius=0.33, minor_radius=0.012,
          major_segments=48, minor_segments=6)
    b.add("uv_sphere", "Collaret_Penjoll", (0, -0.36, 1.19), "body", daurat, scale=(0.03, 0.012, 0.04),
          segments=16, ring_count=8)

    # carpeta de documents a la mà esquerra (os arm_L), amb fulls que sobreixen i una goma
    x, y, z, w, h = -1.04, -0.24, 0.32, 0.18, 0.24
    b.add("cube", "Carpeta_Fulls", (x + 0.01, y + 0.005, z + 0.03), "arm_L", paper, scale=(w - 0.02, 0.018, h), size=2)
    b.add("cube", "Carpeta", (x, y, z), "arm_L", carpeta, scale=(w, 0.025, h), bevel=0.012, size=2)
    b.add("cube", "Carpeta_Goma", (x, y - 0.027, z - h * 0.55), "arm_L", goma, scale=(w + 0.002, 0.004, 0.008), size=2)
    b.add("cube", "Carpeta_Escut", (x, y - 0.027, z + h * 0.3), "arm_L", daurat, scale=(0.05, 0.003, 0.06), bevel=0.004, size=2)


# --- bar (Maria, cambrera): polo taronja, davantal negre llarg amb llibreta i drap,
#     pestanyes i safata amb un café i un suc de taronja ---------------------------------
def outfit_bar(b):
    from math import pi
    polo    = mat("Polo_Taronja",   (0.80, 0.22, 0.04), 0.7)
    blanc   = mat("Blanc_Polo",     (0.93, 0.93, 0.92), 0.7)
    negre   = mat("Davantal_Negre", (0.03, 0.03, 0.035), 0.75)
    paper   = mat("Llibreta",       (0.95, 0.95, 0.90), 0.8)
    llapis  = mat("Llapis_Groc",    (0.95, 0.75, 0.10), 0.5)
    drap    = mat("Drap_Blanc",     (0.92, 0.92, 0.90), 0.95)
    ratlla  = mat("Ratlla_Drap",    (0.70, 0.05, 0.05), 0.9)
    plata   = mat("Safata_Plata",   (0.75, 0.77, 0.80), 0.25, metal=1.0)
    tassa   = mat("Tassa_Bar",      (0.95, 0.95, 0.95), 0.3)
    cafe    = mat("Cafe_Bar",       (0.12, 0.05, 0.02), 0.2)
    vidre   = mat("Vidre_Got",      (0.80, 0.90, 0.95), 0.05)
    suc     = mat("Suc_Taronja",    (0.95, 0.50, 0.05), 0.2, emit=0.1)
    gb = next(n for n in vidre.node_tree.nodes if n.type == 'BSDF_PRINCIPLED')
    gb.inputs["Alpha"].default_value = 0.2
    for attr, val in (("surface_render_method", 'BLENDED'), ("blend_method", 'BLEND')):
        try: setattr(vidre, attr, val)
        except (AttributeError, TypeError): pass

    pestanyes(b)

    # polo taronja (os body): la senyera queda com un logo estampat; coll blanc i botonera
    b.add("cube", "Polo", (0, 0, 0.66), "body", polo, scale=(0.70, 0.548, 0.52), bevel=0.24, segs=6, size=2)
    b.add("torus", "Polo_Coll", (0, 0, 1.2), "body", blanc, scale=(1, 1, 0.7),
          major_radius=0.30, minor_radius=0.06, major_segments=48, minor_segments=12)
    b.add("cube", "Polo_Botonera", (0, -0.552, 1.03), "body", polo, scale=(0.05, 0.006, 0.11), size=2)
    for i, z in enumerate((1.10, 0.98)):
        b.add("cylinder", f"Polo_Botó.{i}", (0, -0.56, z), "body", blanc, rot=(pi / 2, 0, 0), radius=0.018, depth=0.01, vertices=12)
    for side in (-1, 1):  # mànegues curtes: només la part de dalt del braç
        b.add("uv_sphere", f"Polo_Mànega.{'E' if side < 0 else 'D'}", (side * 0.806, 0, 0.758),
              "arm_L" if side < 0 else "arm_R", polo, scale=(0.19, 0.19, 0.2), rot=(0, -side * 0.385, 0),
              segments=32, ring_count=16)

    # davantal negre llarg des de la cintura, cinta que s'ajusta al polo i butxaca amb llibreta
    b.add("cube", "Davantal_Cinta", (0, 0, 0.395), "body", negre, scale=(0.706, 0.554, 0.02), bevel=0.24, segs=6, size=2)
    b.add("cube", "Davantal", (0, -0.562, 0.19), "body", negre, scale=(0.58, 0.012, 0.21), bevel=0.01, size=2)
    b.add("cube", "Davantal_Butxaca", (-0.30, -0.577, 0.22), "body", negre, scale=(0.16, 0.006, 0.1), bevel=0.008, size=2)
    b.add("cube", "Llibreta", (-0.34, -0.585, 0.33), "body", paper, scale=(0.06, 0.006, 0.07), rot=(0, 0.12, 0), size=2)
    b.add("cylinder", "Llapis", (-0.22, -0.587, 0.35), "body", llapis, rot=(0, -0.25, 0), radius=0.014, depth=0.2, vertices=6)
    # drap blanc penjant a la cintura, a la dreta
    b.add("cube", "Drap", (0.50, -0.575, 0.27), "body", drap, scale=(0.09, 0.012, 0.16), bevel=0.01, size=2)
    b.add("cube", "Drap_Ratlla", (0.50, -0.589, 0.17), "body", ratlla, scale=(0.09, 0.003, 0.012), size=2)

    # safata rodona damunt de la mà esquerra (os arm_L) amb un café i un got de suc
    x, y, z = -1.12, -0.32, 0.42
    b.add("cylinder", "Safata", (x, y, z), "arm_L", plata, bevel=0.008, radius=0.27, depth=0.025, vertices=48)
    b.add("torus", "Safata_Vora", (x, y, z + 0.013), "arm_L", plata, major_radius=0.265, minor_radius=0.013,
          major_segments=48, minor_segments=6)
    b.add("cylinder", "Tassa", (x + 0.10, y - 0.06, z + 0.08), "arm_L", tassa, bevel=0.01, radius=0.075, depth=0.13, vertices=24)
    b.add("cylinder", "Tassa_Cafe", (x + 0.10, y - 0.06, z + 0.142), "arm_L", cafe, radius=0.064, depth=0.008, vertices=24)
    b.add("torus", "Tassa_Nansa", (x + 0.19, y - 0.06, z + 0.08), "arm_L", tassa, rot=(pi / 2, 0, 0),
          major_radius=0.035, minor_radius=0.012, major_segments=16, minor_segments=6)
    b.add("cylinder", "Got", (x - 0.10, y - 0.02, z + 0.13), "arm_L", vidre, radius=0.065, depth=0.24, vertices=24,
          end_fill_type='NOTHING')
    b.add("cylinder", "Got_Suc", (x - 0.10, y - 0.02, z + 0.11), "arm_L", suc, radius=0.06, depth=0.18, vertices=24)


# --- taller (mecànic en cap): granota de treball blava amb taques de greix, pegat amb el
#     nom, tornavís a la butxaca, drap, gorra de treball i clau fixa a la mà -------------
def outfit_taller(b):
    from math import pi
    granota = mat("Granota_Blava",   (0.04, 0.10, 0.28), 0.85)
    costura = mat("Costura_Taronja", (0.85, 0.35, 0.05), 0.8)
    greix   = mat("Taca_Greix",      (0.03, 0.03, 0.03), 0.6)
    pegat   = mat("Pegat_Nom",       (0.93, 0.93, 0.92), 0.7)
    roig    = mat("Roig_Taller",     (0.70, 0.05, 0.04), 0.7)
    crom    = mat("Crom_Eina",       (0.80, 0.82, 0.85), 0.15, metal=1.0)
    mànec   = mat("Mànec_Tornavís",  (0.80, 0.08, 0.05), 0.4)

    # granota de treball (os body): la senyera queda com un pegat cosit; mànegues llargues i coll
    b.add("cube", "Granota", (0, 0, 0.60), "body", granota, scale=(0.70, 0.548, 0.575), bevel=0.24, segs=6, size=2)
    for side in (-1, 1):
        b.add("uv_sphere", f"Mànega.{'E' if side < 0 else 'D'}", (side * 0.87, 0, 0.60), "arm_L" if side < 0 else "arm_R",
              granota, scale=(0.175, 0.175, 0.36), rot=(0, -side * 0.385, 0), segments=32, ring_count=16)
    b.add("torus", "Granota_Coll", (0, 0, 1.2), "body", granota, scale=(1, 1, 0.7),
          major_radius=0.30, minor_radius=0.065, major_segments=48, minor_segments=12)
    b.add("cube", "Granota_Cremallera", (0, -0.552, 1.03), "body", costura, scale=(0.008, 0.004, 0.13), size=2)
    b.add("cube", "Granota_Cintura", (0, 0, 0.36), "body", costura, scale=(0.706, 0.554, 0.012), bevel=0.24, segs=6, size=2)
    # taques de greix
    for k, (x, z, sx, sz) in enumerate(((-0.42, 0.18, 0.07, 0.04), (0.35, 0.12, 0.05, 0.03), (0.50, 0.55, 0.04, 0.03),
                                        (-0.20, 0.08, 0.04, 0.025))):
        b.add("uv_sphere", f"Taca_Greix.{k}", (x, -0.548, z), "body", greix, scale=(sx, 0.006, sz), segments=12, ring_count=6)

    # pegat amb el nom al pit dret i butxaca amb tornavís al pit esquerre
    b.add("cylinder", "Pegat_Nom", (0.52, -0.553, 0.95), "body", pegat, rot=(pi / 2, 0, 0), scale=(1.4, 1, 0.8),
          radius=0.06, depth=0.008, vertices=32)
    b.add("cube", "Pegat_Nom_Text", (0.52, -0.559, 0.95), "body", roig, scale=(0.055, 0.002, 0.008), size=2)
    b.add("cube", "Butxaca_Pit", (-0.52, -0.556, 0.86), "body", granota, scale=(0.12, 0.008, 0.11), bevel=0.01, size=2)
    b.add("cube", "Butxaca_Pit_Costura", (-0.52, -0.566, 0.96), "body", costura, scale=(0.12, 0.002, 0.006), size=2)
    b.add("cylinder", "Tornavís_Mànec", (-0.48, -0.555, 1.02), "body", mànec, radius=0.022, depth=0.1, vertices=8)
    b.add("cylinder", "Tornavís_Barra", (-0.48, -0.555, 0.93), "body", crom, radius=0.008, depth=0.12, vertices=6)

    # drap roig penjant del maluc dret
    b.add("cube", "Drap_Taller", (0.55, -0.565, 0.22), "body", roig, scale=(0.08, 0.014, 0.15), rot=(0, 0.08, 0),
          bevel=0.01, size=2)
    b.add("uv_sphere", "Drap_Taca", (0.53, -0.58, 0.16), "body", greix, scale=(0.03, 0.005, 0.025), segments=10, ring_count=5)

    # gorra de treball blava amb pegat taronja (os head); l'antena ix pel botó de dalt
    b.add("uv_sphere", "Gorra_Treball", (0, 0, 2.78), "head", granota, scale=(0.56, 0.56, 0.28), segments=40, ring_count=20)
    b.add("cylinder", "Gorra_Treball_Visera", (0, -0.80, 2.79), "head", granota, scale=(1, 0.65, 1), rot=(0.22, 0, 0),
          bevel=0.012, radius=0.40, depth=0.04, vertices=40)
    b.add("cylinder", "Gorra_Treball_Pegat", (0, -0.49, 2.92), "head", costura, rot=(pi / 2 - 0.8, 0, 0),
          radius=0.07, depth=0.01, vertices=24)

    # clau fixa (inglesa) a la mà esquerra (os arm_L): barra cap amunt i cap obert per dalt
    x, y = -1.02, -0.22
    b.add("cube", "Clau_Fixa_Barra", (x, y, 0.42), "arm_L", crom, scale=(0.03, 0.012, 0.22), bevel=0.008, size=2)
    cap_clau = b.mesh("cylinder", "Clau_Fixa_Cap", (x, y, 0.68), crom, rot=(pi / 2, 0, 0), radius=0.075, depth=0.024, vertices=32)
    b.cut(cap_clau, (x, y, 0.74), (0.032, 0.05, 0.06))
    b.attach(cap_clau, "arm_L")


# --- turisme (Laura, guia turística): armilla de guia turquesa, samarreta blanca, visera,
#     pestanyes, placa de guia, plànol a la butxaca i banderí per a guiar el grup ---------
def outfit_turisme(b):
    from math import pi
    armilla = mat("Armilla_Guia",    (0.00, 0.33, 0.40), 0.6)
    vora    = mat("Vora_Guia",       (0.00, 0.28, 0.32), 0.6)
    samarreta = mat("Samarreta_Blanca_Guia", (0.93, 0.93, 0.92), 0.7)
    placa   = mat("Placa_Guia",      (0.95, 0.80, 0.10), 0.4)
    fosc    = mat("Text_Guia",       (0.05, 0.05, 0.05), 0.6)
    planol  = mat("Planol",          (0.92, 0.90, 0.80), 0.8)
    carrer  = mat("Planol_Carrer",   (0.85, 0.30, 0.20), 0.8)
    pal     = mat("Pal_Banderi",     (0.70, 0.72, 0.75), 0.25, metal=1.0)
    banderi = mat("Banderi",         (0.90, 0.25, 0.05), 0.5)

    pestanyes(b)

    # armilla de guia sense mànegues sobre una samarreta blanca, amb tapes de butxaca
    jaqueta_oberta(b, armilla, samarreta, nom="Armilla_Guia", nom_camisa="Samarreta", manegues=False)
    for side in (-1, 1):
        s = 'E' if side < 0 else 'D'
        b.add("cube", f"Vora_Obertura.{s}", (side * 0.345, -0.568, 0.60), "body", vora, scale=(0.012, 0.01, 0.52), size=2)
        b.add("cube", f"Butxaca_Tapa.{s}", (side * 0.53, -0.572, 0.36), "body", vora, scale=(0.12, 0.012, 0.04), bevel=0.01, size=2)
    # plànol plegat que sobreix de la butxaca esquerra
    b.add("cube", "Planol", (-0.55, -0.566, 0.43), "body", planol, scale=(0.08, 0.006, 0.07), rot=(0, 0.15, 0), size=2)
    b.add("cube", "Planol_Carrer", (-0.55, -0.573, 0.44), "body", carrer, scale=(0.06, 0.002, 0.006), rot=(0, 0.6, 0), size=2)
    # placa de guia al pit dret
    b.add("cube", "Placa_Guia", (0.53, -0.572, 0.92), "body", placa, scale=(0.1, 0.006, 0.045), bevel=0.008, size=2)
    b.add("cube", "Placa_Guia_Text", (0.53, -0.579, 0.92), "body", fosc, scale=(0.065, 0.002, 0.008), size=2)

    # visera turquesa (os head): cinta al voltant del cap i ala per davant; sense copa, l'antena queda lliure
    b.attach(b.band("Visera_Cinta", "Cap", 2.62, 0.10, armilla), "head")
    b.add("cylinder", "Visera_Ala", (0, -0.86, 2.64), "head", armilla, scale=(1, 0.7, 1), rot=(0.3, 0, 0),
          bevel=0.012, radius=0.46, depth=0.04, vertices=40)

    # banderí per a guiar el grup, alçat a la mà esquerra (os arm_L)
    x, y = -1.02, -0.22
    b.add("cylinder", "Banderi_Pal", (x, y, 0.78), "arm_L", pal, radius=0.016, depth=1.26, vertices=8)
    b.add("uv_sphere", "Banderi_Punta", (x, y, 1.42), "arm_L", pal, radius=0.03, segments=12, ring_count=6)
    b.add("cone", "Banderi", (x - 0.24, y, 1.26), "arm_L", banderi, scale=(0.15, 0.012, 0.24),
          rot=(0, -pi / 2, 0), radius1=1, depth=2, vertices=3)


# --- b1_persones (Elena, companya del curs de cuina): jersei menta, davantal roig de pitet,
#     mocador al cap, pestanyes, arracades, recepta a la butxaca i batedora de varetes ----
def outfit_cuina(b):
    from math import pi, sin, cos
    jersei   = mat("Jersei_Menta",     (0.22, 0.50, 0.38), 0.85)
    davantal = mat("Davantal_Roig",    (0.62, 0.04, 0.07), 0.75)
    ribet    = mat("Ribet_Blanc",      (0.93, 0.93, 0.92), 0.7)
    mocador  = mat("Mocador_Mostassa", (0.85, 0.58, 0.08), 0.7)
    punt     = mat("Punt_Blanc",       (0.95, 0.95, 0.93), 0.7)
    perla    = mat("Arracada_Cuina",   (0.95, 0.93, 0.88), 0.15)
    recepta  = mat("Recepta",          (0.95, 0.93, 0.85), 0.8)
    tinta    = mat("Tinta_Recepta",    (0.10, 0.15, 0.40), 0.6)
    acer     = mat("Acer_Batedora",    (0.80, 0.82, 0.85), 0.15, metal=1.0)
    manec    = mat("Manec_Batedora",   (0.62, 0.42, 0.22), 0.6)

    pestanyes(b)
    for side in (-1, 1):  # arracades: una perleta davall de cada orella
        b.add("uv_sphere", f"Arracada.{'E' if side < 0 else 'D'}", (side * 0.98, -0.12, 1.70), "head", perla,
              radius=0.04, segments=16, ring_count=8)

    # jersei menta (os body) amb mànegues llargues; el davantal va per damunt
    b.add("cube", "Jersei", (0, 0, 0.60), "body", jersei, scale=(0.70, 0.545, 0.575), bevel=0.24, segs=6, size=2)
    for side in (-1, 1):
        b.add("uv_sphere", f"Mànega.{'E' if side < 0 else 'D'}", (side * 0.87, 0, 0.60), "arm_L" if side < 0 else "arm_R",
              jersei, scale=(0.175, 0.175, 0.36), rot=(0, -side * 0.385, 0), segments=32, ring_count=16)
    b.add("torus", "Jersei_Coll", (0, 0, 1.2), "body", jersei, scale=(1, 1, 0.7),
          major_radius=0.29, minor_radius=0.055, major_segments=48, minor_segments=12)

    # davantal roig de pitet (darrere de la insígnia, que queda com un pegat) amb ribet blanc
    b.add("cube", "Davantal_Falda", (0, -0.551, 0.30), "body", davantal, scale=(0.55, 0.004, 0.27), bevel=0.003, size=2)
    b.add("cube", "Davantal_Pitet", (0, -0.551, 0.80), "body", davantal, scale=(0.38, 0.004, 0.23), bevel=0.003, size=2)
    b.add("cube", "Davantal_Ribet_Baix", (0, -0.565, 0.035), "body", ribet, scale=(0.55, 0.004, 0.01), size=2)
    for side in (-1, 1):
        s = 'E' if side < 0 else 'D'
        b.add("cube", f"Davantal_Ribet_Pitet.{s}", (side * 0.375, -0.565, 0.80), "body", ribet, scale=(0.008, 0.004, 0.22), size=2)
        b.add("cube", f"Davantal_Tirant.{s}", (side * 0.31, -0.555, 1.10), "body", davantal, scale=(0.03, 0.008, 0.08), size=2)
        b.add("cube", f"Davantal_Tirant_Dalt.{s}", (side * 0.27, -0.35, 1.18), "body", davantal,
              scale=(0.03, 0.19, 0.008), rot=(0, 0, side * 0.2), size=2)
    # butxaca amb una recepta
    b.add("cube", "Davantal_Butxaca", (0.27, -0.567, 0.24), "body", davantal, scale=(0.15, 0.006, 0.1), bevel=0.012, size=2)
    b.add("cube", "Davantal_Butxaca_Ribet", (0.27, -0.574, 0.335), "body", ribet, scale=(0.15, 0.003, 0.008), size=2)
    b.add("cube", "Recepta", (0.24, -0.572, 0.38), "body", recepta, scale=(0.07, 0.004, 0.06), rot=(0, -0.15, 0), size=2)
    for k in range(3):
        b.add("cube", f"Recepta_Linia.{k}", (0.24 - 0.004 * k, -0.577, 0.405 - k * 0.02), "body", tinta,
              scale=(0.05, 0.002, 0.003), rot=(0, -0.15, 0), size=2)

    # mocador mostassa al cap amb punts blancs i nus al costat (os head)
    b.attach(b.band("Mocador_Cap", "Cap", 2.62, 0.17, mocador), "head")
    for k, (x, z) in enumerate(((-0.55, 2.64), (-0.2, 2.6), (0.15, 2.65), (0.5, 2.6))):
        b.add("uv_sphere", f"Mocador_Punt.{k}", (x, -0.775, z), "head", punt, scale=(0.022, 0.006, 0.022), segments=10, ring_count=5)
    b.add("uv_sphere", "Mocador_Nus", (0.93, -0.25, 2.66), "head", mocador, scale=(0.05, 0.06, 0.05), segments=16, ring_count=8)
    for k, ang in enumerate((0.5, -0.4)):
        b.add("cone", f"Mocador_Punta.{k}", (0.98, -0.25 + 0.06 * (1 if k else -1), 2.58), "head", mocador,
              scale=(0.012, 0.05, 0.09), rot=(ang, 0, 0), radius1=1, depth=2, vertices=3)

    # batedora de varetes a la mà esquerra (os arm_L): mànec de fusta i varetes d'acer
    x, y = -1.03, -0.24
    b.add("cylinder", "Batedora_Manec", (x, y, 0.38), "arm_L", manec, radius=0.036, depth=0.3, vertices=12)
    for k in range(4):
        a = k * pi / 4
        b.add("torus", f"Batedora_Vareta.{k}", (x, y, 0.72), "arm_L", acer, scale=(0.55, 0.55, 1.0),
              rot=(pi / 2, 0, a), major_radius=0.2, minor_radius=0.01, major_segments=24, minor_segments=5)


# --- b1_relacions (Pau, el teu cosí, que prepara les noces d'or dels avis): sobrecamisa de
#     pana, samarreta, gorro de llana i globus daurat amb el número 50 ---------------------
def outfit_cosi(b):
    from math import pi, atan2
    from mathutils import Vector
    pana     = mat("Pana_Rovell",      (0.50, 0.18, 0.06), 0.9)
    pana_c   = mat("Pana_Clara",       (0.65, 0.30, 0.12), 0.9)
    samarreta = mat("Samarreta_Marina", (0.04, 0.07, 0.20), 0.8)
    botó     = mat("Botó_Banya",       (0.20, 0.12, 0.06), 0.4)
    llana    = mat("Gorro_Llana",      (0.04, 0.08, 0.22), 0.95)
    or_      = mat("Globus_Or",        (0.90, 0.68, 0.20), 0.25, metal=0.85)
    fil      = mat("Fil_Globus_Or",    (0.90, 0.90, 0.90), 0.6)

    # sobrecamisa de pana oberta amb samarreta marina; butxaques de pit amb tapa i botó, punys girats
    jaqueta_oberta(b, pana, samarreta, nom="Sobrecamisa", nom_camisa="Samarreta")
    b.add("torus", "Sobrecamisa_Coll", (0, 0, 1.2), "body", pana, scale=(1, 1, 0.7),
          major_radius=0.31, minor_radius=0.065, major_segments=48, minor_segments=12)
    for side in (-1, 1):
        s = 'E' if side < 0 else 'D'
        b.add("cube", f"Butxaca_Tapa.{s}", (side * 0.53, -0.572, 0.93), "body", pana_c, scale=(0.12, 0.012, 0.045), bevel=0.01, size=2)
        b.add("cylinder", f"Butxaca_Botó.{s}", (side * 0.53, -0.587, 0.91), "body", botó, rot=(pi / 2, 0, 0),
              radius=0.02, depth=0.01, vertices=12)
        b.add("torus", f"Puny_Girat.{s}", (side * 0.964, 0, 0.368), "arm_L" if side < 0 else "arm_R", pana_c,
              rot=(0, -side * 0.385, 0), major_radius=0.135, minor_radius=0.04, major_segments=32, minor_segments=8)
    for i, z in enumerate((0.75, 0.55, 0.35)):
        b.add("cylinder", f"Botó.{i}", (-0.40, -0.57, z), "body", botó, rot=(pi / 2, 0, 0), radius=0.024, depth=0.014, vertices=12)

    # gorro de llana amb la vora girada (os head); l'antena ix per dalt com una borla
    b.add("uv_sphere", "Gorro_Llana", (0, 0, 2.74), "head", llana, scale=(0.62, 0.62, 0.32), segments=40, ring_count=20)
    b.attach(b.band("Gorro_Llana_Vora", "Cap", 2.66, 0.14, llana), "head")

    # globus daurat «50» per a les noces d'or, lligat a la mà esquerra (os arm_L)
    y, k = -0.12, 1.5                     # k: mida dels números
    ox, oz = -1.40, 1.62                  # centre del globus
    ma, nus = Vector((-1.0, y, 0.36)), Vector((ox + 0.05, y, oz - 0.15 * k))
    d = nus - ma
    b.add("cylinder", "Globus_Fil", (ma + nus) / 2, "arm_L", fil, rot=(0, atan2(d.x, d.z), 0),
          radius=0.008, depth=d.length, vertices=6)
    # el «0»
    b.add("torus", "Globus_0", (ox + 0.14 * k, y, oz), "arm_L", or_, rot=(pi / 2, 0, 0), scale=(0.72, 1, 1),
          major_radius=0.12 * k, minor_radius=0.045 * k, major_segments=32, minor_segments=12)
    # el «5»: barra de dalt, traç vertical i panxa oberta a l'esquerra
    cx = ox - 0.13 * k
    b.add("cube", "Globus_5_Dalt", (cx + 0.02 * k, y, oz + 0.13 * k), "arm_L", or_,
          scale=(0.075 * k, 0.04 * k, 0.035 * k), bevel=0.03 * k, segs=6, size=2)
    b.add("cube", "Globus_5_Pal", (cx - 0.05 * k, y, oz + 0.06 * k), "arm_L", or_,
          scale=(0.035 * k, 0.04 * k, 0.07 * k), bevel=0.03 * k, segs=6, size=2)
    panxa = b.mesh("torus", "Globus_5_Panxa", (cx, y, oz - 0.08 * k), or_, rot=(pi / 2, 0, 0),
                   major_radius=0.085 * k, minor_radius=0.045 * k, major_segments=32, minor_segments=12)
    b.cut(panxa, (cx - 0.1 * k, y, oz - 0.02 * k), (0.07 * k, 0.1 * k, 0.07 * k))
    b.attach(panxa, "arm_L")


# --- b1_vida_quotidiana (Amparo, atenció al client d'Electrodomèstics Túria): auriculars
#     amb micròfon, polo blau de la botiga, pestanyes, arracada i cafetera italiana -------
def outfit_atencio_client(b):
    from math import pi, atan2
    from mathutils import Vector
    polo     = mat("Polo_Turia",       (0.03, 0.25, 0.55), 0.7)
    blanc    = mat("Blanc_Turia",      (0.93, 0.93, 0.92), 0.7)
    negre    = mat("Auriculars_Negre", (0.04, 0.04, 0.045), 0.4)
    escuma   = mat("Escuma_Micro",     (0.08, 0.08, 0.09), 0.95)
    perla    = mat("Arracada_Turia",   (0.95, 0.93, 0.88), 0.15)
    alumini  = mat("Alumini_Cafetera", (0.75, 0.77, 0.80), 0.3, metal=1.0)
    baquelita = mat("Baquelita",       (0.03, 0.03, 0.03), 0.4)

    pestanyes(b)
    b.add("uv_sphere", "Arracada.E", (-0.98, -0.12, 1.70), "head", perla, radius=0.04, segments=16, ring_count=8)

    # auriculars (os head): diadema per damunt del cap, desplaçada cap arrere perquè no toque
    # l'antena; un auricular a l'orella dreta i el micròfon cap a la boca
    diadema = b.mesh("torus", "Auriculars_Diadema", (0, 0.28, 2.05), negre, rot=(pi / 2, 0, 0), scale=(1.0, 1.0, 0.87),
                     major_radius=1.0, minor_radius=0.03, major_segments=64, minor_segments=8)
    b.cut(diadema, (0, 0.28, 1.5), (1.3, 0.2, 0.55))
    b.attach(diadema, "head")
    for side in (-1, 1):  # suports damunt de cada orella
        b.add("cube", f"Auriculars_Suport.{'E' if side < 0 else 'D'}", (side * 1.0, 0.28, 2.12), "head", negre,
              scale=(0.03, 0.03, 0.08), bevel=0.01, size=2)
    b.add("cylinder", "Auricular", (1.17, 0.0, 2.05), "head", negre, rot=(0, pi / 2, 0), bevel=0.02,
          radius=0.2, depth=0.08, vertices=32)
    b.add("cube", "Auricular_Pont", (1.07, 0.15, 2.1), "head", negre, scale=(0.08, 0.13, 0.025), size=2)
    # braç del micròfon: primer per fora del costat del cap i després per davant de la pantalla
    punts = [Vector((1.13, -0.15, 1.97)), Vector((1.0, -0.90, 1.86)), Vector((0.52, -0.92, 1.79))]
    for k, (p0, p1) in enumerate(zip(punts, punts[1:])):
        d = p1 - p0
        b.add("cylinder", f"Micro_Brac.{k}", (p0 + p1) / 2, "head", negre, rot=tuple(d.to_track_quat('Z', 'Y').to_euler()),
              radius=0.016, depth=d.length, vertices=8)
    b.add("uv_sphere", "Micro_Colze", punts[1], "head", negre, radius=0.018, segments=12, ring_count=6)
    b.add("uv_sphere", "Micro_Escuma", punts[2], "head", escuma, scale=(0.06, 0.05, 0.05), segments=16, ring_count=8)

    # polo blau d'Electrodomèstics Túria (os body): la senyera com a estampat, coll blanc i logo d'una ona
    b.add("cube", "Polo", (0, 0, 0.60), "body", polo, scale=(0.70, 0.548, 0.575), bevel=0.24, segs=6, size=2)
    b.add("torus", "Polo_Coll", (0, 0, 1.2), "body", blanc, scale=(1, 1, 0.7),
          major_radius=0.30, minor_radius=0.06, major_segments=48, minor_segments=12)
    for side in (-1, 1):  # mànegues curtes
        b.add("uv_sphere", f"Polo_Mànega.{'E' if side < 0 else 'D'}", (side * 0.806, 0, 0.758),
              "arm_L" if side < 0 else "arm_R", polo, scale=(0.19, 0.19, 0.2), rot=(0, -side * 0.385, 0),
              segments=32, ring_count=16)
    for k, dx in enumerate((-0.04, 0.04)):  # logo: dues ones blanques
        ona = b.mesh("torus", f"Logo_Ona.{k}", (0.52 + dx, -0.553, 0.92 - 0.02 * k), blanc, rot=(pi / 2, 0, 0),
                     major_radius=0.035, minor_radius=0.008, major_segments=24, minor_segments=6)
        b.cut(ona, (0.52 + dx, -0.553, 0.88 - 0.02 * k), (0.06, 0.05, 0.035))
        b.attach(ona, "body")

    # cafetera italiana a la mà esquerra (os arm_L): dipòsit i part de dalt octogonals, mànec negre
    x, y = -1.03, -0.24
    b.add("cone", "Cafetera_Baix", (x, y, 0.29), "arm_L", alumini, radius1=0.10, radius2=0.075, depth=0.16, vertices=8)
    b.add("cylinder", "Cafetera_Cintura", (x, y, 0.38), "arm_L", alumini, radius=0.078, depth=0.025, vertices=8)
    b.add("cone", "Cafetera_Dalt", (x, y, 0.47), "arm_L", alumini, radius1=0.075, radius2=0.095, depth=0.16, vertices=8)
    b.add("cone", "Cafetera_Tapa", (x, y, 0.57), "arm_L", alumini, radius1=0.095, radius2=0.04, depth=0.04, vertices=8)
    b.add("uv_sphere", "Cafetera_Pom", (x, y, 0.605), "arm_L", baquelita, radius=0.022, segments=12, ring_count=6)
    b.add("cube", "Cafetera_Manec", (x + 0.12, y, 0.47), "arm_L", baquelita, scale=(0.02, 0.018, 0.075), bevel=0.01, size=2)
    b.add("cone", "Cafetera_Broc", (x - 0.1, y, 0.53), "arm_L", alumini, rot=(0, -1.0, 0), radius1=0.025, radius2=0.008,
          depth=0.06, vertices=8)


# --- b1_llocs (Joan, agent immobiliari de Castelló): americana camel, camisa celeste de
#     coll obert, mocador de butxaca, rellotge i claus del pis amb un clauer en forma de casa
def outfit_immobiliaria(b):
    from math import pi
    from mathutils import Matrix, Vector
    camel   = mat("Americana_Camel",  (0.38, 0.22, 0.08), 0.6)
    solapa  = mat("Solapa_Camel",     (0.24, 0.13, 0.05), 0.5)
    camisa  = mat("Camisa_Celeste_Coll_Obert", (0.55, 0.72, 0.88), 0.6)
    daurat  = mat("Daurat_Immobiliaria", (0.85, 0.62, 0.15), 0.3, metal=0.9)
    roig    = mat("Mocador_Butxaca_Roig", (0.65, 0.04, 0.05), 0.5)
    esfera  = mat("Esfera_Rellotge",  (0.95, 0.95, 0.93), 0.2)
    casa    = mat("Clauer_Casa",      (0.95, 0.93, 0.88), 0.5)
    teulada = mat("Clauer_Teulada",   (0.70, 0.12, 0.06), 0.5)
    acer    = mat("Acer_Claus_Pis",   (0.72, 0.74, 0.77), 0.25, metal=1.0)

    # americana camel amb camisa celeste; coll de la camisa obert (dues puntes) i mocador de butxaca
    americana_oberta(b, camel, solapa, camisa, daurat)
    for side in (-1, 1):
        b.add("cone", f"Camisa_Coll.{'E' if side < 0 else 'D'}", (side * 0.17, -0.40, 1.19), "body", camisa,
              scale=(0.09, 0.012, 0.06), rot=(-0.6, 0, side * 0.5), radius1=1, depth=2, vertices=3)
    b.add("torus", "Camisa_Coll_Darrere", (0, 0.02, 1.19), "body", camisa, scale=(1, 1, 0.6),
          major_radius=0.30, minor_radius=0.05, major_segments=48, minor_segments=12)
    b.add("cube", "Butxaca_Vora", (0.52, -0.572, 0.93), "body", solapa, scale=(0.12, 0.008, 0.012), size=2)
    b.add("cone", "Mocador_Butxaca", (0.50, -0.568, 0.97), "body", roig,
          scale=(0.07, 0.008, 0.05), rot=(0, 0.15, 0), radius1=1, depth=2, vertices=3)

    # rellotge daurat al canell dret (os arm_R)
    b.add("torus", "Rellotge_Corretja", (0.964, 0, 0.368), "arm_R", daurat, rot=(0, -0.385, 0),
          major_radius=0.135, minor_radius=0.025, major_segments=32, minor_segments=8)
    b.add("cylinder", "Rellotge_Caixa", (0.93, -0.14, 0.37), "arm_R", daurat, rot=(pi / 2, 0, 0),
          radius=0.045, depth=0.025, vertices=24)
    b.add("cylinder", "Rellotge_Esfera", (0.93, -0.153, 0.37), "arm_R", esfera, rot=(pi / 2, 0, 0),
          radius=0.035, depth=0.004, vertices=24)

    # claus del pis amb clauer en forma de caseta, a la mà esquerra (os arm_L), alçades per a ensenyar-les
    x, y, k = -1.04, -0.26, 1.8
    b.add("cube", "Clauer_Casa", (x, y, 0.36), "arm_L", casa, scale=(0.06 * k, 0.018 * k, 0.05 * k), bevel=0.006, size=2)
    b.add("cone", "Clauer_Teulada", (x, y, 0.36 + 0.085 * k), "arm_L", teulada, scale=(0.075 * k, 0.022 * k, 0.035 * k),
          rot=(0, 0, pi / 4), radius1=1.41, radius2=0, depth=2, vertices=4)
    b.add("cube", "Clauer_Porta", (x, y - 0.02 * k, 0.345), "arm_L", teulada, scale=(0.015 * k, 0.003, 0.025 * k), size=2)
    b.add("torus", "Clauer_Anella_Pis", (x, y, 0.36 + 0.16 * k), "arm_L", acer, rot=(pi / 2, 0, 0),
          major_radius=0.035 * k, minor_radius=0.007 * k, major_segments=20, minor_segments=6)
    for j, ang in enumerate((0.35, -0.3)):
        rot = Matrix.Rotation(ang, 3, 'Y')
        top = Vector((x, y, 0.36 + 0.19 * k))
        b.add("cylinder", f"Clau_Pis_Cap.{j}", top + rot @ Vector((0, 0, 0.04 * k)), "arm_L", acer, rot=(pi / 2, 0, 0),
              radius=0.035 * k, depth=0.012 * k, vertices=20)
        b.add("cube", f"Clau_Pis_Tija.{j}", top + rot @ Vector((0, 0, 0.12 * k)), "arm_L", acer, rot=(0, ang, 0),
              scale=(0.011 * k, 0.005 * k, 0.055 * k), size=2)
        b.add("cube", f"Clau_Pis_Dents.{j}", top + rot @ Vector((0.016 * k, 0, 0.14 * k)), "arm_L", acer, rot=(0, ang, 0),
              scale=(0.008 * k, 0.005 * k, 0.02 * k), size=2)


# --- b1_viatges (Neus, agent de viatges de Gandia): americana blau cel, top blanc, fular de
#     seda al coll, placa amb un avió, pestanyes, arracades i bola del món --------------
def outfit_viatges(b):
    from math import pi, sin, cos, radians
    from mathutils import Vector
    americana = mat("Americana_Cel",   (0.08, 0.32, 0.62), 0.5)
    solapa    = mat("Solapa_Cel",      (0.04, 0.18, 0.40), 0.4)
    top       = mat("Top_Blanc_Viatges", (0.93, 0.93, 0.92), 0.6)
    daurat    = mat("Daurat_Viatges",  (0.85, 0.62, 0.15), 0.3, metal=0.9)
    fular     = mat("Fular_Corall",    (0.90, 0.30, 0.20), 0.35)
    perla     = mat("Arracada_Viatges", (0.95, 0.93, 0.88), 0.15)
    mari      = mat("Avio_Mari",       (0.04, 0.10, 0.30), 0.5)
    oceà      = mat("Bola_Ocea",       (0.05, 0.35, 0.75), 0.35)
    terra     = mat("Bola_Terra",      (0.20, 0.55, 0.15), 0.6)

    pestanyes(b)
    for side in (-1, 1):
        b.add("uv_sphere", f"Arracada.{'E' if side < 0 else 'D'}", (side * 0.98, -0.12, 1.70), "head", perla,
              radius=0.04, segments=16, ring_count=8)

    # americana blau cel oberta amb top blanc i botons daurats
    americana_oberta(b, americana, solapa, top, daurat)

    # fular de seda corall al coll, amb el nus i les puntes a la dreta (os body)
    b.add("torus", "Fular_Coll", (0, 0, 1.22), "body", fular, scale=(1, 1, 0.8),
          major_radius=0.28, minor_radius=0.055, major_segments=48, minor_segments=12)
    # nus a la vora de davant del pit (per damunt de la senyera) i puntes penjant
    b.add("cube", "Fular_Davant", (0.12, -0.42, 1.185), "body", fular, scale=(0.14, 0.11, 0.02), rot=(0, 0, -0.5),
          bevel=0.015, size=2)
    b.add("uv_sphere", "Fular_Nus", (0.22, -0.54, 1.14), "body", fular, scale=(0.075, 0.04, 0.065), segments=20, ring_count=10)
    for k, (dx, ang, llarg) in enumerate(((-0.02, 0.15, 0.11), (0.08, -0.35, 0.09))):
        b.add("cone", f"Fular_Punta.{k}", (0.22 + dx, -0.56, 1.14 - llarg), "body", fular, scale=(0.055, 0.012, llarg),
              rot=(pi, ang, 0), radius1=1, depth=2, vertices=3)

    # placa amb un avionet al pit dret
    b.add("cube", "Placa_Viatges", (0.53, -0.572, 0.82), "body", daurat, scale=(0.1, 0.006, 0.04), bevel=0.008, size=2)
    b.add("cube", "Avio_Fuselatge", (0.49, -0.579, 0.82), "body", mari, scale=(0.035, 0.002, 0.007), size=2)
    b.add("cube", "Avio_Ales", (0.495, -0.579, 0.82), "body", mari, scale=(0.008, 0.002, 0.03), size=2)
    b.add("cube", "Placa_Viatges_Text", (0.575, -0.579, 0.82), "body", mari, scale=(0.035, 0.002, 0.006), size=2)

    # bola del món en un peu, damunt de la mà esquerra (os arm_L)
    x, y = -1.06, -0.24
    b.add("cylinder", "Bola_Peu", (x, y, 0.40), "arm_L", daurat, bevel=0.006, radius=0.09, depth=0.03, vertices=24)
    b.add("cylinder", "Bola_Tija", (x, y, 0.46), "arm_L", daurat, radius=0.014, depth=0.1, vertices=8)
    c = Vector((x, y, 0.67))
    r = 0.18
    b.add("uv_sphere", "Bola_Mon", c, "arm_L", oceà, radius=r, segments=32, ring_count=16)
    b.add("torus", "Bola_Meridia", c, "arm_L", daurat, rot=(pi / 2, 0, 0.35), major_radius=r + 0.02, minor_radius=0.008,
          major_segments=40, minor_segments=6)
    for k, (lon, lat, sx, sz) in enumerate(((-110, 25, 0.08, 0.07), (-75, -10, 0.06, 0.08), (-130, -30, 0.05, 0.04),
                                           (-50, 35, 0.055, 0.04))):
        lo, la = radians(lon), radians(lat)
        n = Vector((cos(la) * cos(lo), cos(la) * sin(lo), sin(la)))
        b.add("uv_sphere", f"Bola_Continent.{k}", c + n * (r + 0.002), "arm_L", terra,
              scale=(sx, 0.012, sz), rot=tuple(n.to_track_quat('Y', 'Z').to_euler()), segments=12, ring_count=6)


# --- b1_oci_esport (Andreu, amic esportista amb el diari obert per l'agenda cultural):
#     jaqueta de xandall amb franges, samarreta esportiva, rellotge esportiu i el diari ----
def outfit_esport(b):
    from math import pi, sin, cos
    from mathutils import Vector
    xandall  = mat("Xandall_Negre",    (0.03, 0.03, 0.035), 0.55)
    franja   = mat("Franja_Taronja",   (0.95, 0.40, 0.03), 0.5)
    samarreta = mat("Samarreta_Esport", (0.65, 0.67, 0.70), 0.7)
    rellotge = mat("Rellotge_Esport",  (0.04, 0.04, 0.05), 0.3)
    pantalla = mat("Pantalla_Rellotge", (0.10, 0.80, 0.50), 0.2, emit=0.8)
    paper    = mat("Diari_Paper",      (0.90, 0.89, 0.85), 0.85)
    text     = mat("Diari_Text",       (0.45, 0.45, 0.47), 0.8)
    titular  = mat("Diari_Titular",    (0.05, 0.05, 0.05), 0.7)
    foto     = mat("Diari_Foto",       (0.35, 0.45, 0.60), 0.6)

    # jaqueta de xandall oberta amb samarreta gris; vores de la cremallera i coll taronja
    jaqueta_oberta(b, xandall, samarreta, nom="Jaqueta_Xandall", nom_camisa="Samarreta")
    b.add("torus", "Xandall_Coll", (0, 0, 1.2), "body", xandall, scale=(1, 1, 0.75),
          major_radius=0.31, minor_radius=0.06, major_segments=48, minor_segments=12)
    for side in (-1, 1):
        s = 'E' if side < 0 else 'D'
        bone = "arm_L" if side < 0 else "arm_R"
        b.add("cube", f"Cremallera_Vora.{s}", (side * 0.35, -0.568, 0.60), "body", franja, scale=(0.022, 0.01, 0.52), size=2)
        # dues franges al llarg de cada mànega, pel costat de fora i un poc cap a davant
        a = -side * 0.385
        eix = Vector((sin(a), 0, cos(a)))
        fora = Vector((cos(a) * side, 0, -sin(a) * side)).normalized()
        centre = Vector((side * 0.87, 0, 0.60))
        n = (fora * 0.8 + Vector((0, -0.6, 0))).normalized()
        b.add("cube", f"Mànega_Franja.{s}", centre + n * 0.16, bone, franja, rot=(0, a, 0),
              scale=(0.03, 0.03, 0.31), bevel=0.012, size=2)
        b.add("cube", f"Costat_Franja.{s}", (side * 0.712, -0.1, 0.60), "body", franja, scale=(0.006, 0.012, 0.5), size=2)

    # rellotge esportiu al canell dret (os arm_R)
    b.add("torus", "Rellotge_Esport_Corretja", (0.964, 0, 0.368), "arm_R", rellotge, rot=(0, -0.385, 0),
          major_radius=0.135, minor_radius=0.03, major_segments=32, minor_segments=8)
    b.add("cube", "Rellotge_Esport_Caixa", (0.93, -0.15, 0.37), "arm_R", rellotge, scale=(0.045, 0.015, 0.05), bevel=0.012, size=2)
    b.add("cube", "Rellotge_Esport_Pantalla", (0.93, -0.166, 0.37), "arm_R", pantalla, scale=(0.032, 0.002, 0.036), size=2)

    # el diari obert per l'agenda cultural, a la mà esquerra (os arm_L)
    x, y, z, w, h = -1.08, -0.27, 0.40, 0.21, 0.27
    for k, dx in enumerate((-w * 0.5, w * 0.5)):  # dues pàgines, un poc en angle com un diari obert
        b.add("cube", f"Diari_Pagina.{k}", (x + dx, y - 0.01 * (1 - k), z), "arm_L", paper, rot=(0, 0, (-1 if k else 1) * 0.18),
              scale=(w * 0.5, 0.006, h), size=2)
    yf = y - 0.03
    b.add("cube", "Diari_Titular", (x - w * 0.5, yf, z + h * 0.78), "arm_L", titular, scale=(w * 0.42, 0.003, 0.018), size=2)
    b.add("cube", "Diari_Foto", (x - w * 0.62, yf, z + h * 0.3), "arm_L", foto, scale=(w * 0.26, 0.003, 0.05), size=2)
    for k in range(6):
        col = -1 if k < 3 else 1
        zz = z + h * (0.0 - 0.22 * (k % 3)) if col < 0 else z + h * (0.62 - 0.22 * (k % 3) * 1.4)
        b.add("cube", f"Diari_Linia.{k}", (x + col * w * 0.5, yf, zz), "arm_L", text, scale=(w * 0.38, 0.003, 0.007), size=2)


# --- b1_territori (Hannah, estudiant d'Erasmus que prepara una presentació sobre la Comunitat
#     Valenciana): jersei mostassa, motxilla, pestanyes i un mapa per a la presentació -----
def outfit_erasmus(b):
    from math import pi
    jersei  = mat("Jersei_Mostassa",  (0.70, 0.45, 0.05), 0.85)
    motxilla = mat("Motxilla_Marina", (0.04, 0.08, 0.22), 0.7)
    cremallera = mat("Cremallera_Taronja", (0.95, 0.40, 0.03), 0.5)
    sivella = mat("Sivella_Negra",    (0.05, 0.05, 0.05), 0.5)
    paper   = mat("Mapa_Paper",       (0.95, 0.94, 0.90), 0.8)
    mar     = mat("Mapa_Mar",         (0.20, 0.50, 0.85), 0.6)
    terra   = mat("Mapa_Terra",       (0.85, 0.70, 0.40), 0.7)
    ciutat  = mat("Mapa_Ciutat",      (0.80, 0.05, 0.05), 0.5)

    pestanyes(b)

    # jersei mostassa (os body) amb mànegues llargues; la senyera queda com un estampat
    b.add("cube", "Jersei", (0, 0, 0.60), "body", jersei, scale=(0.70, 0.548, 0.575), bevel=0.24, segs=6, size=2)
    for side in (-1, 1):
        b.add("uv_sphere", f"Mànega.{'E' if side < 0 else 'D'}", (side * 0.87, 0, 0.60), "arm_L" if side < 0 else "arm_R",
              jersei, scale=(0.175, 0.175, 0.36), rot=(0, -side * 0.385, 0), segments=32, ring_count=16)
    b.add("torus", "Jersei_Coll", (0, 0, 1.2), "body", jersei, scale=(1, 1, 0.75),
          major_radius=0.29, minor_radius=0.06, major_segments=48, minor_segments=12)

    # motxilla a l'esquena amb cremallera taronja i les corretges per davant (fora de la senyera)
    b.add("cube", "Motxilla", (0, 0.68, 0.80), "body", motxilla, scale=(0.50, 0.15, 0.50), bevel=0.12, segs=6, size=2)
    b.add("cube", "Motxilla_Butxaca", (0, 0.83, 0.50), "body", motxilla, scale=(0.36, 0.04, 0.18), bevel=0.05, segs=4, size=2)
    b.add("cube", "Motxilla_Cremallera", (0, 0.875, 0.62), "body", cremallera, scale=(0.3, 0.006, 0.008), size=2)
    b.add("torus", "Motxilla_Nansa", (0, 0.62, 1.31), "body", motxilla, rot=(0, pi / 2, 0), scale=(1, 0.6, 1),
          major_radius=0.07, minor_radius=0.018, major_segments=20, minor_segments=6)
    for side in (-1, 1):
        s = 'E' if side < 0 else 'D'
        b.add("cube", f"Corretja_Davant.{s}", (side * 0.43, -0.556, 0.82), "body", motxilla, scale=(0.045, 0.008, 0.35), size=2)
        b.add("cube", f"Corretja_Espatla.{s}", (side * 0.43, 0.0, 1.183), "body", motxilla, scale=(0.045, 0.56, 0.008), size=2)
        b.add("cube", f"Corretja_Sivella.{s}", (side * 0.43, -0.565, 0.52), "body", sivella, scale=(0.05, 0.006, 0.02), size=2)
    b.add("cube", "Corretja_Pit", (0, -0.566, 0.98), "body", motxilla, scale=(0.43, 0.006, 0.018), size=2)
    b.add("cube", "Corretja_Pit_Sivella", (0, -0.574, 0.98), "body", sivella, scale=(0.035, 0.004, 0.025), size=2)

    # mapa per a la presentació, a la mà esquerra (os arm_L): mar blau, la costa i València
    x, y, z, w, h = -1.09, -0.27, 0.42, 0.22, 0.28
    b.add("cube", "Mapa", (x, y, z), "arm_L", paper, scale=(w, 0.008, h), bevel=0.006, size=2)
    b.add("cube", "Mapa_Mar", (x + w * 0.35, y - 0.009, z), "arm_L", mar, scale=(w * 0.6, 0.002, h * 0.92), size=2)
    b.add("uv_sphere", "Mapa_Terra", (x - w * 0.18, y - 0.011, z), "arm_L", terra, scale=(0.08, 0.003, 0.24),
          rot=(0, 0.3, 0), segments=16, ring_count=8)
    b.add("uv_sphere", "Mapa_Valencia", (x - w * 0.05, y - 0.016, z - 0.01), "arm_L", ciutat, radius=0.024,
          segments=12, ring_count=6)


# --- b1_cultura (Àlex, locutor d'una ràdio local): auriculars d'estudi, jaqueta bomber,
#     samarreta i micròfon de mà per a l'entrevista -----------------------------------------
def outfit_radio(b):
    from math import pi
    bomber   = mat("Bomber_Granat",    (0.30, 0.03, 0.06), 0.55)
    canale   = mat("Canale_Negre",     (0.04, 0.04, 0.045), 0.9)
    samarreta = mat("Samarreta_Negra", (0.05, 0.05, 0.06), 0.8)
    negre    = mat("Auriculars_Estudi", (0.04, 0.04, 0.045), 0.35)
    roig     = mat("Anell_Roig",       (0.80, 0.06, 0.05), 0.4)
    reixeta  = mat("Reixeta_Micro",    (0.75, 0.77, 0.80), 0.35, metal=1.0)
    cub      = mat("Cub_Emissora",     (0.80, 0.06, 0.05), 0.4)
    logo     = mat("Logo_Emissora",    (0.95, 0.95, 0.93), 0.6)

    # auriculars d'estudi tapant les dues orelles (os head); la diadema va un poc arrere de l'antena
    diadema = b.mesh("torus", "Auriculars_Estudi_Diadema", (0, 0.28, 2.05), negre, rot=(pi / 2, 0, 0), scale=(1.0, 1.0, 0.87),
                     major_radius=1.05, minor_radius=0.04, major_segments=64, minor_segments=8)
    b.cut(diadema, (0, 0.28, 1.5), (1.4, 0.2, 0.55))
    b.attach(diadema, "head")
    for side in (-1, 1):
        s = 'E' if side < 0 else 'D'
        b.add("cylinder", f"Auricular_Estudi.{s}", (side * 1.10, 0.0, 2.05), "head", negre, rot=(0, pi / 2, 0),
              bevel=0.04, radius=0.36, depth=0.2, vertices=40)
        b.add("torus", f"Auricular_Estudi_Anell.{s}", (side * 1.205, 0.0, 2.05), "head", roig, rot=(0, pi / 2, 0),
              major_radius=0.25, minor_radius=0.022, major_segments=40, minor_segments=8)
        b.add("cube", f"Auricular_Estudi_Suport.{s}", (side * 1.08, 0.18, 2.32), "head", negre,
              scale=(0.035, 0.12, 0.05), rot=(0.6, 0, 0), bevel=0.012, size=2)

    # jaqueta bomber granat oberta amb samarreta negra; canalé al coll i als punys
    jaqueta_oberta(b, bomber, samarreta, nom="Bomber", nom_camisa="Samarreta")
    b.add("torus", "Bomber_Coll", (0, 0, 1.2), "body", canale, scale=(1, 1, 0.75),
          major_radius=0.31, minor_radius=0.06, major_segments=48, minor_segments=12)
    for side in (-1, 1):
        b.add("torus", f"Bomber_Puny.{'E' if side < 0 else 'D'}", (side * 0.964, 0, 0.368), "arm_L" if side < 0 else "arm_R",
              canale, rot=(0, -side * 0.385, 0), major_radius=0.135, minor_radius=0.04, major_segments=32, minor_segments=8)

    # micròfon de mà amb el cub de l'emissora, alçat a la mà esquerra (os arm_L)
    x, y = -1.04, -0.25
    b.add("cylinder", "Micro_Ma_Manec", (x, y, 0.38), "arm_L", negre, radius=0.045, depth=0.36, vertices=16)
    b.add("cube", "Micro_Ma_Cub", (x, y, 0.60), "arm_L", cub, scale=(0.09, 0.09, 0.07), bevel=0.012, size=2)
    b.add("cylinder", "Micro_Ma_Logo", (x, y - 0.091, 0.60), "arm_L", logo, rot=(pi / 2, 0, 0), radius=0.045, depth=0.004, vertices=16)
    b.add("uv_sphere", "Micro_Ma_Reixeta", (x, y, 0.76), "arm_L", reixeta, radius=0.1, segments=24, ring_count=12)


# --- b1_natura_clima (Pilar, guia del Parc Natural del Montgó): camisa de guarda oliva amb
#     butxaques i insígnia, barret d'excursió, pestanyes, prismàtics i bastó de senderisme --
def outfit_parc_natural(b):
    from math import pi
    camisa  = mat("Camisa_Guarda",    (0.20, 0.24, 0.10), 0.8)
    tapa    = mat("Tapa_Guarda",      (0.14, 0.17, 0.07), 0.8)
    caqui   = mat("Barret_Caqui",     (0.45, 0.37, 0.20), 0.9)
    cinta   = mat("Cinta_Verda",      (0.05, 0.18, 0.08), 0.7)
    insignia = mat("Insignia_Parc",   (0.08, 0.40, 0.15), 0.6)
    fulla   = mat("Fulla_Insignia",   (0.93, 0.93, 0.90), 0.6)
    negre   = mat("Prismatics",       (0.05, 0.05, 0.06), 0.4)
    lent    = mat("Lent_Prismatics",  (0.10, 0.25, 0.40), 0.05, metal=0.5)
    alumini = mat("Alumini_Basto",    (0.30, 0.45, 0.65), 0.3, metal=0.9)
    goma    = mat("Puny_Basto",       (0.04, 0.04, 0.05), 0.8)

    pestanyes(b)

    # camisa de guarda (os body), mànegues llargues amb el puny girat, tapes de butxaca i insígnia
    b.add("cube", "Camisa_Guarda", (0, 0, 0.60), "body", camisa, scale=(0.70, 0.548, 0.575), bevel=0.24, segs=6, size=2)
    b.add("torus", "Camisa_Guarda_Coll", (0, 0, 1.2), "body", camisa, scale=(1, 1, 0.7),
          major_radius=0.30, minor_radius=0.06, major_segments=48, minor_segments=12)
    for side in (-1, 1):
        s = 'E' if side < 0 else 'D'
        bone = "arm_L" if side < 0 else "arm_R"
        b.add("uv_sphere", f"Mànega.{s}", (side * 0.87, 0, 0.60), bone, camisa, scale=(0.175, 0.175, 0.36),
              rot=(0, -side * 0.385, 0), segments=32, ring_count=16)
        b.add("torus", f"Puny_Girat.{s}", (side * 0.964, 0, 0.368), bone, tapa, rot=(0, -side * 0.385, 0),
              major_radius=0.135, minor_radius=0.04, major_segments=32, minor_segments=8)
        b.add("cube", f"Butxaca_Tapa.{s}", (side * 0.53, -0.56, 0.86), "body", tapa, scale=(0.12, 0.012, 0.045), bevel=0.01, size=2)
    b.add("cylinder", "Insignia_Parc", (-0.53, -0.555, 1.02), "body", insignia, rot=(pi / 2, 0, 0), radius=0.085, depth=0.012, vertices=32)
    b.add("uv_sphere", "Insignia_Fulla", (-0.53, -0.563, 1.02), "body", fulla, scale=(0.03, 0.004, 0.055), rot=(0, 0.6, 0),
          segments=12, ring_count=6)

    # barret d'excursió d'ala ampla (os head); l'antena ix per dalt
    b.add("cone", "Barret_Ala", (0, 0, 2.80), "head", caqui, radius1=1.02, radius2=0.56, depth=0.08, vertices=64)
    b.add("cylinder", "Barret_Copa", (0, 0, 2.95), "head", caqui, bevel=0.06, radius=0.52, depth=0.28, vertices=48)
    b.add("cylinder", "Barret_Cinta", (0, 0, 2.86), "head", cinta, radius=0.535, depth=0.06, vertices=48)

    # prismàtics penjant al maluc dret, amb la corretja pel costat dret
    b.add("cube", "Prismatics_Corretja", (0.55, -0.556, 0.80), "body", negre, scale=(0.015, 0.006, 0.38), size=2)
    for dx in (-0.075, 0.075):
        b.add("cylinder", f"Prismatics_Tub.{'E' if dx < 0 else 'D'}", (0.55 + dx, -0.64, 0.36), "body", negre,
              rot=(pi / 2, 0, 0), radius=0.063, depth=0.19, vertices=20)
        b.add("cylinder", f"Prismatics_Lent.{'E' if dx < 0 else 'D'}", (0.55 + dx, -0.737, 0.36), "body", lent,
              rot=(pi / 2, 0, 0), radius=0.05, depth=0.006, vertices=20)
    b.add("cube", "Prismatics_Pont", (0.55, -0.64, 0.36), "body", negre, scale=(0.05, 0.04, 0.025), size=2)

    # bastó de senderisme a la mà esquerra (os arm_L)
    x, y = -1.03, -0.22
    b.add("cylinder", "Basto", (x, y, 0.42), "arm_L", alumini, radius=0.024, depth=1.1, vertices=10)
    b.add("cylinder", "Basto_Puny", (x, y, 0.88), "arm_L", goma, bevel=0.01, radius=0.04, depth=0.18, vertices=12)
    b.add("cylinder", "Basto_Disc", (x, y, 0.0), "arm_L", goma, radius=0.05, depth=0.012, vertices=16)
    b.add("cone", "Basto_Punta", (x, y, -0.15), "arm_L", goma, rot=(pi, 0, 0), radius1=0.016, radius2=0.004, depth=0.06, vertices=8)


# --- colegi (Marta, mestra): rebeca corall, brusa amb coll rodó, ulleres de lectura penjades
#     d'una cadeneta, pestanyes, arracades i llibres amb una poma --------------------------
def outfit_mestra(b):
    from math import pi
    from mathutils import Vector
    rebeca  = mat("Rebeca_Corall",   (0.70, 0.22, 0.16), 0.85)
    brusa   = mat("Brusa_Mestra",    (0.94, 0.94, 0.93), 0.6)
    botó    = mat("Botó_Mestra",     (0.95, 0.93, 0.88), 0.2)
    daurat  = mat("Cadeneta_Daurada", (0.85, 0.62, 0.15), 0.3, metal=0.9)
    montura = mat("Montura_Lectura", (0.25, 0.12, 0.05), 0.35)
    perla   = mat("Arracada_Mestra", (0.95, 0.93, 0.88), 0.15)
    llibre1 = mat("Llibre_Blau",     (0.06, 0.20, 0.55), 0.6)
    llibre2 = mat("Llibre_Verd",     (0.08, 0.40, 0.20), 0.6)
    pagines = mat("Pagines",         (0.95, 0.93, 0.85), 0.8)
    poma    = mat("Poma",            (0.75, 0.04, 0.04), 0.35)
    fulla   = mat("Fulla_Poma",      (0.15, 0.50, 0.10), 0.5)
    rabet   = mat("Rabet_Poma",      (0.30, 0.17, 0.08), 0.6)

    pestanyes(b)
    for side in (-1, 1):
        b.add("uv_sphere", f"Arracada.{'E' if side < 0 else 'D'}", (side * 0.98, -0.12, 1.70), "head", perla,
              radius=0.04, segments=16, ring_count=8)

    # rebeca corall oberta amb brusa blanca; coll rodó (dues mitges llunes) i botons
    jaqueta_oberta(b, rebeca, brusa, nom="Rebeca", nom_camisa="Brusa")
    for side in (-1, 1):
        coll = b.mesh("cylinder", f"Brusa_Coll_Rodo.{'E' if side < 0 else 'D'}", (side * 0.12, -0.45, 1.185), brusa,
                      rot=(0.25, 0, 0), radius=0.13, depth=0.02, vertices=32)
        b.cut(coll, (side * 0.12, -0.32, 1.19), (0.2, 0.12, 0.1))
        b.attach(coll, "body")
    for i, z in enumerate((0.75, 0.55, 0.35)):
        b.add("uv_sphere", f"Botó.{i}", (-0.40, -0.57, z), "body", botó, scale=(0.026, 0.012, 0.026), segments=12, ring_count=6)

    # ulleres de lectura penjant d'una cadeneta daurada, per damunt de la senyera (os body)
    for side in (-1, 1):
        s = 'E' if side < 0 else 'D'
        b.add("torus", f"Ulleres_Lectura.{s}", (side * 0.085, -0.565, 0.99), "body", montura, rot=(pi / 2, 0, 0),
              major_radius=0.06, minor_radius=0.009, major_segments=24, minor_segments=6)
        p0, p1 = Vector((side * 0.2, -0.46, 1.175)), Vector((side * 0.145, -0.565, 1.0))
        d = p1 - p0
        b.add("cylinder", f"Cadeneta.{s}", (p0 + p1) / 2, "body", daurat, rot=tuple(d.to_track_quat('Z', 'Y').to_euler()),
              radius=0.006, depth=d.length, vertices=6)
    b.add("cube", "Ulleres_Lectura_Pont", (0, -0.565, 1.01), "body", montura, scale=(0.025, 0.006, 0.006), size=2)

    # llibres amb una poma damunt, a la mà esquerra (os arm_L)
    x, y, k = -1.08, -0.2, 1.35  # k: escala del conjunt
    z0 = 0.42
    def pos(dx, dy, dz):
        return (x + dx * k, y + dy * k, z0 + dz * k)
    b.add("cube", "Llibre_1", pos(0, 0, 0), "arm_L", llibre1, scale=(0.17 * k, 0.12 * k, 0.035 * k), bevel=0.006, size=2)
    b.add("cube", "Llibre_1_Pagines", pos(0.01, -0.005, 0), "arm_L", pagines, scale=(0.165 * k, 0.118 * k, 0.027 * k), size=2)
    b.add("cube", "Llibre_2", pos(0.01, -0.01, 0.065), "arm_L", llibre2, rot=(0, 0, 0.15),
          scale=(0.15 * k, 0.11 * k, 0.03 * k), bevel=0.006, size=2)
    b.add("cube", "Llibre_2_Pagines", pos(0.02, -0.015, 0.065), "arm_L", pagines, rot=(0, 0, 0.15),
          scale=(0.145 * k, 0.108 * k, 0.023 * k), size=2)
    b.add("uv_sphere", "Poma", pos(0, -0.02, 0.16), "arm_L", poma, scale=(0.07 * k, 0.07 * k, 0.065 * k), segments=24, ring_count=12)
    b.add("cylinder", "Poma_Rabet", pos(0, -0.02, 0.235), "arm_L", rabet, radius=0.008 * k, depth=0.04 * k, vertices=6)
    b.add("uv_sphere", "Poma_Fulla", pos(0.03, -0.02, 0.24), "arm_L", fulla, scale=(0.03 * k, 0.008 * k, 0.015 * k),
          rot=(0, -0.4, 0), segments=10, ring_count=5)


# --- n0_pocio (Merlí, el mag, per als xiquets): barret punxegut amb estrelles, barba blanca,
#     túnica amb estrelles i mànegues amples, cinturó amb una poció i vareta màgica ---------
def outfit_mag(b):
    from math import pi, sin, cos
    from mathutils import Vector
    tunica  = mat("Tunica_Mag",     (0.12, 0.05, 0.40), 0.6)
    or_     = mat("Or_Mag",         (0.95, 0.72, 0.15), 0.3, metal=0.8)
    barba   = mat("Barba_Blanca",   (0.95, 0.95, 0.95), 0.9)
    pocio   = mat("Pocio_Verda",    (0.20, 0.90, 0.30), 0.2, emit=1.2)
    vidre   = mat("Vidre_Pocio",    (0.85, 0.95, 1.00), 0.05)
    suro    = mat("Suro",           (0.55, 0.38, 0.20), 0.8)
    fusta   = mat("Vareta_Fusta",   (0.20, 0.10, 0.05), 0.5)
    gb = next(n for n in vidre.node_tree.nodes if n.type == 'BSDF_PRINCIPLED')
    gb.inputs["Alpha"].default_value = 0.3
    for attr, val in (("surface_render_method", 'BLENDED'), ("blend_method", 'BLEND')):
        try: setattr(vidre, attr, val)
        except (AttributeError, TypeError): pass

    # barret punxegut (os head), inclinat cap arrere perquè l'antena isca per davant
    tilt = -0.62
    eix = Vector((0, -sin(tilt), cos(tilt)))
    base = Vector((0, 0.16, 2.80))
    alt, radi = 1.3, 0.56
    b.add("cone", "Barret_Mag_Ala", (0, 0.05, 2.80), "head", tunica, radius1=1.0, radius2=0.6, depth=0.06, vertices=64)
    b.add("cone", "Barret_Mag", base + eix * (alt / 2), "head", tunica, rot=(tilt, 0, 0),
          radius1=radi, radius2=0.0, depth=alt, vertices=48)
    b.add("cylinder", "Barret_Mag_Cinta", base + eix * 0.05, "head", or_, rot=(tilt, 0, 0),
          radius=radi * 0.97, depth=0.06, vertices=48)
    for k, (h, ang, sz) in enumerate(((0.35, -100, 0.07), (0.62, -60, 0.05), (0.85, -120, 0.045), (0.30, -40, 0.05))):
        r = radi * (1 - h / alt) + 0.01
        a = ang * pi / 180
        local = Vector((r * cos(a), r * sin(a), h))
        rot_m = Vector((0, 0, 0))
        from mathutils import Matrix
        p = base + Matrix.Rotation(tilt, 3, 'X') @ local
        b.attach(b.star(f"Barret_Estrela.{k}", p, or_, size=sz, rot=(0, 0, a + pi / 2 + pi / 2)), "head")

    # barba blanca i espessa per davall de la pantalla (os head): no tapa el somriure ni la senyera
    for k, (x, y, z, sx, sy, sz) in enumerate(((0, -0.80, 1.40, 0.40, 0.12, 0.16), (-0.18, -0.78, 1.24, 0.17, 0.11, 0.15),
                                               (0.18, -0.78, 1.24, 0.17, 0.11, 0.15), (0, -0.80, 1.18, 0.2, 0.12, 0.17),
                                               (0, -0.77, 1.02, 0.11, 0.09, 0.1))):
        b.add("uv_sphere", f"Barba.{k}", (x, y, z), "head", barba, scale=(sx, sy, sz), segments=24, ring_count=12)

    # túnica llarga amb vol per baix (os body); la senyera queda com un pegat
    # part de dalt recta (la senyera queda per davant) i falda amb vol per davall de la insígnia
    # (la unió queda davall del cinturó)
    b.add("cube", "Tunica", (0, 0, 0.74), "body", tunica, scale=(0.70, 0.548, 0.44), bevel=0.24, segs=6, size=2)
    falda = b.mesh("cube", "Tunica_Falda", (0, 0, 0.17), tunica, scale=(0.70, 0.548, 0.19), bevel=0.17, segs=6, size=2)
    for v in falda.data.vertices:  # vol per baix
        if v.co.z < 0:
            v.co.x *= 1.14; v.co.y *= 1.14
    b.attach(falda, "body")
    b.add("torus", "Tunica_Coll", (0, 0, 1.2), "body", or_, scale=(1, 1, 0.6),
          major_radius=0.30, minor_radius=0.04, major_segments=48, minor_segments=8)
    for side in (-1, 1):  # mànegues amples acampanades
        s = 'E' if side < 0 else 'D'
        bone = "arm_L" if side < 0 else "arm_R"
        b.add("uv_sphere", f"Mànega_Mag.{s}", (side * 0.87, 0, 0.60), bone, tunica, scale=(0.18, 0.18, 0.36),
              rot=(0, -side * 0.385, 0), segments=32, ring_count=16)
        b.add("cone", f"Mànega_Mag_Campana.{s}", (side * 0.955, 0, 0.39), bone, tunica, rot=(0, -side * 0.385, 0),
              radius1=0.24, radius2=0.15, depth=0.2, vertices=32, end_fill_type='NOTHING')
        b.add("torus", f"Mànega_Mag_Vora.{s}", (side * 0.99, 0, 0.30), bone, or_, rot=(0, -side * 0.385, 0),
              major_radius=0.235, minor_radius=0.015, major_segments=40, minor_segments=6)
    for k, (x, z, sz) in enumerate(((-0.52, 0.85, 0.06), (0.50, 0.95, 0.05), (-0.45, 0.30, 0.05), (0.40, 0.18, 0.065),
                                    (0.0, 0.18, 0.045))):
        b.attach(b.star(f"Tunica_Estrela.{k}", (x, -0.57 - (0.04 if z < 0.4 else 0), z), or_, size=sz), "body")

    # cinturó de cordó daurat amb una poció verda al maluc dret
    b.add("cube", "Cinturo_Mag", (0, 0, 0.355), "body", or_, scale=(0.715, 0.565, 0.035), bevel=0.2, segs=6, size=2)
    b.add("uv_sphere", "Pocio_Flascó", (0.48, -0.66, 0.31), "body", vidre, radius=0.085, segments=24, ring_count=12)
    b.add("uv_sphere", "Pocio_Liquid", (0.48, -0.66, 0.30), "body", pocio, radius=0.07, segments=24, ring_count=12)
    b.add("cylinder", "Pocio_Coll", (0.48, -0.66, 0.41), "body", vidre, radius=0.03, depth=0.06, vertices=16)
    b.add("cylinder", "Pocio_Suro", (0.48, -0.66, 0.45), "body", suro, radius=0.032, depth=0.03, vertices=16)
    b.add("cylinder", "Pocio_Cordill", (0.48, -0.62, 0.47), "body", or_, rot=(0.4, 0, 0), radius=0.006, depth=0.08, vertices=6)

    # vareta màgica amb una estrella a la punta, a la mà esquerra (os arm_L)
    x, y = -1.03, -0.22
    b.add("cylinder", "Vareta", (x - 0.06, y, 0.52), "arm_L", fusta, rot=(0, -0.25, 0), radius=0.018, depth=0.6, vertices=10)
    b.attach(b.star("Vareta_Estrela", (x - 0.135, y, 0.83), or_, size=0.09, depth=0.025), "arm_L")


OUTFITS = {"mercat": outfit_mercat, "farmacia": outfit_farmacia, "forn": outfit_forn, "oficina": outfit_oficina,
           "a2_identificacio": outfit_festa, "a2_casa": outfit_casa,
           "a2_activitats": outfit_gimnas,
           "a2_menjar": outfit_restaurant,
           "a2_servicis": outfit_botiga,
           "a2_faena": outfit_carrer,
           "a2_clima": outfit_irlanda,
           "a2_viatges": outfit_hotel,
           "ajuntament": outfit_ajuntament, "bar": outfit_bar,
           "taller": outfit_taller, "turisme": outfit_turisme,
           "b1_persones": outfit_cuina, "b1_relacions": outfit_cosi,
           "b1_vida_quotidiana": outfit_atencio_client, "b1_llocs": outfit_immobiliaria,
           "b1_viatges": outfit_viatges, "b1_oci_esport": outfit_esport,
           "b1_territori": outfit_erasmus, "b1_cultura": outfit_radio,
           "b1_natura_clima": outfit_parc_natural, "colegi": outfit_mestra,
           "n0_pocio": outfit_mag}


def build(name):
    b = Builder(bpy.data.objects["Robot_Rig"])
    OUTFITS[name](b)
    b.done()


def export_glb(name):
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=SRC)
    for o in list(bpy.data.objects):
        if o.name.startswith("Icosphere"):  # ajudant de l'importador, no forma part del model
            bpy.data.objects.remove(o, do_unlink=True)
    build(name)
    dst = os.path.join(OUT_DIR, f"robot-{name}.glb")
    bpy.ops.export_scene.gltf(filepath=dst, export_format='GLB', export_animation_mode='ACTIONS',
                              export_apply=True, export_yup=True, **DRACO)
    print("[robot-avatar] GLB exportat a", dst)


def render_png(name):
    scene = bpy.context.scene
    build(name)
    scene.render.resolution_x = scene.render.resolution_y = 512
    scene.render.resolution_percentage = 100
    scene.render.image_settings.file_format = 'WEBP'
    scene.render.image_settings.color_mode = 'RGBA'
    scene.render.image_settings.quality = 88
    scene.render.filepath = os.path.join(OUT_DIR, f"robot-{name}.webp")
    bpy.ops.render.render(write_still=True)
    print("[robot-avatar] Imatge desada a", scene.render.filepath)


if __name__ == "__main__":
    args = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    names = [a for a in args if not a.startswith("--")] or list(OUTFITS)
    if "--png" in args:
        render_png(names[0])  # una per execució: el .blend ja queda modificat en memòria
    else:
        for n in names:
            export_glb(n)
