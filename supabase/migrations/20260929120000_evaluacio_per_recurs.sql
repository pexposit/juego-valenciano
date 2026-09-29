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
