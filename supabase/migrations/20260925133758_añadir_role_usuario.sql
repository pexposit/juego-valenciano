ALTER TABLE "public"."profiles"
  ADD COLUMN "role" text NOT NULL DEFAULT 'user'::text;

ALTER TABLE "public"."profiles"
  ADD CONSTRAINT "profiles_role_check" CHECK ((role = ANY (ARRAY['admin'::text, 'user'::text])));
