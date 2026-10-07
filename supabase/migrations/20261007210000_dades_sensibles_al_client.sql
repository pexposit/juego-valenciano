-- Les dades que pot escriure l'usuari (i, per tant, poden ser sensibles) ja no es guarden al
-- servidor: viuen en el navegador de l'usuari (IndexedDB, frontend/src/lib/localStore.ts).
--   * conversation_messages: els missatges de les converses. El client envia l'historial en
--     cada torn i el servidor el fa servir sense guardar-lo.
--   * user_errors: es queda només amb les metadades (categoria, origen, resolt...). La frase
--     de l'usuari, la correcció, l'explicació i el context van al client amb el mateix id.
--   * user_evaluations: es queda només amb el priority_focus (una categoria d'error), que fa
--     servir la ruta d'aprenentatge. El resum i els punts febles van al client.
--   * session_resource: el títol de les converses amb el tutor (resum del LLM o nom posat per
--     l'usuari) passa al client.
-- Les dades que hi havia es perden: no es poden moure al navegador de cada usuari.

DROP TABLE IF EXISTS public.conversation_messages CASCADE;

ALTER TABLE public.user_errors
  DROP COLUMN IF EXISTS message_id,
  DROP COLUMN IF EXISTS error_text,
  DROP COLUMN IF EXISTS correction,
  DROP COLUMN IF EXISTS explanation,
  DROP COLUMN IF EXISTS context;

ALTER TABLE public.user_evaluations
  DROP COLUMN IF EXISTS summary,
  DROP COLUMN IF EXISTS weaknesses;

ALTER TABLE public.session_resource
  DROP CONSTRAINT IF EXISTS session_resource_title_length_check,
  DROP CONSTRAINT IF EXISTS session_resource_title_source_check,
  DROP COLUMN IF EXISTS title,
  DROP COLUMN IF EXISTS title_source,
  DROP COLUMN IF EXISTS title_message_count;
