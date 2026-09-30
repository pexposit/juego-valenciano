-- Examen interactiu B1 de la JQCV (octubre 2025) com a recurs de category 'examen'.
-- Contingut a metadata.exam; àudio de comprensió oral a url, convertit a MP3 des del
-- WAV oficial (frontend/public/audio/Audio_B1_oct2025.mp3). Font: https://jqcv.gva.es/documents/161863165/165492629/B1+octubre+2025.pdf/247b33d1-18e6-a25c-11f9-f7467e48520f

INSERT INTO public.resources (id, name, type, url, content, metadata, xp_earned, difficulty, category)
SELECT id, name, type, url, content, metadata, xp_earned, difficulty, category
FROM jsonb_populate_record(NULL::public.resources, $data${
 "id": "088c65fa-ea6c-5bd4-a1da-6e4e6624b110",
 "name": "Simulacre B1: octubre 2025",
 "type": "jqcv_b1_oct2025",
 "category": "examen",
 "difficulty": "intermedi",
 "xp_earned": 35,
 "url": "/audio/Audio_B1_oct2025.mp3",
 "content": "Examen oficial B1 de la JQCV (octubre 2025): comprensió oral i escrita autocorregibles, redacció i pràctica oral.",
 "metadata": {
  "icon": "🧘",
  "color": "#A5D6A7",
  "exam_body": "JQCV",
  "certificate_level": "B1",
  "exam": {
   "level": "B1",
   "session": "Octubre 2025",
   "body": "JQCV",
   "source_url": "https://jqcv.gva.es/documents/161863165/165492629/B1+octubre+2025.pdf/247b33d1-18e6-a25c-11f9-f7467e48520f",
   "audio_source_url": "https://jqcv.gva.es/documents/161863165/167041107/NIVELL_B1_48KH_24BITS.wav/a511439b-4d19-f474-8396-328ab80a1e8f",
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
       "instructions": "Escolta l'àudio i digues si les afirmacions són verdaderes (V) o falses (F). Llig els enunciats abans de fer l'activitat.",
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
         "prompt": "A Vicent Cabanes li va transmetre la passió per teixir el seu germà.",
         "answer": "F"
        },
        {
         "n": 2,
         "prompt": "En el negoci dels germans només es tixen mantes bocairentines.",
         "answer": "F"
        },
        {
         "n": 3,
         "prompt": "Cabanes pensa que s'ha d'ensenyar l'ofici de teixir i la gestió d'un negoci tradicional.",
         "answer": "V"
        },
        {
         "n": 4,
         "prompt": "La manta morellana és igual per les dos cares.",
         "answer": "V"
        },
        {
         "n": 5,
         "prompt": "Segons el mestre teixidor, una manta es tix en dos setmanes.",
         "answer": "F"
        }
       ]
      },
      {
       "n": 2,
       "kind": "choice",
       "instructions": "Escolta l'entrevista a la professora de ioga Xuan Lan i tria l'opció correcta. Només hi ha una resposta correcta per a cada enunciat. Llig els enunciats abans de fer l'activitat.",
       "questions": [
        {
         "n": 6,
         "prompt": "La raó principal per la qual Xuan Lan se n'anà a Nova York va ser...",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "per a estudiar la carrera d'Economia."
          },
          {
           "key": "b",
           "text": "per l'encant que té Nova York."
          },
          {
           "key": "c",
           "text": "per a escapar de la pressió familiar."
          }
         ]
        },
        {
         "n": 7,
         "prompt": "Xuan Lan va connectar amb el ioga...",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "quan va fer el viatge a l'Índia."
          },
          {
           "key": "b",
           "text": "després de provar diverses disciplines."
          },
          {
           "key": "c",
           "text": "durant el temps que va viure a Nova York."
          }
         ]
        },
        {
         "n": 8,
         "prompt": "Quina de les tres definicions descriuria millor els beneficis del ioga?",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "És una disciplina que millora l'estat físic."
          },
          {
           "key": "b",
           "text": "És una disciplina que millora la ment i cansa."
          },
          {
           "key": "c",
           "text": "És una disciplina que repetixes quan la proves."
          }
         ]
        },
        {
         "n": 9,
         "prompt": "Què va fer que Xuan Lan es dedicara únicament al ioga?",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "La faena que tenia no li agradava."
          },
          {
           "key": "b",
           "text": "Reflexionar després dels consells d'un amic."
          },
          {
           "key": "c",
           "text": "S'arrastrava cada dia per anar al treball."
          }
         ]
        },
        {
         "n": 10,
         "prompt": "Per a Xuan Lan...",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "quan no s'està a gust s'ha de deixar la faena."
          },
          {
           "key": "b",
           "text": "no podem deixar el treball perquè ens dona diners."
          },
          {
           "key": "c",
           "text": "abans de fer canvis s'ha de pensar molt bé."
          }
         ]
        }
       ]
      },
      {
       "n": 3,
       "kind": "binary",
       "instructions": "Escoltaràs un fragment d'un programa de ràdio sobre Tere, l'atleta de 88 anys que inspira. Ordena els enunciats en el mateix orde en què els escoltes. Marca «No surt» en els dos enunciats que no apareixen en l'àudio i numera la resta de l'1 al 5.",
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
         "prompt": "Tere és l'exemple que els anys no són un límit per a estar actiu i en forma.",
         "answer": "5"
        },
        {
         "n": 12,
         "prompt": "Els dissabtes i els diumenges Tere ix amb les amigues per a desconnectar del gimnàs.",
         "answer": "x"
        },
        {
         "n": 13,
         "prompt": "L'entrenador de Tere és el seu net, que es mostra molt orgullós de la seua iaia.",
         "answer": "3"
        },
        {
         "n": 14,
         "prompt": "Tere continuarà anant al gimnàs mentres continue l'èxit en les xarxes socials.",
         "answer": "x"
        },
        {
         "n": 15,
         "prompt": "Tere s'ha fet viral després que un vídeo seu apareguera en les xarxes d'À Punt.",
         "answer": "1"
        },
        {
         "n": 16,
         "prompt": "A banda d'anar al gimnàs, Tere camina cada dia entre una hora i hora i mitja.",
         "answer": "4"
        },
        {
         "n": 17,
         "prompt": "Tere es dedica a entrenar-se quatre dies a la setmana, de dilluns a dijous.",
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
       "instructions": "Llig atentament el text i digues si les afirmacions són verdaderes (V) o falses (F).",
       "reading": {
        "title": "La cuina medieval valenciana",
        "paragraphs": [
         "Plats molt allunyats dels gustos culinaris actuals, alguns amb molt de sucre i amb una quinzena d'espècies, però també uns altres que continuen en les nostres taules, com les natilles o els bunyols de formatge. Així es desprén d'un estudi revelat per una investigadora castellonenca del receptari de cuina més antic que es conserva en la península Ibèrica, de 700 anys d'antiguitat, i que, a més, està escrit en valencià: El llibre de Sent Soví.",
         "Una de les receptes més cridaneres és el pollastre amb sucre, que pot recordar, segons la investigadora de Sant Mateu, la combinació de sabors de la mostassa i la mel, present en la gastronomia actual.",
         "Així, en esta exposició, per primera vegada s'exhibixen 72 receptes de gastronomia medieval en què, per raons òbvies, no hi havia dacsa ni creïlla. La mostra fa un repàs d'utensilis, manuals i ingredients d'esta cuina pensada per a alimentar els rics. Segons explicà l'autora en una entrevista recent, «a finals del segle XIII i principis del XIV es reprenen els receptaris perquè la noblesa no estava tan preocupada per menjar molt, sinó per menjar bé».",
         "En el rebost d'una cuina noble del segle XIV, per exemple, el pa, el vi i l'oli eren l'essència. La carn, el peix i el formatge, la base d'un menú medieval en què la diferència social la marcava la forma de cocció i l'ús d'espècies portades d'Orient. Tot això ho sabem gràcies a este receptari gastronòmic escrit en valencià, i que veu la llum pública per primera vegada.",
         "Finalment, l'exposició dedica una part als utensilis necessaris en la taula, a on el visitant podrà vore des de gots de vidre fins a la primera forqueta de la Península, que es va fer a València, com puntualitzava l'experta en història medieval."
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
         "prompt": "Hi ha alguns plats medievals amb moltes espècies que han sobreviscut en la cuina actual valenciana.",
         "answer": "F"
        },
        {
         "n": 19,
         "prompt": "La combinació de dolç i salat era completament desconeguda en la gastronomia medieval valenciana.",
         "answer": "F"
        },
        {
         "n": 20,
         "prompt": "Les receptes exposades mostren una cuina orientada al gust refinat de la noblesa més que a l'alimentació abundant.",
         "answer": "V"
        },
        {
         "n": 21,
         "prompt": "El tipus de cocció i la quantitat d'espècies emprades ajudaven a distingir l'estatus social en la taula medieval.",
         "answer": "V"
        },
        {
         "n": 22,
         "prompt": "Entre els utensilis es mostra la primera forqueta que es coneix en el món, segons l'experta en història medieval.",
         "answer": "F"
        }
       ]
      },
      {
       "n": 5,
       "kind": "match",
       "instructions": "Una agència oferix diferents opcions d'oci. Llig les preferències de cada persona i tria l'activitat que millor s'adapte a cada una. Dos activitats es quedaran sense emparellar.",
       "options_title": "Opcions d'oci",
       "options": [
        {
         "key": "a",
         "text": "Spa: Si busques un espai a on silenciar la ment, no et pots perdre l'experiència del nostre spa. Està situat en un espai natural a on el silenci només és interromput pel soroll de les aus autòctones. Podràs disfrutar de les aigües termals del riu Millars. A més, oferim una àmplia gamma de massatges corporals per a ajudar a combatre l'estrés i la tensió."
        },
        {
         "key": "b",
         "text": "Safari: Si t'agraden els animals en el seu hàbitat natural, has de visitar el Safari d'Aitana. Esta reserva natural, situada a 1.000 metres d'altitud i amb una extensió de 1.500.000 m², concentra animals salvatges dels cinc continents. És un espai per a passar un bon dia amb la família o els amics."
        },
        {
         "key": "c",
         "text": "Platja: Per als amants de la mar, t'oferim una platja emblemàtica situada entre les localitats d'Alcalà de Xivert i Alcossebre: la platja de les Fonts. Un espai natural amb vistes a la muntanya i aigua dolça que brolla per l'arena fina dels més de 400 metres de costa. Si el que busques és passar un bon dia amb la família, esta és, sens dubte, una bona opció."
        },
        {
         "key": "d",
         "text": "Museus: Per als amants de la història i la cultura t'oferim una visita al museu del Palau Borrull. A banda de conservar una àmplia col·lecció d'art i objectes històrics que narren el passat de Sant Mateu, compta amb exposicions temporals i permanents i també organitza esdeveniments culturals."
        },
        {
         "key": "e",
         "text": "Senderisme/bici: Una activitat que es pot combinar a peu i en bicicleta és la Via Verda del Xitxarra. Es tracta d'un recorregut de 15 kilòmetres en ple contacte amb la naturalesa, des del santuari de les Virtuts fins a Biar. Esta ruta, a més, és accessible i es pot fer amb cadira de rodes."
        },
        {
         "key": "f",
         "text": "Esport de risc i aventura: Si t'agrada l'adrenalina, en AdrePont t'oferim tot un ventall d'activitats de risc. Una de les opcions més reclamades és el pònting, un salt en vertical des de més de 50 metres d'altura. També podràs disfrutar d'un descens per les aigües més ràpides amb una llanxa pneumàtica."
        },
        {
         "key": "g",
         "text": "Experiència gastronòmica: Esta experiència et garantix la possibilitat d'estimular els cinc sentits a través del menjar, el gust, l'olfacte, la vista, l'oïda i el cervell. Es tracta d'un viatge complet des de l'entrada fins a l'eixida del restaurant, un viatge que et farà descobrir tots els secrets que es poden amagar en la cuina."
        }
       ],
       "questions": [
        {
         "n": 23,
         "prompt": "Leo Esteve treballa en una empresa familiar agrària. La maquinària que utilitza diàriament és molt sorollosa: tractors, segadores, serres de motor... Li agraden els treballs extrems com podar arbres de sis metres d'altura. Però quan té temps lliure busca desestressar-se, tranquil·litat i relaxació.",
         "answer": "a"
        },
        {
         "n": 24,
         "prompt": "Paola Pardo és una jove esportista a qui li agrada molt el futbol. És molt activa i li costa estar-se quieta i relaxar-se. El descans no forma part del seu vocabulari, i quan proposa als pares alguna activitat sempre busca que tinga aigua. Ara bé, no li agrada córrer cap risc.",
         "answer": "c"
        },
        {
         "n": 25,
         "prompt": "Adriana Garcia té 16 anys, i li agrada molt llegir. Encara no té clar què vol estudiar, però reconeix que li agradaria alguna carrera científica. Ha recorregut tres continents i, quan fa turisme de proximitat, li agrada conéixer la història i cultura dels pobles.",
         "answer": "d"
        },
        {
         "n": 26,
         "prompt": "Miquel Puig és pare de família i treballa com a auxiliar d'infermeria. La velocitat i els esports d'aigua l'apassionen, però els dos fills menuts el condicionen a l'hora de buscar activitats recreatives, i ara que ha d'organitzar un viatge familiar busca combinar naturalesa i animals.",
         "answer": "b"
        },
        {
         "n": 27,
         "prompt": "Empar Guillem té cinc nets. La família és molt gran, i costa buscar una activitat recreativa que els agrade a tots. L'objectiu amb què fan alguna excursió és buscar tranquil·litat i passar el dia junts; per això un passeig que es puga fer amb diversos mitjans i que siga accessible és la millor opció.",
         "answer": "e"
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
         "text": "Has viscut alguna vegada un moment que t'haja canviat la manera de vore les coses? Una trobada inesperada, una conversació especial o una situació que t'haja fet reflexionar? Escriu la teua experiència en una entrada en el blog Moments que marquen, a on s'arrepleguen històries reals que han suposat un fet important per a les persones.",
         "points": [
          "Una descripció del que vas viure.",
          "Com et vas sentir i quina reacció vas tindre.",
          "Per què recordaràs sempre eixe moment."
         ]
        },
        {
         "key": "B",
         "text": "L'ajuntament del teu poble ha organitzat amb motiu del Dia Mundial de l'Amistat un concurs d'escriptura. Com que tens afició a escriure, has decidit llegir-te les bases i presentar-te al concurs.",
         "points": [
          "Quina importància té una bona amistat i per què.",
          "Com ha de ser una bona amistat.",
          "Tens predisposició a fer noves amistats o et quedes amb les de sempre?"
         ]
        }
       ]
      },
      {
       "n": 7,
       "kind": "writing",
       "title": "Missatge a la teua amiga",
       "instructions": "Les vacacions són un moment perfecte per a descansar de la pantalla, però la teua amiga, amb qui te'n vas a un complex turístic, està enganxadíssima a les xarxes i saps que passarà tot el temps connectada. Decidixes enviar-li un missatge en què mostres la teua preocupació i l'animes a desconnectar. Tin en compte la informació que apareix en la imatge.",
       "min_words": 100,
       "max_words": 120,
       "image": "/exams/b1-octubre-2025/e7-desconnecta.jpg"
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
         "title": "Monòleg · Agraïment",
         "duration": "3 minuts",
         "intro": "Com cada matí, estàs escoltant el teu programa de ràdio preferit. Hui han obert la secció «Ha sigut gràcies a tu» per a enviar missatges d'agraïment. En seguida, has tingut clar a qui li'l dedicaries. Envia un missatge de veu al programa per a agrair a eixa persona tot el que va fer per tu i conta com va ser.",
         "questions": [],
         "images": []
        },
        {
         "title": "Monòleg · Reclamació",
         "duration": "3 minuts",
         "intro": "Has comprat recentment un microones que no funciona correctament. Encara que està en garantia, decidixes deixar un missatge en el contestador de la botiga a on l'has comprat per a mostrar el teu malestar. Explica'ls quin és el problema i demana una solució (recanvi, reparació o reembossament).",
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
         "title": "Diàleg · I el gat?",
         "duration": "4 minuts",
         "intro": "En casa en sou tres: tu, la teua parella i el vostre gat, que vau adoptar fa uns mesos. Ara vos n'anireu de vacacions durant dos setmanes, i no podeu emportar-vos l'animal. Heu de buscar algú que el cuide mentres esteu fora.",
         "questions": [],
         "images": [],
         "roles": [
          {
           "name": "Persona A",
           "text": "Tu tens una persona en el cap que creus que seria perfecta per a fer-se'n càrrec. Explica qui és, quines qualitats té i per què penses que és la millor opció. Intenta convéncer la teua parella (persona B) de per què hauríeu de deixar el gat a esta persona."
          },
          {
           "name": "Persona B",
           "text": "Tu tens una persona en el cap que creus que seria perfecta per a fer-se'n càrrec. Explica qui és, quines qualitats té i per què penses que és la millor opció. Intenta convéncer la teua parella (persona A) de per què hauríeu de deixar el gat a esta persona."
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
