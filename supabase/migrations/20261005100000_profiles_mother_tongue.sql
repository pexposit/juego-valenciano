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
