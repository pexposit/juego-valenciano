-- Puntuació oficial de l'examen A1 (JQCV): cada encert es multiplica per un factor
-- i el resultat s'arredonix. Per davall del mínim d'una àrea, quedes fora de la prova.
--   Àrea 1 (comprensió oral):    encerts × 1,667 → màxim 30 punts, apte amb 15 o més.
--   Àrea 2 (comprensió escrita): encerts × 1,389 → màxim 25 punts, apte amb 13 o més.
UPDATE public.resources
SET metadata = jsonb_set(
      jsonb_set(metadata, '{exam,areas,0,scoring}', '{"points_per_correct": 1.667, "max_points": 30, "pass_points": 15}'),
      '{exam,areas,1,scoring}', '{"points_per_correct": 1.389, "max_points": 25, "pass_points": 13}')
WHERE id = 'cd809f6e-a233-4030-892f-45907219fd77'
  AND metadata #>> '{exam,areas,0,n}' = '1'
  AND metadata #>> '{exam,areas,1,n}' = '2';
