-- Més detall dels fallos per a la docent:
--   * kids_lesson_sessions.words: les paraules que han costat en els jocs d'una lliçó
--     (com kids_sessions.words en les illes). kids_finish_lesson les rep ara.
--   * study_assignment_work torna també les respostes fallades dels exercicis guardades
--     en user_errors: per als intents d'abans que es guardaren totes les respostes.

ALTER TABLE public.kids_lesson_sessions ADD COLUMN IF NOT EXISTS words jsonb NOT NULL DEFAULT '[]';

DROP FUNCTION IF EXISTS public.kids_finish_lesson(text);
CREATE OR REPLACE FUNCTION public.kids_finish_lesson(p_lesson text, p_words jsonb DEFAULT '[]')
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Cal iniciar sessió' USING ERRCODE = '42501';
  END IF;
  IF coalesce(p_lesson, '') !~ '^[a-z0-9-]{1,40}$' OR jsonb_typeof(coalesce(p_words, '[]')) <> 'array' OR jsonb_array_length(coalesce(p_words, '[]')) > 80 THEN
    RAISE EXCEPTION 'Lliçó no vàlida' USING ERRCODE = '22023';
  END IF;
  INSERT INTO kids_lesson_sessions (user_id, lesson, words)
  VALUES (auth.uid(), p_lesson,
    (SELECT coalesce(jsonb_agg(jsonb_build_object(
       'word', left(x ->> 'word', 80), 'emoji', left(coalesce(x ->> 'emoji', ''), 24), 'missed', coalesce((x ->> 'missed')::boolean, false))), '[]'::jsonb)
     FROM jsonb_array_elements(coalesce(p_words, '[]')) AS x WHERE coalesce(x ->> 'word', '') <> ''));
END;
$$;

REVOKE ALL ON FUNCTION public.kids_finish_lesson(text, jsonb) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.kids_finish_lesson(text, jsonb) TO authenticated;

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
  SELECT i.id, 'lesson', l.created_at, NULL, NULL, jsonb_build_object('words', l.words)
  FROM study_path_items i JOIN kids_lesson_sessions l ON l.lesson = i.kids_ref AND l.user_id = p_student AND l.created_at >= since
  WHERE i.path_id = a.path_id AND i.kind = 'kids_lesson'
  UNION ALL
  -- Resultats de pràctica, examen o xat.
  SELECT i.id, 'result', r.created_at, r.score, r.total, jsonb_build_object('kind', r.kind, 'level', r.level, 'details', r.details)
  FROM study_path_items i JOIN user_resource_results r ON r.resource_id = i.resource_id AND r.user_id = p_student AND r.created_at >= since
  WHERE i.path_id = a.path_id AND i.kind = 'resource'
  UNION ALL
  -- Respostes fallades dels exercicis (user_errors): per als intents d'abans que es
  -- guardaren totes les respostes, són l'únic detall que hi ha.
  SELECT i.id, 'error', e.created_at, NULL, NULL,
         jsonb_build_object('prompt', e.context, 'answer', e.error_text, 'correction', e.correction, 'explanation', e.explanation, 'exercise_id', e.exercise_id)
  FROM study_path_items i JOIN user_errors e ON e.resource_id = i.resource_id AND e.user_id = p_student AND e.source = 'practice' AND e.created_at >= since
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
