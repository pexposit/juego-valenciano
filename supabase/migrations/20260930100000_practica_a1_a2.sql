-- Migració agrupada: 20260930100000_practica_a1_a2
-- Conté, per ordre, les 7 migracions originals següents:
--   20260930100000_clear_gramatica_category
--   20260930110000_practice_exercises
--   20260930120000_practice_skills
--   20260930130000_practice_fonetica_more
--   20260930140000_practice_morfosintaxi_more
--   20260930150000_practice_vocabulari
--   20260930160000_practice_lexic_more

-- ============================================================
-- Origen: 20260930100000_clear_gramatica_category.sql
-- ============================================================
-- Buida la categoria "gramatica" del catàleg d'activitats (taula resources).
-- Les files de session_resource (i per cascada els missatges, errors i
-- avaluacions d'eixes sessions) desapareixen amb els recursos.
DELETE FROM public.resources WHERE category = 'gramatica';

-- ============================================================
-- Origen: 20260930110000_practice_exercises.sql
-- ============================================================
-- Pràctica dels continguts lingüístics del temari de la JQCV (Quadern A2, 2024).
-- Cada àrea (4.1 Fonètica i ortografia, 4.2 Morfosintaxi, 4.3 Lèxic i semàntica)
-- és una `category` de resources i cada contingut, un `type`. Els exercicis no
-- van a resources.metadata com els exàmens, sinó a practice_exercises, una fila
-- per exercici i nivell: el catàleg no els carrega i un mateix contingut pot
-- tindre exercicis d'A1, A2, B1... sense duplicar el recurs.

-- Ordre dels continguts dins de cada àrea (el del temari, no l'alfabètic).
ALTER TABLE public.resources ADD COLUMN IF NOT EXISTS sort_order smallint NOT NULL DEFAULT 0;
CREATE INDEX IF NOT EXISTS idx_resources_category_order ON public.resources (category, sort_order, type);

CREATE TABLE IF NOT EXISTS public.practice_exercises (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  resource_id uuid NOT NULL REFERENCES public.resources(id) ON UPDATE CASCADE ON DELETE CASCADE,
  level text NOT NULL CHECK (level IN ('A1', 'A2', 'B1', 'B2', 'C1', 'C2')),
  position smallint NOT NULL,
  -- choice: triar una de les `options` (la correcta és answers[1]);
  -- fill: escriure la resposta, que es compara amb qualsevol de les `answers`.
  kind text NOT NULL CHECK (kind IN ('choice', 'fill')),
  prompt text NOT NULL,
  options text[],
  answers text[] NOT NULL CHECK (cardinality(answers) > 0),
  explanation text,
  -- També és l'índex de la consulta de la pantalla (recurs -> nivell -> ordre).
  CONSTRAINT practice_exercises_position_key UNIQUE (resource_id, level, position),
  CONSTRAINT practice_exercises_choice_check CHECK (
    kind <> 'choice' OR (cardinality(options) >= 2 AND cardinality(answers) = 1 AND answers[1] = ANY (options))
  )
);

-- Només hi accedix el backend (service role), com a resources.
ALTER TABLE public.practice_exercises ENABLE ROW LEVEL SECURITY;

-- Catàleg: {q: enunciat, o: opcions (la primera és la correcta; la pantalla les
-- barreja), e: explicació} o, per a escriure la resposta, {q, a: respostes acceptades, e}.
CREATE TEMP TABLE practice_catalog AS
SELECT * FROM jsonb_to_recordset($data$[
  {
    "id": "5340aadb-100f-428d-a1ad-6d866a54a2e6", "category": "fonetica_ortografia", "type": "tonicitat", "sort_order": 1,
    "title": "Síl·laba tònica", "name": "Tonicitat i atonicitat",
    "content": "Reconeix la síl·laba i la vocal tònica en el vocabulari bàsic.", "icon": "🔊", "color": "#B2EBF2",
    "exercises": [
      {"q": "En quina síl·laba recau l'accent de «fàbrica» (l'edifici)?", "o": ["fà-", "-bri-", "-ca"], "e": "Fàbrica és esdrúixola: la síl·laba tònica és la primera, fà-."},
      {"q": "«El meu veí fabrica mobles.» Quina és la síl·laba tònica de «fabrica»?", "o": ["-bri-", "fa-", "-ca"], "e": "Fa-BRI-ca (verb en present) és plana acabada en vocal: per això no porta accent."},
      {"q": "«Ahir el fuster fabricà una taula.» Quina és la síl·laba tònica de «fabricà»?", "o": ["-cà", "fa-", "-bri-"], "e": "Fa-bri-CÀ és aguda acabada en vocal i porta accent."},
      {"q": "Quina d'estes paraules és aguda (tònica en l'última síl·laba)?", "o": ["sofà", "taula", "música"], "e": "So-FÀ: la força recau en l'última síl·laba."},
      {"q": "Quina d'estes paraules és esdrúixola (tònica en l'antepenúltima síl·laba)?", "o": ["pàgina", "telèfon", "plàtan"], "e": "PÀ-gi-na és esdrúixola. Telèfon i plàtan són planes."},
      {"q": "Quina és la síl·laba tònica de «cadira»?", "o": ["-di-", "ca-", "-ra"], "e": "Ca-DI-ra és plana: la tònica és la penúltima síl·laba."},
      {"q": "«Jo canto» i «el cantó de la casa»: què diferencia «canto» i «cantó»?", "o": ["La síl·laba tònica", "La consonant inicial", "El nombre de síl·labes"], "e": "CAN-to és plana i can-TÓ és aguda: canviar la tònica canvia la paraula."},
      {"q": "Quina d'estes paraules és plana (tònica en la penúltima síl·laba)?", "o": ["finestra", "sofà", "dinàmica"], "e": "Fi-NES-tra és plana. Sofà és aguda i dinàmica, esdrúixola."}
    ]
  },
  {
    "id": "3d8fbee8-b30f-491c-9906-c442729c5e3d", "category": "fonetica_ortografia", "type": "alfabet_grafies", "sort_order": 2,
    "title": "Alfabet i grafies", "name": "Ordre alfabètic, dígrafs i síl·labes",
    "content": "Ordre alfabètic, correspondència so-grafia, dígrafs i separació de síl·labes i paraules.", "icon": "🔤", "color": "#FFE0B2",
    "exercises": [
      {"q": "Quina llista està en ordre alfabètic?", "o": ["barca, carrer, dona, escola", "carrer, barca, dona, escola", "barca, dona, carrer, escola"], "e": "B va abans que C, C abans que D i D abans que E."},
      {"q": "Quina d'estes paraules va primer en el diccionari?", "o": ["llet", "llibre", "lluna"], "e": "Les tres comencen per «ll»: es mira la lletra següent (e, i, u)."},
      {"q": "Quin d'estos grups de lletres és un dígraf (dues lletres que fan un sol so)?", "o": ["ny en «any»", "pr en «prat»", "bl en «blau»"], "e": "«Ny» representa un sol so. En «pr» i «bl» se senten els dos sons."},
      {"q": "Quantes lletres i quants sons té «xiquet»?", "o": ["6 lletres i 5 sons", "6 lletres i 6 sons", "5 lletres i 5 sons"], "e": "«Qu» davant de e és un dígraf: les dues lletres fan un sol so /k/."},
      {"q": "Com se separa en síl·labes «cotxe»?", "o": ["cot-xe", "co-txe", "cotx-e"], "e": "El dígraf «tx» se separa en síl·labes diferents: cot-xe."},
      {"q": "Com se separa en síl·labes «pollastre»?", "o": ["po-llas-tre", "pol-las-tre", "poll-as-tre"], "e": "El dígraf «ll» no se separa mai: po-llas-tre."},
      {"q": "Quina d'estes paraules té el dígraf «rr»?", "o": ["carrer", "raó", "tres"], "e": "Car-rer: la «rr» només apareix entre vocals."},
      {"q": "Quina frase té les paraules ben separades?", "o": ["Demà anem a la platja.", "Demàanem a laplatja.", "De mà anem ala platja."], "e": "Cada paraula s'escriu separada: demà / anem / a / la / platja."}
    ]
  },
  {
    "id": "975ade8f-5197-4edc-bd4a-20dd8816d65f", "category": "fonetica_ortografia", "type": "accentuacio", "sort_order": 3,
    "title": "Accentuació", "name": "Regles bàsiques de l'accent gràfic",
    "content": "Quan porten accent les paraules agudes, planes i esdrúixoles.", "icon": "✍️", "color": "#FFCDD2",
    "exercises": [
      {"q": "Quina d'estes paraules està ben escrita?", "o": ["sofà", "tàula", "finèstra"], "e": "Les agudes acabades en vocal porten accent (sofà). Taula i finestra són planes acabades en vocal: sense accent."},
      {"q": "Quina forma és correcta?", "o": ["camió", "camio", "càmio"], "e": "Ca-mi-Ó és aguda acabada en vocal: porta accent."},
      {"q": "Quina forma és correcta?", "o": ["dimarts", "dimàrts", "dímarts"], "e": "Di-MARTS és aguda, però acaba en -rts (no en vocal, vocal + s, -en o -in): no porta accent."},
      {"q": "Per què porta accent «música»?", "o": ["Perquè és esdrúixola i totes les esdrúixoles s'accentuen", "Perquè és aguda acabada en vocal", "Perquè és plana acabada en vocal"], "e": "MÚ-si-ca és esdrúixola: les esdrúixoles sempre porten accent."},
      {"q": "Quina d'estes paraules està ben escrita?", "o": ["difícil", "cadíra", "pòrta"], "e": "Di-FÍ-cil és plana acabada en -l: les planes que no acaben en vocal, vocal + s, -en o -in porten accent."},
      {"q": "Quina forma és correcta?", "o": ["germà", "gérma", "germa"], "e": "Ger-MÀ és aguda acabada en vocal: porta accent."},
      {"q": "Quina forma és correcta?", "o": ["examen", "exàmen", "éxamen"], "e": "E-XA-men és plana acabada en -en: no porta accent."},
      {"q": "Escriu la paraula amb l'accent correcte: cosi (el fill del meu oncle).", "a": ["cosí"], "e": "Co-SÍ és aguda acabada en vocal: porta accent."},
      {"q": "Escriu la paraula amb l'accent correcte: pagina (d'un llibre).", "a": ["pàgina"], "e": "PÀ-gi-na és esdrúixola: sempre porta accent."}
    ]
  },
  {
    "id": "b832d33a-d974-4137-8d8c-d23523f6d44a", "category": "fonetica_ortografia", "type": "apostrofacio", "sort_order": 4,
    "title": "Apòstrof i contraccions", "name": "L'escola, l'amic, al, del, pel...",
    "content": "Usos bàsics de l'apòstrof en l'article, elisions habituals i contraccions.", "icon": "🔗", "color": "#D1C4E9",
    "exercises": [
      {"q": "Completa: ___ escola està prop de casa.", "o": ["L'", "La", "El"], "e": "L'article s'apostrofa davant de vocal: l'escola."},
      {"q": "Completa: ___ amic de Joan viu a Gandia.", "o": ["L'", "El", "Lo"], "e": "El + amic → l'amic."},
      {"q": "Quina forma és correcta?", "o": ["la universitat", "l'universitat", "l' universitat"], "e": "L'article femení «la» no s'apostrofa davant de i o u àtones: la universitat."},
      {"q": "Quina forma és correcta?", "o": ["l'hospital", "el hospital", "la hospital"], "e": "La h és muda: s'apostrofa com davant de vocal."},
      {"q": "Completa: Vinc ___ mercat.", "o": ["del", "de el", "d'el"], "e": "De + el → del."},
      {"q": "Completa: Anem ___ cine esta nit.", "o": ["al", "a el", "a l'"], "e": "A + el → al."},
      {"q": "Completa: Passegem ___ carrers del centre.", "o": ["pels", "per els", "per los"], "e": "Per + els → pels."},
      {"q": "Completa: Tinc ganes ___ anar-hi.", "o": ["d'", "de", "des"], "e": "La preposició «de» s'apostrofa davant de vocal: d'anar."},
      {"q": "Escriu la contracció: a + els", "a": ["als"], "e": "A + els → als (anem als jardins)."},
      {"q": "Escriu la contracció: de + els", "a": ["dels"], "e": "De + els → dels (la casa dels meus pares)."}
    ]
  },
  {
    "id": "b3f10344-a6e4-43f5-9a59-3dd9dd7ad9a5", "category": "fonetica_ortografia", "type": "alveolars", "sort_order": 5,
    "title": "S, SS, Z, C i Ç", "name": "Consonants alveolars",
    "content": "S sorda i sonora, -ss- entre vocals, c davant de e, i, i ç.", "icon": "🐍", "color": "#C8E6C9",
    "exercises": [
      {"q": "Completa: ca__a (el lloc on vivim)", "o": ["s", "ss", "ç"], "e": "Casa: la s sonora entre vocals s'escriu amb una s."},
      {"q": "Completa: pa__ar (anar d'un lloc a un altre)", "o": ["ss", "s", "ç"], "e": "Passar: la s sorda entre vocals s'escriu amb ss."},
      {"q": "Completa: ca__ola (recipient per a cuinar)", "o": ["ss", "s", "ç"], "e": "Cassola: so sord entre vocals → ss."},
      {"q": "Completa: __eba (verdura)", "o": ["c", "s", "ç"], "e": "Ceba: el so /s/ davant de e o i s'escriu sovint amb c."},
      {"q": "Completa: __ine (sala de pel·lícules)", "o": ["c", "s", "z"], "e": "Cine: c davant de i."},
      {"q": "Completa: pla__a (lloc ample d'un poble)", "o": ["ç", "s", "ss"], "e": "Plaça: davant de a, o, u el so sord s'escriu amb ç."},
      {"q": "Completa: __ero (el número 0)", "o": ["z", "s", "c"], "e": "Zero: s sonora a principi de paraula → z."},
      {"q": "Completa: ro__a (un color)", "o": ["s", "ss", "z"], "e": "Rosa: s sonora entre vocals → s."},
      {"q": "Escriu en lletres el número 12.", "a": ["dotze"], "e": "Dotze: la s sonora després de t s'escriu z (tz)."}
    ]
  },
  {
    "id": "5e910bc3-c0d6-486e-9edc-852f7f7684b2", "category": "fonetica_ortografia", "type": "palatals", "sort_order": 6,
    "title": "J, G, TJ, TG, X, IX, TX", "name": "Consonants palatals",
    "content": "Palatal sonora (jove, germà, platja, metge) i sorda (caixa, peix, cotxe, maig).", "icon": "🌊", "color": "#BBDEFB",
    "exercises": [
      {"q": "Completa: pla__a (vora del mar)", "o": ["tj", "tg", "j"], "e": "Platja: davant de a, o, u s'escriu j (tj)."},
      {"q": "Completa: me__e (treballa a l'hospital)", "o": ["tg", "tj", "g"], "e": "Metge: davant de e, i s'escriu g (tg)."},
      {"q": "Completa: __ove (persona de poca edat)", "o": ["j", "g", "x"], "e": "Jove: j davant de o."},
      {"q": "Completa: __ermà (fill dels meus pares)", "o": ["g", "j", "x"], "e": "Germà: g davant de e."},
      {"q": "Completa: forma__e (es fa amb llet)", "o": ["tg", "tj", "j"], "e": "Formatge: tg davant de e."},
      {"q": "Completa: desi__ar (voler molt una cosa)", "o": ["tj", "tg", "j"], "e": "Desitjar: tj davant de a."},
      {"q": "Completa: pe__ (animal que viu en l'aigua)", "o": ["ix", "x", "tx"], "e": "Peix: darrere de vocal, el so sord s'escriu normalment ix."},
      {"q": "Completa: co__e (vehicle de quatre rodes)", "o": ["tx", "ix", "x"], "e": "Cotxe: so africat → tx."},
      {"q": "Completa: __àtiva (ciutat valenciana)", "o": ["X", "Tx", "J"], "e": "Xàtiva: a principi de paraula s'escriu x."},
      {"q": "Completa: el mes de ma__ (el cinqué mes de l'any)", "o": ["ig", "tx", "ix"], "e": "Maig: a final de paraula, darrere de vocal, s'escriu ig (com mig)."}
    ]
  },
  {
    "id": "77e69eed-4550-4420-a66e-1f226c99a989", "category": "fonetica_ortografia", "type": "laterals", "sort_order": 7,
    "title": "L i LL", "name": "Consonants laterals",
    "content": "Grafia simple l (litre, parlar, bola) i dígraf ll en totes les posicions (lluna, falla, coll).", "icon": "🌙", "color": "#F0F4C3",
    "exercises": [
      {"q": "Completa: __ibre (el llegim)", "o": ["ll", "l", "l·l"], "e": "Llibre: dígraf ll a principi de paraula."},
      {"q": "Completa: __itre (unitat de mesura)", "o": ["l", "ll"], "e": "Litre: l simple."},
      {"q": "Completa: par__ar (dir coses)", "o": ["l", "ll"], "e": "Parlar: l simple."},
      {"q": "Completa: co__ (part del cos entre el cap i el tronc)", "o": ["ll", "l"], "e": "Coll: el dígraf ll també pot anar a final de paraula."},
      {"q": "Completa: coni__ (animal amb orelles llargues)", "o": ["ll", "l"], "e": "Conill: ll a final de paraula."},
      {"q": "Completa: fa__a (la festa de València)", "o": ["ll", "l"], "e": "Falla: ll entre vocals."},
      {"q": "Completa: bo__a (objecte rodó)", "o": ["l", "ll"], "e": "Bola: l simple."},
      {"q": "Completa: __una (la veiem de nit)", "o": ["ll", "l"], "e": "Lluna: ll a principi de paraula."},
      {"q": "Escriu la paraula: animal de corral que posem a la paella, po__astre.", "a": ["pollastre"], "e": "Pollastre, amb el dígraf ll."}
    ]
  },
  {
    "id": "4a7ebcc7-0141-4e17-bae8-6386275e31dd", "category": "fonetica_ortografia", "type": "rotiques", "sort_order": 8,
    "title": "R i RR", "name": "Consonants ròtiques",
    "content": "R bategant i vibrant en el vocabulari bàsic: ratolí, parlar, caramel, carrer.", "icon": "🐭", "color": "#FFECB3",
    "exercises": [
      {"q": "Completa: ca__er (via d'una ciutat)", "o": ["rr", "r"], "e": "Carrer: la r forta entre vocals s'escriu rr."},
      {"q": "Completa: __atolí (animal xicotet)", "o": ["r", "rr"], "e": "Ratolí: a principi de paraula la r sona forta però s'escriu amb una sola r."},
      {"q": "Completa: ca__amel (llepolia dolça)", "o": ["r", "rr"], "e": "Caramel: r suau entre vocals."},
      {"q": "Completa: ho__a (unitat de temps)", "o": ["r", "rr"], "e": "Hora: r suau entre vocals."},
      {"q": "Completa: to__e (edifici molt alt)", "o": ["rr", "r"], "e": "Torre: r forta entre vocals → rr."},
      {"q": "Completa: te__a (el planeta on vivim)", "o": ["rr", "r"], "e": "Terra: r forta entre vocals → rr."},
      {"q": "Completa: ca__a (part del cap on tenim els ulls i la boca)", "o": ["r", "rr"], "e": "Cara: r suau entre vocals."},
      {"q": "En quina d'estes paraules sona la r forta (vibrant)?", "o": ["rosa", "cara", "hora"], "e": "A principi de paraula la r sempre és forta: rosa."}
    ]
  },
  {
    "id": "c84eadef-dfd6-44d0-9864-61e37ef55e97", "category": "fonetica_ortografia", "type": "grafia_h", "sort_order": 9,
    "title": "La H", "name": "La h muda i el verb haver",
    "content": "La h en paraules bàsiques (home, hora, hospital, ahir) i les formes del verb haver.", "icon": "🏥", "color": "#E1BEE7",
    "exercises": [
      {"q": "Quina forma és correcta?", "o": ["home", "ome", "hom"], "e": "Home s'escriu amb h inicial muda."},
      {"q": "Quina forma és correcta?", "o": ["ahir", "aïr", "air"], "e": "Ahir porta h entre vocals."},
      {"q": "Quina forma és correcta?", "o": ["hospital", "ospital", "hospitàl"], "e": "Hospital: h inicial i sense accent (aguda acabada en -l)."},
      {"q": "Quina forma és correcta?", "o": ["hivern", "ivern", "hibern"], "e": "Hivern: amb h i amb v."},
      {"q": "Completa: Quina ___ és?", "o": ["hora", "ora", "óra"], "e": "Hora, amb h."},
      {"q": "Completa: Jo ___ menjat paella.", "o": ["he", "e", "é"], "e": "He és el verb haver (he menjat)."},
      {"q": "Completa: Nosaltres ___ viatjat a Roma.", "o": ["hem", "em", "hen"], "e": "Hem és el verb haver. «Em» sense h és un pronom (em dic Anna)."},
      {"q": "Completa: Ells ___ arribat tard.", "o": ["han", "an", "hàn"], "e": "Han és el verb haver."},
      {"q": "Completa: A la plaça ___ ha molta gent.", "o": ["hi", "i", "y"], "e": "Hi ha (verb haver-hi). «I» sense h és la conjunció."}
    ]
  },
  {
    "id": "e5d6e371-5128-48a1-a4be-01a98a83bedb", "category": "fonetica_ortografia", "type": "puntuacio", "sort_order": 10,
    "title": "Majúscules i puntuació", "name": "Convencions de l'escriptura",
    "content": "Majúscules inicials i en noms propis; punt, coma, interrogació, admiració i dos punts.", "icon": "❗", "color": "#CFD8DC",
    "exercises": [
      {"q": "Quina frase està ben escrita?", "o": ["Vicent viu a Castelló.", "vicent viu a castelló.", "Vicent Viu a Castelló."], "e": "Majúscula a l'inici de la frase i en els noms propis de persona i de lloc."},
      {"q": "Quina frase està ben escrita?", "o": ["Hui és dilluns, 3 de març.", "Hui és Dilluns, 3 de Març.", "hui és dilluns, 3 de març."], "e": "Els dies de la setmana i els mesos s'escriuen amb minúscula."},
      {"q": "Quina frase està ben escrita?", "o": ["Parle valencià i anglés.", "Parle Valencià i Anglés.", "parle valencià i anglés."], "e": "Els noms de les llengües van en minúscula."},
      {"q": "Quina frase està ben escrita?", "o": ["Visc al carrer de la Pau.", "Visc al Carrer de la pau.", "visc al carrer de la Pau."], "e": "«Carrer» va en minúscula; el nom propi del carrer, en majúscula."},
      {"q": "Quin signe falta? «Com et diuen__»", "o": ["?", "!", "."], "e": "És una pregunta: interrogació al final."},
      {"q": "Quin signe falta? «Quina alegria__»", "o": ["!", "?", ":"], "e": "Expressa una emoció: admiració."},
      {"q": "Quina frase usa bé els dos punts?", "o": ["Necessite tres coses: pa, llet i ous.", "Necessite: tres coses pa, llet i ous.", "Necessite tres coses pa: llet i ous."], "e": "Els dos punts introduïxen una enumeració."},
      {"q": "Quina frase té les comes ben posades?", "o": ["He comprat pomes, peres i taronges.", "He comprat, pomes peres i taronges.", "He comprat pomes peres, i taronges."], "e": "La coma separa els elements d'una llista; davant de l'últim va la «i»."}
    ]
  },
  {
    "id": "8e2976bb-d06b-4230-8887-fcf23f45bbdd", "category": "morfosintaxi", "type": "genere_nombre", "sort_order": 1,
    "title": "Gènere i nombre", "name": "Femení, plural i concordança",
    "content": "Formació del femení i del plural de substantius i adjectius, i concordança.", "icon": "⚖️", "color": "#F8BBD0",
    "exercises": [
      {"q": "Quin és el femení de «gat»?", "o": ["gata", "gatessa", "gate"], "e": "Regla general: s'afig -a."},
      {"q": "Quin és el femení de «alumne»?", "o": ["alumna", "alumnea", "alumnessa"], "e": "La -e final canvia a -a."},
      {"q": "Quin és el femení de «cosí»?", "o": ["cosina", "cosia", "cosinessa"], "e": "Els masculins acabats en vocal tònica afigen -na: cosí → cosina."},
      {"q": "Quin és el plural de «lleó»?", "o": ["lleons", "lleós", "lleones"], "e": "Moltes paraules agudes acabades en vocal afigen -ns: lleó → lleons."},
      {"q": "Quin és el plural de «camió»?", "o": ["camions", "camiós", "camiones"], "e": "Camió → camions (-ns)."},
      {"q": "Quin és el plural de «avís»?", "o": ["avisos", "avíssos", "avís"], "e": "Els acabats en -s tònica afigen -os: avís → avisos."},
      {"q": "Quin és el plural de «dia»?", "o": ["dies", "dias", "diaes"], "e": "La -a final es convertix en -es: dia → dies."},
      {"q": "Completa amb la concordança correcta: Tinc dues ___.", "o": ["cadires blanques", "cadires blancs", "cadira blanques"], "e": "Substantiu i adjectiu concorden en femení plural."},
      {"q": "Escriu el plural de «dona».", "a": ["dones"], "e": "-a → -es: dona → dones."},
      {"q": "Escriu el plural de «feliç».", "a": ["feliços"], "e": "Els acabats en -ç afigen -os: feliç → feliços."}
    ]
  },
  {
    "id": "79dd1db4-40ff-4860-8f49-279ee059ab46", "category": "morfosintaxi", "type": "determinants", "sort_order": 2,
    "title": "Determinants", "name": "Articles, demostratius i possessius",
    "content": "Articles, els tres graus dels demostratius (este, eixe, aquell) i possessius.", "icon": "👉", "color": "#FFE0B2",
    "exercises": [
      {"q": "Completa (el llibre el tens tu a la mà): ___ llibre és nou.", "o": ["Este", "Eixe", "Aquell"], "e": "Este: prop de qui parla."},
      {"q": "Completa (el bolígraf el té qui t'escolta): Em deixes ___ bolígraf?", "o": ["eixe", "este", "aquell"], "e": "Eixe: prop de qui escolta."},
      {"q": "Completa: Mira ___ muntanya del fons. Que lluny!", "o": ["aquella", "esta", "eixa"], "e": "Aquella: lluny dels dos interlocutors."},
      {"q": "Completa: ___ sabates que porte són noves.", "o": ["Estes", "Estos", "Esta"], "e": "Sabates és femení plural: estes."},
      {"q": "Completa: Esta és ___ germana, Laia.", "o": ["la meua", "el meu", "les meues"], "e": "Germana és femení singular: la meua."},
      {"q": "Completa: ___ pares viuen a Alcoi.", "o": ["Els nostres", "Les nostres", "El nostre"], "e": "Pares és masculí plural: els nostres."},
      {"q": "Completa: Vosaltres porteu ___ cotxe?", "o": ["el vostre", "la vostra", "els vostres"], "e": "Cotxe és masculí singular: el vostre."},
      {"q": "Completa: Tinc ___ gos i ___ gata.", "o": ["un / una", "uns / unes", "el / l'"], "e": "Indefinits en singular: un gos, una gata."},
      {"q": "Escriu el demostratiu que falta (prop de qui parla, masculí plural): ___ xiquets són els meus fills.", "a": ["estos"], "e": "Este, esta, estos, estes."}
    ]
  },
  {
    "id": "725395e1-be2e-47a3-89bb-432fc4f4a152", "category": "morfosintaxi", "type": "pronoms", "sort_order": 3,
    "title": "Pronoms", "name": "Personals, febles, interrogatius i relatius",
    "content": "Pronoms tònics, febles de 1a i 2a persona, CD i CI de 3a persona, interrogatius i relatius que / a on.", "icon": "🗣️", "color": "#C5CAE9",
    "exercises": [
      {"q": "Completa: ___ em dic Marta i ___ et dius Pau.", "o": ["Jo / tu", "Mi / tu", "Jo / te"], "e": "Pronoms personals tònics de subjecte: jo, tu."},
      {"q": "Completa: Com ___ dius?", "o": ["et", "te", "t'"], "e": "Davant d'un verb que comença per consonant: et."},
      {"q": "Completa: ___ alce a les set.", "o": ["M'", "Em", "Me"], "e": "Davant de vocal el pronom s'apostrofa: m'alce."},
      {"q": "Substituïx el complement directe: «Compre el pa.»", "o": ["El compre.", "Li compre.", "Els compre."], "e": "CD masculí singular: el."},
      {"q": "Substituïx el complement directe: «Vull vore la pel·lícula.»", "o": ["Vull vore-la.", "Vull vore-li.", "Vull la vore-la."], "e": "Darrere d'un infinitiu el pronom va darrere i amb guionet: vore-la."},
      {"q": "Substituïx el complement indirecte: «Done un regal a ma mare.»", "o": ["Li done un regal.", "La done un regal.", "Els done un regal."], "e": "CI de 3a persona singular: li."},
      {"q": "Completa: El llibre ___ he comprat és interessant.", "o": ["que", "qui", "a on"], "e": "Relatiu «que»."},
      {"q": "Completa: El poble ___ visc és xicotet.", "o": ["a on", "que", "qui"], "e": "Relatiu de lloc: a on."},
      {"q": "Completa: ___ vens a la festa? — Dissabte.", "o": ["Quan", "Quant", "Quin"], "e": "Quan pregunta pel temps."},
      {"q": "Completa: ___ costa el pa? — Un euro.", "o": ["Quant", "Quan", "Quina"], "e": "Quant pregunta per la quantitat."},
      {"q": "Substituïx «les claus» pel pronom: «Busque les claus.» → ___ busque.", "a": ["les"], "e": "CD femení plural: les."}
    ]
  },
  {
    "id": "9d900655-f7cc-4ca6-9611-6fc2f32bbc2b", "category": "morfosintaxi", "type": "quantificadors", "sort_order": 4,
    "title": "Quantificadors", "name": "Numerals, indefinits i quantitatius",
    "content": "Cardinals, ordinals fins al desé, indefinits (algú, ningú, res, cap) i massa, prou, molt, poc.", "icon": "🔢", "color": "#B2DFDB",
    "exercises": [
      {"q": "Com s'escriu el número 16?", "o": ["setze", "deu-i-sis", "setce"], "e": "Setze."},
      {"q": "Com s'escriu el número 25?", "o": ["vint-i-cinc", "vint i cinc", "vinticinc"], "e": "Les desenes i les unitats s'unixen amb guionets: vint-i-cinc."},
      {"q": "Com s'escriu el número 14?", "o": ["catorze", "quatorze", "catorce"], "e": "Catorze."},
      {"q": "Completa: Març és el ___ mes de l'any.", "o": ["tercer", "tres", "terç"], "e": "Ordinal: primer, segon, tercer..."},
      {"q": "Completa: He arribat ___ a la meta, darrere de Sara.", "o": ["segon", "dos", "segona"], "e": "Ordinal masculí: segon."},
      {"q": "Completa: No tinc ___ germà.", "o": ["cap", "algun", "ningú"], "e": "En frases negatives: no... cap."},
      {"q": "Completa: Hi ha ___ a la porta? — No, no hi ha ningú.", "o": ["algú", "res", "cap"], "e": "Algú (alguna persona) / ningú (cap persona)."},
      {"q": "Completa: No vull ___, gràcies.", "o": ["res", "ningú", "algú"], "e": "Res: cap cosa."},
      {"q": "Completa: Esta sopa està ___ salada: no es pot menjar.", "o": ["massa", "prou", "gens"], "e": "Massa: més del que cal."},
      {"q": "Completa: No compres més pa, ja en tenim ___.", "o": ["prou", "gens", "cap"], "e": "Prou: la quantitat necessària."},
      {"q": "Escriu en lletres el número 21.", "a": ["vint-i-u", "vint-i-un"], "e": "Vint-i-u (o vint-i-un davant d'un nom masculí)."}
    ]
  },
  {
    "id": "a8c6af22-1a37-49d0-a8b9-35c91f26bff9", "category": "morfosintaxi", "type": "preposicions", "sort_order": 5,
    "title": "Preposicions", "name": "A, de, en, amb, per, per a...",
    "content": "Preposicions àtones i tòniques usuals, també davant dels interrogatius.", "icon": "📍", "color": "#DCEDC8",
    "exercises": [
      {"q": "Completa: Demà vaig ___ València.", "o": ["a", "en", "per a"], "e": "Destinació: anar a un lloc."},
      {"q": "Completa: Soc ___ Xàtiva.", "o": ["de", "a", "en"], "e": "Procedència: de."},
      {"q": "Completa: Isc ___ el meu germà.", "o": ["amb", "en", "a"], "e": "Companyia: amb."},
      {"q": "Completa: Este regal és ___ tu.", "o": ["per a", "per", "amb"], "e": "Destinatari: per a."},
      {"q": "Completa: Gràcies ___ l'ajuda.", "o": ["per", "per a", "de"], "e": "Causa: gràcies per."},
      {"q": "Completa: Prenc el café ___ sucre: no m'agrada dolç.", "o": ["sense", "amb", "entre"], "e": "Sense: absència d'una cosa."},
      {"q": "Completa: La farmàcia està ___ el banc i el forn.", "o": ["entre", "contra", "cap a"], "e": "Entre: en mig de dues coses."},
      {"q": "Completa: Treballe de dilluns ___ divendres.", "o": ["a", "cap a", "contra"], "e": "De... a...: de dilluns a divendres."},
      {"q": "Completa: ___ qui parles per telèfon?", "o": ["Amb", "En", "Per a"], "e": "Parlar amb algú → Amb qui parles?"}
    ]
  },
  {
    "id": "03d45225-e0a6-4178-8574-ba4960ef05c1", "category": "morfosintaxi", "type": "adverbis", "sort_order": 6,
    "title": "Adverbis", "name": "Temps, lloc, quantitat, manera i orde",
    "content": "Adverbis i locucions de temps, lloc, quantitat, manera, orde, afirmació i negació.", "icon": "⏱️", "color": "#FFF9C4",
    "exercises": [
      {"q": "Completa: No m'agrada el futbol: no el veig ___.", "o": ["mai", "sempre", "sovint"], "e": "Mai: en cap moment."},
      {"q": "Completa: Vaig al gimnàs ___: dilluns, dimecres i divendres.", "o": ["sovint", "mai", "tampoc"], "e": "Sovint: moltes vegades."},
      {"q": "Completa: El llibre està ___ de la taula (a sobre).", "o": ["damunt", "davall", "dins"], "e": "Damunt: a la part de dalt."},
      {"q": "Completa: El gat dorm ___ del llit (a sota).", "o": ["davall", "damunt", "dalt"], "e": "Davall: a la part de baix."},
      {"q": "Completa: Vine ___, al meu costat!", "o": ["ací", "allà", "fora"], "e": "Ací: prop de qui parla."},
      {"q": "Quin és el contrari de «prompte»?", "o": ["tard", "ara", "ja"], "e": "Prompte / tard."},
      {"q": "Completa: Parla ___, que vas massa de pressa i no t'entenc.", "o": ["a poc a poc", "de pressa", "gens"], "e": "A poc a poc: lentament."},
      {"q": "Completa: Primer em dutxe, ___ esmorze i finalment isc de casa.", "o": ["després", "abans", "mai"], "e": "Orde: primer, després, finalment."},
      {"q": "Completa: — No m'agraden les olives. — A mi ___.", "o": ["tampoc", "també", "sí"], "e": "Tampoc confirma una negació."},
      {"q": "Completa: No tinc ___ de fam.", "o": ["gens", "molt", "massa"], "e": "Gens: en frases negatives, cap quantitat."}
    ]
  },
  {
    "id": "e7ee9121-8467-4534-9ec5-1f8b491794f2", "category": "morfosintaxi", "type": "conjuncions", "sort_order": 7,
    "title": "Conjuncions", "name": "Coordinació i subordinació bàsica",
    "content": "I, ni, o, però, sinó; que, quan, perquè, com que, per tant, si, per a.", "icon": "🔀", "color": "#D7CCC8",
    "exercises": [
      {"q": "Completa: Vull un café ___ un got d'aigua.", "o": ["i", "ni", "sinó"], "e": "I: suma dos elements."},
      {"q": "Completa: No menge carn ___ peix.", "o": ["ni", "o", "i"], "e": "Ni: suma elements en una frase negativa."},
      {"q": "Completa: Vols te ___ café?", "o": ["o", "ni", "però"], "e": "O: cal triar entre dues opcions."},
      {"q": "Completa: M'agrada la platja, ___ hui fa fred.", "o": ["però", "sinó", "perquè"], "e": "Però: contrast."},
      {"q": "Completa: No és el meu cosí, ___ el meu germà.", "o": ["sinó", "però", "o"], "e": "Sinó: corregix una negació anterior."},
      {"q": "Completa: No vinc ___ estic malalta.", "o": ["perquè", "però", "si"], "e": "Perquè: causa."},
      {"q": "Completa: ___ no tenia diners, no vaig comprar res.", "o": ["Com que", "Sinó", "Ni"], "e": "Com que: causa, a principi de frase."},
      {"q": "Completa: Ha plogut molt; ___, el camp està verd.", "o": ["per tant", "sinó", "ni"], "e": "Per tant: conseqüència."},
      {"q": "Completa: ___ plou, anirem al cine.", "o": ["Si", "Que", "Però"], "e": "Si: condició."},
      {"q": "Completa: ___ arribes a casa, telefona'm.", "o": ["Quan", "Quant", "Perquè"], "e": "Quan: temps."},
      {"q": "Completa: Estudie ___ aprovar l'examen.", "o": ["per a", "sinó", "com que"], "e": "Finalitat: per a + infinitiu."}
    ]
  },
  {
    "id": "e971fb5a-f24b-4b65-bdf4-6f85d3b084c7", "category": "morfosintaxi", "type": "sistema_verbal", "sort_order": 8,
    "title": "Verbs", "name": "Temps verbals i verbs irregulars",
    "content": "Present, passats, futur, condicional, imperatiu, verbs irregulars bàsics i haver-hi.", "icon": "⏳", "color": "#B3E5FC",
    "exercises": [
      {"q": "Present: Jo ___ (parlar) valencià.", "o": ["parle", "parlo", "parli"], "e": "En valencià la 1a persona del present acaba en -e: parle."},
      {"q": "Passat perifràstic: Ahir ___ (anar, jo) al cine.", "o": ["vaig anar", "vaig a anar", "aní anar"], "e": "Passat perifràstic: vaig + infinitiu."},
      {"q": "Passat perfet: Hui ___ (menjar, nosaltres) paella.", "o": ["hem menjat", "vam menjar", "menjarem"], "e": "Amb «hui», el temps del passat que es fa servir és el perfet: hem menjat."},
      {"q": "Plusquamperfet: Quan vaig arribar, ells ja ___ (dinar).", "o": ["havien dinat", "han dinat", "dinaran"], "e": "Acció anterior a una altra del passat: havien dinat."},
      {"q": "Futur: Demà ___ (viatjar, tu) a Madrid.", "o": ["viatjaràs", "viatjaves", "has viatjat"], "e": "Futur: viatjaràs."},
      {"q": "Condicional: Si tinguera temps, ___ (viatjar, jo) més.", "o": ["viatjaria", "viatjaré", "viatge"], "e": "Condicional simple: viatjaria."},
      {"q": "Imperatiu: ___ (obrir, tu) la finestra, per favor.", "o": ["Obri", "Obres", "Obrir"], "e": "Imperatiu de tu d'obrir: obri."},
      {"q": "Completa amb el verb ser: Nosaltres ___ de Castelló.", "o": ["som", "sem", "sóm"], "e": "Ser: soc, eres, és, som, sou, són."},
      {"q": "Completa amb el verb tindre: Tu ___ germans?", "o": ["tens", "tins", "tindres"], "e": "Tindre: tinc, tens, té..."},
      {"q": "Completa amb el verb conéixer: Jo ___ la teua mare.", "o": ["conec", "conesc", "conéixo"], "e": "Conéixer: conec, coneixes, coneix..."},
      {"q": "Completa amb el verb vore: Jo ___ la tele cada nit.", "o": ["veig", "vec", "voig"], "e": "Vore: veig, veus, veu..."},
      {"q": "Completa amb haver-hi: A la classe ___ vint alumnes.", "o": ["hi ha", "hi han", "ha"], "e": "Haver-hi és impersonal: hi ha també amb plural."},
      {"q": "Escriu el present del verb fer: Jo ___ els deures de vesprada.", "a": ["faig"], "e": "Fer: faig, fas, fa..."},
      {"q": "Escriu el present del verb viure: Ella ___ a Elx.", "a": ["viu"], "e": "Viure: visc, vius, viu..."}
    ]
  },
  {
    "id": "be7ce637-a745-4ec9-8d00-502b96b164a1", "category": "lexic_semantica", "type": "vocabulari", "sort_order": 1,
    "title": "Vocabulari", "name": "Àmbits temàtics del nivell A2",
    "content": "Família, temps, alimentació, cos i roba, oci, salut, transports i nacionalitats.", "icon": "📚", "color": "#FFCCBC",
    "exercises": [
      {"q": "Com es diu la mare de ta mare?", "o": ["l'àvia", "la tia", "la cosina"], "e": "L'àvia (o la iaia)."},
      {"q": "Són les 17.30. Com ho dius?", "o": ["Són les cinc i mitja de la vesprada.", "Són les set i mitja.", "És la una i mitja."], "e": "17.30 → les cinc i mitja de la vesprada."},
      {"q": "Quin dia va després de dimecres?", "o": ["dijous", "dimarts", "divendres"], "e": "Dilluns, dimarts, dimecres, dijous, divendres, dissabte, diumenge."},
      {"q": "En quina estació de l'any fa més calor?", "o": ["l'estiu", "l'hivern", "la tardor"], "e": "Primavera, estiu, tardor i hivern."},
      {"q": "Quin d'estos és un envàs?", "o": ["una botella", "un quilo", "un litre"], "e": "Quilo i litre són mesures; la botella és un envàs."},
      {"q": "On et poses les sabates?", "o": ["als peus", "a les mans", "al cap"], "e": "Les sabates van als peus."},
      {"q": "Tinc tos i mocs: estic ___.", "o": ["refredat", "afamat", "avorrit"], "e": "Refredat: amb un refredat."},
      {"q": "Quin mitjà de transport va per les vies?", "o": ["el tren", "el vaixell", "l'avió"], "e": "El tren circula per les vies."},
      {"q": "Com es diu un home d'Itàlia?", "o": ["italià", "italianer", "italiés"], "e": "Italià, italiana."},
      {"q": "Quina festa valenciana se celebra al mes de març?", "o": ["les Falles", "el Nadal", "Sant Joan"], "e": "Les Falles se celebren al març; Sant Joan, al juny i Nadal, al desembre."}
    ]
  },
  {
    "id": "2d99f341-c91b-4c70-9d21-75a239956f97", "category": "lexic_semantica", "type": "creacio_lexica", "sort_order": 2,
    "title": "Formació de paraules", "name": "Oficis, gentilicis, objectes i arbres",
    "content": "Sufixos -er/-era, -ista, -or/-ora, -aire, -à, -í, -és, -enc.", "icon": "🧩", "color": "#C8E6C9",
    "exercises": [
      {"q": "Qui fa mobles de fusta?", "o": ["el fuster", "el fustista", "el fustador"], "e": "Sufix d'ofici -er: fuster."},
      {"q": "Qui arregla la llum de casa?", "o": ["l'electricista", "l'electriquer", "l'electrador"], "e": "Sufix -ista, invariable: l'electricista, la electricista."},
      {"q": "Quin és el femení de «pintor»?", "o": ["pintora", "pintoressa", "pintrera"], "e": "-or → -ora."},
      {"q": "Com es diu una persona que parla molt?", "o": ["xarraire", "xarrador", "xarrista"], "e": "Sufix -aire, invariable: un xarraire, una xarraire."},
      {"q": "Una dona d'Alacant és...", "o": ["alacantina", "alacantesa", "alacantenca"], "e": "-í / -ina: alacantí, alacantina."},
      {"q": "Un home de França és...", "o": ["francés", "francí", "francenc"], "e": "-és / -esa: francés, francesa."},
      {"q": "Una dona d'Eivissa és...", "o": ["eivissenca", "eivissana", "eivissesa"], "e": "-enc / -enca: eivissenc, eivissenca."},
      {"q": "On posem la sal a la taula?", "o": ["al saler", "al salista", "a la salaire"], "e": "Recipient: sufix -er (saler)."},
      {"q": "On tirem els papers?", "o": ["a la paperera", "al paperista", "a la papereta"], "e": "Recipient: sufix -era (paperera)."},
      {"q": "L'arbre que fa taronges és...", "o": ["el taronger", "el tarongista", "el tarongeraire"], "e": "Arbres fruiters: -er / -era (taronger, olivera)."},
      {"q": "Completa l'ofici: dona que cuina en un restaurant, la ___.", "a": ["cuinera"], "e": "Cuiner, cuinera."}
    ]
  },
  {
    "id": "e1165f90-cd1d-4006-84f3-75bda93d947e", "category": "lexic_semantica", "type": "relacions_semantiques", "sort_order": 3,
    "title": "Sinònims, antònims i cortesia", "name": "Relacions lèxiques i fórmules",
    "content": "Sinònims, antònims, hiperònims (fruita → poma) i fórmules de salutació, comiat i agraïment.", "icon": "🤝", "color": "#F0F4C3",
    "exercises": [
      {"q": "Quin és el contrari de «alt»?", "o": ["baix", "gran", "llarg"], "e": "Alt / baix."},
      {"q": "Quin és el contrari de «obrir»?", "o": ["tancar", "eixir", "traure"], "e": "Obrir / tancar."},
      {"q": "Quin és un sinònim de «faena»?", "o": ["treball", "festa", "descans"], "e": "Faena i treball."},
      {"q": "Quin és un sinònim de «xicotet»?", "o": ["menut", "gros", "ample"], "e": "Xicotet i menut."},
      {"q": "Quina d'estes paraules NO és una fruita?", "o": ["ceba", "poma", "taronja"], "e": "La ceba és una hortalissa."},
      {"q": "Poma, pera i plàtan són...", "o": ["fruites", "verdures", "begudes"], "e": "Fruita és la paraula general (hiperònim)."},
      {"q": "Què dius quan algú t'ajuda?", "o": ["Moltes gràcies.", "Bon profit.", "Fins demà."], "e": "Agraïment."},
      {"q": "Què dius quan arribes tard a una cita?", "o": ["Perdona el retard.", "Enhorabona!", "Bon viatge!"], "e": "Petició de disculpa."},
      {"q": "Quina és una salutació formal per a començar un correu?", "o": ["Benvolguda senyora,", "Ei, què passa?", "Adéu!"], "e": "Benvolgut / benvolguda: registre formal."},
      {"q": "Què diuen a la taula abans de començar a menjar?", "o": ["Bon profit!", "Bona nit!", "Molt de gust!"], "e": "Bon profit!"},
      {"q": "Quin és un comiat informal?", "o": ["Fins després!", "Atentament,", "Benvolgut senyor,"], "e": "«Atentament» és un comiat formal i «Benvolgut senyor» una salutació formal."}
    ]
  }
]$data$::jsonb) AS t(
  id uuid, category text, type text, sort_order smallint, title text, name text,
  content text, icon text, color text, exercises jsonb
);

INSERT INTO public.resources (id, name, type, category, content, difficulty, xp_earned, sort_order, metadata)
SELECT id, name, type, category, content, 'principiant', 10, sort_order,
       jsonb_build_object('icon', icon, 'color', color, 'section_name', title)
FROM practice_catalog
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  type = EXCLUDED.type,
  category = EXCLUDED.category,
  content = EXCLUDED.content,
  sort_order = EXCLUDED.sort_order,
  metadata = EXCLUDED.metadata;

-- Es reescriuen els exercicis A2 d'estos continguts: tornar a aplicar el fitxer no els duplica.
DELETE FROM public.practice_exercises e
USING practice_catalog c
WHERE e.resource_id = c.id AND e.level = 'A2';

INSERT INTO public.practice_exercises (resource_id, level, position, kind, prompt, options, answers, explanation)
SELECT c.id, 'A2', x.ord,
       CASE WHEN x.e ? 'a' THEN 'fill' ELSE 'choice' END,
       x.e->>'q',
       CASE WHEN x.e ? 'o' THEN ARRAY(SELECT jsonb_array_elements_text(x.e->'o')) END,
       CASE WHEN x.e ? 'a' THEN ARRAY(SELECT jsonb_array_elements_text(x.e->'a')) ELSE ARRAY[x.e->'o'->>0] END,
       x.e->>'e'
FROM practice_catalog c
CROSS JOIN LATERAL jsonb_array_elements(c.exercises) WITH ORDINALITY AS x(e, ord);

DROP TABLE practice_catalog;

-- ============================================================
-- Origen: 20260930120000_practice_skills.sql
-- ============================================================
-- Àrees de destreses del Quadern A2 de la JQCV (objectius per àrees):
-- Comprensió oral, Comprensió escrita, Expressió escrita i Expressió oral, al
-- costat de les àrees de continguts lingüístics (20260930110000).
--   * Comprensió oral i escrita: textos o àudios (practice_passages) amb preguntes.
--     Els àudios són fitxers estàtics (`audio_url`) generats amb el TTS a partir de
--     la transcripció, torn a torn i amb la veu de cada personatge: després
--     d'afegir-ne o de canviar-ne, cal executar backend/scripts/generate-practice-audio.ts.
--   * Expressió escrita: redaccions (`writing`) i formularis (`form`) que avalua
--     el LLM amb la rúbrica de la JQCV; la consigna va a `task`.
--   * Expressió oral: xats amb un personatge, com els escenaris (metadata amb
--     character, system_prompt, objectius, voice...), sense practice_exercises.

CREATE TABLE IF NOT EXISTS public.practice_passages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  resource_id uuid NOT NULL REFERENCES public.resources(id) ON UPDATE CASCADE ON DELETE CASCADE,
  level text NOT NULL CHECK (level IN ('A1', 'A2', 'B1', 'B2', 'C1', 'C2')),
  position smallint NOT NULL,
  -- text: es llig en pantalla; audio: s'escolta i la transcripció es mostra en corregir.
  media text NOT NULL CHECK (media IN ('text', 'audio')),
  title text,
  -- [{text, speaker?, voice?}]: paràgrafs d'un text o torns d'un diàleg.
  lines jsonb NOT NULL CHECK (jsonb_typeof(lines) = 'array' AND jsonb_array_length(lines) > 0),
  CONSTRAINT practice_passages_position_key UNIQUE (resource_id, level, position)
);

-- Àudio estàtic de frontend/public (/audio/practice/<type>-<nivell>-<posició>.wav).
ALTER TABLE public.practice_passages ADD COLUMN IF NOT EXISTS audio_url text;

ALTER TABLE public.practice_passages ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.practice_exercises
  ADD COLUMN IF NOT EXISTS passage_id uuid REFERENCES public.practice_passages(id) ON DELETE CASCADE,
  -- writing: {min_words, max_words, words?, min_words_used?}; form: {fields}.
  ADD COLUMN IF NOT EXISTS task jsonb;

CREATE INDEX IF NOT EXISTS idx_practice_exercises_passage ON public.practice_exercises (passage_id);

ALTER TABLE public.practice_exercises ALTER COLUMN answers DROP NOT NULL;
ALTER TABLE public.practice_exercises DROP CONSTRAINT IF EXISTS practice_exercises_kind_check;
ALTER TABLE public.practice_exercises DROP CONSTRAINT IF EXISTS practice_exercises_answers_check;
ALTER TABLE public.practice_exercises DROP CONSTRAINT IF EXISTS practice_exercises_task_check;
ALTER TABLE public.practice_exercises
  ADD CONSTRAINT practice_exercises_kind_check CHECK (kind IN ('choice', 'fill', 'writing', 'form')),
  -- Les preguntes tancades porten solució; les redaccions i els formularis, la consigna.
  ADD CONSTRAINT practice_exercises_answers_check CHECK (kind NOT IN ('choice', 'fill') OR cardinality(answers) > 0),
  ADD CONSTRAINT practice_exercises_task_check CHECK (
    (kind <> 'writing' OR (task ? 'min_words' AND task ? 'max_words'))
    AND (kind <> 'form' OR jsonb_typeof(task->'fields') = 'array')
  );

-- Catàleg. Cada recurs porta `exercises` o bé `blocks` ({passage, exercises}).
-- Exercicis: {q, o (la primera, correcta), e} | {q, a (respostes acceptades), e}
-- | {q, w: task d'una redacció} | {q, f: camps d'un formulari}.
-- `metadata` s'afig a {icon, color, section_name} (p. ex. el personatge d'un xat).
DO $do$
DECLARE
  catalog jsonb := $data$[
  {
    "id": "296c0bc1-40b2-4663-9a3c-c1f30eb8e635", "category": "comprensio_oral", "type": "co_personal", "sort_order": 1,
    "title": "Informació personal", "name": "Presentacions i dades personals",
    "content": "Entén converses lentes i clares sobre família, residència i ocupació.", "icon": "👋", "color": "#B2EBF2",
    "blocks": [
      {
        "passage": {"media": "audio", "title": "Nous veïns", "lines": [
          {"speaker": "Laura", "voice": "gina", "text": "Hola, bon dia! Tu deus ser el nou veí del tercer, no?"},
          {"speaker": "Pau", "voice": "lluc", "text": "Sí, bon dia! Em dic Pau. Vaig arribar dilluns passat. I tu?"},
          {"speaker": "Laura", "voice": "gina", "text": "Jo soc Laura i visc ací davant, al tercer B. D'on eres?"},
          {"speaker": "Pau", "voice": "lluc", "text": "Soc de Morella, però ara treballe a València, en una llibreria del centre."},
          {"speaker": "Laura", "voice": "gina", "text": "Ah, que bé! Jo soc infermera a l'hospital. I vius a soles?"},
          {"speaker": "Pau", "voice": "lluc", "text": "No, visc amb la meua germana, Carme. Ella estudia Medicina a la universitat."},
          {"speaker": "Laura", "voice": "gina", "text": "Doncs si necessiteu alguna cosa, ja sabeu on estic. Benvinguts!"},
          {"speaker": "Pau", "voice": "lluc", "text": "Moltes gràcies, Laura. Fins després!"}
        ]},
        "exercises": [
          {"q": "De quin poble és Pau?", "o": ["De Morella", "De València", "De Castelló"], "e": "«Soc de Morella, però ara treballe a València.»"},
          {"q": "On treballa Pau?", "o": ["En una llibreria", "En un hospital", "En la universitat"], "e": "«Treballe a València, en una llibreria del centre.»"},
          {"q": "Quina és la professió de Laura?", "o": ["Infermera", "Llibretera", "Estudiant"], "e": "«Jo soc infermera a l'hospital.»"},
          {"q": "Amb qui viu Pau?", "o": ["Amb la seua germana", "A soles", "Amb els seus pares"], "e": "«Visc amb la meua germana, Carme.»"},
          {"q": "Quan va arribar Pau al pis?", "o": ["Dilluns passat", "Fa un mes", "Ahir"], "e": "«Vaig arribar dilluns passat.»"}
        ]
      }
    ]
  },
  {
    "id": "4c658569-e553-4eab-858b-dd44b95d92a4", "category": "comprensio_oral", "type": "co_instruccions", "sort_order": 2,
    "title": "Instruccions", "name": "Indicacions a classe i en una oficina",
    "content": "Seguix instruccions de primera necessitat de l'àmbit acadèmic i institucional.", "icon": "📋", "color": "#FFE0B2",
    "blocks": [
      {
        "passage": {"media": "audio", "title": "El primer dia de classe", "lines": [
          {"speaker": "Professor", "voice": "lluc", "text": "Bon dia a tots i a totes. Abans de començar, escolteu bé. Primer, obriu el llibre per la pàgina dotze. Després, feu l'exercici tres a soles, sense mirar el diccionari. Teniu quinze minuts."},
          {"speaker": "Professor", "voice": "lluc", "text": "Quan acabeu, compareu les respostes amb el company del costat. Els deures per a dijous són els exercicis cinc i sis. I recordeu: divendres no hi ha classe perquè és festa."}
        ]},
        "exercises": [
          {"q": "Per quina pàgina cal obrir el llibre?", "o": ["Per la dotze", "Per la tres", "Per la quinze"], "e": "«Obriu el llibre per la pàgina dotze.»"},
          {"q": "Com cal fer l'exercici tres?", "o": ["A soles i sense diccionari", "En parella", "Amb el diccionari"], "e": "«Feu l'exercici tres a soles, sense mirar el diccionari.»"},
          {"q": "Què cal fer en acabar l'exercici?", "o": ["Comparar les respostes amb un company", "Donar-lo al professor", "Fer l'exercici cinc"], "e": "«Compareu les respostes amb el company del costat.»"},
          {"q": "Per què no hi ha classe divendres?", "o": ["Perquè és festa", "Perquè el professor està malalt", "Perquè hi ha examen"], "e": "«Divendres no hi ha classe perquè és festa.»"}
        ]
      },
      {
        "passage": {"media": "audio", "title": "A l'oficina de l'ajuntament", "lines": [
          {"speaker": "Funcionària", "voice": "gina", "text": "Per a demanar el certificat d'empadronament, agafeu un número en la màquina de l'entrada i espereu que isca en la pantalla. Porteu el DNI o el passaport. El certificat és gratuït i vos el donem en el moment."}
        ]},
        "exercises": [
          {"q": "Què cal fer primer?", "o": ["Agafar un número", "Anar a la pantalla", "Pagar el certificat"], "e": "«Agafeu un número en la màquina de l'entrada.»"},
          {"q": "Quant costa el certificat?", "o": ["Res, és gratuït", "Cinc euros", "Depén del document"], "e": "«El certificat és gratuït.»"}
        ]
      }
    ]
  },
  {
    "id": "b13de171-1883-4f5b-bc30-6cec8a22bc74", "category": "comprensio_oral", "type": "co_dialegs", "sort_order": 3,
    "title": "Diàlegs quotidians", "name": "Compres en una botiga",
    "content": "Capta el sentit general i les dades concretes d'un diàleg senzill.", "icon": "👟", "color": "#C8E6C9",
    "blocks": [
      {
        "passage": {"media": "audio", "title": "En una sabateria", "lines": [
          {"speaker": "Dependenta", "voice": "gina", "text": "Bona vesprada! Puc ajudar-te?"},
          {"speaker": "Client", "voice": "lluc", "text": "Sí, per favor. Busque unes sabates esportives per a córrer."},
          {"speaker": "Dependenta", "voice": "gina", "text": "Quin número uses?"},
          {"speaker": "Client", "voice": "lluc", "text": "El quaranta-dos."},
          {"speaker": "Dependenta", "voice": "gina", "text": "Tenim estes en blanc i en blau. Les blanques costen seixanta euros i les blaves, cinquanta-cinc."},
          {"speaker": "Client", "voice": "lluc", "text": "M'agraden més les blaves. Puc provar-me-les?"},
          {"speaker": "Dependenta", "voice": "gina", "text": "Clar que sí. Com et van?"},
          {"speaker": "Client", "voice": "lluc", "text": "Em van un poc xicotetes. Tens el quaranta-tres?"},
          {"speaker": "Dependenta", "voice": "gina", "text": "Sí, ací el tens."},
          {"speaker": "Client", "voice": "lluc", "text": "Estes em van perfectes. Me les quede. Puc pagar amb targeta?"},
          {"speaker": "Dependenta", "voice": "gina", "text": "Sí, sense cap problema."}
        ]},
        "exercises": [
          {"q": "Què vol comprar el client?", "o": ["Unes sabates esportives", "Unes botes", "Una camiseta"], "e": "«Busque unes sabates esportives per a córrer.»"},
          {"q": "De quin color les tria?", "o": ["Blaves", "Blanques", "Negres"], "e": "«M'agraden més les blaves.»"},
          {"q": "Quant li costen?", "o": ["Cinquanta-cinc euros", "Seixanta euros", "Quaranta-dos euros"], "e": "Les blaves costen cinquanta-cinc euros."},
          {"q": "Quin número s'endú finalment?", "o": ["El quaranta-tres", "El quaranta-dos", "El quaranta-quatre"], "e": "El quaranta-dos li va xicotet i es queda el quaranta-tres."},
          {"q": "Com paga?", "o": ["Amb targeta", "En efectiu", "Encara no paga"], "e": "«Puc pagar amb targeta?» — «Sí, sense cap problema.»"}
        ]
      }
    ]
  },
  {
    "id": "49c60d99-e4da-40de-a362-4ef97181833c", "category": "comprensio_oral", "type": "co_debats", "sort_order": 4,
    "title": "Debats i discussions", "name": "Opinions sobre un tema",
    "content": "Identifica el tema general i les opinions d'una discussió lenta i clara.", "icon": "💬", "color": "#D1C4E9",
    "blocks": [
      {
        "passage": {"media": "audio", "title": "Un debat a la ràdio del poble", "lines": [
          {"speaker": "Neus", "voice": "gina", "text": "Hui parlem d'un tema que interessa molt al poble: tancar el centre als cotxes els caps de setmana. Jordi, tu què en penses?"},
          {"speaker": "Jordi", "voice": "lluc", "text": "Jo estic a favor. El centre serà més tranquil, hi haurà menys soroll i els xiquets podran jugar al carrer."},
          {"speaker": "Neus", "voice": "gina", "text": "Però molts comerciants diuen que vendran menys, perquè la gent no podrà aparcar prop de les tendes."},
          {"speaker": "Jordi", "voice": "lluc", "text": "Jo crec que no. En molts pobles ho han fet i ara passeja més gent pel centre i compra més."},
          {"speaker": "Neus", "voice": "gina", "text": "I els veïns grans, que caminen poc?"},
          {"speaker": "Jordi", "voice": "lluc", "text": "Per a ells, l'ajuntament posarà un autobús xicotet i gratuït."}
        ]},
        "exercises": [
          {"q": "De quin tema parlen?", "o": ["De tancar el centre als cotxes", "De construir un aparcament", "D'obrir tendes noves"], "e": "«Tancar el centre als cotxes els caps de setmana.»"},
          {"q": "Què pensa Jordi?", "o": ["Està a favor", "Està en contra", "No té opinió"], "e": "«Jo estic a favor.»"},
          {"q": "Per què estan preocupats alguns comerciants?", "o": ["Pensen que vendran menys", "No volen soroll", "No tenen autobús"], "e": "«Diuen que vendran menys, perquè la gent no podrà aparcar.»"},
          {"q": "Quina solució hi ha per a la gent gran?", "o": ["Un autobús gratuït", "Aparcaments nous", "Taxis més barats"], "e": "«L'ajuntament posarà un autobús xicotet i gratuït.»"}
        ]
      }
    ]
  },
  {
    "id": "13f987c9-442d-454c-b6a7-c3badafc914b", "category": "comprensio_oral", "type": "co_mitjans", "sort_order": 5,
    "title": "Ràdio i televisió", "name": "Falques i previsió del temps",
    "content": "Entén el sentit general i les dades d'un anunci de ràdio i de la previsió meteorològica.", "icon": "📻", "color": "#FFCDD2",
    "blocks": [
      {
        "passage": {"media": "audio", "title": "Falca de ràdio", "lines": [
          {"speaker": "Locutor", "voice": "lluc", "text": "Arriba la Fira del Llibre de Castelló! Del dotze al vint d'abril, a la plaça Major, trobareu més de cinquanta parades amb llibres en valencià, contacontes per als xiquets i signatures d'autors. Obrim cada dia de deu del matí a nou de la nit. L'entrada és lliure. Fira del Llibre de Castelló: llig, viu, gaudix!"}
        ]},
        "exercises": [
          {"q": "Què anuncia la falca?", "o": ["Una fira del llibre", "Un festival de música", "Un mercat de roba"], "e": "«Arriba la Fira del Llibre de Castelló!»"},
          {"q": "On es fa?", "o": ["A la plaça Major", "A la biblioteca", "Al port"], "e": "«A la plaça Major.»"},
          {"q": "Quant costa entrar?", "o": ["Res, l'entrada és lliure", "Deu euros", "Cinc euros"], "e": "«L'entrada és lliure»: no cal pagar."}
        ]
      },
      {
        "passage": {"media": "audio", "title": "El temps", "lines": [
          {"speaker": "Presentadora", "voice": "gina", "text": "Bon dia! Demà dissabte el temps canviarà. Al matí farà sol a tot el territori, però a la vesprada arribaran núvols i plourà a l'interior de Castelló i de València. Les temperatures baixaran: a la costa, la màxima serà de díhuit graus. Diumenge tornarà el sol, però farà vent a la costa d'Alacant."}
        ]},
        "exercises": [
          {"q": "Quin temps farà dissabte al matí?", "o": ["Sol", "Pluja", "Vent"], "e": "«Al matí farà sol a tot el territori.»"},
          {"q": "On plourà dissabte de vesprada?", "o": ["A l'interior de Castelló i de València", "A la costa d'Alacant", "A tot arreu"], "e": "«Plourà a l'interior de Castelló i de València.»"},
          {"q": "Què passarà diumenge a la costa d'Alacant?", "o": ["Farà vent", "Nevarà", "Plourà molt"], "e": "«Farà vent a la costa d'Alacant.»"}
        ]
      }
    ]
  },
  {
    "id": "5d5c0103-fabf-40c7-9528-e550e7fbd42e", "category": "comprensio_oral", "type": "co_megafonia", "sort_order": 6,
    "title": "Megafonia i avisos", "name": "Estacions, aeroports i botigues",
    "content": "Entén missatges i indicacions públiques per megafonia.", "icon": "📢", "color": "#FFF9C4",
    "blocks": [
      {
        "passage": {"media": "audio", "title": "Tres avisos", "lines": [
          {"speaker": "Estació", "voice": "gina", "text": "Atenció, per favor. El tren regional amb destinació a Xàtiva, que havia d'eixir a les deu i quart, eixirà amb vint minuts de retard per la via tres."},
          {"speaker": "Aeroport", "voice": "lluc", "text": "Senyores i senyors passatgers del vol amb destinació a Palma: es prega que vagen a la porta d'embarcament B12. L'embarcament començarà d'ací a deu minuts."},
          {"speaker": "Supermercat", "voice": "gina", "text": "Benvolguts clients: el supermercat tancarà d'ací a quinze minuts. Per favor, passen per caixa. Recordem que demà, diumenge, obrim de deu a dues."}
        ]},
        "exercises": [
          {"q": "A quina hora eixirà el tren de Xàtiva?", "o": ["A les deu i trenta-cinc", "A les deu i quart", "A les deu i vint"], "e": "Havia d'eixir a les deu i quart, amb vint minuts de retard: a les deu i trenta-cinc."},
          {"q": "Per quina via eixirà?", "o": ["Per la tres", "Per la dotze", "Per la dos"], "e": "«Per la via tres.»"},
          {"q": "On han d'anar els passatgers del vol a Palma?", "o": ["A la porta B12", "A la via tres", "A la caixa"], "e": "«A la porta d'embarcament B12.»"},
          {"q": "Què demanen als clients del supermercat?", "o": ["Que vagen a pagar", "Que tornen demà", "Que agafen un número"], "e": "«Tancarà d'ací a quinze minuts. Per favor, passen per caixa.»"},
          {"q": "Quin horari té el supermercat diumenge?", "o": ["De deu a dues", "No obri", "De deu a deu"], "e": "«Demà, diumenge, obrim de deu a dues.»"}
        ]
      }
    ]
  },
  {
    "id": "d5eec6dc-3e42-4564-8505-083fe2803f2d", "category": "comprensio_oral", "type": "co_orientacio", "sort_order": 7,
    "title": "Orientació", "name": "Com arribar a un lloc",
    "content": "Seguix instruccions pas a pas per a arribar a peu o en transport públic.", "icon": "🧭", "color": "#DCEDC8",
    "blocks": [
      {
        "passage": {"media": "audio", "title": "On és Correus?", "lines": [
          {"speaker": "Turista", "voice": "lluc", "text": "Perdone, sap on és l'oficina de Correus?"},
          {"speaker": "Veïna", "voice": "gina", "text": "Sí, no està lluny. Seguisca tot recte per este carrer fins a la plaça de l'Església. Allí, gire a la dreta i agafe el segon carrer a l'esquerra. Correus està al costat d'una farmàcia, davant del parc."},
          {"speaker": "Turista", "voice": "lluc", "text": "Hi ha molta distància?"},
          {"speaker": "Veïna", "voice": "gina", "text": "No, a peu són uns deu minuts. Si està cansat, l'autobús número quatre para just davant."},
          {"speaker": "Turista", "voice": "lluc", "text": "Moltes gràcies!"}
        ]},
        "exercises": [
          {"q": "Fins a on ha de seguir recte?", "o": ["Fins a la plaça de l'Església", "Fins al parc", "Fins a la farmàcia"], "e": "«Seguisca tot recte fins a la plaça de l'Església.»"},
          {"q": "Què ha de fer en la plaça?", "o": ["Girar a la dreta", "Girar a l'esquerra", "Seguir recte"], "e": "«Allí, gire a la dreta.»"},
          {"q": "Què hi ha al costat de Correus?", "o": ["Una farmàcia", "Una església", "Una parada de taxis"], "e": "«Correus està al costat d'una farmàcia, davant del parc.»"},
          {"q": "Quant es tarda a peu?", "o": ["Uns deu minuts", "Mitja hora", "Dos minuts"], "e": "«A peu són uns deu minuts.»"},
          {"q": "Quin autobús pot agafar?", "o": ["El quatre", "El deu", "El dos"], "e": "«L'autobús número quatre para just davant.»"}
        ]
      }
    ]
  },
  {
    "id": "2da45308-17e5-43b6-958c-c14dc9497160", "category": "comprensio_escrita", "type": "ce_noticies", "sort_order": 1,
    "title": "Notícies", "name": "Notícies breus de premsa",
    "content": "Comprén una notícia breu i extrau-ne les dades clau.", "icon": "📰", "color": "#CFD8DC",
    "blocks": [
      {
        "passage": {"media": "text", "title": "La biblioteca de Sueca obrirà també els diumenges", "lines": [
          {"text": "La biblioteca municipal de Sueca obrirà també els diumenges a partir del pròxim mes de novembre. L'horari serà de deu del matí a dues de la vesprada."},
          {"text": "Segons l'ajuntament, la decisió respon a la petició de molts estudiants, que necessiten un lloc tranquil per a estudiar durant els caps de setmana, sobretot en època d'exàmens."},
          {"text": "A més, la biblioteca oferirà cada diumenge una activitat per a xiquets: contacontes, tallers de dibuix i jocs de taula. Les activitats són gratuïtes, però cal inscriure's abans en la web de l'ajuntament."}
        ]},
        "exercises": [
          {"q": "Què canvia a la biblioteca?", "o": ["Obrirà també els diumenges", "Tancarà els dissabtes", "Canviarà de lloc"], "e": "Primer paràgraf: obrirà també els diumenges."},
          {"q": "Quan comença el nou horari?", "o": ["Al novembre", "Demà", "A l'estiu"], "e": "«A partir del pròxim mes de novembre.»"},
          {"q": "Qui havia demanat el canvi?", "o": ["Molts estudiants", "Els xiquets", "Els treballadors"], "e": "«Respon a la petició de molts estudiants.»"},
          {"q": "Què cal fer per a participar en les activitats per a xiquets?", "o": ["Inscriure's en la web", "Pagar a l'entrada", "Portar un llibre"], "e": "«Són gratuïtes, però cal inscriure's abans en la web.»"}
        ]
      }
    ]
  },
  {
    "id": "024f0b76-81a9-4c47-8a58-f99d0ae29e75", "category": "comprensio_escrita", "type": "ce_opinio", "sort_order": 2,
    "title": "Textos d'opinió", "name": "Identificar la tesi principal",
    "content": "Comprén un text argumentatiu senzill i identifica'n la idea principal.", "icon": "🚲", "color": "#C8E6C9",
    "blocks": [
      {
        "passage": {"media": "text", "title": "Per què vaig en bici a la faena", "lines": [
          {"text": "Cada dia vaig a la faena en bicicleta i estic convençuda que és la millor opció per a moure's per la ciutat."},
          {"text": "En primer lloc, és bo per a la salut: faig exercici sense anar al gimnàs. En segon lloc, estalvie diners, perquè no gaste gasolina ni pague l'aparcament. A més, la bici no contamina."},
          {"text": "És veritat que quan plou no és gens agradable i que en alguns barris falten carrils bici. Però crec que l'ajuntament n'ha de fer més i que tots hauríem de provar-ho almenys un dia a la setmana."}
        ]},
        "exercises": [
          {"q": "Quina és la idea principal del text?", "o": ["Anar en bici a la faena és la millor opció", "Els carrils bici són perillosos", "El gimnàs és massa car"], "e": "La tesi apareix a la primera frase i es defén en la resta del text."},
          {"q": "Quin avantatge NO diu l'autora?", "o": ["Que arriba abans que en cotxe", "Que fa exercici", "Que estalvia diners"], "e": "Parla de la salut, dels diners i de la contaminació, però no del temps."},
          {"q": "Quin problema reconeix?", "o": ["Que quan plou no és agradable", "Que la bici és cara", "Que no té on deixar-la"], "e": "«És veritat que quan plou no és gens agradable.»"},
          {"q": "Què proposa al final?", "o": ["Fer més carrils i provar-ho un dia a la setmana", "Prohibir els cotxes", "Regalar bicis"], "e": "L'última frase recull la proposta."}
        ]
      }
    ]
  },
  {
    "id": "58bff655-a995-468c-b76f-7d5dd33af249", "category": "comprensio_escrita", "type": "ce_instruccions", "sort_order": 3,
    "title": "Instruccions", "name": "Textos instructius breus",
    "content": "Comprén instruccions breus i poc complexes de l'entorn immediat.", "icon": "📝", "color": "#FFE0B2",
    "blocks": [
      {
        "passage": {"media": "text", "title": "Com fer-se el carnet de la biblioteca", "lines": [
          {"text": "1. Omple el formulari d'inscripció. El trobaràs en el taulell de l'entrada o en la web."},
          {"text": "2. Porta el formulari, el DNI i una foto de carnet."},
          {"text": "3. Si tens menys de catorze anys, el pare o la mare ha de firmar el formulari."},
          {"text": "4. Arreplega el carnet en el mateix moment. És gratuït."},
          {"text": "5. Amb el carnet pots endur-te tres llibres durant quinze dies."}
        ]},
        "exercises": [
          {"q": "On pots trobar el formulari?", "o": ["En el taulell o en la web", "Només en la web", "A l'ajuntament"], "e": "Instrucció 1."},
          {"q": "Què NO cal portar?", "o": ["Una factura de la llum", "Una foto de carnet", "El DNI"], "e": "Instrucció 2: formulari, DNI i foto."},
          {"q": "Qui ha de firmar el formulari d'un xiquet de deu anys?", "o": ["El pare o la mare", "El bibliotecari", "El mateix xiquet"], "e": "Instrucció 3: té menys de catorze anys."},
          {"q": "Quants llibres pots endur-te alhora?", "o": ["Tres", "Quinze", "Catorze"], "e": "Instrucció 5: tres llibres durant quinze dies."}
        ]
      }
    ]
  },
  {
    "id": "12e436ef-c398-4f36-96ca-f1d5b6db92eb", "category": "comprensio_escrita", "type": "ce_retols", "sort_order": 4,
    "title": "Rètols i descripcions", "name": "Senyalística i descripcions",
    "content": "Entén rètols, cartells i avisos, i descripcions de persones, llocs i objectes.", "icon": "🪧", "color": "#FFCCBC",
    "blocks": [
      {
        "passage": {"media": "text", "title": "Rètols", "lines": [
          {"text": "Rètol A · PROHIBIT FUMAR"},
          {"text": "Rètol B · TANCAT PER VACANCES. TORNEM L'1 DE SETEMBRE"},
          {"text": "Rètol C · PERILL: TERRA MULLAT"},
          {"text": "Rètol D · ESTACIÓ DE METRO → 200 m"},
          {"text": "Rètol E · MENÚ DEL DIA: 12 € (PRIMER, SEGON, POSTRES I BEGUDA)"}
        ]},
        "exercises": [
          {"q": "Vols dinar sense gastar molts diners.", "o": ["Rètol E", "Rètol A", "Rètol C"], "e": "El menú del dia costa 12 € amb tot inclòs."},
          {"q": "Busques per on anar al metro.", "o": ["Rètol D", "Rètol B", "Rètol E"], "e": "La fletxa indica l'estació a 200 metres."},
          {"q": "Has de caminar amb compte per a no caure.", "o": ["Rètol C", "Rètol A", "Rètol D"], "e": "El terra està mullat."},
          {"q": "Esta botiga no obri en agost.", "o": ["Rètol B", "Rètol E", "Rètol C"], "e": "Està tancada per vacances fins a l'1 de setembre."},
          {"q": "No pots encendre un cigarret.", "o": ["Rètol A", "Rètol D", "Rètol B"], "e": "Prohibit fumar."}
        ]
      },
      {
        "passage": {"media": "text", "title": "Cartell al carrer", "lines": [
          {"text": "HE PERDUT LA MEUA GOSSA!"},
          {"text": "Es diu Lluna. És xicoteta, de color marró i té una taca blanca a la cara. Porta un collar roig."},
          {"text": "Es va perdre dimarts de vesprada prop del parc de l'Alameda. És molt bona i no mossega."},
          {"text": "Si la veus, telefona al 612 345 678. Gràcies!"}
        ]},
        "exercises": [
          {"q": "Com és la Lluna?", "o": ["Xicoteta i marró, amb una taca blanca", "Gran i blanca", "Negra, amb un collar blau"], "e": "Segon paràgraf del cartell."},
          {"q": "On es va perdre?", "o": ["Prop d'un parc", "A la platja", "A casa"], "e": "«Prop del parc de l'Alameda.»"},
          {"q": "Què vol dir «no mossega»?", "o": ["Que no fa mal amb les dents", "Que no menja", "Que no borda"], "e": "Mossegar: clavar les dents. Es pot deduir pel context: «És molt bona»."}
        ]
      }
    ]
  },
  {
    "id": "559b9e61-3da9-4c1d-95f3-7813adf78292", "category": "comprensio_escrita", "type": "ce_documents", "sort_order": 5,
    "title": "Documents quotidians", "name": "Horaris, preus i anuncis",
    "content": "Localitza informació específica en horaris, tarifes i anuncis, i deduïx significats pel context.", "icon": "🗓️", "color": "#B3E5FC",
    "blocks": [
      {
        "passage": {"media": "text", "title": "Piscina municipal", "lines": [
          {"text": "De dilluns a divendres: de 7.00 a 22.00 h · Dissabtes: de 9.00 a 20.00 h · Diumenges i festius: tancat"},
          {"text": "Entrada individual: 4 €. Menors de 12 anys i majors de 65: 2 €. Abonament mensual: 30 €."},
          {"text": "És obligatori portar gorra de bany. Prohibit menjar dins del recinte."}
        ]},
        "exercises": [
          {"q": "Pots nadar diumenge al matí?", "o": ["No, està tancat", "Sí, de 9 a 20 h", "Sí, de 7 a 22 h"], "e": "Diumenges i festius: tancat."},
          {"q": "Quant paga una xiqueta de 10 anys?", "o": ["2 €", "4 €", "30 €"], "e": "Menors de 12 anys: 2 €."},
          {"q": "Què és obligatori portar?", "o": ["Gorra de bany", "Ulleres", "Tovallola"], "e": "«És obligatori portar gorra de bany.»"},
          {"q": "Vas a nadar tres vegades per setmana. Què et convé més?", "o": ["L'abonament mensual", "L'entrada individual", "Anar-hi els diumenges"], "e": "Unes dotze entrades de 4 € costen més que l'abonament de 30 €."}
        ]
      },
      {
        "passage": {"media": "text", "title": "Anunci", "lines": [
          {"text": "ES LLOGA pis al centre d'Alcoi. Tres habitacions, dos banys, cuina moblada i balcó. Molt lluminós. A prop de l'estació de tren."},
          {"text": "550 € al mes. Interessats, telefoneu de 17 a 20 h al 965 00 11 22."}
        ]},
        "exercises": [
          {"q": "Què vol dir «es lloga»?", "o": ["Que s'hi pot viure pagant cada mes", "Que es ven", "Que ja està ocupat"], "e": "Llogar: pagar per a usar una cosa durant un temps. Ho indica el preu «al mes»."},
          {"q": "Quan pots telefonar?", "o": ["De 17 a 20 h", "Al matí", "A qualsevol hora"], "e": "«Telefoneu de 17 a 20 h.»"},
          {"q": "Què NO té el pis?", "o": ["Piscina", "Balcó", "Cuina moblada"], "e": "L'anunci no parla de piscina."}
        ]
      }
    ]
  },
  {
    "id": "e2118fdc-8cf9-4cfe-ac1f-2c70b69c9cea", "category": "comprensio_escrita", "type": "ce_correus", "sort_order": 6,
    "title": "Cartes i correus", "name": "Comunicació interpersonal",
    "content": "Comprén cartes, correus, invitacions, confirmacions i comandes.", "icon": "✉️", "color": "#F8BBD0",
    "blocks": [
      {
        "passage": {"media": "text", "title": "Correu d'Anna", "lines": [
          {"text": "Hola, Marc:"},
          {"text": "Com estàs? T'escric per a convidar-te al meu aniversari. Faré una festa el dissabte 14 a les nou de la nit a casa meua. Vindran els amics de la universitat i també la meua cosina Júlia, que ja coneixes."},
          {"text": "Si pots, porta alguna cosa per a beure; jo prepararé el sopar. Ah! I no cal que em compres cap regal, de veritat."},
          {"text": "Confirma'm si vens abans de dijous, per favor, que he de saber quanta gent serem."},
          {"text": "Una abraçada,\nAnna"}
        ]},
        "exercises": [
          {"q": "Per què escriu Anna?", "o": ["Per a convidar Marc a una festa", "Per a demanar-li un regal", "Per a donar-li les gràcies"], "e": "«T'escric per a convidar-te al meu aniversari.»"},
          {"q": "On serà la festa?", "o": ["A casa d'Anna", "A la universitat", "A casa de Júlia"], "e": "«A casa meua.»"},
          {"q": "Què ha de portar Marc?", "o": ["Alguna cosa per a beure", "El sopar", "Un regal"], "e": "«Porta alguna cosa per a beure; jo prepararé el sopar.»"},
          {"q": "Què ha de fer Marc abans de dijous?", "o": ["Confirmar si hi va", "Comprar el regal", "Telefonar a Júlia"], "e": "«Confirma'm si vens abans de dijous.»"}
        ]
      }
    ]
  },
  {
    "id": "4b489174-128e-44bd-9f19-f032ea21d116", "category": "expressio_escrita", "type": "ee_descripcio", "sort_order": 1,
    "title": "Descripcions i relats", "name": "Escriptura bàsica amb connectors",
    "content": "Escriu descripcions i històries senzilles amb connectors bàsics.", "icon": "🖊️", "color": "#FFE0B2",
    "exercises": [
      {"q": "Descriu la teua casa o el teu pis: on està, quantes estances té, com és la teua habitació i què és el que més t'agrada. Usa connectors com «i», «però», «a més» o «perquè».", "w": {"min_words": 60, "max_words": 80}},
      {"q": "Conta què vas fer el cap de setmana passat: on vas anar, amb qui i què et va agradar més. Ordena les accions amb «primer», «després» i «finalment».", "w": {"min_words": 60, "max_words": 80, "words": ["primer", "després", "finalment"], "min_words_used": 2}}
    ]
  },
  {
    "id": "c8628719-f1d2-4176-a15f-0e665e5eba2d", "category": "expressio_escrita", "type": "ee_vida", "sort_order": 2,
    "title": "La meua vida", "name": "Rutina, família i faena",
    "content": "Escriu sobre la rutina diària, la família, les condicions de vida i la faena.", "icon": "🏡", "color": "#DCEDC8",
    "exercises": [
      {"q": "Explica la teua rutina d'un dia normal: a quina hora t'alces, què fas al matí i a la vesprada, i què fas abans de dormir.", "w": {"min_words": 60, "max_words": 80, "words": ["prompte", "dinar", "sempre", "de vegades", "tard"], "min_words_used": 3}},
      {"q": "Presenta la teua família o els teus amics: qui són, com són (físic i caràcter) i què feu junts.", "w": {"min_words": 60, "max_words": 80}},
      {"q": "Explica en què treballes o què estudies (o què feies abans): l'horari, el lloc i el que més t'agrada i el que menys.", "w": {"min_words": 60, "max_words": 80}}
    ]
  },
  {
    "id": "0c6366f8-7a2c-4b74-b564-98da8b54071c", "category": "expressio_escrita", "type": "ee_formularis", "sort_order": 3,
    "title": "Formularis", "name": "Fitxes i sol·licituds",
    "content": "Completa formularis i models textuals breus i tancats.", "icon": "🗂️", "color": "#C5CAE9",
    "exercises": [
      {"q": "Vols apuntar-te a una activitat del poliesportiu municipal. Omple la fitxa d'inscripció.", "f": ["Nom i cognoms", "Data de naixement", "Adreça", "Telèfon", "Activitat que vols fer", "Dies i horari que prefereixes", "Per què vols fer esta activitat?"]},
      {"q": "Has perdut la maleta a l'aeroport. Omple el formulari de reclamació.", "f": ["Nom i cognoms", "Número de vol", "Data del viatge", "Descripció de la maleta (color, grandària...)", "Què hi havia dins de la maleta?", "Telèfon i correu electrònic"]}
    ]
  },
  {
    "id": "fbd2efb4-79e9-4935-b3a9-db66f12a53b6", "category": "expressio_escrita", "type": "ee_notes", "sort_order": 4,
    "title": "Notes i missatges", "name": "Missatges breus i dubtes",
    "content": "Anota missatges breus i expressa per escrit dubtes o incomprensió.", "icon": "🗒️", "color": "#FFF9C4",
    "exercises": [
      {"q": "Deixa una nota a la persona amb qui comparteixes pis: hui arribaràs tard, cal comprar pa i llet i ha telefonat el propietari del pis.", "w": {"min_words": 25, "max_words": 40}},
      {"q": "Escriu un missatge a la teua professora: no has entés els deures per a dilluns. Explica què no has entés i demana-li ajuda.", "w": {"min_words": 25, "max_words": 40}},
      {"q": "Has contestat una telefonada per a un company de faena que no hi era. Deixa-li una nota: qui ha telefonat, per què i què ha de fer.", "w": {"min_words": 25, "max_words": 40}}
    ]
  },
  {
    "id": "3f56c1b7-d9c8-476d-9040-7a87ce8d0e59", "category": "expressio_escrita", "type": "ee_correus", "sort_order": 5,
    "title": "Cartes i correus", "name": "Disculpar-se, excusar-se i agrair",
    "content": "Escriu cartes personals i correus per a disculpar-te, excusar-te o donar les gràcies.", "icon": "💌", "color": "#F8BBD0",
    "exercises": [
      {"q": "Una amiga t'ha convidat al sopar del seu aniversari, però no pots anar-hi. Escriu-li un correu per a disculpar-te: explica per què no pots anar, felicita-la i proposa-li quedar un altre dia.", "w": {"min_words": 60, "max_words": 80}},
      {"q": "Has passat uns dies a casa d'uns amics. Escriu-los un correu per a donar-los les gràcies: conta què és el que més t'ha agradat i convida'ls a vindre a ta casa.", "w": {"min_words": 60, "max_words": 80}},
      {"q": "La setmana que ve no podràs anar a classe de valencià. Escriu un correu formal a l'acadèmia per a excusar-te, explicar el motiu i demanar els materials.", "w": {"min_words": 50, "max_words": 70}}
    ]
  },
  {
    "id": "afeec18e-6204-4efc-bdc2-4b1c87e0957d", "category": "expressio_oral", "type": "eo_descripcio", "sort_order": 1,
    "title": "Descriure i narrar", "name": "Conversa amb Marta",
    "content": "Descriu persones, espais i rutines, i conta fets recents, gustos i preferències.", "icon": "🧑‍🤝‍🧑", "color": "#B2EBF2",
    "metadata": {
      "character": "Marta, companya d'intercanvi", "voice": "gina",
      "initial_prompt": "Hola! Soc Marta, encantada! Com que és el primer dia de l'intercanvi, conta'm una mica de tu: com eres i on vius?",
      "objectius": ["Descriu-te: com eres físicament i de caràcter.", "Descriu la teua casa o el teu barri.", "Conta què vas fer el cap de setmana passat.", "Explica què t'agrada fer en el temps lliure."],
      "system_prompt": "Ets Marta, una jove valenciana simpàtica que fa un intercanvi de conversa amb una persona que prepara el nivell A2 de la JQCV. Fes-li preguntes perquè descriga persones (físic i caràcter), la seua casa, el seu barri, la seua rutina, fets recents i els seus gustos. Parla en valencià general, amb frases curtes i clares, vocabulari quotidià i una sola pregunta per torn. Si s'equivoca, repetix la frase de manera correcta dins de la teua resposta, sense fer lliçons. Anima-la a allargar les respostes (per exemple: «I com és?», «I què més vas fer?»)."
    }
  },
  {
    "id": "6c707bd9-a1e6-4370-ad37-82f0c065d021", "category": "expressio_oral", "type": "eo_entrevista", "sort_order": 2,
    "title": "Preguntes i respostes", "name": "Entrevista de faena amb Andreu",
    "content": "Pregunta i respon sobre assumptes personals, d'estudi i de faena.", "icon": "💼", "color": "#FFE0B2",
    "metadata": {
      "character": "Andreu, responsable d'un alberg", "voice": "lluc",
      "initial_prompt": "Bon dia, passa i seu. Soc Andreu, el responsable de l'alberg. Busquem una persona per a treballar este estiu. Com et dius i d'on eres?",
      "objectius": ["Presenta't: nom, origen i edat.", "Explica què estudies o en què has treballat.", "Respon què saps fer i quins idiomes parles.", "Pregunta per l'horari i el sou de la faena."],
      "system_prompt": "Ets Andreu, responsable d'un alberg juvenil de Morella, i fas una entrevista de treball per a l'estiu a una persona que prepara el nivell A2 de la JQCV. Fes preguntes senzilles, una per torn, sobre dades personals, estudis, faenes anteriors, idiomes i disponibilitat. Quan la persona pregunte per l'horari, el sou o les tasques, respon amb dades concretes (per exemple: de 8 a 15 h, 1.200 € al mes, atendre la recepció i organitzar activitats). Parla en valencià general, amb frases curtes i un registre formal però amable. Si s'equivoca, reformula-ho bé dins de la teua resposta, sense corregir-la explícitament."
    }
  },
  {
    "id": "d6da3054-2982-431e-b05c-300cd9b19472", "category": "expressio_oral", "type": "eo_exposicio", "sort_order": 3,
    "title": "Exposició breu", "name": "Presentació davant del professor",
    "content": "Fes una presentació breu i preparada sobre plans, la vida quotidiana o una opinió simple.", "icon": "🎤", "color": "#D1C4E9",
    "metadata": {
      "character": "Josep, professor de valencià", "voice": "lluc",
      "initial_prompt": "Bon dia! Hui toca l'exposició oral. Tens un parell de minuts per a parlar dels teus plans per a les pròximes vacances. Quan vulgues, comença!",
      "objectius": ["Explica on aniràs i amb qui.", "Explica com hi aniràs i quants dies.", "Conta què faràs allí.", "Dona la teua opinió: per què t'agrada eixe pla?"],
      "system_prompt": "Ets Josep, professor de valencià, i escoltes l'exposició oral breu d'una persona que prepara el nivell A2 de la JQCV. El tema són els seus plans per a les vacances, però si en vol parlar d'un altre de quotidià (el seu poble, una festa, la seua faena), accepta-ho. Deixa-la parlar i, després de cada intervenció, fes una sola pregunta breu perquè amplie la informació (on, quan, amb qui, per què). Quan haja cobert els objectius, fes-li un comentari final breu i positiu amb una o dues coses per millorar. Parla en valencià general i amb frases clares."
    }
  },
  {
    "id": "df177758-c43b-4ebf-ba2c-58e7b539e8c6", "category": "expressio_oral", "type": "eo_estrategies", "sort_order": 4,
    "title": "Estratègies d'interacció", "name": "Xarrar amb Pepa, la veïna",
    "content": "Inicia, mantín i tanca una conversa; demana que et repetisquen o que t'aclarisquen una paraula.", "icon": "👵", "color": "#FFCDD2",
    "metadata": {
      "character": "Pepa, veïna del poble", "voice": "gina",
      "initial_prompt": "Ai, bon dia! Què fas per ací tan de matí? Vas cap al forn o vas a la plaça, que hui hi ha mercat?",
      "objectius": ["Saluda i respon a Pepa.", "Demana-li que repetisca o que parle més a poc a poc.", "Pregunta què vol dir una paraula que no entens.", "Acomiada't amablement per a acabar la conversa."],
      "system_prompt": "Ets Pepa, una veïna gran, xarraire i afectuosa d'un poble valencià, que conversa amb una persona que prepara el nivell A2 de la JQCV. L'objectiu és que practique estratègies d'interacció: iniciar, mantindre i acabar una conversa, demanar que li repetisques una cosa i preguntar el significat de paraules. De tant en tant usa alguna paraula o expressió col·loquial poc coneguda (per exemple: «estar fet pols», «fer la migdiada», «el porrat») i, quan la persona et pregunte què vol dir, explica-ho amb paraules senzilles. Si et demana que repetisques o que parles més a poc a poc, fes-ho amb una frase més curta. Parla en valencià general, amb frases no massa llargues. Si la persona s'acomiada, acomiada't tu també."
    }
  }
  ]$data$;
  r jsonb;
  b jsonb;
  e jsonb;
  rid uuid;
  pid uuid;
  ppos smallint;
  epos smallint;
BEGIN
  FOR r IN SELECT * FROM jsonb_array_elements(catalog) LOOP
    rid := (r->>'id')::uuid;
    INSERT INTO public.resources (id, name, type, category, content, difficulty, xp_earned, sort_order, metadata)
    VALUES (
      rid, r->>'name', r->>'type', r->>'category', r->>'content', 'principiant', 10, (r->>'sort_order')::smallint,
      jsonb_build_object('icon', r->>'icon', 'color', r->>'color', 'section_name', r->>'title') || coalesce(r->'metadata', '{}')
    )
    ON CONFLICT (id) DO UPDATE SET
      name = EXCLUDED.name,
      type = EXCLUDED.type,
      category = EXCLUDED.category,
      content = EXCLUDED.content,
      sort_order = EXCLUDED.sort_order,
      metadata = EXCLUDED.metadata;

    -- Es reescriu el contingut A2 del recurs: tornar a aplicar el fitxer no el duplica.
    DELETE FROM public.practice_exercises WHERE resource_id = rid AND level = 'A2';
    DELETE FROM public.practice_passages WHERE resource_id = rid AND level = 'A2';

    ppos := 0;
    epos := 0;
    FOR b IN SELECT * FROM jsonb_array_elements(
      coalesce(r->'blocks', CASE WHEN r ? 'exercises' THEN jsonb_build_array(jsonb_build_object('exercises', r->'exercises')) ELSE '[]' END)
    ) LOOP
      pid := NULL;
      IF b ? 'passage' THEN
        ppos := ppos + 1;
        INSERT INTO public.practice_passages (resource_id, level, position, media, title, lines, audio_url)
        VALUES (
          rid, 'A2', ppos, b->'passage'->>'media', b->'passage'->>'title', b->'passage'->'lines',
          CASE WHEN b->'passage'->>'media' = 'audio' THEN format('/audio/practice/%s-a2-%s.wav', r->>'type', ppos) END
        )
        RETURNING id INTO pid;
      END IF;

      FOR e IN SELECT * FROM jsonb_array_elements(b->'exercises') LOOP
        epos := epos + 1;
        INSERT INTO public.practice_exercises (resource_id, level, position, passage_id, kind, prompt, options, answers, task, explanation)
        VALUES (
          rid, 'A2', epos, pid,
          CASE WHEN e ? 'o' THEN 'choice' WHEN e ? 'a' THEN 'fill' WHEN e ? 'w' THEN 'writing' ELSE 'form' END,
          e->>'q',
          CASE WHEN e ? 'o' THEN ARRAY(SELECT jsonb_array_elements_text(e->'o')) END,
          CASE WHEN e ? 'o' THEN ARRAY[e->'o'->>0] WHEN e ? 'a' THEN ARRAY(SELECT jsonb_array_elements_text(e->'a')) END,
          CASE WHEN e ? 'w' THEN e->'w' WHEN e ? 'f' THEN jsonb_build_object('fields', e->'f') END,
          e->>'e'
        );
      END LOOP;
    END LOOP;
  END LOOP;
END
$do$;

-- ============================================================
-- Origen: 20260930130000_practice_fonetica_more.sql
-- ============================================================
-- Més exercicis A2 per als continguts de 4.1 Fonètica i ortografia
-- (20260930110000 en tenia 8-10 per contingut): s'afigen darrere dels que ja hi
-- ha, a partir de la posició `offset`, fins a uns 35 per contingut. Tornar a
-- aplicar el fitxer no els duplica: primer s'esborren les posicions > offset.

CREATE TEMP TABLE practice_more AS
SELECT * FROM jsonb_to_recordset($data$[
  {
    "id": "5340aadb-100f-428d-a1ad-6d866a54a2e6", "offset": 8,
    "exercises": [
      {"q": "Quina és la síl·laba tònica de «rellotge»?", "o": ["-llot-", "re-", "-ge"], "e": "Re-LLOT-ge és plana: la tònica és la penúltima síl·laba."},
      {"q": "Quina és la síl·laba tònica de «ordinador»?", "o": ["-dor", "or-", "-di-"], "e": "Or-di-na-DOR és aguda: la tònica és l'última síl·laba."},
      {"q": "Quina és la síl·laba tònica de «llibre»?", "o": ["lli-", "-bre"], "e": "LLI-bre és plana."},
      {"q": "Quina és la síl·laba tònica de «tomaca»?", "o": ["-ma-", "to-", "-ca"], "e": "To-MA-ca és plana acabada en vocal: per això no porta accent."},
      {"q": "Quina és la síl·laba tònica de «plàtan»?", "o": ["plà-", "-tan"], "e": "PLÀ-tan és plana; l'accent gràfic ens ho indica."},
      {"q": "Quina és la síl·laba tònica de «telèfon»?", "o": ["-lè-", "te-", "-fon"], "e": "Te-LÈ-fon és plana acabada en -n (no en -en): porta accent."},
      {"q": "Quina és la síl·laba tònica de «paella»?", "o": ["-e-", "pa-", "-lla"], "e": "Pa-E-lla és plana: la tònica és la penúltima síl·laba."},
      {"q": "Quina és la síl·laba tònica de «dinar»?", "o": ["-nar", "di-"], "e": "Di-NAR és aguda acabada en -r: no porta accent."},
      {"q": "Quina és la síl·laba tònica de «pantalons»?", "o": ["-lons", "pan-", "-ta-"], "e": "Pan-ta-LONS és aguda."},
      {"q": "Quina és la síl·laba tònica de «ciutat»?", "o": ["-tat", "ciu-"], "e": "Ciu-TAT és aguda acabada en -t: no porta accent."},
      {"q": "Quina és la síl·laba tònica de «música»?", "o": ["mú-", "-si-", "-ca"], "e": "MÚ-si-ca és esdrúixola."},
      {"q": "Quina és la síl·laba tònica de «bicicleta»?", "o": ["-cle-", "bi-", "-ci-", "-ta"], "e": "Bi-ci-CLE-ta és plana."},
      {"q": "Quina és la síl·laba tònica de «dimecres»?", "o": ["-me-", "di-", "-cres"], "e": "Di-ME-cres és plana acabada en -s: no porta accent."},
      {"q": "Quina és la síl·laba tònica de «setmana»?", "o": ["-ma-", "set-", "-na"], "e": "Set-MA-na és plana."},
      {"q": "Quina és la síl·laba tònica de «valencià»?", "o": ["-cià", "va-", "-len-"], "e": "Va-len-CIÀ és aguda acabada en vocal: porta accent."},
      {"q": "Quina és la síl·laba tònica de «Castelló»?", "o": ["-lló", "cas-", "-te-"], "e": "Cas-te-LLÓ és aguda acabada en vocal: porta accent."},
      {"q": "Quina és la síl·laba tònica de «Alacant»?", "o": ["-cant", "a-", "-la-"], "e": "A-la-CANT és aguda acabada en -nt: no porta accent."},
      {"q": "Quina d'estes paraules és aguda?", "o": ["cafè", "cadira", "número"], "e": "Ca-FÈ és aguda. Cadira és plana i número, esdrúixola."},
      {"q": "Quina d'estes paraules és aguda?", "o": ["menjar", "menja", "menjava"], "e": "Men-JAR és aguda. MEN-ja i men-JA-va són planes."},
      {"q": "Quina d'estes paraules és aguda?", "o": ["cançó", "taula", "àlbum"], "e": "Can-ÇÓ és aguda. Taula i àlbum són planes."},
      {"q": "Quina d'estes paraules és plana?", "o": ["germana", "camió", "llàgrima"], "e": "Ger-MA-na és plana. Camió és aguda i llàgrima, esdrúixola."},
      {"q": "Quina d'estes paraules és plana?", "o": ["fàcil", "sofà", "màquina"], "e": "FÀ-cil és plana. Sofà és aguda i màquina, esdrúixola."},
      {"q": "Quina d'estes paraules és esdrúixola?", "o": ["màquina", "ordinador", "plàtan"], "e": "MÀ-qui-na és esdrúixola. Ordinador és aguda i plàtan, plana."},
      {"q": "Quina d'estes paraules és esdrúixola?", "o": ["número", "cadira", "cançó"], "e": "NÚ-me-ro és esdrúixola."},
      {"q": "Quantes síl·labes té «finestra»?", "o": ["3", "2", "4"], "e": "Fi-nes-tra: tres síl·labes."},
      {"q": "Quantes síl·labes té «ordinador»?", "o": ["4", "3", "5"], "e": "Or-di-na-dor: quatre síl·labes."},
      {"q": "Quantes síl·labes té «pa»?", "o": ["1", "2", "3"], "e": "Pa és monosíl·laba: té una sola síl·laba."}
    ]
  },
  {
    "id": "3d8fbee8-b30f-491c-9906-c442729c5e3d", "offset": 8,
    "exercises": [
      {"q": "Quina d'estes paraules va primer en el diccionari?", "o": ["casa", "cotxe", "cuina"], "e": "Les tres comencen per c: es mira la segona lletra (a, o, u)."},
      {"q": "Quina d'estes paraules va l'última en el diccionari?", "o": ["zero", "xiquet", "vaca"], "e": "L'ordre és v, x, z: zero va l'última."},
      {"q": "Quina llista està en ordre alfabètic?", "o": ["gat, gos, gust", "gos, gat, gust", "gust, gat, gos"], "e": "Es mira la segona lletra: a, o, u."},
      {"q": "Quina d'estes paraules va primer en el diccionari?", "o": ["mar", "mare", "marit"], "e": "Mar és més curta i les tres lletres coincidixen: va primer. Després mare (e) i marit (i)."},
      {"q": "Quina lletra ve després de la «p» en l'alfabet?", "o": ["q", "r", "o"], "e": "L'ordre és ... o, p, q, r ..."},
      {"q": "Quina lletra ve abans de la «t» en l'alfabet?", "o": ["s", "u", "r"], "e": "L'ordre és ... r, s, t, u ..."},
      {"q": "Quina d'estes paraules té un dígraf?", "o": ["guerra", "gran", "gat"], "e": "En «guerra» hi ha dos dígrafs: gu (davant de e) i rr."},
      {"q": "Quantes lletres i quants sons té «llet»?", "o": ["4 lletres i 3 sons", "4 lletres i 4 sons", "3 lletres i 3 sons"], "e": "El dígraf ll fa un sol so: ll-e-t."},
      {"q": "Quantes lletres i quants sons té «any»?", "o": ["3 lletres i 2 sons", "3 lletres i 3 sons", "2 lletres i 2 sons"], "e": "El dígraf ny fa un sol so: a-ny."},
      {"q": "Quantes lletres i quants sons té «carro»?", "o": ["5 lletres i 4 sons", "5 lletres i 5 sons", "4 lletres i 4 sons"], "e": "El dígraf rr fa un sol so: c-a-rr-o."},
      {"q": "Quantes lletres i quants sons té «guitarra»?", "o": ["8 lletres i 6 sons", "8 lletres i 7 sons", "8 lletres i 8 sons"], "e": "Hi ha dos dígrafs: gu (davant de i) i rr."},
      {"q": "Quina d'estes paraules té el dígraf «ny»?", "o": ["muntanya", "música", "nit"], "e": "Mun-ta-nya: ny fa un sol so."},
      {"q": "En quina paraula «qu» és un dígraf (la u no sona)?", "o": ["quinze", "quatre", "quan"], "e": "Davant de e i i, «qu» fa un sol so /k/. En quatre i quan la u sí que sona."},
      {"q": "En quina paraula «gu» és un dígraf (la u no sona)?", "o": ["guerra", "aigua", "guant"], "e": "Davant de e i i, «gu» fa un sol so. En aigua i guant la u sí que sona."},
      {"q": "Com se separa en síl·labes «carrer»?", "o": ["car-rer", "ca-rrer", "carr-er"], "e": "El dígraf rr es separa: car-rer."},
      {"q": "Com se separa en síl·labes «passeig»?", "o": ["pas-seig", "pa-sseig", "pass-eig"], "e": "El dígraf ss es separa: pas-seig."},
      {"q": "Com se separa en síl·labes «senyor»?", "o": ["se-nyor", "sen-yor", "seny-or"], "e": "El dígraf ny no se separa: se-nyor."},
      {"q": "Com se separa en síl·labes «metge»?", "o": ["met-ge", "me-tge", "metg-e"], "e": "El dígraf tg es separa: met-ge."},
      {"q": "Com se separa en síl·labes «platja»?", "o": ["plat-ja", "pla-tja", "platj-a"], "e": "El dígraf tj es separa: plat-ja."},
      {"q": "Com se separa en síl·labes «caixa»?", "o": ["cai-xa", "ca-ixa", "caix-a"], "e": "El dígraf ix es separa: cai-xa."},
      {"q": "Com se separa en síl·labes «guitarra»?", "o": ["gui-tar-ra", "gu-i-tar-ra", "gui-ta-rra"], "e": "Gu no se separa i rr sí: gui-tar-ra."},
      {"q": "Com se separa en síl·labes «escola»?", "o": ["es-co-la", "e-sco-la", "esc-o-la"], "e": "Es-co-la: la s va amb la síl·laba anterior."},
      {"q": "Com se separa en síl·labes «aigua»?", "o": ["ai-gua", "a-i-gua", "aig-ua"], "e": "Ai-gua: ai i ua són diftongs i no se separen."},
      {"q": "Quantes síl·labes té «estudiant»?", "o": ["4", "3", "5"], "e": "Es-tu-di-ant: la i i la a són en síl·labes diferents."},
      {"q": "Quina frase té les paraules ben separades?", "o": ["Vaig a comprar pa.", "Vaiga comprar pa.", "Vaig acomprar pa."], "e": "Vaig / a / comprar / pa: cada paraula s'escriu separada."},
      {"q": "Quina frase té les paraules ben separades?", "o": ["Tinc una germana.", "Tincuna germana.", "Tinc unager mana."], "e": "Tinc / una / germana."},
      {"q": "Quina frase té les paraules ben separades?", "o": ["El meu amic és de Sueca.", "Elmeu amic és de Sueca.", "El meuamic ésde Sueca."], "e": "El / meu / amic / és / de / Sueca."}
    ]
  },
  {
    "id": "975ade8f-5197-4edc-bd4a-20dd8816d65f", "offset": 9,
    "exercises": [
      {"q": "Quina forma és correcta?", "o": ["cafè", "café", "cafe"], "e": "Ca-FÈ és aguda acabada en vocal; la e és oberta: cafè."},
      {"q": "Quina forma és correcta?", "o": ["també", "tambè", "tambe"], "e": "Tam-BÉ és aguda acabada en vocal; la e és tancada: també."},
      {"q": "Quina forma és correcta?", "o": ["dijous", "dijóus", "díjous"], "e": "Di-JOUS és aguda acabada en diftong + s: no porta accent."},
      {"q": "Quina forma és correcta?", "o": ["cançó", "canço", "cánço"], "e": "Can-ÇÓ és aguda acabada en vocal: porta accent."},
      {"q": "Quina forma és correcta?", "o": ["número", "numero", "numéro"], "e": "NÚ-me-ro és esdrúixola: sempre porta accent."},
      {"q": "Quina forma és correcta?", "o": ["fàcil", "facil", "fácil"], "e": "FÀ-cil és plana acabada en -l: porta accent. La a sempre porta accent obert (à)."},
      {"q": "Quina forma és correcta?", "o": ["arròs", "arros", "arrós"], "e": "Ar-RÒS és aguda acabada en vocal + s: porta accent, i la o és oberta."},
      {"q": "Quina forma és correcta?", "o": ["matí", "mati", "màti"], "e": "Ma-TÍ és aguda acabada en vocal: porta accent."},
      {"q": "Quina forma és correcta?", "o": ["divendres", "divèndres", "divendrés"], "e": "Di-VEN-dres és plana acabada en -s: no porta accent."},
      {"q": "Quina forma és correcta?", "o": ["dilluns", "dillúns", "dílluns"], "e": "Di-LLUNS és aguda acabada en -ns: no porta accent."},
      {"q": "Quina forma és correcta?", "o": ["pastís", "pastis", "pàstis"], "e": "Pas-TÍS és aguda acabada en vocal + s: porta accent."},
      {"q": "Quina forma és correcta?", "o": ["jardí", "jardi", "jàrdi"], "e": "Jar-DÍ és aguda acabada en vocal: porta accent."},
      {"q": "Quina forma és correcta?", "o": ["estiu", "estíu", "éstiu"], "e": "Es-TIU és aguda acabada en diftong: no porta accent."},
      {"q": "Quina forma és correcta?", "o": ["després", "despres", "desprès"], "e": "Des-PRÉS és aguda acabada en vocal + s: porta accent; la e és tancada."},
      {"q": "Quina forma és correcta?", "o": ["València", "Valéncia", "Valencia"], "e": "Va-LÈN-ci-a porta accent obert en la e."},
      {"q": "Quina forma és correcta?", "o": ["dinar", "dinàr", "dínar"], "e": "Di-NAR és aguda acabada en -r: no porta accent."},
      {"q": "Quina forma és correcta?", "o": ["àlbum", "album", "albúm"], "e": "ÀL-bum és plana acabada en -m: porta accent."},
      {"q": "Quina forma és correcta?", "o": ["meló", "melo", "mèlo"], "e": "Me-LÓ és aguda acabada en vocal: porta accent."},
      {"q": "Quina d'estes paraules està ben escrita sense accent?", "o": ["germans", "cafe", "musica"], "e": "Ger-MANS és aguda acabada en -ns: no porta accent. Cafè i música sí que en porten."},
      {"q": "Per què no porta accent «taula»?", "o": ["Perquè és plana acabada en vocal", "Perquè és aguda", "Perquè és esdrúixola"], "e": "TAU-la és plana acabada en vocal: les planes acabades en vocal no s'accentuen."},
      {"q": "Per què porta accent «pastís»?", "o": ["Perquè és aguda acabada en vocal + s", "Perquè és plana acabada en -s", "Perquè és esdrúixola"], "e": "Les agudes acabades en vocal, vocal + s, -en o -in porten accent."},
      {"q": "Escriu la paraula amb l'accent correcte: sofa (seient per a dues o tres persones).", "a": ["sofà"], "e": "So-FÀ és aguda acabada en vocal."},
      {"q": "Escriu la paraula amb l'accent correcte: rapid (que va molt de pressa).", "a": ["ràpid"], "e": "RÀ-pid és plana acabada en -d: porta accent."},
      {"q": "Escriu la paraula amb l'accent correcte: autobus.", "a": ["autobús"], "e": "Au-to-BÚS és aguda acabada en vocal + s."},
      {"q": "Escriu la paraula amb l'accent correcte: maquina (de cosir, de rentar...).", "a": ["màquina"], "e": "MÀ-qui-na és esdrúixola: sempre porta accent."},
      {"q": "Escriu la paraula amb l'accent correcte: tambe.", "a": ["també"], "e": "Tam-BÉ és aguda acabada en vocal, amb e tancada."}
    ]
  },
  {
    "id": "b832d33a-d974-4137-8d8c-d23523f6d44a", "offset": 10,
    "exercises": [
      {"q": "Completa: ___ aigua està molt freda.", "o": ["L'", "La", "El"], "e": "L'article s'apostrofa davant de vocal: l'aigua."},
      {"q": "Completa: ___ home del bar és molt simpàtic.", "o": ["L'", "El", "Lo"], "e": "Davant de h muda també s'apostrofa: l'home."},
      {"q": "Completa: Ja és ___ hora de dinar.", "o": ["l'", "la", "el"], "e": "L'hora: la h és muda i la o és tònica."},
      {"q": "Completa: ___ illa és molt menuda.", "o": ["L'", "La", "El"], "e": "L'illa: la i és tònica, per això «la» s'apostrofa."},
      {"q": "Completa: ___ ordinador no funciona.", "o": ["L'", "El", "La"], "e": "El + ordinador → l'ordinador."},
      {"q": "Quina forma és correcta?", "o": ["la infermera", "l'infermera", "l' infermera"], "e": "«La» no s'apostrofa davant de i o u àtones: la infermera."},
      {"q": "Quina forma és correcta?", "o": ["la història", "l'història", "l' història"], "e": "His-TÒ-ri-a: la i és àtona, per això no s'apostrofa."},
      {"q": "Quina forma és correcta?", "o": ["l'avió", "el avió", "la avió"], "e": "Davant de vocal: l'avió."},
      {"q": "Quina forma és correcta?", "o": ["l'ull", "el ull", "lo ull"], "e": "Davant de vocal: l'ull."},
      {"q": "Quina forma és correcta?", "o": ["el pare", "l'pare", "lo pare"], "e": "Davant de consonant no s'apostrofa: el pare."},
      {"q": "Quina forma és correcta?", "o": ["l'escola i l'institut", "la escola i el institut", "l'escola i el institut"], "e": "Tots dos comencen per vocal: s'apostrofen."},
      {"q": "Completa: Són ___ una del migdia.", "o": ["la", "l'", "lo"], "e": "Per a les hores es diu «la una», sense apòstrof."},
      {"q": "Completa: Vinc ___ ajuntament.", "o": ["de l'", "del", "d'el"], "e": "Davant de vocal, l'article s'apostrofa i ja no hi ha contracció: de l'ajuntament."},
      {"q": "Completa: Anem ___ hospital.", "o": ["a l'", "al", "a el"], "e": "L'hospital: amb l'article apostrofat no es fa contracció."},
      {"q": "Completa: Vaig ___ metge.", "o": ["al", "a el", "a l'"], "e": "A + el → al."},
      {"q": "Completa: Tinc una casa ___ camp.", "o": ["al", "a el", "a l'"], "e": "A + el → al."},
      {"q": "Completa: Parlem ___ professors.", "o": ["dels", "de els", "d'els"], "e": "De + els → dels."},
      {"q": "Completa: Done el regal ___ xiquets.", "o": ["als", "a els", "a los"], "e": "A + els → als."},
      {"q": "Completa: Caminem ___ parc.", "o": ["pel", "per el", "per l'"], "e": "Per + el → pel."},
      {"q": "Completa: És el cotxe ___ Anna.", "o": ["d'", "de", "del"], "e": "La preposició «de» s'apostrofa davant de vocal: d'Anna."},
      {"q": "Completa: Vull una tassa ___ aigua.", "o": ["d'", "de", "del"], "e": "D'aigua: «de» davant de vocal."},
      {"q": "Completa: Vull una tassa ___ llet.", "o": ["de", "d'", "del"], "e": "Davant de consonant, «de» no s'apostrofa."},
      {"q": "Completa: Soc ___ Alacant.", "o": ["d'", "de", "del"], "e": "D'Alacant: «de» davant de vocal."},
      {"q": "Escriu la contracció: per + el", "a": ["pel"], "e": "Per + el → pel (passegem pel parc)."},
      {"q": "Escriu la contracció: a + el", "a": ["al"], "e": "A + el → al (anem al cine)."}
    ]
  },
  {
    "id": "b3f10344-a6e4-43f5-9a59-3dd9dd7ad9a5", "offset": 9,
    "exercises": [
      {"q": "Completa: cami__a (peça de roba)", "o": ["s", "ss", "ç"], "e": "Camisa: s sonora entre vocals → s."},
      {"q": "Completa: cla__e (aula de l'escola)", "o": ["ss", "s", "ç"], "e": "Classe: s sorda entre vocals → ss."},
      {"q": "Completa: ta__a (per a beure el café)", "o": ["ss", "s", "ç"], "e": "Tassa: s sorda entre vocals → ss."},
      {"q": "Completa: pre__a (Tinc molta ___, arribe tard!)", "o": ["ss", "s", "ç"], "e": "Pressa: s sorda entre vocals → ss."},
      {"q": "Completa: pi__ina (per a nadar)", "o": ["sc", "ss", "c"], "e": "Piscina s'escriu amb sc."},
      {"q": "Completa: __ol (brilla al cel)", "o": ["s", "c", "z"], "e": "Sol: a principi de paraula, davant de o, el so sord és s."},
      {"q": "Completa: __abates (les portem als peus)", "o": ["s", "c", "z"], "e": "Sabates: s a principi de paraula."},
      {"q": "Completa: __ucre (endolcix el café)", "o": ["s", "c", "z"], "e": "Sucre: s a principi de paraula."},
      {"q": "Completa: __inc (el número 5)", "o": ["c", "s", "z"], "e": "Cinc: c davant de i."},
      {"q": "Completa: __entre (el mig de la ciutat)", "o": ["c", "s", "z"], "e": "Centre: c davant de e."},
      {"q": "Completa: __ervesa (beguda)", "o": ["c", "s", "z"], "e": "Cervesa: c davant de e i s sonora entre vocals."},
      {"q": "Completa: po__ar (col·locar una cosa en un lloc)", "o": ["s", "ss", "ç"], "e": "Posar: s sonora entre vocals → s."},
      {"q": "Completa: bra__ (part del cos)", "o": ["ç", "s", "ss"], "e": "Braç: a final de paraula el so sord pot ser ç."},
      {"q": "Completa: for__a (energia per a fer una cosa)", "o": ["ç", "c", "ss"], "e": "Força: ç davant de a."},
      {"q": "Completa: No tinc for__es.", "o": ["c", "ç", "ss"], "e": "Forces: davant de e s'escriu c, no ç."},
      {"q": "El plural de «braç» és...", "o": ["braços", "bracos", "brasos"], "e": "Braços: davant de o es manté la ç."},
      {"q": "El plural de «gos» és...", "o": ["gossos", "gosos", "goços"], "e": "Gossos: la s sorda entre vocals s'escriu ss."},
      {"q": "El plural de «mes» és...", "o": ["mesos", "messos", "meços"], "e": "Mesos: s sonora entre vocals → s."},
      {"q": "El femení de «francés» és...", "o": ["francesa", "francessa", "franceça"], "e": "Francesa: s sonora entre vocals → s."},
      {"q": "El femení de «gros» és...", "o": ["grossa", "grosa", "groça"], "e": "Grossa: s sorda entre vocals → ss."},
      {"q": "Quina paraula vol dir «buscar animals per a atrapar-los»?", "o": ["caçar", "casar", "cassar"], "e": "Caçar (amb ç). Casar vol dir unir en matrimoni."},
      {"q": "Completa: tre__e (el número 13)", "o": ["tz", "ts", "z"], "e": "Tretze: s sonora després de t → tz."},
      {"q": "Completa: qui__e (el número 15)", "o": ["nz", "ns", "nc"], "e": "Quinze: s sonora després de n → z."},
      {"q": "Completa: do__ (el número 2)", "o": ["s", "ss", "ç"], "e": "Dos: s a final de paraula."},
      {"q": "Escriu en lletres el número 11.", "a": ["onze"], "e": "Onze: s sonora després de n → z."},
      {"q": "Escriu en lletres el número 16.", "a": ["setze"], "e": "Setze: s sonora després de t → tz."}
    ]
  },
  {
    "id": "5e910bc3-c0d6-486e-9edc-852f7f7684b2", "offset": 10,
    "exercises": [
      {"q": "Completa: __ardí (lloc amb plantes i flors)", "o": ["j", "g", "x"], "e": "Jardí: j davant de a."},
      {"q": "Completa: __ent (moltes persones)", "o": ["g", "j", "x"], "e": "Gent: g davant de e."},
      {"q": "Completa: __ener (el primer mes de l'any)", "o": ["g", "j", "x"], "e": "Gener: g davant de e."},
      {"q": "Completa: __uliol (el setè mes de l'any)", "o": ["j", "g", "x"], "e": "Juliol: j davant de u."},
      {"q": "Completa: __ugar (divertir-se amb un joc)", "o": ["j", "g", "x"], "e": "Jugar: j davant de u."},
      {"q": "Completa: men__ar (prendre aliments)", "o": ["j", "g", "tj"], "e": "Menjar: j davant de a."},
      {"q": "Completa: Jo men__e pa amb tomaca.", "o": ["g", "j", "tg"], "e": "Menge: davant de e s'escriu g."},
      {"q": "Completa: pu__ar (anar cap amunt)", "o": ["j", "g", "x"], "e": "Pujar: j davant de a."},
      {"q": "Completa: Nosaltres pu__em a la muntanya.", "o": ["g", "j", "x"], "e": "Pugem: davant de e canvia a g."},
      {"q": "Completa: plu__a (aigua que cau del cel)", "o": ["j", "g", "tj"], "e": "Pluja: j davant de a."},
      {"q": "Completa: pà__ina (d'un llibre)", "o": ["g", "j", "tg"], "e": "Pàgina: g davant de i."},
      {"q": "Completa: via__ar (anar d'un lloc a un altre)", "o": ["tj", "tg", "j"], "e": "Viatjar: tj davant de a."},
      {"q": "Completa: un via__e a París", "o": ["tg", "tj", "g"], "e": "Viatge: tg davant de e."},
      {"q": "Completa: rello__e (marca l'hora)", "o": ["tg", "tj", "g"], "e": "Rellotge: tg davant de e."},
      {"q": "Completa: ro__ (el color de la sang)", "o": ["ig", "tx", "ix"], "e": "Roig: a final de paraula, darrere de vocal, ig."},
      {"q": "Completa: __ocolata (llepolia de cacau)", "o": ["x", "tx", "ix"], "e": "Xocolata: a principi de paraula, x."},
      {"q": "Completa: __iquet (persona de poca edat)", "o": ["x", "tx", "ix"], "e": "Xiquet: a principi de paraula, x."},
      {"q": "Completa: cai__a (recipient per a guardar coses)", "o": ["ix", "x", "tx"], "e": "Caixa: darrere de vocal, ix."},
      {"q": "Completa: dibu__ar (fer un dibuix)", "o": ["ix", "x", "tx"], "e": "Dibuixar: darrere de vocal, ix."},
      {"q": "Completa: madu__a (fruita roja i xicoteta)", "o": ["ix", "x", "tx"], "e": "Maduixa: darrere de vocal, ix."},
      {"q": "Completa: fi__a (targeta amb informació)", "o": ["tx", "ix", "x"], "e": "Fitxa: so africat, tx."},
      {"q": "Completa: despa__ (lloc on treballa el director)", "o": ["tx", "ix", "x"], "e": "Despatx: so africat, tx."},
      {"q": "Completa: pe__os (plural de peix)", "o": ["ix", "x", "tx"], "e": "Peixos: es manté ix."},
      {"q": "Escriu el plural de «platja».", "a": ["platges"], "e": "Platja → platges: davant de e, tj canvia a tg."},
      {"q": "Escriu el verb que correspon a «viatge».", "a": ["viatjar"], "e": "Viatge → viatjar: davant de a, tg canvia a tj."}
    ]
  },
  {
    "id": "77e69eed-4550-4420-a66e-1f226c99a989", "offset": 9,
    "exercises": [
      {"q": "Completa: __et (beguda blanca)", "o": ["ll", "l"], "e": "Llet: dígraf ll a principi de paraula."},
      {"q": "Completa: __imona (fruita groga i àcida)", "o": ["ll", "l"], "e": "Llimona: dígraf ll."},
      {"q": "Completa: __apis (per a escriure i dibuixar)", "o": ["ll", "l"], "e": "Llapis: dígraf ll."},
      {"q": "Completa: __ençol (roba del llit)", "o": ["ll", "l"], "e": "Llençol: dígraf ll."},
      {"q": "Completa: __adre (persona que roba)", "o": ["ll", "l"], "e": "Lladre: dígraf ll."},
      {"q": "Completa: __ínia (ratlla en un paper)", "o": ["l", "ll"], "e": "Línia: l simple."},
      {"q": "Completa: __ent (que va a poc a poc)", "o": ["l", "ll"], "e": "Lent: l simple."},
      {"q": "Completa: cava__ (animal que es pot muntar)", "o": ["ll", "l"], "e": "Cavall: ll a final de paraula."},
      {"q": "Completa: ga__ (canta de matí)", "o": ["ll", "l"], "e": "Gall: ll a final de paraula."},
      {"q": "Completa: cabe__ (el tenim al cap)", "o": ["ll", "l"], "e": "Cabell: ll a final de paraula."},
      {"q": "Completa: sa__ (condiment blanc)", "o": ["l", "ll"], "e": "Sal: l simple."},
      {"q": "Completa: ce__ (el veiem blau de dia)", "o": ["l", "ll"], "e": "Cel: l simple."},
      {"q": "Completa: me__ (la fan les abelles)", "o": ["l", "ll"], "e": "Mel: l simple."},
      {"q": "Completa: abe__a (insecte que fa mel)", "o": ["ll", "l"], "e": "Abella: ll entre vocals."},
      {"q": "Completa: fu__a (d'un arbre)", "o": ["ll", "l"], "e": "Fulla: ll entre vocals."},
      {"q": "Completa: ce__a (pèl damunt de l'ull)", "o": ["ll", "l"], "e": "Cella: ll entre vocals."},
      {"q": "Completa: ampo__a (d'aigua o de vi)", "o": ["ll", "l"], "e": "Ampolla: ll entre vocals."},
      {"q": "Completa: sa__a (habitació gran de la casa)", "o": ["l", "ll"], "e": "Sala: l simple entre vocals."},
      {"q": "Completa: vo__ar (fer com els ocells)", "o": ["l", "ll"], "e": "Volar: l simple."},
      {"q": "Completa: ca__ar (no parlar)", "o": ["ll", "l"], "e": "Callar: ll entre vocals."},
      {"q": "Completa: a__í (en aquell lloc)", "o": ["ll", "l"], "e": "Allí: ll entre vocals."},
      {"q": "Completa: mo__t (una gran quantitat)", "o": ["l", "ll"], "e": "Molt: l simple."},
      {"q": "Quina forma és correcta?", "o": ["lluny", "luny", "llunny"], "e": "Lluny: ll a principi i ny al final."},
      {"q": "Quina forma és correcta?", "o": ["llibreria", "libreria", "llibrería"], "e": "Llibreria, com llibre."},
      {"q": "Escriu el contrari de «curt».", "a": ["llarg"], "e": "Llarg, amb ll inicial."},
      {"q": "Escriu el contrari de «jove».", "a": ["vell"], "e": "Vell, amb ll final."}
    ]
  },
  {
    "id": "4a7ebcc7-0141-4e17-bae8-6386275e31dd", "offset": 8,
    "exercises": [
      {"q": "Completa: ca__o (vehicle tirat per un cavall)", "o": ["rr", "r"], "e": "Carro: r forta entre vocals → rr."},
      {"q": "Completa: gue__a (conflicte entre països)", "o": ["rr", "r"], "e": "Guerra: r forta entre vocals → rr."},
      {"q": "Completa: a__òs (el posem a la paella)", "o": ["rr", "r"], "e": "Arròs: r forta entre vocals → rr."},
      {"q": "Completa: guita__a (instrument de música)", "o": ["rr", "r"], "e": "Guitarra: r forta entre vocals → rr."},
      {"q": "Completa: ba__a (de pa)", "o": ["rr", "r"], "e": "Barra: r forta entre vocals → rr."},
      {"q": "Completa: có__er (anar molt de pressa a peu)", "o": ["rr", "r"], "e": "Córrer: r forta entre vocals → rr."},
      {"q": "Completa: fe__o (metall dur)", "o": ["rr", "r"], "e": "Ferro: r forta entre vocals → rr."},
      {"q": "Completa: e__or (equivocació)", "o": ["rr", "r"], "e": "Error: r forta entre vocals → rr."},
      {"q": "Completa: ba__et (el portem al cap)", "o": ["rr", "r"], "e": "Barret: r forta entre vocals → rr."},
      {"q": "Completa: pe__uquer (talla els cabells)", "o": ["rr", "r"], "e": "Perruquer: r forta entre vocals → rr."},
      {"q": "Completa: pe__a (fruita)", "o": ["r", "rr"], "e": "Pera: r suau entre vocals."},
      {"q": "Completa: ta__onja (fruita típica valenciana)", "o": ["r", "rr"], "e": "Taronja: r suau entre vocals."},
      {"q": "Completa: ma__e (la dona que t'ha tingut)", "o": ["r", "rr"], "e": "Mare: r suau entre vocals."},
      {"q": "Completa: pa__e (l'home que t'ha tingut)", "o": ["r", "rr"], "e": "Pare: r suau entre vocals."},
      {"q": "Completa: __iu (aigua que corre fins a la mar)", "o": ["r", "rr"], "e": "Riu: a principi de paraula, r forta però amb una sola r."},
      {"q": "Completa: __oda (d'un cotxe o d'una bici)", "o": ["r", "rr"], "e": "Roda: a principi de paraula, sempre una sola r."},
      {"q": "Completa: __ellotge (marca l'hora)", "o": ["r", "rr"], "e": "Rellotge: a principi de paraula, una sola r."},
      {"q": "Completa: En__ic (nom de persona)", "o": ["r", "rr"], "e": "Enric: darrere de n, la r sona forta però s'escriu amb una sola r."},
      {"q": "Completa: Is__ael (nom de persona)", "o": ["r", "rr"], "e": "Israel: darrere de s, la r sona forta però s'escriu amb una sola r."},
      {"q": "Completa: ve__d (el color de l'herba)", "o": ["r", "rr"], "e": "Verd: davant de consonant, sempre una sola r."},
      {"q": "Completa: po__ta (per a entrar a casa)", "o": ["r", "rr"], "e": "Porta: davant de consonant, sempre una sola r."},
      {"q": "Completa: ma__ó (color de la xocolata)", "o": ["rr", "r"], "e": "Marró: r forta entre vocals → rr."},
      {"q": "En quina d'estes paraules la r és suau?", "o": ["cara", "carro", "riu"], "e": "Cara: r suau entre vocals. En carro i riu és forta."},
      {"q": "En quina d'estes paraules sona la r forta?", "o": ["Enric", "Maria", "pera"], "e": "Darrere de n la r sona forta."},
      {"q": "Escriu en lletres el número 4.", "a": ["quatre"], "e": "Quatre: r suau darrere de t."},
      {"q": "Escriu en lletres el número 3.", "a": ["tres"], "e": "Tres, amb una sola r."},
      {"q": "Escriu el contrari de «dolç».", "a": ["amarg"], "e": "Amarg: r davant de consonant, una sola r."}
    ]
  },
  {
    "id": "c84eadef-dfd6-44d0-9864-61e37ef55e97", "offset": 9,
    "exercises": [
      {"q": "Quina forma és correcta?", "o": ["història", "istòria", "històrya"], "e": "Història porta h inicial."},
      {"q": "Quina forma és correcta?", "o": ["hotel", "otel", "hotél"], "e": "Hotel: h inicial muda."},
      {"q": "Quina forma és correcta?", "o": ["herba", "erba", "hèrba"], "e": "Herba: h inicial muda."},
      {"q": "Quina forma és correcta?", "o": ["hui", "ui", "húi"], "e": "Hui (el dia d'avui) porta h."},
      {"q": "Quina forma és correcta?", "o": ["hort", "ort", "hòrt"], "e": "Hort: h inicial muda."},
      {"q": "Quina forma és correcta?", "o": ["hortalissa", "ortalissa", "hortalisa"], "e": "Hortalissa: amb h, com hort, i amb ss."},
      {"q": "Quina forma és correcta?", "o": ["habitació", "abitació", "habitaciò"], "e": "Habitació: h inicial i accent tancat en la o."},
      {"q": "Quina forma és correcta?", "o": ["humit", "umit", "húmit"], "e": "Humit: h inicial."},
      {"q": "Quina forma és correcta?", "o": ["humor", "umor", "humòr"], "e": "Humor: h inicial."},
      {"q": "Quina forma és correcta?", "o": ["helicòpter", "elicòpter", "helicópter"], "e": "Helicòpter: h inicial i o oberta."},
      {"q": "Quina forma és correcta?", "o": ["prohibit", "proibit", "prohíbit"], "e": "Prohibit porta h entre vocals."},
      {"q": "Quina forma és correcta?", "o": ["vehicle", "veicle", "vehícle"], "e": "Vehicle porta h entre vocals."},
      {"q": "Quina forma és correcta? (el ponen les gallines)", "o": ["ou", "hou", "óu"], "e": "Ou s'escriu sense h (no com el castellà «huevo»)."},
      {"q": "Quina forma és correcta? (part del cos per a sentir)", "o": ["orella", "horella", "horeya"], "e": "Orella s'escriu sense h."},
      {"q": "Quina forma és correcta? (part dura de l'esquelet)", "o": ["os", "hos", "òs"], "e": "Os s'escriu sense h (plural: ossos)."},
      {"q": "Completa: Tu ___ vist la pel·lícula?", "o": ["has", "as", "hàs"], "e": "Has és el verb haver (has vist)."},
      {"q": "Completa: Ell ___ dinat a casa.", "o": ["ha", "a", "hà"], "e": "Ha és el verb haver (ha dinat)."},
      {"q": "Completa: Demà vaig ___ Castelló.", "o": ["a", "ha", "hà"], "e": "Ací és la preposició «a», sense h."},
      {"q": "Completa: Vosaltres ___ estudiat molt.", "o": ["heu", "eu", "héu"], "e": "Heu és el verb haver (heu estudiat)."},
      {"q": "Completa: A casa ___ tres habitacions.", "o": ["hi ha", "i ha", "hi a"], "e": "Hi ha: verb haver-hi."},
      {"q": "Completa: No ___ ha pa.", "o": ["hi", "i", "y"], "e": "No hi ha: el pronom hi porta h."},
      {"q": "Completa: Pere ___ Maria són germans.", "o": ["i", "hi", "y"], "e": "La conjunció i s'escriu sense h."},
      {"q": "Completa: ___ dic Joan.", "o": ["Em", "Hem", "Hen"], "e": "Em (pronom) va sense h. «Hem» és el verb haver."},
      {"q": "Completa: Nosaltres ___ arribat prompte.", "o": ["hem", "em", "hen"], "e": "Hem és el verb haver (hem arribat)."},
      {"q": "Escriu la paraula: el dia abans de hui.", "a": ["ahir"], "e": "Ahir porta h entre vocals."},
      {"q": "Escriu la paraula: l'estació de l'any més freda.", "a": ["hivern"], "e": "Hivern: amb h i amb v."}
    ]
  },
  {
    "id": "e5d6e371-5128-48a1-a4be-01a98a83bedb", "offset": 8,
    "exercises": [
      {"q": "Quina frase està ben escrita?", "o": ["Maria és de València.", "maria és de València.", "Maria és de valència."], "e": "Majúscula a l'inici de frase i en els noms de persona i de lloc."},
      {"q": "Quina frase està ben escrita?", "o": ["El meu gos es diu Tobi.", "El meu Gos es diu Tobi.", "el meu gos es diu tobi."], "e": "El nom de l'animal (Tobi) va en majúscula; «gos», en minúscula."},
      {"q": "Quina frase està ben escrita?", "o": ["Vaig a París a l'agost.", "Vaig a parís a l'Agost.", "Vaig a París a l'Agost."], "e": "Noms de ciutat en majúscula; mesos en minúscula."},
      {"q": "Quina frase està ben escrita?", "o": ["Tinc un amic francés.", "Tinc un amic Francés.", "tinc un amic francés."], "e": "Els gentilicis (francés, valencià...) van en minúscula."},
      {"q": "Quina frase està ben escrita?", "o": ["Per Nadal anem al poble.", "Per nadal anem al poble.", "per Nadal anem al Poble."], "e": "Les festes (Nadal, Pasqua) van en majúscula."},
      {"q": "Quina frase està ben escrita?", "o": ["Els valencians celebren les Falles al març.", "Els Valencians celebren les falles al Març.", "Els valencians celebren les falles al Març."], "e": "Falles (la festa) en majúscula; gentilicis i mesos en minúscula."},
      {"q": "Quina frase està ben escrita?", "o": ["El riu Túria passa per València.", "El Riu túria passa per València.", "El riu túria passa per València."], "e": "«Riu» en minúscula; el nom propi (Túria), en majúscula."},
      {"q": "Quina frase està ben escrita?", "o": ["Visc a l'avinguda del Port.", "Visc a l'Avinguda del port.", "Visc a l'avinguda del port."], "e": "«Avinguda» en minúscula; el nom propi (Port), en majúscula."},
      {"q": "Quina frase està ben escrita?", "o": ["El dilluns tinc classe d'anglés.", "El Dilluns tinc classe d'Anglés.", "El dilluns tinc classe d'Anglés."], "e": "Dies de la setmana i llengües en minúscula."},
      {"q": "Quina frase està ben escrita?", "o": ["M'agrada molt la primavera.", "M'agrada molt la Primavera.", "m'agrada molt la primavera."], "e": "Les estacions de l'any van en minúscula."},
      {"q": "Quina frase està ben escrita?", "o": ["Em dic Laura Martí Soler.", "Em dic laura martí soler.", "Em dic Laura martí soler."], "e": "El nom i els cognoms van en majúscula."},
      {"q": "Quina frase està ben escrita?", "o": ["El meu germà viu a Nova York.", "El meu germà viu a nova york.", "El meu Germà viu a Nova York."], "e": "Noms de ciutat en majúscula (totes les paraules); «germà», en minúscula."},
      {"q": "Quina frase està ben escrita?", "o": ["Ahir vaig anar al cine. Després vam sopar.", "Ahir vaig anar al cine. després vam sopar.", "ahir vaig anar al cine. Després vam sopar."], "e": "Després d'un punt es comença amb majúscula."},
      {"q": "Quina frase està completa i ben puntuada?", "o": ["Em dic Pau i visc a Elx.", "Em dic Pau i visc a Elx", "em dic Pau i visc a Elx."], "e": "Majúscula a l'inici i punt al final."},
      {"q": "Quina frase està ben escrita?", "o": ["Vols un café?", "¿Vols un café?", "Vols un café¿"], "e": "En valencià normalment només es posa l'interrogant final."},
      {"q": "Quina frase està ben escrita?", "o": ["Que bonic!", "¡Que bonic!", "Que bonic¡"], "e": "En valencià normalment només es posa el signe d'admiració final."},
      {"q": "Quin signe falta? «On vius__»", "o": ["?", "!", "."], "e": "És una pregunta: interrogant al final."},
      {"q": "Quin signe falta? «Quants anys tens__»", "o": ["?", "!", ":"], "e": "És una pregunta: interrogant al final."},
      {"q": "Quin signe falta? «Quina calor fa__»", "o": ["!", "?", ","], "e": "Expressa una emoció o sorpresa: admiració."},
      {"q": "Quin signe falta? «Hui és dimarts__»", "o": [".", "?", ":"], "e": "És una afirmació: punt final."},
      {"q": "Quin signe falta? «Compra pa, ous__ llet i sucre.»", "o": [",", ":", "?"], "e": "La coma separa els elements d'una enumeració."},
      {"q": "Quina frase té la coma ben posada?", "o": ["Joan, vine ací!", "Joan vine, ací!", "Joan vine ací,!"], "e": "El nom de la persona a qui parlem se separa amb una coma."},
      {"q": "Quina frase té la coma ben posada?", "o": ["Hola, Marta, com estàs?", "Hola Marta com, estàs?", "Hola, Marta com, estàs?"], "e": "El nom de la persona a qui parlem va entre comes."},
      {"q": "Quina frase té les comes ben posades?", "o": ["A casa tinc un gat, un gos i dos peixos.", "A casa tinc, un gat un gos i dos peixos.", "A casa tinc un gat un gos, i dos peixos."], "e": "Coma entre els elements de la llista; davant de la «i» final, no."},
      {"q": "Quina frase usa bé els dos punts?", "o": ["Tinc dues germanes: Laura i Carla.", "Tinc dues: germanes Laura i Carla.", "Tinc dues germanes Laura: i Carla."], "e": "Els dos punts introduïxen els elements que s'anuncien."},
      {"q": "Quin signe es posa al final d'una frase que afirma una cosa?", "o": ["El punt (.)", "L'interrogant (?)", "Els dos punts (:)"], "e": "Les frases afirmatives acaben en punt."},
      {"q": "Quin signe usem per a fer una pregunta?", "o": ["L'interrogant (?)", "La coma (,)", "L'admiració (!)"], "e": "L'interrogant marca les preguntes."}
    ]
  }
]$data$::jsonb) AS t(id uuid, "offset" smallint, exercises jsonb);

DELETE FROM public.practice_exercises e
USING practice_more m
WHERE e.resource_id = m.id AND e.level = 'A2' AND e.position > m."offset";

INSERT INTO public.practice_exercises (resource_id, level, position, kind, prompt, options, answers, explanation)
SELECT m.id, 'A2', m."offset" + x.ord,
       CASE WHEN x.e ? 'a' THEN 'fill' ELSE 'choice' END,
       x.e->>'q',
       CASE WHEN x.e ? 'o' THEN ARRAY(SELECT jsonb_array_elements_text(x.e->'o')) END,
       CASE WHEN x.e ? 'a' THEN ARRAY(SELECT jsonb_array_elements_text(x.e->'a')) ELSE ARRAY[x.e->'o'->>0] END,
       x.e->>'e'
FROM practice_more m
CROSS JOIN LATERAL jsonb_array_elements(m.exercises) WITH ORDINALITY AS x(e, ord);

DROP TABLE practice_more;

-- ============================================================
-- Origen: 20260930140000_practice_morfosintaxi_more.sql
-- ============================================================
-- Més exercicis A2 per als continguts de 4.2 Morfosintaxi (20260930110000 en
-- tenia 9-14 per contingut): s'afigen darrere dels que ja hi ha, a partir de la
-- posició `offset`, fins a 35 per contingut. Tornar a aplicar el fitxer no els
-- duplica: primer s'esborren les posicions > offset.

CREATE TEMP TABLE practice_more AS
SELECT * FROM jsonb_to_recordset($data$[
  {
    "id": "8e2976bb-d06b-4230-8887-fcf23f45bbdd", "offset": 10,
    "exercises": [
      {"q": "Quin és el femení de «professor»?", "o": ["professora", "professoressa", "professor"], "e": "Professor → professora: s'afig -a."},
      {"q": "Quin és el femení de «actor»?", "o": ["actriu", "actora", "actoressa"], "e": "Actor → actriu: és un femení irregular."},
      {"q": "Quin és el femení de «rei»?", "o": ["reina", "reia", "reïna"], "e": "Rei → reina."},
      {"q": "Quin és el femení de «nebot»?", "o": ["neboda", "nebota", "nebotessa"], "e": "Nebot → neboda: la -t final canvia a -d-."},
      {"q": "Quin és el femení de «amic»?", "o": ["amiga", "amica", "amiqua"], "e": "Amic → amiga: la -c final canvia a -g-."},
      {"q": "Quin és el femení de «llop»?", "o": ["lloba", "llopa", "llopessa"], "e": "Llop → lloba: la -p final canvia a -b-."},
      {"q": "Quin és el femení de l'adjectiu «nou»?", "o": ["nova", "noua", "nouva"], "e": "Nou → nova: la -u final canvia a -v-."},
      {"q": "Quin és el femení de «blanc»?", "o": ["blanca", "blanqua", "blanc"], "e": "Blanc → blanca."},
      {"q": "Quin és el femení de «home»?", "o": ["dona", "homa", "homessa"], "e": "Home i dona són paraules diferents per a cada sexe."},
      {"q": "Quin és el femení de «jove»?", "o": ["jove", "jova", "jovena"], "e": "Jove és invariable: un xic jove, una xica jove."},
      {"q": "Quin és el femení de «feliç»?", "o": ["feliç", "feliça", "felissa"], "e": "Feliç és invariable: un home feliç, una dona feliç."},
      {"q": "Quin és el plural de «casa»?", "o": ["cases", "casas", "casos"], "e": "Les paraules acabades en -a fan el plural en -es: cases."},
      {"q": "Quin és el plural de «platja»?", "o": ["platges", "platjes", "platjas"], "e": "Platja → platges: davant de e, tj canvia a tg."},
      {"q": "Quin és el plural de «amiga»?", "o": ["amigues", "amigas", "amiges"], "e": "Amiga → amigues: davant de e, g canvia a gu."},
      {"q": "Quin és el plural de «peix»?", "o": ["peixos", "peixs", "peixes"], "e": "Les paraules acabades en -x fan el plural en -os: peixos."},
      {"q": "Quin és el plural de «gos»?", "o": ["gossos", "gosos", "goss"], "e": "Gos → gossos: afig -os i la s passa a ss."},
      {"q": "Quin és el plural de «mà»?", "o": ["mans", "màs", "manes"], "e": "Mà → mans: recupera la n."},
      {"q": "Quin és el plural de «llapis»?", "o": ["llapis", "llapissos", "llapisos"], "e": "Llapis és invariable: un llapis, dos llapis."},
      {"q": "Quin és el plural de «francés»?", "o": ["francesos", "francéss", "franceses"], "e": "Francés → francesos (masculí plural)."},
      {"q": "Completa: Les meues germanes són molt ___.", "o": ["altes", "alts", "alta"], "e": "L'adjectiu concorda amb el nom: femení plural."},
      {"q": "Completa: M'he comprat uns pantalons ___.", "o": ["nous", "noves", "nou"], "e": "Pantalons és masculí plural: nous."},
      {"q": "Completa: La paella està molt ___.", "o": ["bona", "bo", "bones"], "e": "Paella és femení singular: bona."},
      {"q": "Escriu el plural de «taronja».", "a": ["taronges"], "e": "Taronja → taronges: davant de e, j canvia a g."},
      {"q": "Escriu el femení de «valencià».", "a": ["valenciana"], "e": "Valencià → valenciana: recupera la n i perd l'accent."},
      {"q": "Escriu el plural de «cançó».", "a": ["cançons"], "e": "Cançó → cançons: recupera la n i perd l'accent."}
    ]
  },
  {
    "id": "79dd1db4-40ff-4860-8f49-279ee059ab46", "offset": 9,
    "exercises": [
      {"q": "Completa: M'agraden molt ___ pomes.", "o": ["les", "els", "la"], "e": "Pomes és femení plural: les."},
      {"q": "Completa: ___ dimarts tinc classe d'anglés.", "o": ["El", "La", "Lo"], "e": "Els dies de la setmana són masculins: el dimarts."},
      {"q": "Completa: Tinc ___ amic a Londres.", "o": ["un", "una", "uns"], "e": "Amic és masculí singular: un."},
      {"q": "Completa: Hi ha ___ taronges a la taula.", "o": ["unes", "uns", "una"], "e": "Taronges és femení plural: unes."},
      {"q": "Completa (la jaqueta la portes tu posada i parles d'ella): ___ jaqueta és meua.", "o": ["Esta", "Eixa", "Aquella"], "e": "Prop de qui parla: esta."},
      {"q": "Completa (la cadira és al costat de qui t'escolta): Seu en ___ cadira.", "o": ["eixa", "esta", "aquella"], "e": "Prop de qui escolta: eixa."},
      {"q": "Completa (els núvols són molt lluny): Mira ___ núvols!", "o": ["aquells", "estos", "eixos"], "e": "Lluny de tots dos: aquells."},
      {"q": "Completa (les claus les té qui t'escolta): Dona'm ___ claus.", "o": ["eixes", "estes", "aquelles"], "e": "Prop de qui escolta: eixes."},
      {"q": "Completa: ___ any (l'any en què estem) vaig a Itàlia.", "o": ["Este", "Eixe", "Aquell"], "e": "El temps present s'expressa amb el demostratiu de proximitat: este any."},
      {"q": "Completa: Recordes ___ estiu de 2010? Va ser genial.", "o": ["aquell", "este", "eixe"], "e": "Un temps llunyà en el passat: aquell."},
      {"q": "Quina forma és correcta?", "o": ["estos xiquets", "estes xiquets", "este xiquets"], "e": "Masculí plural: estos."},
      {"q": "Quina forma és correcta?", "o": ["eixes cases", "eixos cases", "eixa cases"], "e": "Femení plural: eixes."},
      {"q": "Completa: Este és ___ cotxe.", "o": ["el meu", "la meua", "els meus"], "e": "Cotxe és masculí singular: el meu."},
      {"q": "Completa: ___ amigues són molt simpàtiques.", "o": ["Les teues", "Els teus", "La teua"], "e": "Amigues és femení plural: les teues."},
      {"q": "Completa: La Maria ve amb ___ germà.", "o": ["el seu", "la seua", "els seus"], "e": "El possessiu concorda amb la cosa posseïda (germà), no amb qui la posseïx: el seu."},
      {"q": "Completa: Nosaltres vivim amb ___ àvia.", "o": ["la nostra", "el nostre", "les nostres"], "e": "Àvia és femení singular: la nostra."},
      {"q": "Completa: On teniu ___ maletes?", "o": ["les vostres", "els vostres", "la vostra"], "e": "Maletes és femení plural: les vostres."},
      {"q": "Completa: Estos llibres són ___.", "o": ["meus", "meues", "meu"], "e": "Llibres és masculí plural: meus."},
      {"q": "Completa (la casa és de Joan): Aquella casa és ___.", "o": ["seua", "seu", "seues"], "e": "Casa és femení singular: seua."},
      {"q": "Completa amb la forma curta (la mare de qui parla): Visc amb ___ mare.", "o": ["ma", "mon", "mos"], "e": "Amb alguns noms de parentiu es pot usar la forma curta: ma mare (= la meua mare)."},
      {"q": "Completa amb la forma curta (el pare de qui parla): ___ pare és metge.", "o": ["Mon", "Ma", "Mos"], "e": "Mon pare (= el meu pare)."},
      {"q": "Quina frase és correcta?", "o": ["Els meus cosins viuen a Gandia.", "Els meues cosins viuen a Gandia.", "Les meus cosins viuen a Gandia."], "e": "Cosins és masculí plural: els meus."},
      {"q": "Escriu el possessiu (de mi, femení singular): Esta és la ___ bicicleta.", "a": ["meua", "meva"], "e": "La meua (o la meva) bicicleta."},
      {"q": "Escriu el demostratiu (lluny, femení singular): ___ casa del fons és molt gran.", "a": ["aquella"], "e": "Lluny de qui parla i de qui escolta: aquella."},
      {"q": "Escriu el demostratiu (prop de qui escolta, femení plural): ___ sabates que portes són molt boniques.", "a": ["eixes"], "e": "Prop de qui escolta: eixes."},
      {"q": "Escriu l'article: ___ xiquets juguen al parc.", "a": ["els"], "e": "Xiquets és masculí plural: els."}
    ]
  },
  {
    "id": "725395e1-be2e-47a3-89bb-432fc4f4a152", "offset": 11,
    "exercises": [
      {"q": "Completa: ___ som de València.", "o": ["Nosaltres", "Vosaltres", "Ells"], "e": "Som és la primera persona del plural: nosaltres."},
      {"q": "Completa: I ___, d'on sou?", "o": ["vosaltres", "nosaltres", "elles"], "e": "Sou és la segona persona del plural: vosaltres."},
      {"q": "Completa: Este regal és per a ___ (la persona que parla).", "o": ["mi", "jo", "me"], "e": "Darrere de preposició s'usa «mi»: per a mi."},
      {"q": "Completa: Com ___ dieu?", "o": ["vos", "nos", "es"], "e": "Segona persona del plural: vos dieu."},
      {"q": "Completa: Ells ___ diuen Pere i Joan.", "o": ["es", "els", "li"], "e": "Tercera persona del verb dir-se: es diuen."},
      {"q": "Completa: Nosaltres ___ alcem prompte.", "o": ["ens", "vos", "es"], "e": "Primera persona del plural: ens alcem."},
      {"q": "Completa: ___ agrada molt la música (a mi).", "o": ["M'", "Em", "Me"], "e": "Davant de vocal, em s'apostrofa: m'agrada."},
      {"q": "Completa: ___ agrada el futbol? (a tu)", "o": ["T'", "Et", "Te"], "e": "Davant de vocal, et s'apostrofa: t'agrada."},
      {"q": "Completa: A Joan ___ agrada el cine.", "o": ["li", "el", "la"], "e": "Complement indirecte de tercera persona singular: li."},
      {"q": "Completa: Als meus pares ___ agrada viatjar.", "o": ["els", "li", "los"], "e": "Complement indirecte de tercera persona plural davant del verb: els."},
      {"q": "Substituïx el complement directe: «Mire la tele.»", "o": ["La mire.", "El mire.", "Li mire."], "e": "La tele és femení singular: la."},
      {"q": "Substituïx el complement directe: «Compre els llibres.»", "o": ["Els compre.", "Les compre.", "Li compre."], "e": "Els llibres és masculí plural: els."},
      {"q": "Substituïx el complement directe: «Vull comprar el pa.»", "o": ["Vull comprar-lo.", "Vull comprar-el.", "Vull comprar-li."], "e": "Darrere de l'infinitiu, el pronom va amb guionet: comprar-lo."},
      {"q": "Substituïx el complement directe: «Obri la porta!»", "o": ["Obri-la!", "La obri!", "Obri-li!"], "e": "Darrere de l'imperatiu, el pronom va amb guionet: obri-la."},
      {"q": "Substituïx el complement indirecte: «Escric un missatge a la meua amiga.»", "o": ["Li escric un missatge.", "La escric un missatge.", "Els escric un missatge."], "e": "Complement indirecte singular (masculí o femení): li."},
      {"q": "Substituïx el complement indirecte: «Done caramels als xiquets.»", "o": ["Els done caramels.", "Li done caramels.", "Los done caramels."], "e": "Complement indirecte plural davant del verb: els."},
      {"q": "Completa: ___ et dius? — Anna.", "o": ["Com", "Què", "Qui"], "e": "Per a preguntar el nom: com."},
      {"q": "Completa: ___ vius? — A Alzira.", "o": ["On", "Quan", "Com"], "e": "Per a preguntar pel lloc: on (o a on)."},
      {"q": "Completa: ___ és eixe home? — És el meu tio.", "o": ["Qui", "Què", "Quin"], "e": "Per a preguntar per una persona: qui."},
      {"q": "Completa: ___ vols per a sopar? — Una truita.", "o": ["Què", "Qui", "On"], "e": "Per a preguntar per una cosa: què."},
      {"q": "Completa: ___ anys tens?", "o": ["Quants", "Quantes", "Quant"], "e": "Anys és masculí plural: quants."},
      {"q": "Completa: ___ germanes tens?", "o": ["Quantes", "Quants", "Quanta"], "e": "Germanes és femení plural: quantes."},
      {"q": "Completa: La xica ___ parla amb Pere és ma germana.", "o": ["que", "qui", "què"], "e": "El relatiu que unix les dues frases: la xica que parla."},
      {"q": "Substituïx «la carta» pel pronom: «Llig la carta.» → ___ llig.", "a": ["la"], "e": "La carta és femení singular: la llig."}
    ]
  },
  {
    "id": "9d900655-f7cc-4ca6-9611-6fc2f32bbc2b", "offset": 11,
    "exercises": [
      {"q": "Com s'escriu el número 12?", "o": ["dotze", "doce", "dotse"], "e": "Dotze, amb tz."},
      {"q": "Com s'escriu el número 17?", "o": ["dèsset", "desisset", "dietset"], "e": "Dèsset (també disset o desset)."},
      {"q": "Com s'escriu el número 19?", "o": ["dènou", "dieunou", "deunou"], "e": "Dènou (també dinou o denou)."},
      {"q": "Com s'escriu el número 30?", "o": ["trenta", "treinta", "tretanta"], "e": "Trenta."},
      {"q": "Com s'escriu el número 40?", "o": ["quaranta", "cuaranta", "quatranta"], "e": "Quaranta."},
      {"q": "Com s'escriu el número 100?", "o": ["cent", "cen", "cente"], "e": "Cent."},
      {"q": "Com s'escriu el número 200?", "o": ["dos-cents", "docents", "dos cent"], "e": "Dos-cents: les centenes s'escriuen amb guionet."},
      {"q": "Quin número és «vint-i-dos»?", "o": ["22", "12", "20"], "e": "Vint-i-dos = 22."},
      {"q": "Completa (si comencem per dilluns): Diumenge és el ___ dia de la setmana.", "o": ["seté", "sisé", "huité"], "e": "Diumenge és el seté dia (7é)."},
      {"q": "Completa: Visc al ___ pis (4t).", "o": ["quart", "quatré", "quarté"], "e": "L'ordinal de quatre és quart."},
      {"q": "Completa: És la ___ vegada que vinc a València (1a).", "o": ["primera", "primer", "una"], "e": "Vegada és femení: primera."},
      {"q": "Completa: No hi ha ___ al parc: està buit.", "o": ["ningú", "algú", "res"], "e": "Ningú: cap persona."},
      {"q": "Completa: He vist ___ amics teus al cine.", "o": ["alguns", "cap", "ningú"], "e": "Alguns: una quantitat indeterminada de persones."},
      {"q": "Completa: No m'ha telefonat ___ en tot el dia.", "o": ["ningú", "res", "cap"], "e": "Ningú es referix a persones."},
      {"q": "Completa: Has menjat ___? — No, encara no.", "o": ["res", "ningú", "cap"], "e": "Res es referix a coses (= alguna cosa, en preguntes)."},
      {"q": "Completa: Parles ___ bé el valencià!", "o": ["molt", "molta", "molts"], "e": "Davant d'un adverbi (bé), molt és invariable."},
      {"q": "Completa: Hui fa ___ calor: quaranta graus!", "o": ["molta", "molt", "pocs"], "e": "La calor és femení: molta calor."},
      {"q": "Completa: Tinc ___ temps: només cinc minuts.", "o": ["poc", "molt", "massa"], "e": "Poc: una quantitat xicoteta."},
      {"q": "Completa: No puc dormir: hi ha ___ soroll.", "o": ["massa", "prou", "gens"], "e": "Massa: més del que convé."},
      {"q": "Completa: Tenim cadires per a tots? — Sí, n'hi ha ___.", "o": ["prou", "massa", "gens"], "e": "Prou: la quantitat necessària."},
      {"q": "Completa: ___ les xiques han vingut a la festa.", "o": ["Totes", "Tots", "Tot"], "e": "Xiques és femení plural: totes."},
      {"q": "Completa: Hi ha ___ gent al concert: està ple.", "o": ["molta", "molts", "poca"], "e": "Gent és femení singular: molta gent."},
      {"q": "Escriu en lletres el número 50.", "a": ["cinquanta"], "e": "Cinquanta."},
      {"q": "Escriu en lletres el número 35.", "a": ["trenta-cinc"], "e": "Trenta-cinc: desenes i unitats s'unixen amb guionet."}
    ]
  },
  {
    "id": "a8c6af22-1a37-49d0-a8b9-35c91f26bff9", "offset": 9,
    "exercises": [
      {"q": "Completa: Esta vesprada anem ___ la platja.", "o": ["a", "en", "de"], "e": "Destinació: a."},
      {"q": "Completa: Visc ___ Gandia.", "o": ["a", "en", "de"], "e": "Davant de noms de lloc s'usa a: visc a Gandia."},
      {"q": "Completa: Hui em quede ___ casa.", "o": ["a", "de", "per"], "e": "Situació: a casa."},
      {"q": "Completa: Vinc a l'escola ___ peu.", "o": ["a", "en", "de"], "e": "Es diu «a peu»."},
      {"q": "Completa: El llibre és ___ Maria.", "o": ["de", "a", "per"], "e": "Possessió: de."},
      {"q": "Completa: Vull una tassa ___ café.", "o": ["de", "a", "per"], "e": "Contingut: una tassa de café."},
      {"q": "Completa: He comprat pa ___ sopar.", "o": ["per a", "per", "de"], "e": "Finalitat davant d'infinitiu: per a."},
      {"q": "Completa: L'avió ix ___ les deu.", "o": ["a", "en", "per"], "e": "Hora: a les deu."},
      {"q": "Completa: Estudie valencià ___ fa dos anys.", "o": ["des de", "de", "per"], "e": "Punt d'inici en el temps: des de."},
      {"q": "Completa: Treballe ___ les nou ___ les tres.", "o": ["de / a", "a / de", "en / per"], "e": "Interval de temps: de... a..."},
      {"q": "Completa: Passem ___ el parc per a anar a l'escola.", "o": ["per", "per a", "a"], "e": "Lloc per on es passa: per."},
      {"q": "Completa: El gat està ___ la taula (a dalt).", "o": ["damunt de", "davall de", "dins de"], "e": "A dalt: damunt de."},
      {"q": "Completa: Les claus estan ___ la bossa.", "o": ["dins de", "fora de", "entre"], "e": "A l'interior: dins de."},
      {"q": "Completa: El banc està ___ la farmàcia (tocant-la).", "o": ["al costat de", "dins de", "entre"], "e": "Tocant: al costat de."},
      {"q": "Completa: La parada està ___ l'escola (en la part de davant).", "o": ["davant de", "darrere de", "dins de"], "e": "En la part de davant: davant de."},
      {"q": "Completa: El jardí està ___ la casa (en la part de darrere).", "o": ["darrere de", "davant de", "damunt de"], "e": "En la part de darrere: darrere de."},
      {"q": "Completa: Isc ___ treballar a les tres.", "o": ["de", "a", "per"], "e": "Eixir de: isc de treballar."},
      {"q": "Completa: Sempre pense ___ tu.", "o": ["en", "a", "de"], "e": "Pensar en algú."},
      {"q": "Completa: Parlem ___ viatge de l'estiu.", "o": ["del", "de el", "en el"], "e": "Parlar de + el → del."},
      {"q": "Completa: Estic ___ acord amb tu.", "o": ["d'", "en", "a"], "e": "Es diu «d'acord»."},
      {"q": "Completa: ___ on eres?", "o": ["D'", "A", "Per"], "e": "Origen: d'on (de + on)."},
      {"q": "Completa: ___ què servix açò?", "o": ["Per a", "De", "En"], "e": "Finalitat: per a què."},
      {"q": "Completa: ___ qui és este paraigua?", "o": ["De", "A", "Amb"], "e": "Possessió: de qui."},
      {"q": "Completa: ___ quina hora comença la classe?", "o": ["A", "En", "De"], "e": "Hora: a quina hora."},
      {"q": "Escriu la preposició: Demà vaig ___ Alacant.", "a": ["a"], "e": "Destinació: a Alacant."},
      {"q": "Escriu la preposició: Isc al cine ___ la meua germana.", "a": ["amb"], "e": "Companyia: amb."}
    ]
  },
  {
    "id": "03d45225-e0a6-4178-8574-ba4960ef05c1", "offset": 10,
    "exercises": [
      {"q": "Completa: Hui és dilluns; ___ serà dimarts.", "o": ["demà", "ahir", "abans"], "e": "El dia següent: demà."},
      {"q": "Completa: ___ va ser diumenge.", "o": ["Ahir", "Demà", "Després"], "e": "El dia anterior: ahir."},
      {"q": "Completa: Ara no puc, t'ho explique ___.", "o": ["més tard", "ahir", "abans"], "e": "En un moment posterior: més tard."},
      {"q": "Completa: — Ha arribat Pere? — Sí, ___ ha arribat.", "o": ["ja", "encara", "mai"], "e": "Ja: la cosa ha passat."},
      {"q": "Completa: Són les deu i el meu germà ___ dorm.", "o": ["encara", "ja", "mai"], "e": "Encara: l'acció continua."},
      {"q": "Completa: ___ esmorze a les set: tots els dies.", "o": ["Sempre", "Mai", "De tant en tant"], "e": "Tots els dies: sempre."},
      {"q": "Completa: Vaig al teatre ___: no gaire sovint.", "o": ["de tant en tant", "sempre", "cada dia"], "e": "Algunes vegades: de tant en tant."},
      {"q": "Completa: El meu amic viu ___, a l'altra punta del món.", "o": ["lluny", "prop", "ací"], "e": "A molta distància: lluny."},
      {"q": "Completa: La farmàcia està molt ___: a dos minuts.", "o": ["prop", "lluny", "fora"], "e": "A poca distància: prop."},
      {"q": "Completa: Entra ___, que plou.", "o": ["dins", "fora", "lluny"], "e": "A l'interior: dins."},
      {"q": "Completa: Aquell llibre està ___, lluny de nosaltres.", "o": ["allí", "ací", "ahí"], "e": "Lluny de qui parla i de qui escolta: allí."},
      {"q": "Completa: Deixa-ho ___, al teu costat.", "o": ["ahí", "ací", "allí"], "e": "Prop de qui escolta: ahí."},
      {"q": "Completa: L'ascensor puja ___.", "o": ["amunt", "avall", "dins"], "e": "Cap a dalt: amunt."},
      {"q": "Completa: La pilota ha rodolat carrer ___.", "o": ["avall", "amunt", "dins"], "e": "Cap a baix: avall."},
      {"q": "Completa: Estic ___ cansat: he corregut deu quilòmetres.", "o": ["molt", "poc", "gens"], "e": "En gran quantitat: molt."},
      {"q": "Completa: Menja ___, que estàs molt prim.", "o": ["més", "menys", "gens"], "e": "Una quantitat major: més."},
      {"q": "Completa: La pel·lícula no m'ha agradat ___.", "o": ["gens", "sempre", "ja"], "e": "En frases negatives, gens = en cap grau."},
      {"q": "Completa: Canta molt ___: té una veu preciosa.", "o": ["bé", "mal", "poc"], "e": "De manera bona: bé."},
      {"q": "Completa: Hui estic ___: tinc febre.", "o": ["malament", "bé", "prou"], "e": "De manera dolenta: malament."},
      {"q": "Completa: Parla ___, que el xiquet dorm.", "o": ["baix", "alt", "fort"], "e": "Amb poca veu: baix."},
      {"q": "Completa: — Vens al cine? — ___, i tant!", "o": ["Sí", "No", "Tampoc"], "e": "Afirmació: sí."},
      {"q": "Completa: — A mi m'agrada el te. — A mi ___.", "o": ["també", "tampoc", "ni"], "e": "Coincidència en una frase afirmativa: també."},
      {"q": "Completa: ___ llig la pregunta i després respon.", "o": ["Primer", "Després", "Finalment"], "e": "La primera acció: primer."},
      {"q": "Escriu el contrari de «lluny».", "a": ["prop"], "e": "Lluny ↔ prop."},
      {"q": "Escriu el contrari de «amunt».", "a": ["avall"], "e": "Amunt ↔ avall."}
    ]
  },
  {
    "id": "e7ee9121-8467-4534-9ec5-1f8b491794f2", "offset": 11,
    "exercises": [
      {"q": "Completa: Tinc un germà ___ una germana.", "o": ["i", "o", "ni"], "e": "Per a sumar elements: i."},
      {"q": "Completa: Vols anar al cine ___ al teatre?", "o": ["o", "i", "ni"], "e": "Per a triar entre dues coses: o."},
      {"q": "Completa: No tinc gana ___ set.", "o": ["ni", "o", "però"], "e": "Per a sumar elements negatius: ni."},
      {"q": "Completa: Ni jo ___ tu tenim cotxe.", "o": ["ni", "o", "i"], "e": "Ni... ni...: cap dels dos."},
      {"q": "Completa: O vens ara ___ me'n vaig sense tu.", "o": ["o", "i", "ni"], "e": "O... o...: una de les dues opcions."},
      {"q": "Completa: És car, ___ és molt bo.", "o": ["però", "sinó", "perquè"], "e": "Per a oposar una idea: però."},
      {"q": "Completa: No vull aigua, ___ suc de taronja.", "o": ["sinó", "però", "o"], "e": "Després d'una negació, per a corregir: sinó."},
      {"q": "Completa: No he anat a classe ___ estava malalt.", "o": ["perquè", "però", "si"], "e": "Per a expressar la causa: perquè."},
      {"q": "Completa: ___ estava cansada, se'n va anar a dormir.", "o": ["Com que", "Però", "Sinó"], "e": "Causa a l'inici de la frase: com que."},
      {"q": "Completa: — Per què estudies valencià? — ___ vull treballar a València.", "o": ["Perquè", "Però", "Com"], "e": "Resposta a «per què?»: perquè."},
      {"q": "Completa: Fa sol; ___, anirem a la platja.", "o": ["per tant", "però", "sinó"], "e": "Per a expressar una conseqüència: per tant."},
      {"q": "Completa: ___ vols, et puc ajudar.", "o": ["Si", "Sinó", "Quan"], "e": "Per a expressar una condició: si."},
      {"q": "Completa: ___ era xicotet, vivia a Morella.", "o": ["Quan", "Si", "Perquè"], "e": "Per a expressar el temps: quan."},
      {"q": "Completa: Vine ___ pugues.", "o": ["quan", "perquè", "però"], "e": "Temps: quan."},
      {"q": "Completa: Marta diu ___ vindrà demà.", "o": ["que", "què", "qui"], "e": "La conjunció que introduïx el que es diu."},
      {"q": "Completa: No sé ___ vindrà o no.", "o": ["si", "que", "quan"], "e": "Pregunta indirecta de sí o no: si."},
      {"q": "Completa: He vingut ___ parlar amb tu.", "o": ["per a", "per", "perquè"], "e": "Finalitat davant d'infinitiu: per a."},
      {"q": "Completa: M'agrada ___ el futbol ___ el bàsquet.", "o": ["tant / com", "tan / com", "molt / que"], "e": "Comparació d'igualtat amb noms: tant... com..."},
      {"q": "Completa: M'agrada llegir ___ escoltar música.", "o": ["i", "ni", "sinó"], "e": "Per a sumar accions: i."},
      {"q": "Quina frase és correcta?", "o": ["No menge ni carn ni peix.", "No menge o carn o peix.", "No menge i carn i peix."], "e": "Per a negar dos elements: ni... ni..."},
      {"q": "Quina d'estes conjuncions expressa causa?", "o": ["perquè", "però", "o"], "e": "Perquè introduïx la causa."},
      {"q": "Quina d'estes conjuncions expressa una alternativa?", "o": ["o", "i", "perquè"], "e": "O presenta opcions."},
      {"q": "Escriu la conjunció: Tinc un gos ___ un gat.", "a": ["i"], "e": "Per a sumar: i."},
      {"q": "Escriu la conjunció: M'agrada, ___ és massa car.", "a": ["però"], "e": "Per a oposar: però."}
    ]
  },
  {
    "id": "e971fb5a-f24b-4b65-bdf4-6f85d3b084c7", "offset": 14,
    "exercises": [
      {"q": "Present: Nosaltres ___ (viure) a Sagunt.", "o": ["vivim", "vivem", "viuem"], "e": "Viure: visc, vius, viu, vivim, viviu, viuen."},
      {"q": "Present: Ells ___ (llegir) el periòdic cada matí.", "o": ["lligen", "leigen", "llegen"], "e": "Llegir: llig, lliges, llig, llegim, llegiu, lligen."},
      {"q": "Present: Jo ___ (preferir) el te.", "o": ["preferisc", "prefiro", "preferixc"], "e": "Preferir és incoatiu: jo preferisc."},
      {"q": "Present: Vosaltres ___ (anar) a classe cada dia.", "o": ["aneu", "van", "anem"], "e": "Anar: vaig, vas, va, anem, aneu, van."},
      {"q": "Present del verb anar: Jo ___ a la feina amb bici.", "o": ["vaig", "vac", "anc"], "e": "Anar és irregular: jo vaig."},
      {"q": "Present del verb poder: Jo no ___ vindre demà.", "o": ["puc", "podo", "pot"], "e": "Poder: puc, pots, pot, podem, podeu, poden."},
      {"q": "Present del verb voler: Jo ___ un café, per favor.", "o": ["vull", "vol", "volc"], "e": "Voler: vull, vols, vol, volem, voleu, volen."},
      {"q": "Present del verb saber: Jo no ___ nadar.", "o": ["sé", "sap", "sabo"], "e": "Saber: sé, saps, sap, sabem, sabeu, saben."},
      {"q": "Present del verb estar: Jo ___ cansada.", "o": ["estic", "esto", "està"], "e": "Estar: estic, estàs, està, estem, esteu, estan."},
      {"q": "Passat perifràstic: Dissabte passat ___ (sopar, nosaltres) fora.", "o": ["vam sopar", "sopem", "sopàvem"], "e": "Passat perifràstic: anar (present) + infinitiu: vam sopar."},
      {"q": "Passat perifràstic: L'any passat ___ (viatjar, ells) a Itàlia.", "o": ["van viatjar", "viatgen", "viatjaran"], "e": "Van viatjar: acció acabada en el passat."},
      {"q": "Imperfet: Quan era xicotet, ___ (jugar, jo) al carrer.", "o": ["jugava", "jugue", "jugaré"], "e": "L'imperfet expressa costums del passat: jugava."},
      {"q": "Passat perfet: Encara no ___ (acabar, jo) els deures.", "o": ["he acabat", "vaig acabar", "acabaré"], "e": "Amb «encara no» s'usa el perfet: he acabat."},
      {"q": "Futur: L'any que ve ___ (estudiar, jo) anglés.", "o": ["estudiaré", "estudie", "estudiava"], "e": "Futur: infinitiu + -é: estudiaré."},
      {"q": "Futur: Demà ___ (ploure).", "o": ["plourà", "plou", "ha plogut"], "e": "Futur de ploure: plourà."},
      {"q": "Imperatiu: ___ (tancar, tu) la porta, per favor!", "o": ["Tanca", "Tanques", "Tancar"], "e": "Imperatiu de tu: tanca."},
      {"q": "Imperatiu: ___ (vindre, tu) ací!", "o": ["Vine", "Vens", "Vinc"], "e": "Imperatiu irregular de vindre: vine."},
      {"q": "Completa amb haver-hi: Ahir ___ molta gent a la festa.", "o": ["hi havia", "hi ha", "hi haurà"], "e": "En passat: hi havia."},
      {"q": "Quina forma és correcta per a expressar obligació?", "o": ["He d'estudiar més.", "Tinc que estudiar més.", "Hi ha que estudiar més."], "e": "L'obligació s'expressa amb haver de + infinitiu. «Tindre que» és un castellanisme."},
      {"q": "Escriu el present del verb tindre: Nosaltres ___ un gos.", "a": ["tenim"], "e": "Tindre: tinc, tens, té, tenim, teniu, tenen."},
      {"q": "Escriu el present del verb anar: Ells ___ al cine.", "a": ["van"], "e": "Anar: vaig, vas, va, anem, aneu, van."}
    ]
  }
]$data$::jsonb) AS t(id uuid, "offset" smallint, exercises jsonb);

DELETE FROM public.practice_exercises e
USING practice_more m
WHERE e.resource_id = m.id AND e.level = 'A2' AND e.position > m."offset";

INSERT INTO public.practice_exercises (resource_id, level, position, kind, prompt, options, answers, explanation)
SELECT m.id, 'A2', m."offset" + x.ord,
       CASE WHEN x.e ? 'a' THEN 'fill' ELSE 'choice' END,
       x.e->>'q',
       CASE WHEN x.e ? 'o' THEN ARRAY(SELECT jsonb_array_elements_text(x.e->'o')) END,
       CASE WHEN x.e ? 'a' THEN ARRAY(SELECT jsonb_array_elements_text(x.e->'a')) ELSE ARRAY[x.e->'o'->>0] END,
       x.e->>'e'
FROM practice_more m
CROSS JOIN LATERAL jsonb_array_elements(m.exercises) WITH ORDINALITY AS x(e, ord);

DROP TABLE practice_more;

-- ============================================================
-- Origen: 20260930150000_practice_vocabulari.sql
-- ============================================================
-- Vocabulari bàsic de l'A2 (Quadern A2 de la JQCV, 4.3 Lèxic i semàntica).
-- El contingut «Vocabulari» de 20260930110000 tenia 10 preguntes de tots els
-- àmbits; es dividix en un contingut per àmbit del temari, perquè la pantalla
-- mostra tots els exercicis d'un contingut alhora. El primer àmbit conserva
-- l'id del recurs original i les seues preguntes es reparteixen entre els àmbits.
-- Formació de paraules i Sinònims passen darrere (sort_order 9 i 10).
-- Tornar a aplicar el fitxer no duplica res: es reescriuen els exercicis A2.

CREATE TEMP TABLE practice_catalog AS
SELECT * FROM jsonb_to_recordset($data$[
  {
    "id": "be7ce637-a745-4ec9-8d00-502b96b164a1", "type": "vocabulari", "sort_order": 1,
    "title": "Família, escola i vivenda", "name": "Família, noms, estudis, professions i vivenda",
    "content": "La família, els noms propis, els estudis i l'escola, les professions i els oficis i la vivenda.", "icon": "🏠", "color": "#FFCCBC",
    "exercises": [
      {"q": "Com es diu la mare de ta mare?", "o": ["l'àvia", "la tia", "la cosina"], "e": "La mare del pare o de la mare és l'àvia."},
      {"q": "Com es diu el pare de ton pare?", "o": ["l'avi", "el tio", "el nebot"], "e": "El pare del pare o de la mare és l'avi."},
      {"q": "Els pares del teu pare i de la teua mare són els teus...", "o": ["avis", "oncles", "sogres"], "e": "L'avi i l'àvia: els avis."},
      {"q": "El germà de ta mare és...", "o": ["el tio", "el cosí", "el nebot"], "e": "El germà del pare o de la mare és el tio (o l'oncle)."},
      {"q": "La filla del teu tio és...", "o": ["la cosina", "la neboda", "la néta"], "e": "Els fills dels tios són els cosins."},
      {"q": "El fill del teu germà és...", "o": ["el nebot", "el cosí", "el nét"], "e": "El fill d'un germà o d'una germana és el nebot."},
      {"q": "La filla del teu fill és...", "o": ["la néta", "la neboda", "la cosina"], "e": "La filla d'un fill o d'una filla és la néta."},
      {"q": "Els fills dels mateixos pares són...", "o": ["germans", "cosins", "nebots"], "e": "Germans: tenen el mateix pare i la mateixa mare."},
      {"q": "El marit de ta germana és...", "o": ["el cunyat", "el sogre", "el gendre"], "e": "El marit d'una germana és el cunyat."},
      {"q": "La mare de la teua dona és...", "o": ["la sogra", "la cunyada", "la nora"], "e": "La mare de la parella és la sogra."},
      {"q": "La dona del teu fill és...", "o": ["la nora", "la sogra", "la cunyada"], "e": "La dona d'un fill és la nora."},
      {"q": "El marit de la teua filla és...", "o": ["el gendre", "el cunyat", "el sogre"], "e": "El marit d'una filla és el gendre."},
      {"q": "Una persona que no s'ha casat és...", "o": ["soltera", "viuda", "divorciada"], "e": "Soltera: que no s'ha casat."},
      {"q": "Una dona a qui se li ha mort el marit és...", "o": ["viuda", "soltera", "divorciada"], "e": "Viuda (o vídua)."},
      {"q": "Quin és el nom valencià de «José»?", "o": ["Josep", "Jusep", "Josè"], "e": "José → Josep."},
      {"q": "Quin és el nom valencià de «Vicente»?", "o": ["Vicent", "Vicento", "Visent"], "e": "Vicente → Vicent."},
      {"q": "Quin és el nom valencià de «Juan»?", "o": ["Joan", "Jon", "Juà"], "e": "Juan → Joan."},
      {"q": "Quin és el nom valencià de «Pedro»?", "o": ["Pere", "Pedre", "Pèdro"], "e": "Pedro → Pere."},
      {"q": "Quin és el nom valencià de «Jorge»?", "o": ["Jordi", "Jorxe", "Jòrdi"], "e": "Jorge → Jordi."},
      {"q": "Quin és el nom valencià de «Carmen»?", "o": ["Carme", "Càrmen", "Carmena"], "e": "Carmen → Carme."},
      {"q": "Quin és el nom valencià de «Jaime»?", "o": ["Jaume", "Jaim", "Jàume"], "e": "Jaime → Jaume."},
      {"q": "On escriu la mestra a classe perquè ho veja tothom?", "o": ["a la pissarra", "a la cadira", "a la motxilla"], "e": "La pissarra."},
      {"q": "Amb què esborrem el que hem escrit amb llapis?", "o": ["amb la goma", "amb el regle", "amb la carpeta"], "e": "La goma."},
      {"q": "Amb què fem línies rectes?", "o": ["amb el regle", "amb la goma", "amb l'estoig"], "e": "El regle."},
      {"q": "On guardem els llapis i els bolis?", "o": ["a l'estoig", "a la pissarra", "a la paperera"], "e": "L'estoig."},
      {"q": "On portem els llibres a l'escola, a l'esquena?", "o": ["a la motxilla", "a l'estoig", "a la cartera de mà"], "e": "La motxilla es porta a l'esquena."},
      {"q": "La persona que ensenya en una escola és...", "o": ["el mestre o la mestra", "l'alumne o l'alumna", "el conserge o la conserja"], "e": "El mestre o la mestra ensenya; l'alumne aprén."},
      {"q": "El temps de descans entre les classes és...", "o": ["l'esplai", "l'examen", "la matrícula"], "e": "L'esplai (o el pati): temps de descans a l'escola."},
      {"q": "Els treballs que la mestra mana fer a casa són...", "o": ["els deures", "les notes", "les classes"], "e": "Els deures."},
      {"q": "Per a aprovar, has de traure bona nota en l'...", "o": ["examen", "esplai", "esmorzar"], "e": "L'examen."},
      {"q": "Si no aproves una assignatura, la...", "o": ["suspens", "apuntes", "matricules"], "e": "Suspendre: no aprovar."},
      {"q": "Els estudis que es fan a la universitat són...", "o": ["la carrera", "l'escola infantil", "la primària"], "e": "La carrera universitària."},
      {"q": "Qui cura els animals malalts?", "o": ["el veterinari", "el metge", "el farmacèutic"], "e": "El veterinari."},
      {"q": "Qui treballa en una farmàcia?", "o": ["el farmacèutic", "l'infermer", "el cambrer"], "e": "El farmacèutic."},
      {"q": "Qui servix el menjar i les begudes en un bar?", "o": ["el cambrer", "el cuiner", "el forner"], "e": "El cambrer servix; el cuiner cuina."},
      {"q": "Qui fa el pa?", "o": ["el forner", "el carnisser", "el peixater"], "e": "El forner treballa al forn."},
      {"q": "Qui ven carn?", "o": ["el carnisser", "el forner", "el fuster"], "e": "El carnisser treballa a la carnisseria."},
      {"q": "Qui porta les cartes a casa?", "o": ["el carter", "el conductor", "el cambrer"], "e": "El carter."},
      {"q": "Qui apaga els incendis?", "o": ["el bomber", "el policia", "el mecànic"], "e": "El bomber."},
      {"q": "Qui arregla els cotxes?", "o": ["el mecànic", "el fontaner", "el pintor"], "e": "El mecànic treballa en un taller."},
      {"q": "Qui arregla les canonades i les aixetes?", "o": ["el fontaner", "el mecànic", "el fuster"], "e": "El fontaner (o lampista)."},
      {"q": "Qui talla els cabells?", "o": ["el perruquer", "el sastre", "el pintor"], "e": "El perruquer."},
      {"q": "Qui cultiva la terra?", "o": ["el llaurador", "el pescador", "el mariner"], "e": "El llaurador."},
      {"q": "Qui defén una persona en un judici?", "o": ["l'advocat", "el jutge", "el policia"], "e": "L'advocat."},
      {"q": "On treballa un metge?", "o": ["a l'hospital", "a l'escola", "al forn"], "e": "A l'hospital o al centre de salut."},
      {"q": "On cuinem?", "o": ["a la cuina", "al bany", "al dormitori"], "e": "A la cuina."},
      {"q": "On dormim?", "o": ["al dormitori", "al menjador", "a la cuina"], "e": "Al dormitori (o l'habitació)."},
      {"q": "On ens dutxem?", "o": ["al bany", "al rebedor", "a la terrassa"], "e": "Al bany."},
      {"q": "On mengem amb la família i rebem les visites?", "o": ["al menjador", "al bany", "al garatge"], "e": "Al menjador."},
      {"q": "On guardem el cotxe?", "o": ["al garatge", "al balcó", "al rebedor"], "e": "Al garatge."},
      {"q": "Quin moble servix per a guardar la roba?", "o": ["l'armari", "la nevera", "el sofà"], "e": "L'armari."},
      {"q": "Quin electrodomèstic manté fresc el menjar?", "o": ["la nevera", "la rentadora", "el forn"], "e": "La nevera."},
      {"q": "Quin electrodomèstic renta la roba?", "o": ["la rentadora", "la nevera", "el microones"], "e": "La rentadora."},
      {"q": "On rentem els plats?", "o": ["a la pica", "al llit", "a l'armari"], "e": "A la pica de la cuina."},
      {"q": "On et gites per a dormir?", "o": ["al llit", "a la cadira", "a la taula"], "e": "Al llit."},
      {"q": "Per on puges d'un pis a un altre si no hi ha ascensor?", "o": ["per l'escala", "pel balcó", "per la finestra"], "e": "Per l'escala."},
      {"q": "Un habitatge dins d'un edifici amb altres veïns és un...", "o": ["pis", "xalet", "mas"], "e": "Un pis."},
      {"q": "Una casa amb jardí, fora de la ciutat, és un...", "o": ["xalet", "pis", "ascensor"], "e": "Un xalet."},
      {"q": "Les persones que viuen al teu edifici són els teus...", "o": ["veïns", "cosins", "cunyats"], "e": "Els veïns."},
      {"q": "Si la casa no és teua, cada mes pagues el...", "o": ["lloguer", "bitllet", "sou"], "e": "El lloguer."},
      {"q": "Escriu la paraula: el germà del teu pare és el teu ___.", "a": ["tio", "oncle"], "e": "El tio o l'oncle."},
      {"q": "Escriu la paraula: la professió de qui cura els malalts a l'hospital i ajuda el metge.", "a": ["infermer", "infermera"], "e": "L'infermer o la infermera."},
      {"q": "Escriu el nom valencià de «Francisco».", "a": ["Francesc"], "e": "Francisco → Francesc."},
      {"q": "Escriu la paraula: lloc de la casa on es cuina.", "a": ["cuina"], "e": "La cuina."}
    ]
  },
  {
    "id": "8fb32978-b788-4be5-81da-4993e52cf2f5", "type": "vocab_paisos_transport", "sort_order": 2,
    "title": "Països, transports i vies", "name": "Països, nacionalitats, transport i comunicació",
    "content": "Els països i les nacionalitats, el transport i la comunicació i les vies urbanes i no urbanes.", "icon": "🚆", "color": "#B3E5FC",
    "exercises": [
      {"q": "Com es diu un home d'Itàlia?", "o": ["italià", "italianer", "italiés"], "e": "Itàlia → italià, italiana."},
      {"q": "Una dona d'Alemanya és...", "o": ["alemanya", "alemana", "alemanyesa"], "e": "Alemanya → alemany, alemanya."},
      {"q": "Un home d'Anglaterra és...", "o": ["anglés", "anglesenc", "anglí"], "e": "Anglaterra → anglés, anglesa."},
      {"q": "Una dona de França és...", "o": ["francesa", "francessa", "francina"], "e": "França → francés, francesa."},
      {"q": "Un home del Marroc és...", "o": ["marroquí", "marroquenc", "marroqués"], "e": "el Marroc → marroquí, marroquina."},
      {"q": "Un home de Portugal és...", "o": ["portugués", "portugalés", "portuguenc"], "e": "Portugal → portugués, portuguesa."},
      {"q": "Una dona de Romania és...", "o": ["romanesa", "romana", "romaniana"], "e": "Romania → romanés, romanesa."},
      {"q": "Un home de la Xina és...", "o": ["xinés", "xinenc", "xinà"], "e": "la Xina → xinés, xinesa."},
      {"q": "Un home del Japó és...", "o": ["japonés", "japonenc", "japonà"], "e": "el Japó → japonés, japonesa."},
      {"q": "Un home dels Estats Units és...", "o": ["nord-americà", "estatunià", "americanés"], "e": "els Estats Units → nord-americà (o estatunidenc)."},
      {"q": "Un home de Rússia és...", "o": ["rus", "russenc", "rusà"], "e": "Rússia → rus, russa."},
      {"q": "Una dona de Grècia és...", "o": ["grega", "greca", "grecesa"], "e": "Grècia → grec, grega."},
      {"q": "Un home de Suïssa és...", "o": ["suís", "suïssenc", "suissà"], "e": "Suïssa → suís, suïssa."},
      {"q": "Una dona del Brasil és...", "o": ["brasilera", "brasilenca", "brasilana"], "e": "el Brasil → brasiler, brasilera."},
      {"q": "Com es diu en valencià el país «Inglaterra»?", "o": ["Anglaterra", "Inglaterra", "Englaterra"], "e": "Anglaterra."},
      {"q": "Com es diu en valencià el país «Alemania»?", "o": ["Alemanya", "Alemània", "Alemana"], "e": "Alemanya."},
      {"q": "Quina llengua es parla a Alemanya?", "o": ["l'alemany", "l'alemanyol", "l'alemanés"], "e": "L'alemany."},
      {"q": "Quina llengua es parla al Brasil?", "o": ["el portugués", "l'espanyol", "el brasiler"], "e": "Al Brasil es parla portugués."},
      {"q": "Quin mitjà de transport va per les vies?", "o": ["el tren", "el vaixell", "l'avió"], "e": "El tren va per les vies."},
      {"q": "Quin vehicle té dues rodes i pedals?", "o": ["la bicicleta", "la moto", "el cotxe"], "e": "La bicicleta."},
      {"q": "Quin transport va per davall de terra a la ciutat?", "o": ["el metro", "el tramvia", "el taxi"], "e": "El metro."},
      {"q": "Un cotxe que et porta on vols i pagues al conductor és un...", "o": ["taxi", "autobús", "tramvia"], "e": "El taxi."},
      {"q": "On esperes l'autobús?", "o": ["a la parada", "a l'aeroport", "al port"], "e": "A la parada."},
      {"q": "On agafes l'avió?", "o": ["a l'aeroport", "al port", "a l'estació"], "e": "A l'aeroport."},
      {"q": "On agafes el vaixell?", "o": ["al port", "a l'aeroport", "a la parada"], "e": "Al port."},
      {"q": "On agafes el tren?", "o": ["a l'estació", "al port", "a l'aeroport"], "e": "A l'estació."},
      {"q": "Què has de comprar per a pujar al tren?", "o": ["el bitllet", "el segell", "la carta"], "e": "El bitllet."},
      {"q": "Un bitllet per a anar i tornar és d'...", "o": ["anada i tornada", "eixida i entrada", "pujada i baixada"], "e": "Bitllet d'anada i tornada."},
      {"q": "La persona que condueix un autobús és...", "o": ["el conductor", "el pilot", "el mariner"], "e": "El conductor."},
      {"q": "La persona que condueix un avió és...", "o": ["el pilot", "el conductor", "el taxista"], "e": "El pilot."},
      {"q": "Per a conduir un cotxe necessites el...", "o": ["carnet de conduir", "passaport", "bitllet"], "e": "El carnet de conduir."},
      {"q": "Per a viatjar a un país de fora d'Europa necessites el...", "o": ["passaport", "carnet de conduir", "segell"], "e": "El passaport."},
      {"q": "El cotxe no té benzina. On vas?", "o": ["a la gasolinera", "al taller", "a la parada"], "e": "A la gasolinera."},
      {"q": "Per a enviar una carta, necessites un...", "o": ["segell", "bitllet", "tiquet"], "e": "El segell."},
      {"q": "On compres segells i envies paquets?", "o": ["a Correus", "a la farmàcia", "al forn"], "e": "A l'oficina de Correus."},
      {"q": "On tirem les cartes per a enviar-les?", "o": ["a la bústia", "a la paperera", "al calaix"], "e": "A la bústia."},
      {"q": "Dins de què posem la carta?", "o": ["dins d'un sobre", "dins d'un segell", "dins d'una bústia de paper"], "e": "La carta va dins d'un sobre."},
      {"q": "Amb què fem una telefonada?", "o": ["amb el mòbil", "amb la bústia", "amb el sobre"], "e": "Amb el mòbil o el telèfon."},
      {"q": "Un missatge que envies per internet és un...", "o": ["correu electrònic", "segell", "sobre"], "e": "Un correu electrònic."},
      {"q": "Quan algú et telefona, el mòbil...", "o": ["sona", "canta", "crida"], "e": "El mòbil sona."},
      {"q": "Una via ampla d'una ciutat, amb arbres, és una...", "o": ["avinguda", "senda", "autopista"], "e": "Una avinguda."},
      {"q": "Una via ràpida per a cotxes entre ciutats és una...", "o": ["autopista", "plaça", "vorera"], "e": "Una autopista (o autovia)."},
      {"q": "Per on caminen les persones en un carrer?", "o": ["per la vorera", "per la carretera", "per l'autopista"], "e": "Per la vorera."},
      {"q": "Per on travessem el carrer?", "o": ["pel pas de vianants", "per la rotonda", "per l'autopista"], "e": "Pel pas de vianants."},
      {"q": "La llum que diu quan pots passar (roja, groga, verda) és...", "o": ["el semàfor", "el fanal", "el pont"], "e": "El semàfor."},
      {"q": "Un encreuament en forma de cercle on giren els cotxes és...", "o": ["una rotonda", "una plaça", "un pont"], "e": "Una rotonda."},
      {"q": "Un lloc ample i obert en un poble, sovint amb una font, és...", "o": ["una plaça", "una autovia", "una senda"], "e": "Una plaça."},
      {"q": "Un camí estret per a caminar pel camp o la muntanya és...", "o": ["una senda", "una avinguda", "una autopista"], "e": "Una senda."},
      {"q": "Una construcció per a passar per damunt d'un riu és...", "o": ["un pont", "un túnel", "un passeig"], "e": "Un pont."},
      {"q": "Un carrer molt estret i curt és...", "o": ["un carreró", "una avinguda", "una carretera"], "e": "Un carreró."},
      {"q": "El passeig al costat de la mar és...", "o": ["el passeig marítim", "la carretera", "l'autopista"], "e": "El passeig marítim."},
      {"q": "Escriu la nacionalitat: una dona d'Anglaterra és ___.", "a": ["anglesa"], "e": "Anglesa."},
      {"q": "Escriu la nacionalitat: un home d'Espanya és ___.", "a": ["espanyol"], "e": "Espanyol."},
      {"q": "Escriu la paraula: on esperes l'autobús? A la ___.", "a": ["parada"], "e": "A la parada."},
      {"q": "Escriu la professió de qui porta les cartes.", "a": ["carter", "cartera"], "e": "El carter o la cartera."}
    ]
  },
  {
    "id": "cef4ecd9-b084-43b8-8ee5-d305e3b702f8", "type": "vocab_temps", "sort_order": 3,
    "title": "L'hora i el calendari", "name": "La mesura del temps",
    "content": "L'hora, les parts del dia, els dies de la setmana, els mesos i les estacions.", "icon": "🕒", "color": "#FFF9C4",
    "exercises": [
      {"q": "Són les 17.30. Com ho dius?", "o": ["Són les cinc i mitja de la vesprada.", "Són les set i mitja.", "És la una i mitja."], "e": "Les 17.30 són les cinc i mitja de la vesprada."},
      {"q": "Són les 8.00 del matí. Com ho dius?", "o": ["Són les huit del matí.", "Són les huit de la nit.", "És la huit del matí."], "e": "Són les huit (o vuit) del matí."},
      {"q": "Són les 13.00. Com ho dius?", "o": ["És la una del migdia.", "Són la una.", "Són les u."], "e": "Amb la una s'usa el singular: és la una."},
      {"q": "Són les 21.15. Com ho dius?", "o": ["Són les nou i quart de la nit.", "Són les nou i quart del matí.", "Són les deu i quart de la nit."], "e": "Les 21.15 són les nou i quart de la nit."},
      {"q": "Són les 10.45. Com ho dius?", "o": ["Són les onze menys quart.", "Són les deu menys quart.", "Són les onze i quart."], "e": "Falta un quart per a les onze: les onze menys quart (o tres quarts d'onze)."},
      {"q": "Són les 12.00 de la nit. Com ho dius?", "o": ["És mitjanit.", "És migdia.", "És de vesprada."], "e": "Les 12 de la nit: mitjanit."},
      {"q": "Són les 12.00 del dia. Com ho dius?", "o": ["És migdia.", "És mitjanit.", "És de vesprada."], "e": "Les 12 del dia: migdia."},
      {"q": "Com preguntes l'hora?", "o": ["Quina hora és?", "Quant hora és?", "Què hora és?"], "e": "Quina hora és?"},
      {"q": "Com preguntes quan comença una cosa?", "o": ["A quina hora comença?", "En quina hora comença?", "Quina hora comença?"], "e": "A quina hora...?"},
      {"q": "La primera part del dia és...", "o": ["el matí", "la vesprada", "la nit"], "e": "El matí."},
      {"q": "La part del dia després de dinar és...", "o": ["la vesprada", "el matí", "la matinada"], "e": "La vesprada."},
      {"q": "Quan es fa fosc, abans de la nit, és...", "o": ["el vespre", "el matí", "la matinada"], "e": "El vespre."},
      {"q": "Les hores després de mitjanit, abans que isca el sol, són...", "o": ["la matinada", "la vesprada", "el migdia"], "e": "La matinada."},
      {"q": "El menjar del matí és...", "o": ["l'esmorzar", "el sopar", "el dinar"], "e": "L'esmorzar."},
      {"q": "El menjar del migdia és...", "o": ["el dinar", "el sopar", "l'esmorzar"], "e": "El dinar."},
      {"q": "El menjar de la nit és...", "o": ["el sopar", "el dinar", "el berenar"], "e": "El sopar."},
      {"q": "El menjar de mitja vesprada, sobretot dels xiquets, és...", "o": ["el berenar", "el sopar", "l'esmorzar"], "e": "El berenar."},
      {"q": "Quin dia va després de dimecres?", "o": ["dijous", "dimarts", "divendres"], "e": "Dilluns, dimarts, dimecres, dijous, divendres, dissabte i diumenge."},
      {"q": "Quin dia va abans de diumenge?", "o": ["dissabte", "dilluns", "divendres"], "e": "Dissabte va abans de diumenge."},
      {"q": "Quin és el primer dia de la setmana laboral?", "o": ["dilluns", "diumenge", "dimarts"], "e": "Dilluns."},
      {"q": "Dissabte i diumenge són...", "o": ["el cap de setmana", "dies feiners", "la quinzena"], "e": "El cap de setmana."},
      {"q": "Els dies de dilluns a divendres són dies...", "o": ["feiners", "festius", "vells"], "e": "Dies feiners: dies de treball."},
      {"q": "Si hui és dimarts, demà passat serà...", "o": ["dijous", "dimecres", "divendres"], "e": "Demà: dimecres; demà passat: dijous."},
      {"q": "Si hui és dilluns, abans-d'ahir va ser...", "o": ["dissabte", "diumenge", "divendres"], "e": "Ahir: diumenge; abans-d'ahir: dissabte."},
      {"q": "Set dies fan una...", "o": ["setmana", "quinzena", "mesada"], "e": "Una setmana."},
      {"q": "Quinze dies fan una...", "o": ["quinzena", "setmana", "dotzena"], "e": "Una quinzena."},
      {"q": "Quin és el primer mes de l'any?", "o": ["gener", "febrer", "desembre"], "e": "Gener."},
      {"q": "Quin mes va després de març?", "o": ["abril", "maig", "febrer"], "e": "Març, abril, maig."},
      {"q": "Quin mes té 28 dies (o 29)?", "o": ["febrer", "gener", "juny"], "e": "Febrer."},
      {"q": "Quin mes va entre juny i agost?", "o": ["juliol", "maig", "setembre"], "e": "Juny, juliol, agost."},
      {"q": "Quin mes va després de setembre?", "o": ["octubre", "novembre", "agost"], "e": "Setembre, octubre, novembre."},
      {"q": "Quin és l'últim mes de l'any?", "o": ["desembre", "novembre", "octubre"], "e": "Desembre."},
      {"q": "En quin mes és Nadal?", "o": ["desembre", "gener", "novembre"], "e": "Nadal és el 25 de desembre."},
      {"q": "En quin mes solen començar les classes?", "o": ["setembre", "juliol", "gener"], "e": "Setembre."},
      {"q": "Dotze mesos fan un...", "o": ["any", "segle", "trimestre"], "e": "Un any."},
      {"q": "En quina estació de l'any fa més calor?", "o": ["l'estiu", "l'hivern", "la tardor"], "e": "L'estiu."},
      {"q": "En quina estació fa més fred?", "o": ["l'hivern", "l'estiu", "la primavera"], "e": "L'hivern."},
      {"q": "En quina estació cauen les fulles dels arbres?", "o": ["la tardor", "la primavera", "l'estiu"], "e": "La tardor."},
      {"q": "En quina estació ixen les flors?", "o": ["la primavera", "la tardor", "l'hivern"], "e": "La primavera."},
      {"q": "Quantes estacions té l'any?", "o": ["quatre", "tres", "dotze"], "e": "Primavera, estiu, tardor i hivern."},
      {"q": "Seixanta minuts fan una...", "o": ["hora", "setmana", "quinzena"], "e": "Una hora."},
      {"q": "Seixanta segons fan un...", "o": ["minut", "hora", "dia"], "e": "Un minut."},
      {"q": "Mitja hora són...", "o": ["trenta minuts", "quinze minuts", "quaranta-cinc minuts"], "e": "Mitja hora = 30 minuts."},
      {"q": "Un quart d'hora són...", "o": ["quinze minuts", "trenta minuts", "deu minuts"], "e": "Un quart d'hora = 15 minuts."},
      {"q": "Cent anys fan un...", "o": ["segle", "trimestre", "mes"], "e": "Un segle."},
      {"q": "El dia abans d'ahir és...", "o": ["abans-d'ahir", "demà passat", "anit"], "e": "Abans-d'ahir."},
      {"q": "La nit d'ahir és...", "o": ["anit", "demà", "enguany"], "e": "Anit."},
      {"q": "L'any en què estem és...", "o": ["enguany", "l'any que ve", "l'any passat"], "e": "Enguany: este any."},
      {"q": "Escriu el dia que va després de dijous.", "a": ["divendres"], "e": "Divendres."},
      {"q": "Escriu el mes que va després de juliol.", "a": ["agost"], "e": "Agost."},
      {"q": "Escriu l'estació que va després de l'estiu.", "a": ["tardor", "la tardor"], "e": "La tardor."},
      {"q": "Escriu el nom del menjar de la nit.", "a": ["sopar", "el sopar"], "e": "El sopar."}
    ]
  },
  {
    "id": "6cb790d3-59d2-40f2-ad09-b465ae03a471", "type": "vocab_menjar", "sort_order": 4,
    "title": "El menjar", "name": "Aliments, begudes, envasos i mesures",
    "content": "Els aliments, les begudes, els envasos i les mesures; al restaurant i a la taula.", "icon": "🍅", "color": "#DCEDC8",
    "exercises": [
      {"q": "Quina d'estes és una hortalissa?", "o": ["la ceba", "la poma", "la pera"], "e": "La ceba és una hortalissa; la poma i la pera són fruites."},
      {"q": "Quina fruita és groga i llarga?", "o": ["el plàtan", "la maduixa", "la cirera"], "e": "El plàtan."},
      {"q": "Quina fruita és roja, xicoteta i té un pinyol?", "o": ["la cirera", "la síndria", "el meló"], "e": "La cirera."},
      {"q": "Quina fruita és gran, verda per fora i roja per dins?", "o": ["la síndria", "el meló", "la pinya"], "e": "La síndria."},
      {"q": "Quina fruita valenciana fem servir per a fer suc?", "o": ["la taronja", "la pinya", "la pera"], "e": "La taronja."},
      {"q": "Amb quina fruita es fa el vi?", "o": ["amb el raïm", "amb la pera", "amb la poma"], "e": "El vi es fa amb raïm."},
      {"q": "Quina hortalissa roja fem servir per a l'amanida i el gaspatxo?", "o": ["la tomaca", "la creïlla", "la ceba"], "e": "La tomaca (o tomàquet)."},
      {"q": "Amb què fem la truita i les patates fregides?", "o": ["amb creïlles", "amb cebes", "amb carabasses"], "e": "La creïlla (o patata)."},
      {"q": "Quina hortalissa és taronja i llarga?", "o": ["la safanòria", "la ceba", "la col"], "e": "La safanòria (o pastanaga)."},
      {"q": "Quina verdura de fulles verdes posem a l'amanida?", "o": ["l'enciam", "l'all", "la ceba"], "e": "L'enciam."},
      {"q": "Quin condiment xicotet i blanc té un sabor molt fort?", "o": ["l'all", "l'enciam", "el julivert"], "e": "L'all (per a l'allioli)."},
      {"q": "Quin d'estos aliments és un llegum?", "o": ["els cigrons", "les pomes", "els raïms"], "e": "Els cigrons, les llentilles i les mongetes són llegums."},
      {"q": "Quin llegum és xicotet, redó i marró?", "o": ["les llentilles", "les cireres", "les olives"], "e": "Les llentilles."},
      {"q": "La paella valenciana porta pollastre i...", "o": ["conill", "vedella", "sardina"], "e": "La paella valenciana porta pollastre i conill."},
      {"q": "La carn de vaca jove és...", "o": ["la vedella", "el corder", "el porc"], "e": "La vedella."},
      {"q": "La carn de l'ovella jove és...", "o": ["el corder", "la vedella", "el conill"], "e": "El corder (o xai)."},
      {"q": "Quin és un peix blau xicotet i molt comú?", "o": ["la sardina", "el lluç", "la gamba"], "e": "La sardina."},
      {"q": "Quin animal de la mar té pinces?", "o": ["el cranc", "la sardina", "la tonyina"], "e": "El cranc."},
      {"q": "Quin aliment blanc ens donen les vaques?", "o": ["la llet", "l'oli", "la farina"], "e": "La llet."},
      {"q": "Quin aliment fet amb llet pot ser tendre o curat?", "o": ["el formatge", "el iogurt", "la mantega"], "e": "El formatge."},
      {"q": "Què ponen les gallines?", "o": ["ous", "llet", "carn"], "e": "Les gallines ponen ous."},
      {"q": "Què comprem al forn?", "o": ["el pa", "la carn", "el peix"], "e": "Al forn comprem pa."},
      {"q": "Quin cereal és l'ingredient principal de la paella?", "o": ["l'arròs", "el blat", "la civada"], "e": "L'arròs."},
      {"q": "Quin plat es fa amb ous batuts i creïlla?", "o": ["la truita", "la paella", "el gaspatxo"], "e": "La truita de creïlla."},
      {"q": "Pa obert amb formatge, pernil o truita dins és...", "o": ["un entrepà", "un pastís", "una sopa"], "e": "Un entrepà."},
      {"q": "Quin dolç mengem en els aniversaris?", "o": ["el pastís", "l'entrepà", "el pa"], "e": "El pastís."},
      {"q": "Quin condiment blanc ve de la mar?", "o": ["la sal", "el sucre", "el pebre"], "e": "La sal."},
      {"q": "Què endolcix el café?", "o": ["el sucre", "la sal", "l'oli"], "e": "El sucre."},
      {"q": "Amb què amanim l'amanida?", "o": ["amb oli i sal", "amb sucre i llet", "amb farina i ous"], "e": "Amb oli, sal i vinagre."},
      {"q": "Quina beguda calenta es fa amb fulles?", "o": ["el te", "el café", "la llet"], "e": "El te."},
      {"q": "Quina beguda de raïm té alcohol?", "o": ["el vi", "el suc", "l'orxata"], "e": "El vi."},
      {"q": "Quina beguda té alcohol, es fa amb ordi i fa escuma?", "o": ["la cervesa", "el vi", "el suc"], "e": "La cervesa."},
      {"q": "Quina beguda es fa esprement fruita?", "o": ["el suc", "el vi", "la cervesa"], "e": "El suc."},
      {"q": "Quina beguda valenciana es fa amb xufa?", "o": ["l'orxata", "la llimonada", "el granissat de café"], "e": "L'orxata de xufa."},
      {"q": "Una beguda amb bombolles i sense alcohol és...", "o": ["un refresc", "un vi", "un cava"], "e": "Un refresc."},
      {"q": "Quin d'estos és un envàs?", "o": ["una botella", "un quilo", "un litre"], "e": "La botella és un envàs. Quilo i litre són mesures."},
      {"q": "L'envàs de metall per als refrescos o la tonyina és...", "o": ["la llanda", "el sac", "la safata"], "e": "La llanda (o llauna)."},
      {"q": "L'envàs de vidre amb tapa per a la melmelada és...", "o": ["el pot", "la bossa", "el sobre"], "e": "El pot."},
      {"q": "Les galetes i l'arròs els comprem en un...", "o": ["paquet", "pot de vidre", "got"], "e": "Un paquet."},
      {"q": "La carn del supermercat ve en una...", "o": ["safata", "botella", "llanda"], "e": "Una safata."},
      {"q": "L'oli i la llet es venen per...", "o": ["litres", "quilos", "metres"], "e": "Els líquids es venen per litres."},
      {"q": "La fruita es ven per...", "o": ["quilos", "litres", "metres"], "e": "Per quilos."},
      {"q": "Mig quilo són...", "o": ["cinc-cents grams", "cent grams", "mil grams"], "e": "Un quilo = 1.000 grams; mig quilo = 500 grams."},
      {"q": "Els ous es venen per...", "o": ["dotzenes", "litres", "metres"], "e": "Una dotzena = 12 ous."},
      {"q": "Un tros pla de pa és una...", "o": ["llesca", "tassa", "botella"], "e": "Una llesca de pa."},
      {"q": "Amb què mengem la sopa?", "o": ["amb la cullera", "amb la forqueta", "amb el ganivet"], "e": "Amb la cullera."},
      {"q": "Amb què tallem la carn?", "o": ["amb el ganivet", "amb la cullera", "amb el got"], "e": "Amb el ganivet."},
      {"q": "On bevem l'aigua?", "o": ["en un got", "en un plat", "en una forqueta"], "e": "En un got."},
      {"q": "Al restaurant, per a saber què hi ha per a menjar, demanes...", "o": ["la carta", "el compte", "la propina"], "e": "La carta."},
      {"q": "Al restaurant, per a pagar, demanes...", "o": ["el compte", "la carta", "el menú"], "e": "El compte, per favor."},
      {"q": "Després del segon plat mengem...", "o": ["les postres", "l'esmorzar", "l'entrant"], "e": "Les postres."},
      {"q": "Escriu el nom de la beguda valenciana que es fa amb xufa.", "a": ["orxata", "l'orxata"], "e": "L'orxata."},
      {"q": "Escriu el nom de la fruita groga i àcida.", "a": ["llima", "llimona"], "e": "La llima (o llimona)."},
      {"q": "Escriu el nom del plat valencià d'arròs que es cuina en una paella.", "a": ["paella"], "e": "La paella."},
      {"q": "Escriu el nom del lloc on es compra el pa.", "a": ["forn", "el forn", "al forn", "fleca", "la fleca"], "e": "El forn (o la fleca)."}
    ]
  },
  {
    "id": "a08cc2d7-a3db-4e92-9661-7c15b9342144", "type": "vocab_roba_cos", "sort_order": 5,
    "title": "La roba, el cos i els colors", "name": "Vestit, complements, cos humà i colors",
    "content": "El vestit i els complements, el cos humà i els colors.", "icon": "👕", "color": "#F8BBD0",
    "exercises": [
      {"q": "Quina peça de roba portem a les cames?", "o": ["els pantalons", "la camisa", "la jaqueta"], "e": "Els pantalons."},
      {"q": "Quina peça de màniga curta portem quan fa calor?", "o": ["la samarreta", "l'abric", "la bufanda"], "e": "La samarreta."},
      {"q": "Quina peça llarga portem damunt de la roba quan fa molt de fred?", "o": ["l'abric", "el banyador", "la samarreta"], "e": "L'abric."},
      {"q": "Què portem per a nadar a la platja?", "o": ["el banyador", "l'abric", "la corbata"], "e": "El banyador."},
      {"q": "Quina peça cobrix de la cintura a les cames i la porten sobretot les dones?", "o": ["la falda", "la camisa", "la jaqueta"], "e": "La falda."},
      {"q": "Què portem als peus, dins de les sabates?", "o": ["els calcetins", "els guants", "els botons"], "e": "Els calcetins."},
      {"q": "Què portem a les mans quan fa fred?", "o": ["els guants", "els calcetins", "les arracades"], "e": "Els guants."},
      {"q": "Què portem al coll quan fa fred?", "o": ["la bufanda", "la gorra", "el cinturó"], "e": "La bufanda."},
      {"q": "Què portem al cap per a protegir-nos del sol?", "o": ["el barret", "la bufanda", "el cinturó"], "e": "El barret (o la gorra)."},
      {"q": "Què servix perquè no caiguen els pantalons?", "o": ["el cinturó", "la corbata", "la bufanda"], "e": "El cinturó."},
      {"q": "Què porten alguns homes al coll, amb camisa i jaqueta?", "o": ["la corbata", "el cinturó", "el rellotge"], "e": "La corbata."},
      {"q": "Quin calcer alt portem quan plou?", "o": ["les botes", "les sandàlies", "les espardenyes"], "e": "Les botes."},
      {"q": "Quin calcer obert portem a l'estiu?", "o": ["les sandàlies", "les botes", "els calcetins"], "e": "Les sandàlies."},
      {"q": "Quina roba portem per a dormir?", "o": ["el pijama", "el banyador", "l'abric"], "e": "El pijama."},
      {"q": "On guardem els diners i les targetes?", "o": ["a la cartera", "a la corbata", "al cinturó"], "e": "A la cartera."},
      {"q": "Quin complement ens diu l'hora?", "o": ["el rellotge", "l'anell", "la polsera"], "e": "El rellotge."},
      {"q": "Quina joia portem al dit?", "o": ["l'anell", "l'arracada", "el collar"], "e": "L'anell."},
      {"q": "Quines joies portem a les orelles?", "o": ["les arracades", "els anells", "les polseres"], "e": "Les arracades."},
      {"q": "Què fem servir perquè no ens mulle la pluja?", "o": ["el paraigua", "el barret de palla", "la bufanda"], "e": "El paraigua."},
      {"q": "Què ens posem per a protegir els ulls del sol?", "o": ["les ulleres de sol", "els guants", "les arracades"], "e": "Les ulleres de sol."},
      {"q": "On guardes les claus en els pantalons?", "o": ["a la butxaca", "a la màniga", "al coll"], "e": "A la butxaca."},
      {"q": "Quina part de la camisa cobrix el braç?", "o": ["la màniga", "la butxaca", "el botó"], "e": "La màniga."},
      {"q": "A la botiga, on vas per a provar-te la roba?", "o": ["a l'emprovador", "a la caixa", "a l'aparador"], "e": "A l'emprovador."},
      {"q": "On et poses les sabates?", "o": ["als peus", "a les mans", "al cap"], "e": "Les sabates van als peus."},
      {"q": "Amb què veiem?", "o": ["amb els ulls", "amb les orelles", "amb el nas"], "e": "Amb els ulls."},
      {"q": "Amb què sentim?", "o": ["amb les orelles", "amb els ulls", "amb la boca"], "e": "Amb les orelles."},
      {"q": "Amb què olorem?", "o": ["amb el nas", "amb la boca", "amb les mans"], "e": "Amb el nas."},
      {"q": "Què tenim dins de la boca per a mastegar?", "o": ["les dents", "els llavis", "les ungles"], "e": "Les dents."},
      {"q": "Què tenim dins de la boca per a notar el sabor?", "o": ["la llengua", "les dents", "els llavis"], "e": "La llengua."},
      {"q": "Quina part del cos va entre el cap i les espatles?", "o": ["el coll", "el colze", "el genoll"], "e": "El coll."},
      {"q": "Quina part del braç es doblega?", "o": ["el colze", "el genoll", "el turmell"], "e": "El colze."},
      {"q": "Quina part de la cama es doblega?", "o": ["el genoll", "el colze", "el canell"], "e": "El genoll."},
      {"q": "Quina part del cos va entre la cama i el peu?", "o": ["el turmell", "el canell", "el colze"], "e": "El turmell."},
      {"q": "Quina part del cos va entre el braç i la mà?", "o": ["el canell", "el turmell", "el genoll"], "e": "El canell."},
      {"q": "Quants dits tenim en cada mà?", "o": ["cinc", "quatre", "deu"], "e": "Cinc dits en cada mà."},
      {"q": "La part de darrere del cos, de les espatles a la cintura, és...", "o": ["l'esquena", "la panxa", "el pit"], "e": "L'esquena."},
      {"q": "La part de davant del cos on tenim el melic és...", "o": ["la panxa", "l'esquena", "el coll"], "e": "La panxa."},
      {"q": "El pèl que tenim al cap són...", "o": ["els cabells", "les celles", "les pestanyes"], "e": "Els cabells."},
      {"q": "El pèl de la cara d'alguns homes, a la barbeta, és...", "o": ["la barba", "les celles", "els cabells"], "e": "La barba."},
      {"q": "Quin òrgan bomba la sang?", "o": ["el cor", "l'estómac", "el pulmó"], "e": "El cor."},
      {"q": "Amb què respirem?", "o": ["amb els pulmons", "amb l'estómac", "amb el cor"], "e": "Amb els pulmons."},
      {"q": "On va el menjar quan l'empassem?", "o": ["a l'estómac", "als pulmons", "al cor"], "e": "A l'estómac."},
      {"q": "De quin color és la neu?", "o": ["blanca", "negra", "roja"], "e": "La neu és blanca."},
      {"q": "De quin color és el cel quan fa sol?", "o": ["blau", "verd", "marró"], "e": "Blau."},
      {"q": "De quin color és l'herba?", "o": ["verda", "groga", "blava"], "e": "Verda."},
      {"q": "De quin color és la sang?", "o": ["roja", "blava", "verda"], "e": "Roja."},
      {"q": "De quin color són les llimes?", "o": ["grogues", "morades", "blanques"], "e": "Grogues."},
      {"q": "De quin color és el carbó?", "o": ["negre", "blanc", "groc"], "e": "Negre."},
      {"q": "De quin color és la xocolata?", "o": ["marró", "groc", "verd"], "e": "Marró."},
      {"q": "Si mesclem blanc i negre, quin color ix?", "o": ["gris", "rosa", "marró"], "e": "Gris."},
      {"q": "Si mesclem roig i blanc, quin color ix?", "o": ["rosa", "taronja", "gris"], "e": "Rosa."},
      {"q": "Si mesclem blau i roig, quin color ix?", "o": ["morat", "verd", "taronja"], "e": "Morat."},
      {"q": "Si mesclem groc i blau, quin color ix?", "o": ["verd", "morat", "gris"], "e": "Verd."},
      {"q": "Quin és el femení de «roig»?", "o": ["roja", "roiga", "rotja"], "e": "Roig → roja."},
      {"q": "Quin és el femení de «groc»?", "o": ["groga", "groca", "grogua"], "e": "Groc → groga."},
      {"q": "Quin és el plural de «blau» (masculí)?", "o": ["blaus", "blavos", "blaves"], "e": "Blau → blaus (femení: blava, blaves)."},
      {"q": "Escriu la part del cos amb què veiem (en plural).", "a": ["ulls", "els ulls"], "e": "Els ulls."},
      {"q": "Escriu el nom de la peça de roba que portem a les cames.", "a": ["pantalons", "els pantalons", "pantaló", "el pantaló"], "e": "Els pantalons."},
      {"q": "Escriu el color de la neu (en masculí).", "a": ["blanc"], "e": "Blanc."}
    ]
  },
  {
    "id": "4cd60711-b1d4-4d5a-b88e-d277d3989a0e", "type": "vocab_oci", "sort_order": 6,
    "title": "Oci, viatges i festes", "name": "Temps lliure, aficions, viatges i festes",
    "content": "El temps lliure i les aficions, els viatges i les vacances i les festes.", "icon": "🎉", "color": "#FFE082",
    "exercises": [
      {"q": "Si t'agrada llegir, pots traure llibres de...", "o": ["la biblioteca", "la farmàcia", "el gimnàs"], "e": "La biblioteca."},
      {"q": "On veiem pel·lícules en una pantalla gran?", "o": ["al cine", "al museu", "a la biblioteca"], "e": "Al cine."},
      {"q": "On veiem obres de teatre?", "o": ["al teatre", "al cine", "a l'estadi"], "e": "Al teatre."},
      {"q": "On veiem quadres i escultures?", "o": ["al museu", "a l'estadi", "al mercat"], "e": "Al museu."},
      {"q": "On fem esport amb màquines i peses?", "o": ["al gimnàs", "a la biblioteca", "al museu"], "e": "Al gimnàs."},
      {"q": "Quin esport es juga amb una pilota i dues porteries?", "o": ["el futbol", "el tenis", "la natació"], "e": "El futbol."},
      {"q": "Quin esport fem a la piscina?", "o": ["la natació", "el ciclisme", "el bàsquet"], "e": "La natació."},
      {"q": "En quin esport anem amb bicicleta?", "o": ["el ciclisme", "la natació", "l'atletisme"], "e": "El ciclisme."},
      {"q": "Quin és l'esport tradicional valencià que es juga amb la mà?", "o": ["la pilota valenciana", "el tenis", "el golf"], "e": "La pilota valenciana."},
      {"q": "Anar a caminar per la muntanya és fer...", "o": ["senderisme", "natació", "ciclisme"], "e": "Senderisme."},
      {"q": "Quin instrument té tecles blanques i negres?", "o": ["el piano", "la guitarra", "el violí"], "e": "El piano."},
      {"q": "Quin instrument de vent sona en moltes festes valencianes, amb el tabal?", "o": ["la dolçaina", "el piano", "la guitarra"], "e": "La dolçaina i el tabal."},
      {"q": "Una persona que toca música és...", "o": ["un músic", "un pintor", "un escriptor"], "e": "Un músic."},
      {"q": "Si t'agrada fer fotos, la teua afició és la...", "o": ["fotografia", "pintura", "natació"], "e": "La fotografia."},
      {"q": "Jugar a la baralla és jugar a les...", "o": ["cartes", "pilotes", "raquetes"], "e": "Jugar a les cartes."},
      {"q": "Mirar botigues i comprar roba és anar de...", "o": ["compres", "vacances", "excursió"], "e": "Anar de compres."},
      {"q": "Per a entrar al cine o a un concert necessites...", "o": ["l'entrada", "el segell", "el passaport"], "e": "L'entrada."},
      {"q": "On dorms quan vas de viatge?", "o": ["a l'hotel", "a l'hospital", "a l'estació"], "e": "A l'hotel."},
      {"q": "Una habitació d'hotel per a dues persones és...", "o": ["doble", "individual", "senzilla"], "e": "Doble: per a dues persones. Individual: per a una."},
      {"q": "On guardes la roba quan vas de viatge?", "o": ["a la maleta", "a la cartera", "a la bústia"], "e": "A la maleta."},
      {"q": "Un mapa dels carrers d'una ciutat és...", "o": ["un plànol", "un calendari", "un horari"], "e": "Un plànol."},
      {"q": "On donen informació als turistes?", "o": ["a l'oficina de turisme", "a l'oficina de Correus", "a la comissaria"], "e": "A l'oficina de turisme."},
      {"q": "Una persona que visita una ciutat per a conéixer-la és...", "o": ["un turista", "un veí", "un alumne"], "e": "Un turista."},
      {"q": "La persona que explica la ciutat als turistes és...", "o": ["el guia", "el xofer", "el cambrer"], "e": "El guia."},
      {"q": "Quan tornes d'un viatge, a vegades portes als amics un...", "o": ["record", "bitllet", "segell"], "e": "Un record del viatge."},
      {"q": "Una targeta amb la foto d'un lloc que enviem per correu és...", "o": ["una postal", "un segell", "un sobre"], "e": "Una postal."},
      {"q": "A la platja ens gitem damunt de la...", "o": ["tovallola", "catifa", "cadira de l'oficina"], "e": "La tovallola."},
      {"q": "Quan anem d'acampada dormim en una...", "o": ["tenda de campanya", "maleta", "piscina"], "e": "Una tenda de campanya."},
      {"q": "Els dies que no treballes a l'estiu són les...", "o": ["vacances", "feines", "classes"], "e": "Les vacances."},
      {"q": "Passar el dia fora, per exemple a la muntanya, és fer...", "o": ["una excursió", "una reunió", "una classe"], "e": "Una excursió."},
      {"q": "Quina festa valenciana se celebra al mes de març?", "o": ["les Falles", "el Nadal", "Sant Joan"], "e": "Les Falles, del 15 al 19 de març."},
      {"q": "Quina festa se celebra la nit del 23 al 24 de juny, amb fogueres a la platja?", "o": ["Sant Joan", "Nadal", "Pasqua"], "e": "La nit de Sant Joan."},
      {"q": "Com es diuen les festes de Sant Joan a Alacant?", "o": ["les Fogueres", "les Falles", "la Magdalena"], "e": "Les Fogueres de Sant Joan."},
      {"q": "Quina és la festa de Castelló a la primavera?", "o": ["la Magdalena", "les Fogueres", "les Falles"], "e": "Les festes de la Magdalena."},
      {"q": "En quina festa hi ha desfilades de «moros» i «cristians», com a Alcoi?", "o": ["els Moros i Cristians", "les Falles", "la Magdalena"], "e": "Els Moros i Cristians."},
      {"q": "A les Falles, el soroll de pólvora que se sent al migdia és...", "o": ["la mascletà", "la cremà", "l'ofrena"], "e": "La mascletà."},
      {"q": "La nit del 19 de març, quan es cremen les falles, és...", "o": ["la cremà", "la mascletà", "l'ofrena"], "e": "La cremà."},
      {"q": "Quan els fallers porten flors a la Mare de Déu, és...", "o": ["l'ofrena", "la cremà", "la mascletà"], "e": "L'ofrena de flors."},
      {"q": "Quina festa se celebra el 25 de desembre?", "o": ["Nadal", "Pasqua", "Cap d'Any"], "e": "Nadal."},
      {"q": "El primer dia de l'any, l'1 de gener, és...", "o": ["Cap d'Any", "Nadal", "Reis"], "e": "Cap d'Any."},
      {"q": "Qui porta regals el 6 de gener?", "o": ["els Reis Mags", "els fallers", "els turistes"], "e": "Els Reis Mags (o Reis d'Orient)."},
      {"q": "En quina festa de primavera mengem la mona?", "o": ["Pasqua", "Nadal", "les Falles"], "e": "La mona de Pasqua."},
      {"q": "El dia que fas anys és el teu...", "o": ["aniversari", "casament", "bateig"], "e": "L'aniversari."},
      {"q": "Què dius a algú el dia del seu aniversari?", "o": ["Per molts anys!", "Bon profit!", "Bon viatge!"], "e": "Per molts anys!"},
      {"q": "Què dius a la gent el dia de Nadal?", "o": ["Bon Nadal!", "Bon profit!", "Que et millores!"], "e": "Bon Nadal!"},
      {"q": "La celebració en què es casen dues persones és...", "o": ["el casament", "el bateig", "l'aniversari"], "e": "El casament (o la boda)."},
      {"q": "Els coets de colors que il·luminen el cel de nit són...", "o": ["els focs artificials", "les campanes", "les fogueres"], "e": "Els focs artificials."},
      {"q": "Escriu el nom de la festa del 25 de desembre.", "a": ["Nadal"], "e": "Nadal."},
      {"q": "Escriu on vas a vore pel·lícules.", "a": ["cine", "el cine", "al cine", "cinema", "al cinema"], "e": "Al cine (o cinema)."},
      {"q": "Escriu on guardes la roba quan vas de viatge.", "a": ["maleta", "la maleta", "una maleta"], "e": "La maleta."}
    ]
  },
  {
    "id": "9e98c74e-b152-480c-a5c8-c74760011079", "type": "vocab_salut", "sort_order": 7,
    "title": "La salut", "name": "Les malalties i els remeis",
    "content": "Símptomes i malalties comunes, el metge, la farmàcia i els remeis.", "icon": "💊", "color": "#B2DFDB",
    "exercises": [
      {"q": "Tinc tos i mocs: estic ___.", "o": ["refredat", "afamat", "avorrit"], "e": "Refredat: amb tos, mocs i a vegades febre."},
      {"q": "Tinc la temperatura molt alta: tinc...", "o": ["febre", "gana", "son"], "e": "Febre."},
      {"q": "Em fa mal el cap: tinc...", "o": ["mal de cap", "mal de panxa", "mal de queixal"], "e": "Mal de cap."},
      {"q": "Em fa mal una dent: tinc mal de...", "o": ["queixal", "cap", "esquena"], "e": "Mal de queixal."},
      {"q": "He menjat massa i em fa mal...", "o": ["la panxa", "l'orella", "el genoll"], "e": "Mal de panxa."},
      {"q": "Em fa mal quan empasse i tinc la gola roja: tinc mal de...", "o": ["gola", "panxa", "peu"], "e": "Mal de gola."},
      {"q": "Quan fas «atxim!»...", "o": ["esternudes", "tussis", "plores"], "e": "Esternudar."},
      {"q": "Quina malaltia de l'hivern dona febre i mal de cos?", "o": ["la grip", "el mal de queixal", "la ferida"], "e": "La grip."},
      {"q": "A la primavera em ploren els ulls i esternude per les flors: tinc...", "o": ["al·lèrgia", "grip", "fam"], "e": "Al·lèrgia."},
      {"q": "M'he caigut i no puc moure el braç: potser el tinc...", "o": ["trencat", "refredat", "cansat"], "e": "Trencat."},
      {"q": "Quan et talles, ix...", "o": ["sang", "suor", "llàgrimes"], "e": "Sang."},
      {"q": "Si prens massa sol, et pots...", "o": ["cremar", "refredar", "trencar"], "e": "Cremar-se amb el sol."},
      {"q": "No he dormit bé i estic molt...", "o": ["cansat", "refredat", "afamat"], "e": "Cansat."},
      {"q": "Qui ens visita quan estem malalts?", "o": ["el metge", "el mecànic", "el cambrer"], "e": "El metge (o la metgessa)."},
      {"q": "El metge de les dents és...", "o": ["el dentista", "l'oculista", "el pediatre"], "e": "El dentista."},
      {"q": "El metge dels xiquets és...", "o": ["el pediatre", "el dentista", "l'oculista"], "e": "El pediatre."},
      {"q": "El metge dels ulls és...", "o": ["l'oculista", "el dentista", "el pediatre"], "e": "L'oculista."},
      {"q": "Per a anar al metge, primer has de demanar...", "o": ["cita", "recepta", "factura"], "e": "Demanar cita."},
      {"q": "El lloc de salut del barri, més xicotet que l'hospital, és...", "o": ["el centre de salut", "la farmàcia", "l'ajuntament"], "e": "El centre de salut."},
      {"q": "El paper on el metge escriu els medicaments és...", "o": ["la recepta", "la factura", "la carta"], "e": "La recepta."},
      {"q": "On comprem els medicaments?", "o": ["a la farmàcia", "al forn", "a la carnisseria"], "e": "A la farmàcia."},
      {"q": "Un medicament xicotet que empassem amb aigua és...", "o": ["una pastilla", "una xeringa", "una tireta"], "e": "Una pastilla."},
      {"q": "Un medicament líquid i dolç per a la tos és...", "o": ["un xarop", "una bena", "una tireta"], "e": "Un xarop."},
      {"q": "Una crema que ens posem damunt de la pell és...", "o": ["una pomada", "una pastilla", "un xarop"], "e": "Una pomada."},
      {"q": "Amb què tapem una ferida xicoteta?", "o": ["amb una tireta", "amb una xeringa", "amb un termòmetre"], "e": "Amb una tireta."},
      {"q": "Amb què emboliquem un turmell torçat?", "o": ["amb una bena", "amb una tireta", "amb una pastilla"], "e": "Amb una bena."},
      {"q": "Amb què mirem si tenim febre?", "o": ["amb el termòmetre", "amb el rellotge", "amb el telèfon"], "e": "Amb el termòmetre."},
      {"q": "Amb què es posa una injecció?", "o": ["amb una xeringa", "amb una tireta", "amb una bena"], "e": "Amb una xeringa."},
      {"q": "Si és molt greu, has d'anar a...", "o": ["urgències", "la perruqueria", "el gimnàs"], "e": "A urgències de l'hospital."},
      {"q": "Quin vehicle porta els malalts a l'hospital?", "o": ["l'ambulància", "el taxi", "el tramvia"], "e": "L'ambulància."},
      {"q": "Una persona malalta que atén el metge és...", "o": ["un pacient", "un client", "un alumne"], "e": "Un pacient."},
      {"q": "Quan estàs malalt, el metge et diu que has de fer...", "o": ["repòs", "esport", "festa"], "e": "Fer repòs: descansar."},
      {"q": "Quan una persona malalta es posa bé, es...", "o": ["cura", "trenca", "refreda"], "e": "Curar-se."},
      {"q": "Què li dius a una persona que està malalta?", "o": ["Que et millores!", "Bon profit!", "Per molts anys!"], "e": "Que et millores!"},
      {"q": "Escriu on comprem els medicaments.", "a": ["farmàcia", "la farmàcia", "a la farmàcia"], "e": "A la farmàcia."},
      {"q": "Escriu la paraula: tinc la temperatura molt alta, tinc ___.", "a": ["febre"], "e": "Febre."},
      {"q": "Escriu el nom de la persona que ens cura quan estem malalts.", "a": ["metge", "metgessa", "el metge", "la metgessa"], "e": "El metge o la metgessa."}
    ]
  },
  {
    "id": "a3a75594-576c-4088-9f19-68b24435470e", "type": "vocab_adjectius", "sort_order": 8,
    "title": "Com és? Adjectius", "name": "Adjectius referits a persones i coses",
    "content": "Adjectius per a descriure l'aspecte i el caràcter de les persones i les coses.", "icon": "🎭", "color": "#D7CCC8",
    "exercises": [
      {"q": "Una persona que pesa molt és...", "o": ["grossa", "prima", "baixa"], "e": "Grossa."},
      {"q": "Quin és el contrari de «gros»?", "o": ["prim", "alt", "lleig"], "e": "Gros ↔ prim."},
      {"q": "Quin és el contrari de «guapo»?", "o": ["lleig", "prim", "ros"], "e": "Guapo ↔ lleig."},
      {"q": "Una persona amb els cabells de color groc és...", "o": ["rossa", "morena", "pèl-roja"], "e": "Rossa."},
      {"q": "Una persona amb els cabells rojos és...", "o": ["pèl-roja", "rossa", "morena"], "e": "Pèl-roja."},
      {"q": "Una persona que no té cabells és...", "o": ["calba", "rossa", "arrissada"], "e": "Calba."},
      {"q": "Els cabells que no són llisos són...", "o": ["arrissats", "llargs", "curts"], "e": "Arrissats ↔ llisos."},
      {"q": "Una persona de noranta anys és una persona...", "o": ["gran", "jove", "xicoteta"], "e": "Una persona gran (o major)."},
      {"q": "Una persona de díhuit anys és...", "o": ["jove", "gran", "vella"], "e": "Jove."},
      {"q": "Una persona que sempre riu i està contenta és...", "o": ["alegre", "trista", "avorrida"], "e": "Alegre."},
      {"q": "Quin és el contrari de «simpàtic»?", "o": ["antipàtic", "alegre", "treballador"], "e": "Simpàtic ↔ antipàtic."},
      {"q": "Una persona que no vol treballar és...", "o": ["gandula", "treballadora", "generosa"], "e": "Gandula ↔ treballadora."},
      {"q": "Una persona que compartix les seues coses és...", "o": ["generosa", "egoista", "tímida"], "e": "Generosa."},
      {"q": "Una persona que només pensa en ella mateixa és...", "o": ["egoista", "generosa", "amable"], "e": "Egoista."},
      {"q": "Una persona a qui li costa parlar amb gent nova és...", "o": ["tímida", "xarraire", "simpàtica"], "e": "Tímida."},
      {"q": "Una persona que sempre diu la veritat és...", "o": ["sincera", "mentidera", "tímida"], "e": "Sincera ↔ mentidera."},
      {"q": "Una persona que aprén ràpid i sap moltes coses és...", "o": ["llesta", "tonta", "gandula"], "e": "Llesta (o intel·ligent)."},
      {"q": "Una persona que tracta bé els altres és...", "o": ["amable", "maleducada", "egoista"], "e": "Amable."},
      {"q": "Quin és el contrari de «nerviós»?", "o": ["tranquil", "content", "trist"], "e": "Nerviós ↔ tranquil."},
      {"q": "Quin és el contrari de «content»?", "o": ["trist", "alegre", "feliç"], "e": "Content ↔ trist."},
      {"q": "Una persona que té molts diners és...", "o": ["rica", "pobra", "cara"], "e": "Rica ↔ pobra."},
      {"q": "Quin és el contrari de «car»?", "o": ["barat", "nou", "gran"], "e": "Car ↔ barat."},
      {"q": "Quin és el contrari de «nou»?", "o": ["vell", "xicotet", "barat"], "e": "Nou ↔ vell."},
      {"q": "Quin és el contrari de «llarg»?", "o": ["curt", "ample", "estret"], "e": "Llarg ↔ curt."},
      {"q": "Quin és el contrari de «ample»?", "o": ["estret", "llarg", "alt"], "e": "Ample ↔ estret."},
      {"q": "Quin és el contrari de «pesat»?", "o": ["lleuger", "dur", "fort"], "e": "Pesat ↔ lleuger."},
      {"q": "Quin és el contrari de «dur»?", "o": ["tou", "fort", "gros"], "e": "Dur ↔ tou."},
      {"q": "Quin és el contrari de «calent»?", "o": ["fred", "sec", "dolç"], "e": "Calent ↔ fred."},
      {"q": "Quin és el contrari de «net»?", "o": ["brut", "fosc", "buit"], "e": "Net ↔ brut."},
      {"q": "Quin és el contrari de «ple»?", "o": ["buit", "brut", "dur"], "e": "Ple ↔ buit."},
      {"q": "Quin és el contrari de «fàcil»?", "o": ["difícil", "ràpid", "lent"], "e": "Fàcil ↔ difícil."},
      {"q": "Quin és el contrari de «ràpid»?", "o": ["lent", "curt", "difícil"], "e": "Ràpid ↔ lent."},
      {"q": "Quin és el contrari de «clar»?", "o": ["fosc", "brut", "ple"], "e": "Clar ↔ fosc."},
      {"q": "Quin és el contrari de «mullat»?", "o": ["sec", "fred", "net"], "e": "Mullat ↔ sec."},
      {"q": "Com és el sucre?", "o": ["dolç", "salat", "àcid"], "e": "Dolç."},
      {"q": "Com és la llima?", "o": ["àcida", "dolça", "salada"], "e": "Àcida."},
      {"q": "Com és l'aigua de la mar?", "o": ["salada", "dolça", "amarga"], "e": "Salada."},
      {"q": "Una cosa que costa molts diners és...", "o": ["cara", "barata", "gratuïta"], "e": "Cara."},
      {"q": "Una cosa que no costa diners és...", "o": ["gratuïta", "cara", "barata"], "e": "Gratuïta."},
      {"q": "Un carrer on hi ha molt de soroll és...", "o": ["sorollós", "silenciós", "tranquil"], "e": "Sorollós ↔ silenciós."},
      {"q": "Una pel·lícula que no t'interessa gens i et fa dormir és...", "o": ["avorrida", "divertida", "interessant"], "e": "Avorrida."},
      {"q": "Una pel·lícula que et fa riure és...", "o": ["divertida", "avorrida", "trista"], "e": "Divertida."},
      {"q": "Un paisatge molt bonic és...", "o": ["preciós", "lleig", "brut"], "e": "Preciós."},
      {"q": "Quin és el femení de «trist»?", "o": ["trista", "tristesa", "triste"], "e": "Trist → trista."},
      {"q": "Quin és el femení de «simpàtic»?", "o": ["simpàtica", "simpàtiqua", "simpàtic"], "e": "Simpàtic → simpàtica."},
      {"q": "Quin és el femení de «amable»?", "o": ["amable", "amabla", "amablessa"], "e": "Amable és invariable."},
      {"q": "Escriu el contrari de «gran».", "a": ["xicotet", "menut", "petit"], "e": "Xicotet (o menut, petit)."},
      {"q": "Escriu el contrari de «bo».", "a": ["dolent"], "e": "Bo ↔ dolent."},
      {"q": "Escriu el contrari de «obert».", "a": ["tancat"], "e": "Obert ↔ tancat."},
      {"q": "Escriu el contrari de «alegre».", "a": ["trist"], "e": "Alegre ↔ trist."}
    ]
  }
]$data$::jsonb) AS t(
  id uuid, type text, sort_order smallint, title text, name text,
  content text, icon text, color text, exercises jsonb
);

INSERT INTO public.resources (id, name, type, category, content, difficulty, xp_earned, sort_order, metadata)
SELECT id, name, type, 'lexic_semantica', content, 'principiant', 10, sort_order,
       jsonb_build_object('icon', icon, 'color', color, 'section_name', title)
FROM practice_catalog
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  type = EXCLUDED.type,
  category = EXCLUDED.category,
  content = EXCLUDED.content,
  sort_order = EXCLUDED.sort_order,
  metadata = EXCLUDED.metadata;

-- Formació de paraules i Sinònims, antònims i cortesia, darrere del vocabulari.
UPDATE public.resources SET sort_order = 9 WHERE id = '2d99f341-c91b-4c70-9d21-75a239956f97';
UPDATE public.resources SET sort_order = 10 WHERE id = 'e1165f90-cd1d-4006-84f3-75bda93d947e';

DELETE FROM public.practice_exercises e
USING practice_catalog c
WHERE e.resource_id = c.id AND e.level = 'A2';

INSERT INTO public.practice_exercises (resource_id, level, position, kind, prompt, options, answers, explanation)
SELECT c.id, 'A2', x.ord,
       CASE WHEN x.e ? 'a' THEN 'fill' ELSE 'choice' END,
       x.e->>'q',
       CASE WHEN x.e ? 'o' THEN ARRAY(SELECT jsonb_array_elements_text(x.e->'o')) END,
       CASE WHEN x.e ? 'a' THEN ARRAY(SELECT jsonb_array_elements_text(x.e->'a')) ELSE ARRAY[x.e->'o'->>0] END,
       x.e->>'e'
FROM practice_catalog c
CROSS JOIN LATERAL jsonb_array_elements(c.exercises) WITH ORDINALITY AS x(e, ord);

DROP TABLE practice_catalog;

-- ============================================================
-- Origen: 20260930160000_practice_lexic_more.sql
-- ============================================================
-- Més exercicis A2 per a Formació de paraules i Sinònims, antònims i cortesia
-- (4.3 Lèxic i semàntica; 20260930110000 en tenia 11 per contingut): s'afigen
-- darrere dels que ja hi ha, a partir de la posició `offset`, fins a 35 per
-- contingut. Tornar a aplicar el fitxer no els duplica.

CREATE TEMP TABLE practice_more AS
SELECT * FROM jsonb_to_recordset($data$[
  {
    "id": "2d99f341-c91b-4c70-9d21-75a239956f97", "offset": 11,
    "exercises": [
      {"q": "Qui fa i arregla sabates?", "o": ["el sabater", "el sabatista", "el sabador"], "e": "Sabata + -er: sabater."},
      {"q": "Qui ven fruita?", "o": ["el fruiter", "el fruitista", "el fruitador"], "e": "Fruita + -er: fruiter."},
      {"q": "Qui cuida els jardins?", "o": ["el jardiner", "el jardinista", "el jardinaire"], "e": "Jardí + -er: jardiner."},
      {"q": "Qui toca el piano?", "o": ["el pianista", "el pianer", "el pianador"], "e": "Piano + -ista: pianista."},
      {"q": "Qui cura les dents?", "o": ["el dentista", "el denter", "el dentador"], "e": "Dent + -ista: dentista."},
      {"q": "Qui condueix un taxi?", "o": ["el taxista", "el taxer", "el taxador"], "e": "Taxi + -ista: taxista."},
      {"q": "Quin és el femení de «periodista»?", "o": ["periodista", "periodistessa", "periodistera"], "e": "El sufix -ista és invariable: el periodista, la periodista."},
      {"q": "Qui juga en un equip de futbol?", "o": ["el jugador", "el juguer", "el jugaire"], "e": "Jugar + -dor: jugador."},
      {"q": "Qui treballa en una fàbrica o en una empresa?", "o": ["el treballador", "el treballer", "el treballista"], "e": "Treballar + -dor: treballador."},
      {"q": "Com es diu una persona que canta cançons populars per afició?", "o": ["cantaire", "cantista", "canter"], "e": "Cantar + -aire: cantaire."},
      {"q": "Com es diu una persona que balla danses populars?", "o": ["dansaire", "dansista", "danser"], "e": "Dansar + -aire: dansaire."},
      {"q": "Un home de València és...", "o": ["valencià", "valencier", "valencés"], "e": "València → valencià, valenciana (-à/-ana)."},
      {"q": "Una dona de Menorca és...", "o": ["menorquina", "menorquesa", "menorquenca"], "e": "Menorca → menorquí, menorquina (-í/-ina)."},
      {"q": "Una dona de Castelló és...", "o": ["castellonenca", "castellonina", "castellonesa"], "e": "Castelló → castellonenc, castellonenca (-enc/-enca)."},
      {"q": "Un home de Barcelona és...", "o": ["barceloní", "barcelonés", "barcelonenc"], "e": "Barcelona → barceloní, barcelonina (-í/-ina)."},
      {"q": "Un home d'Alcoi és...", "o": ["alcoià", "alcoiés", "alcoienc"], "e": "Alcoi → alcoià, alcoiana (-à/-ana)."},
      {"q": "Una dona d'Holanda és...", "o": ["holandesa", "holandina", "holandenca"], "e": "Holanda → holandés, holandesa (-és/-esa)."},
      {"q": "On posem el sucre a la taula?", "o": ["al sucrer", "a la sucrista", "al sucraire"], "e": "Sucre + -er: sucrer."},
      {"q": "On posem el pa a la taula?", "o": ["a la panera", "al panista", "al panaire"], "e": "Pa + -era: panera."},
      {"q": "On guardem els ous a la nevera?", "o": ["a l'ouera", "a l'ouista", "a l'ouaire"], "e": "Ou + -era: ouera."},
      {"q": "Amb quin aparell fem el café?", "o": ["amb la cafetera", "amb el cafetista", "amb el cafetaire"], "e": "Café + -era: cafetera."},
      {"q": "L'arbre que fa pomes és...", "o": ["la pomera", "el pomista", "el pomaire"], "e": "Poma + -era: pomera."},
      {"q": "L'arbre que fa figues és...", "o": ["la figuera", "el figuista", "el figaire"], "e": "Figa + -era: figuera."},
      {"q": "Escriu el nom de l'arbre que fa peres.", "a": ["perera", "la perera"], "e": "Pera + -era: perera."}
    ]
  },
  {
    "id": "e1165f90-cd1d-4006-84f3-75bda93d947e", "offset": 11,
    "exercises": [
      {"q": "Quin és un sinònim de «començar»?", "o": ["iniciar", "acabar", "parar"], "e": "Començar i iniciar volen dir el mateix."},
      {"q": "Quin és un sinònim de «feliç»?", "o": ["content", "trist", "cansat"], "e": "Feliç i content."},
      {"q": "Quin és un sinònim de «ràpid»?", "o": ["veloç", "lent", "tranquil"], "e": "Ràpid i veloç."},
      {"q": "Quin és un sinònim de «casa»?", "o": ["vivenda", "carrer", "poble"], "e": "Casa i vivenda."},
      {"q": "Quin és un sinònim de «alumne»?", "o": ["estudiant", "mestre", "director"], "e": "Alumne i estudiant."},
      {"q": "Quin és un sinònim de «roig»?", "o": ["vermell", "blau", "morat"], "e": "Roig i vermell són el mateix color."},
      {"q": "Quin és el contrari de «entrar»?", "o": ["eixir", "pujar", "obrir"], "e": "Entrar ↔ eixir."},
      {"q": "Quin és el contrari de «pujar»?", "o": ["baixar", "eixir", "entrar"], "e": "Pujar ↔ baixar."},
      {"q": "Quin és el contrari de «comprar»?", "o": ["vendre", "pagar", "gastar"], "e": "Comprar ↔ vendre."},
      {"q": "Quin és el contrari de «encendre» la llum?", "o": ["apagar", "tancar", "obrir"], "e": "Encendre ↔ apagar."},
      {"q": "Quin és el contrari de «guanyar»?", "o": ["perdre", "jugar", "trobar"], "e": "Guanyar ↔ perdre."},
      {"q": "Quin és el contrari de «recordar»?", "o": ["oblidar", "pensar", "saber"], "e": "Recordar ↔ oblidar."},
      {"q": "Gos, gat i conill són...", "o": ["animals", "plantes", "fruites"], "e": "Animal és la paraula general (hiperònim)."},
      {"q": "Taula, cadira i armari són...", "o": ["mobles", "electrodomèstics", "eines"], "e": "Moble és la paraula general."},
      {"q": "Futbol, tenis i natació són...", "o": ["esports", "jocs de taula", "instruments"], "e": "Esport és la paraula general."},
      {"q": "Quina paraula inclou les altres dues?", "o": ["roba", "camisa", "pantalons"], "e": "La camisa i els pantalons són roba: roba és l'hiperònim."},
      {"q": "Com demanes una cosa amb educació?", "o": ["Em dones un got d'aigua, per favor?", "Dona'm aigua ja!", "Aigua!"], "e": "Per favor fa la petició més cortés."},
      {"q": "Com saludes a les cinc de la vesprada?", "o": ["Bona vesprada!", "Bon dia!", "Bon profit!"], "e": "Bon dia pel matí, bona vesprada per la vesprada i bona nit per la nit."},
      {"q": "Què respons quan algú et diu «Moltes gràcies»?", "o": ["De res.", "Perdó.", "Salut!"], "e": "De res (o No es mereixen)."},
      {"q": "Què dius a algú que ha aprovat un examen?", "o": ["Enhorabona!", "Perdona!", "Bon profit!"], "e": "Enhorabona: per a felicitar."},
      {"q": "Què dius a algú que se'n va de viatge?", "o": ["Bon viatge!", "Enhorabona!", "Per molts anys!"], "e": "Bon viatge!"},
      {"q": "Què dius quan coneixes una persona per primera vegada?", "o": ["Encantat de conéixer-te.", "Bon profit.", "Fins demà."], "e": "Encantat (o Molt de gust)."},
      {"q": "Com preguntes a un senyor gran que no coneixes com està?", "o": ["Com està vosté?", "Què passa, tio?", "Com va, xiquet?"], "e": "Amb persones que no coneixem o grans, el tractament de respecte: vosté."},
      {"q": "Què respons quan algú et pregunta «Com estàs?»", "o": ["Molt bé, gràcies. I tu?", "De res.", "Bon profit."], "e": "Molt bé, gràcies. I tu?"}
    ]
  }
]$data$::jsonb) AS t(id uuid, "offset" smallint, exercises jsonb);

DELETE FROM public.practice_exercises e
USING practice_more m
WHERE e.resource_id = m.id AND e.level = 'A2' AND e.position > m."offset";

INSERT INTO public.practice_exercises (resource_id, level, position, kind, prompt, options, answers, explanation)
SELECT m.id, 'A2', m."offset" + x.ord,
       CASE WHEN x.e ? 'a' THEN 'fill' ELSE 'choice' END,
       x.e->>'q',
       CASE WHEN x.e ? 'o' THEN ARRAY(SELECT jsonb_array_elements_text(x.e->'o')) END,
       CASE WHEN x.e ? 'a' THEN ARRAY(SELECT jsonb_array_elements_text(x.e->'a')) ELSE ARRAY[x.e->'o'->>0] END,
       x.e->>'e'
FROM practice_more m
CROSS JOIN LATERAL jsonb_array_elements(m.exercises) WITH ORDINALITY AS x(e, ord);

DROP TABLE practice_more;

