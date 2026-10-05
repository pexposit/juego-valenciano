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
