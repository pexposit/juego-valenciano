-- Errors classificats per l'àrea i el contingut del catàleg (en lloc de les categories
-- soltes del detector: pronoms, lèxic, altres...):
--   * category: l'àrea general, com les de les activitats (fonetica_ortografia, morfosintaxi,
--     lexic_semantica; en la pràctica, l'àrea de l'activitat, p. ex. comprensio_oral).
--   * content_id: el contingut (subcategoria) del nivell de l'alumne on encaixa l'error, és
--     a dir, l'activitat de pràctica que el treballa. Null si el nivell encara no en té.
-- Els errors anteriors, amb les categories antigues, s'esborren (el seu text, al navegador,
-- deixa de mostrar-se perquè el servidor ja no els té pendents).

DELETE FROM public.user_errors;

ALTER TABLE public.user_errors
  ADD COLUMN IF NOT EXISTS content_id uuid REFERENCES public.resources(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_user_errors_content_pending
  ON public.user_errors (user_id, content_id) WHERE resolved = false;
