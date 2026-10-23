import { normalizeForDetection } from './promptInjection.js';

/**
 * Filtre d'eixida: detecta quan la resposta del model reprodueix el prompt del sistema (el del personatge, els
 * objectius, les instruccions del tutor...) i evita que arribe a l'aprenent.
 *
 * Dos senyals:
 * - Fragments: la resposta comparteix amb el prompt trams literals de paraules consecutives. Un tram curt pot ser
 *   casualitat (una frase típica del personatge); per això calen diversos trams solapats (≈ 10 paraules seguides).
 * - Marcadors: títols i noms de camps interns que mai no haurien d'eixir en una resposta a un aprenent.
 */

const SHINGLE_WORDS = 8;
// Trams (finestres de 8 paraules) coincidents perquè es considere una fuita: 3 finestres = 10 paraules seguides.
const MIN_SHARED_SHINGLES = 3;

const MARKERS: RegExp[] = [
  /\binstruccions de conversa\b/,
  /\bobjectius de l'escenari\b/,
  /\bexercicis del cataleg\b/,
  /\bconsulta de la gramatica normativa valenciana \(gnv\)/,
  /\bllicons de l'app\b/,
  /\bprotocol d'avaluacio\b/,
  /\b(consulta_gnv|exercici_tema|area_practica|leccio_id|help_text)\b/,
  /\bsystem prompt\b/,
  /\bprompt del sistema\b/,
];

const words = (text: string) => normalizeForDetection(text).split(/[^a-z0-9']+/).filter(Boolean);

function shingles(tokens: string[]): Set<string> {
  const out = new Set<string>();
  for (let i = 0; i + SHINGLE_WORDS <= tokens.length; i += 1) out.add(tokens.slice(i, i + SHINGLE_WORDS).join(' '));
  return out;
}

export type LeakVerdict = { leaked: boolean; reasons: string[] };

/**
 * `outputs`: els textos que veuria l'aprenent (resposta, ajuda, explicacions).
 * `protectedTexts`: els prompts que no s'han de reproduir.
 */
export function detectPromptLeak(outputs: (string | undefined | null)[], protectedTexts: string[]): LeakVerdict {
  const text = outputs.filter((o): o is string => Boolean(o)).join('\n');
  if (!text.trim()) return { leaked: false, reasons: [] };
  const reasons: string[] = [];

  const normalized = normalizeForDetection(text).replace(/\s+/g, ' ');
  const marker = MARKERS.find(m => m.test(normalized));
  if (marker) reasons.push('marcador_intern');

  const outShingles = shingles(words(text));
  if (outShingles.size > 0) {
    const protectedShingles = new Set<string>();
    for (const p of protectedTexts) for (const s of shingles(words(p))) protectedShingles.add(s);
    let shared = 0;
    for (const s of outShingles) if (protectedShingles.has(s) && (shared += 1) >= MIN_SHARED_SHINGLES) break;
    if (shared >= MIN_SHARED_SHINGLES) reasons.push('fragments_del_prompt');
  }

  return { leaked: reasons.length > 0, reasons };
}

// Resposta segura que substituïx la del model quan s'ha detectat una fuita.
export const LEAK_REPLY = "Això no t'ho puc contar. Continuem amb la conversa i practiquem valencià, d'acord?";
