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
