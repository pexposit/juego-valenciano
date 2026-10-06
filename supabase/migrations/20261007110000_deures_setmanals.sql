-- Deures setmanals.
--   * kids_lesson_sessions: cada lliçó del Nivell 0 acabada, amb data. Fins ara només
--     quedava la medalla («llico:<id>» en profiles.badges), sense saber quan.
--   * study_path_assignments.starts_at / due_at: una assignació amb due_at són uns deures
--     (de starts_at a due_at); sense due_at, una ruta permanent com fins ara.
--   * Els deures també es poden posar a un alumne concret d'una classe de la docent
--     (p. ex. un reforç del que li costa), no només a la classe sencera.
--   * study_assignment_progress: per als deures, un pas només compta si s'ha fet des de
--     starts_at (per a una illa, una partida; no cal el cromo). Torna també quan es va
--     fer, per a saber si va ser dins del termini.

CREATE TABLE IF NOT EXISTS public.kids_lesson_sessions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  lesson text NOT NULL CHECK (lesson ~ '^[a-z0-9-]{1,40}$'),
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_kids_lesson_sessions_user ON public.kids_lesson_sessions (user_id, created_at DESC);

ALTER TABLE public.kids_lesson_sessions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "kids_lesson_sessions: own or teacher" ON public.kids_lesson_sessions
  FOR SELECT USING (user_id = auth.uid() OR public.is_teacher_of(user_id));
GRANT SELECT ON public.kids_lesson_sessions TO authenticated;

CREATE OR REPLACE FUNCTION public.kids_finish_lesson(p_lesson text)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Cal iniciar sessió' USING ERRCODE = '42501';
  END IF;
  IF coalesce(p_lesson, '') !~ '^[a-z0-9-]{1,40}$' THEN
    RAISE EXCEPTION 'Lliçó no vàlida' USING ERRCODE = '22023';
  END IF;
  INSERT INTO kids_lesson_sessions (user_id, lesson) VALUES (auth.uid(), p_lesson);
END;
$$;

ALTER TABLE public.study_path_assignments
  ADD COLUMN IF NOT EXISTS starts_at timestamptz NOT NULL DEFAULT now(),
  ADD COLUMN IF NOT EXISTS due_at timestamptz;

ALTER TABLE public.study_path_assignments DROP CONSTRAINT IF EXISTS study_path_assignments_dates_check;
ALTER TABLE public.study_path_assignments ADD CONSTRAINT study_path_assignments_dates_check CHECK (due_at IS NULL OR due_at > starts_at);

-- La mateixa ruta es pot posar de deures diverses setmanes: la unicitat només val per a les rutes permanents.
DROP INDEX IF EXISTS public.study_path_assignments_class_key;
DROP INDEX IF EXISTS public.study_path_assignments_student_key;
CREATE UNIQUE INDEX IF NOT EXISTS study_path_assignments_class_key ON public.study_path_assignments (path_id, class_id) WHERE class_id IS NOT NULL AND due_at IS NULL;
CREATE UNIQUE INDEX IF NOT EXISTS study_path_assignments_student_key ON public.study_path_assignments (path_id, student_id) WHERE student_id IS NOT NULL AND due_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_study_path_assignments_due ON public.study_path_assignments (due_at) WHERE due_at IS NOT NULL;

-- Una ruta assignada a un alumne també la pot vore la docent que l'ha assignada.
CREATE OR REPLACE FUNCTION public.can_see_path(path uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM study_paths p
    WHERE p.id = path AND (p.owner_id = auth.uid() OR p.is_public OR public.is_path_assigned_to_me(p.id)
      OR EXISTS (
        SELECT 1 FROM study_path_assignments a LEFT JOIN kids_classes c ON c.id = a.class_id
        WHERE a.path_id = p.id AND (c.teacher_id = auth.uid() OR a.assigned_by = auth.uid())
      ))
  );
$$;

DROP POLICY IF EXISTS "study_path_assignments: reads" ON public.study_path_assignments;
CREATE POLICY "study_path_assignments: reads" ON public.study_path_assignments FOR SELECT USING (
  student_id = auth.uid()
  OR assigned_by = auth.uid()
  OR public.is_member_of(class_id)
  OR EXISTS (SELECT 1 FROM public.kids_classes c WHERE c.id = class_id AND c.teacher_id = auth.uid())
);

-- La docent assigna a les seues classes o a un alumne d'alguna classe seua; cadascú s'apunta a rutes públiques.
DROP POLICY IF EXISTS "study_path_assignments: assigns" ON public.study_path_assignments;
CREATE POLICY "study_path_assignments: assigns" ON public.study_path_assignments FOR INSERT WITH CHECK (
  assigned_by = auth.uid() AND public.can_see_path(path_id) AND (
    (class_id IS NOT NULL AND EXISTS (SELECT 1 FROM public.kids_classes c WHERE c.id = class_id AND c.teacher_id = auth.uid()))
    OR (student_id IS NOT NULL AND student_id <> auth.uid() AND public.is_teacher_of(student_id))
    OR (student_id = auth.uid() AND due_at IS NULL AND EXISTS (SELECT 1 FROM public.study_paths p WHERE p.id = path_id AND p.is_public))
  )
);

DROP POLICY IF EXISTS "study_path_assignments: removes" ON public.study_path_assignments;
CREATE POLICY "study_path_assignments: removes" ON public.study_path_assignments FOR DELETE USING (
  -- Qui l'ha posada: l'alumne pot deixar una ruta que ha triat, però no uns deures que li han posat.
  assigned_by = auth.uid()
  OR EXISTS (SELECT 1 FROM public.kids_classes c WHERE c.id = class_id AND c.teacher_id = auth.uid())
);

-- Progrés d'una assignació per a un aprenent. Deures (due_at): només el que s'ha fet des de
-- starts_at, i done_at és la primera vegada. Ruta permanent: com study_path_progress.
CREATE OR REPLACE FUNCTION public.study_assignment_progress(p_assignment uuid, p_student uuid)
RETURNS TABLE (item_id uuid, done boolean, done_at timestamptz)
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
  SELECT i.id, d.at IS NOT NULL OR (a.due_at IS NULL AND badge.ok), d.at
  FROM study_path_items i
  JOIN profiles pr ON pr.id = p_student
  CROSS JOIN LATERAL (
    SELECT CASE i.kind
      WHEN 'resource' THEN (SELECT min(r.created_at) FROM user_resource_results r WHERE r.user_id = p_student AND r.resource_id = i.resource_id AND r.created_at >= since)
      WHEN 'kids_lesson' THEN (SELECT min(l.created_at) FROM kids_lesson_sessions l WHERE l.user_id = p_student AND l.lesson = i.kids_ref AND l.created_at >= since)
      ELSE (SELECT min(s.created_at) FROM kids_sessions s WHERE s.user_id = p_student AND s.island = i.kids_ref AND s.created_at >= since)
    END AS at
  ) d
  -- Les rutes permanents segueixen comptant les medalles i els cromos d'abans.
  CROSS JOIN LATERAL (
    SELECT CASE i.kind
      WHEN 'kids_lesson' THEN ('llico:' || i.kids_ref) = ANY (pr.badges)
      WHEN 'kids_island' THEN ('cromo:' || i.kids_ref) = ANY (pr.badges)
      ELSE false
    END AS ok
  ) badge
  WHERE i.path_id = a.path_id
  ORDER BY i.position;
END;
$$;

REVOKE ALL ON FUNCTION public.kids_finish_lesson(text) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.study_assignment_progress(uuid, uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.kids_finish_lesson(text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.study_assignment_progress(uuid, uuid) TO authenticated;
