-- Migració agrupada: 20260925105816_esquema_v1_i_recursos
-- Conté, per ordre, les 11 migracions originals següents:
--   20260925105816_manejo_estado_aprendizaje
--   20260925133758_añadir_role_usuario
--   20260925150358_refactorizacionbdd-v1.0
--   20260928100006_v1.0
--   20260928121900_v1.0
--   20260928123225_add_scene_resources
--   20260929000000_fix_new_user_trigger_no_scenario_progress
--   20260929081233_reset_and_seed_resources
--   20260929100000_fix_handle_new_user_scenario_progress
--   20260929120000_evaluacio_per_recurs
--   20260929140000_scenarios_in_resources

-- ============================================================
-- Origen: 20260925105816_manejo_estado_aprendizaje.sql
-- ============================================================
CREATE TABLE "public"."user_errors" (
  "id"          uuid    NOT NULL DEFAULT gen_random_uuid(),
  "user_id"     uuid    NOT NULL,
  "error_text"  text    NOT NULL,
  "correction"  text    NOT NULL,
  "category"    text    NOT NULL,
  "explanation" text    NOT NULL,
  "resolved"    boolean NOT NULL DEFAULT false,
  CONSTRAINT "user_errors_pkey" PRIMARY KEY (id)
);

ALTER TABLE "public"."user_errors"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."user_evaluations" (
  "id"             uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "user_id"        uuid                     NOT NULL,
  "summary"        text                     NOT NULL,
  "weaknesses"     text[]                   NOT NULL DEFAULT '{}'::text[],
  "priority_focus" text                     NOT NULL,
  "created_at"     timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "user_evaluations_pkey" PRIMARY KEY (id)
);

ALTER TABLE "public"."user_evaluations"
  ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."user_evaluations"
  ADD CONSTRAINT "user_evaluations_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;

CREATE INDEX idx_user_evaluations_user_created ON public.user_evaluations USING btree (user_id, created_at DESC);

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."user_errors" TO "anon", "authenticated", "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."user_evaluations" TO "anon", "authenticated", "postgres", "service_role";

-- ============================================================
-- Origen: 20260925133758_añadir_role_usuario.sql
-- ============================================================
ALTER TABLE "public"."profiles"
  ADD COLUMN "role" text NOT NULL DEFAULT 'user'::text;

ALTER TABLE "public"."profiles"
  ADD CONSTRAINT "profiles_role_check" CHECK ((role = ANY (ARRAY['admin'::text, 'user'::text])));

-- ============================================================
-- Origen: 20260925150358_refactorizacionbdd-v1.0.sql
-- ============================================================
DROP INDEX "public"."idx_user_evaluations_user_created";

ALTER TABLE "public"."scenario_progress"
  DROP CONSTRAINT "scenario_progress_user_id_fkey";

ALTER TABLE "public"."user_evaluations"
  DROP CONSTRAINT "user_evaluations_user_id_fkey";

ALTER TABLE "public"."conversation_sessions"
  DROP COLUMN "scenario";

ALTER TABLE "public"."user_errors"
  DROP COLUMN "user_id";

ALTER TABLE "public"."user_evaluations"
  DROP COLUMN "user_id";

DROP TABLE "public"."scenario_progress";

CREATE TABLE "public"."activities" (
  "id"          character varying(50)  NOT NULL,
  "title"       character varying(255) NOT NULL DEFAULT 'Sense títol'::character varying,
  "description" text,
  CONSTRAINT "scenario_progress_pkey" PRIMARY KEY (id)
);

ALTER TABLE "public"."activities"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."resources" (
  "id"          uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "activity_id" character varying(50)    NOT NULL,
  "name"        character varying(255)   NOT NULL,
  "type"        character varying(50)    NOT NULL,
  "url"         text,
  "content"     text,
  "metadata"    jsonb                    DEFAULT '{}'::jsonb,
  "created_at"  timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "xp_earned"   smallint                 NOT NULL,
  CONSTRAINT "recursos_pkey" PRIMARY KEY (id)
);

ALTER TABLE "public"."resources"
  ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."conversation_sessions"
  ADD COLUMN "activity_id" character varying(50);

ALTER TABLE "public"."user_errors"
  ADD COLUMN "message_id" uuid;

ALTER TABLE "public"."user_evaluations"
  ADD COLUMN "session_id" uuid NOT NULL;

CREATE TYPE "public"."activity_type" AS ENUM (
  'ortografia',
  'lexic',
  'scenari',
  'pronoms_febles'
);

CREATE TYPE "public"."categoria_actividades" AS ENUM (
  'ortografia',
  'lexic',
  'escenari',
  'pornomsF'
);

CREATE TYPE "public"."difficulties" AS ENUM (
  'principiant',
  'intermedi',
  'avancat'
);

ALTER TABLE "public"."resources"
  ADD COLUMN "difficulty" public.difficulties NOT NULL;

ALTER TABLE "public"."conversation_sessions"
  ADD CONSTRAINT "conversation_sessions_activity_id_fkey" FOREIGN KEY (activity_id) REFERENCES public.activities(id) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE "public"."resources"
  ADD CONSTRAINT "recursos_actividad_id_fkey" FOREIGN KEY (activity_id) REFERENCES public.activities(id) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE "public"."user_errors"
  ADD CONSTRAINT "user_errors_message_id_fkey" FOREIGN KEY (message_id) REFERENCES public.conversation_messages(id) ON DELETE CASCADE;

ALTER TABLE "public"."user_evaluations"
  ADD CONSTRAINT "user_evaluations_session_id_fkey" FOREIGN KEY (session_id) REFERENCES public.conversation_sessions(id) ON UPDATE CASCADE ON DELETE CASCADE;

CREATE INDEX idx_conversation_sessions_activity_id ON public.conversation_sessions USING btree (activity_id);

CREATE INDEX idx_recursos_actividad_id ON public.resources USING btree (activity_id);

CREATE INDEX idx_recursos_metadata ON public.resources USING gin (metadata);

CREATE INDEX idx_recursos_tipo ON public.resources USING btree (TYPE);

CREATE INDEX idx_user_errors_message_id ON public.user_errors USING btree (message_id);

CREATE INDEX idx_user_evaluations_user_created ON public.user_evaluations USING btree (session_id, created_at DESC);

CREATE POLICY "Allow authenticated read activities" ON "public"."activities"
  FOR SELECT
  TO "authenticated"
  USING (true);

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."activities" TO "anon", "authenticated", "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."resources" TO "anon", "authenticated", "postgres", "service_role";

GRANT USAGE ON TYPE "public"."activity_type" TO "postgres";

GRANT USAGE ON TYPE "public"."categoria_actividades" TO "postgres";

GRANT USAGE ON TYPE "public"."difficulties" TO "postgres";

-- ============================================================
-- Origen: 20260928100006_v1.0.sql
-- ============================================================
DROP POLICY "own messages" ON "public"."conversation_messages";

DROP INDEX "public"."idx_recursos_actividad_id";

ALTER TABLE "public"."conversation_messages"
  DROP CONSTRAINT "conversation_messages_session_id_fkey";

ALTER TABLE "public"."conversation_sessions"
  DROP CONSTRAINT "conversation_sessions_activity_id_fkey";

ALTER TABLE "public"."conversation_sessions"
  DROP CONSTRAINT "conversation_sessions_user_id_fkey";

ALTER TABLE "public"."resources"
  DROP CONSTRAINT "recursos_actividad_id_fkey";

ALTER TABLE "public"."user_evaluations"
  DROP CONSTRAINT "user_evaluations_session_id_fkey";

ALTER TABLE "public"."conversation_messages"
  DROP COLUMN "error_flags";

ALTER TABLE "public"."resources"
  DROP COLUMN "activity_id";

DROP TABLE "public"."activities";

DROP TABLE "public"."conversation_sessions";

CREATE TABLE "public"."session_resource" (
  "sesion_id"  uuid    NOT NULL,
  "recurso_id" uuid    NOT NULL,
  "resolved"   boolean,
  CONSTRAINT "session_resource_pkey" PRIMARY KEY (sesion_id, recurso_id)
);

ALTER TABLE "public"."session_resource"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."session" (
  "id"             uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "user_id"        uuid                     NOT NULL,
  "started_at"     timestamp with time zone NOT NULL DEFAULT now(),
  "ended_at"       timestamp with time zone,
  "level_at_start" public.learner_level     NOT NULL,
  "xp_earned"      integer                  NOT NULL DEFAULT 0,
  "world_type"     boolean,
  CONSTRAINT "conversation_sessions_pkey" PRIMARY KEY (id)
);

ALTER TABLE "public"."session"
  ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."conversation_messages"
  ADD COLUMN "recurso_id" uuid NOT NULL;

ALTER TABLE "public"."resources"
  ADD COLUMN "category" character varying NOT NULL;

ALTER TABLE "public"."session"
  ADD CONSTRAINT "conversation_sessions_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

ALTER TABLE "public"."conversation_messages"
  ADD CONSTRAINT "fk_conversation_messages_session_resource" FOREIGN KEY (session_id, recurso_id) REFERENCES public.session_resource(sesion_id, recurso_id) ON DELETE CASCADE;

ALTER TABLE "public"."session_resource"
  ADD CONSTRAINT "session_resource_recurso_id_fkey" FOREIGN KEY (recurso_id) REFERENCES public.resources(id);

ALTER TABLE "public"."session_resource"
  ADD CONSTRAINT "session_resource_sesion_id_fkey" FOREIGN KEY (sesion_id) REFERENCES public.session(id);

ALTER TABLE "public"."user_evaluations"
  ADD CONSTRAINT "user_evaluations_session_id_fkey" FOREIGN KEY (session_id) REFERENCES public.session(id) ON UPDATE CASCADE ON DELETE CASCADE;

CREATE POLICY "own messages" ON "public"."conversation_messages"
  FOR SELECT
  TO PUBLIC
  USING ((EXISTS ( SELECT 1
   FROM public.session s
  WHERE ((s.id = conversation_messages.session_id) AND (s.user_id = auth.uid())))));

CREATE POLICY "own sessions" ON "public"."session"
  FOR ALL
  TO PUBLIC
  USING ((auth.uid() = user_id))
  WITH CHECK ((auth.uid() = user_id));

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."session" TO "anon", "authenticated", "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."session_resource" TO "anon", "authenticated", "postgres", "service_role";

-- ============================================================
-- Origen: 20260928121900_v1.0.sql
-- ============================================================
DROP POLICY "own messages" ON "public"."conversation_messages";

ALTER TABLE "public"."conversation_messages"
  DROP CONSTRAINT "fk_conversation_messages_session_resource";

ALTER TABLE "public"."session"
  DROP CONSTRAINT "conversation_sessions_user_id_fkey";

ALTER TABLE "public"."session_resource"
  DROP CONSTRAINT "session_resource_pkey";

ALTER TABLE "public"."session_resource"
  DROP CONSTRAINT "session_resource_recurso_id_fkey";

ALTER TABLE "public"."session_resource"
  DROP CONSTRAINT "session_resource_sesion_id_fkey";

ALTER TABLE "public"."user_evaluations"
  DROP CONSTRAINT "user_evaluations_session_id_fkey";

ALTER TABLE "public"."conversation_messages"
  DROP COLUMN "recurso_id";

ALTER TABLE "public"."conversation_messages"
  DROP COLUMN "session_id";

DROP TABLE "public"."session";

CREATE TABLE "public"."sessions" (
  "id"             uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "user_id"        uuid                     NOT NULL,
  "started_at"     timestamp with time zone NOT NULL DEFAULT now(),
  "ended_at"       timestamp with time zone,
  "level_at_start" public.learner_level     NOT NULL,
  "xp_earned"      integer                  NOT NULL DEFAULT 0,
  "world_type"     boolean,
  CONSTRAINT "conversation_sessions_pkey" PRIMARY KEY (id)
);

ALTER TABLE "public"."sessions"
  ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."conversation_messages"
  ADD COLUMN "session_resource_id" uuid NOT NULL;

ALTER TABLE "public"."session_resource"
  ADD COLUMN "id" uuid NOT NULL DEFAULT gen_random_uuid();

ALTER TABLE "public"."session_resource"
  ADD CONSTRAINT "session_resource_pkey" PRIMARY KEY (id);

ALTER TABLE "public"."conversation_messages"
  ADD CONSTRAINT "conversation_messages_session_id_fkey" FOREIGN KEY (session_resource_id) REFERENCES public.session_resource(id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE "public"."session_resource"
  ADD CONSTRAINT "session_resource_recurso_id_fkey" FOREIGN KEY (recurso_id) REFERENCES public.resources(id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE "public"."session_resource"
  ADD CONSTRAINT "session_resource_sesion_id_fkey" FOREIGN KEY (sesion_id) REFERENCES public.sessions(id);

ALTER TABLE "public"."sessions"
  ADD CONSTRAINT "conversation_sessions_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

ALTER TABLE "public"."user_evaluations"
  ADD CONSTRAINT "user_evaluations_session_id_fkey" FOREIGN KEY (session_id) REFERENCES public.sessions(id) ON UPDATE CASCADE ON DELETE CASCADE;

CREATE POLICY "own messages" ON "public"."conversation_messages"
  FOR SELECT
  TO PUBLIC
  USING ((EXISTS ( SELECT 1
   FROM public.sessions s
  WHERE ((s.id = conversation_messages.session_resource_id) AND (s.user_id = auth.uid())))));

CREATE POLICY "Users can only link resources to their own sessions" ON "public"."session_resource"
  FOR INSERT
  TO PUBLIC
  WITH CHECK ((EXISTS ( SELECT 1
   FROM public.sessions
  WHERE ((sessions.id = session_resource.sesion_id) AND (sessions.user_id = auth.uid())))));

CREATE POLICY "Users can only update their own sessions" ON "public"."sessions"
  FOR UPDATE
  TO PUBLIC
  USING ((auth.uid() = user_id));

CREATE POLICY "own sessions" ON "public"."sessions"
  FOR ALL
  TO PUBLIC
  USING ((auth.uid() = user_id))
  WITH CHECK ((auth.uid() = user_id));

COMMENT ON TABLE "public"."sessions" IS 'En world type 0 = mundo abierto, 1 = mundo cerrado';

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."sessions" TO "anon", "authenticated", "postgres", "service_role";

-- ============================================================
-- Origen: 20260928123225_add_scene_resources.sql
-- ============================================================
INSERT INTO "public"."resources" ("type", "name", "category", "difficulty", "xp_earned")
VALUES
  ('mercat', 'scene', 'escenari', 'principiant', 10),
  ('bar', 'scene', 'escenari', 'principiant', 10),
  ('oficina', 'scene', 'escenari', 'principiant', 10),
  ('ajuntament', 'scene', 'escenari', 'principiant', 10),
  ('oficina de turisme', 'scene', 'escenari', 'principiant', 10);

-- ============================================================
-- Origen: 20260929000000_fix_new_user_trigger_no_scenario_progress.sql
-- ============================================================
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

-- ============================================================
-- Origen: 20260929081233_reset_and_seed_resources.sql
-- ============================================================
-- 1. Vaciar la tabla existente
TRUNCATE TABLE resources RESTART IDENTITY CASCADE;

-- 2. Insertar los 6 recursos de escenarios
INSERT INTO resources (name, type, category, difficulty, xp_earned, content, metadata)
VALUES
  (
    'Comprar fruita al mercat central',
    'mercat',
    'escenari',
    'principiant',
    15,
    'Practica com demanar fruita, preguntar el preu i pagar en una parada de mercat.',
    '{
      "scenario": "mercat",
      "character_role": "Venedor del mercat",
      "initial_prompt": "Bon dia! Què et pose hui? Tenim unes taronges boníssimes."
    }'::jsonb
  ),
  (
    'Primer dia a l''oficina',
    'oficina',
    'escenari',
    'principiant',
    15,
    'Presenta''t als teus companys, demana indicacions sobre el lloc de treball i les tasques bàsiques.',
    '{
      "scenario": "oficina",
      "character_role": "Company de feina",
      "initial_prompt": "Hola! Benvingut a l''equip. Jo sóc en Marc. Si necessites qualsevol cosa amb l''ordinador o els accessos, dis-me''l."
    }'::jsonb
  ),
  (
    'Demanar un café i esmorzar al bar',
    'bar',
    'escenari',
    'intermedi',
    25,
    'Aprèn a demanar begudes, esmorzars típics, demanar el compte i pagar.',
    '{
      "scenario": "bar",
      "character_role": "Cambrer",
      "initial_prompt": "Hola! Què prens per a esmorzar? Un tallat, un café amb llet o potser un entrepà?"
    }'::jsonb
  ),
  (
    'Tràmits i empadronament a l''ajuntament',
    'ajuntament',
    'escenari',
    'intermedi',
    25,
    'Sol·licita el certificat d''empadronament, demana informació sobre documentació i taxes.',
    '{
      "scenario": "ajuntament",
      "character_role": "Funcionari d''atenció ciutadana",
      "initial_prompt": "Bona vesprada. Com el puc ajudar? Ha demanat cita prèvia per al tràmit d''empadronament?"
    }'::jsonb
  ),
  (
    'Reunió de tutoria a l''escola',
    'colegi',
    'escenari',
    'avancat',
    40,
    'Comenta el progrés acadèmic, resol dubtes sobre metodologies i planteja objectius del curs.',
    '{
      "scenario": "escola",
      "character_role": "Tutor escolar",
      "initial_prompt": "Molt bon dia. Gràcies per vindre a la tutoria. Volia comentar com ha començat el curs i els objectius que tenim plantejats."
    }'::jsonb
  ),
  (
    'Demanar informació a l''oficina de turisme',
    'turisme',
    'escenari',
    'intermedi',
    25,
    'Pregunta per monuments d''interés, rutes a peu, recomanacions locals i horaris de museus.',
    '{
      "scenario": "turisme",
      "character_role": "Guia de l''oficina de turisme",
      "initial_prompt": "Hola, bon dia! Benvingut a la ciutat. Busques informació sobre llocs d''interés, o t''agradaria alguna recomanació per a visitar hui?"
    }'::jsonb
  );

-- ============================================================
-- Origen: 20260929100000_fix_handle_new_user_scenario_progress.sql
-- ============================================================
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

-- ============================================================
-- Origen: 20260929120000_evaluacio_per_recurs.sql
-- ============================================================
-- L'avaluació pedagògica passa de disparar-se en tancar tota la sessió a disparar-se
-- en tancar cada recurs individual (botó "Eixir" de l'escenari). Cal per tant poder
-- filtrar els errors i les avaluacions per session_resource_id, cosa que ara mateix
-- no era possible: user_errors només penjava de message_id i user_evaluations de
-- session_id, cap dels dos apuntava al recurs concret.

-- 1. user_errors: afegim session_resource_id (denormalitzat des de conversation_messages)
--    perquè es puga filtrar directament pels errors d'un recurs concret sense fer join.
ALTER TABLE "public"."user_errors"
  ADD COLUMN "session_resource_id" uuid;

UPDATE "public"."user_errors" ue
SET "session_resource_id" = cm.session_resource_id
FROM "public"."conversation_messages" cm
WHERE cm.id = ue.message_id;

ALTER TABLE "public"."user_errors"
  ALTER COLUMN "session_resource_id" SET NOT NULL;

ALTER TABLE "public"."user_errors"
  ADD CONSTRAINT "user_errors_session_resource_id_fkey" FOREIGN KEY (session_resource_id) REFERENCES public.session_resource(id) ON DELETE CASCADE;

CREATE INDEX idx_user_errors_session_resource_id ON public.user_errors USING btree (session_resource_id, resolved);

-- 2. user_evaluations: substituïm session_id (sessió completa) per session_resource_id
--    (el recurs concret que s'acaba d'avaluar) i recuperem user_id (eliminat en
--    20260925150358) per a poder consultar l'historial complet d'un usuari sense
--    haver de saltar per sessions/session_resource.
ALTER TABLE "public"."user_evaluations"
  ADD COLUMN "session_resource_id" uuid;

ALTER TABLE "public"."user_evaluations"
  ADD COLUMN "user_id" uuid;

UPDATE "public"."user_evaluations" ue
SET "user_id" = s.user_id
FROM "public"."sessions" s
WHERE s.id = ue.session_id;

ALTER TABLE "public"."user_evaluations"
  DROP CONSTRAINT "user_evaluations_session_id_fkey";

ALTER TABLE "public"."user_evaluations"
  DROP COLUMN "session_id";

ALTER TABLE "public"."user_evaluations"
  ADD CONSTRAINT "user_evaluations_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

ALTER TABLE "public"."user_evaluations"
  ADD CONSTRAINT "user_evaluations_session_resource_id_fkey" FOREIGN KEY (session_resource_id) REFERENCES public.session_resource(id) ON DELETE CASCADE;

DROP INDEX IF EXISTS "public"."idx_user_evaluations_user_created";

CREATE INDEX idx_user_evaluations_user_created ON public.user_evaluations USING btree (user_id, created_at DESC);

CREATE INDEX idx_user_evaluations_session_resource_id ON public.user_evaluations USING btree (session_resource_id);

-- ============================================================
-- Origen: 20260929140000_scenarios_in_resources.sql
-- ============================================================
-- Els escenaris passen a definir-se a la BDD: resources.metadata guarda
-- l'aparença de la secció (icon, color, section_name, background) i el
-- personatge del xat (character, system_prompt, objectius, voice).
-- Un recurs de category 'escenari' amb system_prompt és jugable sense tocar codi.
--
-- Els valors ja presents a metadata tenen prioritat (no es trepitgen els canvis
-- fets a mà); només s'omplin les claus que falten.
UPDATE resources SET metadata = v.data || coalesce(resources.metadata, '{}'::jsonb)
FROM (VALUES
  ('mercat', $json${"section_name": "El Mercat", "character": "Vicent, venedor del mercat", "system_prompt": "Ets Vicent, un venedor amable d'un mercat valencià. Mantín una conversa natural per ajudar la persona a comprar fruita, verdura o ingredients. Usa vocabulari viu del mercat (parada, quilo, fresc, canvi) i valencià general. Adapta frases, velocitat i vocabulari al nivell de l'aprenent: principiant usa frases breus; intermedi amplia preguntes; avançat usa registre espontani. No faces lliçons llargues: respon com Vicent i, si cal, corregeix suaument amb un exemple. Avalua si la resposta està per sota, al nivell o per damunt del seu nivell. El teu objectiu és que continue la conversa.", "objectius": ["Saluda a Vicent i pregunta com va tot.", "Demana un quilo de taronges o una altra fruita.", "Pregunta el preu o demana el canvi.", "Paga, dona les gràcies i acomiada't."], "voice": "lluc", "background": "/images/market.jpg"}$json$::jsonb),
  ('bar', $json${"section_name": "El Bar", "character": "Maria, cambrera", "system_prompt": "Ets Maria, una cambrera propera d'un bar valencià. Practica com demanar, preguntar i pagar amb naturalitat. Ajusta el registre al nivell i guia amb preguntes curtes.", "objectius": ["Saluda a Maria i busca una taula.", "Demana una beguda o el desdejuni del dia.", "Pregunta quant és o demana el compte.", "Paga, dona les gràcies i acomiada't."], "voice": "gina", "background": "/images/bar.jpg"}$json$::jsonb),
  ('oficina', $json${"section_name": "L'Oficina", "character": "Joan, company d'oficina", "system_prompt": "Ets Joan, un company d'una oficina moderna. Conversa sobre reunions, tasques i horaris en valencià. Adapta't al nivell i corregeix amb tacte.", "objectius": ["Saluda a Joan i pregunta com està.", "Pregunta per la reunió o les tasques d'avui.", "Demana ajuda o un aclariment sobre un tema.", "Confirma el que has de fer i acomiada't."], "voice": "lluc", "background": "/images/office.jpg"}$json$::jsonb),
  ('ajuntament', $json${"section_name": "L'Ajuntament", "character": "Amparo, funcionària d'atenció", "system_prompt": "Ets Amparo, funcionària d'atenció ciutadana a l'ajuntament.\n- To i personalitat: Amable, eficient i professional. Utilitza un valencià formal estàndard però accessible i clar (tractament de vosté o de tu respectuós segons l'aprenent).\n- Regla d'interacció: Fes respostes breus (màxim 2-3 frases per torn). No resolgues el tràmit tot d'una: fes preguntes de seguiment pas a pas per obligar l'aprenent a intervindre i avançar en els seus objectius.\n- Immersió: Mai no te'n vages del personatge. Si l'aprenent fa un error lingüístic o un castellanisme, no el corregisques directament com un docent; reformula-ho amb naturalitat dins de la teua resposta institucional.\n- Adaptació al nivell:\n  * Si el nivell és inicial (A1-A2): Usa vocabulari senzill, frases curtes i opcions guiades (\"Vol demanar cita prèvia o el certificat d'empadronament?\").\n  * Si el nivell és avançat (B2-C1): Empra fórmules administratives genuïnes (\"instància\", \"taxa municipal\", \"termini de presentació\", \"acreditació\").", "objectius": ["Saluda a Amparo i digues què necessites.", "Explica el tràmit que vols fer.", "Pregunta els requisits o els horaris.", "Dona les gràcies i acomiada't."], "voice": "gina", "background": "/images/townhall.jpg"}$json$::jsonb),
  ('colegi', $json${"section_name": "L'Escola", "character": "Marta, mestra", "system_prompt": "Ets Marta, una mestra amable d'una escola valenciana. Practica converses d'aula: saludar, demanar permís, preguntar dubtes, explicar tasques i parlar de les assignatures. Usa vocabulari escolar (pissarra, llibre, deures, examen, pati) i valencià general. Adapta't al nivell de l'aprenent: principiant usa frases breus i clares; intermedi amplia amb preguntes; avançat usa registre docent espontani. No faces lliçons llargues: respon com Marta i, si cal, corregeix suaument amb un exemple. Avalua si la resposta està per sota, al nivell o per damunt del seu nivell. El teu objectiu és que continue la conversa.", "objectius": ["Saluda a Marta i pregunta com està.", "Pregunta pels deures o la tasca d'avui.", "Demana permís o explica un dubte.", "Dona les gràcies i acomiada't."], "voice": "gina", "background": "/images/classroom.jpg"}$json$::jsonb),
  ('turisme', $json${"section_name": "Oficina de Turisme", "character": "Laura, guia turística", "system_prompt": "Ets Laura, una guia turística simpàtica de l'Oficina de Turisme de València. Ajuda la persona a descobrir la ciutat en valencià: recomana monuments, museus, platges i festes populars; explica horaris, preus i com arribar-hi; i pregunta què li agradaria visitar. Usa vocabulari turístic viu (visita guiada, entrada, horari, plaça, monument, platja, mapa, follet) i valencià general. Adapta't al nivell de l'aprenent: principiant usa frases breus i clares; intermedi amplia amb preguntes; avançat usa registre espontani. No faces guies llargues: respon com Laura i, si cal, corregeix suaument amb un exemple. Avalua si la resposta està per sota, al nivell o per damunt del seu nivell. El teu objectiu és que continue la conversa.", "objectius": ["Saluda a Laura i digues què busques.", "Demana una recomanació de lloc per a visitar.", "Pregunta horaris, preus o com arribar-hi.", "Dona les gràcies i acomiada't."], "voice": "gina", "background": "/images/tourism.jpg"}$json$::jsonb),
  ('farmacia', $json${"section_name": "La Farmàcia", "character": "Pau, farmacèutic", "voice": "lluc", "system_prompt": "Ets Pau, un farmacèutic amable d'una farmàcia de barri valenciana. Ajuda la persona a explicar què li passa, demanar un medicament o presentar una recepta. Usa vocabulari de farmàcia (recepta, pastilles, xarop, dosi, símptomes, mal de cap, refredat) i valencià general. Fes preguntes curtes per saber els símptomes i recomana amb prudència; si és greu, aconsella anar al metge. Adapta't al nivell de l'aprenent: principiant usa frases breus i clares; intermedi amplia amb preguntes; avançat usa registre espontani. No faces explicacions llargues: respon com Pau i, si cal, corregeix suaument amb un exemple. El teu objectiu és que continue la conversa.", "objectius": ["Saluda a Pau i explica què et passa.", "Demana un medicament o dona la recepta.", "Pregunta com i quan cal prendre-ho.", "Paga, dona les gràcies i acomiada't."]}$json$::jsonb)
) AS v(type, data)
WHERE resources.category = 'escenari' AND resources.type = v.type;

-- apply_turn_xp depenia de l'enum scenario_key i de conversation_sessions /
-- scenario_progress, que ja no existixen. Ara només suma XP al perfil i a la sessió.
DROP FUNCTION IF EXISTS public.apply_turn_xp(uuid, uuid, public.scenario_key, integer, integer);

CREATE OR REPLACE FUNCTION public.apply_turn_xp(p_user_id uuid, p_session_id uuid, p_xp_delta integer)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  UPDATE profiles SET xp = xp + p_xp_delta, updated_at = now() WHERE id = p_user_id;
  UPDATE sessions SET xp_earned = xp_earned + p_xp_delta WHERE id = p_session_id AND user_id = p_user_id;
END
$$;

