-- Puntuació oficial de l'Àrea 2 (comprensió escrita) dels exàmens A2 (JQCV),
-- sobre 100 punts i amb un valor diferent per a cada exercici:
--   Exercici 3 (emparellar, 5 preguntes):     8 punts per encert → 40 punts.
--   Exercici 4 (verdader/fals, 5 preguntes):  6 punts per encert → 30 punts.
--   Exercici 5 (opció múltiple, 5 preguntes): 6 punts per encert → 30 punts.
-- Eliminatòria per si mateixa: apte amb 50 punts o més; de 0 a 49, quedes fora de la prova.
-- S'aplica a tots els exàmens A2 (juny 2026, octubre 2025, 2024 i 2023).
UPDATE public.resources
SET metadata = jsonb_set(metadata, '{exam,areas,1,scoring}',
      '{"points_per_exercise": {"3": 8, "4": 6, "5": 6}, "max_points": 100, "pass_points": 50}')
WHERE category = 'examen'
  AND metadata #>> '{exam,level}' = 'A2'
  AND metadata #>> '{exam,areas,1,n}' = '2';
