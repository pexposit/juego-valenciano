# Font de l'avatar robot (Blender)

- `robot_avatar.blend`: model, materials, rig (`Robot_Rig`, 9 ossos) i les 14 accions.
- `animations.py`: genera les animacions a partir de funcions (fàcil d'ajustar angles i temps).
- `export_glb.py`: exporta a `frontend/public/avatar-robot/robot.glb`.

```bash
blender -b robot_avatar.blend --python animations.py   # regenera i desa les animacions
blender -b robot_avatar.blend --python export_glb.py   # exporta el GLB
```

> En aquest ordinador l'exportador glTF de Blender falla perquè el Control d'aplicacions
> de Windows bloqueja una DLL de numpy. El GLB actual es va exportar amb el mòdul `bpy`
> de Python (Blender 5.0) en Linux. Si et passa, pots fer l'export en un altre equip o amb
> `pip install bpy` i: `python -c "import bpy; bpy.ops.wm.open_mainfile(filepath='robot_avatar.blend'); exec(open('export_glb.py').read())"`.

Ossos: `root` (tot, inclosa la base), `body`, `head`, `antenna`, `eye_L`, `eye_R`, `mouth`, `arm_L`, `arm_R`.
Clips (30 fps): `body_idle`, `body_wave`, `body_happy` (una vegada), `body_confused`, `body_thinking`,
`eyes_neutral|happy|confused|thinking`, `mouth_neutral|happy|confused|thinking|talk`.
