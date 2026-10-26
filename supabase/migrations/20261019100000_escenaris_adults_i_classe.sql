-- Migració agrupada: 20261019100000_escenaris_adults_i_classe
-- Conté, per ordre, les 13 migracions originals següents:
--   20261019100000_escenari_adults_n0_ajuntament
--   20261019110000_escenari_adults_n0_taller
--   20261019120000_escenari_adults_n0_fruiteria
--   20261019130000_escenari_b2_gent_background
--   20261019140000_escenari_b2_cultura_llengua_background
--   20261019150000_escenari_c1_relacions_background
--   20261019160000_escenari_c1_temps_lliure_background
--   20261019170000_escenari_c1_comerc_background
--   20261019180000_escenari_c1_economia_background
--   20261019190000_escenari_c1_medi_clima_background
--   20261019200000_escenari_c1_sociocultural_background
--   20261019210000_entrada_amb_codi_de_classe
--   20261019220000_classe_fixa_sense_compte

-- ============================================================
-- Origen: 20261019100000_escenari_adults_n0_ajuntament.sql
-- ============================================================
-- Escenari de conversa per a persones ADULTES del Nivell 0 (principiants absoluts): «A l'ajuntament».
-- Rosa, funcionària de l'ajuntament, atén una persona que no sap res de valencià: frases molt curtes,
-- una sola pregunta per torn i opcions que l'aprenent pot repetir. No és un escenari infantil:
-- metadata.audience = 'adult' (els infantils, sense la marca, només els fan els xiquets). Inclou les
-- traduccions per als subtítols de la llengua materna (metadata.translations) i la salutació en àudio
-- (metadata.greeting_audio, es genera amb `npx tsx scripts/generate-scenario-audio.ts` a backend/).
-- Tornar a aplicar el fitxer no el duplica (ON CONFLICT per id).

INSERT INTO public.resources (id, name, type, category, content, difficulty, xp_earned, sort_order, metadata)
VALUES (
  '8e2b4d67-3a19-4f5c-b7d0-6c1a9e5f2b43',
  'A l''ajuntament',
  'n0_ajuntament',
  'escenari',
  'Vas a l''ajuntament i Rosa, la funcionària, t''ajuda. Parla poc a poc i amb frases molt curtes.',
  'nivell0',
  10,
  1,
  jsonb_build_object(
    'audience', 'adult',
    'icon', '🏛️',
    'color', '#BBDEFB',
    'bgIllustration', '#E3F2FD',
    'background', '/images/townhall.jpg',
    'voice', 'gina',
    'scenario', 'n0_ajuntament',
    'character', 'Rosa, funcionària de l''ajuntament',
    'character_role', 'Funcionària',
    'section_name', 'A l''ajuntament',
    'initial_prompt', 'Bon dia! Soc Rosa. Ací és l''ajuntament. Em dius com et diuen?',
    'greeting_audio', '/audio/scenarios/n0_ajuntament-salutacio.wav',
    'objectius', jsonb_build_array(
      'Saludar: «Bon dia».',
      'Dir com et diuen: «Em diuen...».',
      'Dir de quin país ets: «Soc de...».',
      'Demanar un paper o una cita: «Vull un paper, per favor».',
      'Donar les gràcies i acomiadar-se: «Gràcies. Adéu».'
    ),
    'system_prompt',
      'Ets Rosa, una funcionària de l''ajuntament molt amable i molt pacient. Parles amb una persona adulta que NO sap res de valencià (principiant absolut, Nivell 0). ' ||
      'Parla sempre en valencià MOLT senzill: frases de 3 a 7 paraules, present d''indicatiu, paraules molt freqüents, sense subordinades ni expressions fetes. ' ||
      'Fes sempre UNA sola pregunta xicoteta per torn i espera la resposta. Tracta-la de tu. ' ||
      'Si l''aprenent no t''entén o es queda callat, repeteix la frase més lentament amb altres paraules, ensenya-li què pot dir i fes-li repetir la frase («Digues: Bon dia») o ofereix-li dues opcions («Vols un paper o una cita?»). ' ||
      'Si respon en castellà, en anglés o en una altra llengua, entén-lo, diu-li en valencià el que ha volgut dir amb una frase curta i demana-li que ho repetisca en valencià. ' ||
      'Guia la situació pas a pas: saluda i pregunta com es diu (pot dir un nom inventat); pregunta de quin país és; demana què vol (un paper o una cita, tria entre les dues coses); quan ho demane, digues-li «Un moment, per favor» i dona-li el paper o digues-li el dia de la cita ("dilluns", "dimarts"...); ' ||
      'al final, anima''l a dir gràcies i adéu. Celebra cada intent amb alegria («Molt bé!», «Perfecte!»). ' ||
      'Mai no ixes del personatge ni fas lliçons de gramàtica. No demanes dades personals reals (adreça, telèfon, DNI): si cal, que invente la dada. ' ||
      'Quan haja complit els objectius (saludar, dir com es diu, dir de quin país és, demanar un paper o una cita, i donar les gràcies i acomiadar-se), tanca la situació amb naturalitat i acomiada''t.',
    'translations', $json$
    {
      "es": {
        "content": "Vas al ayuntamiento y Rosa, la funcionaria, te ayuda. Habla despacio y con frases muy cortas.",
        "initial_prompt": "¡Buenos días! Soy Rosa. Esto es el ayuntamiento. ¿Me dices cómo te llamas?",
        "objectius": [
          "Saludar: «Bon dia».",
          "Decir cómo te llamas: «Em diuen...».",
          "Decir de qué país eres: «Soc de...».",
          "Pedir un papel o una cita: «Vull un paper, per favor».",
          "Dar las gracias y despedirse: «Gràcies. Adéu»."
        ]
      },
      "en": {
        "content": "You go to the town hall and Rosa, the clerk, helps you. She speaks slowly and with very short sentences.",
        "initial_prompt": "Good morning! I'm Rosa. This is the town hall. Can you tell me your name?",
        "objectius": [
          "Say hello: «Bon dia».",
          "Say your name: «Em diuen...».",
          "Say which country you are from: «Soc de...».",
          "Ask for a document or an appointment: «Vull un paper, per favor».",
          "Say thank you and goodbye: «Gràcies. Adéu»."
        ]
      },
      "fr": {
        "content": "Tu vas à la mairie et Rosa, la fonctionnaire, t'aide. Elle parle lentement et avec des phrases très courtes.",
        "initial_prompt": "Bonjour ! Je suis Rosa. Ici, c'est la mairie. Tu peux me dire comment tu t'appelles ?",
        "objectius": [
          "Dire bonjour : «Bon dia».",
          "Dire comment tu t'appelles : «Em diuen...».",
          "Dire de quel pays tu es : «Soc de...».",
          "Demander un document ou un rendez-vous : «Vull un paper, per favor».",
          "Dire merci et au revoir : «Gràcies. Adéu»."
        ]
      },
      "it": {
        "content": "Vai in comune e Rosa, l'impiegata, ti aiuta. Parla piano e con frasi molto brevi.",
        "initial_prompt": "Buongiorno! Sono Rosa. Questo è il comune. Mi dici come ti chiami?",
        "objectius": [
          "Salutare: «Bon dia».",
          "Dire come ti chiami: «Em diuen...».",
          "Dire di che paese sei: «Soc de...».",
          "Chiedere un documento o un appuntamento: «Vull un paper, per favor».",
          "Ringraziare e salutare: «Gràcies. Adéu»."
        ]
      },
      "ro": {
        "content": "Mergi la primărie și Rosa, funcționara, te ajută. Vorbește rar și cu propoziții foarte scurte.",
        "initial_prompt": "Bună ziua! Sunt Rosa. Aici este primăria. Îmi spui cum te cheamă?",
        "objectius": [
          "Să salute: «Bon dia».",
          "Să spună cum îl cheamă: «Em diuen...».",
          "Să spună din ce țară este: «Soc de...».",
          "Să ceară un act sau o programare: «Vull un paper, per favor».",
          "Să mulțumească și să-și ia rămas-bun: «Gràcies. Adéu»."
        ]
      },
      "uk": {
        "content": "Ти йдеш до міської ради, і Роза, службовиця, допомагає тобі. Вона говорить повільно й дуже короткими реченнями.",
        "initial_prompt": "Добрий день! Я Роза. Це міська рада. Скажеш, як тебе звати?",
        "objectius": [
          "Привітатися: «Bon dia».",
          "Сказати, як тебе звати: «Em diuen...».",
          "Сказати, з якої ти країни: «Soc de...».",
          "Попросити документ або запис на прийом: «Vull un paper, per favor».",
          "Подякувати й попрощатися: «Gràcies. Adéu»."
        ]
      }
    }
    $json$::jsonb
  )
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  type = EXCLUDED.type,
  category = EXCLUDED.category,
  content = EXCLUDED.content,
  difficulty = EXCLUDED.difficulty,
  xp_earned = EXCLUDED.xp_earned,
  sort_order = EXCLUDED.sort_order,
  metadata = EXCLUDED.metadata;

-- ============================================================
-- Origen: 20261019110000_escenari_adults_n0_taller.sql
-- ============================================================
-- Escenari de conversa per a persones ADULTES del Nivell 0 (principiants absoluts): «Al taller mecànic».
-- Toni, el mecànic, atén una persona que no sap res de valencià: frases molt curtes, una sola pregunta
-- per torn i opcions que l'aprenent pot repetir (colors, el problema del cotxe, els dies). Com l'escenari
-- de l'ajuntament del Nivell 0, porta metadata.audience = 'adult' (els infantils, sense la marca, només
-- els fan els xiquets) i les traduccions per als subtítols de la llengua materna (metadata.translations).
-- La salutació en àudio (metadata.greeting_audio) es genera amb
-- `npx tsx scripts/generate-scenario-audio.ts` a backend/. Tornar a aplicar el fitxer no el duplica.

INSERT INTO public.resources (id, name, type, category, content, difficulty, xp_earned, sort_order, metadata)
VALUES (
  'c4a7e913-5d28-4b6f-8a01-2f9d7b3e6c58',
  'Al taller mecànic',
  'n0_taller',
  'escenari',
  'Tens un problema amb el cotxe i vas al taller. Toni, el mecànic, t''ajuda. Parla poc a poc i amb frases molt curtes.',
  'nivell0',
  10,
  2,
  jsonb_build_object(
    'audience', 'adult',
    'icon', '🔧',
    'color', '#B0BEC5',
    'bgIllustration', '#ECEFF1',
    'background', '/images/car_workshop.jpg',
    'voice', 'lluc',
    'scenario', 'n0_taller',
    'character', 'Toni, mecànic del taller',
    'character_role', 'Mecànic',
    'section_name', 'Al taller mecànic',
    'initial_prompt', 'Bon dia! Soc Toni. Ací és el taller. Què passa amb el cotxe?',
    'greeting_audio', '/audio/scenarios/n0_taller-salutacio.wav',
    'objectius', jsonb_build_array(
      'Saludar: «Bon dia».',
      'Dir quin cotxe tens i de quin color és: «Tinc un cotxe blanc».',
      'Dir què passa amb el cotxe: «No funciona» o «Fa soroll».',
      'Dir quin dia el vols: «Dimarts, per favor».',
      'Donar les gràcies i acomiadar-se: «Gràcies. Adéu».'
    ),
    'system_prompt',
      'Ets Toni, un mecànic molt amable i molt pacient que treballa en un taller. Parles amb una persona adulta que NO sap res de valencià (principiant absolut, Nivell 0). ' ||
      'Parla sempre en valencià MOLT senzill: frases de 3 a 7 paraules, present d''indicatiu, paraules molt freqüents, sense subordinades ni expressions fetes. ' ||
      'Fes sempre UNA sola pregunta xicoteta per torn i espera la resposta. Tracta-la de tu. ' ||
      'Si l''aprenent no t''entén o es queda callat, repeteix la frase més lentament amb altres paraules, ensenya-li què pot dir i fes-li repetir la frase («Digues: Bon dia») o ofereix-li dues opcions («El cotxe és blanc o roig?»). ' ||
      'Si respon en castellà, en anglés o en una altra llengua, entén-lo, diu-li en valencià el que ha volgut dir amb una frase curta i demana-li que ho repetisca en valencià. ' ||
      'Guia la situació pas a pas: saluda i pregunta què passa amb el cotxe; pregunta de quin color és el cotxe (ofereix dos colors: blanc, roig, blau, negre, gris); ' ||
      'pregunta què li passa («No funciona o fa soroll?»); digues que ho mirareu i pregunta quin dia el vol («Dilluns o dimarts?») amb els dies de la setmana; ' ||
      'al final, anima''l a dir gràcies i adéu. Pots dir un preu amb una xifra senzilla («Cent euros»), però no cal que l''entenga. Celebra cada intent amb alegria («Molt bé!», «Perfecte!»). ' ||
      'Mai no ixes del personatge ni fas lliçons de gramàtica. No demanes dades personals reals (matrícula, telèfon, adreça): si cal, que invente la dada. ' ||
      'Quan haja complit els objectius (saludar, dir quin cotxe té i de quin color, dir què passa, dir quin dia el vol, i donar les gràcies i acomiadar-se), tanca la situació amb naturalitat i acomiada''t.',
    'translations', $json$
    {
      "es": {
        "content": "Tienes un problema con el coche y vas al taller. Toni, el mecánico, te ayuda. Habla despacio y con frases muy cortas.",
        "initial_prompt": "¡Buenos días! Soy Toni. Esto es el taller. ¿Qué le pasa al coche?",
        "objectius": [
          "Saludar: «Bon dia».",
          "Decir qué coche tienes y de qué color es: «Tinc un cotxe blanc».",
          "Decir qué le pasa al coche: «No funciona» o «Fa soroll».",
          "Decir qué día lo quieres: «Dimarts, per favor».",
          "Dar las gracias y despedirse: «Gràcies. Adéu»."
        ]
      },
      "en": {
        "content": "You have a problem with your car and go to the garage. Toni, the mechanic, helps you. He speaks slowly and with very short sentences.",
        "initial_prompt": "Good morning! I'm Toni. This is the garage. What's wrong with the car?",
        "objectius": [
          "Say hello: «Bon dia».",
          "Say what car you have and what color it is: «Tinc un cotxe blanc».",
          "Say what is wrong with the car: «No funciona» or «Fa soroll».",
          "Say which day you want it: «Dimarts, per favor».",
          "Say thank you and goodbye: «Gràcies. Adéu»."
        ]
      },
      "fr": {
        "content": "Tu as un problème avec ta voiture et tu vas au garage. Toni, le mécanicien, t'aide. Il parle lentement et avec des phrases très courtes.",
        "initial_prompt": "Bonjour ! Je suis Toni. Ici, c'est le garage. Qu'est-ce qu'elle a, la voiture ?",
        "objectius": [
          "Dire bonjour : «Bon dia».",
          "Dire quelle voiture tu as et de quelle couleur elle est : «Tinc un cotxe blanc».",
          "Dire ce qui ne va pas avec la voiture : «No funciona» ou «Fa soroll».",
          "Dire quel jour tu la veux : «Dimarts, per favor».",
          "Dire merci et au revoir : «Gràcies. Adéu»."
        ]
      },
      "it": {
        "content": "Hai un problema con l'auto e vai in officina. Toni, il meccanico, ti aiuta. Parla piano e con frasi molto brevi.",
        "initial_prompt": "Buongiorno! Sono Toni. Questa è l'officina. Cos'ha l'auto?",
        "objectius": [
          "Salutare: «Bon dia».",
          "Dire che auto hai e di che colore è: «Tinc un cotxe blanc».",
          "Dire cosa ha l'auto: «No funciona» o «Fa soroll».",
          "Dire che giorno la vuoi: «Dimarts, per favor».",
          "Ringraziare e salutare: «Gràcies. Adéu»."
        ]
      },
      "ro": {
        "content": "Ai o problemă cu mașina și mergi la atelier. Toni, mecanicul, te ajută. Vorbește rar și cu propoziții foarte scurte.",
        "initial_prompt": "Bună ziua! Sunt Toni. Aici este atelierul. Ce are mașina?",
        "objectius": [
          "Să salute: «Bon dia».",
          "Să spună ce mașină are și de ce culoare este: «Tinc un cotxe blanc».",
          "Să spună ce are mașina: «No funciona» sau «Fa soroll».",
          "Să spună în ce zi o vrea: «Dimarts, per favor».",
          "Să mulțumească și să-și ia rămas-bun: «Gràcies. Adéu»."
        ]
      },
      "uk": {
        "content": "У тебе проблема з машиною, і ти йдеш в автомайстерню. Тоні, механік, допомагає тобі. Він говорить повільно й дуже короткими реченнями.",
        "initial_prompt": "Добрий день! Я Тоні. Це майстерня. Що з машиною?",
        "objectius": [
          "Привітатися: «Bon dia».",
          "Сказати, яка в тебе машина і якого вона кольору: «Tinc un cotxe blanc».",
          "Сказати, що з машиною: «No funciona» або «Fa soroll».",
          "Сказати, в який день тобі потрібна: «Dimarts, per favor».",
          "Подякувати й попрощатися: «Gràcies. Adéu»."
        ]
      }
    }
    $json$::jsonb
  )
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  type = EXCLUDED.type,
  category = EXCLUDED.category,
  content = EXCLUDED.content,
  difficulty = EXCLUDED.difficulty,
  xp_earned = EXCLUDED.xp_earned,
  sort_order = EXCLUDED.sort_order,
  metadata = EXCLUDED.metadata;

-- ============================================================
-- Origen: 20261019120000_escenari_adults_n0_fruiteria.sql
-- ============================================================
-- Escenari de conversa per a persones ADULTES del Nivell 0 (principiants absoluts): «A la fruiteria».
-- Josep, el fruiter, atén una persona que no sap res de valencià: frases molt curtes, una sola
-- pregunta per torn i opcions que l'aprenent pot repetir (fruites, nombres de l'1 al 5, preu). Com els
-- altres escenaris adults del Nivell 0, porta metadata.audience = 'adult' (els infantils, sense la marca,
-- només els fan els xiquets) i les traduccions per als subtítols de la llengua materna
-- (metadata.translations). La salutació en àudio (metadata.greeting_audio) es genera amb
-- `npx tsx scripts/generate-scenario-audio.ts` a backend/. Tornar a aplicar el fitxer no el duplica.

INSERT INTO public.resources (id, name, type, category, content, difficulty, xp_earned, sort_order, metadata)
VALUES (
  'b6d3f812-7e45-4a9c-9c20-4a8e1d5b7f63',
  'A la fruiteria',
  'n0_fruiteria',
  'escenari',
  'Vas a la fruiteria a comprar fruita. Josep, el fruiter, t''ajuda. Parla poc a poc i amb frases molt curtes.',
  'nivell0',
  10,
  3,
  jsonb_build_object(
    'audience', 'adult',
    'icon', '🍎',
    'color', '#FFCCBC',
    'bgIllustration', '#FBE9E7',
    'background', '/images/market.jpg',
    'voice', 'lluc',
    'scenario', 'n0_fruiteria',
    'character', 'Josep, fruiter',
    'character_role', 'Fruiter',
    'section_name', 'A la fruiteria',
    'initial_prompt', 'Bon dia! Soc Josep. Ací és la fruiteria. Què vols?',
    'greeting_audio', '/audio/scenarios/n0_fruiteria-salutacio.wav',
    'objectius', jsonb_build_array(
      'Saludar: «Bon dia».',
      'Demanar una fruita: «Vull una poma».',
      'Dir quantes en vols: «Dues, per favor».',
      'Preguntar el preu: «Quant és?».',
      'Donar les gràcies i acomiadar-se: «Gràcies. Adéu».'
    ),
    'system_prompt',
      'Ets Josep, un fruiter molt amable i molt pacient que té una fruiteria. Parles amb una persona adulta que NO sap res de valencià (principiant absolut, Nivell 0). ' ||
      'Parla sempre en valencià MOLT senzill: frases de 3 a 7 paraules, present d''indicatiu, paraules molt freqüents, sense subordinades ni expressions fetes. ' ||
      'Fes sempre UNA sola pregunta xicoteta per torn i espera la resposta. Tracta-la de tu. ' ||
      'Si l''aprenent no t''entén o es queda callat, repeteix la frase més lentament amb altres paraules, ensenya-li què pot dir i fes-li repetir la frase («Digues: Vull una poma») o ofereix-li dues opcions («Pomes o taronges?»). ' ||
      'Si respon en castellà, en anglés o en una altra llengua, entén-lo, diu-li en valencià el que ha volgut dir amb una frase curta i demana-li que ho repetisca en valencià. ' ||
      'A la fruiteria hi ha: pomes, taronges, plàtans, peres, raïm, síndria i maduixes. ' ||
      'Guia la situació pas a pas: saluda i pregunta què vol (ofereix dues fruites); pregunta quantes en vol («Quantes? Una, dues, tres?»; només els nombres de l''1 al 5); ' ||
      'quan ho haja dit, pregunta si vol res més i, després, ensenya-li a preguntar el preu («Digues: Quant és?») i respon amb una xifra senzilla («Són tres euros»); ' ||
      'al final, anima''l a dir gràcies i adéu. Celebra cada intent amb alegria («Molt bé!», «Perfecte!»). ' ||
      'Mai no ixes del personatge ni fas lliçons de gramàtica. No demanes dades personals reals. ' ||
      'Quan haja complit els objectius (saludar, demanar una fruita, dir quantes en vol, preguntar el preu, i donar les gràcies i acomiadar-se), tanca la situació amb naturalitat i acomiada''t.',
    'translations', $json$
    {
      "es": {
        "content": "Vas a la frutería a comprar fruta. Josep, el frutero, te ayuda. Habla despacio y con frases muy cortas.",
        "initial_prompt": "¡Buenos días! Soy Josep. Esto es la frutería. ¿Qué quieres?",
        "objectius": [
          "Saludar: «Bon dia».",
          "Pedir una fruta: «Vull una poma».",
          "Decir cuántas quieres: «Dues, per favor».",
          "Preguntar el precio: «Quant és?».",
          "Dar las gracias y despedirse: «Gràcies. Adéu»."
        ]
      },
      "en": {
        "content": "You go to the fruit shop to buy fruit. Josep, the fruit seller, helps you. He speaks slowly and with very short sentences.",
        "initial_prompt": "Good morning! I'm Josep. This is the fruit shop. What do you want?",
        "objectius": [
          "Say hello: «Bon dia».",
          "Ask for a fruit: «Vull una poma».",
          "Say how many you want: «Dues, per favor».",
          "Ask the price: «Quant és?».",
          "Say thank you and goodbye: «Gràcies. Adéu»."
        ]
      },
      "fr": {
        "content": "Tu vas chez le marchand de fruits pour acheter des fruits. Josep, le marchand, t'aide. Il parle lentement et avec des phrases très courtes.",
        "initial_prompt": "Bonjour ! Je suis Josep. Ici, c'est la fruiterie. Qu'est-ce que tu veux ?",
        "objectius": [
          "Dire bonjour : «Bon dia».",
          "Demander un fruit : «Vull una poma».",
          "Dire combien tu en veux : «Dues, per favor».",
          "Demander le prix : «Quant és?».",
          "Dire merci et au revoir : «Gràcies. Adéu»."
        ]
      },
      "it": {
        "content": "Vai dal fruttivendolo a comprare della frutta. Josep, il fruttivendolo, ti aiuta. Parla piano e con frasi molto brevi.",
        "initial_prompt": "Buongiorno! Sono Josep. Questa è la fruttivendola. Cosa vuoi?",
        "objectius": [
          "Salutare: «Bon dia».",
          "Chiedere un frutto: «Vull una poma».",
          "Dire quanti ne vuoi: «Dues, per favor».",
          "Chiedere il prezzo: «Quant és?».",
          "Ringraziare e salutare: «Gràcies. Adéu»."
        ]
      },
      "ro": {
        "content": "Mergi la fructărie să cumperi fructe. Josep, fructarul, te ajută. Vorbește rar și cu propoziții foarte scurte.",
        "initial_prompt": "Bună ziua! Sunt Josep. Aici este fructăria. Ce dorești?",
        "objectius": [
          "Să salute: «Bon dia».",
          "Să ceară un fruct: «Vull una poma».",
          "Să spună câte vrea: «Dues, per favor».",
          "Să întrebe prețul: «Quant és?».",
          "Să mulțumească și să-și ia rămas-bun: «Gràcies. Adéu»."
        ]
      },
      "uk": {
        "content": "Ти йдеш у фруктову крамницю купити фрукти. Жузеп, продавець, допомагає тобі. Він говорить повільно й дуже короткими реченнями.",
        "initial_prompt": "Добрий день! Я Жузеп. Це фруктова крамниця. Що ти хочеш?",
        "objectius": [
          "Привітатися: «Bon dia».",
          "Попросити фрукт: «Vull una poma».",
          "Сказати, скільки хочеш: «Dues, per favor».",
          "Запитати ціну: «Quant és?».",
          "Подякувати й попрощатися: «Gràcies. Adéu»."
        ]
      }
    }
    $json$::jsonb
  )
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  type = EXCLUDED.type,
  category = EXCLUDED.category,
  content = EXCLUDED.content,
  difficulty = EXCLUDED.difficulty,
  xp_earned = EXCLUDED.xp_earned,
  sort_order = EXCLUDED.sort_order,
  metadata = EXCLUDED.metadata;

-- ============================================================
-- Origen: 20261019130000_escenari_b2_gent_background.sql
-- ============================================================
-- Foto de fons (resources.metadata.background) de l'escenari B2 «Conéixer la gent»: Carme,
-- la presidenta de l'associació cultural del barri (la imatge és a frontend/public/images/).
-- Tornar a aplicar el fitxer no canvia res (és un UPDATE idempotent).

UPDATE public.resources
SET metadata = jsonb_set(metadata, '{background}', to_jsonb('/images/asociacion_cultural.jpg'::text), true)
WHERE category = 'escenari' AND type = 'b2_gent';

-- ============================================================
-- Origen: 20261019140000_escenari_b2_cultura_llengua_background.sql
-- ============================================================
-- Foto de fons (resources.metadata.background) de l'escenari B2 «Cultura i llengua»: la
-- tia Pepeta conta rondalles a la fresca en una nit de festes al poble (la imatge és a
-- frontend/public/images/). Tornar a aplicar el fitxer no canvia res (és un UPDATE idempotent).

UPDATE public.resources
SET metadata = jsonb_set(metadata, '{background}', to_jsonb('/images/pueblo_noche.jpg'::text), true)
WHERE category = 'escenari' AND type = 'b2_cultura_llengua';

-- ============================================================
-- Origen: 20261019150000_escenari_c1_relacions_background.sql
-- ============================================================
-- Foto de fons (resources.metadata.background) de l'escenari C1 «Relacions personals i
-- socials»: Neus, la cosina, prepara la festa de les noces d'or dels avis (la imatge és a
-- frontend/public/images/). Tornar a aplicar el fitxer no canvia res (és un UPDATE idempotent).

UPDATE public.resources
SET metadata = jsonb_set(metadata, '{background}', to_jsonb('/images/casa_abuelos.jpg'::text), true)
WHERE category = 'escenari' AND type = 'c1_relacions';

-- ============================================================
-- Origen: 20261019160000_escenari_c1_temps_lliure_background.sql
-- ============================================================
-- Foto de fons (resources.metadata.background) de l'escenari C1 «Temps lliure i viatges»:
-- Jordi, de l'associació d'antics alumnes, organitza el viatge cultural (la imatge és a
-- frontend/public/images/). Tornar a aplicar el fitxer no canvia res (és un UPDATE idempotent).

UPDATE public.resources
SET metadata = jsonb_set(metadata, '{background}', to_jsonb('/images/asociacion_cultural.jpg'::text), true)
WHERE category = 'escenari' AND type = 'c1_temps_lliure';

-- ============================================================
-- Origen: 20261019170000_escenari_c1_comerc_background.sql
-- ============================================================
-- Foto de fons (resources.metadata.background) de l'escenari C1 «Activitats comercials i
-- transaccionals»: la parada de Rafel, l'antiquari del rastre dels diumenges (la imatge és a
-- frontend/public/images/). Tornar a aplicar el fitxer no canvia res (és un UPDATE idempotent).

UPDATE public.resources
SET metadata = jsonb_set(metadata, '{background}', to_jsonb('/images/mercadillo.jpg'::text), true)
WHERE category = 'escenari' AND type = 'c1_comerc';

-- ============================================================
-- Origen: 20261019180000_escenari_c1_economia_background.sql
-- ============================================================
-- Foto de fons (resources.metadata.background) de l'escenari C1 «Economia, indústria,
-- ciència i tecnologia»: Sergi assessora a l'oficina de l'agència de desenvolupament local
-- (la imatge és a frontend/public/images/). Tornar a aplicar el fitxer no canvia res
-- (és un UPDATE idempotent).

UPDATE public.resources
SET metadata = jsonb_set(metadata, '{background}', to_jsonb('/images/office.jpg'::text), true)
WHERE category = 'escenari' AND type = 'c1_economia';

-- ============================================================
-- Origen: 20261019190000_escenari_c1_medi_clima_background.sql
-- ============================================================
-- Foto de fons (resources.metadata.background) de l'escenari C1 «Medi físic i clima»: Pilar,
-- la tècnica de protecció civil de l'Ajuntament, revisa el pla municipal d'emergències (la
-- imatge és a frontend/public/images/). Tornar a aplicar el fitxer no canvia res (és un
-- UPDATE idempotent).

UPDATE public.resources
SET metadata = jsonb_set(metadata, '{background}', to_jsonb('/images/townhall.jpg'::text), true)
WHERE category = 'escenari' AND type = 'c1_medi_clima';

-- ============================================================
-- Origen: 20261019200000_escenari_c1_sociocultural_background.sql
-- ============================================================
-- Foto de fons (resources.metadata.background) de l'escenari C1 «Entorn sociocultural i
-- polític»: Marina, la presidenta d'una associació intercultural, prepara unes jornades (la
-- imatge és a frontend/public/images/). Tornar a aplicar el fitxer no canvia res (és un
-- UPDATE idempotent).

UPDATE public.resources
SET metadata = jsonb_set(metadata, '{background}', to_jsonb('/images/asociacion_cultural.jpg'::text), true)
WHERE category = 'escenari' AND type = 'c1_sociocultural';

-- ============================================================
-- Origen: 20261019210000_entrada_amb_codi_de_classe.sql
-- ============================================================
-- Tercera forma d'entrar: amb el codi d'una classe, sense compte (ni correu ni contrasenya).
--   * L'alumne escriu el codi i tria un apodo (i el nivell, si la classe en té dos). L'app crea una sessió
--     anònima de Supabase (auth.signInAnonymously) amb el nivell, el grup d'edat i l'apodo com a metadades:
--     handle_new_user() ja en fa el perfil (display_name = l'apodo). El navegador guarda la sessió.
--   * El servidor només guarda l'apodo i el seguiment (resultats, objectius dels escenaris...): és el que la
--     docent veu a la seua taula. El que escriu o diu l'alumne es queda en el seu navegador.
--   * class_code_preview(): amb el codi diu a quina classe va (nom i nivells) i si l'apodo ja és en ús en
--     eixa classe. Es pot cridar sense sessió, perquè l'alumne ho veja abans de crear res.
--   * kids_join_class(): igual que abans, però si qui crida és una sessió anònima també comprova l'apodo
--     (format, i que no el tinga ningú més de la classe).
-- Cal activar els inicis de sessió anònims: `enable_anonymous_sign_ins = true` en supabase/config.toml
-- (en local) i en Authentication → Providers → Anonymous Sign-Ins (en Supabase Cloud).

-- Format de l'apodo: 2 a 20 caràcters (lletres, xifres, punt, guionet i guionet baix), sense espais.
CREATE OR REPLACE FUNCTION public.valid_nick(p text)
RETURNS boolean
LANGUAGE sql
IMMUTABLE
AS $$
  SELECT coalesce(p ~ '^[A-Za-zÀ-ÖØ-öø-ÿ0-9._-]{2,20}$', false);
$$;

-- Si l'apodo ja el té un altre alumne de la classe (sense distinguir majúscules i minúscules).
CREATE OR REPLACE FUNCTION public.nick_taken_in_class(p_class uuid, p_nick text, p_except uuid DEFAULT NULL)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM kids_class_members m
    JOIN profiles p ON p.id = m.student_id
    WHERE m.class_id = p_class
      AND lower(p.display_name) = lower(trim(coalesce(p_nick, '')))
      AND (p_except IS NULL OR m.student_id <> p_except)
  );
$$;
REVOKE ALL ON FUNCTION public.nick_taken_in_class(uuid, text, uuid) FROM PUBLIC;

-- Quina classe és, per al codi (nom, nivells i si l'apodo ja és en ús). Sense sessió: només torna això.
CREATE OR REPLACE FUNCTION public.class_code_preview(p_code text, p_nick text DEFAULT NULL)
RETURNS TABLE (name text, levels text[], nick_taken boolean)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  found kids_classes;
BEGIN
  SELECT * INTO found FROM kids_classes c WHERE c.code = upper(trim(coalesce(p_code, '')));
  IF found.id IS NULL THEN
    RAISE EXCEPTION 'No hi ha cap classe amb este codi' USING ERRCODE = 'P0002';
  END IF;
  RETURN QUERY SELECT found.name, found.levels,
    (p_nick IS NOT NULL AND public.nick_taken_in_class(found.id, p_nick));
END;
$$;
REVOKE ALL ON FUNCTION public.class_code_preview(text, text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.class_code_preview(text, text) TO anon, authenticated;

-- Unir-se a una classe amb el codi. Una sessió anònima (entrada amb el codi) també ha de tindre un apodo
-- vàlid i que no tinga ningú més de la classe.
CREATE OR REPLACE FUNCTION public.kids_join_class(p_code text)
RETURNS TABLE (id uuid, name text)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  uid uuid := auth.uid();
  found kids_classes;
  student_level text;
  student_nick text;
  anonymous boolean := coalesce((auth.jwt() ->> 'is_anonymous')::boolean, false);
BEGIN
  IF uid IS NULL THEN
    RAISE EXCEPTION 'Cal iniciar sessió' USING ERRCODE = '42501';
  END IF;
  SELECT * INTO found FROM kids_classes c WHERE c.code = upper(trim(coalesce(p_code, '')));
  IF found.id IS NULL THEN
    RAISE EXCEPTION 'No hi ha cap classe amb este codi' USING ERRCODE = 'P0002';
  END IF;
  SELECT level::text, display_name INTO student_level, student_nick FROM profiles WHERE profiles.id = uid;
  IF NOT (cefr_of(student_level) && found.levels) THEN
    RAISE EXCEPTION 'Esta classe és per a alumnat de %, i el teu nivell és %',
      (SELECT string_agg(level_label(l), ' i ') FROM unnest(found.levels) l), level_label(student_level)
      USING ERRCODE = '42501';
  END IF;
  IF anonymous THEN
    IF NOT valid_nick(student_nick) THEN
      RAISE EXCEPTION 'L''apodo ha de tindre entre 2 i 20 caràcters: lletres, xifres, punt, guionet o guionet baix' USING ERRCODE = '22023';
    END IF;
    IF nick_taken_in_class(found.id, student_nick, uid) THEN
      RAISE EXCEPTION 'Este apodo ja el té algú de la classe: tria''n un altre' USING ERRCODE = '23505';
    END IF;
  END IF;
  INSERT INTO kids_class_members (class_id, student_id) VALUES (found.id, uid) ON CONFLICT DO NOTHING;
  RETURN QUERY SELECT found.id, found.name;
END;
$$;

-- ============================================================
-- Origen: 20261019220000_classe_fixa_sense_compte.sql
-- ============================================================
-- Qui entra amb el codi d'una classe (sessió anònima, sense compte) queda en eixa classe: no en pot eixir ni
-- unir-se a una altra. Si pogués eixir-ne, perdria el seguiment (i com que no té compte, no podria tornar a
-- entrar com el mateix alumne); i unir-se a més classes no té sentit amb un apodo d'una sola classe.
--   * kids_class_members: una sessió anònima no pot esborrar la seua pertinença (sí la docent, que l'esborra
--     o treu l'alumne de la classe).
--   * kids_join_class(): una sessió anònima que ja és en una classe no es pot unir a una altra.

DROP POLICY IF EXISTS "kids_class_members: student or teacher removes" ON public.kids_class_members;
CREATE POLICY "kids_class_members: student or teacher removes" ON public.kids_class_members
  FOR DELETE USING (
    (student_id = auth.uid() AND NOT coalesce((auth.jwt() ->> 'is_anonymous')::boolean, false))
    OR EXISTS (SELECT 1 FROM kids_classes c WHERE c.id = kids_class_members.class_id AND c.teacher_id = auth.uid())
  );

CREATE OR REPLACE FUNCTION public.kids_join_class(p_code text)
RETURNS TABLE (id uuid, name text)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  uid uuid := auth.uid();
  found kids_classes;
  student_level text;
  student_nick text;
  anonymous boolean := coalesce((auth.jwt() ->> 'is_anonymous')::boolean, false);
BEGIN
  IF uid IS NULL THEN
    RAISE EXCEPTION 'Cal iniciar sessió' USING ERRCODE = '42501';
  END IF;
  SELECT * INTO found FROM kids_classes c WHERE c.code = upper(trim(coalesce(p_code, '')));
  IF found.id IS NULL THEN
    RAISE EXCEPTION 'No hi ha cap classe amb este codi' USING ERRCODE = 'P0002';
  END IF;
  SELECT level::text, display_name INTO student_level, student_nick FROM profiles WHERE profiles.id = uid;
  IF NOT (cefr_of(student_level) && found.levels) THEN
    RAISE EXCEPTION 'Esta classe és per a alumnat de %, i el teu nivell és %',
      (SELECT string_agg(level_label(l), ' i ') FROM unnest(found.levels) l), level_label(student_level)
      USING ERRCODE = '42501';
  END IF;
  IF anonymous THEN
    -- Sense compte, només una classe: la del codi amb què ha entrat.
    IF EXISTS (SELECT 1 FROM kids_class_members m WHERE m.student_id = uid AND m.class_id <> found.id) THEN
      RAISE EXCEPTION 'Has entrat amb el codi d''una classe: no et pots unir a una altra sense un compte' USING ERRCODE = '42501';
    END IF;
    IF NOT valid_nick(student_nick) THEN
      RAISE EXCEPTION 'L''apodo ha de tindre entre 2 i 20 caràcters: lletres, xifres, punt, guionet o guionet baix' USING ERRCODE = '22023';
    END IF;
    IF nick_taken_in_class(found.id, student_nick, uid) THEN
      RAISE EXCEPTION 'Este apodo ja el té algú de la classe: tria''n un altre' USING ERRCODE = '23505';
    END IF;
  END IF;
  INSERT INTO kids_class_members (class_id, student_id) VALUES (found.id, uid) ON CONFLICT DO NOTHING;
  RETURN QUERY SELECT found.id, found.name;
END;
$$;

