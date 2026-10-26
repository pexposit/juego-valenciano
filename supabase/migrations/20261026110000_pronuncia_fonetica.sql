-- Més exercicis de pronúncia («Llig en veu alta») en els continguts de fonètica que tenen sons que l'API fonètica
-- distingix bé (vegeu backend/src/services/pronunciation.ts): les palatals, la ll (només la confusió amb la l: la
-- i del ieisme no la distingix) i la r forta. Les alveolars (s/z, x) i la ny no s'hi han posat: en les proves la
-- sonoritat de la s i la ny final donaven falsos errors. Totes les frases s'han provat amb la veu gina llegint bé
-- (cap fals error) i amb les faltes d'un hispanoparlant (es marquen). Per contingut: b1_fon_palatals 5, b2_fon_palatals 5, c1_fon_palatals 5, rotiques 5, c1_fon_rotiques_h 5, laterals 5, c1_fon_laterals_nasals 5, b1_fon_laterals_h 5, b2_fon_laterals_h 5, b1_fon_elocucio 5, b2_fon_elocucio 5, c1_fon_elocucio 5.
-- Les frases van repartides entre les preguntes escrites, no al final. Tornar a aplicar el fitxer no duplica res
-- ni canvia l'ordre.

CREATE TEMP TABLE pronunciation_catalog AS
SELECT * FROM jsonb_to_recordset($data$[
 {
  "resource_id": "ce18cc3f-74e3-44b7-9613-2853cb3b3290",
  "level": "B1",
  "n": 1,
  "prompt": "Llig la frase en veu alta i fixa't en els sons palatals.",
  "text": "Els viatges a la platja de Gandia són llargs però divertits.",
  "sounds": [
   "ʃ",
   "ʒ",
   "tʃ",
   "dʒ"
  ],
  "explanation": "La tg de «viatges» i la tj de «platja» sonen com la j de «jove»."
 },
 {
  "resource_id": "ce18cc3f-74e3-44b7-9613-2853cb3b3290",
  "level": "B1",
  "n": 2,
  "prompt": "Llig la frase en veu alta i fixa't en els sons palatals.",
  "text": "El metge em va dir que menjara més fruita i verdura.",
  "sounds": [
   "ʃ",
   "ʒ",
   "tʃ",
   "dʒ"
  ],
  "explanation": "La tg de «metge» i la j de «menjara» són palatals sonores, com en «platja»."
 },
 {
  "resource_id": "ce18cc3f-74e3-44b7-9613-2853cb3b3290",
  "level": "B1",
  "n": 3,
  "prompt": "Llig la frase en veu alta i fixa't en els sons palatals.",
  "text": "Al migdia passegem pel passeig amb el xiquet.",
  "sounds": [
   "ʃ",
   "ʒ",
   "tʃ",
   "dʒ"
  ],
  "explanation": "La g de «migdia» i «passegem», la ig de «passeig» i la x de «xiquet» són palatals."
 },
 {
  "resource_id": "ce18cc3f-74e3-44b7-9613-2853cb3b3290",
  "level": "B1",
  "n": 4,
  "prompt": "Llig la frase en veu alta i fixa't en els sons palatals.",
  "text": "La caixa de dibuixos està dins del calaix.",
  "sounds": [
   "ʃ",
   "ʒ",
   "tʃ",
   "dʒ"
  ],
  "explanation": "La ix de «caixa», «dibuixos» i «calaix» sona com en «peix», no com una s."
 },
 {
  "resource_id": "ce18cc3f-74e3-44b7-9613-2853cb3b3290",
  "level": "B1",
  "n": 5,
  "prompt": "Llig la frase en veu alta i fixa't en els sons palatals.",
  "text": "Desitge que el mes de juny siga més tranquil.",
  "sounds": [
   "ʃ",
   "ʒ",
   "tʃ",
   "dʒ"
  ],
  "explanation": "La tg de «desitge» i la j de «juny» sonen com en «platja»."
 },
 {
  "resource_id": "53f521aa-eeea-5579-ad61-75e6c876df19",
  "level": "B2",
  "n": 1,
  "prompt": "Llig la frase en veu alta i fixa't en els sons palatals.",
  "text": "La jaqueta roja i els pantalons rojos són del meu germà.",
  "sounds": [
   "ʃ",
   "ʒ",
   "tʃ",
   "dʒ"
  ],
  "explanation": "La j de «jaqueta», «roja» i «rojos» i la g de «germà» sonen com en «platja»."
 },
 {
  "resource_id": "53f521aa-eeea-5579-ad61-75e6c876df19",
  "level": "B2",
  "n": 2,
  "prompt": "Llig la frase en veu alta i fixa't en els sons palatals.",
  "text": "Les platges de Xàbia són més boniques que les del nord.",
  "sounds": [
   "ʃ",
   "ʒ",
   "tʃ",
   "dʒ"
  ],
  "explanation": "La tg de «platges» i la X de «Xàbia» són palatals."
 },
 {
  "resource_id": "53f521aa-eeea-5579-ad61-75e6c876df19",
  "level": "B2",
  "n": 3,
  "prompt": "Llig la frase en veu alta i fixa't en els sons palatals.",
  "text": "El director despatxa els assumptes urgents al seu despatx.",
  "sounds": [
   "ʃ",
   "ʒ",
   "tʃ",
   "dʒ"
  ],
  "explanation": "La tx de «despatx» i «despatxa» sona com en «cotxe»; la g d'«urgents», com en «gent»."
 },
 {
  "resource_id": "53f521aa-eeea-5579-ad61-75e6c876df19",
  "level": "B2",
  "n": 4,
  "prompt": "Llig la frase en veu alta i fixa't en els sons palatals.",
  "text": "A mitja vesprada fem un mig entrepà de formatge.",
  "sounds": [
   "ʃ",
   "ʒ",
   "tʃ",
   "dʒ"
  ],
  "explanation": "La tj de «mitja», la g de «mig» i la tg de «formatge» són palatals."
 },
 {
  "resource_id": "53f521aa-eeea-5579-ad61-75e6c876df19",
  "level": "B2",
  "n": 5,
  "prompt": "Llig la frase en veu alta i fixa't en els sons palatals.",
  "text": "Aquell edifici lleig té una façana encara més lletja.",
  "sounds": [
   "ʃ",
   "ʒ",
   "tʃ",
   "dʒ"
  ],
  "explanation": "La ig de «lleig» sona com la tx de «cotxe» i la tj de «lletja», com en «platja»."
 },
 {
  "resource_id": "edf7dc63-a228-586e-b90f-c2ce2c5a95b1",
  "level": "C1",
  "n": 1,
  "prompt": "Llig la frase en veu alta i fixa't en els sons palatals.",
  "text": "Ens vam hostatjar en un alberg al costat de la platja.",
  "sounds": [
   "ʃ",
   "ʒ",
   "tʃ",
   "dʒ"
  ],
  "explanation": "La tj d'«hostatjar» i de «platja» sona com la j de «jove»."
 },
 {
  "resource_id": "edf7dc63-a228-586e-b90f-c2ce2c5a95b1",
  "level": "C1",
  "n": 2,
  "prompt": "Llig la frase en veu alta i fixa't en els sons palatals.",
  "text": "Quan viatge en vaixell em marege amb facilitat.",
  "sounds": [
   "ʃ",
   "ʒ",
   "tʃ",
   "dʒ"
  ],
  "explanation": "La tg de «viatge», la ix de «vaixell» i la g de «marege» són palatals."
 },
 {
  "resource_id": "edf7dc63-a228-586e-b90f-c2ce2c5a95b1",
  "level": "C1",
  "n": 3,
  "prompt": "Llig la frase en veu alta i fixa't en els sons palatals.",
  "text": "La infermera li va posar una injecció al braç.",
  "sounds": [
   "ʃ",
   "ʒ",
   "tʃ",
   "dʒ"
  ],
  "explanation": "La j d'«injecció» és una palatal sonora, com en «platja»."
 },
 {
  "resource_id": "edf7dc63-a228-586e-b90f-c2ce2c5a95b1",
  "level": "C1",
  "n": 4,
  "prompt": "Llig la frase en veu alta i fixa't en els sons palatals.",
  "text": "Els jeroglífics egipcis encara desperten un gran interés.",
  "sounds": [
   "ʃ",
   "ʒ",
   "tʃ",
   "dʒ"
  ],
  "explanation": "La j de «jeroglífics» i la g d'«egipcis» sonen com en «gent»."
 },
 {
  "resource_id": "edf7dc63-a228-586e-b90f-c2ce2c5a95b1",
  "level": "C1",
  "n": 5,
  "prompt": "Llig la frase en veu alta i fixa't en els sons palatals.",
  "text": "El jutge va jutjar el cas amb molta justícia.",
  "sounds": [
   "ʃ",
   "ʒ",
   "tʃ",
   "dʒ"
  ],
  "explanation": "La tg de «jutge», la tj de «jutjar» i la j de «justícia» són palatals."
 },
 {
  "resource_id": "4a7ebcc7-0141-4e17-bae8-6386275e31dd",
  "level": "A2",
  "n": 1,
  "prompt": "Llig la frase en veu alta i fixa't en la r forta.",
  "text": "El ratolí corre pel carrer.",
  "sounds": [
   "r"
  ],
  "explanation": "La r a principi de paraula i la rr entre vocals sonen fortes, vibrant."
 },
 {
  "resource_id": "4a7ebcc7-0141-4e17-bae8-6386275e31dd",
  "level": "A2",
  "n": 2,
  "prompt": "Llig la frase en veu alta i fixa't en la r forta.",
  "text": "Ramon regala roses a la seua germana.",
  "sounds": [
   "r"
  ],
  "explanation": "La r a principi de paraula sempre és forta: «Ramon», «regala», «roses»."
 },
 {
  "resource_id": "4a7ebcc7-0141-4e17-bae8-6386275e31dd",
  "level": "A2",
  "n": 3,
  "prompt": "Llig la frase en veu alta i fixa't en la r forta.",
  "text": "La guitarra de Roc sona molt bé.",
  "sounds": [
   "r"
  ],
  "explanation": "La rr de «guitarra» i la r inicial de «Roc» són fortes."
 },
 {
  "resource_id": "4a7ebcc7-0141-4e17-bae8-6386275e31dd",
  "level": "A2",
  "n": 4,
  "prompt": "Llig la frase en veu alta i fixa't en la r forta.",
  "text": "Hi ha un gerro de terra damunt de la taula.",
  "sounds": [
   "r"
  ],
  "explanation": "«Gerro» i «terra» porten rr: la r sona forta."
 },
 {
  "resource_id": "4a7ebcc7-0141-4e17-bae8-6386275e31dd",
  "level": "A2",
  "n": 5,
  "prompt": "Llig la frase en veu alta i fixa't en la r forta.",
  "text": "El carro roig corre per la carretera.",
  "sounds": [
   "r"
  ],
  "explanation": "La rr entre vocals i la r inicial sonen fortes: «carro», «roig», «corre», «carretera»."
 },
 {
  "resource_id": "d94b8164-595d-5ef6-b396-3b675874896c",
  "level": "C1",
  "n": 1,
  "prompt": "Llig la frase en veu alta i fixa't en la r forta.",
  "text": "El ferrocarril recorre tota la regió.",
  "sounds": [
   "r"
  ],
  "explanation": "La rr de «ferrocarril» i «recorre» i la r inicial de «regió» són fortes."
 },
 {
  "resource_id": "d94b8164-595d-5ef6-b396-3b675874896c",
  "level": "C1",
  "n": 2,
  "prompt": "Llig la frase en veu alta i fixa't en la r forta.",
  "text": "L'arròs al forn requerix una cocció lenta.",
  "sounds": [
   "r"
  ],
  "explanation": "La rr d'«arròs» i la r inicial de «requerix» són fortes."
 },
 {
  "resource_id": "d94b8164-595d-5ef6-b396-3b675874896c",
  "level": "C1",
  "n": 3,
  "prompt": "Llig la frase en veu alta i fixa't en la r forta.",
  "text": "Les errades ortogràfiques resten punts en la redacció.",
  "sounds": [
   "r"
  ],
  "explanation": "La rr d'«errades» i la r inicial de «resten» i «redacció» són fortes."
 },
 {
  "resource_id": "d94b8164-595d-5ef6-b396-3b675874896c",
  "level": "C1",
  "n": 4,
  "prompt": "Llig la frase en veu alta i fixa't en la r forta.",
  "text": "El riu Xúquer rega les terres de la Ribera.",
  "sounds": [
   "r"
  ],
  "explanation": "La r inicial de «riu», «rega» i «Ribera» i la rr de «terres» són fortes."
 },
 {
  "resource_id": "d94b8164-595d-5ef6-b396-3b675874896c",
  "level": "C1",
  "n": 5,
  "prompt": "Llig la frase en veu alta i fixa't en la r forta.",
  "text": "Va córrer tan ràpid que arribà el primer.",
  "sounds": [
   "r"
  ],
  "explanation": "La rr de «córrer» i «arribà» i la r inicial de «ràpid» són fortes."
 },
 {
  "resource_id": "77e69eed-4550-4420-a66e-1f226c99a989",
  "level": "A2",
  "n": 1,
  "prompt": "Llig la frase en veu alta i fixa't en la ll.",
  "text": "La lluna plena il·lumina la platja.",
  "sounds": [
   "ʎ"
  ],
  "explanation": "La ll de «lluna» és un so propi, diferent de la l de «luna»."
 },
 {
  "resource_id": "77e69eed-4550-4420-a66e-1f226c99a989",
  "level": "A2",
  "n": 2,
  "prompt": "Llig la frase en veu alta i fixa't en la ll.",
  "text": "El meu fill porta una ovella a la falla.",
  "sounds": [
   "ʎ"
  ],
  "explanation": "La ll de «fill», «ovella» i «falla» no sona com una l."
 },
 {
  "resource_id": "77e69eed-4550-4420-a66e-1f226c99a989",
  "level": "A2",
  "n": 3,
  "prompt": "Llig la frase en veu alta i fixa't en la ll.",
  "text": "Bevem llet calenta abans d'anar a l'escola.",
  "sounds": [
   "ʎ"
  ],
  "explanation": "La ll de «llet» és palatal: la llengua toca el paladar."
 },
 {
  "resource_id": "77e69eed-4550-4420-a66e-1f226c99a989",
  "level": "A2",
  "n": 4,
  "prompt": "Llig la frase en veu alta i fixa't en la ll.",
  "text": "La paella de la meua iaia és boníssima.",
  "sounds": [
   "ʎ"
  ],
  "explanation": "La ll de «paella» no és una l ni una i: és el so de «lluna»."
 },
 {
  "resource_id": "77e69eed-4550-4420-a66e-1f226c99a989",
  "level": "A2",
  "n": 5,
  "prompt": "Llig la frase en veu alta i fixa't en la ll.",
  "text": "Llegim un llibre al costat de la finestra.",
  "sounds": [
   "ʎ"
  ],
  "explanation": "La ll de «llegim» i «llibre» és el so propi de «lluna»."
 },
 {
  "resource_id": "374de871-c607-51fb-b2d3-d29324c25a93",
  "level": "C1",
  "n": 1,
  "prompt": "Llig la frase en veu alta i fixa't en la ll.",
  "text": "La col·lecció de segells del meu avi és molt valuosa.",
  "sounds": [
   "ʎ"
  ],
  "explanation": "La ll de «segells» és palatal; la l·l de «col·lecció» és una l doble."
 },
 {
  "resource_id": "374de871-c607-51fb-b2d3-d29324c25a93",
  "level": "C1",
  "n": 2,
  "prompt": "Llig la frase en veu alta i fixa't en la ll.",
  "text": "L'ull dret em llagrimeja des d'ahir.",
  "sounds": [
   "ʎ"
  ],
  "explanation": "La ll d'«ull» i «llagrimeja» és palatal, com en «lluna»."
 },
 {
  "resource_id": "374de871-c607-51fb-b2d3-d29324c25a93",
  "level": "C1",
  "n": 3,
  "prompt": "Llig la frase en veu alta i fixa't en la ll.",
  "text": "Llancem una mirada lleugerament crítica al llibre.",
  "sounds": [
   "ʎ"
  ],
  "explanation": "La ll de «llancem», «lleugerament» i «llibre» és palatal."
 },
 {
  "resource_id": "374de871-c607-51fb-b2d3-d29324c25a93",
  "level": "C1",
  "n": 4,
  "prompt": "Llig la frase en veu alta i fixa't en la ll.",
  "text": "Els cavallers medievals lluitaven amb espasa.",
  "sounds": [
   "ʎ"
  ],
  "explanation": "La ll de «cavallers» i «lluitaven» és palatal."
 },
 {
  "resource_id": "374de871-c607-51fb-b2d3-d29324c25a93",
  "level": "C1",
  "n": 5,
  "prompt": "Llig la frase en veu alta i fixa't en la ll.",
  "text": "La boira cobria els turons i les collades.",
  "sounds": [
   "ʎ"
  ],
  "explanation": "La ll de «collades» és palatal, no una l."
 },
 {
  "resource_id": "7baaddb7-7eaf-4f14-bfc3-b2e2e1c04964",
  "level": "B1",
  "n": 1,
  "prompt": "Llig la frase en veu alta i fixa't en la ll i en la r forta.",
  "text": "La parella ha llogat un pis al carrer Major.",
  "sounds": [
   [
    "ʎ"
   ],
   [
    "r"
   ]
  ],
  "explanation": "La ll de «parella» i «llogat» és palatal i la rr de «carrer», forta."
 },
 {
  "resource_id": "7baaddb7-7eaf-4f14-bfc3-b2e2e1c04964",
  "level": "B1",
  "n": 2,
  "prompt": "Llig la frase en veu alta i fixa't en la ll i en la r forta.",
  "text": "Les rodes del cotxe vell rodolen per la carretera.",
  "sounds": [
   [
    "ʎ"
   ],
   [
    "r"
   ]
  ],
  "explanation": "La r inicial de «rodes» i «rodolen» i la rr de «carretera» són fortes; la ll de «vell», palatal."
 },
 {
  "resource_id": "7baaddb7-7eaf-4f14-bfc3-b2e2e1c04964",
  "level": "B1",
  "n": 3,
  "prompt": "Llig la frase en veu alta i fixa't en la ll i en la r forta.",
  "text": "En la cuina tallem ceba i all per al sofregit.",
  "sounds": [
   [
    "ʎ"
   ],
   [
    "r"
   ]
  ],
  "explanation": "La ll de «tallem» i «all» és palatal, com en «lluna»."
 },
 {
  "resource_id": "7baaddb7-7eaf-4f14-bfc3-b2e2e1c04964",
  "level": "B1",
  "n": 4,
  "prompt": "Llig la frase en veu alta i fixa't en la ll i en la r forta.",
  "text": "El rellotge de la torre marca les onze.",
  "sounds": [
   [
    "ʎ"
   ],
   [
    "r"
   ]
  ],
  "explanation": "La r inicial de «rellotge» i la rr de «torre» són fortes; la ll, palatal."
 },
 {
  "resource_id": "7baaddb7-7eaf-4f14-bfc3-b2e2e1c04964",
  "level": "B1",
  "n": 5,
  "prompt": "Llig la frase en veu alta i fixa't en la ll i en la r forta.",
  "text": "Ella llig la revista mentre plou.",
  "sounds": [
   [
    "ʎ"
   ],
   [
    "r"
   ]
  ],
  "explanation": "La ll d'«ella» i «llig» és palatal i la r inicial de «revista», forta."
 },
 {
  "resource_id": "bc84c944-a8c7-5bff-a6e2-b72aa9f12e7c",
  "level": "B2",
  "n": 1,
  "prompt": "Llig la frase en veu alta i fixa't en la ll i en la r forta.",
  "text": "La batalla per la llibertat va durar molts anys.",
  "sounds": [
   [
    "ʎ"
   ],
   [
    "r"
   ]
  ],
  "explanation": "La ll de «batalla» i «llibertat» és palatal."
 },
 {
  "resource_id": "bc84c944-a8c7-5bff-a6e2-b72aa9f12e7c",
  "level": "B2",
  "n": 2,
  "prompt": "Llig la frase en veu alta i fixa't en la ll i en la r forta.",
  "text": "El ballarí va rebre un ram de roses.",
  "sounds": [
   [
    "ʎ"
   ],
   [
    "r"
   ]
  ],
  "explanation": "La ll de «ballarí» és palatal i la r inicial de «rebre», «ram» i «roses», forta."
 },
 {
  "resource_id": "bc84c944-a8c7-5bff-a6e2-b72aa9f12e7c",
  "level": "B2",
  "n": 3,
  "prompt": "Llig la frase en veu alta i fixa't en la ll i en la r forta.",
  "text": "Cal rellegir el treball abans del lliurament.",
  "sounds": [
   [
    "ʎ"
   ],
   [
    "r"
   ]
  ],
  "explanation": "La r inicial de «rellegir» és forta; la ll de «treball» i «lliurament», palatal."
 },
 {
  "resource_id": "bc84c944-a8c7-5bff-a6e2-b72aa9f12e7c",
  "level": "B2",
  "n": 4,
  "prompt": "Llig la frase en veu alta i fixa't en la ll i en la r forta.",
  "text": "Les ametles i les avellanes són fruita seca.",
  "sounds": [
   [
    "ʎ"
   ],
   [
    "r"
   ]
  ],
  "explanation": "La ll d'«avellanes» és palatal; la tl d'«ametles» sona com una l doble."
 },
 {
  "resource_id": "bc84c944-a8c7-5bff-a6e2-b72aa9f12e7c",
  "level": "B2",
  "n": 5,
  "prompt": "Llig la frase en veu alta i fixa't en la ll i en la r forta.",
  "text": "El rector de la universitat va rebre els alumnes.",
  "sounds": [
   [
    "ʎ"
   ],
   [
    "r"
   ]
  ],
  "explanation": "La r inicial de «rector» i «rebre» és forta."
 },
 {
  "resource_id": "013139cd-ab6b-45b5-99e7-58104459f974",
  "level": "B1",
  "n": 1,
  "prompt": "Llig la frase en veu alta i fixa't en els sons propis del valencià.",
  "text": "El xiquet juga amb la pilota al carrer.",
  "sounds": [
   [
    "ʃ",
    "ʒ",
    "tʃ",
    "dʒ"
   ],
   [
    "ʎ"
   ],
   [
    "r"
   ]
  ],
  "explanation": "La x de «xiquet» i la j de «juga» són palatals; la rr de «carrer», forta."
 },
 {
  "resource_id": "013139cd-ab6b-45b5-99e7-58104459f974",
  "level": "B1",
  "n": 2,
  "prompt": "Llig la frase en veu alta i fixa't en els sons propis del valencià.",
  "text": "La meua germana viatja a Xàtiva cada dilluns.",
  "sounds": [
   [
    "ʃ",
    "ʒ",
    "tʃ",
    "dʒ"
   ],
   [
    "ʎ"
   ],
   [
    "r"
   ]
  ],
  "explanation": "La g de «germana», la tj de «viatja» i la X de «Xàtiva» són palatals; la ll de «dilluns» també."
 },
 {
  "resource_id": "013139cd-ab6b-45b5-99e7-58104459f974",
  "level": "B1",
  "n": 3,
  "prompt": "Llig la frase en veu alta i fixa't en els sons propis del valencià.",
  "text": "Els rellotges de l'estació van rebre una reparació.",
  "sounds": [
   [
    "ʃ",
    "ʒ",
    "tʃ",
    "dʒ"
   ],
   [
    "ʎ"
   ],
   [
    "r"
   ]
  ],
  "explanation": "La r inicial de «rellotges», «rebre» i «reparació» és forta; la ll i la tg, palatals."
 },
 {
  "resource_id": "013139cd-ab6b-45b5-99e7-58104459f974",
  "level": "B1",
  "n": 4,
  "prompt": "Llig la frase en veu alta i fixa't en els sons propis del valencià.",
  "text": "Mengem formatge i pa amb oli a la platja.",
  "sounds": [
   [
    "ʃ",
    "ʒ",
    "tʃ",
    "dʒ"
   ],
   [
    "ʎ"
   ],
   [
    "r"
   ]
  ],
  "explanation": "La g de «mengem», la tg de «formatge» i la tj de «platja» sonen com la j de «jove»."
 },
 {
  "resource_id": "013139cd-ab6b-45b5-99e7-58104459f974",
  "level": "B1",
  "n": 5,
  "prompt": "Llig la frase en veu alta i fixa't en els sons propis del valencià.",
  "text": "La llum del migdia entra per la finestra.",
  "sounds": [
   [
    "ʃ",
    "ʒ",
    "tʃ",
    "dʒ"
   ],
   [
    "ʎ"
   ],
   [
    "r"
   ]
  ],
  "explanation": "La ll de «llum» i la g de «migdia» són sons palatals."
 },
 {
  "resource_id": "09b7be43-f83f-571e-9498-785bf09dda31",
  "level": "B2",
  "n": 1,
  "prompt": "Llig la frase en veu alta i fixa't en els sons propis del valencià.",
  "text": "El jove periodista va redactar un reportatge sobre la ciutat.",
  "sounds": [
   [
    "ʃ",
    "ʒ",
    "tʃ",
    "dʒ"
   ],
   [
    "ʎ"
   ],
   [
    "r"
   ]
  ],
  "explanation": "La j de «jove» i la tg de «reportatge» són palatals; la r inicial, forta."
 },
 {
  "resource_id": "09b7be43-f83f-571e-9498-785bf09dda31",
  "level": "B2",
  "n": 2,
  "prompt": "Llig la frase en veu alta i fixa't en els sons propis del valencià.",
  "text": "Les fulles roges cauen dels arbres a la tardor.",
  "sounds": [
   [
    "ʃ",
    "ʒ",
    "tʃ",
    "dʒ"
   ],
   [
    "ʎ"
   ],
   [
    "r"
   ]
  ],
  "explanation": "La ll de «fulles» és palatal; la r inicial de «roges», forta."
 },
 {
  "resource_id": "09b7be43-f83f-571e-9498-785bf09dda31",
  "level": "B2",
  "n": 3,
  "prompt": "Llig la frase en veu alta i fixa't en els sons propis del valencià.",
  "text": "L'equip rival va jugar millor en la segona part.",
  "sounds": [
   [
    "ʃ",
    "ʒ",
    "tʃ",
    "dʒ"
   ],
   [
    "ʎ"
   ],
   [
    "r"
   ]
  ],
  "explanation": "La r inicial de «rival» és forta, la j de «jugar» i la ll de «millor», palatals."
 },
 {
  "resource_id": "09b7be43-f83f-571e-9498-785bf09dda31",
  "level": "B2",
  "n": 4,
  "prompt": "Llig la frase en veu alta i fixa't en els sons propis del valencià.",
  "text": "Hem de desxifrar el missatge abans de dijous.",
  "sounds": [
   [
    "ʃ",
    "ʒ",
    "tʃ",
    "dʒ"
   ],
   [
    "ʎ"
   ],
   [
    "r"
   ]
  ],
  "explanation": "La x de «desxifrar», la tg de «missatge» i la j de «dijous» són palatals."
 },
 {
  "resource_id": "09b7be43-f83f-571e-9498-785bf09dda31",
  "level": "B2",
  "n": 5,
  "prompt": "Llig la frase en veu alta i fixa't en els sons propis del valencià.",
  "text": "La rondalla explica la història d'un rei generós.",
  "sounds": [
   [
    "ʃ",
    "ʒ",
    "tʃ",
    "dʒ"
   ],
   [
    "ʎ"
   ],
   [
    "r"
   ]
  ],
  "explanation": "La r inicial de «rondalla» i «rei» és forta; la ll i la g de «generós», palatals."
 },
 {
  "resource_id": "88e5a42a-4fbe-50f6-8abb-52ed7437a16d",
  "level": "C1",
  "n": 1,
  "prompt": "Llig la frase en veu alta i fixa't en els sons propis del valencià.",
  "text": "La correcció lingüística exigix rigor i paciència.",
  "sounds": [
   [
    "ʃ",
    "ʒ",
    "tʃ",
    "dʒ"
   ],
   [
    "ʎ"
   ],
   [
    "r"
   ]
  ],
  "explanation": "La rr de «correcció» i la r inicial de «rigor» són fortes; la g i la x d'«exigix», palatals."
 },
 {
  "resource_id": "88e5a42a-4fbe-50f6-8abb-52ed7437a16d",
  "level": "C1",
  "n": 2,
  "prompt": "Llig la frase en veu alta i fixa't en els sons propis del valencià.",
  "text": "Els joves reivindiquen el dret a un habitatge digne.",
  "sounds": [
   [
    "ʃ",
    "ʒ",
    "tʃ",
    "dʒ"
   ],
   [
    "ʎ"
   ],
   [
    "r"
   ]
  ],
  "explanation": "La j de «joves» i la tg d'«habitatge» són palatals; la r inicial, forta."
 },
 {
  "resource_id": "88e5a42a-4fbe-50f6-8abb-52ed7437a16d",
  "level": "C1",
  "n": 3,
  "prompt": "Llig la frase en veu alta i fixa't en els sons propis del valencià.",
  "text": "La pluja torrencial va arrasar els camps de regadiu.",
  "sounds": [
   [
    "ʃ",
    "ʒ",
    "tʃ",
    "dʒ"
   ],
   [
    "ʎ"
   ],
   [
    "r"
   ]
  ],
  "explanation": "La j de «pluja» és palatal; la rr de «torrencial» i «arrasar» i la r de «regadiu», fortes."
 },
 {
  "resource_id": "88e5a42a-4fbe-50f6-8abb-52ed7437a16d",
  "level": "C1",
  "n": 4,
  "prompt": "Llig la frase en veu alta i fixa't en els sons propis del valencià.",
  "text": "El rellotger va reparar l'engranatge del rellotge.",
  "sounds": [
   [
    "ʃ",
    "ʒ",
    "tʃ",
    "dʒ"
   ],
   [
    "ʎ"
   ],
   [
    "r"
   ]
  ],
  "explanation": "La r inicial és forta; la ll, la tg i la g són palatals."
 },
 {
  "resource_id": "88e5a42a-4fbe-50f6-8abb-52ed7437a16d",
  "level": "C1",
  "n": 5,
  "prompt": "Llig la frase en veu alta i fixa't en els sons propis del valencià.",
  "text": "La xerrada sobre la llengua va despertar molt d'interés.",
  "sounds": [
   [
    "ʃ",
    "ʒ",
    "tʃ",
    "dʒ"
   ],
   [
    "ʎ"
   ],
   [
    "r"
   ]
  ],
  "explanation": "La x de «xerrada» i la ll de «llengua» són palatals; la rr, forta."
 }
]$data$)
  AS x(resource_id uuid, level text, n int, prompt text, text text, sounds jsonb, explanation text);

INSERT INTO public.practice_exercises (resource_id, level, position, kind, prompt, task, explanation)
SELECT c.resource_id, c.level, 1000 + c.n, 'pronunciation', c.prompt, jsonb_build_object('text', c.text, 'sounds', c.sounds), c.explanation
FROM pronunciation_catalog c
WHERE NOT EXISTS (
  SELECT 1 FROM public.practice_exercises e
  WHERE e.resource_id = c.resource_id AND e.kind = 'pronunciation' AND e.task ->> 'text' = c.text
);

-- Repartiment: la frase i-èsima de P va darrere de la pregunta escrita round(i·W/(P+1)) de W. La clau no depén de les
-- posicions actuals (sí de l'ordre de les preguntes escrites i del de les frases en el catàleg). Primer s'aparten
-- totes fora del rang, perquè la restricció única (resource_id, level, position) no salte a mitja renumeració.
UPDATE public.practice_exercises SET position = position + 2000
WHERE resource_id IN ('013139cd-ab6b-45b5-99e7-58104459f974', '09b7be43-f83f-571e-9498-785bf09dda31', '374de871-c607-51fb-b2d3-d29324c25a93', '4a7ebcc7-0141-4e17-bae8-6386275e31dd', '53f521aa-eeea-5579-ad61-75e6c876df19', '77e69eed-4550-4420-a66e-1f226c99a989', '7baaddb7-7eaf-4f14-bfc3-b2e2e1c04964', '88e5a42a-4fbe-50f6-8abb-52ed7437a16d', 'bc84c944-a8c7-5bff-a6e2-b72aa9f12e7c', 'ce18cc3f-74e3-44b7-9613-2853cb3b3290', 'd94b8164-595d-5ef6-b396-3b675874896c', 'edf7dc63-a228-586e-b90f-c2ce2c5a95b1');

WITH ex AS (
  SELECT e.id, e.resource_id, e.level, e.kind = 'pronunciation' AS spoken,
    row_number() OVER (PARTITION BY e.resource_id, e.level, e.kind = 'pronunciation'
                       ORDER BY coalesce(c.n, 0), e.position) AS i
  FROM public.practice_exercises e
  LEFT JOIN pronunciation_catalog c ON c.resource_id = e.resource_id AND c.text = e.task ->> 'text'
  WHERE e.resource_id IN ('013139cd-ab6b-45b5-99e7-58104459f974', '09b7be43-f83f-571e-9498-785bf09dda31', '374de871-c607-51fb-b2d3-d29324c25a93', '4a7ebcc7-0141-4e17-bae8-6386275e31dd', '53f521aa-eeea-5579-ad61-75e6c876df19', '77e69eed-4550-4420-a66e-1f226c99a989', '7baaddb7-7eaf-4f14-bfc3-b2e2e1c04964', '88e5a42a-4fbe-50f6-8abb-52ed7437a16d', 'bc84c944-a8c7-5bff-a6e2-b72aa9f12e7c', 'ce18cc3f-74e3-44b7-9613-2853cb3b3290', 'd94b8164-595d-5ef6-b396-3b675874896c', 'edf7dc63-a228-586e-b90f-c2ce2c5a95b1')
),
counts AS (
  SELECT resource_id, level, count(*) FILTER (WHERE NOT spoken) AS w, count(*) FILTER (WHERE spoken) AS p
  FROM ex GROUP BY resource_id, level
),
keyed AS (
  SELECT ex.id, ex.resource_id, ex.level,
    CASE WHEN ex.spoken THEN round(ex.i * c.w::numeric / (c.p + 1)) * 10 + 5 ELSE ex.i * 10 END AS sort_key
  FROM ex JOIN counts c USING (resource_id, level)
)
UPDATE public.practice_exercises e
SET position = k.position
FROM (SELECT id, row_number() OVER (PARTITION BY resource_id, level ORDER BY sort_key) AS position FROM keyed) k
WHERE e.id = k.id;

DROP TABLE pronunciation_catalog;
