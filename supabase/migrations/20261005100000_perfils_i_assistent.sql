-- Migració agrupada: 20261005100000_perfils_i_assistent
-- Conté, per ordre, les 6 migracions originals següents:
--   20261005100000_profiles_mother_tongue
--   20261005110000_profiles_age_group
--   20261005120000_assistent_infantil
--   20261005130000_profiles_show_mother_tongue
--   20261005140000_profiles_mother_tongue_check
--   20261005150000_nivell0_i_adults

-- ============================================================
-- Origen: 20261005100000_profiles_mother_tongue.sql
-- ============================================================
-- Llengua materna de l'aprenent (codi ISO 639-1, o 'other'), triada en crear el compte.
-- És nullable: els perfils anteriors no la tenen. handle_new_user() la llig de
-- raw_user_meta_data (la que envia signUp) i ignora qualsevol valor que no siga un
-- codi de 2-5 lletres minúscules, perquè el client no puga guardar text arbitrari.

ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS mother_tongue text;

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  initial_level learner_level;
  tongue text;
begin
  initial_level := case new.raw_user_meta_data ->> 'level'
    when 'intermedi' then 'intermedi'::learner_level
    when 'avancat' then 'avancat'::learner_level
    else 'principiant'::learner_level
  end;

  tongue := lower(coalesce(new.raw_user_meta_data ->> 'mother_tongue', ''));
  if tongue !~ '^([a-z]{2}|other)$' then
    tongue := null;
  end if;

  insert into public.profiles (id, display_name, level, mother_tongue)
  values (new.id, coalesce(new.raw_user_meta_data ->> 'display_name', ''), initial_level, tongue)
  on conflict (id) do nothing;

  return new;
end;
$$;

-- ============================================================
-- Origen: 20261005110000_profiles_age_group.sql
-- ============================================================
-- Públic del compte: 'child' (xiquet) o 'adult', triat en crear el perfil. Els perfils
-- anteriors queden com a 'adult'. Els xiquets no trien nivell: handle_new_user() els
-- fixa en principiant, encara que el client n'envie un altre. Qualsevol valor que no
-- siga 'child' es guarda com a 'adult'.

ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS age_group text NOT NULL DEFAULT 'adult';

ALTER TABLE public.profiles
  DROP CONSTRAINT IF EXISTS profiles_age_group_check,
  ADD CONSTRAINT profiles_age_group_check CHECK (age_group IN ('child', 'adult'));

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

  initial_level := case
    when group_of_age = 'child' then 'principiant'::learner_level
    else case new.raw_user_meta_data ->> 'level'
      when 'intermedi' then 'intermedi'::learner_level
      when 'avancat' then 'avancat'::learner_level
      else 'principiant'::learner_level
    end
  end;

  tongue := lower(coalesce(new.raw_user_meta_data ->> 'mother_tongue', ''));
  if tongue !~ '^([a-z]{2}|other)$' then
    tongue := null;
  end if;

  insert into public.profiles (id, display_name, level, mother_tongue, age_group)
  values (new.id, coalesce(new.raw_user_meta_data ->> 'display_name', ''), initial_level, tongue, group_of_age)
  on conflict (id) do nothing;

  return new;
end;
$$;

-- ============================================================
-- Origen: 20261005120000_assistent_infantil.sql
-- ============================================================
-- Tutor de valencià per als comptes infantils: un xat directe des del tauler. És un recurs
-- de la categoria 'assistent' (inclosa a CHAT_CATEGORIES perquè /api/turn el sàpiga fer
-- servir), però el catàleg d'activitats l'amaga. La primera frase és initial_prompt:
-- es guarda com a primer missatge del personatge en obrir la conversa. Tornar a aplicar
-- la migració no el duplica.

INSERT INTO public.resources (name, type, category, content, difficulty, xp_earned, sort_order, metadata)
SELECT
  'Tutor de valencià per a xiquets',
  'ajuda_infantil',
  'assistent',
  'Ajuda a xiquets i xiquetes amb dubtes de llengua valenciana.',
  'principiant',
  10,
  0,
  jsonb_build_object(
    'character', 'el professor',
    'voice', 'gina',
    'initial_prompt', 'En què et puc ajudar?',
    'system_prompt',
    'Ets el professor de valencià d''un xiquet o una xiqueta (de 6 a 12 anys) en una aplicació per a aprendre valencià. ' ||
    'Respon sempre en valencià senzill, amb les formes valencianes (xiquet, este, eixe, hui, vull), en frases molt curtes (2 o 3 com a màxim) i amb paraules fàcils. ' ||
    'Fes servir un to amable, pacient i animat, i posa sempre un exemple xicotet. ' ||
    'Si el xiquet escriu amb errades o en castellà, corregeix-lo amb suavitat i amb un exemple, sense fer-lo sentir malament. ' ||
    'Només pots ajudar amb la llengua valenciana: vocabulari, ortografia, gramàtica, pronunciació, com es diu una paraula en valencià i coses semblants. ' ||
    'Si et pregunta una altra cosa, digues-li amablement que només pots ajudar amb el valencià i proposa-li una pregunta sobre la llengua. ' ||
    'No demanes ni acceptes dades personals (cognoms, adreça, telèfon, escola) i no parles de temes violents, sexuals, polítics ni de risc. ' ||
    'Si el xiquet conta que algú li fa mal o que està en perill, digues-li que ho conte ara mateix a una persona adulta de confiança.'
  )
WHERE NOT EXISTS (
  SELECT 1 FROM public.resources WHERE category = 'assistent' AND type = 'ajuda_infantil'
);

-- ============================================================
-- Origen: 20261005130000_profiles_show_mother_tongue.sql
-- ============================================================
-- Preferència dels comptes infantils: mostrar o no l'ajuda en la llengua materna (les línies en gris)
-- en els missatges del tutor. Només afecta la visualització: el tutor continua generant-la i es
-- guarda amb els missatges, així que es pot tornar a activar i veure-la també en les converses anteriors.

ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS show_mother_tongue boolean NOT NULL DEFAULT true;

-- ============================================================
-- Origen: 20261005140000_profiles_mother_tongue_check.sql
-- ============================================================
-- La llengua materna ara es pot editar des del perfil, i la política "own profile" deixa que el client
-- escriga qualsevol text. La restricció la limita al que accepta handle_new_user() en el registre:
-- un codi de dues lletres minúscules (ISO 639-1) o 'other', o null.

ALTER TABLE public.profiles
  DROP CONSTRAINT IF EXISTS profiles_mother_tongue_check,
  ADD CONSTRAINT profiles_mother_tongue_check CHECK (mother_tongue IS NULL OR mother_tongue ~ '^([a-z]{2}|other)$');

-- ============================================================
-- Origen: 20261005150000_nivell0_i_adults.sql
-- ============================================================
-- Nivell 0 i perfils infantils.
--   * learner_level: nou valor 'nivell0', el més bàsic de tots (davant de
--     'principiant'). Per als xiquets que encara no llegixen: l'app els mostra el
--     món d'illes del Nivell 0 (àudio + il·lustració + moviment) en lloc del tauler.
--   * Els xiquets es distingixen per profiles.age_group = 'child' (20261005110000).
--     La columna es_adult que feia el mateix (versió anterior d'esta migració) es
--     passa a age_group i s'elimina, si hi és.
--   * handle_new_user(): conserva la llengua materna i el públic (age_group) i, a
--     més, accepta level = 'nivell0' només per als xiquets.
-- Tornar a aplicar el fitxer no canvia res més.

ALTER TYPE public.learner_level ADD VALUE IF NOT EXISTS 'nivell0' BEFORE 'principiant';

DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'profiles' AND column_name = 'es_adult'
  ) THEN
    UPDATE public.profiles SET age_group = 'child' WHERE es_adult = false;
    ALTER TABLE public.profiles DROP COLUMN es_adult;
  END IF;
END
$$;

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

  -- Els xiquets comencen en principiant o en el Nivell 0; els adults no poden triar el Nivell 0.
  initial_level := case
    when group_of_age = 'child' then case new.raw_user_meta_data ->> 'level'
      when 'nivell0' then 'nivell0'::learner_level
      else 'principiant'::learner_level
    end
    else case new.raw_user_meta_data ->> 'level'
      when 'intermedi' then 'intermedi'::learner_level
      when 'avancat' then 'avancat'::learner_level
      else 'principiant'::learner_level
    end
  end;

  tongue := lower(coalesce(new.raw_user_meta_data ->> 'mother_tongue', ''));
  if tongue !~ '^([a-z]{2}|other)$' then
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

