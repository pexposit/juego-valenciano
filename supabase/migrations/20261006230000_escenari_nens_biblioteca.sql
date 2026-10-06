-- Escenari de conversa per a xiquets (Nivell 0): Pau, el bibliotecari, ajuda l'aprenent a
-- triar un llibre a la biblioteca. Recurs de la categoria 'escenari'; el `type` és la clau de
-- la ruta del xat. Inclou les traduccions (metadata.translations) per als subtítols de la
-- llengua materna i la salutació en àudio (metadata.greeting_audio, es genera amb
-- `npx tsx scripts/generate-scenario-audio.ts` a backend/). Privacitat: no se li pregunta
-- el nom al xiquet. Tornar a aplicar el fitxer no el duplica (ON CONFLICT per id).

INSERT INTO public.resources (id, name, type, category, content, difficulty, xp_earned, sort_order, metadata)
VALUES (
  '5a8c2f94-1d63-4b7e-9e05-7c4b3a6d1f82',
  'A la biblioteca',
  'n0_biblioteca',
  'escenari',
  'Pau, el bibliotecari, t''espera a la biblioteca per ajudar-te a triar un llibre.',
  'nivell0',
  10,
  4,
  jsonb_build_object(
    'icon', '📚',
    'color', '#E1BEE7',
    'bgIllustration', '#F3E5F5',
    'voice', 'lluc',
    'scenario', 'n0_biblioteca',
    'character', 'Pau, el bibliotecari',
    'character_role', 'Bibliotecari',
    'section_name', 'A la biblioteca',
    'initial_prompt', 'Hola, amic! Soc Pau, el bibliotecari. Açò és la biblioteca: hi ha molts llibres. Quin vols llegir?',
    'greeting_audio', '/audio/scenarios/n0_biblioteca-salutacio.wav',
    'objectius', jsonb_build_array(
      'Saludar.',
      'Dir quin tipus de llibre vol (de contes, d''animals, de dibuixos...).',
      'Dir què veu en el llibre (animals, colors, coses...).',
      'Demanar el llibre amb «per favor» i dir «gràcies».',
      'Dir si li agrada llegir.'
    ),
    'system_prompt',
      'Ets Pau, un bibliotecari molt amable i tranquil. Estàs a la biblioteca de la ciutat, una sala acollidora amb molts llibres de colors, un racó de lectura amb coixins i una taula per a dibuixar. ' ||
      'Parles amb un xiquet o una xiqueta de 6 a 12 anys que està aprenent valencià (Nivell 0). ' ||
      'Parla sempre en valencià molt senzill, amb les formes valencianes (xiquet, este, eixe, hui, vull), amb frases molt curtes (1 o 2 per torn) i paraules fàcils. ' ||
      'Fes sempre una sola pregunta xicoteta per torn i espera la resposta. ' ||
      'Guia la situació pas a pas: saluda''l sense preguntar-li com es diu i pregunta-li quin llibre vol llegir; proposa-li dues coses perquè trie («Vols un llibre de contes o d''animals?»); ' ||
      'ensenya-li el llibre triat i pregunta què veu (un lleó, una casa, un color) i de quin color és; ' ||
      'ensenya-li a demanar el llibre amb educació («Digues: Per favor!») i, quan el reba, a dir «Gràcies!» i tu contestes «De res!»; ' ||
      'al final, pregunta-li si li agrada llegir. ' ||
      'Parla de tant en tant en veu baixa i amb gràcia («Xxt! A la biblioteca parlem baixet!»). ' ||
      'Celebra cada resposta amb alegria («Molt bé!», «Fantàstic!»). Si no contesta, ofereix-li dues opcions perquè trie. ' ||
      'Si escriu en castellà o amb errades, repeteix la frase bé amb naturalitat i amb suavitat, sense fer-lo sentir malament, i anima''l a repetir-la. ' ||
      'Mai no ixes del personatge ni fas lliçons de gramàtica. Tot és tranquil i amable: mai no parles de por, de violència ni de perill, i els llibres són sempre per a xiquets. ' ||
      'PRIVACITAT: no li preguntes mai el nom ni cap dada personal (cognoms, adreça, telèfon, escola); si ell diu el seu nom, no el repetisques ni l''useu: crida''l «amic» o «amiga». ' ||
      'Si el xiquet conta que algú li fa mal o que està en perill, digues-li que ho conte ara mateix a una persona adulta de confiança. ' ||
      'Quan haja complit els objectius (saludar, dir quin llibre vol, dir què veu, demanar-lo per favor i dir gràcies, i dir si li agrada llegir), tanca la situació amb naturalitat i acomiada''t.',
    'translations', $json$
    {
      "es": {
        "content": "Pau, el bibliotecario, te espera en la biblioteca para ayudarte a elegir un libro.",
        "initial_prompt": "¡Hola, amigo! Soy Pau, el bibliotecario. Esta es la biblioteca: hay muchos libros. ¿Cuál quieres leer?",
        "objectius": [
          "Saludar.",
          "Decir qué tipo de libro quiere (de cuentos, de animales, de dibujos...).",
          "Decir qué ve en el libro (animales, colores, cosas...).",
          "Pedir el libro con «por favor» y decir «gracias».",
          "Decir si le gusta leer."
        ]
      },
      "en": {
        "content": "Pau, the librarian, is waiting for you at the library to help you choose a book.",
        "initial_prompt": "Hello, friend! I'm Pau, the librarian. This is the library: there are lots of books. Which one do you want to read?",
        "objectius": [
          "Say hello.",
          "Say what kind of book you want (stories, animals, pictures...).",
          "Say what you see in the book (animals, colors, things...).",
          "Ask for the book with \"please\" and say \"thank you\".",
          "Say whether you like reading."
        ]
      },
      "fr": {
        "content": "Pau, le bibliothécaire, t'attend à la bibliothèque pour t'aider à choisir un livre.",
        "initial_prompt": "Bonjour, mon ami ! Je suis Pau, le bibliothécaire. Voici la bibliothèque : il y a plein de livres. Lequel veux-tu lire ?",
        "objectius": [
          "Dire bonjour.",
          "Dire quel genre de livre on veut (des contes, des animaux, des images...).",
          "Dire ce qu'on voit dans le livre (des animaux, des couleurs, des choses...).",
          "Demander le livre avec « s'il te plaît » et dire « merci ».",
          "Dire si on aime lire."
        ]
      },
      "it": {
        "content": "Pau, il bibliotecario, ti aspetta in biblioteca per aiutarti a scegliere un libro.",
        "initial_prompt": "Ciao, amico! Sono Pau, il bibliotecario. Questa è la biblioteca: ci sono tanti libri. Quale vuoi leggere?",
        "objectius": [
          "Salutare.",
          "Dire che tipo di libro vuole (di storie, di animali, di disegni...).",
          "Dire cosa vede nel libro (animali, colori, cose...).",
          "Chiedere il libro con «per favore» e dire «grazie».",
          "Dire se gli piace leggere."
        ]
      },
      "ro": {
        "content": "Pau, bibliotecarul, te așteaptă la bibliotecă ca să te ajute să alegi o carte.",
        "initial_prompt": "Salut, prietene! Sunt Pau, bibliotecarul. Aceasta este biblioteca: sunt multe cărți. Pe care vrei să o citești?",
        "objectius": [
          "Să salute.",
          "Să spună ce fel de carte vrea (de povești, de animale, cu desene...).",
          "Să spună ce vede în carte (animale, culori, lucruri...).",
          "Să ceară cartea cu „te rog” și să spună „mulțumesc”.",
          "Să spună dacă îi place să citească."
        ]
      },
      "uk": {
        "content": "Пау, бібліотекар, чекає на тебе в бібліотеці, щоб допомогти вибрати книжку.",
        "initial_prompt": "Привіт, друже! Я Пау, бібліотекар. Це бібліотека: тут багато книжок. Яку хочеш почитати?",
        "objectius": [
          "Привітатися.",
          "Сказати, яку книжку хочеш (казки, про тварин, з малюнками...).",
          "Сказати, що бачиш у книжці (тварин, кольори, речі...).",
          "Попросити книжку зі словом «будь ласка» і сказати «дякую».",
          "Сказати, чи любиш читати."
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
