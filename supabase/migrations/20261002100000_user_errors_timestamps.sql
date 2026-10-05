-- Pestanya de pràctica d'errors: user_errors necessitava saber quan es va
-- cometre cada error (per a ordenar-los) i quan es va resoldre en la pràctica.
-- Les files existents reben l'hora d'aplicació de la migració com a created_at.

ALTER TABLE public.user_errors
  ADD COLUMN IF NOT EXISTS created_at  timestamptz NOT NULL DEFAULT now(),
  ADD COLUMN IF NOT EXISTS resolved_at timestamptz;
