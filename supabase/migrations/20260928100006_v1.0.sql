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
