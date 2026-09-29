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
