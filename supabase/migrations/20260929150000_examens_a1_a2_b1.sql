-- Migració agrupada: 20260929150000_examens_a1_a2_b1
-- Conté, per ordre, les 15 migracions originals següents:
--   20260929150000_exam_a1_juny_2026
--   20260929160000_sync_resources_catalog
--   20260929170000_exam_a2_juny_2026
--   20260929180000_exam_a2_oct2025
--   20260929190000_exam_a2_oct2024
--   20260929200000_exam_a2_oct2023
--   20260929210000_exam_b1_jun2026
--   20260929220000_exam_b1_oct2025
--   20260929230000_exam_b1_oct2024
--   20260929240000_exam_a1_scoring
--   20260929250000_exam_a2_scoring
--   20260929260000_exam_a2_area2_scoring
--   20260929270000_exam_b1_area1_scoring
--   20260929280000_exam_b1_area2_scoring
--   20260929290000_exam_b1_e7_image_text

-- ============================================================
-- Origen: 20260929150000_exam_a1_juny_2026.sql
-- ============================================================
-- Contingut interactiu de l'examen A1 de la JQCV (juny 2026) guardat a
-- resources.metadata.exam: àrees, exercicis, preguntes, opcions i solucions.
-- La pantalla d'examen el pinta sense PDF; les imatges són a
-- frontend/public/exams/a1-juny-2026/. Font: https://jqcv.gva.es/documents/161863165/411097827/A1+juny+2026.pdf/1bbb808f-60ca-5204-3992-6213acfa0fa3
UPDATE resources
SET url = '/audio/Audio_A1.mp3',
    metadata = (coalesce(metadata, '{}'::jsonb) - 'pdf_url') || jsonb_build_object('exam', $exam${
 "level": "A1",
 "session": "Juny 2026",
 "body": "JQCV",
 "source_url": "https://jqcv.gva.es/documents/161863165/411097827/A1+juny+2026.pdf/1bbb808f-60ca-5204-3992-6213acfa0fa3",
 "areas": [
  {
   "n": 1,
   "title": "Comprensió oral",
   "weight": 25,
   "duration": "15 minuts",
   "audio": true,
   "intro": "Escoltaràs una sèrie d'àudios dos vegades, amb una pausa d'un minut entre cada audició. Només hi ha una resposta correcta per a cada enunciat.",
   "exercises": [
    {
     "n": 1,
     "kind": "choice",
     "instructions": "Escolta els quatre àudios i tria l'opció correcta per a cada situació. Llig les preguntes abans de fer l'activitat.",
     "questions": [
      {
       "n": 1,
       "prompt": "Com va Anna al treball?",
       "answer": "a",
       "options": [
        {
         "key": "a",
         "image": "/exams/a1-juny-2026/e1-q1-a.jpg"
        },
        {
         "key": "b",
         "image": "/exams/a1-juny-2026/e1-q1-b.jpg"
        },
        {
         "key": "c",
         "image": "/exams/a1-juny-2026/e1-q1-c.jpg"
        }
       ]
      },
      {
       "n": 2,
       "prompt": "Quin producte està d'oferta?",
       "answer": "a",
       "options": [
        {
         "key": "a",
         "image": "/exams/a1-juny-2026/e1-q2-a.jpg"
        },
        {
         "key": "b",
         "image": "/exams/a1-juny-2026/e1-q2-b.jpg"
        },
        {
         "key": "c",
         "image": "/exams/a1-juny-2026/e1-q2-c.jpg"
        }
       ]
      },
      {
       "n": 3,
       "prompt": "A quina hora és la reunió?",
       "answer": "b",
       "options": [
        {
         "key": "a",
         "image": "/exams/a1-juny-2026/e1-q3-a.jpg"
        },
        {
         "key": "b",
         "image": "/exams/a1-juny-2026/e1-q3-b.jpg"
        },
        {
         "key": "c",
         "image": "/exams/a1-juny-2026/e1-q3-c.jpg"
        }
       ]
      },
      {
       "n": 4,
       "prompt": "Quant val la barra de pa?",
       "answer": "a",
       "options": [
        {
         "key": "a",
         "image": "/exams/a1-juny-2026/e1-q4-a.jpg"
        },
        {
         "key": "b",
         "image": "/exams/a1-juny-2026/e1-q4-b.jpg"
        },
        {
         "key": "c",
         "image": "/exams/a1-juny-2026/e1-q4-c.jpg"
        }
       ]
      }
     ]
    },
    {
     "n": 2,
     "kind": "binary",
     "instructions": "Escolta la conversació entre dos amics i digues si les afirmacions són verdaderes (V) o falses (F).",
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
       "n": 5,
       "prompt": "Jaume s'alça a les 6:30 hores.",
       "answer": "V"
      },
      {
       "n": 6,
       "prompt": "Jaume desdejuna en una cafeteria.",
       "answer": "F"
      },
      {
       "n": 7,
       "prompt": "Jaume ha d'entrar a treballar a les 7:45 hores.",
       "answer": "F"
      },
      {
       "n": 8,
       "prompt": "Jaume dina en el restaurant.",
       "answer": "F"
      },
      {
       "n": 9,
       "prompt": "Jaume fa esport durant la setmana.",
       "answer": "V"
      },
      {
       "n": 10,
       "prompt": "Jaume llig una novel·la abans de dormir.",
       "answer": "F"
      }
     ]
    },
    {
     "n": 3,
     "kind": "binary",
     "instructions": "Escolta la conversació entre una mare i la seua filla, i marca «Sí» o «No» segons els ingredients que es mencionen.",
     "options": [
      {
       "key": "si",
       "text": "Sí"
      },
      {
       "key": "no",
       "text": "No"
      }
     ],
     "questions": [
      {
       "n": 11,
       "prompt": "Farina",
       "image": "/exams/a1-juny-2026/e3-farina.jpg",
       "answer": "no"
      },
      {
       "n": 12,
       "prompt": "Mantega",
       "image": "/exams/a1-juny-2026/e3-mantega.jpg",
       "answer": "no"
      },
      {
       "n": 13,
       "prompt": "Fruita seca",
       "image": "/exams/a1-juny-2026/e3-fruita-seca.jpg",
       "answer": "no"
      },
      {
       "n": 14,
       "prompt": "Llet",
       "image": "/exams/a1-juny-2026/e3-llet.jpg",
       "answer": "si"
      },
      {
       "n": 15,
       "prompt": "Aigua",
       "image": "/exams/a1-juny-2026/e3-aigua.jpg",
       "answer": "no"
      },
      {
       "n": 16,
       "prompt": "Ous",
       "image": "/exams/a1-juny-2026/e3-ous.jpg",
       "answer": "si"
      },
      {
       "n": 17,
       "prompt": "Oli",
       "image": "/exams/a1-juny-2026/e3-oli.jpg",
       "answer": "no"
      },
      {
       "n": 18,
       "prompt": "Sucre",
       "image": "/exams/a1-juny-2026/e3-sucre.jpg",
       "answer": "si"
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
     "n": 4,
     "kind": "match",
     "instructions": "Llig els missatges de text i relaciona'ls amb les situacions. Només hi ha un missatge correcte per a cada situació.",
     "options": [
      {
       "key": "a",
       "text": "El pròxim dilluns 15 de maig té una cita amb el doctor Forner a les 11:00 hores."
      },
      {
       "key": "b",
       "text": "Hola, Anna! Vols que quedem este cap de setmana?"
      },
      {
       "key": "c",
       "text": "Enhorabona, parella! Vos desitgem molta sort en esta nova etapa!"
      },
      {
       "key": "d",
       "text": "Bon dia, Joan! El dia 28 d'abril celebre el meu aniversari. Vols vindre?"
      },
      {
       "key": "e",
       "text": "Gràcies per enviar el seu currículum! Ens interessaria concertar una entrevista laboral amb vosté."
      },
      {
       "key": "f",
       "text": "Tinc una cita amb el dentiste. No podré acompanyar-te a comprar el regal de Toni. Podem quedar demà per a anar a comprar-lo?"
      }
     ],
     "questions": [
      {
       "n": 19,
       "prompt": "Una quedada amb una amiga.",
       "answer": "b"
      },
      {
       "n": 20,
       "prompt": "Una cita mèdica.",
       "answer": "a"
      },
      {
       "n": 21,
       "prompt": "Una oferta de treball.",
       "answer": "e"
      },
      {
       "n": 22,
       "prompt": "Un canvi de plans.",
       "answer": "f"
      },
      {
       "n": 23,
       "prompt": "Una felicitació pel casament.",
       "answer": "c"
      },
      {
       "n": 24,
       "prompt": "Una invitació a una festa.",
       "answer": "d"
      }
     ]
    },
    {
     "n": 5,
     "kind": "match",
     "instructions": "Llig els rètols i relaciona'ls amb els enunciats. Només hi ha un rètol correcte per a cada enunciat.",
     "options": [
      {
       "key": "a",
       "sign": {
        "title": "El color de les flors",
        "lines": [
         "Dies: del 2 al 5 d'octubre",
         "Horari: de 18:00 a 20:00 h",
         "Lloc: Casa de la Cultura"
        ]
       }
      },
      {
       "key": "b",
       "sign": {
        "title": "Forn d'Or",
        "lines": [
         "Pa acabat de fer tots els dies.",
         "Horari: de 07:00 a 14:00 h"
        ]
       }
      },
      {
       "key": "c",
       "sign": {
        "title": "Botiga Via Moda",
        "lines": [
         "Camises, pantalons i faldes rebaixats al 50 % este mes."
        ]
       }
      },
      {
       "key": "d",
       "sign": {
        "title": "Contenidor verd",
        "lines": [
         "Recordeu llevar els taps de plàstic quan tireu els envasos de vidre."
        ]
       }
      },
      {
       "key": "e",
       "sign": {
        "title": "Sala d'espera",
        "lines": [
         "No pot passar a la consulta del metge si no apareix el seu número en la pantalla."
        ]
       }
      },
      {
       "key": "f",
       "sign": {
        "title": "Vestidor per a adults",
        "lines": [
         "Per 7 € al mes pots guardar les teues coses en un lloc segur."
        ]
       }
      }
     ],
     "questions": [
      {
       "n": 25,
       "prompt": "Pots llogar una taquilla per menys de deu euros al mes.",
       "answer": "f"
      },
      {
       "n": 26,
       "prompt": "En este establiment pots comprar menjar per a almorzar.",
       "answer": "b"
      },
      {
       "n": 27,
       "prompt": "Has d'esperar que isca el teu número per a entrar a la consulta.",
       "answer": "e"
      },
      {
       "n": 28,
       "prompt": "En este contenidor pots tirar una botella de vi.",
       "answer": "d"
      },
      {
       "n": 29,
       "prompt": "En esta tenda la roba és més barata este mes.",
       "answer": "c"
      },
      {
       "n": 30,
       "prompt": "L'exposició de pintura es pot visitar de vesprada.",
       "answer": "a"
      }
     ]
    },
    {
     "n": 6,
     "kind": "match",
     "instructions": "Llig els enunciats i relaciona'ls amb les imatges. Només hi ha una imatge correcta per a cada enunciat.",
     "options": [
      {
       "key": "a",
       "image": "/exams/a1-juny-2026/e6-a.jpg"
      },
      {
       "key": "b",
       "image": "/exams/a1-juny-2026/e6-b.jpg"
      },
      {
       "key": "c",
       "image": "/exams/a1-juny-2026/e6-c.jpg"
      },
      {
       "key": "d",
       "image": "/exams/a1-juny-2026/e6-d.jpg"
      },
      {
       "key": "e",
       "image": "/exams/a1-juny-2026/e6-e.jpg"
      },
      {
       "key": "f",
       "image": "/exams/a1-juny-2026/e6-f.jpg"
      }
     ],
     "questions": [
      {
       "n": 31,
       "prompt": "Jugar a tenis.",
       "answer": "e"
      },
      {
       "n": 32,
       "prompt": "Pintar un quadro.",
       "answer": "b"
      },
      {
       "n": 33,
       "prompt": "Llegir un llibre.",
       "answer": "f"
      },
      {
       "n": 34,
       "prompt": "Tocar el violí.",
       "answer": "d"
      },
      {
       "n": 35,
       "prompt": "Jugar a futbol.",
       "answer": "a"
      },
      {
       "n": 36,
       "prompt": "Fer ceràmica.",
       "answer": "c"
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
     "n": 7,
     "kind": "form",
     "instructions": "Acabes d'arribar a una ciutat nova i vols fer-te el carnet de la biblioteca local. Per a registrar-te, has d'omplir el formulari següent amb les teues dades.",
     "fields": [
      "Nom i cognoms",
      "Data de naixement",
      "Nacionalitat",
      "Adreça postal",
      "Professió o ocupació",
      "Població",
      "Adreça de correu electrònic",
      "Llengua materna",
      "Llengües en què vols llegir",
      "Temes d'interés",
      "Activitats que t'agradaria trobar en la biblioteca"
     ],
     "max_points": 15,
     "criteria": [
      {
       "title": "Competències lingüístiques",
       "items": [
        {
         "name": "Lèxic",
         "description": "Disposes de lèxic bàsic suficient per a resoldre la tasca."
        },
        {
         "name": "Estructures",
         "description": "Les frases del format demanat estan ben construïdes."
        },
        {
         "name": "Ortografia",
         "description": "Cometes errors ortogràfics mínims."
        }
       ]
      },
      {
       "title": "Competències textuals",
       "items": [
        {
         "name": "Comprensibilitat i coherència",
         "description": "Les respostes són comprensibles i coherents."
        },
        {
         "name": "Adequació",
         "description": "Completes adequadament la tasca que se t'encomana."
        }
       ]
      }
     ]
    }
   ]
  },
  {
   "n": 4,
   "title": "Expressió i interacció orals",
   "weight": 30,
   "duration": "25 minuts",
   "intro": "Esta àrea consta de dos parts. En la primera contestaràs les preguntes de la persona que t'examina. En la segona voràs una sèrie d'imatges amb preguntes sobre situacions de la vida quotidiana.",
   "exercises": [
    {
     "n": 8,
     "kind": "oral",
     "instructions": "Tria una proposta i practica en veu alta. Intenta respondre cada pregunta amb una o dos frases completes.",
     "proposals": [
      {
       "title": "Tu i el lloc on vius",
       "questions": [
        "Com et diuen?",
        "D'a on eres?",
        "A on vius?",
        "Què t'agrada del lloc a on vius?",
        "Què és el que menys t'agrada del lloc a on vius?",
        "Quants anys tens?",
        "Treballes o estudies?",
        "De què treballes? / Què estudies?",
        "Quant de temps fa que treballes en este lloc? / Quant de temps fa que estudies això?",
        "Què és el que més t'agrada del teu treball? / Què és el que més t'agrada del que estudies?"
       ],
       "images": [
        {
         "prompt": "A on estan els xiquets?",
         "image": "/exams/a1-juny-2026/o1-xiquets.jpg"
        },
        {
         "prompt": "Quins aliments hi ha en el plat?",
         "image": "/exams/a1-juny-2026/o1-plat.jpg"
        },
        {
         "prompt": "A què juga?",
         "image": "/exams/a1-juny-2026/o1-juga.jpg"
        },
        {
         "prompt": "Quant valen les llimes?",
         "image": "/exams/a1-juny-2026/o1-llimes.jpg"
        },
        {
         "prompt": "Quin instrument està tocant?",
         "image": "/exams/a1-juny-2026/o1-instrument.jpg"
        }
       ]
      },
      {
       "title": "El menjar",
       "questions": [
        "Què t'agrada cuinar en casa?",
        "Quin és el teu plat favorit?",
        "Quina fruita t'agrada més?",
        "Què t'agrada beure quan fa calor?",
        "Quin és el teu moment preferit del dia per a menjar?",
        "Quins plats d'un altre país t'agraden i per què?",
        "Menges de forma saludable o preferixes el menjar ràpid?",
        "A on fas la compra i què compres normalment?",
        "Quins productes locals compres i per què t'agraden?",
        "Quin és el teu bar o restaurant preferit?"
       ],
       "images": [
        {
         "prompt": "Quina hora és?",
         "image": "/exams/a1-juny-2026/o2-hora.jpg"
        },
        {
         "prompt": "Com està la muntanya?",
         "image": "/exams/a1-juny-2026/o2-muntanya.jpg"
        },
        {
         "prompt": "Quina part de la casa és esta?",
         "image": "/exams/a1-juny-2026/o2-casa.jpg"
        },
        {
         "prompt": "Què estan fent estes persones?",
         "image": "/exams/a1-juny-2026/o2-persones.jpg"
        },
        {
         "prompt": "Què té el xiquet en la mà?",
         "image": "/exams/a1-juny-2026/o2-xiquet.jpg"
        }
       ]
      },
      {
       "title": "Les llengües",
       "questions": [
        "Quantes llengües parles? Quines són?",
        "Quina és la teua llengua materna?",
        "I quina llengua parles amb els amics?",
        "I quina utilitzes en el treball?",
        "T'agrada aprendre noves llengües? Per què?",
        "Quines llengües t'agradaria aprendre?",
        "Què és el més difícil per a tu quan estudies una llengua?",
        "Qui és l'amic o familiar que parla més llengües i quines parla?",
        "Creus que és important aprendre llengües per a viatjar?",
        "Quan viatges a un país estranger, quina llengua utilitzes?"
       ],
       "images": []
      },
      {
       "title": "El temps lliure",
       "questions": [
        "Què fas en el teu temps lliure?",
        "Compartixes el temps lliure amb altres persones?",
        "Tens aficions? Quines?",
        "Quant de temps dediques a les teues aficions?",
        "Què fas normalment els caps de setmana?",
        "T'agrada aprendre activitats noves? Quines?",
        "Quines activitats no t'agraden?",
        "Quines activitats practiques a l'aire lliure?",
        "Fas esport? Quin?",
        "Quina activitat t'agradaria fer més a sovint?"
       ],
       "images": []
      }
     ]
    }
   ]
  }
 ]
}$exam$::jsonb)
WHERE category = 'examen' AND type = 'jqcv_a1_oral';

-- ============================================================
-- Origen: 20260929160000_sync_resources_catalog.sql
-- ============================================================
-- Sincronitza el catàleg d'activitats (taula resources) amb l'estat de la BDD
-- local del 29/09/2026: mateixes files, mateixos id i mateix contingut
-- (escenaris, gramàtica i l'examen A1). Es pot aplicar en qualsevol BDD:
--   * afig la columna img, creada a mà en local;
--   * si ja hi ha un recurs amb la mateixa category + type però un altre id
--     (p. ex. el seed de 20260929081233), li posa l'id local. session_resource
--     té ON UPDATE CASCADE, així que l'historial d'eixe recurs es conserva;
--   * insereix o actualitza cada fila per id;
--   * esborra els recursos que ja no existixen al catàleg.

ALTER TABLE public.resources ADD COLUMN IF NOT EXISTS img text;

CREATE TEMP TABLE resources_catalog AS
SELECT * FROM jsonb_populate_recordset(NULL::public.resources, $data$[
    {
        "id": "ff3c4e04-ba2a-4c31-a71f-775890fe08a0",
        "img": null,
        "url": null,
        "name": "Tràmits i empadronament a l'ajuntament",
        "type": "ajuntament",
        "content": "Sol·licita el certificat d'empadronament, demana informació sobre documentació i taxes.",
        "category": "escenari",
        "metadata": {
            "icon": "🏛️",
            "color": "#C8D7EE",
            "voice": "gina",
            "scenario": "ajuntament",
            "character": "Amparo, funcionària d'atenció",
            "objectius": [
                "Saluda a Amparo i digues què necessites.",
                "Explica el tràmit que vols fer.",
                "Pregunta els requisits o els horaris.",
                "Dona les gràcies i acomiada't."
            ],
            "background": "/images/townhall.jpg",
            "section_name": "L'Ajuntament",
            "system_prompt": "Ets Amparo, funcionària d'atenció ciutadana a l'ajuntament.\n- To i personalitat: Amable, eficient i professional. Utilitza un valencià formal estàndard però accessible i clar (tractament de vosté o de tu respectuós segons l'aprenent).\n- Regla d'interacció: Fes respostes breus (màxim 2-3 frases per torn). No resolgues el tràmit tot d'una: fes preguntes de seguiment pas a pas per obligar l'aprenent a intervindre i avançar en els seus objectius.\n- Immersió: Mai no te'n vages del personatge. Si l'aprenent fa un error lingüístic o un castellanisme, no el corregisques directament com un docent; reformula-ho amb naturalitat dins de la teua resposta institucional.\n- Adaptació al nivell:\n  * Si el nivell és inicial (A1-A2): Usa vocabulari senzill, frases curtes i opcions guiades (\"Vol demanar cita prèvia o el certificat d'empadronament?\").\n  * Si el nivell és avançat (B2-C1): Empra fórmules administratives genuïnes (\"instància\", \"taxa municipal\", \"termini de presentació\", \"acreditació\").",
            "bgIllustration": "#E8EFF8",
            "character_role": "Funcionari d'atenció ciutadana",
            "initial_prompt": "Bona vesprada. Com el puc ajudar? Ha demanat cita prèvia per al tràmit d'empadronament?"
        },
        "xp_earned": 25,
        "created_at": "2026-09-29T08:13:41.031677+00:00",
        "difficulty": "intermedi"
    },
    {
        "id": "06f2fce4-04be-4548-8c20-168c8d54061d",
        "img": null,
        "url": null,
        "name": "Demanar un café i esmorzar al bar",
        "type": "bar",
        "content": "Aprèn a demanar begudes, esmorzars típics, demanar el compte i pagar.",
        "category": "escenari",
        "metadata": {
            "icon": "☕",
            "color": "#F2B47C",
            "voice": "gina",
            "scenario": "bar",
            "character": "Maria, cambrera",
            "objectius": [
                "Saluda a Maria i busca una taula.",
                "Demana una beguda o el desdejuni del dia.",
                "Pregunta quant és o demana el compte.",
                "Paga, dona les gràcies i acomiada't."
            ],
            "background": "/images/bar.jpg",
            "section_name": "El Bar",
            "system_prompt": "Ets Maria, una cambrera propera d'un bar valencià. Practica com demanar, preguntar i pagar amb naturalitat. Ajusta el registre al nivell i guia amb preguntes curtes.",
            "bgIllustration": "#FDE8D0",
            "character_role": "Cambrer",
            "initial_prompt": "Hola! Què prens per a esmorzar? Un tallat, un café amb llet o potser un entrepà?"
        },
        "xp_earned": 25,
        "created_at": "2026-09-29T08:13:41.031677+00:00",
        "difficulty": "intermedi"
    },
    {
        "id": "8eaa2742-959e-4da4-9fe7-966a8fe069e3",
        "img": null,
        "url": null,
        "name": "Reunió de tutoria a l'escola",
        "type": "colegi",
        "content": "Comenta el progrés acadèmic, resol dubtes sobre metodologies i planteja objectius del curs.",
        "category": "escenari",
        "metadata": {
            "icon": "🏫",
            "color": "#D9C8EE",
            "voice": "gina",
            "scenario": "escola",
            "character": "Marta, mestra",
            "objectius": [
                "Saluda a Marta i pregunta com està.",
                "Pregunta pels deures o la tasca d'avui.",
                "Demana permís o explica un dubte.",
                "Dona les gràcies i acomiada't."
            ],
            "background": "/images/classroom.jpg",
            "section_name": "L'Escola",
            "system_prompt": "Ets Marta, una mestra amable d'una escola valenciana. Practica converses d'aula: saludar, demanar permís, preguntar dubtes, explicar tasques i parlar de les assignatures. Usa vocabulari escolar (pissarra, llibre, deures, examen, pati) i valencià general. Adapta't al nivell de l'aprenent: principiant usa frases breus i clares; intermedi amplia amb preguntes; avançat usa registre docent espontani. No faces lliçons llargues: respon com Marta i, si cal, corregeix suaument amb un exemple. Avalua si la resposta està per sota, al nivell o per damunt del seu nivell. El teu objectiu és que continue la conversa.",
            "bgIllustration": "#F0E8F8",
            "character_role": "Tutor escolar",
            "initial_prompt": "Molt bon dia. Gràcies per vindre a la tutoria. Volia comentar com ha començat el curs i els objectius que tenim plantejats."
        },
        "xp_earned": 40,
        "created_at": "2026-09-29T08:13:41.031677+00:00",
        "difficulty": "avancat"
    },
    {
        "id": "2e0c66aa-9528-471c-adc2-4c993694836c",
        "img": null,
        "url": null,
        "name": "Comprar medicaments a la farmàcia",
        "type": "farmacia",
        "content": "Explica els símptomes d'un refredat o mal de cap, demana consell farmacèutic i entén la posologia del medicament.",
        "category": "escenari",
        "metadata": {
            "icon": "💊",
            "color": "#A8E6CF",
            "voice": "lluc",
            "scenario": "farmacia",
            "character": "Pau, farmacèutic",
            "objectius": [
                "Saluda a Pau i explica què et passa.",
                "Demana un medicament o dona la recepta.",
                "Pregunta com i quan cal prendre-ho.",
                "Paga, dona les gràcies i acomiada't."
            ],
            "section_name": "La Farmàcia",
            "system_prompt": "Ets Pau, un farmacèutic amable d'una farmàcia de barri valenciana. Ajuda la persona a explicar què li passa, demanar un medicament o presentar una recepta. Usa vocabulari de farmàcia (recepta, pastilles, xarop, dosi, símptomes, mal de cap, refredat) i valencià general. Fes preguntes curtes per saber els símptomes i recomana amb prudència; si és greu, aconsella anar al metge. Adapta't al nivell de l'aprenent: principiant usa frases breus i clares; intermedi amplia amb preguntes; avançat usa registre espontani. No faces explicacions llargues: respon com Pau i, si cal, corregeix suaument amb un exemple. El teu objectiu és que continue la conversa.",
            "bgIllustration": "#EAF9F1",
            "character_role": "Farmacèutic",
            "initial_prompt": "Bon dia! En què et puc ajudar hui? Tens alguna recepta o busques alguna cosa per a algun símptoma en concret?"
        },
        "xp_earned": 20,
        "created_at": "2026-09-29T10:22:14.723187+00:00",
        "difficulty": "principiant"
    },
    {
        "id": "dffee2f6-f0e6-4b07-bb61-c01753a6fa3b",
        "img": null,
        "url": null,
        "name": "Comprar el pa i dolços al forn",
        "type": "forn",
        "content": "Demana barres de pa, pataquetes o pastes típiques, pregunta quins productes estan acabats de traure del forn i paga.",
        "category": "escenari",
        "metadata": {
            "icon": "🥖",
            "color": "#F7D070",
            "scenario": "forn",
            "bgIllustration": "#FCF6E5",
            "character_role": "Forner",
            "initial_prompt": "Hola, bon dia! Què et pose? Acabem de traure una fornada de barres i també tenim coques de llanda calentes."
        },
        "xp_earned": 15,
        "created_at": "2026-09-29T10:37:03.145654+00:00",
        "difficulty": "principiant"
    },
    {
        "id": "d221f87f-186f-42cc-9c99-ac32cd87f820",
        "img": null,
        "url": null,
        "name": "Comprar fruita al mercat central",
        "type": "mercat",
        "content": "Practica com demanar fruita, preguntar el preu i pagar en una parada de mercat.",
        "category": "escenari",
        "metadata": {
            "icon": "🍊",
            "color": "#FFD98A",
            "voice": "lluc",
            "scenario": "mercat",
            "character": "Vicent, venedor del mercat",
            "objectius": [
                "Saluda a Vicent i pregunta com va tot.",
                "Demana un quilo de taronges o una altra fruita.",
                "Pregunta el preu o demana el canvi.",
                "Paga, dona les gràcies i acomiada't."
            ],
            "background": "/images/market.jpg",
            "section_name": "El Mercat",
            "system_prompt": "Ets Vicent, un venedor amable d'un mercat valencià. Mantín una conversa natural per ajudar la persona a comprar fruita, verdura o ingredients. Usa vocabulari viu del mercat (parada, quilo, fresc, canvi) i valencià general. Adapta frases, velocitat i vocabulari al nivell de l'aprenent: principiant usa frases breus; intermedi amplia preguntes; avançat usa registre espontani. No faces lliçons llargues: respon com Vicent i, si cal, corregeix suaument amb un exemple. Avalua si la resposta està per sota, al nivell o per damunt del seu nivell. El teu objectiu és que continue la conversa.",
            "bgIllustration": "#FFF3CC",
            "character_role": "Venedor del mercat",
            "initial_prompt": "Bon dia! Què et pose hui? Tenim unes taronges boníssimes."
        },
        "xp_earned": 15,
        "created_at": "2026-09-29T08:13:41.031677+00:00",
        "difficulty": "principiant"
    },
    {
        "id": "1783e443-3c75-4ddf-8147-f56f9a5a725b",
        "img": null,
        "url": null,
        "name": "Primer dia a l'oficina",
        "type": "oficina",
        "content": "Presenta't als teus companys, demana indicacions sobre el lloc de treball i les tasques bàsiques.",
        "category": "escenari",
        "metadata": {
            "icon": "💻",
            "color": "#BDE9E8",
            "voice": "lluc",
            "scenario": "oficina",
            "character": "Joan, company d'oficina",
            "objectius": [
                "Saluda a Joan i pregunta com està.",
                "Pregunta per la reunió o les tasques d'avui.",
                "Demana ajuda o un aclariment sobre un tema.",
                "Confirma el que has de fer i acomiada't."
            ],
            "background": "/images/office.jpg",
            "section_name": "L'Oficina",
            "system_prompt": "Ets Joan, un company d'una oficina moderna. Conversa sobre reunions, tasques i horaris en valencià. Adapta't al nivell i corregeix amb tacte.",
            "bgIllustration": "#E2F5F4",
            "character_role": "Company de feina",
            "initial_prompt": "Hola! Benvingut a l'equip. Jo sóc en Marc. Si necessites qualsevol cosa amb l'ordinador o els accessos, dis-me'l."
        },
        "xp_earned": 15,
        "created_at": "2026-09-29T08:13:41.031677+00:00",
        "difficulty": "principiant"
    },
    {
        "id": "1c36a205-94be-4334-87c4-1cebcc8ba85a",
        "img": null,
        "url": null,
        "name": "Revisió del cotxe al taller mecànic",
        "type": "taller",
        "content": "Explica una avaria o soroll estrany al cotxe, pregunta pel cost de la reparació i concreta quan estarà llest.",
        "category": "escenari",
        "metadata": {
            "icon": "🔧",
            "color": "#A0B2C6",
            "scenario": "taller",
            "bgIllustration": "#EBF1F6",
            "character_role": "Mecànic en cap",
            "initial_prompt": "Hola! Dis-me, què li passa al vehicle? Fa algun soroll estrany en frenar o se t'ha encés algun testimoni al quadre?"
        },
        "xp_earned": 30,
        "created_at": "2026-09-29T10:39:11.286316+00:00",
        "difficulty": "intermedi"
    },
    {
        "id": "ac633087-2d6d-4746-949f-901be5449fca",
        "img": null,
        "url": null,
        "name": "Demanar informació a l'oficina de turisme",
        "type": "turisme",
        "content": "Pregunta per monuments d'interés, rutes a peu, recomanacions locals i horaris de museus.",
        "category": "escenari",
        "metadata": {
            "icon": "🗺️",
            "color": "#9AD0EC",
            "voice": "gina",
            "scenario": "turisme",
            "character": "Laura, guia turística",
            "objectius": [
                "Saluda a Laura i digues què busques.",
                "Demana una recomanació de lloc per a visitar.",
                "Pregunta horaris, preus o com arribar-hi.",
                "Dona les gràcies i acomiada't."
            ],
            "background": "/images/tourism.jpg",
            "section_name": "Oficina de Turisme",
            "system_prompt": "Ets Laura, una guia turística simpàtica de l'Oficina de Turisme de València. Ajuda la persona a descobrir la ciutat en valencià: recomana monuments, museus, platges i festes populars; explica horaris, preus i com arribar-hi; i pregunta què li agradaria visitar. Usa vocabulari turístic viu (visita guiada, entrada, horari, plaça, monument, platja, mapa, follet) i valencià general. Adapta't al nivell de l'aprenent: principiant usa frases breus i clares; intermedi amplia amb preguntes; avançat usa registre espontani. No faces guies llargues: respon com Laura i, si cal, corregeix suaument amb un exemple. Avalua si la resposta està per sota, al nivell o per damunt del seu nivell. El teu objectiu és que continue la conversa.",
            "bgIllustration": "#E4F3FB",
            "character_role": "Guia de l'oficina de turisme",
            "initial_prompt": "Hola, bon dia! Benvingut a la ciutat. Busques informació sobre llocs d'interés, o t'agradaria alguna recomanació per a visitar hui?"
        },
        "xp_earned": 25,
        "created_at": "2026-09-29T08:13:41.031677+00:00",
        "difficulty": "intermedi"
    },
    {
        "id": "cd809f6e-a233-4030-892f-45907219fd77",
        "img": null,
        "url": "/audio/Audio_A1.mp3",
        "name": "Simulacre Oral A1: Presentació personal i entorn quotidià",
        "type": "jqcv_a1_oral",
        "content": "Simulacre de prova oral bàsica. Fes una presentació senzilla sobre tu mateix: nom, procedència, professió o estudis, família i aficions quotidianes.",
        "category": "examen",
        "metadata": {
            "exam": {
                "body": "JQCV",
                "areas": [
                    {
                        "n": 1,
                        "audio": true,
                        "intro": "Escoltaràs una sèrie d'àudios dos vegades, amb una pausa d'un minut entre cada audició. Només hi ha una resposta correcta per a cada enunciat.",
                        "title": "Comprensió oral",
                        "weight": 25,
                        "duration": "15 minuts",
                        "exercises": [
                            {
                                "n": 1,
                                "kind": "choice",
                                "questions": [
                                    {
                                        "n": 1,
                                        "answer": "a",
                                        "prompt": "Com va Anna al treball?",
                                        "options": [
                                            {
                                                "key": "a",
                                                "image": "/exams/a1-juny-2026/e1-q1-a.jpg"
                                            },
                                            {
                                                "key": "b",
                                                "image": "/exams/a1-juny-2026/e1-q1-b.jpg"
                                            },
                                            {
                                                "key": "c",
                                                "image": "/exams/a1-juny-2026/e1-q1-c.jpg"
                                            }
                                        ]
                                    },
                                    {
                                        "n": 2,
                                        "answer": "a",
                                        "prompt": "Quin producte està d'oferta?",
                                        "options": [
                                            {
                                                "key": "a",
                                                "image": "/exams/a1-juny-2026/e1-q2-a.jpg"
                                            },
                                            {
                                                "key": "b",
                                                "image": "/exams/a1-juny-2026/e1-q2-b.jpg"
                                            },
                                            {
                                                "key": "c",
                                                "image": "/exams/a1-juny-2026/e1-q2-c.jpg"
                                            }
                                        ]
                                    },
                                    {
                                        "n": 3,
                                        "answer": "b",
                                        "prompt": "A quina hora és la reunió?",
                                        "options": [
                                            {
                                                "key": "a",
                                                "image": "/exams/a1-juny-2026/e1-q3-a.jpg"
                                            },
                                            {
                                                "key": "b",
                                                "image": "/exams/a1-juny-2026/e1-q3-b.jpg"
                                            },
                                            {
                                                "key": "c",
                                                "image": "/exams/a1-juny-2026/e1-q3-c.jpg"
                                            }
                                        ]
                                    },
                                    {
                                        "n": 4,
                                        "answer": "a",
                                        "prompt": "Quant val la barra de pa?",
                                        "options": [
                                            {
                                                "key": "a",
                                                "image": "/exams/a1-juny-2026/e1-q4-a.jpg"
                                            },
                                            {
                                                "key": "b",
                                                "image": "/exams/a1-juny-2026/e1-q4-b.jpg"
                                            },
                                            {
                                                "key": "c",
                                                "image": "/exams/a1-juny-2026/e1-q4-c.jpg"
                                            }
                                        ]
                                    }
                                ],
                                "instructions": "Escolta els quatre àudios i tria l'opció correcta per a cada situació. Llig les preguntes abans de fer l'activitat."
                            },
                            {
                                "n": 2,
                                "kind": "binary",
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
                                        "n": 5,
                                        "answer": "V",
                                        "prompt": "Jaume s'alça a les 6:30 hores."
                                    },
                                    {
                                        "n": 6,
                                        "answer": "F",
                                        "prompt": "Jaume desdejuna en una cafeteria."
                                    },
                                    {
                                        "n": 7,
                                        "answer": "F",
                                        "prompt": "Jaume ha d'entrar a treballar a les 7:45 hores."
                                    },
                                    {
                                        "n": 8,
                                        "answer": "F",
                                        "prompt": "Jaume dina en el restaurant."
                                    },
                                    {
                                        "n": 9,
                                        "answer": "V",
                                        "prompt": "Jaume fa esport durant la setmana."
                                    },
                                    {
                                        "n": 10,
                                        "answer": "F",
                                        "prompt": "Jaume llig una novel·la abans de dormir."
                                    }
                                ],
                                "instructions": "Escolta la conversació entre dos amics i digues si les afirmacions són verdaderes (V) o falses (F)."
                            },
                            {
                                "n": 3,
                                "kind": "binary",
                                "options": [
                                    {
                                        "key": "si",
                                        "text": "Sí"
                                    },
                                    {
                                        "key": "no",
                                        "text": "No"
                                    }
                                ],
                                "questions": [
                                    {
                                        "n": 11,
                                        "image": "/exams/a1-juny-2026/e3-farina.jpg",
                                        "answer": "no",
                                        "prompt": "Farina"
                                    },
                                    {
                                        "n": 12,
                                        "image": "/exams/a1-juny-2026/e3-mantega.jpg",
                                        "answer": "no",
                                        "prompt": "Mantega"
                                    },
                                    {
                                        "n": 13,
                                        "image": "/exams/a1-juny-2026/e3-fruita-seca.jpg",
                                        "answer": "no",
                                        "prompt": "Fruita seca"
                                    },
                                    {
                                        "n": 14,
                                        "image": "/exams/a1-juny-2026/e3-llet.jpg",
                                        "answer": "si",
                                        "prompt": "Llet"
                                    },
                                    {
                                        "n": 15,
                                        "image": "/exams/a1-juny-2026/e3-aigua.jpg",
                                        "answer": "no",
                                        "prompt": "Aigua"
                                    },
                                    {
                                        "n": 16,
                                        "image": "/exams/a1-juny-2026/e3-ous.jpg",
                                        "answer": "si",
                                        "prompt": "Ous"
                                    },
                                    {
                                        "n": 17,
                                        "image": "/exams/a1-juny-2026/e3-oli.jpg",
                                        "answer": "no",
                                        "prompt": "Oli"
                                    },
                                    {
                                        "n": 18,
                                        "image": "/exams/a1-juny-2026/e3-sucre.jpg",
                                        "answer": "si",
                                        "prompt": "Sucre"
                                    }
                                ],
                                "instructions": "Escolta la conversació entre una mare i la seua filla, i marca «Sí» o «No» segons els ingredients que es mencionen."
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
                                "n": 4,
                                "kind": "match",
                                "options": [
                                    {
                                        "key": "a",
                                        "text": "El pròxim dilluns 15 de maig té una cita amb el doctor Forner a les 11:00 hores."
                                    },
                                    {
                                        "key": "b",
                                        "text": "Hola, Anna! Vols que quedem este cap de setmana?"
                                    },
                                    {
                                        "key": "c",
                                        "text": "Enhorabona, parella! Vos desitgem molta sort en esta nova etapa!"
                                    },
                                    {
                                        "key": "d",
                                        "text": "Bon dia, Joan! El dia 28 d'abril celebre el meu aniversari. Vols vindre?"
                                    },
                                    {
                                        "key": "e",
                                        "text": "Gràcies per enviar el seu currículum! Ens interessaria concertar una entrevista laboral amb vosté."
                                    },
                                    {
                                        "key": "f",
                                        "text": "Tinc una cita amb el dentiste. No podré acompanyar-te a comprar el regal de Toni. Podem quedar demà per a anar a comprar-lo?"
                                    }
                                ],
                                "questions": [
                                    {
                                        "n": 19,
                                        "answer": "b",
                                        "prompt": "Una quedada amb una amiga."
                                    },
                                    {
                                        "n": 20,
                                        "answer": "a",
                                        "prompt": "Una cita mèdica."
                                    },
                                    {
                                        "n": 21,
                                        "answer": "e",
                                        "prompt": "Una oferta de treball."
                                    },
                                    {
                                        "n": 22,
                                        "answer": "f",
                                        "prompt": "Un canvi de plans."
                                    },
                                    {
                                        "n": 23,
                                        "answer": "c",
                                        "prompt": "Una felicitació pel casament."
                                    },
                                    {
                                        "n": 24,
                                        "answer": "d",
                                        "prompt": "Una invitació a una festa."
                                    }
                                ],
                                "instructions": "Llig els missatges de text i relaciona'ls amb les situacions. Només hi ha un missatge correcte per a cada situació."
                            },
                            {
                                "n": 5,
                                "kind": "match",
                                "options": [
                                    {
                                        "key": "a",
                                        "sign": {
                                            "lines": [
                                                "Dies: del 2 al 5 d'octubre",
                                                "Horari: de 18:00 a 20:00 h",
                                                "Lloc: Casa de la Cultura"
                                            ],
                                            "title": "El color de les flors"
                                        }
                                    },
                                    {
                                        "key": "b",
                                        "sign": {
                                            "lines": [
                                                "Pa acabat de fer tots els dies.",
                                                "Horari: de 07:00 a 14:00 h"
                                            ],
                                            "title": "Forn d'Or"
                                        }
                                    },
                                    {
                                        "key": "c",
                                        "sign": {
                                            "lines": [
                                                "Camises, pantalons i faldes rebaixats al 50 % este mes."
                                            ],
                                            "title": "Botiga Via Moda"
                                        }
                                    },
                                    {
                                        "key": "d",
                                        "sign": {
                                            "lines": [
                                                "Recordeu llevar els taps de plàstic quan tireu els envasos de vidre."
                                            ],
                                            "title": "Contenidor verd"
                                        }
                                    },
                                    {
                                        "key": "e",
                                        "sign": {
                                            "lines": [
                                                "No pot passar a la consulta del metge si no apareix el seu número en la pantalla."
                                            ],
                                            "title": "Sala d'espera"
                                        }
                                    },
                                    {
                                        "key": "f",
                                        "sign": {
                                            "lines": [
                                                "Per 7 € al mes pots guardar les teues coses en un lloc segur."
                                            ],
                                            "title": "Vestidor per a adults"
                                        }
                                    }
                                ],
                                "questions": [
                                    {
                                        "n": 25,
                                        "answer": "f",
                                        "prompt": "Pots llogar una taquilla per menys de deu euros al mes."
                                    },
                                    {
                                        "n": 26,
                                        "answer": "b",
                                        "prompt": "En este establiment pots comprar menjar per a almorzar."
                                    },
                                    {
                                        "n": 27,
                                        "answer": "e",
                                        "prompt": "Has d'esperar que isca el teu número per a entrar a la consulta."
                                    },
                                    {
                                        "n": 28,
                                        "answer": "d",
                                        "prompt": "En este contenidor pots tirar una botella de vi."
                                    },
                                    {
                                        "n": 29,
                                        "answer": "c",
                                        "prompt": "En esta tenda la roba és més barata este mes."
                                    },
                                    {
                                        "n": 30,
                                        "answer": "a",
                                        "prompt": "L'exposició de pintura es pot visitar de vesprada."
                                    }
                                ],
                                "instructions": "Llig els rètols i relaciona'ls amb els enunciats. Només hi ha un rètol correcte per a cada enunciat."
                            },
                            {
                                "n": 6,
                                "kind": "match",
                                "options": [
                                    {
                                        "key": "a",
                                        "image": "/exams/a1-juny-2026/e6-a.jpg"
                                    },
                                    {
                                        "key": "b",
                                        "image": "/exams/a1-juny-2026/e6-b.jpg"
                                    },
                                    {
                                        "key": "c",
                                        "image": "/exams/a1-juny-2026/e6-c.jpg"
                                    },
                                    {
                                        "key": "d",
                                        "image": "/exams/a1-juny-2026/e6-d.jpg"
                                    },
                                    {
                                        "key": "e",
                                        "image": "/exams/a1-juny-2026/e6-e.jpg"
                                    },
                                    {
                                        "key": "f",
                                        "image": "/exams/a1-juny-2026/e6-f.jpg"
                                    }
                                ],
                                "questions": [
                                    {
                                        "n": 31,
                                        "answer": "e",
                                        "prompt": "Jugar a tenis."
                                    },
                                    {
                                        "n": 32,
                                        "answer": "b",
                                        "prompt": "Pintar un quadro."
                                    },
                                    {
                                        "n": 33,
                                        "answer": "f",
                                        "prompt": "Llegir un llibre."
                                    },
                                    {
                                        "n": 34,
                                        "answer": "d",
                                        "prompt": "Tocar el violí."
                                    },
                                    {
                                        "n": 35,
                                        "answer": "a",
                                        "prompt": "Jugar a futbol."
                                    },
                                    {
                                        "n": 36,
                                        "answer": "c",
                                        "prompt": "Fer ceràmica."
                                    }
                                ],
                                "instructions": "Llig els enunciats i relaciona'ls amb les imatges. Només hi ha una imatge correcta per a cada enunciat."
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
                                "n": 7,
                                "kind": "form",
                                "fields": [
                                    "Nom i cognoms",
                                    "Data de naixement",
                                    "Nacionalitat",
                                    "Adreça postal",
                                    "Professió o ocupació",
                                    "Població",
                                    "Adreça de correu electrònic",
                                    "Llengua materna",
                                    "Llengües en què vols llegir",
                                    "Temes d'interés",
                                    "Activitats que t'agradaria trobar en la biblioteca"
                                ],
                                "criteria": [
                                    {
                                        "items": [
                                            {
                                                "name": "Lèxic",
                                                "description": "Disposes de lèxic bàsic suficient per a resoldre la tasca."
                                            },
                                            {
                                                "name": "Estructures",
                                                "description": "Les frases del format demanat estan ben construïdes."
                                            },
                                            {
                                                "name": "Ortografia",
                                                "description": "Cometes errors ortogràfics mínims."
                                            }
                                        ],
                                        "title": "Competències lingüístiques"
                                    },
                                    {
                                        "items": [
                                            {
                                                "name": "Comprensibilitat i coherència",
                                                "description": "Les respostes són comprensibles i coherents."
                                            },
                                            {
                                                "name": "Adequació",
                                                "description": "Completes adequadament la tasca que se t'encomana."
                                            }
                                        ],
                                        "title": "Competències textuals"
                                    }
                                ],
                                "max_points": 15,
                                "instructions": "Acabes d'arribar a una ciutat nova i vols fer-te el carnet de la biblioteca local. Per a registrar-te, has d'omplir el formulari següent amb les teues dades."
                            }
                        ]
                    },
                    {
                        "n": 4,
                        "intro": "Esta àrea consta de dos parts. En la primera contestaràs les preguntes de la persona que t'examina. En la segona voràs una sèrie d'imatges amb preguntes sobre situacions de la vida quotidiana.",
                        "title": "Expressió i interacció orals",
                        "weight": 30,
                        "duration": "25 minuts",
                        "exercises": [
                            {
                                "n": 8,
                                "kind": "oral",
                                "proposals": [
                                    {
                                        "title": "Tu i el lloc on vius",
                                        "images": [
                                            {
                                                "image": "/exams/a1-juny-2026/o1-xiquets.jpg",
                                                "prompt": "A on estan els xiquets?"
                                            },
                                            {
                                                "image": "/exams/a1-juny-2026/o1-plat.jpg",
                                                "prompt": "Quins aliments hi ha en el plat?"
                                            },
                                            {
                                                "image": "/exams/a1-juny-2026/o1-juga.jpg",
                                                "prompt": "A què juga?"
                                            },
                                            {
                                                "image": "/exams/a1-juny-2026/o1-llimes.jpg",
                                                "prompt": "Quant valen les llimes?"
                                            },
                                            {
                                                "image": "/exams/a1-juny-2026/o1-instrument.jpg",
                                                "prompt": "Quin instrument està tocant?"
                                            }
                                        ],
                                        "questions": [
                                            "Com et diuen?",
                                            "D'a on eres?",
                                            "A on vius?",
                                            "Què t'agrada del lloc a on vius?",
                                            "Què és el que menys t'agrada del lloc a on vius?",
                                            "Quants anys tens?",
                                            "Treballes o estudies?",
                                            "De què treballes? / Què estudies?",
                                            "Quant de temps fa que treballes en este lloc? / Quant de temps fa que estudies això?",
                                            "Què és el que més t'agrada del teu treball? / Què és el que més t'agrada del que estudies?"
                                        ]
                                    },
                                    {
                                        "title": "El menjar",
                                        "images": [
                                            {
                                                "image": "/exams/a1-juny-2026/o2-hora.jpg",
                                                "prompt": "Quina hora és?"
                                            },
                                            {
                                                "image": "/exams/a1-juny-2026/o2-muntanya.jpg",
                                                "prompt": "Com està la muntanya?"
                                            },
                                            {
                                                "image": "/exams/a1-juny-2026/o2-casa.jpg",
                                                "prompt": "Quina part de la casa és esta?"
                                            },
                                            {
                                                "image": "/exams/a1-juny-2026/o2-persones.jpg",
                                                "prompt": "Què estan fent estes persones?"
                                            },
                                            {
                                                "image": "/exams/a1-juny-2026/o2-xiquet.jpg",
                                                "prompt": "Què té el xiquet en la mà?"
                                            }
                                        ],
                                        "questions": [
                                            "Què t'agrada cuinar en casa?",
                                            "Quin és el teu plat favorit?",
                                            "Quina fruita t'agrada més?",
                                            "Què t'agrada beure quan fa calor?",
                                            "Quin és el teu moment preferit del dia per a menjar?",
                                            "Quins plats d'un altre país t'agraden i per què?",
                                            "Menges de forma saludable o preferixes el menjar ràpid?",
                                            "A on fas la compra i què compres normalment?",
                                            "Quins productes locals compres i per què t'agraden?",
                                            "Quin és el teu bar o restaurant preferit?"
                                        ]
                                    },
                                    {
                                        "title": "Les llengües",
                                        "images": [
                                        ],
                                        "questions": [
                                            "Quantes llengües parles? Quines són?",
                                            "Quina és la teua llengua materna?",
                                            "I quina llengua parles amb els amics?",
                                            "I quina utilitzes en el treball?",
                                            "T'agrada aprendre noves llengües? Per què?",
                                            "Quines llengües t'agradaria aprendre?",
                                            "Què és el més difícil per a tu quan estudies una llengua?",
                                            "Qui és l'amic o familiar que parla més llengües i quines parla?",
                                            "Creus que és important aprendre llengües per a viatjar?",
                                            "Quan viatges a un país estranger, quina llengua utilitzes?"
                                        ]
                                    },
                                    {
                                        "title": "El temps lliure",
                                        "images": [
                                        ],
                                        "questions": [
                                            "Què fas en el teu temps lliure?",
                                            "Compartixes el temps lliure amb altres persones?",
                                            "Tens aficions? Quines?",
                                            "Quant de temps dediques a les teues aficions?",
                                            "Què fas normalment els caps de setmana?",
                                            "T'agrada aprendre activitats noves? Quines?",
                                            "Quines activitats no t'agraden?",
                                            "Quines activitats practiques a l'aire lliure?",
                                            "Fas esport? Quin?",
                                            "Quina activitat t'agradaria fer més a sovint?"
                                        ]
                                    }
                                ],
                                "instructions": "Tria una proposta i practica en veu alta. Intenta respondre cada pregunta amb una o dos frases completes."
                            }
                        ]
                    }
                ],
                "level": "A1",
                "session": "Juny 2026",
                "source_url": "https://jqcv.gva.es/documents/161863165/411097827/A1+juny+2026.pdf/1bbb808f-60ca-5204-3992-6213acfa0fa3"
            },
            "icon": "📋",
            "color": "#A5D6A7",
            "exam_body": "JQCV",
            "pdf_source": "https://jqcv.gva.es/documents/161863165/411097827/A1+juny+2026.pdf/1bbb808f-60ca-5204-3992-6213acfa0fa3",
            "bgIllustration": "#E8F5E9",
            "character_role": "Examinador oficial de la JQCV",
            "initial_prompt": "Bon dia! Anem a començar la prova oral de nivell A1. Per favor, presenta't breument: digues com et dius, d'on eres, a què et dediques i què t'agrada fer en el teu temps lliure.",
            "certificate_level": "A1",
            "time_limit_seconds": 120,
            "evaluation_criteria": [
                "lexic_basic_quotidia",
                "pronunciacio_clara",
                "estructures_simples",
                "comprensio_preguntes"
            ]
        },
        "xp_earned": 20,
        "created_at": "2026-09-29T10:59:45.437215+00:00",
        "difficulty": "principiant"
    },
    {
        "id": "cd62be79-ac29-4e65-bc96-0fabb792af52",
        "img": null,
        "url": null,
        "name": "Posició bàsica del pronom feble: davant vs. darrere del verb",
        "type": "posicio_pronoms",
        "content": "Diferenciació de posició: proclític amb formes conjugades habituals i enclític obligatori amb infinitiu, gerundi i imperatiu.",
        "category": "gramatica",
        "metadata": {
            "icon": "↔️",
            "color": "#C77DFF",
            "topic": "colocacio_pronoms_a2",
            "grammar_focus": [
                "proclisi_enclisi",
                "infinitiu_imperatiu"
            ],
            "bgIllustration": "#F7EDFF",
            "character_role": "Tutor de valencià",
            "initial_prompt": "Hola! Recorda: els pronoms van darrere només amb infinitiu, gerundi i imperatiu. Com transformes: \"Vull (fer això)\" -> \"Vull fer-___\"? I amb imperatiu positiu: \"(Obrir la finestra)\" -> \"Obri-___\"?",
            "expected_targets": [
                "fer-ho",
                "obri-la"
            ]
        },
        "xp_earned": 20,
        "created_at": "2026-09-29T10:49:19.439316+00:00",
        "difficulty": "principiant"
    },
    {
        "id": "77acac95-d8b0-4db7-b847-de5ee863a95e",
        "img": null,
        "url": null,
        "name": "El pronom neutre \"ho\": substituir idees i demostratius neutres",
        "type": "pronom_ho",
        "content": "Reconeixement i ús del pronom feble neutre \"ho\" per a substituir açò, això, allò o oracions completes.",
        "category": "gramatica",
        "metadata": {
            "icon": "💡",
            "color": "#FFD166",
            "topic": "pronom_neutre_ho",
            "grammar_focus": [
                "pronom_ho",
                "neutre_oracional"
            ],
            "bgIllustration": "#FFF7E6",
            "character_role": "Tutor de valencià",
            "initial_prompt": "Hola! Quan responem sobre una frase o idea sencera (com \"això\" o \"que plourà\"), usem \"ho\". Si et pregunte: \"Saps a quina hora arriba l'autobús?\", com respons breument: \"No, no ___ sé\"?",
            "expected_targets": [
                "no ho sé"
            ]
        },
        "xp_earned": 15,
        "created_at": "2026-09-29T10:49:19.439316+00:00",
        "difficulty": "principiant"
    },
    {
        "id": "b085d074-d7f9-47b4-bbb4-f078e0f3a99a",
        "img": null,
        "url": null,
        "name": "Pronoms personals reflexius i febles bàsics (em, et, es, ens, us)",
        "type": "pronoms_basics",
        "content": "Aprèn a utilitzar les formes bàsiques de 1a i 2a persona davant del verb i darrere d'un imperatiu o infinitiu (em/me, 'm, -me, ens/-nos).",
        "category": "gramatica",
        "metadata": {
            "icon": "👋",
            "color": "#BCE784",
            "topic": "pronoms_personals_a1",
            "grammar_focus": [
                "pronoms_personals",
                "posicio_verb"
            ],
            "bgIllustration": "#F3FBE8",
            "character_role": "Tutor de valencià",
            "initial_prompt": "Bon dia! Practiquem la presentació bàsica. Completa la frase: \"___ diuen Pau i visc a València\". I si em vols demanar ajuda amb un imperatiu, com dius: \"Ajuda___, per favor\"?",
            "expected_targets": [
                "Em diuen",
                "Ajuda'm / Ajuda-me"
            ]
        },
        "xp_earned": 15,
        "created_at": "2026-09-29T10:49:19.439316+00:00",
        "difficulty": "principiant"
    },
    {
        "id": "111a1adc-51d2-4a05-a8f9-5241deaa8af1",
        "img": null,
        "url": null,
        "name": "CD determinat bàsic: el, la, els, les i l'apostrofació",
        "type": "pronoms_cd",
        "content": "Substitució de coses conegudes pel complement directe determinat i ús bàsic de l'apòstrof davant o darrere de vocal.",
        "category": "gramatica",
        "metadata": {
            "icon": "🎯",
            "color": "#85E3FF",
            "topic": "cd_determinat_a1",
            "grammar_focus": [
                "el_la_els_les",
                "apostrof_pronom"
            ],
            "bgIllustration": "#EBFBFF",
            "character_role": "Tutor de valencià",
            "initial_prompt": "Hola! Anem a substituir objectes directes coneguts. Si et pregunte: \"Has vist el meu telèfon?\", com contestes dient \"Sí, ___ he vist\"? I si és \"Compraràs la camisa?\", com dius \"Sí, vaig a comprar-___\"?",
            "expected_targets": [
                "l'he vist",
                "comprar-la"
            ]
        },
        "xp_earned": 15,
        "created_at": "2026-09-29T10:49:19.439316+00:00",
        "difficulty": "principiant"
    },
    {
        "id": "b2d2f8c3-83a6-4b2b-9d0c-17918fa9a166",
        "img": null,
        "url": null,
        "name": "Combinació de pronoms febles i concordança de participi",
        "type": "pronoms_febles",
        "content": "Practica la substitució pronominal binària (CD determinat + CI) i la concordança obligatòria del participi quan el pronom acusatiu és de 3a persona (la, les, en).",
        "category": "gramatica",
        "metadata": {
            "icon": "🧩",
            "color": "#B39DDB",
            "topic": "sintaxi_i_morfologia",
            "grammar_focus": [
                "pronoms_febles_combinats",
                "concordanca_participi"
            ],
            "bgIllustration": "#EDE7F6",
            "character_role": "Assistent gramatical",
            "initial_prompt": "Hola! Anem a posar a prova la combinació de pronoms. Transforma aquesta frase substituint el complement directe i el complement indirecte: \"Vaig portar les claus a ma mare ahir\". Com quedaria amb els pronoms i la concordança correcta?",
            "expected_target": "Li les vaig portar / Vaig portar-li-les"
        },
        "xp_earned": 45,
        "created_at": "2026-09-29T10:40:31.548917+00:00",
        "difficulty": "avancat"
    }
]$data$::jsonb);

UPDATE public.resources r
SET id = c.id
FROM resources_catalog c
WHERE r.category = c.category
  AND r.type = c.type
  AND r.id <> c.id
  AND NOT EXISTS (SELECT 1 FROM public.resources x WHERE x.id = c.id);

INSERT INTO public.resources (id, name, type, url, content, metadata, created_at, xp_earned, difficulty, category, img)
SELECT id, name, type, url, content, metadata, created_at, xp_earned, difficulty, category, img FROM resources_catalog
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  type = EXCLUDED.type,
  url = EXCLUDED.url,
  content = EXCLUDED.content,
  metadata = EXCLUDED.metadata,
  created_at = EXCLUDED.created_at,
  xp_earned = EXCLUDED.xp_earned,
  difficulty = EXCLUDED.difficulty,
  category = EXCLUDED.category,
  img = EXCLUDED.img;

DELETE FROM public.resources
WHERE id NOT IN (SELECT id FROM resources_catalog);

DROP TABLE resources_catalog;

-- ============================================================
-- Origen: 20260929170000_exam_a2_juny_2026.sql
-- ============================================================
-- Examen interactiu A2 de la JQCV (juny 2026): afig o actualitza el recurs
-- 05bb0122-… (category 'examen') amb el contingut a metadata.exam i l'àudio
-- oficial de comprensió oral a url (frontend/public/audio/Audio_A2.mp3).
-- Font: https://jqcv.gva.es/va/nivell-a2
--
-- També posa títol al formulari de l'examen A1, que abans estava fixat en el codi.

INSERT INTO public.resources (id, name, type, url, content, metadata, created_at, xp_earned, difficulty, category, img)
SELECT id, name, type, url, content, metadata, created_at, xp_earned, difficulty, category, img
FROM jsonb_populate_record(NULL::public.resources, $data${
 "id": "05bb0122-5e71-445c-884a-f276ad03a591",
 "img": null,
 "url": "/audio/Audio_A2.mp3",
 "name": "Simulacre Oral A2: La meua rutina diària i el meu barri",
 "type": "jqcv_a2_monoleg",
 "content": "Prova d'expressió oral individual. Descriu detalladament la teua jornada habitual, els teus horaris i com és el teu barri o poble (serveis, comerços i transport).",
 "category": "examen",
 "metadata": {
  "icon": "🏘️",
  "color": "#80CBC4",
  "exam_body": "JQCV",
  "bgIllustration": "#E0F2F1",
  "character_role": "Examinador oficial de la JQCV",
  "initial_prompt": "Bon dia. Per a començar la tasca individual, descriu què sols fer un dia qualsevol de dilluns a divendres: a quina hora t'alces, com et desplaces i com és el lloc on vius. Tens un parell de minuts.",
  "certificate_level": "A2",
  "time_limit_seconds": 150,
  "evaluation_criteria": [
   "lexic_rutines_horaris",
   "us_connectors_temporals",
   "adjectivacio_descriptiva",
   "correccio_present_indicatiu"
  ],
  "exam": {
   "level": "A2",
   "session": "Juny 2026",
   "body": "JQCV",
   "source_url": "https://jqcv.gva.es/documents/161863165/165492618/A2+juny+2026.pdf/47ca9ce1-a5c4-ae0b-51a2-137be84c7488",
   "audio_source_url": "https://jqcv.gva.es/documents/161863165/411134096/2026+06_A2_VF1.mp3/454946c3-15df-66c7-89d8-45cd3e0f12eb",
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
         "prompt": "El contracte de bibliotecari serà per a tres anys.",
         "answer": "F"
        },
        {
         "n": 2,
         "prompt": "La gestió del fons bibliogràfic consistix exclusivament en el préstec de llibres.",
         "answer": "F"
        },
        {
         "n": 3,
         "prompt": "Entre les funcions que s'han de fer està l'atenció al públic.",
         "answer": "V"
        },
        {
         "n": 4,
         "prompt": "El coneixement d'idiomes es tindrà en compte per al lloc de treball.",
         "answer": "V"
        },
        {
         "n": 5,
         "prompt": "Les sol·licituds es presentaran en la biblioteca o s'enviaran per correu.",
         "answer": "F"
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
         "prompt": "Quant de temps fa que Carles col·labora amb l'associació?",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "Des de fa quasi un any."
          },
          {
           "key": "b",
           "text": "Des de fa un any."
          },
          {
           "key": "c",
           "text": "Des de fa dos anys."
          }
         ]
        },
        {
         "n": 7,
         "prompt": "Quines activitats fan en l'associació?",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "Només fan manualitats."
          },
          {
           "key": "b",
           "text": "Pinten i fan deures."
          },
          {
           "key": "c",
           "text": "Fan esport, ball i teatre."
          }
         ]
        },
        {
         "n": 8,
         "prompt": "A l'associació van...",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "dos dies a la setmana de vesprada."
          },
          {
           "key": "b",
           "text": "dos dies de vesprada al mes."
          },
          {
           "key": "c",
           "text": "els dies i les vesprades que volen."
          }
         ]
        },
        {
         "n": 9,
         "prompt": "Com pot ajudar Empar si no pot anar sempre a l'associació?",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "Pot anar a l'associació algun dia i donar diners."
          },
          {
           "key": "b",
           "text": "Ha d'anar tots els dies i donar diners tots els mesos."
          },
          {
           "key": "c",
           "text": "Pot ajudar un dia en els preparatius de l'obra de teatre."
          }
         ]
        },
        {
         "n": 10,
         "prompt": "Empar decidix finalment...",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "ajudar totes les vesprades."
          },
          {
           "key": "b",
           "text": "donar diners tots els mesos."
          },
          {
           "key": "c",
           "text": "anar a vore com treballen."
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
       "instructions": "Llig estos set consells per a adaptar-te amb facilitat als canvis d'hora i relaciona cada consell amb un dels enunciats. Hi ha dos consells que no es corresponen amb cap enunciat.",
       "options_title": "Consells per a adaptar-te amb facilitat als canvis d'hora",
       "options": [
        {
         "key": "a",
         "text": "Per a adaptar-te de la millor manera possible al canvi d'hora, és recomanable que els dies previs intentes gitar-te uns 15 o 20 minuts més tard del teu horari habitual. Això ajuda a fer que el canvi no siga tan brusc."
        },
        {
         "key": "b",
         "text": "Quan t'alces, obri les finestres o ix a caminar una estona. Esta exposició a la llum ajuda a despertar el cervell i a reduir la sensació de somnolència durant el dia."
        },
        {
         "key": "c",
         "text": "Si, a més d'això, reduïxes el consum de cafeïna, sobretot, de vesprada i de nit, descansaràs millor. Opta per beure infusions abans d'anar a dormir per a facilitar un descans reparador."
        },
        {
         "key": "d",
         "text": "Així i tot, és possible que notes que et costa adaptar-te. No intentes canviar la rutina bruscament. Escalona els horaris de les menjades, les activitats i el descans gradualment durant els dies posteriors."
        },
        {
         "key": "e",
         "text": "Un altre consell essencial per a ajustar-te al canvi és fer esport. Tant eixir a caminar com fer estiraments suaus t'ajudarà a regular el son i a mantindre l'energia durant el dia."
        },
        {
         "key": "f",
         "text": "Quan hi ha un canvi d'hora, és habitual sentir-se més cansat o dispers. Com ho podem resoldre? Una manera ben senzilla és beure aigua regularment per a mantindre alerta el cos i la ment."
        },
        {
         "key": "g",
         "text": "Per últim, no oblides que el canvi d'hora pot generar xicotetes alteracions de l'humor durant dos o tres dies. Pren-t'ho amb calma, ja que el cos necessita temps per a ajustar-se al canvi."
        }
       ],
       "questions": [
        {
         "n": 11,
         "prompt": "Exposar-te a la llum natural t'ajudarà a reduir la son durant el dia.",
         "answer": "b"
        },
        {
         "n": 12,
         "prompt": "Fer activitat física moderada també t'ajudarà a dormir millor.",
         "answer": "e"
        },
        {
         "n": 13,
         "prompt": "Abans de gitar-te, intenta consumir begudes que no siguen excitants.",
         "answer": "c"
        },
        {
         "n": 14,
         "prompt": "Recorda hidratar-te bé per a estar actiu i evitar l'esgotament.",
         "answer": "f"
        },
        {
         "n": 15,
         "prompt": "Regula l'horari d'anar a dormir uns dies abans del canvi perquè no siga tan brusc.",
         "answer": "a"
        }
       ]
      },
      {
       "n": 4,
       "kind": "binary",
       "instructions": "Llig el text i contesta si les afirmacions són verdaderes (V) o falses (F).",
       "reading": {
        "title": "El canvi d'armari: un joc semestral",
        "paragraphs": [
         "Cada any, quan arriba la tardor i les temperatures baixen, faig el canvi d'armari amb tranquil·litat. Primer revise tota la roba i el calçat. Separe tot el que ja no utilitze, i ho done o ho regale a familiars o amics. Sempre hi ha algú que ho aprofita. Eliminar el que no necessite m'ajuda a guanyar espai i a tindre l'armari més ordenat. Si hi ha una peça de roba que no m'he posat en molt de temps, accepte que no la tornaré a usar i la regale. M'agrada ser sincer amb mi mateix i no guardar coses «per si de cas». Així em sent millor.",
         "Abans de traure la roba d'hivern, classifique la d'estiu per categories. Agrupe les camisetes, les camises fines, els polos i els pantalons curts. També ordene les sandàlies i les sabatilles, i ajunte els complements, com els banyadors, les gorres o les ulleres de sol.",
         "Si no tinc prou espai en els armaris, gaste caixes transparents per a vore el contingut ràpidament. També utilitze bosses de buit per a reduir el volum de la roba. A vegades aprofite les maletes de viatge com a espai extra per a guardar la roba d'estiu, i sempre pose etiquetes per a saber què hi ha en cada caixa.",
         "Finalment, trac la roba d'hivern, l'estenc per a airejar-la i l'endemà l'organitze en l'armari. Quan acabe, em sent molt satisfet."
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
         "prompt": "La roba i el calçat que ja no utilitza els guarda per a l'any següent.",
         "answer": "F"
        },
        {
         "n": 17,
         "prompt": "La roba d'hivern la trau després de guardar la d'estiu.",
         "answer": "V"
        },
        {
         "n": 18,
         "prompt": "Utilitza caixes transparents perquè la roba es conserva millor.",
         "answer": "F"
        },
        {
         "n": 19,
         "prompt": "Les maletes les utilitza per a traure la roba més ràpidament.",
         "answer": "F"
        },
        {
         "n": 20,
         "prompt": "Abans de guardar la roba d'hivern en l'armari l'aireja.",
         "answer": "V"
        }
       ]
      },
      {
       "n": 5,
       "kind": "choice",
       "instructions": "Llig el text i marca l'opció correcta. Només hi ha una resposta correcta per a cada pregunta.",
       "reading": {
        "title": "Els veïns no es poden triar, però pots millorar la convivència",
        "paragraphs": [
         "Hi ha qui diu que tindre bons veïns és com guanyar la loteria. Quan vas a viure a un lloc nou, no saps què et tocarà, però sempre tens l'esperança que la sort t'acompanye. No els pots triar ni «fer matx» com en una aplicació, però sí que pots intentar portar-te bé perquè la convivència siga més agradable… o, com a mínim, suportable.",
         "En una comunitat, el respecte és la base. Xicotets gestos com no fer soroll a hores intempestives, arreplegar els excrements del teu gos, no posar en marxa la llavadora a primera hora del matí o no ocupar places d'aparcament d'altres veïns poden marcar la diferència. No cal ser el veí ideal; només un poquet empàtic i respectuós.",
         "Un punt clau? La comunicació. Si hi ha algun malentés, val més parlar-ho amb calma abans que la tensió es convertisca en un silenci incòmode (o en notes enganxades en el portal, que mai són una bona idea). A vegades molts conflictes veïnals es podrien evitar amb una conversació a temps i un to adequat.",
         "També ajuda el fet de conéixer un poc els veïns: saber qui viu dalt i qui viu baix o qui és eixa veïna que té un gos. No cal ser els millors amics, però saludar, interessar-se de tant en tant o, per què no?, compartir alguna activitat comunitària (una festa de barri, una junta que no siga un drama, un berenar popular…), pot ajudar a crear vincles més positius.",
         "I quan la convivència es complica sempre podem recórrer a la mediació. Molts ajuntaments oferixen servicis gratuïts per a resoldre conflictes entre veïns abans que la cosa vaja a més. Perquè conviure no vol dir aguantar-ho tot, però tampoc anar a la guerra per qualsevol cosa. Al cap i a la fi, una comunitat és com una xicoteta societat, i cada u té el seu paper. Tu no pots triar qui viu al costat, però sí com convius."
        ]
       },
       "questions": [
        {
         "n": 21,
         "prompt": "Tindre bons veïns és com guanyar la loteria...",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "perquè és molt ràpid fer amistats."
          },
          {
           "key": "b",
           "text": "perquè no saps els veïns que et tocaran."
          },
          {
           "key": "c",
           "text": "perquè els pots triar abans de mudar-te."
          }
         ]
        },
        {
         "n": 22,
         "prompt": "Les xicotetes accions que milloren la convivència...",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "t'ajudaran a obtindre el premi de veí ideal."
          },
          {
           "key": "b",
           "text": "són una mostra de respecte necessària."
          },
          {
           "key": "c",
           "text": "són, entre altres coses, posar la llavadora de bon matí."
          }
         ]
        },
        {
         "n": 23,
         "prompt": "La comunicació entre els veïns i veïnes...",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "és important per a resoldre conflictes."
          },
          {
           "key": "b",
           "text": "s'ha de fer amb notes en el portal."
          },
          {
           "key": "c",
           "text": "no ajuda a resoldre els problemes."
          }
         ]
        },
        {
         "n": 24,
         "prompt": "Alguns gestos que poden ajudar a millorar la convivència són...",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "saludar i convidar a dinar el dia de la benvinguda."
          },
          {
           "key": "b",
           "text": "ser educat i fer alguna activitat conjunta."
          },
          {
           "key": "c",
           "text": "acompanyar el veí a passejar el gos."
          }
         ]
        },
        {
         "n": 25,
         "prompt": "Si hi ha problemes de convivència...",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "es pot sol·licitar ajuda en els servicis de l'ajuntament."
          },
          {
           "key": "b",
           "text": "la situació s'ha de donar per perduda i conviure així."
          },
          {
           "key": "c",
           "text": "una solució és traslladar-te perquè no pots triar amb qui vius."
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
       "title": "Nota per al tauler d'anuncis",
       "instructions": "En el centre a on estudies valencià es convoquen a final de curs els exàmens oficials de diverses llengües. El dia que et presentares al nivell A2 et vas deixar la motxilla amb tot el material que portaves dins. Després de preguntar al professorat i a la secretaria sense trobar-la, has decidit escriure una nota en el tauler d'anuncis del centre en què descrius com és la motxilla i el material que contenia.",
       "min_words": 80,
       "max_words": 100,
       "words": [
        "estoig",
        "bolígraf",
        "llibreta",
        "martell",
        "llapis",
        "grapadora",
        "grua",
        "agenda",
        "quadern",
        "roda"
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
         "title": "Monòleg · Festes i celebracions",
         "duration": "3 minuts",
         "questions": [
          "Quina és la teua festa preferida de l'any?",
          "Celebres el teu aniversari? Com el celebres?",
          "Com t'agraden més les celebracions? Amb molta gent o amb poca?",
          "Conta alguna celebració que haja sigut molt especial per a tu."
         ],
         "images": []
        },
        {
         "title": "Diàleg · I tu, a on vols viure?",
         "duration": "4 minuts",
         "questions": [],
         "images": [],
         "intro": "Mantín un diàleg amb una altra persona. Defén la teua proposta, evita les respostes massa curtes i participa com en una conversa habitual: les intervencions han de ser equilibrades.",
         "roles": [
          {
           "name": "Persona A",
           "text": "Tu i la teua parella (persona B) heu decidit anar a viure junts. Després de pensar quina seria la millor opció, has decidit proposar-li comprar un pis en la ciutat. Explica-li que has trobat el pis ideal i descriu-li'l. Intenta convéncer la teua parella que és la millor opció per a viure."
          },
          {
           "name": "Persona B",
           "text": "Tu i la teua parella (persona A) heu decidit anar a viure junts. Després de pensar quina seria la millor opció, has decidit proposar-li comprar una casa en el poble. Explica-li que has trobat la casa ideal i descriu-li-la. Intenta convéncer la teua parella que és la millor opció per a viure."
          }
         ]
        }
       ]
      }
     ]
    }
   ]
  }
 },
 "xp_earned": 25,
 "created_at": "2026-09-29T11:50:49.61654+00:00",
 "difficulty": "principiant"
}$data$::jsonb)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  type = EXCLUDED.type,
  url = EXCLUDED.url,
  content = EXCLUDED.content,
  metadata = EXCLUDED.metadata,
  created_at = EXCLUDED.created_at,
  xp_earned = EXCLUDED.xp_earned,
  difficulty = EXCLUDED.difficulty,
  category = EXCLUDED.category,
  img = EXCLUDED.img;

UPDATE public.resources
SET metadata = jsonb_set(metadata, '{exam,areas,2,exercises,0,title}', to_jsonb('Biblioteca municipal · Sol·licitud de carnet'::text))
WHERE id = 'cd809f6e-a233-4030-892f-45907219fd77'
  AND metadata #>> '{exam,areas,2,exercises,0,kind}' = 'form';

-- ============================================================
-- Origen: 20260929180000_exam_a2_oct2025.sql
-- ============================================================
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

-- ============================================================
-- Origen: 20260929190000_exam_a2_oct2024.sql
-- ============================================================
-- Examen interactiu A2 de la JQCV (octubre 2024) com a recurs de category 'examen'.
-- Contingut a metadata.exam; àudio de comprensió oral a url, convertit a MP3 des del
-- WAV oficial (frontend/public/audio/Audio_A2_oct2024.mp3). Font: https://jqcv.gva.es/documents/161863165/165492618/A2+octubre+2024.pdf/b24c9792-10c7-b49a-11dc-67af15731f5d

INSERT INTO public.resources (id, name, type, url, content, metadata, xp_earned, difficulty, category)
SELECT id, name, type, url, content, metadata, xp_earned, difficulty, category
FROM jsonb_populate_record(NULL::public.resources, $data${
 "id": "7badb167-bf96-5a83-90de-596e5b6ff1c7",
 "name": "Simulacre A2: octubre 2024",
 "type": "jqcv_a2_oct2024",
 "category": "examen",
 "difficulty": "principiant",
 "xp_earned": 25,
 "url": "/audio/Audio_A2_oct2024.mp3",
 "content": "Examen oficial A2 de la JQCV (octubre 2024): comprensió oral i escrita autocorregibles, redacció i pràctica oral.",
 "metadata": {
  "icon": "🎬",
  "color": "#B39DDB",
  "exam_body": "JQCV",
  "certificate_level": "A2",
  "exam": {
   "level": "A2",
   "session": "Octubre 2024",
   "body": "JQCV",
   "source_url": "https://jqcv.gva.es/documents/161863165/165492618/A2+octubre+2024.pdf/b24c9792-10c7-b49a-11dc-67af15731f5d",
   "audio_source_url": "https://jqcv.gva.es/documents/161863165/167041107/A2+octubre+2024.wav/2bb99b23-7cf8-b1ec-5eff-d79119ec895d",
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
         "prompt": "La bicicleta és un bon mitjà de transport, però a vegades, si no la reparem, deixem d'utilitzar-la.",
         "answer": "V"
        },
        {
         "n": 2,
         "prompt": "La mecànica de la bicicleta és complexa i no podrem fer-li ajustos mínims sense l'ajuda d'un especialista.",
         "answer": "F"
        },
        {
         "n": 3,
         "prompt": "Necessitarem comprar molt de material divers per a poder fer-li alguns ajustos i reparacions.",
         "answer": "F"
        },
        {
         "n": 4,
         "prompt": "Si t'agrada aprendre a reparar bicicletes, pots inscriure't en el curs, encara que no tingues 18 anys.",
         "answer": "F"
        },
        {
         "n": 5,
         "prompt": "Les classes tenen lloc un dia a la setmana durant el mes de desembre en horari de vesprada.",
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
         "prompt": "Quant va pagar Carla per l'entrada al cine?",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "El mateix que tot el món."
          },
          {
           "key": "b",
           "text": "Quatre euros perquè Carla és estudiant."
          },
          {
           "key": "c",
           "text": "Huit euros perquè no té descompte d'estudiant."
          }
         ]
        },
        {
         "n": 7,
         "prompt": "Quin tipus de pel·lícula va vore Carla?",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "Una pel·lícula d'humor."
          },
          {
           "key": "b",
           "text": "Una pel·lícula d'acció."
          },
          {
           "key": "c",
           "text": "Una pel·lícula dramàtica."
          }
         ]
        },
        {
         "n": 8,
         "prompt": "Va anar Pau, finalment, amb el grup d'amics a la platja?",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "Es va incorporar més tard al grup."
          },
          {
           "key": "b",
           "text": "No, no va poder anar a la platja."
          },
          {
           "key": "c",
           "text": "Sí que va anar a la platja."
          }
         ]
        },
        {
         "n": 9,
         "prompt": "Què va passar amb l'experiència gastronòmica d'Òscar en el restaurant?",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "Li va agradar el menjar i les vistes."
          },
          {
           "key": "b",
           "text": "Li va agradar el menjar però no les vistes."
          },
          {
           "key": "c",
           "text": "Li van agradar les vistes però no el menjar."
          }
         ]
        },
        {
         "n": 10,
         "prompt": "Òscar proposa a Carla...",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "anar a la muntanya a fer senderisme."
          },
          {
           "key": "b",
           "text": "dinar en un restaurant luxós."
          },
          {
           "key": "c",
           "text": "fer una ruta ciclista per la Mariola."
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
       "instructions": "Llig estos set consells per a llogar pisos turístics de manera segura i responsable i relaciona cada consell amb un dels enunciats. Hi ha dos consells que no es corresponen amb cap enunciat.",
       "options_title": "Consells per a llogar pisos turístics de manera segura i responsable",
       "options": [
        {
         "key": "a",
         "text": "El preu ha d'estar en concordança amb la qualitat de la vivenda que llogarem. Per esta raó, has de desconfiar de les ofertes massa econòmiques."
        },
        {
         "key": "b",
         "text": "No hem de negociar directament amb el propietari les condicions o ofertes que no estiguen prèviament pactades amb l'agència de lloguer."
        },
        {
         "key": "c",
         "text": "Informa't de la normativa relativa a apartaments d'ús vacacional en la comunitat autònoma a on el llogaràs, perquè és obligatori que estiguen degudament registrats."
        },
        {
         "key": "d",
         "text": "Exigix sempre el contracte. Guarda tota la documentació, inclosa la publicitat i el resguard de la reserva o senyal abonats. Informa't sobre les possibilitats de cancel·lació de la reserva."
        },
        {
         "key": "e",
         "text": "Si pagues a través d'un web, verifica que es tracta d'un web segur. Una vegada fet el pagament, exigix sempre una factura desglossada."
        },
        {
         "key": "f",
         "text": "Sigues cívic, respecta el descans dels veïns i l'ús de zones comunes. Respecta les normes de convivència perquè no estàs a soles en l'edifici."
        },
        {
         "key": "g",
         "text": "En cas d'incompliment de l'acord, has de saber que tens drets. Acudix al teu organisme de consum o associació de consumidors i fes una reclamació."
        }
       ],
       "questions": [
        {
         "n": 11,
         "prompt": "No oblides que vius en una comunitat.",
         "answer": "f"
        },
        {
         "n": 12,
         "prompt": "Les característiques del pis determinaran el preu.",
         "answer": "a"
        },
        {
         "n": 13,
         "prompt": "Cal evitar parlar només amb l'amo del pis.",
         "answer": "b"
        },
        {
         "n": 14,
         "prompt": "És important tindre un document amb informació contractual.",
         "answer": "d"
        },
        {
         "n": 15,
         "prompt": "Assegura't que no t'enganyen a l'hora de pagar.",
         "answer": "e"
        }
       ]
      },
      {
       "n": 4,
       "kind": "binary",
       "instructions": "Llig el text i contesta si les afirmacions són verdaderes (V) o falses (F).",
       "reading": {
        "title": "Com ha canviat la nostra forma de vestir al llarg dels anys",
        "paragraphs": [
         "Des dels principis del temps, el vestuari ens ha acompanyat com una segona pell. En un primer moment era per a protegir-nos de les baixes temperatures i el sol, però també per a expressar i mostrar qui som.",
         "La roba ens identifica, de manera que entre la classe social acomodada no reconeixem cap pedaç de roba per a reparar pantalons o camises, però sí en la classe obrera. A més, la gent més humil guarda la roba elegant per a ocasions especials, com els festius o simplement els diumenges.",
         "Les classes socials visten de manera diferent. És fàcil distingir el vestuari elegant, colorit i variat de l'amo, de la roba senzilla, obscura i repetitiva dels treballadors. Gorra, boina o copa: només amb el barret podem saber a quina classe social pertany.",
         "El davantal va deixar de ser roba de faena i es va convertir en una peça més, perquè com anem vestits també mostra els canvis socials. De fet, la consecució de drets i llibertats de la dona es va poder saber a partir de la roba que vestia. Fins al segle XX, la roba femenina era rígida i pesada. Si no, pregunteu a les falleres per la comoditat del seu vestuari.",
         "Les festivitats rescaten vestuaris que d'una altra manera estarien en desús i, a més, el convertixen en uniforme. La manera de vestir dona unitat a un grup, crea la nostra identitat o, almenys, la que somiem."
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
         "prompt": "La roba només servix per a protegir-nos de les temperatures extremes.",
         "answer": "F"
        },
        {
         "n": 17,
         "prompt": "Els treballadors guarden la roba elegant per a dies festius i esdeveniments especials.",
         "answer": "V"
        },
        {
         "n": 18,
         "prompt": "Treballadors i patrons utilitzen roba diferent, però porten el mateix tipus de barret.",
         "answer": "F"
        },
        {
         "n": 19,
         "prompt": "La roba femenina ha patit pocs canvis al llarg dels anys, ja que no ha progressat gens la societat.",
         "answer": "F"
        },
        {
         "n": 20,
         "prompt": "El tipus de roba que portem fa que ens sentim part d'un grup i, al mateix temps, mostra la nostra personalitat.",
         "answer": "V"
        }
       ]
      },
      {
       "n": 5,
       "kind": "choice",
       "instructions": "Llig el text i marca l'opció correcta. Només hi ha una resposta correcta per a cada pregunta.",
       "reading": {
        "title": "Putxero en l'estiu, sí o no?",
        "paragraphs": [
         "Un dia de fred i, en arribar a casa, t'espera el perol de putxero. És açò el més paregut al paradís? No en tinc proves, però tampoc dubtes. El putxero és un plat típic de la cuina valenciana. La seua olor és sinònim de casa i la seua degustació és capaç d'alçar l'ànim a qualsevol.",
         "Antigament este plat era típic del dia de Nadal. Per sort, ja no està reservat només a eixa data, i qualsevol dia et pot esperar en casa este regal per al paladar. Els elements comuns en totes les cases són l'ús de verdures, llegums i carns. Però el que està clar si preguntes és que el preferit és el que fa la iaia.",
         "Ara bé, recapitulem: «era típic del dia de Nadal». Encara que hi ha un dia concret en què és tradició tindre'l a taula, entenem que és un plat que fa que entrem en calor de manera automàtica qualsevol dia de l'any. Però açò no pot significar que a partir del moment que les temperatures pugen hem de deixar de disfrutar-lo.",
         "A mesura que s'acosta l'estiu, la humitat impregna l'ambient i la suor es convertix en un complement més del nostre vestuari. L'aire condicionat, el ventilador, un palmito o qualsevol paper que et faça aire passen a ser els teus aliats. I vas a la cuina i preguntes: «què hi ha per a dinar?», i et responen que hi ha putxero. Silenci.",
         "L'opinió social està dividida davant d'esta qüestió. Uns fixen el mes de maig com a data límit per a servir-lo a taula, uns pocs s'atrevixen a dir que pel febrer ja pesa el plat, però és cert que l'opinió més sostinguda per la població valenciana assenyala que qualsevol dia és vàlid per a fer putxero. Ara bé, l'elecció de menjar putxero en estiu corre a compte de cada u, en funció del temps que pugues esperar per a degustar el següent putxero."
        ]
       },
       "questions": [
        {
         "n": 21,
         "prompt": "El putxero pot aconseguir que...",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "no tingues ganes de fer res més després."
          },
          {
           "key": "b",
           "text": "pugues superar millor un dia gelat."
          },
          {
           "key": "c",
           "text": "només arribar a casa vullgues fugir."
          }
         ]
        },
        {
         "n": 22,
         "prompt": "Tots els putxeros...",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "es fan el dia de Nadal."
          },
          {
           "key": "b",
           "text": "tenen llegums, verdures i carn."
          },
          {
           "key": "c",
           "text": "es fan per a regalar-los a algú."
          }
         ]
        },
        {
         "n": 23,
         "prompt": "El putxero és un dinar...",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "que només podem menjar en Nadal."
          },
          {
           "key": "b",
           "text": "que només podem menjar quan fa fred."
          },
          {
           "key": "c",
           "text": "que podem menjar sempre que vullguem."
          }
         ]
        },
        {
         "n": 24,
         "prompt": "Quan s'aproxima l'estiu...",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "el putxero és el plat predilecte de molts."
          },
          {
           "key": "b",
           "text": "la humitat se suporta millor amb un putxero."
          },
          {
           "key": "c",
           "text": "s'agraïx que hi haja aire condicionat o ventiladors."
          }
         ]
        },
        {
         "n": 25,
         "prompt": "L'elecció de menjar putxero en l'estiu...",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "està condicionada per la temperatura corporal."
          },
          {
           "key": "b",
           "text": "està condicionada per les ganes de menjar-ne."
          },
          {
           "key": "c",
           "text": "està condicionada pel pes corporal."
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
       "title": "Missatge a una amiga",
       "instructions": "Una amiga teua es vol canviar de pis i de barri; està cansada del rebombori de la zona centre. Per esta raó t'ha demanat que li expliques com és la zona a on tu vius i amb quins servicis compta per a estudiar eixa opció. Envia-li un missatge a on descrigues les característiques del teu barri i els servicis que oferix perquè ella es puga decidir.",
       "min_words": 80,
       "max_words": 100,
       "words": [
        "botiga",
        "metro",
        "botella",
        "carrer",
        "parc",
        "auricular",
        "aparcament",
        "col·legi",
        "hospital",
        "estoig"
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
         "title": "Monòleg · Viatges",
         "duration": "3 minuts",
         "questions": [
          "De tots els viatges que has fet, quin és el que més t'ha marcat?",
          "Quines característiques o fets el feren especial?",
          "Quina ciutat et faria il·lusió visitar? Per què?",
          "Amb qui viatges habitualment? T'agradaria viatjar a soles?"
         ],
         "images": []
        },
        {
         "title": "Diàleg · Plans per al dissabte",
         "duration": "4 minuts",
         "questions": [],
         "images": [],
         "intro": "Mantín un diàleg amb una altra persona. Defén la teua proposta, evita les respostes massa curtes i participa com en una conversa habitual: les intervencions han de ser equilibrades.",
         "roles": [
          {
           "name": "Persona A",
           "text": "Després d'una setmana molt llarga, ha arribat el dissabte. Tens ganes de fer alguna activitat amb la persona B, però estàs esgotat/da i vols fer alguna cosa relaxada. Proposa a la persona B anar al cine esta nit. Explica-li quina pel·lícula vols vore i per què. Intenta convéncer-la que és la millor opció per a hui."
          },
          {
           "name": "Persona B",
           "text": "Després d'una setmana molt llarga, ha arribat el dissabte. Tens ganes de fer alguna activitat amb la persona A, i després de tant de treballar, necessites diversió. Proposa a la persona A anar de festa. Explica-li què vols fer i per què. Intenta convéncer-la que és la millor opció per a hui."
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

-- ============================================================
-- Origen: 20260929200000_exam_a2_oct2023.sql
-- ============================================================
-- Examen interactiu A2 de la JQCV (octubre 2023) com a recurs de category 'examen'.
-- Contingut a metadata.exam; àudio de comprensió oral a url, convertit a MP3 des del
-- WAV oficial (frontend/public/audio/Audio_A2_oct2023.mp3). Font: https://jqcv.gva.es/documents/161863165/165492618/A2+octubre+2023.pdf/698bb3af-756e-f279-9d00-22e515f7f0e0

INSERT INTO public.resources (id, name, type, url, content, metadata, xp_earned, difficulty, category)
SELECT id, name, type, url, content, metadata, xp_earned, difficulty, category
FROM jsonb_populate_record(NULL::public.resources, $data${
 "id": "f270a4bc-fea4-515f-95cf-06618a15cae1",
 "name": "Simulacre A2: octubre 2023",
 "type": "jqcv_a2_oct2023",
 "category": "examen",
 "difficulty": "principiant",
 "xp_earned": 25,
 "url": "/audio/Audio_A2_oct2023.mp3",
 "content": "Examen oficial A2 de la JQCV (octubre 2023): comprensió oral i escrita autocorregibles, redacció i pràctica oral.",
 "metadata": {
  "icon": "🚲",
  "color": "#90CAF9",
  "exam_body": "JQCV",
  "certificate_level": "A2",
  "exam": {
   "level": "A2",
   "session": "Octubre 2023",
   "body": "JQCV",
   "source_url": "https://jqcv.gva.es/documents/161863165/165492618/A2+octubre+2023.pdf/698bb3af-756e-f279-9d00-22e515f7f0e0",
   "audio_source_url": "https://jqcv.gva.es/documents/161863165/167041107/A2+octubre+2023.wav/7f8959bf-e63d-5ed6-67bc-812e66c03c9e",
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
       "instructions": "Escolta l'àudio i contesta si les afirmacions són verdaderes (V) o falses (F). Abans llig les preguntes.",
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
         "prompt": "La iniciativa «Un barri més viu» es va crear l'any 2017.",
         "answer": "F"
        },
        {
         "n": 2,
         "prompt": "La primera acció del projecte va ser preguntar a la gent que viu en els barris.",
         "answer": "V"
        },
        {
         "n": 3,
         "prompt": "La gent major del barri té unes necessitats que s'han de tindre en compte.",
         "answer": "F"
        },
        {
         "n": 4,
         "prompt": "Entre les propostes que ha fet la població està construir un mercat.",
         "answer": "V"
        },
        {
         "n": 5,
         "prompt": "Esta iniciativa no busca atraure veïnat nou, sinó que ningú se'n vaja.",
         "answer": "F"
        }
       ]
      },
      {
       "n": 2,
       "kind": "choice",
       "instructions": "Escolta l'àudio i tria l'opció correcta. Només hi ha una resposta correcta per a cada pregunta. Abans llig les preguntes.",
       "questions": [
        {
         "n": 6,
         "prompt": "A l'hora d'escollir una professió, un dels dubtes acostuma a ser si...",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "la faena estarà prop de casa."
          },
          {
           "key": "b",
           "text": "el sou serà suficient per a viure bé."
          },
          {
           "key": "c",
           "text": "serà una faena per a tota la vida."
          }
         ]
        },
        {
         "n": 7,
         "prompt": "Què és el primer que et pot ajudar a elegir la teua professió?",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "Parlar amb molta gent."
          },
          {
           "key": "b",
           "text": "Conéixer quina és la teua vocació."
          },
          {
           "key": "c",
           "text": "Aprendre a usar l'ordinador."
          }
         ]
        },
        {
         "n": 8,
         "prompt": "Teresa treballa de...",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "periodista."
          },
          {
           "key": "b",
           "text": "cambrera."
          },
          {
           "key": "c",
           "text": "professora."
          }
         ]
        },
        {
         "n": 9,
         "prompt": "Una de les passions de Teresa és...",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "anar de compres."
          },
          {
           "key": "b",
           "text": "cuidar mascotes."
          },
          {
           "key": "c",
           "text": "conéixer món."
          }
         ]
        },
        {
         "n": 10,
         "prompt": "Segons Teresa, què portem en la motxilla de la vida?",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "Vivències positives i negatives."
          },
          {
           "key": "b",
           "text": "Les nostres passions i emocions."
          },
          {
           "key": "c",
           "text": "Els llibres de l'escola."
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
       "instructions": "Llig estos set textos sobre el xef Ricard Camarena i relaciona cada text amb un dels enunciats. Hi ha dos textos que no es corresponen amb cap enunciat.",
       "options_title": "Ricard Camarena, un cuiner valencià de prestigi internacional",
       "options": [
        {
         "key": "a",
         "text": "Ricard és un cuiner inquiet, va deixar la música per a dedicar-se a la cuina. Va decidir canviar les partitures per les receptes, i les composicions musicals per les elaboracions gastronòmiques."
        },
        {
         "key": "b",
         "text": "En 2001 va agarrar el restaurant de la piscina de Barx, i va començar el seu estil de cuina, buscant en les arrels de les receptes tradicionals valencianes i en els productes típics valencians."
        },
        {
         "key": "c",
         "text": "Quan va aconseguir una bona clientela i una cuina més sòlida va decidir, juntament amb la seua dona, fer un gran pas i obrir a Gandia el restaurant Arrop, que té molt d'èxit."
        },
        {
         "key": "d",
         "text": "Prompte li van arribar els premis. En 2006, Arrop es convertix en Restaurant revelació, i un any més tard Ricard Camarena va ser considerat el millor cap de cuina, i també va aconseguir la primera estrela Michelin."
        },
        {
         "key": "e",
         "text": "En el Mercat de Colom, en la ciutat de València, Camarena té un espai d'investigació on treballa per a trobar noves receptes, i també oferix tallers per a donar formació a les persones aficionades a la cuina."
        },
        {
         "key": "f",
         "text": "El 2018 va aconseguir la desitjada segona estrela Michelin i un dels seus restaurants va ocupar l'onzena posició mundial gràcies al tractament i al protagonisme que el xef dona a les verdures."
        },
        {
         "key": "g",
         "text": "En 2023, Arrop se situa entre els 100 millors restaurants del món. Camarena atribuïx l'èxit a l'equip i a la seua dona; tots junts lluiten perquè el seu treball siga cada vegada millor."
        }
       ],
       "questions": [
        {
         "n": 11,
         "prompt": "Camarena creu en la importància del treball en equip i valora l'èxit del treball conjunt.",
         "answer": "g"
        },
        {
         "n": 12,
         "prompt": "La passió per la cuina li fa abandonar la passió musical anterior.",
         "answer": "a"
        },
        {
         "n": 13,
         "prompt": "Camarena vol ensenyar el que sap a la gent interessada en la cuina.",
         "answer": "e"
        },
        {
         "n": 14,
         "prompt": "La dona de Camarena es convertix en la seua sòcia i treballen en equip.",
         "answer": "c"
        },
        {
         "n": 15,
         "prompt": "Els inicis de la seua carrera tenen com a base la cuina valenciana de sempre.",
         "answer": "b"
        }
       ]
      },
      {
       "n": 4,
       "kind": "binary",
       "instructions": "Llig el text i contesta si les afirmacions són verdaderes (V) o falses (F).",
       "reading": {
        "title": "Teatre i circ a Alacant",
        "paragraphs": [
         "El dissabte 3 de febrer, la coneguda companyia L'Horta Teatre torna a Alacant, al teatre Arniches, amb l'obra Els Villalonga. Es tracta d'una comèdia que reflexiona sobre els valors d'una família, i sobre la relació que els membres d'esta família tenen amb la felicitat. El pare, Paco Villalonga, està a punt de jubilar-se, i la filla no vol saber res del negoci familiar. Per això, el pare busca algú que continue el negoci, una obsessió que genera moltes situacions còmiques.",
         "El diumenge 4 de febrer, a les 19.30 hores, l'Institut Valencià de Cultura presenta una proposta de circ molt especial. Karl Stets, un artista nascut a Dinamarca, però establit a Barcelona des de fa sis anys, dirigix l'espectacle Cuerdo. Amb elements de dansa i acompanyat de titelles, Karl mostra al públic un espectacle que combina l'humor del pallasso amb la tensió d'una pel·lícula de terror.",
         "En paraules del director del teatre Arniches: «Pense que riure és també una bona manera d'atraure el públic. Per esta raó oferim un cap de setmana amb propostes de teatre i de circ plenes d'humor. I també d'emoció… que sempre està present en la nostra programació»."
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
         "prompt": "La companyia L'Horta Teatre mai ha actuat al teatre Arniches.",
         "answer": "F"
        },
        {
         "n": 17,
         "prompt": "La filla de Paco Villalonga no vol continuar el negoci familiar.",
         "answer": "V"
        },
        {
         "n": 18,
         "prompt": "L'artista Karl Stets va nàixer a Barcelona i ara viu a Dinamarca.",
         "answer": "F"
        },
        {
         "n": 19,
         "prompt": "L'espectacle Cuerdo transforma l'humor del pallasso en històries d'amor.",
         "answer": "F"
        },
        {
         "n": 20,
         "prompt": "El director del teatre pensa que les propostes d'humor agraden al públic.",
         "answer": "V"
        }
       ]
      },
      {
       "n": 5,
       "kind": "choice",
       "instructions": "Llig el text i marca l'opció correcta. Només hi ha una resposta correcta per a cada pregunta.",
       "reading": {
        "title": "València aposta per la bicicleta",
        "paragraphs": [
         "Estàs cansat dels embussos en els carrers de la ciutat i de no trobar aparcament? No tens temps per a anar al gimnàs? Estàs buscant una nova activitat física que et motive? Anar en bici és sinònim de vida saludable i de respecte pel medi ambient. Amb la bici circules al teu ritme, fas exercici, no contamines, no generes soroll i estalvies temps i diners.",
         "En els desplaçaments més llargs pots combinar la bicicleta amb el transport públic. Pedalejar a València és una bona opció per a realitzar les teues gestions i activitats diàries, des d'anar al treball fins a comprar el pa o quedar amb els amics i les amigues que no viuen en el teu barri. Perquè la bici està canviant la manera de moure'ns per la ciutat.",
         "La xarxa de comunicacions de la nostra ciutat està en augment. Hui en dia disposes de molts quilòmetres de carril bici que oferixen un espai confortable i segur per als i les ciclistes, una extensa oferta de punts d'aparcament, elements de senyalització, semàfors, i separadors per a protegir-te dels vehicles de motor. Però encara hem de millorar alguns aspectes. Per exemple, en alguns barris els carrils bici ocupen les voreres, i en altres zones els i les ciclistes i els i les vianants circulen pel mateix espai.",
         "Moure's per la ciutat és un dret de totes les persones. I fer-ho amb seguretat també. Més del 90 % dels ferits greus en accidents de trànsit formen part dels col·lectius més vulnerables: motoristes, vianants, ciclistes i persones conductores de patinets elèctrics. És per això que, si coneixem i seguim la normativa de trànsit, podrem aconseguir fer una ciutat més amable i segura.",
         "Per a garantir la bona convivència entre totes les persones que usen la via pública, et recomanem que circules amb precaució i que respectes la resta de persones que transiten pel teu entorn. I si cal, baixa de la bicicleta i camina. Disfrutem junts de l'espai públic. Veuràs com tots guanyem."
        ]
       },
       "questions": [
        {
         "n": 21,
         "prompt": "Utilitzar la bicicleta ajuda a...",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "cuidar el medi ambient."
          },
          {
           "key": "b",
           "text": "trobar faena fàcilment."
          },
          {
           "key": "c",
           "text": "arribar a temps al gimnàs."
          }
         ]
        },
        {
         "n": 22,
         "prompt": "L'ús de la bicicleta a València...",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "és la millor opció per als desplaçaments llargs."
          },
          {
           "key": "b",
           "text": "està substituint el transport públic."
          },
          {
           "key": "c",
           "text": "està canviant la mobilitat a la ciutat."
          }
         ]
        },
        {
         "n": 23,
         "prompt": "La xarxa de carrils bici...",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "encara té punts insegurs per als que l'usen."
          },
          {
           "key": "b",
           "text": "no disposa de senyals de trànsit."
          },
          {
           "key": "c",
           "text": "té pocs quilòmetres, però s'està ampliant."
          }
         ]
        },
        {
         "n": 24,
         "prompt": "Els accidents de trànsit...",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "han disminuït en els últims anys."
          },
          {
           "key": "b",
           "text": "afecten majoritàriament els col·lectius dels ciclistes i dels vianants."
          },
          {
           "key": "c",
           "text": "són causats sobretot pel col·lectiu dels motoristes."
          }
         ]
        },
        {
         "n": 25,
         "prompt": "Per a garantir un bon ús de la via pública, s'aconsella...",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "agarrar més la bicicleta i caminar."
          },
          {
           "key": "b",
           "text": "circular amb precaució i respecte."
          },
          {
           "key": "c",
           "text": "passejar i disfrutar de l'espai públic."
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
       "title": "WhatsApp a una amiga metja",
       "instructions": "És la primera vegada que viatges sense companyia a un altre país. Has fet una excursió a un paratge natural que ha durat tot el dia. A la nit, després de sopar, has començat a trobar-te molt malament. No saps on anar i els símptomes no milloren. Com que tens una amiga que és metja, has decidit escriure-li un WhatsApp en què li expliques de manera detallada què et passa, li demanes consell sobre què pots fer i li agraïxes l'ajuda.",
       "min_words": 80,
       "max_words": 100,
       "words": [
        "febra",
        "medicament",
        "malalt/a",
        "insolació",
        "estómac",
        "suar",
        "al·lèrgia",
        "inflamació",
        "dolor",
        "cama"
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
         "title": "Monòleg · Compres",
         "duration": "3 minuts",
         "questions": [
          "Quantes vegades sols anar a comprar? En quin moment del dia?",
          "Quines són les coses que més compres?",
          "Com pagues: en efectiu o d'una altra manera? Per què?",
          "Preferixes comprar per internet o en una botiga? Per què?",
          "Alguna vegada has comprat o venut alguna cosa en línia? Què era?"
         ],
         "images": []
        },
        {
         "title": "Diàleg · Vacances relaxades",
         "duration": "4 minuts",
         "questions": [],
         "images": [],
         "intro": "Mantín un diàleg amb una altra persona. Defén la teua proposta, evita les respostes massa curtes i participa com en una conversa habitual: les intervencions han de ser equilibrades.",
         "roles": [
          {
           "name": "Persona A",
           "text": "La persona B i tu acabeu d'arribar a un hotel de platja, on passareu una setmana de vacances. Després d'uns mesos de molta faena, tu necessites plans relaxats i descans. Proposa a la persona B quedar-vos a l'hotel i aprofitar els serveis que tenen. Explica-li quines activitats podeu fer. Intenta convéncer-la que és la millor opció per a una setmana de vacances relaxades."
          },
          {
           "name": "Persona B",
           "text": "La persona A i tu acabeu d'arribar a un hotel de platja, on passareu una setmana de vacances. Després d'uns mesos de molta faena, tu necessites plans d'aventura i desconnexió. Proposa a la persona A fer excursions per a conéixer el lloc i descobrir els punts d'interés que hi ha a la zona. Explica-li quines activitats podeu fer. Intenta convéncer-la que és la millor opció per a una setmana de vacances autèntiques."
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

-- ============================================================
-- Origen: 20260929210000_exam_b1_jun2026.sql
-- ============================================================
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

-- ============================================================
-- Origen: 20260929220000_exam_b1_oct2025.sql
-- ============================================================
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

-- ============================================================
-- Origen: 20260929230000_exam_b1_oct2024.sql
-- ============================================================
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

-- ============================================================
-- Origen: 20260929240000_exam_a1_scoring.sql
-- ============================================================
-- Puntuació oficial de l'examen A1 (JQCV): cada encert es multiplica per un factor
-- i el resultat s'arredonix. Per davall del mínim d'una àrea, quedes fora de la prova.
--   Àrea 1 (comprensió oral):    encerts × 1,667 → màxim 30 punts, apte amb 15 o més.
--   Àrea 2 (comprensió escrita): encerts × 1,389 → màxim 25 punts, apte amb 13 o més.
UPDATE public.resources
SET metadata = jsonb_set(
      jsonb_set(metadata, '{exam,areas,0,scoring}', '{"points_per_correct": 1.667, "max_points": 30, "pass_points": 15}'),
      '{exam,areas,1,scoring}', '{"points_per_correct": 1.389, "max_points": 25, "pass_points": 13}')
WHERE id = 'cd809f6e-a233-4030-892f-45907219fd77'
  AND metadata #>> '{exam,areas,0,n}' = '1'
  AND metadata #>> '{exam,areas,1,n}' = '2';

-- ============================================================
-- Origen: 20260929250000_exam_a2_scoring.sql
-- ============================================================
-- Puntuació oficial de l'Àrea 1 (comprensió oral) dels exàmens A2 (JQCV):
-- 10 preguntes, cada encert val 10 punts → màxim 100 punts, apte amb 50 o més
-- (5 encerts). Per davall del mínim, quedes fora de la prova.
-- S'aplica a tots els exàmens A2 (juny 2026, octubre 2025, 2024 i 2023).
UPDATE public.resources
SET metadata = jsonb_set(metadata, '{exam,areas,0,scoring}', '{"points_per_correct": 10, "max_points": 100, "pass_points": 50}')
WHERE category = 'examen'
  AND metadata #>> '{exam,level}' = 'A2'
  AND metadata #>> '{exam,areas,0,n}' = '1';

-- ============================================================
-- Origen: 20260929260000_exam_a2_area2_scoring.sql
-- ============================================================
-- Puntuació oficial de l'Àrea 2 (comprensió escrita) dels exàmens A2 (JQCV),
-- sobre 100 punts i amb un valor diferent per a cada exercici:
--   Exercici 3 (emparellar, 5 preguntes):     8 punts per encert → 40 punts.
--   Exercici 4 (verdader/fals, 5 preguntes):  6 punts per encert → 30 punts.
--   Exercici 5 (opció múltiple, 5 preguntes): 6 punts per encert → 30 punts.
-- Eliminatòria per si mateixa: apte amb 50 punts o més; de 0 a 49, quedes fora de la prova.
-- S'aplica a tots els exàmens A2 (juny 2026, octubre 2025, 2024 i 2023).
UPDATE public.resources
SET metadata = jsonb_set(metadata, '{exam,areas,1,scoring}',
      '{"points_per_exercise": {"3": 8, "4": 6, "5": 6}, "max_points": 100, "pass_points": 50}')
WHERE category = 'examen'
  AND metadata #>> '{exam,level}' = 'A2'
  AND metadata #>> '{exam,areas,1,n}' = '2';

-- ============================================================
-- Origen: 20260929270000_exam_b1_area1_scoring.sql
-- ============================================================
-- Puntuació oficial de l'Àrea 1 (comprensió oral) dels exàmens B1 (JQCV),
-- sobre 100 punts i amb un valor diferent per a cada exercici:
--   Exercici 1 (verdader/fals, 5 preguntes):    6 punts per encert → 30 punts.
--   Exercici 2 (opció múltiple, 5 preguntes):   6 punts per encert → 30 punts.
--   Exercici 3 (ordenar 5 dels 7 enunciats):    8 punts per encert → 40 punts.
-- En l'exercici 3, els dos enunciats «No surt» (resposta 'x') es corregixen en
-- pantalla però no puntuen: només compten els 5 que apareixen en l'àudio.
-- Eliminatòria per si mateixa: apte amb 50 punts o més; de 0 a 49, quedes fora de la prova.
-- S'aplica a tots els exàmens B1 (juny 2026, octubre 2025 i 2024).
UPDATE public.resources
SET metadata = jsonb_set(
      jsonb_set(metadata, '{exam,areas,0,scoring}',
        '{"points_per_exercise": {"1": 6, "2": 6, "3": 8}, "max_points": 100, "pass_points": 50}'),
      '{exam,areas,0,exercises,2,questions}',
      (SELECT jsonb_agg(CASE WHEN q->>'answer' = 'x' THEN q || '{"scored": false}' ELSE q END ORDER BY i)
       FROM jsonb_array_elements(metadata #> '{exam,areas,0,exercises,2,questions}') WITH ORDINALITY AS t(q, i)))
WHERE category = 'examen'
  AND metadata #>> '{exam,level}' = 'B1'
  AND metadata #>> '{exam,areas,0,n}' = '1'
  AND metadata #>> '{exam,areas,0,exercises,2,n}' = '3';

-- ============================================================
-- Origen: 20260929280000_exam_b1_area2_scoring.sql
-- ============================================================
-- Puntuació oficial de l'Àrea 2 (comprensió escrita) dels exàmens B1 (JQCV),
-- sobre 100 punts i amb un valor diferent per a cada exercici:
--   Exercici 4 (verdader/fals, 5 preguntes):              8 punts per encert → 40 punts.
--   Exercici 5 (emparellar, 5 preguntes amb 7 opcions):  12 punts per encert → 60 punts.
-- Eliminatòria per si mateixa: apte amb 50 punts o més; de 0 a 49, quedes fora de la prova.
-- S'aplica a tots els exàmens B1 (juny 2026, octubre 2025 i 2024).
UPDATE public.resources
SET metadata = jsonb_set(metadata, '{exam,areas,1,scoring}',
      '{"points_per_exercise": {"4": 8, "5": 12}, "max_points": 100, "pass_points": 50}')
WHERE category = 'examen'
  AND metadata #>> '{exam,level}' = 'B1'
  AND metadata #>> '{exam,areas,1,n}' = '2';

-- ============================================================
-- Origen: 20260929290000_exam_b1_e7_image_text.sql
-- ============================================================
-- Contingut de les infografies de l'exercici 7 dels exàmens B1 (resources.metadata
-- ...exercises[].image_text): l'avaluador amb IA no veu la imatge, però l'enunciat
-- demana tindre-la en compte. Transcrit de frontend/public/exams/b1-*/e7-*.jpg.
UPDATE public.resources
SET metadata = jsonb_set(metadata, '{exam,areas,2,exercises,1,image_text}', to_jsonb(
  'Infografia «Rutina diària per a reduir l''estrés». Consells: no utilitzes el mòbil només despertar-te; respiració conscient; estiraments; pensa en les coses positives del dia; ordena les prioritats; música suau o relaxant.'::text))
WHERE category = 'examen'
  AND metadata #>> '{exam,areas,2,exercises,1,image}' = '/exams/b1-juny-2026/e7-estres.jpg';

UPDATE public.resources
SET metadata = jsonb_set(metadata, '{exam,areas,2,exercises,1,image_text}', to_jsonb(
  'Infografia «Desconnecta (de veritat) en el viatge», sobre la pantalla d''un mòbil. Consells: desactiva les notificacions; allunya''t del mòbil; deixa el carregador en casa; utilitza un rellotge tradicional.'::text))
WHERE category = 'examen'
  AND metadata #>> '{exam,areas,2,exercises,1,image}' = '/exams/b1-octubre-2025/e7-desconnecta.jpg';

UPDATE public.resources
SET metadata = jsonb_set(metadata, '{exam,areas,2,exercises,1,image_text}', to_jsonb(
  'Infografia «Saps com estalviar aigua en la faena?» (campanya «Polits + Sans»). Consells: tanca bé l''aixeta (una gota per segon representa 30 litres diaris); no utilitzes el vàter com si fora una paperera; utilitza el polsador de descàrrega curta de la cisterna del vàter; avisa a manteniment si detectes fugues o avaries en aixetes, cisternes o depòsits.'::text))
WHERE category = 'examen'
  AND metadata #>> '{exam,areas,2,exercises,1,image}' = '/exams/b1-octubre-2024/e7-aigua.jpg';

