/**
 * Evidència fonètica de variant a partir de les respostes de PhoneticXeus.
 *
 * Port fidel de `features.py` / `fetch.clean` / `classify.py` del prototip:
 * per a cada paraula es comparen la transcripció de referència central (`ca`)
 * i la valenciana (`ca-va`) i, allà on difereixen (`ə` ↔ `a`/`e`, `u` ↔ `o`,
 * …), es mesura quin dels dos sons ha sentit l'API com a log-quocient de
 * probabilitats. Les vocals que són iguals en les dues referències fan de
 * línia base (calibratge del parlant i del canal).
 *
 * Les expressions regulars de Python són Unicode per defecte (`\w`, `\b`,
 * `\s` inclouen lletres accentuades); les de JavaScript no, així que ací es
 * construïxen a mà amb classes `\p{…}` equivalents.
 */
import { getOpcodes, type Opcode } from './difflib.js';
import type { HypPhone, PhoneticResponse } from './phoneticApi.js';

/** Suavitzat de les probabilitats abans del logaritme. */
export const EPS = 0.01;

/** Categories d'evidència (les mateixes claus que en Python). */
export type EvidenceCategory =
  | 'a_schwa' | 'e_schwa' | 'o_u' | 'mid_open' | 'v_lab' | 'j_jo' | 'dZ' | 'glide' | 'tS'
  | 'final_r' | 'final_t' | 'j_glide' | 'r_tap' | 'other'
  | 'base_a' | 'base_e' | 'base_o';

/** Evidència per categoria: llista de valors (log P(va)/P(ca), o ±1 si és presència). */
export type Evidence = Partial<Record<EvidenceCategory, number[]>>;

/** Posició on s'ha mesurat una vocal: categoria, índex del fonema reconegut i paraula. */
export type EvidencePosition = { category: EvidenceCategory; hypIndex: number; wordIndex: number };

/* ── Expressions regulars a la manera de Python ───────────────────────────── */

/** `\w` de Python 3 (str): lletres, xifres i guió baix de qualsevol alfabet. */
const PY_W = String.raw`[\p{L}\p{N}_]`;
/** `\s` de Python 3 (str.isspace), que no és igual que el de JavaScript. */
const PY_S_CHARS = String.raw`\t\n\v\f\r\x1c-\x1f \x85\xa0  -     　`;
/** `\b` de Python 3: frontera entre `\w` i no-`\w`. */
const PY_B = `(?:(?<=${PY_W})(?!${PY_W})|(?<!${PY_W})(?=${PY_W}))`;

/** Compila un patró escrit amb la sintaxi de Python (`\b`, `\w`, `\s`, `.`). */
function pyRegex(source: string): RegExp {
  const translated = source
    .replace(/\\b/g, PY_B)
    .replace(/\\w/g, PY_W)
    .replace(/\\s/g, `[${PY_S_CHARS}]`)
    .replace(/(?<!\\)\./g, '[^\\n]');
  return new RegExp(translated, 'gu');
}

const NON_TEXT = new RegExp(String.raw`[^\p{L}\p{N}_${PY_S_CHARS}'’·\-]`, 'gu');
const SPACES = new RegExp(`[${PY_S_CHARS}]+`, 'gu');

/** `fetch.clean`: fora puntuació (la G2P la conserva), apòstrof recte, espais simples. */
export function cleanText(text: string | null | undefined): string {
  const t = (text ?? '').replace(NON_TEXT, ' ').replaceAll('’', "'");
  return t.replace(SPACES, ' ').trim();
}

const REPETITION_LOOP = pyRegex(String.raw`\b(.{6,}?)(?:\s+\1\b){1,}`);

/** Plega els bucles de repetició de Whisper («i va dir i va dir i va dir» → «i va dir»). */
export function collapseLoops(text: string): string {
  return text.replace(REPETITION_LOOP, '$1');
}

/** Text de referència d'un segment: el conegut si n'hi ha, si no el de Whisper. */
export function referenceText(known: string | null | undefined, transcript: string | null | undefined): string {
  return collapseLoops(cleanText(known || transcript));
}

/* ── Marques lèxiques (només per a parla lliure) ─────────────────────────── */

const LEX_VA = [
  String.raw`\best(e|a|os|es)\b`, String.raw`\beix(e|a|os|es)\b`, String.raw`\baixina\b`, String.raw`\bhui\b`,
  String.raw`\bvore\b`, String.raw`\bmeu(a|es)\b`, String.raw`\bseu(a|es)\b`, String.raw`\bteu(a|es)\b`,
  String.raw`\bxiquet`, String.raw`\beixir`, String.raw`\bhuit\b`, String.raw`\bdènou\b`, String.raw`\bdeset\b`,
  String.raw`\bmos\b`, String.raw`\btindre\b`, String.raw`\bvindre\b`, String.raw`\bvullga`,
  String.raw`\bpuga\b`, String.raw`\bfaça\b`, String.raw`\bsiga\b`, String.raw`\bpareix`, String.raw`\bacà\b`,
].map(pyRegex);
const LEX_CA = [
  String.raw`\baquest(a|s|es)?\b`, String.raw`\baquell(a|s|es)?\b`, String.raw`\bavui\b`, String.raw`\bveure\b`,
  String.raw`\bmev(a|es)\b`, String.raw`\bsev(a|es)\b`, String.raw`\btev(a|es)\b`,
  String.raw`\bnens?\b`, String.raw`\bsortir\b`, String.raw`\bvuit\b`, String.raw`\bdinou\b`, String.raw`\bdisset\b`,
  String.raw`\btenir\b`, String.raw`\bvenir\b`, String.raw`\bpugui\b`, String.raw`\bfaci\b`, String.raw`\bsigui\b`,
  String.raw`\bsembla`,
].map(pyRegex);

const countMatches = (patterns: RegExp[], text: string) =>
  patterns.reduce((total, pattern) => total + (text.match(pattern)?.length ?? 0), 0);

/** Formes valencianes menys formes centrals del text (en minúscules). */
export function lexicalScore(text: string): number {
  const t = text.toLowerCase();
  return countMatches(LEX_VA, t) - countMatches(LEX_CA, t);
}

/* ── Fonemes ─────────────────────────────────────────────────────────────── */

/** Unix l'africada amb lligadura de xeus (t͡ʃ) amb la de la G2P (tʃ). */
export const normPhone = (p: string) => p.replaceAll('͡', '');

/** Probabilitat de cada fonema en una posició reconeguda (el millor + alternatives). */
export function posterior(phone: HypPhone): Map<string, number> {
  const d = new Map<string, number>([[phone.ipa, phone.confidence]]);
  for (const alt of phone.alternatives ?? []) d.set(alt.ipa, (d.get(alt.ipa) ?? 0) + alt.prob);
  return d;
}

/** `post` amb les claus normalitzades; si dues coincidixen, guanya l'última (com el dict de Python). */
function normPosterior(phone: HypPhone): Map<string, number> {
  const d = new Map<string, number>();
  for (const [k, v] of posterior(phone)) d.set(normPhone(k), v);
  return d;
}

/** Categoria d'una diferència entre el segment central i el valencià. */
export function category(ca: readonly string[], va: readonly string[], atEnd: boolean): EvidenceCategory {
  const c = ca.join('');
  const v = va.join('');
  const pair = (x: string, y: string) => (c === x && v === y) || (c === y && v === x);
  if (c === 'ə' && v === 'a') return 'a_schwa';
  if (c === 'ə' && v === 'e') return 'e_schwa';
  if (c === 'ə' && v === 'ɛ') return 'e_schwa';
  if (c === 'u' && v === 'o') return 'o_u';
  if (c === 'u' && v === 'ɔ') return 'o_u';
  if (pair('e', 'ɛ') || pair('o', 'ɔ')) return 'mid_open';
  if (c === 'b' && v === 'v') return 'v_lab';
  if ((c === 'ʒ' || c === 'dʒ') && v === 'j') return 'j_jo';
  if (c === 'ʒ' && v === 'dʒ') return 'dZ';
  if (c === '' && v === 'd') return 'dZ';
  if ((c === 'b' || c === 'β') && v === 'v') return 'v_lab';
  if (c === 'ə' && v === 'o') return 'o_u';
  if (c === 'i' && v === 'j') return 'glide';
  if (c === 'ɛ' && v === 'e') return 'mid_open';
  if (c === 'ʃ' && v === 'tʃ') return 'tS';
  if (c === '' && v === 'ɾ' && atEnd) return 'final_r';
  if (c === '' && v === 't' && atEnd) return 'final_t';
  if (c === '' && v === 't') return 'final_t';
  if (c === '' && v === 'j') return 'j_glide';
  if (c === 'r' && v === 'ɾ') return 'r_tap';
  return 'other';
}

/** Opcodes de difflib amb els `replace` multi-fonema d'igual llargària partits 1:1 (ər>eɾ → ə>e, r>ɾ). */
export function splitOps(pc: readonly string[], pv: readonly string[]): Opcode[] {
  const out: Opcode[] = [];
  for (const [op, i1, i2, j1, j2] of getOpcodes(pc, pv, false)) {
    if (op === 'replace' && i2 - i1 === j2 - j1 && i2 - i1 > 1) {
      for (let k = 0; k < i2 - i1; k += 1) {
        if (pc[i1 + k] !== pv[j1 + k]) out.push(['replace', i1 + k, i1 + k + 1, j1 + k, j1 + k + 1]);
      }
    } else {
      out.push([op, i1, i2, j1, j2]);
    }
  }
  return out;
}

const BASE_KEY: Record<string, EvidenceCategory> = { a: 'base_a', e: 'base_e', ɛ: 'base_e', o: 'base_o', ɔ: 'base_o' };

export type WordFeatures = { evidence: Evidence; positions: EvidencePosition[] };

/**
 * `word_features`: evidència a les posicions on la referència central i la
 * valenciana difereixen, més la línia base de vocals estables. `phones` són
 * els fonemes de la crida sense referència (la que porta les alternatives).
 * Torna null si les dues referències no tenen les mateixes paraules.
 */
export function wordFeatures(central: PhoneticResponse, valencian: PhoneticResponse, phones: readonly HypPhone[]): WordFeatures | null {
  const ca = central.alignment;
  const va = valencian.alignment;
  if (!ca || !va) return null;
  const caRef = ca.reference;
  const vaRef = va.reference;
  if (caRef.length !== vaRef.length) return null;
  const vops = new Map(va.ops.filter((o) => o.ref_i !== null).map((o) => [o.ref_i as number, o]));
  const cops = new Map(ca.ops.filter((o) => o.ref_i !== null).map((o) => [o.ref_i as number, o]));
  const evidence: Evidence = {};
  const positions: EvidencePosition[] = [];
  const add = (cat: EvidenceCategory, value: number) => (evidence[cat] ??= []).push(value);
  // Un hyp_j fora de rang faria petar Python; ací es descarta la posició.
  const hyp = (j: number | null) => (j === null ? undefined : phones[j]);
  let offc = 0;
  let offv = 0;

  caRef.forEach((rc, wi) => {
    const rv = vaRef[wi];
    const pc = rc.phones.map(normPhone);
    const pv = rv.phones.map(normPhone);
    const differ = pc.length !== pv.length || pc.some((p, i) => p !== pv[i]);
    if (differ) {
      for (const [op, i1, i2, j1, j2] of splitOps(pc, pv)) {
        if (op === 'equal') continue;
        const cat = category(pc.slice(i1, i2), pv.slice(j1, j2), j2 === pv.length);
        if (op === 'replace' && i2 - i1 === 1 && j2 - j1 === 1) {
          const o = vops.get(offv + j1);
          const phone = o ? hyp(o.hyp_j) : undefined;
          if (!o || !phone) continue; // esborrat: no hi ha vocal per a mesurar
          const d = normPosterior(phone);
          add(cat, Math.log((d.get(pv[j1]) ?? 0) + EPS) - Math.log((d.get(pc[i1]) ?? 0) + EPS));
          positions.push({ category: cat, hypIndex: o.hyp_j as number, wordIndex: wi });
        } else if (op === 'insert') {
          // La valenciana té fonemes de més (r final, t, j).
          for (let j = j1; j < j2; j += 1) {
            const o = vops.get(offv + j);
            if (!o) continue;
            add(cat, o.kind === 'match' ? 1 : o.kind === 'deletion' ? -1 : 0);
          }
        } else if (op === 'delete') {
          // La central té fonemes de més.
          for (let i = i1; i < i2; i += 1) {
            const o = cops.get(offc + i);
            if (!o) continue;
            add(cat, o.kind === 'match' ? -1 : o.kind === 'deletion' ? 1 : 0);
          }
        }
      }
    }
    // Línia base: a / e / o iguals en les dues referències (sobretot tòniques).
    for (const [op, , , j1, j2] of getOpcodes(pc, pv, false)) {
      if (op !== 'equal') continue;
      for (let j = j1; j < j2; j += 1) {
        const target = pv[j];
        const key = BASE_KEY[target];
        if (!key) continue;
        const o = vops.get(offv + j);
        const phone = o ? hyp(o.hyp_j) : undefined;
        if (!o || !phone) continue;
        const d = normPosterior(phone);
        const alt = key === 'base_o' ? 'u' : 'ə';
        add(key, Math.log((d.get(target) ?? 0) + EPS) - Math.log((d.get(alt) ?? 0) + EPS));
        positions.push({ category: key, hypIndex: o.hyp_j as number, wordIndex: wi });
      }
    }
    offc += rc.phones.length;
    offv += rv.phones.length;
  });
  return { evidence, positions };
}
