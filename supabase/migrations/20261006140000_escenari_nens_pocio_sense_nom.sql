-- Privacitat: en l'escenari infantil del mag i la poció el xiquet ja no ha de dir el seu nom.
-- Merlí només el saluda (no li ho pregunta ni repetix el nom si el diu) i el primer objectiu
-- passa de «Saludar i dir el seu nom» a «Saludar», també en les traduccions. Tornar a aplicar
-- el fitxer no canvia res (els reemplaços són idempotents).

UPDATE public.resources
SET metadata = jsonb_set(
  jsonb_set(
    metadata,
    '{system_prompt}',
    to_jsonb(
      replace(metadata ->> 'system_prompt', 'saluda i pregunta-li com es diu; demana-li', 'saluda''l sense preguntar-li com es diu; demana-li')
      || CASE WHEN metadata ->> 'system_prompt' LIKE '%No li preguntes mai el nom%' THEN ''
         ELSE ' PRIVACITAT: no li preguntes mai el nom ni cap dada personal; si ell diu el seu nom, no el repetisques ni l''useu: crida''l «amic» o «amiga».' END
    )
  ),
  '{objectius,0}', '"Saludar."'::jsonb
)
WHERE category = 'escenari' AND type = 'n0_pocio';

UPDATE public.resources
SET metadata = jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(metadata,
  '{translations,es,objectius,0}', '"Saludar."'),
  '{translations,en,objectius,0}', '"Say hello."'),
  '{translations,fr,objectius,0}', '"Dire bonjour."'),
  '{translations,it,objectius,0}', '"Salutare."'),
  '{translations,ro,objectius,0}', '"Să salute."'),
  '{translations,uk,objectius,0}', '"Привітатися."')
WHERE category = 'escenari' AND type = 'n0_pocio';
