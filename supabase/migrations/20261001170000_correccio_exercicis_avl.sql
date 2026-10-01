-- Correcció dels exercicis B1 de Morfosintaxi que contradeien les gramàtiques de
-- l'AVL (GVB i GNV, en assets-src/avl/), detectats en redactar les lliçons fixes
-- («Aprendre lliçó»): respostes incorrectes i distractors que l'AVL accepta com a
-- correctes. Cada fila substituïx l'enunciat, les opcions, les respostes i
-- l'explicació de l'exercici (recurs, nivell, posició). La resposta correcta va
-- primer, com en la resta d'exercicis. Tornar a aplicar el fitxer no canvia res més.

UPDATE public.practice_exercises e SET
  prompt = f.prompt,
  options = ARRAY(SELECT jsonb_array_elements_text(f.options)),
  answers = ARRAY(SELECT jsonb_array_elements_text(f.answers)),
  explanation = f.explanation
FROM jsonb_to_recordset($data$[
  {"type": "b1_mor_pronoms_cd_ci", "pos": 24,
   "prompt": "«Porta'ns la cadira.» → «Porta___!»",
   "options": ["'ns-la", "-nos-la", "-la-nos"], "answers": ["'ns-la"],
   "explanation": "Darrere d'un verb acabat en vocal, nos es reduïx a 'ns: Porta'ns-la (GVB 26.4.2). La forma -nos-la va darrere de consonant: portar-nos-la."},
  {"type": "b1_mor_quantitatius_indefinits", "pos": 9,
   "prompt": "«Només ha collit ___ d'olives.» (poca quantitat)",
   "options": ["una miqueta", "un fum", "un muntó"], "answers": ["una miqueta"],
   "explanation": "Una miqueta de indica poca quantitat. Un fum de, un muntó de i un grapat de indiquen molta quantitat (GVB 23.5)."},
  {"type": "b1_mor_adverbis", "pos": 13,
   "prompt": "Quina és correcta?",
   "options": ["Parlava tranquil·lament i lentament.", "Parlava lenta i tranquil·lament.", "Parlava lenta i tranquil·la."], "answers": ["Parlava tranquil·lament i lentament."],
   "explanation": "Quan es coordinen adverbis en -ment, es pot llevar la terminació del segon (tranquil·lament i lenta), mai del primer; i hui és més habitual mantindre-la en tots dos (GVB 34.2)."},
  {"type": "b1_mor_numerals", "pos": 10,
   "prompt": "«Tinc ___ germanes.» (2, forma femenina)",
   "options": ["dues", "dós", "dúes"], "answers": ["dues"],
   "explanation": "El femení de dos és dues, especialment en registres formals (també s'admet dos germanes). Cap de les dues formes porta accent (GVB 22.2.4)."},
  {"type": "b1_mor_preposicions", "pos": 19,
   "prompt": "«Ara estic ___ casa.»",
   "options": ["a (o en)", "dins", "de"], "answers": ["a (o en)"],
   "explanation": "Per a dir on estàs, davant de casa sense article l'AVL usa en (m'haguera quedat en casa, GVB 15.4), i també és molt habitual a. Amb moviment, a: Torne a casa."},
  {"type": "b1_mor_preposicions", "pos": 20,
   "prompt": "«Els alumnes estan ___ classe.»",
   "options": ["a (o en)", "de", "per"], "answers": ["a (o en)"],
   "explanation": "Davant d'un nom sense article que indica on és algú, s'usa en o a: estan en classe / a classe. Amb moviment, a: Vaig a classe."},
  {"type": "b1_mor_preposicions", "pos": 22,
   "prompt": "Quina és correcta?",
   "options": ["Conec la teua germana des de fa anys.", "Conec a la teua germana des de fa anys.", "Conec de la teua germana des de fa anys."], "answers": ["Conec la teua germana des de fa anys."],
   "explanation": "El complement directe va sense preposició, encara que siga una persona: Conec la teua germana. Davant d'un nom propi sense article, la a és opcional: Conec (a) Marta (GNV 32.2)."},
  {"type": "b1_mor_regim", "pos": 19,
   "prompt": "«El joc consistix ___ endevinar la paraula.»",
   "options": ["a", "de", "per"], "answers": ["a"],
   "explanation": "Consistir davant d'infinitiu porta a: La prova consistix a alçar un sac de ciment (GVB 34.5.21)."},
  {"type": "b1_mor_regim", "pos": 28,
   "prompt": "«Està interessat ___ la feina.»",
   "options": ["per (o en)", "a", "de"], "answers": ["per (o en)"],
   "explanation": "Interessar-se i estar interessat porten per (persones interessades per la llengua, GVB 13.3.5); també és habitual en."},
  {"type": "b1_mor_substantius", "pos": 33,
   "prompt": "Quin és un plural correcte de «bosc»?",
   "options": ["boscos", "bosques", "bosquis"], "answers": ["boscos"],
   "explanation": "Els noms acabats en -sc fan el plural en -os o en -s: boscos o boscs; totes dues formes són correctes (GVB 17.2)."},
  {"type": "b1_mor_verbs_irregulars", "pos": 22,
   "prompt": "«Ahir ell ___ els deures.» (fer, passat simple)",
   "options": ["feu", "fiu", "fa"], "answers": ["feu"],
   "explanation": "Passat simple de fer: fiu, feres, feu, férem, féreu, feren (GNV 30.2.4.3). En la parla és més habitual el perifràstic: va fer."}
]$data$::jsonb) AS f(type text, pos smallint, prompt text, options jsonb, answers jsonb, explanation text)
WHERE e.level = 'B1'
  AND e.position = f.pos
  AND e.resource_id = (SELECT r.id FROM public.resources r WHERE r.category = 'morfosintaxi' AND r.type = f.type);
