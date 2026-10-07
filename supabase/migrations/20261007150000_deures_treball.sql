-- Què ha fet un aprenent en una assignació (uns deures o una ruta), pas per pas, perquè la
-- docent ho puga revisar: cada partida d'una illa, cada lliçó acabada, cada resultat de
-- pràctica/examen i cada conversa amb un personatge (amb els objectius). Per als deures,
-- només des de starts_at. Els resultats (user_resource_results) només els llig el backend:
-- esta funció els dona amb els mateixos permisos que study_assignment_progress.

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
         jsonb_build_object('seconds', s.seconds, 'easy', s.easy, 'misses', s.misses, 'stage', s.stage)
  FROM study_path_items i JOIN kids_sessions s ON s.island = i.kids_ref AND s.user_id = p_student AND s.created_at >= since
  WHERE i.path_id = a.path_id AND i.kind = 'kids_island'
  UNION ALL
  SELECT i.id, 'lesson', l.created_at, NULL, NULL, '{}'::jsonb
  FROM study_path_items i JOIN kids_lesson_sessions l ON l.lesson = i.kids_ref AND l.user_id = p_student AND l.created_at >= since
  WHERE i.path_id = a.path_id AND i.kind = 'kids_lesson'
  UNION ALL
  -- Resultats de pràctica, examen o xat.
  SELECT i.id, 'result', r.created_at, r.score, r.total, jsonb_build_object('kind', r.kind, 'level', r.level)
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

REVOKE ALL ON FUNCTION public.study_assignment_work(uuid, uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.study_assignment_work(uuid, uuid) TO authenticated;
