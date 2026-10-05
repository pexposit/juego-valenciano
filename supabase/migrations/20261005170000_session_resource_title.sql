-- Títol de les converses amb el tutor (pestanya «Converses»).
--   * title: el nom que es mostra en la llista.
--   * title_source: 'user' si l'ha escrit l'usuari (no es toca mai més) o 'auto' si
--     l'ha resumit el LLM. NULL = encara no en té.
--   * title_message_count: quants missatges tenia la conversa quan es va resumir; si
--     ha crescut prou, el títol automàtic es torna a generar.
-- Tornar a aplicar el fitxer no canvia res.

ALTER TABLE public.session_resource
  ADD COLUMN IF NOT EXISTS title text,
  ADD COLUMN IF NOT EXISTS title_source text,
  ADD COLUMN IF NOT EXISTS title_message_count integer;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'session_resource_title_source_check') THEN
    ALTER TABLE public.session_resource
      ADD CONSTRAINT session_resource_title_source_check CHECK (title_source IN ('user', 'auto'));
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'session_resource_title_length_check') THEN
    ALTER TABLE public.session_resource
      ADD CONSTRAINT session_resource_title_length_check CHECK (title IS NULL OR char_length(title) BETWEEN 1 AND 80);
  END IF;
END
$$;
