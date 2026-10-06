-- Seguiment del Nivell 0 per a la família i el professorat.
--   * kids_sessions: cada partida d'una illa (quina etapa, quantes rondes, quantes s'han
--     encertat a la primera, quants errors, si era en mode fàcil i quant ha durat).
--   * kids_word_stats: per a cada paraula (element) que s'ha preguntat, quantes vegades
--     s'ha preguntat i quantes ha costat: d'ací ix «ho domina» i «li costa».
--   * kids_classes / kids_class_members: classes del professorat. La docent crea una
--     classe i rep un codi; la família l'escriu en el seguiment del xiquet per a unir-s'hi.
--     La docent veu el seguiment (i el nom i les medalles del perfil) de qui hi és.
-- Les escriptures només es fan amb les funcions de baix (security definer), que validen
-- les dades i usen auth.uid(): ningú pot escriure en el seguiment d'un altre.

CREATE TABLE IF NOT EXISTS public.kids_sessions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  island text NOT NULL,
  -- L'etapa de l'illa (0, 1, 2...); null si era un repàs de l'illa ja acabada.
  stage smallint,
  rounds smallint NOT NULL CHECK (rounds > 0),
  first_try smallint NOT NULL CHECK (first_try >= 0 AND first_try <= rounds),
  misses smallint NOT NULL CHECK (misses >= 0),
  easy boolean NOT NULL DEFAULT false,
  seconds integer NOT NULL CHECK (seconds >= 0),
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_kids_sessions_user ON public.kids_sessions (user_id, created_at DESC);

CREATE TABLE IF NOT EXISTS public.kids_word_stats (
  user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  item_id text NOT NULL,
  word text NOT NULL,
  emoji text NOT NULL DEFAULT '',
  island text NOT NULL,
  attempts integer NOT NULL DEFAULT 0,
  misses integer NOT NULL DEFAULT 0,
  last_seen timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, item_id),
  CONSTRAINT kids_word_stats_misses_check CHECK (misses >= 0 AND misses <= attempts)
);

CREATE TABLE IF NOT EXISTS public.kids_classes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  teacher_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  name text NOT NULL CHECK (char_length(name) BETWEEN 1 AND 60),
  -- Sense lletres que es confonen (I, O) ni xifres semblants (0, 1).
  code text NOT NULL UNIQUE CHECK (code ~ '^[A-HJ-NP-Z2-9]{6}$'),
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_kids_classes_teacher ON public.kids_classes (teacher_id);

CREATE TABLE IF NOT EXISTS public.kids_class_members (
  class_id uuid NOT NULL REFERENCES public.kids_classes(id) ON DELETE CASCADE,
  student_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  joined_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (class_id, student_id)
);

CREATE INDEX IF NOT EXISTS idx_kids_class_members_student ON public.kids_class_members (student_id);

-- La persona que ha iniciat sessió és docent d'alguna classe d'este xiquet? (Sense RLS,
-- perquè les polítiques de profiles i del seguiment la puguen fer servir sense recursió.)
CREATE OR REPLACE FUNCTION public.is_teacher_of(student uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM kids_class_members m
    JOIN kids_classes c ON c.id = m.class_id
    WHERE m.student_id = student AND c.teacher_id = auth.uid()
  );
$$;

-- Les classes d'on és membre la persona que ha iniciat sessió (sense RLS, per la mateixa raó).
CREATE OR REPLACE FUNCTION public.is_member_of(class uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (SELECT 1 FROM kids_class_members WHERE class_id = class AND student_id = auth.uid());
$$;

ALTER TABLE public.kids_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.kids_word_stats ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.kids_classes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.kids_class_members ENABLE ROW LEVEL SECURITY;

CREATE POLICY "kids_sessions: own or teacher" ON public.kids_sessions
  FOR SELECT USING (user_id = auth.uid() OR public.is_teacher_of(user_id));

CREATE POLICY "kids_word_stats: own or teacher" ON public.kids_word_stats
  FOR SELECT USING (user_id = auth.uid() OR public.is_teacher_of(user_id));

CREATE POLICY "kids_classes: teacher or member reads" ON public.kids_classes
  FOR SELECT USING (teacher_id = auth.uid() OR public.is_member_of(id));
CREATE POLICY "kids_classes: teacher renames" ON public.kids_classes
  FOR UPDATE USING (teacher_id = auth.uid()) WITH CHECK (teacher_id = auth.uid());
CREATE POLICY "kids_classes: teacher deletes" ON public.kids_classes
  FOR DELETE USING (teacher_id = auth.uid());

CREATE POLICY "kids_class_members: student or teacher reads" ON public.kids_class_members
  FOR SELECT USING (
    student_id = auth.uid()
    OR EXISTS (SELECT 1 FROM public.kids_classes c WHERE c.id = class_id AND c.teacher_id = auth.uid())
  );
-- La família pot traure el xiquet d'una classe, i la docent pot traure'l de la seua.
CREATE POLICY "kids_class_members: student or teacher removes" ON public.kids_class_members
  FOR DELETE USING (
    student_id = auth.uid()
    OR EXISTS (SELECT 1 FROM public.kids_classes c WHERE c.id = class_id AND c.teacher_id = auth.uid())
  );

-- La docent veu el nom, el nivell i les medalles/cromos (badges) dels seus alumnes.
CREATE POLICY "profiles: teacher reads students" ON public.profiles
  FOR SELECT USING (public.is_teacher_of(id));

GRANT SELECT ON public.kids_sessions, public.kids_word_stats TO authenticated;
GRANT SELECT, UPDATE, DELETE ON public.kids_classes TO authenticated;
GRANT SELECT, DELETE ON public.kids_class_members TO authenticated;

-- Guarda una partida acabada i suma les paraules preguntades. p_words: [{id, word, emoji, missed}].
CREATE OR REPLACE FUNCTION public.kids_finish_session(
  p_island text, p_stage smallint, p_rounds smallint, p_first_try smallint, p_misses smallint,
  p_easy boolean, p_seconds integer, p_words jsonb
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  uid uuid := auth.uid();
BEGIN
  IF uid IS NULL THEN
    RAISE EXCEPTION 'Cal iniciar sessió' USING ERRCODE = '42501';
  END IF;
  IF p_island !~ '^[a-z0-9-]{1,40}$' OR p_rounds NOT BETWEEN 1 AND 40 OR p_first_try NOT BETWEEN 0 AND p_rounds
     OR p_misses NOT BETWEEN 0 AND 1000 OR jsonb_typeof(p_words) <> 'array' OR jsonb_array_length(p_words) > 80 THEN
    RAISE EXCEPTION 'Partida no vàlida' USING ERRCODE = '22023';
  END IF;

  INSERT INTO kids_sessions (user_id, island, stage, rounds, first_try, misses, easy, seconds)
  VALUES (uid, p_island, p_stage, p_rounds, p_first_try, p_misses, coalesce(p_easy, false), least(greatest(coalesce(p_seconds, 0), 0), 7200));

  -- Una fila per paraula (si apareix dues vegades en la partida, compta com a fallada si en alguna ha costat).
  INSERT INTO kids_word_stats AS s (user_id, item_id, word, emoji, island, attempts, misses, last_seen)
  SELECT uid, w.id, w.word, w.emoji, p_island, 1, CASE WHEN w.missed THEN 1 ELSE 0 END, now()
  FROM (
    SELECT DISTINCT ON (x ->> 'id')
      left(x ->> 'id', 80) AS id,
      left(coalesce(x ->> 'word', ''), 80) AS word,
      left(coalesce(x ->> 'emoji', ''), 24) AS emoji,
      coalesce((x ->> 'missed')::boolean, false) AS missed
    FROM jsonb_array_elements(p_words) AS x
    WHERE coalesce(x ->> 'id', '') <> '' AND coalesce(x ->> 'word', '') <> ''
    ORDER BY x ->> 'id', coalesce((x ->> 'missed')::boolean, false) DESC
  ) AS w
  ON CONFLICT (user_id, item_id) DO UPDATE SET
    attempts = s.attempts + 1,
    misses = s.misses + excluded.misses,
    word = excluded.word,
    emoji = excluded.emoji,
    island = excluded.island,
    last_seen = now();
END;
$$;

-- Crea una classe (només comptes d'adult) amb un codi nou.
CREATE OR REPLACE FUNCTION public.kids_create_class(p_name text)
RETURNS public.kids_classes
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  uid uuid := auth.uid();
  alphabet text := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  new_code text;
  created kids_classes;
BEGIN
  IF uid IS NULL THEN
    RAISE EXCEPTION 'Cal iniciar sessió' USING ERRCODE = '42501';
  END IF;
  IF (SELECT age_group FROM profiles WHERE id = uid) IS DISTINCT FROM 'adult' THEN
    RAISE EXCEPTION 'Només les persones adultes poden crear classes' USING ERRCODE = '42501';
  END IF;
  IF char_length(trim(coalesce(p_name, ''))) NOT BETWEEN 1 AND 60 THEN
    RAISE EXCEPTION 'El nom de la classe ha de tindre entre 1 i 60 caràcters' USING ERRCODE = '22023';
  END IF;
  LOOP
    new_code := (SELECT string_agg(substr(alphabet, 1 + floor(random() * length(alphabet))::int, 1), '') FROM generate_series(1, 6));
    BEGIN
      INSERT INTO kids_classes (teacher_id, name, code) VALUES (uid, trim(p_name), new_code) RETURNING * INTO created;
      RETURN created;
    EXCEPTION WHEN unique_violation THEN
      -- Codi repetit: se'n prova un altre.
    END;
  END LOOP;
END;
$$;

-- Unix el xiquet que ha iniciat sessió a la classe d'este codi. Torna la classe (id i nom).
CREATE OR REPLACE FUNCTION public.kids_join_class(p_code text)
RETURNS TABLE (id uuid, name text)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  uid uuid := auth.uid();
  found kids_classes;
BEGIN
  IF uid IS NULL THEN
    RAISE EXCEPTION 'Cal iniciar sessió' USING ERRCODE = '42501';
  END IF;
  SELECT * INTO found FROM kids_classes c WHERE c.code = upper(trim(coalesce(p_code, '')));
  IF found.id IS NULL THEN
    RAISE EXCEPTION 'No hi ha cap classe amb este codi' USING ERRCODE = 'P0002';
  END IF;
  INSERT INTO kids_class_members (class_id, student_id) VALUES (found.id, uid) ON CONFLICT DO NOTHING;
  RETURN QUERY SELECT found.id, found.name;
END;
$$;

REVOKE ALL ON FUNCTION public.kids_finish_session(text, smallint, smallint, smallint, smallint, boolean, integer, jsonb) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.kids_create_class(text) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.kids_join_class(text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.kids_finish_session(text, smallint, smallint, smallint, smallint, boolean, integer, jsonb) TO authenticated;
GRANT EXECUTE ON FUNCTION public.kids_create_class(text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.kids_join_class(text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_teacher_of(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_member_of(uuid) TO authenticated;
