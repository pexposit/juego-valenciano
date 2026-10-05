-- Nivell 0 i perfils infantils.
--   * learner_level: nou valor 'nivell0', el més bàsic de tots (davant de
--     'principiant'). Per als xiquets que encara no llegixen: l'app els mostra el
--     món d'illes del Nivell 0 (àudio + il·lustració + moviment) en lloc del tauler.
--   * profiles.es_adult: true per als adults (tots els perfils que ja hi ha) i false
--     per als xiquets.
--   * handle_new_user(): accepta level = 'nivell0' i es_adult de les metadades del
--     registre (raw_user_meta_data).
-- Tornar a aplicar el fitxer no canvia res més.

ALTER TYPE public.learner_level ADD VALUE IF NOT EXISTS 'nivell0' BEFORE 'principiant';

ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS es_adult boolean NOT NULL DEFAULT true;

COMMENT ON COLUMN public.profiles.es_adult IS 'true si l''usuari és adult; false si és un xiquet (modes infantils com el Nivell 0).';

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  initial_level learner_level;
begin
  initial_level := case new.raw_user_meta_data ->> 'level'
    when 'nivell0' then 'nivell0'::learner_level
    when 'intermedi' then 'intermedi'::learner_level
    when 'avancat' then 'avancat'::learner_level
    else 'principiant'::learner_level
  end;

  insert into public.profiles (id, display_name, level, es_adult)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'display_name', ''),
    initial_level,
    coalesce((new.raw_user_meta_data ->> 'es_adult')::boolean, true)
  )
  on conflict (id) do nothing;

  return new;
end;
$$;
