-- Contingut de les infografies de l'exercici 7 dels exàmens B1 (resources.metadata
-- ...exercises[].image_text): l'avaluador amb IA no veu la imatge, però l'enunciat
-- demana tindre-la en compte. Transcrit de frontend/public/exams/b1-*/e7-*.jpg.
UPDATE public.resources
SET metadata = jsonb_set(metadata, '{exam,areas,2,exercises,1,image_text}', to_jsonb(
  'Infografia «Rutina diària per a reduir l''estrés». Consells: no utilitzes el mòbil només despertar-te; respiració conscient; estiraments; pensa en les coses positives del dia; ordena les prioritats; música suau o relaxant.'::text))
WHERE category = 'examen'
  AND metadata #>> '{exam,areas,2,exercises,1,image}' = '/exams/b1-juny-2026/e7-estres.jpg';

UPDATE public.resources
SET metadata = jsonb_set(metadata, '{exam,areas,2,exercises,1,image_text}', to_jsonb(
  'Infografia «Desconnecta (de veritat) en el viatge», sobre la pantalla d''un mòbil. Consells: desactiva les notificacions; allunya''t del mòbil; deixa el carregador en casa; utilitza un rellotge tradicional.'::text))
WHERE category = 'examen'
  AND metadata #>> '{exam,areas,2,exercises,1,image}' = '/exams/b1-octubre-2025/e7-desconnecta.jpg';

UPDATE public.resources
SET metadata = jsonb_set(metadata, '{exam,areas,2,exercises,1,image_text}', to_jsonb(
  'Infografia «Saps com estalviar aigua en la faena?» (campanya «Polits + Sans»). Consells: tanca bé l''aixeta (una gota per segon representa 30 litres diaris); no utilitzes el vàter com si fora una paperera; utilitza el polsador de descàrrega curta de la cisterna del vàter; avisa a manteniment si detectes fugues o avaries en aixetes, cisternes o depòsits.'::text))
WHERE category = 'examen'
  AND metadata #>> '{exam,areas,2,exercises,1,image}' = '/exams/b1-octubre-2024/e7-aigua.jpg';
