# Despliegue de ParlaVal

Guía para publicar el juego en producción: base de datos en **Supabase Cloud**, API en **Render / Railway / Fly.io** y web en **Vercel**.

```
   NAVEGADOR
       │
       ├──► Vercel (web estática React/Vite, HTTPS)
       │         │  fetch VITE_API_BASE_URL/api/turn
       │         ▼
       └──► Render / Railway / Fly  (API Express en Docker)
                    │                    │
                    ▼                    ▼
          Supabase Cloud          matxa (DeepLab, UJI)
          Postgres + Auth         STT + TTS en catalán
                    ▲
                    └── OpenAI (gpt-4o-mini)
```

**Qué NO se despliega:** `speech-lab/` (laboratorio de voz local: 91 MB de modelos Vosk + sidecar Python) y el stack de Supabase en Docker que usas en desarrollo.

## 0. Antes de empezar

- Cuenta en Supabase, en un host de contenedores y en Vercel.
- CLI de Supabase instalada (`npm install -g supabase`).
- Clave de OpenAI.
- **La web y la API tienen que ir por HTTPS.** El navegador solo concede el micrófono (`getUserMedia`) en contexto seguro: servido por HTTP, el juego se queda sin voz y sin ningún error visible.
- La API se publica como contenedor. El `backend/Dockerfile` ya construye correctamente (verificado con `docker build`, arranque real y `GET /health`).

## 1. Base de datos: Supabase Cloud

```bash
# 1.1 Crea el proyecto en supabase.com (región EU, p. ej. Frankfurt).
#     Guarda Project URL, anon key (Publishable) y service_role key (Secret).

# 1.2 Vincula este repositorio al proyecto remoto (una sola vez).
supabase link --project-ref <project-ref>

# 1.3 Aplica las migraciones de supabase/migrations/ (001 → 004).
supabase db push

# 1.4 Comprueba que no queda nada pendiente.
supabase db diff --linked      # debe salir vacío
```

Después, en el panel de Supabase → **Authentication → URL Configuration**:

- **Site URL**: `https://<tu-app>.vercel.app`
- **Redirect URLs**: `https://<tu-app>.vercel.app/**`

Sin esto, los correos de confirmación apuntan a `localhost` y el alta de usuario falla en silencio. En el plan gratuito Supabase solo envía 3-4 correos/hora con su SMTP propio; para uso real configura un SMTP externo (Resend, Brevo…) o desactiva las confirmaciones igual que en local.

La migración `002_fix_new_user_trigger.sql` es la que crea el perfil y desbloquea `mercat` al registrarse. Si ese trigger no existe, los usuarios nuevos se quedan sin perfil ni progreso.

## 2. API: host de contenedores

En Render / Railway / Fly.io: servicio nuevo desde el repositorio de GitHub, con **Dockerfile** en `backend/Dockerfile` y **contexto = raíz del repositorio**.

- El host inyecta `PORT`; el código lo respeta (`Number(process.env.PORT) || 3001`).
- Health check: `GET /health` → `{"ok":true}`. El `Dockerfile` ya incluye `HEALTHCHECK`.
- Prueba la imagen en local antes de publicar:

```bash
docker build -t parlaval-api -f backend/Dockerfile .
docker run --rm -p 3001:3001 --env-file backend/.env parlaval-api
curl -s localhost:3001/health
```

⚠️ `--env-file` solo para probar en tu máquina. En producción las variables van en el panel del host: el `.dockerignore` impide que `backend/.env` entre en la imagen.

### Variables del backend

| Variable | Ejemplo / por defecto | ¿Obligatoria? |
|---|---|---|
| `FRONTEND_ORIGIN` | `https://tu-app.vercel.app` (varios, separados por comas) | ✅ |
| `SUPABASE_URL` | `https://xxxx.supabase.co` | ✅ |
| `SUPABASE_SERVICE_ROLE_KEY` | `eyJ...` (Secret) | ✅ |
| `OPENAI_API_KEY` | `sk-...` | ✅ |
| `OPENAI_MODEL` | `gpt-4o-mini` | 🔶 recomendada |
| `ALLOW_DEMO` | `false` en producción | 🔶 recomendada |
| `RATE_LIMIT_AUTHED_PER_MIN` | `30` | ❌ |
| `RATE_LIMIT_ANON_PER_MIN` | `6` | ❌ |
| `OPENAI_TIMEOUT_MS` | `30000` | ❌ |
| `MATXA_*` (`TTS_URL`, `STT_URL`, `TTS_VOICE`, `STT_LANGUAGE`…) | servidor DeepLab de la UJI | ❌ (ya tienen por defecto) |

Nunca pongas `SUPABASE_SERVICE_ROLE_KEY` en el frontend: da acceso total a la base de datos saltándose las políticas RLS.

### Cómo funciona `ALLOW_DEMO`

- `ALLOW_DEMO=true` (por defecto): se puede jugar sin cuenta. Las peticiones anónimas se cobran contra `RATE_LIMIT_ANON_PER_MIN` y no se guarda nada en la base de datos.
- `ALLOW_DEMO=false`: `/api/turn` y `/api/tts` exigen token de Supabase (401 sin él). Si lo desactivas, hay que pedir sesión en la interfaz antes de entrar a un escenario: hoy el frontend permite jugar como invitado.
- Recomendación: déjalo en `true` con un límite anónimo bajo, así cualquiera prueba el juego pero nadie puede fundir tu cuenta de OpenAI.

## 3. Web: Vercel (es un monorepo)

Configuración del proyecto en Vercel:

| Ajuste | Valor | Por qué |
|---|---|---|
| Root Directory | `.` (raíz del repositorio) | El frontend importa `@parlaval/shared`, que es un workspace |
| Framework Preset | Vite | — |
| Install Command | `npm ci` | Instala todos los workspaces |
| Build Command | `npm run build -w shared && npm run build -w frontend` | **`shared` primero**: el frontend consume sus tipos |
| Output Directory | `frontend/dist` | Salida de Vite |

### Variables del frontend

```
VITE_SUPABASE_URL      = https://xxxx.supabase.co
VITE_SUPABASE_ANON_KEY = eyJ...        (Publishable: esta sí va al navegador)
VITE_API_BASE_URL      = https://api.tu-dominio.com
```

⚠️ Las variables `VITE_*` **se incrustan en el bundle durante el build**: si cambias `VITE_API_BASE_URL`, no basta con guardarla, hay que **redesplegar**. Por eso conviene poner la API detrás de un subdominio propio (`api.tu-dominio.com`): así puedes mover el backend de Render a Railway sin tocar el frontend.

## 4. Comprobaciones tras el despliegue

| # | Prueba | Resultado esperado |
|---|---|---|
| 1 | `curl https://api.tu-dominio.com/health` | `{"ok":true}` |
| 2 | Abrir la web y hacer un turno | Sin errores de CORS en la consola del navegador |
| 3 | Registrarse con un correo nuevo | Fila en `profiles` **y** en `scenario_progress` con `mercat` = `unlocked` (visible en Studio) |
| 4 | Jugar un turno con sesión iniciada | `conversation_messages` sube en 2 filas y `profiles.xp` sube 10 |
| 5 | Pulsar el micrófono y hablar | Pide permiso y transcribe (esto prueba el HTTPS) |
| 6 | Escuchar la respuesta del personaje | Suena la voz de Lluc/Gina (llega del DeepLab por HTTPS) |
| 7 | Pedir 7 turnos seguidos sin sesión | A partir del 7.º, `429` con `Retry-After` (prueba el límite anónimo) |

## 5. Detalles que suelen morder

- **HTTPS y micrófono.** Sin contexto seguro, `getUserMedia` no funciona y el juego pierde la voz sin mensaje de error. Vercel lo da gratis; un servidor propio con IP o HTTP, no.
- **matxa es HTTP, pero no pasa nada.** `http://deeplab.lsi.uji.es:11000` lo llama el **backend** (servidor a servidor), así que el navegador no bloquea nada por contenido mixto. Si algún día lo llamara el frontend, sí lo bloquearía.
- **El límite de peticiones vive en memoria del proceso.** Con una instancia (lo normal en Render/Railway/Fly) es suficiente. Si escalas a varias réplicas, cada una llevaría su propia cuenta: entonces necesitarás Redis o contadores en la base de datos.
- **`req.ip` detrás de un proxy.** Ya está resuelto con `app.set('trust proxy', 1)`; sin esa línea, todas las peticiones llegarían con la IP del proxy y el límite afectaría a todos los usuarios a la vez.
- **El laboratorio de voz no se despliega.** `speech-lab/` necesita los modelos Vosk y Python; es herramienta de desarrollo. Ojo: su README documenta que llama a `/api/tts` sin token, así que con `ALLOW_DEMO=false` el laboratorio dejará de poder pedir audio.
- **Los audios de salutación no gastan TTS.** `frontend/public/audio/*.wav` son ficheros estáticos.
- **El XP es fijo.** Cada turno da 10 XP (`xpDelta` en `backend/src/routes/turn.ts`) y en modo demostración no se guarda nada.
- **El DeepLab es un servidor académico.** Si el juego va a tener uso real, avisa en la UJI antes de que el tráfico crezca.

## 6. Problemas típicos

| Síntoma | Causa probable |
|---|---|
| El build de Docker falla con `TS2307: Cannot find module '@parlaval/shared'` | No se ha copiado `shared/` o no se ha construido antes que `backend` (el Dockerfile actual ya lo hace) |
| `Not allowed by CORS` | `FRONTEND_ORIGIN` no incluye el dominio exacto: sin barra final y con `https://` |
| `401` en todas las peticiones | `ALLOW_DEMO=false` y el usuario no ha iniciado sesión |
| `429 Massa peticions seguides` | Límite por minuto alcanzado; se ajusta con `RATE_LIMIT_*` |
| Todo el mundo recibe 429 a la vez | Falta `trust proxy` o el host encadena varios proxies |
| No suena la voz / no pide micrófono | La web no se sirve por HTTPS |
| La respuesta de texto tarda mucho | Mira los tiempos por etapa en los logs del host: `[turn] stt=… agente=… tts=… db=… total=…` |
| `403 Sessió no vàlida` | La sesión es de otro usuario/escenario, o falló la consulta: busca `[turn] error consultant la sessió` |
| El XP sube en pantalla pero al recargar baja | Fallo de persistencia: busca `[turn] no hem pogut guardar els missatges` o `no hem pogut aplicar els XP` en los logs |
| Al registrarse no aparece el perfil | Falta el trigger de la migración 002 o las Redirect URLs de Auth |

## 7. Costes orientativos

| Servicio | Coste |
|---|---|
| Vercel Hobby | 0 € (uso no comercial; para producto, plan Pro) |
| Supabase Free | 0 € (500 MB de base de datos; cada mensaje ocupa ~100 bytes) |
| Render Free | 0 €, pero el servicio se duerme a los 15 min sin tráfico (arranque en frío de 30-60 s) |
| Railway | ~5 €/mes, siempre despierto |
| Fly.io | Franja gratuita con máquinas pequeñas siempre encendidas |
| OpenAI `gpt-4o-mini` | ≈ 0,0006 $ por turno → 1.000 turnos ≈ 0,6 $ |
| matxa (DeepLab, UJI) | 0 € |

## 8. Pendientes conocidos

Mejoras ya identificadas y todavía no implementadas:

1. **Streaming del turno** (SSE): hoy el turno espera a que OpenAI termine y luego pide el TTS, así que el texto tarda ~3-4 s. Enviando la respuesta por frases se bajaría a ~1 s.
2. **Caché de TTS** por `hash(texto, voz)`: ahorra coste y latencia en frases repetidas.
3. **XP real**: usar `error_flags` y `detected_level_signal` en lugar del `+10` fijo.
4. **Gamificación de verdad**: `streak_days`, `last_active_on` y `badges` nunca se actualizan, y `required: 0` en los escenarios hace que ninguno se bloquee.
5. **Tests del frontend** y de `backend/src/routes/turn.ts`.
6. **CI en GitHub Actions**: ejecutar `npm test`, `test:speech` y los builds en cada push.
7. **Limpiar artefactos versionados**: `frontend/vite.config.js` (¡Vite le da prioridad sobre `vite.config.ts`!), `vite.config.d.ts` y los `*.tsbuildinfo`.
8. **Renombrar imágenes duplicadas**: `images/` y `frontend/public/images/` son 1,2 MB repetidos, con nombres que contienen `:`, espacios y acentos.
9. **CORS**: en producción se puede quitar la excepción que acepta cualquier `localhost`.
10. **Borrado de datos**: no hay endpoint para que un usuario elimine su historial o su cuenta.




## 9. Alternativa: todo en un servidor propio (Docker Compose)

En lugar de Supabase Cloud + Render + Vercel, todo puede ir en un único servidor. `docker-compose.yml` levanta:

| Servicio | Qué es |
|---|---|
| `web` | Caddy: sirve el build de Vite, hace de proxy de `/api`, `/auth/v1` y `/rest/v1` y **obtiene el certificado HTTPS de Let's Encrypt** |
| `api` | El backend (`backend/Dockerfile`) |
| `db` | Postgres con las extensiones y roles de Supabase (`supabase/postgres`) |
| `auth` | GoTrue, el servicio de Auth de Supabase (altas e inicios de sesión) |
| `rest` | PostgREST, lo que responde a `supabase.from(...)` |
| `migrate` | Aplica `supabase/migrations/*.sql` que falten y termina |

Es un **Supabase mínimo**: solo lo que usa el juego. No incluye Studio (el panel web), Storage, Realtime ni Edge Functions; si algún día hacen falta, parte del [docker-compose oficial](https://github.com/supabase/supabase/tree/master/docker). Así cabe en un VPS de **2 GB de RAM** (el oficial completo pide unos 4 GB).

Web, API y Supabase comparten dominio: `VITE_SUPABASE_URL` es `https://$DOMAIN`, `VITE_API_BASE_URL` queda vacía y el compose fija `FRONTEND_ORIGIN` y `SUPABASE_URL` solo.

### Primer despliegue

```bash
# En el servidor, con Docker instalado y los puertos 80 y 443 abiertos:
git clone <repo> && cd juego-valenciano
cp .env.deploy.example .env                  # pon DOMAIN
docker run --rm -v "$PWD/deploy:/d" node:22-alpine node /d/generate-secrets.mjs >> .env
cp backend/.env.example backend/.env         # OpenAI, matxa, ALLOW_DEMO... (SUPABASE_* no hace falta)
docker compose up -d --build
docker compose logs migrate                  # "Base de dades al dia"
curl https://$DOMAIN/health                  # {"ok":true}
```

- El registro DNS debe apuntar a la IP del servidor **antes** del primer arranque, o Caddy no podrá emitir el certificado.
- Para probarlo en tu máquina: `DOMAIN=localhost` (certificado local, el navegador avisa una vez).
- **Guarda una copia del `.env`.** Si pierdes `JWT_SECRET`, todas las sesiones dejan de valer; si pierdes `POSTGRES_PASSWORD`, los servicios no conectan a la base de datos.
- Las altas no piden confirmación por correo (`ENABLE_EMAIL_AUTOCONFIRM=true`). Para activarla, rellena las `SMTP_*` del `.env`.

### Mantenimiento

- **Actualizar:** `git pull && docker compose up -d --build`. Las migraciones nuevas de `supabase/migrations/` se aplican solas, cada una una sola vez (registro en `deploy.applied_migrations`).
- **Copia de seguridad** (hazla con cron; ahora los datos solo existen en tu servidor):
  ```bash
  docker compose exec -T db pg_dump -U supabase_admin -d postgres -n public -n auth -Fc > parlaval-$(date +%F).dump
  ```
- **Consultar la base de datos:** `docker compose exec db psql -U supabase_admin -d postgres`.
- **No borres los volúmenes** (`docker compose down -v`): `db_data` son los datos y `caddy_data` los certificados.
- Postgres no se publica a Internet: solo se accede desde la red interna del compose.
