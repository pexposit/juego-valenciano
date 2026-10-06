-- Salutació en àudio de l'escenari infantil del mag i la poció (resources.metadata.greeting_audio,
-- ruta dins de frontend/public). El fitxer es genera amb el TTS matxa:
-- `npx tsx scripts/generate-scenario-audio.ts` (a backend/). Si no existix, el xat demana l'àudio
-- al TTS com abans. Tornar a aplicar el fitxer no canvia res (és un UPDATE idempotent).

UPDATE public.resources
SET metadata = jsonb_set(metadata, '{greeting_audio}', to_jsonb('/audio/scenarios/n0_pocio-salutacio.wav'::text), true)
WHERE category = 'escenari' AND type = 'n0_pocio';
