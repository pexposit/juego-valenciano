-- Deures amb activitats soltes: la docent tria activitats del catàleg sense crear una ruta.
-- Per davall es guarden com una ruta interna (is_adhoc) que no apareix en la llista de rutes
-- de la docent ni es pot publicar; els reforços automàtics també ho són.

ALTER TABLE public.study_paths ADD COLUMN IF NOT EXISTS is_adhoc boolean NOT NULL DEFAULT false;
ALTER TABLE public.study_paths DROP CONSTRAINT IF EXISTS study_paths_adhoc_check;
ALTER TABLE public.study_paths ADD CONSTRAINT study_paths_adhoc_check CHECK (NOT (is_adhoc AND is_public));

-- Els reforços creats fins ara (títol «Reforç · …», sense publicar) passen a ser interns.
UPDATE public.study_paths SET is_adhoc = true WHERE title LIKE 'Reforç · %' AND NOT is_public;
