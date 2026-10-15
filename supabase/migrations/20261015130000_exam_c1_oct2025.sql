-- Examen interactiu C1 de la JQCV (octubre 2025) com a recurs de category 'examen'.
-- Contingut a metadata.exam, amb les quatre àrees del C1 i la puntuació de la guia de la prova
-- (comprensió escrita 10 %, 5 preguntes de 20 punts; estructures lingüístiques 20 %, 30 buits;
-- expressió escrita 35 % i expressió oral 35 %; mínim del 20 %, el 40 % i el 50 % segons el pes de
-- l'àrea). Les respostes són les de la plantilla oficial que inclou el quadern. Les redaccions es
-- corregixen amb la rúbrica C1; les infografies de l'exercici 5 són a frontend/public/exams/.
-- Font: https://jqcv.gva.es/documents/161863165/165492633/C1+octubre+2025.pdf/917ec2e9-461d-bb7d-df14-7bc1517f1afb

INSERT INTO public.resources (id, name, type, url, content, metadata, xp_earned, difficulty, category)
SELECT id, name, type, url, content, metadata, xp_earned, difficulty, category
FROM jsonb_populate_record(NULL::public.resources, $data${
 "id": "e02e7881-8369-54f1-b5e7-a26b61b277b8",
 "name": "Simulacre C1: octubre 2025",
 "type": "jqcv_c1_oct2025",
 "category": "examen",
 "difficulty": "C1",
 "xp_earned": 40,
 "content": "Examen oficial C1 de la JQCV (octubre 2025): comprensió escrita i estructures lingüístiques autocorregibles, dos redaccions i pràctica oral.",
 "metadata": {
  "icon": "🚀",
  "color": "#B3E5FC",
  "exam_body": "JQCV",
  "certificate_level": "C1",
  "exam": {
   "level": "C1",
   "session": "Octubre 2025",
   "body": "JQCV",
   "source_url": "https://jqcv.gva.es/documents/161863165/165492633/C1+octubre+2025.pdf/917ec2e9-461d-bb7d-df14-7bc1517f1afb",
   "pass_rule": "Per a ser APTE cal una puntuació global mínima de 60 sobre 100. Les àrees valen un 10 % (comprensió escrita), un 20 % (estructures lingüístiques), un 35 % (expressió i interacció escrites) i un 35 % (expressió i interacció orals), i en cada una cal arribar al mínim: el 20 % en la comprensió escrita, el 40 % en les estructures lingüístiques i el 50 % en l’expressió escrita i en l’expressió oral.",
   "areas": [
    {
     "n": 1,
     "title": "Comprensió escrita",
     "weight": 10,
     "duration": "3 h 30 min (àrees 1, 2 i 3)",
     "scoring": {
      "points_per_correct": 20,
      "max_points": 100,
      "pass_points": 20
     },
     "exercises": [
      {
       "n": 1,
       "kind": "choice",
       "instructions": "Llig atentament este article i tria l’opció correcta (a, b, c o d). Tin en compte que, per a cada qüestió plantejada, només hi ha una resposta correcta. Fixa’t en l’exemple (número 0).",
       "reading": {
        "title": "Afronautes",
        "paragraphs": [
         "En plena guerra freda, la confrontació entre els Estats Units i l’URSS va excedir fronteres, literalment. El deliri de les dos nacions perquè els models que defenien dominaren el món es va traduir en una carrera espacial. Encara que la victòria final va ser per als nord-americans, la Unió Soviètica va donar el tir d’eixida d’esta competició, el 1957, amb el llançament de l’Sputnik 1, el primer satèl·lit artificial posat en òrbita al voltant de la Terra. El primer home que va sobrevolar l’espai, el 1961, Iuri Gagarin, també era de nacionalitat russa. Ara bé, els nord-americans van agarrar embranzida i, el 20 de juliol del 1969, Neil Armstrong va ser el primer humà que va xafar la Lluna.",
         "Paral·lelament a aquella guerra, Zàmbia, que fins al 1964 havia sigut Rhodèsia del Nord i estava a punt d’adquirir la independència del Regne Unit, també va decidir sumar-se a la competició. Es tractava d’un país africà que només tenia cent universitaris i a on menys del 0,5 % de la població havia acabat els estudis primaris. El líder del projecte va ser Edward Makuka Nkoloso, professor de ciències i figura important del moviment per la independència del país. Havia lluitat en la Segona Guerra Mundial, havia sigut traductor del Govern de Rhodèsia del Nord i membre del Partit per la Independència Nacional Unit, i havia col·laborat per a redactar la nova constitució del país.",
         "El 1960, Makuka Nkoloso va crear l’Acadèmia Nacional de Ciència, Investigació Espacial i Filosofia. “El nostre pensament està cinc o sis anys per davant del seu”, en referència als habitants d’aquell planeta, assegurava Nkoloso. Este visionari va reclutar onze jóvens per a convertir-los en els primers afronautes, terme que ell mateix va encunyar, arribar a la Lluna i després a Mart, a on estava convençut que hi havia vida. Entre els integrants de la tripulació, hi havia una xica de setze anys que es deia Martha Mwamba, que, com a condició, va imposar portar els seus dos gats a l’expedició. També es va unir a l’equip un missioner. Tot i això, el líder el va advertir que no havia d’imposar el cristianisme si els habitants de Mart no ho volien.",
         "Una vella granja als afores de Lusaka, la capital de Zàmbia, es va transformar en el centre d’entrenament dels jóvens reclutes. Els exercicis a què se sotmetien els cosmonautes eren variats, més pareguts a una classe d’aeròbic que a una preparació espacial. Algunes proves consistien a pegar bots amb els braços alçats mentres feien palmes o s’engrunsaven. També se’ls veia caminar en fila índia pel descampat i tirar-se redolant des de dalt d’un tossal dins d’un barril d’oli, per a experimentar la ingravitació i el salt al buit, així com per a simular el moviment del coet.",
         "Si els exercicis pareixien poc adequats, la nau, batejada D-Kalu i feta artesanalment, tampoc era espectacular. Estava pensada per a portar una persona, tenia forma cilíndrica, un diàmetre prou reduït i era més baixeta que qualsevol membre de l’equip. De fet, era més adient per al decorat d’una funció teatral que per al pelegrinatge interplanetari que s’havien proposat. La idea era impulsar-la amb una catapulta, però no va alçar mai el vol.",
         "El 1964, una cadena de televisió britànica va gravar els reclutes mentres s’entrenaven i va aprofitar per a entrevistar a Nkoloso, que anava vestit amb un casc —de l’exèrcit britànic reciclat— i una capa. “Quina creu que serà la reacció dels Estats Units i l’URSS davant de la incorporació de Zàmbia a la carrera espacial?”, preguntava el periodiste. “Només se sorprendran. Descobriran que han subestimat els nostres recursos i la nostra intel·ligència. Estic segur que els estem atrapant”, responia, tot convençut.",
         "El 24 d’octubre del 1964, Dia Oficial de la Independència, també era la data que Nkoloso havia triat per a fer enlairar el coet des de l’Estadi Nacional. El comité oficial de les celebracions, però, li ho va prohibir, i va al·legar que podria espantar els assistents. Uns dies després de l’esdeveniment, la revista Time mencionava que només un ciutadà zambià havia quedat descontent amb els festejos d’independència: Edward Nkoloso. La festivitat havia interferit en el seu programa espacial.",
         "Amb el pas del temps, el projecte espacial de Zàmbia va anar flaquejant. El finançament es va convertir en un problema: les autoritats nacionals se’n van desentendre i la UNESCO no va contestar mai la carta en què Nkoloso els demanava 7 milions de lliures esterlines. Sense diners, arribar a la Lluna era impossible. A més, un escàndol va enfosquir el projecte. Martha Mwamba, l’única xica de la tripulació, va quedar embarassada d’un altre membre de l’equip, i els pares la van obligar a abandonar el projecte i tornar al poble.",
         "Knoloso mai va reconéixer que el seu projecte era una utopia. De fet, va denunciar que les grans potències, l’URSS i els EUA, volien temptar els seus astronautes fent-los ofertes. I va assegurar que “els neocolonialistes imperialistes estaven espantats del coneixement espacial de Zàmbia”. L’arribada de la missió nord-americana Apollo 11 a la Lluna, l’estiu del 1969, va ser el colp definitiu perquè el projecte es desmantellara del tot i, definitivament, quedara com una anècdota curiosa més en la història de la carrera espacial."
        ]
       },
       "questions": [
        {
         "n": 0,
         "prompt": "El text explica…",
         "answer": "a",
         "scored": false,
         "options": [
          {
           "key": "a",
           "text": "l’intent de Zàmbia d’unir-se a la carrera espacial durant la guerra freda."
          },
          {
           "key": "b",
           "text": "la rivalitat tecnològica entre l’URSS i els EUA per a controlar els recursos zambians."
          },
          {
           "key": "c",
           "text": "el procés amb què Zàmbia rebé suport internacional per a enviar una nau a Mart."
          },
          {
           "key": "d",
           "text": "com influïren els mitjans de comunicació en el relat espacial durant la guerra freda."
          }
         ]
        },
        {
         "n": 1,
         "prompt": "La figura d’Edward Nkoloso destaca perquè…",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "va rebre finançament de la UNESCO per a impulsar la investigació científica."
          },
          {
           "key": "b",
           "text": "combinava activisme polític, experiència militar i visió científica."
          },
          {
           "key": "c",
           "text": "es va formar com a científic al Regne Unit, però es va inspirar en el model científic rus."
          },
          {
           "key": "d",
           "text": "liderava el moviment de descolonització des del Govern britànic de Rhodèsia."
          }
         ]
        },
        {
         "n": 2,
         "prompt": "L’Acadèmia fundada per Nkoloso pretenia…",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "promoure la investigació espacial amb una metodologia innovadora."
          },
          {
           "key": "b",
           "text": "desenrotllar un projecte pilot espacial a Àfrica amb l’ajuda del Regne Unit."
          },
          {
           "key": "c",
           "text": "formar un grup de jóvens i impulsar una missió interplanetària."
          },
          {
           "key": "d",
           "text": "arribar a l’espai i evitar l’evangelització dels habitants de Mart."
          }
         ]
        },
        {
         "n": 3,
         "prompt": "En relació amb la nau D-Kalu, el text indica que…",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "tenia una capacitat reduïda i una aparença pròpia d’un espectacle teatral."
          },
          {
           "key": "b",
           "text": "es va llançar amb una catapulta en l’Estadi Nacional de Lusaka."
          },
          {
           "key": "c",
           "text": "s’havia dissenyat per a allotjar el membre més baixet de la tripulació."
          },
          {
           "key": "d",
           "text": "es van fer proves amb condicions de gravetat zero durant l’entrenament."
          }
         ]
        },
        {
         "n": 4,
         "prompt": "Nkoloso pensava que la resta de potències espacials…",
         "answer": "d",
         "options": [
          {
           "key": "a",
           "text": "ironitzaven sobre el projecte en els mitjans de comunicació."
          },
          {
           "key": "b",
           "text": "eren cauts i temien els avanços dels afronautes."
          },
          {
           "key": "c",
           "text": "planejaven sabotejar el llançament del coet D-Kalu."
          },
          {
           "key": "d",
           "text": "infravaloraven la manera en què treballaven el seu equip i ell."
          }
         ]
        },
        {
         "n": 5,
         "prompt": "El projecte va començar a fracassar per…",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "la prohibició del Govern zambià de fer-lo públic el Dia de la Independència."
          },
          {
           "key": "b",
           "text": "la falta de resposta i el desinterés progressiu del Govern zambià."
          },
          {
           "key": "c",
           "text": "l’escàndol de dos dels integrants de la tripulació."
          },
          {
           "key": "d",
           "text": "la pressió de l’URSS i els Estats Units sobre els integrants de la tripulació."
          }
         ]
        }
       ]
      }
     ]
    },
    {
     "n": 2,
     "title": "Estructures lingüístiques",
     "weight": 20,
     "duration": "3 h 30 min (àrees 1, 2 i 3)",
     "scoring": {
      "points_per_correct": 3.333,
      "max_points": 100,
      "pass_points": 40
     },
     "exercises": [
      {
       "n": 2,
       "kind": "choice",
       "instructions": "Completa el text que tens a continuació amb l’alternativa més precisa i adequada. Només hi ha una opció correcta per a cada buit. Fixa’t en l’exemple (número 0).",
       "reading": {
        "title": "La saviesa aixafada de l’Amazones",
        "paragraphs": [
         "La riquesa de la selva tropical més gran del món —fa set milions de quilòmetres quadrats i (0) travessa nou països— és incomparable. Centenars de milers d’espècies, (6) ______ hi ha trenta milions de persones, habiten este ecosistema enorme. Hi ha quatre-cents pobles indígenes que parlen més de tres-centes llengües diferents i, (7) ______, amb algunes d’estes comunitats encara no s’ha pogut establir contacte.",
         "Fa anys, (8) ______, la població indígena era molt més nombrosa. Quan els navegants portuguesos van arribar per primera vegada (9) ______ l’any 1500 a l’Amazones vivien cinc milions de persones. Hui es calcula que hi ha uns 310.000 nadius. Al vore fotografies aèries, podem imaginar un xicotet fragment de la immensitat de la selva amazònica. S’observa una catifa verda que ix de (10) ______ i tot de línies serpentejants dels rius que la travessen, els afluents del riu Amazones, que dona nom a la selva. Este riu de (11) ______ generós medix 7.000 quilòmetres des del seu naixement andí (12) ______ la desembocadura atlàntica. Allí coincidixen els pobles originaris, amb coneixements ancestrals, i també els afrodescendents, colons i riberinhos, que van arribar en (13) ______ etapes migratòries a la regió.",
         "En este ecosistema passen fenòmens naturals curiosos. Per exemple, el riu Amazones i els seus afluents no són l’única manera de transportar aigua. La selva amazònica és l’únic lloc del planeta a on la humitat aèria no depén de l’evaporació dels oceans. Allà tenen el que anomenen “rius voladors”. Els 400.000 milions d’arbres de la regió fan de màquines de vapor: succionen centenars de litres d’aigua cada dia i (14) ______ a l’atmosfera a través dels (15) ______ del seu fullatge. Estos “rius voladors” transporten més aigua que el (16) ______ riu Amazones.",
         "És per això que les fotografies per satèl·lit d’este bosc enorme mostren sempre la selva mig amagada darrere de núvols. Si alguna volta la (17) ______ prou definida, voldrà dir que els “rius voladors” hauran desaparegut, i les conseqüències seran catastròfiques per al planeta.",
         "Ara mateix, l’Amazones està (18) ______ per la contaminació, la desforestació, la lluita per les matèries (19) ______, els incendis i una gravíssima sequera. Un procés que està destrossant la riquesa natural del territori i que, (20) ______ la resistència, ha esborrat part de la memòria cultural de la població originària, que habita la regió des de fa més de tretze mil anys."
        ]
       },
       "questions": [
        {
         "n": 6,
         "prompt": "Buit 6",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "d’entre què"
          },
          {
           "key": "b",
           "text": "d’entre les quals"
          },
          {
           "key": "c",
           "text": "d’entre les que"
          }
         ]
        },
        {
         "n": 7,
         "prompt": "Buit 7",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "a dia de hui"
          },
          {
           "key": "b",
           "text": "hui en dia"
          },
          {
           "key": "c",
           "text": "hui per hui"
          }
         ]
        },
        {
         "n": 8,
         "prompt": "Buit 8",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "però"
          },
          {
           "key": "b",
           "text": "doncs"
          },
          {
           "key": "c",
           "text": "llavors"
          }
         ]
        },
        {
         "n": 9,
         "prompt": "Buit 9",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "al Brasil"
          },
          {
           "key": "b",
           "text": "en Brasil"
          },
          {
           "key": "c",
           "text": "a Brasil"
          }
         ]
        },
        {
         "n": 10,
         "prompt": "Buit 10",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "plànol"
          },
          {
           "key": "b",
           "text": "planell"
          },
          {
           "key": "c",
           "text": "pla"
          }
         ]
        },
        {
         "n": 11,
         "prompt": "Buit 11",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "cabal"
          },
          {
           "key": "b",
           "text": "cabdal"
          },
          {
           "key": "c",
           "text": "caudal"
          }
         ]
        },
        {
         "n": 12,
         "prompt": "Buit 12",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "fins"
          },
          {
           "key": "b",
           "text": "fins a"
          },
          {
           "key": "c",
           "text": "fins en"
          }
         ]
        },
        {
         "n": 13,
         "prompt": "Buit 13",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "vàries"
          },
          {
           "key": "b",
           "text": "diverses"
          },
          {
           "key": "c",
           "text": "algunes"
          }
         ]
        },
        {
         "n": 14,
         "prompt": "Buit 14",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "l’alliberen"
          },
          {
           "key": "b",
           "text": "la lliuren"
          },
          {
           "key": "c",
           "text": "la llisquen"
          }
         ]
        },
        {
         "n": 15,
         "prompt": "Buit 15",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "pors"
          },
          {
           "key": "b",
           "text": "porosos"
          },
          {
           "key": "c",
           "text": "porus"
          }
         ]
        },
        {
         "n": 16,
         "prompt": "Buit 16",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "mateix"
          },
          {
           "key": "b",
           "text": "propi"
          },
          {
           "key": "c",
           "text": "llur"
          }
         ]
        },
        {
         "n": 17,
         "prompt": "Buit 17",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "vegem"
          },
          {
           "key": "b",
           "text": "veem"
          },
          {
           "key": "c",
           "text": "vérem"
          }
         ]
        },
        {
         "n": 18,
         "prompt": "Buit 18",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "assolat"
          },
          {
           "key": "b",
           "text": "dessolat"
          },
          {
           "key": "c",
           "text": "assolit"
          }
         ]
        },
        {
         "n": 19,
         "prompt": "Buit 19",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "primeres"
          },
          {
           "key": "b",
           "text": "primerenques"
          },
          {
           "key": "c",
           "text": "primes"
          }
         ]
        },
        {
         "n": 20,
         "prompt": "Buit 20",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "tanmateix"
          },
          {
           "key": "b",
           "text": "malgrat que"
          },
          {
           "key": "c",
           "text": "a pesar de"
          }
         ]
        }
       ]
      },
      {
       "n": 3,
       "kind": "choice",
       "instructions": "Completa el text que tens a continuació amb l’alternativa més precisa i adequada. Només hi ha una opció correcta per a cada buit. Fixa’t en l’exemple (número 0).",
       "reading": {
        "title": "Torres humanes del món: les Forze d’Ercole venecianes",
        "paragraphs": [
         "Les torres humanes són un fenomen que transcendix tota (0) classe de fronteres polítiques i culturals. És evident que les més conegudes per als valencians són les muixerangues i els castells; però, xano-xano, (21) ______ altres de més llunyanes, com les del Magrib, el Perú, Itàlia o la Xina. Ara, (22) ______, coneixerem les torres humanes venecianes.",
         "Les Forze d’Ercole han sigut una variable més de les construccions humanes que es practiquen (23) ______ del món. Durant la primera època, (24) ______ des del segle IX fins al segle XIII, actuaren en un dels illots de la Llacuna que es coneix com Eraclea, d’a on provenien dos nissagues familiars històricament enfrontades. En els inicis, les construccions eren bastides de manera (25) ______ descurada. Quan les dos famílies rivals s’instal·laren a Venècia, s’emportaren i mantingueren alguns costums, que també van fer seus gran part dels habitants dels barris (26) ______ afores de la ciutat.",
         "Prompte, les Forze d’Ercole van servir com un element més de pugna i les actuacions començaren a practicar-se en actes festius i commemoratius. Concentraven força i (27) ______. Les Forze d’Ercole van actuar regularment durant uns quants segles fins que va acabar la República de Venècia (1797). (28) ______, encara ho van fer, de manera puntual i extraordinària, en les beceroles del segle XIX, després d’uns anys de prohibició napoleònica.",
         "Les dos faccions estaven formades quasi exclusivament per hòmens que es dedicaven a construir un ventall d’estructures humanes, (29) ______ era prou eclèctica. Per exemple, segons el tipus de figura que alçaven, s’ajudaven, o les combinaven, amb (30) ______ de fusta. En qualsevol cas, feia falta una bona dosi d’agilitat i equilibri, atés que actuaven tant en terra ferma com en els canals, sobre dos barcasses lligades. Pel que sembla, les construccions van arribar a tindre huit pisos.",
         "Les colles que actuaven estaven formades per un mínim de trenta persones entre hòmens, jóvens i la criatura, el cimiereto. El grup dels forte, saorna o zavorre formaven la base de la construcció. Els membres situats en els pisos intermedis, que anaven disminuint gradualment (31) ______ arribar al capdamunt, se’ls denominava secondi, terzi… El cas de la xiqueta de qui tenim coneixement es deia Bàrbara Flaminia, que (32) ______ va ser de les actrius més famoses del segle XV. Tan bon punt es coronaven aquelles construccions, que eren prou piramidals i tenien un sentit al·legòric, com les muixerangues, el cimiereto feia un seguit de postures i volantins i, els més atrevits, algun salt mortal (anomenat tombolo o impalo).",
         "Després d’estos moviments, feia una salutació al dux i es llançava al buit, (33) ______ damunt d’un gran coixí o matalaf que prèviament havien col·locat en terra, (34) ______ l’estructura. El desmuntatge o “descarregada” de la construcció de tots els components el completaven seguint el mateix camí. Es tractava de comprovar quin dels dos bàndols mantenia l’equilibri durant més temps sense caure (35) ______ o podia completar la construcció. La colla que reeixia era qui aconseguia la victòria."
        ]
       },
       "questions": [
        {
         "n": 21,
         "prompt": "Buit 21",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "en descobrim"
          },
          {
           "key": "b",
           "text": "n’hi descobrim"
          },
          {
           "key": "c",
           "text": "hi descobrim"
          }
         ]
        },
        {
         "n": 22,
         "prompt": "Buit 22",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "no obstant"
          },
          {
           "key": "b",
           "text": "doncs"
          },
          {
           "key": "c",
           "text": "llavors"
          }
         ]
        },
        {
         "n": 23,
         "prompt": "Buit 23",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "arran"
          },
          {
           "key": "b",
           "text": "arreu"
          },
          {
           "key": "c",
           "text": "a recer"
          }
         ]
        },
        {
         "n": 24,
         "prompt": "Buit 24",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "si fa no fa"
          },
          {
           "key": "b",
           "text": "si més no"
          },
          {
           "key": "c",
           "text": "si de cas"
          }
         ]
        },
        {
         "n": 25,
         "prompt": "Buit 25",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "més be"
          },
          {
           "key": "b",
           "text": "més prompte"
          },
          {
           "key": "c",
           "text": "més que no"
          }
         ]
        },
        {
         "n": 26,
         "prompt": "Buit 26",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "d’"
          },
          {
           "key": "b",
           "text": "de les"
          },
          {
           "key": "c",
           "text": "dels"
          }
         ]
        },
        {
         "n": 27,
         "prompt": "Buit 27",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "virolla"
          },
          {
           "key": "b",
           "text": "traça"
          },
          {
           "key": "c",
           "text": "avinentesa"
          }
         ]
        },
        {
         "n": 28,
         "prompt": "Buit 28",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "Altrament"
          },
          {
           "key": "b",
           "text": "Al cap i a la fi"
          },
          {
           "key": "c",
           "text": "Amb tot"
          }
         ]
        },
        {
         "n": 29,
         "prompt": "Buit 29",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "l’arquitectura de les quals"
          },
          {
           "key": "b",
           "text": "l’arquitectura del qual"
          },
          {
           "key": "c",
           "text": "l’arquitectura de la qual"
          }
         ]
        },
        {
         "n": 30,
         "prompt": "Buit 30",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "taulons"
          },
          {
           "key": "b",
           "text": "taulells"
          },
          {
           "key": "c",
           "text": "taulers"
          }
         ]
        },
        {
         "n": 31,
         "prompt": "Buit 31",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "fins"
          },
          {
           "key": "b",
           "text": "fins a"
          },
          {
           "key": "c",
           "text": "fins a l’"
          }
         ]
        },
        {
         "n": 32,
         "prompt": "Buit 32",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "més avant"
          },
          {
           "key": "b",
           "text": "d’ara endavant"
          },
          {
           "key": "c",
           "text": "més cap al davant"
          }
         ]
        },
        {
         "n": 33,
         "prompt": "Buit 33",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "anant"
          },
          {
           "key": "b",
           "text": "que anava"
          },
          {
           "key": "c",
           "text": "i anava"
          }
         ]
        },
        {
         "n": 34,
         "prompt": "Buit 34",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "junt a"
          },
          {
           "key": "b",
           "text": "arrel de"
          },
          {
           "key": "c",
           "text": "al costat de"
          }
         ]
        },
        {
         "n": 35,
         "prompt": "Buit 35",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "Ø"
          },
          {
           "key": "b",
           "text": "’s"
          },
          {
           "key": "c",
           "text": "-s’hi"
          }
         ]
        }
       ]
      }
     ]
    },
    {
     "n": 3,
     "title": "Expressió i interacció escrites",
     "weight": 35,
     "duration": "3 h 30 min (àrees 1, 2 i 3)",
     "exercises": [
      {
       "n": 4,
       "kind": "writing",
       "title": "Redacció",
       "instructions": "Tria una de les dos opcions i redacta un text amb una extensió entre 200 i 220 paraules.",
       "min_words": 200,
       "max_words": 220,
       "choices": [
        {
         "key": "A",
         "text": "Arran d’esdeveniments com la pandèmia o l’apagada del mes de maig, s’ha evidenciat la soledat en què viuen moltes persones majors i l’enorme impacte que té este aïllament en el seu envelliment. Amb vincles més dèbils, amb un estat de salut més dependent i amb més facilitat per a desconnectar-se dels avanços tecnològics i socials, les persones majors esdevenen més vulnerables. Treballes en els servicis socials del teu municipi, i has elaborat un programa de dinamització per a la gent major. Per a donar-lo a conéixer a tot el món, t’han encomanat que escrigues un article per a un fullet informatiu en què expliques les iniciatives que s’estan duent a terme i convides a tots els ciutadans a sumar-se al projecte. En el teu escrit cal que tractes, entre altres, estos punts:",
         "points": [
          "Activitats socioculturals que promouen un envelliment actiu.",
          "Activitats fora de casa amb què s’intensifiquen les relacions intergeneracionals.",
          "Impuls de la gestió democràtica i participativa de la llar dels jubilats."
         ]
        },
        {
         "key": "B",
         "text": "Els concursos de cuina de la televisió han contribuït a fer més visible la cuina casolana i reconéixer la professió dels cuiners. Esta tendència ha despertat l’interés per tornar als foguers, redescobrir receptes tradicionals i experimentar amb sabors autòctons i aliens. Més enllà de nodrir-nos, el món de la cuina ha reviscolat i s’ha convertit en una expressió identitària i artística. Participes en un taller de cuina organitzat per l’associació gastronòmica de la teua localitat, i t’han demanat que redactes una entrada en el blog de la mateixa associació en què reflexiones sobre el valor de la cuina casolana i de l’acte de cuinar com a fenomen cultural i emocional. En el teu escrit cal que tractes, entre altres, estos punts:",
         "points": [
          "Relació entre cuina tradicional i sostenibilitat.",
          "Funció terapèutica i social de cuinar.",
          "Transmissió de memòria familiar i identitat generacional."
         ]
        }
       ]
      },
      {
       "n": 5,
       "kind": "writing",
       "title": "Text a partir d’una infografia",
       "instructions": "Tria una de les dos opcions i redacta un text amb una extensió entre 170 i 190 paraules.",
       "min_words": 170,
       "max_words": 190,
       "choices": [
        {
         "key": "A",
         "text": "Es calcula que, de mitjana, cada valencià genera 1,5 kg de residus al dia, és a dir, vora 570 kg a l’any. D’estos residus, aproximadament un 45 % són orgànics, amb un alt valor mediambiental, que podrien tindre una vida posterior com a adob per a la terra. Amb estes dades, diversos sectors socials, en col·laboració amb la Regidoria de Medi Ambient, han decidit impulsar l’autocompostatge comunitari. Es tracta d’una actuació en què les comunitats veïnals reduiran la quantitat de residus que cal arreplegar, transportar i gestionar en instal·lacions de tractament. Presidixes l’associació de veïns, i amb la informació que t’ha fet arribar la Regidoria escrius un correu electrònic en què informes el veïnat de la nova iniciativa que es vol dur a terme. En el teu text cal que tingues en compte la informació de la infografia següent:",
         "image": "/exams/c1-octubre-2025/e5-a.jpg",
         "image_text": "Infografia sobre l’autocompostatge. «Què és l’autocompostatge?»: És l’aprofitament en la pròpia llar de les restes de la cuina i del jardí que generem per a fer un adob natural que podem aplicar a les nostres plantes o a l’hort. Amb l’autocompostatge retornem els nutrients al sòl i tanquem el cicle de la matèria orgànica; d’esta manera simplifiquem el cicle, ja que es produïx en el mateix lloc a on es generen els residus orgànics. «Quins usuaris pot tindre l’autocompostatge?»: L’autocompostatge es pot realitzar en l’àmbit domèstic (compostatge casolà o domèstic) o de forma col·lectiva (compostatge comunitari). «Comunitari»: El compostatge comunitari es realitza en espais lliures o enjardinats comunitaris d’un conjunt de vivendes, en espais públics, en escoletes, etc. «Casolà»: El compostatge casolà es realitza en el mateix domicili a on es generen les restes orgàniques, i així és tanca el cicle de la matèria orgànica en la pròpia llar. Il·lustració: compostadors de fusta amb una pala, un banc i un parc infantil."
        },
        {
         "key": "B",
         "text": "Parlar d’emocions en l’escola no és una qüestió de moda, sinó que és una necessitat. Els docents i les famílies reconeixen que aprendre a identificar i gestionar què senten els alumnes és tan important com saber llegir o fer operacions matemàtiques. Treballes en el departament d’orientació en un centre educatiu, i fa temps que assistixes a formacions i recopiles informació sobre la gestió emocional en l’aula. Per això, decidixes escriure un article divulgatiu per a la revista del centre en què expliques la importància de l’educació emocional i oferixes algunes pautes per a aplicar-la. En el teu text cal que tingues en compte la informació de la infografia següent:",
         "image": "/exams/c1-octubre-2025/e5-b.jpg",
         "image_text": "Infografia «Les emocions en l’escola», amb un cicle de passos units per fletxes. Identificar: El primer pas és identificar l’emoció que s’està experimentant. Comprendre: Saber per què apareixen les emocions. Entendre què les ha provocades. Desenrotllar l’empatia: Comprendre i compartir els sentiments dels altres. Expressar: Aprendre a expressar-les de manera adequada segons la situació. Lloc segur: Crear espais en l’aula a on els alumnes se senten segurs per a expressar les emocions."
        }
       ]
      }
     ]
    },
    {
     "n": 4,
     "title": "Expressió i interacció orals",
     "weight": 35,
     "duration": "25 minuts",
     "intro": "Esta àrea té dos parts: un monòleg d’uns tres minuts sobre un tema que tries, amb les idees que has de desenvolupar, i un diàleg d’uns quatre minuts amb una altra persona aspirant, en què defens el paper que et toque.",
     "exercises": [
      {
       "n": 6,
       "kind": "oral",
       "instructions": "Has de triar un tema i preparar un monòleg de tres minuts, aproximadament. A continuació trobaràs el tema sobre el qual has de parlar i les idees que has de desenvolupar.",
       "proposals": [
        {
         "title": "Monòleg · Foment lector",
         "duration": "3 minuts",
         "intro": "La lectura completa la vida de les persones perquè és un acte que proporciona un espai personal per a l’evasió, la transformació i l’enriquiment de l’individu, ens aporta pau mental i ens obri la porta a nous mons. El foment de la lectura s’ha de dur a terme des de la infància, i no s’hauria d’interrompre després de l’educació obligatòria. Desgraciadament, en l’hàbit lector intervenen molts factors, com ara els estudis, l’herència cultural familiar, el temps lliure, l’accés a llibres, etc. Treballes de dinamitzador cultural d’una escola d’adults, i has comprovat que, en general, l’alumnat del centre presenta uns índexs baixos de lectura. En una reunió proposes un pla als teus companys per a fomentar la lectura entre l’alumnat. En la teua intervenció cal que tractes, entre altres, estes idees:",
         "questions": [
          "Accessibilitat a altres formes d’entreteniment desactiven l’interés per la lectura entre els adults.",
          "Activitats de dinamització lectora en el centre.",
          "Establiment d’unes pautes de lectura en casa."
         ],
         "images": []
        },
        {
         "title": "Monòleg · Baixa taxa de natalitat",
         "duration": "3 minuts",
         "intro": "La Comunitat Valenciana té ara més població que fa unes dècades, però este augment demogràfic no es deu a l’increment de la natalitat, sinó a l’arribada de població estrangera. En els últims anys la taxa de naixements és menor que la de defuncions, i per això en termes estadístics el balanç del creixement és nul. Hi ha moltes raons que fan que cada vegada menys persones prenguen la determinació de ser pares i mares. T’han convidat a participar en una taula redona per a abordar els problemes i els reptes a què s’afronten els adults entre els 25 i els 35 anys. Es dedica una ronda d’intervenció a la natalitat, i dones el teu punt de vista. En la teua intervenció cal que tractes, entre altres, estes idees:",
         "questions": [
          "La inestabilitat i la precarietat laboral són factors determinants.",
          "Moltes dones es repensen ser mares per l’impacte que tindrà en la seua projecció laboral.",
          "Les polítiques públiques no tenen en compte les exigències que comporta la criança dels fills."
         ],
         "images": []
        }
       ]
      },
      {
       "n": 7,
       "kind": "oral",
       "instructions": "Has de mantindre un diàleg amb un altre o una altra aspirant sobre la situació comunicativa que vos proposem. Llig la introducció del tema i defén el paper que t’atorga la proposta ombrejada. Les intervencions han de ser equilibrades; evita donar respostes massa curtes i participa activament com ho faries en una conversació habitual. La duració de la conversació serà de quatre minuts, aproximadament.",
       "proposals": [
        {
         "title": "Diàleg · Primeres cites",
         "duration": "4 minuts",
         "intro": "Cada vegada trobem més aplicacions per a lligar i també trobem més parelles que s’han conegut a través d’estos entorns digitals. Les nostres vides caminen a un ritme frenètic i la faena implica desplaçar-se dels nostres llocs de naixement, de manera que les parelles es trenquen més a sovint. Tot això ha propiciat que les aplicacions per a conéixer gent estiguen cada vegada més esteses.",
         "questions": [],
         "images": [],
         "roles": [
          {
           "name": "Persona A",
           "text": "Eres una persona que ha fet ús d’estes aplicacions o estaria disposada a fer-ne, perquè per a tu els entorns digitals són espais d’interacció igual de vàlids com ho són el treball, les associacions o una discoteca. Opines que no s’ha d’estigmatitzar la gent que recorre a estos entorns, i expliques com et comportaries en eixos llocs i què tindries en compte a l’hora de demanar una primera cita."
          },
          {
           "name": "Persona B",
           "text": "Eres una persona que mai has utilitzat estes aplicacions i creus que no ho faràs mai. Consideres que els entorns reals són més adequats per a conéixer la gent, i argumentes que així pots interactuar de manera més directa i efectiva amb les persones. Expresses les teues objeccions a este sistema per a aconseguir cites."
          }
         ]
        }
       ]
      }
     ]
    }
   ]
  }
 }
}$data$::jsonb)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  type = EXCLUDED.type,
  url = EXCLUDED.url,
  content = EXCLUDED.content,
  metadata = EXCLUDED.metadata,
  xp_earned = EXCLUDED.xp_earned,
  difficulty = EXCLUDED.difficulty,
  category = EXCLUDED.category;
