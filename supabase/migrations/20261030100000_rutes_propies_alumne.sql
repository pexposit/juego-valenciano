-- Rutes pròpies de l'alumne: les genera el tutor del xat (amb activitats que ja existixen) quan l'aprenent diu que
-- li costa alguna cosa i accepta que se li'n prepare una. Només les veu i les esborra l'alumne que les té.
-- Una ruta és, per tant, d'un d'estos tres tipus: predefinida (sense propietari), d'una docent per a una classe
-- (teacher_id + class_id) o pròpia d'un alumne (student_id).

ALTER TABLE public.study_paths
  ADD COLUMN IF NOT EXISTS student_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE;

CREATE INDEX IF NOT EXISTS idx_study_paths_student ON public.study_paths (student_id);

ALTER TABLE public.study_paths DROP CONSTRAINT IF EXISTS study_paths_owner_check;
ALTER TABLE public.study_paths ADD CONSTRAINT study_paths_owner_check CHECK (
  (student_id IS NULL AND (teacher_id IS NULL) = (class_id IS NULL))
  OR (student_id IS NOT NULL AND teacher_id IS NULL AND class_id IS NULL)
);

DROP POLICY IF EXISTS "study_paths: predefined, own or member" ON public.study_paths;
CREATE POLICY "study_paths: predefined, own or member" ON public.study_paths
  FOR SELECT USING (
    (teacher_id IS NULL AND student_id IS NULL)
    OR teacher_id = auth.uid()
    OR student_id = auth.uid()
    OR public.is_member_of(class_id)
  );

DROP POLICY IF EXISTS "study_paths: teacher deletes" ON public.study_paths;
DROP POLICY IF EXISTS "study_paths: owner deletes" ON public.study_paths;
CREATE POLICY "study_paths: owner deletes" ON public.study_paths
  FOR DELETE USING (teacher_id = auth.uid() OR student_id = auth.uid());

-- Guarda una ruta pròpia de l'alumne p_student. Només la crida el backend (service_role) després d'autenticar-lo: el
-- client no la pot cridar. p_resources: les activitats en ordre, totes del catàleg i del seu nivell. Com a molt 20 rutes
-- per alumne: el tutor no li pot omplir la pantalla de rutes.
CREATE OR REPLACE FUNCTION public.save_own_study_path(p_student uuid, p_title text, p_description text, p_resources uuid[])
 RETURNS study_paths
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  uid uuid := p_student;
  learner_level text;
  saved study_paths;
BEGIN
  IF uid IS NULL OR NOT EXISTS (SELECT 1 FROM profiles WHERE id = uid) THEN
    RAISE EXCEPTION 'Cal iniciar sessió' USING ERRCODE = '42501';
  END IF;
  -- La ruta és del nivell de l'alumne (el que diu el seu perfil, no el que envia el client).
  SELECT level INTO learner_level FROM profiles WHERE id = uid;
  IF learner_level IS NULL OR learner_level NOT IN ('A1', 'A2', 'B1', 'B2', 'C1') THEN
    RAISE EXCEPTION 'El teu nivell encara no té rutes' USING ERRCODE = '22023';
  END IF;
  IF (SELECT count(*) FROM study_paths WHERE student_id = uid) >= 20 THEN
    RAISE EXCEPTION 'Ja tens 20 rutes pròpies: esborra''n alguna abans de crear-ne una altra' USING ERRCODE = '22023';
  END IF;
  IF char_length(trim(coalesce(p_title, ''))) NOT BETWEEN 1 AND 80 OR char_length(coalesce(p_description, '')) > 400 THEN
    RAISE EXCEPTION 'El títol ha de tindre entre 1 i 80 caràcters i la descripció, com a molt 400' USING ERRCODE = '22023';
  END IF;
  IF coalesce(cardinality(p_resources), 0) NOT BETWEEN 1 AND 40
     OR (SELECT count(DISTINCT r) FROM unnest(p_resources) r) <> cardinality(p_resources) THEN
    RAISE EXCEPTION 'Una ruta ha de tindre entre 1 i 40 activitats, sense repetir-ne cap' USING ERRCODE = '22023';
  END IF;
  -- Només activitats del catàleg (no de cap docent) i del nivell de l'alumne.
  IF (SELECT count(*) FROM resources
      WHERE id = ANY (p_resources) AND difficulty = learner_level AND teacher_id IS NULL) <> cardinality(p_resources) THEN
    RAISE EXCEPTION 'Totes les activitats han de ser del catàleg i del teu nivell' USING ERRCODE = '22023';
  END IF;

  INSERT INTO study_paths (level, title, description, student_id)
  VALUES (learner_level, trim(p_title), trim(coalesce(p_description, '')), uid)
  RETURNING * INTO saved;

  INSERT INTO study_path_steps (path_id, position, resource_id)
  SELECT saved.id, r.n, r.id FROM unnest(p_resources) WITH ORDINALITY AS r(id, n);
  RETURN saved;
END;
$function$;

REVOKE ALL ON FUNCTION public.save_own_study_path(uuid, text, text, uuid[]) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.save_own_study_path(uuid, text, text, uuid[]) TO service_role;
