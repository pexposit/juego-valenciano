-- Foto de fons (resources.metadata.background) de l'escenari C1 «Relacions personals i
-- socials»: Neus, la cosina, prepara la festa de les noces d'or dels avis (la imatge és a
-- frontend/public/images/). Tornar a aplicar el fitxer no canvia res (és un UPDATE idempotent).

UPDATE public.resources
SET metadata = jsonb_set(metadata, '{background}', to_jsonb('/images/casa_abuelos.jpg'::text), true)
WHERE category = 'escenari' AND type = 'c1_relacions';
