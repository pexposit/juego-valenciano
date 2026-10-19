-- Foto de fons (resources.metadata.background) de l'escenari B2 «Cultura i llengua»: la
-- tia Pepeta conta rondalles a la fresca en una nit de festes al poble (la imatge és a
-- frontend/public/images/). Tornar a aplicar el fitxer no canvia res (és un UPDATE idempotent).

UPDATE public.resources
SET metadata = jsonb_set(metadata, '{background}', to_jsonb('/images/pueblo_noche.jpg'::text), true)
WHERE category = 'escenari' AND type = 'b2_cultura_llengua';
