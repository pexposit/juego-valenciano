-- Qui entra amb el codi d'una classe (sessió anònima, sense compte) queda en eixa classe: no en pot eixir ni
-- unir-se a una altra. Si pogués eixir-ne, perdria el seguiment (i com que no té compte, no podria tornar a
-- entrar com el mateix alumne); i unir-se a més classes no té sentit amb un apodo d'una sola classe.
--   * kids_class_members: una sessió anònima no pot esborrar la seua pertinença (sí la docent, que l'esborra
--     o treu l'alumne de la classe).
--   * kids_join_class(): una sessió anònima que ja és en una classe no es pot unir a una altra.

DROP POLICY IF EXISTS "kids_class_members: student or teacher removes" ON public.kids_class_members;
CREATE POLICY "kids_class_members: student or teacher removes" ON public.kids_class_members
  FOR DELETE USING (
    (student_id = auth.uid() AND NOT coalesce((auth.jwt() ->> 'is_anonymous')::boolean, false))
    OR EXISTS (SELECT 1 FROM kids_classes c WHERE c.id = kids_class_members.class_id AND c.teacher_id = auth.uid())
  );

CREATE OR REPLACE FUNCTION public.kids_join_class(p_code text)
RETURNS TABLE (id uuid, name text)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  uid uuid := auth.uid();
  found kids_classes;
  student_level text;
  student_nick text;
  anonymous boolean := coalesce((auth.jwt() ->> 'is_anonymous')::boolean, false);
BEGIN
  IF uid IS NULL THEN
    RAISE EXCEPTION 'Cal iniciar sessió' USING ERRCODE = '42501';
  END IF;
  SELECT * INTO found FROM kids_classes c WHERE c.code = upper(trim(coalesce(p_code, '')));
  IF found.id IS NULL THEN
    RAISE EXCEPTION 'No hi ha cap classe amb este codi' USING ERRCODE = 'P0002';
  END IF;
  SELECT level::text, display_name INTO student_level, student_nick FROM profiles WHERE profiles.id = uid;
  IF NOT (cefr_of(student_level) && found.levels) THEN
    RAISE EXCEPTION 'Esta classe és per a alumnat de %, i el teu nivell és %',
      (SELECT string_agg(level_label(l), ' i ') FROM unnest(found.levels) l), level_label(student_level)
      USING ERRCODE = '42501';
  END IF;
  IF anonymous THEN
    -- Sense compte, només una classe: la del codi amb què ha entrat.
    IF EXISTS (SELECT 1 FROM kids_class_members m WHERE m.student_id = uid AND m.class_id <> found.id) THEN
      RAISE EXCEPTION 'Has entrat amb el codi d''una classe: no et pots unir a una altra sense un compte' USING ERRCODE = '42501';
    END IF;
    IF NOT valid_nick(student_nick) THEN
      RAISE EXCEPTION 'L''apodo ha de tindre entre 2 i 20 caràcters: lletres, xifres, punt, guionet o guionet baix' USING ERRCODE = '22023';
    END IF;
    IF nick_taken_in_class(found.id, student_nick, uid) THEN
      RAISE EXCEPTION 'Este apodo ja el té algú de la classe: tria''n un altre' USING ERRCODE = '23505';
    END IF;
  END IF;
  INSERT INTO kids_class_members (class_id, student_id) VALUES (found.id, uid) ON CONFLICT DO NOTHING;
  RETURN QUERY SELECT found.id, found.name;
END;
$$;
