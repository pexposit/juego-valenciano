-- Examen interactiu C2 de la JQCV (octubre 2025) com a recurs de category 'examen'.
-- Contingut a metadata.exam, amb les quatre àrees del C2 i la puntuació de la guia de la prova
-- (comprensió escrita 10 %, 5 preguntes de 20 punts; estructures lingüístiques 20 %, 40 buits de 2,5 punts;
-- expressió escrita 45 % i expressió oral 25 %; mínim del 20 %, el 40 % i el 50 % segons el pes de
-- l'àrea). Les respostes són les del solucionari escanejat que inclou el quadern. Les redaccions es
-- corregixen amb la rúbrica C2 (backend/src/services/examWritingEvaluator.ts); les imatges de l'exercici 5
-- són a frontend/public/exams/. L'àrea oral, com en el C1, només mostra les propostes.
-- Font: https://jqcv.gva.es/va/nivell-c2

INSERT INTO public.resources (id, name, type, url, content, metadata, xp_earned, difficulty, category)
SELECT id, name, type, url, content, metadata, xp_earned, difficulty, category
FROM jsonb_populate_record(NULL::public.resources, $data${
 "id": "024e0efe-0559-53c6-9bf9-96c7842e0ef8",
 "name": "Simulacre C2: octubre 2025",
 "type": "jqcv_c2_oct2025",
 "category": "examen",
 "difficulty": "C2",
 "xp_earned": 40,
 "content": "Examen oficial C2 de la JQCV (octubre 2025): comprensió escrita i estructures lingüístiques autocorregibles, dos redaccions i pràctica oral.",
 "metadata": {
  "icon": "🏆",
  "color": "#D1C4E9",
  "exam_body": "JQCV",
  "certificate_level": "C2",
  "exam": {
   "level": "C2",
   "session": "Octubre 2025",
   "body": "JQCV",
   "source_url": "https://jqcv.gva.es/va/nivell-c2",
   "pass_rule": "Per a ser APTE cal una puntuació global mínima de 60 sobre 100. Les àrees valen un 10 % (comprensió escrita), un 20 % (estructures lingüístiques), un 45 % (expressió i interacció escrites) i un 25 % (expressió i interacció orals), i en cada una cal arribar al mínim: el 20 % en la comprensió escrita, el 40 % en les estructures lingüístiques i el 50 % en l’expressió escrita i en l’expressió oral.",
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
        "title": "Els clàssics",
        "paragraphs": [
         "Tot el món venera els clàssics. Són intocables quasi per definició. Els clàssics són creadors que, damunt dels seus valors objectius, tenen allò que jo dic adherències mítiques, que tan a sovint són les que determinen, no sempre de manera del tot justa, els prestigis generalitzats. Perquè una cosa és el moll de l’os de l’obra d’un creador, i l’altra allò que el temps, els interessos, la casualitat i l’oportunitat hagen pogut afegir. Les fames curiosament es llauren més a partir d’estos elements circumstancials agregats al nucli de les coses que no a partir de la qualitat i transcendència d’estes coses en la seua nuesa. Un clàssic és, doncs, algú a qui a qualsevol li faria vergonya dir que no el coneix. Em referisc al fet que no coneix el gros i el valor de la seua obra, ja que el seu nom i la seua fama segur que sí que els coneixerien. S’imaginen que algú s’atrevira a dir dels poemes d’Horaci que no n’hi ha per a tant?",
         "Majoritàriament, les figures dels clàssics originals, grecs o llatins, només les coneixem a través de bustos de marbre. En el fons tots els veem com a sers antropomòrfics, però no palpables: la seua veracitat, en tant que persones actives, ha quedat com congelada, i s’han convertit en una espècie d’arquetip. A això s’ajunta que ens han arribat a través dels llibres de text de quan estudiàvem, embolcallats amb la consideració de ser els protagonistes d’aquells coneixements que, encara que tal volta no teníem massa fe en els clàssics, eren allò que calia conéixer i venerar. I després de la nostra etapa formativa, tots aquells noms han continuat disfrutant d’un reconeixement enorme.",
         "I el cas és que, si ens parem a pensar, els clàssics van ser, en vida, persones com les altres. Amb aspectes negatius, defectes, contradiccions, misèries..., a part de la seua possible excel·lència “professional”. Com que els clàssics ens han arribat després de segles de veneració, i havent superat una espècie de carrera d’obstacles maratoniana, hui som incapaços de posar-los en qüestió com qualsevol altra cosa. Ja no són les persones que havien sigut: són clixés.",
         "Tampoc tenim en compte que de clàssics, pel camí, se’n poden haver perdut molts, ja que en temps passats la capacitat de conservar i reproduir la seua obra era molt més imperfecta que la que tenim ara. O siga que ens han arribat uns quants clàssics i sengles obres, i estes tal vegada no són sempre les més interessants o ens han arribat mal transcrites. O mal traduïdes o interpretades pels ulls actuals. Llegir un clàssic sense notes a peu de plana es fa difícil: algú que en sap més que tu et guia i et dona les pautes per a poder entendre’l millor. La frescor de la lectura, per tant, es perd. Ara bé, sembla que tot això és igual: es tracta d’obres clàssiques, i per este únic fet ens hem posat tots d’acord per a acceptar i proclamar que són modèliques.",
         "Clàssics, de fet, no ho són només els antics. Georges de La Tour és un dels grans clàssics de la pintura francesa del segle XVII, però la seua obra es va anar difuminant amb els segles de manera que calgué que algú la redescobrira, i ja en el segle XX, la identificara i la recopilara per a posar el seu autor en l’altar dels grans pintors de tots els temps. Quants La Tour —pintors, però també escriptors o pensadors— hi haurà encara amagats baix de capes de desconeixement i que mai afloraran o que tardaran molt a fer-ho? Ara, l’afortunat La Tour ja és un clàssic reconegut, fins i tot pel gran públic, i per això trobarà moltes facilitats per a fugir de la zona en què els artistes poden ser objecte de crítica.",
         "Algú deu haver parlat alguna vegada de clàssics sense la reverència que generalment els envolta. Algú els deu haver considerat simplement persones. És una transgressió insòlita, que no haurà tingut després gran recorregut, però que segur que ha passat. Al marge de si tenien raó o no els transgressors, esta actitud resulta enormement saludable des d’un punt de vista general. Per què Botticelli —per exemple— ha d’estar protegit per l’armadura invulnerable de la impossibilitat de ser valorat com una altra persona humana? Pel fet d’haver viscut en el segle XV i haver generat des d’aleshores capes i capes d’adherències mítiques distorsionadores... i protectores? Ni ell ni ningú ha de ser immune a una visió crítica.",
         "Tot i això, esta actitud no sol ser gens habitual. Els clàssics han entrat en els manuals i es convertixen en intocables, i en tot cas si algú s’atrevix a expressar que no li agraden prou ho fa en privat i en un context de broma, perquè dir-ho en públic seriosament en una tribuna solemne potser li portaria complicacions. Però, en realitat, com a persones de carn i os que van ser, els clàssics són tan qüestionables com les persones de carn i os d’ara mateix. I si fórem capaços de desprendre’ns del prejuí de la sacralitat dels clàssics, probablement podríem valorar objectivament que algú que viu ara mateix a cent quilòmetres de casa, o molt més prop, pot haver fet tants o més mèrits per a ser valorat com una aportació d’igual valor que qualsevol dels hòmens del bust de marbre. Però per a arribar a esta conclusió —si és el cas— els que ho jutgem hauríem de ser capaços de desprendre’ns de tota la influència que pesa sobre nosaltres.",
         "Tot és qüestió de portar adherències mítiques o no portar-ne."
        ]
       },
       "questions": [
        {
         "n": 0,
         "prompt": "Segons l’autor, el prestigi dels clàssics es deu, en part, a…",
         "answer": "c",
         "scored": false,
         "options": [
          {
           "key": "a",
           "text": "la seua qualitat, reconeguda universalment al llarg del temps."
          },
          {
           "key": "b",
           "text": "els manuals escolars, que n’han consolidat la fama."
          },
          {
           "key": "c",
           "text": "diversos factors que s’hi han adherit amb el temps."
          },
          {
           "key": "d",
           "text": "la seua resistència per a superar qualsevol crítica."
          }
         ]
        },
        {
         "n": 1,
         "prompt": "Els clàssics són considerats com a tals perquè…",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "tot el món els llig, encara que no els entenga."
          },
          {
           "key": "b",
           "text": "són reconeguts inclús per qui no els ha llegit."
          },
          {
           "key": "c",
           "text": "el seu reconeixement es basa objectivament en la qualitat artística."
          },
          {
           "key": "d",
           "text": "s’han llegit sempre en l’escola de manera obligatòria."
          }
         ]
        },
        {
         "n": 2,
         "prompt": "La percepció dels clàssics la condicionen…",
         "answer": "d",
         "options": [
          {
           "key": "a",
           "text": "les reinterpretacions que s’han fet de les seues obres amb el temps."
          },
          {
           "key": "b",
           "text": "les poques dades que es tenen respecte de les seues persones."
          },
          {
           "key": "c",
           "text": "els estudis acadèmics gràcies als quals els coneixem."
          },
          {
           "key": "d",
           "text": "els arquetips que els allunyen de la seua humanitat real."
          }
         ]
        },
        {
         "n": 3,
         "prompt": "La selecció dels clàssics és qüestionable perquè…",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "només es conserven els artistes més destacats del seu temps."
          },
          {
           "key": "b",
           "text": "les obres han arribat sense modificacions al llarg del temps."
          },
          {
           "key": "c",
           "text": "molts artistes s’han perdut per la fragilitat de conservar-ne les obres."
          },
          {
           "key": "d",
           "text": "la societat moderna no els entén i no pot atorgar-los valor."
          }
         ]
        },
        {
         "n": 4,
         "prompt": "El cas de Georges de La Tour mostra que…",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "alguns clàssics han necessitat segles per a ser descoberts."
          },
          {
           "key": "b",
           "text": "només amb el pas del temps es pot arribar a ser un clàssic."
          },
          {
           "key": "c",
           "text": "els grans clàssics, prompte o tard, acaben sent descoberts."
          },
          {
           "key": "d",
           "text": "la fama depén només del moment històric en què es descobrix."
          }
         ]
        },
        {
         "n": 5,
         "prompt": "Actualment...",
         "answer": "d",
         "options": [
          {
           "key": "a",
           "text": "només els artistes realment influents mereixen el títol de clàssics."
          },
          {
           "key": "b",
           "text": "els clàssics són molt qüestionats per la influència dels artistes actuals."
          },
          {
           "key": "c",
           "text": "la societat depén massa de les modes i no sap identificar nous clàssics."
          },
          {
           "key": "d",
           "text": "se sobrevaloren els clàssics i s’ignoren artistes actuals amb mèrits similars."
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
      "points_per_correct": 2.5,
      "max_points": 100,
      "pass_points": 40
     },
     "exercises": [
      {
       "n": 2,
       "kind": "choice",
       "instructions": "Completa el text que tens a continuació amb l’alternativa més precisa i adequada. Només hi ha una opció correcta per a cada buit. Fixa’t en l’exemple (número 0).",
       "reading": {
        "title": "Fontilles, la ciutat invisible",
        "paragraphs": [
         "«Fontilles. La ciutat amagada» mostra la vida d’un sanatori que va obrir les portes l’any 1909 i que, amb el pas dels anys, (0) ha esdevingut un lloc de referència per a la investigació i l’abordatge de la lepra, una malaltia (6) ______ que durant dècades va abocar centenars de persones a l’aïllament.",
         "Actualment viuen molt poques d’aquelles persones. Però, en els més de cent anys de funcionament, es calcula que més de dos mil persones van haver (7) ______ entre les seues parets i murs. Esdevingué, (8) ______, una ciutat a xicoteta escala, que acollia els repudiats de la societat i que va acabar creant les seues particulars dinàmiques de vida.",
         "Que l’exposició s’intitule «La ciutat amagada» té tot el sentit del món. Perquè Fontilles fou una ciutat amagada en el sentit literal del terme. No és casual que fora en la Vall de Laguar, entre muntanyes i (9) ______, a on el jesuïta Carlos Ferris i l’advocat Joaquín Ballester decidiren, a principis de segle, ubicar este sanatori. La lepra havia passat a ser, a les (10) ______ del segle XIX, una malaltia endèmica de molts pobles de la Marina Alta, una (11) ______ que abocava a la repulsió social.",
         "Fontilles fou el lloc triat, un punt especialment adequat per a la finalitat perseguida. Era un lloc solejat, amb aigua abundant, ben ventilat i protegit del vent del nord. Un mirador excel·lent al mar amb una particular asimetria òptica que (12) ______ feia impossible ser vist des de cap dels municipis pròxims. No obstant, això no significà la invisibilitat de l’espai. Resulta ben (13) ______ este doble joc. «A pesar d’haver sigut construïda per a ser invisible, Fontilles tingué la necessitat de ser mostrada constantment —explica García Belmar—. La finalitat no era cap altra que recaptar fons i suport per al seu manteniment».",
         "Era, al (14) ______, el principi del segle XX, i només a través de la beneficència era possible cobrir els gastos generats pels ingressats. Des de ben prompte sorgiren les publicacions a on s’explicava l’activitat del centre i també les campanyes de captació de fons, (15) ______ abocaven molts representants de les classes benestants. A voltes, com una manera de redimir els pecats. També pel prestigi i reconeixement social que atorgava participar en una obra benèfica. La mostra està dissenyada de forma que esta triple dimensió siga ben palesa. En primer lloc, en l’entrada són visibles les (16) ______ per a recaptar fons i també una gran fotografia del Land Rover amb què les monges recorrien Espanya per a aplegar gallets.",
         "En (17) ______ principal, una sala dividida en dos parts. En la primera, l’espai dels sans: el despatx del director i els laboratoris a on s’estudiava la malaltia i es buscava un remei. La (18) ______ d’utensilis mèdics és especialment rica: un hemòmetre de Sahli per a calcular la concentració d’hemoglobina en la sang; un centrifugador i lector de microhematòcrits, microlàmpades per a la coloració de la llum o els encenedors, tubs d’assaig i agulles que s’usaven per a determinar, en primera instància, si un individu estava contagiat o no ho estava.",
         "Els fundadors de Fontilles van utilitzar el terme sanatori per a anomenar el seu projecte, (19) ______ amb ell s’expressara de manera explícita la seua voluntat de contribuir a la busca d’un remei amb què sanar els malalts. No es tractava únicament d’aïllar el malalt i procurar el seu benestar corporal i espiritual, tal com s’havia fet en les leproseries i (20) ______ durant segles.",
         "La segona sala de l’exposició està dedicada a parlar de les persones, de la vida d’aquells que es van vore expulsats de la societat per culpa del bacil Mycobacterium leprae. Escoltar el seu testimoni, les seues cavil·lacions, aspiracions i frustracions, acompanyats de tot un (21) ______ de fotografies, és la millor manera de comprendre el complicat (22) ______ que van haver de passar i superar. «Com que es feia molta divulgació, hi ha recopilades al voltant de 20.000 imatges del sanatori», explica García Belmar.",
         "Hi ha, en tot cas, moltes més imatges: la posada en escena d’una obra de teatre, un grup de sevillanes, una rondalla, els tallers de costura i de fusteria... Perquè, al cap i a la fi, en aquella ciutat amagada i emmurallada, hi havia una comunitat que tenia les mateixes necessitats de socialització que tenien la resta. Si l’oci els obria parèntesis (23) ______, el treball es convertia en un eficaç instrument d’intervenció col·lectiva amb el qual fixar temps i espais.",
         "En una iniciativa de (24) ______ religiós, com aquell sanatori, el treball es va concebre com un camí cap a la sanació moral i corporal dels afectats. A partir de la dècada dels cinquanta, quan els tractaments sulfònics van permetre donar les primeres altes, aquells tallers es transformaren, a més, en escoles laborals que els preparaven per al futur. Molts, de fet, recuperaren la vida que tenien; molts altres van fer un viatge d’anada i tornada; uns pocs convertiren Fontilles en la seua llar de per vida.",
         "«Amb l’exposició, hem volgut mostrar com s’organitzava la societat de la lepra —explica García Belmar—. Escoltar els seus relats és una manera de trencar amb la imatge del drama, el patiment i la penalitat. Una de les coses que ens ensenyen, a través dels seus relats, és que de les dificultats no se n’ix per separat, sinó junts». «Fontilles. La ciutat amagada» és, (25) ______, molt més que una exposició sobre història de la medicina."
        ]
       },
       "questions": [
        {
         "n": 6,
         "prompt": "Buit 6",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "estigmatitzadora"
          },
          {
           "key": "b",
           "text": "recurrent"
          },
          {
           "key": "c",
           "text": "recidiva"
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
           "text": "d’eixavuirar-se"
          },
          {
           "key": "b",
           "text": "d’arrecerar-se"
          },
          {
           "key": "c",
           "text": "d’atapeir-se"
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
           "text": "doncs"
          },
          {
           "key": "b",
           "text": "si fa no fa"
          },
          {
           "key": "c",
           "text": "a tot estirar"
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
           "text": "cingles"
          },
          {
           "key": "b",
           "text": "marenys"
          },
          {
           "key": "c",
           "text": "remelsos"
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
           "text": "acaballes"
          },
          {
           "key": "b",
           "text": "darreres"
          },
          {
           "key": "c",
           "text": "postres"
          }
         ]
        },
        {
         "n": 11,
         "prompt": "Buit 11",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "llastra"
          },
          {
           "key": "b",
           "text": "xacra"
          },
          {
           "key": "c",
           "text": "rècua"
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
           "text": "el"
          },
          {
           "key": "b",
           "text": "li"
          },
          {
           "key": "c",
           "text": "l’hi"
          }
         ]
        },
        {
         "n": 13,
         "prompt": "Buit 13",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "paradoxal"
          },
          {
           "key": "b",
           "text": "redundant"
          },
          {
           "key": "c",
           "text": "conseqüent"
          }
         ]
        },
        {
         "n": 14,
         "prompt": "Buit 14",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "fi"
          },
          {
           "key": "b",
           "text": "capdavall"
          },
          {
           "key": "c",
           "text": "tombant"
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
           "text": "a les quals s’hi"
          },
          {
           "key": "b",
           "text": "a què hi"
          },
          {
           "key": "c",
           "text": "a les quals s’"
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
           "text": "vidrioles"
          },
          {
           "key": "b",
           "text": "vidrieres"
          },
          {
           "key": "c",
           "text": "corrioles"
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
           "text": "l’estança"
          },
          {
           "key": "b",
           "text": "l’estada"
          },
          {
           "key": "c",
           "text": "la càmera"
          }
         ]
        },
        {
         "n": 18,
         "prompt": "Buit 18",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "solsida"
          },
          {
           "key": "b",
           "text": "baula"
          },
          {
           "key": "c",
           "text": "caterva"
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
           "text": "per tal com"
          },
          {
           "key": "b",
           "text": "per bé que"
          },
          {
           "key": "c",
           "text": "doncs"
          }
         ]
        },
        {
         "n": 20,
         "prompt": "Buit 20",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "llatzerets"
          },
          {
           "key": "b",
           "text": "apotecaries"
          },
          {
           "key": "c",
           "text": "menescals"
          }
         ]
        },
        {
         "n": 21,
         "prompt": "Buit 21",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "refil"
          },
          {
           "key": "b",
           "text": "reguitzell"
          },
          {
           "key": "c",
           "text": "refiló"
          }
         ]
        },
        {
         "n": 22,
         "prompt": "Buit 22",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "temperi"
          },
          {
           "key": "b",
           "text": "tràngol"
          },
          {
           "key": "c",
           "text": "trencall"
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
           "text": "d’esbargiment"
          },
          {
           "key": "b",
           "text": "d’assimilació"
          },
          {
           "key": "c",
           "text": "d’alienació"
          }
         ]
        },
        {
         "n": 24,
         "prompt": "Buit 24",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "sentiment"
          },
          {
           "key": "b",
           "text": "prelat"
          },
          {
           "key": "c",
           "text": "caire"
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
           "text": "si molt convé"
          },
          {
           "key": "b",
           "text": "fet i fet"
          },
          {
           "key": "c",
           "text": "tanmateix"
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
        "title": "Al foc amb la ciència!",
        "paragraphs": [
         "La primera cosa que ens pot vindre al cap (0) mentres parlem de falles és la teoria de la tectònica de plaques. Però ara no ens referim a este tipus de falles, sinó que parlem (26) ______ en març, concretament, (27) ______ els carrers de València, i que en pocs dies són consumides per les flames davant de l’admiració dels espectadors. Encara que no som de cap manera els primers a plantejar una font de cultura popular per a un estudi de la ciència en clau historicosocial, cal preguntar-se, en primer lloc, si verdaderament les falles ens poden dir alguna cosa sobre la manera (28) ______ es popularitza la ciència. Les falles representen en si mateixes una mostra de la tensió essencial que existix entre tradició i innovació. Això no és gens estrany, a pesar de la percepció popular que els nous invents acaben (29) ______ amb les velles solucions. Les falles que observem hui en dia són un conjunt de velles pràctiques artesanals amb noves tècniques d’avantguarda. Les falles, (30) ______, són artefactes tecnològics sotmesos a un procés d’evolució continu que pretenen transmetre una idea. Però quines idees? Quines característiques fan un fenomen científic apropiat o no per a aparéixer en una falla? No pareix que hi haja un criteri clar, però vorem un grapat d’exemples curiosos i (31) ______ d’esta relació controvertida entre ciència i falles. Les grans teories científiques evolucionen des de l’àmbit (32) ______ de les comunitats científiques fins a l’acceptació pel conjunt de la societat. D’este fet hi ha nombroses evidències, però potser un dels exemples més cridaners (33) ______ el de la teoria de l’evolució. Així, la paròdia a la transició de l’espècie humana dels nostres avantpassats simiescos a Homo sapiens és un referent habitual, usualment plasmat (34) ______ recurs ben poc darwiniste del curs evolutiu que popularitzaren Huxley i Haeckel. Satíric i convulsiu, el discurs faller ja era una ferramenta emprada pels valencians per a fer burla també del seu (35) ______ al començament del segle passat. El 1933, la falla de la Plaça del Mercat presentava un tal Homo vivendis, un nou homínid avantpassat del valencià actual que constituïa una crítica del meninfotisme, o actitud conformista que el tòpic associa (36) ______ del poble valencià. Cal parar esment en l’ús de la nomenclatura (37) ______ per a designar esta nova espècie, fruit de la imaginació fallera. L’acudit a partir d’esta esotèrica manera d’anomenar les espècies ha sigut també un recurs habitual des d’aleshores. El sentiment d’ambivalència davant dels efectes de la ciència ha sigut un altre gir temàtic habitual en les falles. En 1969, la ciència presenta les seues dos cares —bona i (38) ______— en el monument Gérmens malignes, de la falla de la Plaça del Pilar. Magníficament representada, una figura abstracta caracteritza la mare naturalesa que observa amb un microscopi gegant els gérmens malignes caricaturitzats. El més curiós, (39) ______, és com la biodiversitat representa un doble paper en esta proposta. És la mateixa naturalesa qui s’estudia a si mateixa, és la protagonista del treball científic i alhora el problema per solucionar. Un discurs, doncs, més complex del que de primeres (40) ______ esperaria en una manifestació de cultura popular festiva.",
         "I (41) ______ dels transmissors? Dels grans inventors? La figura dels investigadors i científics tampoc és (42) ______ per les falles. Tal volta molts recorden el monument que en 2012 va plantar la falla Na Jordana, Leonardo da Vinci. Este mostrava els vessants científic i tècnic del gran creador italià, (43) ______ un gran impacte per la seua particular execució.",
         "En definitiva, podem dir que les falles són un objecte d’investigació molt interessant per als estudis socials de la ciència. (44) ______, sembla que és la ciència la que també comença a interessar-se per les falles, i no només al revés. És probable que ens trobem en un procés en què el món faller i l’acadèmia finalment normalitzen una relació quotidianament col·laborativa. I és que les falles són una festa que sempre té molt (45) ______ dir, fins i tot de ciència."
        ]
       },
       "questions": [
        {
         "n": 26,
         "prompt": "Buit 26",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "de les que"
          },
          {
           "key": "b",
           "text": "de les quals"
          },
          {
           "key": "c",
           "text": "de què"
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
           "text": "ameren"
          },
          {
           "key": "b",
           "text": "reblixen"
          },
          {
           "key": "c",
           "text": "entaforen"
          }
         ]
        },
        {
         "n": 28,
         "prompt": "Buit 28",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "que"
          },
          {
           "key": "b",
           "text": "en la que"
          },
          {
           "key": "c",
           "text": "en com"
          }
         ]
        },
        {
         "n": 29,
         "prompt": "Buit 29",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "com Camot"
          },
          {
           "key": "b",
           "text": "de soca-rel"
          },
          {
           "key": "c",
           "text": "a tot i a totes"
          }
         ]
        },
        {
         "n": 30,
         "prompt": "Buit 30",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "amb tot"
          },
          {
           "key": "b",
           "text": "altrament"
          },
          {
           "key": "c",
           "text": "de fet"
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
           "text": "esclarificadors"
          },
          {
           "key": "b",
           "text": "aclaridors"
          },
          {
           "key": "c",
           "text": "clarividents"
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
           "text": "reclòs"
          },
          {
           "key": "b",
           "text": "reclús"
          },
          {
           "key": "c",
           "text": "resclosit"
          }
         ]
        },
        {
         "n": 33,
         "prompt": "Buit 33",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "és"
          },
          {
           "key": "b",
           "text": "siga"
          },
          {
           "key": "c",
           "text": "fora"
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
           "text": "conforme el"
          },
          {
           "key": "b",
           "text": "conformement el"
          },
          {
           "key": "c",
           "text": "conformement al"
          }
         ]
        },
        {
         "n": 35,
         "prompt": "Buit 35",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "mateix origen"
          },
          {
           "key": "b",
           "text": "propi origen"
          },
          {
           "key": "c",
           "text": "origen mateix"
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
           "text": "a la vel·leitat"
          },
          {
           "key": "b",
           "text": "a la rauxa"
          },
          {
           "key": "c",
           "text": "al tarannà"
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
           "text": "lineal"
          },
          {
           "key": "b",
           "text": "linneana"
          },
          {
           "key": "c",
           "text": "linina"
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
           "text": "mala"
          },
          {
           "key": "b",
           "text": "roina"
          },
          {
           "key": "c",
           "text": "roin"
          }
         ]
        },
        {
         "n": 39,
         "prompt": "Buit 39",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "així mateix"
          },
          {
           "key": "b",
           "text": "però"
          },
          {
           "key": "c",
           "text": "consegüentment"
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
           "text": "u"
          },
          {
           "key": "b",
           "text": "altri"
          },
          {
           "key": "c",
           "text": "cadascun"
          }
         ]
        },
        {
         "n": 41,
         "prompt": "Buit 41",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "què hi podem dir"
          },
          {
           "key": "b",
           "text": "què en tenim"
          },
          {
           "key": "c",
           "text": "què hi ha"
          }
         ]
        },
        {
         "n": 42,
         "prompt": "Buit 42",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "empallegada"
          },
          {
           "key": "b",
           "text": "bandejada"
          },
          {
           "key": "c",
           "text": "entrebancada"
          }
         ]
        },
        {
         "n": 43,
         "prompt": "Buit 43",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "tenint"
          },
          {
           "key": "b",
           "text": "que va tindre"
          },
          {
           "key": "c",
           "text": "i va tindre"
          }
         ]
        },
        {
         "n": 44,
         "prompt": "Buit 44",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "No debades"
          },
          {
           "key": "b",
           "text": "Amb prou faenes"
          },
          {
           "key": "c",
           "text": "Més que més"
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
           "text": "en"
          },
          {
           "key": "b",
           "text": "que"
          },
          {
           "key": "c",
           "text": "a"
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
     "weight": 45,
     "duration": "3 h 30 min (àrees 1, 2 i 3)",
     "exercises": [
      {
       "n": 4,
       "kind": "writing",
       "title": "Redacció",
       "instructions": "Tria una de les dos opcions i redacta un text amb una extensió entre 210 i 230 paraules.",
       "min_words": 210,
       "max_words": 230,
       "choices": [
        {
         "key": "A",
         "text": "Diversos estudis han posat de manifest que aliments quotidians com el café, el cacau o els plàtans podrien convertir-se en articles de luxe, o inclús desaparéixer de les nostres taules en les pròximes dècades. Les causes apunten a l’impacte del canvi climàtic, a les pràctiques de sobreexplotació agrícola i a les condicions laborals que desincentiven la producció en els països d’origen. Amb este escenari, cal replantejar-nos què mengem, com produïm i com valorem els aliments. Escriu un article d’opinió per a una revista de nutrició en què reflexiones sobre este fenomen i l’impacte que podria tindre la desaparició progressiva d’aliments bàsics del nostre model alimentari a escala individual i col·lectiva. En el teu escrit cal que tractes, entre altres, els punts següents:",
         "points": [
          "Factors ambientals, econòmics i socials en la desaparició d’alguns aliments.",
          "Conseqüències culturals, econòmiques i simbòliques de la pèrdua d’aliments arrelats en la societat.",
          "Possibles alternatives: nous cultius, canvi en els hàbits de consum, innovacions tecnològiques o intervenció política."
         ]
        },
        {
         "key": "B",
         "text": "En contextos d’inestabilitat —siga per motius sanitaris, econòmics o geopolítics— la cultura a sovint queda relegada a un segon pla davant de necessitats considerades més urgents. No obstant, múltiples veus del món intel·lectual i artístic defenen que la cultura no és un element accessori o un entreteniment, sinó un pilar fonamental per a la cohesió social, la preservació de la memòria col·lectiva i l’estímul del pensament crític. Eres periodista i t’han demanat que escrigues un article d’opinió per a una revista cultural en què analitzes la funció i el valor de la cultura en temps de crisis globals. En el teu escrit cal que tractes, entre altres, els punts següents:",
         "points": [
          "Consideració de la cultura com una necessitat estructural i no com un luxe circumstancial.",
          "Funció de la creació i el consum cultural en la resiliència individual i col·lectiva.",
          "Opinió sobre el reconeixement i el suport al sector cultural per part de les institucions i la ciutadania."
         ]
        }
       ]
      },
      {
       "n": 5,
       "kind": "writing",
       "title": "Text a partir d’una infografia",
       "instructions": "Tria una de les dos opcions i redacta un text amb una extensió entre 200 i 220 paraules.",
       "min_words": 200,
       "max_words": 220,
       "choices": [
        {
         "key": "A",
         "text": "Amb la transformació del món laboral, els riscos psicosocials han anat augmentant significativament. L’exigència constant de rendiment, la pressió per a aconseguir objectius o la inestabilitat contractual afecten directament la salut mental i emocional de les persones treballadores. Tot i que és un fenomen àmpliament documentat, encara són poques les empreses que apliquen mesures efectives per a previndre’ls i gestionar-los de manera adequada. Treballes com a tècnic en prevenció de riscos laborals i t’han demanat que redactes un informe per a la direcció d’una empresa basant-te en les dades de la infografia. L’objectiu és informar dels principals factors de riscos psicosocials i conscienciar sobre la necessitat de mesures preventives efectives.",
         "image": "/exams/c2-octubre-2025/e5-a.jpg",
         "image_text": "Infografia «Principals factors dels riscos psicosocials», amb nou apartats il·lustrats amb icones. «Contingut del treball»: Monotonia, falta de varietat, faenes desagradables per les quals se sent rebuig. «Càrrega i ritme de treball»: Càrrega de treball excessiva o insuficient, pressió de temps, terminis estrictes. «Participació i control»: Falta de participació en la presa de decisions. «Temps de treball»: Horaris molt llargs o imprevisibles, treball en torns. «Cultura organitzacional»: Comunicacions pobres, suport insuficient davant dels problemes, falta de definició d’objectius. «Relacions personals»: Aïllament, males relacions, conflictes, conductes inadequades. «Rol»: Ambigüitat o conflicte de rol, responsabilitat sobre persones. «Desenrotllament personal»: Escassa valoració social del treball, falta o excés de promoció. «Interacció casa-treball»: Conflicte d’exigències, problemes de la doble presència."
        },
        {
         "key": "B",
         "text": "En un moment en què les formes d’accés a la cultura i al coneixement canvien de manera ràpida, els espais públics vinculats a la lectura i a l’aprenentatge també viuen processos de transformació. Això arriba a generar un debat sobre el paper que tenen dins de la societat en relació amb la capacitat d’adaptació a les necessitats actuals de la ciutadania. Treballes en la biblioteca municipal de la teua localitat i t’han encarregat que escrigues una entrada per a la pàgina web de l’Ajuntament amb la finalitat de compartir un balanç en relació amb el servici que oferix la biblioteca i reivindicar el paper que continua tenint en la localitat. Cal que tingues en compte la informació de la infografia següent:",
         "image": "/exams/c2-octubre-2025/e5-b.jpg",
         "image_text": "Infografia «Què fa la gent en les biblioteques públiques?». «Servicis d’internet»: 4,1 milions de connexions públiques a internet i 6 milions d’ordinadors públics. «Activitats realitzades»: 12.300 visites escolars, 15.300 sessions de clubs de lectura i 3.200 exposicions. «Préstecs», gràfic circular (percentatges): llibres 68,1; audiovisual 18,8; revistes 5,2; àudios 4,6; altres materials 1,9; llibres electrònics 1,4. «Assistència per edats», gràfic de barres: 13-29 anys, 50 %; 30-54 anys, 35 %; +55 anys, 15 %."
        }
       ]
      }
     ]
    },
    {
     "n": 4,
     "title": "Expressió i interacció orals",
     "weight": 25,
     "duration": "25 minuts aprox.",
     "intro": "Esta àrea té dos parts: un monòleg d’uns tres minuts sobre un tema que tries, amb les idees que has de desenvolupar, i un diàleg d’uns quatre minuts amb una altra persona aspirant, en què defens el paper que et toque.",
     "exercises": [
      {
       "n": 6,
       "kind": "oral",
       "instructions": "Has de triar un tema i preparar un monòleg de tres minuts, aproximadament. A continuació trobaràs el tema sobre el qual has de parlar i les idees que has de desenvolupar.",
       "proposals": [
        {
         "title": "Monòleg · Dimitir en silenci",
         "duration": "3 minuts",
         "intro": "Fa un temps que els departaments de recursos humans comencen a percebre un comportament conegut com a dimissió silenciosa. Es tracta d’una actitud adoptada per alguns treballadors que, en resposta a la falta de reconeixement, a la sobrecàrrega de tasques o a unes condicions laborals poc dignes, opten per limitar-se a complir estrictament el que establix el seu contracte. Sense renunciar formalment a la faena, deixen d’assumir responsabilitats extres o d’implicar-se més enllà del mínim exigit per a reivindicar el seu valor. Treballes en el departament de recursos humans d’una empresa, i t’han convidat a unes jornades sobre benestar laboral perquè participes en un fòrum per a analitzar este fenomen des d’una perspectiva crítica. En la teua intervenció cal que tingues en compte, entre altres, estes idees:",
         "questions": [
          "Factors que originen esta actitud i efectes en el rendiment i l’ambient laboral.",
          "Dificultats a l’hora de gestionar, cohesionar i motivar els equips.",
          "Estratègies per a promoure entorns laborals productius, sostenibles i emocionalment segurs."
         ],
         "images": []
        },
        {
         "title": "Monòleg · Festival de microaventures",
         "duration": "3 minuts",
         "intro": "Les microaventures s’han consolidat com una alternativa innovadora i sostenible dins del món del turisme i de l’oci. Són activitats breus, accessibles i amb un impacte ambiental reduït, pensades per a redescobrir espais pròxims amb una mirada nova. L’objectiu és oferir experiències significatives fent valdre el patrimoni natural sense infraestructures complexes. Treballes en l’oficina de turisme de la teua localitat, i et reunixes amb la Regidoria de Turisme per a defendre esta classe de turisme i proposar-los organitzar un festival de microaventures. En la teua intervenció cal que tingues en compte, entre altres, estes idees:",
         "questions": [
          "Redefinició del turisme com a experiència quotidiana i arrelada al context local.",
          "Desestacionalització del turisme i dinamització econòmica del municipi.",
          "Tipus d’activitats i coordinació amb diversos agents locals perquè hi participen."
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
         "title": "Diàleg · Cooperativisme",
         "duration": "4 minuts",
         "intro": "Les cooperatives són organitzacions basades en els valors de democràcia, igualtat, equitat i solidaritat i es gestionen democràticament pels socis, que participen activament en la definició de les polítiques i en la presa de decisions. Una part dels excedents de la cooperativa s’ha de reinvertir en el suport a altres cooperatives, i és a través d’eixa col·laboració que poden aconseguir el seu màxim potencial. Esteu en la reunió anual de socis en la qual es debaten diversos eixos que vertebraran la cooperativa en el següent període. Un dels punts de l’orde del dia és la distribució de les reserves a altres cooperatives.",
         "questions": [],
         "images": [],
         "roles": [
          {
           "name": "Opció A",
           "text": "Argumentes els beneficis d’enfortir els llaços amb altres cooperatives locals o comarcals per a crear sinergies i expliques l’impacte positiu que suposaria crear un teixit cooperativista fort per a la vostra comunitat."
          },
          {
           "name": "Opció B",
           "text": "Justifiques la responsabilitat que cal assumir en matèria de cooperació internacional, atesos els conflictes bèl·lics i l’empobriment extrem en què estan submergides algunes zones del globus. Expliques l’impacte positiu que suposaria crear esta col·laboració internacional tant en la vostra comunitat com en la receptora."
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
