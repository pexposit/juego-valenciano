-- Examen interactiu C2 de la JQCV (octubre 2023) com a recurs de category 'examen'.
-- Contingut a metadata.exam, amb les quatre àrees del C2 i la puntuació de la guia de la prova
-- (comprensió escrita 10 %, 5 preguntes de 20 punts; estructures lingüístiques 20 %, 40 buits de 2,5 punts;
-- expressió escrita 45 % i expressió oral 25 %; mínim del 20 %, el 40 % i el 50 % segons el pes de
-- l'àrea). Les respostes són les del solucionari escanejat que inclou el quadern. Les redaccions es
-- corregixen amb la rúbrica C2 (backend/src/services/examWritingEvaluator.ts); les imatges de l'exercici 5
-- són a frontend/public/exams/. L'àrea oral, com en el C1, només mostra les propostes.
-- Font: https://jqcv.gva.es/va/nivell-c2

INSERT INTO public.resources (id, name, type, url, content, metadata, xp_earned, difficulty, category)
SELECT id, name, type, url, content, metadata, xp_earned, difficulty, category
FROM jsonb_populate_record(NULL::public.resources, $data${
 "id": "15d56146-f2f8-50b9-8ca7-401c70c0dbd9",
 "name": "Simulacre C2: octubre 2023",
 "type": "jqcv_c2_oct2023",
 "category": "examen",
 "difficulty": "C2",
 "xp_earned": 40,
 "content": "Examen oficial C2 de la JQCV (octubre 2023): comprensió escrita i estructures lingüístiques autocorregibles, dos redaccions i pràctica oral.",
 "metadata": {
  "icon": "🏆",
  "color": "#D1C4E9",
  "exam_body": "JQCV",
  "certificate_level": "C2",
  "exam": {
   "level": "C2",
   "session": "Octubre 2023",
   "body": "JQCV",
   "source_url": "https://jqcv.gva.es/va/nivell-c2",
   "pass_rule": "Per a ser APTE cal una puntuació global mínima de 60 sobre 100. Les àrees valen un 10 % (comprensió escrita), un 20 % (estructures lingüístiques), un 45 % (expressió i interacció escrites) i un 25 % (expressió i interacció orals), i en cada una cal arribar al mínim: el 20 % en la comprensió escrita, el 40 % en les estructures lingüístiques i el 50 % en l’expressió escrita i en l’expressió oral.",
   "areas": [
    {
     "n": 1,
     "title": "Comprensió escrita",
     "weight": 10,
     "duration": "1 h 30 min (àrees 1 i 2)",
     "scoring": {
      "points_per_correct": 20,
      "max_points": 100,
      "pass_points": 20
     },
     "exercises": [
      {
       "n": 1,
       "kind": "choice",
       "instructions": "Llegiu atentament este article i trieu la resposta correcta (a, b, c o d). Teniu en compte que, per a cada qüestió plantejada, només hi ha una resposta correcta. Fixeu-vos en l’exemple (número 0).",
       "reading": {
        "title": "La insolència essencial de la veritat",
        "paragraphs": [
         "Possiblement no anava gaire desencaminat el jove Nietzsche quan en Sobre veritat i mentida en sentit extramoral ens advertia que l’ésser humà experimenta un cert sentiment ambivalent davant la veritat i la mentida. L’ésser humà no fuig tant de ser enganyat com de ser perjudicat per l’engany. Només en desitja les conseqüències agradables, però és indiferent o fins i tot contrari a la veritat, sobretot, quan pot tindre efectes perjudicials o destructius.",
         "Tanmateix, potser també té raó qui opina que la realitat (la veritat) és un estat que té un valor superior a la fantasia (la mentida). Sentim que la veritat no és una simple propietat abstracta dels nostres judicis, sinó una cosa essencial per a viure bé. Per exemple, fins i tot aquells que acostumen a actuar dins de paràmetres postmoderns, això és, inestables i efímers, segurament podran sentir-se commoguts amb les peripècies del protagonista d’El show de Truman quan decidix abandonar la plàcida vida d’aquell món que li havien construït expressament perquè hi passara la totalitat de la seua existència. Si haguera decidit quedar-s’hi, la seua decisió s’hauria interpretat com un signe de debilitat. En canvi, es valora la fermesa amb què afronta el seu futur, una situació plena d’incerteses, una actitud amb la qual és difícil no reconéixer un heroi autèntic. El grau del seu coratge es calcula en relació directa al grau de dificultat dels entrebancs que ha de superar per a alliberar-se de la mentida. Són entrebancs emocionals, psíquics i socials als quals ha de fer front, que l’encadenen a un món il·lusori. Christof, el creador del món on viu Truman, afirma que allò normal és acceptar la realitat tal com se’ns presenta. Esta és la raó que explica per què Truman mai no havia sospitat fins a aquell moment que tot el seu entorn era una farsa.",
         "Queda palés, doncs, que tenim una natural disposició a creure en el que els altres ens diuen i, més encara, en el que ens diuen els nostres pares, la nostra parella o els nostres millors amics. El nostre saber, les nostres veritats, són fonamentalment creences; poques coses d’allò que prenem com a verdader les hem comprovades per nosaltres mateixos. En general, no acostumem a assegurar-nos de tot allò que escoltem, que veiem o que llegim. Som crèduls per naturalesa. Confiem en els altres i en el que ens diuen. Per què ens haurien d’enganyar? A més, és un fet fefaent que la mentida és més perfecta, més mentida, com més veritat sembla.",
         "Però, esta veritat a la qual aspirem, pot ella sola lluitar contra la mentida organitzada? ¿La veritat sense ajut extern pot desemmascarar l’engany estructural si la mentida s’alimenta de l’opacitat i la manca de transparència? En situacions com estes, aplicar l’imperatiu categòric kantià resulta excessiu, llavors, si es pretén que la gent diga la veritat, cada individu ha de dir-la sempre, n’ha de ser exemple. Una mentida, quan és dominant, desqualifica les altres mentides perquè n’ha esdevingut l’única veritat. En estes situacions, la veritat autèntica només pot combatre la veritat falsa fent servir la mentida o l’engany. Truman enganya els seus guardians i només així pot alliberar-se de la mentida. Com, si no, es pot conéixer l’interior d’organitzacions que soscaven la societat? Infiltrant-se, fent-se passar per un integrant d’estos grups, guanyant-se la seua confiança. Perquè també per als fabricants de mentides, la veritat és un valor important, no els fa cap gràcia que ningú els enganye, són ells qui tenen el monopoli del frau i per això perseguixen amb ràbia a qui els ha defraudat. La traïció es paga cara entre aquells que fan de la mentida la seua professió, amb la seua vida. La mentida triomfa perquè en el fons la veritat és la regla.",
         "Hi ha qui va més enllà a l’hora de valorar els efectes benèfics del compliment dels nostres compromisos i la veritat. La promesa complida va més enllà dels seus valors sociològics, perquè els transcendix. Té a veure amb un acte fundacional. Un acte que canvia la manera de concebre l’ésser humà. És, ni més ni menys, el pas de l’espècie humana de l’univers natural a un univers propi, exclusiu, específicament humà: l’univers moral. Este acte coincidix en el temps amb el fet de donar valor a la paraula. Quan a algú se’l reconeix com a “home de paraula” significa que este ésser s’identifica amb el que ha dit. Ser home de paraula o tindre paraula significa mantindre-la caiga qui caiga, aguantar-la malgrat les adversitats i a pesar que semblaria millor cedir als nostres impulsos vitals. En el moment en què la carn es va fer verb, paraula, la humanitat va aconseguir alliberar-se de les determinacions de la naturalesa. Esta emergència, inexplicable encara hui en dia per la ciència, va donar lloc a la singularitat humana: un ésser que és capaç de contrariar les exigències naturals. Cap altre ésser viu és capaç de fer callar durant uns moments els seus instints vitals. Només l’ésser humà gràcies a la paraula donada pot resistir-se a la biologia. La fermesa a l’hora d’expressar allò que es pensa i fer allò que s’ha dit implica no una continuïtat, sinó una ruptura, un salt en l’evolució de l’espècie en què els imperatius naturals deixen pas als imperatius morals. La paraula forma i estructura el caràcter i la consciència morals.",
         "Un enfocament de la veritat també diferent és el que ens proporciona Michel Foucault quan planteja el tema de la parresia. El pensador francés entén este concepte com “el coratge de la veritat en qui parla i assumix el risc de parlar, malgrat tot; però és també el coratge de l’interlocutor que accepta rebre com a certa la veritat ofensiva que escolta”. Foucault destaca dos elements essencials en la parresia: d’una banda, la coherència i, de l’altra, la valentia. Per distingir el parresista del xarrador o del demagog cal que hi haja una harmonia entre el que es diu i el que es fa. A més, la valentia, l’altre signe distintiu, implica un risc, no només per a aquell que emet la veritat, perquè pot rebre les reaccions violentes d’aquell que es pot sentir perjudicat, sobretot si és una comunitat (democràcia) o d’aquell que té el poder (tirania), sinó també per a aquell que accepta escoltar-la. Podem considerar Truman un parresista modern? El ben cert és que reconeixem el seu coratge i la seua coherència en el moment en què decidix trencar amb tota la seua vida desconeixent les conseqüències de la seua decisió.",
         "En el pròleg d’Ecce Homo, un Nietzsche ja més madur clamava que la vàlua d’un home es pot mesurar per la quantitat de veritat que pot suportar. La veritat acostuma a jugar-se en camp contrari, amb una gespa descuidada, davant d’un públic hostil i sota l’escrutini d’àrbitres poc fiables. Sorprén que encara hi haja algú que s’enteste a jugar en circumstàncies tan adverses. Tanmateix, sense este punt d’insolència, de ben segur que la veritat hauria desaparegut fa molt de temps de les nostres vides."
        ]
       },
       "questions": [
        {
         "n": 0,
         "prompt": "L’objectiu final d’este article és...",
         "answer": "a",
         "scored": false,
         "options": [
          {
           "key": "a",
           "text": "explorar el problema de la veritat de la mà d’autors que l’aborden des d’òptiques diferents."
          },
          {
           "key": "b",
           "text": "demostrar que l’aproximació que fa Nietzsche a la veritat ha servit de base per a altres pensadors."
          },
          {
           "key": "c",
           "text": "criticar la falta de veritat en les nostres vides a partir de la revisió històrica del terme."
          },
          {
           "key": "d",
           "text": "assumir que la veritat és un valor que ha deixat de ser operatiu en la societat actual."
          }
         ]
        },
        {
         "n": 1,
         "prompt": "Segons Nietzsche, i pel que fa a la veritat, l’ésser humà...",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "pensa que és un element essencial per a viure bé, i no un simple concepte abstracte."
          },
          {
           "key": "b",
           "text": "hi té una aproximació paradoxal, només la defén de paraula, però no a través del seu comportament."
          },
          {
           "key": "c",
           "text": "no vol ser enganyat ni patir-ne les conseqüències, però tolera la mentida si la veritat el pot perjudicar."
          },
          {
           "key": "d",
           "text": "la busca de manera sistemàtica, però de vegades ha de recórrer a l’engany per a protegir-se."
          }
         ]
        },
        {
         "n": 2,
         "prompt": "Segons l’autor, el protagonista de la pel·lícula El show de Truman...",
         "answer": "d",
         "options": [
          {
           "key": "a",
           "text": "és considerat un heroi feble perquè no vol deixar l’espai que li havien construït expressament."
          },
          {
           "key": "b",
           "text": "supera entrebancs emocionals i socials en el món en què viu, cosa que eleva el seu grau de coratge."
          },
          {
           "key": "c",
           "text": "decidix acceptar la realitat tal com se li presenta, tot i que la viu i la considera una farsa."
          },
          {
           "key": "d",
           "text": "demostra valentia quan tria un futur ple d’incertesa, en comptes d’una vida còmoda i prefabricada."
          }
         ]
        },
        {
         "n": 3,
         "prompt": "Les persones acostumen a considerar veritat...",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "els arguments que han sigut prèviament comprovats a partir de les pròpies experiències."
          },
          {
           "key": "b",
           "text": "les opinions dels altres, sobretot si les manifesten persones acostades i de confiança."
          },
          {
           "key": "c",
           "text": "les creences que se’ns presenten de manera versemblant, encara que desconfiem dels polítics."
          },
          {
           "key": "d",
           "text": "els sabers que són constatables, sobretot per les persones expertes en estes matèries."
          }
         ]
        },
        {
         "n": 4,
         "prompt": "L’aparició del llenguatge humà…",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "singularitza l’espècie humana perquè li permet tindre domini sobre els instints i les exigències naturals."
          },
          {
           "key": "b",
           "text": "ajuda els humans a satisfer les necessitats naturals a pesar de les adversitats de l’entorn."
          },
          {
           "key": "c",
           "text": "contribuïx a l’expressió ferma dels desitjos naturals, i a la possibilitat de dur-los a terme."
          },
          {
           "key": "d",
           "text": "marca l’evolució de l’ésser humà, però alhora l’inici de la construcció de la mentida."
          }
         ]
        },
        {
         "n": 5,
         "prompt": "Segons el text, Michel Foucault considera que la veritat és...",
         "answer": "d",
         "options": [
          {
           "key": "a",
           "text": "el millor indicador de la vàlua d’un home: com més veritat assumisca, més hostilitats podrà suportar."
          },
          {
           "key": "b",
           "text": "el precepte rector de les societats democràtiques, necessària per a evitar caure en la tirania."
          },
          {
           "key": "c",
           "text": "un principi incòmode en el món actual, però que cal exigir amb un punt d’insolència i ironia."
          },
          {
           "key": "d",
           "text": "un concepte bidireccional que necessita el coratge de qui la diu i l’acceptació de qui la rep."
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
     "duration": "1 h 30 min (àrees 1 i 2)",
     "scoring": {
      "points_per_correct": 2.5,
      "max_points": 100,
      "pass_points": 40
     },
     "exercises": [
      {
       "n": 2,
       "kind": "choice",
       "instructions": "Completeu el text que teniu a continuació amb l’alternativa més precisa i adequada. Només hi ha una opció vàlida per a cada buit. Fixeu-vos en l’exemple (número 0).",
       "reading": {
        "title": "La bellesa no humana",
        "paragraphs": [
         "(0) Perceben la bellesa de les flors, l’abella o el colibrí, que s’hi acosten per a recol·lectar-ne el nèctar? És a dir, poden els animals no humans apreciar-la? Existix una veritat universal sobre la bellesa? O només és un atribut útil, un indicador d’un tret valuós? Com succeïx amb tants altres fenòmens naturals, no hi ha una resposta simple a estes preguntes.",
         "Les restes fòssils d’(6) ______, un dinosaure de la mida d’un corb, van permetre caracteritzar-ne el plomatge. Era predominantment gris, amb un monyo castany com una cresta de mohawk i unes plomes blanques llargues amb (7) ______ negres a les extremitats. Les plomes, amples i planes, no eren bones per a volar. Els (8) ______ l’haurien ajudat a aïllar-se de l’exterior –del fred, la humitat o la calor– i a mantindre així la temperatura corporal dins d’uns límits confortables. Però una cosa són els plomissols i l’altra, les plomes, sobretot si són grans i tenen, a més, colors vistosos. Richard Prum, el líder de l’equip investigador que va publicar la troballa de les restes de les plomes de colors, creu que la raó de ser d’aquelles és, senzillament, la bellesa. Segons ell, eren així perquè eren boniques, susceptibles de ser admirades pels membres de l’altre sexe de la mateixa espècie. Esta seria la pressió selectiva (9) ______ ha impulsat la gran explosió estètica dels rèptils (10) ______ després de la seua aparició, així com, en menor mesura, en altres grups animals.",
         "Uns 155 milions d’anys després, els mascles de milers d’espècies d’aus, hereus d’aquells primers dinosaures emplomats, exhibixen els seus ornaments davant de les femelles per convéncer-les (11) ______ s’aparellen amb ells. A més de resultar-nos belles, les plomes de les aus, (12) ______ altres trets anatòmics i fisiològics, haurien conferit als seus (13) ______, després, la facultat de volar. Estètica i utilitat haurien confluït, per tant, en el plomatge de les aus. En la mateixa època, fa uns 150 milions d’anys, moltes plantes depenien del vent per a (14) ______ el pol·len que produïen i així reproduir-se. Però certs insectes van començar a alimentar-se d’estos grans de pol·len rics en proteïnes i els transportaren de forma accidental d’una planta a una altra. La fecundació va resultar ser molt més eficient per esta via que pel moviment de l’aire. Les plantes més riques en pol·len van ser especialment exitoses. (15) ______, els insectes més hàbils per a trobar pol·len també ho van ser.",
         "A través d’un procés de coevolució, algunes plantes van començar a modificar les seues fulles i van sorgir-ne les flors: estructures que cridaven l’atenció dels pol·linitzadors i els atreien. Les formes i colors cridaners les van ajudar a destacar sobre el fons verd. Les olors i l’emissió de llum en una gamma molt àmplia de freqüències –arribant a la ultraviolada– van generar una resposta coincident per part dels pol·linitzadors. El nèctar va proporcionar un incentiu en forma d’aportació energètica addicional. Els insectes, les aus i els mamífers van començar a competir (16) ______ per l’accés i van desenvolupar ales, llengües i encèfals més adequats per a la cerca de l’aliment floral. (17) ______ s’intensificava la pressió d’ambdos parts, les plantes i els seus pol·linitzadors van establir relacions cada vegada més específiques, i es llançaren mútuament cap a extrems estètics i adaptatius: un ocell diminut, que (18) ______ i voleteja com un insecte, o una orquídia que imita l’aparença i l’olor d’una abella femella. Milers d’anys després, les flors ens fascinen. Ens captiven els colors, la forma i les aromes. Per què ens agraden? Són, de la mateixa manera, belles per a l’abella o el colibrí que s’hi acosten per a recol·lectar-ne el nèctar? Algunes de les seues característiques exercixen un efecte semblant en l’abella, el colibrí o qualsevol de nosaltres? I, de forma més general, quina és l’essència de la bellesa? Poden els animals no humans apreciar-la? Existix una veritat universal sobre ella?",
         "Segons el físic David Deutsch, «les flors ens agraden perquè són belles». No perquè ens ho semblen, sinó perquè ho són. (19) ______, a més del component subjectiu, que depén de diferents circumstàncies que afecten l’observador, hi ha un component objectiu en la bellesa, de manera que, segons ell, no seria del tot cert el conegut (20) ______ «la bellesa és als ulls de qui mira». I el fet que les flors ens agraden als éssers humans seria la prova que la seua bellesa és un tret objectiu, ja que (21) ______ sentim atrets malgrat que no n’obtenim un profit equivalent (22) ______ obtenen els pol·linitzadors.",
         "Deutsch sosté que el recurs a (23) ______ la bellesa és la millor forma de dificultar que puguen falsificar-se els senyals que utilitzen per a comunicar-se els éssers vius, flors i insectes pol·linitzadors en el cas que ens ocupa. La bellesa de les flors no seria un efecte secundari accidental, perquè els gens que més es (24) ______ serien aquells que incorporen la bellesa objectiva. En una entrevista per a una revista científica prestigiosa arriba a afirmar que (25) ______ poden haver veritats estètiques tan objectives com les lleis de la física."
        ]
       },
       "questions": [
        {
         "n": 6,
         "prompt": "Buit 6",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "anchiornis huxleyi"
          },
          {
           "key": "b",
           "text": "Anchiornis Huxleyi"
          },
          {
           "key": "c",
           "text": "Anchiornis huxleyi"
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
           "text": "lluentons"
          },
          {
           "key": "b",
           "text": "llentilletes"
          },
          {
           "key": "c",
           "text": "llautons"
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
           "text": "plomalles"
          },
          {
           "key": "b",
           "text": "plomissons"
          },
          {
           "key": "c",
           "text": "plomalls"
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
           "text": "la qual"
          },
          {
           "key": "b",
           "text": "què"
          },
          {
           "key": "c",
           "text": "que"
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
           "text": "aviaris"
          },
          {
           "key": "b",
           "text": "aviars"
          },
          {
           "key": "c",
           "text": "avícoles"
          }
         ]
        },
        {
         "n": 11,
         "prompt": "Buit 11",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "de que"
          },
          {
           "key": "b",
           "text": "que"
          },
          {
           "key": "c",
           "text": "de què"
          }
         ]
        },
        {
         "n": 12,
         "prompt": "Buit 12",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "juntament a"
          },
          {
           "key": "b",
           "text": "junt a"
          },
          {
           "key": "c",
           "text": "junt amb"
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
           "text": "posseidors"
          },
          {
           "key": "b",
           "text": "poseïdors"
          },
          {
           "key": "c",
           "text": "posseïdors"
          }
         ]
        },
        {
         "n": 14,
         "prompt": "Buit 14",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "estossegar"
          },
          {
           "key": "b",
           "text": "espargir"
          },
          {
           "key": "c",
           "text": "difuminar"
          }
         ]
        },
        {
         "n": 15,
         "prompt": "Buit 15",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "Així mateix"
          },
          {
           "key": "b",
           "text": "Contràriament"
          },
          {
           "key": "c",
           "text": "Fet i fet"
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
           "text": "-n’hi"
          },
          {
           "key": "b",
           "text": "-hi"
          },
          {
           "key": "c",
           "text": "Ø"
          }
         ]
        },
        {
         "n": 17,
         "prompt": "Buit 17",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "Quant més"
          },
          {
           "key": "b",
           "text": "A mesura que"
          },
          {
           "key": "c",
           "text": "Per més que"
          }
         ]
        },
        {
         "n": 18,
         "prompt": "Buit 18",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "rondina"
          },
          {
           "key": "b",
           "text": "parrupa"
          },
          {
           "key": "c",
           "text": "brunzix"
          }
         ]
        },
        {
         "n": 19,
         "prompt": "Buit 19",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "Sota el seu parer"
          },
          {
           "key": "b",
           "text": "Baix el seu punt de vista"
          },
          {
           "key": "c",
           "text": "A parer seu"
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
           "text": "adagi"
          },
          {
           "key": "b",
           "text": "adaggi"
          },
          {
           "key": "c",
           "text": "addagi"
          }
         ]
        },
        {
         "n": 21,
         "prompt": "Buit 21",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "ens hi"
          },
          {
           "key": "b",
           "text": "ens"
          },
          {
           "key": "c",
           "text": "ens en"
          }
         ]
        },
        {
         "n": 22,
         "prompt": "Buit 22",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "a que"
          },
          {
           "key": "b",
           "text": "al qual"
          },
          {
           "key": "c",
           "text": "al que"
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
           "text": "estandarizar"
          },
          {
           "key": "b",
           "text": "estandarditzar"
          },
          {
           "key": "c",
           "text": "estandaritzar"
          }
         ]
        },
        {
         "n": 24,
         "prompt": "Buit 24",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "destruïxen"
          },
          {
           "key": "b",
           "text": "copien"
          },
          {
           "key": "c",
           "text": "repliquen"
          }
         ]
        },
        {
         "n": 25,
         "prompt": "Buit 25",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "hi"
          },
          {
           "key": "b",
           "text": "en"
          },
          {
           "key": "c",
           "text": "n’hi"
          }
         ]
        }
       ]
      },
      {
       "n": 3,
       "kind": "choice",
       "instructions": "Completeu el text que teniu a continuació amb l’alternativa més precisa i adequada. Només hi ha una opció vàlida per a cada buit. Fixeu-vos en l’exemple (número 0).",
       "reading": {
        "title": "Pioners",
        "paragraphs": [
         "(0) L’any 1901, amb només dènou anys, Andreas Madsen abandonà la seua Dinamarca natal, rumb a l’Argentina. A Buenos Aires, s’enrolà en la Comisión de Límites de Francisco Pascasio Moreno (el famós Perito Moreno) i es trobà, ell que era mariner, posant fites a la frontera entre Xile i l’Argentina, (26) ______ patagònics. S’hi quedà. Fou un dels primers colonitzadors de la zona, al costat d’una escassa i bigarrada colla d’altres europeus i americans (27) ______ que van aprendre a conviure amb els igualment escassíssims indis tehueltxes de l’àrea. La vida d’aquella gent fou una epopeia, tots sols en aquelles gèlides immensitats. Al Canadà o als (28) ______ ja s’havien viscut històries semblants, com les dels valerosos Daniel Boone o David Crockett. Foren (29) ______ i veritables pioners.",
         "Antigament, els francesos anomenaven pionniers els soldats d’infanteria que marxaven al davant dels exèrcits. El dendròleg i escriptor anglés John Evelyn, a Sylva or a discourse of forest-trees (1664), ja utilitzà el terme pioneer en el modern sentit de ‘persona capdavantera’. La colonització dels far west nord i sud-americans fou obra de pioners, tasca (30) ______ més tard en innombrables pel·lícules més o menys passables. La seua dimensió èpica va ser convenientment exaltada, però no sempre es feu notar prou la remarcable inscripció ambiental d’aquella gent, sens dubte forçada per la necessitat, però també conseqüència de l’imaginari d’arrel calvinista que arrossegaven dels seus països d’origen. Els abusos i les matances de (31) ______ o de (32) ______ andins vingueren després.",
         "“El pioner conquerix, però no destruïx”, deixà escrit Andreas Madsen, tot lamentant-se de les aniquilacions faunístiques i de les tales abusives. (33) ______, després dels pioners, arribaren els aprofitats. Segles abans, havia passat el mateix al (34) ______. L’abundància relaxa els costums i aboca (35) ______ marginats a emigrar per rejovenir el sistema en terres encara verges. Però a la Terra s’han acabat els exteriors colonitzables. Possiblement per això hem posat (36) ______ fora del planeta i, ja des dels anys seixanta, vam començar a enviar a l’espai les sondes justament anomenades Pioneer. N’és hereu l’astromòbil Perseverance, que, des de febrer de 2021, campa pels deserts de Mart. Algunes veus són partidàries de colonitzar el planeta vermell, tasca no gens senzilla i no sé si gaire sensata: després dels pioners, hi enviarem els aprofitats de consuetud per reproduir la nostra brillant trajectòria d’(37) ______ esbojarrats i ineficients...?",
         "(38) ______, estes hipotètiques noves fronteres no ens estalvien l’endreça domèstica. L’any 2007, Thomas L. Friedman argumentà a les planes de (39) ______ la conveniència de plantejar-se un Green New Deal, és a dir un “nou repte verd” o “nou repte ambiental”. Era una idea oportuna, reeixida paràfrasi del New Deal socioeconòmic propugnat l’any 1933 pel president Franklin D. Roosevelt per (40) ______ les conseqüències de la Gran Depressió provocada pel (41) ______ de 1929. Sí, a la vista del canvi climàtic galopant, necessitem fer alguna cosa.",
         "La Comissió Europea ha llançat l’European Green Deal. Es proposa aconseguir la neutralitat climàtica europea l’any 2050. (42) ______ no és un objectiu tan ambiciós com colonitzar Mart, però sens dubte més immediatament convenient. (43) ______ comencen a preparar-se uns encara (44) ______ pioners dels deserts marcians, els terrícoles de tota la vida hauríem de restaurar les condicions climàtiques per arribar sense excessius sobresalts al segle XXII. Ens hauríem de convertir en els pioners d’este nou (45) ______ climàtic, de consecució no pas fàcil, però possible i en tot cas molt desitjable. Tindria la seua èpica i una gran utilitat."
        ]
       },
       "questions": [
        {
         "n": 26,
         "prompt": "Buit 26",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "a Los Andes"
          },
          {
           "key": "b",
           "text": "Als Andes"
          },
          {
           "key": "c",
           "text": "A Els Andes"
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
           "text": "hiperbòlics"
          },
          {
           "key": "b",
           "text": "hiperboris"
          },
          {
           "key": "c",
           "text": "hiperbàrics"
          }
         ]
        },
        {
         "n": 28,
         "prompt": "Buit 28",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "USA"
          },
          {
           "key": "b",
           "text": "EEUU"
          },
          {
           "key": "c",
           "text": "EUA"
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
           "text": "esquallosos"
          },
          {
           "key": "b",
           "text": "pusil·lànimes"
          },
          {
           "key": "c",
           "text": "estrenus"
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
           "text": "reflectida"
          },
          {
           "key": "b",
           "text": "reflexada"
          },
          {
           "key": "c",
           "text": "reflectada"
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
           "text": "bissonts"
          },
          {
           "key": "b",
           "text": "bisons"
          },
          {
           "key": "c",
           "text": "bissons"
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
           "text": "cérvols"
          },
          {
           "key": "b",
           "text": "cèrvols"
          },
          {
           "key": "c",
           "text": "cervols"
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
           "text": "Tanmateix"
          },
          {
           "key": "b",
           "text": "No obstant això"
          },
          {
           "key": "c",
           "text": "En efecte"
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
           "text": "vell món"
          },
          {
           "key": "b",
           "text": "vell Món"
          },
          {
           "key": "c",
           "text": "Vell Món"
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
           "text": "els"
          },
          {
           "key": "b",
           "text": "als"
          },
          {
           "key": "c",
           "text": "en els"
          }
         ]
        },
        {
         "n": 36,
         "prompt": "Buit 36",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "l’albarda"
          },
          {
           "key": "b",
           "text": "l’esguard"
          },
          {
           "key": "c",
           "text": "l’olla"
          }
         ]
        },
        {
         "n": 37,
         "prompt": "Buit 37",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "espoliadors"
          },
          {
           "key": "b",
           "text": "expoliadors"
          },
          {
           "key": "c",
           "text": "espol·liadors"
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
           "text": "En tot cas"
          },
          {
           "key": "b",
           "text": "Per contra"
          },
          {
           "key": "c",
           "text": "Nogensmenys"
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
           "text": "“The New York Times” (entre cometes i en cursiva)"
          },
          {
           "key": "b",
           "text": "The New York Times (en lletra redona)"
          },
          {
           "key": "c",
           "text": "The New York Times (en cursiva)"
          }
         ]
        },
        {
         "n": 40,
         "prompt": "Buit 40",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "enfrontar"
          },
          {
           "key": "b",
           "text": "fer front a"
          },
          {
           "key": "c",
           "text": "acarar"
          }
         ]
        },
        {
         "n": 41,
         "prompt": "Buit 41",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "crac"
          },
          {
           "key": "b",
           "text": "crack"
          },
          {
           "key": "c",
           "text": "crak"
          }
         ]
        },
        {
         "n": 42,
         "prompt": "Buit 42",
         "answer": "b",
         "options": [
          {
           "key": "a",
           "text": "Pot ser"
          },
          {
           "key": "b",
           "text": "Potser"
          },
          {
           "key": "c",
           "text": "Pot ser que"
          }
         ]
        },
        {
         "n": 43,
         "prompt": "Buit 43",
         "answer": "a",
         "options": [
          {
           "key": "a",
           "text": "Mentre"
          },
          {
           "key": "b",
           "text": "Mentrestant"
          },
          {
           "key": "c",
           "text": "Mentre que"
          }
         ]
        },
        {
         "n": 44,
         "prompt": "Buit 44",
         "answer": "c",
         "options": [
          {
           "key": "a",
           "text": "empírics"
          },
          {
           "key": "b",
           "text": "panegírics"
          },
          {
           "key": "c",
           "text": "onírics"
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
           "text": "estatus quo"
          },
          {
           "key": "b",
           "text": "status quo"
          },
          {
           "key": "c",
           "text": "statu quo"
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
     "weight": 45,
     "duration": "2 h 30 min",
     "exercises": [
      {
       "n": 4,
       "kind": "writing",
       "title": "Redacció",
       "instructions": "Trieu una de les dos opcions i redacteu un text amb una extensió entre 210 i 230 paraules.",
       "min_words": 210,
       "max_words": 230,
       "choices": [
        {
         "key": "A",
         "text": "Treballeu com a responsable de Recursos Humans d’una empresa de telecomunicacions que oferix servei de telefonia mòbil i d’internet. En els últims mesos l’empresa ha rebut moltes queixes i reclamacions de la clientela per l’atenció inadequada que oferix i per la baixa qualitat del servei, i el balanç de negoci s’ha ressentit molt. Envieu una circular a tota la plantilla en què analitzeu la situació de l’empresa i mostreu el vostre malestar pels resultats tan minsos que ha obtingut. Cal que l’escrit siga contundent, però sense resultar impertinent, perquè voleu evitar que s’hi cree un ambient enrarit. El text ha d’incloure els punts següents:",
         "points": [
          "El malestar per l’allau de queixes i reclamacions que ha rebut l’empresa.",
          "Les conseqüències i perjudicis que pot comportar esta situació.",
          "La decisió que heu adoptat per a revertir la situació abans que siga tard."
         ]
        },
        {
         "key": "B",
         "text": "Treballeu en una empresa de telecomunicacions que oferix servei de telefonia mòbil i d’internet. Sembla que hi han arribat moltes queixes de la clientela, i que la situació de l’empresa no és bona. El responsable de Recursos Humans ha enviat una circular a tota la plantilla en què culpabilitza els treballadors i les treballadores d’esta situació, amb un to dur que no vos ha semblat adequat. Escriviu una carta formal a la Direcció de l’empresa en què mostreu malestar per l’acusació que ha fet el responsable de Recursos Humans i en què exposeu, amb un to irònic, que l’origen del problema pot estar en la gestió d’alguns responsables de l’empresa. El text ha d’incloure els punts següents:",
         "points": [
          "La indignació pel to de la circular i pel retret general que es fa a la plantilla.",
          "La justificació de les bones pràctiques professionals de tota la plantilla.",
          "Una descripció dels problemes que, a parer teu, han conduït a la situació actual."
         ]
        }
       ]
      },
      {
       "n": 5,
       "kind": "writing",
       "title": "Text a partir d’una infografia",
       "instructions": "Trieu una de les dos opcions i redacteu un text amb una extensió entre 200 i 220 paraules.",
       "min_words": 200,
       "max_words": 220,
       "choices": [
        {
         "key": "A",
         "text": "La Conselleria de Medi Ambient ha compartit en xarxes una app que calcula el “volum d’aigua virtual”, és a dir, aquella aigua que no veiem, però que s’usa per a produir els productes i serveis que fem servir cada dia. El fet és que tot el que es fabrica requerix aigua en cada pas de la cadena de producció i distribució. Teniu un blog en què comenteu temes d’actualitat relacionats amb el medi ambient. Decidiu escriure una entrada en el blog en què qüestioneu de manera irònica i subtil que sempre es demane més consciència i sacrificis als petits consumidors. Useu les dades de la infografia per a donar força als vostres arguments.",
         "image": "/exams/c2-octubre-2023/e5-a.jpg",
         "image_text": "Infografia amb vuit aixetes, cadascuna amb el temps que caldria tindre-la oberta (sense cap mecanisme i amb un cabal de 14 l/min) per a gastar l’aigua que fa falta per a produir cada producte: cotxe de 1.100 kg, 3 setmanes; 1 kg de carn, 19 hores; texans, 18 hores; 1 kg d’arròs, 6 hores; samarreta de color, 5 hores; 1 kg d’ous, 4 hores; 1 kg de sucre, 1 hora i 47 minuts; 1 kg de pomes, 50 minuts. Nota: «Xifres en setmanes, hores o minuts d’una aixeta oberta sense cap mecanisme i que raja a 14 l/min.»"
        },
        {
         "key": "B",
         "text": "La legislació actual determina que les ciutats de més de 50.000 habitants i les de més de 20.000 habitants que superen els valors límit de qualitat de l’aire han d’establir zones de baixes emissions (ZBE). Estes zones són entorns urbans delimitats en què es restringix la circulació de vehicles privats, especialment dels més contaminants. Pertanyeu a una associació de persones amb mobilitat reduïda i decidiu redactar un manifest que expose, amb un toc d’humor, les raons per les quals vos oposeu a la creació d’una ZBE universal i indiscriminada en la vostra localitat. L’objectiu és obtindre el suport de l’opinió pública i convéncer les administracions que tinguen en compte les vostres necessitats. Vos heu de basar en esta infografia per a transmetre les vostres idees.",
         "image": "/exams/c2-octubre-2023/e5-b.jpg",
         "image_text": "Cartell «No deixar a ningú arrere en les ZBE», amb els lemes «Confinem els cotxes, recuperem el nostre espai» i «#ConfinemElsCotxes» i el logotip d’Ecologistes en Acció. Textos: «Assegurar una bona accessibilitat amb mitjans alternatius al cotxe»; «Els vehicles de persones discapacitades no han de tindre restriccions»; «Accessibilitat universal»; «Tarifes planes, bons socials i familiars per al transport públic»; «Perspectiva de gènere en el disseny urbà i del transport públic». Il·lustració d’una ciutat amb autobús, tren, persones amb mobilitat reduïda, una persona cega, una cadira de rodes, una parada d’autobús i una persona en bicicleta."
        }
       ]
      }
     ]
    },
    {
     "n": 4,
     "title": "Expressió i interacció orals",
     "weight": 25,
     "duration": "25 minuts aprox.",
     "intro": "Esta àrea té dos parts: un monòleg d’uns tres minuts sobre un tema que tries, amb les idees que has de desenvolupar, i un diàleg d’uns quatre minuts amb una altra persona aspirant, en què defens el paper que et toque.",
     "exercises": [
      {
       "n": 6,
       "kind": "oral",
       "instructions": "Heu de triar un tema i preparar un monòleg de tres minuts, aproximadament. A continuació trobareu el tema sobre el qual heu de parlar i les idees que heu de desenvolupar.",
       "proposals": [
        {
         "title": "Monòleg — Estratègies empresarials",
         "duration": "3 minuts",
         "intro": "Hui en dia hi ha una tendència a substituir els materials o ingredients d’un producte per uns altres de qualitat inferior, perquè les marques no reduïsquen els beneficis. Els qui més perden amb esta mala praxi són els consumidors, que reben un producte pitjor pel mateix preu. Les empreses que adopten esta dubtosa conducta també ixen perjudicades; tarden poc a ser descobertes i denunciades. Sols és una pràctica legal si s’anuncia clarament en l’envàs. Vos han convidat a una tertúlia radiofònica perquè doneu la vostra opinió sobre este fenomen. Cal que tingueu en compte, entre d’altres, estes idees:",
         "questions": [
          "Les conseqüències en la imatge de les empreses.",
          "Els enganys comercials per a mantindre els beneficis.",
          "Els drets dels consumidors: els coneixem bé?"
         ],
         "images": []
        },
        {
         "title": "Monòleg — Cobrar per anar en bicicleta",
         "duration": "3 minuts",
         "intro": "A llocs com França o els Països Baixos, els empleats i les empleades poden arribar a cobrar fins a 1.500 € extra a l’any per anar a la faena en bicicleta. S’hi apliquen incentius fiscals o descomptes per a adquirir-la i, fins i tot, pot comprar-la l’empresa per a la qual es treballa. En el nostre context, també comencen a demanar-se mesures semblants per a facilitar la implantació d’este mitjà de transport. Participeu en una taula redona sobre hàbits saludables organitzada per l’ajuntament de la vostra localitat. Cal que tingueu en compte, entre d’altres, estes idees:",
         "questions": [
          "Els canvis que caldria implantar en les empreses perquè siga viable.",
          "El disseny de les ciutats adaptat a esta nova manera de desplaçar-se.",
          "Avantatges i problemes d’este incentiu per a anar a la faena."
         ],
         "images": []
        }
       ]
      },
      {
       "n": 7,
       "kind": "oral",
       "instructions": "Heu de mantindre un diàleg amb un altre o una altra aspirant sobre la situació comunicativa que vos proposem. Llegiu la introducció del tema i defenseu el paper que vos atorga la proposta ombrejada. Les intervencions han de ser equilibrades; eviteu donar respostes massa curtes i participeu activament com ho faríeu en una conversa habitual. La duració de la conversa serà de quatre minuts, aproximadament.",
       "proposals": [
        {
         "title": "Diàleg — La desjudicialització dels conflictes",
         "duration": "4 minuts",
         "intro": "La mediació és una forma de resolució de conflictes que es fomenta com a alternativa a la via judicial en àmbits com el laboral o el comercial o, fins i tot, en el context de les organitzacions socials. Es tracta de la cerca d’una solució satisfactòria per a les parts implicades, amb l’assistència d’una persona de confiança, que guia el procés.",
         "questions": [],
         "images": [],
         "roles": [
          {
           "name": "Opció A",
           "text": "Participeu en una tertúlia radiofònica sobre resolució de conflictes i penseu que la mediació és una via més econòmica i menys estressant per a les parts implicades. A més, considereu que les solucions alternatives poden ser més satisfactòries que les establides en la legislació."
          },
          {
           "name": "Opció B",
           "text": "Participeu en una tertúlia radiofònica sobre resolució de conflictes i penseu que la mediació, especialment si se n’encarrega algú sense els coneixements necessaris, pot significar que qui tinga la responsabilitat en un acte perjudicial no compense adequadament la víctima. A més, considereu que el seguiment del compliment dels acords és més difícil que en la via judicial."
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
