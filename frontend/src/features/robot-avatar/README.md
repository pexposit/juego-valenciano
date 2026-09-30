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
