-- Afegeix l'escenari "Oficina de Turisme" (turisme) a l'enum scenario_key i encadena
-- el seu desbloqueig després de completar l'escola (colegi).
--
-- Per a instal·lacions noves n'hi ha prou amb 001_initial_schema.sql (ja actualitzat);
-- per a bases ja existents, aquesta migració amplia l'enum i recrea la funció
-- apply_turn_xp amb la nova cadena de desbloqueig.
alter type scenario_key add value if not exists 'turisme';

create or replace function apply_turn_xp(p_user_id uuid,p_session_id uuid,p_scenario scenario_key,p_xp_delta integer,p_threshold integer) returns void language plpgsql security definer as $$ declare total integer; next_s scenario_key; begin update profiles set xp=xp+p_xp_delta,updated_at=now() where id=p_user_id; update conversation_sessions set xp_earned=xp_earned+p_xp_delta where id=p_session_id; insert into scenario_progress(user_id,scenario,status,xp_earned) values(p_user_id,p_scenario,'unlocked',p_xp_delta) on conflict(user_id,scenario) do update set xp_earned=scenario_progress.xp_earned+p_xp_delta,updated_at=now() returning xp_earned into total; if total>=p_threshold then update scenario_progress set status='completed',completed_at=now() where user_id=p_user_id and scenario=p_scenario; next_s:=case p_scenario when 'mercat' then 'bar' when 'bar' then 'oficina' when 'oficina' then 'ajuntament' when 'ajuntament' then 'colegi' when 'colegi' then 'turisme' else null end; if next_s is not null then insert into scenario_progress(user_id,scenario,status) values(p_user_id,next_s,'unlocked') on conflict(user_id,scenario) do nothing; end if; end if; end $$;