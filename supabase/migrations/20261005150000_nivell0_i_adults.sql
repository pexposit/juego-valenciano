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
