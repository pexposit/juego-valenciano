-- Foto de fons (resources.metadata.background) de l'escenari C1 «Economia, indústria,
-- ciència i tecnologia»: Sergi assessora a l'oficina de l'agència de desenvolupament local
-- (la imatge és a frontend/public/images/). Tornar a aplicar el fitxer no canvia res
-- (és un UPDATE idempotent).

UPDATE public.resources
SET metadata = jsonb_set(metadata, '{background}', to_jsonb('/images/office.jpg'::text), true)
WHERE category = 'escenari' AND type = 'c1_economia';
