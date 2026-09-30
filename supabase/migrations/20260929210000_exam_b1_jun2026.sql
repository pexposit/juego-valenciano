-- Examen interactiu B1 de la JQCV (juny 2026) com a recurs de category 'examen'.
-- Contingut a metadata.exam; àudio de comprensió oral a url, convertit a MP3 des del
-- WAV oficial (frontend/public/audio/Audio_B1_jun2026.mp3). Font: https://jqcv.gva.es/documents/161863165/165492629/B1+juny+2026.pdf/7caaf06b-34da-e6fe-e781-fa439c7bcb83

INSERT INTO public.resources (id, name, type, url, content, metadata, xp_earned, difficulty, category)
SELECT id, name, type, url, content, metadata, xp_earned, difficulty, category
FROM jsonb_populate_record(NULL::public.resources, $data${
 "id": "b2728589-1320-53d8-b8e7-556c8ca5f84e",
 "name": "Simulacre B1: juny 2026",
 "type": "jqcv_b1_jun2026",
 "category": "examen",
 "difficulty": "intermedi",
 "xp_earned": 35,
 "url": "/audio/Audio_B1_jun2026.mp3",
 "content": "Examen oficial B1 de la JQCV (juny 2026): comprensió oral i escrita autocorregibles, redacció i pràctica oral.",
 "metadata": {
  "icon": "🎤",
  "color": "#F48FB1",
  "exam_body": "JQCV",
  "certificate_level": "B1",
  "exam": {
   "level": "B1",
   "session": "Juny 2026",
   "body": "JQCV",
   "source_url": "https://jqcv.gva.es/documents/161863165/165492629/B1+juny+2026.pdf/7caaf06b-34da-e6fe-e781-fa439c7bcb83",
   "audio_source_url": "https://jqcv.gva.es/documents/161863165/411134096/2026+06_B1_VF1.mp3/09832442-34b6-c1a5-84f6-4432daa79748",
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
         "prompt": "Cada text de 100 paraules escrit en ChatGPT equival a tindre 14 peretes led enceses una hora.",
         "answer": "V"
        },
        {
         "n": 2,
         "prompt": "Les imatges generades en estil japonés en abril de 2025 van consumir aproximadament 216 litres d'aigua.",
         "answer": "F"
        },
        {
         "n": 3,
         "prompt": "Encara no se sap amb certesa la xifra de litres d'aigua que es consumix en la generació de vídeos en ChatGPT.",
         "answer": "V"
        },
        {
         "n": 4,
         "prompt": "Un dels motius pels quals la IA consumix tanta aigua és perquè es necessiten sistemes de refrigeració amb aigua potable.",
         "answer": "V"
        },
        {
         "n": 5,
         "prompt": "Els centres de dades estan localitzats per tot el món, especialment a Dinamarca i als Estats Units.",
         "answer": "F"
        }
       ]
      },
      {
       "n": 2,
       "kind": "choice",
       "instructions": "Escolta l'entrevista a la cantant Naina i tria l'opció correcta. Només hi ha una resposta correcta per a cada enunciat. Llig els enunciats abans de fer l'activitat.",
       "questions": [
        {
         "n": 6,
         "prompt": "Com ha viscut la cantant la publicació del nou disc?",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "Contenta, encara que el disc no ha tingut la rebuda que esperava."
          },
          {
           "key": "b",
           "text": "Amb alegria, perquè ha superat les expectatives que tenia."
          },
          {
           "key": "c",
           "text": "Sorpresa, perquè l'èxit no ha sigut el que desitjava."
          }
         ]
        },
        {
         "n": 7,
         "prompt": "Per a Naina l'èxit és...",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "saber digerir els mals moments."
          },
          {
           "key": "b",
           "text": "fer el que ella vol amb la seua gent."
          },
          {
           "key": "c",
           "text": "estar feliç amb la seua gent."
          }
         ]
        },
        {
         "n": 8,
         "prompt": "La col·laboració amb La Fúmiga...",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "es va produir perquè ella sempre anava als concerts de la Fúmiga a primera fila."
          },
          {
           "key": "b",
           "text": "va començar quan Àrtur li va telefonar per a preguntar-li si volia col·laborar amb ells."
          },
          {
           "key": "c",
           "text": "la va deixar morta per l'excés de treball i gravacions que va implicar."
          }
         ]
        },
        {
         "n": 9,
         "prompt": "Com descriu l'artista el seu procés creatiu?",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "Sempre compon quan està en classe, ja que li ve la inspiració."
          },
          {
           "key": "b",
           "text": "En un horari planificat en sessions de composició amb el productor."
          },
          {
           "key": "c",
           "text": "La inspiració li sol vindre de repent i en qualsevol lloc."
          }
         ]
        },
        {
         "n": 10,
         "prompt": "La música de Naina...",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "fa que la gent de totes les edats s'identifique."
          },
          {
           "key": "b",
           "text": "no és recomanable si no tens emocions."
          },
          {
           "key": "c",
           "text": "és de l'estil de la música que ella escolta."
          }
         ]
        }
       ]
      },
      {
       "n": 3,
       "kind": "binary",
       "instructions": "Escoltaràs un fragment d'un programa de ràdio sobre la influència d'un bon ambient laboral en el benestar dels treballadors. Ordena els enunciats en el mateix orde en què els escoltes. Marca «No surt» en els dos enunciats que no apareixen en l'àudio i numera la resta de l'1 al 5.",
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
         "prompt": "És important millorar el benestar i reduir l'estrés.",
         "answer": "4"
        },
        {
         "n": 12,
         "prompt": "Treballar en altres empreses aporta noves idees.",
         "answer": "x"
        },
        {
         "n": 13,
         "prompt": "Si hi ha més motivació, el rendiment augmenta.",
         "answer": "1"
        },
        {
         "n": 14,
         "prompt": "Una bona imatge de l'empresa depén del bon ambient laboral.",
         "answer": "5"
        },
        {
         "n": 15,
         "prompt": "La comunicació reforça les amistats dins de l'empresa.",
         "answer": "x"
        },
        {
         "n": 16,
         "prompt": "Cal retindre el talent i reduir la rotació.",
         "answer": "2"
        },
        {
         "n": 17,
         "prompt": "La fluïdesa depén d'una bona comunicació laboral.",
         "answer": "3"
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
        "title": "L'art d'escriure a mà",
        "paragraphs": [
         "Primer va ser la màquina d'escriure; després, el teclat de l'ordinador, i més tard arribaren el mòbil i la tauleta. Per este motiu, hui en dia, escriure a mà sembla cosa del passat, i això que els beneficis són evidents. Segons la pedagoga Montse Modesto, esta pràctica «estimula l'activitat cerebral, perquè treballem l'àmbit visual, el motor i el cognitiu».",
         "Escriure a mà, igual que les operacions matemàtiques manuals, és una oportunitat que ens oferim a nosaltres mateixos, a través de les nostres mans, per a exercitar i estimular les neurones. La nostra capacitat de comprensió i assimilació, sumada a un procés més lent, troba, per tant, el seu aliat en una activitat tan simple, i alhora tan complexa, mil·lenària i universal, com l'escriptura.",
         "Este element beneficiós que proporciona l'escriptura manual es pot potenciar encara més, des de menuts, si utilitzem l'escriptura com a ferramenta de comunicació emocional, és a dir, com a vehicle d'expressió d'allò que naix dins d'u mateix amb la voluntat de ser compartit, i no com a exercici extern, mecànic i desconnectat. I això es rep, especialment, en l'escola.",
         "En alguns centres que busquen les últimes innovacions educatives no trobarem ordinadors ni tauletes electròniques per als alumnes; però sí, devoció per l'escriptura i la lectura. Trencant els tòpics, tampoc vorem classes convencionals amb files de taules i cadires davant d'un mestre i una pissarra. Cada xiquet aprén a escriure com ha aprés a caminar o a parlar: de manera autònoma i al seu temps.",
         "Esta pràctica a contracorrent, que valora l'escriptura a mà però que no imposa la tècnica ni els continguts de les redaccions, busca precisament potenciar tots els beneficis de l'escriptura sorgida des de dins. Com es pot cultivar este hàbit? Les veus expertes aposten per escriure un diari o, quan hem de fer llistes de treballs domèstics o de qualsevol altre tipus, fer-les a mà."
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
         "prompt": "Els que escriuen a mà hui en dia es consideren persones del passat.",
         "answer": "F"
        },
        {
         "n": 19,
         "prompt": "L'escriptura és una activitat senzilla i difícil que desperta la nostra ment.",
         "answer": "V"
        },
        {
         "n": 20,
         "prompt": "Escriure a mà ens ajuda a transmetre i compartir el que sentim.",
         "answer": "V"
        },
        {
         "n": 21,
         "prompt": "Segons el text, per a innovar en educació és necessari escriure en ordinadors o tauletes electròniques.",
         "answer": "F"
        },
        {
         "n": 22,
         "prompt": "Escriure a mà és un hàbit que cal aprendre de menuts; si no, és complicat fer-ho bé.",
         "answer": "F"
        }
       ]
      },
      {
       "n": 5,
       "kind": "match",
       "instructions": "Els experts en viatges d'una prestigiosa revista han elaborat una llista amb els llocs més especials per a visitar enguany. Llig les preferències de cada persona i tria el destí que millor s'adapte a cada una. Dos destins es quedaran sense emparellar.",
       "options_title": "Destins per a visitar enguany",
       "options": [
        {
         "key": "a",
         "text": "Muntanyes Rocoses (Canadà). Vols descobrir els prats alpins immaculats d'Alberta, al Canadà? Ara és possible fer-ho a bord d'un tren de luxe amb cúpules de vidre, plataformes d'observació a l'aire lliure i menjar de proximitat. Els viatgers poden desplaçar-se en qualsevol direcció durant dos dies, seguint rius sinuosos a través de serralades escarpades. Cascades, llacs i el pic més alt de les muntanyes Rocoses canadenques, el Mont Robson, de 3.972 metres, són alguns dels llocs d'interés."
        },
        {
         "key": "b",
         "text": "Snaefellsnes (Islàndia). El 12 d'agost els caçadors d'eclipsis podran disfrutar d'un eclipsi total de sol que travessarà l'oest d'Islàndia. Per a celebrar l'ocasió, el país acollirà el festival Iceland Eclipse, de quatre dies, a Snaefellsnes, amb DJ, balls i inclús alguns astronautes presents. El pròxim eclipsi solar total a Islàndia no tindrà lloc fins al 2196, fet que convertirà el d'este 2026 en un esdeveniment únic en la vida."
        },
        {
         "key": "c",
         "text": "Melbourne (Austràlia). La ciutat es prepara per a una altra fita de la F1: el debut d'un equip Cadillac, el primer equip nou en una dècada. Esta novetat convertix el Gran Premi d'Austràlia en un esdeveniment imprescindible per als addictes a la velocitat de tot el món. A més del circuit, la ciutat oferix carrers plens de cafeteries, el Queen Victoria Market ple de venedors i els Royal Botanic Gardens a la vora del riu, entre altres delícies."
        },
        {
         "key": "d",
         "text": "Zona de conservació del Ngorongoro (Tanzània). L'àrea de conservació de Ngorongoro, Patrimoni de la Humanitat per la UNESCO, al nord-est de Tanzània, que comprén planes altes, paisatges de sabana, boscos i selves, ha atret durant molt de temps viatgers al seu espectacular cràter, la caldera ininterrompuda més gran del món. A més, per la zona es poden vore rinoceronts negres, blancs, elefants, hipopòtams, búfals i flamencs en el seu hàbitat."
        },
        {
         "key": "e",
         "text": "Orà (Algèria). Coneguda com el bressol del rai, un gènere de música folklòrica algeriana dels anys vint, Orà està recuperant la seua posició com a centre de creativitat i vida nocturna. La ciutat, amb tossals que oferixen vistes panoràmiques sobre el Mediterrani, és una mescla de palaus otomans, fortaleses espanyoles i arquitectura colonial francesa. Hi ha també el recentment restaurat Théâtre Régional d'Orà, una joia arquitectònica centenària que oferix un programa d'espectacles contemporanis."
        },
        {
         "key": "f",
         "text": "Yunnan (Xina). Durant més d'un mil·lenni, fins a mitjans del segle XX una sèrie de camins, anomenats la Ruta dels Cavalls del Te, es van utilitzar per a exportar fulles de te al Tibet des de les províncies del sud de la Xina. Ara esta antiga ruta comercial del te troba una nova vida amb allotjaments moderns i un circuit per carretera pels pobles, cada un dels quals té especialitats culturals, artesanals i culinàries diferents."
        },
        {
         "key": "g",
         "text": "Illa de Camiguin (Filipines). L'illa és rica en gastronomia local i en patrimoni cultural, com ara un cementeri afonat, una visita a una granja ecològica i un festival de tardor en tota l'illa, dedicat a una fruita típica d'allí, anomenada lanzón. Però Camiguin és sobretot un destí per a aquells que els agrada l'aigua, amb cloïsses de la mida d'un cofre del tresor, una abundància de tortugues marines al voltant d'illots de bancs d'arena blanca, aigües termals i cascades."
        }
       ],
       "questions": [
        {
         "n": 23,
         "prompt": "Betlem Martí diu que només descansa sense soroll de trànsit ni edificis alts. Li agrada passar hores observant l'horitzó i esperar amb paciència fins que apareix algun moviment entre l'herba o prop de l'aigua. Sempre llig informació sobre projectes de protecció d'espècies i s'emociona quan pot vore animals que només coneixia pels documentals. No busca comoditats especials, sinó paisatges amplis i la sensació d'estar molt lluny de la vida urbana.",
         "answer": "d"
        },
        {
         "n": 24,
         "prompt": "Jordi Aliaga organitza les seues vacacions segons el calendari d'alguns esdeveniments internacionals que no es vol perdre. Li encanta l'ambient de competició i la velocitat, i sobretot disfruta quan molta gent de diferents països es reunix amb la mateixa il·lusió. Però no tot és l'esdeveniment: també li agrada passejar pels barris de la ciutat, visitar mercats tradicionals i descansar en parcs prop del riu amb un café en la mà.",
         "answer": "c"
        },
        {
         "n": 25,
         "prompt": "Mireia Torres planifica els seus viatges amb molta antelació. Fa mesos que parla d'una data que, segons ella, no tornarà a repetir-se en moltes generacions. Li agraden els paisatges dramàtics, formats fa milers d'anys, i no li importa si el clima és fresc o canviant. Sap que hi haurà molta gent compartint el mateix moment especial, però això no li molesta; al contrari, creu que farà l'experiència encara més intensa.",
         "answer": "b"
        },
        {
         "n": 26,
         "prompt": "Andrea Benavent s'estima més descobrir un territori a poc a poc, fent parades en diferents pobles. Li interessa conéixer les tradicions locals, tastar productes típics i parlar amb artesans sobre el seu treball. Té curiositat per les rutes antigues que connectaven regions llunyanes i que encara hui conserven vestigis del passat. Valora els allotjaments amb encant i l'experiència cultural per damunt de qualsevol luxe.",
         "answer": "f"
        },
        {
         "n": 27,
         "prompt": "Alexandre Ferris associa vacacions amb aigua. Sempre busca llocs a on puga combinar banys en entorns naturals amb experiències culturals pròpies del territori. Li agrada descobrir sabors nous i participar en celebracions locals si coincidixen amb el seu viatge. També sent curiositat per espais que han canviat amb el temps, especialment si tenen alguna història sorprenent relacionada amb la mar o amb la naturalesa.",
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
         "text": "Fent neteja de calaixos, has trobat una fotografia teua amb un company que va estudiar amb tu en la universitat. Fa anys que no en saps res, i t'agradaria reprendre el contacte, ja que féreu molt bona lliga durant l'etapa universitària. Decidixes escriure-li un correu electrònic per a saber què és de la seua vida i quedar per a tornar a vore-vos.",
         "points": [
          "Records de l'etapa universitària.",
          "Canvis en la teua vida.",
          "La teua vida actualment."
         ]
        },
        {
         "key": "B",
         "text": "La regidoria de festes del teu ajuntament ha obert un espai en la seua pàgina web en què oferix als veïns que proposen idees per a millorar les festes del poble. Penses que sí que podries fer algunes aportacions, i decidixes escriure una entrada en la pàgina web amb les teues suggerències.",
         "points": [
          "Quines activitats t'agraden més de les festes i per què.",
          "Quines activitats noves t'agradaria que es feren i per què.",
          "Quines mesures proposes per a reduir les molèsties ocasionades durant els actes festius."
         ]
        }
       ]
      },
      {
       "n": 7,
       "kind": "writing",
       "title": "Article «Vida saludable»",
       "instructions": "En l'empresa a on treballes han creat un butlletí per a millorar el benestar dels treballadors i compartir idees útils per al dia a dia. La direcció t'ha demanat que escrigues un article per a la secció «Vida saludable», en què expliques per què és important controlar l'estrés i proposes alguns consells o activitats per a reduir-lo. Tin en compte la informació que apareix en la imatge.",
       "min_words": 100,
       "max_words": 120,
       "image": "/exams/b1-juny-2026/e7-estres.jpg"
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
         "title": "Monòleg · Visita d'un amic",
         "duration": "3 minuts",
         "intro": "Un amic estranger amb qui vas mantindre una bona relació durant l'Erasmus ve a visitar-te este mes. Està molt comboiat perquè la seua estada coincidirà amb les festes del teu poble o ciutat. A tu també et fa molta il·lusió esta visita, i ja tens pensat què fareu. Li envies un missatge de veu per a mostrar-li el teu entusiasme, contar-li com són les festes i quins són els actes més importants.",
         "questions": [],
         "images": []
        },
        {
         "title": "Monòleg · Canvi d'entrades",
         "duration": "3 minuts",
         "intro": "Fa unes setmanes vas comprar unes entrades per a vore un espectacle. Però hui, comentant-ho amb la família, has vist que hi ha hagut un error, i que no podreu assistir el dia i l'hora indicats en les entrades. Telefona a l'empresa responsable de la venda i explica la situació. Demana si és possible modificar la reserva i indica clarament per a quina nova data i hora voldries fer el canvi.",
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
         "title": "Diàleg · Reorganització de l'espai",
         "duration": "4 minuts",
         "intro": "Tu i el teu company o companya treballeu en un centre educatiu a on hi ha un antic magatzem que està desaprofitat, i ara es vol reconvertir en un lloc útil per a l'alumnat.",
         "questions": [],
         "images": [],
         "roles": [
          {
           "name": "Persona A",
           "text": "Explica al teu company o a la teua companya que creus que la millor opció és fer una sala d'estudi tranquil·la perquè els alumnes que no tenen en casa un espai d'estudi puguen preparar exàmens, fer treballs en grup i aprofitar les hores mortes."
          },
          {
           "name": "Persona B",
           "text": "Explica al teu company o a la teua companya que creus que la millor opció és fer una sala de descans i convivència perquè els alumnes puguen usar-la per a fer activitats educatives informals, com ara tallers o jocs de taula, que fomenten la cohesió entre ells i creen vincles positius."
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
