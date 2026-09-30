"""
[robot-avatar] Exporta el robot (malles + rig + clips) a frontend/public/avatar-robot/robot.glb.

    blender -b robot_avatar.blend --python export_glb.py

Nota: cada clip exportat inclou pistes de tots els ossos; el frontend filtra
les pistes per capa (LAYER_BONES en states.ts), per això es poden combinar.
"""
import os
import bpy

here = os.path.dirname(bpy.data.filepath)
out = os.path.normpath(os.path.join(here, "..", "..", "frontend", "public", "avatar-robot", "robot.glb"))

rig = bpy.data.objects["Robot_Rig"]
for tr in rig.animation_data.nla_tracks:
    tr.mute = True
rig.animation_data.action = None
bpy.ops.object.select_all(action='DESELECT')
for o in bpy.data.collections["Robot_Avatar"].objects:
    o.select_set(True)
bpy.context.view_layer.objects.active = rig
bpy.ops.export_scene.gltf(
    filepath=out, export_format='GLB', use_selection=True, export_apply=True,
    export_animations=True, export_animation_mode='ACTIONS', export_force_sampling=True,
    export_def_bones=False, export_yup=True, export_lights=False, export_cameras=False,
)
print("[robot-avatar] GLB exportat a", out)
