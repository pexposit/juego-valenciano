-- Puntuació oficial de l'Àrea 1 (comprensió oral) dels exàmens A2 (JQCV):
-- 10 preguntes, cada encert val 10 punts → màxim 100 punts, apte amb 50 o més
-- (5 encerts). Per davall del mínim, quedes fora de la prova.
-- S'aplica a tots els exàmens A2 (juny 2026, octubre 2025, 2024 i 2023).
UPDATE public.resources
SET metadata = jsonb_set(metadata, '{exam,areas,0,scoring}', '{"points_per_correct": 10, "max_points": 100, "pass_points": 50}')
WHERE category = 'examen'
  AND metadata #>> '{exam,level}' = 'A2'
  AND metadata #>> '{exam,areas,0,n}' = '1';
