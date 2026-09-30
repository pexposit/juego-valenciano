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
