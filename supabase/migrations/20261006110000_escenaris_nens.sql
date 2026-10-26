-- Migració agrupada: 20261006110000_escenaris_nens
-- Conté, per ordre, les 14 migracions originals següents:
--   20261006110000_escenari_nens_pocio
--   20261006120000_escenari_nens_pocio_background
--   20261006130000_escenari_nens_pocio_translations
--   20261006140000_escenari_nens_pocio_sense_nom
--   20261006150000_escenari_nens_pocio_audio
--   20261006160000_seguiment_nivell0
--   20261006170000_pin_familia
--   20261006180000_converses_nivell0
--   20261006190000_escenari_nens_zoo
--   20261006200000_escenari_nens_zoo_background
--   20261006210000_escenari_nens_pati
--   20261006220000_escenari_nens_pati_background
--   20261006230000_escenari_nens_biblioteca
--   20261006240000_escenari_nens_biblioteca_background

-- ============================================================
-- Origen: 20261006110000_escenari_nens_pocio.sql
-- ============================================================
-- Escenari de conversa per a xiquets (Nivell 0): el mag Merlí prepara una poció màgica
-- i l'aprenent l'ajuda a triar els ingredients, a remenar-la i a posar-li un nom.
-- Recurs de la categoria 'escenari'; el `type` és la clau de la ruta del xat. Tornar a
-- aplicar el fitxer no el duplica (ON CONFLICT per id).

INSERT INTO public.resources (id, name, type, category, content, difficulty, xp_earned, sort_order, metadata)
VALUES (
  '7b3d5c1e-2f4a-4e8b-9a61-5d0c8e2f4b17',
  'El mag i la poció màgica',
  'n0_pocio',
  'escenari',
  'El mag Merlí està preparant una poció màgica al seu laboratori i necessita la teua ajuda per a triar els ingredients.',
  'nivell0',
  10,
  1,
  jsonb_build_object(
    'icon', '🧙',
    'color', '#D1C4E9',
    'bgIllustration', '#EDE7F6',
    'voice', 'lluc',
    'scenario', 'n0_pocio',
    'character', 'Merlí, el mag',
    'character_role', 'Mag',
    'section_name', 'El mag i la poció màgica',
    'initial_prompt', 'Hola, amic! Soc Merlí, el mag. Estic preparant una poció màgica, però em falten ingredients. M''ajudes?',
    'objectius', jsonb_build_array(
      'Saludar i dir el seu nom.',
      'Dir els colors i les coses de la poció (verd, roig, caldero, estrella, ou...).',
      'Comptar fins a cinc els ingredients.',
      'Dir què li agrada o què no li agrada de la poció.',
      'Posar nom a la poció.'
    ),
    'system_prompt',
      'Ets Merlí, un mag simpàtic i un poc despistat que prepara una poció màgica en el seu laboratori, amb un caldero, una cullera gran, una estrella, bolets, una rana i una ploma. ' ||
      'Parles amb un xiquet o una xiqueta de 6 a 12 anys que està aprenent valencià (Nivell 0). ' ||
      'Parla sempre en valencià molt senzill, amb les formes valencianes (xiquet, este, eixe, hui, vull), amb frases molt curtes (1 o 2 per torn) i paraules fàcils. ' ||
      'Fes sempre una sola pregunta xicoteta per torn i espera la resposta. ' ||
      'Guia la situació pas a pas: saluda i pregunta-li com es diu; demana-li que t''ajude a triar tres ingredients (pregunta pels colors i les coses: «La poció és verda o roja?», «Vols una rana o un bolet?»); ' ||
      'compteu junts els ingredients fins a cinc; remeneu la poció amb la cullera i pregunta-li si li agrada; i al final demana-li que li pose un nom a la poció. ' ||
      'Celebra cada resposta amb alegria («Molt bé!», «Fantàstic!»). Si no contesta, ofereix-li dues opcions perquè trie. ' ||
      'Si escriu en castellà o amb errades, repeteix la frase bé amb naturalitat i amb suavitat, sense fer-lo sentir malament, i anima''l a repetir-la. ' ||
      'Mai no ixes del personatge ni fas lliçons de gramàtica. La poció és sempre de mentida i inofensiva (la poció fa coses divertides: fa riure, fa créixer flors, fa volar un ratolí); mai no beu ningú res, ni parles de coses de por, violència o perill. ' ||
      'No demanes ni acceptes dades personals (cognoms, adreça, telèfon, escola). Si el xiquet conta que algú li fa mal o que està en perill, digues-li que ho conte ara mateix a una persona adulta de confiança. ' ||
      'Quan haja complit els objectius (saludar, dir colors i coses, comptar fins a cinc, dir què li agrada i posar-li nom a la poció), tanca la situació amb naturalitat i acomiada''t.'
  )
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  type = EXCLUDED.type,
  category = EXCLUDED.category,
  content = EXCLUDED.content,
  difficulty = EXCLUDED.difficulty,
  xp_earned = EXCLUDED.xp_earned,
  sort_order = EXCLUDED.sort_order,
  metadata = EXCLUDED.metadata;

-- ============================================================
-- Origen: 20261006120000_escenari_nens_pocio_background.sql
-- ============================================================
-- Foto de fons (resources.metadata.background) de l'escenari infantil del mag i la poció
-- (la imatge és a frontend/public/images/). Tornar a aplicar el fitxer no canvia res
-- (és un UPDATE idempotent).

UPDATE public.resources
SET metadata = jsonb_set(metadata, '{background}', to_jsonb('/images/mago.jpg'::text), true)
WHERE category = 'escenari' AND type = 'n0_pocio';

-- ============================================================
-- Origen: 20261006130000_escenari_nens_pocio_translations.sql
-- ============================================================
-- Traduccions de l'escenari infantil del mag i la poció (resources.metadata.translations) a
-- les llengües maternes amb subtítols: resum de la situació (content), objectius i primera
-- frase del personatge. El xat les mostra davall del valencià si el perfil té activada la
-- llengua materna. Tornar a aplicar el fitxer no canvia res (és un UPDATE idempotent).

UPDATE public.resources
SET metadata = jsonb_set(metadata, '{translations}', $json$
{
  "es": {
    "content": "El mago Merlí está preparando una poción mágica en su laboratorio y necesita tu ayuda para elegir los ingredientes.",
    "initial_prompt": "¡Hola, amigo! Soy Merlí, el mago. Estoy preparando una poción mágica, pero me faltan ingredientes. ¿Me ayudas?",
    "objectius": [
      "Saludar y decir su nombre.",
      "Decir los colores y las cosas de la poción (verde, rojo, caldero, estrella, huevo...).",
      "Contar hasta cinco los ingredientes.",
      "Decir qué le gusta o qué no le gusta de la poción.",
      "Ponerle nombre a la poción."
    ]
  },
  "en": {
    "content": "Merlí the wizard is making a magic potion in his lab and needs your help to choose the ingredients.",
    "initial_prompt": "Hello, friend! I'm Merlí, the wizard. I'm making a magic potion, but I'm missing some ingredients. Will you help me?",
    "objectius": [
      "Say hello and say your name.",
      "Say the colors and things in the potion (green, red, cauldron, star, egg...).",
      "Count the ingredients up to five.",
      "Say what you like or don't like about the potion.",
      "Give the potion a name."
    ]
  },
  "fr": {
    "content": "Le magicien Merlí prépare une potion magique dans son laboratoire et a besoin de ton aide pour choisir les ingrédients.",
    "initial_prompt": "Bonjour, mon ami ! Je suis Merlí, le magicien. Je prépare une potion magique, mais il me manque des ingrédients. Tu m'aides ?",
    "objectius": [
      "Dire bonjour et dire son prénom.",
      "Dire les couleurs et les choses de la potion (vert, rouge, chaudron, étoile, œuf...).",
      "Compter les ingrédients jusqu'à cinq.",
      "Dire ce qu'il aime ou n'aime pas dans la potion.",
      "Donner un nom à la potion."
    ]
  },
  "it": {
    "content": "Il mago Merlí sta preparando una pozione magica nel suo laboratorio e ha bisogno del tuo aiuto per scegliere gli ingredienti.",
    "initial_prompt": "Ciao, amico! Sono Merlí, il mago. Sto preparando una pozione magica, ma mi mancano degli ingredienti. Mi aiuti?",
    "objectius": [
      "Salutare e dire il proprio nome.",
      "Dire i colori e le cose della pozione (verde, rosso, calderone, stella, uovo...).",
      "Contare gli ingredienti fino a cinque.",
      "Dire cosa gli piace o non gli piace della pozione.",
      "Dare un nome alla pozione."
    ]
  },
  "ro": {
    "content": "Magicianul Merlí pregătește o poțiune magică în laboratorul lui și are nevoie de ajutorul tău ca să aleagă ingredientele.",
    "initial_prompt": "Salut, prietene! Sunt Merlí, magicianul. Pregătesc o poțiune magică, dar îmi lipsesc ingrediente. Mă ajuți?",
    "objectius": [
      "Să salute și să spună cum îl cheamă.",
      "Să spună culorile și lucrurile din poțiune (verde, roșu, căldare, stea, ou...).",
      "Să numere ingredientele până la cinci.",
      "Să spună ce îi place sau ce nu îi place la poțiune.",
      "Să dea un nume poțiunii."
    ]
  },
  "uk": {
    "content": "Чарівник Мерлі готує чарівне зілля у своїй лабораторії, і йому потрібна твоя допомога, щоб вибрати інгредієнти.",
    "initial_prompt": "Привіт, друже! Я Мерлі, чарівник. Я готую чарівне зілля, але мені бракує інгредієнтів. Допоможеш мені?",
    "objectius": [
      "Привітатися й сказати, як тебе звати.",
      "Назвати кольори й речі в зіллі (зелений, червоний, казан, зірка, яйце...).",
      "Порахувати інгредієнти до п'яти.",
      "Сказати, що тобі подобається або не подобається в зіллі.",
      "Дати зіллю назву."
    ]
  }
}
$json$::jsonb, true)
WHERE category = 'escenari' AND type = 'n0_pocio';

-- ============================================================
-- Origen: 20261006140000_escenari_nens_pocio_sense_nom.sql
-- ============================================================
-- Privacitat: en l'escenari infantil del mag i la poció el xiquet ja no ha de dir el seu nom.
-- Merlí només el saluda (no li ho pregunta ni repetix el nom si el diu) i el primer objectiu
-- passa de «Saludar i dir el seu nom» a «Saludar», també en les traduccions. Tornar a aplicar
-- el fitxer no canvia res (els reemplaços són idempotents).

UPDATE public.resources
SET metadata = jsonb_set(
  jsonb_set(
    metadata,
    '{system_prompt}',
    to_jsonb(
      replace(metadata ->> 'system_prompt', 'saluda i pregunta-li com es diu; demana-li', 'saluda''l sense preguntar-li com es diu; demana-li')
      || CASE WHEN metadata ->> 'system_prompt' LIKE '%No li preguntes mai el nom%' THEN ''
         ELSE ' PRIVACITAT: no li preguntes mai el nom ni cap dada personal; si ell diu el seu nom, no el repetisques ni l''useu: crida''l «amic» o «amiga».' END
    )
  ),
  '{objectius,0}', '"Saludar."'::jsonb
)
WHERE category = 'escenari' AND type = 'n0_pocio';

UPDATE public.resources
SET metadata = jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(metadata,
  '{translations,es,objectius,0}', '"Saludar."'),
  '{translations,en,objectius,0}', '"Say hello."'),
  '{translations,fr,objectius,0}', '"Dire bonjour."'),
  '{translations,it,objectius,0}', '"Salutare."'),
  '{translations,ro,objectius,0}', '"Să salute."'),
  '{translations,uk,objectius,0}', '"Привітатися."')
WHERE category = 'escenari' AND type = 'n0_pocio';

-- ============================================================
-- Origen: 20261006150000_escenari_nens_pocio_audio.sql
-- ============================================================
-- Salutació en àudio de l'escenari infantil del mag i la poció (resources.metadata.greeting_audio,
-- ruta dins de frontend/public). El fitxer es genera amb el TTS matxa:
-- `npx tsx scripts/generate-scenario-audio.ts` (a backend/). Si no existix, el xat demana l'àudio
-- al TTS com abans. Tornar a aplicar el fitxer no canvia res (és un UPDATE idempotent).

UPDATE public.resources
SET metadata = jsonb_set(metadata, '{greeting_audio}', to_jsonb('/audio/scenarios/n0_pocio-salutacio.wav'::text), true)
WHERE category = 'escenari' AND type = 'n0_pocio';

-- ============================================================
-- Origen: 20261006160000_seguiment_nivell0.sql
-- ============================================================
-- Seguiment del Nivell 0 per a la família i el professorat.
--   * kids_sessions: cada partida d'una illa (quina etapa, quantes rondes, quantes s'han
--     encertat a la primera, quants errors, si era en mode fàcil i quant ha durat).
--   * kids_word_stats: per a cada paraula (element) que s'ha preguntat, quantes vegades
--     s'ha preguntat i quantes ha costat: d'ací ix «ho domina» i «li costa».
--   * kids_classes / kids_class_members: classes del professorat. La docent crea una
--     classe i rep un codi; la família l'escriu en el seguiment del xiquet per a unir-s'hi.
--     La docent veu el seguiment (i el nom i les medalles del perfil) de qui hi és.
-- Les escriptures només es fan amb les funcions de baix (security definer), que validen
-- les dades i usen auth.uid(): ningú pot escriure en el seguiment d'un altre.

CREATE TABLE IF NOT EXISTS public.kids_sessions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  island text NOT NULL,
  -- L'etapa de l'illa (0, 1, 2...); null si era un repàs de l'illa ja acabada.
  stage smallint,
  rounds smallint NOT NULL CHECK (rounds > 0),
  first_try smallint NOT NULL CHECK (first_try >= 0 AND first_try <= rounds),
  misses smallint NOT NULL CHECK (misses >= 0),
  easy boolean NOT NULL DEFAULT false,
  seconds integer NOT NULL CHECK (seconds >= 0),
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_kids_sessions_user ON public.kids_sessions (user_id, created_at DESC);

CREATE TABLE IF NOT EXISTS public.kids_word_stats (
  user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  item_id text NOT NULL,
  word text NOT NULL,
  emoji text NOT NULL DEFAULT '',
  island text NOT NULL,
  attempts integer NOT NULL DEFAULT 0,
  misses integer NOT NULL DEFAULT 0,
  last_seen timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, item_id),
  CONSTRAINT kids_word_stats_misses_check CHECK (misses >= 0 AND misses <= attempts)
);

CREATE TABLE IF NOT EXISTS public.kids_classes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  teacher_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  name text NOT NULL CHECK (char_length(name) BETWEEN 1 AND 60),
  -- Sense lletres que es confonen (I, O) ni xifres semblants (0, 1).
  code text NOT NULL UNIQUE CHECK (code ~ '^[A-HJ-NP-Z2-9]{6}$'),
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_kids_classes_teacher ON public.kids_classes (teacher_id);

CREATE TABLE IF NOT EXISTS public.kids_class_members (
  class_id uuid NOT NULL REFERENCES public.kids_classes(id) ON DELETE CASCADE,
  student_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  joined_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (class_id, student_id)
);

CREATE INDEX IF NOT EXISTS idx_kids_class_members_student ON public.kids_class_members (student_id);

-- La persona que ha iniciat sessió és docent d'alguna classe d'este xiquet? (Sense RLS,
-- perquè les polítiques de profiles i del seguiment la puguen fer servir sense recursió.)
CREATE OR REPLACE FUNCTION public.is_teacher_of(student uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM kids_class_members m
    JOIN kids_classes c ON c.id = m.class_id
    WHERE m.student_id = student AND c.teacher_id = auth.uid()
  );
$$;

-- Les classes d'on és membre la persona que ha iniciat sessió (sense RLS, per la mateixa raó).
CREATE OR REPLACE FUNCTION public.is_member_of(class uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (SELECT 1 FROM kids_class_members WHERE class_id = class AND student_id = auth.uid());
$$;

ALTER TABLE public.kids_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.kids_word_stats ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.kids_classes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.kids_class_members ENABLE ROW LEVEL SECURITY;

CREATE POLICY "kids_sessions: own or teacher" ON public.kids_sessions
  FOR SELECT USING (user_id = auth.uid() OR public.is_teacher_of(user_id));

CREATE POLICY "kids_word_stats: own or teacher" ON public.kids_word_stats
  FOR SELECT USING (user_id = auth.uid() OR public.is_teacher_of(user_id));

CREATE POLICY "kids_classes: teacher or member reads" ON public.kids_classes
  FOR SELECT USING (teacher_id = auth.uid() OR public.is_member_of(id));
CREATE POLICY "kids_classes: teacher renames" ON public.kids_classes
  FOR UPDATE USING (teacher_id = auth.uid()) WITH CHECK (teacher_id = auth.uid());
CREATE POLICY "kids_classes: teacher deletes" ON public.kids_classes
  FOR DELETE USING (teacher_id = auth.uid());

CREATE POLICY "kids_class_members: student or teacher reads" ON public.kids_class_members
  FOR SELECT USING (
    student_id = auth.uid()
    OR EXISTS (SELECT 1 FROM public.kids_classes c WHERE c.id = class_id AND c.teacher_id = auth.uid())
  );
-- La família pot traure el xiquet d'una classe, i la docent pot traure'l de la seua.
CREATE POLICY "kids_class_members: student or teacher removes" ON public.kids_class_members
  FOR DELETE USING (
    student_id = auth.uid()
    OR EXISTS (SELECT 1 FROM public.kids_classes c WHERE c.id = class_id AND c.teacher_id = auth.uid())
  );

-- La docent veu el nom, el nivell i les medalles/cromos (badges) dels seus alumnes.
CREATE POLICY "profiles: teacher reads students" ON public.profiles
  FOR SELECT USING (public.is_teacher_of(id));

GRANT SELECT ON public.kids_sessions, public.kids_word_stats TO authenticated;
GRANT SELECT, UPDATE, DELETE ON public.kids_classes TO authenticated;
GRANT SELECT, DELETE ON public.kids_class_members TO authenticated;

-- Guarda una partida acabada i suma les paraules preguntades. p_words: [{id, word, emoji, missed}].
CREATE OR REPLACE FUNCTION public.kids_finish_session(
  p_island text, p_stage smallint, p_rounds smallint, p_first_try smallint, p_misses smallint,
  p_easy boolean, p_seconds integer, p_words jsonb
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  uid uuid := auth.uid();
BEGIN
  IF uid IS NULL THEN
    RAISE EXCEPTION 'Cal iniciar sessió' USING ERRCODE = '42501';
  END IF;
  IF p_island !~ '^[a-z0-9-]{1,40}$' OR p_rounds NOT BETWEEN 1 AND 40 OR p_first_try NOT BETWEEN 0 AND p_rounds
     OR p_misses NOT BETWEEN 0 AND 1000 OR jsonb_typeof(p_words) <> 'array' OR jsonb_array_length(p_words) > 80 THEN
    RAISE EXCEPTION 'Partida no vàlida' USING ERRCODE = '22023';
  END IF;

  INSERT INTO kids_sessions (user_id, island, stage, rounds, first_try, misses, easy, seconds)
  VALUES (uid, p_island, p_stage, p_rounds, p_first_try, p_misses, coalesce(p_easy, false), least(greatest(coalesce(p_seconds, 0), 0), 7200));

  -- Una fila per paraula (si apareix dues vegades en la partida, compta com a fallada si en alguna ha costat).
  INSERT INTO kids_word_stats AS s (user_id, item_id, word, emoji, island, attempts, misses, last_seen)
  SELECT uid, w.id, w.word, w.emoji, p_island, 1, CASE WHEN w.missed THEN 1 ELSE 0 END, now()
  FROM (
    SELECT DISTINCT ON (x ->> 'id')
      left(x ->> 'id', 80) AS id,
      left(coalesce(x ->> 'word', ''), 80) AS word,
      left(coalesce(x ->> 'emoji', ''), 24) AS emoji,
      coalesce((x ->> 'missed')::boolean, false) AS missed
    FROM jsonb_array_elements(p_words) AS x
    WHERE coalesce(x ->> 'id', '') <> '' AND coalesce(x ->> 'word', '') <> ''
    ORDER BY x ->> 'id', coalesce((x ->> 'missed')::boolean, false) DESC
  ) AS w
  ON CONFLICT (user_id, item_id) DO UPDATE SET
    attempts = s.attempts + 1,
    misses = s.misses + excluded.misses,
    word = excluded.word,
    emoji = excluded.emoji,
    island = excluded.island,
    last_seen = now();
END;
$$;

-- Crea una classe (només comptes d'adult) amb un codi nou.
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
  IF (SELECT age_group FROM profiles WHERE id = uid) IS DISTINCT FROM 'adult' THEN
    RAISE EXCEPTION 'Només les persones adultes poden crear classes' USING ERRCODE = '42501';
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

-- Unix el xiquet que ha iniciat sessió a la classe d'este codi. Torna la classe (id i nom).
CREATE OR REPLACE FUNCTION public.kids_join_class(p_code text)
RETURNS TABLE (id uuid, name text)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  uid uuid := auth.uid();
  found kids_classes;
BEGIN
  IF uid IS NULL THEN
    RAISE EXCEPTION 'Cal iniciar sessió' USING ERRCODE = '42501';
  END IF;
  SELECT * INTO found FROM kids_classes c WHERE c.code = upper(trim(coalesce(p_code, '')));
  IF found.id IS NULL THEN
    RAISE EXCEPTION 'No hi ha cap classe amb este codi' USING ERRCODE = 'P0002';
  END IF;
  INSERT INTO kids_class_members (class_id, student_id) VALUES (found.id, uid) ON CONFLICT DO NOTHING;
  RETURN QUERY SELECT found.id, found.name;
END;
$$;

REVOKE ALL ON FUNCTION public.kids_finish_session(text, smallint, smallint, smallint, smallint, boolean, integer, jsonb) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.kids_create_class(text) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.kids_join_class(text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.kids_finish_session(text, smallint, smallint, smallint, smallint, boolean, integer, jsonb) TO authenticated;
GRANT EXECUTE ON FUNCTION public.kids_create_class(text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.kids_join_class(text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_teacher_of(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_member_of(uuid) TO authenticated;

-- ============================================================
-- Origen: 20261006170000_pin_familia.sql
-- ============================================================
-- PIN de la família del Nivell 0: quatre xifres que tria la persona adulta en crear el
-- compte infantil i que protegixen el seguiment (que el xiquet no hi entre). Es guarda
-- només el hash (bcrypt) en una taula a banda, amb RLS i sense polítiques: ningú la pot
-- llegir (tampoc la docent, que sí que llig profiles); només s'hi accedix amb les funcions
-- de baix. Cinc errors seguits bloquegen cinc minuts. Si s'oblida, es canvia amb la
-- contrasenya del compte.

CREATE TABLE IF NOT EXISTS public.kids_parent_pins (
  user_id uuid PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
  pin_hash text NOT NULL,
  fails smallint NOT NULL DEFAULT 0,
  locked_until timestamptz,
  updated_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.kids_parent_pins ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.kids_parent_pins FROM anon, authenticated;

-- Té PIN el compte que ha iniciat sessió?
CREATE OR REPLACE FUNCTION public.kids_has_pin()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (SELECT 1 FROM kids_parent_pins WHERE user_id = auth.uid());
$$;

-- El primer PIN (en crear el compte o la primera vegada que s'entra al seguiment).
-- Si ja n'hi ha un, no el canvia: per a això cal kids_reset_pin amb la contrasenya.
CREATE OR REPLACE FUNCTION public.kids_set_pin(p_pin text)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Cal iniciar sessió' USING ERRCODE = '42501';
  END IF;
  IF coalesce(p_pin, '') !~ '^[0-9]{4}$' THEN
    RAISE EXCEPTION 'El PIN ha de tindre 4 xifres' USING ERRCODE = '22023';
  END IF;
  INSERT INTO kids_parent_pins (user_id, pin_hash) VALUES (auth.uid(), crypt(p_pin, gen_salt('bf')))
  ON CONFLICT (user_id) DO NOTHING;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Este compte ja té PIN' USING ERRCODE = '23505';
  END IF;
END;
$$;

-- Comprova el PIN. Torna {ok, locked_seconds, attempts_left}. No llança errors en fallar,
-- perquè el comptador d'intents s'ha de guardar.
CREATE OR REPLACE FUNCTION public.kids_check_pin(p_pin text)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
  saved kids_parent_pins;
BEGIN
  SELECT * INTO saved FROM kids_parent_pins WHERE user_id = auth.uid() FOR UPDATE;
  IF saved.user_id IS NULL THEN
    RETURN jsonb_build_object('ok', false, 'locked_seconds', 0, 'attempts_left', 0, 'missing', true);
  END IF;
  IF saved.locked_until > now() THEN
    RETURN jsonb_build_object('ok', false, 'locked_seconds', ceil(extract(epoch FROM saved.locked_until - now())), 'attempts_left', 0);
  END IF;
  IF crypt(coalesce(p_pin, ''), saved.pin_hash) = saved.pin_hash THEN
    UPDATE kids_parent_pins SET fails = 0, locked_until = NULL WHERE user_id = saved.user_id;
    RETURN jsonb_build_object('ok', true, 'locked_seconds', 0, 'attempts_left', 5);
  END IF;
  IF saved.fails + 1 >= 5 THEN
    UPDATE kids_parent_pins SET fails = 0, locked_until = now() + interval '5 minutes' WHERE user_id = saved.user_id;
    RETURN jsonb_build_object('ok', false, 'locked_seconds', 300, 'attempts_left', 0);
  END IF;
  UPDATE kids_parent_pins SET fails = saved.fails + 1 WHERE user_id = saved.user_id;
  RETURN jsonb_build_object('ok', false, 'locked_seconds', 0, 'attempts_left', 5 - (saved.fails + 1));
END;
$$;

-- PIN oblidat: un PIN nou amb la contrasenya del compte (compta per als intents i el bloqueig).
CREATE OR REPLACE FUNCTION public.kids_reset_pin(p_password text, p_pin text)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
  uid uuid := auth.uid();
  saved kids_parent_pins;
  stored text;
BEGIN
  IF uid IS NULL THEN
    RAISE EXCEPTION 'Cal iniciar sessió' USING ERRCODE = '42501';
  END IF;
  IF coalesce(p_pin, '') !~ '^[0-9]{4}$' THEN
    RAISE EXCEPTION 'El PIN ha de tindre 4 xifres' USING ERRCODE = '22023';
  END IF;
  SELECT * INTO saved FROM kids_parent_pins WHERE user_id = uid FOR UPDATE;
  IF saved.locked_until > now() THEN
    RETURN jsonb_build_object('ok', false, 'locked_seconds', ceil(extract(epoch FROM saved.locked_until - now())));
  END IF;
  SELECT encrypted_password INTO stored FROM auth.users WHERE id = uid;
  IF stored IS NULL OR crypt(coalesce(p_password, ''), stored) <> stored THEN
    IF saved.user_id IS NOT NULL THEN
      UPDATE kids_parent_pins
      SET fails = CASE WHEN saved.fails + 1 >= 5 THEN 0 ELSE saved.fails + 1 END,
          locked_until = CASE WHEN saved.fails + 1 >= 5 THEN now() + interval '5 minutes' END
      WHERE user_id = uid;
    END IF;
    RETURN jsonb_build_object('ok', false, 'locked_seconds', 0);
  END IF;
  INSERT INTO kids_parent_pins (user_id, pin_hash) VALUES (uid, crypt(p_pin, gen_salt('bf')))
  ON CONFLICT (user_id) DO UPDATE SET pin_hash = excluded.pin_hash, fails = 0, locked_until = NULL, updated_at = now();
  RETURN jsonb_build_object('ok', true, 'locked_seconds', 0);
END;
$$;

REVOKE ALL ON FUNCTION public.kids_has_pin() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.kids_set_pin(text) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.kids_check_pin(text) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.kids_reset_pin(text, text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.kids_has_pin() TO authenticated;
GRANT EXECUTE ON FUNCTION public.kids_set_pin(text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.kids_check_pin(text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.kids_reset_pin(text, text) TO authenticated;

-- ============================================================
-- Origen: 20261006180000_converses_nivell0.sql
-- ============================================================
-- Converses del Nivell 0 (escenaris com «El mag i la poció màgica») per al seguiment de la
-- família i del professorat. En el Nivell 0 no es guarden errors gramaticals de la conversa:
-- en acabar-la, el LLM només revisa quins objectius de l'escenari ha complit el xiquet.
-- Una fila per conversa (session_resource). L'escriu el backend (clau de servei); la llig
-- el mateix xiquet i la seua docent, com la resta del seguiment (is_teacher_of).

CREATE TABLE IF NOT EXISTS public.kids_scenario_reviews (
  session_resource_id uuid PRIMARY KEY REFERENCES public.session_resource(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  resource_id uuid NOT NULL REFERENCES public.resources(id) ON DELETE CASCADE,
  scenario_name text NOT NULL,
  -- [{ "text": "Comptar fins a cinc els ingredients.", "met": true }]; met és null si no s'ha pogut revisar.
  objectives jsonb NOT NULL DEFAULT '[]',
  turns smallint NOT NULL DEFAULT 0 CHECK (turns >= 0),
  seconds integer NOT NULL DEFAULT 0 CHECK (seconds >= 0),
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_kids_scenario_reviews_user ON public.kids_scenario_reviews (user_id, created_at DESC);

ALTER TABLE public.kids_scenario_reviews ENABLE ROW LEVEL SECURITY;

CREATE POLICY "kids_scenario_reviews: own or teacher" ON public.kids_scenario_reviews
  FOR SELECT USING (user_id = auth.uid() OR public.is_teacher_of(user_id));

REVOKE ALL ON public.kids_scenario_reviews FROM anon;
GRANT SELECT ON public.kids_scenario_reviews TO authenticated;

-- ============================================================
-- Origen: 20261006190000_escenari_nens_zoo.sql
-- ============================================================
-- Escenari de conversa per a xiquets (Nivell 0): Carme, la cuidadora del zoo, dona de
-- menjar als animals i l'aprenent l'ajuda a dir-ne els noms, els colors i què mengen.
-- Recurs de la categoria 'escenari'; el `type` és la clau de la ruta del xat. Inclou les
-- traduccions (metadata.translations) per als subtítols de la llengua materna i la
-- salutació en àudio (metadata.greeting_audio, es genera amb
-- `npx tsx scripts/generate-scenario-audio.ts` a backend/). Privacitat: no se li pregunta
-- el nom al xiquet. Tornar a aplicar el fitxer no el duplica (ON CONFLICT per id).

INSERT INTO public.resources (id, name, type, category, content, difficulty, xp_earned, sort_order, metadata)
VALUES (
  '3c9f6a2d-8b14-4d7e-a5c3-1e72b0d94f58',
  'La cuidadora del zoo',
  'n0_zoo',
  'escenari',
  'Carme, la cuidadora del zoo, ha de donar de menjar als animals i necessita la teua ajuda.',
  'nivell0',
  10,
  2,
  jsonb_build_object(
    'icon', '🦁',
    'color', '#C8E6C9',
    'bgIllustration', '#E8F5E9',
    'voice', 'gina',
    'scenario', 'n0_zoo',
    'character', 'Carme, la cuidadora del zoo',
    'character_role', 'Cuidadora del zoo',
    'section_name', 'La cuidadora del zoo',
    'initial_prompt', 'Hola, amic! Soc Carme, la cuidadora del zoo. Hui hi ha molta faena: els animals tenen fam. M''ajudes?',
    'greeting_audio', '/audio/scenarios/n0_zoo-salutacio.wav',
    'objectius', jsonb_build_array(
      'Saludar.',
      'Dir els noms dels animals (lleó, elefant, mico, girafa, pingüí...).',
      'Dir els colors dels animals i si són grans o xicotets.',
      'Comptar fins a cinc els animals.',
      'Dir quin animal li agrada més i què menja.'
    ),
    'system_prompt',
      'Ets Carme, una cuidadora de zoo alegre i molt amable. Estàs al zoo donant de menjar als animals amb un carretó ple de fruita, verdura i peix: hi ha un lleó, un elefant, un mico, una girafa i un pingüí. ' ||
      'Parles amb un xiquet o una xiqueta de 6 a 12 anys que està aprenent valencià (Nivell 0). ' ||
      'Parla sempre en valencià molt senzill, amb les formes valencianes (xiquet, este, eixe, hui, vull), amb frases molt curtes (1 o 2 per torn) i paraules fàcils. ' ||
      'Fes sempre una sola pregunta xicoteta per torn i espera la resposta. ' ||
      'Guia la situació pas a pas: saluda''l sense preguntar-li com es diu i pregunta-li quin animal vol veure primer; demana-li que t''ajude a dir el nom de cada animal que apareix; ' ||
      'pregunta pel color i la mida («El lleó és groc o blau?», «L''elefant és gran o xicotet?»); compteu junts els animals fins a cinc; ' ||
      'pregunta-li què creu que menja cada animal («El mico menja plàtans o peix?») i, al final, quin animal li agrada més. ' ||
      'Celebra cada resposta amb alegria («Molt bé!», «Fantàstic!»). Si no contesta, ofereix-li dues opcions perquè trie. ' ||
      'Si escriu en castellà o amb errades, repeteix la frase bé amb naturalitat i amb suavitat, sense fer-lo sentir malament, i anima''l a repetir-la. ' ||
      'Mai no ixes del personatge ni fas lliçons de gramàtica. Tots els animals són simpàtics i tranquils; mai no parles de por, de mossegades, de violència ni de perill, i el xiquet no entra mai als recintes: només mira i ajuda a repartir el menjar des del carretó. ' ||
      'PRIVACITAT: no li preguntes mai el nom ni cap dada personal (cognoms, adreça, telèfon, escola); si ell diu el seu nom, no el repetisques ni l''useu: crida''l «amic» o «amiga». ' ||
      'Si el xiquet conta que algú li fa mal o que està en perill, digues-li que ho conte ara mateix a una persona adulta de confiança. ' ||
      'Quan haja complit els objectius (saludar, dir noms, colors i mides dels animals, comptar fins a cinc i dir quin li agrada i què menja), tanca la situació amb naturalitat i acomiada''t.',
    'translations', $json$
    {
      "es": {
        "content": "Carme, la cuidadora del zoo, tiene que dar de comer a los animales y necesita tu ayuda.",
        "initial_prompt": "¡Hola, amigo! Soy Carme, la cuidadora del zoo. Hoy hay mucho trabajo: los animales tienen hambre. ¿Me ayudas?",
        "objectius": [
          "Saludar.",
          "Decir los nombres de los animales (león, elefante, mono, jirafa, pingüino...).",
          "Decir los colores de los animales y si son grandes o pequeños.",
          "Contar hasta cinco los animales.",
          "Decir qué animal le gusta más y qué come."
        ]
      },
      "en": {
        "content": "Carme, the zookeeper, has to feed the animals and needs your help.",
        "initial_prompt": "Hello, friend! I'm Carme, the zookeeper. There's a lot to do today: the animals are hungry. Will you help me?",
        "objectius": [
          "Say hello.",
          "Say the names of the animals (lion, elephant, monkey, giraffe, penguin...).",
          "Say the colors of the animals and whether they are big or small.",
          "Count the animals up to five.",
          "Say which animal you like best and what it eats."
        ]
      },
      "fr": {
        "content": "Carme, la gardienne du zoo, doit nourrir les animaux et a besoin de ton aide.",
        "initial_prompt": "Bonjour, mon ami ! Je suis Carme, la gardienne du zoo. Aujourd'hui, il y a beaucoup de travail : les animaux ont faim. Tu m'aides ?",
        "objectius": [
          "Dire bonjour.",
          "Dire les noms des animaux (lion, éléphant, singe, girafe, pingouin...).",
          "Dire les couleurs des animaux et s'ils sont grands ou petits.",
          "Compter les animaux jusqu'à cinq.",
          "Dire quel animal on aime le plus et ce qu'il mange."
        ]
      },
      "it": {
        "content": "Carme, la guardiana dello zoo, deve dare da mangiare agli animali e ha bisogno del tuo aiuto.",
        "initial_prompt": "Ciao, amico! Sono Carme, la guardiana dello zoo. Oggi c'è molto da fare: gli animali hanno fame. Mi aiuti?",
        "objectius": [
          "Salutare.",
          "Dire i nomi degli animali (leone, elefante, scimmia, giraffa, pinguino...).",
          "Dire i colori degli animali e se sono grandi o piccoli.",
          "Contare gli animali fino a cinque.",
          "Dire quale animale piace di più e cosa mangia."
        ]
      },
      "ro": {
        "content": "Carme, îngrijitoarea de la grădina zoologică, trebuie să dea de mâncare animalelor și are nevoie de ajutorul tău.",
        "initial_prompt": "Salut, prietene! Sunt Carme, îngrijitoarea de la grădina zoologică. Azi am mult de lucru: animalele sunt flămânde. Mă ajuți?",
        "objectius": [
          "Să salute.",
          "Să spună numele animalelor (leu, elefant, maimuță, girafă, pinguin...).",
          "Să spună culorile animalelor și dacă sunt mari sau mici.",
          "Să numere animalele până la cinci.",
          "Să spună ce animal îi place cel mai mult și ce mănâncă."
        ]
      },
      "uk": {
        "content": "Карме, доглядачка зоопарку, має нагодувати тварин, і їй потрібна твоя допомога.",
        "initial_prompt": "Привіт, друже! Я Карме, доглядачка зоопарку. Сьогодні багато роботи: тварини голодні. Допоможеш мені?",
        "objectius": [
          "Привітатися.",
          "Назвати тварин (лев, слон, мавпа, жирафа, пінгвін...).",
          "Назвати кольори тварин і сказати, великі вони чи маленькі.",
          "Порахувати тварин до п'яти.",
          "Сказати, яка тварина подобається найбільше і що вона їсть."
        ]
      }
    }
    $json$::jsonb
  )
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  type = EXCLUDED.type,
  category = EXCLUDED.category,
  content = EXCLUDED.content,
  difficulty = EXCLUDED.difficulty,
  xp_earned = EXCLUDED.xp_earned,
  sort_order = EXCLUDED.sort_order,
  metadata = EXCLUDED.metadata;

-- ============================================================
-- Origen: 20261006200000_escenari_nens_zoo_background.sql
-- ============================================================
-- Foto de fons (resources.metadata.background) de l'escenari infantil de la cuidadora del zoo
-- (la imatge és a frontend/public/images/). Tornar a aplicar el fitxer no canvia res
-- (és un UPDATE idempotent).

UPDATE public.resources
SET metadata = jsonb_set(metadata, '{background}', to_jsonb('/images/zoo.jpg'::text), true)
WHERE category = 'escenari' AND type = 'n0_zoo';

-- ============================================================
-- Origen: 20261006210000_escenari_nens_pati.sql
-- ============================================================
-- Escenari de conversa per a xiquets (Nivell 0): Laia, una xiqueta de l'escola, vol fer
-- alguna cosa a l'hora del pati (esmorzar, jugar a futbol, saltar a corda, pillar...) i
-- l'aprenent l'ajuda a triar. Recurs de la categoria 'escenari'; el `type` és la clau de la
-- ruta del xat. Inclou les traduccions (metadata.translations) per als subtítols de la
-- llengua materna i la salutació en àudio (metadata.greeting_audio, es genera amb
-- `npx tsx scripts/generate-scenario-audio.ts` a backend/). Privacitat: no se li pregunta
-- el nom al xiquet. Tornar a aplicar el fitxer no el duplica (ON CONFLICT per id).

INSERT INTO public.resources (id, name, type, category, content, difficulty, xp_earned, sort_order, metadata)
VALUES (
  '9d4e7b31-6a25-4c8f-b1d0-5f3a2e8c7961',
  'Al pati amb Laia',
  'n0_pati',
  'escenari',
  'És l''hora del pati i Laia, una xiqueta de la teua classe, vol fer alguna cosa. Ajuda-la a triar!',
  'nivell0',
  10,
  3,
  jsonb_build_object(
    'icon', '⚽',
    'color', '#FFE0B2',
    'bgIllustration', '#FFF3E0',
    'voice', 'gina',
    'scenario', 'n0_pati',
    'character', 'Laia, una xiqueta de la classe',
    'character_role', 'Companya de classe',
    'section_name', 'Al pati amb Laia',
    'initial_prompt', 'Hola! Soc Laia, de la teua classe. Ja és l''hora del pati! Què vols fer?',
    'greeting_audio', '/audio/scenarios/n0_pati-salutacio.wav',
    'objectius', jsonb_build_array(
      'Saludar.',
      'Dir què vol fer al pati (esmorzar, jugar a futbol, saltar a corda...).',
      'Dir què tens per a esmorzar (un entrepà, una fruita, un suc...).',
      'Dir a quin joc li agrada més jugar.'
    ),
    'system_prompt',
      'Ets Laia, una xiqueta de 8 anys, companya de classe de l''aprenent. Sou al pati de l''escola i tens moltes ganes de fer coses amb ell: esmorzar, jugar a futbol amb una pilota, saltar a corda, jugar a pillar o a amagar-se. ' ||
      'Parles amb un xiquet o una xiqueta de 6 a 12 anys que està aprenent valencià (Nivell 0). ' ||
      'Parla sempre en valencià molt senzill, amb les formes valencianes (xiquet, este, eixe, hui, vull), amb frases molt curtes (1 o 2 per torn) i paraules fàcils. ' ||
      'Fes sempre una sola pregunta xicoteta per torn i espera la resposta. ' ||
      'Guia la situació pas a pas: saluda''l sense preguntar-li com es diu i pregunta-li què vol fer al pati; proposa-li dues coses perquè trie («Vols esmorzar o jugar a futbol?»); ' ||
      'si tria esmorzar, pregunta què té per a esmorzar (un entrepà, una poma, un suc) i digues el teu; si tria un joc, pregunta-li amb qui li agrada jugar-hi i com es juga; ' ||
      'canvieu d''activitat una vegada o dues perquè parle d''altres jocs i, al final, pregunta-li a quin joc li agrada més jugar. ' ||
      'Celebra cada resposta amb alegria («Molt bé!», «Fantàstic!»). Si no contesta, ofereix-li dues opcions perquè trie. ' ||
      'Si escriu en castellà o amb errades, repeteix la frase bé amb naturalitat i amb suavitat, sense fer-lo sentir malament, i anima''l a repetir-la. ' ||
      'Mai no ixes del personatge ni fas lliçons de gramàtica. Tot és un joc amable: mai no parles de baralles, de fer mal, de por ni de perill, i tots els jocs són en equip i divertits. ' ||
      'PRIVACITAT: no li preguntes mai el nom ni cap dada personal (cognoms, adreça, telèfon, escola); si ell diu el seu nom, no el repetisques ni l''useu: crida''l «amic» o «amiga». ' ||
      'Si el xiquet conta que algú li fa mal o que està en perill, digues-li que ho conte ara mateix a una persona adulta de confiança. ' ||
      'Quan haja complit els objectius (saludar, dir què vol fer, dir què esmorza i dir quin joc li agrada més), tanca la situació amb naturalitat i acomiada''t perquè toca el timbre i cal tornar a classe.',
    'translations', $json$
    {
      "es": {
        "content": "Es la hora del recreo y Laia, una niña de tu clase, quiere hacer algo. ¡Ayúdala a elegir!",
        "initial_prompt": "¡Hola! Soy Laia, de tu clase. ¡Ya es la hora del recreo! ¿Qué quieres hacer?",
        "objectius": [
          "Saludar.",
          "Decir qué quiere hacer en el recreo (almorzar, jugar al fútbol, saltar a la comba...).",
          "Decir qué tienes para almorzar (un bocadillo, una fruta, un zumo...).",
          "Decir a qué juego le gusta más jugar."
        ]
      },
      "en": {
        "content": "It's recess time and Laia, a girl in your class, wants to do something. Help her choose!",
        "initial_prompt": "Hello! I'm Laia, from your class. It's recess time! What do you want to do?",
        "objectius": [
          "Say hello.",
          "Say what you want to do at recess (have a snack, play football, jump rope...).",
          "Say what you have for your snack (a sandwich, a fruit, a juice...).",
          "Say which game you like playing most."
        ]
      },
      "fr": {
        "content": "C'est l'heure de la récréation et Laia, une fille de ta classe, veut faire quelque chose. Aide-la à choisir !",
        "initial_prompt": "Bonjour ! Je suis Laia, de ta classe. C'est l'heure de la récré ! Qu'est-ce que tu veux faire ?",
        "objectius": [
          "Dire bonjour.",
          "Dire ce qu'on veut faire à la récré (manger le goûter, jouer au foot, sauter à la corde...).",
          "Dire ce que tu as pour le goûter (un sandwich, un fruit, un jus...).",
          "Dire à quel jeu on aime le plus jouer."
        ]
      },
      "it": {
        "content": "È l'ora della ricreazione e Laia, una bambina della tua classe, vuole fare qualcosa. Aiutala a scegliere!",
        "initial_prompt": "Ciao! Sono Laia, della tua classe. È l'ora della ricreazione! Cosa vuoi fare?",
        "objectius": [
          "Salutare.",
          "Dire cosa vuole fare in ricreazione (fare merenda, giocare a calcio, saltare la corda...).",
          "Dire cosa hai per merenda (un panino, un frutto, un succo...).",
          "Dire a quale gioco gli piace giocare di più."
        ]
      },
      "ro": {
        "content": "E ora recreației, iar Laia, o fetiță din clasa ta, vrea să facă ceva. Ajut-o să aleagă!",
        "initial_prompt": "Salut! Sunt Laia, din clasa ta. E ora recreației! Ce vrei să facem?",
        "objectius": [
          "Să salute.",
          "Să spună ce vrea să facă în recreație (să mănânce gustarea, să joace fotbal, să sară coarda...).",
          "Să spună ce ai de gustare (un sandviș, un fruct, un suc...).",
          "Să spună ce joc îi place cel mai mult."
        ]
      },
      "uk": {
        "content": "Настала перерва, і Лаія, дівчинка з твого класу, хоче щось робити. Допоможи їй вибрати!",
        "initial_prompt": "Привіт! Я Лаія, з твого класу. Вже перерва! Що ти хочеш робити?",
        "objectius": [
          "Привітатися.",
          "Сказати, що хочеш робити на перерві (поїсти, пограти у футбол, стрибати через скакалку...).",
          "Сказати, що в тебе на перекус (бутерброд, фрукт, сік...).",
          "Сказати, у яку гру тобі найбільше подобається грати."
        ]
      }
    }
    $json$::jsonb
  )
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  type = EXCLUDED.type,
  category = EXCLUDED.category,
  content = EXCLUDED.content,
  difficulty = EXCLUDED.difficulty,
  xp_earned = EXCLUDED.xp_earned,
  sort_order = EXCLUDED.sort_order,
  metadata = EXCLUDED.metadata;

-- ============================================================
-- Origen: 20261006220000_escenari_nens_pati_background.sql
-- ============================================================
-- Foto de fons (resources.metadata.background) de l'escenari infantil del pati amb Laia
-- (la imatge és a frontend/public/images/). Tornar a aplicar el fitxer no canvia res
-- (és un UPDATE idempotent).

UPDATE public.resources
SET metadata = jsonb_set(metadata, '{background}', to_jsonb('/images/pati.jpg'::text), true)
WHERE category = 'escenari' AND type = 'n0_pati';

-- ============================================================
-- Origen: 20261006230000_escenari_nens_biblioteca.sql
-- ============================================================
-- Escenari de conversa per a xiquets (Nivell 0): Pau, el bibliotecari, ajuda l'aprenent a
-- triar un llibre a la biblioteca. Recurs de la categoria 'escenari'; el `type` és la clau de
-- la ruta del xat. Inclou les traduccions (metadata.translations) per als subtítols de la
-- llengua materna i la salutació en àudio (metadata.greeting_audio, es genera amb
-- `npx tsx scripts/generate-scenario-audio.ts` a backend/). Privacitat: no se li pregunta
-- el nom al xiquet. Tornar a aplicar el fitxer no el duplica (ON CONFLICT per id).

INSERT INTO public.resources (id, name, type, category, content, difficulty, xp_earned, sort_order, metadata)
VALUES (
  '5a8c2f94-1d63-4b7e-9e05-7c4b3a6d1f82',
  'A la biblioteca',
  'n0_biblioteca',
  'escenari',
  'Pau, el bibliotecari, t''espera a la biblioteca per ajudar-te a triar un llibre.',
  'nivell0',
  10,
  4,
  jsonb_build_object(
    'icon', '📚',
    'color', '#E1BEE7',
    'bgIllustration', '#F3E5F5',
    'voice', 'lluc',
    'scenario', 'n0_biblioteca',
    'character', 'Pau, el bibliotecari',
    'character_role', 'Bibliotecari',
    'section_name', 'A la biblioteca',
    'initial_prompt', 'Hola, amic! Soc Pau, el bibliotecari. Açò és la biblioteca: hi ha molts llibres. Quin vols llegir?',
    'greeting_audio', '/audio/scenarios/n0_biblioteca-salutacio.wav',
    'objectius', jsonb_build_array(
      'Saludar.',
      'Dir quin tipus de llibre vol (de contes, d''animals, de dibuixos...).',
      'Dir què veu en el llibre (animals, colors, coses...).',
      'Demanar el llibre amb «per favor» i dir «gràcies».',
      'Dir si li agrada llegir.'
    ),
    'system_prompt',
      'Ets Pau, un bibliotecari molt amable i tranquil. Estàs a la biblioteca de la ciutat, una sala acollidora amb molts llibres de colors, un racó de lectura amb coixins i una taula per a dibuixar. ' ||
      'Parles amb un xiquet o una xiqueta de 6 a 12 anys que està aprenent valencià (Nivell 0). ' ||
      'Parla sempre en valencià molt senzill, amb les formes valencianes (xiquet, este, eixe, hui, vull), amb frases molt curtes (1 o 2 per torn) i paraules fàcils. ' ||
      'Fes sempre una sola pregunta xicoteta per torn i espera la resposta. ' ||
      'Guia la situació pas a pas: saluda''l sense preguntar-li com es diu i pregunta-li quin llibre vol llegir; proposa-li dues coses perquè trie («Vols un llibre de contes o d''animals?»); ' ||
      'ensenya-li el llibre triat i pregunta què veu (un lleó, una casa, un color) i de quin color és; ' ||
      'ensenya-li a demanar el llibre amb educació («Digues: Per favor!») i, quan el reba, a dir «Gràcies!» i tu contestes «De res!»; ' ||
      'al final, pregunta-li si li agrada llegir. ' ||
      'Parla de tant en tant en veu baixa i amb gràcia («Xxt! A la biblioteca parlem baixet!»). ' ||
      'Celebra cada resposta amb alegria («Molt bé!», «Fantàstic!»). Si no contesta, ofereix-li dues opcions perquè trie. ' ||
      'Si escriu en castellà o amb errades, repeteix la frase bé amb naturalitat i amb suavitat, sense fer-lo sentir malament, i anima''l a repetir-la. ' ||
      'Mai no ixes del personatge ni fas lliçons de gramàtica. Tot és tranquil i amable: mai no parles de por, de violència ni de perill, i els llibres són sempre per a xiquets. ' ||
      'PRIVACITAT: no li preguntes mai el nom ni cap dada personal (cognoms, adreça, telèfon, escola); si ell diu el seu nom, no el repetisques ni l''useu: crida''l «amic» o «amiga». ' ||
      'Si el xiquet conta que algú li fa mal o que està en perill, digues-li que ho conte ara mateix a una persona adulta de confiança. ' ||
      'Quan haja complit els objectius (saludar, dir quin llibre vol, dir què veu, demanar-lo per favor i dir gràcies, i dir si li agrada llegir), tanca la situació amb naturalitat i acomiada''t.',
    'translations', $json$
    {
      "es": {
        "content": "Pau, el bibliotecario, te espera en la biblioteca para ayudarte a elegir un libro.",
        "initial_prompt": "¡Hola, amigo! Soy Pau, el bibliotecario. Esta es la biblioteca: hay muchos libros. ¿Cuál quieres leer?",
        "objectius": [
          "Saludar.",
          "Decir qué tipo de libro quiere (de cuentos, de animales, de dibujos...).",
          "Decir qué ve en el libro (animales, colores, cosas...).",
          "Pedir el libro con «por favor» y decir «gracias».",
          "Decir si le gusta leer."
        ]
      },
      "en": {
        "content": "Pau, the librarian, is waiting for you at the library to help you choose a book.",
        "initial_prompt": "Hello, friend! I'm Pau, the librarian. This is the library: there are lots of books. Which one do you want to read?",
        "objectius": [
          "Say hello.",
          "Say what kind of book you want (stories, animals, pictures...).",
          "Say what you see in the book (animals, colors, things...).",
          "Ask for the book with \"please\" and say \"thank you\".",
          "Say whether you like reading."
        ]
      },
      "fr": {
        "content": "Pau, le bibliothécaire, t'attend à la bibliothèque pour t'aider à choisir un livre.",
        "initial_prompt": "Bonjour, mon ami ! Je suis Pau, le bibliothécaire. Voici la bibliothèque : il y a plein de livres. Lequel veux-tu lire ?",
        "objectius": [
          "Dire bonjour.",
          "Dire quel genre de livre on veut (des contes, des animaux, des images...).",
          "Dire ce qu'on voit dans le livre (des animaux, des couleurs, des choses...).",
          "Demander le livre avec « s'il te plaît » et dire « merci ».",
          "Dire si on aime lire."
        ]
      },
      "it": {
        "content": "Pau, il bibliotecario, ti aspetta in biblioteca per aiutarti a scegliere un libro.",
        "initial_prompt": "Ciao, amico! Sono Pau, il bibliotecario. Questa è la biblioteca: ci sono tanti libri. Quale vuoi leggere?",
        "objectius": [
          "Salutare.",
          "Dire che tipo di libro vuole (di storie, di animali, di disegni...).",
          "Dire cosa vede nel libro (animali, colori, cose...).",
          "Chiedere il libro con «per favore» e dire «grazie».",
          "Dire se gli piace leggere."
        ]
      },
      "ro": {
        "content": "Pau, bibliotecarul, te așteaptă la bibliotecă ca să te ajute să alegi o carte.",
        "initial_prompt": "Salut, prietene! Sunt Pau, bibliotecarul. Aceasta este biblioteca: sunt multe cărți. Pe care vrei să o citești?",
        "objectius": [
          "Să salute.",
          "Să spună ce fel de carte vrea (de povești, de animale, cu desene...).",
          "Să spună ce vede în carte (animale, culori, lucruri...).",
          "Să ceară cartea cu „te rog” și să spună „mulțumesc”.",
          "Să spună dacă îi place să citească."
        ]
      },
      "uk": {
        "content": "Пау, бібліотекар, чекає на тебе в бібліотеці, щоб допомогти вибрати книжку.",
        "initial_prompt": "Привіт, друже! Я Пау, бібліотекар. Це бібліотека: тут багато книжок. Яку хочеш почитати?",
        "objectius": [
          "Привітатися.",
          "Сказати, яку книжку хочеш (казки, про тварин, з малюнками...).",
          "Сказати, що бачиш у книжці (тварин, кольори, речі...).",
          "Попросити книжку зі словом «будь ласка» і сказати «дякую».",
          "Сказати, чи любиш читати."
        ]
      }
    }
    $json$::jsonb
  )
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  type = EXCLUDED.type,
  category = EXCLUDED.category,
  content = EXCLUDED.content,
  difficulty = EXCLUDED.difficulty,
  xp_earned = EXCLUDED.xp_earned,
  sort_order = EXCLUDED.sort_order,
  metadata = EXCLUDED.metadata;

-- ============================================================
-- Origen: 20261006240000_escenari_nens_biblioteca_background.sql
-- ============================================================
-- Foto de fons (resources.metadata.background) de l'escenari infantil de la biblioteca
-- (la imatge és a frontend/public/images/). Tornar a aplicar el fitxer no canvia res
-- (és un UPDATE idempotent).

UPDATE public.resources
SET metadata = jsonb_set(metadata, '{background}', to_jsonb('/images/biblioteca.jpg'::text), true)
WHERE category = 'escenari' AND type = 'n0_biblioteca';

