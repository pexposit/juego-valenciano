-- Puntuació oficial de l'Àrea 2 (comprensió escrita) dels exàmens B1 (JQCV),
-- sobre 100 punts i amb un valor diferent per a cada exercici:
--   Exercici 4 (verdader/fals, 5 preguntes):              8 punts per encert → 40 punts.
--   Exercici 5 (emparellar, 5 preguntes amb 7 opcions):  12 punts per encert → 60 punts.
-- Eliminatòria per si mateixa: apte amb 50 punts o més; de 0 a 49, quedes fora de la prova.
-- S'aplica a tots els exàmens B1 (juny 2026, octubre 2025 i 2024).
UPDATE public.resources
SET metadata = jsonb_set(metadata, '{exam,areas,1,scoring}',
      '{"points_per_exercise": {"4": 8, "5": 12}, "max_points": 100, "pass_points": 50}')
WHERE category = 'examen'
  AND metadata #>> '{exam,level}' = 'B1'
  AND metadata #>> '{exam,areas,1,n}' = '2';
