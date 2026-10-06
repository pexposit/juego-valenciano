# robot-avatar

Avatar robot 3D animat (modelat i animat en Blender, renderitzat amb three.js).

## Què fa

| On | Substituïx | Comportament |
|---|---|---|
| `Dashboard` | `/images/avatar_professor.svg` | Saluda en aparéixer i quan passes el ratolí per damunt; fa un bot si el cliques. |
| `Chat` (via `SceneArt`) | Els personatges il·lustrats de cada escenari | Saluda en entrar i després segueix l'estat de la conversa. |

Estats del xat → animació del robot:

| Estat de l'app | Estat del robot | Animació |
|---|---|---|
| inici de l'escenari (2,6 s) | `wave` | saluda amb la mà |
| `mood: 'neutral'` | `idle` | respira, mira al voltant, parpelleja |
| `mood: 'content'` | `happy` | bot d'alegria, ulls verds i somriure gran |
| `mood: 'confus'` | `confused` | inclina el cap, es rasca, ulls ambre i boca trista |
| esperant la resposta (`loading`) | `thinking` | mira amunt, antena que gira i parpelleja, ulls liles |
| sona l'àudio del personatge | `talking` (capa extra) | mou la boca mentre parla |

## Fitxers

- `config.ts`: interruptors del mòdul (global i per lloc).
- `states.ts`: estats, clips de cada estat i colors; `robotStateFromMood()`.
- `robotEngine.ts`: escena three.js, càrrega del GLB i mescla d'animacions en 3 capes (cos / ulls / boca). Es carrega amb `import()` dinàmic.
- `RobotAvatar.tsx`: component React genèric (`state`, `talking`). Mostra `robot.png` mentre carrega o si WebGL falla.
- `RobotSceneArt.tsx`, `DashboardRobot.tsx`: integracions concretes.
- Recursos: `frontend/public/avatar-robot/robot.glb` i `robot.png`.
- Roba per escenari: `config.ts` → `scenarioOutfits` (ara `mercat`, `farmacia`, `forn`, `oficina`, `a2_identificacio`, `a2_casa`, `a2_activitats`, `a2_menjar`, `a2_servicis`, `a2_faena`, `a2_clima`, `a2_viatges`, `ajuntament`, `bar`, `taller`, `turisme`, `b1_persones`, `b1_relacions`, `b1_vida_quotidiana`, `b1_llocs`, `b1_viatges`, `b1_oci_esport`, `b1_territori`, `b1_cultura`, `b1_natura_clima`, `colegi`, `n0_pocio`, `n0_zoo` i `n0_pati` → `robot-<escenari>.glb` + `.webp`, generats amb `assets-src/robot-avatar/robot_outfits.py`).
- Càrrega ràpida: en obrir `ScenarioSelect` es crida `preloadRobotAvatar()` (three.js + robot normal) i, en passar el ratolí, tocar o enfocar un escenari, `preloadRobotAvatar(escenari)` (només la roba d'eixe escenari). Cada GLB es baixa una sola vegada per sessió (`fetchRobotModel` en `robotEngine.ts`). En entrar en una escena, `components/SceneLoading.tsx` mostra una pantalla de càrrega fins que hi ha el fons i el GLB (`loadRobotAvatar`, que es comença a baixar alhora que el catàleg), i només llavors munta el xat. Els GLB porten les malles comprimides amb Draco; el descodificador (de three.js) és a `frontend/public/draco/`.
- Font de Blender i scripts: `assets-src/robot-avatar/`.

## Desactivar / revertir

- Sense tocar codi: `VITE_ROBOT_AVATAR=off` en `frontend/.env` → torna l'avatar original.
- Només en un lloc: `places.dashboard` o `places.chat` a `false` en `config.ts`.
- Eliminar-lo del tot: veure `ROBOT_AVATAR_CAMBIOS.md` en l'arrel del projecte.

## Ús en altres pantalles

```tsx
import { RobotAvatar } from '../features/robot-avatar';
<RobotAvatar state="happy" talking={false} className="h-64 w-64" />
```
