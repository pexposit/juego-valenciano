-- scenario_progress fue eliminada en 20260925150358_refactorizacionbdd-v1.0.sql,
-- pero handle_new_user() seguia insertant-hi, cosa que trencava el signup
-- (trigger on_auth_user_created fallava amb "relation scenario_progress does not exist").
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

  return new;
end;
$$;
