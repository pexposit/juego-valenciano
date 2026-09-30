-- scenario_progress ja no existix (substituïda per resources/session_resource):
-- el disparador encara hi inseria i tallava tot alta nova amb un 500.
create or replace function handle_new_user() returns trigger language plpgsql security definer
set search_path = public
as $$
declare
  initial_level public.learner_level;
begin
  initial_level := case new.raw_user_meta_data ->> 'level'
    when 'intermedi' then 'intermedi'::public.learner_level
    when 'avancat' then 'avancat'::public.learner_level
    else 'principiant'::public.learner_level
  end;

  insert into public.profiles (id, display_name, level)
  values (new.id, coalesce(new.raw_user_meta_data ->> 'display_name', ''), initial_level)
  on conflict (id) do nothing;

  return new;
end;
$$;
