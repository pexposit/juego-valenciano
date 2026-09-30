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
