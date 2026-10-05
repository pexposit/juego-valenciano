import { motherTongueLabel } from '@parlaval/shared';

// "En què et puc ajudar?" en cada llengua materna triable. Valencià/Català ('ca') i
// "una altra llengua" ('other') no en porten: el missatge és només en valencià.
const HELP_GREETING: Record<string, string> = {
  es: '¿En qué te puedo ayudar?',
  en: 'How can I help you?',
  fr: "En quoi puis-je t'aider ?",
  ar: 'كيف يمكنني مساعدتك؟',
  ro: 'Cu ce te pot ajuta?',
  uk: 'Чим я можу тобі допомогти?',
  ru: 'Чем я могу тебе помочь?',
  zh: '我能帮你什么？',
  it: 'In cosa posso aiutarti?',
  de: 'Wie kann ich dir helfen?',
  pt: 'Em que posso ajudar-te?',
};

// Salutació del tutor: en valencià i, en una línia nova, en la llengua materna del xiquet.
// El TTS només llig la primera línia (la veu és valenciana).
export function bilingualGreeting(greeting: string, motherTongue: string | null | undefined) {
  const translation = motherTongue ? HELP_GREETING[motherTongue] : undefined;
  return translation ? `${greeting}\n${translation}` : greeting;
}

// Instruccions per al tutor infantil perquè tinga en compte la llengua materna del xiquet.
// Sense llengua materna, o si és el valencià/català o una altra no triable, no s'afig res.
export function motherTongueInstructions(motherTongue: string | null | undefined) {
  if (!motherTongue || !(motherTongue in HELP_GREETING)) return undefined;
  const language = motherTongueLabel(motherTongue);
  return [
    `LLENGUA MATERNA DEL XIQUET: ${language}.`,
    `Excepció a la norma de respondre sempre en valencià: reply_text ha de ser NOMÉS en valencià, sense cap paraula en ${language} (llevat de la paraula o frase que estiga explicant), i en help_text has d'escriure la mateixa idea, breument i tota en ${language}, perquè l'entenga bé.`,
    `Quan expliques una paraula o una frase, dona'n la traducció a ${language} dins de help_text.`,
    `Si el xiquet et pregunta en ${language}, entén-lo i respon igual: reply_text en valencià i help_text en ${language}.`,
    `Quan ajude, compara el valencià amb ${language} (paraules paregudes, diferències, falsos amics) dins de help_text, sempre amb frases curtes.`,
  ].join(' ');
}
