-- Examen interactiu A2 de la JQCV (octubre 2025) com a recurs de category 'examen'.
-- Contingut a metadata.exam; àudio de comprensió oral a url, convertit a MP3 des del
-- WAV oficial (frontend/public/audio/Audio_A2_oct2025.mp3). Font: https://jqcv.gva.es/documents/161863165/165492618/A2+octubre+2025.pdf/94e58d92-2056-4a9f-e154-f53ff58c00d8

INSERT INTO public.resources (id, name, type, url, content, metadata, xp_earned, difficulty, category)
SELECT id, name, type, url, content, metadata, xp_earned, difficulty, category
FROM jsonb_populate_record(NULL::public.resources, $data${
 "id": "0a5c83ca-f87a-558b-9971-883f69d76988",
 "name": "Simulacre A2: octubre 2025",
 "type": "jqcv_a2_oct2025",
 "category": "examen",
 "difficulty": "principiant",
 "xp_earned": 25,
 "url": "/audio/Audio_A2_oct2025.mp3",
 "content": "Examen oficial A2 de la JQCV (octubre 2025): comprensió oral i escrita autocorregibles, redacció i pràctica oral.",
 "metadata": {
  "icon": "🍂",
  "color": "#FFCC80",
  "exam_body": "JQCV",
  "certificate_level": "A2",
  "exam": {
   "level": "A2",
   "session": "Octubre 2025",
   "body": "JQCV",
   "source_url": "https://jqcv.gva.es/documents/161863165/165492618/A2+octubre+2025.pdf/94e58d92-2056-4a9f-e154-f53ff58c00d8",
   "audio_source_url": "https://jqcv.gva.es/documents/161863165/167041107/NIVELL_A2_48KH_24BITS.wav/e2044a6c-6302-e8a8-7061-6c294e613be1",
   "pass_rule": "Per a ser APTE cal una puntuació global mínima de 60 sobre 100 i arribar al mínim de cada àrea: el 50 % en les àrees que valen un 25 % o més, i el 40 % en les que valen un 20 %.",
   "areas": [
    {
     "n": 1,
     "title": "Comprensió oral",
     "weight": 25,
     "duration": "15 minuts",
     "audio": true,
     "intro": "Escoltaràs dos àudios dos vegades, amb una pausa d'un minut entre cada audició. Només hi ha una resposta correcta per a cada enunciat.",
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
         "prompt": "La previsió de l'oratge de dilluns anuncia possibilitat de granís.",
         "answer": "V"
        },
        {
         "n": 2,
         "prompt": "La boira ha dificultat el trànsit en zones de platja.",
         "answer": "F"
        },
        {
         "n": 3,
         "prompt": "En el nord de Castelló i d'Alacant hi haurà més possibilitat de granís.",
         "answer": "V"
        },
        {
         "n": 4,
         "prompt": "Les temperatures de dilluns estaran entre els 6 graus i els 16.",
         "answer": "F"
        },
        {
         "n": 5,
         "prompt": "Dimarts s'espera vent i una baixada de temperatures.",
         "answer": "V"
        }
       ]
      },
      {
       "n": 2,
       "kind": "choice",
       "instructions": "Escolta l'àudio i tria l'opció correcta. Només hi ha una resposta correcta per a cada pregunta. Llig les preguntes abans de fer l'activitat.",
       "questions": [
        {
         "n": 6,
         "prompt": "Quin és el problema que hi ha hagut en l'estació?",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "Que no tenen prou trens."
          },
          {
           "key": "b",
           "text": "Que els trens duen molt de retard."
          },
          {
           "key": "c",
           "text": "Que hi ha hagut una avaria tècnica."
          }
         ]
        },
        {
         "n": 7,
         "prompt": "Què preocupa a Xavi?",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "Que no arribarà a agarrar l'avió."
          },
          {
           "key": "b",
           "text": "Que no podrà vore els amics."
          },
          {
           "key": "c",
           "text": "Que no li agrada viatjar per carretera."
          }
         ]
        },
        {
         "n": 8,
         "prompt": "Quines són les dos solucions que li oferixen?",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "Agarrar un avió o anar en cotxe."
          },
          {
           "key": "b",
           "text": "Esperar un altre tren o tornar-li els diners."
          },
          {
           "key": "c",
           "text": "Tornar-li els diners o canviar-li el bitllet."
          }
         ]
        },
        {
         "n": 9,
         "prompt": "Per què fa un viatge Xavi?",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "Per a celebrar el final de carrera."
          },
          {
           "key": "b",
           "text": "Per a vore uns amics de fora."
          },
          {
           "key": "c",
           "text": "Perquè té faena a Alacant."
          }
         ]
        },
        {
         "n": 10,
         "prompt": "En quin mitjà de transport es desplaçarà finalment?",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "Avió."
          },
          {
           "key": "b",
           "text": "Autobús."
          },
          {
           "key": "c",
           "text": "Tren."
          }
         ]
        }
       ]
      }
     ]
    },
    {
     "n": 2,
     "title": "Comprensió escrita",
     "weight": 25,
     "duration": "1 h 35 min (amb l'àrea 3)",
     "exercises": [
      {
       "n": 3,
       "kind": "match",
       "instructions": "Llig estos set consells per a estalviar en la cistella de la compra i relaciona cada consell amb un dels enunciats. Hi ha dos consells que no es corresponen amb cap enunciat.",
       "options_title": "Consells per a estalviar en la cistella de la compra",
       "options": [
        {
         "key": "a",
         "text": "Planifica detingudament totes les menjades: des del dinar i el sopar, fins al desdejuni, l'esmorzar i el berenar, per a no comprar en excés."
        },
        {
         "key": "b",
         "text": "Amb això, fes una llista abans d'anar a comprar i seguix-la al mil·límetre per a no acabar comprant coses innecessàries i que no estan en la teua planificació."
        },
        {
         "key": "c",
         "text": "Compara preus per a poder triar la botiga o el supermercat més econòmic. Si saps en quin comerç és més barat cada producte, podràs estalviar fins a 1.000 euros a l'any."
        },
        {
         "key": "d",
         "text": "Compra els productes que caduquen més tard, i els aliments no peribles compra'ls en paquets grans, ja que són més econòmics i l'estalvi és més significatiu."
        },
        {
         "key": "e",
         "text": "Si adquirixes les fruites i verdures fresques de temporada, també estalviaràs diners. Les que no són de temporada són d'importació, i per tant més cares."
        },
        {
         "key": "f",
         "text": "Opta pels aliments congelats i les marques blanques. Els productes congelats són més econòmics que els frescos, i les marques blanques són més assequibles que les de «tota la vida»."
        },
        {
         "key": "g",
         "text": "Aprofita les ofertes que oferixen molts supermercats, però ves amb compte i mira sempre el preu per quilogram perquè, a vegades, les quantitats enganyen."
        }
       ],
       "questions": [
        {
         "n": 11,
         "prompt": "Planifica menjades per a evitar fer compres innecessàries.",
         "answer": "a"
        },
        {
         "n": 12,
         "prompt": "Tria opcions econòmiques comparant preus.",
         "answer": "c"
        },
        {
         "n": 13,
         "prompt": "Compra aliments que duren en envasos més grans.",
         "answer": "d"
        },
        {
         "n": 14,
         "prompt": "Els productes frescos de temporada són més barats.",
         "answer": "e"
        },
        {
         "n": 15,
         "prompt": "Fixa't en les ofertes comparant el preu segons la quantitat del producte.",
         "answer": "g"
        }
       ]
      },
      {
       "n": 4,
       "kind": "binary",
       "instructions": "Llig el text i digues si les afirmacions són verdaderes (V) o falses (F).",
       "reading": {
        "title": "La jardineria: una afició per al benestar",
        "paragraphs": [
         "Fa uns dissabtes estava coberta de terra, em feia mal l'esquena i notava com el sol em començava a cremar la part de darrere del coll. Estava en el paradís. Al llarg del dia, havia plantat algunes flors d'estiu, havia trasplantat un arbre i havia arrancat una margarita que havia crescut massa.",
         "Per a mi, la jardineria és exercici, una forma de meditació i una oportunitat per a socialitzar amb els veïns, tot en u. I, encara que no soc imparcial, la investigació confirma algunes de les meues observacions sobre la jardineria i els beneficis reals que pot tindre per a la ment i el cos.",
         "Remoure la terra, arrancar males herbes i carregar una regadora es poden considerar activitats físiques d'intensitat moderada. Les persones que practiquen la jardineria solen registrar nivells més alts d'activitat física en comparació amb les que no ho fan.",
         "A més, alguns experts indiquen que treballar en un jardí reduïx els nivells d'ansietat i depressió; i altres han descobert un augment de la confiança i l'autoestima entre els que cuiden plantes. I per què és així? Perquè l'activitat física és una manera molt evident de millorar l'estat d'ànim.",
         "Per últim, moltes persones afirmen que cultivar un hort els fa tindre un sentit i un propòsit. Ara bé, la constància i la paciència són necessàries, i per això no tots els que comencen aconseguixen no abandonar. I tu, t'animes a començar el teu hort?"
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
         "n": 16,
         "prompt": "Treballar un hort és una activitat cansada que pot provocar dolors en el cos.",
         "answer": "V"
        },
        {
         "n": 17,
         "prompt": "Els estudis contradiuen l'opinió de l'autora sobre els beneficis de la jardineria.",
         "answer": "F"
        },
        {
         "n": 18,
         "prompt": "Les persones que practiquen la jardineria s'exerciten més que les que no la practiquen.",
         "answer": "V"
        },
        {
         "n": 19,
         "prompt": "Segons el text, cuidar un jardí pot disminuir la confiança en u mateix.",
         "answer": "F"
        },
        {
         "n": 20,
         "prompt": "Per a cultivar un hort has de tindre calma i no anar amb presses.",
         "answer": "V"
        }
       ]
      },
      {
       "n": 5,
       "kind": "choice",
       "instructions": "Llig el text i marca l'opció correcta. Només hi ha una resposta correcta per a cada pregunta.",
       "reading": {
        "title": "Organitza ta casa",
        "paragraphs": [
         "Per sort o per desgràcia, les xarxes estan plenes de trucs d'orde, sistemes d'organització i reptes motivadors que prometen canviar-te la casa i la vida. Analitzem els pros i els contres dels tres reptes més populars d'internet.",
         "El repte dels 30 dies. Consistix a dedicar 15 minuts al dia durant un mes a tirar tot el que no utilitzem en casa. Roba que no ens posem, cosmètics caducats, joguets oblidats… Al final d'este repte de velocitat (en 15 minuts no hi ha ni un segon a perdre) aconseguixes que la casa es veja un poc més buida, si és que el que tires estava a la vista. Si et desfàs de coses que estaven guardades en armaris i calaixos, la casa es continua veent igual de desordenada. Este repte és per a les persones «sense temps».",
         "El repte de l'1, 2, 3. Consistix a tirar una cosa el dia 1 del mes; al sendemà, 2 coses; el següent, 3 coses, fins a acabar el mes i tirar-ne 31. Està indicat per a motivar-se i començar el camí de suprimir coses i simplificar la casa. En realitat és més prompte un joc, i com tots els jocs té les seues trampes. La més comuna és «guardar-se» coses per a tirar-les el dia que no sapiem de què prescindir.",
         "Toc únic. Un sistema que es diferencia de la resta és el toc únic perquè no t'has de desfer de res. Ens imaginem que entrem en casa i deixem l'abric damunt de la butaca; les claus, en la taula del menjador, i les sabates, davant del sofà. Si volem tindre la casa ben arreglada, després haurem d'agarrar cada cosa i deixar-la en el seu lloc.",
         "D'entrada, deixa-ho a on toca, i així no ho hauràs d'arreplegar després. Esta premissa, que és de sentit comú, és la clau de les persones ordenades, que, contràriament al que pensa molta gent, no es passen el dia ordenant: simplement no desordenen. Potser podem adaptar la dita i afirmar que no és més organitzat qui més ordena, sinó qui menys desordena."
        ]
       },
       "questions": [
        {
         "n": 21,
         "prompt": "L'objectiu principal del repte de 30 dies és...",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "organitzar la casa en 15 minuts."
          },
          {
           "key": "b",
           "text": "desfer-se del que no utilitzes."
          },
          {
           "key": "c",
           "text": "organitzar únicament els objectes visibles."
          }
         ]
        },
        {
         "n": 22,
         "prompt": "En el repte de 30 dies, desfer-se únicament de les coses amagades...",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "només és útil per a les persones sense temps."
          },
          {
           "key": "b",
           "text": "és més senzill i t'ajuda a buidar la casa ràpidament."
          },
          {
           "key": "c",
           "text": "no ajuda a canviar el desorde de la casa."
          }
         ]
        },
        {
         "n": 23,
         "prompt": "El repte de l'1, 2, 3 consistix a...",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "tirar cada dia una cosa més que el dia anterior."
          },
          {
           "key": "b",
           "text": "guardar-se coses per a poder tirar-les el dia 31."
          },
          {
           "key": "c",
           "text": "guardar-se les coses de valor sense fer trampes."
          }
         ]
        },
        {
         "n": 24,
         "prompt": "A diferència dels altres, el toc únic...",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "t'anima a separar el que no utilitzes i tirar-ho."
          },
          {
           "key": "b",
           "text": "no es basa en consells per a tirar les coses."
          },
          {
           "key": "c",
           "text": "t'anima a deixar les coses desordenades."
          }
         ]
        },
        {
         "n": 25,
         "prompt": "El sistema del toc únic explica que...",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "és important deixar les coses en el lloc quan arribem a casa."
          },
          {
           "key": "b",
           "text": "les persones ordenades sempre estan organitzant la casa."
          },
          {
           "key": "c",
           "text": "hi ha algunes dites populars sobre l'orde que no es complixen."
          }
         ]
        }
       ]
      }
     ]
    },
    {
     "n": 3,
     "title": "Expressió escrita",
     "weight": 20,
     "duration": "1 h 35 min (amb l'àrea 2)",
     "exercises": [
      {
       "n": 6,
       "kind": "writing",
       "title": "Correu a l'agència de viatges",
       "instructions": "Cada any, un membre de la teua família organitza un viatge a un destí diferent. Enguany et toca a tu organitzar-lo, però no saps a quin lloc anar. Per això, decidixes escriure un correu electrònic a una agència de viatges en què expliques les teues preferències perquè puguen oferir-te diversos destins.",
       "min_words": 80,
       "max_words": 100,
       "words": [
        "transport",
        "reserva",
        "visita",
        "excursió",
        "platja",
        "muntanya",
        "allotjament",
        "cadira",
        "foli",
        "fusta"
       ],
       "min_words_used": 5
      }
     ]
    },
    {
     "n": 4,
     "title": "Expressió i interacció orals",
     "weight": 30,
     "duration": "25 minuts",
     "intro": "Esta àrea té dos parts: un monòleg d'uns tres minuts sobre un tema i un diàleg d'uns quatre minuts amb una altra persona aspirant.",
     "exercises": [
      {
       "n": 7,
       "kind": "oral",
       "instructions": "Llig les preguntes del tema i prepara les respostes. No han de ser monosil·làbiques: l'avaluador et pot fer totes les preguntes o només algunes. Després, practica el diàleg defenent la proposta de la teua persona.",
       "proposals": [
        {
         "title": "Monòleg · Restaurant",
         "duration": "3 minuts",
         "questions": [
          "Quan tries un restaurant per a dinar o sopar, en què et fixes: en la varietat de la carta o en el preu?",
          "Preferixes anar a dinar o a sopar? Per què?",
          "Quin tipus de cuina t'agrada més: exòtica o tradicional? Per què?",
          "Hi ha algun plat que t'agradaria tastar però no t'has atrevit a fer-ho? Quin i per què?"
         ],
         "images": []
        },
        {
         "title": "Diàleg · A on sopem?",
         "duration": "4 minuts",
         "questions": [],
         "images": [],
         "intro": "Mantín un diàleg amb una altra persona. Defén la teua proposta, evita les respostes massa curtes i participa com en una conversa habitual: les intervencions han de ser equilibrades.",
         "roles": [
          {
           "name": "Persona A",
           "text": "Demà és un dia molt especial per a tu i la teua parella, i les dates especials sempre s'han de celebrar! Tens moltes ganes de provar un restaurant nou que han obert en el teu barri. Proposa a la persona B anar allí a sopar. Explica-li a on està i per què vols anar a eixe restaurant. Intenta convéncer-la que és la millor opció."
          },
          {
           "name": "Persona B",
           "text": "Demà és un dia molt especial per a tu i la teua parella, i les dates especials sempre s'han de celebrar! Un dia tan important s'ha de celebrar en el vostre restaurant preferit. Proposa a la persona A anar allí a sopar. Explica-li què podeu menjar i per què vols anar a eixe restaurant. Intenta convéncer-la que és la millor opció."
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
