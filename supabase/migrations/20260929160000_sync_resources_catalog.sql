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
