-- Examen interactiu C1 de la JQCV (maig 2024) com a recurs de category 'examen'.
-- Contingut a metadata.exam, amb les quatre àrees del C1 i la puntuació de la guia de la prova
-- (comprensió escrita 10 %, 5 preguntes de 20 punts; estructures lingüístiques 20 %, 30 buits;
-- expressió escrita 35 % i expressió oral 35 %; mínim del 20 %, el 40 % i el 50 % segons el pes de
-- l'àrea). Les respostes són les de la plantilla oficial que inclou el quadern. Les redaccions es
-- corregixen amb la rúbrica C1; les infografies de l'exercici 5 són a frontend/public/exams/.
-- Font: https://jqcv.gva.es/documents/161863165/165492633/C1+maig+2024.pdf/9b2e7609-8662-ba33-bfe3-777b38f8eea6

INSERT INTO public.resources (id, name, type, url, content, metadata, xp_earned, difficulty, category)
SELECT id, name, type, url, content, metadata, xp_earned, difficulty, category
FROM jsonb_populate_record(NULL::public.resources, $data${
 "id": "f069fa57-6d0b-575c-ae92-a98c83a9f230",
 "name": "Simulacre C1: maig 2024",
 "type": "jqcv_c1_maig2024",
 "category": "examen",
 "difficulty": "C1",
 "xp_earned": 40,
 "content": "Examen oficial C1 de la JQCV (maig 2024): comprensió escrita i estructures lingüístiques autocorregibles, dos redaccions i pràctica oral.",
 "metadata": {
  "icon": "📸",
  "color": "#B3E5FC",
  "exam_body": "JQCV",
  "certificate_level": "C1",
  "exam": {
   "level": "C1",
   "session": "Maig 2024",
   "body": "JQCV",
   "source_url": "https://jqcv.gva.es/documents/161863165/165492633/C1+maig+2024.pdf/9b2e7609-8662-ba33-bfe3-777b38f8eea6",
   "pass_rule": "Per a ser APTE cal una puntuació global mínima de 60 sobre 100. Les àrees valen un 10 % (comprensió escrita), un 20 % (estructures lingüístiques), un 35 % (expressió i interacció escrites) i un 35 % (expressió i interacció orals), i en cada una cal arribar al mínim: el 20 % en la comprensió escrita, el 40 % en les estructures lingüístiques i el 50 % en les dos àrees d’expressió.",
   "areas": [
    {
     "n": 1,
     "title": "Comprensió escrita",
     "weight": 10,
     "duration": "3 h 30 min (àrees 1, 2 i 3)",
     "scoring": {
      "points_per_correct": 20,
      "max_points": 100,
      "pass_points": 20
     },
     "exercises": [
      {
       "n": 1,
       "kind": "choice",
       "instructions": "Llig atentament este article i tria l’opció correcta (a, b, c o d). Tin en compte que, per a cada qüestió plantejada, només hi ha una resposta correcta. Fixa’t en l’exemple (número 0).",
       "reading": {
        "title": "Control facial",
        "paragraphs": [
         "S’acaba de presentar “Face Control”, una exposició col·lectiva de vint-i-tres autors que tracten, des de diferents perspectives, l’ús que hui en dia fem, amb les noves tecnologies digitals, de les nostres cares i del control que se’n fa per part de tercers. L’exposició està comissariada per Urs Sthael, consultor i expert en fotografia contemporània, que ha reunit treballs de destacats fotògrafs procedents de diferents museus i col·leccions particulars. El nexe que els unix és que presenten exclusivament cares humanes i el tractament a què se les sotmet en l’actualitat. Així, parla del control que s’exercix sobre el nostre rostre des de dos punts de vista: el que fem nosaltres mateixos, de dins cap a fora, manipulant-lo per a ajustar-lo a com volem ser vistos; i el que realitzen des de fora sobre nosaltres grups amb interessos econòmics i polítics a fi de reconéixer, conservar i recopilar dades per a satisfer els seus objectius.",
         "Pel que fa al primer aspecte, tots som conscients que les noves tecnologies, i especialment el mòbil i els programes d’edició digital, han portat fins al paroxisme la natural inclinació humana al narcisisme. El selfisme ens permet amb la màxima facilitat retratar-nos en tota classe de posicions i situacions, sense haver de recórrer, com abans, a l’ajuda d’espills, de disparadors automàtics o de tercers que ens auxilien. D’esta manera, la nostra imatge passa per davant de la resta de realitat, que es convertix només en el marc que l’envolta.",
         "Però el que sobretot es planteja en el material que podem vore en l’exposició va un pas més enllà en el procés de manipulació per canviar les formes, els colors i altres característiques dels rostres a fi de dotar-los dels trets que els originals no tenien, però que són els que desitgem, o els que els volem donar. I sabem que això ja es pot fer amb complexos programes d’edició a través de l’ordinador. I que hui ja estan arribant als mòbils aplicacions des de les quals es poden modificar amb poques pulsacions les fotografies que acabem de fer: aprimar o engrossir els rostres, modificar-ne el color, corregir els ulls, deformar-ne els trets, etc. La manipulació no sembla tindre límits i la fotografia està perdent els valors testimonials que l’havien caracteritzada. Joan Fontcuberta ha teoritzat a bastament sobre esta deriva de la pràctica fotogràfica que ell anomena, en termes generals, postfotografia.",
         "En relació al segon gran tema, l’exposició mostra exemples de treballs fets a partir d’imatges captades per càmeres de fotografia i sobretot de televisió en què els rostres són una manera d’obtindre informació gràfica de les persones amb finalitats identificatives o fins i tot de tipificació de possibles comportaments socials. Este és un corrent que ve de lluny i les sèries de fotografies de bojos en els manicomis o de delinqüents en les comissaries de policia havien sigut tractades ja en el segle XIX en el que s’anomena fisiognomia, que es pot definir com l’intent de traure conclusions sobre les propietats intel·lectuals o morals d’una persona a partir de l’aspecte i els trets del seu rostre. És certament un tema de futur perquè les tecnologies modernes faran que ben prompte tots els espais públics de les grans ciutats dels països desenvolupats estiguen coberts —la majoria ja ho estan— per càmeres que ens registren i seguixen els nostres moviments.",
         "Esta aproximació és de màxima actualitat, i ho serà més, de ben segur, en el futur. Per això l’exposició resulta de considerable interés a l’oferir-nos els treballs d’uns artistes que en fan una constatació i alhora una denúncia, malauradament estèril. Moltes de les seues obres tenen un caràcter multidisciplinari, ja que combinen l’ús de la fotografia, el vídeo i tota classe de manipulacions digitals. Ací, a vegades, la fotografia és només un suport, o un simple complement, del conjunt de l’obra en què l’artista usa elements extrets de les xarxes. L’exposició té, per tant, un contingut conceptual i teòric que passa per davant dels aspectes de caràcter més plàstic, i això fa que la interpretació de les obres requerisca explicacions complementàries perquè l’espectador en conega l’origen i la intenció; d’ací que resulten molt rellevants els peus d’obra que les acompanyen. En conjunt, esta exposició té el gran mèrit de permetre que l’espectador conega i s’endinse en els corrents més actuals de la fotografia. Un aspecte molt interessant perquè habitualment les exposicions de fotografia acostumen a mirar cap al passat i a centrar-se en estils i figures del passat."
        ]
       },
       "questions": [
        {
         "n": 0,
         "prompt": "El text tracta sobre…",
         "answer": "a",
         "scored": false,
         "options": [
          {
           "key": "a",
           "text": "una exposició sobre el control facial que fem individualment i també el que fan sobre nosaltres terceres persones."
          },
          {
           "key": "b",
           "text": "una exposició en què vint-i-tres artistes mostren, amb les seues obres, l’ús que fem dels programes d’edició d’imatges."
          },
          {
           "key": "c",
           "text": "l’exposició “Face Control”, que conjumina obres de fotògrafs com Urs Sthael, procedents de diversos museus."
          },
          {
           "key": "d",
           "text": "una exposició que mostra com ha evolucionat la fotografia gràcies, entre altres, a les noves tecnologies."
          }
         ]
        },
        {
         "n": 1,
         "prompt": "L’exposició “Face Control” pretén mostrar…",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "el treball d’Urs Sthael com a coordinador d’un equip de vint-i-tres artistes."
          },
          {
           "key": "b",
           "text": "les aplicacions per a ús propi i alié dels programes de tractament facial."
          },
          {
           "key": "c",
           "text": "algunes tècniques per a alterar l’aspecte dels rostres per a no ser identificats."
          },
          {
           "key": "d",
           "text": "l’ús sense consentiment de la imatge de les persones amb finalitats lucratives."
          }
         ]
        },
        {
         "n": 2,
         "prompt": "L’alteració dels trets facials…",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "fomenta l’autonomia individual dels usuaris a través del mode selfie del mòbil."
          },
          {
           "key": "b",
           "text": "contribuïx a millorar l’autoestima perquè podem aconseguir la imatge que desitgem."
          },
          {
           "key": "c",
           "text": "desvirtua la funció inicial de les fotografies de deixar constància fidel de la realitat."
          },
          {
           "key": "d",
           "text": "se circumscriu bàsicament a modificar formes, colors i a fer xicotetes correccions."
          }
         ]
        },
        {
         "n": 3,
         "prompt": "Segons Joan Fontcuberta, la postfotografia…",
         "answer": "d",
         "options": [
          {
           "key": "a",
           "text": "és la manipulació de les formes i els colors d’una imatge."
          },
          {
           "key": "b",
           "text": "és una pràctica fotogràfica possible gràcies a les aplicacions mòbils."
          },
          {
           "key": "c",
           "text": "permet aportar a les imatges trets que no tenen les originals."
          },
          {
           "key": "d",
           "text": "aconseguirà que es perda l’essència original de la fotografia."
          }
         ]
        },
        {
         "n": 4,
         "prompt": "El tractament de les imatges captades per tercers…",
         "answer": "d",
         "options": [
          {
           "key": "a",
           "text": "és l’interés principal del corrent teòric que Joan Fontcuberta denomina postfotografia."
          },
          {
           "key": "b",
           "text": "permet que els visitants de l’exposició s’identifiquen amb les obres dels artistes."
          },
          {
           "key": "c",
           "text": "servix per a diagnosticar símptomes de fisiognomia en persones amb problemes mentals."
          },
          {
           "key": "d",
           "text": "s’usa històricament per a intentar entendre i preveure el comportament humà."
          }
         ]
        },
        {
         "n": 5,
         "prompt": "El missatge que hi ha darrere de les obres de l’exposició…",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "promou que es duguen a terme nous treballs artístics a partir d’imatges de videovigilància."
          },
          {
           "key": "b",
           "text": "difícilment arribarà al públic general, ja que les obres costen d’entendre per si soles."
          },
          {
           "key": "c",
           "text": "pretén convidar els espectadors a ser creatius amb les imatges que publiquen en xarxes."
          },
          {
           "key": "d",
           "text": "té la intenció de denunciar l’obsessió amb el passat de les exposicions fotogràfiques."
          }
         ]
        }
       ]
      }
     ]
    },
    {
     "n": 2,
     "title": "Estructures lingüístiques",
     "weight": 20,
     "duration": "3 h 30 min (àrees 1, 2 i 3)",
     "scoring": {
      "points_per_correct": 3.333,
      "max_points": 100,
      "pass_points": 40
     },
     "exercises": [
      {
       "n": 2,
       "kind": "choice",
       "instructions": "Completa el text que tens a continuació amb l’alternativa més precisa i adequada. Només hi ha una opció correcta per a cada buit. Fixa’t en l’exemple (número 0).",
       "reading": {
        "title": "Les coses importants són les que no ho semblen",
        "paragraphs": [
         "La història de la medicina està plena de descobriments que en un primer moment no pareixien importants, però que, (0) a hores d’ara, no podem entendre com (6) ______ apanyaven sense ells. Un dels pioners va ser Joseph Lister, a qui posteriorment anomenarien el pare dels antisèptics.",
         "La seua tasca investigadora es va centrar en el procés inflamatori i la curació de les ferides. En una època (7) ______ la cirurgia havia començat a avançar (8) ______ procediments anestèsics, el principal problema eren les infeccions postquirúrgiques. En la població general no existien les mínimes (9) ______ d’higiene, i el cirurgià operava amb la mateixa roba del carrer o (10) ______ la mateixa sonda per a drenar (11) ______ de diferents pacients.",
         "En este context, el Dr. Lister (12) ______ que els pacients amb fractures tancades desenvolupaven una infecció en molt poques ocasions, (13) ______ aquells amb fractures obertes quasi sempre patien complicacions. Així va començar a sospitar que la causa no estava dins de la ferida, (14) ______ en l’aire que estava en contacte amb la llaga i que provocava la coneguda gangrena.",
         "(15) ______ es va assabentar de les investigacions de Louis Pasteur, que amb els seus experiments va demostrar la teoria microbiana de les infeccions. Amb estos descobriments, Lister va proposar que l’ús d’una barrera antisèptica entre l’àrea quirúrgica (16) ______ tractar i l’aire podria protegir la ferida dels microorganismes presents en l’aire, en l’instrumental o en les mans del cirurgià.",
         "Seguint la idea de trobar una substància que es poguera aplicar (17) ______ teixits humans sense causar-los cap dany, però inhibint la síntesi dels microbis, va trobar l’àcid carbòlic, hui anomenat fenol. Este producte, que (18) ______ s’utilitzava per a evitar la putrefacció de la fusta dels barcos o (19) ______ tractament d’aigües residuals, va tindre per primera vegada èxit l’any 1865 en el tractament d’una ferida oberta d’un xiquet atropellat per un carro.",
         "(20) ______ les crítiques i burles inicials per part de la comunitat científica als seus protocols, és indubtable que esta forma de procedir va suposar un abans i un després en la pràctica de qualsevol activitat sanitària."
        ]
       },
       "questions": [
        {
         "n": 6,
         "prompt": "Buit 6",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "se’ls"
          },
          {
           "key": "b",
           "text": "se les"
          },
          {
           "key": "c",
           "text": "se l’"
          }
         ]
        },
        {
         "n": 7,
         "prompt": "Buit 7",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "en què"
          },
          {
           "key": "b",
           "text": "en la que"
          },
          {
           "key": "c",
           "text": "de la qual"
          }
         ]
        },
        {
         "n": 8,
         "prompt": "Buit 8",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "a mercé dels"
          },
          {
           "key": "b",
           "text": "degut als"
          },
          {
           "key": "c",
           "text": "per bé dels"
          }
         ]
        },
        {
         "n": 9,
         "prompt": "Buit 9",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "medides"
          },
          {
           "key": "b",
           "text": "mides"
          },
          {
           "key": "c",
           "text": "mesures"
          }
         ]
        },
        {
         "n": 10,
         "prompt": "Buit 10",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "s’utilitzava"
          },
          {
           "key": "b",
           "text": "s’hi utilitzava"
          },
          {
           "key": "c",
           "text": "se n’utilitzava"
          }
         ]
        },
        {
         "n": 11,
         "prompt": "Buit 11",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "absis"
          },
          {
           "key": "b",
           "text": "abscisions"
          },
          {
           "key": "c",
           "text": "abscessos"
          }
         ]
        },
        {
         "n": 12,
         "prompt": "Buit 12",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "es va adonar"
          },
          {
           "key": "b",
           "text": "s’hi va adonar"
          },
          {
           "key": "c",
           "text": "se’n va adonar"
          }
         ]
        },
        {
         "n": 13,
         "prompt": "Buit 13",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "mentrestant"
          },
          {
           "key": "b",
           "text": "mentres"
          },
          {
           "key": "c",
           "text": "mentres que"
          }
         ]
        },
        {
         "n": 14,
         "prompt": "Buit 14",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "sinó"
          },
          {
           "key": "b",
           "text": "si no"
          },
          {
           "key": "c",
           "text": "sino"
          }
         ]
        },
        {
         "n": 15,
         "prompt": "Buit 15",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "Tanmateix"
          },
          {
           "key": "b",
           "text": "Doncs"
          },
          {
           "key": "c",
           "text": "Prompte"
          }
         ]
        },
        {
         "n": 16,
         "prompt": "Buit 16",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "en"
          },
          {
           "key": "b",
           "text": "a"
          },
          {
           "key": "c",
           "text": "al"
          }
         ]
        },
        {
         "n": 17,
         "prompt": "Buit 17",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "damunt dels"
          },
          {
           "key": "b",
           "text": "al damunt els"
          },
          {
           "key": "c",
           "text": "a dalt dels"
          }
         ]
        },
        {
         "n": 18,
         "prompt": "Buit 18",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "fins a aleshores"
          },
          {
           "key": "b",
           "text": "fins a eixe moment"
          },
          {
           "key": "c",
           "text": "fins a les hores"
          }
         ]
        },
        {
         "n": 19,
         "prompt": "Buit 19",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "pel"
          },
          {
           "key": "b",
           "text": "per al"
          },
          {
           "key": "c",
           "text": "pèl"
          }
         ]
        },
        {
         "n": 20,
         "prompt": "Buit 20",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "A pesar de"
          },
          {
           "key": "b",
           "text": "Tot i que"
          },
          {
           "key": "c",
           "text": "Malgrat que"
          }
         ]
        }
       ]
      },
      {
       "n": 3,
       "kind": "choice",
       "instructions": "Completa el text que tens a continuació amb l’alternativa més precisa i adequada. Només hi ha una opció correcta per a cada buit. Fixa’t en l’exemple (número 0).",
       "reading": {
        "title": "Una visita al Louvre",
        "paragraphs": [
         "Hi ha una pel·lícula que du per títol Una visita al Louvre. La (0) restricció artística és màxima en el film: un recorregut per alguns quadros seleccionats. La càmera es para en cada obra i la (21) ______. Imatges amb llum freda, plans (22) ______ i lents, esguitats ací i allà amb lleus moviments de la càmera. El guió seguix fidelment les conversacions entre Paul Cézanne i el poeta Joachim Gasquet.",
         "Cézanne no tenia una concepció massa elevada de Jacques-Louis David. Considerava, de manera (23) ______, que David matà la pintura amb la introducció del tòpic, revestit en el seu cas d’ideal. El rostre perfecte, la mà bella, el ser suprem… Per a Cézanne això equivalia a desterrar el caràcter. L’exemple de la falta de passió és, segons ell, La mort de Marat, (24) ______ es conserva a Brussel·les. El pintor considera que Marat és un heroi fred i que l’escena té alguna cosa d’artificial. El conjunt lleva els trets de la vida en benefici de la composició, (25) ______ l’autor pensava més en el que dirien d’ell, en la seua aurèola artística, que no en (26) ______ l’obra insinuava sobre la personalitat de Marat. Tot amb l’agreujant que Jacques-Louis David havia contemplat el cadàver de l’amic. La idealització (27) ______ s’explica per motius estètics, però en cap cas (28) ______ l’amistat que uní Marat i David.",
         "Un fet (29) ______: el mateix David admirava profundament Robespierre. Fixem-nos en el text d’una de les dos cartes que apareixen en el quadro de David, la carta redactada per Charlotte Corday, l’assassina de Marat, la qual pretenia salvar la revolució dels (30) ______ dels seus sectors més radicals. El redactat és tot un prodigi d’ironia: «(31) ______ prou que jo siga dissortada per tindre dret a la vostra benevolència». (32) ______, cal subratllar de nou que Cézanne considera que en este cas David és un mal pintor. Un clàssic virtuós en la pitjor (33) ______ del terme. En un altre text, arguïx que els falsos pintors no veuen l’arbre concret, el que tenim davant, sinó l’arbre com a idealització universal, (34) ______ implica la pèrdua de visió. Per això el pintor es reconeix com a cerebral, però també (35) ______ que és una bèstia. La seua exigència artística és nítida: l’heroisme del real."
        ]
       },
       "questions": [
        {
         "n": 21,
         "prompt": "Buit 21",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "dissemina"
          },
          {
           "key": "b",
           "text": "desenvolupa"
          },
          {
           "key": "c",
           "text": "dissecciona"
          }
         ]
        },
        {
         "n": 22,
         "prompt": "Buit 22",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "fixos"
          },
          {
           "key": "b",
           "text": "fixs"
          },
          {
           "key": "c",
           "text": "fixes"
          }
         ]
        },
        {
         "n": 23,
         "prompt": "Buit 23",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "escèptica"
          },
          {
           "key": "b",
           "text": "categòrica"
          },
          {
           "key": "c",
           "text": "hermètica"
          }
         ]
        },
        {
         "n": 24,
         "prompt": "Buit 24",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "l’original del qual"
          },
          {
           "key": "b",
           "text": "el qual l’original"
          },
          {
           "key": "c",
           "text": "del que l’original"
          }
         ]
        },
        {
         "n": 25,
         "prompt": "Buit 25",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "per què"
          },
          {
           "key": "b",
           "text": "ja que"
          },
          {
           "key": "c",
           "text": "doncs"
          }
         ]
        },
        {
         "n": 26,
         "prompt": "Buit 26",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "el què"
          },
          {
           "key": "b",
           "text": "el fet que"
          },
          {
           "key": "c",
           "text": "allò que"
          }
         ]
        },
        {
         "n": 27,
         "prompt": "Buit 27",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "pot ser que"
          },
          {
           "key": "b",
           "text": "potser"
          },
          {
           "key": "c",
           "text": "pot ser"
          }
         ]
        },
        {
         "n": 28,
         "prompt": "Buit 28",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "cal no oblidar"
          },
          {
           "key": "b",
           "text": "no hi ha que oblidar"
          },
          {
           "key": "c",
           "text": "no cal oblidar"
          }
         ]
        },
        {
         "n": 29,
         "prompt": "Buit 29",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "irreprimible"
          },
          {
           "key": "b",
           "text": "abominable"
          },
          {
           "key": "c",
           "text": "irrefutable"
          }
         ]
        },
        {
         "n": 30,
         "prompt": "Buit 30",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "excessos"
          },
          {
           "key": "b",
           "text": "exordis"
          },
          {
           "key": "c",
           "text": "exabruptes"
          }
         ]
        },
        {
         "n": 31,
         "prompt": "Buit 31",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "Hi ha"
          },
          {
           "key": "b",
           "text": "N’hi ha"
          },
          {
           "key": "c",
           "text": "Hi hauria"
          }
         ]
        },
        {
         "n": 32,
         "prompt": "Buit 32",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "Siga com vullga"
          },
          {
           "key": "b",
           "text": "Encara com siga"
          },
          {
           "key": "c",
           "text": "Siga qui siga"
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
           "text": "asserció"
          },
          {
           "key": "b",
           "text": "acceptació"
          },
          {
           "key": "c",
           "text": "accepció"
          }
         ]
        },
        {
         "n": 34,
         "prompt": "Buit 34",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "el que"
          },
          {
           "key": "b",
           "text": "cosa que"
          },
          {
           "key": "c",
           "text": "cosa la qual"
          }
         ]
        },
        {
         "n": 35,
         "prompt": "Buit 35",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "admés"
          },
          {
           "key": "b",
           "text": "admet"
          },
          {
           "key": "c",
           "text": "admiteix"
          }
         ]
        }
       ]
      }
     ]
    },
    {
     "n": 3,
     "title": "Expressió i interacció escrites",
     "weight": 35,
     "duration": "3 h 30 min (àrees 1, 2 i 3)",
     "exercises": [
      {
       "n": 4,
       "kind": "writing",
       "title": "Redacció",
       "instructions": "Tria una de les dos opcions i redacta un text amb una extensió entre 200 i 220 paraules.",
       "min_words": 200,
       "max_words": 220,
       "choices": [
        {
         "key": "A",
         "text": "La llibertat per a triar les relacions personals genera una gamma d’opcions d’amistat, des de la més superficial fins a la més íntima. Segons un estudi recent, totes estes tenen un paper determinant en la felicitat i el benestar d’una persona, ja que els amics ens consolen en les adversitats, reforcen la nostra autoestima o ens acompanyen en moments d’oci. Redacta un assaig per al teu blog personal en què reflexiones sobre la teua idea d’amistat. Cal que hi tractes, entre altres, els punts següents:",
         "points": [
          "Com canvia l’amistat al llarg de la vida.",
          "L’amistat en el context de les xarxes socials.",
          "Els amics com a família escollida."
         ]
        },
        {
         "key": "B",
         "text": "La forma de viatjar ha evolucionat en els últims anys, i s’hi han afegit noves fórmules com l’intercanvi de vivendes, el voluntariat o, fins i tot, deixar-se acollir per un desconegut en el seu sofà. Són alternatives més econòmiques i una opció diferent per a fer plans d’última hora en dates assenyalades de temporada alta. Col·labores en el suplement Tendències del diari local i t’han encomanat que redactes un article a partir de la teua experiència viatgera. Cal que hi tractes, entre altres, els punts següents:",
         "points": [
          "Destinacions que es podrien visitar amb poc de pressupost.",
          "Alguna anècdota que hàgeu viscut en un viatge.",
          "Consells per a evitar males experiències."
         ]
        }
       ]
      },
      {
       "n": 5,
       "kind": "writing",
       "title": "Redacció amb suport",
       "instructions": "Tria una de les dos opcions i redacta un text amb una extensió entre 170 i 190 paraules.",
       "min_words": 170,
       "max_words": 190,
       "choices": [
        {
         "key": "A",
         "text": "Més enllà de la conveniència o la utilitat dels deures per al rendiment escolar, cada vegada hi ha més debat sobre el grau d’implicació i les diverses estratègies que les famílies poden incorporar en casa per a ajudar els seus fills a preparar exàmens o resoldre dubtes. Estudis, opinions expertes, articles d’opinió… Abunden els missatges al respecte en la premsa, però a voltes són contradictoris. Treballes com a docent en un centre educatiu valencià i decidixes enviar una carta al director del diari comarcal per a valorar este tipus d’informacions i donar algun consell des de la teua experiència. Cal que tingues en compte els titulars següents:",
         "image": "/exams/c1-maig-2024/e5-a.jpg",
         "image_text": "Tres titulars de premsa: 1) «Els programes que fomenten la implicació de pares i mares en l'educació dels fills poden tindre un impacte positiu equivalent a tres mesos d'aprenentatge». 2) Secció «Educació»: «Fer els deures amb els fills té un impacte nul en el seu aprenentatge». 3) Secció «Cultura»: «Deures durant l’estiu: sí o no», amb el subtítol «No fer deures no té per què significar no fer res»."
        },
        {
         "key": "B",
         "text": "Les xarxes socials han revolucionat el món dels adolescents i, hui en dia, quan es pregunta als jóvens a què es volen dedicar en el futur, la majoria responen que volen ser creadors de contingut. En paral·lel als youtubers i als instagramers, apareix la figura dels podcasters. L’objectiu d’un pòdcast és compartir coneixements específics sobre un tema en les xarxes i, aparentment, qualsevol persona pot gravar pòdcasts i difondre’ls. Treballes com a docent en un institut en què formes l’alumnat en l’ús de les TIC, i, davant de l’interés que ha suscitat la creació de pòdcasts, has decidit redactar una guia per a explicar-los les claus de com fer-los bé. Cal que tingues en compte la informació de la infografia següent:",
         "image": "/exams/c1-maig-2024/e5-b.jpg",
         "image_text": "Infografia «Com pots fer un bon pòdcast» (SM / Cruïlla), amb la foto d’un micròfon i uns auriculars. Passos: 1) Decidix-ne el tema, el format i la duració. 2) Guionitza i crea una estructura de programa. 3) Cuida’n la forma: qualitat i creativitat. 4) Busca inspiració. 5) Crea una estratègia de difusió. 6) Passa-t’ho bé. Lema final: «Ara t’escolte!»."
        }
       ]
      }
     ]
    },
    {
     "n": 4,
     "title": "Expressió i interacció orals",
     "weight": 35,
     "duration": "25 minuts",
     "intro": "Esta àrea té dos parts: un monòleg d’uns tres minuts sobre un tema que tries i un diàleg d’uns quatre minuts amb una altra persona aspirant.",
     "exercises": [
      {
       "n": 6,
       "kind": "oral",
       "instructions": "Has de triar un tema i preparar un monòleg de tres minuts, aproximadament. A continuació trobaràs el tema sobre el qual has de parlar i les idees que has de desenvolupar.",
       "proposals": [
        {
         "title": "Monòleg · Autoajuda",
         "duration": "3 minuts",
         "intro": "L'autoajuda ha sigut objecte de controvèrsia en els últims temps. Mentres que alguns la veuen com una ferramenta positiva per al creixement personal i el canvi positiu, uns altres la critiquen perquè consideren que no té una base científica sòlida per a avalar-ne l’eficàcia i per la seua tendència a simplificar problemes complexos. Certs llibres d'autoajuda oferixen solucions ràpides a problemes profunds, però això també pot generar expectatives poc realistes. Participes en un club de lectura a on s’ha plantejat este tema, i hi intervens per a expressar la teua opinió. Cal que tingues en compte, entre altres, estes idees:",
         "questions": [
          "Perills de portar a extrem l’actitud positiva.",
          "Autoajuda i atenció professional.",
          "Comercialització excessiva."
         ],
         "images": []
        },
        {
         "title": "Monòleg · L’auge de la moda sostenible",
         "duration": "3 minuts",
         "intro": "Cada vegada hi ha més consumidors que demanen productes responsables amb el medi ambient i elaborats amb estàndards ètics. A mesura que la moda sostenible guanya impuls, sorgixen moltes empreses de moda, des de marques de luxe fins a botigues assequibles, per a satisfer esta demanda creixent i abordar els desafiaments ambientals i socials en esta indústria. Participes en una xarrada organitzada per l’associació de comerços del teu municipi sobre la moda sostenible, i hi intervens per a expressar la teua opinió. Cal que tingues en compte, entre altres, estes idees:",
         "questions": [
          "Esta tendència es pot llegir com una estratègia més de màrqueting.",
          "Vivim l’auge del consumisme conscient.",
          "La vida útil de la roba s’ha allargat gràcies a les plataformes de compravenda."
         ],
         "images": []
        }
       ]
      },
      {
       "n": 7,
       "kind": "oral",
       "instructions": "Has de mantindre un diàleg amb un altre o una altra aspirant sobre la situació comunicativa que vos proposem. Llig la introducció del tema i defén el paper que t’atorga la proposta ombrejada. Les intervencions han de ser equilibrades; evita donar respostes massa curtes i participa activament com ho faries en una conversa habitual. La duració de la conversa serà de quatre minuts, aproximadament.",
       "proposals": [
        {
         "title": "Diàleg · L’educació en línia o presencial",
         "duration": "4 minuts",
         "intro": "En els últims anys l’oferta educativa s’ha vist obligada a adaptar-se a noves situacions i a redefinir els espais de docència. La formació en línia, per exemple, ha deixat de ser una opció residual i complementària de l’educació presencial, i ara el mercat ha comprovat que pot ser una opció rendible que va guanyant adeptes.",
         "questions": [],
         "images": [],
         "roles": [
          {
           "name": "Persona A",
           "text": "Participes en un debat radiofònic sobre este tema. Consideres que l’educació telemàtica no pot ser, en cap cas, una substitució de l’educació presencial. A més, opines que este tipus d’ensenyança deshumanitza la tasca per factors com la falta d’interacció."
          },
          {
           "name": "Persona B",
           "text": "Participes en un debat radiofònic sobre este tema. Opines que la formació en línia és avantatjosa per la flexibilitat de temps i espai que oferix, entre altres factors. A més, penses que el professorat només hauria d’actuar com a guia del procés d’aprenentatge."
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
