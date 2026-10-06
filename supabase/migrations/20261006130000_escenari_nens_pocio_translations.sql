-- Traduccions de l'escenari infantil del mag i la poció (resources.metadata.translations) a
-- les llengües maternes amb subtítols: resum de la situació (content), objectius i primera
-- frase del personatge. El xat les mostra davall del valencià si el perfil té activada la
-- llengua materna. Tornar a aplicar el fitxer no canvia res (és un UPDATE idempotent).

UPDATE public.resources
SET metadata = jsonb_set(metadata, '{translations}', $json$
{
  "es": {
    "content": "El mago Merlí está preparando una poción mágica en su laboratorio y necesita tu ayuda para elegir los ingredientes.",
    "initial_prompt": "¡Hola, amigo! Soy Merlí, el mago. Estoy preparando una poción mágica, pero me faltan ingredientes. ¿Me ayudas?",
    "objectius": [
      "Saludar y decir su nombre.",
      "Decir los colores y las cosas de la poción (verde, rojo, caldero, estrella, huevo...).",
      "Contar hasta cinco los ingredientes.",
      "Decir qué le gusta o qué no le gusta de la poción.",
      "Ponerle nombre a la poción."
    ]
  },
  "en": {
    "content": "Merlí the wizard is making a magic potion in his lab and needs your help to choose the ingredients.",
    "initial_prompt": "Hello, friend! I'm Merlí, the wizard. I'm making a magic potion, but I'm missing some ingredients. Will you help me?",
    "objectius": [
      "Say hello and say your name.",
      "Say the colors and things in the potion (green, red, cauldron, star, egg...).",
      "Count the ingredients up to five.",
      "Say what you like or don't like about the potion.",
      "Give the potion a name."
    ]
  },
  "fr": {
    "content": "Le magicien Merlí prépare une potion magique dans son laboratoire et a besoin de ton aide pour choisir les ingrédients.",
    "initial_prompt": "Bonjour, mon ami ! Je suis Merlí, le magicien. Je prépare une potion magique, mais il me manque des ingrédients. Tu m'aides ?",
    "objectius": [
      "Dire bonjour et dire son prénom.",
      "Dire les couleurs et les choses de la potion (vert, rouge, chaudron, étoile, œuf...).",
      "Compter les ingrédients jusqu'à cinq.",
      "Dire ce qu'il aime ou n'aime pas dans la potion.",
      "Donner un nom à la potion."
    ]
  },
  "it": {
    "content": "Il mago Merlí sta preparando una pozione magica nel suo laboratorio e ha bisogno del tuo aiuto per scegliere gli ingredienti.",
    "initial_prompt": "Ciao, amico! Sono Merlí, il mago. Sto preparando una pozione magica, ma mi mancano degli ingredienti. Mi aiuti?",
    "objectius": [
      "Salutare e dire il proprio nome.",
      "Dire i colori e le cose della pozione (verde, rosso, calderone, stella, uovo...).",
      "Contare gli ingredienti fino a cinque.",
      "Dire cosa gli piace o non gli piace della pozione.",
      "Dare un nome alla pozione."
    ]
  },
  "ro": {
    "content": "Magicianul Merlí pregătește o poțiune magică în laboratorul lui și are nevoie de ajutorul tău ca să aleagă ingredientele.",
    "initial_prompt": "Salut, prietene! Sunt Merlí, magicianul. Pregătesc o poțiune magică, dar îmi lipsesc ingrediente. Mă ajuți?",
    "objectius": [
      "Să salute și să spună cum îl cheamă.",
      "Să spună culorile și lucrurile din poțiune (verde, roșu, căldare, stea, ou...).",
      "Să numere ingredientele până la cinci.",
      "Să spună ce îi place sau ce nu îi place la poțiune.",
      "Să dea un nume poțiunii."
    ]
  },
  "uk": {
    "content": "Чарівник Мерлі готує чарівне зілля у своїй лабораторії, і йому потрібна твоя допомога, щоб вибрати інгредієнти.",
    "initial_prompt": "Привіт, друже! Я Мерлі, чарівник. Я готую чарівне зілля, але мені бракує інгредієнтів. Допоможеш мені?",
    "objectius": [
      "Привітатися й сказати, як тебе звати.",
      "Назвати кольори й речі в зіллі (зелений, червоний, казан, зірка, яйце...).",
      "Порахувати інгредієнти до п'яти.",
      "Сказати, що тобі подобається або не подобається в зіллі.",
      "Дати зіллю назву."
    ]
  }
}
$json$::jsonb, true)
WHERE category = 'escenari' AND type = 'n0_pocio';
