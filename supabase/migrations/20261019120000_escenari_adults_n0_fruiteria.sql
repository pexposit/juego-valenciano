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
