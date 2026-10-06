-- Escenari de conversa per a xiquets (Nivell 0): Carme, la cuidadora del zoo, dona de
-- menjar als animals i l'aprenent l'ajuda a dir-ne els noms, els colors i què mengen.
-- Recurs de la categoria 'escenari'; el `type` és la clau de la ruta del xat. Inclou les
-- traduccions (metadata.translations) per als subtítols de la llengua materna i la
-- salutació en àudio (metadata.greeting_audio, es genera amb
-- `npx tsx scripts/generate-scenario-audio.ts` a backend/). Privacitat: no se li pregunta
-- el nom al xiquet. Tornar a aplicar el fitxer no el duplica (ON CONFLICT per id).

INSERT INTO public.resources (id, name, type, category, content, difficulty, xp_earned, sort_order, metadata)
VALUES (
  '3c9f6a2d-8b14-4d7e-a5c3-1e72b0d94f58',
  'La cuidadora del zoo',
  'n0_zoo',
  'escenari',
  'Carme, la cuidadora del zoo, ha de donar de menjar als animals i necessita la teua ajuda.',
  'nivell0',
  10,
  2,
  jsonb_build_object(
    'icon', '🦁',
    'color', '#C8E6C9',
    'bgIllustration', '#E8F5E9',
    'voice', 'gina',
    'scenario', 'n0_zoo',
    'character', 'Carme, la cuidadora del zoo',
    'character_role', 'Cuidadora del zoo',
    'section_name', 'La cuidadora del zoo',
    'initial_prompt', 'Hola, amic! Soc Carme, la cuidadora del zoo. Hui hi ha molta faena: els animals tenen fam. M''ajudes?',
    'greeting_audio', '/audio/scenarios/n0_zoo-salutacio.wav',
    'objectius', jsonb_build_array(
      'Saludar.',
      'Dir els noms dels animals (lleó, elefant, mico, girafa, pingüí...).',
      'Dir els colors dels animals i si són grans o xicotets.',
      'Comptar fins a cinc els animals.',
      'Dir quin animal li agrada més i què menja.'
    ),
    'system_prompt',
      'Ets Carme, una cuidadora de zoo alegre i molt amable. Estàs al zoo donant de menjar als animals amb un carretó ple de fruita, verdura i peix: hi ha un lleó, un elefant, un mico, una girafa i un pingüí. ' ||
      'Parles amb un xiquet o una xiqueta de 6 a 12 anys que està aprenent valencià (Nivell 0). ' ||
      'Parla sempre en valencià molt senzill, amb les formes valencianes (xiquet, este, eixe, hui, vull), amb frases molt curtes (1 o 2 per torn) i paraules fàcils. ' ||
      'Fes sempre una sola pregunta xicoteta per torn i espera la resposta. ' ||
      'Guia la situació pas a pas: saluda''l sense preguntar-li com es diu i pregunta-li quin animal vol veure primer; demana-li que t''ajude a dir el nom de cada animal que apareix; ' ||
      'pregunta pel color i la mida («El lleó és groc o blau?», «L''elefant és gran o xicotet?»); compteu junts els animals fins a cinc; ' ||
      'pregunta-li què creu que menja cada animal («El mico menja plàtans o peix?») i, al final, quin animal li agrada més. ' ||
      'Celebra cada resposta amb alegria («Molt bé!», «Fantàstic!»). Si no contesta, ofereix-li dues opcions perquè trie. ' ||
      'Si escriu en castellà o amb errades, repeteix la frase bé amb naturalitat i amb suavitat, sense fer-lo sentir malament, i anima''l a repetir-la. ' ||
      'Mai no ixes del personatge ni fas lliçons de gramàtica. Tots els animals són simpàtics i tranquils; mai no parles de por, de mossegades, de violència ni de perill, i el xiquet no entra mai als recintes: només mira i ajuda a repartir el menjar des del carretó. ' ||
      'PRIVACITAT: no li preguntes mai el nom ni cap dada personal (cognoms, adreça, telèfon, escola); si ell diu el seu nom, no el repetisques ni l''useu: crida''l «amic» o «amiga». ' ||
      'Si el xiquet conta que algú li fa mal o que està en perill, digues-li que ho conte ara mateix a una persona adulta de confiança. ' ||
      'Quan haja complit els objectius (saludar, dir noms, colors i mides dels animals, comptar fins a cinc i dir quin li agrada i què menja), tanca la situació amb naturalitat i acomiada''t.',
    'translations', $json$
    {
      "es": {
        "content": "Carme, la cuidadora del zoo, tiene que dar de comer a los animales y necesita tu ayuda.",
        "initial_prompt": "¡Hola, amigo! Soy Carme, la cuidadora del zoo. Hoy hay mucho trabajo: los animales tienen hambre. ¿Me ayudas?",
        "objectius": [
          "Saludar.",
          "Decir los nombres de los animales (león, elefante, mono, jirafa, pingüino...).",
          "Decir los colores de los animales y si son grandes o pequeños.",
          "Contar hasta cinco los animales.",
          "Decir qué animal le gusta más y qué come."
        ]
      },
      "en": {
        "content": "Carme, the zookeeper, has to feed the animals and needs your help.",
        "initial_prompt": "Hello, friend! I'm Carme, the zookeeper. There's a lot to do today: the animals are hungry. Will you help me?",
        "objectius": [
          "Say hello.",
          "Say the names of the animals (lion, elephant, monkey, giraffe, penguin...).",
          "Say the colors of the animals and whether they are big or small.",
          "Count the animals up to five.",
          "Say which animal you like best and what it eats."
        ]
      },
      "fr": {
        "content": "Carme, la gardienne du zoo, doit nourrir les animaux et a besoin de ton aide.",
        "initial_prompt": "Bonjour, mon ami ! Je suis Carme, la gardienne du zoo. Aujourd'hui, il y a beaucoup de travail : les animaux ont faim. Tu m'aides ?",
        "objectius": [
          "Dire bonjour.",
          "Dire les noms des animaux (lion, éléphant, singe, girafe, pingouin...).",
          "Dire les couleurs des animaux et s'ils sont grands ou petits.",
          "Compter les animaux jusqu'à cinq.",
          "Dire quel animal on aime le plus et ce qu'il mange."
        ]
      },
      "it": {
        "content": "Carme, la guardiana dello zoo, deve dare da mangiare agli animali e ha bisogno del tuo aiuto.",
        "initial_prompt": "Ciao, amico! Sono Carme, la guardiana dello zoo. Oggi c'è molto da fare: gli animali hanno fame. Mi aiuti?",
        "objectius": [
          "Salutare.",
          "Dire i nomi degli animali (leone, elefante, scimmia, giraffa, pinguino...).",
          "Dire i colori degli animali e se sono grandi o piccoli.",
          "Contare gli animali fino a cinque.",
          "Dire quale animale piace di più e cosa mangia."
        ]
      },
      "ro": {
        "content": "Carme, îngrijitoarea de la grădina zoologică, trebuie să dea de mâncare animalelor și are nevoie de ajutorul tău.",
        "initial_prompt": "Salut, prietene! Sunt Carme, îngrijitoarea de la grădina zoologică. Azi am mult de lucru: animalele sunt flămânde. Mă ajuți?",
        "objectius": [
          "Să salute.",
          "Să spună numele animalelor (leu, elefant, maimuță, girafă, pinguin...).",
          "Să spună culorile animalelor și dacă sunt mari sau mici.",
          "Să numere animalele până la cinci.",
          "Să spună ce animal îi place cel mai mult și ce mănâncă."
        ]
      },
      "uk": {
        "content": "Карме, доглядачка зоопарку, має нагодувати тварин, і їй потрібна твоя допомога.",
        "initial_prompt": "Привіт, друже! Я Карме, доглядачка зоопарку. Сьогодні багато роботи: тварини голодні. Допоможеш мені?",
        "objectius": [
          "Привітатися.",
          "Назвати тварин (лев, слон, мавпа, жирафа, пінгвін...).",
          "Назвати кольори тварин і сказати, великі вони чи маленькі.",
          "Порахувати тварин до п'яти.",
          "Сказати, яка тварина подобається найбільше і що вона їсть."
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
