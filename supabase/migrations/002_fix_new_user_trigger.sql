-- Repair the Auth trigger used when a person signs in for the first time.
-- Run this migration in Supabase SQL Editor after 001_initial_schema.sql.
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
    when 'intermedi' then 'intermedi'::learner_level
    when 'avancat' then 'avancat'::learner_level
    else 'principiant'::learner_level
  end;

  insert into public.profiles (id, display_name, level)
  values (new.id, coalesce(new.raw_user_meta_data ->> 'display_name', ''), initial_level)
  on conflict (id) do nothing;

  insert into public.scenario_progress (user_id, scenario, status)
  values (new.id, 'mercat', 'unlocked')
  on conflict (user_id, scenario) do nothing;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
