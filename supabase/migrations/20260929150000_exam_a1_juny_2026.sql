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
