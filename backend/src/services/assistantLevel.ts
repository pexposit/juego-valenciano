import { levelBand } from '@parlaval/shared';

// El tutor del tauler s'adapta al nivell (profiles.level) i al públic (profiles.age_group) de qui hi parla:
// la salutació inicial i les pautes que se sumen al prompt del recurs.
// Totes les salutacions acaben amb la mateixa pregunta, que és la que bilingualGreeting traduïx a la llengua materna.
const HELP_QUESTION = 'En què et puc ajudar?';

// Per tram del MECR (A1-A2, B1-B2, C1-C2), a banda del Nivell 0.
type Tier = 'nivell0' | 'A' | 'B' | 'C';

const GREETINGS: Record<Tier, string> = {
  nivell0: `Hola! Sóc el professor. ${HELP_QUESTION}`,
  A: `Hola! Sóc el teu professor de valencià. Pregunta'm el que vulgues. ${HELP_QUESTION}`,
  B: `Hola! Pots preguntar-me sobre gramàtica, vocabulari, ortografia o pronunciació, i et corregiré el que escrigues. ${HELP_QUESTION}`,
  C: `Hola! Podem treballar els matisos, el registre, les expressions i els dubtes de normativa. ${HELP_QUESTION}`,
};

const LEVEL_INSTRUCTIONS: Record<Tier, string> = {
  nivell0:
    "L'aprenent està en el Nivell 0: encara no sap llegir bé ni sap valencià. Fes servir només paraules molt bàsiques i freqüents (casa, mare, gos, colors, números), " +
    'frases d\'1 o 2 oracions curtes en present i un sol concepte cada vegada. No facis servir terminologia gramatical.',
  A:
    "L'aprenent és de nivell bàsic (A1-A2): frases curtes i clares, vocabulari quotidià i temps verbals senzills (present, passat i futur simples). " +
    "Dóna exemples breus i evita la terminologia gramatical; si n'has de fer servir, explica-la amb paraules fàcils.",
  B:
    "L'aprenent és de nivell intermedi (B1-B2): pots fer servir frases més llargues, vocabulari variat i una mica de terminologia gramatical. " +
    "Explica el perquè de les regles, compara formes properes i proposa algun exercici curt quan convinga.",
  C:
    "L'aprenent és de nivell avançat (C1-C2): respon amb registre ric i precís, tracta matisos, registres, expressions idiomàtiques i qüestions de normativa (AVL), " +
    'i justifica les correccions amb la regla corresponent.',
};

// Si no és un xiquet, el prompt del recurs (pensat per a xiquets de 6 a 12 anys) es matisa.
const ADULT_INSTRUCTIONS =
  "L'aprenent és una persona adulta, no un xiquet: tracta-la com a tal, amb un to cordial i respectuós, sense llenguatge infantil. " +
  'Ignora la indicació del to per a xiquets i el límit de 2 o 3 frases: pots explicar-te amb més detall quan calga.';

// Els nivells alts no porten la traducció de la salutació a la llengua materna.
const TRANSLATED_GREETING_TIERS: readonly Tier[] = ['nivell0', 'A'];

const tierOf = (level: string | null | undefined): Tier => (level === 'nivell0' ? 'nivell0' : levelBand(level) ?? 'A');

export function assistantGreeting(level: string | null | undefined) {
  return GREETINGS[tierOf(level)];
}

export function assistantLevelInstructions(level: string | null | undefined, ageGroup: string | null | undefined) {
  return [LEVEL_INSTRUCTIONS[tierOf(level)], ageGroup === 'child' ? undefined : ADULT_INSTRUCTIONS].filter(Boolean).join(' ');
}

export const assistantGreetingIsTranslated = (level: string | null | undefined) =>
  TRANSLATED_GREETING_TIERS.includes(tierOf(level));
