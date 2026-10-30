-- Rutes d'aprenentatge també per al nivell C2, ara que el C2 té tots els continguts al catàleg (escenaris, fonètica,
-- morfosintaxi, lèxic, destreses i exàmens). Accepten ara el C2:
-- - les rutes de la docent per a una classe: la restricció de study_paths i save_study_path (com en 20261022100000);
-- - les rutes pròpies de l'alumne que prepara el tutor del xat: save_own_study_path (com en 20261030100000).
-- La resta de validacions no canvia.

ALTER TABLE public.study_paths DROP CONSTRAINT IF EXISTS study_paths_level_check;
ALTER TABLE public.study_paths ADD CONSTRAINT study_paths_level_check
  CHECK (level IN ('A1', 'A2', 'B1', 'B2', 'C1', 'C2'));

CREATE OR REPLACE FUNCTION public.save_study_path(p_id uuid, p_class uuid, p_level text, p_title text, p_description text, p_resources uuid[])
 RETURNS study_paths
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  uid uuid := auth.uid();
  saved study_paths;
BEGIN
  IF uid IS NULL THEN
    RAISE EXCEPTION 'Cal iniciar sessió' USING ERRCODE = '42501';
  END IF;
  IF (SELECT role FROM profiles WHERE id = uid) IS DISTINCT FROM 'teacher' THEN
    RAISE EXCEPTION 'Només el professorat pot crear rutes' USING ERRCODE = '42501';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM kids_classes WHERE id = p_class AND teacher_id = uid) THEN
    RAISE EXCEPTION 'La classe no és teua' USING ERRCODE = '42501';
  END IF;
  IF p_level NOT IN ('A1', 'A2', 'B1', 'B2', 'C1', 'C2') THEN
    RAISE EXCEPTION 'Nivell no vàlid' USING ERRCODE = '22023';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM kids_classes WHERE id = p_class AND cefr_of(p_level) && levels) THEN
    RAISE EXCEPTION 'La ruta ha de ser d''un dels nivells de la classe' USING ERRCODE = '22023';
  END IF;
  IF char_length(trim(coalesce(p_title, ''))) NOT BETWEEN 1 AND 80 OR char_length(coalesce(p_description, '')) > 400 THEN
    RAISE EXCEPTION 'El títol ha de tindre entre 1 i 80 caràcters i la descripció, com a molt 400' USING ERRCODE = '22023';
  END IF;
  IF coalesce(cardinality(p_resources), 0) NOT BETWEEN 1 AND 40
     OR (SELECT count(DISTINCT r) FROM unnest(p_resources) r) <> cardinality(p_resources) THEN
    RAISE EXCEPTION 'Una ruta ha de tindre entre 1 i 40 activitats, sense repetir-ne cap' USING ERRCODE = '22023';
  END IF;
  IF (SELECT count(*) FROM resources
      WHERE id = ANY (p_resources) AND difficulty = p_level AND (teacher_id IS NULL OR teacher_id = uid)) <> cardinality(p_resources) THEN
    RAISE EXCEPTION 'Totes les activitats han de ser del nivell de la ruta' USING ERRCODE = '22023';
  END IF;

  IF p_id IS NULL THEN
    INSERT INTO study_paths (level, title, description, teacher_id, class_id)
    VALUES (p_level, trim(p_title), trim(coalesce(p_description, '')), uid, p_class)
    RETURNING * INTO saved;
  ELSE
    UPDATE study_paths
    SET level = p_level, title = trim(p_title), description = trim(coalesce(p_description, '')), class_id = p_class, updated_at = now()
    WHERE id = p_id AND teacher_id = uid
    RETURNING * INTO saved;
    IF saved.id IS NULL THEN
      RAISE EXCEPTION 'La ruta no existix o no és teua' USING ERRCODE = 'P0002';
    END IF;
    DELETE FROM study_path_steps WHERE path_id = saved.id;
  END IF;

  INSERT INTO study_path_steps (path_id, position, resource_id)
  SELECT saved.id, r.n, r.id FROM unnest(p_resources) WITH ORDINALITY AS r(id, n);

  INSERT INTO teacher_activity_classes (resource_id, class_id)
  SELECT id, p_class FROM resources WHERE id = ANY (p_resources) AND teacher_id = uid
  ON CONFLICT DO NOTHING;
  RETURN saved;
END;
$function$;

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
  IF learner_level IS NULL OR learner_level NOT IN ('A1', 'A2', 'B1', 'B2', 'C1', 'C2') THEN
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
