-- Els errors de la pestanya «Errors» no sols venen dels xats: també dels exercicis
-- de pràctica i de l'avaluació de l'Expressió escrita. Eixos recursos no tenen
-- session_resource ni missatge, així que user_errors deixa de dependre'n:
--   * user_id: propietari directe (abans s'arribava via session_resource -> sessions).
--   * resource_id / exercise_id: d'on ve l'error quan no és un xat.
--   * source: 'chat' | 'practice' | 'writing'.
--   * context: frase o enunciat on es va cometre l'error quan no hi ha missatge de xat.

ALTER TABLE public.user_errors
  ADD COLUMN IF NOT EXISTS user_id     uuid,
  ADD COLUMN IF NOT EXISTS resource_id uuid,
  ADD COLUMN IF NOT EXISTS exercise_id uuid,
  ADD COLUMN IF NOT EXISTS source      text NOT NULL DEFAULT 'chat',
  ADD COLUMN IF NOT EXISTS context     text;

-- Els errors de xat existents: el propietari és el de la sessió.
UPDATE public.user_errors ue
SET user_id = s.user_id
FROM public.session_resource sr
JOIN public.sessions s ON s.id = sr.sesion_id
WHERE sr.id = ue.session_resource_id AND ue.user_id IS NULL;

ALTER TABLE public.user_errors ALTER COLUMN user_id SET NOT NULL;
ALTER TABLE public.user_errors ALTER COLUMN session_resource_id DROP NOT NULL;

ALTER TABLE public.user_errors
  DROP CONSTRAINT IF EXISTS user_errors_user_id_fkey,
  ADD CONSTRAINT user_errors_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE,
  DROP CONSTRAINT IF EXISTS user_errors_resource_id_fkey,
  ADD CONSTRAINT user_errors_resource_id_fkey FOREIGN KEY (resource_id) REFERENCES public.resources(id) ON DELETE CASCADE,
  DROP CONSTRAINT IF EXISTS user_errors_exercise_id_fkey,
  ADD CONSTRAINT user_errors_exercise_id_fkey FOREIGN KEY (exercise_id) REFERENCES public.practice_exercises(id) ON DELETE CASCADE,
  DROP CONSTRAINT IF EXISTS user_errors_source_check,
  ADD CONSTRAINT user_errors_source_check CHECK (source IN ('chat', 'practice', 'writing'));

CREATE INDEX IF NOT EXISTS idx_user_errors_user_pending ON public.user_errors (user_id, resolved, created_at DESC);

-- Un exercici de pràctica només pot tindre un error pendent per usuari: equivocar-se
-- dos cops en el mateix exercici no el duplica.
CREATE UNIQUE INDEX IF NOT EXISTS uq_user_errors_pending_exercise
  ON public.user_errors (user_id, exercise_id)
  WHERE exercise_id IS NOT NULL AND NOT resolved;
