-- Examen interactiu B2 de la JQCV (octubre 2024) com a recurs de category 'examen'.
-- Contingut a metadata.exam, amb les cinc àrees del B2 i la puntuació oficial de la guia de la
-- prova (comprensió oral 8 i 12 punts per encert; comprensió escrita 3,3 i 8,5; estructures 5 i 5;
-- mínim del 40 % en cada àrea i del 50 % en l'oral). Les respostes són les de la plantilla
-- oficial que inclou el quadern. Àudio de comprensió oral a url, convertit a MP3 des de l'oficial
-- (frontend/public/audio/Audio_B2_oct2024.mp3). Font: https://jqcv.gva.es/documents/161863165/165492631/B2+octubre+2024.pdf/105b72bf-ffed-fda4-ee6e-d884261ab41c

INSERT INTO public.resources (id, name, type, url, content, metadata, xp_earned, difficulty, category)
SELECT id, name, type, url, content, metadata, xp_earned, difficulty, category
FROM jsonb_populate_record(NULL::public.resources, $data${
 "id": "fe2d494d-ca44-52ca-ab7e-83194bac839a",
 "name": "Simulacre B2: octubre 2024",
 "type": "jqcv_b2_oct2024",
 "category": "examen",
 "difficulty": "B2",
 "xp_earned": 40,
 "url": "/audio/Audio_B2_oct2024.mp3",
 "content": "Examen oficial B2 de la JQCV (octubre 2024): comprensió oral i escrita i estructures lingüístiques autocorregibles, dos redaccions i pràctica oral.",
 "metadata": {
  "icon": "🍄",
  "color": "#FFCC80",
  "exam_body": "JQCV",
  "certificate_level": "B2",
  "exam": {
   "level": "B2",
   "session": "Octubre 2024",
   "body": "JQCV",
   "source_url": "https://jqcv.gva.es/documents/161863165/165492631/B2+octubre+2024.pdf/105b72bf-ffed-fda4-ee6e-d884261ab41c",
   "audio_source_url": "https://jqcv.gva.es/documents/161863165/167041107/B2+octubre+2024.mp3/5a52792f-02bb-2345-4d72-b205f31959ff",
   "pass_rule": "Per a ser APTE cal una puntuació global mínima de 60 sobre 100. Les àrees valen un 20 % (comprensió oral), un 20 % (comprensió escrita), un 15 % (estructures lingüístiques), un 20 % (expressió escrita) i un 25 % (expressió oral), i en cada una cal arribar al mínim: el 40 % en les quatre primeres i el 50 % en l'expressió oral.",
   "areas": [
    {
     "n": 1,
     "title": "Comprensió oral",
     "weight": 20,
     "duration": "20 minuts",
     "audio": true,
     "intro": "A continuació escoltaràs dos àudios. Els escoltaràs dos vegades, amb una pausa d'un minut entre cada audició, perquè assegures les respostes. Només hi ha una resposta correcta per a cada enunciat.",
     "scoring": {
      "points_per_exercise": {
       "1": 8,
       "2": 12
      },
      "max_points": 100,
      "pass_points": 40
     },
     "exercises": [
      {
       "n": 1,
       "kind": "choice",
       "instructions": "A continuació escoltaràs una entrevista a María José Mora, directora de Dansa València. Llig les preguntes i tria l'opció correcta en cada cas. Només hi ha una resposta correcta per a cada pregunta.",
       "questions": [
        {
         "n": 1,
         "prompt": "Com es definix María José Mora?",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "Com una persona que coneix la cultura des de diferents punts de vista."
          },
          {
           "key": "b",
           "text": "Com una persona capaç de treballar en diversos àmbits culturals."
          },
          {
           "key": "c",
           "text": "Una professional d'arts escèniques, directora d'una escola de dansa."
          }
         ]
        },
        {
         "n": 2,
         "prompt": "Per a Mora, la dansa...",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "és una expressió artística i humana a través del cos."
          },
          {
           "key": "b",
           "text": "és un art, com agarrar un pinzell per a pintar un quadro."
          },
          {
           "key": "c",
           "text": "és una disciplina específica que requerix un esforç físic."
          }
         ]
        },
        {
         "n": 3,
         "prompt": "Què és Dansa València segons la directora?",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "Un festival de dansa que se celebra a la Comunitat Valenciana i altres comunitats autònomes."
          },
          {
           "key": "b",
           "text": "Un festival que servix de punt de trobada per a creadors i professionals de la dansa."
          },
          {
           "key": "c",
           "text": "Un festival de la ciutat de València, ja que depén de la Conselleria d'Educació, Universitats i Ocupació."
          }
         ]
        },
        {
         "n": 4,
         "prompt": "Es pot dir que València és a escala estatal un referent de la dansa?",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "Sí, per circumstàncies que estan relacionades amb la qualitat de vida de València."
          },
          {
           "key": "b",
           "text": "Sí, per diversos motius, encara que queden moltes coses a fer."
          },
          {
           "key": "c",
           "text": "Sí, per haver creat Dansa València des de l'Institut Valencià de Cultura."
          }
         ]
        },
        {
         "n": 5,
         "prompt": "Quina de les propostes següents definix millor l'objectiu d'Impulsa la Dansa?",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "Organitzar, únicament, programes d'assaig per a companyies teatrals que permeten formar millor els professionals de la dansa i els facilite una eixida laboral."
          },
          {
           "key": "b",
           "text": "Organitzar residències per a fer proves teatrals perquè puguen provar llums, l'obertura del teló, i com i a on situaran la il·luminació o el so."
          },
          {
           "key": "c",
           "text": "Descentralitzar la creació artística, donar suport a les companyies i proporcionar formació als gestors municipals, facilitant espais adequats per a la creació i l'assaig."
          }
         ]
        }
       ]
      },
      {
       "n": 2,
       "kind": "binary",
       "instructions": "Llig els enunciats i relaciona'ls amb els consells per a collir bolets que escoltaràs en les audicions. Ordena'ls en el mateix orde en què apareixen en l'àudio. Hi ha dos enunciats que no corresponen a cap consell: marca «No surt» en eixos dos i numera la resta de l'1 al 5.",
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
         "n": 6,
         "prompt": "No es poden agarrar totes les varietats de bolets encara que siguen comestibles: uns perquè són difícils d'identificar i uns altres perquè són indigestos.",
         "answer": "5"
        },
        {
         "n": 7,
         "prompt": "Cada boletaire no podrà superar els sis quilograms diaris. A més, la comercialització dels bolets recol·lectats està prohibida.",
         "answer": "4"
        },
        {
         "n": 8,
         "prompt": "Les ferramentes principals que necessitem per a recol·lectar bolets són els mapes, ja que ens ajudaran a orientar-nos i, en cas de pèrdua, saber tornar a casa.",
         "answer": "x",
         "scored": false
        },
        {
         "n": 9,
         "prompt": "La recol·lecció no es pot dur mai a terme amb un utensili que no permeta que les espores dels bolets s'escampen. Per això, no utilitzarem bosses de plàstic.",
         "answer": "2"
        },
        {
         "n": 10,
         "prompt": "És important saber el temps que farà, la zona a on recol·lectarem els bolets, vestir-nos amb un equipament adequat i dur menjar i aigua.",
         "answer": "1"
        },
        {
         "n": 11,
         "prompt": "Si som respectuosos amb el medi ambient, afavorirem que tornen a eixir bolets cada temporada, i per tant en podrem recol·lectar tots els anys.",
         "answer": "x",
         "scored": false
        },
        {
         "n": 12,
         "prompt": "No hem d'agarrar els bolets que no sapiem segur que són aptes per al consum. N'hi ha de tòxics, i per tant n'hem de fer una identificació prèvia.",
         "answer": "3"
        }
       ]
      }
     ]
    },
    {
     "n": 2,
     "title": "Comprensió escrita",
     "weight": 20,
     "duration": "2 h 10 min (amb les àrees 3 i 4)",
     "scoring": {
      "points_per_exercise": {
       "3": 3.3,
       "4": 8.5
      },
      "max_points": 100,
      "pass_points": 40
     },
     "exercises": [
      {
       "n": 3,
       "kind": "match",
       "instructions": "Llig atentament el text següent i completa'l amb les propostes de la graella. Tin en compte que hi ha tres propostes que no has d'utilitzar.",
       "reading": {
        "title": "Ikebana: la naturalesa com a mestra",
        "paragraphs": [
         "Pot dir-se que, com el paisatgisme, l'ikebana és una forma de creació estètica basada en la composició d'espècies vegetals, inspirada en elles i en les seues formes. És, (13) ______, una disciplina artística. Encara que tradicionalment s'ha traduït per “art floral del Japó”, les flors no en són la matèria (14) ______. Participen també, i en una forma molt rellevant, les branques, les tiges i les fulles, així com les corfes, els fruits, els capolls i, fins i tot, les (15) ______ en alguns tipus de plantes… La denominació ikebana, que significa literalment “mantindre vives les flors”, al·ludix a la tècnica a través de la qual, una vegada tallades les branques, les flors, etc., i feta la disposició en un recipient, la seua vida es prolonga per un temps. Els vegetals continuen vius, tenen l'aparença de continuar vivint, és a dir, transmeten l'essència del que està viu a qui els contempla. Este és el secret del magnetisme dels arranjaments, el gran atractiu que exercixen, especialment quan es poden vore en directe.",
         "A més d'una disciplina artística, és una forma de (16) ______ que comporta un ritu propi, una pràctica (17) ______. Hi confluïxen, per tant, tres elements: a) la naturalesa física de les formes vegetals, b) els principis compositius de les arts plàstiques i c) un cert sentiment de les coses sagrades o de veneració cap a la vida.",
         "Una altra denominació per a este art, (18) ______, és kadō (‘camí de les flors’). L'ikebana suggerix embarcar-se en una aventura en què el camí mateix és allò que oferix el sentit: caminar és la meta. Practicar l'ikebana significa romandre en un camí. La concentració profunda que (19) ______ la realització d'una disposició deté el temps. Aquells que seguixen este camí són capaços d'eixir de la quotidianitat i entrar en un temps diferent, meditatiu, i viure profundament el present. Un camí que s'incorpora a la pròpia vida, indefinidament, i pot dir-se que arriba a formar part d'u mateix. Este és el punt de vista zen.",
         "No hem d'entendre l'ikebana dins del que comunament anomenem decoració. La diferència principal entre un ikebana i un arranjament occidental és que en l'ikebana les branques i les flors no són sostingudes per un recipient en què reposen, (20) ______ se sostenen per si mateixes, es mantenen erectes, (21) ______, com si cresqueren, vives, en el recipient. Es tracta de reproduir l'essencial de les formes vives, la seua saba, la vitalitat de la seua energia.",
         "És un art efímer. Dura pocs dies abans de pansir-se. Expressa la transitorietat dels estats pels quals passa la vida dels sers. En l'ikebana, totes les fases de l'evolució del vegetal són valorades com una cosa substancial: naixement, floració i (22) ______. Presenten el futur, el present i el passat d'una composició (23) ______. Les tres fases del temps han d'estar, simultàniament, en l'arranjament: en forma de capolls o brots tendres, el futur; en forma de flors obertes i fulles (24) ______, el present, i, finalment, en forma de zones deteriorades, una miqueta seques o rosegades per algun xicotet insecte, el passat."
        ]
       },
       "options_title": "Propostes",
       "options": [
        {
         "key": "a",
         "text": "meditació"
        },
        {
         "key": "b",
         "text": "precedix"
        },
        {
         "key": "c",
         "text": "de fet"
        },
        {
         "key": "d",
         "text": "sinó que"
        },
        {
         "key": "e",
         "text": "fermes"
        },
        {
         "key": "f",
         "text": "labors"
        },
        {
         "key": "g",
         "text": "essencial"
        },
        {
         "key": "h",
         "text": "músties"
        },
        {
         "key": "i",
         "text": "viva"
        },
        {
         "key": "j",
         "text": "espiritual"
        },
        {
         "key": "k",
         "text": "per tant"
        },
        {
         "key": "l",
         "text": "desplegades"
        },
        {
         "key": "m",
         "text": "llavors"
        },
        {
         "key": "n",
         "text": "seguix"
        },
        {
         "key": "o",
         "text": "decadència"
        }
       ],
       "questions": [
        {
         "n": 13,
         "prompt": "Buit 13",
         "answer": "k"
        },
        {
         "n": 14,
         "prompt": "Buit 14",
         "answer": "g"
        },
        {
         "n": 15,
         "prompt": "Buit 15",
         "answer": "m"
        },
        {
         "n": 16,
         "prompt": "Buit 16",
         "answer": "a"
        },
        {
         "n": 17,
         "prompt": "Buit 17",
         "answer": "j"
        },
        {
         "n": 18,
         "prompt": "Buit 18",
         "answer": "c"
        },
        {
         "n": 19,
         "prompt": "Buit 19",
         "answer": "b"
        },
        {
         "n": 20,
         "prompt": "Buit 20",
         "answer": "d"
        },
        {
         "n": 21,
         "prompt": "Buit 21",
         "answer": "e"
        },
        {
         "n": 22,
         "prompt": "Buit 22",
         "answer": "o"
        },
        {
         "n": 23,
         "prompt": "Buit 23",
         "answer": "i"
        },
        {
         "n": 24,
         "prompt": "Buit 24",
         "answer": "l"
        }
       ]
      },
      {
       "n": 4,
       "kind": "match",
       "instructions": "A continuació coneixeràs set de les nostres escriptores. Relaciona cada text amb l'enunciat que li correspon. Hi ha tres enunciats que no corresponen a cap d'elles.",
       "options_title": "Enunciats",
       "options": [
        {
         "key": "a",
         "text": "Gràcies a les ferramentes digitals manté un diàleg amb el seu públic sobre el procés d'escriptura."
        },
        {
         "key": "b",
         "text": "Generà una obra epistolar remarcable que documenta la vida i política cortesanes."
        },
        {
         "key": "c",
         "text": "El conflicte bèl·lic suposa un trasbals per a la seua carrera literària i per a les tertúlies."
        },
        {
         "key": "d",
         "text": "Una part de la seua obra va poder escapar de les espurnes i va efectuar el camí de retorn."
        },
        {
         "key": "e",
         "text": "Per a ella, l'ús del valencià era un acte de reafirmació política i nacional."
        },
        {
         "key": "f",
         "text": "Va experimentar una metamorfosi lingüística quan descobrí el seu lloc d'origen."
        },
        {
         "key": "g",
         "text": "Ens han pervingut un centenar de mostres que confirmen, això sí, un domini de la tècnica."
        },
        {
         "key": "h",
         "text": "Hi ha tres eixos geogràfics des dels quals l'escriptora compon la seua obra lírica."
        },
        {
         "key": "i",
         "text": "S'inspira en les obres que ja ha llegit per a reescriure-les com a històries sobrenaturals."
        },
        {
         "key": "j",
         "text": "Subversiva en l'àmbit personal, també fou públicament una activista pels drets de les dones."
        }
       ],
       "questions": [
        {
         "n": 25,
         "prompt": "Només un fragment de poema s'ha conservat d'Amat al Aziz as-Sari- fa al-Husayniyya, el nom complet de la poeta que pertany a un grup de trenta-cinc poetes clàssiques d'Al-Àndalus, de les quals s'han conservat i identificat cent dos poemes, en molts casos poemes breus o només fragments. El rastre de les poetes andalusines es perd en les antologies. [...] Els seus versos seguixen el gènere clàssic oriental de la cassida, la combinació rítmica de síl·labes llargues i breus, en versos que aconseguixen la rima per la repetició de l'última consonant.",
         "answer": "g"
        },
        {
         "n": 26,
         "prompt": "Figura cabdal de la literatura de postguerra, Maria Beneyto va viure la seua infància a Madrid, i el castellà es convertí en la primera llengua que parlà. Als dotze anys tornà a València, i es convertí en poeta de la terra perquè se n'enamorà. «Per a mi, castellanoparlant, escriure en valencià és un acte d'amor a la terra», això escrivia a Joan Fuster, amic i confident, l'any 1951. Sempre fugí de polèmiques sobre les llengües que usava, sempre va defendre l'absoluta «llibertat del poeta».",
         "answer": "f"
        },
        {
         "n": 27,
         "prompt": "Maria Cambrils mai va defugir la confrontació d'idees ni la defensa de la classe obrera, i contribuí a construir un discurs feminista en defensa de la igualtat. Transgressora en la seua vida privada i pública, de formació autodidàctica, va aconseguir reunir una important biblioteca, traduí la pensadora marxista i feminista Alexandra Kollontai, llegia santa Teresa, es manifestà públicament a favor del sufragi femení, en contra de l'estalinisme, a favor de l'amor lliure, de l'escola laica, de la necessària organització de les dones en el si del socialisme, contra el clericalisme que constrenyia les dones, a favor de la democràcia com a marc polític.",
         "answer": "j"
        },
        {
         "n": 28,
         "prompt": "La cort de la reina Maria es convertix en un centre d'influència i un espai per a la promoció, especialment per a les dones. Va saber negociar amb els súbdits i servir els interessos de la Corona mentres el rei estava a Nàpols. Es mostrà partidària de la pau i del pacte. Però dura, justa i ferma. Treballadora incansable, amant dels llibres i de la música. Enèrgica i lleial. La correspondència de Maria de Castella s'inscriu en la producció documental de la Cancelleria de la Corona d'Aragó, i és una de les més belles i completes del segle XV de tota la Península.",
         "answer": "b"
        },
        {
         "n": 29,
         "prompt": "Maria Egual pertany a la noblesa guanyadora de la Batalla d'Almansa. Educada en un ambient refinat, en el si d'una família de la noblesa castellonenca. Poques coses canvien per a ella en acabar la Guerra de Successió. Obri els salons del palau i reprén la tertúlia literària, imitant els salons de París, els de Madame de Rambouillet. Comença a escriure prompte i, després de tota una vida escrivint, mana que cremen els seus manuscrits. Els manuscrits que se salven del foc, una tercera part, acaben en una subhasta de Sotheby's en el 1976. Els adquirix la Biblioteca Nacional.",
         "answer": "d"
        },
        {
         "n": 30,
         "prompt": "A Quart de Poblet l'invadí la passió per escriure i per les històries fantàstiques, una vocació que ha permés a Laura Gallego vendre més de dos milions de llibres. Escriu el que a ella li agradaria llegir, i ha aconseguit connectar amb un públic adolescent, que la seguix en les xarxes. Ha establit una conversació permanent sobre el que escriu i, des de l'espai virtual, explica quins projectes li ronden pel cap, en quines noves històries pensa, ens deixa llegir els llibres que no li han publicat... Compartix amb qui la seguix el procés, i la dificultat, de construir trames i alçar personatges.",
         "answer": "a"
        },
        {
         "n": 31,
         "prompt": "Àngels Gregori és una veu potent que —des d'Oliva, el poble a on va nàixer i al qual se sent estretament vinculada; Barcelona, la ciutat a on treballa, o Manhattan, el barri que visita sempre que pot— usa la poesia per a mirar el món i intentar transformar-lo. Escriu poesia i treballa per a la poesia, impartint classes de literatura comparada i gestionant espais de trobada i de reivindicació. Escriu el que necessita dir sense por; formula preguntes i respon amb la metàfora; s'entrena llegint poesia; treballa per a l'eternitat, lentament, buscant quedar-se només amb la paraula essencial.",
         "answer": "h"
        }
       ]
      }
     ]
    },
    {
     "n": 3,
     "title": "Estructures lingüístiques",
     "weight": 15,
     "duration": "2 h 10 min (amb les àrees 2 i 4)",
     "scoring": {
      "points_per_exercise": {
       "5": 5,
       "6": 5
      },
      "max_points": 100,
      "pass_points": 40
     },
     "exercises": [
      {
       "n": 5,
       "kind": "choice",
       "instructions": "En el text següent s'han eliminat algunes paraules. Per a cada espai en blanc tens tres opcions de resposta. Només una és correcta. Fixa't en l'exemple (número 0).",
       "reading": {
        "title": "Aprendre i ensenyar amb TIC",
        "paragraphs": [
         "En l'actualitat la tecnologia digital és d'ús comú en (0) diversos contextos i conforma una cultura de participació (32) ______ es du a terme clarament en les xarxes socials, però també en expressions més creatives. (33) ______, esta participació no forma part del currículum explícit, sinó (34) ______ es denomina currículum ocult. La falta d'incorporació d'activitats digitals, a més d'una qüestió de gestió de les tasques escolars, és també un desaprofitament d'oportunitats d'aprenentatge dels estudiants.",
         "En efecte, si bé la tecnologia de la informació i la comunicació (TIC) (35) ______ molts aspectes de l'activitat diària, també ha canviat la nostra interacció amb l'aprenentatge, i estos canvis en els processos d'ensenyança i aprenentatge no han sigut equivalents. La importància i ubiqüitat de les TIC en el treball, l'educació i la vida quotidiana es reflectixen en la consideració de l'escenari actual d'interacció social de la societat, definida com a «societat de la informació i el coneixement». (36) ______, la tecnologia no s'ha de considerar un afegit, sinó un element transformador de l'educació en el context de la societat de la informació i el coneixement, en què els aprenents, les seues característiques, les formes socials, els ritmes d'aprenentatge, etc., estan canviant, i per tant es fa necessari replantejar què, com i quan s'ensenya, com s'avalua, com s'organitzen i s'estructuren les escoles i com es gestionen els temps i els espais.",
         "(37) ______ redefinir el concepte d'escola innovadora –que fins ara se centrava a promoure l'aprenentatge de les TIC amb l'objectiu de formar els xiquets en l'ús de ferramentes i estratègies per al tractament i la transmissió de la informació–, de manera que se centre (38) ______ l'ús de les tecnologies per a aprendre amb la tecnologia. Per tant, es tracta de convertir les TIC en tecnologies per a l'aprenentatge i el coneixement (TAC), fet que es pot entendre com una visió de les TIC des de l'escola. (39) ______, hauríem de posar les tecnologies al servici d'una millora en els processos d'ensenyança-aprenentatge, d'avaluació i d'organització, així com d'actualització en un context de canvi constant.",
         "En conseqüència, l'objectiu de l'escola hauria de ser un aprenentatge més profund, més comprensiu i més significatiu, i preparar l'alumnat per a ser capaç de crear coneixement: educar per a allò que encara no se sap què serà, preparar els alumnes (40) ______ es puguen enfrontar a reptes que encara no tenen i donar el màxim de recursos i ferramentes perquè, quan (41) ______ troben, puguen crear, inventar, redissenyar, estratègies i recursos per a poder aportar solucions. En definitiva, perquè puguen promoure l'aprenentatge al llarg de la vida en etapes i contextos diversos amb l'ajuda de les TIC."
        ]
       },
       "questions": [
        {
         "n": 32,
         "prompt": "Buit 32",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "la qual"
          },
          {
           "key": "b",
           "text": "que"
          },
          {
           "key": "c",
           "text": "què"
          }
         ]
        },
        {
         "n": 33,
         "prompt": "Buit 33",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "També"
          },
          {
           "key": "b",
           "text": "Per exemple"
          },
          {
           "key": "c",
           "text": "Ara bé"
          }
         ]
        },
        {
         "n": 34,
         "prompt": "Buit 34",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "del qual"
          },
          {
           "key": "b",
           "text": "de què"
          },
          {
           "key": "c",
           "text": "del que"
          }
         ]
        },
        {
         "n": 35,
         "prompt": "Buit 35",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "ha modificat"
          },
          {
           "key": "b",
           "text": "els ha modificat"
          },
          {
           "key": "c",
           "text": "n'ha modificat"
          }
         ]
        },
        {
         "n": 36,
         "prompt": "Buit 36",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "Així les coses"
          },
          {
           "key": "b",
           "text": "Per tant"
          },
          {
           "key": "c",
           "text": "A més"
          }
         ]
        },
        {
         "n": 37,
         "prompt": "Buit 37",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "Hi ha que"
          },
          {
           "key": "b",
           "text": "Es deu de"
          },
          {
           "key": "c",
           "text": "Cal"
          }
         ]
        },
        {
         "n": 38,
         "prompt": "Buit 38",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "en"
          },
          {
           "key": "b",
           "text": "amb"
          },
          {
           "key": "c",
           "text": "a"
          }
         ]
        },
        {
         "n": 39,
         "prompt": "Buit 39",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "No obstant això,"
          },
          {
           "key": "b",
           "text": "És a dir,"
          },
          {
           "key": "c",
           "text": "Fet i fet,"
          }
         ]
        },
        {
         "n": 40,
         "prompt": "Buit 40",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "per què"
          },
          {
           "key": "b",
           "text": "per a què"
          },
          {
           "key": "c",
           "text": "per tal que"
          }
         ]
        },
        {
         "n": 41,
         "prompt": "Buit 41",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "se'n"
          },
          {
           "key": "b",
           "text": "s'ho"
          },
          {
           "key": "c",
           "text": "s'hi"
          }
         ]
        }
       ]
      },
      {
       "n": 6,
       "kind": "choice",
       "instructions": "En el text següent s'han eliminat algunes paraules. Per a cada espai en blanc tens tres opcions de resposta. Només una és correcta. Fixa't en l'exemple (número 0).",
       "reading": {
        "title": "Cicatriu",
        "paragraphs": [
         "Una vegada més em quede (0) embadalida davant de l'espill, observant-me la cicatriu. Quantes vegades hauré fet ja este gest? Centenars, milers, milions... Cada dia, des de fa set anys, (42) ______ vegades. Últimament, encara amb més freqüència. La (43) ______ és la del meu palmell ben estirat, uns quinze centímetres. Abans no m'importava massa esta marca; de fet, no és tan diferent d'una piga o d'una taca de naixement. Aleshores no era \"la cicatriu\", sinó “una cicatriu” més.",
         "Quan era més menuda m'agradava mostrar-la. I com m'enorgullia de contar la meua aventura en l'hospital! Podia notar l'enveja dels meus amics perquè les seues cicatrius no tenien res a vore amb la meua. Jo havia festejat amb la mort i això em donava un rang superior a la resta. Mai havia tingut complexos per vestir tops que em deixaren el (44) ______ al descobert –i clar, aquella cicatriu que jo ja no veia–, ni tampoc biquini. Adorava que el meu ventre llis tinguera el color del bronze.",
         "Però este estiu, tot això ha canviat. Una vegada i una altra em pregunte si els metges no podien haver-me fet un tall més discret o si la infermera encarregada de cosir-me la pell no podia haver-ho fet amb més (45) ______. Ara m'adone que la gent em mira la panxa només d'amagat, amb certa coentor en les entranyes, i que mai ningú s'atrevirà a passar els dits per este trau si no és per un rampell de (46) ______.",
         "Bé, en realitat tampoc és que haja fet una enquesta a peu de carrer, però vaig palpar el rebuig de Guillem el dia que una colleta vam anar a la platja per a celebrar l'acabament de les classes. El vaig sorprendre observant-me la panxa i, a l'adonar-se que jo el mirava, va evitar tornar a dirigir els ulls a la pell ferida. Li ho vaig llegir en el rostre: li vaig fer (47) ______. I això justament era el que menys volia jo en este món. No sé per quina raó em va evitar la resta del dia. El seu grupet d'amics també, però a mi ells em tenien igual. Guillem, en canvi, no. Ens havíem fet molt amics durant el curs; de fet, pensava que entre els dos hi havia alguna cosa més que una amistat. Per això la seua (48) ______ em va desconcertar tant.",
         "Després ja no ens voríem en tot l'estiu. L'única cosa que ens unia era que havíem compartit l'aula de primer de Batxillerat A. Per què no em va preguntar res? Jo li hauria explicat sense pèls en la llengua què va passar. Vaig sentir com si algú em clavara les mans dins del cap i volguera (49) ______ tot el meu ser a un altre lloc. Vaig experimentar la mateixa sensació de volar que si estiguera en un (50) ______. Després d'un silenci, un buit, una mort. Aquelles hores mai van ser meues. Em vaig lliurar a unes persones que no coneixia de res, amb total confiança i sense por. Només vaig (51) ______ un \"tot anirà bé\" de la mare just abans d'entrar al quiròfan i la promesa del simpàtic cirurgià vestit amb el color de l'esperança."
        ]
       },
       "questions": [
        {
         "n": 42,
         "prompt": "Buit 42",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "incontables"
          },
          {
           "key": "b",
           "text": "incomptables"
          },
          {
           "key": "c",
           "text": "incontestables"
          }
         ]
        },
        {
         "n": 43,
         "prompt": "Buit 43",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "grandària"
          },
          {
           "key": "b",
           "text": "llargària"
          },
          {
           "key": "c",
           "text": "grossària"
          }
         ]
        },
        {
         "n": 44,
         "prompt": "Buit 44",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "melic"
          },
          {
           "key": "b",
           "text": "melit"
          },
          {
           "key": "c",
           "text": "llambrígol"
          }
         ]
        },
        {
         "n": 45,
         "prompt": "Buit 45",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "alerta"
          },
          {
           "key": "b",
           "text": "cuidat"
          },
          {
           "key": "c",
           "text": "cura"
          }
         ]
        },
        {
         "n": 46,
         "prompt": "Buit 46",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "maldat"
          },
          {
           "key": "b",
           "text": "compassió"
          },
          {
           "key": "c",
           "text": "menyspreu"
          }
         ]
        },
        {
         "n": 47,
         "prompt": "Buit 47",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "llàstima"
          },
          {
           "key": "b",
           "text": "nosa"
          },
          {
           "key": "c",
           "text": "por"
          }
         ]
        },
        {
         "n": 48,
         "prompt": "Buit 48",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "aptitud"
          },
          {
           "key": "b",
           "text": "actitud"
          },
          {
           "key": "c",
           "text": "acritud"
          }
         ]
        },
        {
         "n": 49,
         "prompt": "Buit 49",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "emportar-se"
          },
          {
           "key": "b",
           "text": "portar-se"
          },
          {
           "key": "c",
           "text": "dur-se"
          }
         ]
        },
        {
         "n": 50,
         "prompt": "Buit 50",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "somni"
          },
          {
           "key": "b",
           "text": "son"
          },
          {
           "key": "c",
           "text": "sonall"
          }
         ]
        },
        {
         "n": 51,
         "prompt": "Buit 51",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "necessitar"
          },
          {
           "key": "b",
           "text": "precisar"
          },
          {
           "key": "c",
           "text": "haure"
          }
         ]
        }
       ]
      }
     ]
    },
    {
     "n": 4,
     "title": "Expressió i interacció escrites",
     "weight": 20,
     "duration": "2 h 10 min (amb les àrees 2 i 3)",
     "exercises": [
      {
       "n": 7,
       "kind": "writing",
       "title": "Redacció",
       "instructions": "Tria una de les dos opcions i redacta un text que tinga entre 180 i 220 paraules.",
       "min_words": 180,
       "max_words": 220,
       "choices": [
        {
         "key": "A",
         "text": "Recentment s'ha prohibit, amb algunes excepcions, l'ús del telèfon mòbil en els centres educatius no universitaris, no sols durant les classes sinó també en el temps d'esplai o en les activitats extraescolars. Has llegit la notícia en un periòdic, i no pareix que tota la comunitat estiga d'acord amb esta mesura. Com a membre de l'associació de mares, pares i alumnes, decidixes escriure una entrada en el web del centre educatiu del teu poble en què tractes el tema. Has d'incloure-hi els punts següents:",
         "points": [
          "Expressa preocupació per la quantitat d'hores que els menors passen amb els dispositius mòbils.",
          "Explica les oportunitats que la proposta els oferix: més socialització, menys dependència tecnològica, etc.",
          "Valora el canvi que pot suposar l'atenció en classe i el rendiment."
         ]
        },
        {
         "key": "B",
         "text": "Darrere del tancament d'una carnisseria, un forn o un bar s'amaga un drama comú: el despoblament. Es tracta d'una situació que fa que els pobles es queden sense botigues, sense servicis, sense escoles i, finalment, sense gent. Després de vore un anunci en un periòdic, la idea d'anar a viure a un poble et sembla atractiva, i creus que la teua família i tu hi podeu aportar vitalitat. Escriu una carta a l'Ajuntament d'eixa localitat en què tractes el tema. Has d'incloure-hi els punts següents:",
         "points": [
          "Expressa interés per anar a viure a la localitat.",
          "Explica el tipus de negoci que voleu obrir i què aportarà al poble.",
          "Sol·licita que tinguen en compte la vostra proposta."
         ]
        }
       ]
      },
      {
       "n": 8,
       "kind": "writing",
       "title": "Article per al butlletí municipal",
       "instructions": "Els mars i els oceans cobrixen dos terceres parts de la superfície terrestre. Tenen un valor incalculable, perquè són universos plens de vida i resulten essencials per a la formació dels climes. A pesar d'això, els humans els hem convertit en abocadors de deixalles que impedixen la vida dels ecosistemes i trenquen els equilibris mediambientals. Vius en un poble costaner que ha iniciat unes campanyes de conscienciació i implicació ciutadana. Basant-te en la següent infografia que has trobat en internet, decidixes escriure un article per al Butlletí d'Informació Municipal en què expliques quins canvis d'hàbits podrien millorar la situació de les platges. El text ha de tindre entre 120 i 140 paraules.",
       "min_words": 120,
       "max_words": 140,
       "image": "/exams/b2-octubre-2024/e8-platges.jpg",
       "image_text": "Infografia sobre la cura de les platges, en dos blocs. «Prohibicions» (amb un senyal de prohibit): No tireu l'oli pel desaigüe de la pica; No tireu fem en les platges; No utilitzeu productes agrícoles contaminants. «Iniciatives» (amb un senyal de correcte): Reduïu l'ús d'envasos plàstics (maquillatge, medicines, botelles...); Recicleu plàstics i vidres en els contenidors corresponents; Formeu grups de voluntaris per a netejar platges; Exigiu regulacions més estrictes sobre abocaments."
      }
     ]
    },
    {
     "n": 5,
     "title": "Expressió i interacció orals",
     "weight": 25,
     "duration": "25 minuts",
     "intro": "Esta àrea té dos parts: un monòleg d'uns tres minuts sobre un tema que tries i un diàleg d'uns quatre minuts amb una altra persona aspirant, en què cal arribar a un acord.",
     "exercises": [
      {
       "n": 9,
       "kind": "oral",
       "instructions": "Has de triar un tema i preparar un monòleg de tres minuts, aproximadament.",
       "proposals": [
        {
         "title": "Monòleg · Intercanvis de cases vacacionals",
         "duration": "3 minuts",
         "intro": "Un dels models consolidats en període vacacional per a estalviar diners és l'intercanvi de cases. Este model consistix a oferir a una persona o família ta casa mentres tu t'instal·les en la seua durant el mateix període de temps. Explica si coneixies el model, si l'has practicat o no i què et pareix.",
         "questions": [],
         "images": []
        },
        {
         "title": "Monòleg · Tendències informatives",
         "duration": "3 minuts",
         "intro": "No és una novetat que cada vegada veem menys la televisió convencional i llegim menys premsa escrita per a estar informats. Este canvi de tendència es deu a l'esclat i la consolidació de les xarxes socials. No obstant això, hi ha persones que continuen preferint informar-se a través dels mitjans tradicionals. Explica quines són les teues preferències per a informar-te i per què.",
         "questions": [],
         "images": []
        }
       ]
      },
      {
       "n": 10,
       "kind": "oral",
       "instructions": "Has de mantindre un diàleg amb un altre o una altra aspirant sobre la situació comunicativa que et proposem. Has de defendre el paper de la teua persona i has d'arribar a un acord obligatòriament amb l'altra persona. Has de participar com ho faries en una conversació habitual i les intervencions han de ser equilibrades. La duració de la conversació serà de quatre minuts, aproximadament.",
       "proposals": [
        {
         "title": "Diàleg · El viatge de l'estiu",
         "duration": "4 minuts",
         "intro": "El viatge de l'estiu. Cada persona defén una manera diferent de viatjar i heu d'arribar a un acord.",
         "questions": [],
         "images": [],
         "roles": [
          {
           "name": "Persona A",
           "text": "Eres una persona amb consciència mediambiental, i per a viatjar t'agraden les distàncies curtes. Vols conéixer els llocs de proximitat, intentes utilitzar mitjans de transport poc contaminants; en definitiva, tractes de fer un turisme el més sostenible possible. Penses que esta és la millor forma de viatjar, ja que es minimitza l'impacte ambiental i resulta més econòmica."
          },
          {
           "name": "Persona B",
           "text": "Eres una persona a qui li atrauen les cultures llunyanes, les formes de vida i els costums diferents dels de la teua cultura. T'agrada viatjar a llocs exòtics, busques noves experiències i diferents de les que et pot oferir el teu país. Penses que esta és la millor forma de viatjar, ja que evites el turisme de masses i el contrast cultural et resulta més enriquidor."
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
