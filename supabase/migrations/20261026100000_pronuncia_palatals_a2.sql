-- Exercicis de pronúncia («Llig en veu alta»): l'aprenent llig una frase i l'API fonètica del DeepLab de la UJI
-- corregix els sons del contingut. `task.text` és la frase i `task.sounds`, la família de sons (IPA) que es corregix;
-- la resta de sons de la frase no es puntuen. Es comencen per les palatals de l'A2 (J, G, TJ, TG, X, IX, TX), amb
-- frases provades amb la veu gina sense cap fals error. Tornar a aplicar el fitxer no duplica res.

ALTER TABLE public.practice_exercises DROP CONSTRAINT IF EXISTS practice_exercises_kind_check;
ALTER TABLE public.practice_exercises
  ADD CONSTRAINT practice_exercises_kind_check CHECK (kind IN ('choice', 'fill', 'writing', 'form', 'pronunciation'));

ALTER TABLE public.practice_exercises DROP CONSTRAINT IF EXISTS practice_exercises_task_check;
ALTER TABLE public.practice_exercises ADD CONSTRAINT practice_exercises_task_check CHECK (
  (kind <> 'writing' OR task ? 'min_words' AND task ? 'max_words')
  AND (kind <> 'form' OR jsonb_typeof(task -> 'fields') = 'array')
  AND (kind <> 'pronunciation' OR jsonb_typeof(task -> 'text') = 'string' AND jsonb_typeof(task -> 'sounds') = 'array')
);

INSERT INTO public.practice_exercises (resource_id, level, position, kind, prompt, task, explanation)
SELECT '5e910bc3-c0d6-486e-9edc-852f7f7684b2', 'A2', 35 + n, 'pronunciation',
  'Llig la frase en veu alta i fixa''t en els sons palatals.',
  jsonb_build_object('text', text, 'sounds', '["ʃ", "ʒ", "tʃ", "dʒ"]'::jsonb),
  explanation
FROM (VALUES
  (1, 'El meu germà jove viatja a la platja.', 'La j, la g (davant de e, i) i la tj sonen com en «platja», no com la i de «iogurt».'),
  (2, 'La xiqueta menja xocolata dins del cotxe.', 'La x a principi de paraula i la tx sonen com en «cotxe», no com una s.'),
  (3, 'Hi ha un peix dins de la caixa.', 'La ix de «peix» i «caixa» sona xiuxiuejada, no com una s.'),
  (4, 'El metge menja formatge al juliol.', 'La tg de «metge» i «formatge» i la j de «menja» i «juliol» són sons palatals.'),
  (5, 'Al mes de maig fa sol i el cel és roig.', 'La ig a final de paraula («maig», «roig») sona com la tx de «cotxe».'),
  (6, 'La gent juga al jardí de Xàtiva.', 'La g de «gent», la j de «juga» i «jardí» i la X de «Xàtiva» són palatals.')
) AS s(n, text, explanation)
ON CONFLICT (resource_id, level, position) DO NOTHING;

-- Les frases van intercalades entre les preguntes escrites, cadascuna darrere de les del seu so, i no totes al final.
-- La clau d'ordre no depén de les posicions actuals (sí de l'ordre de les preguntes escrites i del text de cada frase):
-- tornar a aplicar-ho deixa el mateix ordre. Primer s'aparten totes fora del rang, perquè la restricció única
-- (resource_id, level, position) no salte a mitja renumeració.
UPDATE public.practice_exercises SET position = position + 1000
WHERE resource_id = '5e910bc3-c0d6-486e-9edc-852f7f7684b2' AND level = 'A2';

WITH placement(text, after_question) AS (VALUES
  ('El meu germà jove viatja a la platja.', 6),
  ('Al mes de maig fa sol i el cel és roig.', 10),
  ('El metge menja formatge al juliol.', 16),
  ('La gent juga al jardí de Xàtiva.', 22),
  ('La xiqueta menja xocolata dins del cotxe.', 28),
  ('Hi ha un peix dins de la caixa.', 33)
),
keyed AS (
  SELECT e.id,
    CASE WHEN e.kind = 'pronunciation' THEN p.after_question * 10 + 5
         ELSE 10 * row_number() OVER (PARTITION BY e.kind = 'pronunciation' ORDER BY e.position) END AS sort_key
  FROM public.practice_exercises e
  LEFT JOIN placement p ON p.text = e.task ->> 'text'
  WHERE e.resource_id = '5e910bc3-c0d6-486e-9edc-852f7f7684b2' AND e.level = 'A2'
),
ranked AS (SELECT id, row_number() OVER (ORDER BY sort_key) AS position FROM keyed)
UPDATE public.practice_exercises e SET position = ranked.position
FROM ranked WHERE e.id = ranked.id;
