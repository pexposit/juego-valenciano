-- Correcció dels exercicis B1 de Fonètica, elocució i ortografia que contradeien
-- les gramàtiques de l'AVL (GVB i GNV, en assets-src/avl/), detectats en redactar
-- les lliçons fixes («Aprendre lliçó»). Cada fila substituïx l'enunciat, les
-- opcions, les respostes i l'explicació de l'exercici (recurs, nivell, posició).
-- La resposta correcta va primer. Tornar a aplicar el fitxer no canvia res més.

UPDATE public.practice_exercises e SET
  prompt = f.prompt,
  options = CASE WHEN f.options IS NULL OR jsonb_typeof(f.options) = 'null' THEN NULL ELSE ARRAY(SELECT jsonb_array_elements_text(f.options)) END,
  answers = ARRAY(SELECT jsonb_array_elements_text(f.answers)),
  explanation = f.explanation
FROM jsonb_to_recordset($data$[
  {"type": "b1_fon_puntuacio", "pos": 25,
   "prompt": "Quina frase usa bé el punt i coma en una llista de dades?",
   "options": ["Han vingut Joan, de Gandia; Marta, d'Alcoi, i Pere, de Xàtiva.", "Han vingut Joan; de Gandia, Marta; d'Alcoi, i Pere; de Xàtiva.", "Han vingut; Joan, de Gandia, Marta, d'Alcoi, i Pere, de Xàtiva."], "answers": ["Han vingut Joan, de Gandia; Marta, d'Alcoi, i Pere, de Xàtiva."],
   "explanation": "El punt i coma separa grups que ja porten comes, excepte l'últim element precedit de i, que va amb coma (GVB 15.4)."},
  {"type": "b1_fon_puntuacio", "pos": 5,
   "prompt": "Quina frase usa bé els dos punts per a una cita?",
   "options": ["Ma mare va dir: «Torna prompte».", "Ma mare: va dir «Torna prompte».", "Ma mare va: dir «Torna prompte»."], "answers": ["Ma mare va dir: «Torna prompte»."],
   "explanation": "Els dos punts introduïxen la cita. Com que les cometes s'obrin dins de la frase, el punt va darrere de les cometes de tancament (GVB 15.6 i 15.13.2)."},
  {"type": "b1_fon_puntuacio", "pos": 13,
   "prompt": "Què indiquen els punts suspensius entre claudàtors [...] dins d'una cita?",
   "options": ["Que s'ha omés un tros del text", "Que l'autor dubtava", "Que la cita és falsa"], "answers": ["Que s'ha omés un tros del text"],
   "explanation": "Dins d'una cita, els punts suspensius entre claudàtors, [...], indiquen que se n'ha omés una part (GVB 15.7 i 15.12)."},
  {"type": "b1_fon_majuscules", "pos": 31,
   "prompt": "Quina és correcta?",
   "options": ["Han aprovat la llei en les Corts valencianes.", "Han aprovat la Llei en les corts valencianes.", "Han aprovat la llei en les corts Valencianes."], "answers": ["Han aprovat la llei en les Corts valencianes."],
   "explanation": "Corts, com a nom de la institució, va amb majúscula; l'adjectiu valencianes, en minúscula (GVB 12.17). La paraula llei, si no és el títol d'una llei concreta, va en minúscula."},
  {"type": "b1_fon_majuscules", "pos": 32,
   "prompt": "Quina és correcta?",
   "options": ["Cada ajuntament té el seu pressupost.", "Cada Ajuntament té el seu Pressupost.", "cada ajuntament té el seu pressupost."], "answers": ["Cada ajuntament té el seu pressupost."],
   "explanation": "Quan ajuntament s'usa en sentit general, va en minúscula; amb majúscula només quan es referix a una institució concreta: l'Ajuntament d'Alzira (GVB 12.16). La frase comença amb majúscula."},
  {"type": "b1_fon_vocals", "pos": 37,
   "prompt": "Quina parella es distingix per la e oberta / e tancada?",
   "options": ["set (el número 7) / set (ganes de beure)", "dona / dones", "porta / portes"], "answers": ["set (el número 7) / set (ganes de beure)"],
   "explanation": "Set, el número, té e oberta [ɛ]; set, les ganes de beure, e tancada [e]. En canvi, sòl i sol tenen totes dues o oberta: l'accent de sòl és diacrític (GVB 7.7)."},
  {"type": "b1_fon_alfabet", "pos": 35,
   "prompt": "Quina d'estes paraules té el dígraf «ig»?",
   "options": ["roig", "rotg", "roitg"], "answers": ["roig"],
   "explanation": "El dígraf ig representa el so final de roig, lleig o maig (GVB 4.2). En canvi, en peix o caixa la i forma part del grup ix, que l'AVL no compta com a dígraf."},
  {"type": "b1_fon_elocucio", "pos": 14,
   "prompt": "La z de «zero» o «onze» en valencià sona...",
   "options": ["sonora, com la s de «casa»", "com la z castellana de «zapato»", "muda"], "answers": ["sonora, com la s de «casa»"],
   "explanation": "La z valenciana és sonora [z], com la s entre vocals de casa o rosa. La tz de dotze o tretze sona [dz] (GVB 6.15 i 6.16)."},
  {"type": "b1_fon_elocucio", "pos": 5,
   "prompt": "En «Està a casa», com sona la seqüència «està a»?",
   "options": ["Les dues a es reduïxen a una sola", "Es pronuncia «estàs a»", "S'hi afig una e"], "answers": ["Les dues a es reduïxen a una sola"],
   "explanation": "Quan dues vocals iguals queden en contacte entre paraules, en la parla se'n pronuncia només una: està_a casa (GVB 3.1)."},
  {"type": "b1_fon_elocucio", "pos": 38,
   "prompt": "En molts parlars, quina consonant no es pronuncia en «camp»?",
   "options": null, "answers": ["p"],
   "explanation": "En els parlars on és propi, és acceptable no pronunciar la p de -mp final: camp [kam]. Però sempre s'escriu (GNV 1.3.2.1)."}
]$data$::jsonb) AS f(type text, pos smallint, prompt text, options jsonb, answers jsonb, explanation text)
WHERE e.level = 'B1'
  AND e.position = f.pos
  AND e.resource_id = (SELECT r.id FROM public.resources r WHERE r.category = 'fonetica_ortografia' AND r.type = f.type);
