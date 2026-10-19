-- Foto de fons (resources.metadata.background) de l'escenari C1 «Temps lliure i viatges»:
-- Jordi, de l'associació d'antics alumnes, organitza el viatge cultural (la imatge és a
-- frontend/public/images/). Tornar a aplicar el fitxer no canvia res (és un UPDATE idempotent).

UPDATE public.resources
SET metadata = jsonb_set(metadata, '{background}', to_jsonb('/images/asociacion_cultural.jpg'::text), true)
WHERE category = 'escenari' AND type = 'c1_temps_lliure';
