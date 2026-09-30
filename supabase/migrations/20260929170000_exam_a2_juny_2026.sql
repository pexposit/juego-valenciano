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
