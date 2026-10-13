-- L'alumnat i el catàleg passen dels nivells de l'app (principiant = A1-A2, intermedi = B1-B2,
-- avancat = C1-C2) als nivells del MECR, un per un: profiles.level, sessions.level_at_start,
-- learning_paths.level, resources.difficulty i study_paths.level valen 'nivell0' o A1...C2.
-- Així un alumne de B1 no veu les activitats del B2 barrejades amb les seues, i a l'inrevés.
--
-- Les columnes deixen de ser dels tipus enumerats learner_level i difficulties (que s'esborren)
-- i passen a text amb un CHECK. Les dades que ja hi havia es traduïxen així:
--   - recursos: el nivell de l'examen (metadata.exam.level) o el dels exercicis (practice_exercises)
--     si en tenen; les activitats del professorat, el seu metadata.cefr_level; la resta (escenaris,
--     tutor), principiant → A2, intermedi → B1, avancat → C1, que és el nivell dels seus continguts;
--   - alumnat, sessions, rutes: principiant → A2, intermedi → B1, avancat → C1.

-- ── Recursos ──────────────────────────────────────────────────────────────
ALTER TABLE public.resources ALTER COLUMN difficulty TYPE text USING difficulty::text;

UPDATE public.resources r SET difficulty = coalesce(
  CASE WHEN r.teacher_id IS NOT NULL THEN r.metadata ->> 'cefr_level' END,
  r.metadata -> 'exam' ->> 'level',
  (SELECT min(e.level) FROM public.practice_exercises e WHERE e.resource_id = r.id),
  CASE r.difficulty WHEN 'principiant' THEN 'A2' WHEN 'intermedi' THEN 'B1' WHEN 'avancat' THEN 'C1' END,
  r.difficulty
)
WHERE r.difficulty IN ('principiant', 'intermedi', 'avancat');

ALTER TABLE public.resources DROP CONSTRAINT IF EXISTS resources_difficulty_check;
ALTER TABLE public.resources ADD CONSTRAINT resources_difficulty_check
  CHECK (difficulty IN ('nivell0', 'A1', 'A2', 'B1', 'B2', 'C1', 'C2'));
DROP TYPE IF EXISTS public.difficulties;

-- ── Alumnat, sessions i rutes de la IA ───────────────────────────────────
ALTER TABLE public.profiles ALTER COLUMN level DROP DEFAULT;
ALTER TABLE public.profiles ALTER COLUMN level TYPE text USING level::text;
ALTER TABLE public.sessions ALTER COLUMN level_at_start TYPE text USING level_at_start::text;
ALTER TABLE public.learning_paths ALTER COLUMN level TYPE text USING level::text;

UPDATE public.profiles SET level = CASE level WHEN 'principiant' THEN 'A2' WHEN 'intermedi' THEN 'B1' WHEN 'avancat' THEN 'C1' END
WHERE level IN ('principiant', 'intermedi', 'avancat');
UPDATE public.sessions SET level_at_start = CASE level_at_start WHEN 'principiant' THEN 'A2' WHEN 'intermedi' THEN 'B1' WHEN 'avancat' THEN 'C1' END
WHERE level_at_start IN ('principiant', 'intermedi', 'avancat');
UPDATE public.learning_paths SET level = CASE level WHEN 'principiant' THEN 'A2' WHEN 'intermedi' THEN 'B1' WHEN 'avancat' THEN 'C1' END
WHERE level IN ('principiant', 'intermedi', 'avancat');

ALTER TABLE public.profiles ALTER COLUMN level SET DEFAULT 'A2';
ALTER TABLE public.profiles ADD CONSTRAINT profiles_level_check
  CHECK (level IN ('nivell0', 'A1', 'A2', 'B1', 'B2', 'C1', 'C2'));
ALTER TABLE public.sessions ADD CONSTRAINT sessions_level_at_start_check
  CHECK (level_at_start IN ('nivell0', 'A1', 'A2', 'B1', 'B2', 'C1', 'C2'));
ALTER TABLE public.learning_paths ADD CONSTRAINT learning_paths_level_check
  CHECK (level IN ('nivell0', 'A1', 'A2', 'B1', 'B2', 'C1', 'C2'));
DROP TYPE IF EXISTS public.learner_level;

-- ── Rutes predefinides i del professorat ──────────────────────────────────
-- Les predefinides són de l'A2 i del B1; les del professorat, de l'A1 al B2.
ALTER TABLE public.study_paths DROP CONSTRAINT IF EXISTS study_paths_level_check;
UPDATE public.study_paths SET level = CASE level WHEN 'principiant' THEN 'A2' WHEN 'intermedi' THEN 'B1' END
WHERE level IN ('principiant', 'intermedi');
ALTER TABLE public.study_paths ADD CONSTRAINT study_paths_level_check
  CHECK (level IN ('A1', 'A2', 'B1', 'B2'));

-- ── Funcions ──────────────────────────────────────────────────────────────
-- Nivells del MECR d'un nivell de l'alumne: el seu (o el Nivell 0).
CREATE OR REPLACE FUNCTION public.cefr_of(p text)
RETURNS text[]
LANGUAGE sql
IMMUTABLE
AS $$
  SELECT CASE WHEN p IN ('nivell0', 'A1', 'A2', 'B1', 'B2', 'C1', 'C2') THEN ARRAY[p] ELSE ARRAY[]::text[] END;
$$;

CREATE OR REPLACE FUNCTION public.level_label(p text)
RETURNS text
LANGUAGE sql
IMMUTABLE
AS $$
  SELECT CASE p WHEN 'nivell0' THEN 'Nivell 0' ELSE p END;
$$;

CREATE OR REPLACE FUNCTION public.handle_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  initial_level text;
  tongue text;
  group_of_age text;
begin
  group_of_age := case new.raw_user_meta_data ->> 'age_group' when 'child' then 'child' else 'adult' end;

  -- Els xiquets sempre comencen en el Nivell 0; els adults trien el seu nivell (el Nivell 0 o un del MECR).
  initial_level := case
    when group_of_age = 'child' then 'nivell0'
    when new.raw_user_meta_data ->> 'level' in ('nivell0', 'A1', 'A2', 'B1', 'B2', 'C1', 'C2') then new.raw_user_meta_data ->> 'level'
    else 'A2'
  end;

  -- Llengua materna: només al Nivell 0 (xiquets i adults); als altres nivells no es guarda.
  if initial_level = 'nivell0' then
    tongue := lower(coalesce(new.raw_user_meta_data ->> 'mother_tongue', ''));
    if tongue = '' then
      tongue := null;
    elsif tongue not in ('es', 'en', 'fr', 'it', 'ro', 'uk', 'ca', 'other') then
      tongue := 'other';
    end if;
  else
    tongue := null;
  end if;

  insert into public.profiles (id, display_name, level, mother_tongue, age_group)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'display_name', ''),
    initial_level,
    tongue,
    group_of_age
  )
  on conflict (id) do nothing;

  return new;
end;
$function$;

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
  IF p_level NOT IN ('A1', 'A2', 'B1', 'B2') THEN
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
