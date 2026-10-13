-- Examen interactiu B2 de la JQCV (octubre 2025) com a recurs de category 'examen'.
-- Contingut a metadata.exam, amb les cinc àrees del B2 i la puntuació oficial de la guia de la
-- prova (comprensió oral 8 i 12 punts per encert; comprensió escrita 3,3 i 8,5; estructures 5 i 5;
-- mínim del 40 % en cada àrea i del 50 % en l'oral). Les respostes són les de la plantilla
-- oficial que inclou el quadern. Àudio de comprensió oral a url, convertit a MP3 des de l'oficial
-- (frontend/public/audio/Audio_B2_oct2025.mp3). Font: https://jqcv.gva.es/documents/161863165/165492631/B2+octubre+2025.pdf/526dc3ac-9858-b9c6-3564-270760306faa

INSERT INTO public.resources (id, name, type, url, content, metadata, xp_earned, difficulty, category)
SELECT id, name, type, url, content, metadata, xp_earned, difficulty, category
FROM jsonb_populate_record(NULL::public.resources, $data${
 "id": "2d86e7f1-2873-552e-8ab3-46cb4668cd03",
 "name": "Simulacre B2: octubre 2025",
 "type": "jqcv_b2_oct2025",
 "category": "examen",
 "difficulty": "B2",
 "xp_earned": 40,
 "url": "/audio/Audio_B2_oct2025.mp3",
 "content": "Examen oficial B2 de la JQCV (octubre 2025): comprensió oral i escrita i estructures lingüístiques autocorregibles, dos redaccions i pràctica oral.",
 "metadata": {
  "icon": "🌡️",
  "color": "#FFCC80",
  "exam_body": "JQCV",
  "certificate_level": "B2",
  "exam": {
   "level": "B2",
   "session": "Octubre 2025",
   "body": "JQCV",
   "source_url": "https://jqcv.gva.es/documents/161863165/165492631/B2+octubre+2025.pdf/526dc3ac-9858-b9c6-3564-270760306faa",
   "audio_source_url": "https://jqcv.gva.es/documents/161863165/167041107/NIVELL_B2_48KH_24BITS.wav/5a019c6a-b356-2a5a-369d-01c2b1311c71",
   "pass_rule": "Per a ser APTE cal una puntuació global mínima de 60 sobre 100. Les àrees valen un 20 % (comprensió oral), un 20 % (comprensió escrita), un 15 % (estructures lingüístiques), un 20 % (expressió escrita) i un 25 % (expressió oral), i en cada una cal arribar al mínim: el 40 % en les quatre primeres i el 50 % en l'expressió oral.",
   "areas": [
    {
     "n": 1,
     "title": "Comprensió oral",
     "weight": 20,
     "duration": "20 minuts",
     "audio": true,
     "intro": "A continuació escoltaràs dos àudios. Els escoltaràs dos vegades, amb una pausa d'un minut entre cada audició, perquè assegures les respostes. Només hi ha una resposta correcta per a cada enunciat.",
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
       "instructions": "A continuació escoltaràs una entrevista a Clotilde Leguil, professora del Departament de Psicoanàlisi de la Universitat de París 8. Llig les preguntes i tria l'opció correcta en cada cas. Només hi ha una resposta correcta per a cada pregunta.",
       "questions": [
        {
         "n": 1,
         "prompt": "Què impulsa Clotilde Leguil a reflexionar sobre la paraula tòxic?",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "La necessitat d'advertir sobre els efectes físics de les substàncies tòxiques."
          },
          {
           "key": "b",
           "text": "L'observació que el terme ha passat a descriure formes de malestar en l'àmbit relacional."
          },
          {
           "key": "c",
           "text": "La voluntat d'analitzar com els mitjans utilitzen terminologia científica i arguments d'autoritat."
          }
         ]
        },
        {
         "n": 2,
         "prompt": "Segons l'autora, quin és el sentit profund de la metàfora de la fletxa tòxica?",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "Representa la crítica social com a recurs per a protegir-se de l'altre."
          },
          {
           "key": "b",
           "text": "Evoca com l'entorn laboral pot generar dany emocional sense voler."
          },
          {
           "key": "c",
           "text": "Expressa com determinats discursos externs ens travessen i generen patiment intern."
          }
         ]
        },
        {
         "n": 3,
         "prompt": "La psicoanalista afirma que la toxicitat...",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "pot estar dins de nosaltres sense que ens n'adonem."
          },
          {
           "key": "b",
           "text": "és una sensació de benestar emocional."
          },
          {
           "key": "c",
           "text": "és un maltractament personal a u mateix."
          }
         ]
        },
        {
         "n": 4,
         "prompt": "Per què és tan difícil eixir de la toxicitat?",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "Perquè és una forma d'evitar-nos problemes."
          },
          {
           "key": "b",
           "text": "Perquè acabem interioritzant-la."
          },
          {
           "key": "c",
           "text": "Perquè no ens adonem que està en el nostre cos."
          }
         ]
        },
        {
         "n": 5,
         "prompt": "Quina proposta fa Clotilde Leguil per a superar la lògica de la toxicitat?",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "Reconnectar amb un desig que transcendix la satisfacció personal immediata."
          },
          {
           "key": "b",
           "text": "Substituir la toxicitat per hàbits saludables i relacions positives amb l'altra persona."
          },
          {
           "key": "c",
           "text": "Trobar límits socials clars per a evitar l'exposició al malestar extern."
          }
         ]
        }
       ]
      },
      {
       "n": 2,
       "kind": "binary",
       "instructions": "Escoltaràs uns consells per a estudiar de manera eficient. Relaciona els enunciats amb els consells i ordena'ls en el mateix orde en què apareixen en l'àudio. Marca «No surt» en els dos enunciats que no corresponen a cap consell i numera la resta de l'1 al 5.",
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
         "prompt": "No dubtes a sol·licitar ajuda a professionals, amistats o familiars si en algun moment en necessites.",
         "answer": "5"
        },
        {
         "n": 7,
         "prompt": "Alimentar-se diàriament amb proteïnes i hidrats contribuirà a mantindre't despert i cansar-te menys.",
         "answer": "x",
         "scored": false
        },
        {
         "n": 8,
         "prompt": "Té igual que estudies en la biblioteca o en casa, però mantín sempre les condicions adequades d'estudi.",
         "answer": "3"
        },
        {
         "n": 9,
         "prompt": "Assistir a classe et permetrà plantejar preguntes als professors que t'ajudaran a resoldre dubtes.",
         "answer": "1"
        },
        {
         "n": 10,
         "prompt": "Gravar-te per a poder escoltar-te després és una tècnica d'estudi que et pot resultar efectiva.",
         "answer": "4"
        },
        {
         "n": 11,
         "prompt": "Dedicar al dia sempre les mateixes hores d'estudi ens ajudarà a seguir una rutina i facilitarà la concentració.",
         "answer": "x",
         "scored": false
        },
        {
         "n": 12,
         "prompt": "Utilitza ferramentes digitals per a confeccionar un horari amb descansos i respectar-lo rigorosament.",
         "answer": "2"
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
        "title": "El misteri de les llàgrimes: per què plorem quan estem tristos?",
        "paragraphs": [
         "Plorar és una experiència humana per excel·lència. Altres espècies produïxen llàgrimes, però les nostres són les úniques que, segons els científics, emergixen (13) ______ no només per a lubricar i protegir els globus oculars, sinó també per a expressar emocions, com després de patir una ruptura sentimental, en les cerimònies o mentres veem un drama en el cine o en la televisió. Encara que són de les poques coses que ens fan (14) ______ humans, en molts sentits, les llàgrimes emocionals continuen sent un enigma. Una investigació ha revelat que les nostres emocions són encara més complicades del que els neurocientífics creien: no existix una zona en el cervell (15) ______ dels sentiments de tristor o ira, per exemple.",
         "Les causes canvien amb l'edat",
         "Durant els primers anys de la nostra vida, plorem sobretot per experiències pròpies: una rascada en el genoll, una picada d'abella o un gelat que ens ha caigut en terra. Això comença a canviar a (16) ______ que ens fem majors i ens desenvolupem més emocionalment i socialment. Plorem menys com a resposta al dolor (17) ______ i més per les nostres (18) ______ emocionals per altres persones. “El teu món es fa més gran quan hi ha persones que es tornen més importants per a tu”, diu Vingerhoets.",
         "Una de les raons més (19) ______ per a plorar és l'absència o la pèrdua d'un ser estimat, tant si el trobem a faltar quan no estem en casa, com si patim una ruptura amorosa durant l'adolescència o estem passant un (20) ______ per una mort a qualsevol edat. També plorem per les penes dels altres. Estes llàgrimes d'empatia poden produir-se perquè ens imaginem en el (21) ______ d'altres persones, siguen amics, desconeguts o inclús personatges de ficció.",
         "Els beneficis de plorar",
         "Entre els investigadors, (22) ______ el debat més antic és trobar per quin motiu plorar fa que les persones se senten millor. En un dels estudis més importants sobre este tema, es va preguntar a milers de persones de tot el món sobre l'última volta que havien vessat llàgrimes. Més de la mitat van dir que s'havien sentit millor, quasi el 40 % no va notar cap diferència i el 10 % va dir sentir-se pitjor. Plorar, (23) ______ quan s'està a soles, pot servir com una autoteràpia.",
         "En situacions socials, el factor que més influïx en com et sents després de plorar és com reaccionen les persones que et rodegen. Les persones que reben una resposta de suport, com un abraç o la validació dels seus sentiments, tendixen a sentir-se millor, mentres que, si les llàgrimes són rebudes amb ira o burla, les persones són més propenses a sentir-se pitjor. Això té sentit, ja que els experts creuen que el principal (24) ______ de la llàgrima, independentment de l'edat, és comunicar patiment als altres."
        ]
       },
       "options_title": "Propostes",
       "options": [
        {
         "key": "a",
         "text": "mesura"
        },
        {
         "key": "b",
         "text": "físic"
        },
        {
         "key": "c",
         "text": "comuns"
        },
        {
         "key": "d",
         "text": "dol"
        },
        {
         "key": "e",
         "text": "potser"
        },
        {
         "key": "f",
         "text": "espiritual"
        },
        {
         "key": "g",
         "text": "propòsit"
        },
        {
         "key": "h",
         "text": "lloc"
        },
        {
         "key": "i",
         "text": "sobretot"
        },
        {
         "key": "j",
         "text": "sistemàticament"
        },
        {
         "key": "k",
         "text": "distintivament"
        },
        {
         "key": "l",
         "text": "connexions"
        },
        {
         "key": "m",
         "text": "responsable"
        },
        {
         "key": "n",
         "text": "mida"
        },
        {
         "key": "o",
         "text": "comunes"
        }
       ],
       "questions": [
        {
         "n": 13,
         "prompt": "Buit 13",
         "answer": "j"
        },
        {
         "n": 14,
         "prompt": "Buit 14",
         "answer": "k"
        },
        {
         "n": 15,
         "prompt": "Buit 15",
         "answer": "m"
        },
        {
         "n": 16,
         "prompt": "Buit 16",
         "answer": "a"
        },
        {
         "n": 17,
         "prompt": "Buit 17",
         "answer": "b"
        },
        {
         "n": 18,
         "prompt": "Buit 18",
         "answer": "l"
        },
        {
         "n": 19,
         "prompt": "Buit 19",
         "answer": "o"
        },
        {
         "n": 20,
         "prompt": "Buit 20",
         "answer": "d"
        },
        {
         "n": 21,
         "prompt": "Buit 21",
         "answer": "h"
        },
        {
         "n": 22,
         "prompt": "Buit 22",
         "answer": "e"
        },
        {
         "n": 23,
         "prompt": "Buit 23",
         "answer": "i"
        },
        {
         "n": 24,
         "prompt": "Buit 24",
         "answer": "g"
        }
       ]
      },
      {
       "n": 4,
       "kind": "match",
       "instructions": "A continuació es descriuen set aplicacions informàtiques. Relaciona-les amb els enunciats. Hi ha tres enunciats que no corresponen a cap d'elles.",
       "options_title": "Enunciats",
       "options": [
        {
         "key": "a",
         "text": "Esta ferramenta és útil per a fer bons dissenys, però també et pot ajudar a preparar-te per als exàmens."
        },
        {
         "key": "b",
         "text": "Amb esta ferramenta pots crear fòrums i espais de debat per a fomentar la interacció escrita entre l'alumnat."
        },
        {
         "key": "c",
         "text": "És una ferramenta de comunicació ideal per a persones amb trastorns del llenguatge o dificultats de parla."
        },
        {
         "key": "d",
         "text": "Si eres ràpid a l'hora de respondre i encertes, obtindràs més punts i, per tant, la possibilitat de guanyar als companys o amics."
        },
        {
         "key": "e",
         "text": "És una aplicació que permet reforçar continguts escolars, especialment en llengües, a través d'activitats interactives."
        },
        {
         "key": "f",
         "text": "Es tracta d'una ferramenta de càlcul en format web i aplicació que et permetrà interactuar amb alumnes."
        },
        {
         "key": "g",
         "text": "És una ferramenta digital que facilita el seguiment de l'activitat de l'alumnat i la gestió de tasques dins de l'aula."
        },
        {
         "key": "h",
         "text": "Si no tens habilitats tecnològiques, esta ferramenta et permetrà crear ràpidament dissenys visuals en diversos formats."
        },
        {
         "key": "i",
         "text": "És una aplicació sense cost; l'idioma pot ser una barrera, però és fàcil de controlar."
        },
        {
         "key": "j",
         "text": "Amb esta aplicació podràs competir amb els altres a través de preguntes interactives que apareixen en vídeos."
        }
       ],
       "questions": [
        {
         "n": 25,
         "prompt": "Aloud és un programari que servix per a comunicar-se de manera eficaç i desenrotllar el llenguatge, òptim per a aquelles persones que no poden parlar o tenen dificultats en la parla. Augmenta les possibilitats d'interacció i comunicació de qui l'utilitza, tant en persones que ja usen símbols i volen desenrotllar el llenguatge com en aquelles que ja poden utilitzar el text i escriure. Este programa fa possible una interacció cara a cara, com a distància, independentment del nivell de llenguatge, ja que oferix una infinitat d'opcions avançades i vocabularis per a tots els nivells.",
         "answer": "c"
        },
        {
         "n": 26,
         "prompt": "Estapp és una ferramenta de disseny gràfic en línia que oferix als usuaris la possibilitat de crear fàcilment una àmplia varietat de materials visuals de manera intuïtiva i sense necessitat d'habilitats de disseny avançades. Esta aplicació web, també presentada en format App, proporciona plantilles personalitzables i una interfície d'usuari amigable, cosa que la convertix en una opció popular per a aquells que busquen dissenyar gràfics de manera ràpida i eficient. Amb Estapp, els usuaris poden crear una àmplia gamma d'elements visuals, com ara presentacions, cartells, targetes de presentació, publicacions en xarxes socials o fullets, entre altres.",
         "answer": "h"
        },
        {
         "n": 27,
         "prompt": "Ribcloud és una aplicació gratuïta educativa basada en el núvol que facilita la creació de lliçons interactives i la participació activa d'estudiants. Els professionals de l'educació que es creen un compte podran dissenyar presentacions multimèdia que inclouen qüestionaris, enquestes i diverses activitats, i promoure així un aprenentatge col·laboratiu i dinàmic. L'alumnat, en canvi, no necessita crear-se cap perfil i pot accedir al contingut a través d'un codi generat per l'autor del material. Es tracta també d'una ferramenta que només es presenta en anglés, però no es necessiten coneixements amplis de l'idioma ja que és prou intuïtiva.",
         "answer": "i"
        },
        {
         "n": 28,
         "prompt": "Mattex es presenta en format web i aplicació. És un programari de matemàtiques dinàmiques que abasta totes les àrees escolars de les matemàtiques amb enfocament de problemes de matemàtiques, gràfiques de funcions i equacions, combinacions amb geometria interactiva. Permet guardar i compartir els resultats personalitzats de l'alumnat, així com fer-ne un seguiment personalitzat. Entre les seues funcions destaquen la possibilitat de realitzar derivades, integrals, línies corbes amb gràfics, equacions, divisions... Una ferramenta fantàstica per a l'ús diari en l'aula i perquè l'alumnat faça pràctiques en casa amb l'ajuda de la família.",
         "answer": "f"
        },
        {
         "n": 29,
         "prompt": "La ferramenta Sap només es presenta en línia, i és una plataforma interactiva d'aprenentatge basada en jocs que s'ha tornat popular en entorns no només educatius sinó també empresarials. Esta aplicació proporciona una manera lúdica i participativa d'avaluar el coneixement. La característica central de Sap és la creació i realització de qüestionaris, enquestes i avaluacions interactives, coneguts com a “sabers”. Els usuaris, que poden ser estudiants, treballadors o participants en una reunió, responen a les preguntes en temps real utilitzant els seus dispositius mòbils o ordinadors. La puntuació es calcula segons la rapidesa i la precisió de les respostes, fet que crea una experiència competitiva i divertida.",
         "answer": "d"
        },
        {
         "n": 30,
         "prompt": "EnKaixa és una plataforma d'aprenentatge en línia que se centra en la creació i distribució de contingut educatiu interactiu a través de vídeos. Dissenyada principalment per a educadors i estudiants, esta aplicació web permet als docents personalitzar i millorar vídeos educatius amb elements interactius, com ara preguntes, comentaris i notes. Els usuaris d'EnKaixa poden seleccionar vídeos de diverses fonts, com YouTube o la seua pròpia biblioteca de vídeos, i després afegir capes d'interactivitat per a crear experiències d'aprenentatge més efectives. Els elements interactius poden incloure preguntes d'opció múltiple, preguntes obertes, comentaris de veu i anotacions que s'integren directament en el vídeo, i permet la participació mentres es veu el contingut.",
         "answer": "j"
        },
        {
         "n": 31,
         "prompt": "Esquemàtik és una aplicació utilitzada per a la creació de diagrames i esquemes visuals. La seua interfície permet als usuaris dissenyar diagrames de flux, organigrames, mapes mentals, diagrames de xarxes, entre altres. La ferramenta és compatible amb múltiples formats d'arxiu, cosa que facilita l'exportació i l'intercanvi dels diagrames creats. A més, permet la integració amb plataformes d'emmagatzematge en el núvol, facilitant la col·laboració en projectes en equip. Si treballes de forma cooperativa en el teu centre o la teua oficina, et facilitarà la interacció amb els companys. Però també és una bona ferramenta per a utilitzar-la com a tècnica d'estudi.",
         "answer": "a"
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
        "title": "Quan els Reis venien de Ciutat Vella",
        "paragraphs": [
         "Ara fa 60 anys, José Verdú Sanjuan va decidir obrir una jogueteria en el centre de València. Fart d'anar amunt i (0) avall amb el material que comercialitzava, este home originari d'Ibi (l'Alcoià) pensà que havia arribat l'hora d'establir-se en un lloc fix amb un negoci estable, d'aquells que tenen horari i persiana. És així com va nàixer Moñacos, el comerç de joguets més antic de la ciutat de València.",
         "L'establiment que hui perviu és regentat per José Vicente Verdú Barrachina, membre de la tercera generació familiar. Als Verdú els corren joguets per les venes i pareixen estar equipats amb piles alcalines en lloc de músculs. (32) ______ així s'entén la tenacitat (33) ______ mantenen en marxa un negoci que ha patit com pocs les urpes del capitalisme globaliste. En primer (34) ______, a causa de la deslocalització del producte, que va passar de tindre les poblacions d'Ibi i Onil (35) ______ quilòmetre zero a tindre el punt neuràlgic de fabricació en algun racó de l'Orient Llunyà. I en segon lloc, per l'auge de les grans cadenes i el comerç digital.",
         "Siga com siga, (36) ______ València, els Reis no venien de l'Orient, sinó de Ciutat Vella. Allà acudien cada Nadal els pares, les mares, els iaios o les iaies, a comprar els regals que els més menuts (37) ______ entusiasmats el 6 de gener de bon matí. La botiga central de Moñacos era un gran basar. Ubicada al costat del Teatre Olympia i envoltada de comerços tradicionals, el xamfrà de Sant Vicent amb el carrer de les Garrigues era sinònim de diversió. Centenars de milers de valencians quedaren embadalits, en un moment o algun altre, al passar per davant de la tenda.",
         "“Ara resulta impossible competir (38) ______ les grans superfícies i les plataformes de comerç electrònic”, lamenta el propietari. “El volum de negoci no té res a vore amb el d'abans”. Per això tracten de trobar el seu nínxol de mercat en joguets de preu baix, com ara nines i peluixos de 10 o 15 euros. Productes que la gent s'estima més de vore en persona.",
         "Els marges de benefici ja estan molt ajustats. A Moñacos, cada 5 de gener els costa més que (39) ______ els comptes. Hi ha cadenes i grans magatzems que venen els joguets al mateix preu que els adquirixen ells. Una batalla que tenen perduda... “La sort és que molts clients (40) ______ són per costum, (41) ______ venien amb els pares i els iaios”, diu José Vicente. Qui millor que ell per a aconseguir-los aquell joguet que no troben perquè en altres llocs s'ha exhaurit?"
        ]
       },
       "questions": [
        {
         "n": 32,
         "prompt": "Buit 32",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "No més"
          },
          {
           "key": "b",
           "text": "Només"
          },
          {
           "key": "c",
           "text": "Soles"
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
           "text": "amb la que"
          },
          {
           "key": "b",
           "text": "amb què"
          },
          {
           "key": "c",
           "text": "amb que"
          }
         ]
        },
        {
         "n": 34,
         "prompt": "Buit 34",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "terme"
          },
          {
           "key": "b",
           "text": "term"
          },
          {
           "key": "c",
           "text": "termini"
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
           "text": "com a"
          },
          {
           "key": "b",
           "text": "com"
          },
          {
           "key": "c",
           "text": "com a un"
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
           "text": "de"
          },
          {
           "key": "b",
           "text": "a"
          },
          {
           "key": "c",
           "text": "a la"
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
           "text": "obririen"
          },
          {
           "key": "b",
           "text": "obriren"
          },
          {
           "key": "c",
           "text": "obriran"
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
           "text": "amb"
          },
          {
           "key": "b",
           "text": "en"
          },
          {
           "key": "c",
           "text": "a"
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
           "text": "sortiren"
          },
          {
           "key": "b",
           "text": "ixen"
          },
          {
           "key": "c",
           "text": "isquen"
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
           "text": "ho"
          },
          {
           "key": "b",
           "text": "en"
          },
          {
           "key": "c",
           "text": "el"
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
           "text": "perquè"
          },
          {
           "key": "b",
           "text": "per què"
          },
          {
           "key": "c",
           "text": "per que"
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
        "title": "Quan els egipcis van deixar de treballar",
        "paragraphs": [
         "Quan volem protestar contra una situació injusta, a sovint decidim no anar a treballar per a reivindicar-nos. Però quan va passar això per primera vegada? Per a conéixer els detalls d'aquell fet (0) insòlit cal que viatgem més de tres mil anys arrere, a l'Antic Egipte.",
         "La primera (42) ______ de la història va tindre lloc durant el regnat del faraó Ramsés III, aproximadament, en l'any 1157 abans de Crist. Vaja, que ha plogut des de llavors!",
         "En el poblat de Set-Ma'at, ―que vol dir ‘el lloc de la veritat’, i que actualment es coneix com a Deir al-Madinah,― vivien cent vint artesans molt qualificats i les seues famílies. S'encarregaven de construir i decorar les tombes magnífiques dels faraons en la Vall dels Reis. Feien la faena en secret i (43) ______ de grans (44) ______ de seguretat per a desanimar la gent a furtar.",
         "Aquella (45) ______ treballava molt bé. De fet, eren els obrers més respectats i ben pagats de tot el país del Nil. Però va arribar una època de moltes (46) ______. Els egipcis van haver de fer front a uns enemics estrangers que volien conquistar sa casa. Van aconseguir derrotar-los, però la victòria els va eixir molt cara. Per si allò no fora prou, les (47) ______ no van ser bones i el preu del menjar va apujar moltíssim.",
         "Els problemes econòmics encara es van fer més grans perquè s'acostava una (48) ______ molt assenyalada: l'any següent se celebraria que feia trenta anys que Ramsés III era el faraó. El Heb Sed era el festival més important de tots, perquè servia per a renovar la força del faraó, i ja podeu imaginar-vos que els egipcis estiraven més el braç que la mànega.",
         "Enmig d'aquella situació tan difícil, els obrers de Set-Ma'at van deixar de rebre els sacs de gra que eren part del seu (49) ______. D'allò tenien molta culpa els oficials que els (50) ______ en nom del faraó, perquè alguns eren molt corruptes. Farts que els prengueren el pèl, els obrers van deixar d'anar a treballar, i així va començar tot!",
         "I com sabem tot això? Gràcies a l'escriba Amennakht, que va explicar els fets (51) ______ en un text que va escriure."
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
           "text": "vaga"
          },
          {
           "key": "b",
           "text": "baga"
          },
          {
           "key": "c",
           "text": "revetla"
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
           "text": "remenats"
          },
          {
           "key": "b",
           "text": "rodejats"
          },
          {
           "key": "c",
           "text": "regirats"
          }
         ]
        },
        {
         "n": 44,
         "prompt": "Buit 44",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "mides"
          },
          {
           "key": "b",
           "text": "mesures"
          },
          {
           "key": "c",
           "text": "medides"
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
           "text": "quadriga"
          },
          {
           "key": "b",
           "text": "gropa"
          },
          {
           "key": "c",
           "text": "colla"
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
           "text": "angoixes"
          },
          {
           "key": "b",
           "text": "fraules"
          },
          {
           "key": "c",
           "text": "angostes"
          }
         ]
        },
        {
         "n": 47,
         "prompt": "Buit 47",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "segades"
          },
          {
           "key": "b",
           "text": "segues"
          },
          {
           "key": "c",
           "text": "collites"
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
           "text": "data"
          },
          {
           "key": "b",
           "text": "dada"
          },
          {
           "key": "c",
           "text": "diada"
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
           "text": "saler"
          },
          {
           "key": "b",
           "text": "saldo"
          },
          {
           "key": "c",
           "text": "sou"
          }
         ]
        },
        {
         "n": 50,
         "prompt": "Buit 50",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "demanaven"
          },
          {
           "key": "b",
           "text": "manaven"
          },
          {
           "key": "c",
           "text": "encomanaven"
          }
         ]
        },
        {
         "n": 51,
         "prompt": "Buit 51",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "fil per randa"
          },
          {
           "key": "b",
           "text": "a la babalà"
          },
          {
           "key": "c",
           "text": "a tort i a dret"
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
         "text": "Cada vegada més jóvens decidixen compartir la seua vida amb un animal de companyia, com gossos o gats. El gran problema arriba a l'hora de trobar un pis de lloguer a on s'accepten animals, ja que molts propietaris consideren que poden ocasionar molèsties o desperfectes en la vivenda. Tens un animal de companyia i t'està costant trobar un pis per a llogar-lo. Encara que complixes tots els requisits, els propietaris et rebutgen argumentant que tens un gat com a animal de companyia. Per això, decidixes publicar una entrada en el teu blog personal per a denunciar esta problemàtica. En el teu escrit has d'incloure els punts següents:",
         "points": [
          "Explica el teu cas i les dificultats per a trobar pis amb el teu animal de companyia.",
          "Defén el dret a la vivenda de les persones que tenen animals de companyia.",
          "Proposa possibles solucions per a facilitar el lloguer en estos casos."
         ]
        },
        {
         "key": "B",
         "text": "En els últims anys s'ha començat a parlar de l'escriptura terapèutica com una ferramenta que pot potenciar el benestar emocional. L'escriptura es convertix en una activitat reflexiva a través de la qual explorem les nostres emocions, processem els pensaments i fem balanç de les nostres accions. T'has apuntat a un taller d'escriptura, i en la primera sessió t'han demanat que escrigues una carta al teu jo de 12 anys amb tota l'experiència i la saviesa de què hui en dia disposes. En el teu escrit has d'incloure els punts següents:",
         "points": [
          "Hi ha algunes coses que estan mitificades en la vida.",
          "En la vida trobaràs alguns obstacles.",
          "Les coses importants són les que no ho pareixen."
         ]
        }
       ]
      },
      {
       "n": 8,
       "kind": "writing",
       "title": "Entrada de blog",
       "instructions": "A pesar de tindre un clima mediterrani i viure estius calorosos, en els últims anys hem patit onades de calor intenses i amb temperatures extremes que poden posar en risc la salut de les persones. Has consultat la previsió de l'oratge, i has vist que en els pròxims dies vindrà una nova onada de calor. Basant-te en la infografia següent que has trobat en internet, i com que saps que este tema preocupa a moltes persones del teu entorn, decidixes escriure una entrada en el blog del centre social de la teua localitat en què dones diversos consells per a protegir-se i actuar amb responsabilitat durant estos dies. El text ha de tindre entre 120 i 140 paraules.",
       "min_words": 120,
       "max_words": 140,
       "image": "/exams/b2-octubre-2025/e8-onada-calor.jpg",
       "image_text": "Infografia «Que no t'arrossegue l'onada. Protegix-te de la calor» (#onadadecalor; Generalitat Valenciana, Conselleria de Sanitat), amb nou dibuixos. Consells: Fes exercici en les hores menys caloroses; Evita l'exposició directa al sol entre les 12 h i les 17 h; Utilitza cremes protectores adequades; No deixes a ningú en el cotxe, tampoc la teua mascota; Mantín la vivenda fresca i ventilada; Menja abundants ensalades, fruites i verdures; Protegix majors, menors i altres persones vulnerables; Beu aigua abundant si no tens contraindicació mèdica, evita l'alcohol i la cafeïna; Busca llocs frescos i a l'ombra."
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
         "title": "Monòleg · El silenci en la ciutat",
         "duration": "3 minuts",
         "intro": "Generalment, relacionem el silenci amb la tranquil·litat i el confort, però pareix que les persones que viuen en les ciutats han perdut el dret a tindre silenci: trànsit, obres, música, comerços, turistes… Per això, alguns ajuntaments han començat a crear espais silenciosos per la ciutat per a millorar el benestar de la ciutadania. Explica què et sembla esta mesura i si valores el silenci com una necessitat.",
         "questions": [],
         "images": []
        },
        {
         "title": "Monòleg · Viure en una furgoneta",
         "duration": "3 minuts",
         "intro": "El moviment van life s'ha convertit en una tendència entre els jóvens que volen explorar el món vivint en una furgoneta adaptada, el que es coneix com a càmper. Esta opció, poc habitual fa uns anys, és cada vegada més comuna. Raona si et sentiries còmode vivint pel món en una furgoneta i si el teu estil de vida encaixaria amb esta alternativa.",
         "questions": [],
         "images": []
        }
       ]
      },
      {
       "n": 10,
       "kind": "oral",
       "instructions": "Has de mantindre un diàleg amb un altre o una altra aspirant sobre la situació comunicativa que et proposem. Has de defendre el paper de la persona que et toque i has d'arribar a un acord obligatòriament amb l'altra persona. Has de participar com ho faries en una conversació habitual i les intervencions han de ser equilibrades. La duració de la conversació serà de quatre minuts, aproximadament.",
       "proposals": [
        {
         "title": "Diàleg · Ens apuntem a extraescolars?",
         "duration": "4 minuts",
         "intro": "Hui en dia molts xiquets acaben l'escola o bé a l'hora de dinar o bé a primera hora de la vesprada. En una cultura com la nostra, en què les vesprades s'allarguen molt, queden unes quantes hores perquè els xiquets les disfruten. Quan són adolescents o preadolescents ja tenen deures, però durant el període d'Infantil i els primers anys de Primària no hi ha a penes càrrega de faenes per a fer en casa.",
         "questions": [],
         "images": [],
         "roles": [
          {
           "name": "Persona A",
           "text": "Penses que, quan els xiquets són tan menuts, no necessiten tindre tasques programades, i que les vesprades són per a jugar, per a fer activitats no mediades pels adults, com passa en les extraescolars."
          },
          {
           "name": "Persona B",
           "text": "Penses que fer algunes activitats durant la setmana pot ser beneficiós per als xiquets, perquè els poden despertar curiositats, servixen per a socialitzar, per a estimular el moviment i també ajuden a la conciliació familiar."
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
