# Avatar robot 3D: registro de cambios

Fecha: 30/09/2026. Todo lo añadido lleva la marca `[robot-avatar]` en comentarios, para poder buscarlo con `grep -rn "robot-avatar"`.

## 1. Archivos NUEVOS (se pueden borrar sin afectar al resto)

| Ruta | Qué es |
|---|---|
| `frontend/src/features/robot-avatar/` | Módulo completo: `config.ts`, `states.ts`, `robotEngine.ts`, `RobotAvatar.tsx`, `RobotSceneArt.tsx`, `DashboardRobot.tsx`, `index.ts`, `README.md` |
| `frontend/public/avatar-robot/robot.glb` | Modelo 3D con rig y 14 animaciones (~1 MB) |
| `frontend/public/avatar-robot/robot.png` | Imagen estática de respaldo (mientras carga / sin WebGL) |
| `assets-src/robot-avatar/` | Fuente de Blender (`robot_avatar.blend`), scripts `animations.py` y `export_glb.py`, `README.md` y `cambios-proyecto.patch` |
| `ROBOT_AVATAR_CAMBIOS.md` | Este documento |

## 2. Archivos EXISTENTES modificados (cambios mínimos)

El diff completo está en `assets-src/robot-avatar/cambios-proyecto.patch`.

### `frontend/package.json`
- `dependencies`: `"three": "^0.186.1"`
- `devDependencies`: `"@types/three": "^0.186.0"`
- ⚠️ Hay que ejecutar `npm install` en la raíz del proyecto. Esto actualiza también `package-lock.json`, que yo no he tocado porque ya tenía cambios tuyos sin confirmar.

### `frontend/src/components/SceneArt.tsx` (+3 líneas, 1 cambiada)
- Import de `isRobotAvatarEnabled` y `RobotSceneArt`.
- Dos props opcionales nuevas: `thinking?` y `talking?`.
- Al principio de la función: si el módulo está activo para el chat, devuelve `<RobotSceneArt …/>`. Si no, se ejecuta el código original, que sigue intacto.

### `frontend/src/pages/Chat.tsx` (+4 líneas, 1 cambiada)
- Estado nuevo `talking` (vale `true` mientras suena el audio del personaje).
- En `setReplyAudio`: `setTalking(false)` y los listeners `onplay`, `onpause` y `onended` del `Audio`.
- `<SceneArt … thinking={loading} talking={talking} />`
- En el `<audio controls>`: `onPlay`, `onPause` y `onEnded` actualizan `talking`.

### `frontend/src/pages/Dashboard.tsx` (+5 líneas, 1 cambiada)
- Import de `DashboardRobot` e `isRobotAvatarEnabled`.
- El `<img src="/images/avatar_professor.svg">` pasa a ser condicional: se muestra el robot si el módulo está activo y, si no, la imagen original, que se conserva sin cambios.

## 3. Cómo desactivarlo o revertirlo

1. **Temporal, sin tocar código:** añade `VITE_ROBOT_AVATAR=off` en `frontend/.env` y reinicia `npm run dev`.
2. **Solo en un sitio:** en `frontend/src/features/robot-avatar/config.ts`, pon `places.dashboard` o `places.chat` a `false`.
3. **Eliminarlo por completo:**
   ```bash
   git restore frontend/package.json frontend/src/components/SceneArt.tsx frontend/src/pages/Chat.tsx frontend/src/pages/Dashboard.tsx
   rm -r frontend/src/features/robot-avatar frontend/public/avatar-robot assets-src/robot-avatar ROBOT_AVATAR_CAMBIOS.md
   npm install
   ```
   Otra opción, desde la raíz: `git apply -R assets-src/robot-avatar/cambios-proyecto.patch` (antes de borrar la carpeta).

## 4. Estados y animaciones

| App | Robot | Animación |
|---|---|---|
| Entrar en un escenario (2,6 s) | `wave` | Saluda |
| `mood = neutral` | `idle` | Respira, mira a los lados, parpadea |
| `mood = content` | `happy` | Salta de alegría (una vez); ojos verdes y sonrisa grande |
| `mood = confus` | `confused` | Inclina la cabeza, se rasca; ojos ámbar y boca triste |
| `loading` (esperando respuesta) | `thinking` | Mira arriba, la antena gira y parpadea; ojos lilas |
| Audio del personaje sonando | capa `talking` | Mueve la boca |
| Dashboard | `wave` → `idle` | Saluda al aparecer y al pasar el ratón; salta si le haces clic |

## 5. Notas técnicas
- three.js se carga con `import()` dinámico: el bundle principal no crece (el chunk `robotEngine` pesa ~164 KB gzip y solo se descarga donde aparece el robot).
- Las animaciones se mezclan en 3 capas independientes (cuerpo, ojos y boca), con fundidos de 0,35 s.
- La animación se pausa cuando el robot no está visible o la pestaña está oculta. Con `prefers-reduced-motion` va más lenta y sin saltos.
- Verificado: `tsc -b` y `vite build` sin errores. También se ha comprobado el render en Chromium (Dashboard, Chat en escritorio y en móvil, y los 6 estados).
