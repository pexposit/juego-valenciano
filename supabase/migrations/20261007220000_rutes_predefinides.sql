-- Rutes d'aprenentatge predefinides per a l'A2 (principiant) i el B1 (intermedi). En estos
-- nivells substituïxen la ruta que generava la IA (learning_paths):
--   * Rutes predefinides (teacher_id i class_id nuls): les veu tot l'alumnat del nivell.
--   * Rutes del professorat: cada docent en crea per a una de les seues classes, i només les
--     veu l'alumnat d'eixa classe (kids_classes: ara també hi entren adults, amb el codi).
-- Una ruta és una llista ordenada d'activitats del catàleg (resources) del seu nivell. Un pas
-- està fet quan l'usuari té algun resultat d'eixa activitat (user_resource_results).
-- El professorat només escriu amb save_study_path (security definer), que ho valida tot.

CREATE TABLE IF NOT EXISTS public.study_paths (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  level text NOT NULL CHECK (level IN ('principiant', 'intermedi')),
  title text NOT NULL CHECK (char_length(title) BETWEEN 1 AND 80),
  description text NOT NULL DEFAULT '' CHECK (char_length(description) <= 400),
  teacher_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE,
  class_id uuid REFERENCES public.kids_classes(id) ON DELETE CASCADE,
  sort_order smallint NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  -- O és predefinida (sense docent ni classe) o és d'una docent per a una classe.
  CONSTRAINT study_paths_owner_check CHECK ((teacher_id IS NULL) = (class_id IS NULL))
);

CREATE INDEX IF NOT EXISTS idx_study_paths_class ON public.study_paths (class_id);
CREATE INDEX IF NOT EXISTS idx_study_paths_level ON public.study_paths (level) WHERE teacher_id IS NULL;

CREATE TABLE IF NOT EXISTS public.study_path_steps (
  path_id uuid NOT NULL REFERENCES public.study_paths(id) ON DELETE CASCADE,
  position smallint NOT NULL CHECK (position > 0),
  resource_id uuid NOT NULL REFERENCES public.resources(id) ON DELETE CASCADE,
  PRIMARY KEY (path_id, position),
  UNIQUE (path_id, resource_id)
);

ALTER TABLE public.study_paths ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.study_path_steps ENABLE ROW LEVEL SECURITY;

CREATE POLICY "study_paths: predefined, own or member" ON public.study_paths
  FOR SELECT USING (teacher_id IS NULL OR teacher_id = auth.uid() OR public.is_member_of(class_id));
CREATE POLICY "study_paths: teacher deletes" ON public.study_paths
  FOR DELETE USING (teacher_id = auth.uid());
CREATE POLICY "study_path_steps: visible path" ON public.study_path_steps
  FOR SELECT USING (EXISTS (SELECT 1 FROM public.study_paths p WHERE p.id = path_id));

GRANT SELECT, DELETE ON public.study_paths TO authenticated;
GRANT SELECT ON public.study_path_steps TO authenticated;

-- Crea (p_id nul) o actualitza una ruta d'una classe de la docent que ha iniciat sessió.
-- p_resources: les activitats en ordre, totes del nivell de la ruta.
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
  IF (SELECT count(*) FROM resources WHERE id = ANY (p_resources) AND difficulty::text = p_level) <> cardinality(p_resources) THEN
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
  RETURN saved;
END;
$$;

REVOKE ALL ON FUNCTION public.save_study_path(uuid, uuid, text, text, text, uuid[]) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.save_study_path(uuid, uuid, text, text, text, uuid[]) TO authenticated;

/* ── Rutes predefinides ──────────────────────────────────────────────────
 * Ids fixos perquè la migració es puga tornar a aplicar. Les activitats es busquen pel
 * `type` dins del nivell: si una migració del catàleg esborra i torna a crear un recurs,
 * el seu pas desapareix (ON DELETE CASCADE) i caldrà tornar a aplicar este bloc. */
CREATE OR REPLACE FUNCTION pg_temp.seed_path(p_id uuid, p_level text, p_order int, p_title text, p_description text, p_types text[])
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO public.study_paths (id, level, title, description, sort_order)
  VALUES (p_id, p_level, p_title, p_description, p_order)
  ON CONFLICT (id) DO UPDATE SET level = excluded.level, title = excluded.title, description = excluded.description,
    sort_order = excluded.sort_order, updated_at = now();
  DELETE FROM public.study_path_steps WHERE path_id = p_id;
  INSERT INTO public.study_path_steps (path_id, position, resource_id)
  SELECT p_id, row_number() OVER (ORDER BY t.n), r.id
  FROM unnest(p_types) WITH ORDINALITY AS t(type, n)
  JOIN public.resources r ON r.type = t.type AND r.difficulty::text = p_level;
END;
$$;

-- A2 (principiant)
SELECT pg_temp.seed_path('a2000000-0000-4000-8000-000000000001', 'principiant', 1,
  'Primeres passes en l''A2',
  'Una volta per tot el que treballaràs: un poc de gramàtica, vocabulari, una conversa i les primeres comprensions i expressions.',
  ARRAY['determinants', 'vocabulari', 'a2_identificacio', 'tonicitat', 'co_personal', 'ee_vida', 'eo_entrevista']);
SELECT pg_temp.seed_path('a2000000-0000-4000-8000-000000000002', 'principiant', 2,
  'Gramàtica de l''A2',
  'Tota la morfosintaxi de l''A2, des del gènere i el nombre fins als verbs.',
  ARRAY['genere_nombre', 'determinants', 'pronoms', 'quantificadors', 'preposicions', 'adverbis', 'conjuncions', 'sistema_verbal']);
SELECT pg_temp.seed_path('a2000000-0000-4000-8000-000000000003', 'principiant', 3,
  'Ortografia i pronunciació',
  'L''accent, l''apòstrof i les lletres que més costen: s/ss/z/ç, j/g/x, l/ll, r/rr i la h.',
  ARRAY['tonicitat', 'alfabet_grafies', 'accentuacio', 'apostrofacio', 'alveolars', 'palatals', 'laterals', 'rotiques', 'grafia_h', 'puntuacio']);
SELECT pg_temp.seed_path('a2000000-0000-4000-8000-000000000004', 'principiant', 4,
  'Vocabulari del dia a dia',
  'Les paraules de cada dia, amb converses per a fer-les servir: al mercat i a la farmàcia.',
  ARRAY['vocabulari', 'vocab_temps', 'vocab_menjar', 'mercat', 'vocab_roba_cos', 'vocab_salut', 'farmacia', 'vocab_paisos_transport', 'vocab_oci', 'vocab_adjectius', 'relacions_semantiques', 'creacio_lexica']);
SELECT pg_temp.seed_path('a2000000-0000-4000-8000-000000000005', 'principiant', 5,
  'Comprensió oral i escrita',
  'Escoltar i llegir, alternant: de diàlegs i rètols fins a notícies i debats.',
  ARRAY['co_dialegs', 'ce_retols', 'co_megafonia', 'ce_documents', 'co_instruccions', 'ce_instruccions', 'co_orientacio', 'ce_correus', 'co_mitjans', 'ce_noticies', 'co_debats', 'ce_opinio']);
SELECT pg_temp.seed_path('a2000000-0000-4000-8000-000000000006', 'principiant', 6,
  'Conversa en situacions reals',
  'Parlar en situacions de cada dia: presentar-te, comprar, la casa, els servicis, els viatges i la faena.',
  ARRAY['a2_identificacio', 'forn', 'a2_menjar', 'eo_descripcio', 'a2_casa', 'a2_activitats', 'a2_servicis', 'eo_estrategies', 'a2_viatges', 'a2_faena', 'eo_exposicio']);
SELECT pg_temp.seed_path('a2000000-0000-4000-8000-000000000007', 'principiant', 7,
  'Preparar l''examen A2',
  'Expressió escrita, un repàs de connectors i verbs, i els simulacres de la JQCV.',
  ARRAY['ee_formularis', 'ee_notes', 'ee_correus', 'ee_descripcio', 'conjuncions', 'sistema_verbal', 'jqcv_a2_monoleg', 'jqcv_a2_oct2025', 'jqcv_a2_oct2024', 'jqcv_a2_oct2023']);

-- B1 (intermedi)
SELECT pg_temp.seed_path('b1000000-0000-4000-8000-000000000001', 'intermedi', 1,
  'Primeres passes en el B1',
  'Una volta per tot el que treballaràs: gramàtica, vocabulari, una conversa i les primeres comprensions i expressions.',
  ARRAY['b1_mor_determinants', 'b1_vocab_persones', 'b1_persones', 'b1_fon_accentuacio', 'b1_ce_correspondencia', 'b1_ee_correus', 'b1_eo_experiencies']);
SELECT pg_temp.seed_path('b1000000-0000-4000-8000-000000000002', 'intermedi', 2,
  'Gramàtica del B1',
  'Tota la morfosintaxi del B1: determinants, pronoms febles, preposicions, connectors i verbs.',
  ARRAY['b1_mor_substantius', 'b1_mor_adjectius', 'b1_mor_determinants', 'b1_mor_pronoms_personals', 'b1_mor_pronoms_cd_ci', 'b1_mor_interrogatius', 'b1_mor_numerals', 'b1_mor_quantitatius_indefinits', 'b1_mor_preposicions', 'b1_mor_adverbis', 'b1_mor_connectors', 'b1_mor_verbs_regulars', 'b1_mor_verbs_irregulars', 'b1_mor_regim', 'b1_mor_modes', 'b1_mor_perifrasis']);
SELECT pg_temp.seed_path('b1000000-0000-4000-8000-000000000003', 'intermedi', 3,
  'Ortografia i pronunciació del B1',
  'De l''elocució i les síl·labes a l''accentuació, l''apostrofació, les consonants i la puntuació.',
  ARRAY['b1_fon_elocucio', 'b1_fon_alfabet', 'b1_fon_sillaba', 'b1_fon_vocals', 'b1_fon_accentuacio', 'b1_fon_apostrofacio', 'b1_fon_oclusives', 'b1_fon_alveolars', 'b1_fon_palatals', 'b1_fon_laterals_h', 'b1_fon_majuscules', 'b1_fon_puntuacio']);
SELECT pg_temp.seed_path('b1000000-0000-4000-8000-000000000004', 'intermedi', 4,
  'Vocabulari per a la vida diària',
  'Cada tema, primer el vocabulari i després una conversa per a fer-lo servir: casa, viatges, salut, tràmits i treball.',
  ARRAY['b1_vocab_vida_quotidiana', 'b1_vida_quotidiana', 'b1_vocab_llocs', 'b1_llocs', 'b1_vocab_viatges', 'b1_viatges', 'b1_vocab_salut', 'b1_salut', 'b1_vocab_administracio', 'b1_administracio', 'b1_vocab_treball', 'b1_treball']);
SELECT pg_temp.seed_path('b1000000-0000-4000-8000-000000000005', 'intermedi', 5,
  'Comprensió oral i escrita',
  'Escoltar i llegir, alternant: converses, avisos, premsa, ficció, debats i xarrades.',
  ARRAY['b1_co_converses', 'b1_ce_correspondencia', 'b1_co_avisos', 'b1_ce_instruccions', 'b1_co_mitjans', 'b1_ce_premsa', 'b1_co_ficcio', 'b1_ce_dialogats', 'b1_co_debat', 'b1_ce_opinio', 'b1_co_xarrada', 'b1_ce_documents']);
SELECT pg_temp.seed_path('b1000000-0000-4000-8000-000000000006', 'intermedi', 6,
  'Conversa en situacions reals',
  'Parlar de tu, del teu temps lliure i del territori, resoldre imprevistos, opinar i fer una exposició.',
  ARRAY['b1_relacions', 'b1_eo_experiencies', 'b1_oci_esport', 'b1_eo_imprevistos', 'b1_territori', 'b1_eo_mediacio', 'b1_cultura', 'b1_eo_opinio', 'b1_natura_clima', 'b1_eo_exposicio']);
SELECT pg_temp.seed_path('b1000000-0000-4000-8000-000000000007', 'intermedi', 7,
  'Preparar l''examen B1',
  'Connectors i modes verbals, les tasques d''expressió escrita i oral més difícils i els simulacres de la JQCV.',
  ARRAY['b1_mor_connectors', 'b1_mor_modes', 'b1_ee_formal', 'b1_ee_parafrasi', 'b1_ee_apunts', 'b1_eo_opinio', 'jqcv_b1_oct2024', 'jqcv_b1_oct2025', 'jqcv_b1_jun2026']);
