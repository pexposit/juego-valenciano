-- Foto de fons (resources.metadata.background) de l'escenari C1 «Medi físic i clima»: Pilar,
-- la tècnica de protecció civil de l'Ajuntament, revisa el pla municipal d'emergències (la
-- imatge és a frontend/public/images/). Tornar a aplicar el fitxer no canvia res (és un
-- UPDATE idempotent).

UPDATE public.resources
SET metadata = jsonb_set(metadata, '{background}', to_jsonb('/images/townhall.jpg'::text), true)
WHERE category = 'escenari' AND type = 'c1_medi_clima';
