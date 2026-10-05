-- Ruta d'aprenentatge personalitzada.
--   * user_resource_results: resultat de cada recurs acabat per l'usuari (pràctica,
--     examen o xat). Fins ara la pràctica i els exàmens només es guardaven al
--     navegador; ara alimenten també la ruta.
--   * learning_paths / learning_path_steps: la ruta que genera el LLM a partir de les
--     avaluacions (user_evaluations), els errors (user_errors) i els resultats. Cada
--     usuari té com a molt una ruta activa; les anteriors queden arxivades.
-- Com user_evaluations, tenen RLS sense polítiques: només hi accedix el backend.

CREATE TABLE IF NOT EXISTS public.user_resource_results (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  resource_id uuid NOT NULL REFERENCES public.resources(id) ON DELETE CASCADE,
  -- Nivell del MECR dels exercicis fets (A1..C2); null en els xats.
  level text CHECK (level IS NULL OR level IN ('A1', 'A2', 'B1', 'B2', 'C1', 'C2')),
  kind text NOT NULL CHECK (kind IN ('practice', 'exam', 'chat')),
  -- Encerts i total de preguntes tancades (o punts d'un examen); null si no n'hi ha.
  score numeric,
  total numeric,
  -- Notes de les redaccions avaluades, errors detectats, àrees d'examen...
  details jsonb NOT NULL DEFAULT '{}',
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT user_resource_results_score_check CHECK (score IS NULL OR (total > 0 AND score >= 0 AND score <= total))
);

CREATE INDEX IF NOT EXISTS idx_user_resource_results_user ON public.user_resource_results (user_id, created_at DESC);

CREATE TABLE IF NOT EXISTS public.learning_paths (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  level public.learner_level NOT NULL,
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'archived')),
  -- Categories d'error o continguts en què se centra la ruta (p. ex. «pronoms»).
  focus text[] NOT NULL DEFAULT '{}',
  -- Explicació per a l'aprenent de per què se li proposa esta ruta.
  rationale text NOT NULL,
  -- priority_focus de l'última avaluació quan es va generar: si canvia, es regenera.
  source_focus text,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS learning_paths_one_active ON public.learning_paths (user_id) WHERE status = 'active';

CREATE TABLE IF NOT EXISTS public.learning_path_steps (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  path_id uuid NOT NULL REFERENCES public.learning_paths(id) ON DELETE CASCADE,
  position smallint NOT NULL,
  resource_id uuid NOT NULL REFERENCES public.resources(id) ON DELETE CASCADE,
  stage text NOT NULL CHECK (stage IN ('aprendre', 'practicar', 'aplicar', 'comprovar')),
  reason text NOT NULL,
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'done', 'skipped')),
  completed_at timestamptz,
  CONSTRAINT learning_path_steps_position_key UNIQUE (path_id, position),
  CONSTRAINT learning_path_steps_resource_key UNIQUE (path_id, resource_id)
);

ALTER TABLE public.user_resource_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.learning_paths ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.learning_path_steps ENABLE ROW LEVEL SECURITY;
