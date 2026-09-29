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
