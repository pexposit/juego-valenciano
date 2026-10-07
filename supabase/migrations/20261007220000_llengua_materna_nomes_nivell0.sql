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
