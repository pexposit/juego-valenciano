-- Puntuació oficial de l'Àrea 1 (comprensió oral) dels exàmens B1 (JQCV),
-- sobre 100 punts i amb un valor diferent per a cada exercici:
--   Exercici 1 (verdader/fals, 5 preguntes):    6 punts per encert → 30 punts.
--   Exercici 2 (opció múltiple, 5 preguntes):   6 punts per encert → 30 punts.
--   Exercici 3 (ordenar 5 dels 7 enunciats):    8 punts per encert → 40 punts.
-- En l'exercici 3, els dos enunciats «No surt» (resposta 'x') es corregixen en
-- pantalla però no puntuen: només compten els 5 que apareixen en l'àudio.
-- Eliminatòria per si mateixa: apte amb 50 punts o més; de 0 a 49, quedes fora de la prova.
-- S'aplica a tots els exàmens B1 (juny 2026, octubre 2025 i 2024).
UPDATE public.resources
SET metadata = jsonb_set(
      jsonb_set(metadata, '{exam,areas,0,scoring}',
        '{"points_per_exercise": {"1": 6, "2": 6, "3": 8}, "max_points": 100, "pass_points": 50}'),
      '{exam,areas,0,exercises,2,questions}',
      (SELECT jsonb_agg(CASE WHEN q->>'answer' = 'x' THEN q || '{"scored": false}' ELSE q END ORDER BY i)
       FROM jsonb_array_elements(metadata #> '{exam,areas,0,exercises,2,questions}') WITH ORDINALITY AS t(q, i)))
WHERE category = 'examen'
  AND metadata #>> '{exam,level}' = 'B1'
  AND metadata #>> '{exam,areas,0,n}' = '1'
  AND metadata #>> '{exam,areas,0,exercises,2,n}' = '3';
