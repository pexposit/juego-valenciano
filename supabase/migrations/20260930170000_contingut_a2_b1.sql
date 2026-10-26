-- Migració agrupada: 20260930170000_contingut_a2_b1
-- Conté, per ordre, les 12 migracions originals següents:
--   20260930170000_escenaris_a2
--   20261001100000_practice_vocabulari_b1
--   20261001110000_escenaris_b1
--   20261001120000_practice_vocabulari_b1_usual
--   20261001130000_practice_fonetica_b1
--   20261001140000_practice_morfosintaxi_b1
--   20261001150000_revisio_exercicis
--   20261001160000_llicons_morfosintaxi_b1
--   20261001170000_correccio_exercicis_avl
--   20261001180000_llicons_fonetica_b1
--   20261001190000_correccio_exercicis_fonetica_avl
--   20261001200000_escenaris_backgrounds

-- ============================================================
-- Origen: 20260930170000_escenaris_a2.sql
-- ============================================================
-- Escenaris de conversa de l'A2: un per a cada bloc de 3.1 Continguts temàtics
-- i comunicatius del Quadern A2 de la JQCV, amb els punts del bloc com a
-- objectius (metadata.objectius) i un personatge i una situació que els
-- permeten practicar tots. Són recursos de la categoria 'escenari' de nivell
-- principiant; el `type` és la clau de la ruta del xat (/xat/:type).
-- El system_prompt es compon amb el del personatge, els objectius i unes
-- pautes comunes de l'A2. Substituïxen els escenaris A2 anteriors (type 'a2_%').
-- Tornar a aplicar el fitxer no duplica res.

DELETE FROM public.resources WHERE category = 'escenari' AND type LIKE 'a2\_%';

CREATE TEMP TABLE escenaris_a2 AS
SELECT * FROM jsonb_to_recordset($data$[
  {
    "id": "cf006bc1-7402-4706-a7a8-c9b3c6133736", "type": "a2_identificacio", "sort_order": 1,
    "name": "3.1.1. Identificació personal i contacte social", "icon": "🤝", "color": "#F8BBD0", "bg": "#FDEBF2",
    "content": "Estàs en la festa d'aniversari de Núria, una amiga que encara coneixes poc.",
    "voice": "gina", "character": "Núria, amiga que fa anys", "role": "Amiga",
    "greeting": "Hola! Que bé que has vingut a la meua festa! Encara no ens coneixem molt: com et dius i d'on eres?",
    "prompt": "Ets Núria, una jove valenciana que celebra el seu aniversari a casa amb amics. L'aprenent és un convidat que coneixes poc. Pregunta-li qui és, d'on és, quants anys té i a què es dedica. Presenta-li el teu germà Pau (alt, ros, porta una camisa blava, és simpàtic però un poc tímid) i demana-li que et presente algú o que et descriga algú de la seua família o un amic (físic, roba i caràcter). Pregunta-li per la seua família i les seues amistats. Ofereix-li alguna cosa per a beure o menjar. Parleu del que us agrada i del que no (música, menjar, esports) i de com se sent a la festa. Convida'l a una excursió a la muntanya diumenge: pot acceptar-la o excusar-se. Si l'accepta, discutiu qüestions pràctiques (anar en cotxe o en autobús, a quina hora eixir, què cal portar) i demana-li que justifique la seua opinió. Si et fa una invitació o un oferiment, respon-hi, i si s'acomiada, dona-li les gràcies per vindre.",
    "objectius": [
      "Saludar, presentar una tercera persona i presentar-se.",
      "Donar informació sobre u mateix.",
      "Descriure de manera senzilla algú, tant físicament (físic i roba) com psicològicament.",
      "Preguntar i donar dades sobre els membres de la família i les amistats.",
      "Establir contacte social: salutacions i despedides, agraïments.",
      "Fer i acceptar un oferiment o una invitació, i excusar-se.",
      "Dir què li agrada i què no li agrada, i expressar com se sent.",
      "Argumentar sobre qüestions pràctiques de la vida quotidiana."
    ]
  },
  {
    "id": "d46ec394-b6e6-43d5-bc71-1acfbc44bcd1", "type": "a2_casa", "sort_order": 2,
    "name": "3.1.2. Casa i entorn", "icon": "🏠", "color": "#FFE0B2", "bg": "#FFF3E0",
    "content": "Xavi serà el teu nou company de pis i et telefona abans de mudar-se.",
    "voice": "lluc", "character": "Xavi, nou company de pis", "role": "Company de pis",
    "greeting": "Hola! Soc Xavi, el nou company de pis. Dissabte faig la mudança i no conec la zona: on està exactament el pis?",
    "prompt": "Ets Xavi, un estudiant que dissabte es muda al pis de l'aprenent i li telefona perquè no coneix la zona. Pregunta-li on està el pis (carrer, número, planta, prop de què està) i com s'hi arriba. Conta-li on vius ara tu (un pis xicotet al centre de Castelló, sense ascensor). Demana-li que et descriga el pis per dins: quantes habitacions té, com és la teua habitació, quins mobles hi ha i com està decorat. Pregunta-li on es troben algunes coses que necessitaràs (la planxa, l'escombra, les tovalloles, el tornavís i el martell per a penjar uns quadres, la caixa de ferramentes) i fes preguntes fins que t'ho explique amb precisió (davall de, damunt de, dins de, al costat de...). Finalment, pregunta-li com és el barri i quins servicis públics hi ha (centre de salut, escola, biblioteca, mercat, parada d'autobús o de metro, poliesportiu).",
    "objectius": [
      "Preguntar i explicar a on viu algú. Situar la vivenda respecte de la ubicació física.",
      "Descriure la vivenda per dins i parlar de mobiliari o decoració.",
      "Explicar a on es troben objectes o ferramentes dins de casa.",
      "Descriure el barri (servicis públics)."
    ]
  },
  {
    "id": "30b9402e-61bd-4f8b-a465-b00088b96072", "type": "a2_activitats", "sort_order": 3,
    "name": "3.1.3. Activitats quotidianes i temps lliure", "icon": "🎬", "color": "#D1C4E9", "bg": "#EFEAF7",
    "content": "Et trobes Toni, un amic del gimnàs, i parleu de la vostra setmana i del cap de setmana.",
    "voice": "lluc", "character": "Toni, amic del gimnàs", "role": "Amic",
    "greeting": "Hola! Quant de temps! Què tal la setmana? Jo no pare: faena, gimnàs... Tu què fas normalment entre setmana?",
    "prompt": "Ets Toni, un amic que l'aprenent ha conegut al gimnàs. Primer parleu de la vostra rutina: horaris, què feu cada dia i amb quina freqüència (sempre, sovint, a vegades, mai). Tu t'alces a les set, treballes en una botiga i vas al gimnàs tres dies a la setmana. Pregunta-li què fa en el temps lliure. Conta-li què vas fer el cap de setmana passat (vas anar d'excursió a la Serra Calderona) i pregunta-li pel seu, per les seues aficions i per algun viatge que haja fet. Pregunta-li què preferix: cine, teatre, llegir, fer esport, anar a un concert... Finalment, proposa-li plans per a este dissabte (anar al cine, a un concert a la plaça, a la festa del poble...) i deixa que ell en propose d'altres; decidiu què fareu, on i a quina hora quedeu.",
    "objectius": [
      "Demanar i donar informació sobre les activitats quotidianes i d'oci.",
      "Expressar preferències sobre activitats com, per exemple, cinema, lectures, teatre, esports...",
      "Proposar diferents activitats lúdiques o festives.",
      "Intercanviar informació sobre activitats, com ara viatges, aficions, fets ocorreguts...",
      "Descriure costums i hàbits (horaris, freqüència, activitats...)."
    ]
  },
  {
    "id": "afa5fcf8-919e-482e-b9d9-4a0470d86489", "type": "a2_menjar", "sort_order": 4,
    "name": "3.1.4. Menjar i beure", "icon": "🍽️", "color": "#DCEDC8", "bg": "#F1F8E9",
    "content": "Telefones al restaurant L'Albufera per a reservar un sopar amb uns amics.",
    "voice": "gina", "character": "Empar, propietària del restaurant", "role": "Propietària del restaurant",
    "greeting": "Restaurant L'Albufera, bona vesprada! Soc Empar. En què et puc ajudar?",
    "prompt": "Ets Empar, la propietària del restaurant L'Albufera, i atens el telèfon. L'aprenent vol reservar taula. Pregunta-li, d'una en una, les dades de la reserva: dia, hora, nombre de persones, on vol seure (a la terrassa o dins, prop de la finestra) i un nom. El restaurant obri de dimarts a diumenge, de 13 a 16 h i de 20.30 a 23.30 h. Quan pregunte què hi ha per a menjar, explica-li la carta i el menú: menú del dia de 15 € (inclou pa, beguda —aigua, vi o cervesa; els refrescos no— i postres o café) amb amanida valenciana o sopa de peix de primer, i arròs a banda, pollastre al forn o lluç a la planxa de segon; fora de menú, paella valenciana a 14 € per persona (per encàrrec, mínim dues persones). Deixa que faça la comanda per endavant, que demane aclariments (què porta un plat, si pica) i que expresse preferències (vegetarià, sense gluten). Pregunta-li pels seus hàbits: a quina hora sol sopar, què menja normalment. Com que vols posar plats nous a la carta, demana-li que t'explique com es prepara un plat del seu país o de la seua família: ingredients, quantitats i passos. Al final, repetix la reserva per a confirmar-la.",
    "objectius": [
      "Reservar una taula en un restaurant (hora, persones, ubicació...).",
      "Parlar d'hàbits gastronòmics: horaris, classes d'aliments...",
      "Fer una comanda en un restaurant, demanar aclariments o expressar preferències.",
      "Entendre la carta o el menú (preus, aliments, begudes incloses o no, etc.).",
      "Explicar breument i donar indicacions de com es du a terme la preparació d'un plat (ingredients i mesures, procediment...)."
    ]
  },
  {
    "id": "faf47c95-6ed0-4135-8e05-34ab053fdea8", "type": "a2_servicis", "sort_order": 5,
    "name": "3.1.5. Servicis", "icon": "🛍️", "color": "#B3E5FC", "bg": "#E1F5FE",
    "content": "Estàs en uns grans magatzems i demanes ajuda a Lídia, del punt d'informació.",
    "voice": "gina", "character": "Lídia, dependenta dels grans magatzems", "role": "Dependenta",
    "greeting": "«Atenció, senyors clients: hui el centre tancarà a les nou de la nit.» Bon dia! Soc Lídia, del punt d'informació. Què necessites?",
    "prompt": "Ets Lídia, dependenta del punt d'informació d'uns grans magatzems. Ajuda l'aprenent amb el que necessite. Horaris: les botigues obrin de 10 a 21 h de dilluns a dissabte; el cine de la tercera planta té sessions a les 17, 19.30 i 22 h (entrada 7 €, 5 € el dimecres); l'autobús 12 para a la porta cada 15 minuts i el metro més pròxim és la parada Àngel Guimerà. Tens un fullet de la programació del cine i un altre de les ofertes de la setmana que li pots llegir. Si pregunta per rètols («Eixida d'emergència», «Provadors», «Caixa», «Ascensor», «Rebaixes»), explica'ls. De tant en tant, abans de parlar, llig entre cometes un avís breu de megafonia («Atenció: el cotxe amb matrícula 1234 ABC té les llums enceses», «La sessió de les 19.30 comença d'ací a deu minuts») i comprova que l'ha entés. Quan vulga comprar alguna cosa, fes de dependenta: pregunta què vol, de quin color, quina talla o grandària; ensenya-li opcions amb preu (una jaqueta blava de 45 €, uns pantalons negres de 30 €) i pregunta com vol pagar (en efectiu o amb targeta).",
    "objectius": [
      "Demanar i dir horaris de botigues, espectacles, mitjans de transport públic i altres classes de servicis.",
      "Comprendre rètols i fullets informatius dels diferents servicis (teatres, cinemes, autobús, metro, etc.).",
      "Entendre els missatges emesos per megafonia en estacions, teatres i altres espais públics.",
      "Demanar i dir què vol, i especificar algunes qualitats d'un producte (color, talla, grandària...). Demanar el preu d'alguna cosa i pagar."
    ]
  },
  {
    "id": "616f46c5-3743-423e-9386-c7743fa82297", "type": "a2_faena", "sort_order": 6,
    "name": "3.1.6. Estudis, faena i relacions professionals", "icon": "💼", "color": "#CFD8DC", "bg": "#ECEFF1",
    "content": "Et trobes pel carrer Sílvia, una companya de l'institut que no veies des de fa anys.",
    "voice": "gina", "character": "Sílvia, antiga companya de l'institut", "role": "Antiga companya",
    "greeting": "No m'ho puc creure! Eres tu? Quants anys sense vore'ns! Què fas ara? Estudies o treballes?",
    "prompt": "Ets Sílvia, una antiga companya de l'institut que es troba l'aprenent pel carrer després de molts anys. Pregunta-li què estudia o en què treballa, en quina empresa o centre, quin horari té, quant cobra aproximadament i com són les condicions (contracte, vacances, companys, distància de casa). Conta-li també la teua situació: treballes d'infermera a l'Hospital La Fe, fas torns de matí i de nit, guanyes uns 1.800 € al mes i t'agradaria tindre més vacances; a més, estudies anglés dos vesprades a la setmana a l'Escola Oficial d'Idiomes. Compareu les vostres faenes i estudis i pregunta-li si està content. Al final, proposa prendre un café un altre dia.",
    "objectius": [
      "Preguntar i dir què estudia o quin treball fa algú.",
      "Preguntar i donar informació sobre els estudis o el treball (horaris, salari, nom de l'empresa...).",
      "Intercanviar informació sobre la classe de faena i les condicions laborals."
    ]
  },
  {
    "id": "7170877e-0856-4145-bc9b-3d35cbb77d49", "type": "a2_clima", "sort_order": 7,
    "name": "3.1.7. Clima i oratge", "icon": "🌦️", "color": "#BBDEFB", "bg": "#E3F2FD",
    "content": "Liam, un amic irlandés que et vindrà a visitar, et telefona per preguntar pel temps.",
    "voice": "lluc", "character": "Liam, amic irlandés", "role": "Amic estranger",
    "greeting": "Hola! Soc Liam, des de Dublín. La setmana que ve vinc a veure't i no sé quina roba portar! Quin temps fa allí?",
    "prompt": "Ets Liam, un amic irlandés que parla valencià i vindrà a visitar l'aprenent la setmana que ve. Pregunta-li com és el clima on viu en les diferents estacions, quin temps fa estos dies i quina roba has de portar. Conta-li com és el temps a Dublín (plou molt, fa fred, a l'estiu fa uns 20 graus). En algun moment, llig-li entre cometes la previsió del temps que has sentit a la ràdio: «Per al cap de setmana a València: dissabte, cel assolellat i temperatures de 18 a 26 graus; diumenge, núvols i possibilitat de pluja a la vesprada, amb vent de llevant.» Pregunta-li què ha entés i si cal portar paraigua. Fes-li preguntes concretes sobre l'oratge (fa molta calor a l'estiu?, neva a l'hivern?, plou molt a la tardor?).",
    "objectius": [
      "Entendre la informació atmosfèrica llegida o sentida en algun mitjà de comunicació.",
      "Explicar de manera bàsica el clima del lloc a on es viu o fer algun aclariment sobre l'oratge en un moment concret."
    ]
  },
  {
    "id": "54d5f053-4217-404a-bc74-0757f336ff1a", "type": "a2_viatges", "sort_order": 8,
    "name": "3.1.8. Viatges", "icon": "✈️", "color": "#B2EBF2", "bg": "#E0F7FA",
    "content": "Telefones a l'Hotel Mar Blau de Peníscola per a reservar una habitació per a les vacances.",
    "voice": "lluc", "character": "Jordi, recepcionista de l'hotel", "role": "Recepcionista",
    "greeting": "Hotel Mar Blau de Peníscola, bon dia! Li parla Jordi. Digue'm, què desitja?",
    "prompt": "Ets Jordi, recepcionista de l'Hotel Mar Blau de Peníscola, i atens una trucada. L'aprenent vol reservar una habitació. Pregunta-li, d'una en una: per a quins dies (arribada i eixida), quantes persones, quina classe d'habitació vol (individual 60 €/nit, doble 85 €/nit, doble amb vistes a la mar 100 €/nit), si vol l'esmorzar (10 € per persona) o mitja pensió (25 €), i el seu nom i telèfon. Servicis: piscina, aparcament (12 €/dia), wifi gratuït. Pregunta-li d'on ve i com pensa viatjar, i informa'l dels mitjans de transport: tren fins a Benicarló-Peníscola i després autobús (cada hora) o taxi; autobús directe des de València (2 h 30 min, 15 €); en cotxe, per l'AP-7. Tens el fullet d'excursions de l'hotel, que li pots llegir si pregunta: «Visita al castell del Papa Luna, dimarts i dijous a les 10 h, 8 €; eixida en vaixell a les illes Columbretes, dissabte a les 9 h, 45 €, dinar inclòs.» Respon als seus dubtes sobre el viatge (durada, horaris, preus) i, al final, repetix les dades de la reserva i el preu total. Usa el tractament de vosté amb amabilitat.",
    "objectius": [
      "Preguntar i donar informació sobre viatges: destinació, duració, horaris, transports, classes d'allotjament, preu, etc.",
      "Comprendre els fullets informatius sobre viatges.",
      "Per telèfon, reservar una habitació en un hotel (classe d'habitació, dies, servicis...).",
      "Donar i demanar informació sobre els diferents mitjans de transport."
    ]
  }
]$data$::jsonb) AS t(
  id uuid, type text, sort_order smallint, name text, icon text, color text, bg text,
  content text, voice text, character text, role text, greeting text, prompt text, objectius jsonb
);

-- El nom de la secció és el del bloc sense el número.
INSERT INTO public.resources (id, name, type, category, content, difficulty, xp_earned, sort_order, metadata)
SELECT id, name, type, 'escenari', content, 'principiant', 10, sort_order,
       jsonb_build_object(
         'icon', icon,
         'color', color,
         'bgIllustration', bg,
         'voice', voice,
         'scenario', type,
         'character', character,
         'character_role', role,
         'section_name', regexp_replace(name, '^[0-9.]+\s*', ''),
         'initial_prompt', greeting,
         'objectius', objectius,
         'system_prompt', prompt || E'\n\n' ||
           'Pautes: l''aprenent prepara el nivell A2 de la JQCV. Parla en valencià general (normativa de l''AVL), amb frases curtes i clares, vocabulari quotidià i una sola pregunta per torn (màxim 2-3 frases). ' ||
           'Mai no ixes del personatge ni fas lliçons de gramàtica: si l''aprenent s''equivoca o usa un castellanisme, reformula la frase correcta dins de la teua resposta amb naturalitat. ' ||
           'Si no t''entén, repetix-ho de manera més senzilla. Dona dades concretes quan te les pregunte i no resolgues tu la situació: fes-lo parlar. ' ||
           E'\nObjectius que ha de complir l''aprenent (guia la conversa perquè els complisca d''un en un, sense enumerar-los): ' ||
           (SELECT string_agg(o, ' | ') FROM jsonb_array_elements_text(objectius) AS o) ||
           ' Quan els haja complit tots, tanca la situació amb naturalitat i acomiada''t.'
       )
FROM escenaris_a2
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  type = EXCLUDED.type,
  category = EXCLUDED.category,
  content = EXCLUDED.content,
  difficulty = EXCLUDED.difficulty,
  sort_order = EXCLUDED.sort_order,
  metadata = EXCLUDED.metadata;

DROP TABLE escenaris_a2;

-- ============================================================
-- Origen: 20261001100000_practice_vocabulari_b1.sql
-- ============================================================
-- Vocabulari del B1 (Quadern B1 de la JQCV, 3.1 Continguts temàtics i
-- comunicatius). Un contingut de Lèxic i semàntica per a cada bloc del temari
-- (3.1.1 a 3.1.12), amb els exercicis de nivell B1. Són recursos de nivell
-- intermedi: la pantalla d'activitats només mostra els del nivell de l'aprenent
-- i, dins de cada contingut, els exercicis dels seus nivells del MECR (B1-B2).
-- Tornar a aplicar el fitxer no duplica res: es reescriuen els exercicis B1.

CREATE TEMP TABLE practice_catalog AS
SELECT * FROM jsonb_to_recordset($data$[
  {
    "id": "3c2cdca6-70e4-4a53-99af-2db26e50aaea", "type": "b1_vocab_persones", "sort_order": 1,
    "title": "Informació personal i familiar", "name": "Hàbits, família, habitatge i com són les persones",
    "content": "Costums i hàbits, l'entorn familiar i l'habitatge, l'aspecte físic, el caràcter i les apreciacions sobre altres persones (3.1.1).", "icon": "👨‍👩‍👧", "color": "#FFCCBC",
    "exercises": [
      {"q": "«Cada dia m'alce a les sis: m'agrada ___.» Quin verb vol dir 'alçar-se molt prompte'?", "o": ["matinar", "trasnitar", "dormisquejar"], "e": "Matinar: alçar-se de bon matí. Trasnitar és anar-se'n a dormir molt tard."},
      {"q": "«Els caps de setmana sempre ___ : no me'n vaig al llit abans de les tres.»", "o": ["trasnite", "matine", "desdejune"], "e": "Trasnitar: passar la nit sense dormir o gitar-se molt tard."},
      {"q": "Com es diu en valencià la 'siesta', el son curt després de dinar?", "o": ["la becaina", "la vetlada", "la sobretaula"], "e": "Fer la becaina (o la migdiada). La sobretaula és la conversa després de dinar."},
      {"q": "El temps que passem a taula parlant després d'haver dinat és...", "o": ["la sobretaula", "la becaina", "el berenar"], "e": "La sobretaula: estar-se a taula xarrant després de menjar."},
      {"q": "«Tinc el ___ de llegir un poc abans de dormir.» Quina paraula vol dir 'costum'?", "o": ["hàbit", "habitatge", "hàbitat"], "e": "Un hàbit és un costum. L'habitatge és la casa i l'hàbitat, el medi on viu un ésser."},
      {"q": "Una persona que fa les coses sempre de la mateixa manera i a la mateixa hora és...", "o": ["metòdica", "despistada", "impulsiva"], "e": "Metòdica: que seguix un ordre i un mètode."},
      {"q": "El pare de ton avi és el teu...", "o": ["besavi", "rebesavi", "padrí"], "e": "Besavi: el pare de l'avi o de l'àvia. El pare del besavi és el rebesavi."},
      {"q": "El fill de ta néta és el teu...", "o": ["besnét", "nebot", "fillol"], "e": "Besnét: el fill del nét o de la néta."},
      {"q": "El nou marit de ta mare, que no és el teu pare, és el teu...", "o": ["padrastre", "padrí", "sogre"], "e": "Padrastre (i madrastra). El padrí és qui t'apadrina en el bateig."},
      {"q": "El fill que la teua parella té d'un matrimoni anterior és el teu...", "o": ["fillastre", "fillol", "gendre"], "e": "Fillastre (i fillastra): fill de l'altre membre de la parella."},
      {"q": "Dos germans que tenen només el pare o només la mare en comú són...", "o": ["germanastres", "cosins germans", "bessons"], "e": "Germanastres (o mig germans)."},
      {"q": "Dos germans que naixen en el mateix part són...", "o": ["bessons", "germanastres", "cosins"], "e": "Bessons (o bessones)."},
      {"q": "El xiquet de qui eres padrí en el bateig és el teu...", "o": ["fillol", "fillastre", "nebot"], "e": "El padrí i la padrina tenen un fillol o una fillola."},
      {"q": "El fill del cosí de ta mare és el teu...", "o": ["cosí segon", "cosí germà", "nebot"], "e": "Els fills dels cosins germans dels pares són cosins segons."},
      {"q": "Una parella que viu junta i s'ha inscrit en el registre sense casar-se és una...", "o": ["parella de fet", "parella divorciada", "família monoparental"], "e": "Parella de fet: unió registrada sense matrimoni."},
      {"q": "Una família formada per un sol progenitor i els seus fills és una família...", "o": ["monoparental", "nombrosa", "extensa"], "e": "Monoparental: amb un sol pare o una sola mare. Nombrosa: amb molts fills."},
      {"q": "«Els meus pares es van ___ fa dos anys i ara viuen en cases diferents.»", "o": ["separar", "casar", "jubilar"], "e": "Separar-se o divorciar-se: deixar de viure en parella."},
      {"q": "«Ma germana ja no treballa: es va ___ l'any passat, als seixanta-cinc anys.»", "o": ["jubilar", "acomiadar", "matricular"], "e": "Jubilar-se: deixar de treballar per l'edat. Una persona jubilada (o pensionista)."},
      {"q": "Una persona que té el cabell amb molts rinxols té el cabell...", "o": ["arrissat", "llis", "curt"], "e": "Arrissat (amb rínxols). El contrari és el cabell llis."},
      {"q": "Un home que no té cabell és...", "o": ["calb", "ros", "barbut"], "e": "Calb: sense cabell. Barbut: amb barba."},
      {"q": "Les taquetes marrons xicotetes que alguns tenen a la cara són...", "o": ["pigues", "arrugues", "celles"], "e": "Les pigues. Les arrugues són els plecs de la pell que ixen amb els anys."},
      {"q": "El pèl que alguns hòmens tenen damunt del llavi superior és...", "o": ["el bigot", "la barba", "la cella"], "e": "El bigot. La barba cobrix les galtes i el mentó."},
      {"q": "Una persona alta, prima i elegant és...", "o": ["esvelta", "rabassuda", "grassoneta"], "e": "Esvelta. Rabassut: baix i gros, ample."},
      {"q": "Una persona baixeta i ampla, de cos fort, és...", "o": ["rabassuda", "esvelta", "escanyolida"], "e": "Rabassuda. Escanyolit: massa prim, de poca carn."},
      {"q": "«Mon germà i jo som com dues gotes d'aigua»: què vol dir?", "o": ["Que ens assemblem moltíssim", "Que no ens parlem", "Que plorem molt"], "e": "Ser com dues gotes d'aigua: semblar-se molt."},
      {"q": "«Ha eixit a son pare»: què vol dir?", "o": ["Que s'assembla a son pare", "Que ha anat a buscar son pare", "Que viu amb son pare"], "e": "Eixir a algú: assemblar-s'hi en el físic o en el caràcter."},
      {"q": "Una persona que parla molt, sense parar, és...", "o": ["xarraire", "callada", "tímida"], "e": "Xarraire (o parlador). El contrari: callat, reservat."},
      {"q": "Una persona que sempre vol saber què fan els altres és...", "o": ["tafanera", "discreta", "generosa"], "e": "Tafaner: que s'interessa massa per la vida dels altres."},
      {"q": "Una persona que no canvia d'opinió encara que no tinga raó és...", "o": ["tossuda", "flexible", "comprensiva"], "e": "Tossut (o caparrut, cabut)."},
      {"q": "Una persona a qui no li agrada treballar i ho deixa tot per a després és...", "o": ["gandula", "feinera", "responsable"], "e": "Gandul (o mandrós). El contrari és feiner o treballador."},
      {"q": "Una persona que treballa molt i amb ganes és...", "o": ["feinera", "gandula", "pesada"], "e": "Feiner: treballador, diligent."},
      {"q": "Una persona a qui li costa gastar diners, fins i tot en coses necessàries, és...", "o": ["garrepa", "generosa", "malgastadora"], "e": "Garrepa (o agarrat). El contrari és generós o esplèndid."},
      {"q": "Una persona que sent enveja del que tenen els altres és...", "o": ["envejosa", "gelosa", "orgullosa"], "e": "Envejós: que té enveja. Gelós: que té por de perdre l'amor d'algú."},
      {"q": "Una persona que es creu superior als altres és...", "o": ["arrogant", "humil", "modesta"], "e": "Arrogant (o altiu, fanfarró). El contrari és humil o modest."},
      {"q": "Una persona que s'enfada amb facilitat té...", "o": ["mal geni", "bon cor", "bona mà"], "e": "Tindre mal geni: enfadar-se fàcilment. Tindre bon cor: ser bona persona."},
      {"q": "Quin adjectiu NO descriu un caràcter positiu?", "o": ["egoista", "amable", "pacient"], "e": "Egoista: que només pensa en si mateix."},
      {"q": "«La meua veïna és un tros de pa»: quina apreciació en fa?", "o": ["Favorable: és molt bona persona", "Desfavorable: és molt grossa", "Neutra: treballa en un forn"], "e": "Ser un tros de pa: ser molt bo i amable."},
      {"q": "«Eixe xic té més morro que un camió»: com és?", "o": ["Fresc, poc vergonyós", "Molt tímid", "Molt treballador"], "e": "Tindre molt de morro (o molta barra): fer les coses sense vergonya, aprofitant-se dels altres."},
      {"q": "Quina frase fa una apreciació DESFAVORABLE sobre una persona?", "o": ["No m'hi fie gens: sempre diu mentides.", "És una persona molt de fiar.", "Sempre et dona un cop de mà."], "e": "No fiar-se d'algú és una valoració negativa."},
      {"q": "«Ma cosina és més alta ___ jo, però jo sóc ___ tranquil·la que ella.»", "o": ["que / més", "com / tan", "de / molt"], "e": "La comparació de superioritat: més ... que."},
      {"q": "«El meu germà és ___ simpàtic ___ el teu.» (igualtat)", "o": ["tan / com", "més / com", "tant / que"], "e": "Igualtat amb adjectius: tan + adjectiu + com."},
      {"q": "Una casa unida a una altra per una paret, en una filera de cases iguals, és un...", "o": ["adossat", "àtic", "xalet aïllat"], "e": "Un adossat. L'àtic és el pis de dalt de tot d'un edifici."},
      {"q": "El pis més alt d'un edifici, sovint amb terrassa, és...", "o": ["l'àtic", "l'entresol", "el soterrani"], "e": "L'àtic. L'entresol està entre la planta baixa i el primer pis."},
      {"q": "L'espai a l'entrada de la casa, just darrere de la porta, és...", "o": ["el rebedor", "el traster", "el safareig"], "e": "El rebedor. El traster és on guardem les coses que no usem."},
      {"q": "On es renta i s'estén la roba en moltes cases valencianes?", "o": ["a la galeria", "al rebedor", "al menjador"], "e": "La galeria: espai, normalment interior, per a rentar i estendre la roba."},
      {"q": "El conjunt de veïns d'un edifici que es reunixen per a decidir coses és...", "o": ["la comunitat de veïns", "l'associació de pares", "el veïnat de dalt"], "e": "La comunitat de veïns (o de propietaris)."},
      {"q": "Escriu la paraula: la mare de la meua besàvia és la meua ___.", "a": ["rebesàvia"], "e": "Avi → besavi → rebesavi; àvia → besàvia → rebesàvia."},
      {"q": "Escriu el contrari de «generós».", "a": ["garrepa", "agarrat", "avar", "gasiu", "egoista"], "e": "Garrepa, agarrat, avar o gasiu."},
      {"q": "Escriu l'adjectiu: persona que no té paciència és ___.", "a": ["impacient"], "e": "Prefix in- (im- davant de p): impacient."},
      {"q": "Escriu el femení de «padrastre».", "a": ["madrastra"], "e": "Padrastre → madrastra."}
    ]
  },
  {
    "id": "29bc8568-fb92-49f3-ac40-e73ebf5417a7", "type": "b1_vocab_relacions", "sort_order": 2,
    "title": "Relació amb els altres", "name": "Invitacions, celebracions, cartes i fórmules socials",
    "content": "Convidar i respondre a una invitació, celebracions, cartes personals i altres actes comunicatius freqüents (3.1.2).", "icon": "💌", "color": "#F8BBD0",
    "exercises": [
      {"q": "La festa que se celebra quan dues persones es casen és...", "o": ["les noces", "el bateig", "la comunió"], "e": "Les noces (o el casament, la boda)."},
      {"q": "La cerimònia religiosa en què es posa el nom a un nadó és...", "o": ["el bateig", "el casament", "l'aniversari"], "e": "El bateig. Batejar un xiquet."},
      {"q": "L'aniversari de noces quan una parella fa vint-i-cinc anys de casats són les noces de...", "o": ["plata", "or", "diamant"], "e": "Noces de plata (25 anys), d'or (50) i de diamant (60)."},
      {"q": "Un sopar per a dir adeu a un company que se'n va de l'empresa és un sopar de...", "o": ["comiat", "benvinguda", "noces"], "e": "Sopar de comiat. Comiadar-se: dir adeu."},
      {"q": "La persona que organitza una festa a sa casa i rep els convidats és...", "o": ["l'amfitrió", "el convidat", "el padrí"], "e": "L'amfitrió o l'amfitriona."},
      {"q": "El menjar i la beguda que s'oferix en una celebració és...", "o": ["el convit", "el convidat", "la convidada"], "e": "El convit (o el banquet). El convidat és la persona invitada."},
      {"q": "En una invitació: «Us agrairem que ___ l'assistència abans del 15 de maig.»", "o": ["confirmeu", "conformeu", "confieu"], "e": "Confirmar l'assistència: dir si hi anireu."},
      {"q": "«Ens faria molta il·lusió que vingueres al sopar»: què fa qui ho diu?", "o": ["Convida", "Refusa", "Es queixa"], "e": "És una fórmula afectuosa per a convidar."},
      {"q": "Com acceptes amablement una invitació?", "o": ["Hi aniré amb molt de gust!", "Em sap greu, no puc.", "Ja ho pensaré, ja."], "e": "Amb molt de gust (o encantat/encantada) per a acceptar."},
      {"q": "Com refuses educadament una invitació?", "o": ["Em sap molt de greu, però eixe dia ja tinc un compromís.", "No vull vindre.", "Les teues festes són avorrides."], "e": "Saber greu + una excusa: és la manera cortés de refusar."},
      {"q": "Què vol dir «Em sap greu»?", "o": ["Ho lamente", "M'agrada molt", "Tinc pressa"], "e": "Saber greu: lamentar, sentir."},
      {"q": "Què dius a qui fa anys?", "o": ["Per molts anys!", "Bon profit!", "Que vaja bé el viatge!"], "e": "Per molts anys! (o Moltes felicitats!)."},
      {"q": "Què dius a una persona a qui se li ha mort un familiar?", "o": ["T'acompanye en el sentiment.", "Enhorabona!", "Que t'ho passes bé!"], "e": "Donar el condol: t'acompanye en el sentiment / et done el condol."},
      {"q": "Què dius a una parella que acaba de tindre un fill?", "o": ["Enhorabona pel naixement!", "Que et milloren!", "T'acompanye en el sentiment."], "e": "Enhorabona (o felicitats) per a felicitar."},
      {"q": "Què dius a algú que està malalt?", "o": ["Que et milloren!", "Per molts anys!", "Bon viatge!"], "e": "Que et milloren! o Que et poses bo prompte!"},
      {"q": "Què es diu en brindar?", "o": ["Salut!", "Jesús!", "Au!"], "e": "Brindar: alçar les copes i dir Salut!"},
      {"q": "Quina és la salutació més adequada per a començar una carta a una amiga?", "o": ["Estimada Marta,", "Distingida senyora,", "Benvolguda clienta,"], "e": "Estimat/estimada per a cartes personals. Distingit o benvolgut són més formals."},
      {"q": "Quina és la fórmula més adequada per a acabar una carta a un familiar?", "o": ["Una abraçada molt forta,", "Atentament,", "Rebeu una salutació cordial,"], "e": "Una abraçada, un bes, molts besets... en cartes familiars. Atentament és formal."},
      {"q": "En una carta, què vol dir la sigla P.D.?", "o": ["Postdata: el que s'afig després de signar", "Per Dir: el que vols dir", "Primera Data: el dia que escrius"], "e": "P.D. (postdata) introduïx una nota afegida al final."},
      {"q": "En una carta personal, què introduïx la frase «T'escric per a contar-te que...»?", "o": ["El motiu de la carta", "El comiat", "La data"], "e": "Després de la salutació, s'explica el motiu: t'escric per a..."},
      {"q": "«Records a la teua família»: on sol aparéixer esta frase?", "o": ["En el comiat d'una carta o missatge", "En una sol·licitud oficial", "En un anunci de treball"], "e": "Donar records (o salutacions) a algú: fórmula de comiat afectuosa."},
      {"q": "«Fa temps que no ens veiem! Quan quedem?»: què vol dir «quedar»?", "o": ["Fixar una cita per a veure's", "Romandre a casa", "Discutir"], "e": "Quedar (amb algú): fixar un dia i un lloc per a veure's."},
      {"q": "«He de ___ la cita amb el dentista: dimarts no puc anar-hi.»", "o": ["ajornar", "acordar", "assistir"], "e": "Ajornar: deixar per a més avant. Anul·lar: suspendre-la del tot."},
      {"q": "«Ens van ___ a la inauguració, però no hi vam poder anar.»", "o": ["convidar", "convindre", "conviure"], "e": "Convidar: invitar. Convindre: ser oportú. Conviure: viure junts."},
      {"q": "Un missatge breu que deixes escrit a un company per a avisar-lo d'alguna cosa és...", "o": ["una nota", "una instància", "un currículum"], "e": "Una nota o un avís."},
      {"q": "Quina frase és apropiada en una nota per a un company de pis?", "o": ["He eixit a comprar. Torne a les set. Si crida ma mare, digues-li que la telefonaré.", "Sol·licite que em concedisquen el permís.", "Benvolgut senyor, li comunique..."], "e": "Una nota informal: directa, breu i amb el tractament de tu."},
      {"q": "Quina frase és la resposta adequada a una invitació formal?", "o": ["Agraïm la vostra invitació i hi assistirem amb molt de gust.", "Vale, vinc.", "Ja vorem."], "e": "En contextos formals: agrair, confirmar i fer servir un registre cuidat."},
      {"q": "«Dissabte faig una festa sorpresa per a Pau. No li ho digues, eh!» Què demana?", "o": ["Que guarde el secret", "Que porte el pastís", "Que no hi vaja"], "e": "Una festa sorpresa: el protagonista no en sap res."},
      {"q": "El regal que es fa als nuvis és el regal de...", "o": ["noces", "bateig", "comiat"], "e": "Els nuvis són els qui es casen. Regal de noces."},
      {"q": "Les persones que es casen són...", "o": ["els nuvis", "els padrins", "els convidats"], "e": "El nuvi i la núvia."},
      {"q": "Què vol dir «fer-se el sord» quan algú et parla?", "o": ["Fer veure que no se sent", "Tindre mal d'orella", "Parlar molt fort"], "e": "Fer-se el sord: fingir que no s'ha sentit."},
      {"q": "«Gràcies per tot!» «___»", "o": ["No es mereixen.", "Igualment.", "Enhorabona."], "e": "No es mereixen o De res: resposta a un agraïment."},
      {"q": "«Bon Nadal!» «___»", "o": ["Igualment!", "No es mereixen!", "Que et milloren!"], "e": "Igualment: retornar el mateix desig."},
      {"q": "Quan dius a algú «Que vaja bé!» abans d'un examen, li estàs...", "o": ["desitjant sort", "donant el condol", "demanant perdó"], "e": "Que vaja bé! / Molta sort!"},
      {"q": "Com demanes disculpes per arribar tard?", "o": ["Perdoneu el retard, hi havia molt de trànsit.", "Arribe quan vull.", "Enhorabona pel retard."], "e": "Perdoneu / disculpeu + la justificació."},
      {"q": "«Felicitats pel nou treball!» És una...", "o": ["felicitació", "queixa", "invitació"], "e": "Felicitar: expressar alegria pel bé d'una altra persona."},
      {"q": "Què vol dir «trencar el gel» en una festa?", "o": ["Començar una conversa per a superar la incomoditat", "Posar gel a les begudes", "Discutir amb algú"], "e": "Trencar el gel: fer que una situació siga més relaxada."},
      {"q": "Què vol dir «donar carabasses» a algú?", "o": ["Rebutjar-lo, dir-li que no", "Fer-li un regal", "Convidar-lo a sopar"], "e": "Donar carabasses: rebutjar algú, sobretot en l'amor."},
      {"q": "Escriu la paraula: carta breu, sovint il·lustrada, que s'envia quan vas de viatge.", "a": ["postal", "una postal", "targeta postal"], "e": "Una postal (o targeta postal)."},
      {"q": "Escriu el verb: dir adeu a algú quan se'n va és ___.", "a": ["acomiadar", "acomiadar-se", "comiadar", "comiadar-se"], "e": "Acomiadar-se (o comiadar-se) d'algú."},
      {"q": "Escriu el que es diu per a desitjar una bona entrada d'any: «Bon ___ nou!»", "a": ["any"], "e": "Bon any nou! o Feliç any nou!"},
      {"q": "Escriu la paraula: persona a qui s'ha convidat a una festa.", "a": ["convidat", "convidada", "el convidat", "la convidada"], "e": "El convidat o la convidada."}
    ]
  },
  {
    "id": "48c44cc5-47dc-495a-90db-26a0ffb69525", "type": "b1_vocab_vida_quotidiana", "sort_order": 3,
    "title": "Vida quotidiana", "name": "Tasques de casa, compres i reclamacions",
    "content": "Les tasques del dia, descriure el producte que es vol comprar (quantitat, preu, color, mida, material) i reclamar per un article defectuós (3.1.3).", "icon": "🛒", "color": "#C8E6C9",
    "exercises": [
      {"q": "Abans de dinar, posem les estovalles, els plats i els coberts: estem...", "o": ["parant taula", "alçant taula", "fent dissabte"], "e": "Parar taula: preparar-la per a menjar."},
      {"q": "Després de sopar, llevem els plats i les estovalles: estem...", "o": ["alçant taula", "parant taula", "estenent"], "e": "Alçar taula (o desparar taula): llevar-ho tot després de menjar."},
      {"q": "Al País Valencià, «fer dissabte» vol dir...", "o": ["netejar a fons la casa", "no treballar", "anar de festa"], "e": "Fer dissabte: fer la neteja general de la casa."},
      {"q": "Amb què agranem el terra?", "o": ["amb la granera", "amb el fregall", "amb la planxa"], "e": "Agranar amb la granera (escombra)."},
      {"q": "Amb què fem net el terra amb aigua i sabó?", "o": ["amb la fregona i el poal", "amb la granera i el recollidor", "amb l'estenedor"], "e": "Fregar el terra amb la fregona i el poal (cubell)."},
      {"q": "Després de rentar la roba, la penges perquè s'eixugue: l'...", "o": ["estens", "planxes", "plegues"], "e": "Estendre la roba (amb pinces, a l'estenedor)."},
      {"q": "Quan la roba ja està seca, la llevem de l'estenedor: la...", "o": ["arrepleguem", "estenem", "remullem"], "e": "Arreplegar (o replegar) la roba."},
      {"q": "Per a llevar les arrugues de la camisa, la...", "o": ["planxes", "estens", "cuses"], "e": "Planxar la roba amb la planxa."},
      {"q": "Abaixar el fem al contenidor és...", "o": ["traure el fem", "fer el llit", "fer la compra"], "e": "Traure el fem (la brossa). El contenidor groc és per a envasos i el blau, per a paper."},
      {"q": "On tirem les botelles de vidre per a reciclar-les?", "o": ["al contenidor verd", "al contenidor groc", "al contenidor blau"], "e": "Verd: vidre. Groc: envasos de plàstic i llaunes. Blau: paper i cartó."},
      {"q": "L'electrodomèstic que renta els plats és...", "o": ["el rentaplats", "la rentadora", "l'assecadora"], "e": "El rentaplats (o rentavaixelles). La rentadora renta la roba."},
      {"q": "Passar l'aspiradora, fer el llit i regar les plantes són...", "o": ["tasques domèstiques", "tràmits administratius", "aficions"], "e": "Tasques domèstiques (o de casa)."},
      {"q": "«Hui em toca a mi ___ el gos.» Quin verb fa servir per a eixir a passejar-lo?", "o": ["traure", "llevar", "portar-se'n"], "e": "Traure el gos (a passejar)."},
      {"q": "«Abans de les nou he de ___ els xiquets a l'escola.»", "o": ["dur", "dutxar", "despertar-se"], "e": "Dur (o portar) els xiquets a l'escola."},
      {"q": "En una botiga de roba: «Quina ___ fa vosté?» «La M.»", "o": ["talla", "número", "mesura"], "e": "La talla per a la roba (S, M, L...). El número per a les sabates."},
      {"q": "En una sabateria: «Quin ___ calça?» «El 39.»", "o": ["número", "talla", "pes"], "e": "Calçar un número: la mida de les sabates."},
      {"q": "On et proves la roba abans de comprar-la?", "o": ["al provador", "a l'aparador", "a la caixa"], "e": "El provador. L'aparador és on s'exposen els articles cap al carrer."},
      {"q": "L'època de l'any en què la roba és més barata és la de les...", "o": ["rebaixes", "ofertes de treball", "despeses"], "e": "Les rebaixes (de gener i d'estiu)."},
      {"q": "Una cosa molt bona a un preu molt baix és...", "o": ["una ganga", "una estafa", "una factura"], "e": "Una ganga (o una bicoca)."},
      {"q": "«Este jersei és de ___: abriga molt i ve de les ovelles.»", "o": ["llana", "seda", "lli"], "e": "La llana ve de les ovelles. La seda, dels cucs; el lli i el cotó, de plantes."},
      {"q": "Unes sabates fetes amb cuiro de vaca són de...", "o": ["pell", "cotó", "niló"], "e": "De pell (o de cuiro). Altres materials: de lona, de goma, sintètiques."},
      {"q": "«M'agradaria una camisa de ___, que és fresca per a l'estiu.»", "o": ["cotó", "llana", "pana"], "e": "El cotó i el lli són frescos; la llana i la pana, d'hivern."},
      {"q": "Una camisa d'un sol color, sense dibuixos, és...", "o": ["llisa", "de ratlles", "de quadres"], "e": "Llisa. De ratlles, de quadres, de flors o de pics (lunars)."},
      {"q": "Una tela amb rodonetes de color és...", "o": ["de pics", "de ratlles", "llisa"], "e": "De pics (o de boletes)."},
      {"q": "Per a què servix un «obridor»?", "o": ["Per a obrir llaunes o botelles", "Per a tallar pa", "Per a pesar fruita"], "e": "La finalitat de l'objecte: un obrellaunes o un obreampolles."},
      {"q": "Pagar amb bitllets i monedes és pagar...", "o": ["en efectiu", "amb targeta", "a terminis"], "e": "En efectiu (o al comptat, en metàl·lic)."},
      {"q": "Pagar una cosa a poc a poc, en diversos mesos, és pagar...", "o": ["a terminis", "en efectiu", "per avançat"], "e": "A terminis (o en quotes)."},
      {"q": "El paper que et donen en pagar i que has de guardar per a tornar l'article és...", "o": ["el tiquet de compra", "la recepta", "el contracte"], "e": "El tiquet (o comprovant) de compra."},
      {"q": "El període en què l'establiment ha de reparar gratuïtament un aparell que s'espatla és...", "o": ["la garantia", "la rebaixa", "la devolució"], "e": "La garantia: normalment, tres anys per als productes nous."},
      {"q": "«La rentadora s'ha ___ i ja no centrifuga.»", "o": ["espatlat", "estés", "rebaixat"], "e": "Espatlar-se (o fer-se malbé): deixar de funcionar bé."},
      {"q": "«He obert la caixa i el got estava ___: té un tros menys.»", "o": ["trencat", "descosit", "tacat"], "e": "Trencat. Per a la roba: descosit (si s'obri la costura) o esgarrat (si està romput)."},
      {"q": "«Els pantalons tenen una costura oberta.» Estan...", "o": ["descosits", "desinflats", "desfets"], "e": "Descosit: que se li ha desfet el cosit."},
      {"q": "«La llet que he comprat hui ja estava ___: feia mala olor.»", "o": ["passada", "fresca", "congelada"], "e": "Passada (o en mal estat): que s'ha fet malbé."},
      {"q": "Un producte que ha passat la data de consum preferent està...", "o": ["caducat", "rebaixat", "en oferta"], "e": "Caducat: ha passat la data de caducitat."},
      {"q": "Quin document demanes en un establiment per a fer una reclamació oficial?", "o": ["el full de reclamacions", "la carta del restaurant", "el llibre de visites"], "e": "Tots els establiments han de tindre fulls de reclamacions."},
      {"q": "Quina és la frase més adequada per a reclamar en una botiga?", "o": ["Vaig comprar este mòbil fa una setmana i no s'encén. Voldria que me'l canviaren o que em tornaren els diners.", "Este mòbil és una porqueria!", "Doneu-me un mòbil."], "e": "Una reclamació clara: què vas comprar, quan, què li passa i què demanes."},
      {"q": "«Si no queda satisfet, li ___ els diners.»", "o": ["tornem", "cobrem", "gastem"], "e": "Tornar els diners (o reemborsar)."},
      {"q": "Canviar un article per un altre o tornar-lo a la botiga és fer...", "o": ["un canvi o una devolució", "una factura", "un pressupost"], "e": "Un canvi o una devolució (amb el tiquet)."},
      {"q": "El document on un taller t'indica quant costarà una reparació abans de fer-la és...", "o": ["el pressupost", "el rebut", "el catàleg"], "e": "El pressupost."},
      {"q": "El servici que repara els aparells que no funcionen és el servici...", "o": ["tècnic", "d'urgències", "militar"], "e": "El servici tècnic (o d'assistència tècnica)."},
      {"q": "«Cal fer la compra: ___ una dotzena d'ous i mig quilo de tomaques.»", "o": ["necessitem", "sobren", "ens han tornat"], "e": "Una dotzena: dotze. Mig quilo: cinc-cents grams."},
      {"q": "Comprar per internet i rebre el paquet a casa és comprar...", "o": ["en línia", "a terminis", "a l'engròs"], "e": "Comprar en línia (o per internet). La comanda arriba amb el missatger."},
      {"q": "La persona que porta els paquets a domicili és...", "o": ["el repartidor", "el venedor ambulant", "el caixer"], "e": "El repartidor (o el missatger)."},
      {"q": "Escriu el verb: el contrari d'«estendre» la roba és ___ la roba.", "a": ["arreplegar", "replegar", "recollir", "despenjar"], "e": "Arreplegar, replegar o recollir la roba."},
      {"q": "Escriu la paraula: llista de tot el que has de comprar al supermercat.", "a": ["la llista de la compra", "llista de la compra", "llista"], "e": "La llista de la compra."},
      {"q": "Escriu el material: una bossa feta de paper és de ___.", "a": ["paper"], "e": "De paper. Altres materials: de plàstic, de tela, de vidre, de fusta, de metall."},
      {"q": "Escriu el verb valencià: el contrari de «parar taula».", "a": ["alçar taula", "desparar taula", "alçar", "desparar"], "e": "Alçar taula o desparar taula."}
    ]
  },
  {
    "id": "bb9d81a8-ec10-438f-bdca-ce5933d487eb", "type": "b1_vocab_llocs", "sort_order": 4,
    "title": "Llocs i habitatge", "name": "La ciutat, el barri, els servicis i buscar allotjament",
    "content": "Descriure la ciutat, el poble o el barri amb els seus servicis i comunicacions, i el pis o l'allotjament que es busca (3.1.4).", "icon": "🏘️", "color": "#D1C4E9",
    "exercises": [
      {"q": "L'edifici on treballen l'alcalde i els regidors és...", "o": ["l'ajuntament", "la diputació", "el jutjat"], "e": "L'ajuntament (o la casa de la vila). L'alcalde o l'alcaldessa el presidix."},
      {"q": "On vas a fer esport, a la piscina municipal o a jugar a bàsquet?", "o": ["al poliesportiu", "al centre de salut", "a la llotja"], "e": "El poliesportiu (o pavelló esportiu)."},
      {"q": "On vas al metge de capçalera del teu barri?", "o": ["al centre de salut", "a l'ajuntament", "a la casa de cultura"], "e": "El centre de salut (o ambulatori)."},
      {"q": "On deixes en préstec llibres i pel·lícules sense pagar?", "o": ["a la biblioteca municipal", "a la llibreria", "a la papereria"], "e": "La biblioteca presta. La llibreria ven llibres."},
      {"q": "On deixen els pares els xiquets menors de tres anys mentre treballen?", "o": ["a l'escoleta (o escola infantil)", "a l'institut", "a la residència"], "e": "L'escoleta, l'escola infantil o la guarderia."},
      {"q": "On estudien els adolescents l'ESO i el batxillerat?", "o": ["a l'institut", "a l'escoleta", "a la universitat"], "e": "L'institut d'educació secundària (IES)."},
      {"q": "On viuen i són atesos molts majors que necessiten ajuda?", "o": ["en una residència de majors", "en un alberg", "en una escoleta"], "e": "Una residència de majors (o de la tercera edat). També hi ha centres de dia."},
      {"q": "On s'envien cartes i paquets?", "o": ["a l'oficina de correus", "a la comissaria", "a la gestoria"], "e": "Correus. Les cartes es tiren a la bústia."},
      {"q": "On denuncies que t'han furtat la cartera?", "o": ["a la comissaria de policia", "al parc de bombers", "a la biblioteca"], "e": "A la comissaria (policia local o nacional) o al quarter de la Guàrdia Civil."},
      {"q": "Un carrer on no poden passar cotxes és un carrer...", "o": ["de vianants", "d'un sol sentit", "de doble sentit"], "e": "Carrer de vianants (o zona de vianants). Els vianants van a peu."},
      {"q": "El camí reservat per a les bicicletes és...", "o": ["el carril bici", "la vorera", "l'autovia"], "e": "El carril bici. La vorera és la part del carrer per a vianants."},
      {"q": "La part del carrer per on caminen les persones, més alta que la calçada, és...", "o": ["la vorera", "la calçada", "la rotonda"], "e": "La vorera. La calçada és per als vehicles."},
      {"q": "Un barri «ben comunicat» és un barri que...", "o": ["té bones connexions de transport públic", "té molts veïns xarraires", "té bona cobertura de mòbil"], "e": "Ben comunicat: amb autobús, metro, tren o bones carreteres a prop."},
      {"q": "Un barri on hi ha molta vida, botigues i gent pel carrer és un barri...", "o": ["animat", "tranquil", "residencial"], "e": "Animat (o amb molt de moviment). El contrari: tranquil, adormit."},
      {"q": "Una zona de la ciutat on hi ha sobretot cases i pocs comerços és una zona...", "o": ["residencial", "industrial", "comercial"], "e": "Residencial. En un polígon industrial hi ha fàbriques i naus."},
      {"q": "La part més antiga d'una ciutat és...", "o": ["el nucli antic (o el centre històric)", "l'eixample", "el polígon"], "e": "El nucli antic o centre històric. L'eixample és la zona nova, de carrers amples."},
      {"q": "Els barris i pobles que hi ha al voltant d'una gran ciutat són...", "o": ["la rodalia (o els afores)", "el nucli antic", "l'eixample"], "e": "La rodalia, els afores o l'àrea metropolitana."},
      {"q": "La gent que viu en un mateix barri o carrer és...", "o": ["el veïnat", "la plantilla", "el públic"], "e": "El veïnat: el conjunt dels veïns."},
      {"q": "El mercat que es fa al carrer un dia concret de la setmana és...", "o": ["el mercat ambulant (o el mercadet)", "el centre comercial", "el supermercat"], "e": "El mercat ambulant, el mercadet o el mercat de dijous, de dimarts..."},
      {"q": "«En el meu poble hi ha molts ___: tres forns, dues farmàcies i un estanc.»", "o": ["comerços", "habitants", "polígons"], "e": "Comerç (botiga), pl. comerços."},
      {"q": "Les persones que viuen en un poble o ciutat són els seus...", "o": ["habitants", "turistes", "regidors"], "e": "Habitants. Un poble de cinc mil habitants."},
      {"q": "Viure en un pis que no és teu i pagar-ne cada mes és viure de...", "o": ["lloguer", "hipoteca", "herència"], "e": "De lloguer. Llogar un pis; el llogater paga al propietari."},
      {"q": "La persona que viu de lloguer en un pis és...", "o": ["el llogater", "el propietari", "l'agent immobiliari"], "e": "El llogater (o l'inquilí)."},
      {"q": "Els diners que pagues en entrar en un pis de lloguer i que et tornen quan te'n vas són...", "o": ["la fiança", "la hipoteca", "la propina"], "e": "La fiança: garantix que deixaràs el pis en bon estat."},
      {"q": "El préstec que demanes al banc per a comprar una casa és...", "o": ["una hipoteca", "una fiança", "un rebut"], "e": "Una hipoteca. Es paga en quotes mensuals."},
      {"q": "L'empresa que t'ajuda a comprar, vendre o llogar un pis és...", "o": ["una immobiliària", "una gestoria", "una asseguradora"], "e": "Una (agència) immobiliària."},
      {"q": "Un pis que es llogua amb mobles és un pis...", "o": ["moblat", "buit", "reformat"], "e": "Moblat (amb mobles). Sense mobles: buit."},
      {"q": "Un pis que té finestres que donen al carrer és un pis...", "o": ["exterior", "interior", "fosc"], "e": "Exterior. Un pis interior dona a un pati de llums."},
      {"q": "Un pis on entra molta llum natural és...", "o": ["lluminós", "fosc", "humit"], "e": "Lluminós (o assolellat, si hi toca molt el sol)."},
      {"q": "Un pis amb taques a les parets per l'aigua i l'ambient és un pis...", "o": ["humit", "sec", "assolellat"], "e": "Humit: hi ha humitat."},
      {"q": "Els diners mensuals que pagues per a netejar l'escala o mantindre l'ascensor són...", "o": ["les despeses de comunitat", "la fiança", "la nòmina"], "e": "Les despeses (o quotes) de comunitat."},
      {"q": "Per a saber com és de gran una vivenda, mirem els...", "o": ["metres quadrats", "metres cúbics", "quilòmetres"], "e": "Un pis de 90 metres quadrats (m²)."},
      {"q": "«Busque un pis amb ___: tinc cotxe i al meu carrer no hi ha on aparcar.»", "o": ["plaça de garatge", "traster", "galeria"], "e": "Plaça de garatge (o d'aparcament)."},
      {"q": "Quin és l'aparell que escalfa la casa a l'hivern?", "o": ["la calefacció", "l'aire condicionat", "el ventilador"], "e": "La calefacció. L'aire condicionat refresca a l'estiu."},
      {"q": "Viure en un pis amb altres persones, cadascú en la seua habitació, és...", "o": ["compartir pis", "llogar un xalet", "viure de propietari"], "e": "Compartir pis: tens companys de pis."},
      {"q": "Un allotjament econòmic per a joves, amb habitacions compartides, és...", "o": ["un alberg", "un parador", "un hotel de cinc estreles"], "e": "Un alberg (juvenil)."},
      {"q": "On dorms en una tenda de campanya amb servicis comuns?", "o": ["en un càmping", "en un apartahotel", "en una casa rural"], "e": "En un càmping (o en una zona d'acampada)."},
      {"q": "Una casa al camp, adaptada per a llogar-la als turistes, és...", "o": ["una casa rural", "un adossat", "un àtic"], "e": "Una casa rural. Al País Valencià, també una masia o un mas restaurat."},
      {"q": "Una casa tradicional de l'horta de València, amb sostre de palla molt inclinat, és...", "o": ["una barraca", "una masia", "una alqueria"], "e": "La barraca. L'alqueria és una casa de llauradors més gran."},
      {"q": "«Busque un pis ___ la universitat, perquè vull anar-hi a peu.»", "o": ["a prop de", "lluny de", "fora de"], "e": "A prop de: a poca distància. Per a expressar les necessitats: necessite, busque, m'interessa..."},
      {"q": "En un anunci, «2 hab., 1 bany, cuina equipada» vol dir...", "o": ["dues habitacions, un bany i cuina amb electrodomèstics", "dos habitants i una bassa", "dues hipoteques"], "e": "Hab. = habitacions. Equipada: amb nevera, forn, placa..."},
      {"q": "Un pis «a estrenar» és un pis...", "o": ["nou: no hi ha viscut ningú", "molt vell", "per a enderrocar"], "e": "A estrenar: que mai s'ha usat."},
      {"q": "Escriu la paraula: lloc de la vorera on espera l'autobús.", "a": ["parada", "la parada", "parada d'autobús"], "e": "La parada (de l'autobús)."},
      {"q": "Escriu la paraula: persona que va a peu pel carrer.", "a": ["vianant", "el vianant", "la vianant"], "e": "El vianant o la vianant."},
      {"q": "Escriu el verb: pagar per a viure en una casa d'un altre és ___ una casa.", "a": ["llogar"], "e": "Llogar (no «alquilar»). El lloguer."},
      {"q": "Escriu la paraula: lloc del pis on es guarden les coses que no s'usen sovint.", "a": ["traster", "el traster", "golfa", "les golfes"], "e": "El traster (o les golfes, si és davall de la teulada)."}
    ]
  },
  {
    "id": "9714fab7-3383-48bd-8547-ff6c73181491", "type": "b1_vocab_viatges", "sort_order": 5,
    "title": "Viatges i transports", "name": "Maneres de viatjar, bitllets i com arribar a un lloc",
    "content": "Preferències i valoracions de viatges, comprar o reservar bitllets i demanar com arribar a un lloc (3.1.5).", "icon": "✈️", "color": "#B3E5FC",
    "exercises": [
      {"q": "Un bitllet per a anar i tornar al punt de partida és un bitllet...", "o": ["d'anada i tornada", "senzill", "d'anada"], "e": "D'anada i tornada. El bitllet senzill és només d'anada."},
      {"q": "Al tren, el seient al costat de la finestra és el seient de...", "o": ["finestreta", "passadís", "cabina"], "e": "Seient de finestreta. Al costat del passadís: de passadís."},
      {"q": "On esperes el tren a l'estació?", "o": ["a l'andana", "a la pista", "a la porta d'embarcament"], "e": "A l'andana. El tren arriba per la via 3, per exemple."},
      {"q": "On compres els bitllets a l'estació?", "o": ["a la taquilla (o a la màquina expenedora)", "a l'andana", "a la consigna"], "e": "La taquilla o la màquina expenedora de bitllets."},
      {"q": "On deixes les maletes unes hores a l'estació?", "o": ["a la consigna", "a la taquilla", "a la duana"], "e": "La consigna: servici per a guardar l'equipatge."},
      {"q": "La persona que comprova els bitllets en el tren és...", "o": ["el revisor", "el conductor", "l'hostessa de terra"], "e": "El revisor (o la revisora)."},
      {"q": "Canviar de tren o de línia de metro per a continuar el viatge és fer...", "o": ["transbord", "escala", "parada"], "e": "Fer transbord. En avió es diu fer escala."},
      {"q": "Un vol que para en un altre aeroport abans d'arribar al destí és un vol amb...", "o": ["escala", "transbord", "retard"], "e": "Vol amb escala. Sense parades: vol directe."},
      {"q": "En l'aeroport, deixar la maleta gran perquè vaja en la bodega de l'avió és...", "o": ["facturar l'equipatge", "embarcar", "aterrar"], "e": "Facturar. La maleta xicoteta que portes amb tu és l'equipatge de mà."},
      {"q": "El document que necessites per a pujar a l'avió, amb el teu seient, és...", "o": ["la targeta d'embarcament", "el passaport de vacunes", "el bonobús"], "e": "La targeta d'embarcament."},
      {"q": "Quan l'avió s'alça de terra, diem que...", "o": ["s'enlaira", "aterra", "embarca"], "e": "Enlairar-se (o envolar-se). En arribar, aterra."},
      {"q": "«El vol arriba amb dues hores de ___ per la boira.»", "o": ["retard", "avançament", "antelació"], "e": "Retard. Si el vol no es fa: cancel·lació."},
      {"q": "Fer una reserva amb temps vol dir fer-la amb...", "o": ["antelació", "retard", "urgència"], "e": "Amb antelació: amb temps."},
      {"q": "«Voldria ___ dos bitllets per al tren de les 8.15 a Barcelona, per al 12 de juliol.»", "o": ["reservar", "facturar", "embarcar"], "e": "Reservar: assegurar-te una plaça. Especifica el nombre, l'hora i la data."},
      {"q": "Al tren, la classe més econòmica és la classe...", "o": ["turista", "preferent", "business"], "e": "Classe turista (o estàndard). La preferent és més cara i còmoda."},
      {"q": "El període de l'any amb més turistes i preus més alts és la temporada...", "o": ["alta", "baixa", "mitjana"], "e": "Temporada alta. La temporada baixa és més barata."},
      {"q": "Un allotjament on t'inclouen l'esmorzar i el sopar és en règim de...", "o": ["mitja pensió", "pensió completa", "només allotjament"], "e": "Mitja pensió: esmorzar i una altra menjada. Pensió completa: totes."},
      {"q": "Un viatge en què l'agència ho organitza tot (transport, hotel, visites) és un viatge...", "o": ["organitzat", "per lliure", "de negocis"], "e": "Viatge organitzat. Si ho fas tot tu: viatjar per lliure."},
      {"q": "Un viatge per mar en un vaixell gran, visitant diversos ports, és un...", "o": ["creuer", "transbord", "ferri"], "e": "Un creuer. El ferri (o transbordador) porta passatgers i cotxes."},
      {"q": "Viatjar amb motxilla, gastant poc i movent-se molt, és viatjar...", "o": ["de motxilla", "en primera classe", "en creuer"], "e": "Viatjar de motxilla (o amb motxilla)."},
      {"q": "«M'estime més viatjar en tren que en avió.» Què expressa?", "o": ["Una preferència", "Una queixa", "Una obligació"], "e": "Estimar-se més: preferir."},
      {"q": "«El viatge ha valgut la pena»: com el valora?", "o": ["Positivament", "Negativament", "No el valora"], "e": "Valer la pena: ser profitós, compensar l'esforç."},
      {"q": "«Ha sigut un desastre: van perdre la maleta i l'hotel era brut.» Com valora el viatge?", "o": ["Negativament", "Positivament", "No el valora"], "e": "Un desastre: valoració molt negativa."},
      {"q": "El lloc on vas de vacances és la teua...", "o": ["destinació", "procedència", "andana"], "e": "La destinació. El lloc d'on véns és la procedència."},
      {"q": "El document que necessites per a viatjar fora de la Unió Europea és...", "o": ["el passaport", "la targeta SIP", "el carnet de conduir"], "e": "El passaport. Per a alguns països també cal visat."},
      {"q": "El control on revisen allò que portes en entrar en un altre país és...", "o": ["la duana", "la consigna", "la taquilla"], "e": "La duana."},
      {"q": "Una targeta que et permet fer molts viatges en autobús o metro a un preu més baix és...", "o": ["un abonament (o un bonobús)", "un pressupost", "un rebut"], "e": "Un abonament de transport o un bonobús."},
      {"q": "El tren que unix una gran ciutat amb els pobles de la rodalia és...", "o": ["el tren de rodalia", "el tren d'alta velocitat", "el tren de mercaderies"], "e": "Rodalia (Renfe Rodalia València, per exemple)."},
      {"q": "«Perdone, per a anar a l'estació del Nord?» «___ recte fins al semàfor i després gire a mà dreta.»", "o": ["Seguisca", "Puja", "Agafe"], "e": "Seguir recte (o tirar recte). En el tractament de vosté: seguisca, gire, agafe..."},
      {"q": "El lloc on es troben dos carrers és...", "o": ["la cantonada (o el cantó)", "la vorera", "la rotonda"], "e": "La cantonada, el cantó o l'encreuament."},
      {"q": "Una plaça circular on els cotxes giren al voltant és...", "o": ["una rotonda", "una cantonada", "un pas de vianants"], "e": "Una rotonda (o glorieta)."},
      {"q": "Les ratlles blanques al terra per on travessen els vianants són...", "o": ["el pas de vianants (o pas de zebra)", "el carril bici", "la vorera"], "e": "El pas de vianants o pas de zebra."},
      {"q": "«Agafe el primer ___ a l'esquerra, just després de la farmàcia.»", "o": ["bocacarrer", "andana", "peatge"], "e": "El bocacarrer: l'entrada d'un carrer, on s'ajunta amb un altre."},
      {"q": "«Quina línia de metro he d'agafar per a anar a la platja?» Què demana?", "o": ["Quin mitjà de transport cal usar", "El preu de l'hotel", "On és el revisor"], "e": "Demanar informació sobre el mitjà de transport."},
      {"q": "«Quant es tarda a peu fins al museu?» «Uns deu minuts. Està ___.»", "o": ["a prop", "lluny", "fora de mà"], "e": "A prop. Fora de mà: lluny o mal situat."},
      {"q": "Una carretera ampla, amb dos o més carrils per sentit i sense encreuaments, de pagament, és...", "o": ["una autopista", "un camí rural", "una senda"], "e": "Autopista (de peatge). L'autovia és semblant però gratuïta."},
      {"q": "El que es paga per a circular per algunes autopistes és...", "o": ["el peatge", "la fiança", "la propina"], "e": "El peatge."},
      {"q": "On posem gasolina o gasoil al cotxe?", "o": ["a la gasolinera", "al taller", "a l'aparcament"], "e": "A la gasolinera (o estació de servici)."},
      {"q": "«Hem de ___ en la propera parada.»", "o": ["baixar", "pujar", "abaixar"], "e": "Baixar del tren o de l'autobús. Pujar-hi en entrar."},
      {"q": "Un trajecte que es fa cada dia per anar a treballar, per exemple, de Sagunt a València, és un trajecte...", "o": ["diari (o quotidià)", "turístic", "internacional"], "e": "Moltes persones fan cada dia el mateix trajecte: els qui viuen fora i treballen a la ciutat."},
      {"q": "Escriu la paraula: lloc de l'estació on deixes les maletes durant unes hores.", "a": ["consigna", "la consigna"], "e": "La consigna."},
      {"q": "Escriu la paraula: el contrari d'«enlairar-se» (l'avió arriba a terra).", "a": ["aterrar"], "e": "Aterrar."},
      {"q": "Escriu el verb: canviar de tren per a continuar el viatge és fer ___.", "a": ["transbord", "un transbord"], "e": "Fer transbord."},
      {"q": "Escriu la paraula: equipatge xicotet que portes amb tu a l'avió, l'equipatge de ___.", "a": ["mà"], "e": "L'equipatge de mà."}
    ]
  },
  {
    "id": "e5554b24-9965-4d64-9f25-e39d7638f482", "type": "b1_vocab_oci_esport", "sort_order": 6,
    "title": "L'oci i l'esport", "name": "Ofertes culturals, temps lliure i esport amb seguretat",
    "content": "Interpretar l'oferta cultural, opinar i comparar maneres de passar el temps lliure i proposar una activitat o un esport amb les seues normes de seguretat (3.1.6).", "icon": "🎭", "color": "#FFE0B2",
    "exercises": [
      {"q": "La secció del diari on hi ha les pel·lícules i les obres de teatre que fan cada dia és...", "o": ["la cartellera", "l'esquela", "la portada"], "e": "La cartellera."},
      {"q": "El primer dia que es projecta una pel·lícula és...", "o": ["l'estrena", "l'assaig", "l'entreacte"], "e": "L'estrena. Estrenar una pel·lícula o una obra."},
      {"q": "«Entrades ___»: ja no en queda cap per a vendre.", "o": ["esgotades", "gratuïtes", "anticipades"], "e": "Entrades esgotades. Penjar el cartell de «complet»."},
      {"q": "En un concert, «entrada lliure» vol dir que...", "o": ["no cal pagar", "cal portar roba lliure", "pots seure on vulgues pagant el doble"], "e": "Entrada lliure (o gratuïta) fins a completar l'aforament."},
      {"q": "El nombre màxim de persones que caben en un local és...", "o": ["l'aforament", "la taquilla", "l'escenari"], "e": "L'aforament."},
      {"q": "Cada una de les vegades que es projecta una pel·lícula en un dia és...", "o": ["una sessió", "una estrena", "una temporada"], "e": "Una sessió (de vesprada, de nit...). En teatre: funció o representació."},
      {"q": "El descans a la meitat d'una obra de teatre és...", "o": ["l'entreacte", "l'estrena", "el bis"], "e": "L'entreacte."},
      {"q": "El lloc on actuen els actors o els músics és...", "o": ["l'escenari", "la platea", "la taquilla"], "e": "L'escenari. El públic seu a la platea, a les llotges o a l'amfiteatre."},
      {"q": "Una mostra d'obres d'art en un museu o una galeria és...", "o": ["una exposició", "una cartellera", "una estrena"], "e": "Una exposició (temporal o permanent)."},
      {"q": "Un article que analitza i valora una pel·lícula o un llibre és...", "o": ["una crítica (o una ressenya)", "una esquela", "un anunci"], "e": "Una crítica o una ressenya."},
      {"q": "Una pel·lícula en la versió original, amb el text traduït a baix, és...", "o": ["subtitulada", "doblada", "muda"], "e": "En versió original subtitulada (VOS). Doblada: amb les veus traduïdes."},
      {"q": "Una pel·lícula que fa molta por és de...", "o": ["terror", "comèdia", "dibuixos animats"], "e": "De terror. Altres gèneres: comèdia, drama, ciència-ficció, d'aventures, policíaca."},
      {"q": "«Esta exposició és apta per a tots els públics»: vol dir que...", "o": ["la poden veure persones de qualsevol edat", "només per a adults", "només per a xiquets"], "e": "Apta per a tots els públics: sense límit d'edat."},
      {"q": "«Em ve de gust anar al cine esta nit.» Què expressa?", "o": ["Desig o ganes", "Obligació", "Rebuig"], "e": "Vindre de gust: tindre ganes."},
      {"q": "«Em fa mandra eixir: hui m'estime més quedar-me a casa.» Què expressa?", "o": ["Falta de ganes i preferència", "Entusiasme", "Por"], "e": "Fer mandra: no tindre ganes de fer una cosa."},
      {"q": "«El concert m'ha encantat: ha sigut ___.»", "o": ["genial", "avorrit", "pesat"], "e": "Valoració positiva: genial, fantàstic, impressionant."},
      {"q": "«La pel·lícula era tan lenta que m'he adormit.» Era...", "o": ["avorrida", "emocionant", "divertida"], "e": "Avorrit: que no interessa i cansa."},
      {"q": "Una persona a qui agrada molt una activitat n'és...", "o": ["aficionada", "àrbitra", "patrocinadora"], "e": "Aficionat a la música, al futbol... L'afició és el conjunt d'aficionats."},
      {"q": "Per a mi, llegir és més ___ que veure la televisió: aprens més coses.", "o": ["enriquidor", "avorrit", "car"], "e": "Comparar maneres de passar el temps lliure: més/menys ... que."},
      {"q": "«I si anem d'excursió a la muntanya diumenge?» És...", "o": ["un suggeriment", "una ordre", "una queixa"], "e": "I si...? / Per què no...? / Què et pareix si...? per a suggerir."},
      {"q": "Quina és la resposta per a ACCEPTAR una proposta?", "o": ["D'acord, bona idea!", "Ni parlar-ne!", "No em ve gens de gust."], "e": "D'acord / Fet! / Vinga! per a acceptar."},
      {"q": "Quina és la resposta per a REFUSAR una proposta?", "o": ["Ho sent, però no m'agrada gens córrer.", "Perfecte, quedem a les nou!", "Compta amb mi!"], "e": "Excusar-se i justificar el rebuig."},
      {"q": "Caminar per la muntanya seguint camins i senders és fer...", "o": ["senderisme", "escalada", "piragüisme"], "e": "Senderisme. Els senders estan senyalitzats (GR, PR)."},
      {"q": "Pujar parets de roca amb cordes és fer...", "o": ["escalada", "submarinisme", "ciclisme"], "e": "Escalada. Cal portar casc i arnés."},
      {"q": "Baixar un riu en una barca menuda que es mou amb rem és fer...", "o": ["piragüisme", "vela", "natació"], "e": "Piragüisme (o caiac)."},
      {"q": "Bussejar sota l'aigua amb ampolles d'oxigen és fer...", "o": ["submarinisme", "surf", "rem"], "e": "Submarinisme. Amb tub i ulleres: fer snorkel o bussejar."},
      {"q": "Quina és una norma de seguretat per a anar en bicicleta?", "o": ["Portar casc i armilla reflectant de nit", "Anar per la vorera a molta velocitat", "Portar auriculars a tot volum"], "e": "El casc protegix el cap; l'armilla reflectant fa que et vegen."},
      {"q": "Abans de començar a córrer, cal...", "o": ["escalfar i estirar els músculs", "menjar molt", "beure alcohol"], "e": "Escalfar (fer exercicis suaus) i estirar per a evitar lesions."},
      {"q": "Per a fer piragüisme és obligatori portar...", "o": ["l'armilla salvavides", "les botes de muntanya", "la raqueta"], "e": "L'armilla salvavides."},
      {"q": "A la platja, la bandera roja vol dir...", "o": ["que està prohibit banyar-se", "que l'aigua està calenta", "que hi ha socorrista nou"], "e": "Bandera verda: bany lliure; groga: precaució; roja: prohibit el bany."},
      {"q": "Un avantatge de nadar és que...", "o": ["exercita tot el cos sense fer mal a les articulacions", "es pot fer sense aigua", "és molt perillós"], "e": "Justificar els avantatges d'un esport."},
      {"q": "Un inconvenient de l'esquí és que...", "o": ["és car i cal anar lluny, a la neu", "es practica a la platja", "no cal cap material"], "e": "Avantatges i inconvenients: és car, cal desplaçar-se..."},
      {"q": "La persona que dirigix un partit i fa complir les regles és...", "o": ["l'àrbitre", "l'entrenador", "el capità"], "e": "L'àrbitre (o l'àrbitra). L'entrenador prepara l'equip."},
      {"q": "Quan dos equips acaben el partit amb els mateixos gols, han...", "o": ["empatat", "guanyat", "golejat"], "e": "Empatar: empat a dos, per exemple."},
      {"q": "El conjunt de partits entre diversos equips durant una temporada és...", "o": ["la lliga", "la xarxa", "la porteria"], "e": "La lliga (o el campionat)."},
      {"q": "El tauler que indica el resultat d'un partit és...", "o": ["el marcador", "la graderia", "el vestidor"], "e": "El marcador. El públic seu a la graderia."},
      {"q": "On es canvien de roba els esportistes?", "o": ["al vestidor", "a la graderia", "a la pista"], "e": "El vestidor."},
      {"q": "Un lloc a la natura amb taules, barbacoes i fonts per a passar el dia és...", "o": ["un berenador (o àrea recreativa)", "un poliesportiu", "un vestidor"], "e": "Un berenador o una àrea recreativa. Està prohibit fer foc fora de les barbacoes autoritzades."},
      {"q": "Fer una activitat per a ajudar els altres sense cobrar és fer...", "o": ["voluntariat", "hores extra", "vaga"], "e": "Voluntariat: activitat altruista en el temps lliure."},
      {"q": "Escriu la paraula: lloc on es compren les entrades del cine o del teatre.", "a": ["taquilla", "la taquilla"], "e": "La taquilla (també en línia)."},
      {"q": "Escriu el verb: tindre ganes de fer alguna cosa és «vindre de ___».", "a": ["gust"], "e": "Vindre de gust."},
      {"q": "Escriu la paraula: persona que vigila els banyistes a la platja i a la piscina.", "a": ["socorrista", "el socorrista", "la socorrista"], "e": "El socorrista o la socorrista."},
      {"q": "Escriu l'esport: anar per la muntanya seguint camins senyalitzats.", "a": ["senderisme", "el senderisme"], "e": "El senderisme."}
    ]
  },
  {
    "id": "86009785-1c97-4e8f-8203-85f873e596be", "type": "b1_vocab_administracio", "sort_order": 7,
    "title": "L'Administració i els servicis", "name": "Sol·licituds, permisos, tràmits i normes d'ús",
    "content": "Demanar permís per a usar un servici o una instal·lació, autoritzar o denegar una activitat i aconsellar sobre l'ús correcte d'un servici (3.1.7).", "icon": "🏛️", "color": "#CFD8DC",
    "exercises": [
      {"q": "El document escrit amb què demanes formalment alguna cosa a l'Administració és...", "o": ["una sol·licitud (o instància)", "una postal", "una factura"], "e": "Una sol·licitud o una instància. Qui la presenta és el sol·licitant."},
      {"q": "El paper amb espais en blanc que has d'emplenar és...", "o": ["un formulari (o imprés)", "un rebut", "un pressupost"], "e": "Un formulari o un imprés. Cal emplenar-lo (o omplir-lo)."},
      {"q": "«Cal ___ el formulari amb majúscules i signar-lo.»", "o": ["emplenar", "esborrar", "enviar per error"], "e": "Emplenar (o omplir) un formulari."},
      {"q": "Posar el teu nom escrit de la teua mà al final d'un document és...", "o": ["signar-lo (o firmar-lo)", "segellar-lo", "registrar-lo"], "e": "Signar o firmar. La signatura."},
      {"q": "El temps que tens per a presentar una sol·licitud és...", "o": ["el termini", "el tràmit", "el registre"], "e": "El termini: «El termini acaba el 30 de juny.»"},
      {"q": "Cada un dels passos que cal fer en l'Administració per a aconseguir una cosa és...", "o": ["un tràmit (o una gestió)", "un termini", "un segell"], "e": "Un tràmit. Tramitar una sol·licitud."},
      {"q": "Per a ser atés en moltes oficines, abans has de demanar...", "o": ["cita prèvia", "la carta", "el compte"], "e": "La cita prèvia, per telèfon o per internet."},
      {"q": "El lloc d'una oficina on t'atenen a través d'una obertura o d'un taulell és...", "o": ["la finestreta", "la bústia", "el registre civil"], "e": "La finestreta (o el taulell d'atenció al públic)."},
      {"q": "Inscriure't en el registre d'habitants del municipi on vius és...", "o": ["empadronar-se", "matricular-se", "jubilar-se"], "e": "Empadronar-se en el padró municipal. Et donen el certificat d'empadronament."},
      {"q": "El document oficial que acredita una dada (que vius en un lloc, que has estudiat...) és...", "o": ["un certificat", "un catàleg", "un fullet"], "e": "Un certificat. Certificar."},
      {"q": "Una còpia d'un document que l'Administració declara igual a l'original és una còpia...", "o": ["compulsada (o confrontada)", "esborrada", "caducada"], "e": "Còpia compulsada o confrontada."},
      {"q": "«Cal ___ a la sol·licitud una fotocòpia del DNI.»", "o": ["adjuntar", "esborrar", "emplenar"], "e": "Adjuntar: afegir un document a un altre (també en un correu electrònic)."},
      {"q": "Quan l'Administració diu que SÍ a una sol·licitud, la...", "o": ["concedix (o aprova)", "denega", "desestima"], "e": "Concedir, aprovar o atorgar. El contrari: denegar o desestimar."},
      {"q": "Quan l'Administració diu que NO a una sol·licitud, la...", "o": ["denega", "concedix", "tramita"], "e": "Denegar o desestimar: no concedir."},
      {"q": "El document que et permet fer obres en casa és una...", "o": ["llicència d'obres", "targeta sanitària", "factura"], "e": "La llicència d'obres, que dona l'ajuntament."},
      {"q": "«Sol·licite permís per a utilitzar el saló d'actes el dia 3 de març.» Què fa?", "o": ["Demana permís per a usar una instal·lació", "Denega un permís", "Reclama una factura"], "e": "Sol·licitar permís per a usar un servici o una instal·lació."},
      {"q": "Quina és la fórmula adequada per a començar una sol·licitud?", "o": ["EXPOSE: que... SOL·LICITE: que...", "Hola, què tal?", "Una abraçada,"], "e": "La instància té dues parts: expose (els fets) i sol·licite (el que es demana)."},
      {"q": "«Queda autoritzat a usar la pista de pàdel els dimarts.» Què expressa?", "o": ["Una autorització", "Una denegació", "Una reclamació"], "e": "Autoritzar: donar permís."},
      {"q": "«Lamentem comunicar-li que no és possible concedir-li l'ús de l'aula.» Què expressa?", "o": ["Una denegació", "Una autorització", "Una felicitació"], "e": "Denegar de manera cortés: lamentem comunicar-li..."},
      {"q": "«No es permet l'entrada d'animals.» Vol dir que...", "o": ["està prohibit entrar amb animals", "els animals són benvinguts", "cal pagar per l'animal"], "e": "No es permet / Està prohibit / Es prohibix."},
      {"q": "«Es prega silenci.» És...", "o": ["una petició cortés de no fer soroll", "una prohibició de parlar valencià", "una felicitació"], "e": "Es prega: es demana amb educació."},
      {"q": "A la piscina municipal, és obligatori...", "o": ["dutxar-se abans de banyar-se i portar gorra de bany", "menjar dins de l'aigua", "entrar amb sabates de carrer"], "e": "Normes d'ús habituals de la piscina: dutxa, gorra (o casquet) i xancletes."},
      {"q": "El document per a usar els servicis d'un poliesportiu durant un temps és...", "o": ["l'abonament", "la nòmina", "la recepta"], "e": "L'abonament (mensual, trimestral, anual). Els abonats."},
      {"q": "«Per a reservar la pista, cal fer-ho amb 48 hores d'antelació.» És...", "o": ["un consell sobre l'ús correcte del servici", "una queixa", "una denegació"], "e": "Aconsellar sobre l'ús correcte: cal, és convenient, és recomanable..."},
      {"q": "«És recomanable que porte el carnet de la biblioteca per a traure llibres.» És...", "o": ["un consell", "una prohibició", "una autorització"], "e": "És recomanable / és convenient / et recomane que... per a aconsellar."},
      {"q": "Contractar un servici, com la llum o l'aigua, és donar-se d'...", "o": ["alta", "baixa", "avaria"], "e": "Donar-se d'alta. Per a deixar-lo: donar-se de baixa."},
      {"q": "Deixar de tindre contractat un servici és donar-se de...", "o": ["baixa", "alta", "terme"], "e": "Donar-se de baixa (d'un servici, d'un gimnàs...)."},
      {"q": "El document on es demostra que has pagat una cosa és...", "o": ["el rebut", "el pressupost", "la sol·licitud"], "e": "El rebut (o el justificant de pagament)."},
      {"q": "Que el banc pague directament els teus rebuts és tindre'ls...", "o": ["domiciliats", "denegats", "caducats"], "e": "Domiciliar els rebuts en un compte bancari."},
      {"q": "L'aparell que mesura la llum, l'aigua o el gas que gastes és...", "o": ["el comptador", "el termostat", "el rebedor"], "e": "El comptador. Fer la lectura del comptador."},
      {"q": "El servici d'una empresa que respon les preguntes i les queixes dels clients és...", "o": ["l'atenció al client", "el consell d'administració", "el magatzem"], "e": "Servici d'atenció al client."},
      {"q": "Una oficina d'un banc en un barri és...", "o": ["una sucursal", "una franquícia", "una gestoria"], "e": "Una sucursal (o oficina bancària)."},
      {"q": "El número que identifica el teu compte bancari és...", "o": ["l'IBAN", "el DNI", "el NIE"], "e": "L'IBAN. El NIE és el número d'identitat d'estrangers."},
      {"q": "L'organisme que governa la Comunitat Valenciana és...", "o": ["la Generalitat", "la Diputació", "l'Ajuntament"], "e": "La Generalitat Valenciana. La Diputació governa la província i l'Ajuntament, el municipi."},
      {"q": "La persona que forma part del govern d'un ajuntament i s'encarrega d'una àrea (cultura, esports...) és...", "o": ["el regidor", "el jutge", "el notari"], "e": "El regidor o la regidora."},
      {"q": "«Vaig enviar la sol·licitud per la ___ electrònica de l'ajuntament.»", "o": ["seu", "sede", "finestra"], "e": "La seu electrònica: la pàgina web oficial per a fer tràmits. (En valencià no és «sede».)"},
      {"q": "El certificat digital o la Cl@ve servixen per a...", "o": ["identificar-te en internet per a fer tràmits", "obrir el cotxe", "pagar el cine"], "e": "Identificar-se electrònicament davant l'Administració."},
      {"q": "Escriu la paraula: document per a demanar formalment alguna cosa a l'Administració.", "a": ["sol·licitud", "instància", "la sol·licitud", "la instància"], "e": "Una sol·licitud o una instància."},
      {"q": "Escriu el contrari de «concedir» un permís.", "a": ["denegar", "desestimar", "refusar", "rebutjar"], "e": "Denegar o desestimar."},
      {"q": "Escriu el verb: inscriure's en el padró municipal és ___.", "a": ["empadronar-se", "empadronar"], "e": "Empadronar-se."},
      {"q": "Escriu la paraula: temps que es té per a presentar un document.", "a": ["termini", "el termini"], "e": "El termini."}
    ]
  },
  {
    "id": "d2eb464d-1df4-4fcd-9d67-26a8eb56d9f2", "type": "b1_vocab_treball", "sort_order": 8,
    "title": "El treball", "name": "Ofertes de treball, currículum, entrevista i instruccions",
    "content": "Entendre ofertes de treball, redactar el currículum, descriure el lloc de treball i les aptituds, valorar un treball fet i donar indicacions per a fer una tasca (3.1.8).", "icon": "💼", "color": "#FFF9C4",
    "exercises": [
      {"q": "En un anunci, «Es necessita dependent/a» vol dir que...", "o": ["busquen una persona per a treballar en una botiga", "venen una botiga", "una botiga tanca"], "e": "Es necessita / Es busca / Precisem: introduïxen una oferta de treball."},
      {"q": "Un lloc de treball lliure que l'empresa vol cobrir és...", "o": ["una vacant", "una vaga", "una baixa"], "e": "Una vacant (o una plaça). La vaga és deixar de treballar per a protestar."},
      {"q": "Les condicions que ha de complir un candidat són...", "o": ["els requisits", "les vacances", "les despeses"], "e": "Requisits: «Es requerix titulació universitària.»"},
      {"q": "En una oferta, «imprescindible carnet de conduir» vol dir que...", "o": ["és obligatori tindre'l", "és un avantatge", "no cal tindre'l"], "e": "Imprescindible: obligatori. «Es valorarà» vol dir que és un mèrit, no obligatori."},
      {"q": "En una oferta, «es valorarà el coneixement d'idiomes» vol dir que...", "o": ["és un mèrit, però no és obligatori", "és obligatori", "està prohibit"], "e": "Es valorarà: és un punt a favor."},
      {"q": "Un treball de huit hores diàries és de jornada...", "o": ["completa", "parcial", "intensiva de nit"], "e": "Jornada completa. A mitja jornada o jornada parcial: menys hores."},
      {"q": "Treballar de huit a tres sense parar per a dinar és fer jornada...", "o": ["intensiva", "partida", "parcial"], "e": "Jornada intensiva. Jornada partida: matí i vesprada, amb parada per a dinar."},
      {"q": "Treballar uns dies de matí i uns altres de nit és treballar a...", "o": ["torns", "comissió", "domicili"], "e": "A torns: torn de matí, de vesprada i de nit."},
      {"q": "Treballar des de casa amb l'ordinador és...", "o": ["teletreballar", "jubilar-se", "fer vaga"], "e": "El teletreball."},
      {"q": "Els diners que cobres cada mes pel teu treball són...", "o": ["el sou (o el salari)", "la fiança", "el pressupost"], "e": "El sou o el salari. El document on es detalla és la nòmina."},
      {"q": "El document mensual que detalla el teu sou i els descomptes és...", "o": ["la nòmina", "el currículum", "el contracte de lloguer"], "e": "La nòmina."},
      {"q": "El sou abans de llevar-ne els impostos és el sou...", "o": ["brut", "net", "extra"], "e": "Brut: abans de descomptes. Net: el que realment cobres."},
      {"q": "Un contracte sense data de finalització és un contracte...", "o": ["indefinit", "temporal", "en pràctiques"], "e": "Indefinit (o fix). El temporal té data de final."},
      {"q": "Els primers mesos en què l'empresa comprova si fas bé la faena són el període de...", "o": ["prova", "vacances", "baixa"], "e": "El període de prova."},
      {"q": "Una persona que no té treball i en busca està...", "o": ["a l'atur (o aturada)", "jubilada", "de baixa"], "e": "A l'atur. La prestació d'atur."},
      {"q": "Una persona que treballa per a si mateixa, sense cap ni empresa, és...", "o": ["autònoma", "assalariada", "becària"], "e": "Autònom: treballador per compte propi."},
      {"q": "El conjunt de treballadors d'una empresa és...", "o": ["la plantilla", "la nòmina", "la jornada"], "e": "La plantilla. Els companys de faena (o de treball)."},
      {"q": "Quan l'empresa diu a un treballador que ja no hi treballarà més, l'...", "o": ["acomiada", "contracta", "promociona"], "e": "Acomiadar: fer fora un treballador. L'acomiadament."},
      {"q": "Quan un treballador decidix deixar el seu lloc de treball, ...", "o": ["dimitix (o deixa la faena)", "és acomiadat", "es jubila"], "e": "Dimitir: deixar voluntàriament el càrrec o el treball. La dimissió."},
      {"q": "Quan no pots treballar perquè estàs malalt, estàs de...", "o": ["baixa", "vacances", "vaga"], "e": "Estar de baixa (mèdica)."},
      {"q": "Les organitzacions que defensen els drets dels treballadors són...", "o": ["els sindicats", "les immobiliàries", "les gestories"], "e": "Els sindicats."},
      {"q": "El document on resumixes la teua formació i la teua experiència és...", "o": ["el currículum", "la nòmina", "el contracte"], "e": "El currículum (vitae)."},
      {"q": "En el currículum, en quin apartat poses els teus estudis?", "o": ["Formació acadèmica", "Experiència professional", "Dades personals"], "e": "Formació acadèmica: títols i estudis. L'experiència: els treballs que has fet."},
      {"q": "En quin apartat del currículum poses que parles anglés i valencià?", "o": ["Idiomes", "Aficions", "Referències"], "e": "Idiomes (amb el nivell: B1, C1...)."},
      {"q": "La carta que acompanya el currículum i explica per què t'interessa el lloc és...", "o": ["la carta de presentació", "la carta de comiat", "la carta del restaurant"], "e": "La carta de presentació (o de motivació)."},
      {"q": "La conversa amb l'empresa per a saber si eres adequat per al lloc és...", "o": ["l'entrevista de treball", "la vaga", "la reunió de veïns"], "e": "L'entrevista de treball. L'entrevistador i el candidat."},
      {"q": "Una persona que arriba sempre a l'hora és...", "o": ["puntual", "responsable", "creativa"], "e": "Puntual. Altres aptituds: responsable, organitzat, creatiu, resolutiu."},
      {"q": "Una persona que troba solucions als problemes amb rapidesa és...", "o": ["resolutiva", "despistada", "insegura"], "e": "Resolutiva: que resol problemes."},
      {"q": "«Sé treballar en ___ i m'adapte bé als canvis.»", "o": ["equip", "solitari", "torn"], "e": "Treballar en equip: col·laborar amb els companys."},
      {"q": "En una entrevista, quina resposta descriu bé el teu lloc de treball anterior?", "o": ["Era recepcionista en un hotel: atenia els clients i gestionava les reserves.", "M'agrada molt la paella.", "Vull molts diners."], "e": "Descriure el lloc: el càrrec i les funcions."},
      {"q": "«Tinc tres anys d'___ en atenció al públic.»", "o": ["experiència", "experiment", "expedient"], "e": "Experiència laboral (o professional)."},
      {"q": "Una persona que treballa en una empresa per a aprendre, sovint mentre estudia, és...", "o": ["un becari (o una persona en pràctiques)", "un autònom", "un jubilat"], "e": "Becari o en pràctiques."},
      {"q": "«L'informe està molt ben fet: t'has lluït!» Què expressa?", "o": ["Acord i satisfacció amb el treball", "Desacord", "Indiferència"], "e": "Lluir-se: fer una cosa molt bé. Valoració positiva."},
      {"q": "«No estic d'acord amb el resultat: caldria repassar les dades.» Què expressa?", "o": ["Desacord amb el treball fet", "Felicitació", "Una oferta de treball"], "e": "Manifestar desacord de manera constructiva."},
      {"q": "«Està bé, però ___ millorar la presentació.»", "o": ["es podria", "no es pot", "mai"], "e": "Fer una crítica suau: es podria millorar, caldria canviar..."},
      {"q": "Per a donar instruccions en ordre: «___ obri l'arxiu; després, copia les dades; finalment, guarda'l.»", "o": ["Primer", "Finalment", "Tanmateix"], "e": "Primer / en primer lloc, després / a continuació, finalment / per acabar."},
      {"q": "«___ que la màquina està apagada abans de netejar-la.»", "o": ["Assegura't", "Oblida't", "Despreocupa't"], "e": "Assegurar-se: comprovar. Instruccions de seguretat."},
      {"q": "«Abans d'enviar el correu, no t'___ d'adjuntar el document.»", "o": ["oblides", "recordes", "assegures"], "e": "No t'oblides de...: recordar a algú que faça una cosa."},
      {"q": "Treballar més hores de les del contracte és fer...", "o": ["hores extra", "jornada intensiva", "vacances"], "e": "Hores extra (o extraordinàries)."},
      {"q": "Escriu la paraula: document que resumix els estudis i l'experiència d'una persona.", "a": ["currículum", "el currículum", "currículum vitae", "curriculum"], "e": "El currículum (vitae)."},
      {"q": "Escriu el verb: fer fora un treballador de l'empresa és ___-lo.", "a": ["acomiadar"], "e": "Acomiadar."},
      {"q": "Escriu la paraula: la persona que no té treball està a l'___.", "a": ["atur"], "e": "A l'atur."},
      {"q": "Escriu el contrari de «sou brut».", "a": ["sou net", "net"], "e": "Sou net: el que cobres després dels descomptes."}
    ]
  },
  {
    "id": "fab5c251-0a2a-480d-a839-f7ccbaee2bf0", "type": "b1_vocab_salut", "sort_order": 9,
    "title": "Salut i assistència sanitària", "name": "Símptomes, accidents, primers auxilis i on anar",
    "content": "Descriure els símptomes d'una malaltia o les conseqüències d'un accident, explicar com actuar i saber on adreçar-se per a demanar assistència (3.1.9).", "icon": "🩺", "color": "#FFCDD2",
    "exercises": [
      {"q": "«Tot em dona voltes i tinc ganes de vomitar.» Què li passa?", "o": ["Està marejat", "Està afònic", "Té picor"], "e": "Marejar-se: sentir que tot dona voltes. Les nàusees són les ganes de vomitar."},
      {"q": "«Tinc la gola tan irritada que no puc parlar: ___.»", "o": ["estic afònic", "estic restret", "tinc fam"], "e": "Afònic: sense veu. Tindre mal de gola (o de coll)."},
      {"q": "Quan tens el nas ple de mocs i no pots respirar bé, tens el nas...", "o": ["tapat", "trencat", "inflat de colps"], "e": "Tindre el nas tapat (o congestionat)."},
      {"q": "Expulsar aire de cop pel nas, com quan tens al·lèrgia al pol·len, és...", "o": ["esternudar", "tossir", "badallar"], "e": "Esternudar: fer un esternut. Tossir: fer tos."},
      {"q": "Quan tens febre i tremoles de fred, tens...", "o": ["calfreds", "picor", "cremor"], "e": "Calfreds: tremolors de fred, sovint amb febre."},
      {"q": "Una tos sense mocs és una tos...", "o": ["seca", "humida", "forta de pit"], "e": "Tos seca. Amb mocs: tos productiva o amb flegmes."},
      {"q": "Quan no pots anar al bany perquè no fas de ventre, estàs...", "o": ["restret", "marejat", "refredat"], "e": "Restret (estrenyiment). El contrari és tindre diarrea (o descomposició)."},
      {"q": "Una malaltia contagiosa amb febre, mal de cos i tos, que sol vindre a l'hivern, és...", "o": ["la grip", "una torçada", "una cremada"], "e": "La grip. El refredat és més suau."},
      {"q": "La reacció de l'organisme a algunes substàncies, com el pol·len o la pols, és...", "o": ["una al·lèrgia", "una fractura", "una insolació"], "e": "Una al·lèrgia. Ser al·lèrgic a..."},
      {"q": "La sensació a la pell que et fa gratar-te és...", "o": ["la picor (o la coïssor)", "la febre", "la tos"], "e": "Picor o coïssor. Una picada de mosquit pica."},
      {"q": "Si has estat massa hores al sol i et fa mal el cap i tens febre, tens...", "o": ["una insolació", "una fractura", "una torçada"], "e": "Una insolació. Si la pell està roja: una cremada solar."},
      {"q": "Quan et dobles malament el peu i el turmell s'infla, t'has fet...", "o": ["una torçada (o un esquinç)", "una cremada", "una al·lèrgia"], "e": "Torçar-se el turmell: una torçada o un esquinç."},
      {"q": "Quan es trenca un os, és...", "o": ["una fractura", "un esquinç", "un blau"], "e": "Una fractura. Et posen un guix (o una escaiola)."},
      {"q": "La taca morada que ix a la pell després d'un colp és...", "o": ["un blau (o un morat)", "una piga", "una ferida"], "e": "Un blau o un morat (també un cardenal)."},
      {"q": "La inflor que ix al cap després d'un colp és...", "o": ["un bony (o una banya)", "una piga", "una arruga"], "e": "Un bony (popularment, una banya)."},
      {"q": "Quan et talles i ix sang, tens...", "o": ["una ferida", "un blau", "un esquinç"], "e": "Una ferida. Cal netejar-la i desinfectar-la."},
      {"q": "Per a tancar una ferida gran, el metge et posa...", "o": ["punts (de sutura)", "una tireta de colors", "un xarop"], "e": "Punts de sutura. Per a ferides xicotetes: una tireta."},
      {"q": "La tira adhesiva per a tapar una ferida xicoteta és...", "o": ["una tireta", "una bena", "una gasa"], "e": "Una tireta. La bena és la tira de tela per a embenar."},
      {"q": "La capsa amb tireta, gases i desinfectant per a primers auxilis és...", "o": ["la farmaciola", "la farmàcia", "la recepta"], "e": "La farmaciola: hi ha d'haver una a casa, al cotxe i a la faena."},
      {"q": "El número de telèfon d'emergències a tota Europa és...", "o": ["el 112", "el 012", "el 010"], "e": "El 112: ambulàncies, bombers i policia."},
      {"q": "Si et trenques un braç o tens un problema greu, has d'anar a...", "o": ["urgències de l'hospital", "la farmàcia de guàrdia", "l'òptica"], "e": "A urgències. Per a coses lleus, al centre de salut."},
      {"q": "La farmàcia que obri a la nit i els festius és la farmàcia de...", "o": ["guàrdia", "capçalera", "torn de dia"], "e": "La farmàcia de guàrdia."},
      {"q": "El metge que et visita habitualment al centre de salut és el metge de...", "o": ["capçalera (o de família)", "guàrdia", "urgències"], "e": "Metge de capçalera o de família. Ell t'envia a l'especialista si cal."},
      {"q": "El metge especialista en els ossos i les articulacions és...", "o": ["el traumatòleg", "l'oculista", "el pediatre"], "e": "El traumatòleg. L'oculista (oftalmòleg): els ulls. El pediatre: els xiquets."},
      {"q": "La targeta que identifica els pacients de la sanitat pública valenciana és...", "o": ["la targeta SIP", "la targeta d'embarcament", "el carnet de soci"], "e": "La targeta SIP (Sistema d'Informació Poblacional)."},
      {"q": "El paper dins de la capsa del medicament que explica com prendre'l és...", "o": ["el prospecte", "la recepta", "el rebut"], "e": "El prospecte. Hi ha la dosi i els efectes secundaris."},
      {"q": "«Prenga una pastilla cada huit hores, després de menjar.» Esta indicació és...", "o": ["la dosi i la freqüència", "un diagnòstic", "un símptoma"], "e": "La dosi: quantitat de medicament i cada quant de temps."},
      {"q": "Un medicament per a lluitar contra les infeccions de bacteris és...", "o": ["un antibiòtic", "un analgèsic", "un xarop per a la tos"], "e": "Antibiòtic. L'analgèsic calma el dolor."},
      {"q": "Una crema medicinal que s'aplica a la pell és...", "o": ["una pomada", "un xarop", "una injecció"], "e": "Una pomada (o una crema)."},
      {"q": "Fer una anàlisi en dejú vol dir...", "o": ["sense haver menjat res abans", "després de dinar", "amb molta aigua"], "e": "En dejú: sense haver menjat ni begut des de la nit anterior."},
      {"q": "Si algú es crema, què has de fer primer?", "o": ["Posar la cremada sota l'aigua freda uns minuts", "Posar-hi oli", "Rebentar les butllofes"], "e": "Aigua freda (no gelada) i no rebentar les butllofes."},
      {"q": "Si algú ha caigut i pot tindre una lesió a l'esquena, cal...", "o": ["no moure'l i telefonar al 112", "alçar-lo de seguida", "donar-li aigua i menjar"], "e": "No moure el ferit si pot tindre una lesió greu."},
      {"q": "Si algú es torç el turmell, és recomanable...", "o": ["posar-hi gel i alçar la cama", "córrer per a escalfar-lo", "posar-hi aigua calenta"], "e": "Gel, repòs i alçar la cama per a reduir la inflamació."},
      {"q": "Si a algú li ix sang del nas, cal...", "o": ["inclinar el cap avant i pressionar el nas", "tombar el cap arrere", "gitar-lo panxa amunt"], "e": "Cap avant i pressió a les aletes del nas uns minuts."},
      {"q": "El document que dona el metge quan no pots treballar per malaltia és...", "o": ["la baixa mèdica", "l'alta mèdica", "la recepta"], "e": "La baixa. Quan et recuperes, et donen l'alta."},
      {"q": "Quan l'hospital diu que ja pots tornar a casa, et donen...", "o": ["l'alta", "la baixa", "el prospecte"], "e": "L'alta (hospitalària o mèdica)."},
      {"q": "«Des d'ahir em fa mal la panxa i tinc diarrea.» Esta frase descriu...", "o": ["uns símptomes", "un tractament", "un diagnòstic oficial"], "e": "Descriure els símptomes: des de quan i què sents."},
      {"q": "«Em fa mal ací, quan respire fort.» El dolor és...", "o": ["en respirar fort", "quan menge", "sempre a la nit"], "e": "Precisar quan fa mal: en respirar, en caminar, en menjar..."},
      {"q": "Escriu el verb: fer tos és ___.", "a": ["tossir"], "e": "Tossir: jo tus, tu tusses, ell tus."},
      {"q": "Escriu la paraula: capsa amb el material de primers auxilis.", "a": ["farmaciola", "la farmaciola"], "e": "La farmaciola."},
      {"q": "Escriu el número de telèfon d'emergències.", "a": ["112"], "e": "El 112."},
      {"q": "Escriu la paraula: document del metge per a comprar un medicament a la farmàcia.", "a": ["recepta", "la recepta"], "e": "La recepta (electrònica)."}
    ]
  },
  {
    "id": "32cec65a-a7c6-490d-b993-ad562b14a808", "type": "b1_vocab_territori", "sort_order": 10,
    "title": "Geografia i història del territori", "name": "Províncies, comarques, muntanyes, rius i fets històrics",
    "content": "La situació geogràfica, les províncies i les comarques, els principals accidents geogràfics i els fets més importants de la nostra història (3.1.10).", "icon": "🗺️", "color": "#DCEDC8",
    "exercises": [
      {"q": "Quines són les tres províncies de la Comunitat Valenciana, de nord a sud?", "o": ["Castelló, València i Alacant", "Alacant, València i Castelló", "València, Castelló i Múrcia"], "e": "De nord a sud: Castelló, València i Alacant."},
      {"q": "Amb quin mar limita la Comunitat Valenciana per l'est?", "o": ["el mar Mediterrani", "l'oceà Atlàntic", "el mar Cantàbric"], "e": "Tota la costa valenciana és mediterrània."},
      {"q": "Amb quina comunitat autònoma limita la Comunitat Valenciana pel sud?", "o": ["la Regió de Múrcia", "Catalunya", "Aragó"], "e": "Al nord, Catalunya; a l'oest, Aragó i Castella-la Manxa; al sud, Múrcia."},
      {"q": "Amb quina comunitat limita la Comunitat Valenciana pel nord?", "o": ["Catalunya", "Múrcia", "Andalusia"], "e": "Pel nord, Catalunya (el riu de la Sénia en marca part de la frontera)."},
      {"q": "Com s'anomena la divisió del territori formada per diversos municipis veïns amb característiques comunes?", "o": ["la comarca", "la província", "la partida"], "e": "La comarca agrupa municipis. La partida és una zona dins del terme d'un municipi."},
      {"q": "El territori que pertany a un municipi s'anomena...", "o": ["el terme municipal", "la comarca", "el país"], "e": "El terme municipal."},
      {"q": "A quina comarca pertany Gandia?", "o": ["la Safor", "la Marina Alta", "la Ribera Baixa"], "e": "Gandia és la capital de la Safor."},
      {"q": "A quina comarca pertany Alcoi?", "o": ["l'Alcoià", "el Comtat", "la Vall d'Albaida"], "e": "Alcoi és la capital de l'Alcoià."},
      {"q": "A quina comarca pertany Xàtiva?", "o": ["la Costera", "la Ribera Alta", "la Canal de Navarrés"], "e": "Xàtiva és la capital de la Costera."},
      {"q": "A quina comarca pertany Morella?", "o": ["els Ports", "l'Alt Maestrat", "la Plana Alta"], "e": "Morella és la capital dels Ports, a l'interior de Castelló."},
      {"q": "A quina comarca pertany Dénia?", "o": ["la Marina Alta", "la Marina Baixa", "la Safor"], "e": "Dénia és la capital de la Marina Alta."},
      {"q": "A quina comarca pertanyen Elx i Santa Pola?", "o": ["el Baix Vinalopó", "el Baix Segura", "l'Alacantí"], "e": "El Baix Vinalopó."},
      {"q": "A quina comarca pertany Oriola?", "o": ["el Baix Segura", "el Vinalopó Mitjà", "l'Alacantí"], "e": "Oriola és la capital del Baix Segura (la Vega Baixa)."},
      {"q": "Quina comarca envolta la ciutat de València i és famosa pels seus cultius?", "o": ["l'Horta", "la Plana Baixa", "la Foia de Bunyol"], "e": "L'Horta (Nord, Oest i Sud): terres de regadiu al voltant de València."},
      {"q": "Quin riu passava per la ciutat de València i ara el seu antic llit és un gran jardí?", "o": ["el Túria", "el Xúquer", "el Segura"], "e": "Després de la riuada de 1957 es va desviar el Túria i l'antic llit és el Jardí del Túria."},
      {"q": "Quin riu passa per Alzira i desemboca a Cullera?", "o": ["el Xúquer", "el Túria", "el Millars"], "e": "El Xúquer, el riu més cabalós del País Valencià."},
      {"q": "Quin riu desemboca a Guardamar i rega la Vega Baixa?", "o": ["el Segura", "el Vinalopó", "el Serpis"], "e": "El Segura."},
      {"q": "Quin riu passa a prop de Castelló de la Plana i Vila-real?", "o": ["el Millars", "el Palància", "el Xúquer"], "e": "El Millars."},
      {"q": "Quin riu passa per Alcoi i desemboca a prop de Gandia?", "o": ["el Serpis", "el Vinalopó", "el Túria"], "e": "El Serpis."},
      {"q": "Quin riu passa per Sagunt?", "o": ["el Palància", "el Millars", "el Segura"], "e": "El Palància."},
      {"q": "El punt on un riu s'unix al mar és...", "o": ["la desembocadura", "el naixement", "l'afluent"], "e": "La desembocadura. El naixement és on comença. L'afluent és un riu que s'unix a un altre."},
      {"q": "Un riu que porta les aigües a un altre riu més gran és...", "o": ["un afluent", "un embassament", "un barranc"], "e": "Un afluent: el Magre és afluent del Xúquer."},
      {"q": "Quina muntanya emblemàtica de Castelló, de més de 1.800 metres, té un santuari al peu?", "o": ["el Penyagolosa", "el Montgó", "el Puig Campana"], "e": "El Penyagolosa (1.813 m), entre l'Alcalatén i l'Alt Maestrat."},
      {"q": "Quina muntanya s'alça entre Dénia i Xàbia, al costat del mar?", "o": ["el Montgó", "l'Aitana", "el Benicadell"], "e": "El Montgó, parc natural."},
      {"q": "Quina serra, entre Alcoi, Bocairent i Banyeres, és famosa per les plantes aromàtiques?", "o": ["la serra de Mariola", "la serra Calderona", "la serra d'Espadà"], "e": "Mariola: herbes per a fer licors i infusions."},
      {"q": "Quina és la muntanya més alta de la província d'Alacant?", "o": ["l'Aitana", "el Montgó", "el Puig Campana"], "e": "L'Aitana, de més de 1.500 metres."},
      {"q": "Un conjunt de muntanyes en filera és...", "o": ["una serra", "una plana", "una vall"], "e": "Una serra (o serralada). La part més alta d'una muntanya és el cim."},
      {"q": "Un terreny baix entre muntanyes, sovint amb un riu, és...", "o": ["una vall", "un cim", "un cap"], "e": "Una vall (la Vall d'Albaida, la Vall d'Uixó...)."},
      {"q": "Una part de terra que entra en el mar, com el de la Nau o el de Sant Antoni, és...", "o": ["un cap", "un golf", "una badia"], "e": "Un cap. Un golf és una entrada gran del mar en la terra."},
      {"q": "Quina és l'única illa habitada del País Valencià?", "o": ["Tabarca", "les Columbretes", "Benidorm"], "e": "Tabarca (Alacant). Les Columbretes (Castelló) són una reserva natural sense població permanent."},
      {"q": "Quina gran llacuna d'aigua dolça, envoltada d'arrossars, hi ha al sud de València?", "o": ["l'Albufera", "les salines de Santa Pola", "el Fondo"], "e": "L'Albufera, parc natural."},
      {"q": "Qui va conquerir València als musulmans l'any 1238?", "o": ["Jaume I", "Ferran el Catòlic", "el Cid"], "e": "El rei Jaume I va entrar a València el 9 d'octubre de 1238 i va crear el Regne de València."},
      {"q": "Per què el 9 d'Octubre és el Dia de la Comunitat Valenciana?", "o": ["Perquè recorda l'entrada de Jaume I a València el 1238", "Perquè és el dia de Sant Josep", "Perquè és l'aniversari de la Constitució"], "e": "El 9 d'Octubre se celebra la fundació del Regne de València."},
      {"q": "Com s'anomenaven les lleis pròpies del Regne de València?", "o": ["els Furs", "els Decrets", "els Estatuts"], "e": "Els Furs de València, aprovats per Jaume I."},
      {"q": "En quina batalla de 1707 el Regne de València va perdre els Furs?", "o": ["la batalla d'Almansa", "la batalla de Lepant", "la batalla de les Navas"], "e": "Després d'Almansa, Felip V va abolir els Furs amb els Decrets de Nova Planta."},
      {"q": "Com s'anomena la revolta dels gremis valencians contra la noblesa (1519-1523)?", "o": ["les Germanies", "la Reconquesta", "la Renaixença"], "e": "Les Germanies."},
      {"q": "Com es coneix el segle XV, l'època de més esplendor econòmica i literària de València?", "o": ["el Segle d'Or valencià", "la Renaixença", "la Il·lustració"], "e": "El Segle d'Or: es van construir la Llotja de la Seda i el Micalet, i van escriure Ausiàs March i Joanot Martorell."},
      {"q": "Qui va escriure la novel·la de cavalleries «Tirant lo Blanc»?", "o": ["Joanot Martorell", "Ausiàs March", "Vicent Andrés Estellés"], "e": "Joanot Martorell, al segle XV."},
      {"q": "Quin edifici gòtic de València, patrimoni de la humanitat, era el centre del comerç de la seda?", "o": ["la Llotja de la Seda", "el Micalet", "les Torres de Serrans"], "e": "La Llotja de la Seda (o Llotja dels Mercaders)."},
      {"q": "Quin tribunal es reunix cada dijous a la porta de la catedral de València per a resoldre conflictes de reg?", "o": ["el Tribunal de les Aigües", "el Tribunal Suprem", "les Corts"], "e": "El Tribunal de les Aigües, d'origen medieval, patrimoni immaterial de la humanitat."},
      {"q": "Quina escultura ibera famosa es va trobar a Elx?", "o": ["la Dama d'Elx", "la Dama de Baza", "la Venus de Milo"], "e": "La Dama d'Elx, trobada el 1897."},
      {"q": "Quina ciutat valenciana té un teatre i un castell romans i va ser assetjada per Anníbal?", "o": ["Sagunt", "Morella", "Peníscola"], "e": "Sagunt (Saguntum)."},
      {"q": "Els canals per a regar els camps, molts d'origen àrab, són...", "o": ["les sèquies", "les rambles", "els barrancs"], "e": "Les sèquies. Regar a manta, la sèquia mare, l'assut..."},
      {"q": "En quin any es va aprovar el primer Estatut d'Autonomia de la Comunitat Valenciana?", "o": ["1982", "1978", "1707"], "e": "L'Estatut d'Autonomia de 1982 (reformat el 2006)."},
      {"q": "Escriu el nom de la província més al nord de la Comunitat Valenciana.", "a": ["Castelló", "Castelló de la Plana"], "e": "Castelló."},
      {"q": "Escriu el nom del rei que va conquerir València el 1238: Jaume ___.", "a": ["I", "Primer", "el Conqueridor"], "e": "Jaume I, el Conqueridor."},
      {"q": "Escriu la paraula: lloc on naix un riu.", "a": ["naixement", "el naixement", "font"], "e": "El naixement (o la font)."},
      {"q": "Escriu la paraula: divisió territorial que agrupa diversos municipis veïns.", "a": ["comarca", "la comarca"], "e": "La comarca."}
    ]
  },
  {
    "id": "b0fc5d10-4011-49a2-9d23-cdebe3e00507", "type": "b1_vocab_cultura", "sort_order": 11,
    "title": "Cultura i llengua", "name": "Festes, música, gastronomia, jocs i esports tradicionals",
    "content": "Les festes tradicionals i populars i la seua música i gastronomia, i els jocs i els esports tradicionals (3.1.11).", "icon": "🎉", "color": "#FFAB91",
    "exercises": [
      {"q": "En quines dates se celebren les Falles de València?", "o": ["del 15 al 19 de març", "del 20 al 24 de juny", "l'últim dimecres d'agost"], "e": "Les Falles acaben el 19 de març, dia de Sant Josep."},
      {"q": "La nit en què es munten els monuments fallers als carrers és...", "o": ["la plantà", "la cremà", "la despertà"], "e": "La plantà. La cremà és la nit del 19, quan es cremen."},
      {"q": "L'espectacle de petards que es fa a migdia a la plaça de l'Ajuntament durant les Falles és...", "o": ["la mascletà", "la despertà", "l'ofrena"], "e": "La mascletà, a les dues de la vesprada."},
      {"q": "Quan els fallers desperten el veïnat amb petards de bon matí, fan...", "o": ["la despertà", "la plantà", "la cavalcada"], "e": "La despertà."},
      {"q": "El ninot que el públic tria per a salvar-lo del foc és...", "o": ["el ninot indultat", "el ninot cremat", "el ninot de neu"], "e": "El ninot indultat va al Museu Faller."},
      {"q": "Què porten els fallers a la Mare de Déu dels Desemparats durant les Falles?", "o": ["flors (l'Ofrena)", "fruita", "petards"], "e": "L'Ofrena de flors, el 17 i el 18 de març."},
      {"q": "El local on es reunixen els membres d'una falla és...", "o": ["el casal faller", "la barraca", "la filà"], "e": "El casal. També el llibret és la publicació de la falla."},
      {"q": "Quina festa d'Alacant, al voltant del 24 de juny, crema monuments com les Falles?", "o": ["les Fogueres de Sant Joan", "la Magdalena", "la Tomatina"], "e": "Les Fogueres de Sant Joan d'Alacant."},
      {"q": "En quina festa de Castelló es porten «gaiates», monuments lluminosos?", "o": ["la Magdalena", "les Falles", "els Moros i Cristians"], "e": "Les festes de la Magdalena, amb la Romeria de les Canyes."},
      {"q": "On són especialment famosos els Moros i Cristians, en honor de Sant Jordi?", "o": ["a Alcoi", "a Bunyol", "a Morella"], "e": "A Alcoi, a l'abril. També a Ontinyent, Villena, la Vila Joiosa..."},
      {"q": "Cada un dels grups que desfilen en els Moros i Cristians és...", "o": ["una filà", "una falla", "una colla castellera"], "e": "Una filà (pl. filaes). Hi ha l'entrada, l'ambaixada i el desembarcament."},
      {"q": "En quina festa la gent es tira tomaques pel carrer, a Bunyol?", "o": ["la Tomatina", "la Cordà", "la Correguda"], "e": "La Tomatina, l'últim dimecres d'agost."},
      {"q": "Quin drama sacre medieval cantat es representa cada agost a Elx?", "o": ["el Misteri d'Elx", "el Tirant", "la Passió d'Alcoi"], "e": "El Misteri d'Elx, patrimoni immaterial de la humanitat."},
      {"q": "Quina tradició d'Algemesí fa torres humanes en la festa de la Mare de Déu de la Salut?", "o": ["la Muixeranga", "la Patum", "la Moixiganga de Lleida"], "e": "La Muixeranga d'Algemesí, patrimoni immaterial de la humanitat."},
      {"q": "Què se sol fer la nit de Sant Joan, a la platja?", "o": ["Encendre fogueres i botar-les", "Menjar raïm", "Fer la mona"], "e": "Fogueres, revetla i banys a la mitjanit."},
      {"q": "Què es menja per Pasqua, sovint amb un ou dur damunt?", "o": ["la mona", "el torró", "els bunyols"], "e": "La mona de Pasqua. També es vola el catxirulo (l'estel)."},
      {"q": "Com s'anomena l'estel que els xiquets volen per Pasqua?", "o": ["el catxirulo", "la baldufa", "la granera"], "e": "El catxirulo (o milotxa, estel)."},
      {"q": "Què es menja tradicionalment per Tots Sants?", "o": ["castanyes torrades i moniatos", "mona i ou dur", "bunyols i xocolate"], "e": "Castanyes, moniatos (creïlles dolces) i pastissets de moniato."},
      {"q": "Quin dolç nadalenc s'elabora a Xixona amb ametles i mel?", "o": ["el torró", "la coca de llanda", "els fartons"], "e": "El torró de Xixona (tou) i el d'Alacant (dur)."},
      {"q": "Què es fa el dia de Sant Antoni del Porquet (17 de gener) en molts pobles?", "o": ["Beneir els animals i encendre fogueres", "Plantar falles", "Tirar tomaques"], "e": "Sant Antoni: benedicció d'animals, fogueres i coques."},
      {"q": "Quins dos instruments tradicionals acompanyen moltes festes valencianes?", "o": ["la dolçaina i el tabal", "la gaita i el bombo", "el violí i el piano"], "e": "La dolçaina (de vent) i el tabal (de percussió)."},
      {"q": "Quina institució musical hi ha en gairebé tots els pobles valencians?", "o": ["la banda de música (o societat musical)", "l'orquestra filharmònica", "el conservatori superior"], "e": "Les bandes i societats musicals són una tradició molt arrelada."},
      {"q": "Com s'anomena el cant tradicional valencià improvisat, amb modalitats com l'u i el dos, o les albaes?", "o": ["el cant d'estil", "el flamenc", "el cant gregorià"], "e": "El cant d'estil: les albaes, l'u, el dos, el riu-rau..."},
      {"q": "Quins són els ingredients de la paella valenciana tradicional?", "o": ["arròs, pollastre, conill, bajoqueta i garrofó", "arròs, gambes, musclos i calamar", "fideus, sépia i allioli"], "e": "Pollastre, conill, bajoqueta, garrofó, tomaca, oli, safrà i aigua. La de marisc és una altra cosa."},
      {"q": "Quin plat típic de Gandia es fa com la paella però amb fideus?", "o": ["la fideuà", "l'arròs negre", "l'all i pebre"], "e": "La fideuà, de peix i marisc."},
      {"q": "Quin plat de l'Albufera es fa amb anguila, all i pebre roig?", "o": ["l'all i pebre", "l'esgarraet", "la pericana"], "e": "L'all i pebre d'anguila."},
      {"q": "Quin arròs es fa en cassola de fang, amb cigrons, botifarra i creïlla?", "o": ["l'arròs al forn", "l'arròs negre", "l'arròs a banda"], "e": "L'arròs al forn (o arròs passejat)."},
      {"q": "Quin arròs pren el seu color de la tinta de la sépia?", "o": ["l'arròs negre", "l'arròs al forn", "l'arròs amb fesols i naps"], "e": "L'arròs negre, sovint acompanyat d'allioli."},
      {"q": "Quina beguda freda es fa amb xufa, sobretot a Alboraia?", "o": ["l'orxata", "la mistela", "el cremaet"], "e": "L'orxata de xufa, amb fartons per a sucar."},
      {"q": "Què són els bunyols que es menjen en Falles?", "o": ["dolços fregits de pasta, sovint de carabassa", "una mena d'arròs", "un embotit"], "e": "Bunyols de carabassa, amb xocolate calent."},
      {"q": "Quin plat d'Alcoi es fa amb pebrot sec, bacallà i oli?", "o": ["la pericana", "l'olleta", "la coca de llanda"], "e": "La pericana, de l'Alcoià i el Comtat."},
      {"q": "L'esmorzar de mitjan matí amb entrepà, olives, cacauets i cremaet és...", "o": ["l'esmorzaret", "la sobretaula", "el berenar de vesprada"], "e": "L'esmorzaret: un costum molt valencià."},
      {"q": "Quin és l'esport tradicional valencià per excel·lència, que es juga amb la mà?", "o": ["la pilota valenciana", "el pàdel", "l'handbol"], "e": "La pilota valenciana: escala i corda, raspall, galotxa, llargues..."},
      {"q": "El recinte tancat on es juga a pilota d'escala i corda és...", "o": ["el trinquet", "el frontó de pàdel", "el poliesportiu"], "e": "El trinquet."},
      {"q": "Quina modalitat de pilota es juga amb la pilota arran de terra?", "o": ["el raspall", "l'escala i corda", "les llargues"], "e": "El raspall: la pilota es pot tornar després de diversos bots."},
      {"q": "Com s'anomenen els jugadors de pilota valenciana?", "o": ["pilotaris", "pilotistes", "piloters"], "e": "Els pilotaris. Les posicions són el rest, el mitger i el punter."},
      {"q": "En el recompte de la pilota, quina paraula s'usa per al tercer punt (després de quinze i trenta)?", "o": ["val", "deu", "joc"], "e": "Quinze, trenta, val i joc."},
      {"q": "Quin joc de cartes valencià té jugades com «envide» i «truque»?", "o": ["el truc", "el parxís", "el dòmino"], "e": "El truc, molt popular a les comarques centrals."},
      {"q": "Quin joc d'habilitat consistix a tirar una bola per a fer caure unes peces de fusta plantades a terra?", "o": ["les birles", "el sambori", "la baldufa"], "e": "Les birles (o bitlles): cada peça és una birla."},
      {"q": "Quin joc infantil consistix a botar a la pata coixa per unes caselles pintades al terra?", "o": ["el sambori (o la xarranca)", "les bales", "el mocador"], "e": "El sambori o la xarranca."},
      {"q": "La joguina de fusta que gira sobre una punta de ferro quan la tires amb una corda és...", "o": ["la baldufa", "el catxirulo", "la bala"], "e": "La baldufa."},
      {"q": "Les boletes de vidre per a jugar al carrer són...", "o": ["les bales", "les birles", "les baldufes"], "e": "Les bales: jugar a bales al carrer."},
      {"q": "El joc en què un xiquet compta i els altres s'amaguen és...", "o": ["a amagar (o a cuit i amagar)", "a pillar", "a botar a corda"], "e": "Jugar a amagar o a cuit i amagar."},
      {"q": "Escriu el nom de la nit en què es cremen les falles: la ___.", "a": ["cremà", "la cremà"], "e": "La cremà (la nit del 19 de març)."},
      {"q": "Escriu el nom de la beguda de xufa.", "a": ["orxata", "l'orxata", "orxata de xufa"], "e": "L'orxata (de xufa)."},
      {"q": "Escriu el nom de l'instrument de vent tradicional valencià que acompanya el tabal.", "a": ["dolçaina", "la dolçaina"], "e": "La dolçaina."},
      {"q": "Escriu el nom del dolç típic de Pasqua.", "a": ["mona", "la mona", "mona de Pasqua", "la mona de Pasqua"], "e": "La mona de Pasqua."}
    ]
  },
  {
    "id": "45f412d2-e3b7-406e-9e34-1d8dd18f2ddc", "type": "b1_vocab_natura_clima", "sort_order": 12,
    "title": "La naturalesa i el clima", "name": "Clima, paisatges, fauna i flora",
    "content": "Les característiques climàtiques i el paisatge de llocs i països, la fauna i la flora més comunes i els gustos sobre paratges visitats (3.1.12).", "icon": "🌿", "color": "#A5D6A7",
    "exercises": [
      {"q": "Quin és el clima de la costa valenciana?", "o": ["mediterrani", "oceànic", "tropical"], "e": "Mediterrani: estius calorosos i secs, hiverns suaus i pluges sobretot a la tardor."},
      {"q": "Un clima amb hiverns molt freds i estius calorosos, típic de l'interior, és...", "o": ["continental", "mediterrani", "oceànic"], "e": "Continental: grans diferències de temperatura entre l'estiu i l'hivern."},
      {"q": "Un clima de temperatures suaus i pluges abundants tot l'any, com el de Galícia, és...", "o": ["oceànic (o atlàntic)", "desèrtic", "continental"], "e": "Oceànic: plou molt i les temperatures són moderades."},
      {"q": "Un clima amb molt poques pluges i grans diferències de temperatura entre el dia i la nit és...", "o": ["desèrtic", "oceànic", "tropical humit"], "e": "Desèrtic: el Sàhara, per exemple."},
      {"q": "En quina estació de l'any solen caure les pluges torrencials al País Valencià?", "o": ["a la tardor", "a l'estiu", "a l'hivern"], "e": "A la tardor: la gota freda o DANA."},
      {"q": "Un fenomen de pluges intenses i sobtades, freqüent a la tardor a la costa mediterrània, és...", "o": ["la gota freda (o DANA)", "la sequera", "l'onada de calor"], "e": "La gota freda o DANA (depressió aïllada en nivells alts)."},
      {"q": "Un període llarg sense ploure és...", "o": ["una sequera", "una riuada", "una gelada"], "e": "Una sequera (o eixutesa)."},
      {"q": "Quan un riu es desborda i l'aigua inunda els carrers, hi ha...", "o": ["una riuada (o inundació)", "una sequera", "una boira"], "e": "Una riuada o inundació."},
      {"q": "Una pluja curta però molt forta és...", "o": ["un ruixat (o un xàfec)", "un plovisqueig", "una rosada"], "e": "Un ruixat o un xàfec."},
      {"q": "Quan cau una pluja molt fina i lleugera, diem que...", "o": ["plovisqueja", "diluvia", "pedrega"], "e": "Plovisquejar (o plovinejar)."},
      {"q": "Quan cauen boletes de gel, diem que...", "o": ["pedrega (cau pedra o calamarsa)", "neva", "plovisqueja"], "e": "Pedregar: cau pedra. La calamarsa és pedra menuda."},
      {"q": "«Plou a bots i barrals»: com plou?", "o": ["Moltíssim", "Molt poc", "Gens"], "e": "Ploure a bots i barrals: ploure molt fort."},
      {"q": "La llum que es veu en el cel durant una tempesta és...", "o": ["el llampec", "el tro", "l'arc de Sant Martí"], "e": "El llampec (la llum) i el tro (el soroll). El llamp és la descàrrega que cau."},
      {"q": "Les gotetes d'aigua que es troben al matí damunt de l'herba són...", "o": ["la rosada", "la gelada", "la boira"], "e": "La rosada. Si fa molt de fred, gelada (o gebrada)."},
      {"q": "El núvol baix que no deixa veure bé és...", "o": ["la boira", "la rosada", "la xafogor"], "e": "La boira. Hi ha boira espessa."},
      {"q": "La calor humida que fa difícil respirar és...", "o": ["la xafogor", "la gelada", "la brisa"], "e": "La xafogor (o la basca): fa xafogor."},
      {"q": "El vent que ve de l'oest, sec i molt calent a l'estiu al País Valencià, és...", "o": ["el ponent", "el llevant", "la tramuntana"], "e": "El ponent (una ponentada). El llevant ve del mar, de l'est, i sovint porta pluja."},
      {"q": "El vent que ve del nord i és fred és...", "o": ["la tramuntana", "el xaloc", "el ponent"], "e": "La tramuntana. El xaloc ve del sud-est."},
      {"q": "El vent suau que bufa del mar a la terra les vesprades d'estiu és...", "o": ["la marinada", "la ponentada", "la tramuntana"], "e": "La marinada (o brisa marina)."},
      {"q": "Un avantatge del clima mediterrani és que...", "o": ["permet fer vida a l'aire lliure gran part de l'any", "plou cada dia", "neva molt a la costa"], "e": "Avantatges: suau, molt de sol. Desavantatges: sequeres i pluges torrencials."},
      {"q": "Una costa amb roques molt altes i verticals té...", "o": ["penya-segats", "dunes", "marjals"], "e": "Penya-segats: com a la Marina Alta."},
      {"q": "Una platja xicoteta entre roques és...", "o": ["una cala", "una badia", "una rambla"], "e": "Una cala. Una platja de còdols té pedres en compte d'arena."},
      {"q": "Els monticles d'arena que el vent forma prop de la platja són...", "o": ["les dunes", "els cims", "els bancals"], "e": "Les dunes, com les de la Devesa del Saler."},
      {"q": "Una zona de terra inundada d'aigua, amb canyes i molts ocells, és...", "o": ["un aiguamoll (o una marjal)", "un secà", "un penya-segat"], "e": "Un aiguamoll, una marjal o una zona humida."},
      {"q": "Un llit de riu sec la major part de l'any, que porta aigua quan plou fort, és...", "o": ["una rambla (o un barranc)", "una sèquia", "un embassament"], "e": "Una rambla o un barranc."},
      {"q": "Un llac artificial fet amb una presa per a guardar aigua és...", "o": ["un embassament (o pantà)", "una albufera", "una font"], "e": "Un embassament o pantà."},
      {"q": "Una terra que es rega amb aigua de sèquies o pous és terra de...", "o": ["regadiu", "secà", "erm"], "e": "De regadiu (l'horta). La terra de secà depén només de la pluja."},
      {"q": "Els escalons que es fan en la muntanya per a poder cultivar són...", "o": ["els bancals (o les terrasses)", "les dunes", "les rambles"], "e": "Els bancals, sovint fets amb marges de pedra seca."},
      {"q": "Quin animal salvatge, semblant a un porc, viu als boscos valencians?", "o": ["el senglar", "el teixó", "l'eriçó"], "e": "El senglar."},
      {"q": "Quin animal amb cua llarga i pèl roig, també dit guineu, viu al bosc?", "o": ["la rabosa", "la llebre", "la mostela"], "e": "La rabosa o guineu."},
      {"q": "Quin mamífer volador, símbol de València, ix de nit?", "o": ["el rat penat", "el mussol", "el falcó"], "e": "El rat penat (o ratpenat) corona l'escut de València."},
      {"q": "Quin animal xicotet té el cos cobert de punxes?", "o": ["l'eriçó", "l'esquirol", "el conill"], "e": "L'eriçó."},
      {"q": "Quin ocell de potes llargues i color rosa es veu a les salines de Santa Pola?", "o": ["el flamenc", "la gavina", "l'oroneta"], "e": "El flamenc."},
      {"q": "Quin peix xicotet és exclusiu dels aiguamolls valencians i està en perill d'extinció?", "o": ["el samaruc", "la sardina", "el lluç"], "e": "El samaruc, endèmic del País Valencià. També el fartet."},
      {"q": "Quin rèptil xicotet es veu sovint prenent el sol a les parets?", "o": ["la sargantana", "l'escurçó", "la granota"], "e": "La sargantana. El dragó és més gros i ix a la nit. L'escurçó és una serp verinosa."},
      {"q": "Quin insecte canta a l'estiu, sobretot quan fa calor, als pins?", "o": ["la xitxarra (o cigala)", "la formiga", "la papallona"], "e": "La xitxarra o cigala."},
      {"q": "Quin arbre, molt comú als nostres boscos, té fulles en forma d'agulla i fa pinyes?", "o": ["el pi", "l'alzina", "el xop"], "e": "El pi. Els pinyons ixen de les pinyes."},
      {"q": "Com s'anomena l'alzina en moltes comarques valencianes?", "o": ["la carrasca", "la surera", "la figuera"], "e": "La carrasca: fa glans. La surera dona suro (serra d'Espadà)."},
      {"q": "Quin arbre de secà fa garrofes?", "o": ["el garrofer", "l'ametler", "l'olivera"], "e": "El garrofer. L'ametler fa ametles i l'olivera, olives."},
      {"q": "Quina planta aromàtica, també dita farigola, s'usa per a les olives i els guisats?", "o": ["el timó", "el baladre", "la ginesta"], "e": "El timó (farigola). Altres: el romer, l'espígol, la sajolida."},
      {"q": "Quin arbust de flors roses o blanques creix als barrancs i és verinós?", "o": ["el baladre", "el romer", "el margalló"], "e": "El baladre: bonic, però tòxic."},
      {"q": "Quina palmera xicoteta i silvestre és típica de les muntanyes valencianes?", "o": ["el margalló", "la palmera datilera", "el xop"], "e": "El margalló. La palmera datilera forma el Palmerar d'Elx."},
      {"q": "«Vam pujar al Montgó i ens va encantar: les vistes eren impressionants.» Què expressa?", "o": ["Un gust positiu sobre un lloc visitat", "Una queixa", "Una previsió del temps"], "e": "Expressar gustos sobre paratges: ens va encantar, és preciós, val la pena."},
      {"q": "«La platja estava massa ___: no hi cabia ni una tovallola.»", "o": ["massificada", "solitària", "verge"], "e": "Massificada: amb massa gent. Una platja verge no està urbanitzada."},
      {"q": "«Esperàvem més del poble: ens va ___ una mica.»", "o": ["decebre", "encantar", "fascinar"], "e": "Decebre: no complir les expectatives. Una decepció."},
      {"q": "Un lloc natural molt bonic i tranquil és...", "o": ["un paratge (o un indret)", "un polígon", "un aparcament"], "e": "Un paratge o un indret."},
      {"q": "Escriu la paraula: període llarg sense pluja.", "a": ["sequera", "la sequera", "eixutesa"], "e": "La sequera."},
      {"q": "Escriu el nom del vent fred que bufa del nord.", "a": ["tramuntana", "la tramuntana"], "e": "La tramuntana."},
      {"q": "Escriu l'animal que corona l'escut de la ciutat de València.", "a": ["rat penat", "ratpenat", "el rat penat", "el ratpenat"], "e": "El rat penat."},
      {"q": "Escriu el contrari de «secà» (terra que es rega).", "a": ["regadiu", "el regadiu"], "e": "Regadiu."}
    ]
  }
]$data$::jsonb) AS t(
  id uuid, type text, sort_order smallint, title text, name text,
  content text, icon text, color text, exercises jsonb
);

INSERT INTO public.resources (id, name, type, category, content, difficulty, xp_earned, sort_order, metadata)
SELECT id, name, type, 'lexic_semantica', content, 'intermedi', 15, sort_order,
       jsonb_build_object('icon', icon, 'color', color, 'section_name', title)
FROM practice_catalog
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  type = EXCLUDED.type,
  category = EXCLUDED.category,
  content = EXCLUDED.content,
  difficulty = EXCLUDED.difficulty,
  xp_earned = EXCLUDED.xp_earned,
  sort_order = EXCLUDED.sort_order,
  metadata = EXCLUDED.metadata;

DELETE FROM public.practice_exercises e
USING practice_catalog c
WHERE e.resource_id = c.id AND e.level = 'B1';

INSERT INTO public.practice_exercises (resource_id, level, position, kind, prompt, options, answers, explanation)
SELECT c.id, 'B1', x.ord,
       CASE WHEN x.e ? 'a' THEN 'fill' ELSE 'choice' END,
       x.e->>'q',
       CASE WHEN x.e ? 'o' THEN ARRAY(SELECT jsonb_array_elements_text(x.e->'o')) END,
       CASE WHEN x.e ? 'a' THEN ARRAY(SELECT jsonb_array_elements_text(x.e->'a')) ELSE ARRAY[x.e->'o'->>0] END,
       x.e->>'e'
FROM practice_catalog c
CROSS JOIN LATERAL jsonb_array_elements(c.exercises) WITH ORDINALITY AS x(e, ord);

DROP TABLE practice_catalog;

-- ============================================================
-- Origen: 20261001110000_escenaris_b1.sql
-- ============================================================
-- Escenaris de conversa del B1: un per a cada bloc de 3.1 Continguts temàtics
-- i comunicatius del Quadern B1 de la JQCV, amb els punts del bloc com a
-- objectius (metadata.objectius) i un personatge i una situació que els
-- permeten practicar tots. Són recursos de la categoria 'escenari' de nivell
-- intermedi; el `type` és la clau de la ruta del xat (/xat/:type).
-- El system_prompt es compon amb el del personatge, els objectius i unes
-- pautes comunes del B1. Tornar a aplicar el fitxer no duplica res.

DELETE FROM public.resources WHERE category = 'escenari' AND type LIKE 'b1\_%';

CREATE TEMP TABLE escenaris_b1 AS
SELECT * FROM jsonb_to_recordset($data$[
  {
    "id": "48a1f2ee-8732-47f2-93d2-6cdb80b35cc5", "type": "b1_persones", "sort_order": 1,
    "name": "3.1.1. Informació personal i familiar", "icon": "👨‍👩‍👧", "color": "#FFCCBC", "bg": "#FBE9E7",
    "content": "Acabeu de fer la primera classe d'un curs de cuina i Elena, una companya, et proposa fer un café per a conéixer-vos millor.",
    "voice": "gina", "character": "Elena, companya del curs de cuina", "role": "Companya de curs",
    "greeting": "Quina classe més entretinguda, eh? Ara que tenim temps, conta'm: com és un dia normal per a tu? Ets més de matinar o de trasnitar?",
    "prompt": "Ets Elena, una dona valenciana d'uns quaranta anys, mestra d'escola, que acaba de conéixer l'aprenent en un curs de cuina i hi pren un café. Vols conéixer-lo bé. Pregunta-li pels seus costums i hàbits (a quina hora s'alça, què fa els caps de setmana, si cuina sovint, quines tradicions o costums culturals té la seua família) i conta-li els teus (t'alces a les sis per a córrer, els diumenges dines a casa dels teus pares a Alzira). Pregunta-li on viu, com és la seua casa i amb qui viu, i interessa't per la seua família: quants són, quina edat tenen, a què es dedica o què estudia cadascú i quin parentiu hi té. Conta-li que tens dos germans molt diferents: Rafa, alt, prim i calb, molt xarraire i generós però un poc despistat; i Marta, baixeta, de cabell arrissat, seriosa, tossuda i molt treballadora. Després demana-li que et compare dues persones que coneix (germans, amics o pares): com són físicament i de caràcter, i en què s'assemblen i en què es diferencien. Finalment, parla-li de la professora del curs, Pepa (molt pacient i simpàtica, però arriba sempre tard), i del company que seu al seu costat, que és un poc tafaner; demana-li la seua opinió sobre ells o sobre algú que conega, i que la justifique.",
    "objectius": [
      "Donar informació sobre si mateix o sobre una tercera persona: costums, hàbits, comportament, cultura i activitats quotidianes.",
      "Donar informació sobre l'habitatge, l'entorn familiar, els membres de la família (edat, treball, estudis, grau de parentiu...).",
      "Comparar dos persones caracteritzant-ne l'aspecte físic i la manera de ser o l'actitud.",
      "Fer apreciacions favorables o desfavorables sobre una tercera persona."
    ]
  },
  {
    "id": "503302eb-bfa2-4c1e-9281-c352b3399a2e", "type": "b1_relacions", "sort_order": 2,
    "name": "3.1.2. Relació amb els altres", "icon": "💌", "color": "#F8BBD0", "bg": "#FCE4EC",
    "content": "El teu cosí Pau organitza una festa sorpresa per les noces d'or dels vostres avis i et demana ajuda per a convidar la família.",
    "voice": "lluc", "character": "Pau, el teu cosí", "role": "Cosí",
    "greeting": "Ei, cosí! Has vist el missatge? Els avis fan cinquanta anys de casats i vull fer-los una festa sorpresa. M'ajudes a convidar tothom?",
    "prompt": "Ets Pau, cosí de l'aprenent, un jove alegre i un poc desorganitzat. Els avis fan les noces d'or el mes que ve i vols fer-los una festa sorpresa un dissabte a migdia en un restaurant de l'Albufera, amb paella i pastís. Demana a l'aprenent que t'ajude a preparar la invitació: que proposte com convidaria la família per telèfon i que et dicte o redacte un missatge d'invitació amb tots els detalls (motiu, data, hora, lloc, que és secret i que cal confirmar l'assistència). Fes de familiar convidat una estona perquè l'aprenent et convide oralment, i accepta o posa alguna excusa perquè ell reaccione. Després, explica-li que la tia Remei viu a Lió i no usa el mòbil: demana-li que t'ajude a escriure-li una carta personal (salutació afectuosa, notícies de la família, la invitació i un comiat amb records), i comenta amb ell com començar-la i acabar-la. Al final, demana-li ajuda amb altres missatges breus de l'àmbit pròxim: una nota per a deixar al restaurant amb un encàrrec, un missatge per a disculpar-te amb un amic perquè no podràs anar al seu sopar i una felicitació per a una cosina que ha aprovat les oposicions. Respon a les seues propostes i fes-li preguntes perquè les millore.",
    "objectius": [
      "Convidar a una celebració o festa de manera oral o escrita.",
      "Redactar cartes personals a familiars o amics.",
      "Elaborar i entendre altres actes comunicatius orals i escrits freqüents de l'àmbit pròxim."
    ]
  },
  {
    "id": "df8c8cba-0fb6-42ad-8467-71b7c7395e40", "type": "b1_vida_quotidiana", "sort_order": 3,
    "name": "3.1.3. Vida quotidiana", "icon": "🛒", "color": "#C8E6C9", "bg": "#E8F5E9",
    "content": "Telefones al servici d'atenció al client d'una botiga d'electrodomèstics: la cafetera que vas comprar no funciona i, a més, vols encarregar un altre producte.",
    "voice": "gina", "character": "Amparo, del servici d'atenció al client", "role": "Atenció al client",
    "greeting": "Electrodomèstics Túria, bon dia. Soc Amparo, del servici d'atenció al client. En què puc ajudar-lo?",
    "prompt": "Ets Amparo, treballadora del servici d'atenció al client per telèfon d'Electrodomèstics Túria, una botiga de València. Tracta l'aprenent de vosté, amb amabilitat professional. Ell telefona perquè la cafetera que va comprar fa dues setmanes no funciona bé. Demana-li que t'explique amb detall què li passa (si no s'encén, si perd aigua, si fa soroll, si ha arribat trencada), quan i on la va comprar i si conserva el tiquet. Al principi proposa-li una solució que no li convinga del tot (enviar-la al servici tècnic, que tarda tres setmanes) perquè haja de reclamar i argumentar el que vol (un canvi o la devolució dels diners); si insistix amb arguments, accepta canviar-la, i si no queda satisfet, informa'l que pot demanar el full de reclamacions. Després, quan diga que vol comprar també un altre aparell (per exemple una planxa, una aspiradora o un ventilador), demana-li que el descriga bé: per a què el vol, la mida, el color, el material, quants en vol i quant vol gastar; oferix-li dues opcions amb preus diferents. Per a organitzar l'entrega a domicili, pregunta-li quines tasques ha de fer demà i a quina hora estarà a casa, perquè t'explique el seu dia i trieu una franja horària.",
    "objectius": [
      "Indicar les tasques que cal fer durant el dia.",
      "Descriure el producte o l'article que es vol comprar (quantitat, preu, color, mida, material, finalitat, etc.), personalment o usant altres mitjans de comunicació.",
      "Manifestar l'estat incorrecte o el mal funcionament d'un article o d'un producte, i fer una reclamació."
    ]
  },
  {
    "id": "2ac84204-6447-4d42-b0a0-c2724ff22665", "type": "b1_llocs", "sort_order": 4,
    "name": "3.1.4. Llocs i habitatge", "icon": "🏘️", "color": "#D1C4E9", "bg": "#EDE7F6",
    "content": "Et canvies de ciutat per feina i vas a una agència immobiliària a buscar un pis de lloguer.",
    "voice": "lluc", "character": "Joan, agent immobiliari", "role": "Agent immobiliari",
    "greeting": "Bon dia, passe, passe. Soc Joan. M'han dit que busca pis per a llogar: conte'm, d'on ve i què necessita?",
    "prompt": "Ets Joan, agent d'una immobiliària de Castelló de la Plana, cordial i parlador. Tracta l'aprenent de vosté. Ell es trasllada a Castelló per motius de feina i busca un pis de lloguer. Per a entendre què li agrada, pregunta-li com és la ciutat, el poble o el barri on viu ara: quins servicis té (centre de salut, escoles, mercat, comerços, poliesportiu, biblioteca, zones verdes) i com està de comunicat (autobús, tren, metro, carril bici, carreteres); demana-li què li agrada i què trobarà a faltar. Després, demana-li que descriga el pis o l'allotjament que busca segons les seues necessitats: quantes habitacions, si el vol moblat, exterior o interior, amb ascensor, terrassa, plaça de garatge o calefacció, si accepten animals, en quin barri, quant pot pagar al mes i per quant de temps. Oferix-li dues opcions concretes amb avantatges i inconvenients (un pis lluminós al centre però sense ascensor i car; un adossat més gran als afores però mal comunicat) i demana-li que justifique quina prefereix. Si pregunta, explica-li les condicions (fiança d'un mes, despeses de comunitat incloses o no) i com és el barri de cada pis.",
    "objectius": [
      "Descriure la ciutat, el poble o el barri a on es viu informant dels servicis i de les comunicacions que s'hi oferixen.",
      "Descriure les característiques del pis, de l'apartament o de la classe d'allotjament que es busca segons les necessitats de cada u."
    ]
  },
  {
    "id": "a7f6ca29-51c8-420f-a3a9-413ca76fa5b4", "type": "b1_viatges", "sort_order": 5,
    "name": "3.1.5. Viatges i mitjans de transport", "icon": "✈️", "color": "#B3E5FC", "bg": "#E1F5FE",
    "content": "Entres en una agència de viatges per a organitzar les vacances d'estiu i reservar els bitllets.",
    "voice": "gina", "character": "Neus, agent de viatges", "role": "Agent de viatges",
    "greeting": "Bon dia! Benvingut a Viatges Mediterrània. Soc Neus. Ja té pensat on vol anar enguany o encara està dubtant?",
    "prompt": "Ets Neus, agent d'una agència de viatges de Gandia, entusiasta i pràctica. Tracta l'aprenent de vosté. Pregunta-li quina classe de viatges prefereix (platja o muntanya, ciutat o natura, organitzat o per lliure, en tren, en avió, en cotxe o en vaixell) i per què. Pregunta-li també per l'últim viatge que va fer: on va anar, com va anar i com el valora (què li va agradar i què no). Proposa-li dues destinacions amb avantatges i inconvenients (per exemple, uns dies a Mallorca en vaixell o una escapada a Lisboa en avió) i demana-li quina prefereix i per què. Quan decidisca, ajuda'l a reservar els bitllets: pregunta-li quantes persones viatgen, les dates d'anada i de tornada, si vol bitllet senzill o d'anada i tornada, la classe (turista o preferent), el seient i si factura equipatge; dona-li el preu i les condicions. Per acabar, pregunta-li si sap com arribar al port o a l'aeroport des de Gandia i quin mitjà de transport li convé, i fes que et demane informació per a arribar a l'hotel des de l'estació o l'aeroport de destinació; respon-li amb indicacions concretes (línia, parada, transbord, temps).",
    "objectius": [
      "Expressar preferències sobre diferents maneres de viatjar i llocs de destinació, i valorar el viatge.",
      "Comprar o reservar bitllets especificant-ne la classe, el nombre i la data.",
      "Demanar informació sobre la manera d'arribar a un lloc i quins mitjans de transport cal usar."
    ]
  },
  {
    "id": "b353e025-d396-4c10-a900-3e5e51791fe7", "type": "b1_oci_esport", "sort_order": 6,
    "name": "3.1.6. L'oci i l'esport", "icon": "🎭", "color": "#FFE0B2", "bg": "#FFF3E0",
    "content": "Andreu, un amic, té el diari obert per l'agenda cultural i vol decidir amb tu què fer el cap de setmana.",
    "voice": "lluc", "character": "Andreu, amic aficionat a l'esport", "role": "Amic",
    "greeting": "Mira què diu l'agenda del cap de setmana: concert de dolçaina a la plaça, una estrena al cine i una exposició al museu. Què et ve més de gust?",
    "prompt": "Ets Andreu, un amic de l'aprenent, molt esportista i actiu. Tens el diari obert per l'agenda cultural del cap de setmana i li llegeixes algunes ofertes amb detalls concrets: divendres a les 22.00, concert de dolçaina i tabal a la plaça Major, entrada lliure; dissabte, estrena d'una comèdia en versió original subtitulada al cine Albereda, sessions de 18.00 i 20.30, entrades a 7 euros, ja quasi esgotades; tot el mes, exposició de fotografia sobre l'Albufera al museu, gratuïta els diumenges. Fes-li preguntes per comprovar que ho ha entés (horari, preu, on és) i demana-li l'opinió: què li agrada més i per què. Compareu diferents maneres de passar el temps lliure (quedar-se a casa llegint o veient sèries, eixir amb amics, fer esport, anar a activitats culturals) segons els interessos de cadascú: a tu t'agrada moure't i l'aire lliure. Després proposa-li fer piragüisme al riu Xúquer diumenge de matí: explica'n els avantatges (natura, exercici) i els inconvenients (cal matinar, costa 25 euros), i demana-li que diga les normes de seguretat que cal seguir o que te les pregunte (armilla salvavides, saber nadar, crema solar, no anar sol). Deixa que accepte o refuse la proposta i que ho justifique; si refusa, demana-li que en propose una altra activitat o esport amb els seus avantatges i inconvenients.",
    "objectius": [
      "Interpretar les ofertes culturals que ixen en els mitjans de comunicació.",
      "Donar l'opinió i expressar la preferència per alguna activitat d'oci o cultural.",
      "Comparar diferents maneres de passar el temps lliure segons els interessos de cada u.",
      "Suggerir fer alguna activitat o esport, justificar-ne els avantatges i inconvenients, i indicar les normes per a practicar-lo amb seguretat. Acceptar-la o refusar-la."
    ]
  },
  {
    "id": "205a0424-735a-41ad-966a-be8589befe90", "type": "b1_administracio", "sort_order": 7,
    "name": "3.1.7. Relació amb l'Administració o amb empreses de servicis", "icon": "🏛️", "color": "#CFD8DC", "bg": "#ECEFF1",
    "content": "Vas a l'Oficina d'Atenció Ciutadana de l'ajuntament perquè l'associació de veïns vol organitzar unes activitats i necessita permisos.",
    "voice": "gina", "character": "Teresa, tècnica de l'Oficina d'Atenció Ciutadana", "role": "Funcionària",
    "greeting": "Bon dia. Tenia cita prèvia? Soc Teresa, de l'Oficina d'Atenció Ciutadana. Quin tràmit vol fer?",
    "prompt": "Ets Teresa, tècnica de l'Oficina d'Atenció Ciutadana d'un ajuntament valencià, correcta, amable i precisa amb els tràmits. Tracta l'aprenent de vosté. Ell representa l'associació de veïns del seu barri i vol demanar permís per a fer-hi activitats. Fes que sol·licite el permís oralment amb tots els detalls: quina instal·lació o servici vol usar (el saló d'actes del centre cívic, la plaça del barri per a un sopar al carrer, el poliesportiu per a un torneig), quin dia, a quina hora, per a quantes persones i amb quina finalitat. Explica-li que també ho ha de demanar per escrit amb una instància a la seu electrònica o al registre, i demana-li que t'explique què hi posaria (dades, exposició i sol·licitud). Després comunica-li la resolució: autoritza una part (el saló d'actes, amb condicions: deixar-lo net, acabar abans de les 22.00) i denega una altra amb una justificació (la plaça no, perquè aquell dia hi ha mercat). Demana-li que reaccione i que et diga, amb les seues paraules, què li han autoritzat i què no, perquè ho puga explicar als veïns. Finalment, comenta-li que l'ajuntament vol que els veïns usen bé els servicis municipals (la biblioteca, el servici de bicicletes, la deixalleria o el poliesportiu) i demana-li quins consells donaria a un veí nou per a usar-ne un correctament.",
    "objectius": [
      "Sol·licitar permís, oralment o per escrit, per a usar un servici o una instal·lació.",
      "Expressar l'autorització o la denegació per a fer una activitat o utilitzar algun servici.",
      "Aconsellar sobre l'ús correcte d'un servici."
    ]
  },
  {
    "id": "ee5b724f-84e1-474c-8cba-09a7353f7982", "type": "b1_treball", "sort_order": 8,
    "name": "3.1.8. El treball", "icon": "💼", "color": "#FFF9C4", "bg": "#FFFDE7",
    "content": "Has respost a una oferta de treball de recepcionista d'un hotel de Benidorm i et fan l'entrevista.",
    "voice": "lluc", "character": "Sergi, responsable de recursos humans", "role": "Entrevistador",
    "greeting": "Bon dia, passe, per favor. Soc Sergi, de recursos humans de l'Hotel Marina. Hem rebut el seu currículum: per què li interessa la nostra oferta?",
    "prompt": "Ets Sergi, responsable de recursos humans de l'Hotel Marina de Benidorm, professional però proper. Tracta l'aprenent de vosté. Fas una entrevista per a un lloc de recepcionista. L'oferta deia: «Es busca recepcionista. Requisits: experiència d'atenció al públic i coneixements d'informàtica; es valoraran els idiomes. Contracte de sis mesos, jornada completa a torns, incorporació immediata.» Comprova que l'ha entesa preguntant-li què demanava l'oferta i per què creu que complix els requisits, i demana-li que t'explique el seu currículum: estudis, idiomes i experiència. Pregunta-li com era el seu últim lloc de treball (on, quines funcions tenia, horari, companys) i quines aptituds personals té (responsable, puntual, treball en equip, resolució de problemes), amb exemples. Després planteja-li una situació pràctica: ensenya-li el text de benvinguda que va escriure l'últim becari per als clients (té errors i és massa llarg) i demana-li si està d'acord amb com està fet i què canviaria. Finalment, demana-li que t'explique pas a pas com faria una tasca habitual (registrar l'entrada d'un client, atendre una queixa per telèfon o preparar el torn per al company següent), com si donara les instruccions a un company nou. Acaba l'entrevista dient-li quan li donareu una resposta.",
    "objectius": [
      "Entendre anuncis d'ofertes de treball per escrit, respondre a estos textos i redactar un currículum laboral.",
      "Indicar i descriure el lloc de treball i les aptituds personals en una entrevista de treball.",
      "Manifestar l'acord o el desacord sobre un treball fet.",
      "Donar indicacions sobre la realització d'una tasca."
    ]
  },
  {
    "id": "bff1b2da-7534-4dad-b6ac-80737003d3b9", "type": "b1_salut", "sort_order": 9,
    "name": "3.1.9. Salut i assistència sanitària", "icon": "🩺", "color": "#FFCDD2", "bg": "#FFEBEE",
    "content": "Marc, el teu company de pis, ha tornat del partit de futbol coixejant i, a més, sa mare l'ha telefonat perquè té febre.",
    "voice": "lluc", "character": "Marc, company de pis", "role": "Company de pis",
    "greeting": "Ai, ai... Mira com tinc el turmell! M'he torçat jugant a futbol. I a més, ma mare m'ha telefonat: té febre i està sola. No sé què fer...",
    "prompt": "Ets Marc, company de pis de l'aprenent, un xic de vint-i-cinc anys un poc exagerat i nerviós quan està malalt. Acabes de tornar d'un partit de futbol: t'has torçat el turmell, el tens inflat i blau i et fa molt de mal quan camines. A més, ta mare, que viu sola a Ontinyent, t'ha telefonat: té febre alta, tos i mal de cos des de fa dos dies. Pregunta a l'aprenent si alguna vegada ha tingut un accident o una malaltia semblant i demana-li que et descriga els símptomes que va tindre i com va quedar després. Demana-li consell: què has de fer tu amb el turmell (gel, repòs, alçar la cama, no caminar, embenar-lo) i què ha de fer ta mare (beure molt d'aigua, prendre's la temperatura, no eixir de casa); fes-li preguntes perquè t'ho explique bé, perquè després ho vols contar a ta mare. Pregunta-li on has d'anar tu (centre de salut, urgències, farmàcia de guàrdia) i quan cal telefonar al 112. Finalment, de sobte et marejes una mica: demana-li que telefone per demanar assistència i fes tu de telefonista del servici sanitari perquè l'aprenent explique la situació (qui és el pacient, què li passa, des de quan, on esteu) i demane l'ajuda necessària.",
    "objectius": [
      "Descriure els símptomes d'una malaltia o la situació després d'un accident.",
      "Donar informació a una tercera persona sobre com s'ha d'actuar en cas de malaltia o accident.",
      "Indicar a on cal adreçar-se en cas de malaltia o accident, i demanar l'assistència necessària."
    ]
  },
  {
    "id": "b023b572-af29-410c-b2af-a9310385467a", "type": "b1_territori", "sort_order": 10,
    "name": "3.1.10. Geografia i història del territori", "icon": "🗺️", "color": "#DCEDC8", "bg": "#F1F8E9",
    "content": "Hannah, una estudiant alemanya d'Erasmus, ha de fer una presentació sobre la Comunitat Valenciana i et demana ajuda.",
    "voice": "gina", "character": "Hannah, estudiant d'Erasmus", "role": "Estudiant estrangera",
    "greeting": "Hola! Gràcies per quedar amb mi. Per a la meua presentació, primer necessite entendre on està exactament la Comunitat Valenciana. M'ho expliques?",
    "prompt": "Ets Hannah, una estudiant alemanya de vint-i-dos anys que fa un Erasmus a la Universitat de València i parla valencià bastant bé, però encara es confon amb alguns noms. Has de fer una presentació a classe sobre la Comunitat Valenciana i demanes ajuda a l'aprenent. Pregunta-li on està situada (respecte de la península, del mar i de les comunitats veïnes) i quins són els fets més importants de la seua història (els ibers i els romans, la conquesta de Jaume I i el 9 d'Octubre, el Regne de València i els Furs, el Segle d'Or, Almansa, l'Estatut d'autonomia...): no cal que sàpia dates exactes, però demana-li que t'ho explique amb les seues paraules. Pregunta-li quines són les províncies i les seues capitals, què és una comarca i a quina comarca pertany el seu poble o ciutat, i quines en coneix. Després interessa't pels principals rius (el Túria, el Xúquer, el Segura, el Millars...) i muntanyes (el Penyagolosa, l'Aitana, el Montgó, la serra de Mariola...): per on passen, on són, si les ha visitades. De tant en tant, confon alguna dada (per exemple, que el Xúquer passa per València o que Alacant està al nord) perquè l'aprenent et corregisca. Compara-ho breument amb Alemanya quan vinga a tomb.",
    "objectius": [
      "Parlar sobre la nostra situació geogràfica i els principals fets de la nostra història.",
      "Parlar sobre les demarcacions territorials: províncies i comarques.",
      "Parlar sobre els principals accidents geogràfics (muntanyes i rius)."
    ]
  },
  {
    "id": "500e49a8-6401-4c59-b7e5-1c0e8312534f", "type": "b1_cultura", "sort_order": 11,
    "name": "3.1.11. Cultura i llengua", "icon": "🎉", "color": "#FFAB91", "bg": "#FBE9E7",
    "content": "Àlex, locutor d'una ràdio local, et fa una entrevista en directe per a un programa sobre les tradicions dels pobles valencians.",
    "voice": "lluc", "character": "Àlex, locutor de ràdio", "role": "Locutor de ràdio",
    "greeting": "Bona vesprada, oients! Hui tenim amb nosaltres un convidat molt especial per a parlar de les nostres tradicions. Benvingut! Quina és la festa més important del teu poble?",
    "prompt": "Ets Àlex, locutor animat i curiós d'un programa de ràdio local sobre tradicions valencianes. Entrevistes l'aprenent en directe, amb un to proper i alguna broma. Pregunta-li per les festes tradicionals i populars del seu poble o ciutat, o de les que coneix (les Falles, les Fogueres, la Magdalena, els Moros i Cristians, Sant Antoni, la nit de Sant Joan, la Tomatina...): quan se celebren, què s'hi fa, què és el que més li agrada i el que menys. Relaciona cada festa amb la música (la dolçaina i el tabal, la banda de música, els pasdobles, els himnes) i amb la gastronomia (els bunyols, la paella, la mona de Pasqua, la coca, els dolços típics): demana-li quins plats o dolços es mengen i si en sap la recepta o els ingredients principals. Conta tu breument alguna anècdota d'una festa. Després passa a la segona part del programa: els jocs i els esports tradicionals. Pregunta-li si ha jugat a pilota valenciana o l'ha vista en un trinquet, si sap les modalitats (escala i corda, raspall, galotxa), i a quins jocs jugava de xicotet al carrer (el sambori, les bales, la baldufa, a amagar, el truc, les birles). Demana-li la seua opinió sobre si cal mantindre estes tradicions i per què. Acomiada el programa agraint-li la participació.",
    "objectius": [
      "Parlar sobre festes tradicionals i populars, i relacionar-les amb la música i la gastronomia.",
      "Parlar sobre els jocs i els esports tradicionals."
    ]
  },
  {
    "id": "79844cfc-b106-46cb-9d12-71defbea8289", "type": "b1_natura_clima", "sort_order": 12,
    "name": "3.1.12. La naturalesa i el clima", "icon": "🌿", "color": "#A5D6A7", "bg": "#E8F5E9",
    "content": "Fas una ruta guiada pel Parc Natural del Montgó i, mentre pugeu, la guia conversa amb el grup.",
    "voice": "gina", "character": "Pilar, guia del parc natural", "role": "Guia de natura",
    "greeting": "Bon dia a tothom! Abans de començar a pujar, una pregunta: d'on veniu? Hi fa el mateix clima que ací a la Marina Alta?",
    "prompt": "Ets Pilar, guia del Parc Natural del Montgó, entre Dénia i Xàbia, apassionada de la natura i bona comunicadora. Mentre fas una ruta, conversa amb l'aprenent. Pregunta-li d'on és i com és el clima del lloc on viu o d'un país que conega bé (temperatures, pluges, vents, estacions) i com és el paisatge (muntanyes, rius, costa, plana). Compareu-lo amb el clima mediterrani de la Marina Alta i demana-li que n'explique els avantatges i els desavantatges (sol i temperatures suaus però sequeres i gotes fredes; fred i neu però més verd, etc.). Explica tu breument alguna cosa del Montgó (el penya-segat del cap de Sant Antoni, el margalló, el romer, el pi, la sargantana, el falcó) i pregunta-li quins animals i plantes són més comuns on viu ell, quins coneix pel nom i si n'ha vist algun durant la ruta. Finalment, pregunta-li quins paratges o llocs naturals ha visitat i quins li han agradat més o menys, i per què (una platja, una muntanya, un parc natural, un riu, un país), i demana-li que te'n recomane algun.",
    "objectius": [
      "Parlar de les característiques climàtiques i dels principals accidents geogràfics de llocs o de països; poder comparar-los i expressar-ne els avantatges o desavantatges.",
      "Conéixer la fauna i la flora més comuna del seu lloc de residència.",
      "Expressar els gustos sobre paratges i llocs que s'han visitat."
    ]
  }
]$data$::jsonb) AS t(
  id uuid, type text, sort_order smallint, name text, icon text, color text, bg text,
  content text, voice text, character text, role text, greeting text, prompt text, objectius jsonb
);

-- El nom de la secció és el del bloc sense el número.
INSERT INTO public.resources (id, name, type, category, content, difficulty, xp_earned, sort_order, metadata)
SELECT id, name, type, 'escenari', content, 'intermedi', 15, sort_order,
       jsonb_build_object(
         'icon', icon,
         'color', color,
         'bgIllustration', bg,
         'voice', voice,
         'scenario', type,
         'character', character,
         'character_role', role,
         'section_name', regexp_replace(name, '^[0-9.]+\s*', ''),
         'initial_prompt', greeting,
         'objectius', objectius,
         'system_prompt', prompt || E'\n\n' ||
           'Pautes: l''aprenent prepara el nivell B1 (intermedi) de la JQCV. Parla en valencià general (normativa de l''AVL), amb un registre natural i un vocabulari variat propi del B1: usa connectors (perquè, ja que, però, en canvi, a més, per tant), oracions subordinades i, de tant en tant, alguna frase feta freqüent, sempre de manera clara. ' ||
           'Fes torns breus (màxim 3-4 frases) amb una o dues preguntes per torn. Demana-li que done detalls i exemples, que compare, que expresse opinions i que les justifique; si respon amb monosíl·labs o frases molt curtes, repregunta perquè s''allargue. Adapta el tractament (tu o vosté) a la situació i al personatge. ' ||
           'Mai no ixes del personatge ni fas lliçons de gramàtica: si l''aprenent s''equivoca o usa un castellanisme, reformula la frase correcta dins de la teua resposta amb naturalitat. ' ||
           'Si no t''entén, explica-ho amb altres paraules. Dona dades concretes quan te les pregunte i no resolgues tu la situació: fes-lo parlar. ' ||
           E'\nObjectius que ha de complir l''aprenent (guia la conversa perquè els complisca d''un en un, sense enumerar-los): ' ||
           (SELECT string_agg(o, ' | ') FROM jsonb_array_elements_text(objectius) AS o) ||
           ' Quan els haja complit tots, tanca la situació amb naturalitat i acomiada''t.'
       )
FROM escenaris_b1
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  type = EXCLUDED.type,
  category = EXCLUDED.category,
  content = EXCLUDED.content,
  difficulty = EXCLUDED.difficulty,
  xp_earned = EXCLUDED.xp_earned,
  sort_order = EXCLUDED.sort_order,
  metadata = EXCLUDED.metadata;

DROP TABLE escenaris_b1;

-- ============================================================
-- Origen: 20261001120000_practice_vocabulari_b1_usual.sql
-- ============================================================
-- Vocabulari usual del B1 (Quadern B1 de la JQCV): els àmbits que els
-- continguts de 20261001100000 (un per bloc de 3.1) no cobrien o cobrien poc.
-- S'hi afigen huit continguts de Lèxic i semàntica de nivell intermedi (el camp
-- i la ciutat, els vehicles i el trànsit, els jocs i els esports, l'actualitat,
-- la música, el cinema i el teatre, els diners i els negocis, la tecnologia i
-- els estats d'ànim i la descripció d'objectes), i més exercicis B1 per a la
-- família, l'habitatge, el treball i la naturalesa i l'oratge, darrere dels que
-- ja hi ha (a partir de la posició `offset`). Tornar a aplicar el fitxer no
-- duplica res.

CREATE TEMP TABLE practice_catalog AS
SELECT * FROM jsonb_to_recordset($data$[
  {
    "id": "2dbbc6f8-5f76-455f-acc3-af804cf153e2", "type": "b1_vocab_camp_ciutat", "sort_order": 13,
    "title": "El camp i la ciutat", "name": "Agricultura, ramaderia, vida rural i vida urbana",
    "content": "Els treballs del camp, les ferramentes, els cultius, els animals de granja i la comparació entre la vida al camp i a la ciutat (Vocabulari usual).", "icon": "🚜", "color": "#E6EE9C",
    "exercises": [
      {"q": "La persona que treballa la terra és...", "o": ["el llaurador (o agricultor)", "el ramader", "el pescador"], "e": "El llaurador o l'agricultor conrea la terra. El ramader cria bestiar."},
      {"q": "Posar les llavors a la terra perquè naixquen plantes és...", "o": ["sembrar", "collir", "podar"], "e": "Sembrar. Plantar és posar a terra una planta ja nascuda."},
      {"q": "Arreplegar els fruits quan estan madurs és...", "o": ["collir", "sembrar", "regar"], "e": "Collir: la collita. Collir taronges, olives, ametles..."},
      {"q": "La collita del raïm per a fer vi és...", "o": ["la verema", "la sega", "la batuda"], "e": "La verema (veremar). La sega és la collita del blat o de l'arròs."},
      {"q": "Tallar les branques dels arbres perquè creixquen millor és...", "o": ["podar", "empeltar", "sembrar"], "e": "Podar. Empeltar és unir una branca d'un arbre a un altre."},
      {"q": "Cultivar la terra, en general, és...", "o": ["conrear", "colgar", "llaurar el mar"], "e": "Conrear (o cultivar). Els conreus: els cultius."},
      {"q": "La ferramenta amb un mànec i una fulla de ferro per a cavar la terra és...", "o": ["l'aixada", "la falç", "el rasclet"], "e": "L'aixada. La falç té la fulla corba i servix per a segar."},
      {"q": "El vehicle de motor que s'usa per a llaurar i portar remolcs al camp és...", "o": ["el tractor", "la grua", "la furgoneta"], "e": "El tractor."},
      {"q": "El vehicle d'una roda que s'empeny per a portar terra o pedres és...", "o": ["el carretó", "el tractor", "el remolc"], "e": "El carretó (de mà)."},
      {"q": "Una construcció de plàstic o vidre per a cultivar plantes protegides del fred és...", "o": ["un hivernacle", "un magatzem", "un galliner"], "e": "Un hivernacle."},
      {"q": "El producte químic que s'usa per a matar els insectes que fan malbé els cultius és...", "o": ["un insecticida (o plaguicida)", "un adob", "un fertilitzant natural"], "e": "Insecticida o plaguicida. L'adob (o fems) alimenta la terra."},
      {"q": "Els excrements dels animals que s'usen per a adobar la terra són...", "o": ["els fems", "les llavors", "les arrels"], "e": "Els fems: adob natural."},
      {"q": "Un camp ple de tarongers és...", "o": ["un hort de tarongers (o taronjar)", "una vinya", "un arrossar"], "e": "Un hort de tarongers o un taronjar."},
      {"q": "Un camp de vinyes és...", "o": ["una vinya", "un oliverar", "un ametlerar"], "e": "La vinya. Oliverar: camp d'oliveres. Ametlerar: d'ametlers."},
      {"q": "Un camp inundat on es cultiva arròs és...", "o": ["un arrossar", "un secà", "un bancal d'ametlers"], "e": "Un arrossar (com els de l'Albufera)."},
      {"q": "Quina fruita és típica de la tardor i sol ser taronja i molt dolça?", "o": ["el caqui", "la bresquilla", "la cirera"], "e": "El caqui (de la Ribera). La bresquilla i la cirera són d'estiu i de primavera."},
      {"q": "Quina fruita roja, plena de grans, es menja a la tardor?", "o": ["la magrana", "la nespra", "l'albercoc"], "e": "La magrana."},
      {"q": "Quina verdura té fulles dures i es menja el cor, molt típica de Benicarló?", "o": ["la carxofa", "la carabasseta", "l'albergínia"], "e": "La carxofa de Benicarló."},
      {"q": "Un conjunt d'animals de granja (vaques, ovelles, cabres, porcs) és...", "o": ["el bestiar", "el ramat de gats", "la fauna salvatge"], "e": "El bestiar. Un grup d'ovelles o cabres que guarda un pastor és un ramat."},
      {"q": "La persona que guarda i porta a pasturar les ovelles és...", "o": ["el pastor", "el llaurador", "el carnisser"], "e": "El pastor. Pasturar: menjar herba al camp."},
      {"q": "La cria de l'ovella és...", "o": ["el corder", "el vedell", "el poltre"], "e": "El corder (o anyell). El vedell és fill de la vaca i el poltre, del cavall."},
      {"q": "La femella del cavall és...", "o": ["l'egua", "la mula", "la burra"], "e": "L'egua (o euga)."},
      {"q": "On dormen les gallines?", "o": ["al galliner", "a la quadra", "a la cort"], "e": "Al galliner. Els cavalls, a la quadra; els porcs, a la cort (o porquera)."},
      {"q": "Traure la llet a una vaca o a una cabra és...", "o": ["munyir", "esquilar", "pasturar"], "e": "Munyir. Esquilar és tallar la llana a les ovelles."},
      {"q": "Quin animal de granja diu «quiquiriquic» de matí?", "o": ["el gall", "l'ànec", "el porc"], "e": "El gall. La gallina pon ous i els pollets són les cries."},
      {"q": "Una casa de camp gran, amb terres al voltant, típica de l'interior, és...", "o": ["un mas (o una masia)", "un àtic", "un pis"], "e": "Un mas o una masia. A l'horta: l'alqueria."},
      {"q": "Els productes que es cultiven a prop del lloc on es venen són productes...", "o": ["de proximitat (o de quilòmetre zero)", "d'importació", "congelats"], "e": "De proximitat o de quilòmetre zero."},
      {"q": "Els aliments cultivats sense productes químics són...", "o": ["ecològics", "transgènics", "industrials"], "e": "Ecològics (o biològics)."},
      {"q": "L'abandó dels pobles perquè la gent se'n va a viure a la ciutat és...", "o": ["el despoblament rural", "l'eixample", "l'urbanisme"], "e": "El despoblament (o l'èxode rural)."},
      {"q": "Un avantatge de viure al camp és...", "o": ["la tranquil·litat i l'aire net", "el trànsit intens", "la contaminació"], "e": "Avantatges del camp: tranquil·litat, natura, aire net. Inconvenients: menys servicis i transport."},
      {"q": "Un inconvenient de viure en una gran ciutat és...", "o": ["el soroll i la contaminació", "la falta de botigues", "que no hi ha transport"], "e": "Inconvenients de la ciutat: soroll, contaminació, embussos, pisos cars."},
      {"q": "Un edifici molt alt, de moltes plantes, és...", "o": ["un gratacel", "una masia", "una barraca"], "e": "Un gratacel (com els de Benidorm)."},
      {"q": "Un conjunt de cases noves fora del nucli urbà, sovint amb piscina i jardí, és...", "o": ["una urbanització", "un polígon industrial", "una alqueria"], "e": "Una urbanització."},
      {"q": "Quan hi ha massa gent en un lloc, diem que hi ha...", "o": ["aglomeracions", "despoblament", "silenci"], "e": "Aglomeracions (de gent): lloc massificat."},
      {"q": "«En el meu poble tots ens coneixem i ens ajudem.» Quin valor destaca?", "o": ["la vida de veïnat", "la contaminació", "l'anonimat"], "e": "Al poble hi ha més relació entre veïns; a la ciutat, més anonimat."},
      {"q": "Un camí estret per on passen els animals i les persones pel camp és...", "o": ["una senda (o un camí rural)", "una autovia", "una avinguda"], "e": "Una senda, un sender o un camí rural."},
      {"q": "Un carrer molt ample, sovint amb arbres, d'una ciutat és...", "o": ["una avinguda (o un bulevard)", "una senda", "un atzucac"], "e": "Una avinguda. Un atzucac és un carrer sense eixida."},
      {"q": "Un carrer sense eixida és...", "o": ["un atzucac (o carreró sense eixida)", "una avinguda", "una rambla"], "e": "Un atzucac."},
      {"q": "Escriu el verb: tallar les branques d'un arbre perquè cresca millor.", "a": ["podar"], "e": "Podar."},
      {"q": "Escriu el nom de la collita del raïm.", "a": ["verema", "la verema"], "e": "La verema."},
      {"q": "Escriu la cria de la vaca.", "a": ["vedell", "el vedell", "vedella", "la vedella"], "e": "El vedell (o la vedella)."},
      {"q": "Escriu la paraula: lloc on dormen les gallines.", "a": ["galliner", "el galliner"], "e": "El galliner."}
    ]
  },
  {
    "id": "3c7dfeff-bd32-430c-a7dc-ba19c67ba89c", "type": "b1_vocab_transit", "sort_order": 14,
    "title": "Els vehicles i el trànsit", "name": "El cotxe, la conducció, les normes i les incidències",
    "content": "Els vehicles i les seues parts, la conducció, els senyals i les normes de trànsit, les multes, les avaries i els accidents (Vocabulari usual).", "icon": "🚗", "color": "#B0BEC5",
    "exercises": [
      {"q": "La peça rodona amb què es dirigix el cotxe és...", "o": ["el volant", "el fre", "el maleter"], "e": "El volant. Conduir: portar el volant."},
      {"q": "El pedal que servix per a parar el cotxe és...", "o": ["el fre", "l'accelerador", "l'embragatge"], "e": "El fre (frenar). L'accelerador fa anar més de pressa."},
      {"q": "On es posen les maletes en un cotxe?", "o": ["al maleter", "al capó", "al parabrisa"], "e": "Al maleter. El capó cobrix el motor."},
      {"q": "L'espill que permet veure què hi ha darrere del cotxe és...", "o": ["el retrovisor", "l'intermitent", "el para-xocs"], "e": "El retrovisor (interior i laterals)."},
      {"q": "Els llums que avisen que el cotxe girarà són...", "o": ["els intermitents", "els fars antiboira", "els llums de fre"], "e": "Els intermitents: posar l'intermitent abans de girar."},
      {"q": "El vidre de davant del cotxe és...", "o": ["el parabrisa", "el retrovisor", "el capó"], "e": "El parabrisa. Els eixugaparabrises el netegen quan plou."},
      {"q": "La peça de goma plena d'aire que cobrix la roda és...", "o": ["el pneumàtic", "el volant", "el depòsit"], "e": "El pneumàtic. Si es punxa, tens una punxada."},
      {"q": "Quan el pneumàtic perd aire perquè ha xafat un clau, tens...", "o": ["una punxada", "un embús", "una multa"], "e": "Una punxada: cal posar la roda de recanvi."},
      {"q": "La placa amb números i lletres que identifica el cotxe és...", "o": ["la matrícula", "el permís de circulació", "la ITV"], "e": "La matrícula."},
      {"q": "El que has de portar posat per seguretat en el cotxe, encara que el trajecte siga curt, és...", "o": ["el cinturó de seguretat", "el casc", "l'armilla salvavides"], "e": "El cinturó de seguretat és obligatori per a tots els ocupants."},
      {"q": "El document que et permet conduir és...", "o": ["el carnet (o permís) de conduir", "el passaport", "la targeta SIP"], "e": "El carnet de conduir. S'obté a l'autoescola."},
      {"q": "On aprens a conduir?", "o": ["a l'autoescola", "a la gasolinera", "al taller"], "e": "A l'autoescola: examen teòric i examen pràctic."},
      {"q": "La revisió obligatòria que es fa als cotxes per a comprovar que estan en bon estat és...", "o": ["la ITV (inspecció tècnica de vehicles)", "la ITC", "el peatge"], "e": "La ITV."},
      {"q": "On porten el cotxe quan té una avaria?", "o": ["al taller (mecànic)", "a l'autoescola", "a la ITV"], "e": "Al taller. El mecànic repara el cotxe."},
      {"q": "Quan el cotxe s'espatla i no pot continuar, ha tingut...", "o": ["una avaria", "una multa", "un avançament"], "e": "Una avaria. Telefonar a la grua o a l'assegurança."},
      {"q": "El vehicle que s'emporta els cotxes mal aparcats o avariats és...", "o": ["la grua", "l'ambulància", "el camió del fem"], "e": "La grua."},
      {"q": "Una assegurança que cobrix tots els danys del teu cotxe és una assegurança...", "o": ["a tot risc", "a tercers", "de vida"], "e": "A tot risc. A tercers només cobrix els danys als altres."},
      {"q": "Un vehicle de dues rodes amb motor xicotet, que es pot conduir als quinze anys, és...", "o": ["un ciclomotor", "un camió", "un patinet"], "e": "Un ciclomotor (o «moto de 50»)."},
      {"q": "Un vehicle per a transportar mercaderies, més xicotet que un camió, és...", "o": ["una furgoneta", "un autocar", "un tramvia"], "e": "Una furgoneta."},
      {"q": "Un autobús per a viatges llargs per carretera és...", "o": ["un autocar", "un tramvia", "un taxi"], "e": "Un autocar."},
      {"q": "Quan hi ha tants cotxes que no es poden moure, hi ha...", "o": ["un embús (o una retenció)", "un avançament", "una punxada"], "e": "Un embús, una retenció o una caravana de cotxes."},
      {"q": "El moment del dia amb més trànsit és l'hora...", "o": ["punta", "baixa", "lliure"], "e": "L'hora punta."},
      {"q": "Quan el semàfor està en groc (o ambre), has de...", "o": ["parar si pots fer-ho amb seguretat", "accelerar", "pitar"], "e": "Groc o ambre: precaució, el semàfor està a punt de posar-se en roig."},
      {"q": "El senyal octogonal roig que obliga a parar del tot és...", "o": ["el senyal d'estop (STOP)", "el cediu el pas", "el sentit obligatori"], "e": "STOP: cal parar del tot. El senyal de cediu el pas és triangular."},
      {"q": "Passar al cotxe que va davant de tu, pel carril de l'esquerra, és...", "o": ["avançar", "recular", "aparcar"], "e": "Avançar (fer un avançament)."},
      {"q": "Anar cap arrere amb el cotxe és fer...", "o": ["marxa arrere", "un avançament", "un revolt"], "e": "Fer marxa arrere (o recular)."},
      {"q": "Una corba en la carretera és...", "o": ["un revolt", "un voral", "un encreuament"], "e": "Un revolt (o una corba). Revolts perillosos."},
      {"q": "La franja al costat de la carretera, fora dels carrils, on pots parar en cas d'avaria, és...", "o": ["el voral", "la vorera", "la mitjana"], "e": "El voral (de la carretera). La vorera és a la ciutat."},
      {"q": "Deixar el cotxe parat al costat d'un altre cotxe aparcat, en el carril, és aparcar en...", "o": ["doble fila", "zona blava", "bateria"], "e": "Aparcar en doble fila: prohibit i sancionat."},
      {"q": "La zona on cal pagar per a aparcar durant un temps limitat és la zona...", "o": ["blava", "verda de vianants", "de càrrega i descàrrega"], "e": "La zona blava (amb parquímetre o aplicació)."},
      {"q": "La sanció en diners per no complir les normes de trànsit és...", "o": ["una multa", "un peatge", "una propina"], "e": "Una multa. Posar una multa; multar."},
      {"q": "L'aparell que controla la velocitat dels cotxes a la carretera és...", "o": ["el radar", "el parquímetre", "el semàfor"], "e": "El radar. Si vas massa de pressa: excés de velocitat."},
      {"q": "La prova per a saber si un conductor ha begut alcohol és...", "o": ["el control d'alcoholèmia", "la ITV", "l'examen pràctic"], "e": "Control d'alcoholèmia: bufar en l'etilòmetre."},
      {"q": "Quan dos cotxes es peguen un colp, diem que...", "o": ["han xocat (o han topat)", "han avançat", "han aparcat"], "e": "Xocar o topar: un xoc, un accident."},
      {"q": "Quan un vehicle colpeja un vianant, diem que l'ha...", "o": ["atropellat", "avançat", "multat"], "e": "Atropellar: un atropellament."},
      {"q": "On es carrega un cotxe elèctric?", "o": ["en un punt de recàrrega", "en un parquímetre", "en un radar"], "e": "En un punt (o estació) de recàrrega."},
      {"q": "«Hi ha obres en la carretera i ens han fet anar per un altre camí»: hem pres una...", "o": ["desviació", "dreta", "rotonda"], "e": "Una desviació."},
      {"q": "Conduir amb precaució, respectant les normes, és conduir de manera...", "o": ["responsable", "temerària", "distreta"], "e": "Responsable. Una conducció temerària és perillosa."},
      {"q": "Escriu el verb: deixar el cotxe parat en un lloc.", "a": ["aparcar", "estacionar"], "e": "Aparcar o estacionar."},
      {"q": "Escriu la paraula: lloc del cotxe on es posen les maletes.", "a": ["maleter", "el maleter"], "e": "El maleter."},
      {"q": "Escriu el nom del vehicle que s'emporta els cotxes mal aparcats.", "a": ["grua", "la grua"], "e": "La grua."},
      {"q": "Escriu la paraula: quan una roda perd l'aire, tens una ___.", "a": ["punxada"], "e": "Una punxada."}
    ]
  },
  {
    "id": "42fca25a-cf27-40c1-9dee-c1464a42d683", "type": "b1_vocab_esports", "sort_order": 15,
    "title": "Els jocs i els esports", "name": "Esports, competicions, jocs de taula i de cartes",
    "content": "El lèxic dels esports més habituals, de les competicions, dels jocs de taula i de cartes (Vocabulari usual).", "icon": "⚽", "color": "#B2DFDB",
    "exercises": [
      {"q": "En futbol, el jugador que para els xuts i pot tocar la pilota amb les mans és...", "o": ["el porter", "el davanter", "el defensa"], "e": "El porter guarda la porteria. El davanter ataca i el defensa defén."},
      {"q": "Pegar a la pilota amb el peu amb força és...", "o": ["xutar", "encistellar", "rematar amb la mà"], "e": "Xutar: fer un xut."},
      {"q": "El càstig quan es fa una falta dins de l'àrea és...", "o": ["un penal", "un córner", "un fora de joc"], "e": "Un penal (o penalti)."},
      {"q": "Quan l'àrbitre trau una targeta roja, el jugador...", "o": ["és expulsat", "marca un gol", "és canviat per un suplent sense càstig"], "e": "Targeta roja: expulsió. La groga és una amonestació."},
      {"q": "El jugador que espera a la banqueta per a entrar al partit és...", "o": ["el suplent", "el titular", "el capità"], "e": "El suplent. Els titulars comencen jugant."},
      {"q": "Si un partit d'eliminatòria acaba en empat, de vegades es juga...", "o": ["una pròrroga", "un descans", "un entrenament"], "e": "La pròrroga i, si cal, la tanda de penals."},
      {"q": "En bàsquet, ficar la pilota dins de la cistella és...", "o": ["encistellar", "xutar", "servir"], "e": "Encistellar: fer una cistella. Un triple val tres punts."},
      {"q": "En tennis, l'objecte amb què es pega a la pilota és...", "o": ["la raqueta", "el bat", "el pal"], "e": "La raqueta. La pilota ha de passar per damunt de la xarxa."},
      {"q": "En tennis, el primer colp de cada punt és...", "o": ["el servei", "el remat", "el rebot"], "e": "El servei (servir). Un partit es dividix en sets."},
      {"q": "Quin estil de natació es fa panxa amunt?", "o": ["l'esquena", "la braça", "el crol"], "e": "Esquena. Altres estils: crol, braça i papallona."},
      {"q": "Una cursa a peu de 42 quilòmetres és...", "o": ["una marató", "un esprint", "una mitja marató"], "e": "La marató (42,195 km). La mitja marató té 21 km."},
      {"q": "El lloc on acaba una cursa és...", "o": ["la meta", "l'eixida", "el podi"], "e": "La meta. La cursa comença a l'eixida."},
      {"q": "Una cursa en què els corredors d'un equip es passen el testimoni és...", "o": ["una cursa de relleus", "una marató", "una contrarellotge"], "e": "Relleus: cada atleta corre un tram."},
      {"q": "En una volta ciclista, cada una de les curses d'un dia és...", "o": ["una etapa", "una pròrroga", "un set"], "e": "Una etapa. El líder porta el mallot groc (o el de líder)."},
      {"q": "La plataforma on pugen els tres primers classificats és...", "o": ["el podi", "la graderia", "la banqueta"], "e": "El podi: medalla d'or, de plata i de bronze."},
      {"q": "La millor marca de tots els temps en una prova és...", "o": ["el rècord", "l'empat", "el resultat"], "e": "Batre (o superar) un rècord."},
      {"q": "El partit que decidix qui guanya el campionat és...", "o": ["la final", "la semifinal", "els quarts de final"], "e": "La final. Abans: quarts de final i semifinals."},
      {"q": "L'equip que acaba segon en un campionat és...", "o": ["el subcampió", "el campió", "el descendit"], "e": "Subcampió. Baixar de categoria és descendir."},
      {"q": "Quan un club contracta un jugador nou, diem que l'ha...", "o": ["fitxat", "expulsat", "eliminat"], "e": "Fitxar: un fitxatge."},
      {"q": "L'organització que regula un esport en un territori és...", "o": ["la federació", "l'afició", "la penya"], "e": "La federació (de pilota, de futbol...). Una penya és un grup d'aficionats."},
      {"q": "Quan un equip perd un partit i ja no pot continuar en la competició, queda...", "o": ["eliminat", "classificat", "empatat"], "e": "Eliminat. Classificar-se és passar a la ronda següent."},
      {"q": "Un esport que es practica amb un company contra una altra parella, amb pales, en una pista tancada amb vidres, és...", "o": ["el pàdel", "el frontó", "el bàdminton"], "e": "El pàdel."},
      {"q": "Fer exercici per a preparar-se per a una competició és...", "o": ["entrenar-se", "escalfar la cadira", "retirar-se"], "e": "Entrenar(-se): l'entrenament, l'entrenador."},
      {"q": "Un joc d'estratègia en un tauler de 64 caselles, amb rei, reina, torres, alfils, cavalls i peons, és...", "o": ["els escacs", "les dames", "el parxís"], "e": "Els escacs. L'objectiu és fer escac i mat al rei."},
      {"q": "Un joc de taula amb un dau i fitxes de quatre colors és...", "o": ["el parxís", "els escacs", "el dòmino"], "e": "El parxís: tirar el dau i menjar fitxes."},
      {"q": "Un joc amb fitxes rectangulars marcades amb punts és...", "o": ["el dòmino", "el parxís", "les dames"], "e": "El dòmino."},
      {"q": "Quins són els quatre pals de la baralla espanyola?", "o": ["oros, copes, espases i bastos", "cors, piques, diamants i trèvols", "reis, cavalls, sotes i asos"], "e": "Oros, copes, espases i bastos. La baralla francesa té cors, piques, diamants i trèvols."},
      {"q": "Repartir les cartes entre els jugadors és...", "o": ["donar (o repartir) les cartes", "barallar les cartes", "tallar"], "e": "Repartir o donar. Barallar (o remenar) les cartes és mesclar-les."},
      {"q": "Un joc en què has de muntar una imatge amb moltes peces xicotetes és...", "o": ["un trencaclosques", "una endevinalla", "un embarbussament"], "e": "Un trencaclosques (o puzle)."},
      {"q": "Una pregunta enginyosa que has d'endevinar és...", "o": ["una endevinalla", "un trencaclosques", "un refrany"], "e": "Una endevinalla."},
      {"q": "Un joc electrònic que es juga en una consola o en l'ordinador és...", "o": ["un videojoc", "un joc de taula", "un trencaclosques"], "e": "Un videojoc. Jugar en línia amb altres persones."},
      {"q": "«Fer trampes» en un joc vol dir...", "o": ["no respectar les regles per a guanyar", "perdre a propòsit", "jugar molt bé"], "e": "Fer trampes: qui en fa és un trampós."},
      {"q": "Una persona que sap perdre sense enfadar-se té...", "o": ["esportivitat (o joc net)", "mal perdre", "molt de morro"], "e": "Esportivitat, joc net. Qui s'enfada quan perd té mal perdre."},
      {"q": "Les substàncies prohibides que alguns esportistes prenen per a rendir més són...", "o": ["el dopatge", "les vitamines", "l'entrenament"], "e": "El dopatge: els controls antidopatge."},
      {"q": "Quina d'estes paraules NO és un esport de raqueta?", "o": ["l'handbol", "el tennis", "el bàdminton"], "e": "L'handbol es juga amb les mans i una pilota."},
      {"q": "Quina d'estes paraules NO és un esport d'aigua?", "o": ["l'esgrima", "el waterpolo", "el piragüisme"], "e": "L'esgrima és un esport de combat amb espasa."},
      {"q": "Escriu el verb: ficar la pilota a la cistella.", "a": ["encistellar"], "e": "Encistellar."},
      {"q": "Escriu la paraula: lloc on acaba una cursa.", "a": ["meta", "la meta"], "e": "La meta."},
      {"q": "Escriu el joc de taula amb rei, reina, torres i peons.", "a": ["escacs", "els escacs"], "e": "Els escacs."},
      {"q": "Escriu la paraula: jugador que para els xuts a la porteria.", "a": ["porter", "el porter", "portera", "la portera"], "e": "El porter o la portera."}
    ]
  },
  {
    "id": "5ca81c57-fb9e-4e6b-b74a-2b62312e705d", "type": "b1_vocab_actualitat", "sort_order": 16,
    "title": "Els esdeveniments actuals", "name": "Mitjans de comunicació, política, societat i successos",
    "content": "El lèxic per a entendre i comentar les notícies: els mitjans, la política, la societat, el medi ambient i els successos (Vocabulari usual).", "icon": "📰", "color": "#E1BEE7",
    "exercises": [
      {"q": "El títol d'una notícia, escrit amb lletra gran, és...", "o": ["el titular", "el peu de foto", "l'editorial"], "e": "El titular. La portada és la primera pàgina del diari."},
      {"q": "Un article on el diari expressa la seua opinió oficial és...", "o": ["l'editorial", "la notícia", "la cartellera"], "e": "L'editorial. Els articles d'opinió els signen col·laboradors."},
      {"q": "Un text periodístic llarg, amb entrevistes i fotos, sobre un tema concret és...", "o": ["un reportatge", "un titular", "una esquela"], "e": "Un reportatge."},
      {"q": "El periodista que viu en un altre país i n'envia les notícies és...", "o": ["el corresponsal", "el locutor", "el redactor en cap"], "e": "El corresponsal."},
      {"q": "Una reunió en què una persona important informa els periodistes és...", "o": ["una roda de premsa", "una tertúlia", "una manifestació"], "e": "Una roda de premsa (o conferència de premsa)."},
      {"q": "El programa de televisió o de ràdio que dona les notícies del dia és...", "o": ["el noticiari (o les notícies)", "el concurs", "la sèrie"], "e": "El noticiari (o informatiu)."},
      {"q": "Un programa on diverses persones debaten sobre l'actualitat és...", "o": ["una tertúlia (o un debat)", "un documental", "un anunci"], "e": "Una tertúlia o un debat."},
      {"q": "Una informació falsa que es difon com si fora certa és...", "o": ["una notícia falsa", "una exclusiva", "un rumor confirmat"], "e": "Una notícia falsa. Cal contrastar la font."},
      {"q": "Dir públicament que una informació no és certa és...", "o": ["desmentir-la", "confirmar-la", "publicar-la"], "e": "Desmentir. El desmentiment."},
      {"q": "Quan un contingut es compartix moltíssim en les xarxes en poc de temps, diem que s'ha fet...", "o": ["viral", "privat", "obsolet"], "e": "Viral."},
      {"q": "La persona o el document d'on trau la informació un periodista és...", "o": ["la font", "el titular", "la portada"], "e": "La font (fiable o poc fiable)."},
      {"q": "El dia que els ciutadans trien els seus representants hi ha...", "o": ["eleccions", "vaga", "una roda de premsa"], "e": "Eleccions: votar, el vot, l'urna, la papereta."},
      {"q": "El període en què els partits demanen el vot és...", "o": ["la campanya electoral", "la legislatura", "la jornada de reflexió"], "e": "La campanya electoral. El dia abans de votar és la jornada de reflexió."},
      {"q": "Els partits que no governen formen...", "o": ["l'oposició", "el govern", "la majoria absoluta"], "e": "L'oposició."},
      {"q": "El parlament de la Comunitat Valenciana són...", "o": ["les Corts Valencianes", "el Congrés", "el Senat"], "e": "Les Corts Valencianes. El govern és el Consell, presidit pel president de la Generalitat."},
      {"q": "Quan el parlament vota a favor d'una llei, l'...", "o": ["aprova", "deroga", "desmentix"], "e": "Aprovar una llei. Derogar és anul·lar-la."},
      {"q": "Un grup de gent que camina pel carrer per a protestar és...", "o": ["una manifestació", "una vaga", "un míting"], "e": "Una manifestació (manifestants). La vaga és deixar de treballar per protesta."},
      {"q": "L'augment general dels preus és...", "o": ["la inflació", "la deflació", "la rebaixa"], "e": "La inflació (o la pujada dels preus)."},
      {"q": "Una situació econòmica greu, amb molt d'atur i poca activitat, és...", "o": ["una crisi", "una bonança", "un superàvit"], "e": "Una crisi (econòmica)."},
      {"q": "Una persona que fuig del seu país per una guerra o una persecució és...", "o": ["un refugiat", "un turista", "un emigrant per vacances"], "e": "Un refugiat (demanar asil)."},
      {"q": "L'augment de la temperatura del planeta per culpa de l'activitat humana és...", "o": ["el canvi climàtic (o escalfament global)", "la gota freda", "la tardor"], "e": "El canvi climàtic."},
      {"q": "Un foc molt gran en una muntanya o un bosc és...", "o": ["un incendi forestal", "una foguera", "una barbacoa"], "e": "Un incendi forestal. Els bombers forestals l'apaguen."},
      {"q": "Un moviment fort i sobtat de la terra és...", "o": ["un terratrémol", "una riuada", "un tsunami"], "e": "Un terratrémol."},
      {"q": "Les energies que no s'esgoten, com la solar i l'eòlica, són...", "o": ["renovables", "fòssils", "nuclears"], "e": "Energies renovables: plaques solars, molins de vent (aerogeneradors)."},
      {"q": "La secció del diari amb robatoris, accidents i crims és...", "o": ["successos", "cultura", "economia"], "e": "La secció de successos."},
      {"q": "Prendre una cosa d'amagat, sense violència, és...", "o": ["furtar (un furt)", "atracar", "segrestar"], "e": "Furtar: un furt. Robar amb violència o forçant: un robatori. Atracar: amb amenaces."},
      {"q": "Quan la policia agafa una persona sospitosa, la...", "o": ["detén", "absol", "jutja"], "e": "Detindre: el detingut, la detenció."},
      {"q": "La persona que ha vist un fet i ho conta davant del jutge és...", "o": ["el testimoni", "l'acusat", "l'advocat"], "e": "El testimoni (declarar com a testimoni)."},
      {"q": "La decisió final d'un jutge en un judici és...", "o": ["la sentència", "la denúncia", "l'acusació"], "e": "La sentència: condemnar o absoldre."},
      {"q": "Quan el jutge decidix que l'acusat no és culpable, l'...", "o": ["absol", "condemna", "detén"], "e": "Absoldre: l'acusat queda absolt."},
      {"q": "«Segons fonts del Govern, l'acord es firmarà demà.» La frase...", "o": ["atribuïx la informació a una font", "és una opinió del periodista", "és un anunci publicitari"], "e": "Segons..., d'acord amb..., fonts de...: atribuir la informació."},
      {"q": "Quina d'estes expressions s'usa per a donar l'opinió sobre una notícia?", "o": ["Al meu parer, és una mesura encertada.", "Segons el diari, hi ha hagut tres ferits.", "Ahir va ploure a Castelló."], "e": "Al meu parer, des del meu punt de vista, crec que... per a opinar."},
      {"q": "Una informació important que un mitjà publica abans que cap altre és...", "o": ["una exclusiva", "un desmentiment", "una esquela"], "e": "Una exclusiva."},
      {"q": "L'avís breu d'una notícia molt important que acaba de passar és...", "o": ["l'última hora", "el titular de dilluns", "l'editorial"], "e": "Notícia d'última hora."},
      {"q": "El periodista que presenta el programa de notícies és...", "o": ["el presentador", "el corresponsal", "el fotògraf"], "e": "El presentador o la presentadora."},
      {"q": "La persona que governa la Comunitat Valenciana és...", "o": ["el president de la Generalitat", "l'alcalde de València", "el president de la Diputació"], "e": "El president (o presidenta) de la Generalitat."},
      {"q": "Les persones que governen una conselleria de la Generalitat són...", "o": ["els consellers", "els regidors", "els diputats provincials"], "e": "Els consellers o conselleres (d'Educació, de Sanitat...)."},
      {"q": "Quan un partit té més de la meitat dels diputats, té...", "o": ["la majoria absoluta", "la minoria", "l'oposició"], "e": "La majoria absoluta. Si no la té, ha de pactar."},
      {"q": "Arribar a un acord entre diversos partits és...", "o": ["pactar", "dimitir", "votar en blanc"], "e": "Pactar: un pacte, una coalició."},
      {"q": "La prova per a saber què votarà la gent abans de les eleccions és...", "o": ["l'enquesta", "l'escrutini", "el míting"], "e": "L'enquesta (o sondeig). L'escrutini és el recompte dels vots."},
      {"q": "Una persona que ajuda sense cobrar en una catàstrofe és...", "o": ["un voluntari", "un funcionari", "un detingut"], "e": "Un voluntari (el voluntariat)."},
      {"q": "Escriu la paraula: títol d'una notícia.", "a": ["titular", "el titular"], "e": "El titular."},
      {"q": "Escriu el verb: dir que una notícia és falsa.", "a": ["desmentir"], "e": "Desmentir."},
      {"q": "Escriu la paraula: dia en què els ciutadans voten.", "a": ["eleccions", "les eleccions", "jornada electoral"], "e": "Les eleccions (la jornada electoral)."},
      {"q": "Escriu la paraula: moviment sobtat de la terra.", "a": ["terratrémol", "un terratrémol", "sisme"], "e": "El terratrémol (o sisme)."}
    ]
  },
  {
    "id": "7ae5ee2e-54b6-4541-b002-47670d46983a", "type": "b1_vocab_arts", "sort_order": 17,
    "title": "La música, el cinema i el teatre", "name": "Música, cinema, teatre, literatura i art",
    "content": "El lèxic dels temes culturals: la música i els instruments, el cinema, el teatre, la literatura i les arts plàstiques (Vocabulari usual).", "icon": "🎬", "color": "#F48FB1",
    "exercises": [
      {"q": "Una persona que escriu i canta les seues pròpies cançons és...", "o": ["un cantautor", "un director d'orquestra", "un apuntador"], "e": "Un cantautor o una cantautora."},
      {"q": "Les paraules d'una cançó són...", "o": ["la lletra", "la melodia", "el ritme"], "e": "La lletra. La melodia és la música i el ritme, el compàs."},
      {"q": "La sèrie de concerts que fa un grup en diferents ciutats és...", "o": ["una gira", "un assaig", "un festival"], "e": "Una gira (anar de gira)."},
      {"q": "Practicar una obra o una cançó abans de l'actuació és fer...", "o": ["un assaig", "una estrena", "una gira"], "e": "Un assaig (assajar)."},
      {"q": "Quan el públic demana que el grup toque una cançó més al final, el grup fa...", "o": ["un bis", "un entreacte", "un assaig"], "e": "Fer un bis."},
      {"q": "Un grup gran de músics que toquen instruments de corda, vent i percussió és...", "o": ["una orquestra", "un trio", "un cor"], "e": "Una orquestra, dirigida pel director amb la batuta. Un cor és un grup de cantants."},
      {"q": "El músic que toca tot sol o que destaca en una obra és...", "o": ["el solista", "el corista", "el tècnic de so"], "e": "El solista."},
      {"q": "Quin d'estos instruments és de corda?", "o": ["el violí", "la trompeta", "el tabal"], "e": "Corda: violí, guitarra, violoncel, contrabaix. Vent: trompeta, flauta, clarinet. Percussió: tabal, bateria."},
      {"q": "Quin d'estos instruments és de vent?", "o": ["el clarinet", "la bateria", "el piano"], "e": "El clarinet, la flauta, el saxòfon, la trompeta, la tuba, la dolçaina..."},
      {"q": "Quin d'estos instruments és de percussió?", "o": ["la bateria", "el violoncel", "el saxòfon"], "e": "La bateria, el tabal, el bombo, els plats, el xilòfon."},
      {"q": "Un concert en què la música sona en el moment, no gravada, és un concert...", "o": ["en directe", "en diferit", "en playback"], "e": "En directe."},
      {"q": "La música d'una pel·lícula és...", "o": ["la banda sonora", "el guió", "el doblatge"], "e": "La banda sonora."},
      {"q": "El text amb els diàlegs i les escenes d'una pel·lícula és...", "o": ["el guió", "la sinopsi", "el tràiler"], "e": "El guió, escrit pel guionista."},
      {"q": "Un resum breu de l'argument d'una pel·lícula és...", "o": ["la sinopsi", "el guió", "la crítica"], "e": "La sinopsi."},
      {"q": "Un vídeo curt amb escenes d'una pel·lícula per a anunciar-la és...", "o": ["el tràiler (o avançament)", "el càsting", "el rodatge"], "e": "El tràiler."},
      {"q": "Filmar les escenes d'una pel·lícula és...", "o": ["rodar", "estrenar", "doblar"], "e": "Rodar: el rodatge."},
      {"q": "El conjunt d'actors i actrius d'una pel·lícula és...", "o": ["el repartiment", "el públic", "l'equip tècnic"], "e": "El repartiment. L'actor principal és el protagonista."},
      {"q": "Una pel·lícula curta, de menys de mitja hora, és...", "o": ["un curtmetratge", "un llargmetratge", "una sèrie"], "e": "Un curtmetratge. Una pel·lícula llarga: un llargmetratge."},
      {"q": "Una pel·lícula que mostra fets reals, sense actors, és...", "o": ["un documental", "una comèdia", "un musical"], "e": "Un documental."},
      {"q": "Una pel·lícula que té molt d'èxit i guanya molts diners és...", "o": ["un èxit de taquilla", "un fracàs", "una estrena privada"], "e": "Un èxit de taquilla."},
      {"q": "Posar les veus en una altra llengua a una pel·lícula és...", "o": ["doblar-la", "subtitular-la", "rodar-la"], "e": "Doblar: el doblatge."},
      {"q": "La cortina gran que tapa l'escenari d'un teatre és...", "o": ["el teló", "el decorat", "la platea"], "e": "El teló: s'alça el teló i comença l'obra."},
      {"q": "Els objectes i els panells que creen l'ambient de l'escena són...", "o": ["el decorat (o l'escenografia)", "el vestuari", "el repartiment"], "e": "El decorat. El vestuari és la roba dels actors."},
      {"q": "La persona que escriu obres de teatre és...", "o": ["un dramaturg", "un apuntador", "un tramoista"], "e": "Un dramaturg (o autor teatral)."},
      {"q": "Una obra de teatre on parla un sol actor és...", "o": ["un monòleg", "un diàleg", "un musical"], "e": "Un monòleg."},
      {"q": "Una obra de teatre amb un final trist, en què el protagonista patix, és...", "o": ["una tragèdia", "una comèdia", "una farsa"], "e": "Una tragèdia. La comèdia fa riure."},
      {"q": "Uns ninots que es mouen amb fils o amb la mà en un espectacle infantil són...", "o": ["els titelles", "els ninots de falla", "els figurants"], "e": "Els titelles (o putxinel·lis)."},
      {"q": "Quan el públic aplaudix molt fort i dret al final, li fa...", "o": ["una ovació", "un xiulet", "un bis"], "e": "Una ovació (posar-se dret per a aplaudir)."},
      {"q": "Una obra literària llarga, en prosa, que conta una història és...", "o": ["una novel·la", "un poema", "una obra de teatre"], "e": "Una novel·la. Un conte és més curt."},
      {"q": "Cada una de les línies d'un poema és...", "o": ["un vers", "un capítol", "un paràgraf"], "e": "Un vers. Un conjunt de versos és una estrofa."},
      {"q": "Cada una de les parts en què es dividix una novel·la és...", "o": ["un capítol", "un vers", "un acte"], "e": "Un capítol. Les obres de teatre es dividixen en actes."},
      {"q": "L'empresa que publica llibres és...", "o": ["una editorial", "una llibreria", "una biblioteca"], "e": "Una editorial. La llibreria els ven i la biblioteca els presta."},
      {"q": "El conjunt de fets que passen en una novel·la o pel·lícula és...", "o": ["la trama (o l'argument)", "el pròleg", "l'índex"], "e": "La trama o l'argument."},
      {"q": "Un quadre que representa una persona és...", "o": ["un retrat", "un paisatge", "una natura morta"], "e": "Un retrat. Un autoretrat: el pintor es pinta a si mateix."},
      {"q": "Un quadre que representa fruites, flors o objectes és...", "o": ["una natura morta (o bodegó)", "un retrat", "un mural"], "e": "Una natura morta o un bodegó."},
      {"q": "L'art de fer figures en pedra, fusta o metall és...", "o": ["l'escultura", "la pintura", "la fotografia"], "e": "L'escultura (l'escultor)."},
      {"q": "Quin pintor valencià és famós per les seues escenes de platja plenes de llum?", "o": ["Joaquín Sorolla", "Pablo Picasso", "Salvador Dalí"], "e": "Joaquim (Joaquín) Sorolla, de València."},
      {"q": "«És una pel·lícula que t'enganxa des del principi fins al final.» Com la valora?", "o": ["Molt positivament", "Negativament", "No la valora"], "e": "Enganxar: interessar molt. Altres: és trepidant, emocionant, commovedora."},
      {"q": "«L'obra se'm va fer llarguíssima: no passava res.» Com la valora?", "o": ["Negativament", "Positivament", "No la valora"], "e": "Fer-se llarg, ser avorrit, pesat, lent."},
      {"q": "Escriu la paraula: text amb els diàlegs d'una pel·lícula.", "a": ["guió", "el guió"], "e": "El guió."},
      {"q": "Escriu la paraula: cortina gran del teatre.", "a": ["teló", "el teló"], "e": "El teló."},
      {"q": "Escriu la paraula: música d'una pel·lícula, la banda ___.", "a": ["sonora"], "e": "La banda sonora."},
      {"q": "Escriu la paraula: cada línia d'un poema.", "a": ["vers", "el vers"], "e": "El vers."}
    ]
  },
  {
    "id": "743422cf-9743-4f27-934a-948991958ae7", "type": "b1_vocab_diners", "sort_order": 18,
    "title": "Els diners i els negocis", "name": "El banc, l'estalvi, els impostos i l'empresa",
    "content": "El lèxic dels diners, el banc, les despeses i l'estalvi, els impostos i el món de l'empresa i els negocis (Vocabulari usual).", "icon": "💶", "color": "#C5E1A5",
    "exercises": [
      {"q": "La màquina del carrer per a traure diners amb la targeta és...", "o": ["el caixer automàtic", "el parquímetre", "la caixa registradora"], "e": "El caixer automàtic: traure diners."},
      {"q": "Posar diners en el teu compte bancari és...", "o": ["ingressar", "traure", "deure"], "e": "Ingressar (fer un ingrés). Traure: retirar diners."},
      {"q": "Enviar diners des del teu compte al d'una altra persona és fer...", "o": ["una transferència", "una devolució", "un ingrés en efectiu"], "e": "Una transferència (bancària)."},
      {"q": "El número secret de la targeta és...", "o": ["el PIN", "l'IBAN", "el NIF"], "e": "El PIN (número d'identificació personal)."},
      {"q": "La quantitat que cobra el banc per alguns servicis és...", "o": ["la comissió", "la nòmina", "la propina"], "e": "La comissió (bancària)."},
      {"q": "Els diners que et deixa el banc i que has de tornar amb interessos són...", "o": ["un préstec", "un estalvi", "un regal"], "e": "Un préstec. L'interés és el percentatge que pagues de més."},
      {"q": "Els diners que deus a algú són...", "o": ["un deute", "un estalvi", "un ingrés"], "e": "Un deute (deure diners). Tornar els diners: pagar el deute."},
      {"q": "Guardar diners per al futur és...", "o": ["estalviar", "malgastar", "invertir en borsa sempre"], "e": "Estalviar: els estalvis."},
      {"q": "Gastar diners en coses innecessàries és...", "o": ["malgastar", "estalviar", "ingressar"], "e": "Malgastar (o balafiar)."},
      {"q": "La previsió de quant gastaràs i quant ingressaràs en un temps és...", "o": ["el pressupost", "el rebut", "el balanç final"], "e": "El pressupost (familiar, d'una empresa...)."},
      {"q": "«Este cotxe m'ha costat un ull de la cara.» Vol dir que...", "o": ["ha sigut caríssim", "ha sigut molt barat", "l'ha comprat de segona mà"], "e": "Costar un ull de la cara: ser molt car."},
      {"q": "«A final de mes sempre estic escurat.» Vol dir que...", "o": ["no li queden diners", "té molts estalvis", "treballa molt"], "e": "Estar escurat: no tindre diners. També: anar just de diners."},
      {"q": "L'impost que es paga en comprar quasi qualsevol producte és...", "o": ["l'IVA", "l'IRPF", "l'IBI"], "e": "L'IVA (impost sobre el valor afegit). L'IBI es paga pels immobles."},
      {"q": "El document anual que fas per a declarar els teus ingressos a Hisenda és...", "o": ["la declaració de la renda", "la nòmina", "el contracte"], "e": "La declaració de la renda (l'IRPF)."},
      {"q": "Les monedes xicotetes que et tornen quan pagues amb un bitllet gran són...", "o": ["el canvi (o la solta)", "la propina", "la comissió"], "e": "El canvi o la solta (monedes soltes)."},
      {"q": "Els diners que deixes de més a un cambrer per a agrair el servici són...", "o": ["la propina", "la comissió", "l'IVA"], "e": "La propina."},
      {"q": "Una persona que funda i dirigix la seua pròpia empresa és...", "o": ["un emprenedor (o empresari)", "un assalariat", "un aturat"], "e": "Un emprenedor o un empresari."},
      {"q": "La persona o empresa que ven productes a una altra empresa és...", "o": ["el proveïdor", "el client", "el soci"], "e": "El proveïdor. El client compra."},
      {"q": "La persona que compartix la propietat d'una empresa amb tu és...", "o": ["el soci", "el client", "el proveïdor"], "e": "El soci o la sòcia."},
      {"q": "Els diners que guanya una empresa després de pagar totes les despeses són...", "o": ["els beneficis", "les pèrdues", "els deutes"], "e": "Els beneficis (o guanys). El contrari: les pèrdues."},
      {"q": "Posar diners en un negoci per a guanyar-ne més és...", "o": ["invertir", "estalviar en un calaix", "malgastar"], "e": "Invertir: la inversió, l'inversor."},
      {"q": "Quan una empresa no pot pagar els deutes i ha de tancar, fa...", "o": ["fallida", "beneficis", "rebaixes"], "e": "Fer fallida (o anar a la bancarrota)."},
      {"q": "Una botiga que usa la marca i el model de negoci d'una gran empresa és...", "o": ["una franquícia", "una sucursal bancària", "una cooperativa"], "e": "Una franquícia."},
      {"q": "Una empresa propietat dels seus treballadors o socis, com moltes del camp valencià, és...", "o": ["una cooperativa", "una franquícia", "una multinacional"], "e": "Una cooperativa (agrícola, de consum...)."},
      {"q": "Les empreses que oferixen els mateixos productes que la teua són...", "o": ["la competència", "els proveïdors", "els socis"], "e": "La competència (competir)."},
      {"q": "Vendre productes a altres països és...", "o": ["exportar", "importar", "fabricar"], "e": "Exportar. Comprar-ne d'altres països: importar."},
      {"q": "Els anuncis per a donar a conéixer un producte són...", "o": ["la publicitat", "la factura", "la fallida"], "e": "La publicitat (una campanya publicitària)."},
      {"q": "El lloc on es compren i es venen accions d'empreses és...", "o": ["la borsa", "el mercat municipal", "la llotja de peix"], "e": "La borsa (de valors)."},
      {"q": "Pagar amb el mòbil a un amic de manera instantània és fer...", "o": ["un pagament per mòbil", "un xec", "una hipoteca"], "e": "Pagar amb el mòbil o amb una aplicació bancària."},
      {"q": "Un producte que ja ha sigut usat per una altra persona és de...", "o": ["segona mà", "primera mà", "fàbrica"], "e": "De segona mà."},
      {"q": "Una targeta que et permet pagar ara i tornar els diners més avant és una targeta de...", "o": ["crèdit", "dèbit", "fidelització"], "e": "De crèdit. La de dèbit cobra directament del compte."},
      {"q": "El compte del banc on tens els diners per als pagaments habituals és el compte...", "o": ["corrent", "d'estalvi a termini", "de crèdit"], "e": "El compte corrent. El document amb els moviments és l'extracte."},
      {"q": "Canviar euros per dòlars abans d'un viatge és canviar...", "o": ["moneda (o divises)", "de banc", "el PIN"], "e": "Canviar moneda o divises: el tipus de canvi."},
      {"q": "Pagar a algú per un treball fet o un servici és...", "o": ["remunerar", "estafar", "recaptar"], "e": "Remunerar: la remuneració."},
      {"q": "Enganyar algú per a quedar-se els seus diners és...", "o": ["estafar", "invertir", "estalviar"], "e": "Estafar: una estafa, un estafador."},
      {"q": "«Hem de fer números abans de comprar el cotxe.» Vol dir que...", "o": ["cal calcular si ens ho podem permetre", "cal aprendre matemàtiques", "cal jugar a la loteria"], "e": "Fer números: calcular les despeses i els ingressos."},
      {"q": "«Llançar la casa per la finestra» vol dir...", "o": ["gastar molts diners en una celebració", "fer obres a casa", "vendre la casa"], "e": "Tirar (o llançar) la casa per la finestra: no estalviar en una celebració."},
      {"q": "Comprar productes a l'engròs vol dir comprar-los...", "o": ["en grans quantitats", "d'un en un", "de segona mà"], "e": "A l'engròs (majorista). Al detall: en quantitats xicotetes."},
      {"q": "El document on una empresa detalla el que has comprat i el que has de pagar, amb l'IVA, és...", "o": ["la factura", "el pressupost", "la nòmina"], "e": "La factura (facturar)."},
      {"q": "Escriu el verb: guardar diners per al futur.", "a": ["estalviar"], "e": "Estalviar."},
      {"q": "Escriu la paraula: diners que deus a algú.", "a": ["deute", "un deute", "el deute"], "e": "Un deute."},
      {"q": "Escriu el contrari de «benefici».", "a": ["pèrdua", "pèrdues", "les pèrdues", "la pèrdua"], "e": "La pèrdua (les pèrdues)."},
      {"q": "Escriu el contrari d'«exportar».", "a": ["importar"], "e": "Importar."}
    ]
  },
  {
    "id": "cbe6905c-aba9-4c29-bda5-c29fbf1e241e", "type": "b1_vocab_tecnologia", "sort_order": 19,
    "title": "La tecnologia", "name": "Aparells, internet, xarxes socials i informàtica",
    "content": "Els aparells electrònics i les seues parts, les accions en l'ordinador i el mòbil, internet, el correu electrònic, les xarxes socials i la seguretat digital (Vocabulari usual).", "icon": "💻", "color": "#90CAF9",
    "exercises": [
      {"q": "Un ordinador xicotet que es pot plegar i portar amb tu és...", "o": ["un portàtil", "un ordinador de taula", "un servidor"], "e": "Un (ordinador) portàtil."},
      {"q": "Un dispositiu pla amb pantalla tàctil, més gran que un mòbil, és...", "o": ["una tauleta", "un teclat", "un altaveu"], "e": "Una tauleta (tàctil)."},
      {"q": "La peça amb tecles per a escriure en l'ordinador és...", "o": ["el teclat", "el ratolí", "el monitor"], "e": "El teclat. El ratolí mou el cursor per la pantalla."},
      {"q": "L'aparell que servix per a passar al paper un document de l'ordinador és...", "o": ["la impressora", "l'escàner", "l'altaveu"], "e": "La impressora (imprimir). L'escàner fa el contrari: digitalitza un paper."},
      {"q": "El cable o l'aparell per a carregar la bateria del mòbil és...", "o": ["el carregador", "l'endoll", "l'auricular"], "e": "El carregador. L'endoll és on es connecta a la paret."},
      {"q": "Quan el mòbil es queda sense energia, s'ha quedat sense...", "o": ["bateria", "cobertura", "memòria"], "e": "Sense bateria. Sense cobertura: sense senyal de xarxa."},
      {"q": "Una aplicació xicoteta del mòbil és...", "o": ["una app (o aplicació)", "un cable", "un fitxer"], "e": "Una aplicació (app)."},
      {"q": "Passar un fitxer d'internet al teu dispositiu és...", "o": ["descarregar-lo (o baixar-lo)", "penjar-lo", "esborrar-lo"], "e": "Descarregar o baixar. El contrari: penjar (o pujar) un fitxer a internet."},
      {"q": "Posar un programa en l'ordinador perquè funcione és...", "o": ["instal·lar-lo", "desinstal·lar-lo", "imprimir-lo"], "e": "Instal·lar. Llevar-lo: desinstal·lar."},
      {"q": "Posar al dia un programa o el sistema del mòbil amb la versió nova és...", "o": ["actualitzar-lo", "reiniciar-lo", "formatar-lo"], "e": "Actualitzar: una actualització."},
      {"q": "Guardar un document en l'ordinador és...", "o": ["desar-lo", "esborrar-lo", "retallar-lo"], "e": "Desar (o guardar)."},
      {"q": "Copiar un text i posar-lo en un altre lloc és «copiar i ___».", "o": ["apegar (o enganxar)", "esborrar", "desar"], "e": "Copiar i apegar (o enganxar). Retallar: llevar-lo del lloc original."},
      {"q": "Quan l'ordinador es bloqueja i no respon, diem que s'ha...", "o": ["penjat", "carregat", "descarregat"], "e": "Penjar-se: l'ordinador s'ha penjat. Cal reiniciar-lo."},
      {"q": "Apagar i tornar a encendre un aparell és...", "o": ["reiniciar-lo", "actualitzar-lo", "instal·lar-lo"], "e": "Reiniciar."},
      {"q": "Un conjunt de documents agrupats en un lloc de l'ordinador és...", "o": ["una carpeta", "un enllaç", "un navegador"], "e": "Una carpeta. Cada document és un fitxer (o arxiu)."},
      {"q": "El programa que s'usa per a navegar per internet és...", "o": ["el navegador", "el cercador", "el teclat"], "e": "El navegador. El cercador és la pàgina per a buscar informació."},
      {"q": "El text o el botó en què fas clic per a anar a una altra pàgina web és...", "o": ["un enllaç", "un adjunt", "un perfil"], "e": "Un enllaç."},
      {"q": "El document que envies amb un correu electrònic és...", "o": ["un fitxer adjunt", "una contrasenya", "una signatura"], "e": "Un fitxer adjunt (adjuntar un document)."},
      {"q": "Els correus de publicitat que no has demanat són...", "o": ["el correu brossa", "els adjunts", "els esborranys"], "e": "Correu brossa (o correu no desitjat)."},
      {"q": "Un correu que has començat a escriure però encara no has enviat és...", "o": ["un esborrany", "una resposta", "un reenviament"], "e": "Un esborrany."},
      {"q": "La paraula secreta per a entrar en un compte és...", "o": ["la contrasenya", "el nom d'usuari", "l'adreça"], "e": "La contrasenya. Ha de ser segura i no compartir-la."},
      {"q": "Entrar en el teu compte amb el nom d'usuari i la contrasenya és...", "o": ["iniciar la sessió", "tancar la sessió", "donar-se de baixa"], "e": "Iniciar la sessió. En acabar, tancar la sessió."},
      {"q": "La connexió a internet sense fils és...", "o": ["el wifi", "el cable de xarxa", "el bluetooth"], "e": "El wifi (la xarxa sense fils)."},
      {"q": "Guardar els fitxers en servidors d'internet per a accedir-hi des de qualsevol lloc és guardar-los...", "o": ["al núvol", "al calaix", "a la paperera"], "e": "Al núvol."},
      {"q": "Una còpia dels teus fitxers per si es perden és...", "o": ["una còpia de seguretat", "un esborrany", "una captura de pantalla"], "e": "Una còpia de seguretat."},
      {"q": "Una imatge del que es veu en la pantalla en un moment és...", "o": ["una captura de pantalla", "un fons de pantalla", "un perfil"], "e": "Una captura de pantalla."},
      {"q": "Un programa que fa malbé l'ordinador o roba dades és...", "o": ["un virus (o programari maliciós)", "un antivirus", "un navegador"], "e": "Un virus. L'antivirus el detecta i l'elimina."},
      {"q": "Una persona que entra sense permís en sistemes informàtics és...", "o": ["un pirata informàtic", "un programador", "un influenciador"], "e": "Un pirata informàtic."},
      {"q": "Les persones que veuen les publicacions d'un perfil en les xarxes socials són...", "o": ["els seguidors", "els proveïdors", "els usuaris de la biblioteca"], "e": "Els seguidors (seguir un perfil)."},
      {"q": "Posar una foto o un comentari en una xarxa social és...", "o": ["publicar-lo (o penjar-lo)", "esborrar-lo", "descarregar-lo"], "e": "Publicar o penjar."},
      {"q": "Una trucada en què es veu la cara de l'altra persona és...", "o": ["una videotrucada", "un missatge de veu", "un correu"], "e": "Una videotrucada."},
      {"q": "Un programa d'ordinador que imita la manera de pensar humana, per exemple per a respondre preguntes, és...", "o": ["la intel·ligència artificial", "el processador de textos", "el full de càlcul"], "e": "La intel·ligència artificial (IA)."},
      {"q": "El programa per a fer càlculs i taules amb files i columnes és...", "o": ["el full de càlcul", "el processador de textos", "el navegador"], "e": "El full de càlcul. El processador de textos servix per a escriure documents."},
      {"q": "«Abans de tirar el mòbil vell, porta'l a un punt de reciclatge.» És...", "o": ["un consell sobre l'ús responsable de la tecnologia", "una instrucció d'instal·lació", "una queixa"], "e": "Els aparells electrònics vells van al punt net (o deixalleria)."},
      {"q": "La part del dispositiu que guarda els fitxers és...", "o": ["la memòria (o disc dur)", "la pantalla", "el teclat"], "e": "La memòria o el disc dur. Una memòria USB és portàtil."},
      {"q": "L'aparell xicotet que es posa a les orelles per a escoltar música és...", "o": ["els auriculars", "els altaveus", "el micròfon"], "e": "Els auriculars (amb fil o sense fils)."},
      {"q": "Trobar la manera d'eixir d'un problema informàtic és...", "o": ["solucionar-lo", "formatar el ratolí", "penjar-lo"], "e": "Solucionar o resoldre un problema."},
      {"q": "Escriu el verb: posar un programa en l'ordinador.", "a": ["instal·lar"], "e": "Instal·lar."},
      {"q": "Escriu la paraula: paraula secreta per a entrar en un compte.", "a": ["contrasenya", "la contrasenya"], "e": "La contrasenya."},
      {"q": "Escriu el contrari de «descarregar» un fitxer.", "a": ["penjar", "pujar", "carregar"], "e": "Penjar o pujar (un fitxer a internet)."},
      {"q": "Escriu el nom de la peça que mou el cursor de l'ordinador.", "a": ["ratolí", "el ratolí"], "e": "El ratolí."}
    ]
  },
  {
    "id": "37563e69-ff08-4822-a5c1-3de1a9c57c37", "type": "b1_vocab_estats_objectes", "sort_order": 20,
    "title": "Estats d'ànim i descripcions", "name": "Sentiments, emocions i com són els objectes",
    "content": "Lèxic per a descriure estats d'ànim i sentiments, expressions fetes relacionades i adjectius per a descriure objectes: forma, mida, pes, textura, material i estat (Vocabulari usual).", "icon": "😊", "color": "#FFF59D",
    "exercises": [
      {"q": "Una persona que ha perdut les ganes de fer coses i està trista des de fa temps està...", "o": ["desanimada", "eufòrica", "il·lusionada"], "e": "Desanimat (o deprimit, si és greu). El contrari: animat."},
      {"q": "Quan esperes amb alegria que passe una cosa, estàs...", "o": ["il·lusionat", "decebut", "avorrit"], "e": "Il·lusionat: tindre il·lusió per alguna cosa."},
      {"q": "Quan una cosa no ha sigut tan bona com esperaves, estàs...", "o": ["decebut", "il·lusionat", "orgullós"], "e": "Decebut: una decepció."},
      {"q": "Quan tens molta faena i poc temps, i et sents pressionat, estàs...", "o": ["estressat", "relaxat", "avorrit"], "e": "Estressat: l'estrés."},
      {"q": "Quan tens una por i una inquietud molt fortes, estàs...", "o": ["angoixat", "content", "orgullós"], "e": "Angoixat: l'angoixa."},
      {"q": "Quan sents vergonya, estàs...", "o": ["avergonyit", "agraït", "sorprés"], "e": "Avergonyit (tindre vergonya). Posar-se roig de vergonya."},
      {"q": "Quan algú t'ha ajudat i li vols donar les gràcies, estàs...", "o": ["agraït", "gelós", "furiós"], "e": "Agraït: l'agraïment."},
      {"q": "Quan estàs satisfet del que has fet tu o algú pròxim, estàs...", "o": ["orgullós", "avergonyit", "decebut"], "e": "Orgullós: sentir orgull."},
      {"q": "Quan trobes a faltar una persona o un lloc, la...", "o": ["enyores", "oblides", "odies"], "e": "Enyorar: l'enyorança. Trobar a faltar."},
      {"q": "Quan algú fa una cosa que no esperaves gens, et quedes...", "o": ["sorprés", "indiferent", "relaxat"], "e": "Sorprés (o sorpresa): la sorpresa."},
      {"q": "Quan estàs moltíssim enfadat, estàs...", "o": ["furiós", "tranquil", "tímid"], "e": "Furiós: estar fet una fúria."},
      {"q": "Quan no t'importa gens una cosa, et deixa...", "o": ["indiferent", "il·lusionat", "angoixat"], "e": "Indiferent: la indiferència."},
      {"q": "«Estic fet pols»: com està?", "o": ["Molt cansat", "Molt content", "Molt brut"], "e": "Estar fet pols: estar esgotat."},
      {"q": "«Està com un gínjol»: com està?", "o": ["Molt content i ple d'energia", "Malalt", "Enfadat"], "e": "Estar com un gínjol: estar molt bé, alegre i animat."},
      {"q": "«Hui està de mala lluna»: com està?", "o": ["De mal humor", "Molt alegre", "Molt cansat"], "e": "Estar de mala lluna (o de mal humor)."},
      {"q": "«Té els nervis a flor de pell»: com està?", "o": ["Molt nerviós", "Molt tranquil", "Molt trist"], "e": "Tindre els nervis a flor de pell: estar molt nerviós."},
      {"q": "«Va perdre els estreps i va començar a cridar»: què li va passar?", "o": ["Va perdre el control i s'enfadà molt", "Va caure del cavall", "Es va adormir"], "e": "Perdre els estreps (o els nervis): enfadar-se molt."},
      {"q": "«Sempre està en els núvols»: com és?", "o": ["Distret", "Molt atent", "Molt alt"], "e": "Estar en els núvols: estar distret."},
      {"q": "«Botava d'alegria quan li van donar la notícia»: com estava?", "o": ["Molt content", "Molt trist", "Molt cansat"], "e": "Botar d'alegria: estar molt content."},
      {"q": "«Té el cor en un puny»: com està?", "o": ["Molt preocupat i angoixat", "Molt enamorat", "Molt tranquil"], "e": "Tindre el cor en un puny: estar angoixat."},
      {"q": "Un objecte en forma de cercle és...", "o": ["rodó", "quadrat", "triangular"], "e": "Rodó. Altres formes: quadrat, rectangular, triangular, ovalat."},
      {"q": "Un objecte amb la punta fina, que pot fer mal, és...", "o": ["punxegut", "rom", "pla"], "e": "Punxegut. Rom: sense punta o sense tall."},
      {"q": "Un objecte que pesa molt és...", "o": ["pesat", "lleuger", "buit"], "e": "Pesat. El contrari: lleuger."},
      {"q": "Una superfície que fa mal al tacte perquè no és llisa és...", "o": ["aspra (o rugosa)", "suau", "llisa"], "e": "Aspre o rugós. El contrari: suau, llis."},
      {"q": "Un objecte que es trenca amb facilitat és...", "o": ["fràgil", "resistent", "elàstic"], "e": "Fràgil (com el vidre). Resistent: que no es trenca fàcilment."},
      {"q": "Un objecte que es pot doblegar sense trencar-se és...", "o": ["flexible", "rígid", "fràgil"], "e": "Flexible. El contrari: rígid."},
      {"q": "Un coixí o un matalàs que s'afona quan el prems és...", "o": ["tou", "dur", "rígid"], "e": "Tou. El contrari: dur."},
      {"q": "Un objecte de ferro que s'ha posat de color marró amb la humitat està...", "o": ["rovellat", "esquerdat", "abonyegat"], "e": "Rovellat: el rovell. Esquerdat: amb una esquerda. Abonyegat: amb bonys."},
      {"q": "Un got de vidre que té una línia trencada però no s'ha partit està...", "o": ["esquerdat", "rovellat", "descolorit"], "e": "Esquerdat: té una esquerda."},
      {"q": "Un objecte molt usat, que ja no està com nou, està...", "o": ["gastat", "a estrenar", "intacte"], "e": "Gastat (o desgastat)."},
      {"q": "Un material que no deixa passar l'aigua és...", "o": ["impermeable", "transparent", "absorbent"], "e": "Impermeable (com un xubasquer o una jaqueta de pluja)."},
      {"q": "Un material que deixa veure el que hi ha a l'altra banda és...", "o": ["transparent", "opac", "mat"], "e": "Transparent. Opac: no deixa passar la llum."},
      {"q": "Una cosa molt xicoteta és...", "o": ["diminuta", "enorme", "gegant"], "e": "Diminut (o menut, minúscul). El contrari: enorme, gegant."},
      {"q": "Un objecte de terra cuita, com els plats tradicionals de Manises, és de...", "o": ["ceràmica", "acer", "plàstic"], "e": "De ceràmica (o de fang). Manises i l'Alcora són famoses per la ceràmica."},
      {"q": "Per a descriure la finalitat d'un objecte diem...", "o": ["«Servix per a obrir llaunes.»", "«És de color blau.»", "«Pesa dos quilos.»"], "e": "Servix per a..., s'usa per a...: indica la funció."},
      {"q": "Escriu el contrari de «pesat».", "a": ["lleuger"], "e": "Lleuger."},
      {"q": "Escriu el contrari de «dur» (un matalàs).", "a": ["tou"], "e": "Tou."},
      {"q": "Escriu el verb: trobar a faltar una persona o un lloc.", "a": ["enyorar"], "e": "Enyorar."},
      {"q": "Escriu l'adjectiu: que es trenca amb facilitat.", "a": ["fràgil"], "e": "Fràgil."}
    ]
  }
]$data$::jsonb) AS t(
  id uuid, type text, sort_order smallint, title text, name text,
  content text, icon text, color text, exercises jsonb
);

INSERT INTO public.resources (id, name, type, category, content, difficulty, xp_earned, sort_order, metadata)
SELECT id, name, type, 'lexic_semantica', content, 'intermedi', 15, sort_order,
       jsonb_build_object('icon', icon, 'color', color, 'section_name', title)
FROM practice_catalog
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  type = EXCLUDED.type,
  category = EXCLUDED.category,
  content = EXCLUDED.content,
  difficulty = EXCLUDED.difficulty,
  xp_earned = EXCLUDED.xp_earned,
  sort_order = EXCLUDED.sort_order,
  metadata = EXCLUDED.metadata;

DELETE FROM public.practice_exercises e
USING practice_catalog c
WHERE e.resource_id = c.id AND e.level = 'B1';

INSERT INTO public.practice_exercises (resource_id, level, position, kind, prompt, options, answers, explanation)
SELECT c.id, 'B1', x.ord,
       CASE WHEN x.e ? 'a' THEN 'fill' ELSE 'choice' END,
       x.e->>'q',
       CASE WHEN x.e ? 'o' THEN ARRAY(SELECT jsonb_array_elements_text(x.e->'o')) END,
       CASE WHEN x.e ? 'a' THEN ARRAY(SELECT jsonb_array_elements_text(x.e->'a')) ELSE ARRAY[x.e->'o'->>0] END,
       x.e->>'e'
FROM practice_catalog c
CROSS JOIN LATERAL jsonb_array_elements(c.exercises) WITH ORDINALITY AS x(e, ord);

DROP TABLE practice_catalog;

CREATE TEMP TABLE practice_more AS
SELECT * FROM jsonb_to_recordset($data$[
  {
    "id": "3c2cdca6-70e4-4a53-99af-2db26e50aaea", "offset": 50,
    "exercises": [
      {"q": "Els familiers de la teua parella (sogres, cunyats...) són la família...", "o": ["política", "nombrosa", "monoparental"], "e": "La família política: els parents per matrimoni."},
      {"q": "Els pares dels teus fills casats entre ells (el sogre de ton fill) són els teus...", "o": ["consogres", "cunyats", "padrins"], "e": "Consogre i consogra: els pares de l'altre membre de la parella del teu fill."},
      {"q": "Les persones de la família que van viure fa molts anys, abans que tu, són els...", "o": ["avantpassats", "descendents", "hereus"], "e": "Els avantpassats. Els fills, néts i besnéts són els descendents."},
      {"q": "Una persona que ha perdut el pare i la mare és...", "o": ["orfe", "vidu", "solter"], "e": "Orfe (o òrfena). Vidu: qui ha perdut la parella."},
      {"q": "Fer legalment fill teu un xiquet que no és biològic és...", "o": ["adoptar-lo", "apadrinar-lo", "heretar-lo"], "e": "Adoptar: el fill adoptiu, l'adopció."},
      {"q": "Els béns i els diners que deixa una persona quan es mor són...", "o": ["l'herència", "la hipoteca", "el lloguer"], "e": "L'herència. Qui la rep és l'hereu o l'hereva. El testament diu com es repartix."},
      {"q": "Quan dos pares separats es repartixen el temps amb els fills, tenen la custòdia...", "o": ["compartida", "única", "provisional"], "e": "La custòdia compartida."},
      {"q": "En valencià, tindre una relació amorosa amb algú és...", "o": ["festejar", "conviure", "divorciar-se"], "e": "Festejar: el xicot i la xicota."},
      {"q": "Quan una parella decidix casar-se, diem que s'ha...", "o": ["promés (o compromés)", "separat", "divorciat"], "e": "Prometre's: el promés i la promesa."},
      {"q": "Quan dos persones que s'havien barallat tornen a ser amigues, es...", "o": ["reconcilien", "separen", "barallen"], "e": "Reconciliar-se: fer les paus."},
      {"q": "Una persona amb qui tens molta confiança i que t'entén és...", "o": ["un amic íntim", "un conegut", "un desconegut"], "e": "Un amic íntim (o de l'ànima). Un conegut és algú que coneixes poc."},
      {"q": "«Ens portem molt bé.» Vol dir que...", "o": ["tenim una bona relació", "vivim lluny", "ens veiem poc"], "e": "Portar-se bé (o mal) amb algú: tindre una bona (o mala) relació."}
    ]
  },
  {
    "id": "bb9d81a8-ec10-438f-bdca-ce5933d487eb", "offset": 46,
    "exercises": [
      {"q": "La part de fora d'un edifici, la que dona al carrer, és...", "o": ["la façana", "el replà", "el pati de llums"], "e": "La façana."},
      {"q": "La coberta d'un edifici, sovint plana, on es pot estendre la roba, és...", "o": ["el terrat", "la teulada", "el balcó"], "e": "El terrat (pla). La teulada té teules i és inclinada."},
      {"q": "L'espai de l'escala davant de les portes dels pisos és...", "o": ["el replà", "el rebedor", "el traster"], "e": "El replà."},
      {"q": "L'aparell per a obrir la porta del carrer des de dins de casa és...", "o": ["el porter automàtic (o intèrfon)", "el timbre de la bicicleta", "el pany"], "e": "El porter automàtic o l'intèrfon."},
      {"q": "On deixa el carter les cartes?", "o": ["a la bústia", "al replà", "a la finestra"], "e": "A la bústia."},
      {"q": "Les làmines que es baixen per a no deixar entrar la llum per la finestra són...", "o": ["les persianes", "les cortines de dutxa", "les rajoles"], "e": "Les persianes. Abaixar o alçar la persiana."},
      {"q": "Les peces de ceràmica que cobrixen el terra o les parets de la cuina i del bany són...", "o": ["les rajoles", "les teules", "les bigues"], "e": "Les rajoles (de València, de Manises...)."},
      {"q": "On ix l'aigua a la cuina i al bany?", "o": ["per l'aixeta", "per l'endoll", "per l'interruptor"], "e": "L'aixeta. Obrir o tancar l'aixeta."},
      {"q": "On es connecten els aparells elèctrics a la paret?", "o": ["a l'endoll", "a l'interruptor", "a l'aixeta"], "e": "A l'endoll. L'interruptor encén i apaga el llum."},
      {"q": "L'aparell que escalfa l'aigua de la dutxa és...", "o": ["el termo (o escalfador)", "el congelador", "el microones"], "e": "El termo o l'escalfador (d'aigua)."},
      {"q": "L'aparell que hi ha damunt dels fogons per a traure el fum de la cuina és...", "o": ["la campana extractora", "el forn", "la vitroceràmica"], "e": "La campana extractora."},
      {"q": "El moble amb calaixos per a guardar la roba és...", "o": ["la calaixera", "la prestatgeria", "la tauleta de nit"], "e": "La calaixera. La prestatgeria té prestatges per als llibres."},
      {"q": "El professional que arregla les canonades i les aixetes és...", "o": ["el lampista (o fontaner)", "l'electricista", "el fuster"], "e": "El lampista o fontaner. L'electricista, la llum; el fuster, la fusta."},
      {"q": "El professional que fa obres de construcció, posa rajoles i alça parets és...", "o": ["el paleta (o obrer de la construcció)", "el lampista", "el pintor"], "e": "El paleta."},
      {"q": "Fer obres en un pis per a millorar-lo és...", "o": ["reformar-lo", "llogar-lo", "hipotecar-lo"], "e": "Reformar: una reforma. Un pis reformat."},
      {"q": "Canviar-se de casa és...", "o": ["mudar-se (o fer la mudança)", "empadronar-se", "reformar"], "e": "Mudar-se: la mudança."},
      {"q": "Escriu la paraula: lloc on el carter deixa les cartes.", "a": ["bústia", "la bústia"], "e": "La bústia."},
      {"q": "Escriu la paraula: part de fora d'un edifici.", "a": ["façana", "la façana"], "e": "La façana."}
    ]
  },
  {
    "id": "d2eb464d-1df4-4fcd-9d67-26a8eb56d9f2", "offset": 43,
    "exercises": [
      {"q": "Les proves per a aconseguir una plaça fixa en l'Administració són...", "o": ["les oposicions", "les rebaixes", "les eleccions"], "e": "Les oposicions (opositar). Qui les aprova és funcionari."},
      {"q": "Una persona que treballa per a l'Administració amb una plaça fixa és...", "o": ["funcionària", "autònoma", "becària"], "e": "Funcionari o funcionària."},
      {"q": "Passar a un lloc de treball de més responsabilitat és tindre...", "o": ["un ascens", "un acomiadament", "una baixa"], "e": "Un ascens (ascendir, promocionar)."},
      {"q": "Fer compatible el treball amb la vida familiar és...", "o": ["conciliar", "cotitzar", "dimitir"], "e": "Conciliar la vida laboral i familiar: la conciliació."},
      {"q": "Els dies que pots faltar al treball quan naix un fill són el permís de...", "o": ["maternitat o paternitat (per naixement)", "vacances", "assumptes propis"], "e": "El permís per naixement i cura de menor (maternitat o paternitat)."},
      {"q": "Els diners que paga el treballador i l'empresa a la Seguretat Social per a la futura pensió són les...", "o": ["cotitzacions", "propines", "comissions"], "e": "Cotitzar: les cotitzacions a la Seguretat Social."},
      {"q": "Les pagues de més que alguns treballadors reben a l'estiu i per Nadal són les pagues...", "o": ["extra (o extraordinàries)", "mínimes", "de fiança"], "e": "Les pagues extra."},
      {"q": "Una persona molt treballadora diem que «treballa com...»", "o": ["una formiga", "un gat", "un peix"], "e": "Treballar com una formiga: ser molt feiner."}
    ]
  },
  {
    "id": "45f412d2-e3b7-406e-9e34-1d8dd18f2ddc", "offset": 50,
    "exercises": [
      {"q": "La part de la planta que està davall de terra i n'absorbix l'aigua és...", "o": ["l'arrel", "el tronc", "la fulla"], "e": "L'arrel. El tronc, les branques, les fulles, les flors i els fruits."},
      {"q": "La part de la planta d'on naix una planta nova és...", "o": ["la llavor", "la branca", "l'escorça"], "e": "La llavor. L'escorça és la pell del tronc."},
      {"q": "Un arbre que perd les fulles a la tardor és de fulla...", "o": ["caduca", "perenne", "punxeguda"], "e": "De fulla caduca. El pi i l'alzina són de fulla perenne."},
      {"q": "Quin animal marí intel·ligent, que salta fora de l'aigua, es pot veure davant de la costa valenciana?", "o": ["el dofí", "el tauró blanc", "la balena blava"], "e": "El dofí."},
      {"q": "Quin animal marí té huit braços amb ventoses?", "o": ["el pop", "el calamar", "la sépia"], "e": "El pop té huit potes; el calamar i la sépia, deu."},
      {"q": "Quin animal gelatinós del mar pot picar els banyistes?", "o": ["la medusa", "el cranc", "l'eriçó de mar"], "e": "La medusa. L'eriçó de mar té punxes."},
      {"q": "Quin crustaci camina de costat i té pinces?", "o": ["el cranc", "la gamba", "el musclo"], "e": "El cranc. La gamba i la llagosta també són crustacis."},
      {"q": "Quin mosquit ratllat negre i blanc, que pica de dia, s'ha estés per la costa?", "o": ["el mosquit tigre", "la mosca", "la vespa"], "e": "El mosquit tigre."},
      {"q": "Quin insecte groc i negre pica i no fa mel?", "o": ["la vespa", "l'abella", "la papallona"], "e": "La vespa. L'abella fa mel i viu en un rusc."},
      {"q": "Quin animal xicotet fa teles per a caçar insectes?", "o": ["l'aranya", "la formiga", "l'escarabat"], "e": "L'aranya: la teranyina."},
      {"q": "Un animal que només viu en un lloc del món, com el samaruc, és...", "o": ["endèmic", "invasor", "domèstic"], "e": "Endèmic. Una espècie invasora ve de fora i fa mal a les autòctones."},
      {"q": "Una espècie que pot desaparéixer del tot està en perill d'...", "o": ["extinció", "expansió", "hibernació"], "e": "En perill d'extinció. Una espècie protegida."},
      {"q": "«Fa un sol de justícia.» Vol dir que...", "o": ["fa un sol molt fort i molta calor", "està núvol", "plou poc"], "e": "Un sol de justícia: un sol molt fort."},
      {"q": "«Fa un fred que pela.» Vol dir que...", "o": ["fa moltíssim fred", "fa calor", "fa vent suau"], "e": "Fer un fred que pela: fer molt de fred."},
      {"q": "Quan el cel no té cap núvol, està...", "o": ["serè", "ennuvolat", "tapat"], "e": "Serè (o clar). Ennuvolat: amb núvols."},
      {"q": "Quan hi ha núvols però de tant en tant ix el sol, hi ha...", "o": ["clarianes", "calamarsa", "rosada"], "e": "Clarianes: espais sense núvols."},
      {"q": "Les temperatures més baixes que zero graus són temperatures...", "o": ["sota zero (o sota zero graus)", "màximes", "suaus"], "e": "Sota zero. Fer cinc graus sota zero."},
      {"q": "L'arc de colors que apareix al cel quan plou i fa sol és...", "o": ["l'arc de Sant Martí", "el llampec", "l'aurora"], "e": "L'arc de Sant Martí."},
      {"q": "La informació sobre el temps que farà els pròxims dies és...", "o": ["la previsió meteorològica", "la cartellera", "l'esquela"], "e": "La previsió (meteorològica) o l'oratge."},
      {"q": "Quan el mar està molt mogut, amb ones grans, diem que hi ha mar...", "o": ["brava (o forta marejada)", "en calma", "plana"], "e": "Mar brava (o mar grossa, marejada). Mar en calma: bonança."},
      {"q": "Escriu la paraula: part de la planta que està davall de terra.", "a": ["arrel", "l'arrel"], "e": "L'arrel."},
      {"q": "Escriu el contrari de «ennuvolat».", "a": ["serè", "clar", "assolellat"], "e": "Serè o clar."}
    ]
  }
]$data$::jsonb) AS t(id uuid, "offset" smallint, exercises jsonb);

DELETE FROM public.practice_exercises e
USING practice_more m
WHERE e.resource_id = m.id AND e.level = 'B1' AND e.position > m."offset";

INSERT INTO public.practice_exercises (resource_id, level, position, kind, prompt, options, answers, explanation)
SELECT c.id, 'B1', c."offset" + x.ord,
       CASE WHEN x.e ? 'a' THEN 'fill' ELSE 'choice' END,
       x.e->>'q',
       CASE WHEN x.e ? 'o' THEN ARRAY(SELECT jsonb_array_elements_text(x.e->'o')) END,
       CASE WHEN x.e ? 'a' THEN ARRAY(SELECT jsonb_array_elements_text(x.e->'a')) ELSE ARRAY[x.e->'o'->>0] END,
       x.e->>'e'
FROM practice_more c
CROSS JOIN LATERAL jsonb_array_elements(c.exercises) WITH ORDINALITY AS x(e, ord);

DROP TABLE practice_more;

-- ============================================================
-- Origen: 20261001130000_practice_fonetica_b1.sql
-- ============================================================
-- Fonètica, elocució i ortografia del B1 (Quadern B1 de la JQCV, 3.2.1). Un
-- contingut de la categoria fonetica_ortografia per a cada apartat del temari:
-- elocució i fonètica sintàctica; alfabet i grafies; síl·laba, diftong i hiat;
-- vocals; accentuació, dièresi i guionet; apostrofació i contracció; oclusives
-- i labiodentals; alveolars; palatals; laterals, nasals, ròtiques i h;
-- majúscules i minúscules; i signes de puntuació. Són recursos de nivell
-- intermedi amb exercicis B1. Tornar a aplicar el fitxer no duplica res.

CREATE TEMP TABLE practice_catalog AS
SELECT * FROM jsonb_to_recordset($data$[
  {
    "id": "013139cd-ab6b-45b5-99e7-58104459f974", "type": "b1_fon_elocucio", "sort_order": 1,
    "title": "Elocució i fonètica sintàctica", "name": "Elisions, sons propis, emmudiments, geminacions i entonació",
    "content": "Elisions vocàliques, sons consonàntics propis del valencià, emmudiments consonàntics freqüents, articulació de grups i geminacions i entonació interrogativa i exclamativa (3.2.1).", "icon": "🗣️", "color": "#B2EBF2",
    "exercises": [
      {"q": "En una pronunciació natural de «Quina hora és?», quina vocal no se sol pronunciar?", "o": ["la -a de «quina»", "la o d'«hora»", "la e d'«és»"], "e": "Dues vocals en contacte entre paraules s'unixen: [ki-no-ra-és]. La -a àtona final s'elidix davant d'una altra vocal."},
      {"q": "Com es pronuncia de manera natural «quinze anys»?", "o": ["[kin-zanys]", "[kin-ze-a-nys]", "[kin-zi-anys]"], "e": "La -e àtona final de «quinze» s'elidix davant de la a: [kinzanys]."},
      {"q": "En quina d'estes expressions s'elidix una vocal en la parla?", "o": ["una amiga", "un amic", "tres amics"], "e": "Una_amiga: la -a de «una» s'unix amb la a d'«amiga» [unamiga]. En «un amic» no hi ha dues vocals en contacte."},
      {"q": "Com es pronuncia de manera natural «Me'n vaig a Alacant»?", "o": ["amb una sola a: [aalacant] → [alacant]", "separant clarament [a] i [a-la-cant] amb una pausa", "afegint una consonant entre les dues a"], "e": "Dues vocals iguals en contacte es fonen en una: a_Alacant."},
      {"q": "En «Està a casa», com sona la seqüència «està a»?", "o": ["Les dues a es fonen en una de més llarga", "Es pronuncia «estàs a»", "S'hi afig una e"], "e": "Fusió de vocals iguals: està_a casa."},
      {"q": "Quina d'estes expressions NO té elisió vocàlica en la parla?", "o": ["un home", "quina hora", "quinze anys"], "e": "En «un home» no hi ha dues vocals en contacte: la n s'enllaça amb la vocal següent [u-no-me]. La h és muda."},
      {"q": "El so inicial de «juny» en valencià és...", "o": ["com el de «gent» o «platja», sonor", "com la jota castellana de «junio»", "com una i"], "e": "La j valenciana és una consonant palatal sonora, no la jota castellana."},
      {"q": "Com sona la g de «gener» en valencià?", "o": ["com la j de «jove»: palatal sonora", "com la jota castellana", "com la g de «gat»"], "e": "En valencià no existix el so de la jota castellana: g (davant e, i) i j sonen com en «platja»."},
      {"q": "En quina paraula la r sona forta (vibrant múltiple)?", "o": ["racó", "cara", "pera"], "e": "La r inicial sempre és forta: racó, roda, riu. Entre vocals, la r simple és suau: cara."},
      {"q": "En quina paraula hi ha una r forta entre vocals?", "o": ["carro", "caro", "para"], "e": "Entre vocals, el so fort s'escriu rr: carro, parra, morro."},
      {"q": "Quina parella de paraules es distingix només per la r suau o forta?", "o": ["para / parra", "cara / casa", "pera / pena"], "e": "Para (verb parar) i parra (planta de raïm): r suau / rr forta."},
      {"q": "En quina paraula la s sona sonora, com un brunzit d'abella [z]?", "o": ["casa", "passa", "sol"], "e": "La s entre vocals és sonora [z]: casa, rosa. La ss és sorda: passa."},
      {"q": "Quina parella es distingix per la s sonora / s sorda?", "o": ["rosa / rossa", "rosa / roda", "casa / cara"], "e": "Rosa [z] (flor) i rossa [s] (de cabell clar)."},
      {"q": "La z de «zero» o «dotze» en valencià sona...", "o": ["sonora, com la s de «casa»", "com la z castellana de «zapato»", "muda"], "e": "En valencià la z és una s sonora [z], no la z interdental castellana."},
      {"q": "En quina paraula la consonant final no es pronuncia normalment?", "o": ["camp", "cap", "llop"], "e": "Després de m, la p final s'emmudix: camp [kam]. En «cap» i «llop» sí que sona."},
      {"q": "Com es pronuncia normalment la preposició «amb»?", "o": ["[am]", "[amb] amb b forta", "[ab]"], "e": "La b final darrere de m s'emmudix: amb [am], tomb [tom]."},
      {"q": "En quina paraula hi ha un emmudiment de la p?", "o": ["temps", "tapa", "capsa"], "e": "Temps [tems]: la p no es pronuncia. En «tapa» i «capsa» sona."},
      {"q": "En alguns parlars valencians, quina consonant s'emmudix al final dels infinitius com «comptar» o «cantar»?", "o": ["la -r", "la -t", "la -n"], "e": "La -r final s'emmudix en alguns parlars (comptar, senyor, carrer), però sempre s'escriu."},
      {"q": "En «comptar», quina consonant no se sent mai?", "o": ["la p", "la m", "la t"], "e": "Comptar [kon-tar]: la p no es pronuncia, però s'escriu (com en «compte»)."},
      {"q": "Com s'ha d'articular «col·legi»?", "o": ["amb una l doble, allargada [kol-le-dʒi]", "com «colegi» amb una sola l", "com «colleji» amb ll"], "e": "La l·l és una geminada: es pronuncia una l més llarga, repartida entre dues síl·labes."},
      {"q": "Com s'articula «ametla»?", "o": ["amb una l allargada [a-mel-la]", "amb t i l separades molt marcades", "com «ameta»"], "e": "El grup tl de «ametla», «espatla» o «guatla» se sol pronunciar com una l doble."},
      {"q": "En quina paraula hi ha una geminació de m?", "o": ["immens", "imatge", "mama"], "e": "Immens: im-mens, la m sona doble."},
      {"q": "En quina paraula hi ha una geminació de n?", "o": ["ennuvolat", "enutjat", "enyorar"], "e": "En-nu-vo-lat: n doble (en- + nuvolat)."},
      {"q": "Quin grup consonàntic cal articular clarament, sense afegir-hi cap vocal, en «estrella»?", "o": ["str", "tll", "ell"], "e": "Grups consonàntics com str, pl, bl, tr, cr: es-tre-lla."},
      {"q": "En quina pregunta la veu puja al final?", "o": ["Vindràs demà?", "On vas?", "Quan arribes?"], "e": "Preguntes de resposta sí/no: entonació ascendent. Les que comencen per un interrogatiu (on, quan, qui...) solen baixar al final."},
      {"q": "En valencià col·loquial, quina partícula pot introduir una pregunta de sí o no?", "o": ["que: «Que vindràs demà?»", "quin", "com"], "e": "Que expletiu: «Que tens fred?», «Que ha vingut Maria?»."},
      {"q": "Quina d'estes frases és una exclamació?", "o": ["Que bonic és este poble!", "Este poble és bonic.", "Quin poble és?"], "e": "Que + adjectiu...!: entonació exclamativa, emfàtica."},
      {"q": "Quina d'estes expressions s'usa per a exclamar sorpresa?", "o": ["Mare meua!", "Per favor.", "De res."], "e": "Mare meua!, Ostres!, Caram!: exclamacions de sorpresa."},
      {"q": "Com canvia el sentit «Ja ha vingut.» i «Ja ha vingut?»", "o": ["La primera afirma; la segona pregunta, amb entonació ascendent", "Són iguals", "La segona és una ordre"], "e": "L'entonació (i, en l'escriptura, el signe ?) canvia una afirmació en pregunta."},
      {"q": "Quina és la frase exclamativa ben construïda?", "o": ["Quina calor que fa!", "Quina calor fa?", "Calor fa quina!"], "e": "Quin/quina + nom (+ que...)!: Quina calor que fa!"},
      {"q": "En «Quin dia més bonic!», l'entonació...", "o": ["és emfàtica: puja en «bonic» i baixa al final", "puja al final com una pregunta de sí/no", "és plana, sense canvis"], "e": "Entonació exclamativa: èmfasi en la paraula clau."},
      {"q": "En quina paraula la x sona com «tx» ([tʃ]) després de consonant?", "o": ["panxa", "caixa", "taxi"], "e": "Darrere de consonant, la x sona [tʃ]: panxa, planxa, marxa. «Caixa» té [ʃ] i «taxi», [ks]."},
      {"q": "Quina d'estes paraules té el so [ks]?", "o": ["taxi", "xarop", "caixa"], "e": "Taxi, èxit, fax: la x sona [ks]."},
      {"q": "En «examen», com sona la x?", "o": ["[gz], sonora", "[ʃ] com en «caixa»", "com la jota castellana"], "e": "Ex- + vocal: [gz] (examen, exacte, exèrcit)."},
      {"q": "Quina d'estes paraules té el so de la ny?", "o": ["canya", "cana", "cania"], "e": "Ny és una sola consonant palatal: ca-nya."},
      {"q": "Quin signe es posa al final d'una exclamació en valencià?", "o": ["! (només al final)", "¡ ... ! (al principi i al final)", "? (com una pregunta)"], "e": "En valencià el signe d'exclamació només es posa al final."},
      {"q": "Escriu com es pronuncia «quinze anys» unint les paraules (sense espai).", "a": ["quinzanys", "kinzanys"], "e": "S'elidix la -e: quinzanys."},
      {"q": "Escriu la consonant que no es pronuncia en «camp».", "a": ["p"], "e": "La p final després de m."}
    ]
  },
  {
    "id": "32ddfc19-805e-4315-8534-2fdf65376b76", "type": "b1_fon_alfabet", "sort_order": 2,
    "title": "Alfabet i grafies", "name": "Lletres modificades, dígrafs i geminacions",
    "content": "Les lletres simples i modificades, els dígrafs (rr, ll, l·l, ny, gu, qu, ss, tj, tg, tz, ix, ig, tx) i les geminacions en el vocabulari familiar (3.2.1).", "icon": "🔤", "color": "#FFE0B2",
    "exercises": [
      {"q": "Quina d'estes lletres és una lletra modificada (amb un signe que en canvia el so)?", "o": ["ç", "c", "s"], "e": "La ç (ce trencada) sona [s] davant de a, o, u: plaça, caçar, forçós."},
      {"q": "Què és un dígraf?", "o": ["Dues lletres que representen un sol so", "Dues paraules unides", "Una lletra amb accent"], "e": "Dígrafs: rr, ss, ll, ny, qu, gu, ix, ig, tx, tj, tg, tz, l·l."},
      {"q": "Quina d'estes paraules té un dígraf?", "o": ["canya", "cana", "cala"], "e": "Ny és un dígraf: ca-nya."},
      {"q": "Quina d'estes paraules té el dígraf «tz»?", "o": ["dotze", "dos", "dosi"], "e": "Dot-ze, set-ze, tret-ze, organitzar: tz entre vocals."},
      {"q": "Quina d'estes paraules té el dígraf «tg»?", "o": ["metge", "mega", "menja"], "e": "Met-ge, rellot-ge, viat-ge: tg davant de e, i."},
      {"q": "Quina d'estes paraules té el dígraf «tj»?", "o": ["platja", "plaga", "plaja"], "e": "Plat-ja, pit-jor, mit-jà: tj davant de a, o, u."},
      {"q": "En «guerra», què és «gu»?", "o": ["Un dígraf: la u no sona", "Un diftong", "Dues consonants"], "e": "Gu davant de e, i: la u no es pronuncia (guerra, guitarra)."},
      {"q": "En «quatre», la u...", "o": ["sí que sona: forma diftong amb la a", "no sona, és un dígraf", "és una consonant"], "e": "Qu davant de a, o sempre sona [kw]: qua-tre, quan, quota."},
      {"q": "Quantes lletres i quants sons té «carro»?", "o": ["5 lletres i 4 sons", "5 lletres i 5 sons", "4 lletres i 4 sons"], "e": "El dígraf rr fa un sol so: c-a-rr-o."},
      {"q": "Quantes lletres i quants sons té «caixa»?", "o": ["5 lletres i 4 sons", "5 lletres i 5 sons", "4 lletres i 3 sons"], "e": "Ix és un dígraf amb un sol so [ʃ]: c-a-ix-a."},
      {"q": "Com se separa en síl·labes «carro»?", "o": ["car-ro", "ca-rro", "carr-o"], "e": "Els dígrafs rr, ss, l·l, tj, tg, tz i ix se separen: car-ro."},
      {"q": "Com se separa en síl·labes «callar»?", "o": ["ca-llar", "cal-lar", "call-ar"], "e": "La ll no se separa mai: ca-llar."},
      {"q": "Com se separa en síl·labes «canya»?", "o": ["ca-nya", "can-ya", "cany-a"], "e": "La ny no se separa: ca-nya."},
      {"q": "Com se separa en síl·labes «passar»?", "o": ["pas-sar", "pa-ssar", "pass-ar"], "e": "La ss se separa: pas-sar."},
      {"q": "Com se separa en síl·labes «col·legi»?", "o": ["col-le-gi", "co-l·le-gi", "col·l-e-gi"], "e": "La l·l se separa i el punt volat desapareix en partir la paraula: col-le-gi."},
      {"q": "Com se separa en síl·labes «metge»?", "o": ["met-ge", "me-tge", "metg-e"], "e": "Tg se separa: met-ge."},
      {"q": "Com se separa en síl·labes «dotze»?", "o": ["dot-ze", "do-tze", "dotz-e"], "e": "Tz se separa: dot-ze."},
      {"q": "Com se separa en síl·labes «paquet»?", "o": ["pa-quet", "paq-uet", "paqu-et"], "e": "El dígraf qu no se separa: pa-quet."},
      {"q": "Com se separa «guitarra»?", "o": ["gui-tar-ra", "gu-it-ar-ra", "guit-arr-a"], "e": "Gu no se separa; rr sí: gui-tar-ra."},
      {"q": "Quina paraula està ben escrita?", "o": ["col·lecció", "colecció", "col.lecció"], "e": "Col·lecció: la l·l s'escriu amb punt volat (·), no amb un punt baix."},
      {"q": "Quina paraula està ben escrita?", "o": ["il·lusió", "ilusió", "illusió"], "e": "Il·lusió."},
      {"q": "Quina paraula està ben escrita?", "o": ["pel·lícula", "pelícu·la", "pellícula"], "e": "Pel·lícula."},
      {"q": "Quina d'estes paraules té una geminació (dues consonants iguals que sonen)?", "o": ["innecessari", "carro", "passar"], "e": "In-ne-ces-sa-ri: les dues n sonen. En «carro» i «passar», rr i ss són dígrafs d'un sol so."},
      {"q": "Quina d'estes paraules té el dígraf «ig» a final de paraula?", "o": ["maig", "mag", "mai"], "e": "Ig final sona [tʃ]: maig, roig, mig, lleig."},
      {"q": "Quina d'estes paraules té el dígraf «tx»?", "o": ["cotxe", "coixa", "coca"], "e": "Cot-xe, fit-xa, but-xa-ca: tx entre vocals."},
      {"q": "Quantes lletres i quants sons té «llibre»?", "o": ["6 lletres i 5 sons", "6 lletres i 6 sons", "5 lletres i 5 sons"], "e": "Ll és un dígraf: ll-i-b-r-e."},
      {"q": "Quina d'estes paraules NO té cap dígraf?", "o": ["blau", "carrer", "canya"], "e": "Bl és un grup consonàntic, no un dígraf: els dos sons es pronuncien."},
      {"q": "Quina d'estes paraules té un grup consonàntic (dos sons diferents) i no un dígraf?", "o": ["prat", "pell", "pany"], "e": "Pr: se senten la p i la r. Ll i ny són dígrafs."},
      {"q": "En quina d'estes paraules la u de «qu» no es pronuncia?", "o": ["quilo", "quan", "quota"], "e": "Qu davant de e, i: la u no sona (quilo, queixa). Davant de a, o sí: quan, quota."},
      {"q": "Quina d'estes paraules s'escriu amb «qü» (u que sona davant de e o i)?", "o": ["qüestió", "quilo", "queixa"], "e": "Qüestió, freqüent, aqüeducte: la dièresi indica que la u sona."},
      {"q": "Quina d'estes paraules té el dígraf «ss»?", "o": ["massa", "masa", "mas"], "e": "Mas-sa: ss entre vocals (so sord [s])."},
      {"q": "Com se separa en síl·labes «massa»?", "o": ["mas-sa", "ma-ssa", "mass-a"], "e": "La ss se separa: mas-sa."},
      {"q": "Com se separa en síl·labes «caixa»?", "o": ["cai-xa", "ca-ixa", "caix-a"], "e": "El dígraf ix se separa: cai-xa (la i queda amb la vocal anterior)."},
      {"q": "Com se separa en síl·labes «platja»?", "o": ["plat-ja", "pla-tja", "platj-a"], "e": "Tj se separa: plat-ja."},
      {"q": "Quina d'estes paraules té el dígraf «ix»?", "o": ["peix", "pex", "pexi"], "e": "Peix, caixa, baix: ix sona [ʃ]."},
      {"q": "Quina d'estes paraules NO té cap dígraf?", "o": ["pare", "parra", "parell"], "e": "Pare: cada lletra és un so. Parra (rr) i parell (ll) tenen dígrafs."},
      {"q": "Escriu el nombre de sons de «carrer».", "a": ["5", "cinc"], "e": "C-a-rr-e-r: el dígraf rr fa un sol so."},
      {"q": "Separa en síl·labes «canya» (amb guionets).", "a": ["ca-nya"], "e": "Ca-nya."},
      {"q": "Separa en síl·labes «carro» (amb guionets).", "a": ["car-ro"], "e": "Car-ro."},
      {"q": "Escriu el signe que porta la l·l entre les dues l.", "a": ["·", "punt volat", "el punt volat"], "e": "El punt volat (·)."}
    ]
  },
  {
    "id": "6fda17fe-be10-433f-9955-38698e488c6a", "type": "b1_fon_sillaba", "sort_order": 3,
    "title": "Síl·labes, diftongs i hiats", "name": "Tòniques i àtones, agudes, planes, esdrúixoles, diftongs i hiats",
    "content": "Síl·labes tòniques i àtones, agudes, planes i esdrúixoles, diftongs i hiats, separació sil·làbica i els verbs acabats en -iar (3.2.1).", "icon": "🔊", "color": "#C5CAE9",
    "exercises": [
      {"q": "Quina és la síl·laba tònica de «telèfon»?", "o": ["-lè-", "te-", "-fon"], "e": "Te-LÈ-fon: plana (tònica en la penúltima)."},
      {"q": "Quina d'estes paraules és aguda?", "o": ["camió", "camisa", "càmera"], "e": "Ca-mi-Ó: tònica en l'última síl·laba."},
      {"q": "Quina d'estes paraules és plana?", "o": ["examen", "jardí", "música"], "e": "E-XA-men: tònica en la penúltima."},
      {"q": "Quina d'estes paraules és esdrúixola?", "o": ["fàbrica", "fabrica", "fabricà"], "e": "FÀ-bri-ca: tònica en l'antepenúltima."},
      {"q": "«Ramon» és una paraula...", "o": ["aguda", "plana", "esdrúixola"], "e": "Ra-MON: aguda acabada en -on, per això no porta accent."},
      {"q": "«Fenomen» és una paraula...", "o": ["plana", "aguda", "esdrúixola"], "e": "Fe-NO-men: plana acabada en -en, sense accent."},
      {"q": "Quantes síl·labes àtones té «matemàtiques»?", "o": ["4", "5", "1"], "e": "Ma-te-MÀ-ti-ques: 5 síl·labes, una de tònica i 4 d'àtones."},
      {"q": "Quina d'estes paraules té un diftong decreixent (vocal + i/u)?", "o": ["mai", "via", "dia"], "e": "Mai: a + i en la mateixa síl·laba. Diftongs decreixents: ai, ei, oi, ui, au, eu, iu, ou, uu."},
      {"q": "Quina d'estes paraules té un diftong decreixent?", "o": ["peu", "teatre", "poeta"], "e": "Peu: e + u en una síl·laba. Teatre i poeta tenen hiat."},
      {"q": "Quina d'estes paraules té un diftong creixent?", "o": ["quatre", "cuina", "dia"], "e": "Qua-tre: gu/qu + vocal fan diftong creixent (quatre, aigua, guant)."},
      {"q": "Quina d'estes paraules té un hiat (dues vocals en síl·labes diferents)?", "o": ["teatre", "rei", "nou"], "e": "Te-a-tre: e i a en síl·labes diferents."},
      {"q": "Com se separa «poeta»?", "o": ["po-e-ta", "poe-ta", "p-oe-ta"], "e": "Hiat: po-e-ta."},
      {"q": "Com se separa «aigua»?", "o": ["ai-gua", "a-i-gu-a", "aig-ua"], "e": "Ai-gua: diftong decreixent ai i diftong creixent ua."},
      {"q": "Com se separa «noia»?", "o": ["no-ia", "noi-a", "n-oi-a"], "e": "La i entre vocals és consonant i va amb la vocal següent: no-ia, jo-ia, ma-ior."},
      {"q": "Com se separa «creuen»?", "o": ["cre-uen", "creu-en", "cr-eu-en"], "e": "La u entre vocals és consonant: cre-uen."},
      {"q": "Com se separa «veïna»?", "o": ["ve-ï-na", "veï-na", "vei-na"], "e": "La dièresi indica hiat: ve-ï-na."},
      {"q": "Com se separa «cuina»?", "o": ["cui-na", "cu-i-na", "c-ui-na"], "e": "Ui és diftong decreixent: cui-na."},
      {"q": "Com se separa «país»?", "o": ["pa-ís", "pais", "p-aís"], "e": "L'accent indica hiat: pa-ís (aguda)."},
      {"q": "Quantes síl·labes té «estudia» (ell estudia)?", "o": ["4: es-tu-di-a", "3: es-tu-dia", "2: es-tudia"], "e": "En els verbs en -iar, la i i la vocal de la terminació formen hiat: es-tu-di-a."},
      {"q": "Quantes síl·labes té «canvia»?", "o": ["3: can-vi-a", "2: can-via", "4: ca-n-vi-a"], "e": "Can-vi-a: i i a en síl·labes diferents."},
      {"q": "Quina és la pronunciació correcta de «envia» (ell envia una carta)?", "o": ["en-VI-a", "EN-via", "en-vi-A"], "e": "En-VI-a: la tònica és la i, i hi ha hiat."},
      {"q": "Quantes síl·labes té «copie» (que jo copie)?", "o": ["3: co-pi-e", "2: co-pie", "4: c-o-pi-e"], "e": "Co-pi-e: hiat en les formes dels verbs en -iar."},
      {"q": "Quina d'estes paraules és aguda acabada en diftong?", "o": ["fareu", "féreu", "parlàreu"], "e": "Fa-REU: aguda acabada en diftong decreixent -eu, per això no porta accent."},
      {"q": "Quina d'estes paraules és plana?", "o": ["féreu", "fareu", "cantareu"], "e": "FÉ-reu: plana; porta accent perquè acaba en diftong (-eu)."},
      {"q": "«Justícia» és...", "o": ["esdrúixola: jus-tí-ci-a", "plana: jus-tí-cia", "aguda"], "e": "Les paraules acabades en vocal + vocal (-ia, -ie, -io, -ua) es consideren esdrúixoles: jus-TÍ-ci-a, his-TÒ-ri-a."},
      {"q": "Quina parella canvia de significat segons la síl·laba tònica?", "o": ["fabrica / fàbrica", "taula / taules", "casa / cases"], "e": "Fa-BRI-ca (verb) i FÀ-bri-ca (edifici): canviar la tònica canvia la paraula."},
      {"q": "En «ràpidament», on recau l'accent?", "o": ["En «rà-», com en «ràpida»", "En «-ment»", "No en té"], "e": "Els adverbis en -ment conserven l'accent de l'adjectiu: ràpidament, fàcilment."},
      {"q": "Quina d'estes paraules és un monosíl·lab?", "o": ["pa", "pare", "patata"], "e": "Pa: una síl·laba. Els monosíl·labs no porten accent, excepte els diacrítics."},
      {"q": "Quina és la síl·laba tònica de «paraigua»?", "o": ["-rai-", "pa-", "-gua"], "e": "Pa-RAI-gua: plana."},
      {"q": "Quantes síl·labes té «ou»?", "o": ["1", "2", "3"], "e": "Ou: diftong decreixent, una sola síl·laba."},
      {"q": "Quantes síl·labes té «Raül»?", "o": ["2: Ra-ül", "1: Raül", "3: R-a-ül"], "e": "La dièresi marca hiat: Ra-ül."},
      {"q": "Separa en síl·labes «teatre» (amb guionets).", "a": ["te-a-tre"], "e": "Te-a-tre."},
      {"q": "Separa en síl·labes «aigua» (amb guionets).", "a": ["ai-gua"], "e": "Ai-gua."},
      {"q": "Separa en síl·labes «noia» (amb guionets).", "a": ["no-ia"], "e": "No-ia."},
      {"q": "Escriu la síl·laba tònica de «fàbrica».", "a": ["fà", "fà-"], "e": "FÀ-bri-ca."}
    ]
  },
  {
    "id": "b39add6c-4f6f-4daa-a4b4-a5b4665a3f07", "type": "b1_fon_vocals", "sort_order": 4,
    "title": "Les vocals", "name": "Confusions a/e i o/u, la e inicial, alternances i vocals obertes i tancades",
    "content": "Els principals casos de confusió a/e i o/u, la e de les paraules començades per em-, en-, es-, eix-, les alternances e/i i o/u dels verbs irregulars i les vocals obertes i tancades (3.2.1).", "icon": "🅰️", "color": "#FFCCBC",
    "exercises": [
      {"q": "Quina forma és correcta?", "o": ["afaitar", "afeitar", "afetar"], "e": "Afaitar (i afaitada, afaitadora)."},
      {"q": "Quina forma és correcta?", "o": ["llençol", "llançol", "llinçol"], "e": "Llençol."},
      {"q": "Quina forma és correcta?", "o": ["assemblea", "asamblea", "assamblea"], "e": "Assemblea."},
      {"q": "Quina forma és correcta?", "o": ["teranyina", "taranyina", "teranyana"], "e": "Teranyina (la tela de l'aranya)."},
      {"q": "Quina forma és correcta?", "o": ["sergent", "sargent", "sarjent"], "e": "Sergent."},
      {"q": "Quina forma és correcta?", "o": ["taronja", "teronja", "tarunja"], "e": "Taronja."},
      {"q": "Quina forma és correcta?", "o": ["cobert", "cubert", "cubiert"], "e": "Cobert (i cobrir, coberta)."},
      {"q": "Quina forma és correcta?", "o": ["Joan", "Juan", "Jouan"], "e": "Joan s'escriu amb o encara que la o àtona sone [u]."},
      {"q": "Quina forma és correcta?", "o": ["Josep", "Jusep", "Josèp"], "e": "Josep."},
      {"q": "Quina forma és correcta?", "o": ["joguet", "juguet", "joguèt"], "e": "Joguet (i jugar: alternança o/u)."},
      {"q": "Quina forma és correcta?", "o": ["polsera", "pulsera", "pulçera"], "e": "Polsera (de pols, el canell)."},
      {"q": "Quina forma és correcta?", "o": ["escopir", "escupir", "escapir"], "e": "Escopir."},
      {"q": "Quina forma és correcta?", "o": ["sofrir", "sufrir", "sofrar"], "e": "Sofrir (o patir)."},
      {"q": "Quina forma és correcta?", "o": ["suportar", "soportar", "supurtar"], "e": "Suportar s'escriu amb u."},
      {"q": "Quina forma és correcta?", "o": ["tossir", "tussir", "toser"], "e": "Tossir (però jo tus, ell tus)."},
      {"q": "Quina forma és correcta?", "o": ["entendre", "antendre", "intendre"], "e": "Entendre: les paraules usuals començades per en- s'escriuen amb e."},
      {"q": "Quina forma és correcta?", "o": ["estendre", "astendre", "istendre"], "e": "Estendre (la roba)."},
      {"q": "Quina forma és correcta?", "o": ["eixugar", "aixugar", "ixugar"], "e": "Eixugar: eix- a començament de paraula."},
      {"q": "Quina forma és correcta?", "o": ["embastar", "ambastar", "imbastar"], "e": "Embastar (cosir provisionalment amb punts llargs)."},
      {"q": "Quina forma és correcta?", "o": ["escoltar", "ascoltar", "iscoltar"], "e": "Escoltar."},
      {"q": "Quina forma és correcta?", "o": ["enfadar-se", "anfadar-se", "infadar-se"], "e": "Enfadar-se."},
      {"q": "Quina forma és correcta?", "o": ["eixir", "ixir", "aixir"], "e": "L'infinitiu és eixir (eixim, eixiu), però jo isc, tu ixes, ell ix."},
      {"q": "«Jo ___ el diari cada matí.» (llegir)", "o": ["llig", "lleg", "llegix"], "e": "Llegir: jo llig, tu lliges, ell llig, nosaltres llegim. Alternança e/i."},
      {"q": "«Nosaltres ___ el diari cada matí.» (llegir)", "o": ["llegim", "lligim", "lligem"], "e": "Llegim: en posició àtona apareix la e."},
      {"q": "«Tu ___ de casa molt prompte.» (eixir)", "o": ["ixes", "eixes", "ixeixes"], "e": "Eixir: isc, ixes, ix, eixim, eixiu, ixen."},
      {"q": "«Nosaltres ___ a les huit.» (eixir)", "o": ["eixim", "ixim", "eixem"], "e": "Eixim: en posició àtona apareix eix-."},
      {"q": "«Jo no ___ vindre demà.» (poder)", "o": ["puc", "poc", "pot"], "e": "Poder: jo puc, tu pots, ell pot. Alternança o/u."},
      {"q": "«Que jo ___ o no, ho faré igual.» (voler)", "o": ["vullga", "volga", "vulga"], "e": "Voler: que jo vullga (subjuntiu); jo volia (imperfet): alternança u/o."},
      {"q": "«Quan era xicotet, ___ ser bomber.» (voler)", "o": ["volia", "vullia", "vulia"], "e": "Volia: en posició àtona, o."},
      {"q": "«Ma mare ___ els pantalons.» (cosir)", "o": ["cus", "cos", "cusix"], "e": "Cosir: jo cus, tu cuses, ell cus, nosaltres cosim."},
      {"q": "«Ell ___ taronges a l'hort.» (collir)", "o": ["cull", "coll", "cullix"], "e": "Collir: jo cull, ell cull, nosaltres collim."},
      {"q": "Quin accent porta «perquè»?", "o": ["obert: è", "tancat: é", "no en porta"], "e": "Perquè, què: e oberta (è)."},
      {"q": "Quin accent porta «també»?", "o": ["tancat: é", "obert: è", "no en porta"], "e": "També, només, vosté: e tancada (é)."},
      {"q": "Quin accent porta «cançó»?", "o": ["tancat: ó", "obert: ò", "no en porta"], "e": "Cançó, camió, avió: o tancada (ó)."},
      {"q": "Quin accent porta «història»?", "o": ["obert: ò", "tancat: ó", "no en porta"], "e": "Història, memòria, dòlar: o oberta (ò)."},
      {"q": "Quin accent porta la a tònica (sofà, àvia)?", "o": ["sempre greu: à", "sempre agut: á", "depén de la paraula"], "e": "La a sempre porta accent greu (à); la i i la u, sempre agut (í, ú)."},
      {"q": "Quina parella es distingix per la o oberta / o tancada?", "o": ["sòl (terra) / sol (astre)", "dona / dones", "porta / portes"], "e": "Sòl, amb o oberta, és el terra; sol, l'astre."},
      {"q": "Escriu la forma correcta: «Jo ___ el llibre» (llegir, present).", "a": ["llig"], "e": "Llig."},
      {"q": "Escriu el verb correcte: ___ la roba al sol (eixugar o aixugar).", "a": ["eixugar"], "e": "Eixugar."},
      {"q": "Escriu bé el nom: ___ (Joan o Juan).", "a": ["Joan"], "e": "Joan."}
    ]
  },
  {
    "id": "a2de932f-ba79-43c3-88f4-0432422a5ff2", "type": "b1_fon_accentuacio", "sort_order": 5,
    "title": "Accentuació, dièresi i guionet", "name": "Regles generals de l'accent, accents diacrítics, dièresi i guionet",
    "content": "Normes generals de l'accentuació (agudes, planes i esdrúixoles), accent obert i tancat, accents diacrítics, normes bàsiques de la dièresi i del guionet (3.2.1).", "icon": "✍️", "color": "#FFCDD2",
    "exercises": [
      {"q": "Quines paraules agudes porten accent?", "o": ["Les acabades en vocal, vocal + s, -en i -in", "Totes les agudes", "Només les acabades en consonant"], "e": "Agudes: camió, francés, també, entén, camí. Ramon i fareu no en porten."},
      {"q": "Quines paraules planes porten accent?", "o": ["Les que NO acaben en vocal, vocal + s, -en ni -in", "Totes les planes", "Les acabades en vocal"], "e": "Planes: plàstic, difícil, féreu. Però fenomen, examen, taula: sense accent."},
      {"q": "Quines paraules esdrúixoles porten accent?", "o": ["Totes", "Cap", "Només les acabades en -a"], "e": "Totes les esdrúixoles s'accentuen: fàbrica, música, justícia."},
      {"q": "Quina forma és correcta?", "o": ["Ramon", "Ramón", "Ràmon"], "e": "Aguda acabada en -on: no porta accent."},
      {"q": "Quina forma és correcta?", "o": ["fenomen", "fenómen", "fenòmen"], "e": "Plana acabada en -en: no porta accent."},
      {"q": "Quina forma és correcta?", "o": ["plàstic", "plastic", "plàstíc"], "e": "Plana acabada en -c: porta accent."},
      {"q": "Quina forma és correcta? (vosaltres, futur de fer)", "o": ["fareu", "faréu", "fàreu"], "e": "Fa-REU: aguda acabada en diftong; no porta accent."},
      {"q": "Quina forma és correcta? (vosaltres, passat simple de fer)", "o": ["féreu", "fereu", "fèreu"], "e": "FÉ-reu: plana acabada en diftong (-eu): porta accent."},
      {"q": "Quina forma és correcta?", "o": ["justícia", "justicia", "jústicia"], "e": "Jus-TÍ-ci-a: es considera esdrúixola i porta accent."},
      {"q": "Quina forma és correcta?", "o": ["examen", "exàmen", "exámen"], "e": "Plana acabada en -en: sense accent. Però plural: exàmens (acaba en -ens)."},
      {"q": "Quin plural és correcte?", "o": ["exàmens", "examens", "exámens"], "e": "E-XÀ-mens: plana acabada en -ens, que no és cap de les terminacions sense accent."},
      {"q": "Quina forma és correcta?", "o": ["camins", "camíns", "càmins"], "e": "Ca-MINS: aguda acabada en -ins (no en -in): sense accent. Però camí sí."},
      {"q": "Quina forma és correcta?", "o": ["difícil", "dificil", "difìcil"], "e": "Plana acabada en -l: porta accent agut en la i."},
      {"q": "Quina forma és correcta?", "o": ["anglés", "angles", "ànglés"], "e": "Aguda acabada en vocal + s: porta accent (en valencià, anglés, francés)."},
      {"q": "Quina forma és correcta?", "o": ["fàcilment", "facilment", "fácilment"], "e": "Els adverbis en -ment conserven l'accent de l'adjectiu: fàcil → fàcilment."},
      {"q": "«Ell ___ dos germans.» (tindre)", "o": ["té", "te", "tè"], "e": "Té (verb) porta accent diacrític; te (pronom o infusió) no."},
      {"q": "«Ma germana ___ metgessa.»", "o": ["és", "es", "ès"], "e": "És (verb ser) porta accent; es (pronom) no."},
      {"q": "«Vull ___ pa, per favor.»", "o": ["més", "mes", "mès"], "e": "Més (quantitat) porta accent; mes (part de l'any) no."},
      {"q": "«___, vindré a la festa.»", "o": ["Sí", "Si", "Sì"], "e": "Sí (afirmació) porta accent; si (condició) no."},
      {"q": "«No ___ on he deixat les claus.» (saber)", "o": ["sé", "se", "sè"], "e": "Sé (verb saber) porta accent; se (pronom) no."},
      {"q": "«Ho has fet molt ___.»", "o": ["bé", "be", "bè"], "e": "Bé (adverbi) porta accent; be (corder o lletra) no."},
      {"q": "«Ha fet la volta al ___.»", "o": ["món", "mon", "mòn"], "e": "Món (el planeta) porta accent; mon (possessiu) no."},
      {"q": "«M'he trencat la ___.»", "o": ["mà", "ma", "má"], "e": "Mà (part del cos) porta accent; ma (possessiu) no."},
      {"q": "«Tens un ___ en la jaqueta.»", "o": ["pèl", "pel", "pél"], "e": "Pèl (cabell) porta accent; pel (contracció per + el) no."},
      {"q": "Quina paraula necessita dièresi?", "o": ["veïna", "veí", "veu"], "e": "Ve-ï-na: la dièresi marca que i i a no formen diftong. Veí ja porta accent."},
      {"q": "Quina forma és correcta?", "o": ["raïm", "raím", "raim"], "e": "Ra-ïm: hiat marcat amb dièresi (és aguda acabada en -m: no porta accent)."},
      {"q": "Quina forma és correcta?", "o": ["països", "paísos", "paisos"], "e": "Pa-ï-sos: el singular país porta accent; en el plural la i deixa de ser tònica i cal dièresi."},
      {"q": "Quina forma és correcta?", "o": ["pingüí", "pinguí", "pingui"], "e": "Güi: la dièresi indica que la u es pronuncia."},
      {"q": "Quina forma és correcta?", "o": ["aigües", "aigues", "aigúes"], "e": "Aigua → aigües: la u es pronuncia davant de e."},
      {"q": "Quina forma és correcta?", "o": ["egoisme", "egoïsme", "egóisme"], "e": "No es posa dièresi en les terminacions -isme i -ista: egoisme, egoista."},
      {"q": "Quina forma és correcta?", "o": ["traduir", "traduïr", "tradüir"], "e": "No porten dièresi l'infinitiu, el gerundi, el futur i el condicional: traduir, traduint, traduiré. Sí: traduïa, traduït."},
      {"q": "Quina forma és correcta?", "o": ["reunió", "reünió", "rëunió"], "e": "No es posa dièresi després de prefix: re-unió."},
      {"q": "Quina forma és correcta?", "o": ["vint-i-cinc", "vinticinc", "vint i cinc"], "e": "Desenes i unitats amb guionet; entre desenes i unitats, -i-: vint-i-cinc, trenta-dos."},
      {"q": "Com s'escriu 230?", "o": ["dos-cents trenta", "doscents-trenta", "dos cents trenta"], "e": "Unitats i centenes amb guionet (dos-cents), però centenes i desenes separades."},
      {"q": "Quina forma és correcta?", "o": ["dona-li", "donali", "dona li"], "e": "Els pronoms febles darrere del verb s'unixen amb guionet: dona-li, fes-ho, porta-ho."},
      {"q": "Quina forma és correcta?", "o": ["nord-americà", "nordamericà", "nord americà"], "e": "Compostos amb punts cardinals: nord-americà, sud-est."},
      {"q": "Quina forma és correcta?", "o": ["para-sol", "parasol", "para sol"], "e": "Para-sol, gira-sol, para-xocs: guionet quan la primera part acaba en vocal i la segona comença per r, s o x."},
      {"q": "Quina forma és correcta?", "o": ["paraigua", "para-igua", "para igua"], "e": "Paraigua s'escriu junt."},
      {"q": "Quina forma és correcta?", "o": ["expresident", "ex-president", "ex president"], "e": "El prefix ex- s'escriu junt: expresident."},
      {"q": "Escriu amb l'accent correcte: musica.", "a": ["música"], "e": "Esdrúixola: música."},
      {"q": "Escriu amb l'accent correcte: frances (home de França).", "a": ["francés", "francès"], "e": "Francés: aguda acabada en vocal + s."},
      {"q": "Escriu amb la dièresi correcta: veina.", "a": ["veïna"], "e": "Veïna."},
      {"q": "Escriu el número 45 en lletres.", "a": ["quaranta-cinc"], "e": "Quaranta-cinc."}
    ]
  },
  {
    "id": "05b13ba1-42eb-432d-af83-a16cac7346ab", "type": "b1_fon_apostrofacio", "sort_order": 6,
    "title": "Apostrofació i contracció", "name": "Apòstrof de l'article, de la preposició de i dels pronoms febles",
    "content": "Regles generals d'apostrofació dels articles el/la i de la preposició de, l'apòstrof en els pronoms febles units al verb, combinacions bàsiques de pronoms i contraccions (3.2.1).", "icon": "🔗", "color": "#D7CCC8",
    "exercises": [
      {"q": "Quina forma és correcta?", "o": ["l'ase", "el ase", "la ase"], "e": "L'article el s'apostrofa davant de vocal: l'ase."},
      {"q": "Quina forma és correcta?", "o": ["l'era", "la era", "le era"], "e": "La s'apostrofa davant de vocal: l'era."},
      {"q": "Quina forma és correcta?", "o": ["l'illa", "la illa", "lilla"], "e": "L'illa: la i és tònica."},
      {"q": "Quina forma és correcta?", "o": ["l'home", "el home", "lhome"], "e": "Davant de h muda s'apostrofa: l'home, l'hora."},
      {"q": "Quina forma és correcta?", "o": ["l'ungla", "la ungla", "lungla"], "e": "L'ungla: u tònica."},
      {"q": "Quina forma és correcta?", "o": ["la infermera", "l'infermera", "l'infirmera"], "e": "La no s'apostrofa davant de i o u àtones (amb h o sense): la infermera."},
      {"q": "Quina forma és correcta?", "o": ["la universitat", "l'universitat", "la' universitat"], "e": "U àtona: la universitat."},
      {"q": "Quina forma és correcta?", "o": ["la història", "l'història", "la' història"], "e": "Hi- àtona: la història. Però l'hora (o tònica)."},
      {"q": "Quina forma és correcta?", "o": ["l'altra setmana", "la altra setmana", "l altra setmana"], "e": "La s'apostrofa davant de vocal tònica o àtona que no siga i/u: l'altra, l'escola, l'amiga."},
      {"q": "Quina forma és correcta?", "o": ["la indústria", "l'indústria", "la' indústria"], "e": "I àtona: la indústria. Però d'indústria, perquè la preposició de sí que s'apostrofa."},
      {"q": "Quina forma és correcta?", "o": ["el iogurt", "l'iogurt", "le iogurt"], "e": "No s'apostrofa davant de i o u semiconsonants: el iogurt, la iaia."},
      {"q": "Quina forma és correcta? (l'hora)", "o": ["És la una.", "És l'una.", "És la' una."], "e": "Amb l'hora no s'apostrofa: la una."},
      {"q": "Quina forma és correcta?", "o": ["un got d'aigua", "un got de aigua", "un got d aigua"], "e": "De s'apostrofa davant de vocal o h muda: d'aigua, d'home."},
      {"q": "Quina forma és correcta?", "o": ["el gos d'Isabel", "el gos de Isabel", "el gos dIsabel"], "e": "De s'apostrofa sempre davant de vocal, encara que siga i o u àtones: d'Isabel, d'una."},
      {"q": "Quina forma és correcta?", "o": ["la casa de l'amo", "la casa del amo", "la casa d'el amo"], "e": "De + l'amo: no es contrau quan l'article està apostrofat."},
      {"q": "Quina forma és correcta?", "o": ["Vaig a l'escola.", "Vaig al escola.", "Vaig a la escola."], "e": "A + l'escola: no hi ha contracció."},
      {"q": "Quina forma és correcta?", "o": ["Vaig al mercat.", "Vaig a el mercat.", "Vaig a'l mercat."], "e": "A + el = al."},
      {"q": "Quina forma és correcta?", "o": ["Passem pel parc.", "Passem per el parc.", "Passem per'l parc."], "e": "Per + el = pel; per + els = pels."},
      {"q": "Quina forma és correcta?", "o": ["el llibre dels xiquets", "el llibre de els xiquets", "el llibre d'els xiquets"], "e": "De + els = dels."},
      {"q": "Quina forma és correcta?", "o": ["M'agrada molt.", "Me agrada molt.", "Em agrada molt."], "e": "Em davant de verb que comença per vocal: m'agrada."},
      {"q": "Quina forma és correcta?", "o": ["T'estime.", "Te estime.", "Et estime."], "e": "Et → t' davant de vocal: t'estime."},
      {"q": "Quina forma és correcta?", "o": ["L'he vist.", "El he vist.", "Lo he vist."], "e": "El → l' davant de vocal o h: l'he vist."},
      {"q": "Quina forma és correcta?", "o": ["N'hi ha molts.", "En hi ha molts.", "Ni ha molts."], "e": "En + hi davant de ha: n'hi ha."},
      {"q": "Quina forma és correcta?", "o": ["Ens agrada.", "'Ns agrada.", "Ens'agrada."], "e": "Ens no s'apostrofa davant del verb: ens agrada, ens ajuda."},
      {"q": "Quina forma és correcta?", "o": ["Compra'l.", "Compra-el.", "Compral."], "e": "Darrere de verb acabat en vocal, el → 'l: compra'l."},
      {"q": "Quina forma és correcta?", "o": ["Mira'ns.", "Mira-ens.", "Mira'ens."], "e": "Ens → 'ns darrere de verb acabat en vocal: mira'ns."},
      {"q": "Quina forma és correcta?", "o": ["Porta'm al metge.", "Porta-em al metge.", "Portam al metge."], "e": "Em → 'm darrere de verb acabat en vocal: porta'm."},
      {"q": "Quina forma és correcta?", "o": ["Fes-ho.", "Fes'ho.", "Fesho."], "e": "Ho sempre va amb guionet darrere del verb: fes-ho, compra-ho."},
      {"q": "Quina forma és correcta?", "o": ["Obri-la.", "Obri'la.", "Obrila."], "e": "La darrere del verb va amb guionet, no s'apostrofa mai: obri-la."},
      {"q": "Quina forma és correcta?", "o": ["Me'l dones?", "Em el dones?", "M'el dones?"], "e": "Em + el davant de verb → me'l."},
      {"q": "Quina forma és correcta?", "o": ["Se'n va.", "S'en va.", "Es en va."], "e": "Es + en → se'n: se'n va, me'n vaig, te'n vas."},
      {"q": "Quina forma és correcta?", "o": ["M'ho ha dit.", "Me ho ha dit.", "Em ho ha dit."], "e": "Em + ho → m'ho (davant de verb)."},
      {"q": "Quina forma és correcta?", "o": ["Dona-me'l.", "Dona'm el.", "Dona-m'el."], "e": "Darrere del verb: dona-me'l, porta-te'l."},
      {"q": "Quina forma és correcta?", "o": ["Te'n recordes?", "T'en recordes?", "Et en recordes?"], "e": "Et + en → te'n."},
      {"q": "Escriu amb apòstrof: de + aigua.", "a": ["d'aigua"], "e": "D'aigua."},
      {"q": "Escriu la forma correcta: la + universitat.", "a": ["la universitat"], "e": "La universitat (u àtona: no s'apostrofa)."},
      {"q": "Escriu la contracció de per + els.", "a": ["pels"], "e": "Pels."},
      {"q": "Escriu el verb amb el pronom: compra + el.", "a": ["compra'l"], "e": "Compra'l."}
    ]
  },
  {
    "id": "f482c820-b45e-4661-bd1f-af514dcaad47", "type": "b1_fon_oclusives", "sort_order": 7,
    "title": "Oclusives i labiodentals", "name": "Oclusives finals, cu/qu, xc/cc, b/v i la -v- de l'imperfet",
    "content": "Alternances de les oclusives finals en la flexió i la derivació, paraules acabades en oclusiva, els grups cu/qu, les grafies xc i cc, la b i la v, i la -v- de l'imperfet de la primera conjugació (3.2.1).", "icon": "🅱️", "color": "#C8E6C9",
    "exercises": [
      {"q": "Com s'escriu el masculí de «lloba»?", "o": ["llop", "llob", "llopp"], "e": "Llop / lloba: a final de paraula s'escriu p, però en el femení sona b."},
      {"q": "Com s'escriu el masculí de «cunyada»?", "o": ["cunyat", "cunyad", "cuñat"], "e": "Cunyat / cunyada: t final, d en el femení."},
      {"q": "Com s'escriu el masculí de «salada»?", "o": ["salat", "salad", "salatt"], "e": "Salat / salada."},
      {"q": "Com s'escriu el masculí de «verda»?", "o": ["verd", "vert", "berd"], "e": "Verd / verda: la d del femení es manté en el masculí."},
      {"q": "Com s'escriu el masculí de «torta» (no recta)?", "o": ["tort", "tord", "tortt"], "e": "Tort / torta."},
      {"q": "Com s'escriu el femení de «groc»?", "o": ["groga", "groca", "grogua"], "e": "Groc / groga / grocs / grogues."},
      {"q": "Com s'escriu el femení plural de «llarg»?", "o": ["llargues", "llarges", "llargas"], "e": "Llarg / llarga / llargs / llargues: davant de e cal escriure gu."},
      {"q": "Com s'escriu el femení plural de «amic»?", "o": ["amigues", "amiges", "amicues"], "e": "Amic / amiga / amics / amigues."},
      {"q": "«Ell ___ moltes cartes.» (rebre)", "o": ["rep", "reb", "rebe"], "e": "Rebre: ell rep, nosaltres rebem. A final de paraula, p."},
      {"q": "«Nosaltres ___ el paquet demà.» (rebre)", "o": ["rebem", "repem", "rebim"], "e": "Rebem: entre vocals sona i s'escriu b."},
      {"q": "Quina forma és correcta?", "o": ["àrab", "àrap", "àrabe"], "e": "Àrab (àrabs, àraba)."},
      {"q": "Quina forma és correcta?", "o": ["covard", "covart", "cobard"], "e": "Covard (covarda): amb v i d final."},
      {"q": "Quina forma és correcta?", "o": ["sang", "sanc", "sangre"], "e": "Sang: g final (sanguini, sagnar)."},
      {"q": "Quina forma és correcta?", "o": ["fred", "fret", "fredd"], "e": "Fred (freda, fredor)."},
      {"q": "Quina forma és correcta?", "o": ["sord", "sort", "sorth"], "e": "Sord / sorda. Sort és una altra paraula (la bona sort)."},
      {"q": "Quina forma és correcta?", "o": ["tímid", "tímit", "tímide"], "e": "Tímid (tímida): els adjectius en -id s'escriuen amb d."},
      {"q": "Quina forma és correcta?", "o": ["amarg", "amarc", "amargue"], "e": "Amarg / amarga / amargs / amargues."},
      {"q": "Quina forma és correcta?", "o": ["quatre", "cuatre", "quatra"], "e": "Qua- en quatre, quan, qualitat, quadre."},
      {"q": "Quina forma és correcta?", "o": ["quota", "cuota", "qüota"], "e": "Quota (la quota del gimnàs): qu davant de o."},
      {"q": "Quina forma és correcta?", "o": ["cua", "qua", "cüa"], "e": "Cua (del gat, de la fila): c + u vocal + a."},
      {"q": "Quina forma és correcta?", "o": ["evacuar", "evaquar", "evaqüar"], "e": "Evacuar: la u és vocal (e-va-cu-ar)."},
      {"q": "Quina forma és correcta?", "o": ["adequar", "adecuar", "adequär"], "e": "Adequar: qu + a forma diftong (a-de-quar)."},
      {"q": "Quina forma és correcta?", "o": ["excés", "acés", "eccés"], "e": "Excés (ex + cés). Accés és l'entrada a un lloc."},
      {"q": "«L'___ al parc és lliure.»", "o": ["accés", "excés", "exés"], "e": "Accés: entrada. Accedir."},
      {"q": "Quina forma és correcta?", "o": ["excursió", "escursió", "eccursió"], "e": "Excursió."},
      {"q": "Quina forma és correcta?", "o": ["excel·lent", "escel·lent", "eccel·lent"], "e": "Excel·lent: xc i l·l."},
      {"q": "Quina forma és correcta?", "o": ["accident", "axident", "acsident"], "e": "Accident: cc [ks]."},
      {"q": "Quina forma és correcta?", "o": ["acceptar", "aceptar", "axeptar"], "e": "Acceptar: cc."},
      {"q": "Quina forma és correcta?", "o": ["excepte", "eccepte", "esepte"], "e": "Excepte, excepció: xc."},
      {"q": "Quina forma de l'imperfet és correcta?", "o": ["trobava", "trobaba", "trobàva"], "e": "En l'imperfet de la primera conjugació, -v-: trobava, trobaves, trobava."},
      {"q": "«Nosaltres ___ a l'escola junts.» (anar, imperfet)", "o": ["anàvem", "anàbem", "anavem"], "e": "Anàvem: amb v i accent (esdrúixola)."},
      {"q": "«Vosaltres ___ molt de pressa.» (parlar, imperfet)", "o": ["parlàveu", "parlàbeu", "parlaveu"], "e": "Parlàveu: esdrúixola, porta accent."},
      {"q": "Quina forma és correcta?", "o": ["advocat", "abogat", "avogat"], "e": "Advocat (amb dv)."},
      {"q": "Quina forma és correcta?", "o": ["avorrit", "aburrit", "abvorrit"], "e": "Avorrit, avorrir: amb v."},
      {"q": "Quina forma és correcta?", "o": ["govern", "gobern", "gubern"], "e": "Govern, governar: amb v."},
      {"q": "Quina forma és correcta? (tastar o comprovar alguna cosa)", "o": ["provar", "probar", "prouar"], "e": "Provar: amb v. La prova."},
      {"q": "Quina forma és correcta?", "o": ["berenar", "verenar", "merendar"], "e": "Berenar, amb b."},
      {"q": "Escriu el femení de «groc».", "a": ["groga"], "e": "Groga."},
      {"q": "Escriu el masculí de «verda».", "a": ["verd"], "e": "Verd."},
      {"q": "Escriu l'imperfet de «cantar» per a «nosaltres».", "a": ["cantàvem"], "e": "Cantàvem."},
      {"q": "Escriu el femení plural de «llarg».", "a": ["llargues"], "e": "Llargues."}
    ]
  },
  {
    "id": "37c00f03-8d75-42ea-baa1-89cd4efd3442", "type": "b1_fon_alveolars", "sort_order": 8,
    "title": "Consonants alveolars", "name": "c/ç, -ança/-ença, x/cc, -esa/-essa, s/ss i -sc-",
    "content": "La variació c/ç, les paraules en -ança i -ença, el so [ks] i [gz], les paraules en -esa i -essa, els gentilicis en -és, els derivats de les agudes en vocal + s i el grup -sc- (3.2.1).", "icon": "🐍", "color": "#FFF59D",
    "exercises": [
      {"q": "Quin és el plural de «pinça»?", "o": ["pinces", "pinçes", "pinsses"], "e": "Davant de e i i s'escriu c: pinça → pinces."},
      {"q": "Quin és el plural de «plaça»?", "o": ["places", "plaçes", "plasses"], "e": "Plaça → places."},
      {"q": "Quin és el plural de «braç»?", "o": ["braços", "bracos", "brasos"], "e": "Davant de o s'escriu ç: braç → braços."},
      {"q": "Quin és el participi de «véncer»?", "o": ["vençut", "vencut", "venssut"], "e": "Véncer → vençut: davant de u, ç."},
      {"q": "«Nosaltres ___ la porta.» (forçar, present)", "o": ["forcem", "forçem", "forssem"], "e": "Forçar → forcem: davant de e, c."},
      {"q": "«Nosaltres ___ a les huit.» (començar, present)", "o": ["comencem", "començem", "comensem"], "e": "Començar → comencem."},
      {"q": "Quin és el femení de «dolç»?", "o": ["dolça", "dolsa", "dolca"], "e": "Dolç / dolça / dolços / dolces."},
      {"q": "Quina forma és correcta?", "o": ["esperança", "esperanza", "esperansa"], "e": "Esperança: sufix -ança."},
      {"q": "Quina forma és correcta?", "o": ["confiança", "confiansa", "confiánça"], "e": "Confiança."},
      {"q": "Quina forma és correcta?", "o": ["mudança", "mudansa", "mudanza"], "e": "Mudança."},
      {"q": "Quina forma és correcta?", "o": ["complaença", "complaensa", "complaència"], "e": "Complaença: sufix -ença."},
      {"q": "Quina forma és correcta?", "o": ["creença", "creència", "creensa"], "e": "Creença."},
      {"q": "Quina forma és correcta?", "o": ["paciència", "paciença", "pacienssa"], "e": "Paciència, ciència, experiència: -ència (amb accent)."},
      {"q": "Quina forma és correcta?", "o": ["diferència", "diferença", "diferénsia"], "e": "Diferència (però diferent)."},
      {"q": "Quina forma és correcta? (impost que es paga)", "o": ["taxa", "tassa", "tacsa"], "e": "Taxa [ks]: impost. Tassa: recipient per a beure."},
      {"q": "Quina forma és correcta?", "o": ["èxit", "écsit", "èccit"], "e": "Èxit: x [gz]."},
      {"q": "Quina forma és correcta?", "o": ["exèrcit", "egzèrcit", "exèrsit"], "e": "Exèrcit: x [gz], c davant de i."},
      {"q": "Quina forma és correcta?", "o": ["acció", "axió", "accsió"], "e": "Acció: cc [ks] davant de i."},
      {"q": "Quina forma és correcta?", "o": ["direcció", "direxió", "direció"], "e": "Direcció (i director): cc."},
      {"q": "Quina forma és correcta?", "o": ["exacte", "eczacte", "exaccte"], "e": "Exacte: x [gz]."},
      {"q": "Quina forma és correcta?", "o": ["bellesa", "bellessa", "belleza"], "e": "Noms abstractes derivats d'adjectius: -esa (bellesa, tristesa, timidesa, riquesa)."},
      {"q": "Quina forma és correcta?", "o": ["timidesa", "timidessa", "timidez"], "e": "Timidesa (de tímid)."},
      {"q": "Quina forma és correcta?", "o": ["marquesa", "marquessa", "marqueza"], "e": "Marquesa, princesa: -esa."},
      {"q": "Quina forma és correcta?", "o": ["alcaldessa", "alcaldesa", "alcaldeza"], "e": "Alcaldessa, metgessa, comtessa: -essa."},
      {"q": "Quina forma és correcta?", "o": ["metgessa", "metgesa", "metjessa"], "e": "Metgessa."},
      {"q": "Quina forma és correcta?", "o": ["comtessa", "comtesa", "condesa"], "e": "Comtessa."},
      {"q": "Quin és el femení de «xinés»?", "o": ["xinesa", "xinessa", "xineza"], "e": "Xinés / xinesa / xinesos / xineses: s sonora."},
      {"q": "Quin és el plural masculí de «xinés»?", "o": ["xinesos", "xinessos", "xinés"], "e": "Xinesos."},
      {"q": "Quin és el plural masculí de «anglés»?", "o": ["anglesos", "anglessos", "anglés"], "e": "Anglés / anglesa / anglesos / angleses."},
      {"q": "Quin és el femení de «gos»?", "o": ["gossa", "gosa", "gossia"], "e": "Gos → gossa (s sorda: ss)."},
      {"q": "Quin és el plural de «pas»?", "o": ["passos", "pasos", "pàssos"], "e": "Pas → passos."},
      {"q": "Quin és el femení de «calorós»?", "o": ["calorosa", "calorossa", "caloroza"], "e": "Calorós → calorosa (s sonora: s)."},
      {"q": "Quin és el plural de «mes»?", "o": ["mesos", "messos", "meses"], "e": "Mes → mesos."},
      {"q": "Quin és el femení de «gras»?", "o": ["grassa", "grasa", "graça"], "e": "Gras → grassa."},
      {"q": "Quin és el plural de «interés»?", "o": ["interessos", "interesos", "interessus"], "e": "Interés → interessos."},
      {"q": "Quina forma és correcta?", "o": ["piscina", "pissina", "picina"], "e": "Piscina: grup -sc-."},
      {"q": "Quina forma és correcta?", "o": ["escena", "esena", "essena"], "e": "Escena: -sc-."},
      {"q": "Quina forma és correcta?", "o": ["ascensor", "asensor", "assensor"], "e": "Ascensor (i ascens): -sc-."},
      {"q": "Quina forma és correcta?", "o": ["adolescent", "adolesent", "adolessent"], "e": "Adolescent: -sc-."},
      {"q": "Escriu el plural de «plaça».", "a": ["places"], "e": "Places."},
      {"q": "Escriu el femení de «metge».", "a": ["metgessa"], "e": "Metgessa."},
      {"q": "Escriu el femení de «gos».", "a": ["gossa"], "e": "Gossa."},
      {"q": "Escriu el nom abstracte de «trist».", "a": ["tristesa", "tristor"], "e": "Tristesa (o tristor)."}
    ]
  },
  {
    "id": "ce18cc3f-74e3-44b7-9613-2853cb3b3290", "type": "b1_fon_palatals", "sort_order": 9,
    "title": "Consonants palatals", "name": "g/j, tg/tj, ig, x/tx i les seues alternances",
    "content": "Les palatals g, j, tg, tj i ig, les excepcions de la j davant de e i i, la norma de la x i la tx, la variació en la flexió (boja/boges, platja/platges), els derivats de -tx i -ig i la pronunciació de la x (3.2.1).", "icon": "🌊", "color": "#B3E5FC",
    "exercises": [
      {"q": "Quina forma és correcta?", "o": ["gener", "jener", "gené"], "e": "Davant de e i i, normalment g: gener, gent, girar."},
      {"q": "Quina forma és correcta?", "o": ["jove", "gove", "jobe"], "e": "Davant de a, o, u, sempre j: jove, juny, jardí."},
      {"q": "Quina forma és correcta?", "o": ["objecte", "obgecte", "objete"], "e": "Excepció: j davant de e en objecte, projecte, subjecte, trajecte."},
      {"q": "Quina forma és correcta?", "o": ["Jesús", "Gesús", "Jesus"], "e": "Excepció: Jesús, jersei, injecció."},
      {"q": "Quina forma és correcta?", "o": ["projecte", "progecte", "projete"], "e": "Projecte: j davant de e (excepció)."},
      {"q": "Quina forma és correcta?", "o": ["injecció", "ingecció", "injeció"], "e": "Injecció: j (excepció) i cc."},
      {"q": "Quina forma és correcta?", "o": ["platja", "plaja", "platga"], "e": "Entre vocals, tj davant de a, o, u: platja."},
      {"q": "Quin és el plural de «platja»?", "o": ["platges", "platjes", "plages"], "e": "Davant de e: tg. Platja → platges."},
      {"q": "Quin és el plural de «mitja» (peça de roba)?", "o": ["mitges", "mitjes", "miges"], "e": "Mitja → mitges."},
      {"q": "Quin és el femení plural de «boig»?", "o": ["boges", "bojes", "botges"], "e": "Boig / boja / bojos / boges."},
      {"q": "Quin és el masculí plural de «boig»?", "o": ["bojos", "boigs", "bogos"], "e": "Bojos: davant de o, j."},
      {"q": "Quin és el plural de «pluja»?", "o": ["pluges", "plujes", "pluetges"], "e": "Pluja → pluges."},
      {"q": "Quin és el plural de «taronja»?", "o": ["taronges", "taronjes", "tarongues"], "e": "Taronja → taronges."},
      {"q": "«Nosaltres ___ a les dues.» (menjar, present)", "o": ["mengem", "menjem", "mengim"], "e": "Menjar → mengem: davant de e, g."},
      {"q": "«Nosaltres ___ per l'escala.» (pujar, present)", "o": ["pugem", "pujem", "putgem"], "e": "Pujar → pugem."},
      {"q": "Quina forma és correcta?", "o": ["metge", "metje", "mege"], "e": "Tg davant de e: metge, rellotge, viatge, fetge, jutge."},
      {"q": "Quina forma és correcta?", "o": ["pitjor", "pitgor", "pijor"], "e": "Tj davant de o: pitjor."},
      {"q": "Quina forma és correcta?", "o": ["raig", "raitx", "rach"], "e": "A final de paraula, darrere de vocal, -ig: raig, fuig, roig, mig, maig."},
      {"q": "Quina forma és correcta? (ell se'n va corrent)", "o": ["fuig", "fuitx", "fugi"], "e": "Fugir: ell fuig."},
      {"q": "Quin és el femení de «lleig»?", "o": ["lletja", "lleja", "lleitja"], "e": "Lleig → lletja (tj, perquè sona [dʒ])."},
      {"q": "Quin és el nom derivat de «roig» que indica el color?", "o": ["rojor", "rotjor", "roigor"], "e": "Roig → roja, rojor (j)."},
      {"q": "Quin és el verb derivat de «desig»?", "o": ["desitjar", "desijar", "desigar"], "e": "Desig → desitjar."},
      {"q": "Quin és el verb derivat de «passeig»?", "o": ["passejar", "passetjar", "passeigar"], "e": "Passeig → passejar."},
      {"q": "Quina forma és correcta?", "o": ["planxa", "plantxa", "plancha"], "e": "Darrere de consonant, x: planxa, panxa, marxa, punxa."},
      {"q": "Quina forma és correcta? (targeta per a anotar dades o peça d'un joc)", "o": ["fitxa", "ficha", "fitja"], "e": "Entre vocals, tx: fitxa, cotxe, butxaca, motxilla."},
      {"q": "Quina forma és correcta?", "o": ["xarop", "txarop", "charop"], "e": "A començament de paraula, x: xarop, xica, xocolate, xufa."},
      {"q": "Quina forma és correcta?", "o": ["motxilla", "moxilla", "mochilla"], "e": "Motxilla: tx entre vocals."},
      {"q": "Quina forma és correcta?", "o": ["marxar", "martxar", "marchar"], "e": "Marxar: x darrere de r."},
      {"q": "Quin és el plural de «despatx»?", "o": ["despatxos", "despatxs", "despaxos"], "e": "Despatx → despatxos."},
      {"q": "Quin és el verb derivat de «escabetx»?", "o": ["escabetxar", "escabexar", "escabetjar"], "e": "Escabetx → escabetxar."},
      {"q": "Quin és l'adjectiu derivat de «capritx»?", "o": ["capritxós", "caprixós", "capritjós"], "e": "Capritx → capritxós."},
      {"q": "En valencià, com es pronuncia normalment la x inicial de «xic»?", "o": ["[tʃ], com «tx»", "[ks]", "com la jota castellana"], "e": "La x inicial se sol pronunciar africada [tʃ]: xic, xarop."},
      {"q": "Com es pronuncia la x de «Xàtiva»?", "o": ["[ʃ], com la x de «caixa»", "[ks], com en «taxi»", "[gz], com en «examen»"], "e": "En el nom de Xàtiva es manté el so fricatiu [ʃ], com en «caixa» o «peix»."},
      {"q": "Com es pronuncia la x de «panxa»?", "o": ["[tʃ], com «tx»", "[ks]", "[ʃ] suau"], "e": "Darrere de consonant, la x sona [tʃ]: panxa, planxa."},
      {"q": "Escriu el plural de «platja».", "a": ["platges"], "e": "Platges."},
      {"q": "Escriu el femení de «lleig».", "a": ["lletja"], "e": "Lletja."},
      {"q": "Escriu la forma correcta: ___ (fitxa o ficha).", "a": ["fitxa"], "e": "Fitxa."},
      {"q": "Escriu el plural de «taronja».", "a": ["taronges"], "e": "Taronges."}
    ]
  },
  {
    "id": "7baaddb7-7eaf-4f14-bfc3-b2e2e1c04964", "type": "b1_fon_laterals_h", "sort_order": 10,
    "title": "Laterals, nasals, ròtiques i la h", "name": "l·l, tl/tll, m davant de b/p/m, -ny, r/rr i la h",
    "content": "La l·l en al·l-, col·l-, il·l-, -el·la, -il·la; les grafies tl/tll; la m davant de b, p, m; la -ny final; la r i la rr i la -r final; la h inicial i intercalada i el verb haver (3.2.1).", "icon": "🌙", "color": "#D1C4E9",
    "exercises": [
      {"q": "Quina forma és correcta?", "o": ["al·lèrgia", "alèrgia", "allèrgia"], "e": "Al·l-: al·lèrgia, al·lusió."},
      {"q": "Quina forma és correcta?", "o": ["col·laborar", "colaborar", "collaborar"], "e": "Col·l-: col·laborar, col·legi, col·lecció, col·locar."},
      {"q": "Quina forma és correcta?", "o": ["il·luminar", "iluminar", "illuminar"], "e": "Il·l-: il·luminar, il·lusió, il·legal, il·lustrar."},
      {"q": "Quina forma és correcta?", "o": ["il·legal", "ilegal", "illegal"], "e": "Il·legal (in- + legal)."},
      {"q": "Quina forma és correcta?", "o": ["novel·la", "novela", "novella"], "e": "-el·la: novel·la, cel·la, parcel·la."},
      {"q": "Quina forma és correcta?", "o": ["pastil·la", "pastilla", "pastila"], "e": "-il·la: pastil·la, vil·la."},
      {"q": "Quina forma és correcta?", "o": ["intel·ligent", "inteligent", "intelligent"], "e": "Intel·ligent, excel·lent, pel·lícula, tranquil·la."},
      {"q": "Quina forma és correcta?", "o": ["tranquil·la", "tranquila", "tranquilla"], "e": "Tranquil → tranquil·la."},
      {"q": "Quina forma és correcta?", "o": ["ametla", "ametl·la", "ametlla"], "e": "Ametla (i ametler): grup tl."},
      {"q": "Quina forma és correcta?", "o": ["ratlla", "ralla", "rat·lla"], "e": "Ratlla (i ratllar): grup tll."},
      {"q": "Quina forma és correcta?", "o": ["espatla", "espal·la", "espalla"], "e": "Espatla (o muscle): grup tl."},
      {"q": "Quina forma és correcta?", "o": ["bitllet", "billet", "bit·let"], "e": "Bitllet: grup tll."},
      {"q": "Quina forma és correcta?", "o": ["vetlar", "vel·lar", "vellar"], "e": "Vetlar (passar la nit desperts), la vetla."},
      {"q": "Quina forma és correcta?", "o": ["ambulància", "anbulància", "amvulància"], "e": "Davant de b i p s'escriu m: ambulància, temps, camp."},
      {"q": "Quina forma és correcta?", "o": ["combinar", "conbinar", "convinar"], "e": "Combinar: m davant de b."},
      {"q": "Quina forma és correcta?", "o": ["immens", "inmens", "imens"], "e": "Immens: in- davant de m es fa im-: immens, immediat, immigrant."},
      {"q": "Quina forma és correcta?", "o": ["immediat", "inmediat", "imediat"], "e": "Immediat."},
      {"q": "Quina forma és correcta?", "o": ["enviar", "emviar", "embiar"], "e": "Davant de v s'escriu n: enviar, convidar, invent, canviar."},
      {"q": "Quina forma és correcta?", "o": ["convidar", "comvidar", "combidar"], "e": "Convidar: n davant de v."},
      {"q": "Quina forma és correcta?", "o": ["umbracle", "unbracle", "umbracl·le"], "e": "Umbracle (cobert per a fer ombra): m davant de b."},
      {"q": "Quina forma és correcta?", "o": ["disseny", "diseny", "dissenyo"], "e": "Disseny (dissenyar): -ny final."},
      {"q": "Quina forma és correcta? (mà tancada)", "o": ["puny", "punyo", "puñ"], "e": "Puny: -ny final. Tindre el cor en un puny."},
      {"q": "Quina forma és correcta? (inflor al cap per un colp)", "o": ["bony", "bonyo", "boni"], "e": "Bony: -ny final."},
      {"q": "Quina forma és correcta? (queixa de dolor)", "o": ["plany", "planyo", "plañ"], "e": "Plany (planyer-se)."},
      {"q": "En quina paraula la r és forta encara que s'escriu amb una sola r?", "o": ["Enric", "cara", "pera"], "e": "Després de n, l o s, la r és forta però s'escriu simple: Enric, honra, Israel."},
      {"q": "Quina forma és correcta?", "o": ["Enric", "Enrric", "Henric"], "e": "Enric: r simple darrere de n."},
      {"q": "Quina forma és correcta?", "o": ["honra", "honrra", "onra"], "e": "Honra: r simple darrere de n, i h inicial."},
      {"q": "Quina forma és correcta?", "o": ["rosa", "rrosa", "hrosa"], "e": "A començament de paraula, sempre r simple (que sona forta)."},
      {"q": "Quina forma és correcta?", "o": ["carrers", "carres", "carrés"], "e": "La -r final de «carrer» s'escriu sempre, encara que en alguns parlars no se senta, i es manté en el plural."},
      {"q": "Quina forma és correcta?", "o": ["senyors", "senyós", "senyoros"], "e": "Senyor → senyors."},
      {"q": "Quina forma és correcta?", "o": ["harmonia", "armonia", "harmonía"], "e": "Harmonia: amb h inicial."},
      {"q": "Quina forma és correcta?", "o": ["hui", "ui", "huy"], "e": "Hui s'escriu amb h. També huit."},
      {"q": "Quina forma és correcta?", "o": ["ahir", "aïr", "air"], "e": "Ahir: h intercalada."},
      {"q": "Quina forma és correcta?", "o": ["vehicle", "veicle", "vehícle"], "e": "Vehicle: h intercalada."},
      {"q": "Quina forma és correcta?", "o": ["prohibit", "proibit", "prohibít"], "e": "Prohibit, prohibir: h intercalada."},
      {"q": "Quina forma és correcta?", "o": ["vehement", "veement", "vehemènt"], "e": "Vehement: h intercalada."},
      {"q": "Quina forma és correcta?", "o": ["ou", "hou", "huevo"], "e": "Ou s'escriu sense h (cast. «huevo»). També os, orfe, ós, ermita, orxata."},
      {"q": "Quina forma és correcta?", "o": ["orxata", "horxata", "horchata"], "e": "Orxata: sense h."},
      {"q": "Quina forma és correcta?", "o": ["M'ha agradat molt.", "M'a agradat molt.", "Ma agradat molt."], "e": "En els temps compostos, el verb haver: ha agradat, has vist, he anat."},
      {"q": "Quina forma és correcta?", "o": ["Ha anat a València.", "A anat a València.", "Ha anat ha València."], "e": "Ha (verb haver) amb h; a (preposició) sense h."},
      {"q": "Quina forma és correcta?", "o": ["Hi ha molta gent.", "I ha molta gent.", "Hi a molta gent."], "e": "Hi ha: pronom hi + verb haver."},
      {"q": "Escriu amb la grafia correcta: «colegi».", "a": ["col·legi"], "e": "Col·legi."},
      {"q": "Escriu amb la grafia correcta: «inmens».", "a": ["immens"], "e": "Immens."},
      {"q": "Escriu amb la grafia correcta: «air» (el dia anterior a hui).", "a": ["ahir"], "e": "Ahir."},
      {"q": "Escriu amb la grafia correcta: «diseño» en valencià.", "a": ["disseny"], "e": "Disseny."}
    ]
  },
  {
    "id": "b556615d-c4c5-4daa-b132-d8a87ed6a179", "type": "b1_fon_majuscules", "sort_order": 11,
    "title": "Majúscules i minúscules", "name": "Normes bàsiques de l'ús de les majúscules",
    "content": "Quan s'escriu majúscula (inici de text i de frase, noms propis, festes, institucions, títols, sigles i tractaments abreujats) i quan minúscula (dies, mesos, llengües, gentilicis, càrrecs i noms comuns geogràfics) (3.2.1).", "icon": "🔠", "color": "#FFE082",
    "exercises": [
      {"q": "Quina frase està ben escrita?", "o": ["Ens veiem el dilluns 3 de març.", "Ens veiem el Dilluns 3 de Març.", "Ens veiem el dilluns 3 de Març."], "e": "Els dies de la setmana i els mesos s'escriuen amb minúscula."},
      {"q": "Quina frase està ben escrita?", "o": ["A la primavera fa bon temps.", "A la Primavera fa bon temps.", "a la primavera fa bon temps."], "e": "Les estacions, amb minúscula; però la frase comença amb majúscula."},
      {"q": "Quina frase està ben escrita?", "o": ["Parle valencià i anglés.", "Parle Valencià i Anglés.", "Parle valencià i Anglés."], "e": "Els noms de llengües s'escriuen amb minúscula."},
      {"q": "Quina frase està ben escrita?", "o": ["Els valencians celebren el 9 d'Octubre.", "Els Valencians celebren el 9 d'octubre.", "Els valencians celebren el 9 d'octubre."], "e": "Els gentilicis, amb minúscula; les dates que donen nom a una festa o a un fet històric, amb majúscula: el 9 d'Octubre."},
      {"q": "Quina frase està ben escrita?", "o": ["Per Nadal anirem a Morella.", "Per nadal anirem a Morella.", "Per Nadal anirem a morella."], "e": "Les festes (Nadal, Pasqua, Falles) i els noms de lloc, amb majúscula."},
      {"q": "Quina frase està ben escrita?", "o": ["El riu Túria passa per València.", "El Riu Túria passa per València.", "El riu túria passa per València."], "e": "El nom comú (riu, serra, mar) amb minúscula; el nom propi, amb majúscula."},
      {"q": "Quina és correcta?", "o": ["la serra de Mariola", "la Serra de Mariola", "la serra de mariola"], "e": "Nom comú geogràfic en minúscula: la serra de Mariola, el cap de la Nau."},
      {"q": "Quina és correcta?", "o": ["el mar Mediterrani", "el Mar Mediterrani", "el mar mediterrani"], "e": "El mar Mediterrani."},
      {"q": "Quina és correcta?", "o": ["Visc en el carrer de la Pau.", "Visc en el Carrer de la Pau.", "Visc en el carrer de la pau."], "e": "Carrer, plaça, avinguda amb minúscula; el nom propi, amb majúscula."},
      {"q": "Quina és correcta?", "o": ["la Generalitat Valenciana", "la generalitat valenciana", "la Generalitat valenciana"], "e": "Els noms d'institucions porten majúscula en totes les paraules significatives."},
      {"q": "Quina és correcta?", "o": ["la Universitat de València", "la universitat de València", "la Universitat de valència"], "e": "Nom propi d'institució: la Universitat de València."},
      {"q": "Quina és correcta?", "o": ["L'alcaldessa ha inaugurat la biblioteca.", "L'Alcaldessa ha inaugurat la biblioteca.", "l'alcaldessa ha inaugurat la Biblioteca."], "e": "Els càrrecs (alcaldessa, president, rei) s'escriuen amb minúscula."},
      {"q": "Quina és correcta?", "o": ["el president de la Generalitat", "el President de la Generalitat", "el president de la generalitat"], "e": "Càrrec en minúscula; institució en majúscula."},
      {"q": "Quina és correcta?", "o": ["Sr. Martí", "sr. Martí", "Sr. martí"], "e": "Els tractaments abreujats van amb majúscula: Sr., Sra., Dr. Escrits sencers, amb minúscula: el senyor Martí."},
      {"q": "Quina és correcta?", "o": ["el senyor Martí", "el Senyor Martí", "El senyor martí"], "e": "Tractament no abreujat, amb minúscula."},
      {"q": "Quin és el títol ben escrit?", "o": ["He llegit «La plaça del Diamant».", "He llegit «La Plaça Del Diamant».", "He llegit «la plaça del diamant»."], "e": "En els títols d'obres, majúscula només en la primera paraula i en els noms propis."},
      {"q": "Quina és correcta?", "o": ["Viu al nord de Castelló.", "Viu al Nord de Castelló.", "Viu al nord de castelló."], "e": "Els punts cardinals, amb minúscula, excepte quan formen part d'un nom propi (Amèrica del Nord)."},
      {"q": "Quina és correcta?", "o": ["Ha viatjat a Amèrica del Nord.", "Ha viatjat a Amèrica del nord.", "Ha viatjat a amèrica del Nord."], "e": "Part d'un nom propi: Amèrica del Nord."},
      {"q": "Quina és correcta?", "o": ["la UE (Unió Europea)", "la ue (unió europea)", "la Ue (Unió europea)"], "e": "Les sigles, en majúscules."},
      {"q": "Després d'un signe d'interrogació que acaba una frase, la paraula següent...", "o": ["va amb majúscula", "va amb minúscula", "va entre parèntesis"], "e": "«On vas? Vinc amb tu.»: si ? o ! tanca la frase, majúscula."},
      {"q": "Després de dos punts, normalment s'escriu...", "o": ["minúscula, excepte si és una cita o el començament d'una carta", "sempre majúscula", "sempre un número"], "e": "«Necessitem tres coses: farina, ous i sucre.» Però va amb majúscula si és una cita literal (Va dir: «Vinc demà.») o després de la salutació d'una carta."},
      {"q": "Quina és correcta?", "o": ["Me'n vaig a les Falles de València.", "Me'n vaig a les falles de València.", "Me'n vaig a les Falles de valència."], "e": "El nom de la festa, en majúscula: les Falles. (El monument faller és «una falla», en minúscula.)"},
      {"q": "Quina és correcta?", "o": ["La falla del meu barri és molt gran.", "La Falla del meu barri és molt gran.", "la falla del meu barri és molt gran."], "e": "El monument (una falla) és un nom comú: minúscula."},
      {"q": "Quina és correcta?", "o": ["el segle XV", "el segle xv", "el Segle XV"], "e": "Els segles, en xifres romanes majúscules; «segle», en minúscula."},
      {"q": "Quina és correcta?", "o": ["la Comunitat Valenciana", "la comunitat valenciana", "la comunitat Valenciana"], "e": "Nom propi del territori: la Comunitat Valenciana."},
      {"q": "Quina és correcta? (el planeta)", "o": ["La Terra gira al voltant del Sol.", "La terra gira al voltant del sol.", "la Terra gira al voltant del Sol."], "e": "Els noms d'astres i planetes com a noms propis: la Terra, el Sol, la Lluna. «Terra» com a sòl: minúscula."},
      {"q": "Quina és correcta?", "o": ["Plantem tomaques a la terra de l'hort.", "Plantem tomaques a la Terra de l'hort.", "Plantem Tomaques a la terra de l'hort."], "e": "Terra com a sòl és un nom comú: minúscula."},
      {"q": "Quina és correcta?", "o": ["el rei Jaume I", "el Rei Jaume I", "el rei jaume I"], "e": "El càrrec (rei) en minúscula; el nom propi, amb majúscula."},
      {"q": "Quina és correcta?", "o": ["l'Edat Mitjana", "l'edat mitjana", "l'Edat mitjana"], "e": "Els noms de períodes històrics porten majúscula: l'Edat Mitjana, el Renaixement."},
      {"q": "Quina és correcta?", "o": ["el Museu de Belles Arts", "el museu de belles arts", "el Museu de belles arts"], "e": "Nom propi d'un museu o d'un edifici: majúscula en les paraules significatives."},
      {"q": "Quina és correcta?", "o": ["Han aprovat la llei en les Corts Valencianes.", "Han aprovat la Llei en les corts valencianes.", "Han aprovat la llei en les corts Valencianes."], "e": "Institució: les Corts Valencianes. «Llei», nom comú, en minúscula."},
      {"q": "Quina és correcta?", "o": ["Hem anat a l'ajuntament a fer un tràmit.", "Hem anat a l'Ajuntament a Fer un tràmit.", "hem anat a l'ajuntament a fer un tràmit."], "e": "Quan es referix a l'edifici, nom comú (l'ajuntament); quan és la institució amb el nom (l'Ajuntament de Gandia), majúscula."},
      {"q": "Quina és correcta?", "o": ["la Mare de Déu dels Desemparats", "la mare de déu dels desemparats", "la Mare de déu dels desemparats"], "e": "Noms religiosos propis amb majúscula."},
      {"q": "Com s'escriu el nom del mes dins d'una frase?", "o": ["gener", "Gener", "GENER"], "e": "Els mesos, amb minúscula."},
      {"q": "Com s'escriu el nom de la festa dins d'una frase?", "o": ["Nadal", "nadal", "NADAL"], "e": "Les festes, amb majúscula."},
      {"q": "Com s'escriu el nom de la llengua dins d'una frase?", "o": ["valencià", "Valencià", "VALENCIÀ"], "e": "Les llengües, amb minúscula."},
      {"q": "Escriu l'abreviatura de «senyora».", "a": ["Sra.", "Sra"], "e": "Sra."}
    ]
  },
  {
    "id": "5c7449fa-9786-46ef-ad08-f264cf30ec59", "type": "b1_fon_puntuacio", "sort_order": 12,
    "title": "Signes de puntuació", "name": "Punt i coma, dos punts, punts suspensius i parèntesis",
    "content": "L'ús del punt i coma, dels dos punts, dels punts suspensius i dels parèntesis (3.2.1).", "icon": "❗", "color": "#F8BBD0",
    "exercises": [
      {"q": "Quina frase usa bé el punt i coma?", "o": ["A Pau li agrada el futbol, el bàsquet i el tennis; a Marta, la música i el cine.", "A Pau; li agrada el futbol.", "A Pau li agrada; el futbol, el bàsquet i el tennis."], "e": "El punt i coma separa parts d'una enumeració que ja tenen comes dins."},
      {"q": "Per a què servix el punt i coma?", "o": ["Per a separar elements llargs o que ja tenen comes, amb una pausa més forta que la coma", "Per a acabar un text", "Per a fer una pregunta"], "e": "Pausa més llarga que la coma i més curta que el punt."},
      {"q": "Quina frase usa bé el punt i coma davant d'un connector?", "o": ["Vam estudiar molt durant tot el trimestre; tanmateix, no vam aprovar.", "Vam estudiar; molt.", "Vam; estudiar molt."], "e": "Davant de connectors com tanmateix, per tant, no obstant això, en frases llargues."},
      {"q": "Quina frase usa bé els dos punts?", "o": ["Necessitem tres coses: farina, ous i sucre.", "Necessitem: tres coses farina, ous i sucre.", "Necessitem tres: coses farina, ous i sucre."], "e": "Els dos punts introduïxen una enumeració anunciada."},
      {"q": "Quina frase usa bé els dos punts per a una cita?", "o": ["Ma mare va dir: «Torna prompte.»", "Ma mare: va dir «Torna prompte.»", "Ma mare va: dir «Torna prompte.»"], "e": "Davant d'una cita literal, dos punts i cometes."},
      {"q": "Com comença correctament una carta formal?", "o": ["Benvolguda senyora:", "Benvolguda senyora;", "Benvolguda: senyora"], "e": "Després de la salutació d'una carta, dos punts (o coma en cartes personals)."},
      {"q": "Quina frase usa els dos punts per a introduir una explicació o una causa?", "o": ["No vindrà a la festa: està malalt.", "No: vindrà a la festa.", "No vindrà: a la festa."], "e": "Els dos punts poden introduir una conseqüència, una causa o una conclusió."},
      {"q": "Quina frase usa bé els punts suspensius?", "o": ["Al mercat hi havia pomes, peres, taronges...", "Al mercat hi havia... pomes, peres.", "Al mercat... hi... havia."], "e": "Indiquen una enumeració inacabada."},
      {"q": "Quina és la forma correcta?", "o": ["pomes, peres, taronges, etc.", "pomes, peres, taronges, etc...", "pomes, peres, taronges... etc."], "e": "No es posen punts suspensius després de «etc.»: tots dos indiquen el mateix."},
      {"q": "Quants punts tenen els punts suspensius?", "o": ["Sempre tres", "Dos o tres", "Tants com vulgues"], "e": "Sempre tres (...)."},
      {"q": "Quina frase expressa dubte o suspens amb punts suspensius?", "o": ["Doncs... no sé què dir-te.", "Doncs no sé què dir-te.", "Doncs, no sé què dir-te."], "e": "Els punts suspensius poden indicar dubte, vacil·lació o suspens."},
      {"q": "Quina frase deixa una frase feta inacabada amb punts suspensius?", "o": ["Ja saps el que diuen: a qui matina...", "Ja saps el que diuen: a qui matina Déu l'ajuda.", "Ja saps el que diuen."], "e": "Quan el lector pot completar una frase coneguda, es tallen amb punts suspensius."},
      {"q": "Què indiquen els punts suspensius entre parèntesis (...) dins d'una cita?", "o": ["Que s'ha omés un tros del text", "Que l'autor dubtava", "Que la cita és falsa"], "e": "(...) o [...]: s'ha suprimit una part del text citat."},
      {"q": "Quina frase usa bé els parèntesis?", "o": ["La Dama d'Elx (segle V aC) és una escultura ibera.", "La Dama (d'Elx segle V aC) és una escultura ibera.", "(La Dama d'Elx) segle V aC és una escultura ibera."], "e": "Els parèntesis tanquen informació complementària: dates, aclariments."},
      {"q": "Quina frase usa bé els parèntesis per a una sigla?", "o": ["Estudia a la Universitat de València (UV).", "Estudia a la (Universitat de València) UV.", "Estudia a la Universitat (de València UV)."], "e": "Els parèntesis poden contindre la sigla o el seu desenvolupament."},
      {"q": "On va el punt final quan la frase acaba amb un parèntesi?", "o": ["Darrere del parèntesi: ...(UV).", "Davant del parèntesi: ....(UV)", "No cal punt"], "e": "Si el parèntesi forma part de la frase, el punt va darrere: Estudia a la UV (Universitat de València)."},
      {"q": "Quina frase usa els parèntesis per a una aclaració?", "o": ["El meu cosí (el fill de la tia Remei) viu a Lió.", "El meu cosí el fill (de la tia Remei) viu a Lió.", "El meu (cosí el fill de la tia Remei viu a Lió)."], "e": "Aclaració que es podria llevar sense que la frase perdera el sentit."},
      {"q": "Quins signes es poden usar en lloc dels parèntesis per a una aclaració?", "o": ["Els guions llargs o les comes", "Els punts suspensius", "Els signes d'interrogació"], "e": "El meu cosí —el fill de la tia Remei— viu a Lió. O amb comes."},
      {"q": "Quines cometes es recomanen en valencià per a citar?", "o": ["Les baixes o angulars: « »", "Només les simples: ' '", "Cap: no se'n posen"], "e": "Cometes baixes « »; dins d'elles, altes “ ” i després simples ‘ ’."},
      {"q": "Quina frase està ben puntuada?", "o": ["Volíem anar a la platja; però, com que plovia, ens vam quedar a casa.", "Volíem anar; a la platja però com que plovia ens vam quedar a casa.", "Volíem: anar a la platja però com que plovia, ens vam quedar a casa."], "e": "Punt i coma davant de «però» en una frase llarga amb comes."},
      {"q": "Quin signe falta? «Hi ha dues opcions ___ quedar-nos o eixir.»", "o": ["dos punts (:)", "punt i coma (;)", "punts suspensius (...)"], "e": "Dos punts per a anunciar les opcions."},
      {"q": "Quin signe falta? «Si vens a la festa, porta beguda ___ si no vens, avisa'm.»", "o": ["punt i coma (;)", "dos punts (:)", "parèntesis"], "e": "Punt i coma entre dues parts llargues i relacionades."},
      {"q": "Quina frase usa bé els dos punts per a una conclusió?", "o": ["Ha plogut tota la setmana: el pantà està ple.", "Ha plogut: tota la setmana el pantà està ple.", "Ha: plogut tota la setmana."], "e": "Els dos punts poden introduir la conseqüència del que s'ha dit."},
      {"q": "Quina frase usa bé els dos punts després d'una expressió com «per exemple»?", "o": ["Hi ha moltes festes valencianes, per exemple: les Falles, les Fogueres i la Magdalena.", "Hi ha moltes: festes valencianes, per exemple les Falles.", "Hi ha moltes festes valencianes per: exemple les Falles."], "e": "Per exemple, és a dir, com ara... poden anar seguits de dos punts davant d'una enumeració."},
      {"q": "Quina frase usa bé el punt i coma en una llista de dades?", "o": ["Han vingut Joan, de Gandia; Marta, d'Alcoi; i Pere, de Xàtiva.", "Han vingut Joan; de Gandia, Marta; d'Alcoi.", "Han vingut; Joan, de Gandia, Marta, d'Alcoi."], "e": "Cada element ja té una coma: se separen amb punt i coma."},
      {"q": "Quina frase usa bé els punts suspensius per a expressar sorpresa?", "o": ["I quan vaig obrir la porta... estaven tots allí!", "I quan vaig... obrir la porta estaven tots allí!", "I quan vaig obrir la porta estaven... tots... allí."], "e": "Els punts suspensius creen expectació abans d'una sorpresa."},
      {"q": "Quina frase usa bé els parèntesis per a una forma alternativa?", "o": ["Es busca dependent(a) amb experiència.", "Es busca (dependent) a amb experiència.", "Es busca dependent a(mb experiència)."], "e": "En anuncis i formularis, els parèntesis poden indicar la forma femenina."},
      {"q": "Quina frase usa bé els parèntesis per a una dada numèrica?", "o": ["L'Albufera (unes 21.000 hectàrees de parc natural) està al sud de València.", "L'Albufera unes (21.000 hectàrees) de parc natural està al sud de València.", "(L'Albufera unes 21.000 hectàrees) de parc natural."], "e": "Dades complementàries entre parèntesis."},
      {"q": "Quina frase NO necessita punt i coma?", "o": ["Vine prompte.", "Ell estudia medicina; ella, dret.", "Uns es queden; els altres se'n van."], "e": "Una frase curta i simple no necessita punt i coma."},
      {"q": "Quin signe falta? «El metge li ho va dir clar ___ ha de deixar de fumar.»", "o": ["dos punts (:)", "punt i coma (;)", "parèntesis"], "e": "Els dos punts introduïxen el contingut del que s'ha dit."},
      {"q": "Quin signe es posa després de «Benvolgut senyor» en una carta formal?", "o": ["dos punts (:)", "punt i coma (;)", "punts suspensius (...)"], "e": "Dos punts."},
      {"q": "Quin signe indica que una enumeració continua, sense escriure «etc.»?", "o": ["els punts suspensius (...)", "el punt i coma (;)", "els dos punts (:)"], "e": "Punts suspensius."},
      {"q": "Quina frase usa bé els parèntesis per a indicar l'any?", "o": ["Joanot Martorell (segle XV) va escriure el «Tirant».", "Joanot (Martorell segle XV) va escriure el «Tirant».", "Joanot Martorell segle (XV) va escriure el «Tirant»."], "e": "Dades complementàries, com dates o segles, entre parèntesis."},
      {"q": "Quina frase usa bé els dos punts davant d'un exemple?", "o": ["Tinc una idea: anem a la platja.", "Tinc: una idea anem a la platja.", "Tinc una: idea anem a la platja."], "e": "Els dos punts introduïxen allò que s'anuncia."},
      {"q": "Quina és correcta?", "o": ["Va dir: «No vindré.»", "Va dir; «No vindré.»", "Va dir... «No vindré.»"], "e": "Dos punts davant d'una cita en estil directe."},
      {"q": "Quina frase NO necessita dos punts?", "o": ["Demà anirem a la platja.", "Porta això: crema, tovallola i aigua.", "Ho tinc clar: no hi vaig."], "e": "Una frase simple sense enumeració, cita ni explicació no necessita dos punts."},
      {"q": "Quina frase usa massa punts suspensius?", "o": ["Doncs... jo... no... sé...", "Doncs... no sé.", "Hi havia pomes, peres..."], "e": "Cal usar els punts suspensius amb moderació."},
      {"q": "Quina és correcta?", "o": ["Tinc tres germans (Pau, Marta i Joan).", "Tinc tres germans (Pau, Marta i Joan.)", "Tinc tres germans. (Pau, Marta i Joan)"], "e": "El punt de la frase va fora del parèntesi."},
      {"q": "Escriu quants punts tenen sempre els punts suspensius (en número).", "a": ["3", "tres"], "e": "Tres."}
    ]
  }
]$data$::jsonb) AS t(
  id uuid, type text, sort_order smallint, title text, name text,
  content text, icon text, color text, exercises jsonb
);

INSERT INTO public.resources (id, name, type, category, content, difficulty, xp_earned, sort_order, metadata)
SELECT id, name, type, 'fonetica_ortografia', content, 'intermedi', 15, sort_order,
       jsonb_build_object('icon', icon, 'color', color, 'section_name', title)
FROM practice_catalog
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  type = EXCLUDED.type,
  category = EXCLUDED.category,
  content = EXCLUDED.content,
  difficulty = EXCLUDED.difficulty,
  xp_earned = EXCLUDED.xp_earned,
  sort_order = EXCLUDED.sort_order,
  -- Conserva la lliçó fixa («Aprendre lliçó»), que s'afig en una migració posterior.
  metadata = EXCLUDED.metadata || jsonb_strip_nulls(jsonb_build_object('lesson', resources.metadata -> 'lesson'));

DELETE FROM public.practice_exercises e
USING practice_catalog c
WHERE e.resource_id = c.id AND e.level = 'B1';

INSERT INTO public.practice_exercises (resource_id, level, position, kind, prompt, options, answers, explanation)
SELECT c.id, 'B1', x.ord,
       CASE WHEN x.e ? 'a' THEN 'fill' ELSE 'choice' END,
       x.e->>'q',
       CASE WHEN x.e ? 'o' THEN ARRAY(SELECT jsonb_array_elements_text(x.e->'o')) END,
       CASE WHEN x.e ? 'a' THEN ARRAY(SELECT jsonb_array_elements_text(x.e->'a')) ELSE ARRAY[x.e->'o'->>0] END,
       x.e->>'e'
FROM practice_catalog c
CROSS JOIN LATERAL jsonb_array_elements(c.exercises) WITH ORDINALITY AS x(e, ord);

DROP TABLE practice_catalog;

-- ============================================================
-- Origen: 20261001140000_practice_morfosintaxi_b1.sql
-- ============================================================
-- Morfosintaxi del B1 (Quadern B1 de la JQCV, 3.2.2). Setze continguts de la
-- categoria morfosintaxi: gènere i nombre del substantiu; l'adjectiu; articles,
-- demostratius i possessius; pronoms forts i febles; pronoms febles CD/CI i
-- combinacions; interrogatius; numerals; quantitatius i indefinits;
-- preposicions; adverbis; connectors; verbs regulars; verbs irregulars; verbs
-- de règim preposicional; modes verbals; i ser/estar, semblar i perífrasis.
-- Són recursos de nivell intermedi amb exercicis B1. Tornar a aplicar el
-- fitxer no duplica res.

CREATE TEMP TABLE practice_catalog AS
SELECT * FROM jsonb_to_recordset($data$[
  {
    "id": "d4e6b0ae-2e1f-4d5b-ad27-be9d86b4e19e", "type": "b1_mor_substantius", "sort_order": 1,
    "title": "Gènere i nombre del substantiu", "name": "Flexió regular, irregular i invariable del substantiu",
    "content": "El gènere del substantiu (regular amb alteració d'accent, irregular i invariable) i el nombre (amb modificació consonàntica, amb canvi d'accent i altres alteracions) (3.2.2).", "icon": "🔤", "color": "#C5E1A5",
    "exercises": [
      {"q": "Quin és el femení de «secretari»?", "o": ["secretària", "secretaria", "secretàrie"], "e": "Secretari → secretària: en femení la paraula es fa esdrúixola i porta accent. La secretaria (sense accent) és l'oficina."},
      {"q": "Quin és el femení de «funcionari»?", "o": ["funcionària", "funcionaria", "funcionàrie"], "e": "Funcionari → funcionària."},
      {"q": "Quin és el femení de «veterinari»?", "o": ["veterinària", "veterinaria", "veterinàrie"], "e": "Veterinari → veterinària."},
      {"q": "Quin és el femení de «cosí»?", "o": ["cosina", "cosína", "cosíssa"], "e": "Cosí → cosina: en femení perd l'accent, perquè passa a ser plana acabada en vocal."},
      {"q": "Quin és el femení de «veí»?", "o": ["veïna", "veína", "veina"], "e": "Veí → veïna: el femení necessita dièresi."},
      {"q": "Quin és el femení de «campió»?", "o": ["campiona", "campióna", "campioa"], "e": "Campió → campiona."},
      {"q": "Quin és el femení de «cavall»?", "o": ["egua", "cavalla", "cavalleta"], "e": "Femení irregular: cavall / egua (o euga)."},
      {"q": "Quin és el femení de «bou»?", "o": ["vaca", "bova", "boua"], "e": "Bou / vaca: paraules diferents."},
      {"q": "Quin és el femení de «gall»?", "o": ["gallina", "galla", "gallessa"], "e": "Gall / gallina."},
      {"q": "Quin és el femení de «actor»?", "o": ["actriu", "actora", "actriz"], "e": "Actor / actriu (com emperador / emperadriu)."},
      {"q": "Quin és el femení de «metge»?", "o": ["metgessa", "metja", "metgesa"], "e": "Metge / metgessa."},
      {"q": "Quin és el femení de «poeta»?", "o": ["poetessa", "poeta", "poetisa"], "e": "Poeta / poetessa."},
      {"q": "Quin és el femení de «gendre»?", "o": ["nora", "gendra", "gendressa"], "e": "Gendre / nora."},
      {"q": "Quin és el femení de «cantaire»?", "o": ["cantaire (és invariable)", "cantairessa", "cantaira"], "e": "Les paraules en -aire són invariables: el cantaire, la cantaire."},
      {"q": "Quin és el femení de «homicida»?", "o": ["homicida (és invariable)", "homicidessa", "homicidera"], "e": "Homicida, suïcida, artista, periodista: invariables en gènere."},
      {"q": "Quin és el femení de «testimoni» (persona que declara)?", "o": ["testimoni (invariable)", "testimònia", "testimona"], "e": "El testimoni, la testimoni."},
      {"q": "Quin és el femení de «jutge»?", "o": ["jutgessa", "jutja", "jutgesa"], "e": "Jutge / jutgessa."},
      {"q": "Quin és el plural de «llengua»?", "o": ["llengües", "llengues", "llenguas"], "e": "Gu + a → gü + e: llengües. La u continua sonant."},
      {"q": "Quin és el plural de «aigua»?", "o": ["aigües", "aigues", "aiguas"], "e": "Aigua → aigües."},
      {"q": "Quin és el plural de «Pasqua»?", "o": ["Pasqües", "Pasques", "Pasquas"], "e": "Qu + a → qü + e: Pasqües."},
      {"q": "Quin és el plural de «amiga»?", "o": ["amigues", "amiges", "amigas"], "e": "G + a → gu + e: amigues."},
      {"q": "Quin és el plural de «platja»?", "o": ["platges", "platjes", "platjas"], "e": "Tj + a → tg + e: platges."},
      {"q": "Quin és el plural de «plaça»?", "o": ["places", "plaçes", "plasses"], "e": "Ç + a → c + e: places."},
      {"q": "Quin és el plural de «camió»?", "o": ["camions", "camións", "camiós"], "e": "Camió → camions: l'aguda acabada en -ons no porta accent."},
      {"q": "Quin és el plural de «examen»?", "o": ["exàmens", "examens", "exámens"], "e": "Examen → exàmens: el plural plana acabada en -ens porta accent."},
      {"q": "Quin és el plural de «país»?", "o": ["països", "paísos", "paisos"], "e": "País → països: dièresi en lloc d'accent."},
      {"q": "Quin és el plural de «mà»?", "o": ["mans", "màs", "manes"], "e": "Mà → mans: recupera la n (també pa → pans, germà → germans)."},
      {"q": "Quin és el plural de «pa»?", "o": ["pans", "pas", "pàs"], "e": "Pa → pans."},
      {"q": "Quin és el plural de «pis»?", "o": ["pisos", "pises", "pissos"], "e": "Pis → pisos (s sonora: s)."},
      {"q": "Quin és el plural de «peix»?", "o": ["peixos", "peixs", "peixes"], "e": "Paraules acabades en -x: plural en -os (peixos, calaixos)."},
      {"q": "Quin és el plural de «despatx»?", "o": ["despatxos", "despatxs", "despatxes"], "e": "Despatx → despatxos."},
      {"q": "Quin és el plural de «text»?", "o": ["textos", "textes", "textus"], "e": "Paraules en -st, -sc, -xt: textos (també boscos, gustos)."},
      {"q": "Quin és el plural de «bosc» més habitual en valencià?", "o": ["boscos", "bosques", "bosquis"], "e": "Boscos (també boscs)."},
      {"q": "Quin és el plural de «dilluns»?", "o": ["dilluns (invariable)", "dillunsos", "dillunes"], "e": "Les paraules planes acabades en -s són invariables: el dilluns, els dilluns; el llapis, els llapis."},
      {"q": "Quin és el plural de «llapis»?", "o": ["llapis", "llapissos", "llapises"], "e": "Invariable: els llapis."},
      {"q": "Quin és el plural de «braç»?", "o": ["braços", "braçs", "braces"], "e": "Braç → braços."},
      {"q": "Escriu el femení de «propietari».", "a": ["propietària"], "e": "Propietària."},
      {"q": "Escriu el plural de «llengua».", "a": ["llengües"], "e": "Llengües."},
      {"q": "Escriu el plural de «germà».", "a": ["germans"], "e": "Germans."},
      {"q": "Escriu el femení de «rei».", "a": ["reina"], "e": "Reina."}
    ]
  },
  {
    "id": "23d2f0c0-a9b0-4df0-85a4-a501b4525e1c", "type": "b1_mor_adjectius", "sort_order": 2,
    "title": "L'adjectiu", "name": "Flexió, adjectius qualificatius, concordança i graus",
    "content": "La flexió dels adjectius d'una i de dos terminacions, els adjectius qualificatius (físic, caràcter, estats d'ànim; gruixut i gros), la concordança i els graus de l'adjectiu (3.2.2).", "icon": "🎨", "color": "#FFE082",
    "exercises": [
      {"q": "Quin és el femení de «bo»?", "o": ["bona", "boa", "bonna"], "e": "Bo / bona / bons / bones."},
      {"q": "Quin és el femení de «nou»?", "o": ["nova", "noua", "nouva"], "e": "Nou / nova / nous / noves."},
      {"q": "Quin és el femení de «blanc»?", "o": ["blanca", "blanqua", "blanga"], "e": "Blanc / blanca / blancs / blanques."},
      {"q": "Quin és el femení plural de «blanc»?", "o": ["blanques", "blances", "blancas"], "e": "C + e → qu: blanques."},
      {"q": "Quin és el femení de «roig»?", "o": ["roja", "rotja", "roija"], "e": "Roig / roja / rojos (o roigs) / roges."},
      {"q": "Quin és el femení de «gros»?", "o": ["grossa", "grosa", "grosça"], "e": "Gros / grossa / grossos / grosses."},
      {"q": "Quin és el femení de «cru»?", "o": ["crua", "cruda", "cruïa"], "e": "Cru / crua / crus / crues."},
      {"q": "En valencià, quin és el femení de «ample»?", "o": ["ampla", "ample (invariable)", "amplia"], "e": "Ample / ampla. També pobre / pobra en valencià."},
      {"q": "Quin d'estos adjectius té una sola terminació (igual en masculí i femení)?", "o": ["jove", "bo", "nou"], "e": "Jove, alegre, gran, fàcil, agradable, breu: una terminació (el xic jove, la xica jove)."},
      {"q": "Quin és el femení de «fàcil»?", "o": ["fàcil", "fàcila", "facila"], "e": "Fàcil: una sola terminació. Plural: fàcils."},
      {"q": "Quin és el plural de «comú»?", "o": ["comuns", "comús", "comúns"], "e": "Comú → comuns (recupera la n)."},
      {"q": "«Este llibre és molt ___: té mil pàgines.»", "o": ["gruixut", "gros", "ample"], "e": "Gruixut: de molt de gruix (un llibre, una paret, una tela). Gros: de gran volum o mida."},
      {"q": "«Han plantat un arbre molt ___ al parc: fa cinc metres.»", "o": ["gros", "gruixut", "prim"], "e": "Gros: gran. Un tronc pot ser gruixut, però l'arbre és gros."},
      {"q": "«La paret és ___: no se sent res del pis del costat.»", "o": ["gruixuda", "grossa", "gruixa"], "e": "Gruixut / gruixuda: amb molt de gruix."},
      {"q": "Quina frase té la concordança correcta?", "o": ["Les cadires i els sofàs nous", "Les cadires i els sofàs noves", "La cadires i el sofàs nous"], "e": "Amb noms de gènere diferent, l'adjectiu va en masculí plural."},
      {"q": "Quina frase té la concordança correcta?", "o": ["una camisa i una falda blanques", "una camisa i una falda blancs", "una camisa i una falda blanca"], "e": "Dos noms femenins: adjectiu en femení plural."},
      {"q": "Quina frase té la concordança correcta?", "o": ["Els xiquets estaven cansats i la mare, preocupada.", "Els xiquets estaven cansat i la mare, preocupats.", "Els xiquets estaven cansada i la mare, preocupat."], "e": "Cada adjectiu concorda amb el seu nom."},
      {"q": "Quin és el superlatiu de «bo»?", "o": ["boníssim", "bonissim", "bonísim"], "e": "Bo → boníssim: sufix -íssim (sempre amb accent)."},
      {"q": "Quin és el superlatiu de «fàcil»?", "o": ["facilíssim", "fàcilíssim", "facilissim"], "e": "Fàcil → facilíssim: l'accent passa al sufix."},
      {"q": "Quin és el superlatiu de «ric»?", "o": ["riquíssim", "ricíssim", "riquisim"], "e": "Ric → riquíssim: c + i → qu."},
      {"q": "Quin és el superlatiu de «llarg»?", "o": ["llarguíssim", "llargíssim", "llargissim"], "e": "Llarg → llarguíssim: g + i → gu."},
      {"q": "Quin és el superlatiu de «amable»?", "o": ["amabilíssim", "amablíssim", "amableíssim"], "e": "Amable → amabilíssim."},
      {"q": "Quina forma intensiva (diminutiva) és correcta per a «calent»?", "o": ["calentet", "calentit", "calentó"], "e": "Sufix -et: calentet, xicotet, bonet... dona un matís afectuós o intensiu."},
      {"q": "Quin és el comparatiu de superioritat de «bo»?", "o": ["millor", "més bo", "mejor"], "e": "Bo → millor (també es diu «més bo» en el sentit de bondat)."},
      {"q": "Quin és el comparatiu de superioritat de «dolent» (o «roín»)?", "o": ["pitjor", "més roín", "peor"], "e": "Dolent / roín → pitjor."},
      {"q": "«És ___ restaurant de la ciutat.» (superlatiu relatiu de bo)", "o": ["el millor", "el més millor", "molt millor"], "e": "El millor, el pitjor: superlatiu relatiu. «Més millor» és incorrecte."},
      {"q": "«Esta pel·lícula és ___ que l'altra.»", "o": ["pitjor", "més pitjor", "pitjora"], "e": "Pitjor ja és comparatiu: mai «més pitjor»."},
      {"q": "Quin adjectiu és un avaluatiu negatiu?", "o": ["roín", "bo", "excel·lent"], "e": "Avaluatius: bo, regular, roín (o dolent), excel·lent..."},
      {"q": "«Com ha anat l'examen?» «___: ni bé ni mal.»", "o": ["Regular", "Boníssim", "Pitjor"], "e": "Regular: mitjà, normal."},
      {"q": "Quin adjectiu descriu un estat d'ànim?", "o": ["preocupat", "alt", "rodó"], "e": "Preocupat, content, trist, nerviós: estats d'ànim (sovint amb estar)."},
      {"q": "Quin adjectiu descriu el caràcter?", "o": ["generós", "calb", "quadrat"], "e": "Generós, simpàtic, tossut: caràcter (sovint amb ser)."},
      {"q": "Quina és correcta?", "o": ["És una xica molt alegre.", "És una xica molt alegra.", "És una xica molt alegres."], "e": "Alegre: una terminació."},
      {"q": "Escriu el femení de «gros».", "a": ["grossa"], "e": "Grossa."},
      {"q": "Escriu el superlatiu en -íssim de «car».", "a": ["caríssim"], "e": "Caríssim."},
      {"q": "Escriu el comparatiu de superioritat de «bo».", "a": ["millor"], "e": "Millor."},
      {"q": "Escriu el femení plural de «blanc».", "a": ["blanques"], "e": "Blanques."}
    ]
  },
  {
    "id": "465bca6e-cc83-4911-bf60-805f4fe6fe12", "type": "b1_mor_determinants", "sort_order": 3,
    "title": "Articles, demostratius i possessius", "name": "Article, contracció, demostratius simples i reforçats i possessius",
    "content": "Les formes de l'article definit i indefinit, la contracció i l'apostrofació, els demostratius simples i reforçats, i els possessius tònics i àtons (3.2.2).", "icon": "👉", "color": "#B3E5FC",
    "exercises": [
      {"q": "Quin és l'article correcte? «___ home»", "o": ["l'", "el", "lo"], "e": "Davant de vocal o h: l'home."},
      {"q": "Quin és l'article correcte? «___ amiga»", "o": ["l'", "la", "un'"], "e": "L'amiga: la s'apostrofa davant de a."},
      {"q": "Quin és l'article correcte? «___ infermera»", "o": ["la", "l'", "le"], "e": "La infermera: no s'apostrofa davant de i àtona. Però l'infermer (masculí sí)."},
      {"q": "Quin és l'article correcte? «___ infermer»", "o": ["l'", "el", "la"], "e": "El s'apostrofa davant de qualsevol vocal: l'infermer."},
      {"q": "Quin és l'article correcte? «___ era» (lloc per a batre el blat)", "o": ["l'", "la", "el"], "e": "L'era."},
      {"q": "«Anem ___ mercat.»", "o": ["al", "a el", "a'l"], "e": "A + el = al."},
      {"q": "«Venim ___ mercat.»", "o": ["del", "de el", "d'el"], "e": "De + el = del."},
      {"q": "«Hem quedat ___ estadi.»", "o": ["a l'", "al", "a el"], "e": "A + l'estadi: amb article apostrofat no hi ha contracció."},
      {"q": "Quin és el plural de l'article indefinit «una»?", "o": ["unes", "unas", "uns"], "e": "Un, una, uns, unes."},
      {"q": "Quina frase evita el castellanisme de l'article neutre «lo»?", "o": ["El més important és la salut.", "Lo més important és la salut.", "Lo important és la salut."], "e": "En valencià no s'usa «lo» neutre: el més important, allò important."},
      {"q": "Quina és la forma simple del demostratiu de proximitat (prop de qui parla)?", "o": ["este", "eixe", "aquell"], "e": "Este/esta/estos/estes (reforçat: aquest/aquesta/aquests/aquestes)."},
      {"q": "Quina és la forma reforçada equivalent a «este producte»?", "o": ["aquest producte", "aqueix producte", "aquell producte"], "e": "Este = aquest. Eixe = aqueix."},
      {"q": "Quina és la forma reforçada equivalent a «eixe gos»?", "o": ["aqueix gos", "aquest gos", "aquell gos"], "e": "Eixe/eixa/eixos/eixes = aqueix/aqueixa/aqueixos/aqueixes."},
      {"q": "Quin demostratiu indica una cosa prop de la persona que escolta?", "o": ["eixe", "este", "aquell"], "e": "Este: prop de qui parla. Eixe: prop de qui escolta. Aquell: lluny dels dos."},
      {"q": "«___ muntanyes que es veuen al fons són molt altes.»", "o": ["Aquelles", "Estes", "Eixes"], "e": "Aquell/aquella/aquells/aquelles: lluny."},
      {"q": "Quin és el plural de «esta»?", "o": ["estes", "estas", "estos"], "e": "Esta → estes."},
      {"q": "Quin és el plural de «eixe»?", "o": ["eixos", "eixes", "eixs"], "e": "Eixe → eixos; eixa → eixes."},
      {"q": "Quin demostratiu neutre s'usa per a una cosa propera a qui parla?", "o": ["açò", "això", "allò"], "e": "Açò (prop), això (mitjana distància), allò (lluny)."},
      {"q": "«És ___ cotxe?» (possessiu, primera persona)", "o": ["el meu", "el mi", "meu el"], "e": "Possessius tònics: el meu, la meua, els meus, les meues."},
      {"q": "«Estes claus són ___.» (possessiu, primera persona)", "o": ["meues", "mies", "meus"], "e": "Les claus → meues (femení plural)."},
      {"q": "«He vist ___ germana al mercat.» (possessiu de tu)", "o": ["la teua", "la tua", "la tenia"], "e": "El teu, la teua, els teus, les teues."},
      {"q": "Quin és el possessiu de «nosaltres» en femení plural?", "o": ["les nostres", "les nostes", "les nostrues"], "e": "El nostre, la nostra, els nostres, les nostres."},
      {"q": "Quin és el possessiu de «ells» per a «casa»?", "o": ["la seua casa", "la sua casa", "la llur casa"], "e": "El seu, la seua, els seus, les seues (de vosté, d'ell, d'ells...)."},
      {"q": "Quina forma àtona del possessiu s'usa habitualment amb noms de família?", "o": ["ma mare", "la ma mare", "mi mare"], "e": "Àtons amb parentiu: ma mare, mon pare, ta germana, son iaio. També «la meua mare»."},
      {"q": "Quina és l'expressió amb possessiu àton correcta?", "o": ["son iaio", "sa iaio", "son iaia"], "e": "Son (masculí): son iaio, son pare. Sa (femení): sa mare, sa iaia."},
      {"q": "Quina és l'expressió amb possessiu àton correcta?", "o": ["ta germana", "ton germana", "tu germana"], "e": "Ta (femení de ton): ta germana, ta tia."},
      {"q": "Quina expressió fixa usa el possessiu àton?", "o": ["en ma vida", "en mia vida", "en mi vida"], "e": "Algunes expressions fixes: en ma vida, a sa casa."},
      {"q": "Quin és el plural de «mon cosí»?", "o": ["mos cosins", "mons cosins", "mes cosins"], "e": "Mon/ma → mos/mes: mos cosins, mes cosines."},
      {"q": "Escriu la contracció de «de + els».", "a": ["dels"], "e": "Dels."},
      {"q": "Escriu la forma reforçada de «esta».", "a": ["aquesta"], "e": "Aquesta."},
      {"q": "Escriu el possessiu tònic femení plural de primera persona: les ___.", "a": ["meues"], "e": "Les meues."},
      {"q": "Escriu el possessiu àton femení de tercera persona davant de «mare»: ___ mare.", "a": ["sa"], "e": "Sa mare."}
    ]
  },
  {
    "id": "5916a0f9-90af-4c02-bab8-768bc0bc7004", "type": "b1_mor_pronoms_personals", "sort_order": 4,
    "title": "Pronoms forts i febles", "name": "Pronoms personals forts i morfologia i col·locació dels febles",
    "content": "Concepte de pronom fort i feble, morfologia dels pronoms forts i de la col·locació dels febles (davant i darrere del verb, amb apòstrof i guionet) (3.2.2).", "icon": "🙋", "color": "#F8BBD0",
    "exercises": [
      {"q": "Quin d'estos és un pronom fort?", "o": ["nosaltres", "ens", "els"], "e": "Forts: jo, tu, ell, ella, vosté, nosaltres, vosaltres, vostés, ells, elles. Febles: em, et, el, ens, us..."},
      {"q": "Quin d'estos és un pronom feble?", "o": ["li", "ella", "vosté"], "e": "Li és feble: va unit al verb."},
      {"q": "Quin pronom fort s'usa darrere d'una preposició per a la primera persona?", "o": ["mi: «per a mi»", "jo: «per a jo»", "me: «per a me»"], "e": "Darrere de preposició, mi: per a mi, amb mi, a mi."},
      {"q": "Quina és correcta?", "o": ["Vine amb mi.", "Vine amb jo.", "Vine amb me."], "e": "Amb mi."},
      {"q": "Quina és correcta?", "o": ["Entre tu i jo ho farem.", "Entre tu i mi ho farem.", "Entre te i jo ho farem."], "e": "Entre tu i jo (o entre tu i mi)."},
      {"q": "Quin és el pronom fort de respecte per a parlar a una persona gran que no coneixes?", "o": ["vosté", "tu", "vós sempre"], "e": "Vosté (plural vostés), amb el verb en tercera persona."},
      {"q": "Quin és el femení de «ells»?", "o": ["elles", "elas", "ellas"], "e": "Ell, ella, ells, elles."},
      {"q": "«___ compre el pa cada dia.» (el pa = CD, davant del verb)", "o": ["El", "Lo", "L'"], "e": "Davant de verb que comença per consonant: el. Davant de vocal: l' (l'agafe)."},
      {"q": "«___ agafe cada matí.» (el tren)", "o": ["L'", "El", "Lo"], "e": "El → l' davant de vocal."},
      {"q": "«Vull comprar___.» (el pa, darrere de l'infinitiu)", "o": ["-lo", "'l", "-el"], "e": "Darrere de verb acabat en consonant: comprar-lo."},
      {"q": "«Vaig a vendre___.» (el cotxe)", "o": ["'l", "-lo", "-el"], "e": "Darrere de verb acabat en vocal: vendre'l."},
      {"q": "«Compra___!» (el pa, imperatiu)", "o": ["'l", "-lo", "-el"], "e": "Compra'l (acaba en vocal)."},
      {"q": "«Està mirant___.» (la tele, gerundi)", "o": ["-la", "'la", "-lo"], "e": "La darrere del verb sempre amb guionet: mirant-la."},
      {"q": "«___ estime molt.» (a tu)", "o": ["T'", "Et", "Te"], "e": "Et → t' davant de vocal."},
      {"q": "«___ veig demà.» (a tu)", "o": ["Et", "T'", "Te"], "e": "Davant de consonant, forma reforçada: et veig."},
      {"q": "«Ajuda___, per favor!» (a mi)", "o": ["'m", "-me", "-em"], "e": "Darrere de verb acabat en vocal: ajuda'm."},
      {"q": "«Vols ajudar___?» (a mi)", "o": ["-me", "'m", "-em"], "e": "Darrere de verb acabat en consonant: ajudar-me."},
      {"q": "«___ agrada la música.» (a nosaltres)", "o": ["Ens", "'Ns", "Mos"], "e": "Ens: davant del verb no s'apostrofa. «Mos» és col·loquial: en estàndard, ens."},
      {"q": "«Mira___!» (a nosaltres)", "o": ["'ns", "-nos", "-ens"], "e": "Darrere de verb acabat en vocal: mira'ns."},
      {"q": "«Vull veure___.» (a vosaltres)", "o": ["-vos", "'vos", "vos-"], "e": "Darrere del verb, en valencià: -vos (també -us): veure-vos, ajudar-vos."},
      {"q": "«___ espere a la porta.» (a vosaltres)", "o": ["Us", "Vos", "Os"], "e": "Davant del verb: us espere (en valencià col·loquial, també vos)."},
      {"q": "«___ he dit la veritat.» (a ell)", "o": ["Li", "L'", "El"], "e": "Li és el pronom de complement indirecte singular; no s'apostrofa mai."},
      {"q": "«Pregunta___ on viu.» (a ell)", "o": ["-li", "'li", "-lo"], "e": "Darrere del verb: pregunta-li."},
      {"q": "«Vaig a fer___.» (això)", "o": ["-ho", "'ho", "-lo"], "e": "Ho (neutre) sempre amb guionet darrere del verb: fer-ho."},
      {"q": "«___ cal anar demà.» (a la platja, complement de lloc)", "o": ["Hi", "I", "Ni"], "e": "Hi substituïx complements de lloc: hi cal anar, hi vaig."},
      {"q": "«Tens pa? Sí, ___ tinc.»", "o": ["en", "el", "hi"], "e": "En substituïx un complement indeterminat (pa, sense article)."},
      {"q": "«Quantes pomes vols? ___ vull tres.»", "o": ["En", "Les", "Hi"], "e": "Amb quantitats: en vull tres."},
      {"q": "Quina posició del pronom és correcta?", "o": ["El vull comprar. / Vull comprar-lo.", "Vull el comprar.", "Comprar vull-lo."], "e": "Amb perífrasis, el pronom pot anar davant del verb conjugat o darrere de l'infinitiu."},
      {"q": "Escriu el pronom feble que substituïx «el pa» darrere de «comprar»: comprar-___.", "a": ["lo"], "e": "Comprar-lo."},
      {"q": "Escriu el pronom fort de primera persona darrere de «per a»: per a ___.", "a": ["mi"], "e": "Per a mi."},
      {"q": "Escriu el pronom feble de complement indirecte per a «a ella».", "a": ["li"], "e": "Li."},
      {"q": "Escriu «mira + ens» amb el pronom ben escrit.", "a": ["mira'ns"], "e": "Mira'ns."}
    ]
  },
  {
    "id": "bc2f3489-6ae8-468c-aa0f-4b23695a0a02", "type": "b1_mor_pronoms_cd_ci", "sort_order": 5,
    "title": "Pronoms febles: CD, CI i combinacions", "name": "Complement directe, complement indirecte i combinació de dos pronoms",
    "content": "Ús dels pronoms febles en funció de complement directe i indirecte, i combinació de dos pronoms: complement indirecte + complement directe (3.2.2).", "icon": "🔁", "color": "#E1BEE7",
    "exercises": [
      {"q": "«He comprat el pa.» → «___ he comprat.»", "o": ["L'", "Li", "En"], "e": "El pa és complement directe determinat masculí: el / l'."},
      {"q": "«He comprat la llet.» → «___ he comprada.»", "o": ["L'", "Li", "La"], "e": "La llet: CD femení → l' davant de vocal (l'he comprada)."},
      {"q": "«Compraré les pomes.» → «___ compraré.»", "o": ["Les", "Els", "Li"], "e": "Les pomes: CD femení plural → les."},
      {"q": "«Veig els xiquets.» → «___ veig.»", "o": ["Els", "Les", "Li"], "e": "Els xiquets: CD masculí plural → els."},
      {"q": "«He dit que no.» → «___ he dit.»", "o": ["Ho", "El", "Li"], "e": "Una oració o «això» com a CD → ho."},
      {"q": "«Vull pa.» → «___ vull.»", "o": ["En", "El", "Ho"], "e": "CD sense determinant (indeterminat) → en."},
      {"q": "«He escrit una carta a la meua àvia.» Quin és el complement indirecte?", "o": ["a la meua àvia", "una carta", "he escrit"], "e": "El CI indica a qui va destinada l'acció: a la meua àvia."},
      {"q": "«He escrit una carta a la meua àvia.» → «___ he escrit una carta.»", "o": ["Li", "La", "L'"], "e": "CI singular → li (masculí o femení)."},
      {"q": "«Done els regals als meus fills.» → «___ done els regals.»", "o": ["Els", "Li", "Les"], "e": "CI plural → els (masculí o femení): els done."},
      {"q": "«Done els regals a les meues filles.» → «___ done els regals.»", "o": ["Els", "Les", "Li"], "e": "El CI plural sempre és els, també en femení."},
      {"q": "«Telefona a Pere.» → «Telefona___.»", "o": ["-li", "'l", "-lo"], "e": "Telefonar a algú: CI → telefona-li."},
      {"q": "«Pregunte a vosté.» → «___ pregunte.»", "o": ["Li", "El", "La"], "e": "Vosté com a CI: li (li pregunte)."},
      {"q": "«Em dones el llibre?» → «___ dones?»", "o": ["Me'l", "Em el", "M'el"], "e": "CI (em) + CD (el) → me'l."},
      {"q": "«Et done la clau.» → «___ done.»", "o": ["Te la", "Et la", "T'la"], "e": "Et + la → te la."},
      {"q": "«Et porte els papers.» → «___ porte.»", "o": ["Te'ls", "Et els", "T'els"], "e": "Et + els → te'ls."},
      {"q": "«T'explique això.» → «___ explique.»", "o": ["T'ho", "Te ho", "Et ho"], "e": "Et + ho davant de vocal → t'ho."},
      {"q": "«Ens enviaran el paquet.» → «___ enviaran.»", "o": ["Ens l'", "Ens el", "Nos l'"], "e": "Ens + el davant de vocal → ens l' (ens l'enviaran)."},
      {"q": "«Us diré la veritat.» → «___ diré.»", "o": ["Us la", "Vos la", "Us l'"], "e": "Us + la → us la (davant de consonant)."},
      {"q": "«Li done el llibre.» → «___ done.»", "o": ["Li'l", "El li", "Lo li"], "e": "Li + el → li'l (també l'hi)."},
      {"q": "«Li he dit això.» → «___ he dit.»", "o": ["Li ho", "L'ho", "Ho li"], "e": "Li + ho → li ho."},
      {"q": "«Li porte la carta.» → «___ porte.»", "o": ["Li la", "La li", "Li-la"], "e": "Li + la → li la."},
      {"q": "«Els he portat pa.» → «___ he portat.»", "o": ["Els n'", "Els en", "N'els"], "e": "Els + en → els n' davant de vocal."},
      {"q": "«Dona'm el llibre.» → «Dona___!»", "o": ["-me'l", "'m-el", "-el-me"], "e": "Darrere del verb: dona-me'l."},
      {"q": "«Porta'ns la cadira.» → «Porta___!»", "o": ["-nos-la", "'ns-la", "-la-nos"], "e": "Darrere del verb: porta-nos-la."},
      {"q": "«Explica-li això.» → «Explica___!»", "o": ["-li-ho", "-ho-li", "'l-ho"], "e": "Darrere del verb: explica-li-ho."},
      {"q": "«Vull dir-te una cosa.» → «Vull dir-___.» (una cosa → la)", "o": ["te-la", "la-te", "t'la"], "e": "Darrere de l'infinitiu: dir-te-la. També: te la vull dir."},
      {"q": "«Se'n va a casa.» Quins pronoms hi ha?", "o": ["es + en", "es + el", "se + li"], "e": "Anar-se'n: es + en → se'n (davant de consonant)."},
      {"q": "Quina és correcta?", "o": ["Me'n vaig.", "Em en vaig.", "M'en vaig."], "e": "Em + en → me'n."},
      {"q": "Quina és correcta?", "o": ["No me'n recorde.", "No m'en recorde.", "No em en recorde."], "e": "Recordar-se'n: me'n recorde, te'n recordes, se'n recorda."},
      {"q": "Quina és correcta?", "o": ["A Maria, li agrada el cine.", "A Maria, la agrada el cine.", "A Maria, l'agrada el cine."], "e": "Agradar porta CI: li agrada."},
      {"q": "Quina és correcta?", "o": ["A ells, els fa por la foscor.", "A ells, li fa por la foscor.", "A ells, les fa por la foscor."], "e": "CI plural: els."},
      {"q": "Escriu el pronom: «He vist el teu germà» → «___ he vist.»", "a": ["l'", "l"], "e": "L'he vist."},
      {"q": "Escriu el pronom: «Done un regal a ma mare» → «___ done un regal.»", "a": ["li"], "e": "Li."},
      {"q": "Escriu els dos pronoms: «Em dones la sal?» → «___ dones?»", "a": ["me la"], "e": "Me la dones?"},
      {"q": "Escriu els dos pronoms: «Li done el llibre» → «___ done.»", "a": ["li'l", "l'hi"], "e": "Li'l o l'hi."}
    ]
  },
  {
    "id": "a7c5d2a7-6ba3-43ad-86d2-556ac9a00f68", "type": "b1_mor_interrogatius", "sort_order": 6,
    "title": "Pronoms interrogatius", "name": "Què, qui, quin, a on, com, quan i quant",
    "content": "Els pronoms i adverbis interrogatius (què, qui, quin, a on, com) i la distinció entre quan i quant (3.2.2).", "icon": "❓", "color": "#B2DFDB",
    "exercises": [
      {"q": "«___ vols per a sopar?» (una cosa)", "o": ["Què", "Qui", "Quin"], "e": "Què: per a coses."},
      {"q": "«___ ha telefonat?» (una persona)", "o": ["Qui", "Què", "Quin"], "e": "Qui: per a persones."},
      {"q": "«___ llibre estàs llegint?»", "o": ["Quin", "Què", "Qui"], "e": "Quin + nom masculí: quin llibre."},
      {"q": "«___ pel·lícula vols veure?»", "o": ["Quina", "Quin", "Què"], "e": "Quina + nom femení."},
      {"q": "«___ germans tens?» (quantitat)", "o": ["Quants", "Quins", "Quant"], "e": "Quants + nom masculí plural, per a quantitat."},
      {"q": "«___ germanes tens?» (quantitat)", "o": ["Quantes", "Quantas", "Quants"], "e": "Quantes + nom femení plural."},
      {"q": "«___ costa este jersei?»", "o": ["Quant", "Quan", "Quin"], "e": "Quant: quantitat (preu). Quan: temps."},
      {"q": "«___ arribarà el tren?»", "o": ["Quan", "Quant", "Com"], "e": "Quan: temps. Quant: quantitat."},
      {"q": "«___ fa que vius ací?»", "o": ["Quant de temps", "Quan de temps", "Què temps"], "e": "Quant de temps: duració."},
      {"q": "«___ vas aquest estiu?» (lloc)", "o": ["A on", "Com", "Quan"], "e": "A on (o on): lloc."},
      {"q": "«___ et dius?»", "o": ["Com", "Què", "Qui"], "e": "Com: manera. Com et dius?"},
      {"q": "«___ estàs?» «Molt bé, gràcies.»", "o": ["Com", "Què", "On"], "e": "Com estàs?"},
      {"q": "«___ no has vingut?» «Perquè estava malalt.»", "o": ["Per què", "Perquè", "Perque"], "e": "Per què (separat, amb accent): pregunta per la causa. Perquè: resposta."},
      {"q": "«___ és este abric?» (propietari)", "o": ["De qui", "De què", "Qui de"], "e": "De qui: propietat."},
      {"q": "«___ vas al cine?» (companyia)", "o": ["Amb qui", "Amb què", "Qui amb"], "e": "Amb qui: companyia."},
      {"q": "«___ està fet este moble?» (material)", "o": ["De què", "De qui", "Què de"], "e": "De què: material o tema."},
      {"q": "«___ hora és?»", "o": ["Quina", "Què", "Quant"], "e": "Quina hora és?"},
      {"q": "«___ anys tens?»", "o": ["Quants", "Quins", "Quans"], "e": "Quants anys tens?"},
      {"q": "«___ són els teus pares?» (identificar entre diverses persones)", "o": ["Quins", "Qui", "Què"], "e": "Quins: per a triar entre elements d'un grup."},
      {"q": "«No sé ___ fer.» (interrogativa indirecta)", "o": ["què", "que", "qui"], "e": "En les interrogatives indirectes, què també porta accent."},
      {"q": "«M'ha preguntat ___ arribaré.»", "o": ["quan", "quant", "qui"], "e": "Interrogativa indirecta de temps: quan."},
      {"q": "«___ gent hi havia!» (exclamació)", "o": ["Quanta", "Quanta de", "Quan"], "e": "Quanta gent!, quants xiquets!"},
      {"q": "«___ de pa vols?»", "o": ["Quant", "Quan", "Quanta"], "e": "Quant de + nom no comptable: quant de pa, quant de temps."},
      {"q": "Quina pregunta està ben escrita?", "o": ["Què has dit?", "Que has dit?", "Qué has dit?"], "e": "Què interrogatiu porta accent obert (è)."},
      {"q": "Quina pregunta està ben escrita?", "o": ["On vius?", "On vius", "¿On vius?"], "e": "En valencià el signe d'interrogació només es posa al final."},
      {"q": "Escriu l'interrogatiu: «___ arriba l'avió?» (temps)", "a": ["quan"], "e": "Quan."},
      {"q": "Escriu l'interrogatiu: «___ val este llibre?» (preu)", "a": ["quant"], "e": "Quant."},
      {"q": "Escriu l'interrogatiu: «___ és eixa xica?» (persona)", "a": ["qui"], "e": "Qui."},
      {"q": "Escriu l'interrogatiu de causa (dues paraules).", "a": ["per què"], "e": "Per què."}
    ]
  },
  {
    "id": "969469d6-dee2-4b10-bf2b-26bcd3e65e55", "type": "b1_mor_numerals", "sort_order": 7,
    "title": "Els numerals", "name": "Cardinals i ordinals",
    "content": "L'ús dels numerals cardinals (zero, quatre, cinc, catorze, trenta-dos, cent, tres-cents, mil, un milió) i ordinals (primer, segon, quart, cinqué, sisena, vinté...) (3.2.2).", "icon": "🔢", "color": "#FFCCBC",
    "exercises": [
      {"q": "Com s'escriu 8 en valencià?", "o": ["huit", "vuit", "uit"], "e": "En valencià: huit (també vuit en altres variants)."},
      {"q": "Com s'escriu 14?", "o": ["catorze", "catorce", "quatorze"], "e": "Catorze."},
      {"q": "Com s'escriu 17 en valencià?", "o": ["dèsset", "dicisset", "dieciset"], "e": "Dèsset (o disset)."},
      {"q": "Com s'escriu 18 en valencià?", "o": ["díhuit", "dihuit", "devuit"], "e": "Díhuit (o divuit)."},
      {"q": "Com s'escriu 19 en valencià?", "o": ["dènou", "dènau", "diènou"], "e": "Dènou (o dinou)."},
      {"q": "Com s'escriu 32?", "o": ["trenta-dos", "trentaidos", "trenta i dos"], "e": "Desenes i unitats amb guionet: trenta-dos."},
      {"q": "Com s'escriu 21?", "o": ["vint-i-u (o vint-i-un)", "vintiun", "vint i u"], "e": "Entre vint i les unitats, -i-: vint-i-u, vint-i-dos."},
      {"q": "Com s'escriu 300?", "o": ["tres-cents", "trescents", "tres cents"], "e": "Unitats i centenes amb guionet: tres-cents."},
      {"q": "«Hi havia ___ persones.» (200, femení)", "o": ["dues-centes", "dos-cents", "dues cents"], "e": "Les centenes concorden amb el nom: dues-centes persones."},
      {"q": "«Tinc ___ germanes.» (2)", "o": ["dues", "dos", "dós"], "e": "Dos (masculí) / dues (femení)."},
      {"q": "Com s'escriu 1.000.000?", "o": ["un milió", "un millió", "un milló"], "e": "Un milió, dos milions."},
      {"q": "Com s'escriu 1.500?", "o": ["mil cinc-cents", "un mil cinc-cents", "mil-cinc-cents"], "e": "Mil (sense «un») cinc-cents."},
      {"q": "Com s'escriu 105?", "o": ["cent cinc", "cent-cinc", "cent i cinc"], "e": "Centena i unitat, sense guionet ni «i»: cent cinc."},
      {"q": "Quin és l'ordinal de «quatre» en masculí?", "o": ["quart", "quatré", "quarto"], "e": "Primer, segon, tercer, quart."},
      {"q": "Quin és l'ordinal de «cinc» en masculí?", "o": ["cinqué (o quint)", "cinquè (o quinto)", "cinqueno"], "e": "Cinqué (valencià) o quint."},
      {"q": "Quin és l'ordinal femení de «sis»?", "o": ["sisena (o sexta)", "siséa", "sisea"], "e": "Sisena o sexta."},
      {"q": "Quin és l'ordinal de «vint» en masculí?", "o": ["vinté", "vintè", "vintavo"], "e": "Vinté (femení vintena)."},
      {"q": "Quin és el femení de «tercer»?", "o": ["tercera", "tercer", "terça"], "e": "Tercer / tercera."},
      {"q": "Quin és el plural masculí de «primer»?", "o": ["primers", "primeros", "primés"], "e": "Primer / primers / primera / primeres."},
      {"q": "Quin és el plural femení de «quart»?", "o": ["quartes", "quarts", "quartas"], "e": "Quart / quarta / quarts / quartes."},
      {"q": "«Visc en el ___ pis.» (3r)", "o": ["tercer", "tres", "terç"], "e": "Tercer pis (ordinal)."},
      {"q": "«És la ___ vegada que t'ho dic.» (10a)", "o": ["desena", "deu", "décima"], "e": "Desé / desena."},
      {"q": "«Hem arribat en ___ lloc.» (2n)", "o": ["segon", "dos", "segund"], "e": "Segon lloc."},
      {"q": "Quina és la fracció «1/4»?", "o": ["un quart", "un quarta", "un quatre"], "e": "1/4: un quart. 1/2: mig o la meitat. 1/3: un terç."},
      {"q": "«Me'n dones ___ quilo?» (0,5)", "o": ["mig", "mitat", "mitja"], "e": "Mig quilo; mitja hora (femení)."},
      {"q": "«Arribarem a les set i ___.» (30 minuts)", "o": ["mitja", "mig", "mitat"], "e": "Les set i mitja."},
      {"q": "Quin número és «zero»?", "o": ["0", "10", "100"], "e": "Zero (0)."},
      {"q": "Escriu en lletres el número 32.", "a": ["trenta-dos"], "e": "Trenta-dos."},
      {"q": "Escriu en lletres el número 300.", "a": ["tres-cents"], "e": "Tres-cents."},
      {"q": "Escriu l'ordinal masculí de 5 en valencià.", "a": ["cinqué", "quint", "cinquè"], "e": "Cinqué (o quint)."},
      {"q": "Escriu en lletres el número 8 en valencià.", "a": ["huit", "vuit"], "e": "Huit."}
    ]
  },
  {
    "id": "b6c86018-dd00-47e9-88df-9462393e1e84", "type": "b1_mor_quantitatius_indefinits", "sort_order": 8,
    "title": "Quantitatius i indefinits", "name": "Quant, prou, locucions de quantitat, indefinits i res/gens/cap",
    "content": "Quantitatius variables i invariables, l'ús de quant i prou, les locucions de quantitat més freqüents, els indefinits i la distinció entre res, gens i cap/ningun (3.2.2).", "icon": "⚖️", "color": "#DCEDC8",
    "exercises": [
      {"q": "Quin d'estos quantitatius és invariable?", "o": ["massa", "molt", "poc"], "e": "Massa i prou són invariables. Molt, poc, quant varien: molta, pocs, quantes."},
      {"q": "«Hi havia ___ gent a la festa.»", "o": ["molta", "molt", "molts"], "e": "Molt concorda amb el nom: molta gent."},
      {"q": "«Tens ___ temps per a acabar-ho?» (suficient)", "o": ["prou", "pros", "prou de"], "e": "Prou: suficient (invariable)."},
      {"q": "«Ja n'hi ha ___!» (suficient, prou de parlar)", "o": ["prou", "molt", "massa poc"], "e": "Ja n'hi ha prou!: ja és suficient."},
      {"q": "«Hi ha ___ soroll: no puc dormir.» (excés)", "o": ["massa", "masses", "prou"], "e": "Massa: excés, invariable."},
      {"q": "«___ persones vindran?»", "o": ["Quantes", "Quantas", "Quant"], "e": "Quant/quanta/quants/quantes concorda amb el nom."},
      {"q": "«Hi havia ___ gent al concert.» (molta)", "o": ["bona cosa de", "bona cosa", "una bona"], "e": "Bona cosa de: molt, molta."},
      {"q": "«No té ___ de paciència.» (gens)", "o": ["gens ni mica", "res ni gens", "gens de res"], "e": "Gens ni mica (o gens ni miqueta): absolutament gens."},
      {"q": "«Ha collit ___ d'olives amb la mà.» (poca quantitat)", "o": ["un grapat", "un fum", "un milió"], "e": "Un grapat: el que cap en una mà; una quantitat menuda."},
      {"q": "«Tinc ___ de faena!» (molta)", "o": ["un muntó (o un fum)", "un grapat", "una miqueta"], "e": "Un muntó de, un fum de: molta quantitat."},
      {"q": "«Vull una ___ de sucre en el café.» (molt poc)", "o": ["miqueta", "muntó", "bona cosa"], "e": "Una mica, una miqueta: poca quantitat."},
      {"q": "«He visitat ___ països d'Europa.»", "o": ["diversos", "diverses", "divers"], "e": "Diversos/diverses (variable): diversos països."},
      {"q": "«Pots vindre ___ dia.»", "o": ["qualsevol", "qualsevols", "cualsevol"], "e": "Qualsevol (plural: qualssevol)."},
      {"q": "«___ sap que és el millor.» (totes les persones)", "o": ["Tothom", "Tots sabem", "Tothom saben"], "e": "Tothom va amb el verb en singular: tothom sap."},
      {"q": "Quina és correcta?", "o": ["Tothom ha vingut.", "Tothom han vingut.", "Tot el món han vingut."], "e": "Tothom + singular."},
      {"q": "«Vols ___ cosa?» (algun objecte o algun menjar)", "o": ["alguna", "algun", "algú"], "e": "Alguna cosa (o res, en preguntes: vols res?)."},
      {"q": "«Ha telefonat ___?» (alguna persona)", "o": ["algú", "alguna cosa", "algun"], "e": "Algú: alguna persona. Ningú: cap persona."},
      {"q": "«No vol ___.» (cap cosa)", "o": ["res", "gens", "cap"], "e": "Res: cap cosa. No vol res."},
      {"q": "«No queda ___ de vi.» (quantitat no comptable)", "o": ["gens", "res", "cap"], "e": "Gens (de): quantitat de coses no comptables: no queda gens de vi, de pa, de llet."},
      {"q": "«No tinc ___ ordinador.» (comptable)", "o": ["cap (o ningun)", "gens", "res"], "e": "Cap (o ningun/ninguna) davant de nom comptable."},
      {"q": "«No hi ha ___ cadira lliure.»", "o": ["cap", "gens", "res"], "e": "Cap: davant de nom comptable."},
      {"q": "«No ha vingut ___.» (cap persona)", "o": ["ningú", "res", "gens"], "e": "Ningú: cap persona."},
      {"q": "«No m'agrada ___ el futbol.»", "o": ["gens", "res", "cap"], "e": "Gens: en absolut, amb verbs (no m'agrada gens)."},
      {"q": "«Hi ha ___ maneres de fer-ho.» (variades)", "o": ["diferents", "diferent", "diferenta"], "e": "Diferents: diverses."},
      {"q": "«No he vist mai una cosa ___.»", "o": ["tal", "tala", "tals"], "e": "Tal: semblant, d'eixa mena."},
      {"q": "«___ dia vaig al gimnàs.»", "o": ["Cada", "Cades", "Cadascú"], "e": "Cada (invariable). Cadascú: cada persona."},
      {"q": "«Vull ___ cafè, per favor.» (un més)", "o": ["un altre", "otro", "altre un"], "e": "Un altre, una altra, uns altres, unes altres."},
      {"q": "Escriu la paraula: «No queda ___ de llet.»", "a": ["gens"], "e": "Gens."},
      {"q": "Escriu la paraula: «No hi ha ___ taxi lliure.»", "a": ["cap", "ningun"], "e": "Cap (o ningun)."},
      {"q": "Escriu la paraula: «No he menjat ___ en tot el dia.»", "a": ["res"], "e": "Res."},
      {"q": "Escriu el quantitatiu: «Ja n'hi ha ___!» (suficient)", "a": ["prou"], "e": "Prou."}
    ]
  },
  {
    "id": "98325cd9-231e-4aae-80f2-1001b92259d8", "type": "b1_mor_preposicions", "sort_order": 9,
    "title": "Les preposicions", "name": "Preposicions i locucions de mitjà, tema, causa i relació; a amb topònims; a davant del CD",
    "content": "Preposicions i locucions prepositives de mitjà o instrument, de tema, de causa i de relació; la preposició a davant de topònims, classe i casa; i els usos impropis de la preposició a davant del complement directe (3.2.2).", "icon": "➡️", "color": "#CFD8DC",
    "exercises": [
      {"q": "«Hem anat ___ peu fins a la platja.»", "o": ["a", "en", "amb"], "e": "A peu (també a cavall, a mà)."},
      {"q": "«Escriu-ho ___ el bolígraf blau.»", "o": ["amb", "a", "de"], "e": "Amb: instrument."},
      {"q": "«He conegut el meu xicot ___ internet.»", "o": ["a través d'", "per a", "sobre"], "e": "A través de / per mitjà de: mitjà."},
      {"q": "«Vam viatjar ___ tren fins a Madrid.»", "o": ["en (o amb)", "a", "de"], "e": "En tren o amb tren."},
      {"q": "«Hem parlat ___ les vacances.»", "o": ["de (o sobre)", "a", "per a"], "e": "De / sobre: tema."},
      {"q": "«He llegit un llibre ___ la història de València.»", "o": ["sobre", "per", "a"], "e": "Sobre: tema."},
      {"q": "«S'ha suspés el partit ___ la pluja.»", "o": ["a causa de", "gràcies a", "en lloc de"], "e": "A causa de / per culpa de: causa (negativa)."},
      {"q": "«He aprovat ___ la teua ajuda.»", "o": ["gràcies a", "per culpa de", "a causa"], "e": "Gràcies a: causa positiva."},
      {"q": "«Hem arribat tard ___ l'embús.»", "o": ["per culpa de", "gràcies a", "en comptes de"], "e": "Per culpa de: causa negativa, amb valor de retret."},
      {"q": "«___ les festes, l'ajuntament ha posat més autobusos.»", "o": ["Amb motiu de", "En lloc de", "A través de"], "e": "Amb motiu de: amb ocasió de."},
      {"q": "«___ l'accident, han posat un semàfor.»", "o": ["Arran de", "En lloc de", "Sobre"], "e": "Arran de: com a conseqüència de."},
      {"q": "«___ anar en cotxe, anirem amb bicicleta.»", "o": ["En lloc d'", "A causa d'", "Gràcies a"], "e": "En lloc de / en comptes de: substitució."},
      {"q": "«He canviat la camisa ___ una de més gran.»", "o": ["per", "per a", "a"], "e": "Per: canvi, intercanvi."},
      {"q": "«Este regal és ___ tu.» (destinatari)", "o": ["per a", "per", "a"], "e": "Per a: destinació o finalitat."},
      {"q": "«Estudie ___ aprovar.» (finalitat)", "o": ["per a", "per", "a"], "e": "Per a + infinitiu: finalitat."},
      {"q": "«Ho he fet ___ tu: perquè t'estime.» (causa)", "o": ["per", "per a", "a"], "e": "Per: causa."},
      {"q": "«Visc ___ València.»", "o": ["a", "en", "de"], "e": "Davant de topònims: a València, a Alacant."},
      {"q": "«Aquest estiu anirem ___ Itàlia.»", "o": ["a", "en", "cap"], "e": "A Itàlia."},
      {"q": "«Ara estic ___ casa.»", "o": ["a", "en", "dins"], "e": "A casa, a classe, a l'escola."},
      {"q": "«Els alumnes estan ___ classe.»", "o": ["a", "en", "de"], "e": "A classe."},
      {"q": "Quina és correcta?", "o": ["Han vist el mestre.", "Han vist al mestre.", "Han vist a el mestre."], "e": "El complement directe de persona no porta a: he vist el mestre."},
      {"q": "Quina és correcta?", "o": ["Conec Marta des de fa anys.", "Conec a Marta des de fa anys.", "Conec de Marta des de fa anys."], "e": "Sense a davant del CD: conec Marta."},
      {"q": "Quina és correcta?", "o": ["Estime molt els meus pares.", "Estime molt als meus pares.", "Estime molt a els meus pares."], "e": "Estimar algú: CD sense preposició."},
      {"q": "Quina és correcta?", "o": ["Crida a tots.", "Crida tots a.", "Crida de tots."], "e": "Davant de «tots», «tothom», els pronoms forts (a mi, a tu) i en alguns casos per a evitar ambigüitat, el CD pot portar a."},
      {"q": "Quina és correcta?", "o": ["T'he vist a tu.", "He vist tu.", "T'he vist tu a."], "e": "Amb pronom fort de persona, a: t'he vist a tu."},
      {"q": "Quina és correcta?", "o": ["Esperem l'autobús.", "Esperem a l'autobús.", "Esperem per l'autobús."], "e": "Esperar algú/alguna cosa: CD sense a."},
      {"q": "«Vaig ___ el metge.»", "o": ["al", "a el", "el"], "e": "Anar a + el = al metge."},
      {"q": "«Tinc moltes ganes ___ veure't.»", "o": ["de", "a", "per"], "e": "Tindre ganes de."},
      {"q": "Escriu la preposició: «Visc ___ Alacant.»", "a": ["a"], "e": "A Alacant."},
      {"q": "Escriu la preposició: «Este paquet és ___ ta mare.» (destinatari)", "a": ["per a"], "e": "Per a."},
      {"q": "Escriu la locució: «Hem arribat a temps ___ a tu.» (causa positiva)", "a": ["gràcies"], "e": "Gràcies a."},
      {"q": "Corregix la frase: «He vist a ta germana.»", "a": ["he vist ta germana", "he vist la teua germana"], "e": "He vist ta germana (sense a)."}
    ]
  },
  {
    "id": "2b9aa93e-9bff-4dfd-bf80-5de1719a88d5", "type": "b1_mor_adverbis", "sort_order": 10,
    "title": "Els adverbis", "name": "Afirmació i negació, adverbis en -ment i comparatius",
    "content": "Adverbis i locucions d'afirmació i de negació, la formació dels adverbis en -ment i els comparatius més/menys que, tant/tan com (3.2.2).", "icon": "↔️", "color": "#FFE0B2",
    "exercises": [
      {"q": "«Vindràs a la festa?» «___! No me la perdria per res.»", "o": ["I tant", "De cap manera", "Tampoc"], "e": "I tant!: afirmació enfàtica."},
      {"q": "«Ho has fet tu?» «___, ho he fet jo.»", "o": ["Sí, de veres", "De cap manera", "Gens"], "e": "De veres (o de veritat): afirmació."},
      {"q": "En valencià col·loquial, «prou» pot voler dir...", "o": ["«sí, és clar» en una resposta", "«massa»", "«mai»"], "e": "«Vindràs?» «Prou!»: afirmació. També vol dir «suficient»."},
      {"q": "«És ___ el millor jugador de l'equip.» (no hi ha cap dubte)", "o": ["sens dubte", "potser", "de cap manera"], "e": "Sens dubte: afirmació segura."},
      {"q": "«Deixaràs que ho faça sol?» «___!»", "o": ["De cap manera", "I tant", "De veres"], "e": "De cap manera (o de ninguna manera): negació rotunda."},
      {"q": "«Jo no hi vaig.» «Jo ___.»", "o": ["tampoc", "també", "sí"], "e": "Tampoc: negació en coordinació amb una altra negació. També: afirmació."},
      {"q": "«No hi he estat ___.»", "o": ["mai", "sempre", "ja"], "e": "Mai: en cap moment."},
      {"q": "Quin adverbi en -ment es forma a partir de «ràpid»?", "o": ["ràpidament", "ràpidement", "rapidament"], "e": "Femení de l'adjectiu + -ment: ràpida + ment."},
      {"q": "Quin adverbi en -ment es forma a partir de «clar»?", "o": ["clarament", "clarment", "clarement"], "e": "Clara + ment."},
      {"q": "Quin adverbi en -ment es forma a partir de «feliç»?", "o": ["feliçment", "felicment", "felisment"], "e": "Adjectius d'una terminació: feliç → feliçment."},
      {"q": "Quin adverbi en -ment es forma a partir de «fàcil»?", "o": ["fàcilment", "facilment", "fàcilament"], "e": "Fàcil → fàcilment (conserva l'accent)."},
      {"q": "Quin adverbi en -ment es forma a partir de «segur»?", "o": ["segurament", "segurment", "segurement"], "e": "Segura + ment."},
      {"q": "Quina és correcta?", "o": ["Parlava lenta i tranquil·lament.", "Parlava lentament i tranquil·la.", "Parlava lenta i tranquil·la."], "e": "Amb dos adverbis coordinats en -ment, també és correcte posar el sufix només en l'últim: lenta i tranquil·lament (o lentament i tranquil·lament)."},
      {"q": "«Ma germana és ___ alta ___ jo.» (superioritat)", "o": ["més / que", "més / com", "tan / que"], "e": "Més ... que."},
      {"q": "«Este cotxe és ___ car ___ l'altre.» (inferioritat)", "o": ["menys / que", "menys / com", "tan / que"], "e": "Menys ... que."},
      {"q": "«Pau és ___ simpàtic ___ el seu germà.» (igualtat)", "o": ["tan / com", "tant / com", "tan / que"], "e": "Tan + adjectiu o adverbi + com."},
      {"q": "«Treballa ___ ___ tu.» (igualtat amb verb)", "o": ["tant / com", "tan / com", "tant / que"], "e": "Verb + tant com: treballa tant com tu."},
      {"q": "«Té ___ llibres ___ jo.» (igualtat amb nom)", "o": ["tants / com", "tan / com", "tant / que"], "e": "Tant/tanta/tants/tantes + nom + com."},
      {"q": "«Hi havia ___ gent que no podíem entrar.» (consecutiva)", "o": ["tanta", "tan", "tant de"], "e": "Tanta + nom femení + que: consecutiva intensiva."},
      {"q": "«Corre ___ de pressa que ningú l'alcança.»", "o": ["tan", "tant", "tanta"], "e": "Tan + adverbi + que."},
      {"q": "«Viu ___ prop de l'escola.»", "o": ["molt", "molta", "molts"], "e": "Molt com a adverbi és invariable: molt prop."},
      {"q": "«Hui fa ___ més calor que ahir.»", "o": ["molta", "molt", "molts"], "e": "Molta més calor (calor és femení: la calor)."},
      {"q": "«Arribarem ___.» (en poc de temps)", "o": ["prompte", "pronte", "pronto"], "e": "Prompte: aviat."},
      {"q": "«___ no ho sé.» (potser, dubte)", "o": ["Potser", "Sens dubte", "I tant"], "e": "Potser, tal vegada, a la millor: dubte."},
      {"q": "«Ho has fet ___: no hi ha cap error.»", "o": ["perfectament", "perfecta", "perfectement"], "e": "Perfecta + ment."},
      {"q": "Escriu l'adverbi en -ment de «tranquil».", "a": ["tranquil·lament"], "e": "Tranquil·la + ment."},
      {"q": "Escriu l'adverbi en -ment de «lent».", "a": ["lentament"], "e": "Lentament."},
      {"q": "Escriu la paraula de la comparació d'igualtat: «És tan alt ___ son pare.»", "a": ["com"], "e": "Tan ... com."},
      {"q": "Escriu el contrari de «també» en una frase negativa.", "a": ["tampoc"], "e": "Tampoc."}
    ]
  },
  {
    "id": "46796358-e58c-4953-a44d-261766273faa", "type": "b1_mor_connectors", "sort_order": 11,
    "title": "Conjuncions i connectors", "name": "Adversatius, concessius, consecutius, temporals i condicionals",
    "content": "Conjuncions i connectors adversatius i concessius (encara que, sinó, tot i que), consecutius (doncs, per tant, així), temporals (quan, mentres, cada volta que, abans que, després que) i condicionals (si, en cas que) (3.2.2).", "icon": "🔗", "color": "#E6EE9C",
    "exercises": [
      {"q": "«No vull café, ___ te.»", "o": ["sinó", "si no", "però"], "e": "Sinó: corregix una negació anterior (no A, sinó B)."},
      {"q": "«___ vens, avisa'm.» (condició)", "o": ["Si no", "Sinó", "Sino"], "e": "Si no (separat): condició negativa. Sinó: «no A, sinó B»."},
      {"q": "«No és que no vullga, ___ no pot.»", "o": ["sinó que", "si no que", "però que"], "e": "Sinó que + oració."},
      {"q": "«És car, ___ val la pena.»", "o": ["però", "sinó", "perquè"], "e": "Però: oposició."},
      {"q": "«___ plou, eixirem a passejar.» (concessiva)", "o": ["Encara que", "Perquè", "Així que"], "e": "Encara que: concessió (malgrat que)."},
      {"q": "«___ estava cansat, va acabar la faena.»", "o": ["Tot i que", "Per tant", "Sempre que"], "e": "Tot i que = encara que."},
      {"q": "«Ha estudiat molt; ___, ha aprovat.»", "o": ["per tant", "encara que", "sinó"], "e": "Per tant: conseqüència."},
      {"q": "«No t'agrada? ___, no te'l menges.» (conseqüència)", "o": ["Doncs", "Perquè", "Encara que"], "e": "Doncs: consecutiu. No s'usa com a causal («puix»)."},
      {"q": "«Feia molt de fred, ___ vam encendre l'estufa.»", "o": ["així que", "encara que", "sinó"], "e": "Així que / de manera que: conseqüència."},
      {"q": "«___ arribes, telefona'm.»", "o": ["Quan", "Quant", "Mentre que no"], "e": "Quan: temporal."},
      {"q": "«___ cuinava, escoltava la ràdio.» (simultaneïtat)", "o": ["Mentres (o mentre)", "Després que", "Abans que"], "e": "Mentres: dues accions al mateix temps."},
      {"q": "«___ ve, porta un regal.» (repetició)", "o": ["Cada volta que", "Abans que", "Encara que"], "e": "Cada volta (o vegada) que: repetició."},
      {"q": "«Renta't les mans ___ menjar.»", "o": ["abans de", "abans que", "després que"], "e": "Abans de + infinitiu (mateix subjecte)."},
      {"q": "«Hem d'eixir ___ comence a ploure.»", "o": ["abans que (no)", "abans de", "després de"], "e": "Abans que (no) + subjuntiu (subjectes diferents)."},
      {"q": "«___ dinar, farem la becaina.»", "o": ["Després de", "Després que", "Abans que"], "e": "Després de + infinitiu."},
      {"q": "«T'ajudaré ___ m'ho demanes.»", "o": ["sempre que", "sinó", "encara"], "e": "Sempre que: cada vegada que / amb la condició que."},
      {"q": "«___, el partit s'ajornarà.» (condició amb «en cas que»)", "o": ["En cas que ploga", "En cas que plou", "En cas que plourà"], "e": "En cas que + subjuntiu: en cas que ploga."},
      {"q": "«___ tinguera diners, viatjaria.»", "o": ["Si", "Sinó", "Quan"], "e": "Si + imperfet de subjuntiu, condicional en la principal."},
      {"q": "Quina és correcta?", "o": ["Si tinguera temps, t'ajudaria.", "Si tindria temps, t'ajudaria.", "Si tenia temps, t'ajudaria."], "e": "Mai «si» + condicional: si tinguera."},
      {"q": "«No va vindre ___ estava malalt.» (causa)", "o": ["perquè", "per què", "per a què"], "e": "Perquè: causa."},
      {"q": "«Parla més fort ___ et sentim.» (finalitat)", "o": ["perquè", "per què", "per tant"], "e": "Perquè + subjuntiu: finalitat (perquè et sentim)."},
      {"q": "«___ siga difícil, ho aconseguirem.»", "o": ["Per difícil que", "Per tant", "Doncs"], "e": "Per + adjectiu + que + subjuntiu: concessiva."},
      {"q": "«Malgrat ___, vam anar d'excursió.»", "o": ["la pluja", "que la pluja", "de la pluja"], "e": "Malgrat + nom / malgrat que + verb."},
      {"q": "«Esperarem ___ arribe.»", "o": ["fins que", "fins a", "fins"], "e": "Fins que + verb."},
      {"q": "«___ va eixir el sol, vam anar a la platja.»", "o": ["Tan prompte com", "Encara que", "Sinó"], "e": "Tan prompte com: immediatament després que."},
      {"q": "«Tenia raó; ___, ningú li va fer cas.»", "o": ["tanmateix", "per tant", "així que"], "e": "Tanmateix (o no obstant això): oposició."},
      {"q": "Escriu el connector: «No és roig, ___ taronja.»", "a": ["sinó"], "e": "Sinó."},
      {"q": "Escriu el connector: «___ ploga, eixiré.» (concessiu, dues paraules)", "a": ["encara que", "tot i que"], "e": "Encara que."},
      {"q": "Escriu el connector consecutiu de dues paraules: «Ha plogut; per ___, el camp està mullat.»", "a": ["tant"], "e": "Per tant."},
      {"q": "Escriu el connector temporal de simultaneïtat: «___ tu cuines, jo pare la taula.»", "a": ["mentres", "mentre", "mentre que", "mentres que"], "e": "Mentres (o mentre)."}
    ]
  },
  {
    "id": "89c56ceb-f29e-42f7-b327-8f498302c9ed", "type": "b1_mor_verbs_regulars", "sort_order": 12,
    "title": "Verbs regulars", "name": "Present, passat, perfet, plusquamperfet, futur, subjuntiu i condicional",
    "content": "Conjugació dels verbs regulars: present, passat simple i perifràstic, perfet, plusquamperfet, futur d'indicatiu, present i imperfet de subjuntiu i condicional simple (3.2.2).", "icon": "⏳", "color": "#BBDEFB",
    "exercises": [
      {"q": "«Jo ___ en una botiga.» (treballar, present)", "o": ["treballe", "treballo", "treball"], "e": "En valencià, la primera persona del present: treballe, cante, parle."},
      {"q": "«Nosaltres ___ valencià.» (parlar, present)", "o": ["parlem", "parlam", "parlàm"], "e": "Parlem, parleu, parlen."},
      {"q": "«Ells ___ molta fruita.» (menjar, present)", "o": ["mengen", "menjen", "menjan"], "e": "Menjar: menge, menges, menja, mengem, mengeu, mengen."},
      {"q": "«Jo ___ a les set.» (dormir, present)", "o": ["dorm", "dormisc", "dormo"], "e": "Dormir és pur: jo dorm, tu dorms, ell dorm."},
      {"q": "«Jo ___ el menjar.» (servir, present)", "o": ["servisc", "servix", "servixo"], "e": "Verbs incoatius: servisc, servixes, servix, servim, serviu, servixen."},
      {"q": "«Ell ___ molt bé.» (llegir, present)", "o": ["llig", "llegix", "lleix"], "e": "Llegir: llig, lliges, llig, llegim, llegiu, lligen."},
      {"q": "«Ahir ___ al cine.» (anar, perifràstic, jo)", "o": ["vaig anar", "vaig a anar", "aní vaig"], "e": "Passat perifràstic: vaig + infinitiu (vaig anar = aní)."},
      {"q": "«L'any passat ___ a Roma.» (viatjar, perifràstic, nosaltres)", "o": ["vam viatjar (o vàrem viatjar)", "anem viatjar", "vam viatjat"], "e": "Vam / vàrem + infinitiu."},
      {"q": "«Ahir ell ___ tota la vesprada.» (estudiar, passat simple)", "o": ["estudià", "estudiava", "estudie"], "e": "Passat simple: estudií, estudiares, estudià, estudiàrem, estudiàreu, estudiaren."},
      {"q": "Quina és la forma de passat simple de «cantar» per a «tu»?", "o": ["cantares", "cantaves", "cantaràs"], "e": "Tu cantares (= vas cantar)."},
      {"q": "«Hui ___ molt.» (treballar, perfet, jo)", "o": ["he treballat", "havia treballat", "vaig treballar"], "e": "Perfet: he + participi, per a fets d'un temps no acabat (hui, enguany, esta setmana)."},
      {"q": "«Enguany ___ molts llibres.» (llegir, perfet, nosaltres)", "o": ["hem llegit", "havem llegits", "vam llegir hui"], "e": "Hem llegit (també «havem» col·loquial; en estàndard, hem)."},
      {"q": "«Quan vaig arribar, el tren ja ___.» (eixir, plusquamperfet)", "o": ["havia eixit", "ha eixit", "va eixir"], "e": "Plusquamperfet: havia + participi, una acció anterior a una altra del passat."},
      {"q": "«Demà ___ a la platja.» (anar, futur, nosaltres)", "o": ["anirem", "anarem", "anem a anar"], "e": "Futur: aniré, aniràs, anirà, anirem, anireu, aniran."},
      {"q": "«L'any que ve ___ a la universitat.» (estudiar, futur, jo)", "o": ["estudiaré", "estudiarè", "estudiare"], "e": "Estudiaré (amb é tancada)."},
      {"q": "«Vull que ___ prompte.» (arribar, present de subjuntiu, tu)", "o": ["arribes", "arribaràs", "arribe"], "e": "Present de subjuntiu: arribe, arribes, arribe, arribem, arribeu, arriben."},
      {"q": "«Espere que ell ___ el problema.» (entendre, present de subjuntiu)", "o": ["entenga", "entén", "entendrà"], "e": "Entendre: que jo entenga, que ell entenga."},
      {"q": "«Espere que ells ___ la porta.» (obrir, present de subjuntiu)", "o": ["obriguen", "obren", "obrisquen"], "e": "Obrir: que obriga, obrigues, obriga, obrim, obriu, obriguen."},
      {"q": "«Si ___ temps, vindria.» (tindre, imperfet de subjuntiu)", "o": ["tinguera", "tindria", "tenia"], "e": "Imperfet de subjuntiu: tinguera, tingueres, tinguera..."},
      {"q": "«Si ___ més, aprovaries.» (estudiar, imperfet de subjuntiu, tu)", "o": ["estudiares", "estudiaries", "estudiaves"], "e": "Estudiara, estudiares, estudiara, estudiàrem, estudiàreu, estudiaren."},
      {"q": "«M'agradaria que ___ a la festa.» (vindre, imperfet de subjuntiu, vosaltres)", "o": ["vinguéreu", "vindríeu", "veníeu"], "e": "Imperfet de subjuntiu: vinguera, vingueres, vinguera, vinguérem, vinguéreu, vingueren."},
      {"q": "«Jo ___ una casa al camp.» (comprar, condicional)", "o": ["compraria", "compraré", "comprara"], "e": "Condicional: compraria, compraries, compraria, compraríem, compraríeu, comprarien."},
      {"q": "«Nosaltres ___ encantats.» (estar, condicional)", "o": ["estaríem", "estaríam", "estarem"], "e": "Estaríem (amb accent)."},
      {"q": "«Quan era xicotet, ___ a futbol cada dia.» (jugar, imperfet)", "o": ["jugava", "jugaba", "juguí"], "e": "Imperfet: jugava, jugaves, jugava, jugàvem, jugàveu, jugaven."},
      {"q": "Quina és la forma del gerundi de «cantar»?", "o": ["cantant", "cantan", "cantando"], "e": "Gerundi: cantant, temint, dormint."},
      {"q": "Quina és la forma del participi de «temer»?", "o": ["temut", "temit", "temido"], "e": "Participi de la segona conjugació: temut, perdut, venut."},
      {"q": "Escriu el present de «cantar» per a «jo».", "a": ["cante"], "e": "Cante."},
      {"q": "Escriu el futur de «parlar» per a «nosaltres».", "a": ["parlarem"], "e": "Parlarem."},
      {"q": "Escriu el passat perifràstic de «menjar» per a «jo».", "a": ["vaig menjar"], "e": "Vaig menjar."},
      {"q": "Escriu el condicional de «viatjar» per a «jo».", "a": ["viatjaria"], "e": "Viatjaria."},
      {"q": "Escriu l'imperfet de subjuntiu de «parlar» per a «jo».", "a": ["parlara", "parlés"], "e": "Parlara (o parlés)."}
    ]
  },
  {
    "id": "8c30c366-0748-47c4-9314-14ad0cc65797", "type": "b1_mor_verbs_irregulars", "sort_order": 13,
    "title": "Verbs irregulars", "name": "Nàixer, córrer, saber, voler, ser, vore, anar, estar, fer, dir, poder, tindre, conéixer, omplir, obrir i tossir",
    "content": "Conjugació dels verbs irregulars del B1: nàixer, córrer, saber, voler, ser, vore, anar, estar, fer, dir-se, poder, tindre, conéixer, omplir, obrir i tossir (3.2.2).", "icon": "🌀", "color": "#FFCDD2",
    "exercises": [
      {"q": "«Jo ___ a Gandia.» (nàixer, passat perifràstic)", "o": ["vaig nàixer", "vaig naixer", "vaig néixer"], "e": "Nàixer (o néixer): vaig nàixer. Participi: nascut."},
      {"q": "Quin és el participi de «nàixer»?", "o": ["nascut", "naixut", "nacit"], "e": "Nascut / nascuda."},
      {"q": "«Jo ___ cada matí.» (córrer, present)", "o": ["córrec", "corre", "corro"], "e": "Córrer: córrec, corres, corre, correm, correu, corren."},
      {"q": "Quin és el participi de «córrer»?", "o": ["corregut", "corrut", "corrit"], "e": "Corregut."},
      {"q": "«No ___ on viu.» (saber, present, jo)", "o": ["sé", "sap", "sabo"], "e": "Saber: sé, saps, sap, sabem, sabeu, saben."},
      {"q": "«Vull que ho ___.» (saber, subjuntiu, tu)", "o": ["sàpies", "sabes", "sapigues"], "e": "Subjuntiu: sàpia, sàpies, sàpia, sapiem, sapieu, sàpien."},
      {"q": "«Jo ___ un café.» (voler, present)", "o": ["vull", "vol", "volc"], "e": "Voler: vull, vols, vol, volem, voleu, volen."},
      {"q": "«Fes el que ___.» (voler, subjuntiu, tu)", "o": ["vullgues", "vols", "volgues"], "e": "Que jo vullga, que tu vullgues."},
      {"q": "Quin és el participi de «voler»?", "o": ["volgut", "volit", "vullgut"], "e": "Volgut."},
      {"q": "«Nosaltres ___ de València.» (ser, present)", "o": ["som", "sem", "sóm"], "e": "Ser: sóc (o soc), eres, és, som, sou, són."},
      {"q": "«Espere que ___ feliços.» (ser, subjuntiu, vosaltres)", "o": ["sigueu", "sou", "sigau"], "e": "Subjuntiu de ser: siga, sigues, siga, siguem, sigueu, siguen."},
      {"q": "«Si ___ ric, viatjaria.» (ser, imperfet de subjuntiu, jo)", "o": ["fora", "seria", "era"], "e": "Imperfet de subjuntiu de ser: fora, fores, fora, fórem, fóreu, foren."},
      {"q": "«Jo ___ la mar des de la finestra.» (vore, present)", "o": ["veig", "veu", "vec"], "e": "Vore (o veure): veig, veus, veu, veiem, veieu, veuen."},
      {"q": "Quin és el participi de «vore»?", "o": ["vist", "vorut", "veut"], "e": "Vist / vista."},
      {"q": "«Demà ___ la pel·lícula.» (vore, futur, nosaltres)", "o": ["vorem", "vorerem", "veiem"], "e": "Vore: voré, voràs, vorà, vorem, voreu, voran (amb veure: veuré)."},
      {"q": "«Jo ___ a l'escola a peu.» (anar, present)", "o": ["vaig", "vac", "vaig a"], "e": "Anar: vaig, vas, va, anem, aneu, van."},
      {"q": "«Vull que ___ al metge.» (anar, subjuntiu, tu)", "o": ["vages", "vas", "anes"], "e": "Que jo vaja, que tu vages, que ell vaja, que anem, que aneu, que vagen."},
      {"q": "«Jo ___ molt cansat.» (estar, present)", "o": ["estic", "estoc", "estàc"], "e": "Estar: estic, estàs, està, estem, esteu, estan."},
      {"q": "«Espere que ___ bé.» (estar, subjuntiu, tu)", "o": ["estigues", "estàs", "esteves"], "e": "Que estiga, estigues, estiga..."},
      {"q": "«Jo ___ el sopar.» (fer, present)", "o": ["faig", "fac", "fai"], "e": "Fer: faig, fas, fa, fem, feu, fan."},
      {"q": "«Vull que ho ___ ara.» (fer, subjuntiu, tu)", "o": ["faces", "fas", "fagues"], "e": "Que faça, faces, faça, fem, feu, facen."},
      {"q": "«Ahir ell ___ els deures.» (fer, passat simple)", "o": ["féu", "feu", "fiu"], "e": "Passat simple: fiu, feres, féu, férem, féreu, feren."},
      {"q": "«Com et ___?» (dir-se, present, tu)", "o": ["dius", "dieus", "dius-te"], "e": "Dir: dic, dius, diu, diem, dieu, diuen. Com et dius?"},
      {"q": "«Vull que em ___ la veritat.» (dir, subjuntiu, tu)", "o": ["digues", "dius", "diguis"], "e": "Que diga, digues, diga..."},
      {"q": "«Jo no ___ vindre.» (poder, present)", "o": ["puc", "pot", "poc"], "e": "Poder: puc, pots, pot, podem, podeu, poden."},
      {"q": "«Espere que ___ vindre.» (poder, subjuntiu, ell)", "o": ["puga", "pot", "pogue"], "e": "Que puga, pugues, puga, puguem, pugueu, puguen."},
      {"q": "«Jo ___ dos gats.» (tindre, present)", "o": ["tinc", "tenc", "tin"], "e": "Tindre (o tenir): tinc, tens, té, tenim, teniu, tenen."},
      {"q": "Quin és el participi de «tindre»?", "o": ["tingut", "tengut", "tenit"], "e": "Tingut."},
      {"q": "«Jo no ___ ningú ací.» (conéixer, present)", "o": ["conec", "conéixo", "coneix"], "e": "Conéixer: conec, coneixes, coneix, coneixem, coneixeu, coneixen."},
      {"q": "Quin és el participi de «conéixer»?", "o": ["conegut", "conéixut", "coneixit"], "e": "Conegut."},
      {"q": "«Ell ___ el got d'aigua.» (omplir, present)", "o": ["ompli", "omple", "omplix"], "e": "Omplir: omplic, omples, ompli, omplim, ompliu, omplen."},
      {"q": "«Jo ___ la finestra.» (obrir, present)", "o": ["obric", "obro", "obrisc"], "e": "Obrir: obric, obris, obri, obrim, obriu, obrin (o obren)."},
      {"q": "Quin és el participi de «obrir»?", "o": ["obert", "obrit", "obrut"], "e": "Obert / oberta."},
      {"q": "«Ell ___ molt a la nit.» (tossir, present)", "o": ["tus", "tos", "tossix"], "e": "Tossir: tus, tusses, tus, tossim, tossiu, tussen."},
      {"q": "Escriu el present de «tindre» per a «jo».", "a": ["tinc"], "e": "Tinc."},
      {"q": "Escriu el present de «fer» per a «jo».", "a": ["faig"], "e": "Faig."},
      {"q": "Escriu el participi de «obrir».", "a": ["obert"], "e": "Obert."},
      {"q": "Escriu el present de subjuntiu de «anar» per a «jo»: que jo ___.", "a": ["vaja"], "e": "Vaja."},
      {"q": "Escriu el present de «conéixer» per a «jo».", "a": ["conec"], "e": "Conec."}
    ]
  },
  {
    "id": "f7e75d17-2e5c-4058-8a7a-add0197ad5c4", "type": "b1_mor_regim", "sort_order": 14,
    "title": "Verbs de règim preposicional", "name": "Atrevir-se a, començar a, decidir-se a, negar-se a, pensar en, confiar en...",
    "content": "Els verbs que porten una preposició fixa davant del complement (atrevir-se a, començar a, decidir-se a, negar-se a, pensar en, confiar en...) i la caiguda de la preposició davant de que (3.2.2).", "icon": "🧷", "color": "#D7CCC8",
    "exercises": [
      {"q": "«No m'atrevisc ___ dir-li-ho.»", "o": ["a", "de", "en"], "e": "Atrevir-se a."},
      {"q": "«Ha començat ___ ploure.»", "o": ["a", "de", "per"], "e": "Començar a + infinitiu."},
      {"q": "«Per fi s'ha decidit ___ comprar el pis.»", "o": ["a", "de", "en"], "e": "Decidir-se a (però «decidir» sense pronom: he decidit comprar-lo)."},
      {"q": "«Es nega ___ menjar verdura.»", "o": ["a", "de", "en"], "e": "Negar-se a."},
      {"q": "«Pense molt ___ tu.»", "o": ["en", "a", "de"], "e": "Pensar en algú o en alguna cosa."},
      {"q": "«Confie ___ tu: sé que ho faràs bé.»", "o": ["en", "a", "de"], "e": "Confiar en."},
      {"q": "«M'he acostumat ___ matinar.»", "o": ["a", "de", "en"], "e": "Acostumar-se a."},
      {"q": "«Estic aprenent ___ nadar.»", "o": ["a", "de", "per"], "e": "Aprendre a + infinitiu."},
      {"q": "«M'ha ajudat ___ fer la mudança.»", "o": ["a", "de", "en"], "e": "Ajudar a + infinitiu."},
      {"q": "«Ens han convidat ___ sopar.»", "o": ["a", "de", "per"], "e": "Convidar a."},
      {"q": "«S'ha enamorat ___ una companya de classe.»", "o": ["d'", "a", "en"], "e": "Enamorar-se de."},
      {"q": "«No ___ el seu nom.» (recordar)", "o": ["recorde", "recorde de", "me'n recorde el"], "e": "Recordar alguna cosa, sense preposició: no recorde el seu nom. Amb pronom: no me'n recorde."},
      {"q": "«M'he oblidat ___ les claus.»", "o": ["de", "a", "en"], "e": "Oblidar-se de (o oblidar alguna cosa: he oblidat les claus)."},
      {"q": "«No m'he adonat ___ l'error.»", "o": ["de", "a", "en"], "e": "Adonar-se de."},
      {"q": "«S'ha adonat ___ ningú l'escoltava.»", "o": ["que", "de que", "en que"], "e": "Davant de la conjunció que, la preposició cau: s'ha adonat que..."},
      {"q": "«Pense ___ vindrà demà.»", "o": ["que", "en que", "de que"], "e": "Pensar que + oració (sense en)."},
      {"q": "«Confie ___ tot eixirà bé.»", "o": ["que", "en que", "de que"], "e": "Confiar que (la preposició en cau davant de que)."},
      {"q": "«Insistix ___ pagar ell.»", "o": ["a (o en)", "de", "per"], "e": "Insistir a (o en) + infinitiu."},
      {"q": "«El joc consistix ___ endevinar la paraula.»", "o": ["a (o en)", "de", "per"], "e": "Consistir en (o a)."},
      {"q": "«Es dedica ___ la docència.»", "o": ["a", "de", "en"], "e": "Dedicar-se a."},
      {"q": "«Tinc ganes ___ vore't.»", "o": ["de", "a", "per"], "e": "Tindre ganes de."},
      {"q": "«S'ha queixat ___ soroll.»", "o": ["del", "al", "en el"], "e": "Queixar-se de."},
      {"q": "«Ha tardat molt ___ arribar.»", "o": ["a", "de", "per"], "e": "Tardar a (o en) + infinitiu."},
      {"q": "«Han obligat els treballadors ___ fer hores extra.»", "o": ["a", "de", "en"], "e": "Obligar a."},
      {"q": "«Es fia molt ___ la seua germana.»", "o": ["de", "a", "en"], "e": "Fiar-se de."},
      {"q": "«Ens hem posat d'acord ___ el preu.»", "o": ["en (o sobre)", "a", "per"], "e": "Posar-se d'acord en / sobre alguna cosa."},
      {"q": "«Depén ___ tu.»", "o": ["de", "a", "en"], "e": "Dependre de."},
      {"q": "«Està interessat ___ la feina.»", "o": ["en (o per)", "a", "de"], "e": "Interessat en o per."},
      {"q": "Escriu la preposició: «No t'atrevixes ___ saltar?»", "a": ["a"], "e": "Atrevir-se a."},
      {"q": "Escriu la preposició: «Pensa ___ els altres.»", "a": ["en"], "e": "Pensar en."},
      {"q": "Escriu la preposició: «S'ha negat ___ signar.»", "a": ["a"], "e": "Negar-se a."},
      {"q": "Escriu la preposició: «Ens hem enamorat ___ este poble.»", "a": ["de"], "e": "Enamorar-se de."}
    ]
  },
  {
    "id": "e5f3f3e9-5a53-441d-b318-060e27c2c04c", "type": "b1_mor_modes", "sort_order": 15,
    "title": "Indicatiu, subjuntiu i imperatiu", "name": "Usos dels modes verbals",
    "content": "Quan s'usa l'indicatiu, el subjuntiu i l'imperatiu: desig, dubte, finalitat, temps futur, relatives i ordres afirmatives i negatives (3.2.2).", "icon": "🎭", "color": "#B2EBF2",
    "exercises": [
      {"q": "«Sé que ___ raó.» (tindre, tu)", "o": ["tens", "tingues", "tinguera"], "e": "Saber que + indicatiu: es presenta com un fet."},
      {"q": "«Vull que ___ a la festa.» (vindre, tu)", "o": ["vingues", "véns", "vindràs"], "e": "Voler que + subjuntiu (desig)."},
      {"q": "«Espere que ___ bon temps demà.» (fer)", "o": ["faça", "fa", "farà"], "e": "Esperar que + subjuntiu."},
      {"q": "«Tant de bo ___!» (aprovar, tu)", "o": ["aproves", "aprovaràs", "aprovas"], "e": "Tant de bo + subjuntiu: desig."},
      {"q": "«Crec que ___ a ploure.» (anar)", "o": ["va", "vaja", "anara"], "e": "Creure que (afirmatiu) + indicatiu."},
      {"q": "«No crec que ___ a ploure.» (anar)", "o": ["vaja", "va", "anirà"], "e": "No creure que + subjuntiu (dubte)."},
      {"q": "«És possible que ___ tard.» (arribar, ells)", "o": ["arriben", "arribaran", "arribaven"], "e": "És possible / és probable que + subjuntiu."},
      {"q": "«És evident que ___ raó.» (tindre, ell)", "o": ["té", "tinga", "tinguera"], "e": "És evident / és clar que + indicatiu (certesa)."},
      {"q": "«T'ho explique perquè ho ___.» (entendre, tu: finalitat)", "o": ["entengues", "entens", "entendràs"], "e": "Perquè de finalitat + subjuntiu."},
      {"q": "«No ha vingut perquè ___ malalt.» (estar, ell: causa)", "o": ["està", "estiga", "estiguera"], "e": "Perquè de causa + indicatiu."},
      {"q": "«Quan ___ a casa, telefona'm.» (arribar, tu)", "o": ["arribes", "arribaràs", "arribaries"], "e": "Quan + futur → present de subjuntiu: quan arribes."},
      {"q": "«Quan ___ a casa, sempre sopem junts.» (arribar, jo: costum)", "o": ["arribe (indicatiu)", "arribaré", "arribara"], "e": "Quan + costum: indicatiu (arribe)."},
      {"q": "«Busque un pis que ___ terrassa.» (tindre: encara no el conec)", "o": ["tinga", "té", "tindrà"], "e": "Relativa amb antecedent desconegut: subjuntiu."},
      {"q": "«Visc en un pis que ___ terrassa.» (tindre: el conec)", "o": ["té", "tinga", "tinguera"], "e": "Antecedent conegut: indicatiu."},
      {"q": "«M'agradaria que ___ amb mi.» (vindre, tu)", "o": ["vingueres", "vingues", "vindries"], "e": "Condicional en la principal → imperfet de subjuntiu."},
      {"q": "Quin és l'imperatiu de «cantar» per a «tu»?", "o": ["canta", "cantes", "cante"], "e": "Imperatiu: canta (tu), cante (vosté), cantem, canteu, canten (vostés)."},
      {"q": "Quin és l'imperatiu de «cantar» per a «vosté»?", "o": ["cante", "canta", "cantes"], "e": "Vosté: cante (forma del subjuntiu)."},
      {"q": "Quin és l'imperatiu negatiu de «cantar» per a «tu»?", "o": ["no cantes", "no canta", "no cantar"], "e": "L'imperatiu negatiu usa el subjuntiu: no cantes, no canteu."},
      {"q": "Quin és l'imperatiu de «vindre» per a «tu»?", "o": ["vine", "vin", "vens"], "e": "Vine (tu), vinga (vosté), veniu (vosaltres)."},
      {"q": "Quin és l'imperatiu negatiu de «vindre» per a «tu»?", "o": ["no vingues", "no vine", "no véns"], "e": "No vingues."},
      {"q": "Quin és l'imperatiu de «fer» per a «tu»?", "o": ["fes", "fa", "faces"], "e": "Fes (tu), faça (vosté), feu (vosaltres)."},
      {"q": "Quin és l'imperatiu de «anar» per a «tu»?", "o": ["ves", "va", "vages"], "e": "Ves (tu), vaja (vosté), aneu (vosaltres). Ves-te'n!"},
      {"q": "Quin és l'imperatiu de «dir» per a «tu»?", "o": ["digues", "diu", "di"], "e": "Digues (tu), diga (vosté), digueu (vosaltres)."},
      {"q": "Quin és l'imperatiu de «ser» per a «tu»?", "o": ["sigues", "és", "sé"], "e": "Sigues bo!, sigueu puntuals!"},
      {"q": "Quin és l'imperatiu de «tindre» per a «tu» quan dones una cosa?", "o": ["té (o tin)", "tens", "tingues"], "e": "Té! (o tin): agafa. Tingues paciència: tingues."},
      {"q": "Quin és l'imperatiu de «seure» per a «vosaltres»?", "o": ["seieu", "seeu", "seureu"], "e": "Seure: seu (tu), siga o sega (vosté), seieu (vosaltres)."},
      {"q": "«Perdone, ___'m on és l'estació.» (dir, vosté)", "o": ["diga", "digues", "diu"], "e": "Amb vosté: diga'm (diga + em)."},
      {"q": "«No ___ tan de pressa!» (córrer, tu)", "o": ["corregues", "corres", "corre"], "e": "Imperatiu negatiu: no corregues."},
      {"q": "Escriu l'imperatiu de «parlar» per a «tu».", "a": ["parla"], "e": "Parla."},
      {"q": "Escriu l'imperatiu negatiu de «parlar» per a «tu»: no ___.", "a": ["parles"], "e": "No parles."},
      {"q": "Escriu el verb en subjuntiu: «Vull que ___ (vindre, tu).»", "a": ["vingues"], "e": "Vingues."},
      {"q": "Escriu el verb en indicatiu: «Sé que ___ (estar, ell) ací.»", "a": ["està"], "e": "Està."}
    ]
  },
  {
    "id": "379adbb2-a63b-465b-85a8-57fc66b1f877", "type": "b1_mor_perifrasis", "sort_order": 16,
    "title": "Ser, estar, semblar i perífrasis", "name": "Ser i estar locatius, semblar, haver de, caldre i deure",
    "content": "Els verbs ser i estar amb valor locatiu, el verb semblar i les perífrasis d'obligació (haver de, deure, caldre + infinitiu) i de probabilitat (deure + infinitiu) (3.2.2).", "icon": "🧭", "color": "#C8E6C9",
    "exercises": [
      {"q": "«On ___ el museu?» (localització d'un edifici)", "o": ["és (o està)", "hi ha", "fa"], "e": "Per a localitzar, en valencià s'usen ser i estar: on és / on està el museu."},
      {"q": "«El concert ___ a la plaça Major.» (localització d'un esdeveniment)", "o": ["serà", "estarà", "hi haurà a"], "e": "Per als esdeveniments (concerts, festes, reunions), ser: el concert serà a la plaça."},
      {"q": "«La reunió ___ en la sala de professors.»", "o": ["és", "està", "té"], "e": "Esdeveniment → ser."},
      {"q": "«Ara mateix el meu germà ___ a casa.»", "o": ["està (o és)", "hi ha", "té"], "e": "Persones i coses: ser o estar locatiu."},
      {"q": "«___ una farmàcia a prop?» (existència)", "o": ["Hi ha", "Està", "És"], "e": "Hi ha: existència (sense determinant definit)."},
      {"q": "«Està cansat? ___ que no ha dormit.»", "o": ["Sembla", "Assembla", "Es sembla"], "e": "Semblar que: tindre aparença."},
      {"q": "«Què et ___ el pla?» «Em ___ molt bé.»", "o": ["sembla / sembla", "assembla / assembla", "sembles / semblen"], "e": "Semblar: opinió (em sembla bé)."},
      {"q": "«El xiquet ___ molt a son pare.»", "o": ["s'assembla", "sembla", "assembla"], "e": "Assemblar-se a algú: tindre semblança física o de caràcter."},
      {"q": "«Pareixen germans» es pot dir també...", "o": ["«Semblen germans»", "«Assemblen germans»", "«Es semblen a germans»"], "e": "Semblar (o paréixer): tindre l'aparença de."},
      {"q": "«Demà ___ d'anar al metge.» (obligació, jo)", "o": ["he", "tinc que", "deuré de"], "e": "Haver de + infinitiu: he d'anar."},
      {"q": "Quina és la forma correcta d'expressar obligació?", "o": ["Has d'estudiar més.", "Tens que estudiar més.", "Tens de que estudiar més."], "e": "«Tindre que» és un castellanisme: haver de + infinitiu."},
      {"q": "«___ portar el DNI per a votar.» (obligació impersonal)", "o": ["Cal", "Calen", "Tenen que"], "e": "Caldre + infinitiu: cal portar."},
      {"q": "«___ que vingues prompte.»", "o": ["Cal", "Cal de", "Ha de"], "e": "Cal que + subjuntiu."},
      {"q": "«Em ___ uns pantalons nous.» (necessitat)", "o": ["calen", "cal", "fa falta que"], "e": "Caldre concorda amb el que es necessita: em cal un, em calen uns."},
      {"q": "«No ___ que vingues, ja ho faig jo.»", "o": ["cal", "calen", "tens que"], "e": "No cal que: no és necessari."},
      {"q": "«___ ser les cinc: ja es fa fosc.» (probabilitat)", "o": ["Deuen", "Han", "Calen"], "e": "Deure + infinitiu: probabilitat (deuen ser les cinc)."},
      {"q": "«No contesta: ___ estar dormint.» (probabilitat)", "o": ["deu", "ha", "cal"], "e": "Deu estar dormint = probablement està dormint."},
      {"q": "«Els fills ___ respectar els pares.» (obligació moral)", "o": ["deuen", "han de que", "tenen que"], "e": "Deure + infinitiu també pot expressar obligació."},
      {"q": "Quina frase expressa probabilitat?", "o": ["Deu tindre uns trenta anys.", "Ha de pagar la factura.", "Cal reciclar."], "e": "Deure + infinitiu: suposició."},
      {"q": "Quina frase expressa obligació impersonal?", "o": ["Cal reciclar.", "Deu ser tard.", "Sembla cansat."], "e": "Caldre: obligació o necessitat sense subjecte personal."},
      {"q": "«___ dutxar-se abans d'entrar a la piscina.»", "o": ["Cal", "Cal de", "Tens que"], "e": "Caldre + infinitiu, sense preposició: cal dutxar-se (o s'ha de dutxar)."},
      {"q": "«Ara mateix ___ estudiant.» (acció en curs, jo)", "o": ["estic", "sóc", "he"], "e": "Estar + gerundi: acció en curs."},
      {"q": "«___ d'arribar: encara porte l'abric.» (acció acabada fa poc)", "o": ["Acabe", "Comence", "Torne"], "e": "Acabar de + infinitiu: acció que fa molt poc que ha passat."},
      {"q": "«He ___ de fumar.» (ja no fume)", "o": ["deixat", "tornat", "acabat"], "e": "Deixar de + infinitiu: interrupció."},
      {"q": "«Ha ___ a ploure.» (una altra vegada)", "o": ["tornat", "deixat", "acabat"], "e": "Tornar a + infinitiu: repetició."},
      {"q": "Escriu el verb d'obligació: «___ d'anar a treballar.» (jo, present)", "a": ["he"], "e": "He d'anar."},
      {"q": "Escriu el verb impersonal: «___ portar el passaport.»", "a": ["cal"], "e": "Cal."},
      {"q": "Corregix la frase: «Tinc que estudiar.»", "a": ["he d'estudiar"], "e": "He d'estudiar."},
      {"q": "Escriu la forma de probabilitat: «___ ser les deu.» (deure)", "a": ["deuen"], "e": "Deuen ser les deu."}
    ]
  }
]$data$::jsonb) AS t(
  id uuid, type text, sort_order smallint, title text, name text,
  content text, icon text, color text, exercises jsonb
);

INSERT INTO public.resources (id, name, type, category, content, difficulty, xp_earned, sort_order, metadata)
SELECT id, name, type, 'morfosintaxi', content, 'intermedi', 15, sort_order,
       jsonb_build_object('icon', icon, 'color', color, 'section_name', title)
FROM practice_catalog
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  type = EXCLUDED.type,
  category = EXCLUDED.category,
  content = EXCLUDED.content,
  difficulty = EXCLUDED.difficulty,
  xp_earned = EXCLUDED.xp_earned,
  sort_order = EXCLUDED.sort_order,
  -- Conserva la lliçó fixa («Aprendre lliçó»), que s'afig en una migració posterior.
  metadata = EXCLUDED.metadata || jsonb_strip_nulls(jsonb_build_object('lesson', resources.metadata -> 'lesson'));

DELETE FROM public.practice_exercises e
USING practice_catalog c
WHERE e.resource_id = c.id AND e.level = 'B1';

INSERT INTO public.practice_exercises (resource_id, level, position, kind, prompt, options, answers, explanation)
SELECT c.id, 'B1', x.ord,
       CASE WHEN x.e ? 'a' THEN 'fill' ELSE 'choice' END,
       x.e->>'q',
       CASE WHEN x.e ? 'o' THEN ARRAY(SELECT jsonb_array_elements_text(x.e->'o')) END,
       CASE WHEN x.e ? 'a' THEN ARRAY(SELECT jsonb_array_elements_text(x.e->'a')) ELSE ARRAY[x.e->'o'->>0] END,
       x.e->>'e'
FROM practice_catalog c
CROSS JOIN LATERAL jsonb_array_elements(c.exercises) WITH ORDINALITY AS x(e, ord);

DROP TABLE practice_catalog;

-- ============================================================
-- Origen: 20261001150000_revisio_exercicis.sql
-- ============================================================
-- Revisió lingüística dels exercicis de pràctica (A2 i B1) amb el corrector de
-- Softcatalà (ca-ES-valencia), el DNV de l'AVL i una revisió exercici per
-- exercici: formes no normatives o no valencianes, concordances, apostrofació
-- («d'«amic»»), exercicis amb dues respostes correctes (variants admeses per
-- l'AVL com a distractors), enunciats que revelaven la resposta i respostes
-- escrites que no acceptaven variants normatives. Cada fila substituïx
-- l'enunciat, les opcions, les respostes i l'explicació de l'exercici
-- (recurs, nivell, posició). Tornar a aplicar el fitxer no canvia res més.

UPDATE public.practice_exercises e SET
  prompt = f.prompt,
  options = CASE WHEN f.options IS NULL OR jsonb_typeof(f.options) = 'null' THEN NULL ELSE ARRAY(SELECT jsonb_array_elements_text(f.options)) END,
  answers = ARRAY(SELECT jsonb_array_elements_text(f.answers)),
  explanation = f.explanation
FROM jsonb_to_recordset($data$[
  {"rid": "0c6366f8-7a2c-4b74-b564-98da8b54071c", "level": "A2", "pos": 1, "prompt": "Vols apuntar-te a una activitat del poliesportiu municipal. Ompli la fitxa d'inscripció.", "options": null, "answers": null, "explanation": null},
  {"rid": "0c6366f8-7a2c-4b74-b564-98da8b54071c", "level": "A2", "pos": 2, "prompt": "Has perdut la maleta a l'aeroport. Ompli el formulari de reclamació.", "options": null, "answers": null, "explanation": null},
  {"rid": "975ade8f-5197-4edc-bd4a-20dd8816d65f", "level": "A2", "pos": 10, "prompt": "Quina forma és correcta?", "options": ["café", "cafe", "càfe"], "answers": ["café"], "explanation": "Ca-FÉ és aguda acabada en vocal: porta accent. En valencià, amb e tancada: café (també s'admet café)."},
  {"rid": "975ade8f-5197-4edc-bd4a-20dd8816d65f", "level": "A2", "pos": 28, "prompt": "Quina d'estes paraules està ben escrita sense accent?", "options": ["germans", "cafe", "musica"], "answers": ["germans"], "explanation": "Ger-MANS és aguda acabada en -ns: no porta accent. Café i música sí que en porten."},
  {"rid": "3d8fbee8-b30f-491c-9906-c442729c5e3d", "level": "A2", "pos": 28, "prompt": "Com se separa en síl·labes «caixa»?", "options": ["cai-xa", "ca-ixa", "caix-a"], "answers": ["cai-xa"], "explanation": "La i forma diftong amb la a i la x va amb la síl·laba següent: cai-xa."},
  {"rid": "32ddfc19-805e-4315-8534-2fdf65376b76", "level": "B1", "pos": 10, "prompt": "Quantes lletres i quants sons té «cotxe»?", "options": ["5 lletres i 4 sons", "5 lletres i 5 sons", "4 lletres i 3 sons"], "answers": ["5 lletres i 4 sons"], "explanation": "Tx és un dígraf amb un sol so [tʃ]: c-o-tx-e."},
  {"rid": "32ddfc19-805e-4315-8534-2fdf65376b76", "level": "B1", "pos": 35, "prompt": "Quina d'estes paraules té el dígraf «ix»?", "options": ["peix", "pex", "pexi"], "answers": ["peix"], "explanation": "Peix, caixa, baix: dígraf ix (en valencià la i se sol pronunciar: [pejʃ])."},
  {"rid": "37c00f03-8d75-42ea-baa1-89cd4efd3442", "level": "B1", "pos": 29, "prompt": "Quin és el plural masculí d'«anglés»?", "options": ["anglesos", "anglessos", "anglés"], "answers": ["anglesos"], "explanation": "Anglés / anglesa / anglesos / angleses."},
  {"rid": "37c00f03-8d75-42ea-baa1-89cd4efd3442", "level": "B1", "pos": 35, "prompt": "Quin és el plural d'«interés»?", "options": ["interessos", "interesos", "interessus"], "answers": ["interessos"], "explanation": "Interés → interessos."},
  {"rid": "013139cd-ab6b-45b5-99e7-58104459f974", "level": "B1", "pos": 3, "prompt": "En quina d'estes expressions s'elidix una vocal en la parla?", "options": ["una amiga", "un amic", "tres amics"], "answers": ["una amiga"], "explanation": "Una_amiga: la -a d'«una» s'unix amb la a d'«amiga» [unamiga]. En «un amic» no hi ha dues vocals en contacte."},
  {"rid": "013139cd-ab6b-45b5-99e7-58104459f974", "level": "B1", "pos": 10, "prompt": "En quina paraula hi ha una r forta entre vocals?", "options": ["carro", "cara", "para"], "answers": ["carro"], "explanation": "Entre vocals, el so fort s'escriu rr: carro, parra, morro."},
  {"rid": "013139cd-ab6b-45b5-99e7-58104459f974", "level": "B1", "pos": 21, "prompt": "Com s'articula «ametla»?", "options": ["amb una l allargada [a-mel-la]", "amb t i l separades molt marcades", "com «ameta»"], "answers": ["amb una l allargada [a-mel-la]"], "explanation": "El grup tl d'«ametla», «espatla» o «guatla» se sol pronunciar com una l doble."},
  {"rid": "013139cd-ab6b-45b5-99e7-58104459f974", "level": "B1", "pos": 29, "prompt": "Quina diferència de sentit hi ha entre «Ja ha vingut.» i «Ja ha vingut?»?", "options": ["La primera afirma; la segona pregunta, amb entonació ascendent", "Són iguals", "La segona és una ordre"], "answers": ["La primera afirma; la segona pregunta, amb entonació ascendent"], "explanation": "L'entonació (i, en l'escriptura, el signe ?) canvia una afirmació en pregunta."},
  {"rid": "013139cd-ab6b-45b5-99e7-58104459f974", "level": "B1", "pos": 33, "prompt": "Quina d'estes paraules té el so [ks]?", "options": ["taxi", "xarop", "caixa"], "answers": ["taxi"], "explanation": "Taxi, fax, tòrax: la x sona [ks]. En «èxit» o «examen» sona [gz]."},
  {"rid": "7baaddb7-7eaf-4f14-bfc3-b2e2e1c04964", "level": "B1", "pos": 6, "prompt": "Quina forma és correcta?", "options": ["pupil·la", "pupila", "pupilla"], "answers": ["pupil·la"], "explanation": "-il·la: pupil·la, vil·la, papil·la. Atenció: pastilla s'escriu amb ll."},
  {"rid": "7baaddb7-7eaf-4f14-bfc3-b2e2e1c04964", "level": "B1", "pos": 9, "prompt": "Quina forma és correcta?", "options": ["ametla", "ametl·la", "amel·la"], "answers": ["ametla"], "explanation": "Ametla (i ametler): grup tl, que es pronuncia com una l doble. També s'admet ametlla."},
  {"rid": "7baaddb7-7eaf-4f14-bfc3-b2e2e1c04964", "level": "B1", "pos": 24, "prompt": "Quina forma és correcta? (queixa de dolor)", "options": ["plany", "planyo", "plañ"], "answers": ["plany"], "explanation": "Plany (plànyer-se)."},
  {"rid": "b556615d-c4c5-4daa-b132-d8a87ed6a179", "level": "B1", "pos": 29, "prompt": "Quina és correcta?", "options": ["el Palau de la Música", "el palau de la música", "el Palau de la música"], "answers": ["el Palau de la Música"], "explanation": "Els noms propis d'edificis i institucions porten majúscula en les paraules significatives: el Palau de la Música, la Llotja de la Seda."},
  {"rid": "f482c820-b45e-4661-bd1f-af514dcaad47", "level": "B1", "pos": 8, "prompt": "Com s'escriu el femení plural d'«amic»?", "options": ["amigues", "amiges", "amicues"], "answers": ["amigues"], "explanation": "Amic / amiga / amics / amigues."},
  {"rid": "f482c820-b45e-4661-bd1f-af514dcaad47", "level": "B1", "pos": 11, "prompt": "Quina forma és correcta?", "options": ["àrab", "àrap", "àrabe"], "answers": ["àrab"], "explanation": "Àrab (plural àrabs): la mateixa forma per al masculí i el femení."},
  {"rid": "f482c820-b45e-4661-bd1f-af514dcaad47", "level": "B1", "pos": 15, "prompt": "Quina forma és correcta? (que no hi sent)", "options": ["sord", "sort", "sorth"], "answers": ["sord"], "explanation": "Sord / sorda. Sort és una altra paraula (la bona sort)."},
  {"rid": "ce18cc3f-74e3-44b7-9613-2853cb3b3290", "level": "B1", "pos": 11, "prompt": "Quin és el masculí plural de «boig»?", "options": ["bojos", "botjos", "bogos"], "answers": ["bojos"], "explanation": "Bojos (també boigs): davant de o, j."},
  {"rid": "ce18cc3f-74e3-44b7-9613-2853cb3b3290", "level": "B1", "pos": 30, "prompt": "Quin és el verb derivat d'«escabetx»?", "options": ["escabetxar", "escabexar", "escabetjar"], "answers": ["escabetxar"], "explanation": "Escabetx → escabetxar."},
  {"rid": "ce18cc3f-74e3-44b7-9613-2853cb3b3290", "level": "B1", "pos": 33, "prompt": "Com es pronuncia la x de «Xàtiva»?", "options": ["[ʃ], com la x de «caixa»", "[ks], com en «taxi»", "[gz], com en «examen»"], "answers": ["[ʃ], com la x de «caixa»"], "explanation": "La x inicial de «Xàtiva» és palatal: [ʃ] (o [tʃ] en molts parlars), mai [ks] ni [gz]."},
  {"rid": "5c7449fa-9786-46ef-ad08-f264cf30ec59", "level": "B1", "pos": 1, "prompt": "Quina frase usa bé el punt i coma?", "options": ["A Pau li agrada el futbol, el bàsquet i el tenis; a Marta, la música i el cine.", "A Pau; li agrada el futbol.", "A Pau li agrada; el futbol, el bàsquet i el tenis."], "answers": ["A Pau li agrada el futbol, el bàsquet i el tenis; a Marta, la música i el cine."], "explanation": "El punt i coma separa parts d'una enumeració que ja tenen comes dins."},
  {"rid": "5c7449fa-9786-46ef-ad08-f264cf30ec59", "level": "B1", "pos": 9, "prompt": "Quina és la forma correcta?", "options": ["pomes, peres, taronges, etc.", "pomes, peres, taronges, etc...", "pomes, peres, taronges... etc."], "answers": ["pomes, peres, taronges, etc."], "explanation": "No es posen punts suspensius després d'«etc.»: tots dos indiquen el mateix."},
  {"rid": "5c7449fa-9786-46ef-ad08-f264cf30ec59", "level": "B1", "pos": 12, "prompt": "Quina opció deixa una frase feta inacabada amb punts suspensius?", "options": ["Ja saps el que diuen: a qui matina...", "Ja saps el que diuen: a qui matina Déu l'ajuda.", "Ja saps el que diuen."], "answers": ["Ja saps el que diuen: a qui matina..."], "explanation": "Quan el lector pot completar una frase coneguda, es talla amb punts suspensius."},
  {"rid": "5c7449fa-9786-46ef-ad08-f264cf30ec59", "level": "B1", "pos": 33, "prompt": "Quina frase usa bé els parèntesis per a indicar una època?", "options": ["Joanot Martorell (segle XV) va escriure el «Tirant».", "Joanot (Martorell segle XV) va escriure el «Tirant».", "Joanot Martorell segle (XV) va escriure el «Tirant»."], "answers": ["Joanot Martorell (segle XV) va escriure el «Tirant»."], "explanation": "Dades complementàries, com dates o segles, entre parèntesis."},
  {"rid": "6fda17fe-be10-433f-9955-38698e488c6a", "level": "B1", "pos": 21, "prompt": "Quina és la pronunciació correcta d'«envia» (ell envia una carta)?", "options": ["en-VI-a", "EN-via", "en-vi-A"], "answers": ["en-VI-a"], "explanation": "En-VI-a: la tònica és la i, i hi ha hiat."},
  {"rid": "6fda17fe-be10-433f-9955-38698e488c6a", "level": "B1", "pos": 27, "prompt": "En «ràpidament», on es posa l'accent gràfic?", "options": ["En «rà-», com en «ràpida»", "En «-ment»", "No en té"], "answers": ["En «rà-», com en «ràpida»"], "explanation": "Els adverbis en -ment conserven l'accent de l'adjectiu: ràpidament, fàcilment."},
  {"rid": "b39add6c-4f6f-4daa-a4b4-a5b4665a3f07", "level": "B1", "pos": 28, "prompt": "«Que jo ___ o no, ho faré igual.» (voler)", "options": ["vullga", "volga", "vollga"], "answers": ["vullga"], "explanation": "Voler: que jo vullga (o vulga), subjuntiu; jo volia (imperfet): alternança u/o."},
  {"rid": "c84eadef-dfd6-44d0-9864-61e37ef55e97", "level": "A2", "pos": 1, "prompt": "Quina forma és correcta? («un ___ i una dona»)", "options": ["home", "ome", "hom"], "answers": ["home"], "explanation": "Home s'escriu amb h inicial muda."},
  {"rid": "77e69eed-4550-4420-a66e-1f226c99a989", "level": "A2", "pos": 35, "prompt": "Escriu el contrari de «jove».", "options": null, "answers": ["vell", "ancià"], "explanation": "Vell, amb ll final."},
  {"rid": "5e910bc3-c0d6-486e-9edc-852f7f7684b2", "level": "A2", "pos": 14, "prompt": "Completa: __uliol (el seté mes de l'any)", "options": ["j", "g", "x"], "answers": ["j"], "explanation": "Juliol: j davant de u."},
  {"rid": "5340aadb-100f-428d-a1ad-6d866a54a2e6", "level": "A2", "pos": 7, "prompt": "«Ell canta» (present) i «ell cantà» (passat): què diferencia «canta» i «cantà»?", "options": ["La síl·laba tònica", "La consonant inicial", "El nombre de síl·labes"], "answers": ["La síl·laba tònica"], "explanation": "CAN-ta és plana i can-TÀ és aguda: canviar la tònica canvia la paraula."},
  {"rid": "5340aadb-100f-428d-a1ad-6d866a54a2e6", "level": "A2", "pos": 10, "prompt": "Quina és la síl·laba tònica d'«ordinador»?", "options": ["-dor", "or-", "-di-"], "answers": ["-dor"], "explanation": "Or-di-na-DOR és aguda: la tònica és l'última síl·laba."},
  {"rid": "5340aadb-100f-428d-a1ad-6d866a54a2e6", "level": "A2", "pos": 25, "prompt": "Quina és la síl·laba tònica d'«Alacant»?", "options": ["-cant", "a-", "-la-"], "answers": ["-cant"], "explanation": "A-la-CANT és aguda acabada en -nt: no porta accent."},
  {"rid": "5340aadb-100f-428d-a1ad-6d866a54a2e6", "level": "A2", "pos": 26, "prompt": "Quina d'estes paraules és aguda?", "options": ["café", "cadira", "número"], "answers": ["café"], "explanation": "Ca-FÉ és aguda. Cadira és plana i número, esdrúixola."},
  {"rid": "5ca81c57-fb9e-4e6b-b74a-2b62312e705d", "level": "B1", "pos": 8, "prompt": "Una informació inventada que es difon com si fora certa, sovint per les xarxes, és...", "options": ["una notícia falsa", "una exclusiva", "un rumor confirmat"], "answers": ["una notícia falsa"], "explanation": "Una notícia falsa. Cal contrastar la font."},
  {"rid": "5ca81c57-fb9e-4e6b-b74a-2b62312e705d", "level": "B1", "pos": 27, "prompt": "Quan la policia agafa una persona sospitosa, la...", "options": ["deté", "absol", "jutja"], "answers": ["deté"], "explanation": "Detindre: la policia deté; el detingut, la detenció."},
  {"rid": "5ca81c57-fb9e-4e6b-b74a-2b62312e705d", "level": "B1", "pos": 30, "prompt": "Quan el jutge decidix que l'acusat no és culpable, l'...", "options": ["absol", "condemna", "deté"], "answers": ["absol"], "explanation": "Absoldre: l'acusat queda absolt."},
  {"rid": "5ca81c57-fb9e-4e6b-b74a-2b62312e705d", "level": "B1", "pos": 44, "prompt": "Escriu la paraula: dia en què els ciutadans voten.", "options": null, "answers": ["eleccions", "les eleccions", "jornada electoral", "la jornada electoral", "dia d'eleccions", "el dia d'eleccions"], "explanation": "Les eleccions (la jornada electoral)."},
  {"rid": "5ca81c57-fb9e-4e6b-b74a-2b62312e705d", "level": "B1", "pos": 45, "prompt": "Escriu la paraula: moviment sobtat de la terra.", "options": null, "answers": ["terratrémol", "un terratrémol", "sisme", "el terratrémol", "terratrèmol", "el terratrèmol", "un terratrèmol", "el sisme", "un sisme"], "explanation": "El terratrémol (o sisme)."},
  {"rid": "86009785-1c97-4e8f-8203-85f873e596be", "level": "B1", "pos": 19, "prompt": "«Lamentem comunicar-li que no és possible concedir-li l'ús de l'aula.» Què expressa?", "options": ["Una denegació", "Una autorització", "Una felicitació"], "answers": ["Una denegació"], "explanation": "Denegar de manera cortesa: lamentem comunicar-li..."},
  {"rid": "86009785-1c97-4e8f-8203-85f873e596be", "level": "B1", "pos": 21, "prompt": "«Es prega silenci.» És...", "options": ["una petició cortesa de no fer soroll", "una prohibició de parlar valencià", "una felicitació"], "answers": ["una petició cortesa de no fer soroll"], "explanation": "Es prega: es demana amb educació."},
  {"rid": "86009785-1c97-4e8f-8203-85f873e596be", "level": "B1", "pos": 24, "prompt": "«Per a reservar la pista, cal fer-ho amb 48 hores d'antelació.» És...", "options": ["una norma d'ús del servici", "una queixa", "una denegació"], "answers": ["una norma d'ús del servici"], "explanation": "Expressar obligació o normes d'ús: cal, és obligatori, s'ha de... (per a aconsellar: és convenient, és recomanable...)."},
  {"rid": "86009785-1c97-4e8f-8203-85f873e596be", "level": "B1", "pos": 31, "prompt": "El servici d'una empresa que respon a les preguntes i les queixes dels clients és...", "options": ["l'atenció al client", "el consell d'administració", "el magatzem"], "answers": ["l'atenció al client"], "explanation": "Servici d'atenció al client."},
  {"rid": "7ae5ee2e-54b6-4541-b002-47670d46983a", "level": "B1", "pos": 18, "prompt": "Una pel·lícula de poca duració és...", "options": ["un curtmetratge", "un llargmetratge", "una sèrie"], "answers": ["un curtmetratge"], "explanation": "Un curtmetratge. Una pel·lícula llarga: un llargmetratge."},
  {"rid": "2dbbc6f8-5f76-455f-acc3-af804cf153e2", "level": "B1", "pos": 2, "prompt": "Posar les llavors a la terra perquè en nasquen plantes és...", "options": ["sembrar", "collir", "podar"], "answers": ["sembrar"], "explanation": "Sembrar. Plantar és posar a terra una planta ja nascuda."},
  {"rid": "2dbbc6f8-5f76-455f-acc3-af804cf153e2", "level": "B1", "pos": 5, "prompt": "Tallar les branques dels arbres perquè cresquen millor és...", "options": ["podar", "empeltar", "sembrar"], "answers": ["podar"], "explanation": "Podar. Empeltar és unir una branca d'un arbre a un altre."},
  {"rid": "2dbbc6f8-5f76-455f-acc3-af804cf153e2", "level": "B1", "pos": 14, "prompt": "Un camp plantat de ceps per a fer raïm és...", "options": ["una vinya", "un oliverar", "un ametlerar"], "answers": ["una vinya"], "explanation": "La vinya. Oliverar: camp d'oliveres. Ametlerar: d'ametlers."},
  {"rid": "b0fc5d10-4011-49a2-9d23-cdebe3e00507", "level": "B1", "pos": 3, "prompt": "L'espectacle de petards que es fa a migdia a la plaça de l'Ajuntament durant les Falles és...", "options": ["la mascletà (o mascletada)", "la despertà", "l'ofrena"], "answers": ["la mascletà (o mascletada)"], "explanation": "La mascletà (en estàndard, mascletada), a les dues de la vesprada."},
  {"rid": "b0fc5d10-4011-49a2-9d23-cdebe3e00507", "level": "B1", "pos": 11, "prompt": "Cada un dels grups que desfilen en els Moros i Cristians és...", "options": ["una filà (o filada)", "una falla", "una colla castellera"], "answers": ["una filà (o filada)"], "explanation": "Una filà (pl. filaes; en estàndard, filada). Hi ha l'entrada, l'ambaixada i el desembarcament."},
  {"rid": "b0fc5d10-4011-49a2-9d23-cdebe3e00507", "level": "B1", "pos": 23, "prompt": "Com s'anomena el cant tradicional valencià improvisat, amb modalitats com l'u i el dos, o les albaes (albades)?", "options": ["el cant d'estil", "el flamenc", "el cant gregorià"], "answers": ["el cant d'estil"], "explanation": "El cant d'estil: les albaes, l'u, el dos, el riu-rau..."},
  {"rid": "b0fc5d10-4011-49a2-9d23-cdebe3e00507", "level": "B1", "pos": 25, "prompt": "Quin plat típic de Gandia es fa com la paella però amb fideus?", "options": ["la fideuà (o fideuada)", "l'arròs negre", "l'all i pebre"], "answers": ["la fideuà (o fideuada)"], "explanation": "La fideuà (en estàndard, fideuada), de peix i marisc."},
  {"rid": "b0fc5d10-4011-49a2-9d23-cdebe3e00507", "level": "B1", "pos": 30, "prompt": "Què són els bunyols que es mengen en Falles?", "options": ["dolços fregits de pasta, sovint de carabassa", "una mena d'arròs", "un embotit"], "answers": ["dolços fregits de pasta, sovint de carabassa"], "explanation": "Bunyols de carabassa, amb xocolate calent."},
  {"rid": "b0fc5d10-4011-49a2-9d23-cdebe3e00507", "level": "B1", "pos": 32, "prompt": "L'esmorzar de mitjan matí amb entrepà, olives, cacauets i cremaet és...", "options": ["l'esmorzar de mitjan matí", "la sobretaula", "el berenar de vesprada"], "answers": ["l'esmorzar de mitjan matí"], "explanation": "L'esmorzar (popularment, «l'esmorzaret»): un costum molt valencià."},
  {"rid": "b0fc5d10-4011-49a2-9d23-cdebe3e00507", "level": "B1", "pos": 40, "prompt": "Quin joc infantil consistix a botar a peu coix per unes caselles pintades al terra?", "options": ["el sambori (o la xarranca)", "les bales", "el mocador"], "answers": ["el sambori (o la xarranca)"], "explanation": "El sambori o la xarranca."},
  {"rid": "743422cf-9743-4f27-934a-948991958ae7", "level": "B1", "pos": 29, "prompt": "Enviar diners a un amic de manera instantània des d'una aplicació del telèfon és fer...", "options": ["un pagament per mòbil", "un xec", "una hipoteca"], "answers": ["un pagament per mòbil"], "explanation": "Pagar amb el mòbil o amb una aplicació bancària."},
  {"rid": "42fca25a-cf27-40c1-9dee-c1464a42d683", "level": "B1", "pos": 8, "prompt": "En tenis, l'objecte amb què es pega a la pilota és...", "options": ["la raqueta", "el bat", "el pal"], "answers": ["la raqueta"], "explanation": "La raqueta. La pilota ha de passar per damunt de la xarxa."},
  {"rid": "42fca25a-cf27-40c1-9dee-c1464a42d683", "level": "B1", "pos": 9, "prompt": "En tenis, el primer colp de cada punt és...", "options": ["el servei", "el remat", "el rebot"], "answers": ["el servei"], "explanation": "El servei (servir). Un partit es dividix en sets."},
  {"rid": "42fca25a-cf27-40c1-9dee-c1464a42d683", "level": "B1", "pos": 27, "prompt": "Quins són els quatre pals de la baralla espanyola?", "options": ["oros, copes, espases i bastos", "cors, piques, diamants i trévols", "reis, cavalls, sotes i asos"], "answers": ["oros, copes, espases i bastos"], "explanation": "Oros, copes, espases i bastos. La baralla francesa té cors, piques, diamants i trévols."},
  {"rid": "42fca25a-cf27-40c1-9dee-c1464a42d683", "level": "B1", "pos": 28, "prompt": "Abans de jugar, passar les cartes a cada jugador és...", "options": ["donar (o repartir) les cartes", "barallar les cartes", "tallar"], "answers": ["donar (o repartir) les cartes"], "explanation": "Repartir o donar. Barallar (o remenar) les cartes és mesclar-les."},
  {"rid": "42fca25a-cf27-40c1-9dee-c1464a42d683", "level": "B1", "pos": 34, "prompt": "Prendre substàncies prohibides per a rendir més en l'esport és...", "options": ["el dopatge", "les vitamines", "l'entrenament"], "answers": ["el dopatge"], "explanation": "El dopatge: els controls antidopatge."},
  {"rid": "42fca25a-cf27-40c1-9dee-c1464a42d683", "level": "B1", "pos": 35, "prompt": "Quina d'estes paraules NO és un esport de raqueta?", "options": ["l'handbol", "el tenis", "el bàdminton"], "answers": ["l'handbol"], "explanation": "L'handbol es juga amb les mans i una pilota."},
  {"rid": "37563e69-ff08-4822-a5c1-3de1a9c57c37", "level": "B1", "pos": 9, "prompt": "Quan trobes a faltar una persona, la...", "options": ["enyores", "oblides", "odies"], "answers": ["enyores"], "explanation": "Enyorar: l'enyorança. Trobar a faltar."},
  {"rid": "37563e69-ff08-4822-a5c1-3de1a9c57c37", "level": "B1", "pos": 11, "prompt": "Quan estàs enfadadíssim, estàs...", "options": ["furiós", "tranquil", "tímid"], "answers": ["furiós"], "explanation": "Furiós: estar fet una fúria."},
  {"rid": "37563e69-ff08-4822-a5c1-3de1a9c57c37", "level": "B1", "pos": 31, "prompt": "Un material que no deixa passar l'aigua és...", "options": ["impermeable", "transparent", "absorbent"], "answers": ["impermeable"], "explanation": "Impermeable (com una capa o una jaqueta de pluja)."},
  {"rid": "bb9d81a8-ec10-438f-bdca-ce5933d487eb", "level": "B1", "pos": 4, "prompt": "On pots agafar en préstec llibres i pel·lícules sense pagar?", "options": ["a la biblioteca municipal", "a la llibreria", "a la papereria"], "answers": ["a la biblioteca municipal"], "explanation": "La biblioteca presta. La llibreria ven llibres."},
  {"rid": "bb9d81a8-ec10-438f-bdca-ce5933d487eb", "level": "B1", "pos": 22, "prompt": "Viure en un pis que no és teu i pagar una quantitat cada mes per viure-hi és viure de...", "options": ["lloguer", "hipoteca", "herència"], "answers": ["lloguer"], "explanation": "De lloguer. Llogar un pis; el llogater paga al propietari."},
  {"rid": "bb9d81a8-ec10-438f-bdca-ce5933d487eb", "level": "B1", "pos": 27, "prompt": "Un pis que es lloga amb mobles és un pis...", "options": ["moblat", "buit", "reformat"], "answers": ["moblat"], "explanation": "Moblat (amb mobles). Sense mobles: buit."},
  {"rid": "bb9d81a8-ec10-438f-bdca-ce5933d487eb", "level": "B1", "pos": 43, "prompt": "Escriu la paraula: lloc de la vorera on s'espera l'autobús.", "options": null, "answers": ["parada", "la parada", "parada d'autobús", "parada de l'autobús", "la parada de l'autobús"], "explanation": "La parada (de l'autobús)."},
  {"rid": "bb9d81a8-ec10-438f-bdca-ce5933d487eb", "level": "B1", "pos": 46, "prompt": "Escriu la paraula: lloc del pis on es guarden les coses que no s'usen sovint.", "options": null, "answers": ["traster", "el traster", "golfa", "les golfes", "golfes", "la golfa"], "explanation": "El traster (o les golfes, si és davall de la teulada)."},
  {"rid": "bb9d81a8-ec10-438f-bdca-ce5933d487eb", "level": "B1", "pos": 54, "prompt": "Per on ix l'aigua a la cuina i al bany?", "options": ["per l'aixeta", "per l'endoll", "per l'interruptor"], "answers": ["per l'aixeta"], "explanation": "L'aixeta. Obrir o tancar l'aixeta."},
  {"rid": "45f412d2-e3b7-406e-9e34-1d8dd18f2ddc", "level": "B1", "pos": 34, "prompt": "Quin peix xicotet és exclusiu dels aiguamolls valencians i està en perill d'extinció?", "options": ["el samaruc", "la sardina", "el lluç"], "answers": ["el samaruc"], "explanation": "El samaruc, endèmic del País Valencià. El fartet, també amenaçat, viu en la costa mediterrània peninsular."},
  {"rid": "45f412d2-e3b7-406e-9e34-1d8dd18f2ddc", "level": "B1", "pos": 44, "prompt": "«La platja estava ___: no hi cabia ni una tovallola.»", "options": ["massificada", "solitària", "verge"], "answers": ["massificada"], "explanation": "Massificada: amb massa gent. Una platja verge no està urbanitzada."},
  {"rid": "45f412d2-e3b7-406e-9e34-1d8dd18f2ddc", "level": "B1", "pos": 47, "prompt": "Escriu la paraula: període llarg sense pluja.", "options": null, "answers": ["sequera", "la sequera", "eixutesa", "secada", "la secada", "l'eixutesa"], "explanation": "La sequera."},
  {"rid": "45f412d2-e3b7-406e-9e34-1d8dd18f2ddc", "level": "B1", "pos": 65, "prompt": "Quan el cel no té cap núvol, està...", "options": ["seré", "ennuvolat", "tapat"], "answers": ["seré"], "explanation": "Seré (o clar). Ennuvolat: amb núvols."},
  {"rid": "45f412d2-e3b7-406e-9e34-1d8dd18f2ddc", "level": "B1", "pos": 69, "prompt": "La informació sobre el temps que farà els pròxims dies és...", "options": ["la previsió meteorològica", "la cartellera", "l'esquela"], "answers": ["la previsió meteorològica"], "explanation": "La previsió meteorològica (o el pronòstic del temps)."},
  {"rid": "45f412d2-e3b7-406e-9e34-1d8dd18f2ddc", "level": "B1", "pos": 72, "prompt": "Escriu el contrari d'«ennuvolat».", "options": null, "answers": ["seré", "clar", "assolellat"], "explanation": "Seré o clar."},
  {"rid": "e5554b24-9965-4d64-9f25-e39d7638f482", "level": "B1", "pos": 26, "prompt": "Bussejar sota l'aigua amb ampolles d'aire comprimit és fer...", "options": ["submarinisme", "surf", "rem"], "answers": ["submarinisme"], "explanation": "Submarinisme. Amb tub i ulleres: fer snorkel o bussejar."},
  {"rid": "e5554b24-9965-4d64-9f25-e39d7638f482", "level": "B1", "pos": 41, "prompt": "Escriu la paraula: tindre ganes de fer alguna cosa és «vindre de ___».", "options": null, "answers": ["gust"], "explanation": "Vindre de gust."},
  {"rid": "3c2cdca6-70e4-4a53-99af-2db26e50aaea", "level": "B1", "pos": 1, "prompt": "«Cada dia m'alce a les sis: m'agrada ___.» Quin verb vol dir 'alçar-se molt prompte'?", "options": ["matinar", "gitar-me tard", "dormisquejar"], "answers": ["matinar"], "explanation": "Matinar: alçar-se de bon matí. El contrari és gitar-se tard."},
  {"rid": "3c2cdca6-70e4-4a53-99af-2db26e50aaea", "level": "B1", "pos": 2, "prompt": "«Els caps de setmana sempre ___: no me'n vaig al llit abans de les tres.»", "options": ["em gite molt tard", "matine", "desdejune"], "answers": ["em gite molt tard"], "explanation": "Gitar-se tard (o fer-se tard). El contrari és matinar."},
  {"rid": "3c2cdca6-70e4-4a53-99af-2db26e50aaea", "level": "B1", "pos": 19, "prompt": "Una persona que té els cabells amb molts rínxols té els cabells...", "options": ["arrissat", "llis", "curt"], "answers": ["arrissat"], "explanation": "Arrissat (amb rínxols). El contrari és el cabell llis."},
  {"rid": "3c2cdca6-70e4-4a53-99af-2db26e50aaea", "level": "B1", "pos": 34, "prompt": "Una persona que es creu superior als altres és...", "options": ["arrogant", "humil", "modesta"], "answers": ["arrogant"], "explanation": "Arrogant (o altiu, superb). El contrari és humil o modest."},
  {"rid": "3c2cdca6-70e4-4a53-99af-2db26e50aaea", "level": "B1", "pos": 48, "prompt": "Escriu el contrari de «generós».", "options": null, "answers": ["garrepa", "agarrat", "avar", "gasiu", "egoista", "avariciós"], "explanation": "Garrepa, agarrat, avar o gasiu."},
  {"rid": "3c2cdca6-70e4-4a53-99af-2db26e50aaea", "level": "B1", "pos": 52, "prompt": "Els pares de la persona amb qui s'ha casat ton fill són els teus...", "options": ["consogres", "cunyats", "padrins"], "answers": ["consogres"], "explanation": "Consogre i consogra: els pares de l'altre membre de la parella del teu fill."},
  {"rid": "3c2cdca6-70e4-4a53-99af-2db26e50aaea", "level": "B1", "pos": 60, "prompt": "Quan dues persones que s'havien barallat tornen a ser amigues, es...", "options": ["reconcilien", "separen", "barallen"], "answers": ["reconcilien"], "explanation": "Reconciliar-se: fer les paus."},
  {"rid": "29bc8568-fb92-49f3-ac40-e73ebf5417a7", "level": "B1", "pos": 10, "prompt": "Com refuses educadament una invitació?", "options": ["Em sap molt de greu, però eixe dia ja tinc un compromís.", "No vull vindre.", "Les teues festes són avorrides."], "answers": ["Em sap molt de greu, però eixe dia ja tinc un compromís."], "explanation": "Saber greu + una excusa: és la manera cortesa de refusar."},
  {"rid": "29bc8568-fb92-49f3-ac40-e73ebf5417a7", "level": "B1", "pos": 19, "prompt": "En una carta, què vol dir l'abreviatura P. D.?", "options": ["Postdata: el que s'afig després de signar", "Per Dir: el que vols dir", "Primera Data: el dia que escrius"], "answers": ["Postdata: el que s'afig després de signar"], "explanation": "P.D. (postdata) introduïx una nota afegida al final."},
  {"rid": "29bc8568-fb92-49f3-ac40-e73ebf5417a7", "level": "B1", "pos": 26, "prompt": "Quina frase és apropiada en una nota per a un company de pis?", "options": ["He eixit a comprar. Torne a les set. Si crida ma mare, digues-li que li telefonaré.", "Sol·licite que em concedisquen el permís.", "Benvolgut senyor, li comunique..."], "answers": ["He eixit a comprar. Torne a les set. Si crida ma mare, digues-li que li telefonaré."], "explanation": "Una nota informal: directa, breu i amb el tractament de tu."},
  {"rid": "fab5c251-0a2a-480d-a839-f7ccbaee2bf0", "level": "B1", "pos": 10, "prompt": "La sensació a la pell que et fa gratar és...", "options": ["la picor (o la coïssor)", "la febre", "la tos"], "answers": ["la picor (o la coïssor)"], "explanation": "Picor o coïssor. Una picada de mosquit pica."},
  {"rid": "fab5c251-0a2a-480d-a839-f7ccbaee2bf0", "level": "B1", "pos": 19, "prompt": "La capsa amb tiretes, gases i desinfectant per a primers auxilis és...", "options": ["la farmaciola", "la farmàcia", "la recepta"], "answers": ["la farmaciola"], "explanation": "La farmaciola: n'hi ha d'haver una a casa, al cotxe i a la faena."},
  {"rid": "cbe6905c-aba9-4c29-bda5-c29fbf1e241e", "level": "B1", "pos": 7, "prompt": "Un programa que t'instal·les en el mòbil per a fer una tasca concreta és...", "options": ["una app (o aplicació)", "un cable", "un fitxer"], "answers": ["una app (o aplicació)"], "explanation": "Una aplicació (app)."},
  {"rid": "cbe6905c-aba9-4c29-bda5-c29fbf1e241e", "level": "B1", "pos": 11, "prompt": "Fer que un document quede emmagatzemat en l'ordinador per a no perdre els canvis és...", "options": ["desar-lo", "esborrar-lo", "retallar-lo"], "answers": ["desar-lo"], "explanation": "Desar (o guardar)."},
  {"rid": "cbe6905c-aba9-4c29-bda5-c29fbf1e241e", "level": "B1", "pos": 32, "prompt": "La tecnologia que permet als ordinadors imitar la manera de pensar humana, per exemple per a respondre preguntes, és...", "options": ["la intel·ligència artificial", "el processador de textos", "el full de càlcul"], "answers": ["la intel·ligència artificial"], "explanation": "La intel·ligència artificial (IA)."},
  {"rid": "cbe6905c-aba9-4c29-bda5-c29fbf1e241e", "level": "B1", "pos": 36, "prompt": "Els aparells xicotets que es posen a les orelles per a escoltar música són...", "options": ["els auriculars", "els altaveus", "el micròfon"], "answers": ["els auriculars"], "explanation": "Els auriculars (amb fil o sense fils)."},
  {"rid": "32cec65a-a7c6-490d-b993-ad562b14a808", "level": "B1", "pos": 35, "prompt": "En quina batalla de 1707 el Regne de València va perdre els Furs?", "options": ["la batalla d'Almansa", "la batalla de Lepant", "la batalla de les Naves de Tolosa"], "answers": ["la batalla d'Almansa"], "explanation": "Després d'Almansa, Felip V va abolir els Furs amb els Decrets de Nova Planta."},
  {"rid": "d2eb464d-1df4-4fcd-9d67-26a8eb56d9f2", "level": "B1", "pos": 19, "prompt": "Quan un treballador decidix deixar el seu lloc de treball, ...", "options": ["renuncia al lloc (o se'n va voluntàriament)", "és acomiadat", "es jubila"], "answers": ["renuncia al lloc (o se'n va voluntàriament)"], "explanation": "Renunciar al lloc de treball o demanar la baixa voluntària. Dimitir es diu sobretot d'un càrrec."},
  {"rid": "9714fab7-3383-48bd-8547-ff6c73181491", "level": "B1", "pos": 20, "prompt": "Viatjar amb poc equipatge a l'esquena, gastant poc i movent-se molt, és viatjar...", "options": ["de motxilla", "en primera classe", "en creuer"], "answers": ["de motxilla"], "explanation": "Viatjar de motxilla (o amb motxilla)."},
  {"rid": "9714fab7-3383-48bd-8547-ff6c73181491", "level": "B1", "pos": 27, "prompt": "Una targeta que et permet fer molts viatges en autobús o metro a un preu més baix és...", "options": ["un abonament (o una targeta de transport)", "un pressupost", "un rebut"], "answers": ["un abonament (o una targeta de transport)"], "explanation": "Un abonament de transport (per a deu viatges, mensual...)."},
  {"rid": "9714fab7-3383-48bd-8547-ff6c73181491", "level": "B1", "pos": 33, "prompt": "«Agafe el primer ___ a l'esquerra, just després de la farmàcia.»", "options": ["carrer", "andana", "peatge"], "answers": ["carrer"], "explanation": "El primer carrer a l'esquerra: indicacions per a arribar a un lloc."},
  {"rid": "9714fab7-3383-48bd-8547-ff6c73181491", "level": "B1", "pos": 34, "prompt": "«Quina línia de metro he d'agafar per a anar a la platja?» Què demana?", "options": ["Informació sobre el transport que cal agafar", "El preu de l'hotel", "On és el revisor"], "answers": ["Informació sobre el transport que cal agafar"], "explanation": "Demanar informació sobre el mitjà de transport."},
  {"rid": "9714fab7-3383-48bd-8547-ff6c73181491", "level": "B1", "pos": 39, "prompt": "«Hem de ___ en la pròxima parada.»", "options": ["baixar", "pujar", "abaixar"], "answers": ["baixar"], "explanation": "Baixar del tren o de l'autobús. Pujar-hi en entrar."},
  {"rid": "9714fab7-3383-48bd-8547-ff6c73181491", "level": "B1", "pos": 40, "prompt": "Un trajecte que es fa cada dia per a anar a treballar, per exemple, de Sagunt a València, és un trajecte...", "options": ["diari (o quotidià)", "turístic", "internacional"], "answers": ["diari (o quotidià)"], "explanation": "Moltes persones fan cada dia el mateix trajecte: els qui viuen fora i treballen a la ciutat."},
  {"rid": "9714fab7-3383-48bd-8547-ff6c73181491", "level": "B1", "pos": 43, "prompt": "Escriu la paraula: canviar de tren per a continuar el viatge és fer ___.", "options": null, "answers": ["transbord", "un transbord"], "explanation": "Fer transbord."},
  {"rid": "48c44cc5-47dc-495a-90db-26a0ffb69525", "level": "B1", "pos": 7, "prompt": "Quan la roba ja està eixuta (seca), la llevem de l'estenedor: la...", "options": ["arrepleguem", "estenem", "remullem"], "answers": ["arrepleguem"], "explanation": "Arreplegar (o replegar) la roba."},
  {"rid": "48c44cc5-47dc-495a-90db-26a0ffb69525", "level": "B1", "pos": 13, "prompt": "«Hui em toca a mi ___ el gos.» Quin verb s'usa per a dir que l'eixim a passejar?", "options": ["traure", "llevar", "portar-se'n"], "answers": ["traure"], "explanation": "Traure el gos (a passejar)."},
  {"rid": "48c44cc5-47dc-495a-90db-26a0ffb69525", "level": "B1", "pos": 34, "prompt": "Un producte que ha passat la data de caducitat està...", "options": ["caducat", "rebaixat", "en oferta"], "answers": ["caducat"], "explanation": "Caducat: ha passat la data de caducitat."},
  {"rid": "48c44cc5-47dc-495a-90db-26a0ffb69525", "level": "B1", "pos": 41, "prompt": "«Cal fer la compra: ___ una dotzena d'ous i mig quilo de tomaques.»", "options": ["necessitem", "sobren", "ens han tornat"], "answers": ["necessitem"], "explanation": "Necessitar: fer falta. Una dotzena: dotze; mig quilo: cinc-cents grams."},
  {"rid": "48c44cc5-47dc-495a-90db-26a0ffb69525", "level": "B1", "pos": 46, "prompt": "Escriu el material: una bossa que es recicla al contenidor blau és de ___.", "options": null, "answers": ["paper"], "explanation": "De paper. Altres materials: de plàstic, de tela, de vidre, de fusta, de metall."},
  {"rid": "2d99f341-c91b-4c70-9d21-75a239956f97", "level": "A2", "pos": 2, "prompt": "Qui arregla la llum de casa?", "options": ["l'electricista", "l'electriquer", "l'electrador"], "answers": ["l'electricista"], "explanation": "Sufix -ista, invariable en gènere: l'electricista (home o dona)."},
  {"rid": "2d99f341-c91b-4c70-9d21-75a239956f97", "level": "A2", "pos": 4, "prompt": "Com es diu una persona que parla molt?", "options": ["xarraire", "xarradís", "xarrista"], "answers": ["xarraire"], "explanation": "Sufix -aire, invariable: un xarraire, una xarraire (també xarrador)."},
  {"rid": "2d99f341-c91b-4c70-9d21-75a239956f97", "level": "A2", "pos": 32, "prompt": "Amb quin aparell fem el café?", "options": ["amb la cafetera", "amb el cafetista", "amb el cafetaire"], "answers": ["amb la cafetera"], "explanation": "Café + -era (amb una -t-): cafetera."},
  {"rid": "e1165f90-cd1d-4006-84f3-75bda93d947e", "level": "A2", "pos": 1, "prompt": "Quin és el contrari d'«alt»?", "options": ["baix", "gran", "llarg"], "answers": ["baix"], "explanation": "Alt / baix."},
  {"rid": "e1165f90-cd1d-4006-84f3-75bda93d947e", "level": "A2", "pos": 2, "prompt": "Quin és el contrari d'«obrir»?", "options": ["tancar", "eixir", "traure"], "answers": ["tancar"], "explanation": "Obrir / tancar."},
  {"rid": "e1165f90-cd1d-4006-84f3-75bda93d947e", "level": "A2", "pos": 16, "prompt": "Quin és un sinònim d'«alumne»?", "options": ["estudiant", "mestre", "director"], "answers": ["estudiant"], "explanation": "Alumne i estudiant."},
  {"rid": "e1165f90-cd1d-4006-84f3-75bda93d947e", "level": "A2", "pos": 18, "prompt": "Quin és el contrari d'«entrar»?", "options": ["eixir", "pujar", "obrir"], "answers": ["eixir"], "explanation": "Entrar ↔ eixir."},
  {"rid": "e1165f90-cd1d-4006-84f3-75bda93d947e", "level": "A2", "pos": 21, "prompt": "Quin és el contrari d'«encendre» la llum?", "options": ["apagar", "trencar", "obrir"], "answers": ["apagar"], "explanation": "Encendre ↔ apagar."},
  {"rid": "e1165f90-cd1d-4006-84f3-75bda93d947e", "level": "A2", "pos": 28, "prompt": "Com demanes una cosa amb educació?", "options": ["Em dones un got d'aigua, per favor?", "Dona'm aigua ja!", "Aigua!"], "answers": ["Em dones un got d'aigua, per favor?"], "explanation": "Per favor fa la petició més cortesa."},
  {"rid": "a3a75594-576c-4088-9f19-68b24435470e", "level": "A2", "pos": 17, "prompt": "Una persona que aprén de pressa i sap moltes coses és...", "options": ["llesta", "tonta", "gandula"], "answers": ["llesta"], "explanation": "Llesta (o intel·ligent)."},
  {"rid": "a3a75594-576c-4088-9f19-68b24435470e", "level": "A2", "pos": 25, "prompt": "Quin és el contrari d'«ample»?", "options": ["estret", "llarg", "alt"], "answers": ["estret"], "explanation": "Ample ↔ estret."},
  {"rid": "a3a75594-576c-4088-9f19-68b24435470e", "level": "A2", "pos": 40, "prompt": "Un carrer amb molts cotxes, música i crits és...", "options": ["sorollós", "silenciós", "tranquil"], "answers": ["sorollós"], "explanation": "Sorollós ↔ silenciós."},
  {"rid": "a3a75594-576c-4088-9f19-68b24435470e", "level": "A2", "pos": 46, "prompt": "Quin és el femení d'«amable»?", "options": ["amable", "amabla", "amablessa"], "answers": ["amable"], "explanation": "Amable és invariable."},
  {"rid": "a3a75594-576c-4088-9f19-68b24435470e", "level": "A2", "pos": 48, "prompt": "Escriu el contrari de «bo».", "options": null, "answers": ["dolent", "roín"], "explanation": "Bo ↔ dolent."},
  {"rid": "a3a75594-576c-4088-9f19-68b24435470e", "level": "A2", "pos": 49, "prompt": "Escriu el contrari d'«obert».", "options": null, "answers": ["tancat"], "explanation": "Obert ↔ tancat."},
  {"rid": "a3a75594-576c-4088-9f19-68b24435470e", "level": "A2", "pos": 50, "prompt": "Escriu el contrari d'«alegre».", "options": null, "answers": ["trist"], "explanation": "Alegre ↔ trist."},
  {"rid": "4cd60711-b1d4-4d5a-b88e-d277d3989a0e", "level": "A2", "pos": 36, "prompt": "A les Falles, el soroll de pólvora que se sent al migdia és...", "options": ["la mascletà (o mascletada)", "la cremà", "l'ofrena"], "answers": ["la mascletà (o mascletada)"], "explanation": "La mascletà (o mascletada)."},
  {"rid": "4cd60711-b1d4-4d5a-b88e-d277d3989a0e", "level": "A2", "pos": 37, "prompt": "La nit del 19 de març, quan es cremen les falles, és...", "options": ["la cremà", "la mascletà (o mascletada)", "l'ofrena"], "answers": ["la cremà"], "explanation": "La cremà."},
  {"rid": "4cd60711-b1d4-4d5a-b88e-d277d3989a0e", "level": "A2", "pos": 38, "prompt": "Quan els fallers porten flors a la Mare de Déu, és...", "options": ["l'ofrena", "la cremà", "la mascletà (o mascletada)"], "answers": ["l'ofrena"], "explanation": "L'ofrena de flors."},
  {"rid": "8fb32978-b788-4be5-81da-4993e52cf2f5", "level": "A2", "pos": 51, "prompt": "La via per a passejar al costat de la mar és...", "options": ["el passeig marítim", "la carretera", "l'autopista"], "answers": ["el passeig marítim"], "explanation": "El passeig marítim."},
  {"rid": "a08cc2d7-a3db-4e92-9661-7c15b9342144", "level": "A2", "pos": 38, "prompt": "Els pèls que tenim al cap són...", "options": ["els cabells", "les celles", "les pestanyes"], "answers": ["els cabells"], "explanation": "Els cabells."},
  {"rid": "9e98c74e-b152-480c-a5c8-c74760011079", "level": "A2", "pos": 7, "prompt": "Quan fas «atxim!»...", "options": ["esternudes", "tusses", "plores"], "answers": ["esternudes"], "explanation": "Esternudar."},
  {"rid": "9e98c74e-b152-480c-a5c8-c74760011079", "level": "A2", "pos": 10, "prompt": "He caigut i no puc moure el braç: potser el tinc...", "options": ["trencat", "refredat", "cansat"], "answers": ["trencat"], "explanation": "Trencat."},
  {"rid": "9e98c74e-b152-480c-a5c8-c74760011079", "level": "A2", "pos": 19, "prompt": "El lloc del barri on et visita el metge, més xicotet que l'hospital, és...", "options": ["el centre de salut", "la farmàcia", "l'ajuntament"], "answers": ["el centre de salut"], "explanation": "El centre de salut."},
  {"rid": "9e98c74e-b152-480c-a5c8-c74760011079", "level": "A2", "pos": 29, "prompt": "Si tens un problema de salut molt greu, has d'anar...", "options": ["a urgències", "a la perruqueria", "al gimnàs"], "answers": ["a urgències"], "explanation": "A urgències de l'hospital."},
  {"rid": "cef4ecd9-b084-43b8-8ee5-d305e3b702f8", "level": "A2", "pos": 42, "prompt": "Seixanta segons fan un...", "options": ["minut", "segle", "dia"], "answers": ["minut"], "explanation": "Un minut."},
  {"rid": "cef4ecd9-b084-43b8-8ee5-d305e3b702f8", "level": "A2", "pos": 46, "prompt": "El dia anterior a ahir és...", "options": ["abans-d'ahir", "demà passat", "anit"], "answers": ["abans-d'ahir"], "explanation": "Abans-d'ahir."},
  {"rid": "be7ce637-a745-4ec9-8d00-502b96b164a1", "level": "A2", "pos": 27, "prompt": "La persona que ensenya en una escola és...", "options": ["el mestre o la mestra", "l'alumne o l'alumna", "el conserge o la conserge"], "answers": ["el mestre o la mestra"], "explanation": "El mestre o la mestra ensenya; l'alumne aprén."},
  {"rid": "be7ce637-a745-4ec9-8d00-502b96b164a1", "level": "A2", "pos": 28, "prompt": "El temps de descans entre les classes és...", "options": ["l'esplai", "l'examen", "la matrícula"], "answers": ["l'esplai"], "explanation": "L'esplai (o l'esbarjo): temps de descans entre classes, l'hora del pati."},
  {"rid": "be7ce637-a745-4ec9-8d00-502b96b164a1", "level": "A2", "pos": 47, "prompt": "On dormim?", "options": ["al dormitori", "al menjador", "a la cuina"], "answers": ["al dormitori"], "explanation": "Al dormitori (o a l'habitació)."},
  {"rid": "03d45225-e0a6-4178-8574-ba4960ef05c1", "level": "A2", "pos": 35, "prompt": "Escriu el contrari d'«amunt».", "options": null, "answers": ["avall"], "explanation": "Amunt ↔ avall."},
  {"rid": "23d2f0c0-a9b0-4df0-85a4-a501b4525e1c", "level": "B1", "pos": 8, "prompt": "En valencià, quin és el femení d'«ample»?", "options": ["ampla", "ample (invariable)", "amplia"], "answers": ["ampla"], "explanation": "Ample / ampla. També pobre / pobra en valencià."},
  {"rid": "23d2f0c0-a9b0-4df0-85a4-a501b4525e1c", "level": "B1", "pos": 12, "prompt": "«Este llibre és molt ___: té mil pàgines.»", "options": ["gruixut", "alt", "ample"], "answers": ["gruixut"], "explanation": "Gruixut: de molt de gruix (un llibre, una paret, una tela). Gros: de gran volum o mida."},
  {"rid": "23d2f0c0-a9b0-4df0-85a4-a501b4525e1c", "level": "B1", "pos": 22, "prompt": "Quin és el superlatiu d'«amable»?", "options": ["amabilíssim", "amablíssim", "amableíssim"], "answers": ["amabilíssim"], "explanation": "Amable → amabilíssim."},
  {"rid": "23d2f0c0-a9b0-4df0-85a4-a501b4525e1c", "level": "B1", "pos": 24, "prompt": "Quin és el comparatiu sintètic (d'una sola paraula) de «bo»?", "options": ["millor", "més bo", "mejor"], "answers": ["millor"], "explanation": "Bo → millor (també es diu «més bo», en forma analítica)."},
  {"rid": "23d2f0c0-a9b0-4df0-85a4-a501b4525e1c", "level": "B1", "pos": 25, "prompt": "Quin és el comparatiu sintètic (d'una sola paraula) de «dolent» (o «roín»)?", "options": ["pitjor", "més roín", "peor"], "answers": ["pitjor"], "explanation": "Dolent / roín → pitjor (també «més dolent», en forma analítica)."},
  {"rid": "23d2f0c0-a9b0-4df0-85a4-a501b4525e1c", "level": "B1", "pos": 35, "prompt": "Escriu el comparatiu sintètic (una sola paraula) de «bo».", "options": null, "answers": ["millor"], "explanation": "Millor."},
  {"rid": "2b9aa93e-9bff-4dfd-bf80-5de1719a88d5", "level": "B1", "pos": 1, "prompt": "«Vindràs a la festa?» «___! No me la perdria per res.»", "options": ["I tant", "De cap manera", "Tampoc"], "answers": ["I tant"], "explanation": "I tant!: afirmació emfàtica."},
  {"rid": "2b9aa93e-9bff-4dfd-bf80-5de1719a88d5", "level": "B1", "pos": 6, "prompt": "«Jo no hi vaig.» «Jo ___.»", "options": ["tampoc", "també", "no tampoc"], "answers": ["tampoc"], "explanation": "Tampoc: negació en coordinació amb una altra negació. També: afirmació."},
  {"rid": "2b9aa93e-9bff-4dfd-bf80-5de1719a88d5", "level": "B1", "pos": 19, "prompt": "«Hi havia ___ gent que no podíem entrar.» (consecutiva)", "options": ["tanta", "tan", "tantes"], "answers": ["tanta"], "explanation": "Tanta + nom femení + que: consecutiva intensiva."},
  {"rid": "2b9aa93e-9bff-4dfd-bf80-5de1719a88d5", "level": "B1", "pos": 22, "prompt": "«Hui fa ___ calor.»", "options": ["molta", "molts", "moltes"], "answers": ["molta"], "explanation": "Molta calor (calor és femení: la calor)."},
  {"rid": "2b9aa93e-9bff-4dfd-bf80-5de1719a88d5", "level": "B1", "pos": 24, "prompt": "«___ vindrà demà, però no n'estic segur.» (dubte)", "options": ["Potser", "Sens dubte", "I tant"], "answers": ["Potser"], "explanation": "Potser, tal vegada, a la millor: dubte."},
  {"rid": "46796358-e58c-4953-a44d-261766273faa", "level": "B1", "pos": 28, "prompt": "Escriu el connector concessiu: «___ ploga, eixiré.»", "options": null, "answers": ["encara que", "tot i que", "malgrat que"], "explanation": "Encara que."},
  {"rid": "465bca6e-cc83-4911-bf60-805f4fe6fe12", "level": "B1", "pos": 16, "prompt": "Quin és el plural d'«esta»?", "options": ["estes", "estas", "estos"], "answers": ["estes"], "explanation": "Esta → estes."},
  {"rid": "465bca6e-cc83-4911-bf60-805f4fe6fe12", "level": "B1", "pos": 17, "prompt": "Quin és el plural d'«eixe»?", "options": ["eixos", "eixes", "eixs"], "answers": ["eixos"], "explanation": "Eixe → eixos; eixa → eixes."},
  {"rid": "465bca6e-cc83-4911-bf60-805f4fe6fe12", "level": "B1", "pos": 23, "prompt": "Quin és el possessiu d'«ells» per a «casa»?", "options": ["la seua casa", "la sua casa", "la seu casa"], "answers": ["la seua casa"], "explanation": "El seu, la seua, els seus, les seues (de vosté, d'ell, d'ells...). En registre formal també es pot usar llur: la llur casa."},
  {"rid": "465bca6e-cc83-4911-bf60-805f4fe6fe12", "level": "B1", "pos": 30, "prompt": "Escriu la forma reforçada d'«esta».", "options": null, "answers": ["aquesta"], "explanation": "Aquesta."},
  {"rid": "465bca6e-cc83-4911-bf60-805f4fe6fe12", "level": "B1", "pos": 31, "prompt": "Escriu el possessiu tònic femení plural de primera persona: les ___.", "options": null, "answers": ["meues", "meves"], "explanation": "Les meues."},
  {"rid": "a7c5d2a7-6ba3-43ad-86d2-556ac9a00f68", "level": "B1", "pos": 19, "prompt": "«___ són els teus llibres?» (triar entre diversos llibres)", "options": ["Quins", "Qui", "Què"], "answers": ["Quins"], "explanation": "Quins: per a triar entre elements d'un grup."},
  {"rid": "e5f3f3e9-5a53-441d-b318-060e27c2c04c", "level": "B1", "pos": 5, "prompt": "«Crec que ___ raó.» (tindre, ell)", "options": ["té", "tinga", "tinguera"], "answers": ["té"], "explanation": "Creure que (afirmatiu) + indicatiu."},
  {"rid": "e5f3f3e9-5a53-441d-b318-060e27c2c04c", "level": "B1", "pos": 6, "prompt": "«No crec que ___ raó.» (tindre, ell)", "options": ["tinga", "té", "tindrà"], "answers": ["tinga"], "explanation": "No creure que + subjuntiu (dubte)."},
  {"rid": "e5f3f3e9-5a53-441d-b318-060e27c2c04c", "level": "B1", "pos": 22, "prompt": "Quin és l'imperatiu d'«anar» per a «tu»?", "options": ["ves", "va", "vages"], "answers": ["ves"], "explanation": "Ves (tu), vaja (vosté), aneu (vosaltres). Ves-te'n!"},
  {"rid": "e5f3f3e9-5a53-441d-b318-060e27c2c04c", "level": "B1", "pos": 25, "prompt": "Quin és l'imperatiu de «tindre» per a «tu» quan dones una cosa?", "options": ["té (o tin)", "tens", "tenies"], "answers": ["té (o tin)"], "explanation": "Té! (o tin): agafa. Tingues paciència: tingues."},
  {"rid": "e5f3f3e9-5a53-441d-b318-060e27c2c04c", "level": "B1", "pos": 28, "prompt": "«No ___ tan de pressa!» (córrer, tu)", "options": ["córregues", "corres", "corre"], "answers": ["córregues"], "explanation": "Imperatiu negatiu = subjuntiu: no córregues (que córrega, córregues, córrega...)."},
  {"rid": "969469d6-dee2-4b10-bf2b-26bcd3e65e55", "level": "B1", "pos": 1, "prompt": "Com s'escriu 8 en valencià?", "options": ["huit", "güit", "uit"], "answers": ["huit"], "explanation": "En valencià: huit (també vuit)."},
  {"rid": "969469d6-dee2-4b10-bf2b-26bcd3e65e55", "level": "B1", "pos": 15, "prompt": "Quin és l'ordinal de «cinc» en masculí?", "options": ["cinqué (o quint)", "cinquén (o quinto)", "cinqueno"], "answers": ["cinqué (o quint)"], "explanation": "Cinqué (o cinquè) o quint."},
  {"rid": "969469d6-dee2-4b10-bf2b-26bcd3e65e55", "level": "B1", "pos": 17, "prompt": "Quin és l'ordinal de «vint» en masculí?", "options": ["vinté", "vinteno", "vintavo"], "answers": ["vinté"], "explanation": "Vinté (o vintè), femení vintena."},
  {"rid": "379adbb2-a63b-465b-85a8-57fc66b1f877", "level": "B1", "pos": 14, "prompt": "«Em ___ uns pantalons nous.» (necessitat)", "options": ["calen", "cal", "fa falta que"], "answers": ["calen"], "explanation": "Caldre concorda amb el que es necessita: em cal un bolígraf, em calen uns pantalons."},
  {"rid": "379adbb2-a63b-465b-85a8-57fc66b1f877", "level": "B1", "pos": 26, "prompt": "Escriu el verb d'obligació: «___ d'anar a treballar.» (jo, present)", "options": null, "answers": ["he", "haig"], "explanation": "He d'anar."},
  {"rid": "379adbb2-a63b-465b-85a8-57fc66b1f877", "level": "B1", "pos": 28, "prompt": "Corregix la frase: «Tinc que estudiar.»", "options": null, "answers": ["he d'estudiar", "haig d'estudiar"], "explanation": "He d'estudiar."},
  {"rid": "98325cd9-231e-4aae-80f2-1001b92259d8", "level": "B1", "pos": 27, "prompt": "«Vaig ___ metge.»", "options": ["al", "a el", "el"], "answers": ["al"], "explanation": "Anar a + el = al metge."},
  {"rid": "98325cd9-231e-4aae-80f2-1001b92259d8", "level": "B1", "pos": 32, "prompt": "Corregix la frase: «He vist a ta germana.»", "options": null, "answers": ["he vist ta germana", "he vist la teua germana", "he vist la teva germana"], "explanation": "He vist ta germana (sense a)."},
  {"rid": "bc2f3489-6ae8-468c-aa0f-4b23695a0a02", "level": "B1", "pos": 18, "prompt": "«Us diré la veritat.» → «___ diré.»", "options": ["Us la", "Os la", "Us l'"], "answers": ["Us la"], "explanation": "Us + la → us la (en valencià també vos la)."},
  {"rid": "5916a0f9-90af-4c02-bab8-768bc0bc7004", "level": "B1", "pos": 5, "prompt": "Quina és correcta?", "options": ["Entre tu i jo ho farem.", "Entre te i mi ho farem.", "Entre te i jo ho farem."], "answers": ["Entre tu i jo ho farem."], "explanation": "Entre tu i jo (també entre tu i mi)."},
  {"rid": "5916a0f9-90af-4c02-bab8-768bc0bc7004", "level": "B1", "pos": 7, "prompt": "Quin és el femení d'«ells»?", "options": ["elles", "elas", "ellas"], "answers": ["elles"], "explanation": "Ell, ella, ells, elles."},
  {"rid": "5916a0f9-90af-4c02-bab8-768bc0bc7004", "level": "B1", "pos": 21, "prompt": "«___ espere a la porta.» (a vosaltres)", "options": ["Us", "Eus", "Os"], "answers": ["Us"], "explanation": "Davant del verb: us espere (en valencià també vos espere)."},
  {"rid": "b6c86018-dd00-47e9-88df-9462393e1e84", "level": "B1", "pos": 4, "prompt": "«Ja n'hi ha ___!» (ja és suficient)", "options": ["prou", "molt", "massa poc"], "answers": ["prou"], "explanation": "Ja n'hi ha prou!: ja és suficient."},
  {"rid": "b6c86018-dd00-47e9-88df-9462393e1e84", "level": "B1", "pos": 27, "prompt": "«Vull ___ café, per favor.» (un més)", "options": ["un altre", "otro", "altre un"], "answers": ["un altre"], "explanation": "Un altre, una altra, uns altres, unes altres."},
  {"rid": "d4e6b0ae-2e1f-4d5b-ad27-be9d86b4e19e", "level": "B1", "pos": 10, "prompt": "Quin és el femení d'«actor»?", "options": ["actriu", "actora", "actriz"], "answers": ["actriu"], "explanation": "Actor / actriu (com emperador / emperadriu)."},
  {"rid": "d4e6b0ae-2e1f-4d5b-ad27-be9d86b4e19e", "level": "B1", "pos": 12, "prompt": "Quin és el femení de «poeta»?", "options": ["poetessa", "poetesa", "poetisa"], "answers": ["poetessa"], "explanation": "Poeta / poetessa (també es pot dir «la poeta»)."},
  {"rid": "d4e6b0ae-2e1f-4d5b-ad27-be9d86b4e19e", "level": "B1", "pos": 15, "prompt": "Quin és el femení d'«homicida»?", "options": ["homicida (és invariable)", "homicidessa", "homicidera"], "answers": ["homicida (és invariable)"], "explanation": "Homicida, suïcida, artista, periodista: invariables en gènere."},
  {"rid": "d4e6b0ae-2e1f-4d5b-ad27-be9d86b4e19e", "level": "B1", "pos": 19, "prompt": "Quin és el plural d'«aigua»?", "options": ["aigües", "aigues", "aiguas"], "answers": ["aigües"], "explanation": "Aigua → aigües."},
  {"rid": "d4e6b0ae-2e1f-4d5b-ad27-be9d86b4e19e", "level": "B1", "pos": 21, "prompt": "Quin és el plural d'«amiga»?", "options": ["amigues", "amiges", "amigas"], "answers": ["amigues"], "explanation": "G + a → gu + e: amigues."},
  {"rid": "d4e6b0ae-2e1f-4d5b-ad27-be9d86b4e19e", "level": "B1", "pos": 24, "prompt": "Quin és el plural de «camió»?", "options": ["camions", "camións", "camiós"], "answers": ["camions"], "explanation": "Camió → camions: el plural és pla acabat en -ns i no porta accent."},
  {"rid": "d4e6b0ae-2e1f-4d5b-ad27-be9d86b4e19e", "level": "B1", "pos": 25, "prompt": "Quin és el plural d'«examen»?", "options": ["exàmens", "examens", "exámens"], "answers": ["exàmens"], "explanation": "Examen → exàmens: el plural és pla acabat en -ens i porta accent."},
  {"rid": "8c30c366-0748-47c4-9314-14ad0cc65797", "level": "B1", "pos": 1, "prompt": "«Jo ___ a Gandia.» (nàixer, passat perifràstic)", "options": ["vaig nàixer", "vaig naixer", "vaig nasquer"], "answers": ["vaig nàixer"], "explanation": "Nàixer (o néixer): vaig nàixer. Participi: nascut."},
  {"rid": "8c30c366-0748-47c4-9314-14ad0cc65797", "level": "B1", "pos": 31, "prompt": "«Ell ___ el got d'aigua.» (omplir, present)", "options": ["ompli", "omplixc", "omplix"], "answers": ["ompli"], "explanation": "Omplir en valencià: jo ompli, tu omplis, ell ompli, omplim, ompliu, omplin. Participi: omplit (o omplert)."},
  {"rid": "8c30c366-0748-47c4-9314-14ad0cc65797", "level": "B1", "pos": 32, "prompt": "«Ell ___ la finestra.» (obrir, present)", "options": ["obri", "obro", "obrix"], "answers": ["obri"], "explanation": "Obrir en valencià: jo obri, tu obris, ell obri, obrim, obriu, obrin. Participi: obert."},
  {"rid": "8c30c366-0748-47c4-9314-14ad0cc65797", "level": "B1", "pos": 33, "prompt": "Quin és el participi d'«obrir»?", "options": ["obert", "obrit", "obrut"], "answers": ["obert"], "explanation": "Obert / oberta."},
  {"rid": "8c30c366-0748-47c4-9314-14ad0cc65797", "level": "B1", "pos": 37, "prompt": "Escriu el participi d'«obrir».", "options": null, "answers": ["obert"], "explanation": "Obert."},
  {"rid": "8c30c366-0748-47c4-9314-14ad0cc65797", "level": "B1", "pos": 38, "prompt": "Escriu el present de subjuntiu d'«anar» per a «jo»: que jo ___.", "options": null, "answers": ["vaja"], "explanation": "Vaja."},
  {"rid": "89c56ceb-f29e-42f7-b327-8f498302c9ed", "level": "B1", "pos": 6, "prompt": "«Ell ___ molt bé.» (llegir, present)", "options": ["llig", "lligix", "lleix"], "answers": ["llig"], "explanation": "Llegir: llig, lliges, llig, llegim, llegiu, lligen."},
  {"rid": "89c56ceb-f29e-42f7-b327-8f498302c9ed", "level": "B1", "pos": 18, "prompt": "«Vull que ells ___ el sopar.» (servir, present de subjuntiu)", "options": ["servisquen", "servixen", "serven"], "answers": ["servisquen"], "explanation": "Verbs incoatius en subjuntiu: que servisca, servisques, servisca, servim, serviu, servisquen."},
  {"rid": "89c56ceb-f29e-42f7-b327-8f498302c9ed", "level": "B1", "pos": 25, "prompt": "Quina és la forma del gerundi de «cantar»?", "options": ["cantant", "cantan", "cantando"], "answers": ["cantant"], "explanation": "Gerundi: cantant, tement, dormint."},
  {"rid": "89c56ceb-f29e-42f7-b327-8f498302c9ed", "level": "B1", "pos": 26, "prompt": "Quina és la forma del participi de «témer»?", "options": ["temut", "temit", "temido"], "answers": ["temut"], "explanation": "Participi de la segona conjugació: temut, perdut, venut."},
  {"rid": "79dd1db4-40ff-4860-8f49-279ee059ab46", "level": "A2", "pos": 9, "prompt": "Escriu el demostratiu que falta (prop de qui parla, masculí plural): ___ xiquets són els meus fills.", "options": null, "answers": ["estos", "aquests"], "explanation": "Este, esta, estos, estes."},
  {"rid": "79dd1db4-40ff-4860-8f49-279ee059ab46", "level": "A2", "pos": 34, "prompt": "Escriu el demostratiu (prop de qui escolta, femení plural): ___ sabates que portes són molt boniques.", "options": null, "answers": ["eixes", "aqueixes"], "explanation": "Prop de qui escolta: eixes."},
  {"rid": "8e2976bb-d06b-4230-8887-fcf23f45bbdd", "level": "A2", "pos": 2, "prompt": "Quin és el femení d'«alumne»?", "options": ["alumna", "alumnea", "alumnessa"], "answers": ["alumna"], "explanation": "La -e final canvia a -a."},
  {"rid": "8e2976bb-d06b-4230-8887-fcf23f45bbdd", "level": "A2", "pos": 6, "prompt": "Quin és el plural d'«avís»?", "options": ["avisos", "avíssos", "avís"], "answers": ["avisos"], "explanation": "Els acabats en -s tònica afigen -os: avís → avisos."},
  {"rid": "8e2976bb-d06b-4230-8887-fcf23f45bbdd", "level": "A2", "pos": 12, "prompt": "Quin és el femení d'«actor»?", "options": ["actriu", "actora", "actoressa"], "answers": ["actriu"], "explanation": "Actor → actriu: és un femení irregular."},
  {"rid": "8e2976bb-d06b-4230-8887-fcf23f45bbdd", "level": "A2", "pos": 15, "prompt": "Quin és el femení d'«amic»?", "options": ["amiga", "amica", "amiqua"], "answers": ["amiga"], "explanation": "Amic → amiga: la -c final canvia a -g-."},
  {"rid": "8e2976bb-d06b-4230-8887-fcf23f45bbdd", "level": "A2", "pos": 19, "prompt": "Quin és el femení d'«home»?", "options": ["dona", "homa", "homessa"], "answers": ["dona"], "explanation": "Home i dona són paraules diferents per a cada sexe."},
  {"rid": "8e2976bb-d06b-4230-8887-fcf23f45bbdd", "level": "A2", "pos": 24, "prompt": "Quin és el plural d'«amiga»?", "options": ["amigues", "amigas", "amiges"], "answers": ["amigues"], "explanation": "Amiga → amigues: davant de e, g canvia a gu."},
  {"rid": "8e2976bb-d06b-4230-8887-fcf23f45bbdd", "level": "A2", "pos": 29, "prompt": "Quin és el plural masculí de «francés»?", "options": ["francesos", "francéss", "franceses"], "answers": ["francesos"], "explanation": "Francés → francesos (masculí plural)."},
  {"rid": "a8c6af22-1a37-49d0-a8b9-35c91f26bff9", "level": "A2", "pos": 7, "prompt": "Completa: La farmàcia està ___ el banc i el forn.", "options": ["entre", "contra", "cap a"], "answers": ["entre"], "explanation": "Entre: enmig de dues coses."},
  {"rid": "9d900655-f7cc-4ca6-9611-6fc2f32bbc2b", "level": "A2", "pos": 5, "prompt": "Completa: Pau ha arribat ___ a la meta, darrere de Sara.", "options": ["segon", "dos", "segona"], "answers": ["segon"], "explanation": "Ordinal masculí: segon."}
]$data$::jsonb) AS f(rid uuid, level text, pos smallint, prompt text, options jsonb, answers jsonb, explanation text)
WHERE e.resource_id = f.rid AND e.level = f.level AND e.position = f.pos;

-- Imperatiu valencià d'«omplir» en el text de comprensió escrita.
UPDATE public.practice_passages
SET lines = replace(lines::text, '1. Omple el formulari', '1. Ompli el formulari')::jsonb
WHERE lines::text LIKE '%1. Omple el formulari%';

-- ============================================================
-- Origen: 20261001160000_llicons_morfosintaxi_b1.sql
-- ============================================================
-- Lliçons fixes de la Morfosintaxi del B1 (botó «Aprendre lliçó» de cada contingut).
-- Cada lliçó és una adaptació didàctica de nivell B1, redactada a partir de:
--   - l'abast del Quadern de nivell B1 de la JQCV (2024), apartat 3.2.2 Morfosintaxi;
--   - les regles de la Gramàtica valenciana bàsica (GVB) i de la Gramàtica normativa
--     valenciana (GNV) de l'AVL, descarregades una sola vegada en assets-src/avl/.
-- L'app no consulta l'AVL: el contingut es guarda en metadata.lesson
--   intro, blocks[{title, text, table?, examples?, watch?}], remember, sources[{gram, section, title, url}]
-- (els textos admeten **negreta** i *cursiva*). També s'elimina metadata.avl, que
-- apuntava a la consulta en directe que ja no s'usa. Tornar a aplicar el fitxer no
-- canvia res més. Si es torna a aplicar 20261001140000 (que reescriu metadata), cal
-- tornar a aplicar també este fitxer.

UPDATE public.resources r SET
  metadata = (coalesce(r.metadata, '{}'::jsonb) - 'avl') || jsonb_build_object('lesson', l.lesson)
FROM jsonb_to_recordset($data$[
  {"type": "b1_mor_adjectius", "lesson": {"intro": "Aprendràs a fer el femení i el plural dels adjectius, a concordar-los bé i a descriure, comparar i valorar persones i coses.", "blocks": [{"title": "Una o dos terminacions", "text": "Molts adjectius tenen **dos terminacions**: el femení afig *-a* (*blanc* → *blanca*) o fa canvis com els noms. Altres tenen **una sola terminació**: la majoria dels acabats en *-e* (*jove*, *amable*) i en *-al*, *-il*, *-ant*, *-ent* (*fàcil*). Però: *ample* → *ampla*, *calent* → *calenta*.", "table": {"head": ["masculí", "femení", "plural m.", "plural f."], "rows": [["*bo*", "*bona*", "*bons*", "*bones*"], ["*nou*", "*nova*", "*nous*", "*noves*"], ["*blanc*", "*blanca*", "*blancs*", "*blanques*"], ["*roig*", "*roja*", "*rojos*, *roigs*", "*roges*"], ["*gros*", "*grossa*", "*grossos*", "*grosses*"], ["*jove*", "*jove*", "*joves*", "*joves*"]]}, "watch": [{"wrong": "una mà ample", "right": "una mà ampla"}, {"wrong": "la carn cruna", "right": "la carn crua"}]}, {"title": "Concordança amb el nom", "text": "L'article i l'adjectiu van en el **mateix gènere i nombre** que el nom. Si l'adjectiu va darrere de **dos noms**, va en **plural**: en femení si els dos són femenins i en **masculí** si n'hi ha un de cada gènere.", "examples": ["Hem comprat una camisa i una falda **blanques**.", "Les cadires i els sofàs **nous** ja són a casa.", "Els xiquets estaven **cansats** i la mare, **preocupada**."]}, {"title": "Descriure persones i coses", "text": "Pots descriure el **físic** (*alt*, *prim*, *ros*), el **caràcter** (*generós*, *alegre*, *tossut*) i **l'estat d'ànim** (*content*, *trist*, *preocupat*). Compte: ***gruixut*** és el que té molt de gruix (un llibre, una paret); ***gros*** és el que té molt de volum o grandària.", "examples": ["La meua germana és **alegre** i molt **generosa**.", "Este diccionari és molt **gruixut**: té mil pàgines.", "Al parc hi ha un pi molt **gros**."]}, {"title": "Molt, molt: -íssim i -et", "text": "El **superlatiu** es fa amb ***-íssim*** / ***-íssima***: *bo* → *boníssim*, *fàcil* → *facilíssim*. Mira la grafia: *ric* → *riquíssim*, *llarg* → *llarguíssim*, *amable* → *amabilíssim*. Per a intensificar o fer afecte, usa ***-et*** / ***-eta***: *calent* → *calentet*. També hi ha *-ó*, sobretot amb noms: *carreró*.", "examples": ["La coca estava **boníssima**.", "L'examen ha sigut **facilíssim**.", "Pren-te la sopa ara que està **calenteta**."]}, {"title": "Comparar i valorar", "text": "Per a comparar, usa *més... que* i *menys... que*. **Bo** té formes pròpies: ***millor*** (‘més bo’) i ***pitjor*** (‘menys bo’); amb article, **el millor**, **el pitjor**. Per a valorar, tens *bo*, *roín* (el contrari de *bo*) i *regular*.", "examples": ["Esta pel·lícula és **pitjor** que l'altra.", "És **el millor** restaurant de la ciutat.", "—Com ha anat? —**Regular**: ni bé ni mal."]}], "remember": ["*Jove*, *fàcil* i *amable* tenen una sola forma per als dos gèneres.", "Un nom masculí i un femení junts: adjectiu en masculí plural.", "*Gruixut* vol dir 'de molt de gruix'; *gros*, 'de molt de volum'.", "*Millor* i *pitjor* comparen; *-íssim* intensifica: *boníssim*, *facilíssim*."], "sources": [{"gram": "GVB", "section": "18.1.1", "title": "Conceptes generals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=genere_adjectius"}, {"gram": "GVB", "section": "18.1.2", "title": "Els adjectius variables", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=adjectius_variables"}, {"gram": "GVB", "section": "18.1.3", "title": "Els adjectius invariables respecte al gènere", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=adjectius_invariables"}, {"gram": "GVB", "section": "18.2.1", "title": "La formació del plural", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=nombre_adjectius_formacio_plurals"}, {"gram": "GVB", "section": "18.3", "title": "La concordança de l'adjectiu", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=concordanca_adjectiu"}, {"gram": "GNV", "section": "12.2.1", "title": "Els adjectius qualificatius", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=adjectius_qualificatius"}, {"gram": "GNV", "section": "13.2.2", "title": "La formació del femení a partir de masculins acabats en vocal", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=adjectius_femeni_a_partir_masculins_acabats_en_vocal"}, {"gram": "GNV", "section": "13.3", "title": "Els adjectius invariables respecte al gènere", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=adjectius_invariables"}, {"gram": "GNV", "section": "20.4", "title": "Els quantitatius comparatius", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=quantitatius_mes_menys_tant"}, {"gram": "GNV", "section": "37.3", "title": "Alternances formals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=alternances_formals"}, {"gram": "GNV", "section": "37.6", "title": "La sufixació valorativa", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=sufixacio_valorativa"}]}},
  {"type": "b1_mor_adverbis", "lesson": {"intro": "Aprendràs a dir que sí o que no amb més força, a formar adverbis en *-ment* i a comparar persones i coses.", "blocks": [{"title": "Dir que sí", "text": "*Sí* s'usa en les respostes, sol o amb *que*: *Sí que ho he fet*. Per a reforçar-lo tens *i tant*, *és clar*, *sens dubte* i *de veres* (o *de veritat*). En la conversa, *prou* també pot voler dir 'sí, és clar'. Si dubtes, usa *potser*.", "examples": ["—Vindràs a la festa? —**I tant**! No me la perdria per res.", "És, **sens dubte**, el millor jugador de l'equip.", "**Potser** arribe tard."]}, {"title": "Dir que no", "text": "Per a negar amb força, *de cap manera* (o *de ninguna manera*). Les paraules *mai*, *res*, *ningú*, *cap* i *tampoc* necessiten *no* quan van **darrere del verb**. Si van davant, el *no* és opcional.", "examples": ["—Deixaràs que ho faça sol? —**De cap manera**!", "—Jo no hi vaig. —Jo **tampoc**."], "watch": [{"wrong": "He estat mai a Roma.", "right": "No he estat mai a Roma."}]}, {"title": "Adverbis en *-ment*", "text": "Afig *-ment* a la **forma femenina** de l'adjectiu. Si l'adjectiu és igual en masculí i en femení, afig-lo directament. Si en coordines dos, pots llevar *-ment* del **segon**, però hui és més habitual mantindre'l en tots dos.", "table": {"head": ["adjectiu", "femení", "adverbi"], "rows": [["*ràpid*", "*ràpida*", "*ràpidament*"], ["*clar*", "*clara*", "*clarament*"], ["*fàcil*", "*fàcil*", "*fàcilment*"], ["*feliç*", "*feliç*", "*feliçment*"]]}, "examples": ["Parlava **tranquil·lament i lentament** (o *tranquil·lament i lenta*)."]}, {"title": "Comparar", "text": "Per a comparar usa *més... que*, *menys... que* i, per a la igualtat, *tan... com* davant d'adjectiu o adverbi. Amb un verb, *tant... com*. Davant d'un nom, *tant* concorda: *tanta*, *tants*, *tantes*.", "table": {"head": ["comparació", "fórmula", "exemple"], "rows": [["superioritat", "*més... que*", "*Ma germana és més alta que jo.*"], ["inferioritat", "*menys... que*", "*Este cotxe és menys car que l'altre.*"], ["igualtat + adjectiu", "*tan... com*", "*Pau és tan simpàtic com el seu germà.*"], ["igualtat + verb", "*tant... com*", "*Treballa tant com tu.*"], ["igualtat + nom", "*tants... com*", "*Té tants llibres com jo.*"]]}}, {"title": "*Tan*, *tant* i *molt*", "text": "Amb *que* expressen **conseqüència**: *tan* davant d'adjectiu o adverbi; *tant*, *tanta*... davant de nom. *Molt* no canvia davant d'un adjectiu o adverbi, però amb un nom concorda, encara que hi haja *més* pel mig.", "examples": ["Corre **tan** de pressa que ningú l'alcança.", "Hi havia **tanta** gent que no podíem entrar.", "Hui fa **molta** més calor que ahir."], "watch": [{"wrong": "És tant alt com tu.", "right": "És tan alt com tu."}]}], "remember": ["Per a reforçar el sí: *i tant*, *sens dubte*, *de veres*.", "*Mai*, *res*, *ningú* i *tampoc* darrere del verb demanen *no*.", "Adverbi en *-ment*: femení de l'adjectiu + *-ment*.", "*Tan* + adjectiu o adverbi; *tant* + verb; *tant*, *tanta*, *tants*, *tantes* + nom."], "sources": [{"gram": "GVB", "section": "23.2", "title": "Variació morfològica", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=aspectes_formals_sintactics"}, {"gram": "GVB", "section": "23.3", "title": "Aspectes formals i sintàctics", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=quantitatius"}, {"gram": "GVB", "section": "23.4.11", "title": "Més, menys i tant", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=quantitatius_mes_menys_tant"}, {"gram": "GVB", "section": "24.2.14", "title": "Cap", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=indefinits_negatius"}, {"gram": "GVB", "section": "34.2", "title": "Adverbis derivats d'adjectius", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=adverbis_derivats_adjectius"}, {"gram": "GVB", "section": "37.2.1", "title": "Molt", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=adverbi_molt"}, {"gram": "GVB", "section": "37.2.8", "title": "Tant", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=adverbi_tant"}, {"gram": "GVB", "section": "37.2.9", "title": "Més", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=adverbi_mes"}, {"gram": "GVB", "section": "37.2.10", "title": "Menys", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=adverbi_menys"}, {"gram": "GVB", "section": "38.1", "title": "Els adverbis modals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=adverbis_modals"}, {"gram": "GVB", "section": "38.2.1", "title": "Sí", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=adverbi_si"}, {"gram": "GVB", "section": "38.2.4", "title": "Les paraules negatives", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=usos_paraules_negatives"}, {"gram": "GVB", "section": "41.4.6", "title": "Les conjuncions consecutives", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=conjuncions_consecutives"}, {"gram": "GVB", "section": "42.2.3", "title": "Les interjeccions fàtiques", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=interjeccions_fatiques"}, {"gram": "GNV", "section": "26.5.4", "title": "La preposició sense", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=preposicio_sense"}, {"gram": "GNV", "section": "27.3.2", "title": "Precisions sobre els adverbis de manera", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=adverbis_manera"}, {"gram": "GNV", "section": "27.7.2", "title": "Els adverbis d'afirmació i de negació", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=adverbis_afirmacio_negacio"}]}},
  {"type": "b1_mor_connectors", "lesson": {"intro": "Aprendràs a unir idees per a expressar contrast, obstacle, conseqüència, temps i condició, i a triar el connector adequat en cada frase.", "blocks": [{"title": "Contrast: *però* i *sinó*", "text": "*Però* afig una **restricció** o una idea contrària. *Sinó* **substituïx** el que acabes de negar; si darrere ve una oració, *sinó que*. *Tanmateix* i *no obstant això* també marquen contrast amb el que has dit abans.", "examples": ["És car, **però** val la pena.", "No vull café, **sinó** te.", "No és que no vullga, **sinó que** no pot."]}, {"title": "Un obstacle que no impedix", "text": "Per a dir que hi ha un **obstacle**, però l'acció es fa igualment, usa *encara que* (la més general), *tot i que*, *malgrat que* o *per més que* davant d'una oració. Davant d'un nom, la preposició *malgrat* o *a pesar de*.", "examples": ["**Encara que** plou, eixirem a passejar.", "**Tot i que** estava cansat, va acabar la faena.", "**Malgrat** la pluja, vam anar d'excursió."]}, {"title": "La conseqüència", "text": "Per a presentar el **resultat** del que has dit, usa *per tant*, *per això*, *així que*, *de manera que* o *doncs*. *Doncs* és molt útil per a reaccionar al que diu una altra persona. Amb *tan... que* o *tant... que* la conseqüència ve d'una intensitat.", "examples": ["Ha estudiat molt; **per tant**, ha aprovat.", "Feia molt de fred, **així que** vam encendre l'estufa.", "No t'agrada? **Doncs** no te'l menges."]}, {"title": "El temps", "text": "Amb un verb conjugat, usa *abans que* i *després que*; amb **infinitiu**, *abans de* i *després de*. Darrere d'*abans que* i *fins que* pots posar un *no* que no nega res. *Mentre* també es diu *mentres*.", "table": {"head": ["valor", "connector", "exemple"], "rows": [["moment", "*quan*", "*Quan arribes, telefona'm.*"], ["al mateix temps", "*mentre*", "*Mentre cuinava, escoltava la ràdio.*"], ["repetició", "*cada volta que*, *sempre que*", "*Cada volta que ve, porta un regal.*"], ["abans", "*abans que (no)*, *abans de*", "*Renta't les mans abans de menjar.*"], ["després", "*després que*, *després de*, *tan prompte com*", "*Després de dinar, farem la becaina.*"], ["límit", "*fins que*", "*Esperarem fins que arribe.*"]]}, "watch": [{"wrong": "Hem d'eixir abans de que comence a ploure.", "right": "Hem d'eixir abans que comence a ploure."}]}, {"title": "Condició, causa i finalitat", "text": "La condició bàsica és *si*. Per a una situació **hipotètica**, usa *si* + imperfet de subjuntiu i el condicional en l'altra part. *En cas que* va amb subjuntiu. *Perquè* pot indicar la **causa** o la **finalitat**.", "examples": ["**Si** tinguera temps, t'ajudaria.", "**En cas que** ploga, el partit s'ajornarà.", "No va vindre **perquè** estava malalt."]}], "remember": ["*Però* contrasta; *sinó* substituïx el que has negat.", "Obstacle que no impedix: *encara que*, *tot i que*, *malgrat*.", "Conseqüència: *per tant*, *així que*, *doncs*.", "*Abans de* + infinitiu, però *abans que* + verb conjugat."], "sources": [{"gram": "GVB", "section": "31.10", "title": "Malgrat", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=preposicio_malgrat"}, {"gram": "GVB", "section": "33.2", "title": "L'elisió de preposicions àtones", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=elisio_preposicions"}, {"gram": "GVB", "section": "38.2.3", "title": "Usos expletius de l'adverbi no", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=usos_expletius_adverbi_no"}, {"gram": "GVB", "section": "41.3.4", "title": "Les conjuncions adversatives", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=conjuncions_adversatives"}, {"gram": "GVB", "section": "41.4.2", "title": "Les conjuncions condicionals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=conjuncions_condicionals"}, {"gram": "GVB", "section": "41.4.3", "title": "Les conjuncions concessives", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=conjuncions_concessives"}, {"gram": "GVB", "section": "41.4.4", "title": "Les conjuncions causals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=conjuncions_causals"}, {"gram": "GVB", "section": "41.4.5", "title": "Les conjuncions finals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=conjuncions_finals"}, {"gram": "GVB", "section": "41.4.6", "title": "Les conjuncions consecutives", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=conjuncions_consecutives"}, {"gram": "GVB", "section": "41.4.7", "title": "Les conjuncions temporals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=conjuncions_temporals"}, {"gram": "GNV", "section": "26.3.5", "title": "L'elisió i el canvi de preposicions àtones", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=elisio_canvi_preposicions"}, {"gram": "GNV", "section": "34.4.4", "title": "Les conjuncions adversatives", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=conjuncions_adversatives"}, {"gram": "GNV", "section": "34.5.2", "title": "Les conjuncions condicionals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=conjuncions_condicionals"}, {"gram": "GNV", "section": "34.5.6", "title": "Les conjuncions consecutives", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=conjuncions_consecutives"}, {"gram": "GNV", "section": "34.5.7", "title": "Les conjuncions temporals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=conjuncions_temporals"}]}},
  {"type": "b1_mor_determinants", "lesson": {"intro": "Aprendràs a usar bé els articles, els demostratius i els possessius per a parlar de persones i coses concretes.", "blocks": [{"title": "L'article i l'apòstrof", "text": "Article definit: *el*, *la*, *els*, *les*; indefinit: *un*, *una*, *uns*, *unes*. ***El*** s'apostrofa davant de **vocal o *h***: *l'home*. ***La*** també (*l'amiga*, *l'era*), **excepte davant de *i*, *u* àtones**: *la infermera*, *la universitat*.", "examples": ["**L'**infermer i **la** infermera treballen de nit.", "**L'**habitació de **l'**hotel és molt gran."], "watch": [{"wrong": "l'infermera", "right": "la infermera"}]}, {"title": "Contraccions: al, del, pel", "text": "*A*, *de* i *per* + *el* fan ***al*, *del*, *pel***; + *els* fan ***als*, *dels*, *pels***. Davant de **vocal o *h*** no hi ha contracció: *a l'*, *de l'*, *per l'*. Per a idees generals, usa *el*, no *lo*.", "examples": ["Anem **al** mercat i després venim **del** forn.", "Hem quedat **a l'**estadi a les huit."], "watch": [{"wrong": "Lo més important és la salut.", "right": "El més important és la salut."}]}, {"title": "Este, eixe, aquell", "text": "Indiquen distància: **prop de qui parla**, **prop de qui escolta** i **lluny dels dos**. Les formes **simples** (*este*, *eixe*) són les generals en la llengua oral; les **reforçades** (*aquest*, *aqueix*) són més pròpies de l'escrit. Totes dues són correctes.", "table": {"head": ["", "prop de mi", "prop de tu", "lluny"], "rows": [["masc.", "*este* / *aquest*", "*eixe* / *aqueix*", "*aquell*"], ["fem.", "*esta* / *aquesta*", "*eixa* / *aqueixa*", "*aquella*"], ["masc. pl.", "*estos* / *aquests*", "*eixos* / *aqueixos*", "*aquells*"], ["fem. pl.", "*estes* / *aquestes*", "*eixes* / *aqueixes*", "*aquelles*"], ["neutre", "*açò*", "*això*", "*allò*"]]}}, {"title": "Possessius: el meu, la teua", "text": "Concorden amb **la cosa posseïda** i normalment porten **article**: *el meu cotxe*, *la teua germana*. *Seu* val per a **ell, ella, ells i elles**: *la seua casa*.", "table": {"head": ["", "masculí", "femení", "plural"], "rows": [["jo", "*meu*", "*meua*", "*meus*, *meues*"], ["tu", "*teu*", "*teua*", "*teus*, *teues*"], ["ell, ella, ells", "*seu*", "*seua*", "*seus*, *seues*"], ["nosaltres", "*nostre*", "*nostra*", "*nostres*"], ["vosaltres", "*vostre*", "*vostra*", "*vostres*"]]}, "examples": ["Estes claus són **meues**."]}, {"title": "Ma mare, son iaio", "text": "Les formes curtes (**àtones**) van **sense article** i s'usen amb **noms de família**, amb *casa* i en l'expressió *en ma vida* (‘mai’). Masculí: *mon*, *ton*, *son*; femení: *ma*, *ta*, *sa*; plural: *mos*, *tos*, *sos* / *mes*, *tes*, *ses*.", "examples": ["La Marta viu amb **son** iaio i **sa** mare.", "Han vingut **mos** cosins i **ta** germana.", "**En ma vida** havia vist tanta gent!"], "watch": [{"wrong": "la ma mare", "right": "ma mare (o la meua mare)"}]}], "remember": ["*L'amiga*, però *la infermera*: davant de *i*, *u* àtones, *la*.", "*A* + *el* = *al*; *de* + *el* = *del*; però *a l'estadi*.", "*Este*/*aquest*, *eixe*/*aqueix*: les dues sèries són correctes.", "*Ma mare*, *son iaio*: possessiu curt, sempre sense article."], "sources": [{"gram": "GVB", "section": "19.2.1", "title": "Característiques generals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=article_definit"}, {"gram": "GVB", "section": "19.2.2", "title": "Formes contractes de l'article", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=formes_contractes_article_definit"}, {"gram": "GVB", "section": "19.3", "title": "L'article indefinit", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=article_indefinit"}, {"gram": "GVB", "section": "19.5.1", "title": "Usos amb funció substantivadora", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=article_neutre_substantivador"}, {"gram": "GVB", "section": "20.2.1", "title": "Els determinants demostratius", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=determinants_demostratius"}, {"gram": "GVB", "section": "20.2.2", "title": "Els pronoms neutres demostratius", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=pronoms_neutres_demostratius"}, {"gram": "GVB", "section": "21.2.1", "title": "Morfologia dels possessius tònics", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=morfologia_possessius_tonics"}, {"gram": "GVB", "section": "21.2.2", "title": "Posició dels possessius", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=posicio_possessius"}, {"gram": "GVB", "section": "21.3", "title": "Els possessius àtons", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=possessius_atons"}]}},
  {"type": "b1_mor_interrogatius", "lesson": {"intro": "Aprendràs a fer preguntes amb *qui*, *què*, *quin*, *quant*, *on*, *com* i *quan*, i a no confondre *quan* amb *quant*.", "blocks": [{"title": "Qui (persones) i què (coses)", "text": "**Qui** pregunta per persones i **què**, per coses. No canvien mai de forma i poden anar darrere d'una preposició: *amb qui*, *de qui*, *de què*. *Què* interrogatiu porta **accent**. També els uses dins d'una frase: *No sé què fer*.", "examples": ["**Qui** ha telefonat?", "**De qui** és este abric?", "**De què** està fet este moble?"], "watch": [{"wrong": "Que has dit?", "right": "Què has dit?"}]}, {"title": "Quin, quina, quins, quines", "text": "**Quin** va davant d'un nom i pregunta quin element és, dins d'un grup conegut. **Concorda** en gènere i nombre amb el nom.", "table": {"head": ["", "singular", "plural"], "rows": [["masculí", "*quin* llibre", "*quins* dies"], ["femení", "*quina* pel·lícula", "*quines* sabates"]]}, "examples": ["**Quina** hora és?"]}, {"title": "Quant: la quantitat", "text": "**Quant** pregunta per la quantitat. Davant d'un nom concorda: *quanta*, *quants*, *quantes*. Davant d'un nom masculí singular porta **de**: *quant de temps*, *quant de pa*. Amb un verb no canvia: *Quant costa?* També servix per a exclamar.", "table": {"head": ["", "singular", "plural"], "rows": [["masculí", "*quant de* temps", "*quants* germans"], ["femení", "*quanta* llet", "*quantes* germanes"]]}, "examples": ["**Quant** costa este jersei?", "**Quanta** gent hi havia!"]}, {"title": "On, com i quan", "text": "Per a preguntar pel **lloc**, usa **on** o **a on**; per la **manera**, **com**; pel **temps**, **quan**. Cap d'estos porta accent.", "examples": ["**A on** vas este estiu?", "**Com** et dius?", "M'ha preguntat **quan** arribaré."]}, {"title": "Compte: quan/quant, per què/perquè", "text": "**Quan** (sense *t*) és el temps; **quant** (amb *t*), la quantitat. Per a preguntar la causa, **per què**, separat i amb accent; per a respondre, **perquè**, junt.", "examples": ["**Per què** no has vingut? —**Perquè** estava malalt."], "watch": [{"wrong": "Quant arribarà el tren?", "right": "Quan arribarà el tren?"}, {"wrong": "Perquè no has vingut?", "right": "Per què no has vingut?"}]}], "remember": ["*Qui* per a persones; *què* (amb accent) per a coses.", "*Quin* i *quant* concorden amb el nom: *quina*, *quants*...", "Masculí singular: *quant de* temps, *quant de* pa.", "*Quan* = temps; *quant* = quantitat."], "sources": [{"gram": "GVB", "section": "7.7", "title": "L'accentuació diacrítica", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=accentuacio_diacritica"}, {"gram": "GVB", "section": "23.3", "title": "Aspectes formals i sintàctics", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=quantitatius"}, {"gram": "GVB", "section": "29.1", "title": "Introducció", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=interrogatius_i_exclamatius"}, {"gram": "GVB", "section": "29.2", "title": "Qui", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=interrogatiu_qui"}, {"gram": "GVB", "section": "29.3", "title": "Què", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=interrogatiu_que_accentuat"}, {"gram": "GVB", "section": "29.4", "title": "Quin", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=interrogatiu_quin"}, {"gram": "GVB", "section": "29.5", "title": "Quant", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=interrogatiu_quant"}, {"gram": "GVB", "section": "29.6", "title": "Adverbis interrogatius", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=interrogatiu_quan"}, {"gram": "GVB", "section": "29.7", "title": "Formes i usos dels exclamatius", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=exclamatius"}, {"gram": "GVB", "section": "41.4.4", "title": "Les conjuncions causals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=conjuncions_causals"}]}},
  {"type": "b1_mor_modes", "lesson": {"intro": "Aprendràs quan has d'usar l'indicatiu, el subjuntiu i l'imperatiu per a informar, desitjar, dubtar i donar ordes.", "blocks": [{"title": "Indicatiu o subjuntiu?", "text": "Usa l'**indicatiu** per a informar d'una cosa que dones per certa. Usa el **subjuntiu** després d'expressions de desig, voluntat, dubte o possibilitat: *vull que*, *espere que*, *no crec que*, *és possible que*, *tant de bo*.", "table": {"head": ["indicatiu: és segur", "subjuntiu: desig o dubte"], "rows": [["Sé que **tens** raó.", "Vull que **vingues**."], ["Crec que **té** raó.", "No crec que **tinga** raó."], ["És evident que **té** raó.", "És possible que **arriben** tard."]]}, "examples": ["Espere que demà **faça** bon temps.", "Tant de bo **aproves**!"], "watch": [{"wrong": "Potser vinga demà.", "right": "Potser vindrà demà."}]}, {"title": "Perquè i quan", "text": "*Perquè* + indicatiu explica la **causa**. *Perquè* + subjuntiu indica la **finalitat** (per a què). Amb *quan*, si parles del futur, usa el subjuntiu (també és correcte el futur); si parles d'un costum, l'indicatiu.", "examples": ["No ha vingut perquè **està** malalt.", "Aniré a parlar amb ell perquè m'**explique** què ha passat.", "Quan **estigues** preparat, m'ho dius."]}, {"title": "Relatives i desitjos", "text": "En una relativa, usa el subjuntiu si **no saps** si la cosa existix, i l'indicatiu si ja la coneixes. Després de *m'agradaria que* o d'un *si* poc probable va l'**imperfet de subjuntiu**.", "examples": ["Necessitem una persona que **sàpia** alemany.", "Visc en un pis que **té** terrassa.", "M'agradaria que **vingueres** amb mi."]}, {"title": "L'imperatiu: ordes i peticions", "text": "Per a *tu*, en els verbs regulars, l'imperatiu és com el present de *ell*: *canta*. Per a *vosté*: *cante*; per a *vosaltres*: *canteu*. En **negatiu** sempre va el subjuntiu: *no cantes*. Els pronoms van darrere: *telefona'm*, *diga'm*.", "table": {"head": ["verb", "tu", "vosté", "negatiu (tu)"], "rows": [["*cantar*", "*canta*", "*cante*", "*no cantes*"], ["*vindre*", "*vine*", "*vinga*", "*no vingues*"], ["*fer*", "*fes*", "*faça*", "*no faces*"], ["*anar*", "*ves*", "*vaja*", "*no vages*"], ["*dir*", "*digues*", "*diga*", "*no digues*"], ["*ser*", "*sigues*", "*siga*", "*no sigues*"]]}, "examples": ["**Tingues** (o **tin**) paciència, que ja arriba.", "No **córregues** tant, que no puc seguir-te!"]}], "remember": ["Informes d'una cosa certa: indicatiu (*Sé que tens raó*).", "Desig, voluntat, dubte o possibilitat: subjuntiu (*Vull que vingues*).", "*Perquè* + indicatiu: causa. *Perquè* + subjuntiu: finalitat.", "Imperatiu negatiu: *no* + subjuntiu (*no cantes*, *no vingues*)."], "sources": [{"gram": "GVB", "section": "26.3.1", "title": "Pronoms anteposats i posposats al verb", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=pronoms_anteposats_i_posposats"}, {"gram": "GVB", "section": "39.2.2", "title": "El temps, l'aspecte i el mode", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=categories_temps_aspecte_mode"}, {"gram": "GVB", "section": "41.4.1", "title": "Les conjuncions completives", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=conjuncions_completives"}, {"gram": "GVB", "section": "41.4.4", "title": "Les conjuncions causals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=conjuncions_causals"}, {"gram": "GVB", "section": "41.4.5", "title": "Les conjuncions finals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=conjuncions_finals"}, {"gram": "GVB", "section": "41.4.7", "title": "Les conjuncions temporals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=conjuncions_temporals"}, {"gram": "GNV", "section": "8.6", "title": "La modalitat oracional", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=modalitat_oracional"}, {"gram": "GNV", "section": "28.3", "title": "El mode", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=categoria_mode"}, {"gram": "GNV", "section": "28.4.2", "title": "Els temps verbals de subjuntiu", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=subjuntiu"}, {"gram": "GNV", "section": "28.5", "title": "Precisions sobre l'ús de l'indicatiu i el subjuntiu", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=precisions_us_indicatiu_subjuntiu"}, {"gram": "GNV", "section": "29.4.1", "title": "Model del verb cantar", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=verbs_regulars"}, {"gram": "GNV", "section": "30.2.3", "title": "Tendència a la generalització de formes velaritzades", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=irregularitats_morfologiques"}]}},
  {"type": "b1_mor_numerals", "lesson": {"intro": "Aprendràs a escriure i dir els números (cardinals) i l'ordre de les coses (ordinals) per a preus, dates, adreces i classificacions.", "blocks": [{"title": "Els primers números", "text": "Fixa't en les formes valencianes generals: ***huit***, ***dèsset***, ***díhuit***, ***dènou*** (també són correctes *vuit*, *disset*, *divuit*, *dinou*). Només canvien en femení ***un*** → *una* i ***dos*** → *dues* (en registres formals).", "table": {"head": ["número", "forma", "número", "forma"], "rows": [["0", "*zero*", "8", "***huit***"], ["1", "*u*, *un*, *una*", "14", "*catorze*"], ["2", "*dos*, *dues*", "17", "***dèsset***"], ["4", "*quatre*", "18", "***díhuit***"], ["5", "*cinc*", "19", "***dènou***"]]}}, {"title": "Números compostos i grans", "text": "Porten **guionet** entre desenes i unitats (*trenta-dos*), amb ***-i-*** del 21 al 29 (*vint-i-u* o *vint-i-un*), i entre unitats i centenes (*tres-cents*). ***Cent*** fa *cents*/*centes*. Després de *cent* i *mil* no hi ha guionet: *cent cinc*, *mil cinc-cents*.", "examples": ["Hi havia **dues-centes** persones a la sala.", "El sofà costa **mil cinc-cents** euros.", "Han venut **un milió** d'entrades; l'any passat, **dos milions**."], "watch": [{"wrong": "tres milió d'euros", "right": "tres milions d'euros"}]}, {"title": "Primer, segon, tercer, quart", "text": "Els **ordinals** indiquen l'ordre i **canvien en gènere i nombre**, com un adjectiu. Els quatre primers tenen formes pròpies.", "table": {"head": ["masculí", "femení", "plural m.", "plural f."], "rows": [["*primer* (1r)", "*primera* (1a)", "*primers*", "*primeres*"], ["*segon* (2n)", "*segona* (2a)", "*segons*", "*segones*"], ["*tercer* (3r)", "*tercera* (3a)", "*tercers*", "*terceres*"], ["*quart* (4t)", "*quarta* (4a)", "*quarts*", "*quartes*"]]}, "watch": [{"wrong": "la segon porta", "right": "la segona porta"}]}, {"title": "Del cinqué en avant: -é/-ena", "text": "A partir del 5 s'afig al cardinal ***-é*** (masculí) o ***-ena*** (femení): *cinqué*, *sisena*, *desena*, *vinté*. També són correctes les formes cultes *quint*/*quinta* i *sext*/*sexta*.", "examples": ["Visc en el **tercer** pis i la meua amiga, en el **cinqué**.", "És la **desena** vegada que t'ho dic!", "El nostre equip ha quedat **vinté**."]}, {"title": "Parts: mig, un quart", "text": "Per a les **parts** d'una cosa s'usen les formes dels ordinals (*un quart*, *una quarta part*), excepte ***mig*/*mitja*** i ***terç***.", "examples": ["Me'n dones **mig** quilo de tomaques i **un quart** de formatge?", "Arribarem a les set i **mitja**."]}], "remember": ["En valencià: *huit*, *dèsset*, *díhuit*, *dènou*.", "Guionet en *trenta-dos* i *tres-cents*; *-i-* només del 21 al 29.", "Ordinals: *primer*, *segon*, *tercer*, *quart*; després, *-é*/*-ena*.", "Els ordinals concorden: *la segona*, *les quartes*, *els primers*."], "sources": [{"gram": "GVB", "section": "22.2.2", "title": "La forma dels numerals cardinals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=numerals_cardinals"}, {"gram": "GVB", "section": "22.2.3", "title": "Acotacions a l'ús de les formes un/u", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=numerals_cardinals"}, {"gram": "GVB", "section": "22.2.4", "title": "Variacions de gènere i nombre", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=numerals_cardinals"}, {"gram": "GVB", "section": "22.2.5", "title": "Ortografia dels cardinals compostos", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=numerals_cardinals"}, {"gram": "GVB", "section": "22.3.1", "title": "Caracterització general", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=numerals_ordinals"}, {"gram": "GVB", "section": "22.3.2", "title": "Aspectes formals i sintàctics", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=numerals_ordinals"}, {"gram": "GVB", "section": "22.4", "title": "Els numerals partitius", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=numerals_partitius"}, {"gram": "GNV", "section": "18.3.2", "title": "La forma dels numerals cardinals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=numerals_cardinals"}, {"gram": "GNV", "section": "18.4.2", "title": "Aspectes formals i sintàctics", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=numerals_ordinals"}]}},
  {"type": "b1_mor_perifrasis", "lesson": {"intro": "Aprendràs a dir on és cada cosa amb ser i estar, a usar semblar i a expressar obligació i probabilitat.", "blocks": [{"title": "Ser o estar: on és?", "text": "Per a dir **on és** una persona, una cosa o un acte, usa *ser*. Usa *estar* quan remarques que **hi roman** un temps (*tot el dia*, *sempre*). Per a dir que una cosa **existix** o es troba en un lloc, usa *hi ha*.", "examples": ["El llapis que busques **és** al calaix.", "El teu fill **està** tot el dia al carrer.", "La conferència **serà** en l'Ajuntament a les huit."], "watch": [{"wrong": "Fora està l'home que vingué ahir.", "right": "Fora hi ha l'home que vingué ahir."}]}, {"title": "Semblar (o paréixer)", "text": "*Semblar* i *paréixer* són sinònims. Servixen per a dir **com és** o com pareix una persona o una cosa, per a fer una suposició (*sembla que...*) i, amb *em*, *et*, *li*..., per a donar o demanar una **opinió**.", "examples": ["Esta xica **sembla** simpàtica.", "Està cansat? **Sembla** que no ha dormit.", "Què et **sembla** el pla? —Em **sembla** molt bé."]}, {"title": "Obligació: haver de, deure, caldre", "text": "Per a una obligació personal, usa **haver de** + infinitiu (*he de* o *haig de*). Per a una obligació moral, **deure** + infinitiu. Per a una obligació general, sense dir qui la té, **cal** + infinitiu o *cal que* + subjuntiu.", "table": {"head": ["construcció", "exemple"], "rows": [["*haver de* + infinitiu", "Demà **he d'anar** al metge."], ["*deure* + infinitiu", "Els fills **deuen obeir** els pares."], ["*cal* + infinitiu", "**Cal** reciclar."], ["*cal que* + subjuntiu", "**Cal que** vingues prompte."], ["*no cal que* + subjuntiu", "**No cal que** vingues, ja ho faig jo."]]}, "watch": [{"wrong": "Tinc que estudiar més.", "right": "He d'estudiar més."}, {"wrong": "Hi ha que portar el DNI.", "right": "Cal portar el DNI."}]}, {"title": "Probabilitat: deure + infinitiu", "text": "**Deure** + infinitiu també servix per a fer una **suposició**: dius el que creus que passa, però no ho saps segur. Entre *deure* i l'infinitiu mai no va la preposició *de*.", "examples": ["**Deuen ser** les cinc: ja es fa fosc.", "No contesta: **deu estar** dormint.", "**Deu tindre** uns trenta anys."], "watch": [{"wrong": "Deu de tindre trenta anys.", "right": "Deu tindre trenta anys."}]}, {"title": "Altres perífrasis útils", "text": "Altres perífrasis diuen com va l'acció: si està en curs, si acaba de passar, si s'interromp o si es repetix.", "table": {"head": ["perífrasi", "valor", "exemple"], "rows": [["*estar* + gerundi", "acció en curs", "Ara **estic estudiant**."], ["*acabar de* + infinitiu", "fa un moment", "**Acabe d'arribar**."], ["*deixar de* + infinitiu", "ja no ho fas", "**He deixat de** fumar."], ["*tornar a* + infinitiu", "una altra vegada", "**Ha tornat a** ploure."]]}}], "remember": ["On és? *Ser*. Hi roman molt de temps? *Estar*. Existix? *Hi ha*.", "*Semblar* = *paréixer*: *Em sembla bé*, *Semblen germans*.", "Obligació: *haver de*, *deure* (moral) i *cal* (impersonal) + infinitiu.", "Suposició: *deure* + infinitiu, sense *de*: *Deu estar dormint*."], "sources": [{"gram": "GVB", "section": "40.1", "title": "Introducció", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=perifrasis_verbals"}, {"gram": "GVB", "section": "40.2.1", "title": "Acabar de + infinitiu", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=perifrasi_acabar_de_infinitiu"}, {"gram": "GVB", "section": "40.2.6", "title": "Deixar de + infinitiu", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=perifrasi_deixar_de_infinitiu"}, {"gram": "GVB", "section": "40.2.7", "title": "Deure + infinitiu", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=perifrasi_deure_infinitiu"}, {"gram": "GVB", "section": "40.2.9", "title": "Haver de + infinitiu", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=perifrasi_haver_de_infinitiu"}, {"gram": "GVB", "section": "40.2.10", "title": "Tornar a + infinitiu", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=perifrasi_tornar_a_infinitiu"}, {"gram": "GVB", "section": "40.3.4", "title": "Estar + gerundi", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=perifrasi_estar_gerundi"}, {"gram": "GNV", "section": "30.2.2", "title": "Verbs amb alternances consonàntiques al final del radical", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=irregularitats_morfologiques"}, {"gram": "GNV", "section": "31.3", "title": "Les perífrasis modals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=perifrasis_modals"}, {"gram": "GNV", "section": "31.4", "title": "Les perífrasis aspectuals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=perifrasis_aspectuals"}, {"gram": "GNV", "section": "32.1", "title": "Conceptes generals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=predicacio_verbal_i_complements"}, {"gram": "GNV", "section": "33.2.1", "title": "Predicacions no verbals primàries", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=predicacions_no_verbals_primaries"}, {"gram": "GNV", "section": "33.3.2", "title": "Usos locatius", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=usos_locatius"}]}},
  {"type": "b1_mor_preposicions", "lesson": {"intro": "Aprendràs a triar la preposició adequada per a parlar del mitjà, el tema, la causa i el lloc, i a no posar *a* davant del complement directe.", "blocks": [{"title": "Mitjà i instrument", "text": "Per a l'**instrument** amb què fas alguna cosa, usa *amb*. Per al **mitjà** que et permet aconseguir-la, *a través de* o *per mitjà de*. Amb els **mitjans de transport** pots dir *en* o *amb*. Si vas caminant, vas *a peu*.", "examples": ["Escriu-ho **amb** el bolígraf blau.", "Ens vam conéixer **a través d'**internet.", "Vam viatjar **en** tren (o **amb** tren) fins a Madrid."]}, {"title": "Tema i causa", "text": "Per a dir de què tracta alguna cosa, usa *de* o *sobre*: *parlar de* o *sobre* un tema. Per a la **causa**, tens *a causa de*, *per culpa de* (hi ha un responsable), *gràcies a* (ho agraïxes), *arran de* i *amb motiu de*.", "examples": ["Hem llegit un llibre **sobre** la història de València.", "S'ha suspés el partit **a causa de** la pluja.", "He aprovat **gràcies a** la teua ajuda."], "watch": [{"wrong": "Hem arribat tard gràcies a l'embús.", "right": "Hem arribat tard per culpa de l'embús."}]}, {"title": "*Per*, *per a* i substitució", "text": "*Per* indica la **causa**. *Per a* indica el **destinatari** i la **finalitat**. Quan algú fa una acció amb una intenció, també és correcte *per*: *Estudie per (a) aprovar*. *En lloc de* i *en compte de* indiquen que una cosa en **substituïx** una altra.", "table": {"head": ["forma", "valor", "exemple"], "rows": [["*per*", "causa", "*Ho he fet per tu.*"], ["*per a*", "destinatari", "*Este regal és per a tu.*"], ["*per a*", "finalitat", "*La caixa servix per a guardar fotos.*"], ["*en lloc de*", "substitució", "*En lloc d'anar en cotxe, anirem amb bici.*"]]}}, {"title": "*A* amb llocs, *casa* i *classe*", "text": "Davant dels **noms de lloc** (pobles, ciutats, països) usa *a*, tant si hi estàs com si hi vas. Per a dir **on vas**, també *a*: *a casa*, *a classe*, *al metge*. Recorda que *a* + *el* fa *al*.", "examples": ["Visc **a** València, però este estiu anirem **a** Itàlia.", "Torne **a** casa a les set.", "Demà vaig **al** metge."]}, {"title": "Complement directe sense *a*", "text": "El **complement directe** (el que veus, estimes, esperes...) va **sense preposició**, encara que siga una persona. Porta *a* davant d'un **pronom fort**: *a tu*, *a ell*. Davant de *tots*, *tothom*, *algú* i *ningú*, i de noms de persona, la *a* és opcional.", "examples": ["Estime molt **els meus pares**.", "T'he vist **a tu**."], "watch": [{"wrong": "Han vist al mestre.", "right": "Han vist el mestre."}, {"wrong": "Esperem a l'autobús.", "right": "Esperem l'autobús."}]}], "remember": ["Instrument: *amb*. Mitjà: *a través de*. Transport: *en* o *amb*.", "Causa: *a causa de*, *per culpa de*, *gràcies a*, *arran de*.", "*Per*: causa. *Per a*: destinatari i finalitat.", "Complement directe sense *a*: *Esperem l'autobús*, però *t'he vist a tu*."], "sources": [{"gram": "GVB", "section": "30.2", "title": "Les classes de preposicions", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=classes_preposicions"}, {"gram": "GVB", "section": "30.3", "title": "A", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=preposicions_atones"}, {"gram": "GVB", "section": "30.5", "title": "De", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=preposicio_de"}, {"gram": "GVB", "section": "30.6", "title": "Amb", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=preposicio_amb"}, {"gram": "GVB", "section": "30.7", "title": "Per", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=preposicio_per"}, {"gram": "GVB", "section": "30.8", "title": "Per a", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=preposicio_per_a"}, {"gram": "GVB", "section": "31.16", "title": "Sobre", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=preposicio_sobre"}, {"gram": "GVB", "section": "32.4", "title": "A causa de", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=locucio_preposicional_a_causa_de"}, {"gram": "GVB", "section": "32.17", "title": "A través de", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=locucio_preposicional_a_traves_de"}, {"gram": "GVB", "section": "32.23", "title": "Arran de", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=locucio_preposicional_arran_de"}, {"gram": "GVB", "section": "32.26", "title": "En compte de", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=locucio_preposicional_en_compte_de"}, {"gram": "GVB", "section": "32.33", "title": "Per mitjà de", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=locucio_preposicional_per_mitja_de"}, {"gram": "GVB", "section": "33.3", "title": "La seqüència de preposicions", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=sequencia_preposicions"}, {"gram": "GNV", "section": "26.3.1.1", "title": "Els complements de lloc", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=complements_lloc"}, {"gram": "GNV", "section": "26.3.2", "title": "La preposició amb", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=preposicio_amb"}, {"gram": "GNV", "section": "26.3.4", "title": "Les preposicions per i per a", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=preposicio_per"}, {"gram": "GNV", "section": "32.2", "title": "El complement directe i la transitivitat", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=objecte_directe"}, {"gram": "GNV", "section": "32.4", "title": "El complement de règim", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=complement_de_regim"}]}},
  {"type": "b1_mor_pronoms_cd_ci", "lesson": {"intro": "Aprendràs a substituir el complement directe i l'indirecte per pronoms febles i a combinar-ne dos: *me'l*, *li ho*, *te la*...", "blocks": [{"title": "Complement directe: el, la, els, les", "text": "El **complement directe** és «el que» compres, veus o dius. En 3a persona el pronom canvia segons el **gènere** i el **nombre**. Per a *això* o una frase usem **ho**; per a un nom sense article, **en**. Amb *la* i *les*, el participi sol concordar.", "table": {"head": ["complement directe", "pronom"], "rows": [["el pa", "*el* (*l'*)"], ["la llet", "*la* (*l'*)"], ["els xiquets", "*els*"], ["les pomes", "*les*"], ["això, que no", "*ho*"], ["pa, pomes (sense article)", "*en* (*n'*)"]]}, "examples": ["La llet? Ja **l'**he compr**ada**."]}, {"title": "Complement indirecte: li, els", "text": "El **complement indirecte** és la persona que rep: «a qui». Només té dos formes: **li** (singular) i **els** (plural), tant per a masculí com per a femení. Amb *vosté* també usem *li*. Si poses el complement al principi, repetix-lo amb el pronom.", "examples": ["He escrit a l'àvia. → **Li** he escrit una carta.", "Telefona a Pere. → Telefona-**li**.", "A Maria, **li** agrada el cine."], "watch": [{"wrong": "Les done els regals (a les filles).", "right": "Els done els regals."}]}, {"title": "Dos pronoms: primer el CI", "text": "Quan n'hi ha dos, l'**orde és fix**: primer l'**indirecte** i després el **directe**. Davant del verb, *em*, *et* i *es* prenen la forma *me*, *te* i *se*. L'apòstrof va tan a la dreta com es puga, i davant de vocal *el* es fa *l'*.", "table": {"head": ["CI + CD", "+ el", "+ la", "+ ho"], "rows": [["*me*", "*me'l*", "*me la*", "*m'ho*"], ["*te*", "*te'l*", "*te la*", "*t'ho*"], ["*li*", "*li'l*", "*li la*", "*li ho*"], ["*ens*", "*ens el*", "*ens la*", "*ens ho*"], ["*vos* (*us*)", "*vos el*", "*vos la*", "*vos ho*"], ["*els*", "*els el*", "*els la*", "*els ho*"]]}, "examples": ["El paquet? **Ens l'**enviaran demà.", "Pa per als xiquets? **Els n'**he portat."]}, {"title": "Dos pronoms darrere del verb", "text": "Amb **imperatiu**, **infinitiu** o **gerundi**, els dos pronoms van **darrere**, en el mateix orde (CI + CD), units amb **guionets** o amb **apòstrofs**.", "examples": ["El llibre? Dona-**me'l**!", "Això? Explica-**li-ho** tu.", "Vull dir-**te-la** (una cosa)."]}, {"title": "Verbs amb pronom fix: anar-se'n", "text": "Alguns verbs porten pronoms fixos: *anar-se'n*, *recordar-se'n*. També ací *em*, *et* i *es* passen a **me**, **te** i **se** davant del verb: *me'n*, *te'n*, *se'n* (*se'n* = *es* + *en*).", "examples": ["**Me'n** vaig a casa.", "No **me'n** recorde.", "Joan **se'n** va a les huit."], "watch": [{"wrong": "M'en vaig.", "right": "Me'n vaig."}]}], "remember": ["CD: *el*, *la*, *els*, *les*, *ho*, *en*. CI: *li* i *els*.", "*Els* és el CI plural per a masculí i femení.", "Orde fix: primer el CI, després el CD: *me'l*, *li ho*.", "Darrere del verb, amb guionet o apòstrof: *dona-me'l*."], "sources": [{"gram": "GVB", "section": "27.1", "title": "Introducció", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=pronoms_febles_funcional"}, {"gram": "GVB", "section": "27.2.1", "title": "Els pronoms reflexius i no reflexius", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=pronoms_personals_febles_reflexius_no_reflexius"}, {"gram": "GVB", "section": "27.2.2", "title": "Els pronoms no reflexius de tercera persona", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=pronoms_personals_febles_no_reflexius_tercera_persona"}, {"gram": "GVB", "section": "27.3", "title": "El pronom neutre", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=pronom_neutre"}, {"gram": "GVB", "section": "27.4.1", "title": "El pronom ne", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=pronom_ne"}, {"gram": "GVB", "section": "27.5", "title": "Dislocacions amb pronom feble", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=dislocacions_feble"}, {"gram": "GVB", "section": "25.3.2", "title": "Les formes de cortesia", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=formes_cortesia"}, {"gram": "GVB", "section": "26.4.1", "title": "L'orde dels pronoms febles", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=orde_pronoms_febles"}, {"gram": "GVB", "section": "26.4.2", "title": "La forma dels pronoms febles", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=forma_pronoms_febles"}]}},
  {"type": "b1_mor_pronoms_personals", "lesson": {"intro": "Aprendràs a distingir els pronoms forts (*jo*, *tu*, *ell*...) dels febles (*em*, *el*, *li*...) i a col·locar els febles davant o darrere del verb.", "blocks": [{"title": "Pronoms forts i pronoms febles", "text": "Els **pronoms forts** funcionen com un nom: poden ser el subjecte o anar darrere d'una preposició. Els **febles** (*em*, *et*, *el*, *la*, *li*, *ens*, *us*, *els*, *les*, *ho*, *en*, *hi*) són àtons i sempre van units al verb, davant o darrere.", "examples": ["**Nosaltres** vivim a Elx.", "Tinc un regal per a **vosté**.", "**Li** he dit la veritat."]}, {"title": "Les formes dels pronoms forts", "text": "Canvien segons la **persona** i el **nombre**. Només la 3a persona té masculí i femení. **Vosté** i **vostés** són formes de respecte: es dirigixen a qui escolta, però el verb va en 3a persona.", "table": {"head": ["persona", "singular", "plural"], "rows": [["1a", "*jo*, *mi*", "*nosaltres*"], ["2a", "*tu*", "*vosaltres*"], ["2a de respecte", "*vosté*", "*vostés*"], ["3a masculí", "*ell*", "*ells*"], ["3a femení", "*ella*", "*elles*"]]}, "examples": ["Què desitja **vosté**, senyora?"]}, {"title": "Jo o mi?", "text": "**Jo** és el subjecte. Darrere d'una preposició usem **mi**: *per a mi*, *amb mi*, *contra mi*. Però si la preposició va davant de dos elements units amb *i*, tornem a *jo*.", "examples": ["Vine amb **mi** al mercat.", "Entre tu i **jo** ho farem."], "watch": [{"wrong": "Este café és per a jo.", "right": "Este café és per a mi."}]}, {"title": "Febles davant del verb", "text": "Normalment el pronom feble va **davant** del verb, separat. Si el verb comença per vocal o *h*, alguns s'**apostrofen**. *Ens*, *us*, *els*, *les*, *li*, *ho* i *hi* no s'apostrofen mai.", "table": {"head": ["davant de consonant", "davant de vocal o h"], "rows": [["*em* veus", "*m'*ajudes"], ["*et* veig demà", "*t'*estime"], ["*el* compre", "*l'*agafe"], ["*la* mira", "*l'*escolta"], ["*en* vull tres", "*n'*he comprat"], ["*ens* agrada", "*ens* escolta"]]}, "examples": ["Tens pa? Sí, **en** tinc.", "A la platja? **Hi** cal anar demà."]}, {"title": "Febles darrere del verb", "text": "Amb **infinitiu**, **gerundi** i **imperatiu**, el feble va **darrere** i s'unix amb **guionet**. Si el verb acaba en vocal, alguns s'apostrofen: *compra'l*, *ajuda'm*, *mira'ns*. Amb *vull*, *vaig a*, *estic*... + infinitiu o gerundi, pots triar: davant o darrere.", "table": {"head": ["verb acabat en consonant", "verb acabat en vocal"], "rows": [["comprar-*lo*", "compra'*l*, vendre'*l*"], ["ajudar-*me*", "ajuda'*m*"], ["mirar-*nos*", "mira'*ns*"], ["mirar-*vos*", "veure-*vos*"], ["mirant-*la*, fer-*ho*", "pregunta-*li*"]]}, "examples": ["**El** vull comprar. = Vull comprar-**lo**."]}], "remember": ["Forts: *jo/mi*, *tu*, *vosté*, *ell*, *ella*, *nosaltres*, *vosaltres*, *vostés*, *ells*, *elles*.", "Darrere de preposició, *mi*: *per a mi*; però *entre tu i jo*.", "Febles davant del verb; darrere amb infinitiu, gerundi i imperatiu.", "*Ho* = això; *hi* = un lloc; *en* = una quantitat."], "sources": [{"gram": "GVB", "section": "25.1", "title": "Introducció", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=pronoms_personals"}, {"gram": "GVB", "section": "25.2", "title": "La forma dels pronoms personals forts", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=forma_pronoms_forts"}, {"gram": "GVB", "section": "25.3.1", "title": "L'oposició entre jo i mi", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=oposicio_jo_mi"}, {"gram": "GVB", "section": "25.3.2", "title": "Les formes de cortesia", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=formes_cortesia"}, {"gram": "GVB", "section": "26.1", "title": "Introducció", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=pronoms_febles"}, {"gram": "GVB", "section": "26.2", "title": "Les variacions morfològiques", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=pronoms_febles_variacions_morfologiques"}, {"gram": "GVB", "section": "26.3.1", "title": "Pronoms anteposats i posposats al verb", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=pronoms_anteposats_i_posposats"}, {"gram": "GVB", "section": "26.3.2", "title": "Formes plenes, reforçades, reduïdes i elidides", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=formes_plenes_elidides"}, {"gram": "GVB", "section": "27.3", "title": "El pronom neutre", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=pronom_neutre"}, {"gram": "GVB", "section": "27.4.1", "title": "El pronom ne", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=pronom_ne"}, {"gram": "GVB", "section": "27.4.2", "title": "El pronom hi", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=pronom_hi"}]}},
  {"type": "b1_mor_quantitatius_indefinits", "lesson": {"intro": "Aprendràs a expressar quantitats (*molt*, *massa*, *prou*, *un muntó de*...) i a usar els indefinits (*algú*, *tothom*, *qualsevol*, *res*, *cap*...).", "blocks": [{"title": "Quantitatius que canvien i que no", "text": "**Molt**, **poc**, **tant** i **quant** concorden amb el nom. **Massa**, **prou**, **gens**, **més** i **menys** no canvien mai. Davant d'un nom masculí singular, *molt*, *poc*, *tant* i *quant* solen portar **de**: *molt de soroll*.", "table": {"head": ["varien", "no varien"], "rows": [["*molt*, *molta*, *molts*, *moltes*", "*massa*"], ["*poc*, *poca*, *pocs*, *poques*", "*prou*"], ["*tant*, *tanta*, *tants*, *tantes*", "*gens*"], ["*quant*, *quanta*, *quants*, *quantes*", "*més*, *menys*"]]}, "examples": ["Hi havia **molta** gent a la festa."]}, {"title": "Quant, prou i massa", "text": "**Quant** pregunta per la quantitat o la destaca. **Prou** vol dir «suficient», tant com cal. **Massa** vol dir «més del que cal».", "examples": ["**Quantes** persones vindran?", "Ja has fet **prou** exercicis per hui.", "Hi ha **massa** soroll: no puc dormir."]}, {"title": "Locucions de quantitat", "text": "Per a dir **molt**: *bona cosa de*, *un muntó de*, *un fum de*, *un grapat de*. Per a dir **poc**: *una miqueta de*. Per a dir **gens**: *gens ni miqueta* (o *mica*) *de*. Són expressions vives, sobretot en la llengua parlada.", "examples": ["Hi havia **bona cosa de** gent al concert.", "Tinc **un muntó de** faena!", "No té **gens ni miqueta de** paciència."]}, {"title": "Indefinits", "text": "Alguns varien: *algun/alguna*, *altre/altra*, *diversos/diverses*. Uns altres no canvien de gènere: *diferents*, *qualsevol*, *tal*, *cada*. Per a persones: **algú** i **tothom** (verb en singular); per a coses: **alguna cosa**.", "table": {"head": ["indefinit", "exemple"], "rows": [["*diversos*", "He visitat *diversos* països."], ["*diferents*", "Hi ha *diferents* maneres."], ["*qualsevol*", "Vine *qualsevol* dia."], ["*tal*", "No he vist mai un *tal* desastre."], ["*cada*", "*Cada* dia vaig al gimnàs."], ["*un altre*", "Vull *un altre* café."]]}, "watch": [{"wrong": "Tothom han vingut.", "right": "Tothom ha vingut."}]}, {"title": "Res, ningú, cap i gens", "text": "En frases negatives, **res** vol dir «cap cosa» i **ningú**, «cap persona». **Cap** (o **ningun**) va amb noms que es compten; **gens de**, amb noms que no es compten. Si van darrere del verb, cal posar *no* davant.", "table": {"head": ["paraula", "per a", "exemple"], "rows": [["*res*", "coses", "No vol *res*."], ["*ningú*", "persones", "No ha vingut *ningú*."], ["*cap* / *ningun*", "es compta", "No tinc *cap* ordinador."], ["*gens de*", "no es compta", "No queda *gens de* vi."]]}, "examples": ["No m'agrada **gens** el futbol."]}], "remember": ["*Massa*, *prou* i *gens* no canvien mai de forma.", "*Prou* = suficient; *massa* = més del que cal.", "*Tothom* va amb el verb en singular: *tothom ha vingut*.", "*Res* (coses), *ningú* (persones), *cap* (es compta), *gens* (no es compta)."], "sources": [{"gram": "GVB", "section": "23.1", "title": "Introducció", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=quantitatius"}, {"gram": "GVB", "section": "23.2", "title": "Variació morfològica", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=aspectes_formals_sintactics"}, {"gram": "GVB", "section": "23.3", "title": "Aspectes formals i sintàctics", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=quantitatius"}, {"gram": "GVB", "section": "23.4.3", "title": "Gens", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=quantitatiu_gens"}, {"gram": "GVB", "section": "23.4.4", "title": "Massa", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=quantitatiu_massa"}, {"gram": "GVB", "section": "23.4.5", "title": "Quant", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=quantitatiu_quant"}, {"gram": "GVB", "section": "23.4.7", "title": "Prou", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=quantitatiu_prou"}, {"gram": "GVB", "section": "23.5", "title": "Locucions quantitatives", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=locucions_quantitatives"}, {"gram": "GVB", "section": "24.2.1", "title": "Caracterització general", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=indefinits_quantificadors_nominals"}, {"gram": "GVB", "section": "24.2.3", "title": "Cada i cadascun", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=indefinits_cada_cadascun"}, {"gram": "GVB", "section": "24.2.6", "title": "Qualsevol", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=indefinit_qualsevol"}, {"gram": "GVB", "section": "24.2.8", "title": "Algun", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=indefinit_algun"}, {"gram": "GVB", "section": "24.2.10", "title": "Altre", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=indefinit_altre"}, {"gram": "GVB", "section": "24.2.11", "title": "Diversos", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=indefinit_diversos"}, {"gram": "GVB", "section": "24.2.13", "title": "Tal", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=indefinit_tal"}, {"gram": "GVB", "section": "24.2.14", "title": "Cap", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=indefinits_negatius"}, {"gram": "GVB", "section": "24.3.1", "title": "U, algú, cadascú i cada u", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=indefinits_u_algu_cadascu_cada_u"}, {"gram": "GVB", "section": "24.3.2", "title": "Ningú", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=indefinit_ningu"}, {"gram": "GVB", "section": "24.3.4", "title": "Tots i tothom", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=indefinits_tots_tothom"}, {"gram": "GVB", "section": "24.3.6", "title": "Res", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=indefinit_res"}, {"gram": "GVB", "section": "24.3.7", "title": "Quelcom", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=indefinit_quelcom"}, {"gram": "GVB", "section": "37.2.3", "title": "Gens", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=adverbi_gens"}, {"gram": "GVB", "section": "37.2.5", "title": "Prou", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=adverbi_prou"}, {"gram": "GVB", "section": "38.2.4", "title": "Les paraules negatives", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=usos_paraules_negatives"}, {"gram": "GNV", "section": "19.2.3", "title": "Els indefinits negatius", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=indefinits_negatius"}]}},
  {"type": "b1_mor_regim", "lesson": {"intro": "Molts verbs porten una preposició fixa davant del complement. Aprendràs les més habituals i quan desapareix la preposició.", "blocks": [{"title": "Verbs amb preposició fixa", "text": "Alguns verbs porten sempre una **preposició** davant del complement: aprén-la amb el verb, com si en fóra part. La mantens davant d'un nom i davant d'un **infinitiu**: *s'ha acostumat a la bona vida* i *s'ha acostumat a matinar*.", "table": {"head": ["amb *a*", "amb *en*", "amb *de*"], "rows": [["*atrevir-se a*", "*pensar en*", "*oblidar-se de*"], ["*començar a*", "*confiar en*", "*adonar-se de*"], ["*decidir-se a*", "*insistir en*", "*dependre de*"], ["*negar-se a*", "*fixar-se en*", "*queixar-se de*"], ["*dedicar-se a*", "*coincidir en*", "*tindre ganes de*"]]}, "examples": ["No m'atrevisc **a** dir-li-ho.", "Pense molt **en** tu.", "M'he oblidat **de** les claus."]}, {"title": "*A* davant d'infinitiu", "text": "Amb un **infinitiu** darrere, molts verbs porten *a*: *ajudar a*, *aprendre a*, *convidar a*, *obligar a*, *consistir a*. Alguns canvien de preposició: *tardar en* una cosa, però *tardar a* fer-la. *Confiar* i *insistir* + infinitiu admeten *a* o *en*.", "examples": ["M'ha ajudat **a** fer la mudança.", "Ha tardat molt **a** arribar.", "Insistix **a** (o **en**) pagar ell."]}, {"title": "Davant de *que*, la preposició cau", "text": "Quan el complement és una oració que comença per *que*, les preposicions *a*, *de*, *en* i *amb* **desapareixen**: *m'he adonat de l'error*, però *m'he adonat que m'he equivocat*.", "examples": ["Confie **que** tot eixirà bé."], "watch": [{"wrong": "Estic segur de que vindrà.", "right": "Estic segur que vindrà."}, {"wrong": "Insistix en que vingues.", "right": "Insistix que vingues."}]}, {"title": "*Recordar* i *pensar*", "text": "*Recordar* va **sense preposició**: *recorde el seu nom*. La forma *recordar-se*, en canvi, porta *de*: *no me'n recorde*. *Pensar en* és tindre algú o alguna cosa al cap; per a dir el que creus, *pensar que*.", "examples": ["No **recorde** el seu nom.", "Pense **que** vindrà demà."]}], "remember": ["Aprén cada verb amb la seua preposició: *pensar en*, *atrevir-se a*.", "La preposició es manté davant d'un nom i d'un infinitiu.", "Davant de *que*, la preposició cau: *m'he adonat que...*", "*Tardar a* + infinitiu; *confiar* i *insistir*: *a* o *en*."], "sources": [{"gram": "GVB", "section": "17.8", "title": "El nombre com a marca semàntica", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=nombre_marca_semantica"}, {"gram": "GVB", "section": "27.4.1", "title": "El pronom ne", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=pronom_ne"}, {"gram": "GVB", "section": "30.3", "title": "A", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=preposicions_atones"}, {"gram": "GVB", "section": "30.5", "title": "De", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=preposicio_de"}, {"gram": "GVB", "section": "33.1", "title": "El canvi de preposicions àtones", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=canvi_caiguda_preposicions"}, {"gram": "GVB", "section": "33.2", "title": "L'elisió de preposicions àtones", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=elisio_preposicions"}, {"gram": "GVB", "section": "34.5.21", "title": "A pols", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=locucio_adverbial_en_sopols"}, {"gram": "GVB", "section": "40.2.5", "title": "Començar a + infinitiu", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=perifrasi_comencar_a_infinitiu"}, {"gram": "GVB", "section": "41.4.1", "title": "Les conjuncions completives", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=conjuncions_completives"}, {"gram": "GNV", "section": "8.5.1", "title": "El predicat i els complements", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=predicat_i_complements"}, {"gram": "GNV", "section": "26.3", "title": "Usos i funcions de les preposicions febles", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=26_3"}, {"gram": "GNV", "section": "26.3.5", "title": "L'elisió i el canvi de preposicions àtones", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=elisio_canvi_preposicions"}, {"gram": "GNV", "section": "32.4", "title": "El complement de règim", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=complement_de_regim"}]}},
  {"type": "b1_mor_substantius", "lesson": {"intro": "Aprendràs a formar el femení i el plural dels noms, amb els canvis d'accent i de lletres que cal fer per a escriure'ls bé.", "blocks": [{"title": "El femení: -a i -na", "text": "Normalment el femení **afig una *-a***: *nebot* → *neboda*. Si el masculí acaba en ***-i* àtona**, afig *-a* i **porta accent**: *secretari* → *secretària*. Si acaba en **vocal tònica**, afig ***-na***: *cosí* → *cosina*.", "table": {"head": ["masculí", "femení"], "rows": [["*secretari*", "*secret**à**ria*"], ["*funcionari*", "*funcion**à**ria*"], ["*veterinari*", "*veterin**à**ria*"], ["*campió*", "*campio**na***"], ["*veí*", "*veï**na***"], ["*nebot*", "*nebo**da***"]]}}, {"title": "Femenins especials i invariables", "text": "Alguns noms fan el femení amb **sufixos especials** (*-essa*, *-ina*, *-iu*) o amb **una paraula diferent**. Altres són **invariables**: tenen la mateixa forma i només canvia l'article: *el cantaire* / *la cantaire*, *el guia* / *la guia*.", "table": {"head": ["masculí", "femení"], "rows": [["*metge*, *jutge*, *poeta*", "*metg**essa***, *jutg**essa***, *poet**essa***"], ["*actor*", "*actr**iu***"], ["*gall*", "*gall**ina***"], ["*cavall*", "***egua***"], ["*bou*", "***vaca***"], ["*gendre*", "***nora***"]]}, "examples": ["**La** testimoni ha declarat davant del jutge.", "**La** cantaire del grup és la meua cosina."]}, {"title": "Plural en -es: canvis gràfics", "text": "Els noms en ***-a* àtona** fan el plural en ***-es***. Per a mantindre el so, **canvia la lletra d'abans**: *-ga* → *-gues*, *-ça* → *-ces*, *-ja* → *-ges*, *-gua* → *-gües*, *-qua* → *-qües*.", "table": {"head": ["singular", "plural"], "rows": [["*amiga*", "*ami**gues***"], ["*plaça*", "*pla**ces***"], ["*platja*", "*plat**ges***"], ["*llengua*", "*llen**gües***"], ["*aigua*", "*ai**gües***"], ["*Pasqua*", "*Pas**qües***"]]}}, {"title": "Plural en -ns i accents", "text": "Els noms acabats en **vocal tònica** fan el plural en ***-ns***: *camió* → *camions*, *mà* → *mans*, *pa* → *pans*. En plural, **l'accent pot canviar**: *examen* → *exàmens* (guanya accent), *país* → *països* (perd l'accent i porta dièresi).", "examples": ["Han aparcat dos **camions** davant de casa.", "Demà tinc tres **exàmens**.", "Hem visitat molts **països** d'Europa."]}, {"title": "Plural en -os i invariables", "text": "Els masculins en ***-s*, *-ç*, *-x*, *-ix*, *-tx*** afigen ***-os***: *pis* → *pisos*, *braç* → *braços*, *peix* → *peixos*, *despatx* → *despatxos*. En ***-sc*, *-st*, *-xt***, *-os* o *-s*: *boscos* o *boscs*, *textos* o *texts*. Els **dies de la setmana** i *llapis* no canvien.", "examples": ["Treballem en dos **despatxos** diferents.", "**Els dilluns** vaig al gimnàs."], "watch": [{"wrong": "els llàpissos", "right": "els llapis"}, {"wrong": "els dillunsos", "right": "els dilluns"}]}], "remember": ["Femení: normalment *-a*; en vocal tònica, *-na* (*cosina*, *campiona*).", "*Secretari* → *secretària*: en femení i plural l'accent pot canviar.", "*Llengua*, *llengües*; *platja*, *platges*: canvia la lletra, no el so.", "Masculins en *-s*, *-ç*, *-ix*, *-tx* fan *-os*; *dilluns* i *llapis* no canvien."], "sources": [{"gram": "GVB", "section": "7.2", "title": "Regles generals d'accentuació", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=regles_generals_accentuacio"}, {"gram": "GVB", "section": "8.2", "title": "Estalvi en l'ús de la dièresi", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=estalvi_dieresi"}, {"gram": "GVB", "section": "16.1", "title": "Introducció", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=substantius_formacio_femeni"}, {"gram": "GVB", "section": "16.2.1", "title": "El femení dels masculins acabats en consonant", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=femeni_a_partir_masculins_acabats_en_consonant"}, {"gram": "GVB", "section": "16.2.2", "title": "El femení dels masculins acabats en vocal", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=femeni_a_partir_masculins_acabats_en_vocal"}, {"gram": "GVB", "section": "16.2.3", "title": "Altres casos", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=altres_casos_formacio_femeni"}, {"gram": "GVB", "section": "17.2", "title": "La formació del plural", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=formacio_plural"}, {"gram": "GVB", "section": "17.3", "title": "Substantius invariables", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=substantius_invariables"}, {"gram": "GNV", "section": "11.2", "title": "La formació del plural", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=formacio_plural"}, {"gram": "GNV", "section": "11.3", "title": "Substantius invariables", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=substantius_invariables"}]}},
  {"type": "b1_mor_verbs_irregulars", "lesson": {"intro": "Coneixeràs les formes clau dels verbs irregulars més usats (ser, fer, anar, tindre, poder...) per a parlar amb soltesa del dia a dia.", "blocks": [{"title": "Jo en -c, subjuntiu en -ga", "text": "Molts verbs irregulars fan la persona *jo* del present en **-c** i el present de subjuntiu en **-ga**, **-gues**... El participi sovint també porta **-gut**. *Voler* fa *vull*, però també *vullga* i *volgut*.", "table": {"head": ["verb", "present", "subjuntiu", "participi"], "rows": [["*tindre*", "*tinc*, *tens*", "*tinga*, *tingues*", "*tingut*"], ["*poder*", "*puc*, *pots*", "*puga*, *pugues*", "*pogut*"], ["*voler*", "*vull*, *vols*", "*vullga*, *vullgues*", "*volgut*"], ["*estar*", "*estic*, *estàs*", "*estiga*, *estigues*", "*estat*"], ["*dir*", "*dic*, *dius*", "*diga*, *digues*", "*dit*"], ["*conéixer*", "*conec*, *coneix*", "*conega*, *conegues*", "*conegut*"]]}, "examples": ["Com et **dius**? —Em **dic** Marta.", "Jo no **conec** ningú ací, però **tinc** dos amics a Alzira.", "Fes el que **vullgues**."]}, {"title": "Ser, saber, fer, anar, vore", "text": "Són els més irregulars: aprén les formes clau de memòria. *Fer* fa *faig* (també *faç*), però en subjuntiu només *faça*, *faces*. *Anar* fa *anem*, *aneu* també en subjuntiu. *Vore* també s'escriu *veure*.", "table": {"head": ["verb", "present", "subjuntiu", "participi"], "rows": [["*ser*", "*soc*, *som*, *sou*", "*siga*, *sigues*", "*sigut*"], ["*saber*", "*sé*, *saps*", "*sàpia*, *sàpies*", "*sabut*"], ["*fer*", "*faig*", "*faça*, *faces*", "*fet*"], ["*anar*", "*vaig*, *anem*", "*vaja*, *vages*", "*anat*"], ["*veure* (*vore*)", "*veig*, *veu*", "*veja*, *veges*", "*vist*"], ["*nàixer*", "*nasc*, *naix*", "*nasca*", "*nascut*"]]}, "examples": ["Nosaltres **som** de València.", "Vull que **vages** al metge.", "Demà **vorem** (o **veurem**) la pel·lícula."]}, {"title": "Obrir, omplir, tossir i córrer", "text": "*Obrir* i *omplir* fan *jo* en **-c** i el subjuntiu en **-ga**. En la persona *ell*, *obrir*, *omplir* i *córrer* afigen una vocal: *obri*, *ompli*, *corre*. *Tossir* canvia la vocal: *tus*, però *tossim*.", "table": {"head": ["verb", "formes clau"], "rows": [["*obrir*", "*òbric*, *obri*, *òbriga*; participi *obert*"], ["*omplir*", "*òmplic*, *ompli*, *òmpliga*; participi *omplit*"], ["*tossir*", "*tus*, *tossim*"], ["*córrer*", "*corre*; negatiu: *no córregues*"]]}, "examples": ["Ell **ompli** el got d'aigua.", "El meu pare **tus** molt a la nit."]}, {"title": "Passats de fer, ser i vore", "text": "El passat perifràstic sempre és regular: *vaig* + infinitiu (*vaig nàixer*, *vaig fer*). En canvi, *fer*, *ser* i *vore* tenen formes especials en el **passat simple** i en l'**imperfet de subjuntiu**.", "table": {"head": ["verb", "passat simple", "imperfet de subjuntiu"], "rows": [["*fer*", "*fiu*, *feres*, *feu*", "*fera*, *feres*, *fera*"], ["*ser*", "*fui*, *fores*, *fou*", "*fora*, *fores*, *fora*"], ["*veure* (*vore*)", "*viu*, *veres*, *veu*", "*vera*, *veres*"]]}, "examples": ["Jo **vaig nàixer** a Gandia.", "Aquell dia **fou** inoblidable.", "Si **fora** ric, viatjaria per tot el món."]}], "remember": ["Jo: *tinc*, *puc*, *vull*, *estic*, *dic*, *conec*, *faig*, *vaig*, *veig*.", "Subjuntiu: *tinga*, *puga*, *vullga*, *siga*, *sàpia*, *faça*, *vaja*, *veja*.", "Participis: *tingut*, *pogut*, *volgut*, *conegut*, *nascut*, *vist*, *fet*, *obert*.", "Passat perifràstic, sempre regular: *vaig nàixer*, *vaig fer*, *vaig ser*."], "sources": [{"gram": "GVB", "section": "39.3.2", "title": "Els verbs regulars i els verbs irregulars", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=verbs_regulars_irregulars"}, {"gram": "GNV", "section": "29.5", "title": "Precisions sobre el polimorfisme verbal", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=polimorfisme_verbal"}, {"gram": "GNV", "section": "30.1", "title": "Conceptes generals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=verbs_irregulars"}, {"gram": "GNV", "section": "30.2.1", "title": "Verbs amb alternances vocàliques en el radical", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=irregularitats_morfologiques"}, {"gram": "GNV", "section": "30.2.2", "title": "Verbs amb alternances consonàntiques al final del radical", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=irregularitats_morfologiques"}, {"gram": "GNV", "section": "30.2.3", "title": "Tendència a la generalització de formes velaritzades", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=irregularitats_morfologiques"}, {"gram": "GNV", "section": "30.2.4.3", "title": "Verbs amb passat simple i imperfet de subjuntiu forts", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=irregularitats_morfologiques"}, {"gram": "GNV", "section": "30.2.4.4", "title": "Els participis forts", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=participis_forts"}, {"gram": "GNV", "section": "30.3", "title": "Els principals verbs irregulars", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=verbs_irregulars"}]}},
  {"type": "b1_mor_verbs_regulars", "lesson": {"intro": "Aprendràs a conjugar els verbs regulars en els temps que més uses per a parlar del present, del passat, del futur i dels desitjos.", "blocks": [{"title": "El present: tres conjugacions", "text": "Hi ha tres conjugacions: verbs en *-ar* (*cantar*), en *-re* o *-er* (*batre*, *témer*) i en *-ir*. Els verbs en *-ir* són purs (*sentir*, *dormir*) o **incoatius**, amb *-isc*/*-ix* (*servir*, *patir*). En la llengua escrita també tens *serveixes*, *serveix*, *serveixen*.", "table": {"head": ["cantar", "batre", "sentir", "servir"], "rows": [["*cante*", "*bat*", "*sent*", "*servisc*"], ["*cantes*", "*bats*", "*sents*", "*servixes*"], ["*canta*", "*bat*", "*sent*", "*servix*"], ["*cantem*", "*batem*", "*sentim*", "*servim*"], ["*canteu*", "*bateu*", "*sentiu*", "*serviu*"], ["*canten*", "*baten*", "*senten*", "*servixen*"]]}, "examples": ["Jo **treballe** en una botiga i **dorm** poc.", "Ells **mengen** molta fruita (davant de *e*, la *j* passa a *g*).", "Ell **llig** molt bé, i nosaltres també **llegim** molt."]}, {"title": "Passat simple i perifràstic", "text": "Per a fets d'**abans de hui** (*ahir*, *l'any passat*) tens dues formes amb el mateix valor: el passat perifràstic (*vaig* + infinitiu) i el passat simple. En el perifràstic també pots dir *vares*, *vàrem*, *vàreu*, *varen*.", "table": {"head": ["perifràstic", "simple: cantar", "simple: batre", "simple: sentir"], "rows": [["*vaig cantar*", "*cantí*", "*batí*", "*sentí*"], ["*vas cantar*", "*cantares*", "*bateres*", "*sentires*"], ["*va cantar*", "*cantà*", "*baté*", "*sentí*"], ["*vam cantar*", "*cantàrem*", "*batérem*", "*sentírem*"], ["*vau cantar*", "*cantàreu*", "*batéreu*", "*sentíreu*"], ["*van cantar*", "*cantaren*", "*bateren*", "*sentiren*"]]}, "examples": ["L'any passat **vam viatjar** (o **viatjàrem**) a Roma."], "watch": [{"wrong": "Ahir he treballat molt.", "right": "Ahir vaig treballar molt."}]}, {"title": "Perfet, plusquamperfet i imperfet", "text": "El **perfet** (*he* + participi) parla de hui o d'un període que encara dura (*enguany*). El **plusquamperfet** (*havia* + participi) va abans d'un altre fet passat. Participis: *cantat*, *batut*, *temut*, *sentit*. Gerundis: *cantant*, *batent*, *sentint*.", "table": {"head": ["perfet", "plusquamperfet", "imperfet"], "rows": [["*he cantat*", "*havia cantat*", "*cantava*"], ["*has cantat*", "*havies cantat*", "*cantaves*"], ["*ha cantat*", "*havia cantat*", "*cantava*"], ["*hem cantat*", "*havíem cantat*", "*cantàvem*"], ["*heu cantat*", "*havíeu cantat*", "*cantàveu*"], ["*han cantat*", "*havien cantat*", "*cantaven*"]]}, "examples": ["Enguany **hem llegit** molts llibres.", "Quan vaig arribar, el tren ja **havia eixit**.", "De xicotet **jugava** a futbol cada dia (imperfet: costum del passat)."]}, {"title": "Futur i condicional", "text": "El **futur** parla del que vindrà (*demà*, *l'any que ve*). El **condicional** diu el que passaria en una altra situació o fa una petició cortesa (*Em podries ajudar?*). Les terminacions són les mateixes en les tres conjugacions.", "table": {"head": ["futur: cantar", "condicional: cantar", "futur: batre", "condicional: batre"], "rows": [["*cantaré*", "*cantaria*", "*batré*", "*batria*"], ["*cantaràs*", "*cantaries*", "*batràs*", "*batries*"], ["*cantarà*", "*cantaria*", "*batrà*", "*batria*"], ["*cantarem*", "*cantaríem*", "*batrem*", "*batríem*"], ["*cantareu*", "*cantaríeu*", "*batreu*", "*batríeu*"], ["*cantaran*", "*cantarien*", "*batran*", "*batrien*"]]}, "examples": ["L'any que ve **estudiaré** a la universitat.", "Si guanyara més diners, **compraria** una casa al camp."]}, {"title": "Subjuntiu: present i imperfet", "text": "El subjuntiu va sobretot després de *que* o de *si* (desitjos, dubtes, condicions). L'imperfet més general en valencià acaba en *-ra* (*cantara*); també és correcte en *-s* (*cantàs* o *cantés*). Els incoatius fan *servisca*, *servisques*...", "table": {"head": ["present: cantar", "imperfet: cantar", "present: sentir", "imperfet: sentir"], "rows": [["*cante*", "*cantara*", "*senta*", "*sentira*"], ["*cantes*", "*cantares*", "*sentes*", "*sentires*"], ["*cante*", "*cantara*", "*senta*", "*sentira*"], ["*cantem*", "*cantàrem*", "*sentim*", "*sentírem*"], ["*canteu*", "*cantàreu*", "*sentiu*", "*sentíreu*"], ["*canten*", "*cantaren*", "*senten*", "*sentiren*"]]}, "examples": ["Vull que **arribes** prompte.", "Si **estudiares** més, aprovaries."]}], "remember": ["Jo: *cante*, però *bat*, *sent* i *servisc*.", "Ahir: *vaig cantar* o *cantí*. Hui: *he cantat*.", "Futur *cantaré*, condicional *cantaria*: mateixes terminacions en tots els verbs.", "Imperfet de subjuntiu en *-ra*: *cantara*, *cantares*, *cantàrem*."], "sources": [{"gram": "GVB", "section": "39.3.1", "title": "Les tres conjugacions", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=conjugacions"}, {"gram": "GVB", "section": "39.3.2", "title": "Els verbs regulars i els verbs irregulars", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=verbs_regulars_irregulars"}, {"gram": "GNV", "section": "28.4.1", "title": "Els temps verbals d'indicatiu", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=indicatiu"}, {"gram": "GNV", "section": "28.4.2", "title": "Els temps verbals de subjuntiu", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=subjuntiu"}, {"gram": "GNV", "section": "29.3.1", "title": "Les tres conjugacions", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=conjugacions"}, {"gram": "GNV", "section": "29.3.2", "title": "Els verbs incoatius i els purs de la tercera conjugació", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=verbs_incoatius_purs"}, {"gram": "GNV", "section": "29.4.1", "title": "Model del verb cantar", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=verbs_regulars"}, {"gram": "GNV", "section": "29.4.2", "title": "Model del verb batre", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=verbs_regulars"}, {"gram": "GNV", "section": "29.4.3", "title": "Model del verb servir", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=verbs_regulars"}, {"gram": "GNV", "section": "29.4.4", "title": "Model del verb sentir", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=verbs_regulars"}, {"gram": "GNV", "section": "29.5", "title": "Precisions sobre el polimorfisme verbal", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=polimorfisme_verbal"}, {"gram": "GNV", "section": "30.1", "title": "Conceptes generals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=verbs_irregulars"}, {"gram": "GNV", "section": "30.2.1", "title": "Verbs amb alternances vocàliques en el radical", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=irregularitats_morfologiques"}]}}
]$data$::jsonb) AS l(type text, lesson jsonb)
WHERE r.category = 'morfosintaxi' AND r.type = l.type;

-- ============================================================
-- Origen: 20261001170000_correccio_exercicis_avl.sql
-- ============================================================
-- Correcció dels exercicis B1 de Morfosintaxi que contradeien les gramàtiques de
-- l'AVL (GVB i GNV, en assets-src/avl/), detectats en redactar les lliçons fixes
-- («Aprendre lliçó»): respostes incorrectes i distractors que l'AVL accepta com a
-- correctes. Cada fila substituïx l'enunciat, les opcions, les respostes i
-- l'explicació de l'exercici (recurs, nivell, posició). La resposta correcta va
-- primer, com en la resta d'exercicis. Tornar a aplicar el fitxer no canvia res més.

UPDATE public.practice_exercises e SET
  prompt = f.prompt,
  options = ARRAY(SELECT jsonb_array_elements_text(f.options)),
  answers = ARRAY(SELECT jsonb_array_elements_text(f.answers)),
  explanation = f.explanation
FROM jsonb_to_recordset($data$[
  {"type": "b1_mor_pronoms_cd_ci", "pos": 24,
   "prompt": "«Porta'ns la cadira.» → «Porta___!»",
   "options": ["'ns-la", "-nos-la", "-la-nos"], "answers": ["'ns-la"],
   "explanation": "Darrere d'un verb acabat en vocal, nos es reduïx a 'ns: Porta'ns-la (GVB 26.4.2). La forma -nos-la va darrere de consonant: portar-nos-la."},
  {"type": "b1_mor_quantitatius_indefinits", "pos": 9,
   "prompt": "«Només ha collit ___ d'olives.» (poca quantitat)",
   "options": ["una miqueta", "un fum", "un muntó"], "answers": ["una miqueta"],
   "explanation": "Una miqueta de indica poca quantitat. Un fum de, un muntó de i un grapat de indiquen molta quantitat (GVB 23.5)."},
  {"type": "b1_mor_adverbis", "pos": 13,
   "prompt": "Quina és correcta?",
   "options": ["Parlava tranquil·lament i lentament.", "Parlava lenta i tranquil·lament.", "Parlava lenta i tranquil·la."], "answers": ["Parlava tranquil·lament i lentament."],
   "explanation": "Quan es coordinen adverbis en -ment, es pot llevar la terminació del segon (tranquil·lament i lenta), mai del primer; i hui és més habitual mantindre-la en tots dos (GVB 34.2)."},
  {"type": "b1_mor_numerals", "pos": 10,
   "prompt": "«Tinc ___ germanes.» (2, forma femenina)",
   "options": ["dues", "dós", "dúes"], "answers": ["dues"],
   "explanation": "El femení de dos és dues, especialment en registres formals (també s'admet dos germanes). Cap de les dues formes porta accent (GVB 22.2.4)."},
  {"type": "b1_mor_preposicions", "pos": 19,
   "prompt": "«Ara estic ___ casa.»",
   "options": ["a (o en)", "dins", "de"], "answers": ["a (o en)"],
   "explanation": "Per a dir on estàs, davant de casa sense article l'AVL usa en (m'haguera quedat en casa, GVB 15.4), i també és molt habitual a. Amb moviment, a: Torne a casa."},
  {"type": "b1_mor_preposicions", "pos": 20,
   "prompt": "«Els alumnes estan ___ classe.»",
   "options": ["a (o en)", "de", "per"], "answers": ["a (o en)"],
   "explanation": "Davant d'un nom sense article que indica on és algú, s'usa en o a: estan en classe / a classe. Amb moviment, a: Vaig a classe."},
  {"type": "b1_mor_preposicions", "pos": 22,
   "prompt": "Quina és correcta?",
   "options": ["Conec la teua germana des de fa anys.", "Conec a la teua germana des de fa anys.", "Conec de la teua germana des de fa anys."], "answers": ["Conec la teua germana des de fa anys."],
   "explanation": "El complement directe va sense preposició, encara que siga una persona: Conec la teua germana. Davant d'un nom propi sense article, la a és opcional: Conec (a) Marta (GNV 32.2)."},
  {"type": "b1_mor_regim", "pos": 19,
   "prompt": "«El joc consistix ___ endevinar la paraula.»",
   "options": ["a", "de", "per"], "answers": ["a"],
   "explanation": "Consistir davant d'infinitiu porta a: La prova consistix a alçar un sac de ciment (GVB 34.5.21)."},
  {"type": "b1_mor_regim", "pos": 28,
   "prompt": "«Està interessat ___ la feina.»",
   "options": ["per (o en)", "a", "de"], "answers": ["per (o en)"],
   "explanation": "Interessar-se i estar interessat porten per (persones interessades per la llengua, GVB 13.3.5); també és habitual en."},
  {"type": "b1_mor_substantius", "pos": 33,
   "prompt": "Quin és un plural correcte de «bosc»?",
   "options": ["boscos", "bosques", "bosquis"], "answers": ["boscos"],
   "explanation": "Els noms acabats en -sc fan el plural en -os o en -s: boscos o boscs; totes dues formes són correctes (GVB 17.2)."},
  {"type": "b1_mor_verbs_irregulars", "pos": 22,
   "prompt": "«Ahir ell ___ els deures.» (fer, passat simple)",
   "options": ["feu", "fiu", "fa"], "answers": ["feu"],
   "explanation": "Passat simple de fer: fiu, feres, feu, férem, féreu, feren (GNV 30.2.4.3). En la parla és més habitual el perifràstic: va fer."}
]$data$::jsonb) AS f(type text, pos smallint, prompt text, options jsonb, answers jsonb, explanation text)
WHERE e.level = 'B1'
  AND e.position = f.pos
  AND e.resource_id = (SELECT r.id FROM public.resources r WHERE r.category = 'morfosintaxi' AND r.type = f.type);

-- ============================================================
-- Origen: 20261001180000_llicons_fonetica_b1.sql
-- ============================================================
-- Lliçons fixes de Fonètica, elocució i ortografia del B1 (botó «Aprendre lliçó»).
-- Com les de Morfosintaxi (20261001160000), cada lliçó és una adaptació didàctica
-- de nivell B1 redactada a partir de:
--   - l'abast del Quadern de nivell B1 de la JQCV (2024), apartat 3.2.1;
--   - les regles d'Ortologia i Ortografia de la GVB i la GNV de l'AVL, descarregades
--     una sola vegada en assets-src/avl/.
-- El contingut es guarda en metadata.lesson (mateix format). La migració de
-- continguts (20261001130000) conserva metadata.lesson si es torna a aplicar.
-- Tornar a aplicar este fitxer no canvia res més.

UPDATE public.resources r SET
  metadata = coalesce(r.metadata, '{}'::jsonb) || jsonb_build_object('lesson', l.lesson)
FROM jsonb_to_recordset($data$[
  {"type": "b1_fon_accentuacio", "lesson": {"intro": "Aprendràs quines paraules porten accent i quin accent toca, i quan has d'usar la dièresi i el guionet.", "blocks": [{"title": "Agudes, planes i esdrúixoles", "text": "Les **agudes** (força en l'última síl·laba) porten accent si acaben en vocal, vocal + *s*, *-en* o *-in*. Les **planes** (en la penúltima), al revés: si **no** acaben així. Les **esdrúixoles**, **sempre**. La *u* o *i* final de *-eu*, *-ai*, *-ou* no compta com a vocal.", "table": {"head": ["", "amb accent", "sense accent"], "rows": [["aguda", "*camió*, *anglés*, *entén*", "*Ramon*, *camins*, *fareu*"], ["plana", "*plàstic*, *exàmens*, *féreu*", "*fenomen*, *examen*, *casa*"], ["esdrúixola", "*fàbrica*, *justícia*, *música*", "—"]]}, "watch": [{"wrong": "Ramón ha aprovat l'exámen.", "right": "Ramon ha aprovat l'examen."}]}, {"title": "Accent obert o tancat", "text": "L'accent **greu** (`) va sobre vocal oberta: *à*, *è*, *ò*. L'**agut** (´), sobre vocal tancada: *í*, *ú*, *é*, *ó*. En valencià escrivim *é* tancada en *anglés*, *café*, *conéixer* (també és correcte *anglès*, *cafè*). Els adverbis en *-ment* porten accent si l'adjectiu en porta.", "examples": ["Hem pres un **café** amb el meu **cosí**.", "És una **història** molt **còmica**.", "Ho ha resolt **fàcilment**: era **fàcil**."]}, {"title": "Monosíl·labs i accent diacrític", "text": "Les paraules d'una síl·laba normalment **no porten accent**: *pa*, *sol*, *mes*. Unes poques en porten per a **distingir el significat**: és l'**accent diacrític**.", "table": {"head": ["amb accent", "sense accent"], "rows": [["*té* (verb tindre)", "*te* (pronom; beguda)"], ["*és* (verb ser)", "*es* (pronom)"], ["*més* (quantitat)", "*mes* (de l'any)"], ["*sí* (afirmació)", "*si* (condició)"], ["*sé* (verb saber)", "*se* (pronom)"], ["*bé* (adverbi)", "*be* (corder; lletra)"]]}, "examples": ["**Mon** pare ha viatjat per tot el **món**.", "**Ma** germana m'ha donat la **mà**.", "Passa **pel** parc amb el gos de **pèl** blanc."]}, {"title": "La dièresi (¨)", "text": "La dièresi va sobre la *i* o la *u*. Fa sonar la *u* en *güe*, *güi*, *qüe*, *qüi*: *aigües*, *pingüí*, *qüestió*. I indica que la *i* o la *u* no fa diftong amb la vocal anterior: *veïna*, *raïm*.", "table": {"head": ["sense dièresi", "per què"], "rows": [["*país*", "ja porta accent (*país*)"], ["*egoisme*, *europeista*", "acaba en *-isme*, *-ista*"], ["*traduir*, *traduint*", "infinitiu, gerundi, futur i condicional"], ["*reunió*", "prefix + *i* o *u*"]]}}, {"title": "El guionet (-)", "text": "El guionet unix el **pronom darrere del verb** (*dona-li*, *fes-ho*), les desenes i les unitats dels **numerals** (*vint-i-cinc*), els compostos amb **punt cardinal** (*nord-americà*) i alguns compostos amb el segon element en *r*, *s*, *x* (*para-sol*). Els **prefixos** i quasi tots els compostos van junts.", "table": {"head": ["amb guionet", "sense guionet"], "rows": [["*quaranta-cinc*", "*paraigua*"], ["*dos-cents trenta*", "*expresident*"], ["*sud-americà*", "*vicepresident*"], ["*gira-sol*", "*coliflor*"]]}}], "remember": ["Les esdrúixoles sempre porten accent; agudes i planes, segons com acaben.", "En valencià escrivim *anglés*, *café*, *conéixer*, amb accent tancat.", "*Té*, *és*, *més*, *sí*, *sé*, *bé*: l'accent canvia el significat.", "Prefixos i quasi tots els compostos, sense guionet: *expresident*, *paraigua*."], "sources": [{"gram": "GVB", "section": "6.13", "title": "Les grafies s i ss", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=representacio_so_s"}, {"gram": "GVB", "section": "7.1", "title": "Introducció", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=accent_grafic"}, {"gram": "GVB", "section": "7.2", "title": "Regles generals d'accentuació", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=regles_generals_accentuacio"}, {"gram": "GVB", "section": "7.3", "title": "L'accentuació de les vocals e i o", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=accentuacio_e_o"}, {"gram": "GVB", "section": "7.4", "title": "Observacions sobre l'accentuació de la vocal e", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=accent_grafic"}, {"gram": "GVB", "section": "7.6", "title": "L'accentuació de monosíl·labs", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=accentuacio_monosillabs"}, {"gram": "GVB", "section": "7.7", "title": "L'accentuació diacrítica", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=accentuacio_diacritica"}, {"gram": "GVB", "section": "7.9", "title": "L'accentuació d'adverbis en ‑ment", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=accentuacio_adverbis_ment"}, {"gram": "GVB", "section": "8.1", "title": "Usos de la dièresi", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=usos_dieresi"}, {"gram": "GVB", "section": "8.2", "title": "Estalvi en l'ús de la dièresi", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=estalvi_dieresi"}, {"gram": "GVB", "section": "9.1", "title": "Usos del guionet", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=usos_guionet"}, {"gram": "GVB", "section": "9.2", "title": "Casos sense guionet", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=compostos_sense_guionet"}, {"gram": "GNV", "section": "38.2.1", "title": "La composició pròpia", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=composicio_propia"}]}},
  {"type": "b1_fon_alfabet", "lesson": {"intro": "Coneixeràs les lletres simples i modificades, els dígrafs i les geminacions, i sabràs com es separen en síl·labes per a escriure sense errors.", "blocks": [{"title": "Lletres simples i modificades", "text": "L'alfabet té **26 lletres simples**. Algunes es poden **modificar** amb un signe: l'accent (*à*, *è*, *é*, *í*, *ò*, *ó*, *ú*), la dièresi (*ï*, *ü*) o el trencat de la *ç*.", "examples": ["La **cançó** de l'**àvia** és molt **fàcil**.", "La meua **veïna** em fa una **qüestió**."]}, {"title": "Dígrafs: dos lletres, un so", "text": "Un **dígraf** són **dos lletres que representen un sol so**. Per això *carro* té 5 lletres i 4 sons, i *llibre*, 6 lletres i 5 sons. En *gu* i *qu* davant de *e*, *i*, la *u* **no sona**: *guerra*, *quilo*.", "table": {"head": ["dígraf", "exemple", "dígraf", "exemple"], "rows": [["*rr*", "*carro*", "*ll*", "*callar*"], ["*ny*", "*canya*", "*ss*", "*massa*"], ["*gu*", "*guitarra*", "*qu*", "*paquet*"], ["*tj*", "*platja*", "*tg*", "*metge*"], ["*tz*", "*dotze*", "*tx*", "*cotxe*"], ["*ig*", "*maig*, *roig*", "", ""]]}}, {"title": "Quan la u sí que sona", "text": "La *u* **sí que sona** davant de *a* i *o* (*quatre*, *guant*) i, amb **dièresi**, davant de *e* i *i* (*qüestió*). Dos consonants que sonen distintes (*pr* de *prat*) fan un **grup consonàntic**, no un dígraf. En *caixa* o *peix*, la *i* sovint no sona.", "watch": [{"wrong": "questió", "right": "qüestió"}, {"wrong": "pinguí", "right": "pingüí"}]}, {"title": "Les geminacions", "text": "La **geminació** són dos consonants iguals seguides: *l·l*, *mm*, *nn* (*il·lusió*, *immens*, *innecessari*). La *l·l* porta **punt volat** entre les dos *l*, i en la parla normal sona com una *l* simple.", "watch": [{"wrong": "colecció", "right": "col·lecció"}, {"wrong": "pel.lícula", "right": "pel·lícula"}]}, {"title": "Dígrafs i síl·labes", "text": "Quan separes síl·labes, **es separen** *rr*, *ss*, *l·l* (i el punt volat desapareix), *tj*, *tg*, *tz* i *tx*. **No es separen mai** *ll*, *ny*, *gu*, *qu* ni *ig*.", "table": {"head": ["es separen", "no es separen"], "rows": [["*car-ro*", "*ca-llar*"], ["*pas-sar*, *mas-sa*", "*ca-nya*"], ["*col-le-gi*", "*gui-tar-ra*"], ["*plat-ja*, *met-ge*", "*pa-quet*"], ["*dot-ze*, *cot-xe*", "*ba-teig*"]]}}], "remember": ["Un dígraf són dos lletres i un sol so: *carro* té 4 sons.", "Davant de *e*, *i*, la *u* de *gu* i *qu* només sona amb dièresi.", "La *l·l* porta punt volat: *col·legi*, *il·lusió*, *pel·lícula*.", "Separa *rr*, *ss*, *l·l*, *tj*, *tg*, *tz*, *tx*; mai *ll*, *ny*, *gu*, *qu*."], "sources": [{"gram": "GVB", "section": "4.1", "title": "Lletres simples", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=lletres_simples"}, {"gram": "GVB", "section": "4.2", "title": "Dígrafs i lletres compostes", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=digrafs_lletres_compostes"}, {"gram": "GVB", "section": "4.3", "title": "Lletres modificades", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=lletres_modificades"}, {"gram": "GVB", "section": "5.1.2", "title": "Normes de separació sil·làbica", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=silaba_normes_separacio"}, {"gram": "GVB", "section": "6.17", "title": "Les grafies l, l·l i tl", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=grafies_l_l_l_i_tl"}, {"gram": "GVB", "section": "8.1", "title": "Usos de la dièresi", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=usos_dieresi"}, {"gram": "GVB", "section": "1.2.2.2", "title": "Pronunciacions acceptables", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=vocals_atones"}, {"gram": "GNV", "section": "2.2", "title": "Dígrafs i lletres compostes", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=digrafs_lletres_compostes"}]}},
  {"type": "b1_fon_alveolars", "lesson": {"intro": "Aprendràs quan escriure *ç* o *c*, *s* o *ss*, *x* o *cc*, i com es formen paraules en *-ança*, *-ença*, *-esa* i *-essa*.", "blocks": [{"title": "*ç* o *c*?", "text": "El so [s] s'escriu ***ç*** davant de *a*, *o*, *u* i a final de paraula (*braç*, *braços*), i ***c*** davant de *e*, *i*. Per això la lletra canvia en el plural i en els verbs. Les paraules en ***-ança*** i ***-ença*** porten *ç*.", "table": {"head": ["amb *ç*", "amb *c*"], "rows": [["*pinça*, *plaça*", "*pinces*, *places*"], ["*dolça*", "*dolces*"], ["*vençut*", "*véncer*"], ["*forçar*, *comença*", "*forcem*, *comencem*"]]}, "examples": ["Nosaltres **comencem** a les huit a la **plaça**."]}, {"title": "*-ança*, *-ença* i *-ència*", "text": "Moltes paraules de la vida diària acaben en ***-ança*** o ***-ença***: *esperança*, *confiança*, *mudança*, *complaença*, *creença*. Altres paraules, més cultes, acaben en ***-ència***: *paciència*, *diferència*, *ciència*.", "examples": ["Hem fet la **mudança** amb molta **paciència**.", "No hi ha cap **diferència** entre els dos."]}, {"title": "[ks] i [gz]: *x* i *cc*", "text": "El so [ks] s'escriu ***x*** (*taxa*, *fixar*) o ***cc*** davant de *e*, *i* (*acció*, *direcció*). Si la paraula comença per *ex-* + vocal, la *x* sona sonora, [gz]: *examen*, *exèrcit*, *exacte*, *èxit*.", "examples": ["Hem pagat la **taxa** de l'**examen**.", "La **direcció** ha pres una **acció** ràpida."]}, {"title": "*-esa*, *-essa* i gentilicis", "text": "Amb ***-esa*** es fan noms de qualitat (*bell* → *bellesa*) i el femení de les paraules en *-és* (*marqués* → *marquesa*). Amb ***-essa***, el femení d'alguns càrrecs: *alcaldessa*, *comtessa*, *metgessa*. Els gentilicis en *-és* fan *-esa*, *-esos*, *-eses*.", "table": {"head": ["masculí", "femení", "plural m.", "plural f."], "rows": [["*xinés*", "*xinesa*", "*xinesos*", "*xineses*"], ["*anglés*", "*anglesa*", "*anglesos*", "*angleses*"], ["*alcalde*", "*alcaldessa*", "*alcaldes*", "*alcaldesses*"]]}, "examples": ["La seua **timidesa** amaga una gran **tristesa**."]}, {"title": "Una *s* o dos?", "text": "En les paraules agudes en vocal + *s*, escolta el femení o el plural: si sona [s], com en *passa*, escriu ***ss***; si sona [z], com en *rosa*, escriu ***s***. I recorda el grup ***sc***, que sona [s]: *piscina*, *escena*, *ascensor*, *adolescent*.", "table": {"head": ["sona [s]: *ss*", "sona [z]: *s*"], "rows": [["*gos* → *gossa*", "*calorós* → *calorosa*"], ["*gras* → *grassa*", "*xinés* → *xinesa*"], ["*pas* → *passos*", "*mes* → *mesos*"], ["*interés* → *interessos*", "*francés* → *francesos*"]]}}], "remember": ["*ç* davant de *a*, *o*, *u*; *c* davant de *e*, *i*: *plaça*, *places*.", "*Esperança* i *creença* amb *ç*; *paciència* i *diferència* amb *-ència*.", "*ex-* + vocal sona [gz]: *examen*, *exèrcit*.", "Femení o plural amb [s], *ss* (*gossa*); amb [z], *s* (*mesos*)."], "sources": [{"gram": "GVB", "section": "2.3.1", "title": "Pronunciacions recomanables", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=consonants_sibilants_alveolars"}, {"gram": "GVB", "section": "2.3.2", "title": "Pronunciacions no recomanables", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=consonants_sibilants_alveolars"}, {"gram": "GVB", "section": "6.5", "title": "Les grafies g i c", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=grafies_g_c"}, {"gram": "GVB", "section": "6.12", "title": "Les grafies x, tx i ig", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=representacio_so_ts"}, {"gram": "GVB", "section": "6.13", "title": "Les grafies s i ss", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=representacio_so_s"}, {"gram": "GVB", "section": "6.14", "title": "Les grafies ç i c", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=grafies_c_c"}, {"gram": "GVB", "section": "16.1", "title": "Introducció", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=substantius_formacio_femeni"}, {"gram": "GVB", "section": "16.2.1", "title": "El femení dels masculins acabats en consonant", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=femeni_a_partir_masculins_acabats_en_consonant"}, {"gram": "GVB", "section": "16.2.3", "title": "Altres casos", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=altres_casos_formacio_femeni"}, {"gram": "GVB", "section": "17.2", "title": "La formació del plural", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=formacio_plural"}, {"gram": "GVB", "section": "18.1.2", "title": "Els adjectius variables", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=adjectius_variables"}, {"gram": "GVB", "section": "18.2.1", "title": "La formació del plural", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=nombre_adjectius_formacio_plurals"}, {"gram": "GNV", "section": "4.2", "title": "La representació del so [s]: les grafies s, ss, c i ç", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=representacio_so_s"}, {"gram": "GNV", "section": "4.8", "title": "La representació del grup fònic [ks]", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=representacio_grup_fonic_ks"}, {"gram": "GNV", "section": "13.2.1", "title": "La formació del femení a partir de masculins acabats en consonant", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=adjectius_femeni_a_partir_masculins_acabats_en_consonant"}, {"gram": "GNV", "section": "30.1", "title": "Conceptes generals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=verbs_irregulars"}, {"gram": "GNV", "section": "37.5.1", "title": "Nominalització", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=nominalitzacio"}]}},
  {"type": "b1_fon_apostrofacio", "lesson": {"intro": "Aprendràs quan has d'escriure apòstrof en l'article, en la preposició *de* i en els pronoms, i com es fan les contraccions.", "blocks": [{"title": "*L'* i *d'* davant de vocal", "text": "Els articles *el* i *la* es convertixen en *l'* davant de paraula que comença per **vocal** o per **h muda**. La preposició *de* es convertix en *d'*.", "table": {"head": ["*el*", "*la*", "*de*"], "rows": [["*l'ase*", "*l'era*", "*d'amo*"], ["*l'home*", "*l'illa*", "*d'Isabel*"], ["*l'hivern*", "*l'ungla*", "*d'aigua*"]]}}, {"title": "Quan no s'apostrofa", "text": "*La* **no** s'apostrofa davant de *i* o *u* **àtones** (sense força), amb *h* o sense: *la infermera*, *la història*. Tampoc davant de *una* (l'hora). I *el*, *la* i *de* no s'apostrofen si la *i* o la *u* va seguida de vocal: *el iogurt*, *de hui*.", "examples": ["Estudie en **la universitat** i visc en **l'illa**.", "Ens veiem a **la una**.", "M'agrada **el iogurt** de maduixa."], "watch": [{"wrong": "l'universitat", "right": "la universitat"}]}, {"title": "Les contraccions", "text": "Les preposicions *a*, *de* i *per* s'unixen amb l'article *el* i *els*. Però davant de vocal o *h* muda, l'article s'apostrofa i **no** hi ha contracció: *a l'hospital*, *de l'amo*.", "table": {"head": ["", "+ *el*", "+ *els*"], "rows": [["*a*", "*al*", "*als*"], ["*de*", "*del*", "*dels*"], ["*per*", "*pel*", "*pels*"]]}, "examples": ["Vaig **al** mercat i després **a l'**hospital.", "Passem **pels** carrers **del** centre."]}, {"title": "Pronoms davant i darrere del verb", "text": "**Davant** d'un verb que comença per vocal o *h*: *m'*, *t'*, *l'*, *s'*, *n'*. *Ens* i *els* no s'apostrofen. **Darrere** d'un verb acabat en vocal: *'m*, *'t*, *'l*, *'n*, *'ns*, *'ls*. Si no, guionet: *fes-ho*, *obri-la*.", "table": {"head": ["pronom", "davant de vocal", "darrere de vocal"], "rows": [["*em*", "*m'agrada*", "*porta'm*"], ["*et*", "*t'estime*", "*renta't*"], ["*el*", "*l'he vist*", "*compra'l*"], ["*en*", "*n'hi ha*", "*compra'n*"], ["*ens*", "*ens agrada*", "*mira'ns*"]]}, "watch": [{"wrong": "Me agrada molt.", "right": "M'agrada molt."}]}, {"title": "Dos pronoms junts", "text": "Quan van **dos pronoms**, el primer pren la forma *me*, *te*, *se* i l'apòstrof va **tan a la dreta com es puga**: *me'l*, *te'n*, *se'n*. Davant de *ho* o *hi*: *m'ho*, *s'hi*. Darrere del verb, igual: *dona-me'l*.", "examples": ["**Te'n** vas ja a casa?", "**M'ho** ha contat ma mare.", "Porta-**me'l** demà, per favor."], "watch": [{"wrong": "S'en va.", "right": "Se'n va."}, {"wrong": "Em el dones?", "right": "Me'l dones?"}]}], "remember": ["*L'home*, *l'illa*, però *la infermera*, *la universitat*.", "Davant de vocal, sense contracció: *a l'escola*, *de l'amo*.", "*Ens* i *els* mai no s'apostrofen davant del verb.", "Dos pronoms: apòstrof tan a la dreta com es puga (*se'n*, *me'l*)."], "sources": [{"gram": "GVB", "section": "10.1", "title": "Introducció", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=apostrofacio"}, {"gram": "GVB", "section": "10.2", "title": "L'apostrofació de l'article definit", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=apostrofacio_article_definit"}, {"gram": "GVB", "section": "10.3", "title": "L'apostrofació de la preposició de", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=apostrofacio_preposicio_de"}, {"gram": "GVB", "section": "10.5", "title": "L'Apostrofació davant de i o u no vocàliques", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=apostrofacio_i_u_consonantiques"}, {"gram": "GVB", "section": "10.8", "title": "L'apostrofació davant de paraules homòfones", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=apostrofacio_homofones"}, {"gram": "GVB", "section": "10.14", "title": "L'apostrofació dels pronoms febles", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=apostrofacio_pronoms_febles"}, {"gram": "GVB", "section": "11.1", "title": "Formació de les contraccions", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=formacio_contraccions"}, {"gram": "GVB", "section": "11.2", "title": "Descomposició de les contraccions", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=descomposicio_contraccions"}, {"gram": "GVB", "section": "26.3.2", "title": "Formes plenes, reforçades, reduïdes i elidides", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=formes_plenes_elidides"}, {"gram": "GVB", "section": "26.4.2", "title": "La forma dels pronoms febles", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=forma_pronoms_febles"}]}},
  {"type": "b1_fon_elocucio", "lesson": {"intro": "Aprendràs a parlar amb naturalitat: com s'unixen les vocals, quins sons són propis del valencià, quines consonants no sonen i com es diuen les preguntes i les exclamacions.", "blocks": [{"title": "Vocals que s'unixen", "text": "Si una paraula acaba en vocal i la següent comença per vocal, en la parla **se'n perd una**. Passa sobretot si són **iguals** (*una amiga*) i si una *-a* o *-e* àtones van davant de vocal (*quina hora*). Després de consonant (*un home*), no.", "table": {"head": ["escrius", "dius"], "rows": [["*Quina hora és?*", "*quinora és?*"], ["*quinze anys*", "*quinzanys*"], ["*una amiga*", "*unamiga*"], ["*una escala*", "*unascala*"]]}}, {"title": "Sons propis del valencià", "text": "La *j* i la *g* de *juny* o *gener* sonen [ʤ], **sonores**. La *s* entre vocals i la *z* també són **sonores**: *rosa* no sona com *rossa*. La *r* inicial i la *rr* són **fortes**: *para* i *parra* són paraules diferents.", "table": {"head": ["lletra", "so", "exemples"], "rows": [["*j*, *g*, *tj*, *tg*", "[ʤ], com *gent*", "*juny*, *gener*, *platja*, *metge*"], ["*s* / *ss*", "[z] / [s]", "*casa*, *rosa* / *passa*, *rossa*"], ["*z*, *tz*", "sonores", "*zero*, *onze*, *dotze*"], ["*r* / *rr*", "suau / forta", "*para* / *parra*, *racó*, *carro*"], ["*x*", "[ʧ], [ʃ], [ks], [gz]", "*panxa*, *caixa*, *taxi*, *examen*"], ["*ny*", "un sol so", "*canya*, *any*"]]}}, {"title": "Consonants que no sonen", "text": "La *p* de *compte*, *comptar* o *prompte* **no sona mai**. En molts parlars tampoc sonen la consonant final de *camp*, *font* o *molt* (sobretot en plural: *camps*, *temps*) ni la *-r* dels infinitius (*cantar*). *Amb* sona [am] davant de consonant.", "examples": ["Vaig **amb** ma mare i **amb** el meu oncle."], "watch": [{"wrong": "*portar-li* pronunciat «portà-li»", "right": "*portar-li*, amb la *r* pronunciada"}, {"wrong": "*cadira* pronunciat «caïra»", "right": "*cadira*, amb la *d* pronunciada"}]}, {"title": "Grups i consonants dobles", "text": "Pronuncia bé els **grups de consonants**, sense afegir ni moure sons: *estrella*, *problema*, *comprar*. Les **geminacions** són consonants dobles escrites (*immens*, *ennuvolat*, *col·legi*). Mira com es diuen les més freqüents:", "table": {"head": ["escrius", "pronuncies"], "rows": [["*ametla*", "dos *l* (preferible) o una"], ["*col·legi*", "una *l* simple"], ["*bitllet*", "una *ll* simple"], ["*setmana*", "una *m* simple"]]}, "watch": [{"wrong": "*problema* pronunciat «poblema»", "right": "*problema*, amb la *r*"}, {"wrong": "*comprar* pronunciat «crompar»", "right": "*comprar*"}]}, {"title": "Preguntes i exclamacions", "text": "En les preguntes de **sí o no**, sense paraula interrogativa, l'**entonació** marca la pregunta: la veu sol pujar al final. Les pots començar amb *que*. Les exclamacions tenen una entonació **emfàtica** i porten *!* al final (el signe *¡* d'obertura és opcional).", "examples": ["Ja ha vingut. / Ja ha **vingut?**", "**Que** vindràs demà?", "**Quina calor que** fa! **Mare meua!**"], "watch": [{"wrong": "Que calor que fa!", "right": "Quina calor que fa!"}]}], "remember": ["*Quina hora*, *quinze anys*: en la parla, una de les vocals desapareix.", "*Juny*, *gent* i *platja* sonen [ʤ], sonores.", "*Rosa* i *rossa*, *para* i *parra*: no sonen igual.", "La *p* de *compte* i *comptar* no sona mai."], "sources": [{"gram": "GVB", "section": "2.1.2", "title": "Pronunciacions acceptables", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=consonants_oclusives"}, {"gram": "GVB", "section": "2.1.3", "title": "Pronunciacions no recomanables", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=consonants_oclusives"}, {"gram": "GVB", "section": "2.3.2", "title": "Pronunciacions no recomanables", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=consonants_sibilants_alveolars"}, {"gram": "GVB", "section": "2.4.3", "title": "Pronunciacions no recomanables", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=consonants_sibilants_palatals"}, {"gram": "GVB", "section": "2.5.1", "title": "Pronunciacions recomanables", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=consonants_laterals"}, {"gram": "GVB", "section": "2.6.2", "title": "Pronunciacions acceptables", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=consonants_rotiques"}, {"gram": "GVB", "section": "2.6.3", "title": "Pronunciacions no recomanables", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=consonants_rotiques"}, {"gram": "GVB", "section": "2.7.1", "title": "Pronunciacions recomanables", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=consonants_nasals"}, {"gram": "GVB", "section": "3.1", "title": "Vocals en contacte", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=vocals_en_contacte"}, {"gram": "GVB", "section": "6.12", "title": "Les grafies x, tx i ig", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=representacio_so_ts"}, {"gram": "GVB", "section": "6.13", "title": "Les grafies s i ss", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=representacio_so_s"}, {"gram": "GVB", "section": "6.15", "title": "Les grafies z i s", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=representacio_so_z"}, {"gram": "GVB", "section": "6.16", "title": "La grafia tz", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=grafia_tz"}, {"gram": "GVB", "section": "6.17", "title": "Les grafies l, l·l i tl", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=grafies_l_l_l_i_tl"}, {"gram": "GVB", "section": "6.19", "title": "Les grafies m, n i mp", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=grafies_m_n_mp_tm_tn"}, {"gram": "GVB", "section": "6.22", "title": "Les grafies r i rr", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=grafies_r_i_rr"}, {"gram": "GVB", "section": "15.9", "title": "Els signes d'exclamació", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=exclamacio"}, {"gram": "GNV", "section": "1.3.2.4", "title": "Les consonants sibilants palatals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=consonants_sibilants_palatals"}, {"gram": "GNV", "section": "1.4.1", "title": "Vocals en contacte", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=vocals_en_contacte"}, {"gram": "GNV", "section": "1.4.2.1", "title": "Les consonants oclusives en posició final", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=consonants_oclusives_posicio_final"}, {"gram": "GNV", "section": "25.2.1", "title": "Les interrogatives totals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=interrogatives_totals"}, {"gram": "GNV", "section": "25.4", "title": "Els exclamatius", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=exclamatius"}]}},
  {"type": "b1_fon_laterals_h", "lesson": {"intro": "Aprendràs a escriure la *l·l*, *tl* i *tll*, la *m* davant de *b* i *p*, la *ny* final, la *r* i la *rr*, i la *h*.", "blocks": [{"title": "La *ele geminada*: *l·l*", "text": "Moltes paraules cultes porten ***l·l***, sobretot en els grups *al·l-*, *col·l-*, *il·l-* i en les terminacions *-el·la* i *-il·la*. Es pronuncia com una *l* simple. No oblides el punt volat.", "examples": ["Té **al·lèrgia** a una **pastil·la**.", "Vols **col·laborar** amb el **col·legi**?", "És una **novel·la** molt **intel·ligent**."], "watch": [{"wrong": "ilegal", "right": "il·legal"}, {"wrong": "tranquila", "right": "tranquil·la"}]}, {"title": "*tl* i *tll*", "text": "Algunes paraules de tota la vida s'escriuen amb ***tl*** i sonen com una *l* doble o simple: *ametla*, *espatla*, *vetlar*. Altres porten ***tll*** i sonen normalment com una *ll*: *ratlla*, *bitllet*.", "table": {"head": ["amb *tl*", "amb *tll*"], "rows": [["*ametla*", "*ratlla*"], ["*espatla*", "*bitllet*"], ["*vetlar*", "*rotllo*"]]}}, {"title": "*m*, *n* i *ny* final", "text": "Davant de ***b***, ***p*** i ***m*** s'escriu ***m***: *ambulància*, *combinar*, *umbracle*, *immens*, *immediat*. Davant de ***v***, ***n***: *enviar*, *convidar*. Davant de *r*, el prefix *in-* fa *irr-*: *irrompre*. El so de *canya* a final de paraula s'escriu ***ny***: *disseny*, *puny*, *bony*, *plany*.", "watch": [{"wrong": "inmens", "right": "immens"}, {"wrong": "diseny", "right": "disseny"}]}, {"title": "*r* o *rr*?", "text": "A principi de paraula i darrere de consonant d'una altra síl·laba, la ***r*** sona forta però s'escriu sola: *rosa*, *En-ric*, *hon-ra*. Entre vocals, la forta s'escriu ***rr***: *carrer*. En alguns parlars no es pronuncia la *-r* final (*senyor*, *comptar*), però sempre s'escriu.", "examples": ["Els **senyors** viuen en eixos **carrers**."], "watch": [{"wrong": "Enrric", "right": "Enric"}]}, {"title": "La *h* i el verb *haver*", "text": "La ***h*** no sona, però s'escriu en moltes paraules, a l'inici (*harmonia*, *hui*) o enmig (*ahir*, *vehicle*, *prohibit*, *vehement*). Altres no en porten: *ou*, *orxata*. El verb ***haver*** dels temps compostos s'escriu amb *h*: *he*, *has*, ***ha***...", "examples": ["**M'ha agradat** molt l'**orxata**.", "Hui **ha anat** a València amb el **vehicle** nou.", "**Hi ha** molta gent."], "watch": [{"wrong": "M'a agradat.", "right": "M'ha agradat."}]}], "remember": ["*l·l* amb punt volat: *col·legi*, *il·legal*, *novel·la*.", "*m* davant de *b*, *p*, *m*; *n* davant de *v*.", "*r* inicial sona forta: *rosa*; entre vocals, *rr*: *carrer*.", "*Ahir*, *harmonia*, *ha anat* amb *h*; *ou* i *orxata*, sense."], "sources": [{"gram": "GVB", "section": "2.5.1", "title": "Pronunciacions recomanables", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=consonants_laterals"}, {"gram": "GVB", "section": "2.6.1", "title": "Pronunciacions recomanables", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=consonants_rotiques"}, {"gram": "GVB", "section": "2.6.2", "title": "Pronunciacions acceptables", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=consonants_rotiques"}, {"gram": "GVB", "section": "6.17", "title": "Les grafies l, l·l i tl", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=grafies_l_l_l_i_tl"}, {"gram": "GVB", "section": "6.18", "title": "Les grafies ll i tll", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=grafies_ll_i_tll"}, {"gram": "GVB", "section": "6.19", "title": "Les grafies m, n i mp", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=grafies_m_n_mp_tm_tn"}, {"gram": "GVB", "section": "6.21", "title": "La grafia ny", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=grafia_ny"}, {"gram": "GVB", "section": "6.22", "title": "Les grafies r i rr", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=grafies_r_i_rr"}, {"gram": "GVB", "section": "6.23", "title": "La grafia h", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=grafia_h"}, {"gram": "GVB", "section": "18.1.2", "title": "Els adjectius variables", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=adjectius_variables"}, {"gram": "GNV", "section": "1.3.2.5", "title": "Les consonants laterals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=consonants_laterals"}, {"gram": "GNV", "section": "1.3.2.6", "title": "Les consonants ròtiques", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=consonants_rotiques"}, {"gram": "GNV", "section": "4.12", "title": "Les grafies m, n, mp, tm i tn", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=grafies_m_n_mp_tm_tn"}, {"gram": "GNV", "section": "4.13", "title": "La grafia ny", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=grafia_ny"}, {"gram": "GNV", "section": "4.14", "title": "Les grafies l, l·l i tl", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=grafies_l_l_l_i_tl"}, {"gram": "GNV", "section": "4.15", "title": "Les grafies ll i tll", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=grafies_ll_i_tll"}, {"gram": "GNV", "section": "4.16", "title": "Les grafies r i rr", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=grafies_r_i_rr"}, {"gram": "GNV", "section": "4.17", "title": "La grafia h", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=grafia_h"}, {"gram": "GNV", "section": "29.4.1", "title": "Model del verb cantar", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=verbs_regulars"}, {"gram": "GNV", "section": "37.3", "title": "Alternances formals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=alternances_formals"}]}},
  {"type": "b1_fon_majuscules", "lesson": {"intro": "Aprendràs quan has d'escriure majúscula inicial i quan minúscula: després dels signes de puntuació, en noms propis, institucions, festes i títols.", "blocks": [{"title": "Majúscula per la posició", "text": "Va amb majúscula la **primera paraula** d'un text i la que va després de **punt**, de **?** o **!** que tanquen la frase i, normalment, de **punts suspensius**. Després de **dos punts**, minúscula, excepte si és una **cita** o el text d'una **carta** després de la salutació.", "examples": ["Saps què? **Demà** no treballe.", "Ja t'ho he dit: **no** vull anar-hi.", "Ma mare va dir: «**Torna** prompte»."]}, {"title": "Persones, llocs i astres", "text": "Els **noms propis** van amb majúscula: persones, divinitats (*Déu*, *la Mare de Déu*), pobles, comarques i països (*la Comunitat Valenciana*, *Amèrica del Nord*). La paraula genèrica que acompanya el nom d'un lloc va en **minúscula**. *Terra*, *Sol* i *Lluna*, majúscula només com a astres.", "table": {"head": ["genèric en minúscula", "exemple"], "rows": [["riu, mar", "*el riu Túria*, *el mar Mediterrani*"], ["serra", "*la serra de Mariola*"], ["carrer, plaça", "*el carrer de la Pau*"]]}, "examples": ["La **Terra** gira al voltant del **Sol**.", "Viu al **nord** de Castelló."]}, {"title": "Institucions, festes i èpoques", "text": "Porten majúscula les paraules del nom d'**institucions**, entitats i edificis (*la Generalitat Valenciana*, *el Museu de Belles Arts*), les **festes** (*Nadal*, *les Falles*, *el Nou d'Octubre*) i els **períodes històrics** (*l'Edat Mitjana*). Si el nom s'usa en sentit general o en plural, minúscula.", "examples": ["Treballa en la **Universitat de València**.", "Per **Nadal** anirem a Morella.", "Cada **ajuntament** té el seu pressupost."]}, {"title": "Títols, sigles i abreviatures", "text": "En el títol d'un **llibre** o d'una **pel·lícula**, només la **primera paraula** (i els noms propis) va amb majúscula. Les **sigles** i els números romans dels reis van en majúscules. Els tractaments **abreujats** porten majúscula inicial: *Sr.*, *Sra.*", "examples": ["He llegit *La plaça del Diamant*.", "El rei **Jaume I** va arribar a València.", "La **UE** té la seu a Brussel·les."]}, {"title": "Sempre en minúscula", "text": "Van en **minúscula** els dies, els mesos i les estacions, els noms de **llengües** i els **gentilicis** (de quin lloc és algú), els **càrrecs** i els tractaments escrits sencers.", "table": {"head": ["minúscula", "exemple"], "rows": [["dies, mesos, estacions", "*el dilluns 3 de març*, *la primavera*"], ["llengües, gentilicis", "*parle valencià*, *els valencians*"], ["càrrecs", "*l'alcaldessa*, *el president de la Generalitat*"], ["tractaments sencers", "*el senyor Martí* (però *el Sr. Martí*)"]]}, "watch": [{"wrong": "Ens veiem el Dilluns 3 de Març.", "right": "Ens veiem el dilluns 3 de març."}]}], "remember": ["Després de dos punts, minúscula, excepte en cites i cartes.", "*El riu Túria*: el genèric en minúscula, el nom en majúscula.", "Dies, mesos, llengües, gentilicis i càrrecs, en minúscula.", "Abreviatura amb majúscula: *Sr.*, *Sra.*; sencer, en minúscula: *senyor*."], "sources": [{"gram": "GVB", "section": "12.1", "title": "Introducció", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=majuscules_consideracions_generals"}, {"gram": "GVB", "section": "12.2", "title": "Paraules senceres", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=majuscules_paraules_senceres"}, {"gram": "GVB", "section": "12.3", "title": "Inici de frase", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=majuscules_funcio_demarcativa"}, {"gram": "GVB", "section": "12.5", "title": "Després dels signes d'interrogació i exclamació", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=majuscules_signes_interrogacio"}, {"gram": "GVB", "section": "12.6", "title": "Després de punts suspensius", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=majuscules_punts_suspensius"}, {"gram": "GVB", "section": "12.7", "title": "Després de dos punts", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=majuscules_dos_punts"}, {"gram": "GVB", "section": "12.9", "title": "Noms propis referits a persones", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=majuscules_funcio_distintiva"}, {"gram": "GVB", "section": "12.10", "title": "Càrrecs i títols nobiliaris", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=majuscules_carrecs"}, {"gram": "GVB", "section": "12.11", "title": "Formes de tractament", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=majuscules_formes_tractament"}, {"gram": "GVB", "section": "12.16", "title": "Noms d'institucions, organismes i empreses", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=majuscules_empreses"}, {"gram": "GVB", "section": "12.20", "title": "Noms de festivitats", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=majuscules_festivitats"}, {"gram": "GVB", "section": "12.22", "title": "Divisions temporals cícliques", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=majuscules_divisions_temporals"}, {"gram": "GVB", "section": "12.23", "title": "Noms de períodes històrics", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=majuscules_periodes_historics"}, {"gram": "GVB", "section": "12.25", "title": "Noms de lloc", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=majuscules_toponims"}, {"gram": "GVB", "section": "12.27", "title": "Noms d'astres", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=majuscules_astres"}, {"gram": "GVB", "section": "12.30", "title": "Títols de llibres, pel·lícules i publicacions", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=majuscules_titols_llibres"}, {"gram": "GVB", "section": "13.2.3", "title": "Llibres i publicacions periòdiques", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=cursiva_publicacions"}, {"gram": "GVB", "section": "15.6.1", "title": "Usos dels dos punts", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=dos_punts"}, {"gram": "GNV", "section": "6.1.3", "title": "La funció distintiva", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=majuscules_funcio_distintiva"}]}},
  {"type": "b1_fon_oclusives", "lesson": {"intro": "Aprendràs a escriure bé les consonants finals (*p/b*, *t/d*, *c/g*), els grups *cu* i *qu*, *xc* i *cc*, i la *v* de l'imperfet.", "blocks": [{"title": "Final sord, femení sonor", "text": "A final de paraula, *b*, *d*, *g* sonen [p], [t], [k]. En el femení, molts noms i adjectius canvien ***-p***, ***-t***, ***-c*** per ***-b-***, ***-d-***, ***-g-***: *llop*, *lloba*. Darrere de consonant no canvia: *tort*, *torta*. En plural, *-ga* fa ***-gues***.", "table": {"head": ["masculí", "femení", "plural femení"], "rows": [["*llop*", "*lloba*", "*llobes*"], ["*cunyat*", "*cunyada*", "*cunyades*"], ["*salat*", "*salada*", "*salades*"], ["*verd*", "*verda*", "*verdes*"], ["*groc*", "*groga*", "*grogues*"], ["*llarg*", "*llarga*", "*llargues*"]]}}, {"title": "Dubtes? Mira la família", "text": "Si no saps quina lletra va al final, busca una paraula de la mateixa família: la consonant que hi sona és la que escrius. Passa igual en els verbs: *rebre* → *ell* ***rep***, *nosaltres* ***rebem***.", "table": {"head": ["paraula", "família"], "rows": [["*àrab*", "*arabesc*"], ["*covard*", "*covardia*"], ["*sord*", "*ensordir*"], ["*tímid*", "*timidesa*"], ["*amarg*", "*amargós*"], ["*sang*", "*sanguini*"]]}, "examples": ["Ell **rep** moltes cartes, però nosaltres en **rebem** poques."]}, {"title": "*cu* o *qu*?", "text": "Escriu ***q*** quan la *u* forma diftong amb la vocal següent, en la mateixa síl·laba: *qua-tre*, *quo-ta*, *a-de-quar*. Escriu ***c*** quan la *u* fa síl·laba a part: *cu-a*, *e-va-cu-ar*. Davant de *e*, *i*, el so [k] s'escriu *qu*: *quinze*.", "examples": ["Hem pagat la **quota** del club.", "Hi havia molta **cua** a la farmàcia.", "Cal **evacuar** l'edifici i **adequar** les eixides."]}, {"title": "*Excés* o *accés*?", "text": "Davant de *e*, *i*, el grup que sona [ks] + [s] s'escriu de dos maneres: ***xc*** (*excés*) o ***cc*** (*accés*). No hi ha truc: aprén-te les paraules més usuals.", "table": {"head": ["amb *xc*", "amb *cc*"], "rows": [["*excés*", "*accés*"], ["*excursió*", "*accident*"], ["*excepte*", "*acceptar*"], ["*excel·lent*", "*acció*"]]}}, {"title": "La *v* de l'imperfet", "text": "L'imperfet dels verbs en *-ar* s'escriu i es pronuncia amb ***v***: *-ava*, *-aves*, *-àvem*, *-àveu*, *-aven*. Fixa't també en *advocat*, *avorrit*, *govern* i *provar* (amb *v*), i en *berenar* (amb *b*).", "examples": ["Nosaltres **anàvem** a l'escola junts.", "Vosaltres **parlàveu** molt de pressa."], "watch": [{"wrong": "Ahir trobàem les claus.", "right": "Ahir trobàvem les claus."}]}], "remember": ["Femení amb *-b-*, *-d-*, *-g-*: *llop* → *lloba*, *groc* → *groga*.", "La família t'ajuda: *verd* (*verdós*), *sord* (*ensordir*), *àrab* (*arabesc*).", "*u* en diftong, *q* (*quota*); *u* en síl·laba a part, *c* (*cua*).", "Imperfet en *-ar* sempre amb *v*: *trobava*, *trobàvem*."], "sources": [{"gram": "GVB", "section": "2.2.3", "title": "Pronunciacions no recomanables", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=consonants_fricatives_labiodentals"}, {"gram": "GVB", "section": "3.2.1", "title": "Les consonants b/p, d/t i g/c", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=consonants_oclusives_posicio_final"}, {"gram": "GVB", "section": "3.3", "title": "L'accentuació", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=accentuacio_vacillacions"}, {"gram": "GVB", "section": "5.2.2", "title": "Classificació dels diftongs", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=classificacio_diftongs"}, {"gram": "GVB", "section": "6.4", "title": "Les grafies c, q i qu", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=representacio_so_g"}, {"gram": "GVB", "section": "6.5", "title": "Les grafies g i c", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=grafies_g_c"}, {"gram": "GVB", "section": "6.7", "title": "Les grafies b i p", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=grafies_b_p"}, {"gram": "GVB", "section": "6.8", "title": "Les grafies d i t", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=grafies_d_t"}, {"gram": "GVB", "section": "6.24", "title": "Les grafies b i v", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=grafies_b_v"}, {"gram": "GVB", "section": "16.2.1", "title": "El femení dels masculins acabats en consonant", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=femeni_a_partir_masculins_acabats_en_consonant"}, {"gram": "GVB", "section": "18.1.2", "title": "Els adjectius variables", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=adjectius_variables"}, {"gram": "GVB", "section": "18.2.1", "title": "La formació del plural", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=nombre_adjectius_formacio_plurals"}, {"gram": "GNV", "section": "1.3.2.2", "title": "Les consonants fricatives labiodentals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=consonants_fricatives_labiodentals"}, {"gram": "GNV", "section": "4.1", "title": "La representació dels sons [g] i [k]", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=representacio_so_g"}, {"gram": "GNV", "section": "4.8", "title": "La representació del grup fònic [ks]", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=representacio_grup_fonic_ks"}, {"gram": "GNV", "section": "4.10", "title": "Les grafies b i v", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=grafies_b_v"}, {"gram": "GNV", "section": "4.11", "title": "Les grafies d i t", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=grafies_d_t"}, {"gram": "GNV", "section": "37.3", "title": "Alternances formals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=alternances_formals"}]}},
  {"type": "b1_fon_palatals", "lesson": {"intro": "Aprendràs a triar entre *g*, *j*, *tg*, *tj*, *ig*, *x* i *tx*, i a pronunciar bé la *x*.", "blocks": [{"title": "*g* o *j*? *tg* o *tj*?", "text": "El so de *gent*, [ʤ], s'escriu ***j*** davant de *a*, *o*, *u* (*jove*, *menjar*) i ***g*** davant de *e*, *i* (*gener*, *àgil*). Entre vocals, sovint s'escriu ***tj*** o ***tg*** amb la mateixa regla: *platja*, *pitjor*; *metge*, *mitges*. A final de paraula, *-ig*: *raig*, *fuig*.", "examples": ["Al **gener** la **platja** està buida.", "Hui estic **pitjor**: he d'anar al **metge**."]}, {"title": "Excepcions: *j* davant de *e*", "text": "Algunes paraules porten ***j*** davant de *e*: *Jesús*, *jersei*, *majestat* i les que tenen ***-ject-*** o ***-jecc-***: *objecte*, *projecte*, *injecció*. Pronuncia-les amb el so de *jove*, no amb el de *iogurt*.", "examples": ["Hem presentat el **projecte** a temps.", "La infermera li ha posat una **injecció**."]}, {"title": "Canvis en la flexió", "text": "Quan fas el plural, el femení o conjugues un verb, aplica la regla: ***j***/***tj*** davant de *a*, *o*, *u* i ***g***/***tg*** davant de *e*, *i*. El so no canvia; només canvia la lletra.", "table": {"head": ["amb *j* / *tj*", "amb *g* / *tg*"], "rows": [["*boja*, *bojos*", "*boges*"], ["*platja*", "*platges*"], ["*mitja*", "*mitges*"], ["*pluja*, *taronja*", "*pluges*, *taronges*"], ["*menjar*, *pujar*", "*mengem*, *pugem*"]]}}, {"title": "*x* o *tx*? I com sona?", "text": "S'escriu ***x*** a principi de paraula (*xica*, *xarop*) i darrere de consonant (*planxa*, *marxar*); entre vocals, ***tx*** (*fitxa*, *motxilla*). La *x* de *xic* i *panxa* sona [ʧ]; però en *Xàtiva* o *Xavier* sona [ʃ], com en *caixa*.", "examples": ["Agafa la **motxilla** i el **xarop**, que **marxem**."], "watch": [{"wrong": "ficha", "right": "fitxa"}, {"wrong": "Vaig a «Aixàtiva».", "right": "Vaig a Xàtiva."}]}, {"title": "Finals en *-tx* i *-ig*", "text": "Una paraula acabada en ***-tx*** conserva el *tx* en els derivats. Una acabada en ***-ig*** passa a ***j***/***tj*** o ***g***/***tg***, segons la vocal que seguix.", "table": {"head": ["final", "derivat"], "rows": [["*despatx*, *escabetx*", "*despatxos*, *escabetxar*"], ["*capritx*", "*capritxós*"], ["*lleig*", "*lletja*, *lletges*"], ["*roig*", "*roja*, *rojor*"], ["*desig*, *passeig*", "*desitjar*, *passejar*"]]}}], "remember": ["*j*/*tj* davant de *a*, *o*, *u*; *g*/*tg* davant de *e*, *i*.", "Excepcions amb *j*: *Jesús*, *objecte*, *projecte*, *injecció*.", "*x* a l'inici i darrere de consonant; *tx* entre vocals.", "*-ig* passa a *j*/*tj*: *roig* → *rojor*, *lleig* → *lletja*."], "sources": [{"gram": "GVB", "section": "2.4.1", "title": "Pronunciacions recomanables", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=consonants_sibilants_palatals"}, {"gram": "GVB", "section": "2.4.3", "title": "Pronunciacions no recomanables", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=consonants_sibilants_palatals"}, {"gram": "GVB", "section": "6.10", "title": "Les grafies j i g", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=representacio_so_dz"}, {"gram": "GVB", "section": "6.11", "title": "Les grafies tj i tg", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=grafies_tj_tg"}, {"gram": "GVB", "section": "6.12", "title": "Les grafies x, tx i ig", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=representacio_so_ts"}, {"gram": "GVB", "section": "17.2", "title": "La formació del plural", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=formacio_plural"}, {"gram": "GVB", "section": "18.1.2", "title": "Els adjectius variables", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=adjectius_variables"}, {"gram": "GVB", "section": "18.2.1", "title": "La formació del plural", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=nombre_adjectius_formacio_plurals"}, {"gram": "GNV", "section": "1.3.2.4", "title": "Les consonants sibilants palatals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=consonants_sibilants_palatals"}, {"gram": "GNV", "section": "4.5", "title": "La representació del so [ʤ]: les grafies g, j, tg i tj", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=representacio_so_dz"}, {"gram": "GNV", "section": "4.6", "title": "La representació del so [ʧ]: les grafies x, tx, ig i g", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=representacio_so_ts"}, {"gram": "GNV", "section": "4.7", "title": "La representació del so [ʃ]: la grafia x", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=representacio_so_s_x"}, {"gram": "GNV", "section": "30.1", "title": "Conceptes generals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=verbs_irregulars"}, {"gram": "GNV", "section": "37.3", "title": "Alternances formals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=alternances_formals"}]}},
  {"type": "b1_fon_puntuacio", "lesson": {"intro": "Aprendràs a usar el punt i coma, els dos punts, els punts suspensius i els parèntesis per a escriure textos clars i ben organitzats.", "blocks": [{"title": "El punt i coma (;)", "text": "Marca una pausa **més forta que la coma** i més suau que el punt. Separa **grups que ja tenen comes** (davant de l'últim, si va amb *i*, es posa coma), **frases completes** molt relacionades i frases unides per connectors com *tanmateix* o *no obstant això*.", "examples": ["Han vingut Anna, de Gandia**;** Jordi, d'Alcoi, i Lluís, d'Elx.", "Hui treballe tot el dia**;** demà, descanse.", "He estudiat molt**;** tanmateix, no estic tranquil."]}, {"title": "Els dos punts (:)", "text": "Els dos punts **anuncien** el que ve darrere. Després, normalment, minúscula. **No** els poses entre una preposició i el nom: *representants de França*, no *de: França*.", "table": {"head": ["per a...", "exemple"], "rows": [["una llista", "*Compra tres coses: llet, pa i ous.*"], ["un exemple", "*Hi ha moltes fruites, per exemple: taronges i peres.*"], ["una causa o conseqüència", "*No ve a sopar: està cansat.*"], ["una cita", "*Va dir: «Arribaré tard».*"], ["la salutació d'una carta", "*Benvolgut senyor:*"]]}}, {"title": "Els punts suspensius (...)", "text": "Són **sempre tres** punts. Deixen una frase o una llista **sense acabar** (com *etc.*) o expressen **dubte**, **sorpresa** o una interrupció. Entre claudàtors, *[...]*, indiquen que s'ha **omés un tros** d'una cita.", "examples": ["Hem comprat pomes, peres, plàtans**...**", "Doncs**...** no sé què dir-te.", "Vaig obrir el regal**...** i era un rellotge!"], "watch": [{"wrong": "pomes, peres, plàtans, etc...", "right": "pomes, peres, plàtans, etc."}]}, {"title": "Els parèntesis ( )", "text": "Servixen per a afegir una **informació secundària**: un aclariment, una data, una xifra, el significat d'una sigla o una **forma alternativa**. Per a un aclariment també pots usar **guions llargs** o **comes**. Si el parèntesi s'obri dins de la frase, el **punt va darrere**.", "examples": ["El meu veí (el germà de Rosa) és metge.", "Treballa en la Universitat Jaume I **(UJI).**", "Es necessita cambrer(a) per a l'estiu."]}], "remember": ["Punt i coma: pausa més forta que la coma, entre grups amb comes.", "Dos punts: anuncien una llista, un exemple, una causa o una cita.", "Els punts suspensius són sempre tres, i mai no van darrere d'*etc.*", "Parèntesi dins de la frase: el punt final va darrere."], "sources": [{"gram": "GVB", "section": "15.2", "title": "Posició dels signes de puntuació", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=posicio_signes_puntuacio"}, {"gram": "GVB", "section": "15.3.1", "title": "Usos de la coma", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=coma"}, {"gram": "GVB", "section": "15.4", "title": "El punt i coma", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=punt_i_coma"}, {"gram": "GVB", "section": "15.6.1", "title": "Usos dels dos punts", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=dos_punts"}, {"gram": "GVB", "section": "15.6.3", "title": "Ús incorrecte dels dos punts", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=dos_punts"}, {"gram": "GVB", "section": "15.7.1", "title": "Usos dels punts suspensius", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=punts_suspensius"}, {"gram": "GVB", "section": "15.7.3", "title": "Ús incorrecte dels punts suspensius", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=punts_suspensius"}, {"gram": "GVB", "section": "15.10", "title": "Els guions", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=guions"}, {"gram": "GVB", "section": "15.11.1", "title": "Usos dels parèntesis", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=parentesis"}, {"gram": "GVB", "section": "15.11.2", "title": "Combinació dels parèntesis amb altres signes de puntuació", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=combinacio_parentesis_altres_signes"}, {"gram": "GVB", "section": "15.12", "title": "Els claudàtors", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=claudators"}, {"gram": "GVB", "section": "15.13.1", "title": "Usos de les cometes", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=cometes"}, {"gram": "GNV", "section": "7.3.4", "title": "Els dos punts", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=dos_punts"}]}},
  {"type": "b1_fon_sillaba", "lesson": {"intro": "Aprendràs a separar paraules en síl·labes, a trobar la síl·laba tònica, a distingir diftongs i hiats i a pronunciar bé verbs com *estudia* o *canvia*.", "blocks": [{"title": "Síl·laba tònica i àtones", "text": "Cada síl·laba té una vocal. En les paraules de més d'una síl·laba, una sona **més forta**: la **tònica**. Les altres són **àtones**: en *ca-mi-sa*, la tònica és *-mi-*. Les paraules d'una síl·laba (*pa*, *sol*) són **monosíl·labs**.", "examples": ["En *ma-te-MÀ-ti-ques* hi ha **una tònica** i **quatre àtones**.", "Si canvia la tònica, canvia la paraula: ell *fa-BRI-ca* / la *FÀ-bri-ca*.", "Els adverbis en *-ment* conserven l'accent de l'adjectiu: *ràpida* → **ràpidament**."]}, {"title": "Agudes, planes i esdrúixoles", "text": "Segons on cau la tònica, la paraula és **aguda** (última síl·laba), **plana** (penúltima) o **esdrúixola** (antepenúltima). Les esdrúixoles sempre porten accent gràfic.", "table": {"head": ["aguda", "plana", "esdrúixola"], "rows": [["*ca-mi-ó*", "*e-xa-men*", "*fà-bri-ca*"], ["*Ra-mon*", "*fe-no-men*", "*mú-si-ca*"], ["*fa-reu*", "*fé-reu*", "*pà-gi-na*"], ["*pa-ís*", "*te-lè-fon*", "*nú-me-ro*"]]}}, {"title": "Diftongs i hiats", "text": "Un **diftong** és una vocal i una *i* o *u* en la **mateixa síl·laba**. És **decreixent** si la vocal va davant (*mai*, *peu*, *cui-na*) i **creixent** si va darrere (*qua-tre*, *ai-gua*). Un **hiat** són dos vocals en **síl·labes diferents**: *te-a-tre*, *po-e-ta*.", "table": {"head": ["paraula", "síl·labes", "per què"], "rows": [["*ou*", "*ou* (1)", "diftong *ou*"], ["*paraigua*", "*pa-rai-gua*", "dos diftongs"], ["*noia*", "*no-ia*", "*i* entre vocals"], ["*creuen*", "*cre-uen*", "*u* entre vocals"]]}}, {"title": "Accent i dièresi: hiat", "text": "Si la *i* o la *u* són **tòniques** darrere d'una altra vocal, no fan diftong. Ho marquen l'**accent** o la **dièresi**: *país* (*pa-ís*), *veïna* (*ve-ï-na*), *Raül* (*Ra-ül*).", "examples": ["La meua **veïna** és d'un altre **país**.", "**Raül** menja **raïm** cada dia."]}, {"title": "Verbs acabats en -iar", "text": "En verbs com *estudiar*, *canviar*, *enviar* o *copiar*, les formes que porten la força en l'arrel la porten en la *i*. Per això la *i* i la vocal següent fan **hiat**: *es-tu-DI-a* (4 síl·labes), *can-VI-a*, *co-PI-e*.", "examples": ["Ma germana **estudia** medicina.", "Ell **envia** una carta i jo la **copie**."], "watch": [{"wrong": "es-TU-dia", "right": "es-tu-DI-a"}, {"wrong": "CAN-via", "right": "can-VI-a"}]}], "remember": ["Aguda: tònica última; plana: penúltima; esdrúixola: antepenúltima.", "Diftong, una síl·laba (*mai*, *qua-tre*); hiat, dos (*te-a-tre*).", "L'accent i la dièresi marquen hiat: *pa-ís*, *ve-ï-na*.", "*Estudia*, *canvia*, *envia*: la força va en la *i*."], "sources": [{"gram": "GVB", "section": "5.1.1", "title": "Conceptes generals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=silaba"}, {"gram": "GVB", "section": "5.1.2", "title": "Normes de separació sil·làbica", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=silaba_normes_separacio"}, {"gram": "GVB", "section": "5.2.1", "title": "Conceptes bàsics", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=diftongs"}, {"gram": "GVB", "section": "5.2.2", "title": "Classificació dels diftongs", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=classificacio_diftongs"}, {"gram": "GVB", "section": "7.2", "title": "Regles generals d'accentuació", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=regles_generals_accentuacio"}, {"gram": "GVB", "section": "7.9", "title": "L'accentuació d'adverbis en ‑ment", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=accentuacio_adverbis_ment"}, {"gram": "GVB", "section": "8.1", "title": "Usos de la dièresi", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=usos_dieresi"}, {"gram": "GVB", "section": "3.3", "title": "L'accentuació", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=accentuacio_vacillacions"}, {"gram": "GVB", "section": "1.2.3.1", "title": "Pronunciacions recomanables", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=grups_vocalics"}, {"gram": "GNV", "section": "3.1.1", "title": "Conceptes generals", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=silaba"}, {"gram": "GNV", "section": "3.2.2", "title": "Classificació dels diftongs", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=classificacio_diftongs"}, {"gram": "GNV", "section": "1.5", "title": "L'accentuació", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=accentuacio_vacillacions"}]}},
  {"type": "b1_fon_vocals", "lesson": {"intro": "Aprendràs a escriure bé les vocals que es confonen (a/e, o/u), els canvis de vocal d'alguns verbs i la diferència entre vocals obertes i tancades.", "blocks": [{"title": "Confusions entre a i e", "text": "Algunes paraules s'escriuen amb *e* encara que sovint sonen [a], i altres s'escriuen amb *a* encara que de vegades sonen [e]. Fixa't en la forma escrita:", "table": {"head": ["s'escriuen amb e", "s'escriuen amb a"], "rows": [["*assemblea*", "*afaitar*"], ["*sergent*", "*ambaixada*"], ["*llençol*", "*avaria*"], ["*teranyina*, *Miquelet*", "*rancor*"]]}}, {"title": "Confusions entre o i u", "text": "S'escriuen amb *o*, encara que sovint sonen [u]: *Joan*, *Josep*, *cobert*, *collir*, *cosir*, *tossir*, *escopir*, *joguet*, *sofrir*, *complir*, *polsera*. En canvi, s'escriuen amb *u* *suportar*, *muntar* o *bufetada*.", "watch": [{"wrong": "Juan", "right": "Joan"}, {"wrong": "soportar", "right": "suportar"}]}, {"title": "Paraules començades per e-", "text": "Les paraules començades per *em-*, *en-*, *es-* i *eix-* s'escriuen amb *e*, encara que en la parla moltes sonen [a]: *embastar*, *enfadar-se*, *entendre*, *estendre*, *escoltar*, *eixir*, *eixugar*.", "watch": [{"wrong": "aixugar la roba", "right": "eixugar la roba"}, {"wrong": "ascoltar música", "right": "escoltar música"}]}, {"title": "Verbs que canvien la vocal", "text": "En verbs com *llegir*, *eixir*, *cosir* o *collir*, la síl·laba **tònica** porta *i* o *u*, i l'**àtona**, *e* o *o*. *Poder* i *voler* també alternen, però sense una regla fixa: *puc* / *pot*, *vullga* / *volia*.", "table": {"head": ["tònica: i, u", "àtona: e, o"], "rows": [["*llig*, *lligen*", "*llegim*, *llegir*"], ["*ix*, *ixes*", "*eixim*, *eixir*"], ["*cus*, *cusen*", "*cosim*, *cosir*"], ["*cull*, *cullen*", "*collim*, *collir*"], ["*tus*, *escup*", "*tossim*, *escopim*"]]}, "examples": ["Jo no **puc** vindre, però ella sí que **pot**."]}, {"title": "Vocals obertes i tancades", "text": "La *e* i la *o* tòniques poden ser **obertes** o **tancades**, i això canvia el significat: *set* (número, oberta) i *set* (ganes de beure, tancada). L'accent **greu** marca les obertes, i l'**agut**, les tancades. La *à* sempre porta greu.", "table": {"head": ["accent", "exemples"], "rows": [["*à*, sempre greu", "*sofà*, *àvia*"], ["*è*, *ò*: oberta", "*mèrit*, *història*, *això*"], ["*é*, *ó*: tancada", "*també*, *cançó*, *església*"], ["*í*, *ú*, sempre agut", "*camí*, *útil*"]]}, "examples": ["*Què*, *perquè* i *València* porten **accent greu**, però la *e* és tancada."]}], "remember": ["*Joan*, *Josep*, *cobert*: amb *o*, encara que sonen [u].", "*Entendre*, *estendre*, *eixugar*: comencen per *e*.", "Tònica amb *i* o *u*, àtona amb *e* o *o*: *llig* / *llegim*.", "Accent greu, vocal oberta; accent agut, vocal tancada."], "sources": [{"gram": "GVB", "section": "1.2.1", "title": "Les vocals tòniques", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=vocals_toniques"}, {"gram": "GVB", "section": "1.2.2.1", "title": "Pronunciacions recomanables", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=vocals_atones"}, {"gram": "GVB", "section": "1.2.2.2", "title": "Pronunciacions acceptables", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=vocals_atones"}, {"gram": "GVB", "section": "6.2", "title": "Les grafies a i e", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=grafies_a_e"}, {"gram": "GVB", "section": "6.3", "title": "Les grafies o i u", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=grafies_o_u"}, {"gram": "GVB", "section": "7.1", "title": "Introducció", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=accent_grafic"}, {"gram": "GVB", "section": "7.3", "title": "L'accentuació de les vocals e i o", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=accentuacio_e_o"}, {"gram": "GVB", "section": "7.4", "title": "Observacions sobre l'accentuació de la vocal e", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GVB&index=accent_grafic"}, {"gram": "GNV", "section": "1.2.1.2", "title": "Criteris generals de pronunciació", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=vocals_toniques"}, {"gram": "GNV", "section": "1.2.2.3", "title": "Criteris particulars de pronunciació", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=vocals_atones"}, {"gram": "GNV", "section": "30.2.1", "title": "Verbs amb alternances vocàliques en el radical", "url": "https://www.avl.gva.es/gnv/buscador.jsp?gramatica=GNV&index=irregularitats_morfologiques"}]}}
]$data$::jsonb) AS l(type text, lesson jsonb)
WHERE r.category = 'fonetica_ortografia' AND r.type = l.type;

-- ============================================================
-- Origen: 20261001190000_correccio_exercicis_fonetica_avl.sql
-- ============================================================
-- Correcció dels exercicis B1 de Fonètica, elocució i ortografia que contradeien
-- les gramàtiques de l'AVL (GVB i GNV, en assets-src/avl/), detectats en redactar
-- les lliçons fixes («Aprendre lliçó»). Cada fila substituïx l'enunciat, les
-- opcions, les respostes i l'explicació de l'exercici (recurs, nivell, posició).
-- La resposta correcta va primer. Tornar a aplicar el fitxer no canvia res més.

UPDATE public.practice_exercises e SET
  prompt = f.prompt,
  options = CASE WHEN f.options IS NULL OR jsonb_typeof(f.options) = 'null' THEN NULL ELSE ARRAY(SELECT jsonb_array_elements_text(f.options)) END,
  answers = ARRAY(SELECT jsonb_array_elements_text(f.answers)),
  explanation = f.explanation
FROM jsonb_to_recordset($data$[
  {"type": "b1_fon_puntuacio", "pos": 25,
   "prompt": "Quina frase usa bé el punt i coma en una llista de dades?",
   "options": ["Han vingut Joan, de Gandia; Marta, d'Alcoi, i Pere, de Xàtiva.", "Han vingut Joan; de Gandia, Marta; d'Alcoi, i Pere; de Xàtiva.", "Han vingut; Joan, de Gandia, Marta, d'Alcoi, i Pere, de Xàtiva."], "answers": ["Han vingut Joan, de Gandia; Marta, d'Alcoi, i Pere, de Xàtiva."],
   "explanation": "El punt i coma separa grups que ja porten comes, excepte l'últim element precedit de i, que va amb coma (GVB 15.4)."},
  {"type": "b1_fon_puntuacio", "pos": 5,
   "prompt": "Quina frase usa bé els dos punts per a una cita?",
   "options": ["Ma mare va dir: «Torna prompte».", "Ma mare: va dir «Torna prompte».", "Ma mare va: dir «Torna prompte»."], "answers": ["Ma mare va dir: «Torna prompte»."],
   "explanation": "Els dos punts introduïxen la cita. Com que les cometes s'obrin dins de la frase, el punt va darrere de les cometes de tancament (GVB 15.6 i 15.13.2)."},
  {"type": "b1_fon_puntuacio", "pos": 13,
   "prompt": "Què indiquen els punts suspensius entre claudàtors [...] dins d'una cita?",
   "options": ["Que s'ha omés un tros del text", "Que l'autor dubtava", "Que la cita és falsa"], "answers": ["Que s'ha omés un tros del text"],
   "explanation": "Dins d'una cita, els punts suspensius entre claudàtors, [...], indiquen que se n'ha omés una part (GVB 15.7 i 15.12)."},
  {"type": "b1_fon_majuscules", "pos": 31,
   "prompt": "Quina és correcta?",
   "options": ["Han aprovat la llei en les Corts valencianes.", "Han aprovat la Llei en les corts valencianes.", "Han aprovat la llei en les corts Valencianes."], "answers": ["Han aprovat la llei en les Corts valencianes."],
   "explanation": "Corts, com a nom de la institució, va amb majúscula; l'adjectiu valencianes, en minúscula (GVB 12.17). La paraula llei, si no és el títol d'una llei concreta, va en minúscula."},
  {"type": "b1_fon_majuscules", "pos": 32,
   "prompt": "Quina és correcta?",
   "options": ["Cada ajuntament té el seu pressupost.", "Cada Ajuntament té el seu Pressupost.", "cada ajuntament té el seu pressupost."], "answers": ["Cada ajuntament té el seu pressupost."],
   "explanation": "Quan ajuntament s'usa en sentit general, va en minúscula; amb majúscula només quan es referix a una institució concreta: l'Ajuntament d'Alzira (GVB 12.16). La frase comença amb majúscula."},
  {"type": "b1_fon_vocals", "pos": 37,
   "prompt": "Quina parella es distingix per la e oberta / e tancada?",
   "options": ["set (el número 7) / set (ganes de beure)", "dona / dones", "porta / portes"], "answers": ["set (el número 7) / set (ganes de beure)"],
   "explanation": "Set, el número, té e oberta [ɛ]; set, les ganes de beure, e tancada [e]. En canvi, sòl i sol tenen totes dues o oberta: l'accent de sòl és diacrític (GVB 7.7)."},
  {"type": "b1_fon_alfabet", "pos": 35,
   "prompt": "Quina d'estes paraules té el dígraf «ig»?",
   "options": ["roig", "rotg", "roitg"], "answers": ["roig"],
   "explanation": "El dígraf ig representa el so final de roig, lleig o maig (GVB 4.2). En canvi, en peix o caixa la i forma part del grup ix, que l'AVL no compta com a dígraf."},
  {"type": "b1_fon_elocucio", "pos": 14,
   "prompt": "La z de «zero» o «onze» en valencià sona...",
   "options": ["sonora, com la s de «casa»", "com la z castellana de «zapato»", "muda"], "answers": ["sonora, com la s de «casa»"],
   "explanation": "La z valenciana és sonora [z], com la s entre vocals de casa o rosa. La tz de dotze o tretze sona [dz] (GVB 6.15 i 6.16)."},
  {"type": "b1_fon_elocucio", "pos": 5,
   "prompt": "En «Està a casa», com sona la seqüència «està a»?",
   "options": ["Les dues a es reduïxen a una sola", "Es pronuncia «estàs a»", "S'hi afig una e"], "answers": ["Les dues a es reduïxen a una sola"],
   "explanation": "Quan dues vocals iguals queden en contacte entre paraules, en la parla se'n pronuncia només una: està_a casa (GVB 3.1)."},
  {"type": "b1_fon_elocucio", "pos": 38,
   "prompt": "En molts parlars, quina consonant no es pronuncia en «camp»?",
   "options": null, "answers": ["p"],
   "explanation": "En els parlars on és propi, és acceptable no pronunciar la p de -mp final: camp [kam]. Però sempre s'escriu (GNV 1.3.2.1)."}
]$data$::jsonb) AS f(type text, pos smallint, prompt text, options jsonb, answers jsonb, explanation text)
WHERE e.level = 'B1'
  AND e.position = f.pos
  AND e.resource_id = (SELECT r.id FROM public.resources r WHERE r.category = 'fonetica_ortografia' AND r.type = f.type);

-- ============================================================
-- Origen: 20261001200000_escenaris_backgrounds.sql
-- ============================================================
-- Foto de fons (resources.metadata.background) per als escenaris que encara
-- no en tenien: les noves imatges a frontend/public/images/, triades segons
-- la situació de cada escenari. 'taller' es queda sense foto: no hi ha cap
-- imatge de taller mecànic entre les noves. Tornar a aplicar el fitxer no
-- duplica res (és un UPDATE idempotent).

UPDATE public.resources SET metadata = jsonb_set(metadata, '{background}', '"/images/house_party.jpg"'::jsonb, true)
  WHERE category = 'escenari' AND type = 'a2_identificacio'; -- festa d'aniversari de Núria

UPDATE public.resources SET metadata = jsonb_set(metadata, '{background}', '"/images/flat.jpg"'::jsonb, true)
  WHERE category = 'escenari' AND type = 'a2_casa'; -- el pis nou de Xavi

UPDATE public.resources SET metadata = jsonb_set(metadata, '{background}', '"/images/gym.jpg"'::jsonb, true)
  WHERE category = 'escenari' AND type = 'a2_activitats'; -- Toni, amic del gimnàs

UPDATE public.resources SET metadata = jsonb_set(metadata, '{background}', '"/images/street.jpg"'::jsonb, true)
  WHERE category = 'escenari' AND type = 'a2_faena'; -- et trobes Sílvia pel carrer

UPDATE public.resources SET metadata = jsonb_set(metadata, '{background}', '"/images/restaurant.jpg"'::jsonb, true)
  WHERE category = 'escenari' AND type = 'a2_menjar'; -- reserva al restaurant L'Albufera

UPDATE public.resources SET metadata = jsonb_set(metadata, '{background}', '"/images/mall.jpg"'::jsonb, true)
  WHERE category = 'escenari' AND type = 'a2_servicis'; -- grans magatzems

UPDATE public.resources SET metadata = jsonb_set(metadata, '{background}', '"/images/ireland.jpg"'::jsonb, true)
  WHERE category = 'escenari' AND type = 'a2_clima'; -- Liam, amic irlandés

UPDATE public.resources SET metadata = jsonb_set(metadata, '{background}', '"/images/hotel.jpg"'::jsonb, true)
  WHERE category = 'escenari' AND type = 'a2_viatges'; -- reserva a l'Hotel Mar Blau

UPDATE public.resources SET metadata = jsonb_set(metadata, '{background}', '"/images/pharmacy.jpg"'::jsonb, true)
  WHERE category = 'escenari' AND type = 'farmacia';

UPDATE public.resources SET metadata = jsonb_set(metadata, '{background}', '"/images/forn.jpg"'::jsonb, true)
  WHERE category = 'escenari' AND type = 'forn';

