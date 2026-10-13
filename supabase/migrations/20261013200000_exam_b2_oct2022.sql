-- Examen interactiu B2 de la JQCV (octubre 2022) com a recurs de category 'examen'.
-- Contingut a metadata.exam, amb les cinc àrees del B2 i la puntuació oficial de la guia de la
-- prova (comprensió oral 8 i 12 punts per encert; comprensió escrita 3,3 i 8,5; estructures 5 i 5;
-- mínim del 40 % en cada àrea i del 50 % en l'oral). Les respostes són les de la plantilla
-- oficial que inclou el quadern. Àudio de comprensió oral a url, convertit a MP3 des de l'oficial
-- (frontend/public/audio/Audio_B2_oct2022.mp3). Font: https://jqcv.gva.es/documents/161863165/165492631/B2+octubre+2022.pdf/e2335bd4-ddb0-9b5e-e3a2-348375dca6c7

INSERT INTO public.resources (id, name, type, url, content, metadata, xp_earned, difficulty, category)
SELECT id, name, type, url, content, metadata, xp_earned, difficulty, category
FROM jsonb_populate_record(NULL::public.resources, $data${
 "id": "bff1bd62-b4b1-54fa-b8d7-563e479b4d4f",
 "name": "Simulacre B2: octubre 2022",
 "type": "jqcv_b2_oct2022",
 "category": "examen",
 "difficulty": "B2",
 "xp_earned": 40,
 "url": "/audio/Audio_B2_oct2022.mp3",
 "content": "Examen oficial B2 de la JQCV (octubre 2022): comprensió oral i escrita i estructures lingüístiques autocorregibles, dos redaccions i pràctica oral.",
 "metadata": {
  "icon": "🔌",
  "color": "#FFE0B2",
  "exam_body": "JQCV",
  "certificate_level": "B2",
  "exam": {
   "level": "B2",
   "session": "Octubre 2022",
   "body": "JQCV",
   "source_url": "https://jqcv.gva.es/documents/161863165/165492631/B2+octubre+2022.pdf/e2335bd4-ddb0-9b5e-e3a2-348375dca6c7",
   "audio_source_url": "https://jqcv.gva.es/documents/161863165/167041107/B2+octubre+2022.mp3/1ba6ebaf-4480-8ed0-bbbb-ba8862908bc6",
   "pass_rule": "Per a ser APTE cal una puntuació global mínima de 60 sobre 100. Les àrees valen un 20 % (comprensió oral), un 20 % (comprensió escrita), un 15 % (estructures lingüístiques), un 20 % (expressió escrita) i un 25 % (expressió oral), i en cada una cal arribar al mínim: el 40 % en les quatre primeres i el 50 % en l'expressió oral.",
   "areas": [
    {
     "n": 1,
     "title": "Comprensió oral",
     "weight": 20,
     "duration": "20 minuts",
     "audio": true,
     "intro": "Tot seguit escoltaràs dos àudios. Tots els àudios els escoltaràs dues vegades, amb una pausa entre cada audició, perquè assegures les respostes. Només hi ha una resposta correcta per a cada pregunta.",
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
       "instructions": "A continuació escoltaràs una entrevista a Aleix Eixea sobre els neandertals. Llig les preguntes i tria l’opció correcta en cada cas. Només hi ha una resposta correcta per a cada pregunta.",
       "questions": [
        {
         "n": 1,
         "prompt": "La secció de divulgació científica del programa tractarà sobre…",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "l’habitatge i els costums socials dels pobles paleolítics en terres valencianes."
          },
          {
           "key": "b",
           "text": "la troballa d’un jaciment exterior neandertal en una partida del terme d’Asp."
          },
          {
           "key": "c",
           "text": "l’ocupació del territori i el desenvolupament industrial dels pobles del paleolític."
          }
         ]
        },
        {
         "n": 2,
         "prompt": "La persona entrevistada en el programa, l’investigador Aleix Eixea…",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "és expert en migracions humanes i en assentaments prehistòrics."
          },
          {
           "key": "b",
           "text": "lidera l’equip de treball que formen les universitats d’Alacant i de València."
          },
          {
           "key": "c",
           "text": "va ser el primer expert que va catalogar les ferramentes del jaciment."
          }
         ]
        },
        {
         "n": 3,
         "prompt": "Aquest jaciment d’Asp es considera tan important perquè...",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "es localitza en un entorn natural on també hi havia altres jaciments."
          },
          {
           "key": "b",
           "text": "proporciona informació nova sobre l’estil de vida a les coves."
          },
          {
           "key": "c",
           "text": "dona dades sobre les tasques que els neandertals feien a l’exterior."
          }
         ]
        },
        {
         "n": 4,
         "prompt": "El treball de camp que fan els investigadors al jaciment...",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "es desenvolupa al llarg de tot l’any, excepte als mesos d’estiu."
          },
          {
           "key": "b",
           "text": "consisteix a localitzar-ne la ubicació i extraure’n els materials."
          },
          {
           "key": "c",
           "text": "inclou totes les tasques fins a arribar a la publicació de resultats."
          }
         ]
        },
        {
         "n": 5,
         "prompt": "Es pensa que aquest jaciment era per als neandertals...",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "l’indret on passaren una estada durant el seu camí cap a la costa."
          },
          {
           "key": "b",
           "text": "l’hàbitat on van establir la seua residència habitual des del principi."
          },
          {
           "key": "c",
           "text": "un assentament puntual al qual van acudir de manera recurrent."
          }
         ]
        }
       ]
      },
      {
       "n": 2,
       "kind": "binary",
       "instructions": "Llig els enunciats i relaciona’ls amb els consells que escoltaràs en les audicions per a estalviar en el consum d’energia i rebaixar l’import final de la factura de la llum. Tin en compte que hi ha dos enunciats que no corresponen a cap consell: marca «No surt» en eixos dos i numera la resta de l’1 al 5 seguint l’ordre en què apareixen en l’àudio.",
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
         "prompt": "S’aconsella, sempre que es puga, desconnectar els aparells de casa de la xarxa elèctrica, fins i tot quan estiguen apagats.",
         "answer": "5"
        },
        {
         "n": 7,
         "prompt": "No només hem de programar els electrodomèstics en les hores vall, sinó que també ens hem de fixar en l’eficiència dels aparells.",
         "answer": "3"
        },
        {
         "n": 8,
         "prompt": "Una mesura per a estalviar energia és fer un ús més puntual dels aparells que més consumeixen, com la rentadora i el llavaplats.",
         "answer": "x",
         "scored": false
        },
        {
         "n": 9,
         "prompt": "Si tenim un coneixement acurat de les tarifes podem triar de manera correcta la que més s’ajuste a les nostres necessitats de consum.",
         "answer": "1"
        },
        {
         "n": 10,
         "prompt": "Si es contracta la potència elèctrica més adequada a cada habitatge, l’import total de la factura es pot reduir en un 7 %.",
         "answer": "x",
         "scored": false
        },
        {
         "n": 11,
         "prompt": "Regular de manera adequada la temperatura dels sistemes i aparells de calor implicarà un estalvi econòmic significatiu.",
         "answer": "2"
        },
        {
         "n": 12,
         "prompt": "En els casos en què la instal·lació siga només elèctrica, l’import de la factura serà menor si es revisa la potència contractada.",
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
       "instructions": "Llig atentament el text següent i completa’l amb les propostes de la graella. Tin en compte que hi ha tres propostes que no has d’utilitzar.",
       "reading": {
        "title": "El punt de partida: l'espai públic",
        "paragraphs": [
         "L'espai públic pot ser definit d'una manera tan senzilla com ara el lloc on es troben dos desconeguts. La diferència entre públic i privat està en la quantitat de coneixement que una persona o un grup té sobre els altres. En l'àmbit privat, com ara en una família, normalment coneixem els altres molt bé i de prop, (13) ______ en l'àmbit públic no és així. En l'espai públic, el coneixement incomplet s'adiu amb l'anonimat.",
         "L'espai públic és, (14) ______, un lloc. Tradicionalment, aquest lloc s'havia definit a partir de la seua localització física i, per això, les (15) ______ sobre l'espai públic han estat, també tradicionalment, lligades a les ciutats: l'espai públic s'identificava amb les places, els carrers, els teatres, els cafés, les sales de conferències o les seus governamentals, llocs on gent desconeguda podia trobar-se fàcilment. Hui en dia, les tecnologies de la informació han alterat de manera radical el sentit de lloc: ara l'espai públic el trobem tant al ciberespai com, literalment, al lloc físic.",
         "La qüestió més important sobre l'espai públic és entendre que hi passa. Posar desconeguts en contacte permet un cert tipus d'activitats que no es donen o que no és tan fàcil que es donen en la intimitat de l'esfera (16) ______. En públic, la gent pot accedir a un nou coneixement i (17) ______ així els horitzons de la seua quantitat d'informació. Els mercats depenen d'aquests horitzons d'informació en expansió. En públic, la gent pot parlar i debatre amb altra gent amb qui potser no comparteix punts de vista o interessos. El govern democràtic depén d'aquesta mena d'intercanvis entre desconeguts. L'àmbit públic ofereix a la gent la possibilitat de no estar tan sotmesa a la pressió de la conformitat amb l'entorn, a no haver d'(18) ______ un rol (19) ______ en l'ordre social. L'anonimat i la impersonalitat proporcionen un entorn adequat per al desenvolupament individual. Aquesta possibilitat d'(20) ______ una vida nova entre desconeguts ha empés milers de migrants cap a les ciutats.",
         "Una de les escoles modernes de pensament que han provat d’explicar l’espai públic s’identifica amb els escrits de Hanna Arendt. Aquesta autora pensa en l'espai públic sobretot en termes polítics, tot i que entén la política d'una manera (21) ______. Imagina un àmbit (22) ______ en el qual les persones puguen enraonar i debatre de manera lliure. Per a aconseguir-ho, cal que deixen de banda les seues circumstàncies personals i privades. Aquesta idea és potent: siguen quins siguen els orígens, el gènere, l'estil de vida o la classe, tothom hauria de tindre la mateixa veu com a ciutadans, perquè les (23) ______ privades no tenen cabuda en l'espai públic. Va ser amb aquest projecte tan vigorós que Arendt va desafiar el concepte de nacionalitat o de raça com a base de la ciutadania a l'Alemanya nazi. Hui, a les democràcies occidentals, se la considera la bèstia negra de la política (24) ______."
        ]
       },
       "options_title": "Propostes",
       "options": [
        {
         "key": "a",
         "text": "reduir"
        },
        {
         "key": "b",
         "text": "encetar"
        },
        {
         "key": "c",
         "text": "lluites"
        },
        {
         "key": "d",
         "text": "fix"
        },
        {
         "key": "e",
         "text": "disquisicions"
        },
        {
         "key": "f",
         "text": "àmplia"
        },
        {
         "key": "g",
         "text": "ideal"
        },
        {
         "key": "h",
         "text": "a més"
        },
        {
         "key": "i",
         "text": "circumstàncies"
        },
        {
         "key": "j",
         "text": "no obstant això"
        },
        {
         "key": "k",
         "text": "privada"
        },
        {
         "key": "l",
         "text": "mentre que"
        },
        {
         "key": "m",
         "text": "adoptar"
        },
        {
         "key": "n",
         "text": "identitària"
        },
        {
         "key": "o",
         "text": "expandir"
        }
       ],
       "questions": [
        {
         "n": 13,
         "prompt": "Buit 13",
         "answer": "l"
        },
        {
         "n": 14,
         "prompt": "Buit 14",
         "answer": "h"
        },
        {
         "n": 15,
         "prompt": "Buit 15",
         "answer": "e"
        },
        {
         "n": 16,
         "prompt": "Buit 16",
         "answer": "k"
        },
        {
         "n": 17,
         "prompt": "Buit 17",
         "answer": "o"
        },
        {
         "n": 18,
         "prompt": "Buit 18",
         "answer": "m"
        },
        {
         "n": 19,
         "prompt": "Buit 19",
         "answer": "d"
        },
        {
         "n": 20,
         "prompt": "Buit 20",
         "answer": "b"
        },
        {
         "n": 21,
         "prompt": "Buit 21",
         "answer": "f"
        },
        {
         "n": 22,
         "prompt": "Buit 22",
         "answer": "g"
        },
        {
         "n": 23,
         "prompt": "Buit 23",
         "answer": "i"
        },
        {
         "n": 24,
         "prompt": "Buit 24",
         "answer": "n"
        }
       ]
      },
      {
       "n": 4,
       "kind": "match",
       "instructions": "A continuació llegiràs diverses crítiques musicals. Relaciona-les amb els enunciats. Hi ha tres enunciats que no corresponen a cap crítica musical.",
       "options_title": "Enunciats",
       "options": [
        {
         "key": "a",
         "text": "Un cant a l’evolució cap a la maduresa, un elogi a la senzillesa de cada dia."
        },
        {
         "key": "b",
         "text": "La creativitat sembla inesgotable per a un duet que torna a sorprendre’ns."
        },
        {
         "key": "c",
         "text": "L’artista de trajectòria consolidada s’envolta de col·laboradors excepcionals."
        },
        {
         "key": "d",
         "text": "Un àlbum compromés amb els problemes socials dels nostres dies."
        },
        {
         "key": "e",
         "text": "El trio ens sorprén amb un àlbum en què la melodia es barreja amb tocs de bossa nova."
        },
        {
         "key": "f",
         "text": "El debut discogràfic d’aquesta parella musical suggereix un món de conte."
        },
        {
         "key": "g",
         "text": "Aquest recull de temes molt personals podrien convertir-se en un himne generacional."
        },
        {
         "key": "h",
         "text": "Aquest àlbum recopilatori esdevé imprescindible per als amants d’aquest conjunt mític."
        },
        {
         "key": "i",
         "text": "Un treball artístic fruit de l’estima pel lirisme i d’una preparació excel·lent."
        },
        {
         "key": "j",
         "text": "L’artista crea un còctel de sensacions sense allunyar-se del seu paisatge més immediat."
        }
       ],
       "questions": [
        {
         "n": 25,
         "prompt": "Òscar Peris és un jove cantant valencià que es va donar a conéixer fa dos anys amb el disc Zero per infinit. I no ha passat molt de temps abans de presentar-nos aquest nou treball, amb unes cançons prou elaborades, tant melòdicament com pel que fa al text, i cantades amb una veu nasal ben particular. Acompanyat per l’instrumentista Roger Gascon, Òscar ens ofereix unes cançons que mostren les seues preocupacions, sobretot pel que fa a la situació de la llengua (\"Emergència lingüística\"). Si a \"Un noi de poble\" es fa ressò dels resultats polítics del populisme, a \"Socialisme espiritual\" somnia en un nou sistema que supere els encotillaments actuals.",
         "answer": "d"
        },
        {
         "n": 26,
         "prompt": "Voraigua és un duet format per Muntsa Moral i Paul Perera que s'estrena discogràficament amb aquest àlbum, Meandres, bastit al voltant del tema de l'aigua. Comença amb uns tocs de flamenc, que després es transformen en una mena de cant que crea un clima de llegenda. De vegades, la veu masculina i la femenina es combinen, però el més habitual és que la Muntsa Moral exhibisca en solitari les seues possibilitats vocals, més lligades a la sensibilitat que no a la potència, i que arriben sovint a un gran nivell expressiu, en un bell diàleg amb el piano de Pau Perera. Un àlbum molt suggeridor, que vessa sensibilitat.",
         "answer": "f"
        },
        {
         "n": 27,
         "prompt": "Els últims àlbums d'Enric Hernàez eren Prop la via del tren (2017) i Himnes (2019)... Ara arriba aquest 10 cançons amb els teclats i les guitarres d'Enric, la percussió d'Álvaro Pérez i la guitarra de Mario Maeso. Mario és l’autor de \"Divan\", l'únic tema que no està signat pel cantant, a banda de \"Cara\", un tema compost sobre un text de Mercè Serramalera, que hi posa la veu. Hernàez observa, sent, juxtaposa imatges tot creant ambients i sensacions, i sense fer cap judici, tot i que a \"Les trompetes de Jericó (pregària per la desaparició de Donald Trump)\" mostra una indignació apocalíptica, matisada per un rerefons jazzístic.",
         "answer": "c"
        },
        {
         "n": 28,
         "prompt": "Sequoia és un grup format per Víctor Llonch, Edu Vilardaga i Ramon Pedret. En el seu primer disc, Vint-i-pocs, reflexionen sobre la joventut des de la joventut, i presenten una estètica lligada als referents folk, sense oblidar algunes escapades cap a la música electrònica. A més, escriuen uns textos interessants que volen reproduir sovint les petites coses de la vida quotidiana (en aquest sentit, \"Van ser molts anys\" és una petita joia). Són cançons que fan sentir el pas de l'adolescència a l'edat adulta, de les emocions pures a la seua gestió intel·lectual. Algunes cançons són en anglés, però la major part estan escrites i cantades en català.",
         "answer": "a"
        },
        {
         "n": 29,
         "prompt": "En pocs anys, la jove Gemma Humet s'ha consolidat com una de les nostres veus més interessants, però en aquest últim disc aferma també el seu talent com a autora i compositora. L'àlbum Màtria està plantejat des d'una sensibilitat feminista polièdrica. S'obri amb un breu poema de Maria-Mercè Marçal (\"Damunt un cel de fil\") i es tanca amb un text (\"Mare\") que mira de fer compatibles els lligams teixits per l'amor i els anhels de llibertat. Entre la tendresa i la revolta, elabora un discurs poètic coratjós i estèticament atractiu, gràcies a una veu que posa la tècnica al servei de la comunicació i a unes línies melòdiques encertades.",
         "answer": "i"
        },
        {
         "n": 30,
         "prompt": "En Manel Joseph és un tot terreny incombustible i Postal de la Mediterrània és un dels seus millors treballs i el més unitari, basat en textos de Manuel Dolz i música del saxofonista Pep Torres. Es tracta d'un recorregut tant geogràfic com musical per la Mediterrània en el qual la preciosa cançó \"Mercè\" clava les arrels en la bossa nova. Els textos de Dolz parlen de vides que es troben i se separen, del mar que ens bressola i del dolor que s'hi passeja, de la vida que fa mal, però que ens obliga a estimar-la amb passió.",
         "answer": "j"
        },
        {
         "n": 31,
         "prompt": "Xavier Carles i Xavier Batllés no descansen: pocs mesos després del seu quart àlbum conjunt, arriba Ànima nua, en el qual Xavier Carles s'anima a cantar. Com sempre, la música impecable de Xavier Batllés, que disposa de selectes col·laboradors, cantants i instrumentistes, es posa al servei de la paraula. L'àlbum és una passejada a la recerca de la bellesa, una reivindicació de la llibertat creativa i de les possibilitats del mot i del so. Un dels moments més curiosos del disc és \"Sospirança\", una meditació sobre com haurien de ser els arranjaments de l'anomenada \"cançó d'autor\", i de com la paraula i la música s'han de relacionar mútuament.",
         "answer": "b"
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
       "instructions": "En el següent text s’han eliminat algunes paraules. Per a cada espai en blanc tens tres opcions de resposta. Només una és correcta. Fixa’t en l’exemple (número 0).",
       "reading": {
        "title": "Neveres",
        "paragraphs": [
         "La tardor, enguany, ha volgut (0) assemblar-se a les tardors d'abans: càlida alguns dies, però en general fresca i plujosa. Si les previsions no fallen, la dinàmica de l'hivern serà pareguda, és a dir, relativament normal: les temperatures no (32) ______ massa altes i tindríem episodis de precipitacions que, de tant en tant, caurien en forma de neu a l'interior del nostre país. Ara tenim radars, satèl·lits i nombrosos instruments que ens (33) ______ seguir i pronosticar els fenòmens atmosfèrics amb un grau d'encert molt elevat, però el canvi climàtic ens convida a ser prudents i estar a l'expectativa, com ens recorda l'experiència recent de la borrasca Filomena. Siga com siga, la capacitat d'anàlisi i previsió és espectacular si la comparem amb la del món preindustrial.",
         "(34) ______, antigament la gent també aconseguia domesticar els efectes de la meteorologia, probablement sense la voracitat que ens ha dut a la crisi actual. Un dels testimonis més interessants d'això són les nombroses neveres que s'escampen pel nostre territori. La neu sempre s'havia utilitzat per a finalitats terapèutiques i per a conservar i transportar aliments, però les baixes temperatures que es van registrar a Europa durant l'edat moderna (coneguda com la petita edat de gel) (35) ______ encara més els usos de la neu, que es podia emmagatzemar relativament prop de la costa, com demostra el cas de la nevera de la Murta, molt prop d'Alzira. (36) ______, les neveres, caves, clots i pous solen trobar-se una miqueta més retirades, enfilades a les muntanyes (com la cèlebre Cava Arquejada d'Agres) o construïdes en valls i fondalades (com la Cava de Sant Blai de Bocairent). Les més abundants i famoses es troben a les comarques de la Marina, la Vall d'Albaida, el Comtat i l'Alcoià, (37) ______ pot estar àmpliament relacionat amb la indústria del gelat i l'extraordinària aventura comercial dels fundadors d'orxateries (només (38) ______ pensar en les referències als pobles i als cognoms de la zona en el nom de nombrosos establiments: Ibense, Xixonenca, Sirvent, Planelles, etc.). Però, de neveres, (39) ______ en quasi totes les zones de muntanya del nostre territori, des de la Safor fins a les serres del nord, on trobem la nevera dels Regatxols a Ares o la de Castro a Alfondeguilla.",
         "D'aquests pous de gel no tan coneguts, voldria (40) ______ un, el de Tuéjar (Toixa), situat al camí que va des de l'assut homònim fins a la font d'Arquela, ja en terme d'Alpuente (Alpont). Com totes aquestes construccions, sobreïx la part superior de la nevera, una mena de casup de pedra, de planta redona i rematat amb una coberta que té forma de volta. En una de les parets, observem una porta per a accedir al pou pròpiament dit, que sovint té més de set metres de fondo.",
         "Més enllà de constatar que el comerç de la neu s'escampava per tot l'antic Regne de València, la visita a la nevera de Tuéjar ens convida a recórrer un paratge bellíssim, amb cingles imponents, dominats pels voltors, i amb una vegetació exuberant, fruit de l'abundància de rierols, fonts i barrancs. I, encara més, ens convida (41) ______ coneguem millor els Serrans, una comarca en certa mesura oblidada, que reclama el seu lloc en l'imaginari col·lectiu i en la realitat mediambiental, cultural i econòmica dels valencians."
        ]
       },
       "questions": [
        {
         "n": 32,
         "prompt": "Buit 32",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "serien"
          },
          {
           "key": "b",
           "text": "foren"
          },
          {
           "key": "c",
           "text": "sigueren"
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
           "text": "permitiran"
          },
          {
           "key": "b",
           "text": "permeteixen"
          },
          {
           "key": "c",
           "text": "permeten"
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
           "text": "Malauradament"
          },
          {
           "key": "b",
           "text": "Tanmateix"
          },
          {
           "key": "c",
           "text": "Per això"
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
           "text": "devien d’estimular"
          },
          {
           "key": "b",
           "text": "devien estimular"
          },
          {
           "key": "c",
           "text": "havien d’estimular"
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
           "text": "Per descomptat"
          },
          {
           "key": "b",
           "text": "Fet i fet"
          },
          {
           "key": "c",
           "text": "Amb tot"
          }
         ]
        },
        {
         "n": 37,
         "prompt": "Buit 37",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "fet que"
          },
          {
           "key": "b",
           "text": "cosa que"
          },
          {
           "key": "c",
           "text": "la qual cosa"
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
           "text": "hi ha que"
          },
          {
           "key": "b",
           "text": "es deu de"
          },
          {
           "key": "c",
           "text": "cal"
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
           "text": "hi havia"
          },
          {
           "key": "b",
           "text": "n’hi havia"
          },
          {
           "key": "c",
           "text": "havia"
          }
         ]
        },
        {
         "n": 40,
         "prompt": "Buit 40",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "destacar-hi"
          },
          {
           "key": "b",
           "text": "destacar-ne"
          },
          {
           "key": "c",
           "text": "destacar"
          }
         ]
        },
        {
         "n": 41,
         "prompt": "Buit 41",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "que"
          },
          {
           "key": "b",
           "text": "a què"
          },
          {
           "key": "c",
           "text": "a que"
          }
         ]
        }
       ]
      },
      {
       "n": 6,
       "kind": "choice",
       "instructions": "En el següent text s’han eliminat algunes paraules. Per a cada espai en blanc tens tres opcions de resposta. Només una és correcta. Fixa’t en l’exemple (número 0).",
       "reading": {
        "title": "Vestir a la moda? TikTok sap com fer-ho",
        "paragraphs": [
         "Vestir amb americanes, texans acampanats o faldilles curtes ja no és (0) trencador. En canvi, si ho combines amb una cotilla exterior i unes ballarines que recorden les que (42) ______ Natalie Portman al thriller psicològic El cigne negre, ja és una altra cosa: vas a la moda. Com que l’estil hegemònic popularitzat durant els anys 60, 70 o 80 ja forma part de la nostra indumentària habitual, necessitem elements innovadors que ens deixen sentir que, a part de revisitar les tendències passades, també n’estem generant de noves. Xarxes socials com TikTok o Instagram (43) ______ aquest fenomen i s’encarreguen de popularitzar estils i predir tendències basades tant en l’opinió dels usuaris com en la cultura pop que els envolta: el vestuari de pel·lícules, de sèries, de (44) ______, etc. Només cal que es popularitze una sèrie ambientada en l’època victoriana -com és el cas de The Bridgerton- perquè aquella estètica concreta es torne a posar de moda.",
         "(45) ______ amb noms com regencycore, cottagecore o balletcore, en TikTok trobem ara aquestes tendències en les quals predomina la nostàlgia femenina i la romantització d’èpoques passades, ja siga la dècada dels 70 o l’any 2015. L’experta en tendències i moda juvenil Anna Pompilio ho vincula a la (46) ______ que ens acompanya des de l’inici de la pandèmia: “Aquests dos últims anys han estat plens de precarietat i dubtes, per això veiem com els joves busquen estètiques que els resulten còmodes i els ajuden a escapar de l’ansietat quotidiana”.",
         "TikTok és una eina digital acceleradora del consum que s’ha convertit en el lloc perfecte perquè s’hi generen i hi habiten les tendències. “Com que en aquesta aplicació constantment s’hi promou la novetat, és molt difícil que les modes s’establisquen i s’estabilitzen, perquè el mercat està sempre canviant”, apunta Isa Uribé, consultora de moda i professora de tendències i estilisme. Això provoca una reducció de la durada de les tendències, ara considerades (47) ______, que viuen entre 1 i 5 mesos i muten en funció dels discursos en línia predominants. Aquesta (48) ______ alimenta un consum massiu i molt poc (49) ______ al qual tothom té accés de manera fàcil i ràpida. Tal com apunta Rebecca Jennings, periodista especialitzada en creació de contingut en línia, “les xarxes socials han permés que gent completament desvinculada del sector puga determinar noves modes tot (50) ______ els emissors tradicionals de tendències”. L'accessibilitat i l’algoritme de TikTok desplacen l’hegemonia comunicativa de mitjans com les revistes de moda i obrin la porta a milions de persones que, des de qualsevol lloc, calibren i prediuen aquestes tendències amb la credibilitat que la viralitat del seu contingut els atorga. No obstant això, Jennings també fa referència a l’efecte contrari causat per aquest consum tan fugaç: “La tendència en qüestió s’explota amb tanta intensitat i apareix en tants vídeos que ràpidament se satura. Allò que feia dues setmanes era completament nou ara ja ho hem vist en tots els perfils de TikTok i ja no m’interessa vestir-ho”. D'exemples, podem trobar-ne (51) ______: els anells de plàstic, els tops de ganxet o les bosses peludes."
        ]
       },
       "questions": [
        {
         "n": 42,
         "prompt": "Buit 42",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "lluïa"
          },
          {
           "key": "b",
           "text": "lluía"
          },
          {
           "key": "c",
           "text": "lluia"
          }
         ]
        },
        {
         "n": 43,
         "prompt": "Buit 43",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "ampraren"
          },
          {
           "key": "b",
           "text": "emparen"
          },
          {
           "key": "c",
           "text": "empraren"
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
           "text": "pasarel·les"
          },
          {
           "key": "b",
           "text": "passareles"
          },
          {
           "key": "c",
           "text": "passarel·les"
          }
         ]
        },
        {
         "n": 45,
         "prompt": "Buit 45",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "Batetjades"
          },
          {
           "key": "b",
           "text": "Batejades"
          },
          {
           "key": "c",
           "text": "Bategades"
          }
         ]
        },
        {
         "n": 46,
         "prompt": "Buit 46",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "incertessa"
          },
          {
           "key": "b",
           "text": "incertea"
          },
          {
           "key": "c",
           "text": "incertesa"
          }
         ]
        },
        {
         "n": 47,
         "prompt": "Buit 47",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "microtendències"
          },
          {
           "key": "b",
           "text": "micro-tendències"
          },
          {
           "key": "c",
           "text": "micro tendències"
          }
         ]
        },
        {
         "n": 48,
         "prompt": "Buit 48",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "efervecència"
          },
          {
           "key": "b",
           "text": "efervessència"
          },
          {
           "key": "c",
           "text": "efervescència"
          }
         ]
        },
        {
         "n": 49,
         "prompt": "Buit 49",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "rentable"
          },
          {
           "key": "b",
           "text": "sostenible"
          },
          {
           "key": "c",
           "text": "rendible"
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
           "text": "obviant"
          },
          {
           "key": "b",
           "text": "coneixent"
          },
          {
           "key": "c",
           "text": "obeint"
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
           "text": "a bastament"
          },
          {
           "key": "b",
           "text": "a doll"
          },
          {
           "key": "c",
           "text": "a borbollons"
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
         "text": "L'augment exponencial dels costos de producció provoca que moltes empreses facen tots els possibles per a no perdre diners. Un dels mètodes més habituals és oferir menys producte al mateix preu, però sense canviar la grandària de l’envàs original. Has detectat que l’última ampolla de xampú de la teua marca de confiança costa el mateix de sempre, però conté 50 ml menys. Decideixes enviar un correu electrònic al servei d’atenció al client de l’empresa per a fer-los arribar una queixa.",
         "points": [
          "Mostra indignació per la pujada encoberta del preu d’aquest producte.",
          "Explica de quina manera aquesta pràctica afecta l’economia domèstica.",
          "Suggereix alternatives per a una pràctica comercial més transparent."
         ]
        },
        {
         "key": "B",
         "text": "Els museus han experimentat una diversificació en els últims anys per tal de mantindre el nombre de visitants. La funció purament expositiva ha donat lloc a altres usos enfocats a accions més lúdiques i comercials. Pertanys a l’associació Amics dels Museus i t’han encomanat que escrigues un article d’opinió que es publicarà en el web de l’associació, en què reflexiones sobre aquest fenomen.",
         "points": [
          "La digitalització dels fons permet fer visites virtuals sense haver d’eixir de casa.",
          "Els restaurants i les botigues dels museus són el reclam per a visitar-los.",
          "El futur dels museus com a espai polivalent que reuneix cultura i oci."
         ]
        }
       ]
      },
      {
       "n": 8,
       "kind": "writing",
       "title": "Text per a un diari digital",
       "instructions": "El diari digital Al Dia demana la participació dels lectors i de les lectores per a elaborar una secció en què s’expliquen algunes fórmules i estratègies per a aconseguir desconnectar dels elements i de les situacions que ens causen estrés, com les preocupacions laborals o les notícies roïnes sobre l’actualitat. A partir d’aquests dibuixos, envia un text per al diari en què opines sobre aquest fenomen, i explica quines són les alternatives que et funcionen quan vols evadir-te de les preocupacions del dia a dia. El text ha de tindre entre 120 i 140 paraules.",
       "min_words": 120,
       "max_words": 140,
       "image": "/exams/b2-octubre-2022/e8-desconnectar.jpg",
       "image_text": "Dos dibuixos. Primer dibuix (fet a mà): dues persones assegudes d'esquena en un sofà (rètol «Sofà»), amb les cames encongides, mirant una televisió encesa (rètol «Sèries»); a la dreta, una finestra per on es veu l'exterior, assenyalat amb una fletxa i el rètol «Caos». Segon dibuix (il·lustració): un home d'esquena, amb barret i camisa estampada, que alça els braços amb alegria davant d'un paisatge de platja amb palmera, para-sol, núvols, sol i un castell d'arena; al seu costat hi ha una maleta amb rodes, una bossa de viatge, una pilota i un poal amb una pala (vacances, viatge)."
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
         "title": "Monòleg · La reducció de l’horari laboral",
         "duration": "3 minuts",
         "intro": "La disminució de l’horari de treball és una qüestió que fa temps que està plantejada, però que avança amb dificultat perquè hi ha molts interessos en contra, malgrat que existeix també molta evidència que demostra que pot millorar el benestar dels treballadors i treballadores. Explica quins són els avantatges que tindria una reducció dels horaris laborals i quins problemes podria comportar.",
         "questions": [],
         "images": []
        },
        {
         "title": "Monòleg · Un amic és un tresor?",
         "duration": "3 minuts",
         "intro": "L’amistat és un factor important per al benestar, mentre que la solitud i l’aïllament social s’associen amb un risc més alt de patir trastorns com la depressió o l’ansietat. De la mateixa manera que disposem d’orientacions i recomanacions sobre el nombre d’hores que convé dormir i l’activitat física que hem de fer, aquest també és un tema rellevant per a la salut. Explica quins beneficis aporta el fet de tindre amics i quins problemes ens pot ocasionar no triar-los bé.",
         "questions": [],
         "images": []
        }
       ]
      },
      {
       "n": 10,
       "kind": "oral",
       "instructions": "Has de mantindre un diàleg amb una altra o un altre aspirant sobre la situació comunicativa que et proposem. Has de defensar el paper de la teua persona i has d'arribar a un acord obligatòriament amb l’altra o l’altre aspirant.",
       "proposals": [
        {
         "title": "Diàleg · Visibilitat en les xarxes socials",
         "duration": "4 minuts",
         "intro": "Una persona influenciadora amb més de 30.000 seguidors i seguidores en Instagram proposa al propietari o propietària d’un restaurant un intercanvi: dos menús degustació debades a canvi d’una ressenya amb fotografies sobre el negoci.",
         "questions": [],
         "images": [],
         "roles": [
          {
           "name": "Persona A",
           "text": "Eres un influenciador o influenciadora que té més de 30.000 seguidors i seguidores en Instagram. Proposes al propietari o propietària d’un restaurant un intercanvi: que t’oferisca debades dos menús degustació a canvi de publicar ell o ella una ressenya amb fotografies sobre el seu negoci. Penses que la publicació podria donar-li molta visibilitat. A més, consideres que la despesa dels dos menús es podria veure com una inversió en publicitat."
          },
          {
           "name": "Persona B",
           "text": "Tens un restaurant i contacta amb tu una persona que té més de 30.000 seguidors i seguidores en Instagram. Et vol proposar un intercanvi: que li oferisques menjar debades dos menús degustació a canvi de publicar ell o ella una ressenya amb fotografies sobre el teu negoci. Penses que aquest influenciador o influenciadora simplement vol dinar gratis al teu restaurant. A més, consideres que aquesta visibilitat no es traduirà en un increment significatiu de clientela."
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
