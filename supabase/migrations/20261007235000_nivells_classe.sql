-- Cada classe és d'un nivell o de dos de consecutius (p. ex. A2 i B1, per a l'alumnat que està
-- entre els dos). Només s'hi pot unir alumnat d'eixos nivells, i les rutes i les activitats de la
-- docent que s'hi assignen també han de ser d'eixos nivells.

-- Els nivells, en ordre (els mateixos valors que profiles.level i resources.difficulty).
CREATE OR REPLACE FUNCTION public.valid_class_levels(p text[])
RETURNS boolean
LANGUAGE sql
IMMUTABLE
AS $$
  SELECT p IS NOT NULL
    AND cardinality(p) BETWEEN 1 AND 2
    AND p <@ ARRAY['nivell0', 'principiant', 'intermedi', 'avancat']
    AND (cardinality(p) = 1 OR array_position(ARRAY['nivell0', 'principiant', 'intermedi', 'avancat'], p[2])
                               - array_position(ARRAY['nivell0', 'principiant', 'intermedi', 'avancat'], p[1]) = 1);
$$;

-- Nom visible d'un nivell, per als missatges d'error.
CREATE OR REPLACE FUNCTION public.level_label(p text)
RETURNS text
LANGUAGE sql
IMMUTABLE
AS $$
  SELECT CASE p WHEN 'nivell0' THEN 'Nivell 0' WHEN 'principiant' THEN 'A2' WHEN 'intermedi' THEN 'B1' WHEN 'avancat' THEN 'C1' ELSE p END;
$$;

ALTER TABLE public.kids_classes ADD COLUMN IF NOT EXISTS levels text[];

-- Classes que ja hi havia: el nivell del seu alumnat o de les seues rutes, si és un de sol; si no, el Nivell 0
-- (les classes es van crear per a l'infantil).
UPDATE public.kids_classes c
SET levels = coalesce(
  (SELECT array_agg(DISTINCT p.level::text) FROM public.kids_class_members m JOIN public.profiles p ON p.id = m.student_id
   WHERE m.class_id = c.id HAVING count(DISTINCT p.level) = 1),
  (SELECT array_agg(DISTINCT s.level) FROM public.study_paths s WHERE s.class_id = c.id HAVING count(DISTINCT s.level) = 1),
  ARRAY['nivell0'])
WHERE levels IS NULL;

ALTER TABLE public.kids_classes ALTER COLUMN levels SET NOT NULL;
ALTER TABLE public.kids_classes DROP CONSTRAINT IF EXISTS kids_classes_levels_check;
ALTER TABLE public.kids_classes ADD CONSTRAINT kids_classes_levels_check CHECK (public.valid_class_levels(levels));

-- Crea una classe (només el professorat) amb el seu nivell o nivells i un codi nou.
DROP FUNCTION IF EXISTS public.kids_create_class(text);
CREATE OR REPLACE FUNCTION public.kids_create_class(p_name text, p_levels text[])
RETURNS public.kids_classes
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  uid uuid := auth.uid();
  alphabet text := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  levels text[];
  new_code text;
  created kids_classes;
BEGIN
  IF uid IS NULL THEN
    RAISE EXCEPTION 'Cal iniciar sessió' USING ERRCODE = '42501';
  END IF;
  IF (SELECT role FROM profiles WHERE id = uid) IS DISTINCT FROM 'teacher' THEN
    RAISE EXCEPTION 'Només el professorat pot crear classes' USING ERRCODE = '42501';
  END IF;
  IF char_length(trim(coalesce(p_name, ''))) NOT BETWEEN 1 AND 60 THEN
    RAISE EXCEPTION 'El nom de la classe ha de tindre entre 1 i 60 caràcters' USING ERRCODE = '22023';
  END IF;
  -- Els nivells, sense repetir i en l'ordre dels nivells.
  SELECT array_agg(l ORDER BY array_position(ARRAY['nivell0', 'principiant', 'intermedi', 'avancat'], l))
  INTO levels FROM (SELECT DISTINCT unnest(p_levels) AS l) x;
  IF NOT valid_class_levels(levels) THEN
    RAISE EXCEPTION 'Tria un nivell o dos de consecutius per a la classe' USING ERRCODE = '22023';
  END IF;
  LOOP
    new_code := (SELECT string_agg(substr(alphabet, 1 + floor(random() * length(alphabet))::int, 1), '') FROM generate_series(1, 6));
    BEGIN
      INSERT INTO kids_classes (teacher_id, name, code, levels) VALUES (uid, trim(p_name), new_code, levels) RETURNING * INTO created;
      RETURN created;
    EXCEPTION WHEN unique_violation THEN
      -- Codi repetit: se'n prova un altre.
    END;
  END LOOP;
END;
$$;

REVOKE ALL ON FUNCTION public.kids_create_class(text, text[]) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.kids_create_class(text, text[]) TO authenticated;

-- Unix l'usuari que ha iniciat sessió a la classe d'este codi, si és d'algun dels nivells de la classe.
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
BEGIN
  IF uid IS NULL THEN
    RAISE EXCEPTION 'Cal iniciar sessió' USING ERRCODE = '42501';
  END IF;
  SELECT * INTO found FROM kids_classes c WHERE c.code = upper(trim(coalesce(p_code, '')));
  IF found.id IS NULL THEN
    RAISE EXCEPTION 'No hi ha cap classe amb este codi' USING ERRCODE = 'P0002';
  END IF;
  SELECT level::text INTO student_level FROM profiles WHERE profiles.id = uid;
  IF student_level IS NULL OR NOT (student_level = ANY (found.levels)) THEN
    RAISE EXCEPTION 'Esta classe és per a alumnat de %, i el teu nivell és %',
      (SELECT string_agg(level_label(l), ' i ') FROM unnest(found.levels) l), level_label(student_level)
      USING ERRCODE = '42501';
  END IF;
  INSERT INTO kids_class_members (class_id, student_id) VALUES (found.id, uid) ON CONFLICT DO NOTHING;
  RETURN QUERY SELECT found.id, found.name;
END;
$$;

-- Les rutes d'una classe han de ser d'un dels seus nivells.
CREATE OR REPLACE FUNCTION public.save_study_path(
  p_id uuid, p_class uuid, p_level text, p_title text, p_description text, p_resources uuid[]
)
RETURNS public.study_paths
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
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
  IF p_level NOT IN ('principiant', 'intermedi') THEN
    RAISE EXCEPTION 'Nivell no vàlid' USING ERRCODE = '22023';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM kids_classes WHERE id = p_class AND p_level = ANY (levels)) THEN
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
      WHERE id = ANY (p_resources) AND difficulty::text = p_level AND (teacher_id IS NULL OR teacher_id = uid)) <> cardinality(p_resources) THEN
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
$$;
