-- Converses del Nivell 0 (escenaris com «El mag i la poció màgica») per al seguiment de la
-- família i del professorat. En el Nivell 0 no es guarden errors gramaticals de la conversa:
-- en acabar-la, el LLM només revisa quins objectius de l'escenari ha complit el xiquet.
-- Una fila per conversa (session_resource). L'escriu el backend (clau de servei); la llig
-- el mateix xiquet i la seua docent, com la resta del seguiment (is_teacher_of).

CREATE TABLE IF NOT EXISTS public.kids_scenario_reviews (
  session_resource_id uuid PRIMARY KEY REFERENCES public.session_resource(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  resource_id uuid NOT NULL REFERENCES public.resources(id) ON DELETE CASCADE,
  scenario_name text NOT NULL,
  -- [{ "text": "Comptar fins a cinc els ingredients.", "met": true }]; met és null si no s'ha pogut revisar.
  objectives jsonb NOT NULL DEFAULT '[]',
  turns smallint NOT NULL DEFAULT 0 CHECK (turns >= 0),
  seconds integer NOT NULL DEFAULT 0 CHECK (seconds >= 0),
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_kids_scenario_reviews_user ON public.kids_scenario_reviews (user_id, created_at DESC);

ALTER TABLE public.kids_scenario_reviews ENABLE ROW LEVEL SECURITY;

CREATE POLICY "kids_scenario_reviews: own or teacher" ON public.kids_scenario_reviews
  FOR SELECT USING (user_id = auth.uid() OR public.is_teacher_of(user_id));

REVOKE ALL ON public.kids_scenario_reviews FROM anon;
GRANT SELECT ON public.kids_scenario_reviews TO authenticated;
