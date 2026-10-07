-- Per a revisar els fallos de cada intent (no només la nota):
--   * kids_sessions.words: les paraules de cada partida i si han costat. Fins ara només hi
--     havia el recompte acumulat per paraula (kids_word_stats), no el de cada partida.
--   * study_assignment_work torna també les paraules de cada partida i els detalls de cada
--     resultat (la pràctica guarda ara les respostes de l'alumne en details.answers).

ALTER TABLE public.kids_sessions ADD COLUMN IF NOT EXISTS words jsonb NOT NULL DEFAULT '[]';

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

  INSERT INTO kids_sessions (user_id, island, stage, rounds, first_try, misses, easy, seconds, words)
  VALUES (uid, p_island, p_stage, p_rounds, p_first_try, p_misses, coalesce(p_easy, false), least(greatest(coalesce(p_seconds, 0), 0), 7200),
    -- Les paraules d'esta partida (quines han costat), perquè la docent les puga revisar.
    (SELECT coalesce(jsonb_agg(jsonb_build_object(
       'word', left(x ->> 'word', 80), 'emoji', left(coalesce(x ->> 'emoji', ''), 24), 'missed', coalesce((x ->> 'missed')::boolean, false))), '[]'::jsonb)
     FROM jsonb_array_elements(p_words) AS x WHERE coalesce(x ->> 'word', '') <> ''));

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

CREATE OR REPLACE FUNCTION public.study_assignment_work(p_assignment uuid, p_student uuid)
RETURNS TABLE (item_id uuid, source text, at timestamptz, score numeric, total numeric, extra jsonb)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  a study_path_assignments;
  since timestamptz;
BEGIN
  SELECT * INTO a FROM study_path_assignments WHERE id = p_assignment;
  IF a.id IS NULL OR auth.uid() IS NULL
     OR NOT (p_student = auth.uid() OR public.is_teacher_of(p_student))
     OR NOT (a.student_id = p_student OR p_student IN (SELECT student_id FROM kids_class_members WHERE class_id = a.class_id)) THEN
    RAISE EXCEPTION 'No pots vore este seguiment' USING ERRCODE = '42501';
  END IF;
  since := CASE WHEN a.due_at IS NULL THEN '-infinity'::timestamptz ELSE a.starts_at END;

  RETURN QUERY
  -- Partides d'una illa: encerts a la primera sobre rondes.
  SELECT i.id, 'island'::text, s.created_at, s.first_try::numeric, s.rounds::numeric,
         jsonb_build_object('seconds', s.seconds, 'easy', s.easy, 'misses', s.misses, 'stage', s.stage, 'words', s.words)
  FROM study_path_items i JOIN kids_sessions s ON s.island = i.kids_ref AND s.user_id = p_student AND s.created_at >= since
  WHERE i.path_id = a.path_id AND i.kind = 'kids_island'
  UNION ALL
  SELECT i.id, 'lesson', l.created_at, NULL, NULL, '{}'::jsonb
  FROM study_path_items i JOIN kids_lesson_sessions l ON l.lesson = i.kids_ref AND l.user_id = p_student AND l.created_at >= since
  WHERE i.path_id = a.path_id AND i.kind = 'kids_lesson'
  UNION ALL
  -- Resultats de pràctica, examen o xat.
  SELECT i.id, 'result', r.created_at, r.score, r.total, jsonb_build_object('kind', r.kind, 'level', r.level, 'details', r.details)
  FROM study_path_items i JOIN user_resource_results r ON r.resource_id = i.resource_id AND r.user_id = p_student AND r.created_at >= since
  WHERE i.path_id = a.path_id AND i.kind = 'resource'
  UNION ALL
  -- Converses amb personatges (Nivell 0): objectius complits i la sessió, per a llegir-la.
  SELECT i.id, 'conversation', c.created_at, NULL, NULL,
         jsonb_build_object('session_resource_id', c.session_resource_id, 'resource_id', c.resource_id, 'scenario_name', c.scenario_name,
                            'objectives', c.objectives, 'turns', c.turns, 'seconds', c.seconds)
  FROM study_path_items i JOIN kids_scenario_reviews c ON c.resource_id = i.resource_id AND c.user_id = p_student AND c.created_at >= since
  WHERE i.path_id = a.path_id AND i.kind = 'resource'
  ORDER BY 3;
END;
$$;
