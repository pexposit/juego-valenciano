# ParlaVal

Aplicación para practicar valencià mediante conversaciones situadas. Incluye una web React/Vite y un agente Express propio; no depende de herramientas de automatización visual.

## Puesta en marcha

1. Copia `frontend/.env.example` y `backend/.env.example` a sus respectivos `.env` y completa las credenciales.
2. Ejecuta, en orden, las migraciones de `supabase/migrations/` en el SQL Editor de Supabase.
3. Instala y arranca: `npm install && npm run dev`.

El frontend queda en `http://localhost:5173` y la API en `http://localhost:3001`. Sin variables de Supabase, la interfaz permite recorrer el modo demostración; las conversaciones reales requieren configuración.

## Arquitectura

- `frontend/`: autenticación pública de Supabase, UI mobile-first, MediaRecorder y reproducción de voz.
- `backend/`: verifica el JWT con Supabase, obtiene contexto, llama a Mistral con salida JSON Schema, persiste progreso y aplica XP.
- `backend/src/services/voice.ts`: interfaces STT/TTS para conectar Whisper/Google y ElevenLabs/Google/Azure sin tocar la ruta.
- `supabase/migrations/`: tablas, RLS, trigger de perfil y función transaccional de XP/desbloqueos.

## Despliegue

Despliega `frontend` en Vercel con sus `VITE_*`. El backend incluye `Dockerfile` y puede desplegarse en Railway, Render o Fly.io; configura `FRONTEND_ORIGIN`, secretos de Supabase y Mistral. Nunca expongas `SUPABASE_SERVICE_ROLE_KEY` ni claves de proveedores en el frontend.
