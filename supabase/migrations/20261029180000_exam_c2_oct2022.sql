-- Examen interactiu C2 de la JQCV (octubre 2022) com a recurs de category 'examen'.
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
 "id": "2b02ae66-e705-5689-bfd7-05b84be21132",
 "name": "Simulacre C2: octubre 2022",
 "type": "jqcv_c2_oct2022",
 "category": "examen",
 "difficulty": "C2",
 "xp_earned": 40,
 "content": "Examen oficial C2 de la JQCV (octubre 2022): comprensió escrita i estructures lingüístiques autocorregibles, dos redaccions i pràctica oral.",
 "metadata": {
  "icon": "🏆",
  "color": "#D1C4E9",
  "exam_body": "JQCV",
  "certificate_level": "C2",
  "exam": {
   "level": "C2",
   "session": "Octubre 2022",
   "body": "JQCV",
   "source_url": "https://jqcv.gva.es/va/nivell-c2",
   "pass_rule": "Per a ser APTE cal una puntuació global mínima de 60 sobre 100. Les àrees valen un 10 % (comprensió escrita), un 20 % (estructures lingüístiques), un 45 % (expressió i interacció escrites) i un 25 % (expressió i interacció orals), i en cada una cal arribar al mínim: el 20 % en la comprensió escrita, el 40 % en les estructures lingüístiques i el 50 % en l’expressió escrita i en l’expressió oral.",
   "areas": [
    {
     "n": 1,
     "title": "Comprensió escrita",
     "weight": 10,
     "duration": "1 h 30 min (àrees 1 i 2)",
     "scoring": {
      "points_per_correct": 20,
      "max_points": 100,
      "pass_points": 20
     },
     "exercises": [
      {
       "n": 1,
       "kind": "choice",
       "instructions": "Llegiu atentament aquest article i trieu la resposta correcta (a, b, c o d). Teniu en compte que, per a cada qüestió plantejada, només hi ha una resposta correcta. Fixeu-vos en l’exemple (número 0).",
       "reading": {
        "title": "Plagiarisme: estètica o moviment contemporani?",
        "paragraphs": [
         "En les últimes dècades un nombre considerable d’autors ha assumit i ha reivindicat la seua condició de plagiaris. Sembla que les poètiques i estètiques actuals, lluny de les pruïges romàntiques d’originalitat i autenticitat, hagen restituït el plagi fins a establir un sistema inesgotable d’autoreferencialitat recursiva. Encara més, la proliferació de manifestos, de grups més o menys extensos i influents acollits a l’etiqueta de “plagi”, “apropiacionisme” o similars, ens condueix a preguntar-nos per l’existència d’un moviment coherent més global, més enllà de modes episòdiques, dins d’una estabilitat de plantejaments estètics o pràctics. ¿Hem de considerar el plagiarisme com un tret inherent, és a dir necessari, de la postmodernitat, o, per contra, hauríem d’escriure’l sempre en majúscula com a denominació d’un moviment amb vida autònoma, amb múltiples adherents en les literatures nacionals contemporànies més enllà de denominacions col·lectives, amb genealogies, escoles i subgrups propis?",
         "Al llarg de la història, almenys des que es firmen els textos, l’acusació de plagi ha estat constant en el camp literari. Els autors sempre s’han acusat els uns als altres d’apropiar-se del treball alié i d’atribuir-se autories que no els corresponien. Per aquesta raó, en la majoria dels textos trobem senyals d’identitat que els diferencien, i traces dels autors que els van compondre. En totes les èpoques, ser titllat de “plagiari” és potser la desqualificació més severa en el món literari. La història de les lletres és també, per tant, el relat dels esforços d’escriptors per demostrar i refermar la paternitat literària dels textos que produïen. Topem amb un combat històric del qual trobem empremtes visibles força abans de la instauració de les marques de filiació modernes (registres en les biblioteques nacionals, ISBN), en els prefacis, en els paratextos (títols, avisos al lector, cobertes), en el cos mateix de l’obra… Llocs des d’on els escriptors es curen en salut i accepten la condició intertextual de les seues caricatures; o, per contra, seguint una estratègia diametralment oposada, en reclamen la primacia i l’originalitat absoluta, o relativa, davant de la tradició i del cànon.",
         "No obstant això, existeix una estirp d’escriptors, un partit sempre minoritari, tradicionalment considerat maleït, lúdic i experimental; situats en la perifèria del cànon literari, ja que la seua nòmina inclou aquelles obres i autors que han infringit, en els diferents períodes, les normes per les quals s’ha regit la literatura occidental. En ocasions, aquests escriptors van practicar una literatura basada en la paròdia, en la reescriptura i en l’apropiació de textos preexistents. Per aquest motiu, es van veure exclosos del corrent principal de la literatura, allò que hui en dia es coneix com mainstream, i van acabar relegats a la condició de plagiarisme o a posicions similars fora dels ortodoxos terrenys de l’Escriptura. El destí que la Història ha reservat habitualment a aquests “falsos autors”, que explica la paüra generalitzada que promovien les acusacions de plagi, és l’oblit més absolut dels seus textos i, en el millor dels casos, el record teratològic dels noms propis dels seus autors conservats en l’index prohibitorum (l’anticànon) dels seus censors.",
         "Per tant, el plagiarisme, en tant que procediment creatiu o noció programàtica, ha estat present en nombrosos moviments i períodes, malgrat que ha cobrat una especial rellevància associada a les avantguardes i a la postmodernitat. En l’actualitat, aquest tret s’ha accentuat i són nombrosos els moviments que el reivindiquen o l’assumeixen: postpoesia, plagiarisme punk, copyfight… A més, cal destacar que la ciberliteratura, modalitat genèrica per antonomàsia d’aquests temps tecnològics, ha generalitzat formes equivalents als procediments plagiaristes o apropiacionistes. Això es deu a elements constitutius essencials com les nocions d’hiperenllaç (llenguatge) i comunitat (xarxa), a partir de les quals l’autoria es resol col·lectivament i sempre de manera relativa. Tanmateix, la literatura més convencional no ha romàs, malgrat tot, aliena a les preocupacions de les propostes més radicals o contraculturals. Fa temps que el plagi i altres límits de l’escriptura i de l’autoria artística s’han convertit en temes privilegiats de la ficció contemporània, en contes, novel·les, còmics, pel·lícules o obres d’art.",
         "Una primera explicació de l’interés mostrat per a la representació compulsiva del plagi, del simulacre i de la cita, tant des d’una perspectiva ficcional com teòrica, consistiria a interpretar-lo com un dels modes amb els quals la postmodernitat afronta les seues angoixes escatològiques. En aquest sentit, la literatura globalitzada presenta trets autoreflexius comuns a tendències estètiques més àmplies. Aquesta tematització s’orienta especialment cap a la reproducció massiva, la replicabilitat, la clonació i la multiplicació exponencial d’objectes, processos que inverteixen els valors tradicionals de singularitat i autenticitat culturals. Alguns crítics de la postmodernitat tardana han subratllat el caràcter polimorf i ubic del discurs artístic contemporani que integra la pluralitat dels mèdia i la incorpora tant en el cos com en els possibles usos i modes de lectura de les obres.",
         "Tot tenint en compte el que hem tractat fins ara, sembla que la balança s’inclina cap a la interpretació del plagiarisme com a etiqueta particular i efímera per a trets comuns a l’art contemporani; o més precisament, a possibilitats latents que l’art contemporani ha aguditzat. Al cap i a la fi, des de les primeres dècades del segle passat, la crítica està obligada a llegir cada text com a intertext; això és, com a recursivitat d’allò escrit, que pot ser rastrejada en orígens més llunyans, fins i tot des de l’inici de la reflexió occidental sobre la reescriptura. En poques paraules, les suposades característiques del Plagiarisme com a moviment no serien sinó trets comuns al conjunt de l’art contemporani: autoreferencialitat, indeterminació semàntica, inclusió de discursos heterogenis, desbordament de la propietat jurídica, etc.",
         "Ara bé, és menester matisar aquest últim punt, ja que existeixen, tanmateix, raons per a agrupar aquestes tendències i considerar que apunten cap a una unitat programàtica i una especificitat literària. Com hem assenyalat anteriorment, són diversos els escriptors i col·lectius que en diferents moments i latituds han reclamat «Plagiarisme» com a nom propi col·lectiu. Ara bé, si existira el Plagiarisme com a moviment artístic, fins i tot en les seues formes més efímeres, conformaria un tipus molt peculiar, ja que li manquen els òrgans habituals; com si els seus integrants conservaren una llibertat de moviments que, per aquest mateix motiu, invalidara les pretensions unitàries.",
         "Per totes aquestes raons, podem arribar a diverses conclusions. Per una banda, a cada època i en paral·lel a les interpretacions més restrictives, han existit propostes transgressores respecte als límits convencionals o a les representacions habituals dels elements literaris, de les quals el plagiarisme (sense majúscula) seria l’encarnació postmoderna. Al contrari, el Plagiarisme sembla tenir més entitat com a procediment apropiacionista o intertextual extrem que com a designació d’un corrent o moviment literari concret. Malgrat que ha estat reclamat explícitament per diferents moviments a escala internacional i siga possible trobar interessos i influències comuns entre tots ells, el Plagiarisme sembla conformar més un horitzó utòpic de l’art que un moviment coherent o cohesionat. Això és el que es pot constatar de moment. En qualsevol cas, és encara massa aviat per saber fins on ens conduiran aquestes tendències i si a la llarga sorgirà un moviment dotat de propostes estètiques congruents."
        ]
       },
       "questions": [
        {
         "n": 0,
         "prompt": "En aquest text, l’autor pretén aproximar-se al concepte de “plagiarisme” i...",
         "answer": "d",
         "scored": false,
         "options": [
          {
           "key": "a",
           "text": "fer un estudi dels manifestos que defensen el plagi com a moviment contracultural contemporani."
          },
          {
           "key": "b",
           "text": "confirmar el naixement d’un corrent cultural cohesionat que beu de l’estètica postmoderna."
          },
          {
           "key": "c",
           "text": "establir les bases històriques d’aquesta pràctica literària i reivindicar un retorn a l’originalitat creativa."
          },
          {
           "key": "d",
           "text": "qüestionar que aquesta tendència actual haja derivat en la formació d’un moviment estètic autònom."
          }
         ]
        },
        {
         "n": 1,
         "prompt": "Històricament, el recurs a l’ús del plagi...",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "va ser considerat un element d’originalitat, ja que l’autor havia de demostrar que coneixia la tradició literària."
          },
          {
           "key": "b",
           "text": "va ser titllat de pràctica ominosa, i per això els autors maldaven per citar i referenciar les obres alienes."
          },
          {
           "key": "c",
           "text": "es va tractar de palesar a través de marques textuals que identificaven els autors originals de les obres."
          },
          {
           "key": "d",
           "text": "es va combatre amb la inclusió de l’ISBN per tal d’assegurar el respecte a l’originalitat dels textos."
          }
         ]
        },
        {
         "n": 2,
         "prompt": "El grup reduït escriptors que va trencar amb el cànon literari...",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "va estar constantment parodiat i relegat a les llistes negres dels censors literaris de l’època."
          },
          {
           "key": "b",
           "text": "va estar condemnat a l’ostracisme i a moure’s pels encontorns del pensament majoritari."
          },
          {
           "key": "c",
           "text": "va ser qualificat de “falsos autors” i d’apropiar-se d’obres alienes per a fer literatura experimental."
          },
          {
           "key": "d",
           "text": "no es va incorporar als corrents literaris tradicionals per la por a ser acusat de grup plagiari."
          }
         ]
        },
        {
         "n": 3,
         "prompt": "L’efecte que la producció digital ha tingut sobre la creació artística convencional...",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "ha significat l’aparició de noves formes de fer literatura vinculades a la contracultura."
          },
          {
           "key": "b",
           "text": "ha sigut generalitzar l’assumpció del plagiarisme com un tret associat a la ciberliteratura."
          },
          {
           "key": "c",
           "text": "ha implicat que el plagi haja esdevingut temàtica recurrent dels gèneres artístics contemporanis."
          },
          {
           "key": "d",
           "text": "ha ocasionat un creixement notable de representacions artístiques lligades a les avantguardes."
          }
         ]
        },
        {
         "n": 4,
         "prompt": "L’interés que es mostra actualment pel plagi…",
         "answer": "d",
         "options": [
          {
           "key": "a",
           "text": "es genera en els discursos dels mèdia i es trasllada després a una literatura plenament globalitzada."
          },
          {
           "key": "b",
           "text": "es fonamenta en les tendències contemporànies de lluita contra la clonació i la replicabilitat textual."
          },
          {
           "key": "c",
           "text": "es manifesta en la proliferació d’iniciatives orientades a recrear l’originalitat del producte cultural."
          },
          {
           "key": "d",
           "text": "té a veure amb les tendències estètiques actuals, que reinterpreten l’autenticitat i singularitat de les obres."
          }
         ]
        },
        {
         "n": 5,
         "prompt": "Segons el text, el Plagiarisme, com a moviment artístic...",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "no està plenament constituït per la manca d’unitat programàtica i de cohesió dels seus integrants."
          },
          {
           "key": "b",
           "text": "va existir de manera efímera en les últimes dècades del segle passat, però ara mateix s’ha difuminat."
          },
          {
           "key": "c",
           "text": "es caracteritza per donar llibertat als seus membres a l’hora de reproduir trets d’altres tendències artístiques."
          },
          {
           "key": "d",
           "text": "encara no ha arribat al moment més àlgid, però molts autors el consideren plenament operatiu."
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
     "duration": "1 h 30 min (àrees 1 i 2)",
     "scoring": {
      "points_per_correct": 2.5,
      "max_points": 100,
      "pass_points": 40
     },
     "exercises": [
      {
       "n": 2,
       "kind": "choice",
       "instructions": "Completeu el text que teniu a continuació amb l’alternativa més precisa i adequada. Només hi ha una opció vàlida per a cada buit. Fixeu-vos en l’exemple (número 0).",
       "reading": {
        "title": "El manuscrit trobat en una ampolla",
        "paragraphs": [
         "(0) A l’octubre de 1833, Edgar Allan Poe va publicar en el setmanari Baltimore Saturday Visiter de Baltimore (6) ______, un dels seus primers relats, gràcies al qual va obtindre un guardó literari dotat amb 50 dòlars, que li va aportar certa fama i li va donar confiança en les seues possibilitats com a prosista, per bé que, passats els anys, tenia tendència a menysvalorar-lo, amb l’argument que l’expressió de l’horror ”s’assoleix per mitjans massa externs i encara no s’ha (7) ______ en les regions intel·lectuals”.",
         "L’argument del relat, que es pot classificar entre els de tema fantàstic i intemporal, amb un narrador en primera persona que exhibeix trets autobiogràfics, no és difícil de resumir. Un jove desarrelat, d’orígens obscurs i temperament sensible però d’acurada educació, basada en sòlids principis materialistes, que fa anys que viatja, s’embarca com a passatger al port de Batàvia, capital de Java, en un vaixell amb destí a (8) ______ de les illes de la Sonda, sense cap objectiu clar. Durant els primers dies, la navegació (9) ______ amb placidesa, d’acord amb totes les previsions, fins que un vespre la mar va adquirir unes qualitats insòlites, descrites amb meticulosa precisió, com si el narrador es trobara sota els efectes del làudan; (10) ______, l’opi és un dels productes que formen part de la càrrega mal distribuïda del vaixell, propens a escorar-se. Un núvol estrany s’estén per l’horitzó crepuscular, la lluna adquireix un color vermell fosc i l’aigua de la mar es torna d’una extrema transparència, enmig de la més absoluta immobilitat de l’aire, incapaç de pertorbar la flama d’una espelma en el castell de popa. (11) ______ les veles del vaixell i es llança l’àncora, la tripulació es deixa envair per (12) ______ del moment i es tomba en coberta, mentre el capità ignora els pressentiments del protagonista, que intueix els senyals imminents d’un huracà.",
         "Els seus pitjors auguris es confirmen (13) ______ a mitjanit. Just quan estava a punt de pujar a coberta, una onada enorme sorgida del no-res (14) ______ el vaixell. Aquesta circumstància fortuïta li estalvia tant el destí dels mariners, arrossegats per la brutal ràfega d’aigua, com el dels oficials, que s’ofeguen en l’interior dels seus cambrots inundats. Una vegada passada la primera escomesa, descobreix que del personal (15) ______, només hi resten vius ell i un vell suec, embarcat a darrera hora.",
         "Durant cinc dies i cinc nits s’afanyen amb les bombes, en una temptativa infructuosa d’evitar que el vaixell siga engolit per la tempesta. (16) ______, deriven invariablement cap al sud. Al sisé dia el sol s’extingeix en l’horitzó i se submergeixen en una nit perpètua, la desesperació s’apodera dels dos homes i s’amarren (17) ______ del pal de messana a l’espera de la mort. Al cap d’un període de temps mal de precisar, veuen aparéixer al capdamunt d’una altíssima onada un vaixell espectral de dimensions monstruoses, cent vegades superiors a les usuals, que es precipita violentament sobre la coberta mig enfonsada del vaixell en què viatgen. El suec no aconsegueix salvar-se, però el narrador es deslliga de les cordes que el subjectaven i el formidable impacte el catapulta cap a una altra embarcació.",
         "(18) ______, atesa la seua condició de (19) ______ i l’aprensió que li suscita l’aspecte dels mariners, una elemental cautela l’impulsa a ocultar-se per poder observar amb deteniment, sense ser vist, la peculiar condició d’aquella gent: una colla de vells que enraonen en una llengua desconeguda, amb aspecte de somnàmbuls. Tot seguit, descobreix que pot moure’s tranquil·lament entre ells, perquè viuen en una mena de món paral·lel i semblen trobar-se (20) ______ tot el temps en profundes meditacions. La llibertat de moviments adquirida li permet examinar a fons l’extraordinària estructura de l’embarcació, producte d’una mescla (21) ______ de models de construcció en aparença contradictoris, que treballen amb un tipus desconegut de fusta porosa. La impressió que tot plegat deixa en l’ànim del narrador és la de trobar-se en un vaixell teratològic, que amb el transcurs dels segles ha experimentat un procés inversemblant de creixement orgànic, anàleg en molts aspectes al dels cossos dels mateixos mariners, començant pel capità, figura majestuosa en la qual es condensen i s’accentuen els trets idiosincràtics dels seus homes. Durant una incursió en la seua cabina, plena de cartes de navegació fora d’ús, instruments científics malmesos i vetustos infolis, (22) ______ troba immers en la lectura febril d’un document misteriós, que molt bé podrien ser les seues ordres originals de navegació, mentre parla sol en la llengua desconeguda, que al narrador li arriba des d’una remota llunyania, com si estiguera a una milla de distància.",
         "Al llarg d’un període inconcret, potser setmanes, la nau navega invariablement cap al (23) ______ amb totes les veles desplegades, enmig d’una tempesta que no amaina. A mesura que el viatge sembla acostar-se a una tràgica fi, en forma de descobriment (24) ______ a la destrucció, el narrador percep un canvi subtil en l’ànim dels mariners: a l’apatia i la desesperació habituals se superposa ara una expressió imbuïda d’una misteriosa esperança. El desenllaç es produeix quan el vaixell desemboca en un enorme amfiteatre format per altíssims murs de gel, enmig del qual s’agita un remolí amenaçador que l’engoleix, no sense que el narrador haja introduït abans el seu improvisat dietari en una botella, (25) ______ a l’atzar de les ones."
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
           "text": "MS. Found in a Bottle (sense cometes, en lletra redona)"
          },
          {
           "key": "b",
           "text": "“MS. Found in a Bottle” (entre cometes, en lletra redona)"
          },
          {
           "key": "c",
           "text": "“MS. Found in a Bottle” (entre cometes i en cursiva)"
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
           "text": "sentat"
          },
          {
           "key": "b",
           "text": "assentat"
          },
          {
           "key": "c",
           "text": "assegut"
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
           "text": "l’arxipièl·lag"
          },
          {
           "key": "b",
           "text": "l’arxipièlag"
          },
          {
           "key": "c",
           "text": "l’arxipèlag"
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
           "text": "transcorregué"
          },
          {
           "key": "b",
           "text": "transcorrí"
          },
          {
           "key": "c",
           "text": "transcorré"
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
           "text": "no debades"
          },
          {
           "key": "b",
           "text": "no obstant"
          },
          {
           "key": "c",
           "text": "nogensmenys"
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
           "text": "S’arrien"
          },
          {
           "key": "b",
           "text": "S’hissen"
          },
          {
           "key": "c",
           "text": "S’alcen"
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
           "text": "l’avinentesa"
          },
          {
           "key": "b",
           "text": "la languidesa"
          },
          {
           "key": "c",
           "text": "l’algidesa"
          }
         ]
        },
        {
         "n": 13,
         "prompt": "Buit 13",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "d’imprevist"
          },
          {
           "key": "b",
           "text": "d’improvist"
          },
          {
           "key": "c",
           "text": "d’improvís"
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
           "text": "desacobla"
          },
          {
           "key": "b",
           "text": "desabilla"
          },
          {
           "key": "c",
           "text": "desarbora"
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
           "text": "de bord"
          },
          {
           "key": "b",
           "text": "d’abord"
          },
          {
           "key": "c",
           "text": "de a bord"
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
           "text": "Mentretant"
          },
          {
           "key": "b",
           "text": "Entretant"
          },
          {
           "key": "c",
           "text": "Entre tant"
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
           "text": "al gassó"
          },
          {
           "key": "b",
           "text": "a la soca"
          },
          {
           "key": "c",
           "text": "al tarranc"
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
           "text": "D’ençà"
          },
          {
           "key": "b",
           "text": "Antany"
          },
          {
           "key": "c",
           "text": "D’antuvi"
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
           "text": "polissó"
          },
          {
           "key": "b",
           "text": "politzó"
          },
          {
           "key": "c",
           "text": "poliçó"
          }
         ]
        },
        {
         "n": 20,
         "prompt": "Buit 20",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "summits"
          },
          {
           "key": "b",
           "text": "sumits"
          },
          {
           "key": "c",
           "text": "submits"
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
           "text": "heteròclita"
          },
          {
           "key": "b",
           "text": "ínclita"
          },
          {
           "key": "c",
           "text": "derrenclida"
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
           "text": "se’l"
          },
          {
           "key": "b",
           "text": "s’hi"
          },
          {
           "key": "c",
           "text": "se n’hi"
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
           "text": "pol sud"
          },
          {
           "key": "b",
           "text": "Pol sud"
          },
          {
           "key": "c",
           "text": "pol Sud"
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
           "text": "desemparellat"
          },
          {
           "key": "b",
           "text": "aparellat"
          },
          {
           "key": "c",
           "text": "desparellat"
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
           "text": "lliurant-lo"
          },
          {
           "key": "b",
           "text": "lliurant-ho"
          },
          {
           "key": "c",
           "text": "Lliurant-ne"
          }
         ]
        }
       ]
      },
      {
       "n": 3,
       "kind": "choice",
       "instructions": "Completeu el text que teniu a continuació amb l’alternativa més precisa i adequada. Només hi ha una opció vàlida per a cada buit. Fixeu-vos en l’exemple (número 0).",
       "reading": {
        "title": "El dret a la peresa",
        "paragraphs": [
         "Una recent investigació ha apuntat el fet que l’aparició de l’home modern es produí, (0) en gran mesura, perquè la selecció natural afavorí adaptacions que (26) ______ que els primats centraren (27) ______ alimentació en les dietes més riques en energia i més baixes en fibra. (28) ______, paradoxalment, es planteja la probabilitat que actualment l’home (29) ______ ressentint d’una alimentació insuficient en fibra. Aquesta, sens dubte, no és l’única paradoxa sorgida al llarg del procés de relacions que l’home ha establert amb la natura, i entre els membres de la seua espècie, per tal de garantir la seua supervivència.",
         "Aquest conjunt de relacions, que per entendre (30) ______ podem denominar economia, ha sigut objecte de grans prediccions. Fa més de dos-cents anys Adam Smith va predir que, en una economia oberta, la divisió del treball i l’augment de productivitat (31) ______ comportava ens portaria a una societat en què tots nadaríem en l’abundància. Juntament amb altres socis de l’anomenada escola escocesa, va vendre la idea que calia assimilar progrés a creixement econòmic, que volia dir tant com industrialització (encara que en aquells moments estiguera (32) ______ ). No cal insistir (33) ______ tant el primer com el segon plantejament han fet aigües pertot arreu. Negar aquesta evidència és tant com apuntar-se a la famosa dita de “qui dia passa any empeny”. (34) ______ s’hi apunta, només els cal recordar que avui quasi el 30 % de la Humanitat viu en la pobresa (la major part de la qual es concentra en el sud-est asiàtic i l’(35) ______ ).",
         "L’economia ja no és un conjunt de normes (o com vulgueu dir (36) ______ ) per solucionar de la millor manera possible les necessitats de la societat. O, en altres paraules, la societat és la que està supeditada a la lògica (si és que en té alguna) de l’economia. Som esclaus de les lleis econòmiques. Hui en dia, els (37) ______ de dreta i esquerra ens diuen que l’economia exigeix (38) ______ de l’Estat del benestar, el qual va ser creat precisament per a esmorteir les conseqüències d’una de les variables econòmiques més recurrents: l’aparició de crisis periòdiques. I ens asseguren que ens hem d’acostumar a conviure amb un atur estructural, que es pot estabilitzar als països de la Unió Europea entorn al 10 % de la població activa -a Espanya en aquests moments és superior al 20 %-, (39) ______ a aquell vell lema sindical de “treballar menys per treballar tots”. Quina paradoxa, l’enorme augment de la productivitat que comença a (40) ______ des de l’inici de la revolució industrial no ha servit per donar treball a tothom, encara que fos per unes hores. Si Smith aixequés el cap!",
         "Vivim en un procés (41) ______ en què l’únic objectiu que se’ns apunta és treballar més i millor (encara que després no puga fer-se realitat), ser més competitius, produir i consumir més ràpidament. El que produïm o consumim moltes vegades no és el més important.",
         "És potser per això que el filòsof Alain Finkielkraut, en un debat organitzat per tres importants diaris europeus, ha escrit coses com aquestes: “El món en el qual vivim, ja no pot interpretar-se, (42) ______ viure’s, com a projecte. El projecte ha deixat el lloc a un procés, a un moviment sense fi del qual no es veu la finalitat. Hui es produeix per produir. Es busca, s’emprén la busca, per buscar. Es treballa per treballar. I la qüestió que es planteja en aquests moments és saber si es pot tornar a trobar, en un món que és cada vegada més el del procés, el sentit d’un projecte. Existeix la possibilitat que això (43) ______?”",
         "Sembla, doncs, que vivim en un món sense projectes col·lectius i, potser, també individuals. Cal, per tant, si se’m permet la ingenuïtat, cercar-los. Pense que cal apuntar cap a la individualitat, que no s’ha d’interpretar com a sinònim d’individualisme. Cal apuntar vers actuacions que, (44) ______ no s’emmarquen en projectes col·lectius (més o menys ben (45) ______ ), signifiquen un trencament (per menut que siga) d’aquesta carrera sense fi que anomenem modernitat sense més."
        ]
       },
       "questions": [
        {
         "n": 26,
         "prompt": "Buit 26",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "permetesquen"
          },
          {
           "key": "b",
           "text": "permeteren"
          },
          {
           "key": "c",
           "text": "permeten"
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
           "text": "sa"
          },
          {
           "key": "b",
           "text": "llur"
          },
          {
           "key": "c",
           "text": "qualssevol"
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
           "text": "Però"
          },
          {
           "key": "b",
           "text": "A més a més"
          },
          {
           "key": "c",
           "text": "Si més no"
          }
         ]
        },
        {
         "n": 29,
         "prompt": "Buit 29",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "s’estiguera"
          },
          {
           "key": "b",
           "text": "s’estiga"
          },
          {
           "key": "c",
           "text": "s’està"
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
           "text": "’n"
          },
          {
           "key": "b",
           "text": "’ns"
          },
          {
           "key": "c",
           "text": "-hi"
          }
         ]
        },
        {
         "n": 31,
         "prompt": "Buit 31",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "la qual"
          },
          {
           "key": "b",
           "text": "el qual"
          },
          {
           "key": "c",
           "text": "que"
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
           "text": "en un sopols"
          },
          {
           "key": "b",
           "text": "a deshora"
          },
          {
           "key": "c",
           "text": "a les beceroles"
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
           "text": "que"
          },
          {
           "key": "b",
           "text": "en el fet de que"
          },
          {
           "key": "c",
           "text": "en què"
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
           "text": "N’hi ha qui"
          },
          {
           "key": "b",
           "text": "Hi ha qui"
          },
          {
           "key": "c",
           "text": "N’hi ha que"
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
           "text": "Àfrica Subsahariana"
          },
          {
           "key": "b",
           "text": "Àfrica subsahariana"
          },
          {
           "key": "c",
           "text": "Àfrica Sub-sahariana"
          }
         ]
        },
        {
         "n": 36,
         "prompt": "Buit 36",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "-li’n"
          },
          {
           "key": "b",
           "text": "-li"
          },
          {
           "key": "c",
           "text": "-l’hi"
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
           "text": "tecnòcrates"
          },
          {
           "key": "b",
           "text": "tecnòcrats"
          },
          {
           "key": "c",
           "text": "tecnocrates"
          }
         ]
        },
        {
         "n": 38,
         "prompt": "Buit 38",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "el desmantellament"
          },
          {
           "key": "b",
           "text": "l’esmantellament"
          },
          {
           "key": "c",
           "text": "el mantellament"
          }
         ]
        },
        {
         "n": 39,
         "prompt": "Buit 39",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "fent oïdes sordes"
          },
          {
           "key": "b",
           "text": "parant atenció"
          },
          {
           "key": "c",
           "text": "fent cas omís"
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
           "text": "haver-hi"
          },
          {
           "key": "b",
           "text": "haver-ne"
          },
          {
           "key": "c",
           "text": "haver-n’hi"
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
           "text": "amansit"
          },
          {
           "key": "b",
           "text": "foll"
          },
          {
           "key": "c",
           "text": "apaivagat"
          }
         ]
        },
        {
         "n": 42,
         "prompt": "Buit 42",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "ni tant sol"
          },
          {
           "key": "b",
           "text": "ni tant sols"
          },
          {
           "key": "c",
           "text": "ni tan sols"
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
           "text": "succeïxca"
          },
          {
           "key": "b",
           "text": "succeeïsca"
          },
          {
           "key": "c",
           "text": "succeïsca"
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
           "text": "si bé"
          },
          {
           "key": "b",
           "text": "malgrat"
          },
          {
           "key": "c",
           "text": "encara"
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
           "text": "solsits"
          },
          {
           "key": "b",
           "text": "entrebancats"
          },
          {
           "key": "c",
           "text": "travats"
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
     "duration": "2 h 30 min",
     "exercises": [
      {
       "n": 4,
       "kind": "writing",
       "title": "Redacció",
       "instructions": "Trieu una de les dues opcions i redacteu un text amb una extensió entre 210 i 230 paraules.",
       "min_words": 210,
       "max_words": 230,
       "choices": [
        {
         "key": "A",
         "text": "La idea sobre la qual pivota la nova proposta de jornada laboral de quatre dies és la convicció que una millor organització del treball pot incrementar la productivitat i, per tant, permetre reduir els horaris sense retallar els salaris. Envieu un text a la secció de cartes dels lectors i de les lectores en què expresseu la vostra opinió sobre aquest tema. Cal que hi tracteu, entre altres, aquests punts:",
         "points": [
          "Conseqüències socials i beneficis de la reducció de la jornada laboral.",
          "Repartiment de la jornada laboral com a mesura de distribució de la renda.",
          "Valoració personal sobre la implantació d’aquesta iniciativa."
         ]
        },
        {
         "key": "B",
         "text": "Segons alguns estudis, tancar les centrals nuclears encariria encara més el preu de la llum i faria augmentar les emissions de CO₂ perquè, ara per ara, caldria importar energia o generar-la per mitjans tradicionals. A més, les nuclears garanteixen un subministrament continuat sense massa inversió. Redacteu una carta formal a títol individual adreçada als responsables de la Conselleria de Transició Ecològica en què mostreu la vostra disconformitat amb les conclusions que mostren aquests estudis. Cal que hi tracteu, entre altres, aquests punts:",
         "points": [
          "La seguretat de les instal·lacions nuclears, una preocupació en l’opinió pública.",
          "La fal·làcia que es crea en considerar la nuclear com una energia verda.",
          "Una oportunitat perduda a l’hora d’apostar per les fonts d’energia renovable."
         ]
        }
       ]
      },
      {
       "n": 5,
       "kind": "writing",
       "title": "Text a partir d’una infografia",
       "instructions": "Trieu una de les dues opcions i redacteu un text amb una extensió entre 200 i 220 paraules.",
       "min_words": 200,
       "max_words": 220,
       "choices": [
        {
         "key": "A",
         "text": "Heu rebut aquest correu de la companyia amb la qual teniu contractada la llum en què us demanen que participeu en el nou projecte que han posat en marxa. Us sembla una proposta interessant i, després de rebre’n més informació, decidiu participar-hi. Envieu un correu electrònic a una persona de la colla, expliqueu-li la proposta i intenteu convéncer-la perquè també se sume al projecte. Us heu de basar en aquest text per a explicar la informació que voleu transmetre.",
         "image": "/exams/c2-octubre-2022/e5-a.jpg",
         "image_text": "Correu electrònic: «Hola, Júlia, Tu millor que ningú saps que darrere d’una decisió com la de triar la companyia elèctrica hi ha, en realitat, l’elecció del món on volem viure. Per això, per a nosaltres és molt important que et sentes part de la revolució de les teulades. Perquè, si t’instal·les plaques solars amb nosaltres, formaràs part d’un procés molt més important del que sembla: la teua teulada no és un mer suport per a unes plaques, és un suport per a una revolució.» Apartat «Un model per a un món millor»: «A diferència del model d’autoconsum, en què s’instal·len les plaques justes per donar servei a una llar, amb el nostre model la teua teulada es converteix en una petita central de producció elèctrica. Aquesta és l’única manera de canviar realment el model centralitzat que patim hui en dia, i la manera d’estalviar en la factura de la llum. Com més teulades, més energia verda i de proximitat.» Al costat, fotografia aèria d’un barri residencial amb arbres i cases amb plaques solars en alguns teulats. Apartat «Porta’ns una teulada i ix guanyant»: «Si coneixes algú amb una teulada viable per a instal·lar-hi plaques solars, presenta’ns-el. Si es dona d’alta en la companyia, us recompensarem amb 400€, 200€ per a cadascun. Pots portar-nos tantes teulades com vulgues, però això sí, afanya’t, que l’oferta no dura per sempre!» Signat: Robert Solana, Departament Comercial de LlumiSol."
        },
        {
         "key": "B",
         "text": "Fa poc que ha entrat en vigor la reforma de la llei de trànsit, però sembla que els canvis no han arribat a tothom, ja que encara es cometen moltes infraccions. El canvi de normativa s’adapta als nous comportaments al volant. L’empresa de publicitat per a la qual treballeu us ha encomanat que redacteu el guió per a una falca publicitària institucional que es reproduirà en totes les ràdios comarcals. Us heu de basar en aquesta infografia per a explicar la informació que voleu transmetre.",
         "image": "/exams/c2-octubre-2022/e5-b.jpg",
         "image_text": "Infografia «Quins són els canvis de la nova llei de trànsit?», amb sis icones circulars grises i un text cadascuna. «+20»: desapareix el marge de 20 km/h per fer un avançament. Mà amb un telèfon mòbil: es retiren entre 3 i 6 punts per fer servir el mòbil o tenir-lo a la mà. Cinturó de seguretat: hi ha més sancions per no fer servir sistemes de seguretat com el cinturó. Cotxe amb ones de senyal: se sanciona no només fer servir un detector de radars, també portar-lo al cotxe. Bicicleta amb una fletxa doble: no respectar la distància amb bicicletes costa ara 6 punts del carnet. Cigarret encés: llençar cigarretes per la finestra és sancionat amb la pèrdua de 6 punts."
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
     "intro": "Aquesta àrea té dues parts: un monòleg d’uns tres minuts sobre un tema que trieu, amb les idees que heu de desenvolupar, i un diàleg d’uns quatre minuts amb una altra persona aspirant, en què defenseu el paper que vos toque.",
     "exercises": [
      {
       "n": 6,
       "kind": "oral",
       "instructions": "Heu de triar un tema i preparar un monòleg de tres minuts, aproximadament. A continuació trobareu el tema sobre el qual heu de parlar i les idees que heu de desenvolupar.",
       "proposals": [
        {
         "title": "Monòleg · Algoritmes a les xarxes socials",
         "duration": "3 minuts",
         "intro": "De ben segur que alguna vegada heu buscat algun producte per internet i després heu trobat anuncis sobre aquell mateix producte o similars en les vostres xarxes socials. Això passa gràcies als algoritmes. Els algoritmes cada vegada són més coneguts en la nostra societat, ja que les xarxes socials estan creades per a calcular què ens agrada, què volem comprar, quines són les nostres amistats... Envieu una nota de veu a la tertúlia d’un programa de ràdio en què es parla sobre el tema. Cal que tingueu en compte, entre altres, aquestes idees:",
         "questions": [
          "Els algoritmes estan pensats per a poder millorar l’experiència individual de l’usuari en les xarxes.",
          "Aquestes fórmules tenen una capacitat molt elevada de manipulació i influència, i són un aparador de publicitat.",
          "El fet que ens mostren el contingut que saben que ens interessa fa augmentar els índexs d’addicció a les xarxes socials."
         ],
         "images": []
        },
        {
         "title": "Monòleg · Retardar la maternitat",
         "duration": "3 minuts",
         "intro": "Hui en dia, les dones troben cada vegada més dificultats per a quedar-se embarassades, no només pel fet d’endarrerir el moment de la maternitat, sinó per altres impediments socials. Per això, la indústria de la reproducció assistida s’ha disparat, i el nostre país ja és un dels líders mundials del sector. Enregistreu un missatge de veu que enviareu a la secció dels oients del magazín radiofònic del matí. Cal que tingueu en compte, entre altres, aquestes idees:",
         "questions": [
          "L’endarreriment de la maternitat s’està convertint en un fenomen social i demana polítiques socials ambicioses.",
          "Es pot aconseguir ser mare per diferents vies, però moltes dones no les poden costejar.",
          "En alguns casos s’opta per alternatives que alguns grups socials consideren poc ètiques."
         ],
         "images": []
        }
       ]
      },
      {
       "n": 7,
       "kind": "oral",
       "instructions": "Heu de mantindre un diàleg amb un altre o una altra aspirant sobre la situació comunicativa que us proposem. Llegiu la introducció del tema i defenseu el paper que us atorga la proposta que està ombrejada. Les intervencions han de ser equilibrades; eviteu donar respostes massa curtes i participeu activament com ho faríeu en una conversa habitual. La duració de la conversa serà de quatre minuts, aproximadament.",
       "proposals": [
        {
         "title": "Diàleg · Les enquestes i la creació de l’opinió pública",
         "duration": "4 minuts",
         "intro": "Les turbulències polítiques, econòmiques, socials i culturals han creat una necessitat imperativa de conéixer els canvis que s’estan produint en la nostra societat. Per això, mitjans de comunicació, empreses, administracions i partits polítics encarreguen enquestes constantment per testar l’estat d’opinió de la societat en multitud de temes i poder decidir les estratègies que seguiran.",
         "questions": [],
         "images": [],
         "roles": [
          {
           "name": "Opció A",
           "text": "Participeu en un debat radiofònic en què es tracta aquest tema. Penseu que les enquestes són un instrument que aporta informació. A més, considereu que són estratègies necessàries per a copsar els canvis i les tendències que es produeixen en la societat."
          },
          {
           "name": "Opció B",
           "text": "Participeu en un debat radiofònic en què es tracta aquest tema. Penseu que les enquestes no busquen descriure un temps present, sinó que l’objectiu principal és simplificar la informació. A més, considereu que l’objectiu és condicionar l’opinió pública futura."
          }
         ]
        },
        {
         "title": "Diàleg · Abusos i límits en l’esport",
         "duration": "4 minuts",
         "intro": "Recentment s’ha sabut que la Unió Internacional de Patinatge ha decidit elevar l’edat mínima permesa per a poder prendre part en les diferents competicions que du a terme, amb la intenció de protegir la salut física i mental, i el benestar emocional, dels i de les esportistes.",
         "questions": [],
         "images": [],
         "roles": [
          {
           "name": "Opció A",
           "text": "Participeu en un fòrum sobre esport i exposeu la vostra opinió sobre aquest tema. Penseu que l’edat no és important quan parlem dels i les esportistes d’elit, i que restringir l’edat per a participar-hi pot limitar la seua carrera esportiva. A més, opineu que la solució és oferir-los suport psicològic perquè aprenguen a gestionar els moments de màxim estrés."
          },
          {
           "name": "Opció B",
           "text": "Participeu en un fòrum sobre esport i exposeu la vostra opinió sobre aquest tema. Penseu que l’esport d’alta competició pot causar estralls en els més joves pel nivell d’estrés tan alt que han de suportar els i les esportistes. A més, considereu que caldria limitar l’edat mínima en qualsevol competició d’alt nivell."
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
