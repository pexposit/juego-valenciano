/**
 * Peça d'unió entre el detector de variant i qui l'usa (el servidor del
 * laboratori i la CLI): remostreig a 16 kHz, anàlisi d'una gravació amb el
 * temps de cada segment, sessions en memòria per a acumular l'evidència
 * d'una persona, comprovació de l'API fonètica i textos en valencià per a
 * explicar el resultat.
 *
 * L'algorisme no es toca ací: tot el que decidix el veredicte viu a
 * `detector.ts` i `model.ts`.
 */
import { config } from '../config.js';
import {
  analyseSegment,
  REASON_TEXT,
  VariantSession,
  type RejectReason,
  type SegmentAnalysis,
  type SegmentInput,
  type VariantResult,
} from './detector.js';
import type { FeatureKey } from './model.js';
import type { PhoneticBackend } from './phoneticApi.js';
import { encodeWav, segmentSpeech, type MonoAudio } from './segment.js';

/** Freqüència amb què s'analitza tot (la del laboratori i la de l'API). */
export const TARGET_RATE = 16_000;

/** Amb text conegut la gravació va sencera a l'API: més enllà d'això es tracta com a parla lliure. */
export const REFERENCE_MAX_S = 20;

/** Per davall d'esta veu útil el veredicte és orientatiu (~80 % amb 5 s, ~90 % amb 10–20 s). */
export const RELIABLE_SPEECH_S = 10;

/** Missatge quan l'API no respon: el motiu habitual és estar fora de la xarxa de la UJI. */
export const PHONETIC_HINT =
  "L'API fonètica només és accessible des de la intranet de la UJI (o amb la VPN de la UJI).";

/* ── Remostreig ──────────────────────────────────────────────────────────── */

/** Mitja amplada del nucli en passos de la freqüència més baixa (qualitat / cost). */
const SINC_HALF_TAPS = 10;

/** Freqüències d'entrada acceptades: fora d'este marge el remostreig seria massa car (o no té sentit). */
export const MIN_INPUT_RATE = 8_000;
export const MAX_INPUT_RATE = 96_000;

const gcd = (a: number, b: number): number => (b === 0 ? a : gcd(b, a % b));

/**
 * Remostreja amb un sinc enfinestrat (Hann). En baixar de freqüència el
 * mateix nucli fa de filtre passa-baix: la interpolació lineal de la pàgina
 * deixa passar aliasing que embruta les vocals que mesura el detector. Els
 * pesos es normalitzen a cada mostra, així que les vores no perden nivell.
 *
 * Amb freqüències enteres la posició fraccionària de cada mostra de
 * sortida es repetix cada `q` mostres (polifase): els pesos de cada fase
 * es calculen una vegada i el bucle interior només multiplica i suma. Tot
 * corre al fil principal del servidor, i sense la taula un WAV de 48 kHz
 * de dos minuts el bloquejava uns segons.
 */
export function resampleTo(audio: MonoAudio, targetRate = TARGET_RATE): MonoAudio {
  const { samples, sampleRate } = audio;
  if (sampleRate === targetRate) return audio;
  const ratio = sampleRate / targetRate;
  // Tall a un 95 % del Nyquist de la freqüència més baixa, en unitats de l'entrada.
  const cutoff = Math.min(1, 1 / ratio) * 0.95;
  const half = SINC_HALF_TAPS / cutoff;
  const weightAt = (x: number) => {
    const arg = Math.PI * cutoff * x;
    const sinc = x === 0 ? 1 : Math.sin(arg) / arg;
    return sinc * (0.5 + 0.5 * Math.cos((Math.PI * x) / half));
  };
  // t = n·p/q: part entera i fase r = n·p mod q (de 0 a q-1).
  const integer = Number.isInteger(sampleRate) && Number.isInteger(targetRate);
  const g = integer ? gcd(sampleRate, targetRate) : 1;
  const p = sampleRate / g;
  const q = integer ? targetRate / g : 0;
  const phases = new Map<number, { first: number; weights: Float64Array }>();
  const kernel = (r: number) => {
    let entry = phases.get(r);
    if (!entry) {
      const frac = r / q;
      const first = Math.ceil(frac - half);
      const last = Math.floor(frac + half);
      const weights = new Float64Array(last - first + 1);
      for (let j = 0; j < weights.length; j += 1) weights[j] = weightAt(first + j - frac);
      entry = { first, weights };
      phases.set(r, entry);
    }
    return entry;
  };

  const out = new Float32Array(Math.floor(samples.length / ratio));
  for (let n = 0; n < out.length; n += 1) {
    let acc = 0;
    let weights = 0;
    if (integer) {
      const base = Math.floor((n * p) / q);
      const { first, weights: w } = kernel(n * p - base * q);
      const from = Math.max(0, base + first);
      const to = Math.min(samples.length - 1, base + first + w.length - 1);
      for (let k = from; k <= to; k += 1) {
        const wk = w[k - base - first];
        acc += samples[k] * wk;
        weights += wk;
      }
    } else {
      const t = n * ratio;
      const from = Math.max(0, Math.ceil(t - half));
      const to = Math.min(samples.length - 1, Math.floor(t + half));
      for (let k = from; k <= to; k += 1) {
        const w = weightAt(k - t);
        acc += samples[k] * w;
        weights += w;
      }
    }
    out[n] = weights !== 0 ? acc / weights : 0;
  }
  return { samples: out, sampleRate: targetRate };
}

/* ── Anàlisi d'una gravació ──────────────────────────────────────────────── */

export type TimedAnalysis = { analysis: SegmentAnalysis; ms: number };

export type RecordingAnalysis = {
  analyses: TimedAnalysis[]
  /** Segments que han quedat sense analitzar (l'API ha deixat de respondre o s'ha avortat). */
  skipped: number
  /** L'anàlisi s'ha avortat amb `signal` abans d'acabar. */
  aborted: boolean
  /** S'ha usat el text conegut (si n'hi havia i la gravació no era massa llarga). */
  usedReference: boolean
  audioSeconds: number
  notes: string[]
};

export type AnalyseRecordingOptions = {
  backend?: PhoneticBackend
  referenceText?: string | null
  /** Nom base dels fitxers que es pugen (sempre acaben en `.wav`). */
  filename?: string
  /** Si s'avorta (el client se n'ha anat), no s'envien més segments a l'API. */
  signal?: AbortSignal
};

/** L'API no ha arribat a respondre (xarxa, DNS, temps esgotat). */
const unreachable = (analysis: SegmentAnalysis) => !analysis.ok && analysis.reason === 'error-api' && analysis.status === -1;

/**
 * Analitza una gravació (ja a 16 kHz) i apunta quant ha tardat cada segment.
 *
 * Amb text conegut la gravació va SENCERA com un sol segment: el text
 * descriu tota la gravació, i alinear-lo contra un tros en faria fallar la
 * referència. Si dura més de `REFERENCE_MAX_S` es tracta com a parla
 * lliure i es diu en una nota. Si l'API no respon es deixa d'insistir: els
 * segments que queden esperarien cada un el temps màxim.
 */
export async function analyseRecordingTimed(audio: MonoAudio, options: AnalyseRecordingOptions = {}): Promise<RecordingAnalysis> {
  const audioSeconds = audio.samples.length / audio.sampleRate;
  const base = (options.filename ?? 'gravacio').replace(/\.[a-z0-9]+$/i, '').replace(/[^\w.-]+/g, '_') || 'gravacio';
  const notes: string[] = [];
  let known = options.referenceText?.trim() || null;
  if (known && audioSeconds > REFERENCE_MAX_S) {
    notes.push(
      `Amb text llegit la gravació ha de durar com a màxim ${REFERENCE_MAX_S} s; esta en dura`
      + ` ${audioSeconds.toFixed(1)} i s'ha analitzat com a parla lliure (sense el text).`,
    );
    known = null;
  }

  const pieces: SegmentInput[] = known
    ? [{ ...audio, wav: encodeWav(audio.samples, audio.sampleRate), startS: 0, endS: audioSeconds }]
    : segmentSpeech(audio);
  const analyses: TimedAnalysis[] = [];
  for (const [i, piece] of pieces.entries()) {
    if (options.signal?.aborted) break;
    const started = Date.now();
    const analysis = await analyseSegment(
      { ...piece, filename: `${base}-${i + 1}.wav` },
      { backend: options.backend, referenceText: known },
    );
    analyses.push({ analysis, ms: Date.now() - started });
    if (unreachable(analysis)) break;
  }
  const skipped = pieces.length - analyses.length;
  if (skipped > 0 && !options.signal?.aborted) {
    const seconds = (list: readonly SegmentInput[]) => list.reduce((acc, s) => acc + (s.endS ?? 0) - (s.startS ?? 0), 0);
    notes.push(
      `L'API fonètica ha deixat de respondre: només s'han analitzat ${analyses.length} de ${pieces.length} trossos`
      + ` (${seconds(pieces.slice(0, analyses.length)).toFixed(1)} s de ${seconds(pieces).toFixed(1)} s de veu).`,
    );
  }
  return {
    analyses, skipped, aborted: options.signal?.aborted ?? false, usedReference: known !== null, audioSeconds, notes,
  };
}

/** Alguna anàlisi s'ha quedat sense resposta de l'API (xarxa, DNS, temps esgotat). */
export function anyUnreachable(analyses: readonly TimedAnalysis[]): boolean {
  return analyses.some(({ analysis }) => unreachable(analysis));
}

/** Totes les anàlisis han fallat perquè l'API no ha respost bé (no per la veu). */
export function apiFailure(analyses: readonly TimedAnalysis[]): { status: number } | null {
  if (analyses.length === 0) return null;
  const failed = analyses.every(({ analysis }) => !analysis.ok && analysis.reason === 'error-api');
  if (!failed) return null;
  const first = analyses[0].analysis;
  return { status: !first.ok ? first.status ?? -1 : -1 };
}

/* ── Sessions ────────────────────────────────────────────────────────────── */

export type SessionEntry = {
  session: VariantSession
  /** Gravacions analitzades des de l'últim reinici. */
  recordings: number
  touchedAt: number
};

/**
 * Sessions en memòria per identificador: cada una guarda l'evidència en brut
 * d'una persona i puntua sempre sobre el conjunt. Caduquen al cap de `ttlMs`
 * sense ús i, si se'n creen massa, cau la que fa més temps que no s'usa.
 * Res es guarda a disc: en reiniciar el laboratori es perden.
 */
export class VariantSessionStore {
  private readonly entries = new Map<string, SessionEntry>();

  constructor(
    private readonly ttlMs = config.variant.sessionTtlMs,
    private readonly maxSessions = config.variant.maxSessions,
    private readonly now: () => number = Date.now,
  ) {}

  /** Identificadors acceptats: curts i sense caràcters estranys. */
  static validId(id: string): boolean {
    return /^[\w-]{1,64}$/.test(id);
  }

  /** La sessió `id` (es crea si no hi és o havia caducat). */
  get(id: string): SessionEntry {
    this.sweep();
    let entry = this.entries.get(id);
    if (!entry) {
      entry = { session: new VariantSession(), recordings: 0, touchedAt: this.now() };
      this.entries.set(id, entry);
      this.evict();
    }
    entry.touchedAt = this.now();
    return entry;
  }

  reset(id: string): void {
    const entry = this.entries.get(id);
    if (!entry) return;
    entry.session.reset();
    entry.recordings = 0;
    entry.touchedAt = this.now();
  }

  get size(): number {
    this.sweep();
    return this.entries.size;
  }

  private sweep(): void {
    const limit = this.now() - this.ttlMs;
    for (const [id, entry] of this.entries) if (entry.touchedAt < limit) this.entries.delete(id);
  }

  private evict(): void {
    while (this.entries.size > this.maxSessions) {
      let oldest: string | null = null;
      for (const [id, entry] of this.entries) {
        if (oldest === null || entry.touchedAt < this.entries.get(oldest)!.touchedAt) oldest = id;
      }
      if (oldest === null) return;
      this.entries.delete(oldest);
    }
  }
}

/* ── API fonètica: està viva? ────────────────────────────────────────────── */

export type PingResult =
  | { ok: true; url: string; latencyMs: number; model: string | null; device: string | null }
  | { ok: false; url: string; latencyMs: number; error: string };

/** `GET /health` de PhoneticXeus amb un temps curt: per a fallar ràpid fora de la intranet. */
export async function pingPhoneticApi(
  baseUrl = config.phonetic.baseUrl,
  timeoutMs = 5000,
  fetchImpl: typeof fetch = fetch,
): Promise<PingResult> {
  const url = baseUrl.replace(/\/$/, '');
  const started = Date.now();
  try {
    const response = await fetchImpl(`${url}/health`, { signal: AbortSignal.timeout(timeoutMs) });
    const latencyMs = Date.now() - started;
    if (!response.ok) return { ok: false, url, latencyMs, error: `l'API ha respost ${response.status}` };
    const body = await response.json().catch(() => ({})) as { model?: unknown; device?: unknown };
    return {
      ok: true,
      url,
      latencyMs,
      model: typeof body.model === 'string' ? body.model : null,
      device: typeof body.device === 'string' ? body.device : null,
    };
  } catch (error) {
    const cause = error instanceof Error && error.cause instanceof Error ? ` (${error.cause.message})` : '';
    return { ok: false, url, latencyMs: Date.now() - started, error: `${error instanceof Error ? error.message : String(error)}${cause}` };
  }
}

/* ── Textos per a explicar el resultat ───────────────────────────────────── */

/** Què mesura cada variable, en paraules planes. */
export const FEATURE_TEXT: Record<FeatureKey, string> = {
  norm_ae: 'Vocals àtones obertes (a/e no reduïdes a vocal neutra)',
  norm_o_u: 'o àtona que no es tanca en u',
  f1_ae: 'F1 de la a àtona respecte de la e àtona (com d’oberta és la a)',
  f2_ea: 'F2 de la e àtona respecte de la a àtona (com de davantera és la e)',
  f1_a_rel: 'Obertura de la a àtona respecte de la a tònica',
  d_per: 'Quina fonetització encaixa millor, la valenciana o la central',
  lex: 'Paraules marcadores (este, hui, eixir… davant d’aquest, avui, sortir…)',
};

/** Per què s'ha descartat un segment, en paraules planes. */
export const REJECT_TEXT: Record<RejectReason, string> = {
  'error-api': "L'API fonètica no ha respost bé",
  'pocs-fonemes': 'Massa poca veu (menys de 15 sons): silenci, soroll o un tros massa curt',
  'sense-text': "No s'ha pogut transcriure el tros",
  'sense-alineacio': "No s'ha pogut alinear la veu amb el text",
  'referencia-dubtosa': 'El text no casa amb el que es diu',
  'paraules-desquadrades': 'Les dues fonetitzacions del text no quadren paraula per paraula',
};

export type Contribution = {
  feature: FeatureKey
  text: string
  /** Valor mesurat (null si no s'ha pogut mesurar i s'ha usat el farciment). */
  value: number | null
  /** Empenta al logit: positiva cap a valencià, negativa cap a central. */
  contribution: number
  towards: 'valencia' | 'central' | null
};

/** Contribucions ordenades de més a menys pes, amb el text de cada variable. */
export function explainContributions(result: VariantResult): Contribution[] {
  return (Object.entries(result.contributions) as [FeatureKey, number][])
    .map(([feature, contribution]) => ({
      feature,
      text: FEATURE_TEXT[feature],
      value: result.features[feature],
      contribution,
      towards: Math.abs(contribution) < 1e-9 ? null : contribution > 0 ? 'valencia' as const : 'central' as const,
    }))
    .sort((a, b) => Math.abs(b.contribution) - Math.abs(a.contribution));
}

/** Avisos honestos sobre la quantitat de veu (es mostren davall del veredicte). */
export function speechNotes(result: VariantResult, audioSeconds: number): string[] {
  const notes: string[] = [];
  if (audioSeconds < 3) {
    notes.push(`L'àudio dura ${audioSeconds.toFixed(1)} s: és massa curt. Cal parla seguida, idealment 10–20 s.`);
  } else if (result.usableSegments > 0 && result.speechSeconds < RELIABLE_SPEECH_S) {
    notes.push(
      `Només hi ha ${result.speechSeconds.toFixed(1)} s de veu útil: el veredicte és orientatiu`
      + ' (≈80 % d’encert amb 5 s, ≈90 % amb 10–20 s de parla seguida).',
    );
  }
  return notes;
}

/** Un segment per a la resposta: on és, què s'hi ha entés i si ha servit. */
export type SegmentReport = {
  startS: number
  endS: number
  /** Text de referència usat (el conegut o el de Whisper); null si s'ha descartat. */
  text: string | null
  usable: boolean
  reason: RejectReason | null
  reasonText: string | null
  /** Codi HTTP de l'API quan el motiu és `error-api` (-1: no ha respost). */
  status?: number
  /** Posicions on les dues fonetitzacions difereixen i s'ha mesurat evidència. */
  positions: number
  /** D'elles, vocals àtones a/e (les que compten per al mínim de 6). */
  nAe: number
  ms: number
};

export function describeSegment({ analysis, ms }: TimedAnalysis): SegmentReport {
  if (!analysis.ok) {
    return {
      startS: round(analysis.startS, 2),
      endS: round(analysis.endS, 2),
      text: null,
      usable: false,
      reason: analysis.reason,
      reasonText: REJECT_TEXT[analysis.reason],
      ...(analysis.status !== undefined ? { status: analysis.status } : {}),
      positions: 0,
      nAe: 0,
      ms,
    };
  }
  const { segment } = analysis;
  const count = (values: number[] | undefined) => values?.length ?? 0;
  return {
    startS: round(segment.startS, 2),
    endS: round(segment.endS, 2),
    text: segment.text,
    usable: true,
    reason: null,
    reasonText: null,
    positions: Object.values(segment.evidence).reduce((acc, values) => acc + count(values), 0),
    nAe: count(segment.evidence.a_schwa) + count(segment.evidence.e_schwa),
    ms,
  };
}

/** Veredicte llest per a la resposta JSON (o per a la CLI). */
export function describeResult(result: VariantResult) {
  return {
    verdict: result.verdict,
    label: result.label,
    pValencia: result.pValencia === null ? null : round(result.pValencia, 4),
    model: result.model,
    reason: result.reason,
    reasonText: result.reason ? REASON_TEXT[result.reason] : null,
    features: result.features,
    contributions: explainContributions(result),
  };
}

const round = (value: number, digits: number) => Number(value.toFixed(digits));
