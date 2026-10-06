-- Foto de fons (resources.metadata.background) de l'escenari infantil del mag i la poció
-- (la imatge és a frontend/public/images/). Tornar a aplicar el fitxer no canvia res
-- (és un UPDATE idempotent).

UPDATE public.resources
SET metadata = jsonb_set(metadata, '{background}', to_jsonb('/images/mago.jpg'::text), true)
WHERE category = 'escenari' AND type = 'n0_pocio';
