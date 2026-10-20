-- Foto de fons (resources.metadata.background) de l'escenari B2 «Conéixer la gent»: Carme,
-- la presidenta de l'associació cultural del barri (la imatge és a frontend/public/images/).
-- Tornar a aplicar el fitxer no canvia res (és un UPDATE idempotent).

UPDATE public.resources
SET metadata = jsonb_set(metadata, '{background}', to_jsonb('/images/asociacion_cultural.jpg'::text), true)
WHERE category = 'escenari' AND type = 'b2_gent';
