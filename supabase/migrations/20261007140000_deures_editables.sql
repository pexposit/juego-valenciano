-- La docent pot canviar el termini d'uns deures que ha posat (o de la seua classe). Només
-- el termini (permís per columna): la ruta, la classe o l'alumne no es canvien, i el nou
-- termini no pot ser passat. Les activitats d'uns deures solts s'editen en la seua ruta
-- interna (save_study_path_items), que ja és de la docent.

CREATE POLICY "study_path_assignments: teacher changes due" ON public.study_path_assignments FOR UPDATE
  USING (
    due_at IS NOT NULL AND (
      assigned_by = auth.uid()
      OR EXISTS (SELECT 1 FROM public.kids_classes c WHERE c.id = class_id AND c.teacher_id = auth.uid())
    )
  )
  WITH CHECK (due_at IS NOT NULL AND due_at > now());

-- Supabase dona per defecte UPDATE sobre totes les columnes: cal llevar-lo perquè el permís
-- per columna siga l'únic (si no, es podria canviar la ruta, la classe o l'alumne).
REVOKE UPDATE ON public.study_path_assignments FROM anon, authenticated;
GRANT UPDATE (due_at) ON public.study_path_assignments TO authenticated;
