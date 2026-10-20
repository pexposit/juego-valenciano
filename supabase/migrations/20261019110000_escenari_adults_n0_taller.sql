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
