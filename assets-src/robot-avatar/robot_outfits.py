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
        tgt = bpy.data.objects[target]
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
        rings = [ring(z - height / 2, thick), ring(z + height / 2, thick),
                 ring(z + height / 2, -0.01), ring(z - height / 2, -0.01)]
        verts = [v for r in rings for v in r]
        faces = []
        for k in range(4):
            a0, a1 = k * n, ((k + 1) % 4) * n
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


OUTFITS = {"mercat": outfit_mercat, "farmacia": outfit_farmacia, "forn": outfit_forn, "oficina": outfit_oficina,
           "a2_identificacio": outfit_festa, "a2_casa": outfit_casa,
           "a2_activitats": outfit_gimnas,
           "a2_menjar": outfit_restaurant,
           "a2_servicis": outfit_botiga,
           "a2_faena": outfit_carrer,
           "a2_clima": outfit_irlanda,
           "a2_viatges": outfit_hotel}


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
