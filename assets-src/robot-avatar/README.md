# Font de l'avatar robot (Blender)

- `robot_avatar.blend`: model, materials, rig (`Robot_Rig`, 9 ossos) i les 14 accions.
- `animations.py`: genera les animacions a partir de funcions (fàcil d'ajustar angles i temps).
- `export_glb.py`: exporta a `frontend/public/avatar-robot/robot.glb`.
- `robot_outfits.py`: versions amb roba d'escenari → `robot-<escenari>.glb` i `robot-<escenari>.webp`:
  `mercat` (barret de palla, mocador, davantal, taronja), `farmacia` (bata, creu verda, ulleres, caixa de medicaments), `forn` (gorro de forner, davantal de pitet, barra de pa), `oficina` (americana, camisa, mocador de butxaca, targeta, tassa de café), `a2_identificacio`, la festa d'aniversari de Núria (americana granat, pestanyes, arracades i collar de perles, copa de cava), `a2_casa`, Xavi, el nou company de pis (dessuadora oberta, gorra, claus), `a2_activitats`, Toni, l'amic del gimnàs (samarreta de tirants, pantaló curt, cinta al cap, tovallola, canellera, pesa), `a2_menjar`, Empar, la propietària del restaurant (armilla, brusa, fular, pestanyes, arracades, la carta), `a2_servicis`, Lídia, la dependenta dels grans magatzems (rebeca, cinta mètrica, placa amb el nom, pestanyes), `a2_faena`, Sílvia, l'antiga companya de l'institut (jaqueta texana, top de ratlles, ulleres de sol al cap, pestanyes, bossa, mòbil), `a2_clima`, Liam, l'amic irlandés (impermeable verd, jersei de punt, gorra plana de tweed, paraigua) i `a2_viatges`, Jordi, el recepcionista de l'hotel (uniforme amb ribets daurats, corbata de llacet, placa, agulla de clau, clau de l'habitació).

```bash
blender -b robot_avatar.blend --python animations.py   # regenera i desa les animacions
blender -b robot_avatar.blend --python export_glb.py   # exporta el GLB
blender -b --factory-startup --python robot_outfits.py                      # GLB de totes les robes (a partir de robot.glb)
blender -b robot_avatar.blend --python robot_outfits.py -- farmacia --png  # imatge de càrrega d'una roba
```

> En aquest ordinador l'exportador glTF de Blender falla perquè el Control d'aplicacions
> de Windows bloqueja una DLL de numpy. El GLB actual es va exportar amb el mòdul `bpy`
> de Python (Blender 5.0) en Linux. Si et passa, pots fer l'export en un altre equip o amb
> `pip install bpy` i: `python -c "import bpy; bpy.ops.wm.open_mainfile(filepath='robot_avatar.blend'); exec(open('export_glb.py').read())"`.

Ossos: `root` (tot, inclosa la base), `body`, `head`, `antenna`, `eye_L`, `eye_R`, `mouth`, `arm_L`, `arm_R`.
Clips (30 fps): `body_idle`, `body_wave`, `body_happy` (una vegada), `body_confused`, `body_thinking`,
`eyes_neutral|happy|confused|thinking`, `mouth_neutral|happy|confused|thinking|talk`.
