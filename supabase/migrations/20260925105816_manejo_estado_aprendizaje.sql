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
