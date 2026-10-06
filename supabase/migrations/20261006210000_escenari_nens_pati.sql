-- Escenari de conversa per a xiquets (Nivell 0): Laia, una xiqueta de l'escola, vol fer
-- alguna cosa a l'hora del pati (esmorzar, jugar a futbol, saltar a corda, pillar...) i
-- l'aprenent l'ajuda a triar. Recurs de la categoria 'escenari'; el `type` és la clau de la
-- ruta del xat. Inclou les traduccions (metadata.translations) per als subtítols de la
-- llengua materna i la salutació en àudio (metadata.greeting_audio, es genera amb
-- `npx tsx scripts/generate-scenario-audio.ts` a backend/). Privacitat: no se li pregunta
-- el nom al xiquet. Tornar a aplicar el fitxer no el duplica (ON CONFLICT per id).

INSERT INTO public.resources (id, name, type, category, content, difficulty, xp_earned, sort_order, metadata)
VALUES (
  '9d4e7b31-6a25-4c8f-b1d0-5f3a2e8c7961',
  'Al pati amb Laia',
  'n0_pati',
  'escenari',
  'És l''hora del pati i Laia, una xiqueta de la teua classe, vol fer alguna cosa. Ajuda-la a triar!',
  'nivell0',
  10,
  3,
  jsonb_build_object(
    'icon', '⚽',
    'color', '#FFE0B2',
    'bgIllustration', '#FFF3E0',
    'voice', 'gina',
    'scenario', 'n0_pati',
    'character', 'Laia, una xiqueta de la classe',
    'character_role', 'Companya de classe',
    'section_name', 'Al pati amb Laia',
    'initial_prompt', 'Hola! Soc Laia, de la teua classe. Ja és l''hora del pati! Què vols fer?',
    'greeting_audio', '/audio/scenarios/n0_pati-salutacio.wav',
    'objectius', jsonb_build_array(
      'Saludar.',
      'Dir què vol fer al pati (esmorzar, jugar a futbol, saltar a corda...).',
      'Dir què tens per a esmorzar (un entrepà, una fruita, un suc...).',
      'Dir a quin joc li agrada més jugar.'
    ),
    'system_prompt',
      'Ets Laia, una xiqueta de 8 anys, companya de classe de l''aprenent. Sou al pati de l''escola i tens moltes ganes de fer coses amb ell: esmorzar, jugar a futbol amb una pilota, saltar a corda, jugar a pillar o a amagar-se. ' ||
      'Parles amb un xiquet o una xiqueta de 6 a 12 anys que està aprenent valencià (Nivell 0). ' ||
      'Parla sempre en valencià molt senzill, amb les formes valencianes (xiquet, este, eixe, hui, vull), amb frases molt curtes (1 o 2 per torn) i paraules fàcils. ' ||
      'Fes sempre una sola pregunta xicoteta per torn i espera la resposta. ' ||
      'Guia la situació pas a pas: saluda''l sense preguntar-li com es diu i pregunta-li què vol fer al pati; proposa-li dues coses perquè trie («Vols esmorzar o jugar a futbol?»); ' ||
      'si tria esmorzar, pregunta què té per a esmorzar (un entrepà, una poma, un suc) i digues el teu; si tria un joc, pregunta-li amb qui li agrada jugar-hi i com es juga; ' ||
      'canvieu d''activitat una vegada o dues perquè parle d''altres jocs i, al final, pregunta-li a quin joc li agrada més jugar. ' ||
      'Celebra cada resposta amb alegria («Molt bé!», «Fantàstic!»). Si no contesta, ofereix-li dues opcions perquè trie. ' ||
      'Si escriu en castellà o amb errades, repeteix la frase bé amb naturalitat i amb suavitat, sense fer-lo sentir malament, i anima''l a repetir-la. ' ||
      'Mai no ixes del personatge ni fas lliçons de gramàtica. Tot és un joc amable: mai no parles de baralles, de fer mal, de por ni de perill, i tots els jocs són en equip i divertits. ' ||
      'PRIVACITAT: no li preguntes mai el nom ni cap dada personal (cognoms, adreça, telèfon, escola); si ell diu el seu nom, no el repetisques ni l''useu: crida''l «amic» o «amiga». ' ||
      'Si el xiquet conta que algú li fa mal o que està en perill, digues-li que ho conte ara mateix a una persona adulta de confiança. ' ||
      'Quan haja complit els objectius (saludar, dir què vol fer, dir què esmorza i dir quin joc li agrada més), tanca la situació amb naturalitat i acomiada''t perquè toca el timbre i cal tornar a classe.',
    'translations', $json$
    {
      "es": {
        "content": "Es la hora del recreo y Laia, una niña de tu clase, quiere hacer algo. ¡Ayúdala a elegir!",
        "initial_prompt": "¡Hola! Soy Laia, de tu clase. ¡Ya es la hora del recreo! ¿Qué quieres hacer?",
        "objectius": [
          "Saludar.",
          "Decir qué quiere hacer en el recreo (almorzar, jugar al fútbol, saltar a la comba...).",
          "Decir qué tienes para almorzar (un bocadillo, una fruta, un zumo...).",
          "Decir a qué juego le gusta más jugar."
        ]
      },
      "en": {
        "content": "It's recess time and Laia, a girl in your class, wants to do something. Help her choose!",
        "initial_prompt": "Hello! I'm Laia, from your class. It's recess time! What do you want to do?",
        "objectius": [
          "Say hello.",
          "Say what you want to do at recess (have a snack, play football, jump rope...).",
          "Say what you have for your snack (a sandwich, a fruit, a juice...).",
          "Say which game you like playing most."
        ]
      },
      "fr": {
        "content": "C'est l'heure de la récréation et Laia, une fille de ta classe, veut faire quelque chose. Aide-la à choisir !",
        "initial_prompt": "Bonjour ! Je suis Laia, de ta classe. C'est l'heure de la récré ! Qu'est-ce que tu veux faire ?",
        "objectius": [
          "Dire bonjour.",
          "Dire ce qu'on veut faire à la récré (manger le goûter, jouer au foot, sauter à la corde...).",
          "Dire ce que tu as pour le goûter (un sandwich, un fruit, un jus...).",
          "Dire à quel jeu on aime le plus jouer."
        ]
      },
      "it": {
        "content": "È l'ora della ricreazione e Laia, una bambina della tua classe, vuole fare qualcosa. Aiutala a scegliere!",
        "initial_prompt": "Ciao! Sono Laia, della tua classe. È l'ora della ricreazione! Cosa vuoi fare?",
        "objectius": [
          "Salutare.",
          "Dire cosa vuole fare in ricreazione (fare merenda, giocare a calcio, saltare la corda...).",
          "Dire cosa hai per merenda (un panino, un frutto, un succo...).",
          "Dire a quale gioco gli piace giocare di più."
        ]
      },
      "ro": {
        "content": "E ora recreației, iar Laia, o fetiță din clasa ta, vrea să facă ceva. Ajut-o să aleagă!",
        "initial_prompt": "Salut! Sunt Laia, din clasa ta. E ora recreației! Ce vrei să facem?",
        "objectius": [
          "Să salute.",
          "Să spună ce vrea să facă în recreație (să mănânce gustarea, să joace fotbal, să sară coarda...).",
          "Să spună ce ai de gustare (un sandviș, un fruct, un suc...).",
          "Să spună ce joc îi place cel mai mult."
        ]
      },
      "uk": {
        "content": "Настала перерва, і Лаія, дівчинка з твого класу, хоче щось робити. Допоможи їй вибрати!",
        "initial_prompt": "Привіт! Я Лаія, з твого класу. Вже перерва! Що ти хочеш робити?",
        "objectius": [
          "Привітатися.",
          "Сказати, що хочеш робити на перерві (поїсти, пограти у футбол, стрибати через скакалку...).",
          "Сказати, що в тебе на перекус (бутерброд, фрукт, сік...).",
          "Сказати, у яку гру тобі найбільше подобається грати."
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
