-- Rutes d'aprenentatge predefinides i professorat.
--   * teachers: qui és docent. No és una columna de profiles perquè la política «own
--     profile» deixa que cadascú modifique el seu perfil sencer; esta taula només
--     s'escriu des de l'SQL/Studio (service role). can_publish: pot publicar rutes
--     per a tothom (les rutes «del sistema» que poden triar tots els aprenents).
--     Per a fer docent algú:
--       INSERT INTO public.teachers (user_id) SELECT id FROM auth.users WHERE email = '...';
--   * study_paths: una ruta (títol, públic, nivell). La crea una docent; si és pública,
--     la veu tothom del seu públic.
--   * study_path_items: els passos, en ordre. Cada pas és un recurs del catàleg
--     (resources) o una lliçó/illa del Nivell 0 (definides en el frontend, per id).
--   * study_path_assignments: a qui s'assigna una ruta: a una classe (la docent) o a un
--     aprenent (ell mateix, o la família del xiquet, en triar una ruta pública).
-- Un pas està fet si hi ha un resultat del recurs (user_resource_results), la medalla
-- de la lliçó («llico:<id>») o el cromo de l'illa («cromo:<id>»): ho calcula
-- study_path_progress, que també pot cridar la docent per al seu alumnat.
-- Ara només els docents poden crear classes; qui ja en tenia passa a ser docent.

CREATE TABLE IF NOT EXISTS public.teachers (
  user_id uuid PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
  can_publish boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now()
);

INSERT INTO public.teachers (user_id) SELECT DISTINCT teacher_id FROM public.kids_classes ON CONFLICT DO NOTHING;

CREATE TABLE IF NOT EXISTS public.study_paths (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  title text NOT NULL CHECK (char_length(title) BETWEEN 1 AND 80),
  description text NOT NULL DEFAULT '' CHECK (char_length(description) <= 600),
  audience text NOT NULL CHECK (audience IN ('child', 'adult')),
  level public.learner_level,
  is_public boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_study_paths_owner ON public.study_paths (owner_id);
CREATE INDEX IF NOT EXISTS idx_study_paths_public ON public.study_paths (audience) WHERE is_public;

CREATE TABLE IF NOT EXISTS public.study_path_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  path_id uuid NOT NULL REFERENCES public.study_paths(id) ON DELETE CASCADE,
  position smallint NOT NULL CHECK (position >= 0),
  kind text NOT NULL CHECK (kind IN ('resource', 'kids_lesson', 'kids_island')),
  resource_id uuid REFERENCES public.resources(id) ON DELETE CASCADE,
  kids_ref text,
  -- Indicació de la docent per a este pas (p. ex. «Fes-la dues vegades»).
  note text NOT NULL DEFAULT '' CHECK (char_length(note) <= 300),
  CONSTRAINT study_path_items_ref_check CHECK (
    (kind = 'resource' AND resource_id IS NOT NULL AND kids_ref IS NULL)
    OR (kind <> 'resource' AND resource_id IS NULL AND kids_ref ~ '^[a-z0-9-]{1,40}$')
  )
);

CREATE INDEX IF NOT EXISTS idx_study_path_items_path ON public.study_path_items (path_id, position);

CREATE TABLE IF NOT EXISTS public.study_path_assignments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  path_id uuid NOT NULL REFERENCES public.study_paths(id) ON DELETE CASCADE,
  class_id uuid REFERENCES public.kids_classes(id) ON DELETE CASCADE,
  student_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE,
  assigned_by uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT study_path_assignments_target_check CHECK ((class_id IS NULL) <> (student_id IS NULL))
);

CREATE UNIQUE INDEX IF NOT EXISTS study_path_assignments_class_key ON public.study_path_assignments (path_id, class_id) WHERE class_id IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS study_path_assignments_student_key ON public.study_path_assignments (path_id, student_id) WHERE student_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_study_path_assignments_class ON public.study_path_assignments (class_id);
CREATE INDEX IF NOT EXISTS idx_study_path_assignments_student ON public.study_path_assignments (student_id);

-- Helpers sense RLS (security definer), per a usar-los en les polítiques sense recursió.

CREATE OR REPLACE FUNCTION public.is_teacher()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (SELECT 1 FROM teachers WHERE user_id = auth.uid());
$$;

CREATE OR REPLACE FUNCTION public.can_publish_paths()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (SELECT 1 FROM teachers WHERE user_id = auth.uid() AND can_publish);
$$;

-- La ruta està assignada a la persona que ha iniciat sessió (directament o per una classe seua)?
CREATE OR REPLACE FUNCTION public.is_path_assigned_to_me(path uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM study_path_assignments a
    WHERE a.path_id = path
      AND (a.student_id = auth.uid()
           OR a.class_id IN (SELECT class_id FROM kids_class_members WHERE student_id = auth.uid()))
  );
$$;

-- Qui pot vore una ruta: qui la té, si és pública, si la té assignada, o la docent d'una
-- classe on està assignada (per a seguir l'alumnat).
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
        SELECT 1 FROM study_path_assignments a JOIN kids_classes c ON c.id = a.class_id
        WHERE a.path_id = p.id AND c.teacher_id = auth.uid()
      ))
  );
$$;

CREATE OR REPLACE FUNCTION public.owns_path(path uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (SELECT 1 FROM study_paths WHERE id = path AND owner_id = auth.uid());
$$;

ALTER TABLE public.teachers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.study_paths ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.study_path_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.study_path_assignments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "teachers: own row" ON public.teachers FOR SELECT USING (user_id = auth.uid());

-- owner_id i is_public també en línia: en un INSERT ... RETURNING, can_see_path encara no veu la fila nova.
CREATE POLICY "study_paths: visible" ON public.study_paths FOR SELECT
  USING (owner_id = auth.uid() OR is_public OR public.can_see_path(id));
-- Només una docent crea rutes, sempre a nom seu; publicar-les per a tothom requerix can_publish.
CREATE POLICY "study_paths: teacher creates" ON public.study_paths FOR INSERT
  WITH CHECK (owner_id = auth.uid() AND public.is_teacher() AND (NOT is_public OR public.can_publish_paths()));
CREATE POLICY "study_paths: owner edits" ON public.study_paths FOR UPDATE
  USING (owner_id = auth.uid())
  WITH CHECK (owner_id = auth.uid() AND (NOT is_public OR public.can_publish_paths()));
CREATE POLICY "study_paths: owner deletes" ON public.study_paths FOR DELETE USING (owner_id = auth.uid());

CREATE POLICY "study_path_items: visible" ON public.study_path_items FOR SELECT USING (public.can_see_path(path_id));
CREATE POLICY "study_path_items: owner writes" ON public.study_path_items FOR ALL
  USING (public.owns_path(path_id)) WITH CHECK (public.owns_path(path_id));

-- Cadascú veu les seues assignacions i les de les seues classes; la docent, les de les classes que porta.
CREATE POLICY "study_path_assignments: reads" ON public.study_path_assignments FOR SELECT USING (
  student_id = auth.uid()
  OR public.is_member_of(class_id)
  OR EXISTS (SELECT 1 FROM public.kids_classes c WHERE c.id = class_id AND c.teacher_id = auth.uid())
);
-- La docent assigna a les seues classes rutes que pot vore; cadascú s'apunta a rutes públiques.
CREATE POLICY "study_path_assignments: assigns" ON public.study_path_assignments FOR INSERT WITH CHECK (
  assigned_by = auth.uid() AND public.can_see_path(path_id) AND (
    (class_id IS NOT NULL AND EXISTS (SELECT 1 FROM public.kids_classes c WHERE c.id = class_id AND c.teacher_id = auth.uid()))
    OR (student_id = auth.uid() AND EXISTS (SELECT 1 FROM public.study_paths p WHERE p.id = path_id AND p.is_public))
  )
);
CREATE POLICY "study_path_assignments: removes" ON public.study_path_assignments FOR DELETE USING (
  student_id = auth.uid()
  OR EXISTS (SELECT 1 FROM public.kids_classes c WHERE c.id = class_id AND c.teacher_id = auth.uid())
);

GRANT SELECT ON public.teachers TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.study_paths, public.study_path_items TO authenticated;
GRANT SELECT, INSERT, DELETE ON public.study_path_assignments TO authenticated;

CREATE OR REPLACE FUNCTION public.study_paths_touch()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS study_paths_touch ON public.study_paths;
CREATE TRIGGER study_paths_touch BEFORE UPDATE ON public.study_paths
  FOR EACH ROW EXECUTE FUNCTION public.study_paths_touch();

-- Guarda els passos d'una ruta de colp (en l'ordre de l'array). p_items: [{kind, resource_id?, kids_ref?, note?}].
CREATE OR REPLACE FUNCTION public.save_study_path_items(p_path uuid, p_items jsonb)
RETURNS void
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public
AS $$
BEGIN
  IF NOT public.owns_path(p_path) THEN
    RAISE EXCEPTION 'Només qui ha creat la ruta la pot editar' USING ERRCODE = '42501';
  END IF;
  IF jsonb_typeof(p_items) <> 'array' OR jsonb_array_length(p_items) > 100 THEN
    RAISE EXCEPTION 'Passos no vàlids' USING ERRCODE = '22023';
  END IF;
  DELETE FROM study_path_items WHERE path_id = p_path;
  INSERT INTO study_path_items (path_id, position, kind, resource_id, kids_ref, note)
  SELECT p_path, (x.ord - 1)::smallint, x.item ->> 'kind', (x.item ->> 'resource_id')::uuid,
         x.item ->> 'kids_ref', left(coalesce(x.item ->> 'note', ''), 300)
  FROM jsonb_array_elements(p_items) WITH ORDINALITY AS x(item, ord);
  UPDATE study_paths SET updated_at = now() WHERE id = p_path;
END;
$$;

-- Quins passos d'una ruta ha fet un aprenent: ell mateix, o la docent d'una classe seua.
CREATE OR REPLACE FUNCTION public.study_path_progress(p_path uuid, p_student uuid)
RETURNS TABLE (item_id uuid, done boolean)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF auth.uid() IS NULL OR NOT (p_student = auth.uid() OR public.is_teacher_of(p_student)) OR NOT public.can_see_path(p_path) THEN
    RAISE EXCEPTION 'No pots vore este seguiment' USING ERRCODE = '42501';
  END IF;
  RETURN QUERY
  SELECT i.id,
    CASE i.kind
      WHEN 'resource' THEN EXISTS (SELECT 1 FROM user_resource_results r WHERE r.user_id = p_student AND r.resource_id = i.resource_id)
      WHEN 'kids_lesson' THEN ('llico:' || i.kids_ref) = ANY (pr.badges)
      ELSE ('cromo:' || i.kids_ref) = ANY (pr.badges)
    END
  FROM study_path_items i
  JOIN profiles pr ON pr.id = p_student
  WHERE i.path_id = p_path
  ORDER BY i.position;
END;
$$;

-- Ara només els docents creen classes (abans, qualsevol adult).
CREATE OR REPLACE FUNCTION public.kids_create_class(p_name text)
RETURNS public.kids_classes
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  uid uuid := auth.uid();
  alphabet text := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  new_code text;
  created kids_classes;
BEGIN
  IF uid IS NULL THEN
    RAISE EXCEPTION 'Cal iniciar sessió' USING ERRCODE = '42501';
  END IF;
  IF NOT public.is_teacher() THEN
    RAISE EXCEPTION 'Només el professorat pot crear classes' USING ERRCODE = '42501';
  END IF;
  IF char_length(trim(coalesce(p_name, ''))) NOT BETWEEN 1 AND 60 THEN
    RAISE EXCEPTION 'El nom de la classe ha de tindre entre 1 i 60 caràcters' USING ERRCODE = '22023';
  END IF;
  LOOP
    -- gen_random_bytes en lloc de random(): els codis no s'han de poder endevinar.
    new_code := (SELECT string_agg(substr(alphabet, 1 + (get_byte(b, i) % length(alphabet)), 1), '')
                 FROM extensions.gen_random_bytes(6) AS b, generate_series(0, 5) AS i);
    BEGIN
      INSERT INTO kids_classes (teacher_id, name, code) VALUES (uid, trim(p_name), new_code) RETURNING * INTO created;
      RETURN created;
    EXCEPTION WHEN unique_violation THEN
      -- Codi repetit: se'n prova un altre.
    END;
  END LOOP;
END;
$$;

REVOKE ALL ON FUNCTION public.is_teacher() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.can_publish_paths() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.is_path_assigned_to_me(uuid) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.can_see_path(uuid) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.owns_path(uuid) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.save_study_path_items(uuid, jsonb) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.study_path_progress(uuid, uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.is_teacher() TO authenticated;
GRANT EXECUTE ON FUNCTION public.can_publish_paths() TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_path_assigned_to_me(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.can_see_path(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.owns_path(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.save_study_path_items(uuid, jsonb) TO authenticated;
GRANT EXECUTE ON FUNCTION public.study_path_progress(uuid, uuid) TO authenticated;
