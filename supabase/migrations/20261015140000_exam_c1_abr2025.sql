-- Examen interactiu C1 de la JQCV (abril 2025) com a recurs de category 'examen'.
-- Contingut a metadata.exam, amb les quatre àrees del C1 i la puntuació de la guia de la prova
-- (comprensió escrita 10 %, 5 preguntes de 20 punts; estructures lingüístiques 20 %, 30 buits;
-- expressió escrita 35 % i expressió oral 35 %; mínim del 20 %, el 40 % i el 50 % segons el pes de
-- l'àrea). Les respostes són les de la plantilla oficial que inclou el quadern. Les redaccions es
-- corregixen amb la rúbrica C1; les infografies de l'exercici 5 són a frontend/public/exams/.
-- Font: https://jqcv.gva.es/documents/161863165/165492633/C1+abril+2025.pdf/229cec57-2eb8-aa01-9952-5585730994cf

INSERT INTO public.resources (id, name, type, url, content, metadata, xp_earned, difficulty, category)
SELECT id, name, type, url, content, metadata, xp_earned, difficulty, category
FROM jsonb_populate_record(NULL::public.resources, $data${
 "id": "9d49baae-5d61-53c7-bf1f-eedeb7904bf4",
 "name": "Simulacre C1: abril 2025",
 "type": "jqcv_c1_abr2025",
 "category": "examen",
 "difficulty": "C1",
 "xp_earned": 40,
 "content": "Examen oficial C1 de la JQCV (abril 2025): comprensió escrita i estructures lingüístiques autocorregibles, dos redaccions i pràctica oral.",
 "metadata": {
  "icon": "📰",
  "color": "#B3E5FC",
  "exam_body": "JQCV",
  "certificate_level": "C1",
  "exam": {
   "level": "C1",
   "session": "Abril 2025",
   "body": "JQCV",
   "source_url": "https://jqcv.gva.es/documents/161863165/165492633/C1+abril+2025.pdf/229cec57-2eb8-aa01-9952-5585730994cf",
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
       "instructions": "Llig atentament este text i tria l’opció correcta (a, b, c o d). Tin en compte que, per a cada qüestió plantejada, només hi ha una resposta correcta. Fixa’t en l’exemple (número 0).",
       "reading": {
        "title": "Contra la sostenibilitat",
        "paragraphs": [
         "Durant anys he defés el terme de sostenibilitat. La seua integritat, la seua utilitat. N’he explicat els orígens i el potencial, la capacitat d’entroncar amb conceptes transformadors d’educació ambiental i provocar canvis transversals. La qualitat que té de brúixola i cantimplora, com aquella utopia que escrivia Eduardo Galeano, que mai assolirem, però que ens permet avançar. Igual que el Sant Grial ens obria les portes d’una eterna joventut ambiental, social i econòmica: si era sostenible significava que no s’havia d’acabar! Quina promesa millor que esta, quin futur més desitjable que aquell en què sempre podríem fer el que voldríem sense esgotar el demà!",
         "Tot el món ha anhelat durant dècades trobar esta pedra filosofal, capaç de transformar la sobrepesca en dofins somrients, la rompuda de terres en avitardes felices, els tubs d’escapament en escocells plens de flors i abelles. No obstant això, en algun moment del camí, alguns es van adonar que, en lloc de dedicar més temps, esforços i diners en este camí cap a la sostenibilitat anhelada, era més fàcil, simplement, tractar d’imitar-la. Pintar-ho tot de verd, invertir més en el departament de màrqueting que en el de medi ambient, influir per a aconseguir lleis menys dures i ambicioses, i estar així sempre a l’avantguarda d’estes. En un camí invers a la utopia de Galeano, van atraure la sostenibilitat cap als seus peus, per a poder així anar retrocedint fins a afonar-nos en el fangar a on ens trobem ara immersos.",
         "Algunes veus, provinents majoritàriament de l’ecologisme primigeni i de departaments universitaris, van impugnar des del seu mateix naixement el concepte de desenvolupament sostenible, del qual es derivaria el de sostenibilitat, al seu torn. Moltes d’estes crítiques trobaven el seu germen en l’informe sobre els límits del creixement publicat el 1972 pel Massachusetts Institute of Technology. El que este informe qüestionava era el concepte mateix de creixement, i la seua perversa i interessada sinonímia amb el de desenvolupament. En ple procés conegut com a Gran Acceleració, en què la dimensió econòmica i energètica de la humanitat va pegar un estiró sense precedents, les costures biofísiques del planeta van començar a acusar-ne la tensió. La preocupació per la seua resistència —i el món que ens quedaria després d’un esclafit— justificava sobradament les anàlisis gens optimistes que es van fer sobre la possibilitat de seguir aquell ritme de creixement exponencial.",
         "Per a esquivar la impossibilitat física de mantindre un creixement infinit en un planeta finit es va encunyar el terme desenvolupament sostenible. Les seues línies mestres consistien a incorporar el futur en les decisions del present, mirar més enllà dels nostres nassos en l’àmbit ambiental, però també en l’àmbit econòmic i social, ser conscients del llegat i de l’impacte que estàvem tenint. Aquella era, sens dubte, una visió valuosa, encara més en un moment en què el món estava immers en la Guerra Freda i el reaganisme marcava el pas. Així doncs, les esperances de diverses generacions d’activistes, polítics i acadèmics van cristal·litzar en aquell concepte, perillosament dúctil fins i tot després que l’ONU n’encunyara esta definició formal: “Satisfer les necessitats de les generacions presents sense comprometre les possibilitats de les generacions futures d’atendre les seues pròpies necessitats.”",
         "En cap moment es qüestionaven ni es definien les “necessitats de generacions presents”. De quines generacions parla exactament? Perquè, encara que compartisquen espai i temps en este planeta, les necessitats autopercebudes d’un estatunidenc ric i d’una marroquina pobra —per posar-ne un exemple entre els milers possibles— són dramàticament diferents.",
         "La segona part de la frase insistix en la confusió: sense comprometre les possibilitats de les generacions futures d’atendre les pròpies necessitats. D’acord. I si per satisfer-les limiten les opcions dels que vinguen després? De quant de temps després parlem exactament? En quin moment una generació deixa de ser futura i entra en al terreny térbol de l’especulació? Amb totes estes preguntes sense una resposta clara, l’excusa perfecta per a la procrastinació està servida: “ja s’apanyaran. Alguna cosa inventaran. Nosaltres també ho vam tindre difícil i ens va tocar bregar amb problemes de tota mena”."
        ]
       },
       "questions": [
        {
         "n": 0,
         "prompt": "Durant molt de temps l’autor...",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "dubtava que la sostenibilitat engendrara canvis."
          },
          {
           "key": "b",
           "text": "no estava segur del significat de sostenibilitat."
          },
          {
           "key": "c",
           "text": "entenia la sostenibilitat com un horitzó."
          },
          {
           "key": "d",
           "text": "s’oposava als postulats d’Eduardo Galeano."
          }
         ],
         "scored": false
        },
        {
         "n": 1,
         "prompt": "En el camí en busca de la sostenibilitat...",
         "answer": "d",
         "options": [
          {
           "key": "a",
           "text": "s’han utilitzat campanyes de màrqueting per a divulgar."
          },
          {
           "key": "b",
           "text": "hi ha hagut propostes ambientals de caràcter esotèric."
          },
          {
           "key": "c",
           "text": "les empreses han presentat alternatives transformadores."
          },
          {
           "key": "d",
           "text": "alguns s’han apropiat del terme per a ressignificar-lo."
          }
         ]
        },
        {
         "n": 2,
         "prompt": "Algunes veus provinents de l’ecologisme primigeni i de departaments universitaris...",
         "answer": "d",
         "options": [
          {
           "key": "a",
           "text": "van associar perversament sostenibilitat a desenvolupament."
          },
          {
           "key": "b",
           "text": "van bandejar la sostenibilitat dels estudis acadèmics."
          },
          {
           "key": "c",
           "text": "van entroncar amb el concepte de desenvolupament sostenible."
          },
          {
           "key": "d",
           "text": "van polemitzar el contínuum desenvolupament sostenible i sostenibilitat."
          }
         ]
        },
        {
         "n": 3,
         "prompt": "Durant el procés de la Gran Acceleració...",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "es va evitar anomenar el desenvolupament sostenible."
          },
          {
           "key": "b",
           "text": "el planeta va demostrar tindre uns límits biofísics."
          },
          {
           "key": "c",
           "text": "els sistemes econòmics i energètics entraren en recessió."
          },
          {
           "key": "d",
           "text": "el debat sobre el creixement infinit va ser central."
          }
         ]
        },
        {
         "n": 4,
         "prompt": "El concepte de desenvolupament sostenible...",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "va implicar canvis imminents en l’àmbit econòmic i social."
          },
          {
           "key": "b",
           "text": "traslladava els canvis importants al futur."
          },
          {
           "key": "c",
           "text": "fou menystingut en el context del seu naixement."
          },
          {
           "key": "d",
           "text": "va ser rebatut per una àmplia majoria de la societat."
          }
         ]
        },
        {
         "n": 5,
         "prompt": "La definició de l’ONU sobre el desenvolupament sostenible...",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "aigualix l’acció present, cosa que comprometrà la vida futura."
          },
          {
           "key": "b",
           "text": "presenta el xoc d’interessos de classe a escala mundial."
          },
          {
           "key": "c",
           "text": "unifica les necessitats de la humanitat present i futura."
          },
          {
           "key": "d",
           "text": "ajorna necessitats del present perquè es desenvolupen en un futur sostenible."
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
        "title": "El mapamundi de l’Antropocé",
        "paragraphs": [
         "No sempre hem sabut quina forma tenia el món. Quins eren els seus límits, amb quins colors pintar muntanyes i valls. Tenien nom aquelles terres llunyanes? (0) Hi vivia algú? L’oceà (6) ______ monstres inimaginables, que atemorien els navegants i poblaven els contes infantils i els relats de les tavernes marítimes.",
         "Afaiçonar el món en l’argila, el pergamí, el paper o la pantalla ha sigut un impuls que ens ha acompanyat des de fa mil·lennis. Des de l’esquemàtic primer mapamundi babiloni de fa 2.700 anys fins a Google Maps, passant per la geografia de Ptolemeu, el mapamundi de fra Mauro o el bellíssim Orbis terrarum nova et accuratissima tabula (1658) de Nicolaes Visscher, (7) ______ el món encara roman inacabat. Ens costà més de 2.000 anys tancar les línies del mapa, delimitar en el paper i en la ment a on es trobava cada continent. I ara, (8) ______ tres segles després d’haver-ho aconseguit, hem de tornar a traçar la línia del món.",
         "Des de l’estrena de la pel·lícula Jurassic Park, (9) ______ 1993, el nivell del mar ha pujat mig pam. Sembla poc, però no ho és: deu centímetres són la diferència entre (10) ______ i la catàstrofe. Des de principis del segle passat són ja dos pams i mig: (11) ______ trenta centímetres. Els mapes que tan delicadament hem confeccionat comencen —mai millor dit— a fer aigües. (12) ______ és cert que les costes d’(13) ______ del món han sofrit modificacions notables per les infraestructures que s’hi han construït, l’amenaça que ara plana sobre estes és d’una dimensió distinta, descomunal.",
         "Hi ha relats sobre la pujada del nivell del mar en els inicis de l’Holocé (fa entre 12.000 i 7.000 anys) que encara sobreviuen a la cultura oral d’algunes comunitats, com la dels aborígens australians. (14) ______ les cròniques de l’actual ascens de l’aigua no resistisquen tant —qui sap a on estarà la humanitat (15) ______ tant de temps!—, però sens dubte estaran ben documentades.",
         "Uns quants illots del Pacífic, en les illes Salomó, fa anys que van desaparéixer. A São Tomé i Príncipe ja estan planificant el trasllat de poblacions (16) ______ l’interior, a causa dels riscos climàtics. Al Regne Unit han quantificat en (17) ______ les cases i els negocis en risc. A França estan començant a preguntar-se què fer, perquè tenen una línia de costa particularment vulnerable a la pujada del nivell del mar. A Bangladesh, la salinització dels cultius afecta (18) ______ centenars de milers d’agricultors, i alguns han hagut de reconvertir-se a aqüicultors. El 2022 Venècia va activar un caríssim sistema de barreres artificials per tal de protegir la ciutat en moments d’acqua alta. Els pols nord i sud muten any (19) ______ any, amb la superfície tacada de blanc, i es fan més menuts en una espiral sense fre.",
         "Sembla palés que redibuixar els mapes no és una opció, sinó una comesa que haurem de complir ara i adés. Ara bé, encara estem a temps de decidir com serà el mapamundi de l’Antropocé. Podem i hem de decidir si els mapes del futur estaran (20) ______ d’indicacions d’infraestructures fòssils i urbs mig negades, o si, ara i adés, reflectiran un procés lent i costós, però exitós, de retirada i convivència. No és tard per a aconseguir que la cartografia de l’Antropocé oferisca una crònica visual de l’assumpció dels límits i la realitat per part de les societats humanes del segle xxi."
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
           "text": "l’assorraven"
          },
          {
           "key": "b",
           "text": "el solcaven"
          },
          {
           "key": "c",
           "text": "el suraven"
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
           "text": "en el que"
          },
          {
           "key": "b",
           "text": "en què"
          },
          {
           "key": "c",
           "text": "al que"
          }
         ]
        },
        {
         "n": 8,
         "prompt": "Buit 8",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "no més"
          },
          {
           "key": "b",
           "text": "a soles"
          },
          {
           "key": "c",
           "text": "tant sols"
          }
         ]
        },
        {
         "n": 9,
         "prompt": "Buit 9",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "al"
          },
          {
           "key": "b",
           "text": "a l’any"
          },
          {
           "key": "c",
           "text": "en"
          }
         ]
        },
        {
         "n": 10,
         "prompt": "Buit 10",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "l’esglai"
          },
          {
           "key": "b",
           "text": "la melangia"
          },
          {
           "key": "c",
           "text": "la xafogor"
          }
         ]
        },
        {
         "n": 11,
         "prompt": "Buit 11",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "entorn"
          },
          {
           "key": "b",
           "text": "sobre"
          },
          {
           "key": "c",
           "text": "vora"
          }
         ]
        },
        {
         "n": 12,
         "prompt": "Buit 12",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "Si bé"
          },
          {
           "key": "b",
           "text": "Com que"
          },
          {
           "key": "c",
           "text": "Igualment"
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
           "text": "arran"
          },
          {
           "key": "b",
           "text": "arreu"
          },
          {
           "key": "c",
           "text": "arraïl"
          }
         ]
        },
        {
         "n": 14,
         "prompt": "Buit 14",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "Pot ser"
          },
          {
           "key": "b",
           "text": "Potser"
          },
          {
           "key": "c",
           "text": "Pot ser que"
          }
         ]
        },
        {
         "n": 15,
         "prompt": "Buit 15",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "d’ací a"
          },
          {
           "key": "b",
           "text": "endins de"
          },
          {
           "key": "c",
           "text": "d’ençà de"
          }
         ]
        },
        {
         "n": 16,
         "prompt": "Buit 16",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "fins"
          },
          {
           "key": "b",
           "text": "cap a"
          },
          {
           "key": "c",
           "text": "enmig de"
          }
         ]
        },
        {
         "n": 17,
         "prompt": "Buit 17",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "dos-cents mil"
          },
          {
           "key": "b",
           "text": "dos-centes mil"
          },
          {
           "key": "c",
           "text": "dues-centes mil"
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
           "text": "Ø"
          },
          {
           "key": "b",
           "text": "a"
          },
          {
           "key": "c",
           "text": "als"
          }
         ]
        },
        {
         "n": 19,
         "prompt": "Buit 19",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "arrere"
          },
          {
           "key": "b",
           "text": "rere"
          },
          {
           "key": "c",
           "text": "enrere"
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
           "text": "tips"
          },
          {
           "key": "b",
           "text": "rabassuts"
          },
          {
           "key": "c",
           "text": "farcits"
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
        "title": "El Quiosc Barrachina, l’asil del còmic i del llibre a Castelló",
        "paragraphs": [
         "Algunes llibreries de vell i de segona mà tenen una vida efímera, altres sobreviuen (0) arrelades a un barri i a la seua gent, convertides en referència geogràfica i sentimental de les ciutats a on es troben; potser són un dels indrets més fascinants per als amants de la literatura, que busquem per les seues estanteries (21) ______ esperem trobar algun tresor perdut.",
         "Freqüentat pels amants dels llibres i les antiguitats, José Barrachina era molt conegut a Castelló, la capital de la Plana, per regentar un quiosc en el carrer d’Antonio Maura. Era un establiment emblemàtic, (22) ______ havia obert les portes l’any 1960, després d’haver-se traslladat des de la plaça de Borrull, a on tenia els seus orígens. No es podria definir (23) ______ com una llibreria de vell, perquè era un lloc molt particular. El propietari mateix havia batejat el local com L’asil del còmic i del llibre, segons indicava un paper penjat en l’entrada, ja que en l’interior hi havia (24) ______ d’exemplars i (25) ______ de col·leccions històriques. També s’hi podien trobar revistes antigues, discos de vinil i centenars de fotos antigues de Castelló, tresors que esperaven a ser descoberts.",
         "Fora, també en la porta, hi havia una multitud d’objectes i cartells que (26) ______ a la lectura. Dins del local hi havia dos espais. Una entrada (27) ______ de llibres i, penjant del sostre, objectes diversos. (28) ______ que era difícil eixir d’aquell indret amb les mans buides pels preus atractius dels llibres i la gran varietat de gèneres que (29) ______.",
         "Amb una miqueta de paciència, podies fer-te amb autèntiques joies que esperaven a ser descobertes i fruïdes amb (30) ______, obres descatalogades que no estaven en ninguna altra llibreria de Castelló, perquè durant molts anys va ser una de les poques —(31) ______ l’única— llibreria de vell de la ciutat, a on acudíem molts amants de la literatura a la busca d’un bon exemplar.",
         "Barrachina en si era tot un misteri. Bé per ser un home de poques paraules, per la seua quietud o per la seua icònica figura, amb ulleres i una gorra de capità de barco que portava sovint. Va morir en setembre de 2007, després (32) ______ un turisme l’atropellara, als 76 anys, quan, incombustible, continuava regentant el quiosc. Pel que sembla, cada dia tenia per costum eixir de bona hora de sa casa, en una urbanització pròxima de la carretera de l’Alcora, per a traslladar-se al centre i obrir el local a primera hora. Amb tot, un dia una nota en la porta indicava que s’havia produït (33) ______. La mort va causar una gran commoció en la ciutat, i hi hagué fins i tot una demanda popular per a posar un carrer al seu nom.",
         "Ara ja no queda res del que va ser el Quiosc Barrachina, però un dubte que a molts (34) ______ sí que ens ha quedat és (35) ______ hi havia dins de les caixes sorpresa que venia, embolicades, com si es tractara de xicotets regals. José Barrachina, una verdadera referència, i quasi llegenda, del llibre vell a Castelló de la Plana."
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
           "text": "mentres"
          },
          {
           "key": "b",
           "text": "mentrestant"
          },
          {
           "key": "c",
           "text": "mentres que"
          }
         ]
        },
        {
         "n": 22,
         "prompt": "Buit 22",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "doncs"
          },
          {
           "key": "b",
           "text": "per què"
          },
          {
           "key": "c",
           "text": "atés que"
          }
         ]
        },
        {
         "n": 23,
         "prompt": "Buit 23",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "ben bé"
          },
          {
           "key": "b",
           "text": "més bé"
          },
          {
           "key": "c",
           "text": "tan bé"
          }
         ]
        },
        {
         "n": 24,
         "prompt": "Buit 24",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "mil"
          },
          {
           "key": "b",
           "text": "milers"
          },
          {
           "key": "c",
           "text": "millars"
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
           "text": "nombres"
          },
          {
           "key": "b",
           "text": "números"
          },
          {
           "key": "c",
           "text": "numerals"
          }
         ]
        },
        {
         "n": 26,
         "prompt": "Buit 26",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "esperonaven"
          },
          {
           "key": "b",
           "text": "espaordien"
          },
          {
           "key": "c",
           "text": "espargien"
          }
         ]
        },
        {
         "n": 27,
         "prompt": "Buit 27",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "de bat a bat"
          },
          {
           "key": "b",
           "text": "amb escreix"
          },
          {
           "key": "c",
           "text": "a vessar"
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
           "text": "Per suposat"
          },
          {
           "key": "b",
           "text": "No debades"
          },
          {
           "key": "c",
           "text": "Ausades"
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
           "text": "hi havia"
          },
          {
           "key": "b",
           "text": "n’hi havia"
          },
          {
           "key": "c",
           "text": "n’hi havien"
          }
         ]
        },
        {
         "n": 30,
         "prompt": "Buit 30",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "deleció"
          },
          {
           "key": "b",
           "text": "deler"
          },
          {
           "key": "c",
           "text": "esquer"
          }
         ]
        },
        {
         "n": 31,
         "prompt": "Buit 31",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "si no"
          },
          {
           "key": "b",
           "text": "sino"
          },
          {
           "key": "c",
           "text": "sinó"
          }
         ]
        },
        {
         "n": 32,
         "prompt": "Buit 32",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "de què"
          },
          {
           "key": "b",
           "text": "què"
          },
          {
           "key": "c",
           "text": "que"
          }
         ]
        },
        {
         "n": 33,
         "prompt": "Buit 33",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "la seua travessa"
          },
          {
           "key": "b",
           "text": "el seu traspàs"
          },
          {
           "key": "c",
           "text": "el seu salpàs"
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
           "text": "castellonins"
          },
          {
           "key": "b",
           "text": "castellonencs"
          },
          {
           "key": "c",
           "text": "castellers"
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
           "text": "què"
          },
          {
           "key": "b",
           "text": "el què"
          },
          {
           "key": "c",
           "text": "el que"
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
         "text": "Actualment, vivim rodejats de dades. Comptem els passos que fem al llarg del dia, monitorem les hores i la qualitat del nostre son, controlem les calories que ingerim o analitzem el temps que passem davant de la pantalla del mòbil i quines aplicacions fem servir. Este control és possible gràcies a les aplicacions i els dispositius intel·ligents que registren cada aspecte de la nostra vida quotidiana. Eres psicòleg o psicòloga i decidixes publicar una entrada en el blog del centre en què treballes per a reflexionar sobre la necessitat actual de mesurar-ho tot, i si això ens beneficia o més prompte ens genera una certa obsessió. En el teu escrit cal que tractes, entre altres, estos punts:",
         "points": [
          "Les dades ajuden a tindre més control i eficiència.",
          "Mesurar dades fa perdre la naturalitat de la nostra quotidianitat.",
          "Este control en la nostra percepció de la felicitat i el benestar influïx en les nostres vides de diverses maneres."
         ]
        },
        {
         "key": "B",
         "text": "En menys de deu anys, la generació que va nàixer entre els cinquanta i els setanta i que va registrar els majors índexs de natalitat, els anomenats boomers, acabarà d’engrandir el sistema de pensions. En algunes comunitats autònomes esta franja de població representa ja el 20% del total poblacional, i es preveu que este percentatge augmente. La societat es planteja si les noves generacions podran mantindre el sistema de pensions públic com s’ha fet fins ara. Un diari ha publicat un monogràfic sobre les pensions, i després de llegir-lo decidixes escriure una carta al director en què opines sobre este tema. En el teu escrit cal que tractes, entre altres, estos punts:",
         "points": [
          "El dret a la jubilació en l’estat del benestar.",
          "Establiment d’una edat de jubilació digna.",
          "Fonts de finançament per a mantindre les pensions."
         ]
        }
       ]
      },
      {
       "n": 5,
       "kind": "writing",
       "title": "Redacció a partir d’una infografia",
       "instructions": "Tria una de les dos opcions i redacta un text amb una extensió entre 170 i 190 paraules.",
       "min_words": 170,
       "max_words": 190,
       "choices": [
        {
         "key": "A",
         "text": "Des de fa vint anys, internet ha transformat totes les nostres formes de comunicació (interpersonal, institucional, empresarial...). Ens ha permés superar les distàncies i ens ha facilitat la informació instantània. Una felicitació de Nadal, un pamflet informatiu, un vídeo d’humor... es reenvien milers de vegades i ens fan disfrutar a tots. No obstant, què ocorre quan el missatge que es difon és una falsa notícia? Després d’haver passat una situació d’emergència, l’ajuntament del teu municipi et demana que escrigues una entrada en la pàgina web en què expliques a la ciutadania la importància de discernir entre el que es fals i el que és verdader. En el teu text cal que tingues en compte les vinyetes següents.",
         "image": "/exams/c1-abril-2025/e5-a.jpg",
         "image_text": "Infografia en format de còmic «La volta al món en 80 missatges: La Notícia Falsa» (Generalitat Valenciana i CSIRT-CV, Centre de Seguretat TIC de la Comunitat Valenciana; www.csirtcv.gva.es, concienciat.gva.es), en sis vinyetes. 1. L’origen de la notícia falsa: un usuari («convidat271») escriu en l’ordinador el missatge «CONFIRMAT!!! S’acosta un huracà a 200 km/h. Ens ho estan ocultant. Evacuar tota la zona costanera. Compartix-ho per a avisar els teus afins!», prem «Enviar» i somriu pensant: «Això segur que espanta la gent...». 2. Primers destinataris de la notícia falsa: uns jóvens el reben en el mòbil i diuen «Serà cert? Per si de cas, ho passe a la meua família» i «Diu que ho estan ocultant... Millor difondre-ho ja»; el missatge es reenvia centenars de vegades (comptadors que pugen: 1788, 532, 297…) i algú crida «Mira això! Corre la veu!». 3. Expansió de la notícia falsa: «La notícia falsa és capaç de propagar el caos, sembrar la por i l’alarma social innecessàriament»; gent espantada pel carrer de nit i comentaris en xarxa: «zona costanera. Compartix-ho!», «Jo no m’ho crec...», «Diuen que ho estan ocultant!», «És una emergència! Per què ningú ho està reportant en les notícies?». 4. Com detectar i actuar davant d’una notícia falsa: una dona rep el missatge i pensa «Serà veritat? No vullc espantar a ningú si és fals.»; consulta l’ordinador: «Pas 1: Revisa la font. Els llocs oficials i els mitjans reconeguts són clau», i avisa el grup «Companys de la feina»: «COMPTE! Això és una notícia falsa. Ací està la informació real: [enllaç oficial]». 5. Fomentant la responsabilitat: un jove rep l’avís («COMPTE! Això és una notícia falsa. Ací està la informació real») i pensa «És millor frenar els rumors abans que causen pànic innecessari», i esborra el missatge; text: «Una notícia falsa creix com l’espuma, però el pensament crític pot impedir que la societat caiga en l’engany». 6. Reflexió: un mòbil amb el missatge «Abans de compartir, CONTRASTA la informació» i les etiquetes #ContralaDesinformació i #StopNotíciesFalses."
        },
        {
         "key": "B",
         "text": "El malbaratament alimentari continua sent un dels grans reptes que cal superar en l’actualitat. Més enllà dels recursos naturals usats i l’impacte ambiental que té, reduir-lo és una qüestió de justícia social. Aconseguir-ho passa per l’acció de la ciutadania, així com per la implicació dels servicis de restauració, entre altres. Coordines de manera voluntària un menjador social, que rep bona part del menjar dels excedents d’escoles, residències i hospitals. Com que et preocupa la seguretat alimentària, decidixes escriure una circular als centres que col·laboren amb la iniciativa per a facilitar-los unes pautes perquè donen els aliments de manera segura i poder reaprofitar-los. En el teu text cal que tingues en compte la informació de la infografia següent:",
         "image": "/exams/c1-abril-2025/e5-b.jpg",
         "image_text": "Infografia «Recuperar excedents» (una caixa de verdures al centre i cinc passos en cercle): Refredament: passeu de 60 ºC a 10 ºC en menys de 2 hores. Envasament: useu envasos nets (preferiblement xicotets per a afavorir el refredament) i ompliu-los el més ràpid possible. Etiquetatge: ompliu bé totes les dades. Conservació: en refrigeració (T < 4 ºC); en congelació (T < -18 ºC). Entrega: doneu el menjar amb un document d’entrega."
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
     "intro": "Esta àrea té dos parts: un monòleg d’uns tres minuts sobre un tema que tries, a partir d’unes idees que has de desenrotllar, i un diàleg d’uns quatre minuts amb una altra persona aspirant, en què cada una defén el paper que li toca.",
     "exercises": [
      {
       "n": 6,
       "kind": "oral",
       "instructions": "Has de triar un tema i preparar un monòleg de tres minuts, aproximadament. A continuació trobaràs el tema sobre el qual has de parlar i les idees que has de desenrotllar.",
       "proposals": [
        {
         "title": "Monòleg · Reescrivim els carrers",
         "duration": "3 minuts",
         "intro": "La teua localitat està plena de carrers amb noms d’hòmens il·lustres; però, si es compara amb els carrers que tenen nom de dones importants, la representació femenina és ben escassa. Creus que és necessari obrir el debat sobre la presència femenina en l’espai públic. Participes en una reunió de l’associació veïnal a què pertanys, i expresses la teua opinió sobre la importància de dedicar més carrers a dones destacades. En el teu discurs cal que tingues en compte, entre altres, estes idees:",
         "questions": [
          "Visibilització de les dones i impacte en la societat.",
          "Possibles criteris de selecció.",
          "Iniciatives amb èxit en altres localitats."
         ],
         "images": []
        },
        {
         "title": "Monòleg · Minimalisme",
         "duration": "3 minuts",
         "intro": "En una societat marcada pel consumisme, el minimalisme, un moviment que defén viure amb menys per a viure millor, s’ha convertit en una alternativa per a moltes persones. Esta filosofia promou reduir les possessions materials i simplificar l’estil de vida per a fomentar la sostenibilitat i aconseguir més benestar. T’han convidat a unes jornades sobre hàbits de consum, i participes en un fòrum sobre la viabilitat d’aplicar un estil de vida minimalista en les nostres vides. En el teu discurs cal que tingues en compte, entre altres, estes idees:",
         "questions": [
          "Impacte en les relacions socials i familiars.",
          "Minimalisme com a resposta a l’estrés.",
          "Conscienciació ambiental real o moda passatgera."
         ],
         "images": []
        }
       ]
      },
      {
       "n": 7,
       "kind": "oral",
       "instructions": "Has de mantindre un diàleg amb un altre o una altra aspirant sobre la situació comunicativa que vos proposem. Llig la introducció del tema i defén el paper que t’atorga la proposta ombrejada. Les intervencions han de ser equilibrades; evita donar respostes massa curtes i participa activament com ho faries en una conversa habitual. La duració de la conversació serà de quatre minuts, aproximadament.",
       "proposals": [
        {
         "title": "Diàleg · L’alcohol en les festes",
         "duration": "4 minuts",
         "intro": "El nostre calendari anual s’ompli de festivitats religioses i profanes que cada any s’ameren d’alcohol. Les celebracions han normalitzat el consum i l’abús de la beguda, i en alguns casos fins i tot l’han coronat com un element tan definitori que pot eclipsar els actes o l’interés associatiu.",
         "questions": [],
         "images": [],
         "roles": [
          {
           "name": "Persona A",
           "text": "Com a membre d’un col·lectiu de festers, participes en una reunió en el consistori per a organitzar les festes de l’any vinent. Opines que cal repensar la sobreexposició de l’alcohol en la festa, exposes alternatives d’oci sense alcohol i proposes altres fonts de finançament més enllà de la barra. També reflexiones sobre l’impacte que pot provocar la naturalització de l’alcohol davant de la xicalla."
          },
          {
           "name": "Persona B",
           "text": "Com a membre d’un col·lectiu de festers, participes en una reunió en el consistori per a organitzar les festes de l’any vinent. Et mostres obert o oberta a repensar l’exposició que té l’alcohol en la festa, però descartes eliminar-lo, ja que la beguda i el menjar formen part de qualsevol ritual. Apuntes la importància de l’educació i la prevenció per a evitar conductes de risc."
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
