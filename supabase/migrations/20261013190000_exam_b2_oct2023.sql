-- Examen interactiu B2 de la JQCV (octubre 2023) com a recurs de category 'examen'.
-- Contingut a metadata.exam, amb les cinc àrees del B2 i la puntuació oficial de la guia de la
-- prova (comprensió oral 8 i 12 punts per encert; comprensió escrita 3,3 i 8,5; estructures 5 i 5;
-- mínim del 40 % en cada àrea i del 50 % en l'oral). Les respostes són les de la plantilla
-- oficial que inclou el quadern. Àudio de comprensió oral a url, convertit a MP3 des de l'oficial
-- (frontend/public/audio/Audio_B2_oct2023.mp3). Font: https://jqcv.gva.es/documents/161863165/165492631/B2+octubre+2023.pdf/681bf1b8-8a16-bf64-ce56-9ef28fcd24a2

INSERT INTO public.resources (id, name, type, url, content, metadata, xp_earned, difficulty, category)
SELECT id, name, type, url, content, metadata, xp_earned, difficulty, category
FROM jsonb_populate_record(NULL::public.resources, $data${
 "id": "2b1b59c2-196c-5bb1-8181-c3ce4cb70200",
 "name": "Simulacre B2: octubre 2023",
 "type": "jqcv_b2_oct2023",
 "category": "examen",
 "difficulty": "B2",
 "xp_earned": 40,
 "url": "/audio/Audio_B2_oct2023.mp3",
 "content": "Examen oficial B2 de la JQCV (octubre 2023): comprensió oral i escrita i estructures lingüístiques autocorregibles, dos redaccions i pràctica oral.",
 "metadata": {
  "icon": "🧮",
  "color": "#B2DFDB",
  "exam_body": "JQCV",
  "certificate_level": "B2",
  "exam": {
   "level": "B2",
   "session": "Octubre 2023",
   "body": "JQCV",
   "source_url": "https://jqcv.gva.es/documents/161863165/165492631/B2+octubre+2023.pdf/681bf1b8-8a16-bf64-ce56-9ef28fcd24a2",
   "audio_source_url": "https://jqcv.gva.es/documents/161863165/167041107/B2+octubre+2023.mp3/e35ed67c-5732-a52b-5d21-6a4a2f0440d2",
   "pass_rule": "Per a ser APTE cal una puntuació global mínima de 60 sobre 100. Les àrees valen un 20 % (comprensió oral), un 20 % (comprensió escrita), un 15 % (estructures lingüístiques), un 20 % (expressió escrita) i un 25 % (expressió oral), i en cada una cal arribar al mínim: el 40 % en les quatre primeres i el 50 % en l'expressió oral.",
   "areas": [
    {
     "n": 1,
     "title": "Comprensió oral",
     "weight": 20,
     "duration": "20 minuts",
     "audio": true,
     "intro": "Tot seguit escoltaràs dos àudios. Tots els àudios els escoltaràs dos vegades, amb una pausa entre cada audició, perquè assegures les respostes. Només hi ha una resposta correcta per a cada pregunta.",
     "scoring": {
      "points_per_exercise": {
       "1": 8,
       "2": 12
      },
      "max_points": 100,
      "pass_points": 40
     },
     "exercises": [
      {
       "n": 1,
       "kind": "choice",
       "instructions": "A continuació escoltaràs una entrevista a Eva Miranda sobre la bellesa de les matemàtiques. Llig les preguntes i tria l'opció correcta en cada cas. Només hi ha una resposta correcta per a cada pregunta.",
       "questions": [
        {
         "n": 1,
         "prompt": "Segons Eva Miranda, podríem dir que les matemàtiques són…",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "un refugi que t'aïlla dels problemes quotidians de la vida real."
          },
          {
           "key": "b",
           "text": "una branca del coneixement que busca la solució de problemes."
          },
          {
           "key": "c",
           "text": "un llenguatge basat en fórmules que seguixen un orde concret."
          }
         ]
        },
        {
         "n": 2,
         "prompt": "Les matemàtiques no agraden o resulten difícils a molta gent perquè…",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "no els veuen una utilitat pràctica més enllà de fer operacions."
          },
          {
           "key": "b",
           "text": "es troben problemes oberts que mai s'acaben de resoldre."
          },
          {
           "key": "c",
           "text": "falta una bona pedagogia que ensenye bé este llenguatge."
          }
         ]
        },
        {
         "n": 3,
         "prompt": "La bellesa de les matemàtiques...",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "rau a descobrir allò que és essencial i a bandejar els elements secundaris."
          },
          {
           "key": "b",
           "text": "consistix a poder resoldre els detalls més complexos dels problemes."
          },
          {
           "key": "c",
           "text": "està en la connexió que tenen amb fets quotidians del nostre entorn."
          }
         ]
        },
        {
         "n": 4,
         "prompt": "Segons l'experta, quines aplicacions tenen les matemàtiques?",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "Servixen per a dissenyar sistemes de gestió de la informació."
          },
          {
           "key": "b",
           "text": "S'utilitzen per a configurar els codis ètics en el camp de la medicina."
          },
          {
           "key": "c",
           "text": "Són útils per a millorar l'expressió i la qualitat estètica de les obres d'art."
          }
         ]
        },
        {
         "n": 5,
         "prompt": "Què opina Eva Miranda sobre els sistemes d'intel·ligència artificial?",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "Que estan sotmesos a un control excessiu dels comités universitaris."
          },
          {
           "key": "b",
           "text": "Que s'han d'aprovar normes que en garantisquen un ús ètic."
          },
          {
           "key": "c",
           "text": "Que són un risc perquè poden controlar el funcionament d'armament."
          }
         ]
        }
       ]
      },
      {
       "n": 2,
       "kind": "binary",
       "instructions": "Llig els enunciats i relaciona'ls amb els consells que escoltaràs en les audicions per a previndre infeccions alimentàries per un ús inadequat dels ous. Tin en compte que hi ha dos enunciats que no corresponen a cap consell: marca «No surt» en eixos dos i numera els altres cinc de l'1 al 5 seguint l'orde en què apareixen en l'àudio.",
       "options": [
        {
         "key": "1",
         "text": "1"
        },
        {
         "key": "2",
         "text": "2"
        },
        {
         "key": "3",
         "text": "3"
        },
        {
         "key": "4",
         "text": "4"
        },
        {
         "key": "5",
         "text": "5"
        },
        {
         "key": "x",
         "text": "No surt"
        }
       ],
       "questions": [
        {
         "n": 6,
         "prompt": "Per a saber si els ous estan frescs, podem submergir-los en aigua i, si suren, no són aptes per al consum.",
         "answer": "5"
        },
        {
         "n": 7,
         "prompt": "Cal mirar la data de caducitat abans de comprar els ous, encara que els podem consumir una setmana després d'esta data.",
         "answer": "x",
         "scored": false
        },
        {
         "n": 8,
         "prompt": "Cal assegurar-nos que quan cuinem tinguem les mans netes i els utensilis de cuina estiguen lliures de brutícia.",
         "answer": "1"
        },
        {
         "n": 9,
         "prompt": "S'aconsella no rentar els ous després de comprar-los, només es poden rentar si a continuació els cuines.",
         "answer": "3"
        },
        {
         "n": 10,
         "prompt": "Cal que les persones delicades de salut o amb alguna afectació mèdica no mengen mai els ous crus.",
         "answer": "x",
         "scored": false
        },
        {
         "n": 11,
         "prompt": "La temperatura a què es guarden els ous ha de ser constant per a evitar la contaminació a través de la closca.",
         "answer": "2"
        },
        {
         "n": 12,
         "prompt": "Els ous s'han de cuinar a una temperatura alta i hem d'evitar que queden crus o poc quallats.",
         "answer": "4"
        }
       ]
      }
     ]
    },
    {
     "n": 2,
     "title": "Comprensió escrita",
     "weight": 20,
     "duration": "2 h 10 min (amb les àrees 3 i 4)",
     "scoring": {
      "points_per_exercise": {
       "3": 3.3,
       "4": 8.5
      },
      "max_points": 100,
      "pass_points": 40
     },
     "exercises": [
      {
       "n": 3,
       "kind": "match",
       "instructions": "Llig atentament el text següent i completa'l amb les propostes de la graella. Tin en compte que hi ha tres propostes que no has d'utilitzar.",
       "reading": {
        "title": "Animals salvatges",
        "paragraphs": [
         "Els ecosistemes són sistemes naturals formats per un conjunt d'organismes, pel medi físic on viuen i per les relacions que establixen entre ells i amb el medi. Estes relacions poden ser (13) ______ complexes, i també dinàmiques i adaptables. Per exemple, si un determinat depredador presenta unes preferències de temperatura i lluminositat per a caçar, les seues preses tenen la tendència a readaptar el seu comportament per a limitar al màxim les possibilitats d'una (14) ______ fortuïta. També hi ha animals que alteren el seu comportament per a evitar el contacte amb les persones. En una investigació recent s'ha comprovat que la massiva pressió del turisme fotogràfic a la sabana africana ha fet que molts grups de lleons aprofiten per a caçar al ple migdia, coincidint amb l'estona de dinar de les persones; (15) ______ caçaven en fer-se de dia o a poqueta nit.",
         "En esta mateixa busca, els investigadors van instal·lar càmeres en deu ciutats nord-americanes per a capturar imatges de les incursions que hi fan els animals salvatges que viuen relativament a prop per a buscar menjar o per a refugiar-se, i les han comparades amb el comportament dels que viuen (16) ______ en entorns poc o (17) ______ humanitzats; (18) ______, van examinar depredadors com coiots i linxs, animals que tenen una dieta més flexible, com els ossos rentadors, i també herbívors, com els conills.",
         "Els resultats que han obtingut (19) ______ que els depredadors de mida més gran, com els coiots i les raboses, tenen tendència a (20) ______ el seu cicle biològic diari i esdevindre més nocturns en entorns urbans. D'esta manera, poden buscar restes de menjar entre les deixalles al mateix temps que reduïxen la probabilitat de trobar-se amb les persones, que normalment els fan fora; (21) ______, els conills i els ossos rentadors avancen el seu cicle biològic ja que, a diferència dels carnívors, les persones no els acostumen a (22) ______.",
         "La principal conclusió que els investigadors (23) ______ d'este treball és que, en un ambient cada volta més humanitzat i urbanitzat, quan s'establixen programes de (24) ______, conservació i gestió de la natura s'han de tindre en compte estos canvis de comportament i d'hàbits dels animals, ja que influïxen en la dinàmica global dels ecosistemes i la fan encara més complexa. Segons diuen, el fet de no tindre'ls en compte pot explicar, com a mínim en part, la poca efectivitat de molts d'estos programes i les dificultats de gestió que se'n deriven. Possiblement, també es produïx un efecte similar amb els senglars que passegen al fer-se de nit per molts pobles i ciutats del nostre país."
        ]
       },
       "options_title": "Propostes",
       "options": [
        {
         "key": "a",
         "text": "gens"
        },
        {
         "key": "b",
         "text": "rarament"
        },
        {
         "key": "c",
         "text": "protecció"
        },
        {
         "key": "d",
         "text": "en canvi"
        },
        {
         "key": "e",
         "text": "indiquen"
        },
        {
         "key": "f",
         "text": "molt"
        },
        {
         "key": "g",
         "text": "endarrerir"
        },
        {
         "key": "h",
         "text": "tradicionalment"
        },
        {
         "key": "i",
         "text": "limitació"
        },
        {
         "key": "j",
         "text": "en concret"
        },
        {
         "key": "k",
         "text": "foragitar"
        },
        {
         "key": "l",
         "text": "topada"
        },
        {
         "key": "m",
         "text": "per tant"
        },
        {
         "key": "n",
         "text": "únicament"
        },
        {
         "key": "o",
         "text": "extrauen"
        }
       ],
       "questions": [
        {
         "n": 13,
         "prompt": "Buit 13",
         "answer": "f"
        },
        {
         "n": 14,
         "prompt": "Buit 14",
         "answer": "l"
        },
        {
         "n": 15,
         "prompt": "Buit 15",
         "answer": "h"
        },
        {
         "n": 16,
         "prompt": "Buit 16",
         "answer": "n"
        },
        {
         "n": 17,
         "prompt": "Buit 17",
         "answer": "a"
        },
        {
         "n": 18,
         "prompt": "Buit 18",
         "answer": "j"
        },
        {
         "n": 19,
         "prompt": "Buit 19",
         "answer": "e"
        },
        {
         "n": 20,
         "prompt": "Buit 20",
         "answer": "g"
        },
        {
         "n": 21,
         "prompt": "Buit 21",
         "answer": "d"
        },
        {
         "n": 22,
         "prompt": "Buit 22",
         "answer": "k"
        },
        {
         "n": 23,
         "prompt": "Buit 23",
         "answer": "o"
        },
        {
         "n": 24,
         "prompt": "Buit 24",
         "answer": "c"
        }
       ]
      },
      {
       "n": 4,
       "kind": "match",
       "instructions": "A continuació llegiràs set crítiques de cine. Relaciona cada una amb l'enunciat que li correspon. Hi ha tres enunciats que no corresponen a cap crítica cinematogràfica.",
       "options_title": "Enunciats",
       "options": [
        {
         "key": "a",
         "text": "Un triangle amorós ambientat en un país exòtic que acaba en tragèdia."
        },
        {
         "key": "b",
         "text": "La lluita per recuperar un vincle per damunt de tot acaba en drama."
        },
        {
         "key": "c",
         "text": "La creativitat que desenvolupa un jove per tal de fugir de la seua realitat."
        },
        {
         "key": "d",
         "text": "La protagonista és una dona forta que pren les regnes de la seua vida."
        },
        {
         "key": "e",
         "text": "Una complexa relació entre costures i tradició ambientada en un país exòtic."
        },
        {
         "key": "f",
         "text": "Les dificultats actuals d'una dona marcades per l'atzar del passat."
        },
        {
         "key": "g",
         "text": "Una història autobiogràfica que mostra les dificultats per a arribar a l'èxit."
        },
        {
         "key": "h",
         "text": "Les decisions que pren la protagonista determinaran la seua vida laboral."
        },
        {
         "key": "i",
         "text": "La costa és l'escenari on una dona reviu el fantasma de les decisions passades."
        },
        {
         "key": "j",
         "text": "La força de l'enginy d'un jove per a sobreviure enmig de les dificultats històriques."
        }
       ],
       "questions": [
        {
         "n": 25,
         "prompt": "En El caftà blau, la cineasta Maryam Touzani no fa cap puntada sense fil. Amb escassos ingredients, la directora tix un drama tan delicat com el prim fil d'or amb què Halim, el sastre protagonista, broda les trenes que decoren el vestit tradicional marroquí que dona títol a la pel·lícula. En esta història d'amor entre un matrimoni que regenta una sastreria tradicional a la medina de Salé i el jove aprenent que arriba per a ajudar-los, el drama es construïx, a poc a poc, a partir dels gestos i de les mirades dels protagonistes.",
         "answer": "e"
        },
        {
         "n": 26,
         "prompt": "Este drama té la capacitat d'evocar l'univers social i geogràfic de la classe blanca treballadora del sud-oest dels Estats Units a partir dels espais i d'una banda sonora plena d'èxits country. Trobem la presència d'una protagonista complexa que construïx un equilibri perfecte entre moments d'explosió gestual i d'altres marcats per una immobilitat dolorosa, que expressa una intensa fractura interior. To Leslie és la història d'una dona que es va beure tots els diners que va guanyar a la loteria i que després d'anys de separació intenta, desesperadament, reconnectar amb el seu fill.",
         "answer": "f"
        },
        {
         "n": 27,
         "prompt": "Sola en unes vacacions a la vora del mar, Leda, la protagonista de La filla obscura, s'hi veu consumida per una jove mare i la seua filla, a les quals observa amb deteniment des de la platja. Intrigada per l'atractiva relació que tenen, Leda se sent aclaparada pels seus propis records del terror, per la confusió i per la intensitat de la maternitat primerenca. Un acte impulsiu porta Leda a submergir-se en l'estrany i ominós món de la seua ment, on es veu obligada a enfrontar-se a les decisions poc convencionals que prengué com a mare jove i a les conseqüències d'esta situació.",
         "answer": "i"
        },
        {
         "n": 28,
         "prompt": "Ambientada en una illa remota davant de la costa oest d'Irlanda en 1923, Ànimes en pena d'Inisherin narra la història de dos amics de tota la vida, Pádraic i Colm, que es troben en un carreró sense eixida. Un dia, Colm decidix posar fi a la seua amistat d'una manera sobtada i incomprensible. Un Pádraic atònit s'esforça per a reconstruir la relació que tenien i es nega a acceptar el silenci del seu amic de la infància. Quan Colm planteja a Pádraic un ultimàtum desesperat, els esdeveniments es precipiten i provoquen conseqüències traumàtiques.",
         "answer": "b"
        },
        {
         "n": 29,
         "prompt": "Els Fabelman és un film semiautobiogràfic que narra la infància i joventut del cineasta Steven Spielberg. Ambientada a finals de la dècada de 1950 i principis dels anys 60, un xiquet d'Arizona que es diu Sammy Fabelman, influït per la seua excèntrica mare -artista de professió- i el seu pragmàtic pare -un enginyer informàtic-, descobrix un secret familiar devastador. Este descobriment el porta a voler explorar i llavors és quan s'adona com el poder de les pel·lícules de cine pot ajudar-lo a contar històries i a forjar la seua pròpia identitat.",
         "answer": "c"
        },
        {
         "n": 30,
         "prompt": "Berlín, 1942. Cioma Schönhaus és un jove jueu de 21 anys que s'ha proposat que ningú, ni tan sols les autoritats nazis, li puguen furtar el seu entusiasme per la vida. Per a escapar de la deportació imminent, Cioma utilitza la identitat d'un oficial de la Marina, i d'esta manera descobrix que té un talent ocult per a falsificar no només passaports i documents oficials, sinó també la seua pròpia identitat. El falsificador de passaports és la història d'un supervivent de l'Holocaust i mostra, en tot moment, malgrat que en un segon pla, la guerra i les seues condicions.",
         "answer": "j"
        },
        {
         "n": 31,
         "prompt": "En Tár, la directora d'orquestra mundialment famosa Lydia Tár, interpretada magníficament per la gran Cate Blanchett, està a pocs dies d'afrontar el repte més gran de la seua carrera professional: ha de gravar la simfonia que la pot portar a les altures de la seua ja formidable trajectòria musical. Lydia Tár és una directora famosa que personifica el poder i l'elegància. Ara bé, la seua vida personal i les decisions que pren interferixen progressivament en la seua carrera musical amb unes conseqüències del tot imprevisibles.",
         "answer": "h"
        }
       ]
      }
     ]
    },
    {
     "n": 3,
     "title": "Estructures lingüístiques",
     "weight": 15,
     "duration": "2 h 10 min (amb les àrees 2 i 4)",
     "scoring": {
      "points_per_exercise": {
       "5": 5,
       "6": 5
      },
      "max_points": 100,
      "pass_points": 40
     },
     "exercises": [
      {
       "n": 5,
       "kind": "choice",
       "instructions": "En el text següent s'han eliminat algunes paraules. Per a cada espai en blanc tens tres opcions de resposta. Només una és correcta. Fixa't en l'exemple (número 0).",
       "reading": {
        "title": "Regal",
        "paragraphs": [
         "Una estudiant, no recorde si de filologia o de periodisme, va vindre a casa a fer-me una entrevista. Li havien manat fer un treball sobre un escriptor viu i ella, ignore per què, m'havia triat i m'ho havia proposat per correu electrònic. Vam quedar un dissabte (0) a la vesprada, que ella no tenia classe i jo no havia de treballar.",
         "(32) ______ han fet moltes, d'entrevistes, ja no les prepare. Sempre és, però, incòmode rebre algú que no coneixes, (33) ______ no tens confiança. T'has d'arreglar, no pots atendre amb xandall o, com feia sovint Fuster, amb bata, algú que et farà fotografies i qui sap on les penjarà. No vols donar una imatge negligent de tu mateix. Hi ha l'amor propi i, (34) ______ cada dia menys, la vanitat. No sé fins a quin punt és bo, açò últim. Per una part, saber-se insignificant, prescindible i breu fa que restes importància a quasi tot, i això t'estalvia maldecaps; d'altra banda, sense una mica de vanitat és difícil emprendre projectes de gruix, que tensen la vida.",
         "Era bastant més alta que jo, semblava tímida. Després dels convencionalismes de rigor vam seure, vam beure te verd, ella engegà una gravadora (35) ______ deixà damunt del Schopenhauer, i vam iniciar una conversa llarga sobre els meus llibres i sobre tot el que ella, amb un guió manuscrit damunt les cuixes, preguntava. Era intel·ligent, sabia escoltar i ho sabia copsar tot de primeres, no vaig haver de repetir ni d'especificar el que deia. Feia que sí, (36) ______, amb el cap, diria que amb un punt d'admiració.",
         "Al final de l'agradable conversa, quasi monòleg, abans que (37) ______, vaig voler regalar-li algun dels meus llibres. Vaig preguntar (38) ______ li faltava. Ella, cohibida, va dir que no calia, que se'l podia comprar. “Tens este?”, vaig insistir (39) ______ mostrar-li l'últim que havia publicat. “No, este encara no”, feu. Li vaig estampar una elaborada dedicatòria i li'l vaig posar en les mans. Ella l'introduí amb cura, sense obrir-lo, dins la bossa de pell on havia guardat la gravadora i el guió manuscrit.",
         "Quan va eixir al carrer, la vaig observar, sense que ella ho (40) ______, des del balcó. Vaig veure com deixava la bossa de pell damunt d'un cotxe, com s'ajustava el pantaló i s'allisava la camiseta, i com caminava desimbolta. En arribar a l'altura del contenidor blau, el de paper i cartó, va mirar cap als dos costats del carrer, va traure (41) ______ de la bossa el llibre que li havia regalat i el llançà a dins."
        ]
       },
       "questions": [
        {
         "n": 32,
         "prompt": "Buit 32",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "M'"
          },
          {
           "key": "b",
           "text": "M'hi"
          },
          {
           "key": "c",
           "text": "Me'n"
          }
         ],
         "scored": false
        },
        {
         "n": 33,
         "prompt": "Buit 33",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "amb què"
          },
          {
           "key": "b",
           "text": "amb el que"
          },
          {
           "key": "c",
           "text": "amb qui"
          }
         ]
        },
        {
         "n": 34,
         "prompt": "Buit 34",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "tant de bo"
          },
          {
           "key": "b",
           "text": "tot i que"
          },
          {
           "key": "c",
           "text": "com que"
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
           "text": "que"
          },
          {
           "key": "b",
           "text": "la qual cosa"
          },
          {
           "key": "c",
           "text": "la qual"
          }
         ]
        },
        {
         "n": 36,
         "prompt": "Buit 36",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "en tant en quan"
          },
          {
           "key": "b",
           "text": "de tan en tan"
          },
          {
           "key": "c",
           "text": "de tant en tant"
          }
         ]
        },
        {
         "n": 37,
         "prompt": "Buit 37",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "s'anara"
          },
          {
           "key": "b",
           "text": "se n'anara"
          },
          {
           "key": "c",
           "text": "s'hi anara"
          }
         ]
        },
        {
         "n": 38,
         "prompt": "Buit 38",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "el què"
          },
          {
           "key": "b",
           "text": "què"
          },
          {
           "key": "c",
           "text": "quin"
          }
         ]
        },
        {
         "n": 39,
         "prompt": "Buit 39",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "a"
          },
          {
           "key": "b",
           "text": "en"
          },
          {
           "key": "c",
           "text": "amb"
          }
         ]
        },
        {
         "n": 40,
         "prompt": "Buit 40",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "sabera"
          },
          {
           "key": "b",
           "text": "sapiguera"
          },
          {
           "key": "c",
           "text": "sapiera"
          }
         ]
        },
        {
         "n": 41,
         "prompt": "Buit 41",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "'n"
          },
          {
           "key": "b",
           "text": "Ø"
          },
          {
           "key": "c",
           "text": "hi"
          }
         ]
        }
       ]
      },
      {
       "n": 6,
       "kind": "choice",
       "instructions": "En el text següent s'han eliminat algunes paraules. Per a cada espai en blanc tens tres opcions de resposta. Només una és correcta. Fixa't en l'exemple (número 0).",
       "reading": {
        "title": "De viatge per la Plana Baixa",
        "paragraphs": [
         "Un viatger que vinguera del nord descobriria, en passar la ciutat de Castelló de la Plana cap a València, una àmplia superfície de terra cultivada amb tarongers, tancada en gran part per la (0) serralada d'Espadà. La part baixa de la comarca de la Plana es caracteritza pel contrast entre el (42) ______ del pla i les discretes rutes que de seguida s'(43) ______ en les àrdues però mesurades costeres muntanyenques. Un territori amb una acusada personalitat que mereix una visita reposada. Proposem començar-la pel municipi de la Vall d'Uixó.",
         "Hi ha muntanyes màgiques on per a assaltar els cels és necessari escalar el (44) ______ més escarpat d'un mateix. Altres vegades, no obstant això, el viatge ha de ser cap a la profunditat, i en eixe cas no sempre cal esperar que esta immersió siga només metafòrica. A la Vall d'Uixó, al sud de la comarca de la Plana Baixa, es pot visitar el riu subterrani navegable més llarg d'Europa.",
         "Al riu s'accedix pel paratge conegut com les coves de Sant Josep, a les portes del parc natural de la serra d'Espadà. A vegades la naturalesa ens satisfà de (45) ______ per excés: riu i serra són dues meravelles que mereixen una visita, extensible fàcilment a altres municipis de la comarca. El conjunt de coves que alberga este curs fluvial es va formar durant el triàsic, fa la barbaritat de 250 milions d'anys. L'origen i el final del riu encara ens resulten desconeguts. Actualment és navegable en la major part dels seus quasi tres quilòmetres d'extensió. La temperatura allí dins, com en un (46) ______ perfecte, ronda sempre els vint graus. Les excavacions arqueològiques realitzades in situ ens (47) ______ que este conjunt de coves va ser habitat des del paleolític superior. Els romans van canalitzar-ne l'aigua fins a la part baixa de la vall, i la van usar per a consum i regadiu i com a força motriu de molins. L'ús del riu interior com a referència turística no comença fins als anys trenta del segle passat. L'Ajuntament de la Vall d'Uixó ha aprofitat les potencialitats del lloc per a organitzar activitats com Singing in the Cave, cicles de suggestius concerts en el ventre petri de la muntanya.",
         "A fora, al visitant l'espera la meravella de la serra d'Espadà. Es tracta d'un dels contraforts més orientals del sistema Ibèric, un espai natural realment prodigiós pels seus nivells de conservació. De les seues sureres es trau suro de gran valor ecològic i, dels seus pins, resina. A més, està poblada per un valuós (48) ______ de plantes endèmiques, de gran interés científic. En el capítol de la fauna, cal esmentar diverses espècies amfíbies, rèptils i ocells (49) ______, així com setze varietats diferents de (50) ______, algunes de les quals en greu perill d'extinció. Al cor del gran bosc d'Espadà s'hi pot accedir per Alfondeguilla, venint de la Vall d'Uixó o, des de Nules i la Vilavella, per un itinerari d'elevació espiritual que inclou Eslida, Artana i Aín. El visitant quedarà (51) ______ davant la postal d'estos pobles."
        ]
       },
       "questions": [
        {
         "n": 42,
         "prompt": "Buit 42",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "verdor"
          },
          {
           "key": "b",
           "text": "verger"
          },
          {
           "key": "c",
           "text": "vertigen"
          }
         ]
        },
        {
         "n": 43,
         "prompt": "Buit 43",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "endinsen"
          },
          {
           "key": "b",
           "text": "endenyen"
          },
          {
           "key": "c",
           "text": "engeguen"
          }
         ]
        },
        {
         "n": 44,
         "prompt": "Buit 44",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "vesant"
          },
          {
           "key": "b",
           "text": "aiguavés"
          },
          {
           "key": "c",
           "text": "vessant"
          }
         ]
        },
        {
         "n": 45,
         "prompt": "Buit 45",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "bens"
          },
          {
           "key": "b",
           "text": "vens"
          },
          {
           "key": "c",
           "text": "béns"
          }
         ]
        },
        {
         "n": 46,
         "prompt": "Buit 46",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "celler"
          },
          {
           "key": "b",
           "text": "desllunat"
          },
          {
           "key": "c",
           "text": "safareig"
          }
         ]
        },
        {
         "n": 47,
         "prompt": "Buit 47",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "rebel·len"
          },
          {
           "key": "b",
           "text": "revelen"
          },
          {
           "key": "c",
           "text": "revetlen"
          }
         ]
        },
        {
         "n": 48,
         "prompt": "Buit 48",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "manoll"
          },
          {
           "key": "b",
           "text": "toll"
          },
          {
           "key": "c",
           "text": "matoll"
          }
         ]
        },
        {
         "n": 49,
         "prompt": "Buit 49",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "rapasos"
          },
          {
           "key": "b",
           "text": "rapassos"
          },
          {
           "key": "c",
           "text": "rapaços"
          }
         ]
        },
        {
         "n": 50,
         "prompt": "Buit 50",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "rata penada"
          },
          {
           "key": "b",
           "text": "rata-penada"
          },
          {
           "key": "c",
           "text": "ratapenada"
          }
         ]
        },
        {
         "n": 51,
         "prompt": "Buit 51",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "abatut"
          },
          {
           "key": "b",
           "text": "corprés"
          },
          {
           "key": "c",
           "text": "corcat"
          }
         ]
        }
       ]
      }
     ]
    },
    {
     "n": 4,
     "title": "Expressió i interacció escrites",
     "weight": 20,
     "duration": "2 h 10 min (amb les àrees 2 i 3)",
     "exercises": [
      {
       "n": 7,
       "kind": "writing",
       "title": "Redacció",
       "instructions": "Tria una de les dos opcions i redacta un text que tinga entre 180 i 220 paraules.",
       "min_words": 180,
       "max_words": 220,
       "choices": [
        {
         "key": "A",
         "text": "El phubbing és un nou concepte que es referix a l'acció d'ignorar les persones que tens al teu voltant i de prestar només atenció al telèfon mòbil. Consistix en una dependència psicològica del telèfon que provoca que es descuiden els vincles personals, les converses cara a cara i l'activitat física. A més suposa un comportament poc cívic. Fa uns dies vas quedar en una cafeteria amb un grup d'amics que feia temps que no veies. La major part del temps se'l van passar mirant el mòbil, fet que t'ha molestat especialment. Pràcticament no vau parlar i vas haver d'anul·lar un compromís per a quedar amb ells. Decidixes escriure'ls un correu electrònic en què tractes este tema. El text ha d'incloure els punts següents:",
         "points": [
          "Expressa indignació per la falta de respecte que van mostrar en la quedada.",
          "Explica de quina manera esta pràctica afecta les relacions personals.",
          "Suggerix alternatives per a pròximes reunions en què el mòbil no siga un problema."
         ]
        },
        {
         "key": "B",
         "text": "Els bons restaurants no solament han d'oferir menjar de qualitat, proporcionar als consumidors bones experiències i oferir un entorn acollidor amb una bona atenció. A més, actualment també és important que tinguen una bona valoració per part dels clients. Treballes en un restaurant i fa uns dies una persona que assegurava ser un youtuber hi va anar a dinar, i va proposar que se'l convidara a canvi de fer una valoració positiva del local. Com que et vas negar ha publicat una ressenya negativa en internet. Decidixes publicar una resposta a la ressenya en què tractes este tema. El text ha d'incloure els punts següents:",
         "points": [
          "Mostra indignació per la situació viscuda en el restaurant i les seues conseqüències.",
          "Explica de quina manera esta pràctica poc ètica afecta els restaurants.",
          "Valora la importància desmesurada que donem a les opinions dels altres consumidors."
         ]
        }
       ]
      },
      {
       "n": 8,
       "kind": "writing",
       "title": "Entrada de blog",
       "instructions": "Un dels pilars de les finances personals és estalviar. Tanmateix, quan es vol iniciar el procés sempre existixen circumstàncies que no permeten que l'estalvi cresca al ritme que t'havies proposat. A partir d'esta infografia, i com que este fet afecta moltes persones que coneixes, decidixes escriure una entrada en el teu blog en què dones algunes recomanacions que ajudaran la gent a estalviar. Explica quins són els consells que et funcionen a tu quan necessites estalviar. El text ha de tindre entre 120 i 140 paraules.",
       "min_words": 120,
       "max_words": 140,
       "image": "/exams/b2-octubre-2023/e8-estalvi.jpg",
       "image_text": "Infografia «Vols estalviar i no saps com fer-ho?» (il·lustració d'una família al costat d'una guardiola i icones de casa, menjar, estudis i salut). «Recomanacions per a elaborar una pla d'estalvi efectiu»: fes un pressupost mensual; demana crèdits de forma responsable; aprofita bé els diners extra; reduïx al mínim les despeses; disminuïx les despeses de la casa."
      }
     ]
    },
    {
     "n": 5,
     "title": "Expressió i interacció orals",
     "weight": 25,
     "duration": "25 minuts",
     "intro": "Esta àrea té dos parts: un monòleg d'uns tres minuts sobre un tema que tries i un diàleg d'uns quatre minuts amb una altra persona aspirant, en què cal arribar a un acord.",
     "exercises": [
      {
       "n": 9,
       "kind": "oral",
       "instructions": "Has de triar un tema i preparar un monòleg de tres minuts, aproximadament.",
       "proposals": [
        {
         "title": "Monòleg · La nomofòbia",
         "duration": "3 minuts",
         "intro": "Cada dia apareixen termes nous relacionats amb les noves tecnologies que ben prompte formen part de les converses diàries. Un d'estos termes és la nomofòbia, això és, l'ansietat o la por irracional de no tindre el mòbil a l'abast i sentir-se desconnectat; ara per ara, s'ha convertit en un trastorn que afecta gran part de la població. Explica quines poden ser les conseqüències socials d'este trastorn i quin sector de la població s'hi pot sentir més afectat.",
         "questions": [],
         "images": []
        },
        {
         "title": "Monòleg · Les amistats rituals",
         "duration": "3 minuts",
         "intro": "Tota la gent té un grup d'amics i amigues que només veu un parell de vegades a l'any. Es tracta d'una cita obligatòria, d'un ritual en forma de dinar o de sopar que s'ha de complir. L'amistat que es té amb este grup és diferent de la que es té amb persones més pròximes, perquè no s'hi busca una relació pregona, només un contacte circumstancial. Explica els beneficis, i també els maldecaps, que pot comportar tindre un grup d'amics i amigues amb qui practicar este tipus de ritual d'amistat.",
         "questions": [],
         "images": []
        }
       ]
      },
      {
       "n": 10,
       "kind": "oral",
       "instructions": "Has de mantindre un diàleg amb un altre o una altra aspirant sobre la situació comunicativa que et proposem. Has de defensar el paper de la teua persona i has d'arribar a un acord obligatòriament amb l'altre o l'altra aspirant. Has de participar com ho faries en una conversa habitual i les intervencions han de ser equilibrades. La duració de la conversa serà de quatre minuts, aproximadament.",
       "proposals": [
        {
         "title": "Diàleg · La telemedicina",
         "duration": "4 minuts",
         "intro": "La telemedicina i les consultes mèdiques a través de mitjans en línia ja són una realitat. L'Organització Mundial de la Salut (OMS) definix la telemedicina com l'aportació de serveis de salut amb l'ús de les noves tecnologies de la comunicació per al diagnòstic, el tractament i la prevenció de malalties o lesions.",
         "questions": [],
         "images": [],
         "roles": [
          {
           "name": "Persona A",
           "text": "Penses que els recursos tecnològics optimitzen l'atenció, estalvien temps i costos i augmenten l'accessibilitat."
          },
          {
           "name": "Persona B",
           "text": "Penses que una atenció presencial és més eficaç, a més, no tota la població té accés a les noves tecnologies."
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
