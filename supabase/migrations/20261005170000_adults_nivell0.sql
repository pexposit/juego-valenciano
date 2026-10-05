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
