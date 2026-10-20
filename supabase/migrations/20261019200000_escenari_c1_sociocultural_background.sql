-- Foto de fons (resources.metadata.background) de l'escenari C1 «Entorn sociocultural i
-- polític»: Marina, la presidenta d'una associació intercultural, prepara unes jornades (la
-- imatge és a frontend/public/images/). Tornar a aplicar el fitxer no canvia res (és un
-- UPDATE idempotent).

UPDATE public.resources
SET metadata = jsonb_set(metadata, '{background}', to_jsonb('/images/asociacion_cultural.jpg'::text), true)
WHERE category = 'escenari' AND type = 'c1_sociocultural';
