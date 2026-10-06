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
