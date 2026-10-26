-- Veu de Doraemon (`rvc:doraemon`, del laboratori de veu: Matxa + RVC) per al tutor infantil del tauler i per als
-- escenaris infantils del Nivell 0 (el mag, el zoo, el pati, la biblioteca...). Els escenaris del Nivell 0 per a adults
-- (metadata.audience = 'adult') no la porten: conserven la seua veu.
--
-- El backend envia les veus `rvc:*` al laboratori (SPEECH_LAB_URL) i, si no hi és o no respon, cau a la veu per defecte
-- (gina): sense el laboratori tot continua funcionant, només que amb l'altra veu. Les saludes estàtiques dels
-- escenaris es generen amb `npx tsx scripts/generate-scenario-audio.ts --force` a backend/ (cal el laboratori en marxa).
-- Tornar a aplicar el fitxer no canvia res.

UPDATE public.resources
SET metadata = jsonb_set(metadata, '{voice}', '"rvc:doraemon"'::jsonb)
WHERE (category = 'assistent' AND type = 'ajuda_infantil')
   OR (category = 'escenari'
       AND difficulty = 'nivell0'
       AND coalesce(metadata ->> 'audience', '') <> 'adult');
