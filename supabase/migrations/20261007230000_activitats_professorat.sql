-- Activitats creades pel professorat. Tenen la mateixa forma que les del catàleg i es guarden
-- en les mateixes taules (resources, practice_exercises, practice_passages), de manera que les
-- pinten les mateixes pantalles:
--   * Exercicis (fonetica_ortografia, morfosintaxi, lexic_semantica): preguntes 'choice' i 'fill'.
--   * Comprensió lectora (comprensio_escrita): un text (practice_passages, media 'text') amb preguntes 'choice'.
--   * Redacció (expressio_escrita): un exercici 'writing' amb el mínim i el màxim de paraules.
--   * Escenari (escenari): el personatge en metadata, com els escenaris del catàleg. El prompt el
--     construïx el backend a partir dels camps: la docent no l'escriu.
-- resources.teacher_id és l'autora (null = catàleg). Les activitats d'una docent no les veu ningú
-- fins que les assigna a una classe (teacher_activity_classes): llavors les veu l'alumnat d'eixa
-- classe. Tot es llig i s'escriu des del backend (client admin), que comprova qui pot vore què.

ALTER TABLE public.resources
  ADD COLUMN IF NOT EXISTS teacher_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE;

CREATE INDEX IF NOT EXISTS idx_resources_teacher ON public.resources (teacher_id) WHERE teacher_id IS NOT NULL;

CREATE TABLE IF NOT EXISTS public.teacher_activity_classes (
  resource_id uuid NOT NULL REFERENCES public.resources(id) ON DELETE CASCADE,
  class_id uuid NOT NULL REFERENCES public.kids_classes(id) ON DELETE CASCADE,
  assigned_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (resource_id, class_id)
);

CREATE INDEX IF NOT EXISTS idx_teacher_activity_classes_class ON public.teacher_activity_classes (class_id);

-- Sense polítiques: només hi accedix el backend.
ALTER TABLE public.teacher_activity_classes ENABLE ROW LEVEL SECURITY;

-- Les rutes de la docent poden incloure les seues activitats (a més de les del catàleg). En
-- posar-ne una en la ruta d'una classe, queda assignada a eixa classe perquè l'alumnat la puga obrir.
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
