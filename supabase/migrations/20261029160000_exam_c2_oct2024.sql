-- Examen interactiu C2 de la JQCV (octubre 2024) com a recurs de category 'examen'.
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
 "id": "a557572c-dd26-59be-ad25-30beb757f006",
 "name": "Simulacre C2: octubre 2024",
 "type": "jqcv_c2_oct2024",
 "category": "examen",
 "difficulty": "C2",
 "xp_earned": 40,
 "content": "Examen oficial C2 de la JQCV (octubre 2024): comprensió escrita i estructures lingüístiques autocorregibles, dos redaccions i pràctica oral.",
 "metadata": {
  "icon": "🏆",
  "color": "#D1C4E9",
  "exam_body": "JQCV",
  "certificate_level": "C2",
  "exam": {
   "level": "C2",
   "session": "Octubre 2024",
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
        "title": "L’educació com a camp de batalla",
        "paragraphs": [
         "En les últimes dècades, el sistema educatiu ha sigut objecte d’enormes pressions a fi d’adaptar-lo a les necessitats del món econòmic. Si diem que l’educació és un camp de batalla, és perquè la política educativa dominant perseguix, sobretot, la seua eficàcia. Es tracta d’assimilar l’educació a la producció de capital humà amb l’objectiu d’augmentar la competitivitat econòmica en el marc d’un món globalitzat. És conegut l’argot que advoca per transformar els sistemes escolars d’acord amb el nou esperit del capitalisme. En este context, la innovació educativa apareix com la palanca del canvi que permetrà superar les limitacions de la formació que hui oferixen la majoria d’escoles, instituts i universitats. Al nostre entendre, la innovació educativa és un concepte paradoxal. Innovar és modern, sofisticat, busca el desenvolupament de novetats. Ara bé, innovar no implica necessàriament una millora. En el context educatiu, tampoc. Tot seguit analitzarem el rumb que està prenent en tres aspectes diferents: la innovació vinculada a les aplicacions tecnològiques, l’enfocament pedagògic de les competències i el paper de l’educació emocional.",
         "Bona part del discurs al voltant de la innovació que invadix hui el camp educatiu ha quedat reduït a una qüestió metodològica buida de tota reflexió crítica i desconnectada dels entorns socioculturals dels centres educatius, així com de qualsevol aspiració política. Entre les múltiples propostes d’este culte a la innovació, brilla amb llum pròpia el paper de la tecnologia, que s’ha convertit en una autèntica ideologia amb què s’espera trobar la solució als reptes educatius de la nostra època. En l’actual model de negoci basat en el mercat de les dades, de la personalització i de l’atenció, la innovació pedagògica en marxa ha trobat la seua inspiració en la filosofia de Netflix, Uber i Pokémon Go, és a dir, formació a la carta, economia col·laborativa i ludificació com a base d’una educació tecnocràtica. D’acord amb la tecnoutopia imaginada des de Sillicon Valley, la fórmula és molt simple. En un context hiperconnectat, en què l’alumne és l’agent actiu i responsable del seu procés d’aprenentatge, es preveu la creació de llistes de reproducció educatives a partir de les dades processades per algoritmes. L’arquitectura pedagògica d’este model ja la trobem en els entorns d’ensenyança virtual. El rol dels professors, per exemple, s’ha vist transformat de dalt a baix. Les seues funcions es repartixen entre la producció d’alguns continguts i el disseny de propostes d’aprenentatge. No cal que es reforce la seua presència, sinó que, en molts casos, ni tan sols seran necessaris.",
         "Així les coses, el desenvolupament de tecnologies educatives i infraestructures digitals està aconseguint configurar una indústria de servicis educatius personalitzats que amenaça clarament l’estructura actual del sistema educatiu, considerat des de fa molt de temps com un sistema burocràtic, costós i ineficaç. Quin interés pot haver-hi a seguir finançant un sistema públic d’educació si les multinacionals tecnològiques poden proveir un servici educatiu a la carta? En la mesura que l’educació està deixant de concebre’s com un dret de la ciutadania i està començant a transformar-se en una inversió, els usuaris consumixen estos servicis a fi d’obtindre competències que afavorisquen la seua ocupabilitat. Entrem així en l’altre pilar de la transformació educativa, i és que res de tot això és alié a la promoció d’un nou tipus de subjectivitat, materialitzada en la figura de l’emprenedor. La inversió permanent en capital humà que oferiran les noves plataformes educatives requerix també el desenvolupament d’un altre tipus de maniobres capaces d’operar en un pla psicològic i instrumental.",
         "És ací a on cal situar el discurs pedagògic al voltant de les competències. La pedagogia de les competències es presenta hui com una innovació que ha de generar uns aprenentatges més integrats, més pràctics i més transferibles, i que té com a raó de ser la finalitat econòmica que s’atribuïx a l’educació. El gir que proposa este canvi de model s’orienta cap al cultiu de les competències que acaben convertint-se en un instrument de mesura del rendiment individual en termes de creativitat, capacitat d’adaptació i iniciativa emprenedora. Si el discurs al voltant de les competències troba tan poca contestació en el món educatiu és perquè compta amb la seua justificació pedagògica prenent com a referència la teoria de les intel·ligències múltiples. Això suposa, entre altres coses, la necessitat d’atendre la intel·ligència emocional dels alumnes i, per tant, la seua competència emocional. El grau de domini d’esta competència acabarà reflectint-se en l’àmbit social i laboral, i per això hui en dia es parla tant de la necessitat de fomentar l’educació emocional.",
         "Arribem així al tercer pilar a través del qual les pedagogies d’inspiració individualista han anat impregnant el discurs pedagògic de llenguatge psicològic. Conceptes com felicitat, necessitats emocionals, motivació, autoestima són, juntament amb el diagnòstic de múltiples trastorns de l’aprenentatge i un ampli mercat d’etiquetes i classificacions en salut mental infantil, alguns dels exemples més representatius de la colonització PSI del discurs educatiu. Sens dubte, tot això cal relacionar-ho amb les transformacions dels camps científic i mèdic, i el seu desplaçament cap al paradigma positivista i empirista (classificació, mesurament, observació, avaluació, etc.), reforçat per l’impuls de les neurociències cognitives, que han penetrat amb força en el món de l’educació. A poc a poc, programes d’educació emocional inspirats en la literatura científica comencen a formar part de les pràctiques de moltes escoles, sovint basades en el noble objectiu d’estimular i potenciar la motivació i l’aprenentatge dels alumnes. El desenvolupament d’este tipus de programes s’ha vist també emparat per l’avanç en termes culturals i comercials de la ciència de la felicitat.",
         "Edgar Cabanas i Eva Illouz, en un assaig recent, ens advertixen de fins a quin punt la felicitat s’ha convertit en un estil de vida, en una mentalitat i, en última instància, en un tipus de personalitat per a definir en termes psicològics l’ideal neoliberal del ciutadà contemporani. I és que la felicitat acaba tenint un paper cabdal per a obtindre el control de les nostres subjectivitats i modelar l’arquetip ideal del ciutadà neoliberal. Les tècniques i mètodes que desenvolupen els programes de psicologia positiva invoquen la satisfacció dels propis interessos, la gratificació emocional i la competitivitat, objectius prioritaris d’una formació que ha de preparar les noves generacions per a la implacable competició de la vida. En un moment en què la promesa de l’educació ha caigut, esta ha sigut substituïda per l’educació que promet la felicitat a través de l’educació emocional.",
         "Des de la nostra perspectiva, la funció educativa capaç de sostindre el compromís pedagògic és aquella que –d’acord amb Hannah Arendt– es fa càrrec d’obrir el món a les noves generacions, de fer que el món (el que hi ha més enllà d’u mateix i de la potenciació productiva del seu talent) els parle i els interpel·le. I allò que els ha d’interpel·lar té a vore amb l’aprenentatge, amb la iniciació al coneixement i a les destreses, amb la socialització en la cultura d’una societat entesa en un sentit ampli, i no amb l’exaltació emotiva del jo i la seua autonomia. Si ens apartem de l’enfocament psicològic de l’educació i ens posem a treballar a partir de la cultura dotem les generacions jóvens dels llenguatges que els permetran comunicar-se, i dels instruments gràcies als quals podran fer front als esdeveniments quotidians, dels conceptes que els donaran els mitjans per a comprendre el que els envolta. Defendre el compromís pedagògic suposa assumir el rol que tenim com a educadors de presentar la cultura com a mitjà que permet l’accés al pensament, i per tant a créixer i aprendre."
        ]
       },
       "questions": [
        {
         "n": 0,
         "prompt": "Canviar el sistema educatiu és un anhel molt cobejat...",
         "answer": "b",
         "scored": false,
         "options": [
          {
           "key": "a",
           "text": "perquè controlar l’ecosistema educatiu assegura el domini de l’espai públic."
          },
          {
           "key": "b",
           "text": "perquè no acaba de ser prou rendible per als interessos empresarials."
          },
          {
           "key": "c",
           "text": "perquè el capitalisme necessita més recursos materials."
          },
          {
           "key": "d",
           "text": "perquè el sistema està esgotat i requerix innovacions que el milloren."
          }
         ]
        },
        {
         "n": 1,
         "prompt": "Un dels principals eixos d’innovació ha sigut la tecnologia, i la seua aplicació…",
         "answer": "d",
         "options": [
          {
           "key": "a",
           "text": "s’ha qüestionat des de les institucions per l’impacte que té en l’aprenentatge."
          },
          {
           "key": "b",
           "text": "convertix els docents en actors principals en la transformació dels sistemes d’ensenyança i aprenentatge."
          },
          {
           "key": "c",
           "text": "demostra que el paradigma escolar actual està desfasat i no garantix una educació integral."
          },
          {
           "key": "d",
           "text": "tindrà un fort impacte en les relacions docent-discent i en la selecció i presentació dels continguts."
          }
         ]
        },
        {
         "n": 2,
         "prompt": "Els discursos que advoquen per l’enfocament competencial…",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "es van desenvolupar arran de l’eclosió de la teoria de les intel·ligències múltiples."
          },
          {
           "key": "b",
           "text": "permeten passar d’un paradigma centrat en els coneixements a un altre que focalitza l’atenció en les destreses."
          },
          {
           "key": "c",
           "text": "han sigut qüestionats per la comunitat educativa a causa del seu caràcter empresarial."
          },
          {
           "key": "d",
           "text": "defenen que l’educació ha de canviar per a ser més creativa i innovadora."
          }
         ]
        },
        {
         "n": 3,
         "prompt": "L’eclosió del discurs psicològic en el panorama educatiu…",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "està relacionat amb l’auge de les ciències i la medicina."
          },
          {
           "key": "b",
           "text": "sorgix a partir de la constatació de la diversitat d’accessos a l’aprenentatge."
          },
          {
           "key": "c",
           "text": "té a vore amb l’influx de la neurociència i dels paradigmes científics."
          },
          {
           "key": "d",
           "text": "està lluny de transferir-se a les aules, a pesar de la seua provada eficàcia."
          }
         ]
        },
        {
         "n": 4,
         "prompt": "La busca de la felicitat s’ha erigit com un dels objectius educatius perquè…",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "cal combatre la despersonalització de la ideologia neoliberal."
          },
          {
           "key": "b",
           "text": "al capitalisme li interessa proporcionar ferramentes de benestar individual davant de la ferocitat competitiva."
          },
          {
           "key": "c",
           "text": "l’aprenent alegre pren més consciència com a ciutadà."
          },
          {
           "key": "d",
           "text": "cal contrarestar l’arquetip ideal de ciutadà neoliberal."
          }
         ]
        },
        {
         "n": 5,
         "prompt": "S’entén que articular un autèntic compromís pedagògic passa per…",
         "answer": "d",
         "options": [
          {
           "key": "a",
           "text": "donar importància al docent com a mediador entre el subjecte i el pensament."
          },
          {
           "key": "b",
           "text": "vincular l’ensenyança de les matèries amb l’enfocament psicològic."
          },
          {
           "key": "c",
           "text": "acomplir la promesa educativa trencada de la inserció laboral a través del mèrit."
          },
          {
           "key": "d",
           "text": "enfocar l’educació perquè l’aprenent pense a través de la cultura i intervinga en la societat."
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
       "instructions": "Completa el text que tens a continuació amb l’alternativa més precisa i adequada. Només hi ha una opció vàlida per a cada buit. Fixa’t en l’exemple (número 0).",
       "reading": {
        "title": "La Dama dels Escacs, reina de la Corona d’Aragó?",
        "paragraphs": [
         "La primera al·lusió a la reina dels escacs apareix en un poema escrit en valencià (0) cap a 1475 titulat Scachs d’amor, (6) ______ autors el cavaller Francesc de Castellví, el ciutadà Narcís Vinyoles i el capellà Bernat Fenollar, conservat en un manuscrit que no arribà a publicar-se en el seu moment i que segurament desaparegué durant la Guerra Civil espanyola. En Scachs d’amor es reproduïx per primera vegada en la història una partida d’escacs amb les regles modernes del joc, que s’(7) ______ ràpidament per Europa a partir de la publicació (8) ______ 1495 del Llibre dels jochs partits dels scachs en nombre de 100 de Francesc Vicent, jueu valencià convers que prompte hauria de fugir a Itàlia. Afortunadament un bibliòfil català de renom, Ramon Miquel i Planas, fotografià íntegrament el manuscrit de Scachs d’amor en 1914 i el traduí al castellà en prosa. (9) ______ tot això, fins ara l’opinió més generalitzada atribuïa la creació de la dama dels escacs fonamentalment a la figura d’Isabel la Catòlica, reina de Castella. Però no totes les opinions expertes són coincidents en este aspecte.",
         "El treball del periodiste i croniste oficial de la ciutat de Sogorb, Rafael Martín, defén la tesi que la reina que (10) ______ en el poema Scachs d’amor de Castellví, Vinyoles i Fenollar, contemporanis de Francesc Vicent, no és Isabel I de Castella, monarca al cap i a la fi estrangera per a ells, sinó Maria de Luna (Sogorb, 1357 - Vila-real, 1406), esposa de Martí l’Humà (un rei amb una bona col·lecció de jocs i llibres d’escacs), reina d’Aragó, senyora de Sogorb i nascuda i enterrada també a Sogorb. (11) ______, segons l’esmentat Rafael Martín, “la mateixa base documental en la qual s’ha recolzat la identificació amb Isabel la Catòlica ho desmentix”. En concret, en l’estrofa 54 del poema original es diu textualment que a la reina, en l’acte de la seua proclamació, se li va atorgar el pom, el (12) ______ i la cadira (el tron). Però, segons el croniste sogorbí, “lo pom” fa indubtablement referència a l’(13) ______, a la bola del món que, amb creu o sense creu, s’entrega als monarques en la coronació, i, per contra, “els cronistes (14) ______ que van descriure l’acte de proclamació d’Isabel com a reina de Castella el 13 de desembre de 1474 a Segòvia es detenen en nombrosos detalls però no hi ha cap comentari als elements atorgats, (15) ______ sí que ho fan per a altres elements com les vares de la justícia, les claus de l’alcàsser o el penó reial de Castella”. Amb tot, es proposà com a hipòtesi que el poema Scachs d’amor podria haver sigut escrit en homenatge a la reina castellana, també per la proximitat cronològica dels dos fets.",
         "Martín, però, troba en això una sèrie de contradiccions i considera “il·lògic” que, després dels (16) ______ que s’havien produït entre la Corona d’Aragó i la de Castella al llarg del segle XV, uns autors valencians dedicaren la seua creació a Isabel. S’obria, doncs, la possibilitat de buscar una reina alternativa a Isabel que complira tots els detalls atribuïts en el manuscrit, una acció que no resulta massa difícil, (17) ______, en l’àmbit dels escriptors del poema, hi hagué ben poques reines que foren coronades amb els tres elements mencionats. Centrant-nos en la Corona d’Aragó, encara que les dones no podien accedir al tron com a reines titulars –segons s’hi deia, pel “costum”–, (18) ______ coneixen algunes reines que foren coronades, per tal de reconéixer públicament i simbòlicament el seu paper com a senyores més poderoses de tots els seus dominis. En concret, la història conta que l’any 1396 la inesperada i enigmàtica mort de Joan I, quan practicava la caça, agarrà desprevingut el seu germà Martí, ocupat en la pacificació de Sicília i en el fet d’assegurar el domini de l’illa per al seu fill, Martí el Jove, (19) ______ la seua esposa, Maria de Luna, assumí el govern de la Corona d’Aragó durant més d’un any com a (20) ______ general. Durant eixa regència, Maria defengué amb força els interessos del seu marit absent contra les conspiracions de la reina viuda, Violant de Bar, que pretenia mantindre el seu (21) ______ en el tron al·legant que estava embarassada; alhora, també hagué de resoldre la greu situació creada per les pretensions en paral·lel del seu nebot, el comte de Foix, casat amb una filla de Joan I.",
         "Maria demostrà unes capacitats extraordinàries com a estratega i diplomàtica, i quan el rei Martí tornà als seus dominis, conscient de l’esforç i l’interés que ella havia mostrat en la defensa dels seus interessos i els grans dots de (22) ______ que havia evidenciat, decidí tributar-li el reconeiximent degut. Martí fon coronat el 13 d’abril de 1399 a la catedral de Saragossa i reservà per a la seua muller, Maria de Luna, la data del 23 d’abril, festivitat de Sant Jordi, segurament la més important del conjunt de la Corona pel gran simbolisme religiós i polític que tenia llavors tal (23) ______. Podria ser ella, per tant, la Reina dels Escacs? La posició de Rafael Martín al respecte no resulta fútil. Apunta, sobretot, que “lo pom”, com s’ha dit adés, no es pot vincular a l’espasa que s’atribuïx a la coronació d’Isabel la Catòlica, (24) ______: era un element emprat en el cerimonial de coronació dels monarques aragonesos –que el van adoptar remotament dels emperadors bizantins– per a referir-se a la bola del món, coronada sovint amb una creu, sotmés al monarca. En definitiva, els arguments que vinculen la primera menció a la reina del joc dels escacs amb la figura de Maria de Luna no pareixen desencertats. És molt més que plausible suposar que tres naturals del Regne de València i que recurrentment ocupaven certs càrrecs o oficis relacionats amb l’administració de la Corona d’Aragó, com eren Francesc Castellví, Narcís Vinyoles i Bernat Fenollar, estigueren familiaritzats amb aquell cerimonial que s’havia utilitzat a la Corona d’Aragó (25) ______ entre el segle XIV i principis del XV, i recorregueren a ell en l’estrofa 54 de la seua composició."
        ]
       },
       "questions": [
        {
         "n": 6,
         "prompt": "Buit 6",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "del qual hi són"
          },
          {
           "key": "b",
           "text": "del qual en són"
          },
          {
           "key": "c",
           "text": "de què són"
          }
         ]
        },
        {
         "n": 7,
         "prompt": "Buit 7",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "escamparien"
          },
          {
           "key": "b",
           "text": "extradirien"
          },
          {
           "key": "c",
           "text": "extrapolarien"
          }
         ]
        },
        {
         "n": 8,
         "prompt": "Buit 8",
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
         "n": 9,
         "prompt": "Buit 9",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "En relació a"
          },
          {
           "key": "b",
           "text": "Amb relació en"
          },
          {
           "key": "c",
           "text": "Amb respecte a"
          }
         ]
        },
        {
         "n": 10,
         "prompt": "Buit 10",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "es lloa"
          },
          {
           "key": "b",
           "text": "s’invoca"
          },
          {
           "key": "c",
           "text": "es tributa"
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
           "text": "Així les coses"
          },
          {
           "key": "b",
           "text": "Al remat"
          },
          {
           "key": "c",
           "text": "No debades"
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
           "text": "cenobi"
          },
          {
           "key": "b",
           "text": "ceptre"
          },
          {
           "key": "c",
           "text": "cermet"
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
           "text": "orbe"
          },
          {
           "key": "b",
           "text": "orb"
          },
          {
           "key": "c",
           "text": "urbs"
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
           "text": "coetanis"
          },
          {
           "key": "b",
           "text": "equiennals"
          },
          {
           "key": "c",
           "text": "conterranis"
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
           "text": "mentres que"
          },
          {
           "key": "b",
           "text": "malgrat"
          },
          {
           "key": "c",
           "text": "per tal com"
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
           "text": "conflictes"
          },
          {
           "key": "b",
           "text": "aldarulls"
          },
          {
           "key": "c",
           "text": "estirabots"
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
           "text": "puix que"
          },
          {
           "key": "b",
           "text": "doncs"
          },
          {
           "key": "c",
           "text": "per bé què"
          }
         ]
        },
        {
         "n": 18,
         "prompt": "Buit 18",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "sí s’hi"
          },
          {
           "key": "b",
           "text": "sí que es"
          },
          {
           "key": "c",
           "text": "sí que se’n"
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
           "text": "pel que"
          },
          {
           "key": "b",
           "text": "fet per què"
          },
          {
           "key": "c",
           "text": "la qual cosa"
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
           "text": "lloctinent"
          },
          {
           "key": "b",
           "text": "virrei"
          },
          {
           "key": "c",
           "text": "camarlenc"
          }
         ]
        },
        {
         "n": 21,
         "prompt": "Buit 21",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "llinatge"
          },
          {
           "key": "b",
           "text": "estatus"
          },
          {
           "key": "c",
           "text": "repòs"
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
           "text": "comandància"
          },
          {
           "key": "b",
           "text": "comandament"
          },
          {
           "key": "c",
           "text": "manament"
          }
         ]
        },
        {
         "n": 23,
         "prompt": "Buit 23",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "adveniment"
          },
          {
           "key": "b",
           "text": "apostolat"
          },
          {
           "key": "c",
           "text": "advocació"
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
           "text": "si no més aviat al contrari"
          },
          {
           "key": "b",
           "text": "més prompte al contrari"
          },
          {
           "key": "c",
           "text": "sinó ans al contrari"
          }
         ]
        },
        {
         "n": 25,
         "prompt": "Buit 25",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "si més no"
          },
          {
           "key": "b",
           "text": "amb prou feines"
          },
          {
           "key": "c",
           "text": "si fa no fa"
          }
         ]
        }
       ]
      },
      {
       "n": 3,
       "kind": "choice",
       "instructions": "Completa el text que tens a continuació amb l’alternativa més precisa i adequada. Només hi ha una opció vàlida per a cada buit. Fixa’t en l’exemple (número 0).",
       "reading": {
        "title": "Zelda i Scott Fitzgerald descobrixen el bidet",
        "paragraphs": [
         "Encara impressionats per la bellesa d’una Normandia completament florida (0) per a on havien passat en tren, arriben a la gare de Saint-Lazare. Eixa vesprada de maig de 1924 (26) ______ les primeres imatges radiants d’aquell París desitjat, mitificat, a on pensen regnar sense contemplacions. La cartera de Francis està plena de notes i adreces dels molts escriptors i coneguts (27) ______ (la majoria nord-americans, com ells) allí instal·lats des de fa més o menys temps. Amb la seua ajuda, el talent que la parella atresora i exhibix a la menor ocasió i tot l’alcohol del món volen conquistar la ciutat.",
         "Zelda i Francis Scott Fitzgerald coincidixen en temps i espai quan ell és destinat, (28) ______ part del seu servici militar, al campament Sheridan, ubicat a Montgomery, Alabama. Zelda Sayre –filla d’un jutge del Tribunal Suprem d’eixe estat– era la nineta dels ulls de la societat local, una bellesa (29) ______ que tots desitjaven i que finalment (30) ______ aquell jove i atractiu subtinent originari de Saint Paul, Minnesota, i que es proclama escriptor.",
         "(31) ______ coneixen durant un ball del club de camp de Montgomery. Ell ja té al cap la mitat del pòquer d’asos que el farà immortal: This Side of Paradise, The Beautiful and Damned, The Great Gatsby i Tender Is the Night, i ella una (32) ______ abismal i (33) ______. Els dos compartixen un futur d’alcohol, infidelitats, festes, crits i ressaques (34) ______, però encara no ho saben. En algun lloc d’eixe futur sonen les trompetes del jazz i la remor creixent d’un temps (35) ______ icones, símbols, llum i decadència de tota una època.",
         "Menys d’un lustre després d’aquell ball del club de camp desembarquen a Europa, (36) ______ Normandia i arriben a París. Els acompanya la seua filla Scottie, de 2 anys. Els tres s’allotgen en un hotel de l’avinguda de l’Òpera, el Deux Mondes. Catifes, (37) ______ entrellaçats lleument daurats, recepcionistes amabilíssims, porcellanes discretes i elegants que marquen l’inici i la fi a uns corredors de parets (38) ______ per uns teixits que semblen els (39) ______ d’un teló. L’habitació és ampla, encara a eixes hores assolellada, i el bany, a més del lavabo, l’inodor i la banyera, presenta un artefacte estrany, com a mig fer, d’escassa altura, buidat, (40) ______ i amb entrada i eixida d’aigua, i que ells mai han vist (41) ______, i menys encara en els banys d’Alabama o Minnesota. Incapaços de trobar-li utilitat o sentit, decidixen utilitzar-lo (42) ______ banyera de xiquets molt menuts –perquè d’això sembla tractar l’artefacte– i allí llaven a Scottie, que ja li calia, després de tant de viatge.",
         "Satisfets, (43) ______ per les modernitats domèstiques d’una ciutat que no ha de deixar de sorprendre’ls, Zelda i Francis Scott Fitzgerald (aprofitant que Scottie s’ha quedat (44) ______ adormida després del bany) baixen al bar de l’hotel a prendre una copa, que ja (45) ______ feia falta, després de tant de viatge."
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
           "text": "esguarden"
          },
          {
           "key": "b",
           "text": "guarixen"
          },
          {
           "key": "c",
           "text": "esgrafien"
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
           "text": "excomunicats"
          },
          {
           "key": "b",
           "text": "execrats"
          },
          {
           "key": "c",
           "text": "expatriats"
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
           "text": "en tant que"
          },
          {
           "key": "b",
           "text": "tan just com"
          },
          {
           "key": "c",
           "text": "en tant com"
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
           "text": "peremptòria"
          },
          {
           "key": "b",
           "text": "pertorbadora"
          },
          {
           "key": "c",
           "text": "presbiteriana"
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
           "text": "s’enduria"
          },
          {
           "key": "b",
           "text": "es portaria"
          },
          {
           "key": "c",
           "text": "s’arrossegaria"
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
           "text": "Es"
          },
          {
           "key": "b",
           "text": "S’hi"
          },
          {
           "key": "c",
           "text": "Se’n"
          }
         ]
        },
        {
         "n": 32,
         "prompt": "Buit 32",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "psicosi"
          },
          {
           "key": "b",
           "text": "psique"
          },
          {
           "key": "c",
           "text": "psicagogia"
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
           "text": "turbulenta"
          },
          {
           "key": "b",
           "text": "tremolosa"
          },
          {
           "key": "c",
           "text": "tediosa"
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
           "text": "penitents"
          },
          {
           "key": "b",
           "text": "penedides"
          },
          {
           "key": "c",
           "text": "penitencials"
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
           "text": "del qual els dos en seran"
          },
          {
           "key": "b",
           "text": "de què els dos seran"
          },
          {
           "key": "c",
           "text": "de què els dos hi seran"
          }
         ]
        },
        {
         "n": 36,
         "prompt": "Buit 36",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "travessen"
          },
          {
           "key": "b",
           "text": "encreuen"
          },
          {
           "key": "c",
           "text": "estreben"
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
           "text": "arabescos"
          },
          {
           "key": "b",
           "text": "capitells"
          },
          {
           "key": "c",
           "text": "altells"
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
           "text": "esguitades"
          },
          {
           "key": "b",
           "text": "estampades"
          },
          {
           "key": "c",
           "text": "forrades"
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
           "text": "cortiners"
          },
          {
           "key": "b",
           "text": "cortinatges"
          },
          {
           "key": "c",
           "text": "cortinats"
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
           "text": "còncau"
          },
          {
           "key": "b",
           "text": "convex"
          },
          {
           "key": "c",
           "text": "ovalat"
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
           "text": "en ningun lloc"
          },
          {
           "key": "b",
           "text": "en lloc"
          },
          {
           "key": "c",
           "text": "en cap puesto"
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
           "text": "a mena de"
          },
          {
           "key": "b",
           "text": "a manera de"
          },
          {
           "key": "c",
           "text": "a qualitat de"
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
           "text": "corglaçats"
          },
          {
           "key": "b",
           "text": "corpresos"
          },
          {
           "key": "c",
           "text": "constrets"
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
           "text": "pregonament"
          },
          {
           "key": "b",
           "text": "profusament"
          },
          {
           "key": "c",
           "text": "prodigiosament"
          }
         ]
        },
        {
         "n": 45,
         "prompt": "Buit 45",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "els"
          },
          {
           "key": "b",
           "text": "els hi"
          },
          {
           "key": "c",
           "text": "els en"
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
         "text": "En un món dominat pel consumisme i l’acumulació de béns materials, el moviment minimalista modern sorgix a principis del segle XXI com una resposta a la creixent cultura de consum i la saturació material. El minimalisme promou un estil de vida basat en la simplicitat, la reducció de possessions i de coses supèrflues, i es contraposa a la cultura del consum massiu, que promou l’adquisició constant de béns i l’acumulació de possessions. Escriu un assaig en què analitzes com esta filosofia de vida podria influir en la vida personal i en la societat contemporània i futura. El text ha d’incloure els punts següents:",
         "points": [
          "Valora com l’adopció d’un enfocament minimalista pot influir en la vida de les persones.",
          "Avalua les implicacions socials i ambientals del minimalisme en comparació amb la cultura de consum massiu.",
          "Reflexiona sobre la teua pròpia postura respecte als dos enfocaments."
         ]
        },
        {
         "key": "B",
         "text": "En l’era digital, a on la tecnologia i la producció en massa dominen l’economia global, s’observa un ressorgiment de les tradicions artesanals que valoren l’autenticitat i la sostenibilitat. Escriu un article d’opinió per a una revista cultural en què abordes el renaixement de les artesanies tradicionals, explorant les raons que hi ha darrere d’este fenomen, les seues implicacions culturals i econòmiques, i com la tecnologia moderna pot tant amenaçar com refermar la preservació d’estes pràctiques ancestrals. El text ha d’incloure els punts següents:",
         "points": [
          "De quina manera la sostenibilitat ambiental i econòmica donen suport a les tradicions artesanals.",
          "L’impacte social que poden tindre estes tradicions en les comunitats locals i en la preservació cultural.",
          "Reflexió sobre si creus que és important (o no) preservar i promoure estes tradicions en l’actualitat."
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
         "text": "En els últims anys ha ressorgit el debat públic sobre la responsabilitat individual en el calfament global. La població occidental disfruta d’un estil de vida insostenible que exhaurix els recursos naturals i provoca l’emissió d’agents contaminants i de residus en els ecosistemes. No obstant, segons l’últim informe d’Intermón Oxfam, no tots en som igualment responsables. Fa anys que tens un blog en què comentes temes d’actualitat relacionats amb el medi ambient. Decidixes escriure-hi una entrada en què qüestiones de manera irònica que sempre es demane més consciència i sacrificis al ciutadà mitjà. A més, has de donar solucions a curt i llarg termini. Usa les dades de la infografia per a justificar i reforçar els teus arguments.",
         "image": "/exams/c2-octubre-2024/e5-a.jpg",
         "image_text": "Infografia amb dos requadres. Requadre gris: «Qui contamina?» i «Percentatge d’emissions»: 10 % població rica, 50 %; 40 % població mitjana, 43 %; 50 % població empobrida, 7 %; «Hòmens +12 % que dones». Requadre blau: «Què contamina?». «Sectors productius»: de més a menys, energètic, petrolífer, transport, moda i alimentació. «Desplaçaments»: 1 h en jet privat = 1 any de desplaçaments d’un ciutadà mitjà. «Vivendes»: manteniment de vivendes (instal·lacions, jardins, piscines, reformes...). Logotip d’Oxfam."
        },
        {
         "key": "B",
         "text": "Cada any, durant l’època estival, les persones amb mobilitat reduïda es troben amb dificultats que no els permeten disfrutar del bany en la platja amb familiars i amics per la falta d’accessibilitat. Tot i que la majoria de pobles costaners oferixen prou servicis, en alguns casos es consideren insuficients perquè les platges siguen verdaderament inclusives. Eres una persona amb mobilitat reduïda i has comprovat en internet que la platja d’un poble prop d’a on vius és accessible i has decidit anar-hi. La teua sorpresa ha sigut majúscula quan has arribat a la platja accessible i tenia uns servicis molt menors dels que fixa la normativa sobre la matèria; per tant, no has pogut disfrutar de l’experiència amb plena autonomia. Escriu una queixa a l’Ajuntament en què expliques amb un poc de sarcasme l’odissea que has viscut i sol·licita els canvis pertinents per a una accessibilitat integral d’eixa platja a partir de les dades de la infografia.",
         "image": "/exams/c2-octubre-2024/e5-b.jpg",
         "image_text": "Infografia «Platges accessibles», amb una taula de «Servicis» amb tres columnes: «Sí, n’hi ha», «No n’hi ha» i «Era insuficient». Places de pàrquing reservades: era insuficient. Vestuaris, dutxes i lavabos adaptats: sí, n’hi ha. Cadires amfíbies: era insuficient. Passarel·les i rampes: sí, n’hi ha. Temporada bany accessible, 1 juliol - 31 agost: era insuficient. Plataforma dins de la mar amb ascensor hidràulic (servici recent i inclusiu): no n’hi ha. Personal de suport contractat: era insuficient. Senyalització/informació visual i tàctil: sí, n’hi ha. Transport públic adaptat: no n’hi ha. Ombralls i cadires: no n’hi ha. Fotografia d’un senyal blau de platja accessible (platja accessible, playa accesible) amb el símbol de la cadira de rodes, amb una platja al fons."
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
         "title": "Monòleg · La importància del disseny universal en l’accessibilitat",
         "duration": "3 minuts",
         "intro": "El disseny universal està contribuint a la creació d’espais i productes accessibles per a persones amb diverses capacitats. Està concebut com una estratègia fonamental per a promoure l’accessibilitat en diversos entorns, des d’espais públics fins a productes i servicis. Busca crear solucions que siguen inclusives per a totes les persones, independentment de les seues capacitats físiques, sensorials o cognitives, que no sols beneficien persones amb discapacitats, sinó que també enriquisquen la vida de tots al crear entorns més funcionals i acollidors. Eres un defensor dels drets de les persones amb discapacitat, i t’han convidat a parlar en un fòrum comunitari sobre com millorar l’accessibilitat en la vida diària. Cal que tingues en compte, entre altres, estes idees:",
         "questions": [
          "Beneficis i desafiaments del disseny universal en la construcció d’una societat més inclusiva i accessible.",
          "Contextos d’aplicació: arquitectura d’edificis públics, mobiliari urbà, productes tecnològics...",
          "Recomanacions per a promoure l’adopció del disseny universal."
         ],
         "images": []
        },
        {
         "title": "Monòleg · El rol del voluntariat en les comunitats locals",
         "duration": "3 minuts",
         "intro": "En un món en què els desafiaments socials i comunitaris són cada vegada més complexos, el voluntariat s’erigix com una ferramenta poderosa per a enfortir el teixit social i fomentar el canvi positiu. Té un impacte en el desenrotllament de les comunitats locals, i les seues iniciatives poden millorar la cohesió social, així com proporcionar suport a diverses causes i grups. Participes com a activista comunitari en una reunió d’associacions de veïns del teu municipi amb l’objectiu de mobilitzar els residents perquè s’involucren en activitats voluntàries i donen suport a iniciatives locals. Cal que tingues en compte, entre altres, estes idees:",
         "questions": [
          "El voluntariat dona suport a causes que ajuden a cobrir bretxes que no són ateses pels servicis públics.",
          "Promou la participació cívica, i involucra els ciutadans en la presa de decisions i en l’acció comunitària.",
          "Ha d’obtindre el suport necessari per a capacitar i motivar els seus equips."
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
         "title": "Diàleg · Les amistats en l’edat adulta",
         "duration": "4 minuts",
         "intro": "Tots hem tingut amics quan anàvem a escola i a l’institut que véiem cada dia o cada cap de setmana. A mesura que ens fem majors i mamprenem un itinerari personal de formació o de treball, les amistats són més variables i tangencials. A pesar dels entrebancs, l’amistat és una de les formes de relació humana més necessàries.",
         "questions": [],
         "images": [],
         "roles": [
          {
           "name": "Opció A",
           "text": "Participes en una tertúlia radiofònica sobre vincles humans. Penses que actualment és un repte crear i mantindre els vincles en l’edat adulta. Tens en compte el pes que tenen en esta qüestió les xarxes socials i la falta de temps lliure de què disposen els adults per a dedicar als lligams."
          },
          {
           "name": "Opció B",
           "text": "Participes en una tertúlia radiofònica sobre vincles humans. Penses que mantindre els vincles en l’edat adulta és essencial per al benestar personal. Consideres que les xarxes socials ajuden a mantindre els lligams i que la varietat de formats familiars i de parella permet un millor encaix de l’amistat en l’edat adulta."
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
