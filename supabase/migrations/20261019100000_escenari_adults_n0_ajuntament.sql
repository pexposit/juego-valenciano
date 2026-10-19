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
