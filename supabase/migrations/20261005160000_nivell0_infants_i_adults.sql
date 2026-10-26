-- Migració agrupada: 20261005160000_nivell0_infants_i_adults
-- Conté, per ordre, les 6 migracions originals següents:
--   20261005160000_nens_nivell0
--   20261005170000_adults_nivell0
--   20261005175000_session_resource_title
--   20261005180000_escenaris_b1_backgrounds
--   20261005185000_mother_tongue_6_llengues
--   20261006100000_difficulty_nivell0

-- ============================================================
-- Origen: 20261005160000_nens_nivell0.sql
-- ============================================================
-- Els comptes nous de xiquets (age_group = 'child') comencen sempre en el Nivell 0,
-- encara que el client envie un altre nivell. Els adults no canvien.

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

  -- Els xiquets sempre comencen en el Nivell 0; els adults no el poden triar.
  initial_level := case
    when group_of_age = 'child' then 'nivell0'::learner_level
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

-- ============================================================
-- Origen: 20261005170000_adults_nivell0.sql
-- ============================================================
-- Les persones adultes també poden començar en el Nivell 0 (el més bàsic).
-- Els xiquets continuen començant sempre en el Nivell 0.

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

-- ============================================================
-- Origen: 20261005175000_session_resource_title.sql
-- ============================================================
-- Títol de les converses amb el tutor (pestanya «Converses»).
--   * title: el nom que es mostra en la llista.
--   * title_source: 'user' si l'ha escrit l'usuari (no es toca mai més) o 'auto' si
--     l'ha resumit el LLM. NULL = encara no en té.
--   * title_message_count: quants missatges tenia la conversa quan es va resumir; si
--     ha crescut prou, el títol automàtic es torna a generar.
-- Tornar a aplicar el fitxer no canvia res.

ALTER TABLE public.session_resource
  ADD COLUMN IF NOT EXISTS title text,
  ADD COLUMN IF NOT EXISTS title_source text,
  ADD COLUMN IF NOT EXISTS title_message_count integer;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'session_resource_title_source_check') THEN
    ALTER TABLE public.session_resource
      ADD CONSTRAINT session_resource_title_source_check CHECK (title_source IN ('user', 'auto'));
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'session_resource_title_length_check') THEN
    ALTER TABLE public.session_resource
      ADD CONSTRAINT session_resource_title_length_check CHECK (title IS NULL OR char_length(title) BETWEEN 1 AND 80);
  END IF;
END
$$;

-- ============================================================
-- Origen: 20261005180000_escenaris_b1_backgrounds.sql
-- ============================================================
-- Foto de fons (resources.metadata.background) del taller i dels escenaris del B1
-- (les imatges són a frontend/public/images/). Tornar a aplicar el fitxer no duplica res
-- (és un UPDATE idempotent).

UPDATE public.resources AS r
SET metadata = jsonb_set(r.metadata, '{background}', to_jsonb(v.background), true)
FROM (VALUES
  ('taller',             '/images/car_workshop.jpg'),
  ('b1_persones',        '/images/cooking_workshop.jpg'),
  ('b1_relacions',       '/images/street.jpg'),
  ('b1_vida_quotidiana', '/images/townhall.jpg'),
  ('b1_llocs',           '/images/real_state.jpg'),
  ('b1_viatges',         '/images/travel_agency.jpg'),
  ('b1_oci_esport',      '/images/gym.jpg'),
  ('b1_administracio',   '/images/townhall.jpg'),
  ('b1_treball',         '/images/hotel.jpg'),
  ('b1_salut',           '/images/flat.jpg'),
  ('b1_territori',       '/images/classroom.jpg'),
  ('b1_cultura',         '/images/radio_station.jpg'),
  ('b1_natura_clima',    '/images/Montgó.jpg')
) AS v(type, background)
WHERE r.category = 'escenari' AND r.type = v.type;

-- ============================================================
-- Origen: 20261005185000_mother_tongue_6_llengues.sql
-- ============================================================
-- Llengües maternes acotades a sis amb traducció: castellà, anglés, francés, italià,
-- romanés i ucraïnés (més 'ca' i 'other'). Qui en tenia una altra (àrab, rus, xinés,
-- alemany, portugués...) passa a 'other': el tutor li parla només en valencià.
-- handle_new_user() fa el mateix en el registre (la resta, igual que en 20261005160000).

UPDATE public.profiles
SET mother_tongue = 'other'
WHERE mother_tongue IS NOT NULL
  AND mother_tongue NOT IN ('es', 'en', 'fr', 'it', 'ro', 'uk', 'ca', 'other');

ALTER TABLE public.profiles
  DROP CONSTRAINT IF EXISTS profiles_mother_tongue_check,
  ADD CONSTRAINT profiles_mother_tongue_check
    CHECK (mother_tongue IS NULL OR mother_tongue IN ('es', 'en', 'fr', 'it', 'ro', 'uk', 'ca', 'other'));

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

  -- Els xiquets sempre comencen en el Nivell 0; els adults no el poden triar.
  initial_level := case
    when group_of_age = 'child' then 'nivell0'::learner_level
    else case new.raw_user_meta_data ->> 'level'
      when 'intermedi' then 'intermedi'::learner_level
      when 'avancat' then 'avancat'::learner_level
      else 'principiant'::learner_level
    end
  end;

  tongue := lower(coalesce(new.raw_user_meta_data ->> 'mother_tongue', ''));
  -- Una llengua que no és de les triables passa a 'other' (no trenca el registre).
  if tongue = '' then
    tongue := null;
  elsif tongue not in ('es', 'en', 'fr', 'it', 'ro', 'uk', 'ca', 'other') then
    tongue := 'other';
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
-- Origen: 20261006100000_difficulty_nivell0.sql
-- ============================================================
-- Valor 'nivell0' per a resources.difficulty, perquè hi haja activitats del Nivell 0
-- (xiquets), igual que profiles.level. Va en una migració pròpia: un valor nou d'un
-- enum no es pot usar en la mateixa transacció que l'afegix. Tornar-la a aplicar no
-- canvia res.

ALTER TYPE public.difficulties ADD VALUE IF NOT EXISTS 'nivell0' BEFORE 'principiant';

