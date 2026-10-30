/**
 * Filtre d'eixida de llengua: tots els xatbots (personatges dels escenaris i tutor, en tots els nivells) han de
 * respondre en valencià. Detecta quan la resposta del model (reply_text) està en una altra llengua perquè no arribe
 * a l'aprenent. L'única excepció és l'ajuda en la llengua materna (help_text), que va en una línia a part i no es mira.
 *
 * Sense crides externes: és un comptador de paraules gramaticals exclusives de cada llengua (les que el valencià no
 * té) i d'alfabets no llatins. Les cites («...», "...", '...', *...*) no compten: el personatge pot citar la paraula
 * que l'aprenent ha dit malament («No es diu "bueno", es diu "bé"») o la traducció d'una paraula.
 */

// Paraules que NO són valencianes. Tampoc les que el valencià té amb un altre sentit (por, cosa, pas, os) ni les que el tutor
// cita quan explica la gramàtica (lo, le).
const FOREIGN_WORDS: Record<string, string[]> = {
  es: ['y', 'los', 'las', 'con', 'para', 'pero', 'porque', 'muy', 'como', 'cuando', 'donde', 'dónde', 'qué', 'cómo',
    'está', 'estás', 'están', 'yo', 'tú', 'usted', 'eso', 'esto', 'ese', 'esa', 'hay', 'también', 'más', 'bien', 'gracias',
    'adiós', 'puedes', 'puedo', 'quiero', 'quieres', 'tengo', 'tienes', 'estoy', 'eres', 'soy', 'hacer', 'decir', 'su',
    'sus', 'ya', 'ahora', 'algo', 'vamos', 'bueno', 'buenos', 'buenas', 'días', 'nosotros', 'ellos', 'pon', 'lleva', 'dale',
    'hace', 'dice', 'tiene', 'quién', 'cuál', 'cuántos', 'mamá', 'papá', 'isla', 'claro', 'pongo', 'necesitas', 'gusta', 'quisiera', 'hablar', 'español'],
  en: ['the', 'and', 'is', 'are', 'you', 'to', 'of', 'it', 'this', 'that', 'what', 'how', 'with', 'for', 'your', 'my',
    'can', 'have', 'do', 'please', 'thank', 'thanks', 'hello', 'yes', 'we', 'they', 'be', 'was', 'will', 'not', 'very',
    'good', 'let', "let's", "i'm", "you're", "it's", "don't", 'which', 'them', 'tap', 'touch', 'give', 'one', 'goes',
    'listen', "where's", 'put', 'an', 'there', 'like', 'by', "isn't", "can't", 'well', 'done', 'who', 'says', 'am', 'where'],
  fr: ['le', 'est', 'avec', 'pour', 'je', 'vous', 'nous', 'ce', 'cette', 'dans', 'une', 'du', 'au', 'très',
    'oui', 'merci', 'bonjour', 'il', 'elle', 'sont', 'suis', 'mais', 'comment', 'quoi', "c'est", "j'ai", 'aussi', 'où',
    'ça', 'quelle', 'quel', 'touche', 'écoute', 'fait', 'dit', 'mets', 'donne', 'chaque', 'lui', 'à', 'île', 'veux', 'peux', 'fais'],
  it: ['il', 'è', 'che', 'sono', 'sei', 'molto', 'grazie', 'ciao', 'anche', 'questo', 'questa', 'della', 'gli', 'non',
    'perché', 'come', 'fare', 'io', 'lui', 'buongiorno', 'bene', 'dove', "dov'è", 'nel', 'nello', 'nella', 'alla', 'allo',
    'ogni', 'quale', 'hai', 'sai', 'vuoi', 'puoi', 'tuo', 'tua', 'tocca', 'metti', 'ascolta', 'adesso', 'bravissimo',
    'fai', 'dai', 'quando', 'colora', 'comincia', 'diciamo', 'conosci', 'lettera', 'colore'],
  ro: ['și', 'sunt', 'pentru', 'pe', 'în', 'da', 'eu', 'care', 'foarte', 'mulțumesc', 'bună', 'ziua', 'sau',
    'să', 'că', 'ești', 'unde', 'cu', 'culoare', 'spune', 'atinge', 'pune', 'asta', 'cine', 'iar', 'rog', 'mea'],
  pt: ['não', 'você', 'obrigado', 'obrigada', 'muito', 'uma', 'isso', 'isto', 'ele', 'eles', 'sim', 'olá', 'então'],
};

// Paraules que només són valencianes (entre les llengües de dalt): fan de contrapés en frases mixtes. Sense les que també
// són d'una altra llengua (on, us, he, has, del, al, sí, hola...). I a l'inrevés: «et» o «este» són valencianes.
const VALENCIAN_WORDS = new Set(['i', 'els', 'amb', 'per', 'és', 'això', 'açò', 'aquest', 'aquesta', 'aquests', 'aquestes',
  'hi', 'ho', 'li', 'molt', 'molta', 'molts', 'moltes', 'perquè', 'però', 'també', 'ara', 'doncs', 'més', 'seua', 'teua',
  'meua', 'puc', 'pots', 'vull', 'vols', 'tinc', 'tens', 'soc', 'sóc', 'estic', 'estàs', 'està', 'fer', 'dir', 'bé',
  'gràcies', 'adéu', 'quan', 'ja', 'què', 'res', 'cap', 'encara', 'sempre', 'ací', 'nosaltres', 'vosaltres', 'ells',
  'elles', 'jo', 'dels', 'als', 'pel', 'pels', "d'acord", 'clar', 'bon', 'bona', 'dia', 'vesprada', 'nit', 'em', 'ens',
  'hem', 'heu']);

// Lletres que el valencià no fa servir: castellà (ñ, ¿, ¡), romanés (ș, ț, ă, â, î), portugués (ã, õ). Els signes
// d'obertura (¿, ¡) són tan propis del castellà que compten doble.
const FOREIGN_LETTERS: Record<string, RegExp> = { es: /ñ|[¿¡](?=\p{L})/gu, ro: /[șşțţăâî]/g, pt: /[ãõ]/g };
const DOUBLE_WEIGHT = /[¿¡]/;

// Alfabets no llatins (àrab, ciríl·lic, xinés, grec, hebreu, japonés, coreà, devanagari, tai).
const NON_LATIN = /[\p{Script=Arabic}\p{Script=Cyrillic}\p{Script=Han}\p{Script=Greek}\p{Script=Hebrew}\p{Script=Hiragana}\p{Script=Katakana}\p{Script=Hangul}\p{Script=Devanagari}\p{Script=Thai}]/gu;
const LETTER = /\p{L}/gu;

// Pronoms febles darrere de guionet («fer-lo», «dona-me-la»): es queda el verb. Altres paraules amb guionet (síl·labes com
// «con-ti-nu-a», prefixos com «il-») no compten.
const CLITICS = new Set(['me', 'te', 'se', 'lo', 'la', 'los', 'les', 'li', 'ho', 'hi', 'en', 'ne', 'nos', 'vos', 'us', 'ens']);
const wordOf = (token: string) => {
  const [head, ...rest] = token.split('-');
  return rest.every(part => CLITICS.has(part.replace(/^'+/, ''))) ? head : '';
};

// Cites: «...», “...”, "...", *...* i '...' (aquesta només si no és un apòstrof: davant ha d'haver-hi un espai o res).
const QUOTED = /«[^»]*»|“[^”]*”|"[^"]*"|\*[^*]+\*|(^|\s)'[^'\n]+'/g;

// Paraules estrangeres que fan falta (i més que valencianes) perquè la resposta no es considere valenciana.
const MIN_FOREIGN_WORDS = 2;
// Proporció de lletres d'alfabets no llatins a partir de la qual la resposta no és en valencià.
const MAX_NON_LATIN_SHARE = 0.2;

export type LanguageVerdict = { valencian: boolean; language?: string; reasons: string[] };

export function detectNonValencian(text: string | undefined | null): LanguageVerdict {
  const unquoted = (text ?? '').replace(QUOTED, ' ');
  if (!unquoted.trim()) return { valencian: true, reasons: [] };
  const reasons: string[] = [];

  const letters = unquoted.match(LETTER)?.length ?? 0;
  const nonLatin = unquoted.match(NON_LATIN)?.length ?? 0;
  if (nonLatin >= 3 && nonLatin / letters > MAX_NON_LATIN_SHARE) reasons.push('alfabet_no_llati');

  const tokens = unquoted
    .toLowerCase()
    .replace(/[’‘`´]/g, "'")
    .split(/[^\p{L}'·-]+/u)
    .map(t => wordOf(t.replace(/^'+|'+$/g, '')))
    .filter(Boolean);
  const valencianScore = tokens.filter(t => VALENCIAN_WORDS.has(t)).length;
  let best: { language: string; score: number } | undefined;
  for (const [language, list] of Object.entries(FOREIGN_WORDS)) {
    const words = new Set(list);
    const letters = unquoted.toLowerCase().match(FOREIGN_LETTERS[language] ?? /$^/g) ?? [];
    const score = tokens.filter(t => words.has(t)).length + letters.reduce((sum, l) => sum + (DOUBLE_WEIGHT.test(l) ? 2 : 1), 0);
    if (!best || score > best.score) best = { language, score };
  }
  if (best && best.score >= MIN_FOREIGN_WORDS && best.score > valencianScore) reasons.push(`paraules_${best.language}`);

  return reasons.length
    ? { valencian: false, language: reasons.includes('alfabet_no_llati') ? undefined : best?.language, reasons }
    : { valencian: true, reasons: [] };
}

// Instrucció que s'afig al reintent quan la resposta anterior no era en valencià.
export const VALENCIAN_RETRY_NOTE =
  "La teua resposta anterior en reply_text NO era en valencià. Torna a respondre: reply_text ha de ser NOMÉS en valencià, " +
  "encara que l'aprenent t'escriga en una altra llengua o et demane que li parles en una altra llengua.";

// Resposta segura quan el model, ni reintentant-ho, no respon en valencià.
export const NON_VALENCIAN_REPLY = 'Ací només parlem en valencià. Ho intentem en valencià, d\'acord?';
