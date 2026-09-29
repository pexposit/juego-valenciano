-- Examen interactiu B1 de la JQCV (octubre 2024) com a recurs de category 'examen'.
-- Contingut a metadata.exam; àudio de comprensió oral a url, convertit a MP3 des del
-- WAV oficial (frontend/public/audio/Audio_B1_oct2024.mp3). Font: https://jqcv.gva.es/documents/161863165/165492629/B1+octubre+2024.pdf/1cb10b50-e789-62fe-ce5c-8ab6e1bc4fda

INSERT INTO public.resources (id, name, type, url, content, metadata, xp_earned, difficulty, category)
SELECT id, name, type, url, content, metadata, xp_earned, difficulty, category
FROM jsonb_populate_record(NULL::public.resources, $data${
 "id": "ebd993cc-fde3-574c-98df-e274197ec683",
 "name": "Simulacre B1: octubre 2024",
 "type": "jqcv_b1_oct2024",
 "category": "examen",
 "difficulty": "intermedi",
 "xp_earned": 35,
 "url": "/audio/Audio_B1_oct2024.mp3",
 "content": "Examen oficial B1 de la JQCV (octubre 2024): comprensió oral i escrita autocorregibles, redacció i pràctica oral.",
 "metadata": {
  "icon": "👗",
  "color": "#FFE082",
  "exam_body": "JQCV",
  "certificate_level": "B1",
  "exam": {
   "level": "B1",
   "session": "Octubre 2024",
   "body": "JQCV",
   "source_url": "https://jqcv.gva.es/documents/161863165/165492629/B1+octubre+2024.pdf/1cb10b50-e789-62fe-ce5c-8ab6e1bc4fda",
   "audio_source_url": "https://jqcv.gva.es/documents/161863165/167041107/B1+octubre+2024.wav/43595b70-be19-eebb-8941-198ec72fd2eb",
   "pass_rule": "Per a ser APTE cal una puntuació global mínima de 60 sobre 100 i arribar al 50 % en cada una de les quatre àrees, que valen un 25 % cada una.",
   "areas": [
    {
     "n": 1,
     "title": "Comprensió oral",
     "weight": 25,
     "duration": "20 minuts",
     "audio": true,
     "intro": "Escoltaràs tres àudios dos vegades, amb una pausa d'un minut entre cada audició. Només hi ha una resposta correcta per a cada enunciat.",
     "exercises": [
      {
       "n": 1,
       "kind": "binary",
       "instructions": "Escolta l'àudio i contesta si les afirmacions són verdaderes (V) o falses (F). Llig els enunciats abans de fer l'activitat.",
       "options": [
        {
         "key": "V",
         "text": "Verdader"
        },
        {
         "key": "F",
         "text": "Fals"
        }
       ],
       "questions": [
        {
         "n": 1,
         "prompt": "La cronista, periodista i escriptora Rosario Raro va nàixer als Estats Units en 1908.",
         "answer": "F"
        },
        {
         "n": 2,
         "prompt": "L'espòs de Martha Gellhorn estava a favor que ella participara en el desembarcament com a reportera.",
         "answer": "F"
        },
        {
         "n": 3,
         "prompt": "Va ser difícil arribar a primera línia de combat entre una quantitat considerable d'hòmens.",
         "answer": "V"
        },
        {
         "n": 4,
         "prompt": "Les dones periodistes eren acceptades sense problemes en l'operació militar.",
         "answer": "F"
        },
        {
         "n": 5,
         "prompt": "El reportatge de Martha en què es parlava de l'operació militar es va publicar en uns pocs mesos.",
         "answer": "V"
        }
       ]
      },
      {
       "n": 2,
       "kind": "choice",
       "instructions": "Escolta l'entrevista a l'experta de moda Eugenia López-Fonta i tria l'opció correcta. Només hi ha una resposta correcta per a cada enunciat. Llig els enunciats abans de fer l'activitat.",
       "questions": [
        {
         "n": 6,
         "prompt": "Les peces de roba d'última moda...",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "són diferents en cada temporada."
          },
          {
           "key": "b",
           "text": "haurien d'ocupar el gros del nostre armari."
          },
          {
           "key": "c",
           "text": "es basen en peces minimalistes i essencials."
          }
         ]
        },
        {
         "n": 7,
         "prompt": "Tindre camisetes o pantalons bàsics en el nostre armari...",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "contribuïx a reduir la compra de roba."
          },
          {
           "key": "b",
           "text": "és avorrit i no dona lloc a la diversitat."
          },
          {
           "key": "c",
           "text": "passa de moda molt ràpidament."
          }
         ]
        },
        {
         "n": 8,
         "prompt": "Si volem cuidar el medi ambient...",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "hauríem de fer cas de les tendències de moda."
          },
          {
           "key": "b",
           "text": "hauríem de comprar menys peces bàsiques."
          },
          {
           "key": "c",
           "text": "hauríem d'adquirir roba que no ens canse."
          }
         ]
        },
        {
         "n": 9,
         "prompt": "Eugenia López-Fonta opina que...",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "els pantalons vaquers amples són sinònim de comoditat."
          },
          {
           "key": "b",
           "text": "els pantalons vaquers amples són la moda de la nova temporada."
          },
          {
           "key": "c",
           "text": "els pantalons vaquers ajustats amb sabatilles són tendència."
          }
         ]
        },
        {
         "n": 10,
         "prompt": "El verd oliva és...",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "un color que va predominar la temporada passada."
          },
          {
           "key": "b",
           "text": "el color de moda d'esta temporada."
          },
          {
           "key": "c",
           "text": "un color que hem de combinar amb altres."
          }
         ]
        }
       ]
      },
      {
       "n": 3,
       "kind": "binary",
       "instructions": "Escoltaràs un fragment d'un programa de ràdio sobre Milagros, la dona valenciana de cent anys protagonista d'un pòdcast. Ordena els enunciats en el mateix orde en què els escoltes. Marca «No surt» en els dos enunciats que no apareixen en l'àudio i numera la resta de l'1 al 5.",
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
         "n": 11,
         "prompt": "La lectura va ser durant tota la vida la passió de Milagros.",
         "answer": "4"
        },
        {
         "n": 12,
         "prompt": "Els fills de Milagros estan molt feliços amb este projecte tan bonic.",
         "answer": "x"
        },
        {
         "n": 13,
         "prompt": "Milagros ajuda els altres a través del seu pòdcast a arribar als cent anys.",
         "answer": "1"
        },
        {
         "n": 14,
         "prompt": "El que fa la protagonista del pòdcast té beneficis cognitius per a les persones majors.",
         "answer": "3"
        },
        {
         "n": 15,
         "prompt": "El pòdcast de Milagros es pot escoltar en la ràdio i també en internet.",
         "answer": "5"
        },
        {
         "n": 16,
         "prompt": "Milagros està perdent la memòria i no recorda els llibres que va llegir.",
         "answer": "x"
        },
        {
         "n": 17,
         "prompt": "Milagros, amb dos companys més de la residència, conten la seua vida.",
         "answer": "2"
        }
       ]
      }
     ]
    },
    {
     "n": 2,
     "title": "Comprensió escrita",
     "weight": 25,
     "duration": "1 h 50 min (amb l'àrea 3)",
     "exercises": [
      {
       "n": 4,
       "kind": "binary",
       "instructions": "Llig atentament el text i contesta si les afirmacions són verdaderes (V) o falses (F).",
       "reading": {
        "title": "Fer el gos en el llit: un hàbit recomanable o una pèrdua de temps?",
        "paragraphs": [
         "Quan la casa està gelada i fora encara regna la foscor, pareix raonable disfrutar d'uns minuts extres en el llit. En xarxes socials, alguns usuaris han batejat esta acollidora tendència matutina amb el nom de hurkle-durkling, en referència a una antiga frase escocesa per a passar el temps desperts entre llençols. Tant si vols arropir-te baix de les mantes, com si vols quedar-te pensant en el dia que t'espera, esta tendència és un recordatori que està bé reclamar un poc de temps de no fer res.",
         "Segons Eleanor McGlinchey, psicòloga especialitzada en el son, quedar-se en el llit després de despertar-se ens atrau perquè anhelem esta sensació que estem decidint alguna cosa intencionadament. Igual que, a vegades, retardem l'hora d'anar a dormir, per a compensar les hores que hem passat treballant o cuidant altres persones durant el dia, fer el gos en el llit és avançar este temps «per a mi» abans que ens inunden les responsabilitats del dia.",
         "No obstant, per a aquells que practiquen este hàbit als matins, és important posar límits. El temps de qualitat per a u mateix pot convertir-se en perjudicial, com perdre una hora sense sentit o inclús més temps en les xarxes socials. «Per a algunes persones, agarrar el telèfon i revisar el correu electrònic mentres estan en el llit fa que s'estressen més», declara Eleanor McGlinchey.",
         "Així, els experts recomanen pensar bé amb antelació com vols passar els teus minuts lliures en el llit. És important decidir com comença el teu dia. Però dona't un cert marge de temps. No hi ha una regla fixa sobre quant de temps és massa per a descansar baix dels llençols després de despertar-se, però si això ocorre diàriament, entre 15 i 30 minuts haurien de ser suficients per a la majoria de les persones."
        ]
       },
       "options": [
        {
         "key": "V",
         "text": "Verdader"
        },
        {
         "key": "F",
         "text": "Fals"
        }
       ],
       "questions": [
        {
         "n": 18,
         "prompt": "És comú i normal voler estar en el llit quan fa fred i la llum del dia encara no ha entrat en casa.",
         "answer": "V"
        },
        {
         "n": 19,
         "prompt": "Segons McGlinchey, quedar-se en el llit després de despertar-se compensa el temps invertit en altres activitats durant el dia.",
         "answer": "F"
        },
        {
         "n": 20,
         "prompt": "Cada u pot passar tant de temps en el llit com necessite; en tots els casos és positiu.",
         "answer": "F"
        },
        {
         "n": 21,
         "prompt": "Segons McGlinchey, revisar el correu electrònic mentres s'està en el llit pot ser relaxant per a algunes persones.",
         "answer": "F"
        },
        {
         "n": 22,
         "prompt": "Els experts suggerixen que estar entre 15 i 30 minuts en el llit després de despertar-se sol ser suficient per a la majoria de les persones.",
         "answer": "V"
        }
       ]
      },
      {
       "n": 5,
       "kind": "match",
       "instructions": "Una immobiliària oferix diferents tipus de cases. Llig les preferències de cada persona i tria la vivenda que millor s'adapte a cada una. Dos persones es quedaran sense emparellar.",
       "options_title": "Preferències de les persones",
       "options": [
        {
         "key": "a",
         "text": "Ester Anduix. Ester i el seu marit estaven esperant amb candeleta la jubilació, i esta, per fi, ha arribat. Deixar de banda la vida estressant de la ciutat i anar a viure al poble ha sigut la seua meta després de tindre els fills independitzats. Això sí, voldrien estar prop de València per a poder visitar amics i familiars i tindre una gran terrassa per a ajuntar-se."
        },
        {
         "key": "b",
         "text": "Roser Boronat. Roser és mare a temps complet. La seua parella treballa tot el dia, i ella, amb tres xiquets menuts, necessita viure en una zona a on hi haja de tot i que estiga a l'abast. Una casa que tinga alguna zona en què els xiquets puguen distraure's seria una benedicció per a ella, ja que això de socialitzar amb la resta de mares en el parc no li abellix gens."
        },
        {
         "key": "c",
         "text": "Raül Ferrer. Raül viu amb la seua parella en el barri de Benimaclet, però treballa en l'Ajuntament de València, en ple centre, i és un maldecap haver d'anar a la faena cada dia en cotxe. La tranquil·litat de viure en un barri perifèric és un avantatge, però el fet de no haver d'agarrar el cotxe per a res és encara millor. Per tant, necessiten canviar-se a un pis i, si pot ser, amb bones vistes."
        },
        {
         "key": "d",
         "text": "Maria Ricard. Maria és una jove que, gràcies que ha estalviat durant dos anys, ara ja té diners per a poder pagar l'entrada de la compra d'un pis. No vol res massa gran, ja que pretén viure sola. Així que amb un dormitori en té prou. Només demana que esta vivenda no estiga en una planta molt alta perquè té vertigen."
        },
        {
         "key": "e",
         "text": "Joan Torregrossa. Joan treballa en una empresa de moda creant col·leccions de complements per a home. Després de la pandèmia està més temps en casa treballant en línia que en l'estudi de l'empresa, i voldria poder disfrutar d'un pis amb terrassa i molta llum. També demana espai per a tota la roba que té, que n'és molta."
        },
        {
         "key": "f",
         "text": "Jaume Doménech. Jaume és un home d'edat avançada que viu a soles en un mas als afores de València. L'augment de perímetre de la ciutat any rere any ha fet que cada volta se sentira més invadit per la nova construcció. Per això, no ha tingut més remei que vendre el terreny a una empresa de construcció. Amb els diners que en traga vol comprar un pis que tinga prop un hortet urbà per a entretindre's."
        },
        {
         "key": "g",
         "text": "Frederic Moltó. Frederic, un emprenedor sense problemes de diners, vol muntar un hotel rural prop de València. Pretén que la gent que visite el seu establiment visca la vida rural sense haver d'anar molt lluny. Serviria menjar casolà i tradicional, amb productes de quilòmetre zero de collita pròpia."
        }
       ],
       "questions": [
        {
         "n": 23,
         "prompt": "Pis en un edifici. Situat en un dels carrers més cèntrics de València, a només cinc minuts a peu de tot el que pugues necessitar, tenim un pis de 100 metres, amb dos dormitoris, dos banys complets i amb una cuina i un menjador integrats en una mateixa habitació. Les vistes ens permeten vore gran part de la ciutat, perquè es troba a una altura considerable.",
         "answer": "c"
        },
        {
         "n": 24,
         "prompt": "Casa de poble. A cinc minuts de València en tren, tenim una casa de poble de dos altures. Compta amb tres habitacions, una de les quals es troba en la planta baixa, i dos banys, un en cada planta. El menjador connecta amb la cuina i amb una terrassa de 20 metres a on poder eixir a prendre la fresca en les nits d'estiu.",
         "answer": "a"
        },
        {
         "n": 25,
         "prompt": "Àtic. En la desena planta d'un edifici emblemàtic de la perifèria de València, tenim un àtic molt lluminós i complet. Compta amb una habitació amb vestidor, un bany complet i un menjador-cuina que dona pas a una terrassa espectacular de 40 metres, a on poder passar vetlades especials amb els amics.",
         "answer": "e"
        },
        {
         "n": 26,
         "prompt": "Unifamiliar. En una zona apartada del rebombori de la gran ciutat es troba una urbanització de luxe que compta amb tots els servicis que vos pugueu imaginar. Les cases unifamiliars que hi ha són de tres plantes, amb quatre habitacions i tres banys. Cada planta està dedicada a un menester, però sobretot destaca la baixa, que connecta directament amb un jardí a on poden jugar tranquil·lament els xiquets.",
         "answer": "b"
        },
        {
         "n": 27,
         "prompt": "Casa de camp. A 15 km en cotxe de València tenim una casa de camp que no forma part de cap urbanització. Es tracta d'un mas rehabilitat amb totes les comoditats imaginables. Disposa de sis habitacions, quatre banys i tres tipus d'estances diferents per a menjar, reunir-se o llegir. També té un hortet menut però molt complet, a on poder fer els cultius propis.",
         "answer": "g"
        }
       ]
      }
     ]
    },
    {
     "n": 3,
     "title": "Expressió i interacció escrites",
     "weight": 25,
     "duration": "1 h 50 min (amb l'àrea 2)",
     "exercises": [
      {
       "n": 6,
       "kind": "writing",
       "title": "Redacció",
       "instructions": "Tria una de les dos opcions i redacta un text que tinga entre 150 i 170 paraules.",
       "min_words": 150,
       "max_words": 170,
       "choices": [
        {
         "key": "A",
         "text": "Tens un amic de la infància que ara viu en un altre país. Escriu-li un correu electrònic en què li expliques els teus plans de futur, incloent-hi les teues metes professionals, personals i qualsevol altre projecte important que tingues en ment.",
         "points": [
          "Parla sobre els teus objectius personals.",
          "Esmenta els teus plans professionals.",
          "Explica per què estos plans són importants per a tu."
         ]
        },
        {
         "key": "B",
         "text": "Eres una persona apassionada per les activitats recreatives, i vols compartir la importància de fer-ne alguna, com ara practicar algun esport, jardineria, fotografia, gastronomia, balls de saló, clubs de lectura..., per a millorar la qualitat de vida. Escriu una entrada en el teu blog per a destacar els beneficis de les activitats recreatives i motivar els teus lectors a incorporar-les en la seua rutina diària.",
         "points": [
          "Explica la importància de mantindre un equilibri entre el treball i l'oci.",
          "Comenta els beneficis mentals que comporta (millora de l'estat d'ànim, reducció de l'estrés...).",
          "Parla dels beneficis socials que pot reportar (oportunitat de conéixer noves persones, reforçar relacions existents...)."
         ]
        }
       ]
      },
      {
       "n": 7,
       "kind": "writing",
       "title": "Correu als empleats",
       "instructions": "Eres l'encarregat de recursos humans en la teua empresa i vols fomentar una cultura d'estalvi d'aigua entre els treballadors. Escriu un correu electrònic a tots els empleats en què expliques per què és important estalviar aigua en el lloc de treball i suggerisques algunes mesures concretes que poden adoptar per a contribuir a la consecució d'este objectiu. Tin en compte la informació que apareix en la imatge.",
       "min_words": 100,
       "max_words": 120,
       "image": "/exams/b1-octubre-2024/e7-aigua.jpg"
      }
     ]
    },
    {
     "n": 4,
     "title": "Expressió i interacció orals",
     "weight": 25,
     "duration": "25 minuts",
     "intro": "Esta àrea té dos parts: un monòleg d'uns tres minuts sobre una situació que tries i un diàleg d'uns quatre minuts amb una altra persona aspirant, en què cal arribar a un acord.",
     "exercises": [
      {
       "n": 8,
       "kind": "oral",
       "instructions": "Tria una de les dos propostes i prepara un monòleg de tres minuts, aproximadament.",
       "proposals": [
        {
         "title": "Monòleg · Vida quotidiana",
         "duration": "3 minuts",
         "intro": "Has rebut un paquet amb un article (pots usar el que tu vullgues) que vas demanar en línia i ha arribat en males condicions. A més, el contingut també està danyat, i no funciona. Telefona a atenció al client de l'empresa a on el vas comprar, explica el que ha passat i reclama'ls una indemnització.",
         "questions": [],
         "images": []
        },
        {
         "title": "Monòleg · Activitats a l'aire lliure",
         "duration": "3 minuts",
         "intro": "La teua filla ja té l'edat mínima per a anar de campament amb els scouts este estiu. A tu això et preocupa, com és natural, perquè faran activitats en la muntanya, i patixes per si té algun accident. Explica-li quins passos hauria de seguir en el cas que així fora i, al mateix temps, intenta tranquil·litzar-la.",
         "questions": [],
         "images": []
        }
       ]
      },
      {
       "n": 9,
       "kind": "oral",
       "instructions": "Mantín un diàleg amb una altra persona aspirant. Defén el paper de la teua persona i arribeu obligatòriament a un acord. Participa com en una conversa habitual: les intervencions han de ser equilibrades.",
       "proposals": [
        {
         "title": "Diàleg · Convivència",
         "duration": "4 minuts",
         "intro": "La teua amiga i tu compartiu un apartament per a estudiants prop de la universitat a on estudieu. Però, com que teniu lloc i necessiteu diners, heu pensat que podria entrar a conviure amb vosaltres una altra persona més.",
         "questions": [],
         "images": [],
         "roles": [
          {
           "name": "Persona A",
           "text": "Tu tens una candidata clara i la vols proposar. Explica quines són les seues característiques a la teua companya (persona B) i intenta convéncer-la que és la idònia."
          },
          {
           "name": "Persona B",
           "text": "Tu tens una candidata clara i la vols proposar. Explica quines són les seues característiques a la teua companya (persona A) i intenta convéncer-la que és la idònia."
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
