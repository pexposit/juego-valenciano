-- Migració agrupada: 20261020100000_ajustos_i_rutes_c1
-- Conté, per ordre, les 4 migracions originals següents:
--   20261020100000_reinici_activitats
--   20261021100000_veu_doraemon_xiquets
--   20261021110000_pati_continuitat
--   20261022100000_rutes_c1

-- ============================================================
-- Origen: 20261020100000_reinici_activitats.sql
-- ============================================================
-- Reiniciar una activitat («Tornar a fer»): les rutes i les activitats de la classe deixen de mostrar-la com a
-- corregida i amb la seua nota fins que es torne a corregir. No s'esborra cap resultat (user_resource_results és
-- l'historial que fan servir la ruta personalitzada i els informes de la docent): només es guarda des de quan
-- compta cada activitat per a l'alumne. Un resultat és «vigent» si és posterior al reinici.
-- Sense polítiques: només el backend (service_role) la llig i l'escriu.

CREATE TABLE IF NOT EXISTS public.activity_restarts (
  user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  resource_id uuid NOT NULL REFERENCES public.resources(id) ON DELETE CASCADE,
  restarted_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, resource_id)
);

ALTER TABLE public.activity_restarts ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- Origen: 20261021100000_veu_doraemon_xiquets.sql
-- ============================================================
-- Veu de Doraemon (`rvc:doraemon`, del laboratori de veu: Matxa + RVC) per al tutor infantil del tauler i per als
-- escenaris infantils del Nivell 0 (el mag, el zoo, el pati, la biblioteca...). Els escenaris del Nivell 0 per a adults
-- (metadata.audience = 'adult') no la porten: conserven la seua veu.
--
-- El backend envia les veus `rvc:*` al laboratori (SPEECH_LAB_URL) i, si no hi és o no respon, cau a la veu per defecte
-- (gina): sense el laboratori tot continua funcionant, només que amb l'altra veu. Les saludes estàtiques dels
-- escenaris es generen amb `npx tsx scripts/generate-scenario-audio.ts --force` a backend/ (cal el laboratori en marxa).
-- Tornar a aplicar el fitxer no canvia res.

UPDATE public.resources
SET metadata = jsonb_set(metadata, '{voice}', '"rvc:doraemon"'::jsonb)
WHERE (category = 'assistent' AND type = 'ajuda_infantil')
   OR (category = 'escenari'
       AND difficulty = 'nivell0'
       AND coalesce(metadata ->> 'audience', '') <> 'adult');

-- ============================================================
-- Origen: 20261021110000_pati_continuitat.sql
-- ============================================================
-- El guion del pati («canvieu d'activitat una vegada o dues») feia que Laia canviara de joc als dos torns, sense enllaçar-ho
-- amb el que el xiquet acabava de contar (parlaven de futbol i li oferia pillar o saltar a corda). Ara es queda en el tema
-- fins que s'ha parlat prou i, quan en canvia, ho lliga amb el que ha dit. Tornar a aplicar el fitxer no canvia res.

UPDATE public.resources
SET metadata = jsonb_set(
  metadata,
  '{system_prompt}',
  to_jsonb(replace(
    metadata ->> 'system_prompt',
    'canvieu d''activitat una vegada o dues perquè parle d''altres jocs',
    'no canvieu d''activitat fins que hages parlat de l''actual almenys tres torns (amb qui juga, com es juga, quants sou, qui guanya...), perquè no oblides el que t''ha contat; quan canvieu, una vegada o dues, enllaça-ho amb el que ha dit («Ara que hem parlat de futbol, vols saltar a corda?») perquè parle d''altres jocs'
  ))
)
WHERE type = 'n0_pati'
  AND metadata ->> 'system_prompt' LIKE '%canvieu d''activitat una vegada o dues perquè parle d''altres jocs%';

-- ============================================================
-- Origen: 20261022100000_rutes_c1.sql
-- ============================================================
-- Rutes d'aprenentatge de la docent també per al nivell C1.
-- Fins ara, les rutes de classe (study_paths) eren de l'A1 al B2: la restricció de la taula i save_study_path
-- (l'única manera d'escriure-hi des de l'aplicació) accepten ara també el C1. La resta de validacions no canvia:
-- la ruta ha de ser d'un dels nivells de la classe i totes les activitats, del nivell de la ruta.

ALTER TABLE public.study_paths DROP CONSTRAINT IF EXISTS study_paths_level_check;
ALTER TABLE public.study_paths ADD CONSTRAINT study_paths_level_check
  CHECK (level IN ('A1', 'A2', 'B1', 'B2', 'C1'));

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
  IF p_level NOT IN ('A1', 'A2', 'B1', 'B2', 'C1') THEN
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

