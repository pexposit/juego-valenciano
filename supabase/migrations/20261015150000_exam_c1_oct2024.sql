-- Examen interactiu C1 de la JQCV (octubre 2024) com a recurs de category 'examen'.
-- Contingut a metadata.exam, amb les quatre àrees del C1 i la puntuació de la guia de la prova
-- (comprensió escrita 10 %, 5 preguntes de 20 punts; estructures lingüístiques 20 %, 30 buits;
-- expressió escrita 35 % i expressió oral 35 %; mínim del 20 %, el 40 % i el 50 % segons el pes de
-- l'àrea). Les respostes són les de la plantilla oficial que inclou el quadern. Les redaccions es
-- corregixen amb la rúbrica C1; les infografies de l'exercici 5 són a frontend/public/exams/.
-- Font: https://jqcv.gva.es/documents/161863165/165492633/C1+octubre+2024.pdf/f250360f-8524-ece2-4e51-0382c0e31308

INSERT INTO public.resources (id, name, type, url, content, metadata, xp_earned, difficulty, category)
SELECT id, name, type, url, content, metadata, xp_earned, difficulty, category
FROM jsonb_populate_record(NULL::public.resources, $data${
 "id": "2691a0df-46fd-533b-823f-7c7c90726869",
 "name": "Simulacre C1: octubre 2024",
 "type": "jqcv_c1_oct2024",
 "category": "examen",
 "difficulty": "C1",
 "xp_earned": 40,
 "content": "Examen oficial C1 de la JQCV (octubre 2024): comprensió escrita i estructures lingüístiques autocorregibles, dos redaccions i pràctica oral.",
 "metadata": {
  "icon": "👶",
  "color": "#B3E5FC",
  "exam_body": "JQCV",
  "certificate_level": "C1",
  "exam": {
   "level": "C1",
   "session": "Octubre 2024",
   "body": "JQCV",
   "source_url": "https://jqcv.gva.es/documents/161863165/165492633/C1+octubre+2024.pdf/f250360f-8524-ece2-4e51-0382c0e31308",
   "pass_rule": "Per a ser APTE cal una puntuació global mínima de 60 sobre 100. Les àrees valen un 10 % (comprensió escrita), un 20 % (estructures lingüístiques), un 35 % (expressió i interacció escrites) i un 35 % (expressió i interacció orals), i en cada una cal arribar al mínim: el 20 % en la comprensió escrita, el 40 % en les estructures lingüístiques i el 50 % en les dos àrees d’expressió.",
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
        "title": "Què perceben els bebés?",
        "paragraphs": [
         "Al principi, el món sencer està fet d’olors. Imaginem-nos una cosa així: un entorn fosc i plàcid i un fetus nadant dins del ventre de la mare com si no sentira la gravetat. I, en este moment, els primers senyals que percep el nas del fetus li arriben al còrtex cerebral i transmeten informació sobre el líquid amniòtic que l’embolca. En estudis fets amb dones embarassades que havien ingerit pastilles d’all, s’ha demostrat que el líquid amniòtic fa olor i té gust —dins de l’úter costa distingir un sentit de l’altre— del que menja la futura mare.",
         "El neurocientífic estatunidenc Joel Frohlich, de l’Institut de Neuromodulació i Neurotecnologia de l’Hospital Universitari de Tübingen, investiga les experiències i les percepcions dels fetus. “És clar que no sabem certament què se sent quan s’és un fetus”, explica Frohlich. “Però un dels sentits que probablement està especialment desenvolupat en els nonats és l’olfacte.” Allò que ensuma i tasta un fetus dins del ventre de la mare pot determinar les preferències d’una criatura fins i tot després del naixement. Si la mare menja all o anís durant l’embaràs, el nounat tendix a girar més a sovint el cap en direcció a una font d’olor d’all o d’anís que els nadons que no estan familiaritzats amb estes olors.",
         "Però, a partir de quina setmana d’embaràs un fetus és capaç de percebre l’olor i el gust del líquid amniòtic de manera conscient? Un ser humà en procés de creació ja té allò que es podria anomenar consciència? Tot això, efectivament, també depén del que s’entenga per consciència. Probablement la consciència no és un fenomen de tot o res, sinó que hi ha diversos graus de consciència. L’etapa primària se centra principalment en la integració de diverses percepcions sensorials en relació amb la memòria. En este sentit, molts membres de la comunitat científica situen la consciència principalment en l’escorça cerebral d’una persona.",
         "Siga com siga, una persona en desenvolupament ja pren consciència de gran part del món exterior quan encara està dins de l’úter. A banda del sentit de l’olfacte i del gust, cada vegada hi sent més. El batec del cor de la mare és omnipresent i pròxim, com també poden sentir clarament els sorolls dels intestins materns. Ara bé, quan l’espai comença a quedar un poc just, hi ha un esdeveniment que és imminent. Un que expulsarà el fetus de l’ambient càlid, fosc i protegit de l’úter: el part. “Si poguérem recordar el nostre naixement, probablement seria una experiència molt intensa”, diu Frohlich. La dècada de 1980, Lagercrantz va descobrir que, al nàixer, el nadó allibera grans quantitats de les hormones de l’estrés, l’adrenalina i la noradrenalina. Estes hormones desvetlen el nadó de la placidesa del seu son i, al mateix temps, reduïxen el dolor que puga sentir al passar pel canal del part.",
         "Si bé, en comparació amb altres animals, els nadons humans encara estan molt verds en el moment de nàixer, poden fer justament allò que necessiten per a sobreviure. Per exemple, els nounats oloren molt bé la llet materna, i per este motiu no solen tindre problemes per a trobar el pit. També reconeixen la veu de sa mare poc després de nàixer. A més, els nounats tenen una mena de sèptim sentit, el que es coneix com a interocepció: “Són capaços de percebre la seua pròpia respiració, el seu propi cor i el seu propi sistema digestiu”, explica Frohlich.",
         "Amb el que té més problemes un nounat és amb la vista, ja que la percepció del color encara no està completament desenvolupada. El roig i el verd probablement són un poc més fàcils de distingir que el blau i el groc, però veuen moltes coses en blanc i negre. Amb tot, hi ha una cosa que sí que saben reconéixer bé i per la qual se senten atrets. Una cosa que resulta ser molt rellevant per a poder continuar desenvolupant-se i sentir-se segurs: els rostres.",
         "Frohlich explica que, en comparació amb els adults, els nadons tenen una espècie de “superpoder”: absorbixen el seu entorn amb molts menys filtres i, a diferència de la xicalla de més edat i dels adults, no classifiquen immediatament tot allò que veuen segons els conceptes apresos."
        ]
       },
       "questions": [
        {
         "n": 0,
         "prompt": "El text analitza…",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "el procés en què el fetus percep tots els sentits dins de l’úter."
          },
          {
           "key": "b",
           "text": "les qualitats que té el líquid amniòtic per a transmetre coneixements."
          },
          {
           "key": "c",
           "text": "com es desenvolupen els sentits en el ser humà dins i fora de l’úter."
          },
          {
           "key": "d",
           "text": "com els bebés no tenen filtres a l’hora de percebre la realitat."
          }
         ],
         "scored": false
        },
        {
         "n": 1,
         "prompt": "Els primers senyals que percep el fetus…",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "ajuden a forjar els gustos i apetits de la futura criatura."
          },
          {
           "key": "b",
           "text": "són més intensos si la mare menja aliments com all o anís."
          },
          {
           "key": "c",
           "text": "estan poc determinats per la informació que transmet el líquid amniòtic."
          },
          {
           "key": "d",
           "text": "repercutixen en els moviments que realitza durant la gestació."
          }
         ]
        },
        {
         "n": 2,
         "prompt": "Els primers moments de consciència del ser humà…",
         "answer": "d",
         "options": [
          {
           "key": "a",
           "text": "comencen en l’úter, quan es desenvolupen tots els sentits."
          },
          {
           "key": "b",
           "text": "coincidixen amb el desenvolupament de l’escorça cerebral."
          },
          {
           "key": "c",
           "text": "estan determinats pel batec del cor de la mare, entre altres."
          },
          {
           "key": "d",
           "text": "connecten la memòria i la percepció del gust i l’olfacte."
          }
         ]
        },
        {
         "n": 3,
         "prompt": "El moment del part…",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "s’inicia pels sorolls de la veu de la mare i els intestins."
          },
          {
           "key": "b",
           "text": "es produïx quan l’espai es reduïx, segons alguns especialistes."
          },
          {
           "key": "c",
           "text": "genera canvis en el nadó, que li disminuïxen el dolor."
          },
          {
           "key": "d",
           "text": "dels sers humans i d’altres animals és semblant."
          }
         ]
        },
        {
         "n": 4,
         "prompt": "Els sers humans al nàixer…",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "tenen la supervivència garantida per la facilitat per a olorar la llet materna."
          },
          {
           "key": "b",
           "text": "alliberen hormones que els preparen per a la vida en el món exterior."
          },
          {
           "key": "c",
           "text": "sobreviuen gràcies a la consciència corporal anomenada interocepció."
          },
          {
           "key": "d",
           "text": "disposen de més capacitat adaptativa que la resta de sers vius mamífers."
          }
         ]
        },
        {
         "n": 5,
         "prompt": "La percepció visual dels nounats…",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "els permet distingir tots els colors de la mateixa manera."
          },
          {
           "key": "b",
           "text": "està esbiaixada per l’entorn que l’envolta."
          },
          {
           "key": "c",
           "text": "els ajuda a identificar i a distingir trets facials."
          },
          {
           "key": "d",
           "text": "és el factor diferencial entre xiquets i adults."
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
        "title": "Integritat i macrofestivals: músics a la venda",
        "paragraphs": [
         "A sovint l’especialista en cultura popular Chuck Klosterman situa (0) com la zona zero de l’acusació artística de vendre’s un doble moment: quan The Who publicaren The Who Sell Out (és a dir, ‘The Who es venen’) i quan Bob Dylan prengué una guitarra elèctrica en el festival de folk de Newport. Anys 1967 i 1965. Però troba en els 90 l’(6) ______ de la importància de no vendre’s: “El que feia que vendre’s fora tan psicològicament problemàtic era el nivell de gradació inherent als principis. No es referia només al fet (7) ______ algú estiguera intentant vendre una cosa per a fer-se ric, (8) ______ que es referia que algú estava comprometent els valors que abans defenia (9) ______ una cosa superficial (que solien ser diners, però no sempre)”. La música com a principi motor de la integritat.",
         "(10) ______, Klosterman reconeix que el canvi entre el consum musical dels noranta respecte al de l’actualitat és tan enorme que no té (11) ______ amb “la distància que existix entre conduir un cotxe o muntar a cavall. És com la distància entre botar foc a alguna cosa o (12) ______ en la foscor a esperar que isca el sol”. El foc, explica el compositor Ryan Tedder (que s’ha encarregat de (13) ______ d’uns quants hits de Beyoncé, Adele o Taylor Swift), fa que les cançons hagen de captar l’atenció en els primers segons per tal que l’usuari no canvie de tema en la seua (14) ______ per Spotify i puga monetitzar-se. O que la intro d’un tema sone més tiktokera, amb l’afany que TikTok trie quinze segons de la teua cançó per a ambientar els seus vídeos.",
         "La Llei del Ciberespai de la Xina, aprovada (15) ______ 2020, (16) ______ que els algoritmes han de conduir l’usuari a través del mainstreaming, una manera d’arribar al pensament central. Se sospita (narra Claudio F. González en el recomanable llibre El gran sueño de China) que els algoritmes de recomanació estan personalitzats allí per a evitar la (17) ______ d’estils com el hip-hop o el rap, considerats potencialment problemàtics per a la societat. Nando Cruz, en Macrofestivales, denuncia que les grans cites musicals s’han convertit en exemple de monopoli i monocultiu, utilitzades per les administracions per a aconseguir visitants (18) ______ d’articular culturalment les seues societats. I pel camí ha deixat sense marge l’experimentació o la diversitat d’estils. Per tant, la discussió ha canviat, (19) ______ ja no va de si vendre’s o no vendre’s; (20) ______ de com aconseguir el dret de poder vendre’s enfront d’un mercat monolític."
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
           "text": "apogeu"
          },
          {
           "key": "b",
           "text": "ocàs"
          },
          {
           "key": "c",
           "text": "escenari"
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
           "text": "de què"
          },
          {
           "key": "b",
           "text": "que"
          },
          {
           "key": "c",
           "text": "què"
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
           "text": "si no"
          },
          {
           "key": "b",
           "text": "sinó"
          },
          {
           "key": "c",
           "text": "sino"
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
           "text": "barata"
          },
          {
           "key": "b",
           "text": "barat a"
          },
          {
           "key": "c",
           "text": "barata a"
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
           "text": "Comptat i debatut"
          },
          {
           "key": "b",
           "text": "A saber"
          },
          {
           "key": "c",
           "text": "No obstant"
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
           "text": "res que veure"
          },
          {
           "key": "b",
           "text": "res a vore"
          },
          {
           "key": "c",
           "text": "res de vore"
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
           "text": "arrufar-se"
          },
          {
           "key": "b",
           "text": "encollir-se"
          },
          {
           "key": "c",
           "text": "constrényer-se"
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
           "text": "compostar"
          },
          {
           "key": "b",
           "text": "composar"
          },
          {
           "key": "c",
           "text": "compondre"
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
           "text": "drecera"
          },
          {
           "key": "b",
           "text": "deriva"
          },
          {
           "key": "c",
           "text": "dretura"
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
           "text": "en"
          },
          {
           "key": "b",
           "text": "a"
          },
          {
           "key": "c",
           "text": "al"
          }
         ]
        },
        {
         "n": 16,
         "prompt": "Buit 16",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "senyala"
          },
          {
           "key": "b",
           "text": "anota"
          },
          {
           "key": "c",
           "text": "assenyala"
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
           "text": "promulgació"
          },
          {
           "key": "b",
           "text": "proliferació"
          },
          {
           "key": "c",
           "text": "procreació"
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
           "text": "en compte"
          },
          {
           "key": "b",
           "text": "enlloc"
          },
          {
           "key": "c",
           "text": "en vegada"
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
           "text": "puix"
          },
          {
           "key": "b",
           "text": "puix que"
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
           "text": "més prompte"
          },
          {
           "key": "b",
           "text": "més avia’t"
          },
          {
           "key": "c",
           "text": "més tirant"
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
        "title": "Fronteres",
        "paragraphs": [
         "Quatre pedres, enllaçades amb ciment i coronades amb un gran (0) nuc de fil d’aram amb espines, formen un mur que s’enlaira cap als límits de l’atmosfera i s’expandix per cada mar i oceà. Este mur físic i (21) ______ imaginari delimita cada espai de la terra en parcel·les, com si fora un trencaclosques acabat en què cada peça, (22) ______ siga independent, conforma un paisatge global, el nostre món. En realitat este (23) ______ és un poc més complicat: cada peça es correspon amb un país i els murs són fronteres que ens separen dels nostres veïns. A parer meu, més que contradictori, és (24) ______: totes les peces són absolutament necessàries per a poder-lo acabar, per a fer del conjunt un paisatge comú que ens unisca a tots.",
         "És curiós com els humans, sent sers socials que necessitem conviure per al nostre (25) ______ individual i col·lectiu, ens esforcem tant a mantindre clars els límits entre el jo i el tu, el nosaltres i el vosaltres, entre el meu país i el teu país. Cal diferenciar entre els murs i els ponts. Cal tindre en compte que els ponts et permeten caminar d’una part a l’altra; per contra, els murs et (26) ______ el pas i et limiten. És més curiós encara vore que les fronteres, per a determinades persones, són ponts, (27) ______ per a altres són murs: tot depén del teu origen i de la teua capacitat econòmica. Podríem pensar que les fronteres són límits que ens protegixen. Protegixen el nostre territori, marquen l’abast de les lleis legislatives i polítiques d’un país, controlen el que entra i ix, i un llarg etcètera (28) ______ jo em pregunte: no podem fer tot açò sense establir duanes, sense establir límits artificials? En alguns espais està fent-se: ja no hi ha fronteres entre determinats països. D’exemples, (29) ______ tenim ben prop: les vegades que he viatjat a Andorra ho he fet fàcilment, amb el cotxe, sense mostrar quasi ni el passaport. A més, en l’aeroport des d’Espanya, per a anar a qualsevol país europeu, el Marroc i els Estats Units per exemple, (30) ______ he necessitat mostrar el passaport per a validar que soc qui afirme ser, res més. Ara bé, és tan fàcil per a una persona (31) ______ viatjar a Espanya (quan som veïns), a altres països europeus o als Estats Units? No, de cap de les maneres. Per què?",
         "La resposta fàcil que molta gent ni es qüestiona és afirmar que és simplement una distinció per qüestions i xifres de migracions, i els requisits del país de recepció en països com el Marroc són simplement tràmits preventius enfront de la migració. Però, té igual, perquè estos requisits de prevenció, més que construir ponts i aprofundir en la prevenció de la migració basada en les necessitats de la ciutadania, ens estan distingint i delimitant entre occidentals i orientals. O és que la gent espanyola no migra també? El problema de les migracions forçades no té un rerefons més important que viure en un país o en un altre? No habitem tots el mateix món? És trist com els ponts o els murs es construïxen a partir d’acords polítics i econòmics. Gràcies a la meua experiència i convivència, he aprés que un marroquí ha de demostrar econòmicament que pot viure a Espanya el temps per al qual es demane el visat, (32) ______ per a viatjar una setmana i tornar. Però jo, com a espanyola, no ho he de fer per a anar a Suïssa de viatge, ni al Marroc, ni als Estats Units. No vullc dir que siga així de fàcil viatjar a tots els països, ja que (33) ______ alguns que tenen uns requisits molt estrictes, com Austràlia. El que m’agradaria reflexionar és que estos requisits estan reforçant la distinció entre classes socials, entre persones i entre occidentals i orientals, una vegada més. Limiten la llibertat individual, la convivència i l’aprenentatge entre veïns, com Espanya i el Marroc.",
         "I és que, per a mi, les fronteres, com he dit abans, no són iguals per a tot el món, i en cas que (34) ______ a llarg termini estes distincions entre el tu i el jo, ells o elles i nosaltres, mai comptarem amb una igualtat real que no es base en quants diners tenim o deixem de tindre en el banc, o la nacionalitat que marque el nostre passaport. En este moment, podríem ser un poquet més lliures i no (35) ______ racistes."
        ]
       },
       "questions": [
        {
         "n": 21,
         "prompt": "Buit 21",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "de colp i volta"
          },
          {
           "key": "b",
           "text": "a vegades"
          },
          {
           "key": "c",
           "text": "si fa no fa"
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
           "text": "atés que"
          },
          {
           "key": "b",
           "text": "a fi que"
          },
          {
           "key": "c",
           "text": "a pesar que"
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
           "text": "puzle"
          },
          {
           "key": "b",
           "text": "sambori"
          },
          {
           "key": "c",
           "text": "embarbussament"
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
           "text": "distòpic"
          },
          {
           "key": "b",
           "text": "paradoxal"
          },
          {
           "key": "c",
           "text": "incoherent"
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
           "text": "desenrotllament"
          },
          {
           "key": "b",
           "text": "desvetlament"
          },
          {
           "key": "c",
           "text": "desensonyament"
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
           "text": "barren"
          },
          {
           "key": "b",
           "text": "fiten"
          },
          {
           "key": "c",
           "text": "barregen"
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
           "text": "mentrestant"
          },
          {
           "key": "b",
           "text": "mentre"
          },
          {
           "key": "c",
           "text": "mentres que"
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
           "text": "sobre el que"
          },
          {
           "key": "b",
           "text": "sobre què"
          },
          {
           "key": "c",
           "text": "sobre el qual"
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
           "text": "hi"
          },
          {
           "key": "b",
           "text": "en"
          },
          {
           "key": "c",
           "text": "n’hi"
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
           "text": "a soles"
          },
          {
           "key": "b",
           "text": "sol"
          },
          {
           "key": "c",
           "text": "soles"
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
           "text": "marroquineria"
          },
          {
           "key": "b",
           "text": "marroquina"
          },
          {
           "key": "c",
           "text": "marroquí"
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
           "text": "inclús"
          },
          {
           "key": "b",
           "text": "inclòs"
          },
          {
           "key": "c",
           "text": "incloent"
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
           "text": "hi ha"
          },
          {
           "key": "b",
           "text": "els hi ha"
          },
          {
           "key": "c",
           "text": "n’hi ha"
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
           "text": "mantenim"
          },
          {
           "key": "b",
           "text": "mantinguem"
          },
          {
           "key": "c",
           "text": "mantenint"
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
           "text": "tant"
          },
          {
           "key": "b",
           "text": "tan"
          },
          {
           "key": "c",
           "text": "tant de"
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
         "text": "Una taula de ping-pong, una sala amb consoles i una televisió, una zona de bar i jocs de cartes. Qualsevol pensaria que es tracta d’una casa particular o d’un recinte lúdic, però tot això ho podem trobar també en moltes empreses. Les últimes innovacions en l’àmbit laboral busquen el benestar del personal per a millorar el rendiment de l’empresa, ja que este entorn també influïx en la felicitat. Redacta un correu electrònic per al teu cap en què li proposes l’aplicació d’estes mesures que tant beneficien el personal i, per extensió, l’empresa. Cal que hi tractes, entre altres, els punts següents:",
         "points": [
          "Una persona feliç rendix més.",
          "La cohesió dels membres de l’empresa.",
          "La motivació repercutix en l’esforç."
         ]
        },
        {
         "key": "B",
         "text": "Espanya no és França, a on el sistema educatiu sí que incorpora el cine com una assignatura independent; ni Itàlia, a on des de 1998 funciona un pla nacional per a la promoció de la didàctica del llenguatge cinematogràfic i audiovisual en l’escola. En canvi, ací qualsevol debat sobre la transmissió del cine ha de començar en l’ensenyança superior, com és el grau de Comunicació Audiovisual. Treballes com a docent en un institut i, per la teua afició al cine, t’han encomanat que redactes un article d’opinió per a la revista del centre en què poses de manifest la necessitat d’ensenyar les bases del llenguatge cinematogràfic. Cal que hi tractes, entre altres, els punts següents:",
         "points": [
          "Vore una pel·lícula en l’institut no és treballar el cine.",
          "La gent jove ha deixat d’anar a les sales de cine.",
          "Falten professionals preparats en els centres educatius."
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
         "text": "Envellir és difícil; no hi ha dubte. Fa poc has llegit un llibre molt interessant d’una autora sueca sobre consells per a envellir de manera saludable. Segons ella, no pots parar el pas del temps ni com afecta el teu cos, però pots seguir algunes pautes per a mantindre una ment clara i positiva. Treballes com a cuidador o cuidadora en una residència de la tercera edat i, a partir de la teua lectura, has decidit escriure una entrada en el teu blog per a donar consells sobre com envellir de manera activa. Cal que tingues en compte la informació de la infografia següent:",
         "image": "/exams/c1-octubre-2024/e5-a.jpg",
         "image_text": "Infografia «Consells per a un envelliment saludable», amb el dibuix d’una persona gran fent exercici i sis consells: Accepta les obligacions molestes: si pagues una factura, és perquè pots fer-ho. Adapta’t al teu nou context vital: és clau per a tindre èxit al llarg de la vida. Digues que sí sempre que siga possible: no rebutges plans. Reconeix l’edat que tens, però no faces d’això un problema. Busca activitats que pugues fer. Envolta’t de jóvens: et recordarà qui vas ser."
        },
        {
         "key": "B",
         "text": "L’autònom naix o es fa? Cal tindre esperit d’autònom per a emprendre i tirar avant un projecte propi? Tot el món coincidix que ser autònom requerix tindre un tarannà especial, ser capaç de viure amb certs riscos i no necessitar un sou fix a final de mes. Fa unes setmanes que investigues sobre este assumpte i has estat arreplegant algunes dades de diversos webs. A partir de la informació de la imatge, escriu un article divulgatiu per a la revista digital de l’associació de comerciants de la teua ciutat en què expliques què cal fer per a emprendre un projecte per compte propi. Cal que tingues en compte la informació de la infografia següent:",
         "image": "/exams/c1-octubre-2024/e5-b.jpg",
         "image_text": "Infografia «Consells per a emprendre», dibuixada com un conjunt de finestres de navegador, amb cinc consells: Para l’orella: mantín els ulls oberts i acosta’t a persones que puguen ensenyar-te alguna cosa útil. Controla les finances (sense text explicatiu: el tapa la finestra següent). Pensa en la clientela: el teu negoci està centrat en els possibles clients; recorda prestar atenció a les seues necessitats i preferències. Enamora’t del projecte: la passió es transmet, així que si tu estàs convençut del que fas, els altres creuran en tu. Establix metes: tin clares les teues metes a curt, mitjà i llarg termini per a poder establir un pla d’acció per a complir-les."
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
     "intro": "Esta àrea té dos parts: un monòleg d’uns tres minuts sobre un tema que tries i un diàleg d’uns quatre minuts amb una altra persona aspirant.",
     "exercises": [
      {
       "n": 6,
       "kind": "oral",
       "instructions": "Has de triar un tema i preparar un monòleg de tres minuts, aproximadament. A continuació trobaràs el tema sobre el qual has de parlar i les idees que has de desenvolupar.",
       "proposals": [
        {
         "title": "Monòleg · L’exageració dels problemes",
         "duration": "3 minuts",
         "intro": "Pensar que alguna cosa no eixirà bé o que no som prou bons és un mecanisme que utilitza tot el món. Estos pensaments a sovint es focalitzen en aspectes negatius d’una situació, exagerant els problemes o anticipant resultats desfavorables. En el programa de ràdio de hui es parla sobre este tema, i has decidit enviar un missatge de veu en el torn obert de paraula per a donar-ne la teua opinió. Cal que tingues en compte, entre altres, estes idees:",
         "questions": [
          "La tendència a pensar de manera hipervigilant, catastròfica o negativa.",
          "La importància de treballar en la confiança en un mateix i sentir seguretat.",
          "L’ús de mecanismes per a frenar els pensaments circulars i negatius."
         ],
         "images": []
        },
        {
         "title": "Monòleg · No em vullc perdre l’experiència!",
         "duration": "3 minuts",
         "intro": "La por a perdre experiències úniques porta a reservar mesos abans i planejar amb molta antelació el nostre temps lliure. Per a arribar a tot, ens veem obligats a quedar amb mesos d’antelació per a no perdre’ns eixe espectacle o eixe sopar en un restaurant amb estreles Michelin. Participes en una taula redona en què es parla sobre este tema, i en el teu torn de paraula expresses la teua opinió. Cal que tingues en compte, entre altres, estes idees:",
         "questions": [
          "Tendència a viure la cultura com un èxit, en compte de disfrutar-la.",
          "Impacte de les xarxes socials en el fet de sentir que ens perdem alguna cosa.",
          "Necessitat d’omplir l’agenda amb esdeveniments futurs: autoimposició?"
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
         "title": "Diàleg · Els quioscos es busquen la vida",
         "duration": "4 minuts",
         "intro": "Els quioscos de premsa han fet seua la màxima de renovar-se o morir. Per a compensar la caiguda de vendes de diaris i revistes, han incorporat altres productes com ara llepolies o joguets i cromos per als més menuts, a més de publicitat. Però a on més s’ha evidenciat la reinvenció ha sigut en les zones turístiques, en què els souvenirs han arraconat la premsa.",
         "questions": [],
         "images": [],
         "roles": [
          {
           "name": "Persona A",
           "text": "Com a membre d’una organització ecologista, participes en una taula redona organitzada per l’Ajuntament sobre el futur d’estos establiments, i penses que este tipus de negocis no són sostenibles i la seua evolució cap a tendes de souvenirs és un pas més cap a la turistificació de la ciutat. Creus, a més, que el món evoluciona, i els quioscos i la premsa escrita són cosa del passat."
          },
          {
           "name": "Persona B",
           "text": "Com a propietari d’un quiosc, participes en una taula redona organitzada per l’Ajuntament sobre el futur d’estos establiments, i penses que la societat hauria de prendre mesures per a evitar que desaparegueren, ja que això implicaria una pèrdua de llocs de treball i també impediria accedir a la informació a aquelles persones que no ho fan des d’un dispositiu digital. Creus, a més, que els quioscos haurien de ser considerats part del patrimoni cultural i urbà de la ciutat."
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
