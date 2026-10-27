-- Migració agrupada: 20261007200000_professorat_i_nivells
-- Conté, per ordre, les 8 migracions originals següents:
--   20261007200000_rol_professor
--   20261007210000_dades_sensibles_al_client
--   20261007220000_llengua_materna_nomes_nivell0
--   20261007225000_rutes_predefinides
--   20261007230000_activitats_professorat
--   20261007235000_nivells_classe
--   20261008100000_nivells_mecr
--   20261013100000_nivells_mecr_perfil

-- ============================================================
-- Origen: 20261007200000_rol_professor.sql
-- ============================================================
-- Rol de professorat: només els perfils amb role = 'teacher' poden crear classes.
--   * El rol no es tria en crear el compte: l'assigna un administrador (SQL Editor / Studio
--     o el backend amb la service_role). Exemple:
--       UPDATE public.profiles SET role = 'teacher'
--       WHERE id = (SELECT id FROM auth.users WHERE email = 'docent@exemple.com');
--   * La política "own profile" deixa que cada usuari actualitze la seua fila: el trigger
--     de baix impedix que, des de l'app (anon/authenticated), algú es canvie el rol.

ALTER TABLE public.profiles DROP CONSTRAINT IF EXISTS profiles_role_check;
ALTER TABLE public.profiles
  ADD CONSTRAINT profiles_role_check CHECK (role = ANY (ARRAY['admin'::text, 'teacher'::text, 'user'::text]));

-- Qui ja havia creat classes passa a ser docent, perquè no perda l'accés a les seues classes.
UPDATE public.profiles p
SET role = 'teacher'
WHERE p.role = 'user' AND EXISTS (SELECT 1 FROM public.kids_classes c WHERE c.teacher_id = p.id);

CREATE OR REPLACE FUNCTION public.profiles_protect_role()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = public
AS $$
BEGIN
  -- Només les peticions de l'app (amb JWT d'usuari) estan limitades; la service_role,
  -- el trigger de registre i l'SQL Editor poden assignar el rol.
  IF coalesce(auth.role(), '') NOT IN ('anon', 'authenticated') THEN
    RETURN NEW;
  END IF;
  IF TG_OP = 'INSERT' THEN
    NEW.role := 'user';
  ELSIF NEW.role IS DISTINCT FROM OLD.role THEN
    RAISE EXCEPTION 'No es pot canviar el rol del perfil' USING ERRCODE = '42501';
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS profiles_protect_role ON public.profiles;
CREATE TRIGGER profiles_protect_role
  BEFORE INSERT OR UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.profiles_protect_role();

-- Crea una classe (només el professorat) amb un codi nou.
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
  IF (SELECT role FROM profiles WHERE id = uid) IS DISTINCT FROM 'teacher' THEN
    RAISE EXCEPTION 'Només el professorat pot crear classes' USING ERRCODE = '42501';
  END IF;
  IF char_length(trim(coalesce(p_name, ''))) NOT BETWEEN 1 AND 60 THEN
    RAISE EXCEPTION 'El nom de la classe ha de tindre entre 1 i 60 caràcters' USING ERRCODE = '22023';
  END IF;
  LOOP
    new_code := (SELECT string_agg(substr(alphabet, 1 + floor(random() * length(alphabet))::int, 1), '') FROM generate_series(1, 6));
    BEGIN
      INSERT INTO kids_classes (teacher_id, name, code) VALUES (uid, trim(p_name), new_code) RETURNING * INTO created;
      RETURN created;
    EXCEPTION WHEN unique_violation THEN
      -- Codi repetit: se'n prova un altre.
    END;
  END LOOP;
END;
$$;

-- ============================================================
-- Origen: 20261007210000_dades_sensibles_al_client.sql
-- ============================================================
-- Les dades que pot escriure l'usuari (i, per tant, poden ser sensibles) ja no es guarden al
-- servidor: viuen en el navegador de l'usuari (IndexedDB, frontend/src/lib/localStore.ts).
--   * conversation_messages: els missatges de les converses. El client envia l'historial en
--     cada torn i el servidor el fa servir sense guardar-lo.
--   * user_errors: es queda només amb les metadades (categoria, origen, resolt...). La frase
--     de l'usuari, la correcció, l'explicació i el context van al client amb el mateix id.
--   * user_evaluations: es queda només amb el priority_focus (una categoria d'error), que fa
--     servir la ruta d'aprenentatge. El resum i els punts febles van al client.
--   * session_resource: el títol de les converses amb el tutor (resum del LLM o nom posat per
--     l'usuari) passa al client.
-- Les dades que hi havia es perden: no es poden moure al navegador de cada usuari.

DROP TABLE IF EXISTS public.conversation_messages CASCADE;

ALTER TABLE public.user_errors
  DROP COLUMN IF EXISTS message_id,
  DROP COLUMN IF EXISTS error_text,
  DROP COLUMN IF EXISTS correction,
  DROP COLUMN IF EXISTS explanation,
  DROP COLUMN IF EXISTS context;

ALTER TABLE public.user_evaluations
  DROP COLUMN IF EXISTS summary,
  DROP COLUMN IF EXISTS weaknesses;

ALTER TABLE public.session_resource
  DROP CONSTRAINT IF EXISTS session_resource_title_length_check,
  DROP CONSTRAINT IF EXISTS session_resource_title_source_check,
  DROP COLUMN IF EXISTS title,
  DROP COLUMN IF EXISTS title_source,
  DROP COLUMN IF EXISTS title_message_count;

-- ============================================================
-- Origen: 20261007220000_llengua_materna_nomes_nivell0.sql
-- ============================================================
-- La llengua materna només es demana i es guarda als comptes de xiquets i als d'adults del Nivell 0
-- (és per a l'ajuda amb traducció d'eixe nivell). Els adults dels altres nivells no en guarden.
--
-- Esta versió de handle_new_user() també recupera el Nivell 0 per a adults (20261005170000), que
-- 20261005185000 havia perdut en redefinir la funció: un adult que triava el Nivell 0 acabava en
-- «principiant». La llengua passa a 'other' si no és de les triables (com en 20261005185000).
-- Tornar a aplicar el fitxer no canvia res (create or replace).

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  initial_level learner_level;
  tongue text;
  group_of_age text;
begin
  group_of_age := case new.raw_user_meta_data ->> 'age_group' when 'child' then 'child' else 'adult' end;

  -- Els xiquets sempre comencen en el Nivell 0; els adults el poden triar com els altres nivells.
  initial_level := case
    when group_of_age = 'child' then 'nivell0'::learner_level
    else case new.raw_user_meta_data ->> 'level'
      when 'nivell0' then 'nivell0'::learner_level
      when 'intermedi' then 'intermedi'::learner_level
      when 'avancat' then 'avancat'::learner_level
      else 'principiant'::learner_level
    end
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
$$;

-- ============================================================
-- Origen: 20261007225000_rutes_predefinides.sql
-- ============================================================
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

-- ============================================================
-- Origen: 20261007230000_activitats_professorat.sql
-- ============================================================
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

-- ============================================================
-- Origen: 20261007235000_nivells_classe.sql
-- ============================================================
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

-- ============================================================
-- Origen: 20261008100000_nivells_mecr.sql
-- ============================================================
-- Nivells de les classes i de les activitats del professorat segons el MECR (A1, A2, B1, B2, C1,
-- C2). Una classe és d'un nivell o de dos de contigus; el Nivell 0 (infantil) és una classe a banda,
-- sense activitats ni rutes del professorat (és massa bàsic).
-- El perfil de l'alumnat continua amb els nivells de l'app, que cobrixen dos nivells del MECR:
-- principiant = A1-A2, intermedi = B1-B2, avancat = C1-C2. Un alumne pot entrar en una classe si
-- algun dels nivells de la classe és dels seus.

CREATE OR REPLACE FUNCTION public.cefr_of(p text)
RETURNS text[]
LANGUAGE sql
IMMUTABLE
AS $$
  SELECT CASE p
    WHEN 'nivell0' THEN ARRAY['nivell0']
    WHEN 'principiant' THEN ARRAY['A1', 'A2']
    WHEN 'intermedi' THEN ARRAY['B1', 'B2']
    WHEN 'avancat' THEN ARRAY['C1', 'C2']
    ELSE ARRAY[]::text[]
  END;
$$;

CREATE OR REPLACE FUNCTION public.valid_class_levels(p text[])
RETURNS boolean
LANGUAGE sql
IMMUTABLE
AS $$
  SELECT p IS NOT NULL AND (
    p = ARRAY['nivell0']
    OR (cardinality(p) BETWEEN 1 AND 2
        AND p <@ ARRAY['A1', 'A2', 'B1', 'B2', 'C1', 'C2']
        AND (cardinality(p) = 1 OR array_position(ARRAY['A1', 'A2', 'B1', 'B2', 'C1', 'C2'], p[2])
                                   - array_position(ARRAY['A1', 'A2', 'B1', 'B2', 'C1', 'C2'], p[1]) = 1))
  );
$$;

CREATE OR REPLACE FUNCTION public.level_label(p text)
RETURNS text
LANGUAGE sql
IMMUTABLE
AS $$
  SELECT CASE p WHEN 'nivell0' THEN 'Nivell 0' WHEN 'principiant' THEN 'A1-A2' WHEN 'intermedi' THEN 'B1-B2' WHEN 'avancat' THEN 'C1-C2' ELSE p END;
$$;

-- Classes que ja hi havia: dels nivells de l'app als del MECR.
ALTER TABLE public.kids_classes DROP CONSTRAINT IF EXISTS kids_classes_levels_check;
UPDATE public.kids_classes SET levels = CASE
  WHEN levels = ARRAY['nivell0'] OR levels && ARRAY['nivell0'] THEN ARRAY['nivell0']
  WHEN levels = ARRAY['principiant'] THEN ARRAY['A1', 'A2']
  WHEN levels = ARRAY['intermedi'] THEN ARRAY['B1', 'B2']
  WHEN levels = ARRAY['avancat'] THEN ARRAY['C1', 'C2']
  WHEN levels = ARRAY['principiant', 'intermedi'] THEN ARRAY['A2', 'B1']
  WHEN levels = ARRAY['intermedi', 'avancat'] THEN ARRAY['B2', 'C1']
  ELSE levels
END
WHERE NOT (levels <@ ARRAY['A1', 'A2', 'B1', 'B2', 'C1', 'C2']);
ALTER TABLE public.kids_classes ADD CONSTRAINT kids_classes_levels_check CHECK (public.valid_class_levels(levels));

-- Les activitats del professorat guarden el seu nivell del MECR en metadata.cefr_level
-- (resources.difficulty continua sent el nivell de l'app). Les que ja hi havia eren A2 o B1.
UPDATE public.resources
SET metadata = jsonb_set(metadata, '{cefr_level}', to_jsonb(CASE difficulty::text WHEN 'principiant' THEN 'A2' WHEN 'intermedi' THEN 'B1' ELSE 'C1' END))
WHERE teacher_id IS NOT NULL AND NOT (metadata ? 'cefr_level');

-- Les classes del Nivell 0 no tenen activitats soltes: es lleven les que s'hi hagueren assignat.
DELETE FROM public.teacher_activity_classes t
USING public.kids_classes c
WHERE c.id = t.class_id AND c.levels = ARRAY['nivell0'];

-- Crea una classe (només el professorat): el Nivell 0, o un o dos nivells contigus del MECR.
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
  SELECT array_agg(l ORDER BY array_position(ARRAY['nivell0', 'A1', 'A2', 'B1', 'B2', 'C1', 'C2'], l))
  INTO levels FROM (SELECT DISTINCT unnest(p_levels) AS l) x;
  IF NOT valid_class_levels(levels) THEN
    RAISE EXCEPTION 'Tria el Nivell 0, o un nivell o dos de contigus (A1-C2)' USING ERRCODE = '22023';
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

-- Unix l'usuari a la classe d'este codi si algun dels nivells de la classe és dels seus.
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
  IF NOT (cefr_of(student_level) && found.levels) THEN
    RAISE EXCEPTION 'Esta classe és per a alumnat de %, i el teu nivell és %',
      (SELECT string_agg(level_label(l), ' i ') FROM unnest(found.levels) l), level_label(student_level)
      USING ERRCODE = '42501';
  END IF;
  INSERT INTO kids_class_members (class_id, student_id) VALUES (found.id, uid) ON CONFLICT DO NOTHING;
  RETURN QUERY SELECT found.id, found.name;
END;
$$;

-- Les rutes d'una classe han de ser d'un nivell de l'app que cobrisca algun dels de la classe.
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

-- ============================================================
-- Origen: 20261013100000_nivells_mecr_perfil.sql
-- ============================================================
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


-- ============================================================
-- Docent per defecte: user_profe / @parlaval12@
-- ============================================================
-- Compte inicial amb rol de professorat per a poder crear classes des del primer arranc.
-- Com fa l'app, el nom d'usuari es lliga a una adreça fictícia (@usuaris.parlaval.invalid).
-- El trigger on_auth_user_created en crea el perfil; després se li dona el rol de docent.
-- Canvieu-ne la contrasenya en un desplegament real.
DO $seed$
DECLARE
  teacher_email constant text := 'user_profe@usuaris.parlaval.invalid';
  uid uuid;
BEGIN
  IF EXISTS (SELECT 1 FROM auth.users WHERE email = teacher_email) THEN
    RETURN;
  END IF;

  uid := gen_random_uuid();
  INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
    confirmation_token, recovery_token, email_change_token_new, email_change
  ) VALUES (
    '00000000-0000-0000-0000-000000000000', uid, 'authenticated', 'authenticated', teacher_email,
    extensions.crypt('@parlaval12@', extensions.gen_salt('bf', 10)), now(),
    '{"provider": "email", "providers": ["email"]}',
    '{"age_group": "adult", "display_name": "user_profe", "email_verified": true}',
    now(), now(), '', '', '', ''
  );

  INSERT INTO auth.identities (provider_id, user_id, identity_data, provider, created_at, updated_at)
  VALUES (
    uid::text, uid,
    jsonb_build_object('sub', uid::text, 'email', teacher_email, 'email_verified', false, 'phone_verified', false),
    'email', now(), now()
  );

  UPDATE public.profiles SET role = 'teacher' WHERE id = uid;
END
$seed$;
