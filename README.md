# ParlaVal

Aplicación para practicar valencià mediante conversaciones situadas. Incluye una web React/Vite y un agente Express propio; no depende de herramientas de automatización visual.

## Puesta en marcha

### Base de datos local (Docker)

1. Instala la CLI de Supabase (`npm install -g supabase`) y arranca el stack: `supabase start` (primera vez descarga las imágenes; luego basta `docker start` para encender los contenedores).
2. El stack local expone:
   - API + REST: `http://127.0.0.1:54321`
   - Postgres directo: `postgresql://postgres:postgres@127.0.0.1:54322/postgres`
   - Studio (panel web): `http://127.0.0.1:54323`
   - Mailpit (correos de verificación): `http://127.0.0.1:54324`
3. Las migraciones de `supabase/migrations/` **se aplican automáticamente** al arrancar; no hace falta el SQL Editor.
4. Completa los `.env` con los valores que muestra `supabase status`:
   - `backend/.env`: `SUPABASE_URL` (Project URL) y `SUPABASE_SERVICE_ROLE_KEY` (Secret).
   - `frontend/.env`: `VITE_SUPABASE_URL` (Project URL) y `VITE_SUPABASE_ANON_KEY` (Publishable).
   Las claves locales son de desarrollo; nunca uses la "Secret" en el frontend.

### Aplicación

1. Copia `frontend/.env.example` y `backend/.env.example` a sus respectivos `.env` y completa las credenciales (para desarrollo local, consulta la sección anterior).
2. Instala y arranca: `npm install && npm run dev`.

El frontend queda en `http://localhost:5173` y la API en `http://localhost:3001`. Sin variables de Supabase, la interfaz permite recorrer el modo demostración; las conversaciones reales requieren configuración.

## Arquitectura

- `frontend/`: autenticación pública de Supabase, UI mobile-first, MediaRecorder y reproducción de voz.
- `backend/`: verifica el JWT con Supabase, obtiene contexto, llama a OpenAI con salida JSON, persiste progreso y aplica XP.
- `backend/src/services/voice.ts`: interfaces STT/TTS para conectar Whisper/Google y ElevenLabs/Google/Azure sin tocar la ruta.
- `supabase/migrations/`: tablas, RLS, trigger de perfil y función transaccional de XP/desbloqueos.

## Despliegue

Despliega `frontend` en Vercel con sus `VITE_*`. El backend incluye `Dockerfile` y puede desplegarse en Railway, Render o Fly.io; configura `FRONTEND_ORIGIN`, secretos de Supabase y `OPENAI_API_KEY`. Por defecto usa `gpt-5.6-luna` y dispone de `gpt-4o-mini`/`gpt-4o` como respaldo; puedes cambiarlo con `OPENAI_MODEL`. Nunca expongas `SUPABASE_SERVICE_ROLE_KEY` ni claves de proveedores en el frontend.
