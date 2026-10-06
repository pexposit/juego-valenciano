-- No es poden posar deures amb el termini ja passat (la interfície tampoc ho deixa).
-- Va en la política d'inserció i no en un CHECK: un CHECK amb now() fallaria en
-- qualsevol actualització posterior de deures ja vençuts.

DROP POLICY IF EXISTS "study_path_assignments: assigns" ON public.study_path_assignments;
CREATE POLICY "study_path_assignments: assigns" ON public.study_path_assignments FOR INSERT WITH CHECK (
  assigned_by = auth.uid() AND public.can_see_path(path_id) AND (due_at IS NULL OR due_at > now()) AND (
    (class_id IS NOT NULL AND EXISTS (SELECT 1 FROM public.kids_classes c WHERE c.id = class_id AND c.teacher_id = auth.uid()))
    OR (student_id IS NOT NULL AND student_id <> auth.uid() AND public.is_teacher_of(student_id))
    OR (student_id = auth.uid() AND due_at IS NULL AND EXISTS (SELECT 1 FROM public.study_paths p WHERE p.id = path_id AND p.is_public))
  )
);
