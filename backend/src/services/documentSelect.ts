import { TEACHER_DOCUMENT_MAX_CHARS } from '@parlaval/shared';
import { normalizeForDetection } from './promptInjection.js';

/**
 * Tria, d'un document llarg (examen o temari), els fragments més rellevants per a la petició de la docent, perquè al model
 * només arribe el que importa i càpiga en el seu context.
 *
 * 1. El text es parteix en fragments d'uns 1.200 caràcters, tallant per paràgrafs.
 * 2. Cada fragment es puntua amb BM25 (coincidència de paraules de la petició, sense accents i per arrel) i, si la petició
 *    cita una part del document («tema 3», «unitat 2»), els fragments que la nomenen guanyen molt de pes.
 * 3. Es trien els millors fins a omplir el pressupost, amb els fragments veïns per a donar context, i sempre l'inici del
 *    document (títol, índex). Es tornen en l'ordre original, separats per «[…]» quan hi ha un salt.
 * Si la petició no diu res concret (cap paraula coincidix), es mostra una mostra repartida per tot el document.
 */

const CHUNK_TARGET = 1200;
const CHUNK_MAX = 2000;
const HEAD_MAX = 2500;
const K1 = 1.2;
const B = 0.75;
const REF_BONUS = 10;
const GAP = '\n\n[…]\n\n';

export type Chunk = { start: number; end: number };

/** Fragments contigus (per desplaçaments) d'unes 1.200 lletres: es junten paràgrafs i es parteixen els molt llargs. */
export function chunkText(text: string): Chunk[] {
  const spans: Chunk[] = [];
  let last = 0;
  for (const m of text.matchAll(/\n\s*\n/g)) {
    spans.push({ start: last, end: m.index });
    last = m.index + m[0].length;
  }
  spans.push({ start: last, end: text.length });

  const chunks: Chunk[] = [];
  let current: Chunk | undefined;
  const flush = () => {
    if (current) chunks.push(current);
    current = undefined;
  };
  for (const span of spans) {
    if (span.end <= span.start) continue;
    if (span.end - span.start > CHUNK_MAX) {
      flush();
      // Un paràgraf molt llarg: es talla en una frase o un espai prop de la mida objectiu.
      let start = span.start;
      while (span.end - start > CHUNK_MAX) {
        const limit = start + CHUNK_TARGET;
        const window = text.slice(limit - 300, limit + 300);
        const sentence = window.search(/[.!?]\s/);
        let cut = sentence >= 0 ? limit - 300 + sentence + 1 : text.lastIndexOf(' ', limit);
        if (cut <= start) cut = limit;
        chunks.push({ start, end: cut });
        start = cut;
      }
      chunks.push({ start, end: span.end });
    } else if (current && span.end - current.start <= CHUNK_TARGET) {
      current.end = span.end;
    } else {
      flush();
      current = { ...span };
    }
  }
  flush();
  return chunks;
}

// Paraules sense contingut propi: les de la manera de demanar («crea exercicis del document») no diuen de què va.
const STOP = new Set([
  'amb', 'sobre', 'entre', 'fins', 'cada', 'tota', 'tots', 'totes', 'aquest', 'aquesta', 'aquests', 'aquestes', 'aixo', 'perque',
  'quan', 'quin', 'quina', 'quins', 'quines', 'pero', 'mateix', 'mateixa', 'molt', 'molta', 'mols', 'moltes', 'tambe', 'despres',
  'para', 'como', 'desde', 'hasta', 'esta', 'este', 'estos', 'estas', 'cuando', 'donde', 'todo', 'toda', 'todos', 'todas',
  'exercici', 'exercicis', 'activitat', 'activitats', 'document', 'documents', 'examen', 'examens', 'temari', 'temaris', 'fitxer',
  'crea', 'crear', 'creeu', 'genera', 'generar', 'ruta', 'rutes', 'pregunta', 'preguntes', 'nivell', 'basat', 'basada', 'basant',
  'segons', 'tipus', 'opcio', 'opcions', 'multiple', 'resposta', 'respostes', 'vull', 'voldria', 'necessite', 'fer', 'fent',
]);

const stem = (word: string) => (word.length > 6 ? word.slice(0, 6) : word);
const tokens = (text: string) => normalizeForDetection(text).match(/[a-z0-9]+/g) ?? [];

/** Les arrels de les paraules de la petició que diuen alguna cosa (de 4 lletres o més i no buides). */
export function queryStems(query: string): string[] {
  return [...new Set(tokens(query).filter(w => w.length >= 4 && !STOP.has(w)).map(stem))];
}

const REF_WORDS = 'tema|unitat|leccio|capitol|apartat|bloc|seccio|annex|part|modul|bloque|unidad|leccion|capitulo|seccion';
/** Parts del document que la petició cita («tema 3», «unitat ii»), normalitzades: «tema 3». */
export function queryReferences(query: string): string[] {
  const normalized = normalizeForDetection(query);
  const found = new Set<string>();
  for (const m of normalized.matchAll(new RegExp(`\\b(${REF_WORDS})\\s*(\\d{1,3}|[ivx]{2,5})\\b`, 'g'))) found.add(`${m[1]} ${m[2]}`);
  return [...found];
}

const referenceRegex = (reference: string) => {
  const [word, number] = reference.split(' ');
  return new RegExp(`\\b${word}\\s*${number}\\b`);
};

export type Selection = { text: string; selected: number; total: number; mode: 'all' | 'relevant' | 'spread' };

export function selectRelevant(
  text: string,
  query: string,
  options: { budget?: number; /** Fragments que no es poden usar (p. ex. amb instruccions per a la IA). */ exclude?: (chunk: string) => boolean } = {},
): Selection {
  const budget = options.budget ?? TEACHER_DOCUMENT_MAX_CHARS;
  const chunks = chunkText(text);
  if (text.length <= budget && !options.exclude) return { text, selected: chunks.length, total: chunks.length, mode: 'all' };

  const slice = (i: number) => text.slice(chunks[i].start, chunks[i].end);
  const length = (i: number) => chunks[i].end - chunks[i].start;
  const banned = new Map<number, boolean>();
  const usable = (i: number) => {
    if (!options.exclude) return true;
    if (!banned.has(i)) banned.set(i, options.exclude(slice(i)));
    return !banned.get(i);
  };

  if (text.length <= budget) {
    const ok = chunks.map((_, i) => i).filter(usable);
    return { text: join(text, chunks, ok), selected: ok.length, total: chunks.length, mode: 'all' };
  }

  // Puntuació BM25 de cada fragment amb les paraules de la petició.
  const stems = queryStems(query);
  const refs = queryReferences(query).map(referenceRegex);
  const tf: Map<string, number>[] = [];
  const lens: number[] = [];
  const df = new Map<string, number>();
  const refHits: number[] = [];
  const wanted = new Set(stems);
  for (let i = 0; i < chunks.length; i += 1) {
    const words = tokens(slice(i));
    lens.push(words.length);
    const counts = new Map<string, number>();
    for (const w of words) {
      const s = stem(w);
      if (wanted.has(s)) counts.set(s, (counts.get(s) ?? 0) + 1);
    }
    for (const s of counts.keys()) df.set(s, (df.get(s) ?? 0) + 1);
    tf.push(counts);
    const normalized = refs.length ? normalizeForDetection(slice(i)) : '';
    refHits.push(refs.filter(r => r.test(normalized)).length);
  }
  const avg = lens.reduce((a, b) => a + b, 0) / Math.max(chunks.length, 1) || 1;
  const scores = chunks.map((_, i) => {
    let score = refHits[i] * REF_BONUS;
    for (const [s, f] of tf[i]) {
      const n = df.get(s) ?? 0;
      const idf = Math.log(1 + (chunks.length - n + 0.5) / (n + 0.5));
      score += (idf * f * (K1 + 1)) / (f + K1 * (1 - B + (B * lens[i]) / avg));
    }
    return score;
  });

  const chosen = new Set<number>();
  let used = 0;
  const add = (i: number) => {
    if (i < 0 || i >= chunks.length || chosen.has(i) || !usable(i) || used + length(i) > budget) return false;
    chosen.add(i);
    used += length(i) + GAP.length;
    return true;
  };

  // L'inici del document (títol, índex) dóna context: sempre que càpiga.
  if (length(0) <= HEAD_MAX) add(0);

  const ranked = chunks.map((_, i) => i).filter(i => scores[i] > 0).sort((a, b) => scores[b] - scores[a] || a - b);
  let mode: Selection['mode'] = 'relevant';
  if (ranked.length === 0) {
    // Cap paraula coincidix: mostra repartida per tot el document.
    mode = 'spread';
    const slots = Math.max(1, Math.floor(budget / (CHUNK_TARGET + GAP.length)));
    for (let k = 0; k < slots; k += 1) add(Math.round((k * (chunks.length - 1)) / Math.max(slots - 1, 1)));
  } else {
    for (const i of ranked) add(i);
    // Si sobra lloc, el context: el fragment següent i l'anterior de cada un, dels millors als pitjors.
    for (const i of ranked) {
      if (!chosen.has(i)) continue;
      add(i + 1);
      add(i - 1);
    }
  }

  const order = [...chosen].sort((a, b) => a - b);
  return { text: join(text, chunks, order), selected: order.length, total: chunks.length, mode };
}

/** Els fragments en ordre, junts si són consecutius i amb «[…]» si hi ha un salt entre ells. */
function join(text: string, chunks: Chunk[], order: number[]): string {
  let out = '';
  order.forEach((i, k) => {
    const body = text.slice(chunks[i].start, chunks[i].end).trim();
    out += k === 0 ? body : order[k - 1] === i - 1 ? `\n\n${body}` : `${GAP}${body}`;
  });
  return out;
}
