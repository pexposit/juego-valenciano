/**
 * Detector de variant: diu si una persona pronuncia en VALENCIÀ o en CATALÀ
 * CENTRAL, a partir de l'API fonètica PhoneticXeus de la UJI.
 *
 * Port de `classify.py` del prototip. Per a cada segment de 3–15 s:
 *  1. `/transcribe` sense referència (fonemes amb alternatives + text de Whisper);
 *  2. alineació amb el text i la fonetització central (`ca`);
 *  3. alineació amb el mateix text i la fonetització valenciana (`ca-va`).
 * A les posicions on les dues fonetitzacions difereixen (sobretot les
 * vocals àtones: `ə` central davant d'`a`/`e` valencianes) es mesura què ha
 * sentit l'API i els formants F1/F2. Tots els segments d'una persona
 * s'ajunten ABANS de puntuar (es sumen evidències, no probabilitats), i el
 * model logístic dona la probabilitat de pronunciació valenciana.
 *
 * Límits coneguts: només val per a parla contínua real (no paraules
 * soltes ni veus sintètiques, que sonen centrals), és binari (el balear i
 * el nord-occidental no hi entren) i no s'ha provat amb el micròfon del
 * navegador. El veredicte descriu la PRONUNCIACIÓ, mai la persona.
 */
import { CONSTANTS, MODELS, scoreFeatures, type FeatureKey, type Features, type ModelName } from './model.js';
import { lexicalScore, referenceText, wordFeatures, type Evidence, type EvidenceCategory } from './features.js';
import { measureFormants, median } from './formants.js';
import { createPhoneticApi, type PhoneticBackend, type PhoneticResponse } from './phoneticApi.js';
import { decodeWav, encodeWav, segmentSpeech, type MonoAudio, type SegmentOptions } from './segment.js';

export type Verdict = 'valencia' | 'central' | 'indeterminat';

/** Per què no hi ha veredicte. */
export type IndeterminateReason = 'sense-veu-utilitzable' | 'poca-evidencia' | 'zona-dubtosa';

/** Per què s'ha descartat un segment. */
export type RejectReason =
  | 'error-api'          // l'API no ha respost 200
  | 'pocs-fonemes'       // menys de 15 fonemes: silenci, soroll o massa curt
  | 'sense-text'         // Whisper no ha tornat text (o ha fallat)
  | 'sense-alineacio'    // alguna de les dues alineacions ha fallat
  | 'referencia-dubtosa' // el text no casa amb l'àudio (PER valencià > 0,7)
  | 'paraules-desquadrades'; // les dues fonetitzacions no tenen les mateixes paraules

/** Categories on es mesuren formants (les que usa el model). */
export type FormantCategory = 'a_schwa' | 'e_schwa' | 'base_a';
const FORMANT_CATEGORIES: readonly EvidenceCategory[] = ['a_schwa', 'e_schwa', 'base_a'];

/** Evidència en brut d'un segment acceptat; és el que s'ajunta entre gravacions. */
export type SegmentEvidence = {
  startS: number
  endS: number
  /** Text de referència usat (el conegut o el de Whisper, net). */
  text: string
  /** Log-quocients per categoria, sense retallar. */
  evidence: Evidence
  /** [F1, F2] (Hz) a cada vocal de les categories que usa el model. */
  formants: Partial<Record<FormantCategory, [number, number][]>>
  /** PER central − PER valencià: positiu si la fonetització valenciana encaixa millor. */
  dPer: number
  /** Formes valencianes − centrals del text; null si el text era conegut. */
  lex: number | null
};

/** Resultat d'analitzar un segment: l'evidència o el motiu del descart. */
export type SegmentAnalysis =
  | { ok: true; segment: SegmentEvidence }
  | { ok: false; startS: number; endS: number; reason: RejectReason; status?: number };

/** Un segment a punt per a l'API: el fitxer que es puja i les mostres per als formants. */
export type SegmentInput = MonoAudio & {
  wav: Uint8Array
  /** Nom del fitxer pujat (amb extensió acceptada); per defecte `segment.wav`. */
  filename?: string
  startS?: number
  endS?: number
};

export type AnalyseOptions = {
  backend?: PhoneticBackend
  /** Text que la persona havia de llegir. Sense, s'usa el de Whisper (parla lliure). */
  referenceText?: string | null
};

let defaultBackend: PhoneticBackend | null = null;
const backendOf = (options: AnalyseOptions) => options.backend ?? (defaultBackend ??= createPhoneticApi());

/** Les tres crides d'un segment i l'evidència que se'n trau (`analyse_segment`). */
export async function analyseSegment(input: SegmentInput, options: AnalyseOptions = {}): Promise<SegmentAnalysis> {
  const backend = backendOf(options);
  const startS = input.startS ?? 0;
  const endS = input.endS ?? startS + input.samples.length / input.sampleRate;
  const reject = (reason: RejectReason, status?: number): SegmentAnalysis => ({ ok: false, startS, endS, reason, status });
  const audio = { data: input.wav, filename: input.filename ?? 'segment.wav' };
  const known = options.referenceText?.trim() || null;

  const free = await backend.transcribe(audio, { include_text: 'true', align: 'true', top_k: '5' });
  if (free._status !== 200) return reject('error-api', free._status);
  const phones = free.phones ?? [];
  if (phones.length < CONSTANTS.min_phones) return reject('pocs-fonemes');
  if (!known && free.text_error) return reject('sense-text');
  const text = referenceText(known, free.text_transcript);
  if (!text) return reject('sense-text');

  const central = await backend.transcribe(audio, { align: 'true', g2p_language: 'ca', reference_text: text });
  const valencian = await backend.transcribe(audio, {
    align: 'true', g2p_language: 'ca-va', variants: 'false', reference_text: text,
  });
  if (!central.alignment || !valencian.alignment) {
    const failed = [central, valencian].find((r: PhoneticResponse) => r._status !== 200);
    return failed ? reject('error-api', failed._status) : reject('sense-alineacio');
  }
  if (valencian.alignment.summary.per > 0.7) return reject('referencia-dubtosa');
  const words = wordFeatures(central, valencian, phones);
  if (!words) return reject('paraules-desquadrades');

  // Formants a les vocals mesurades; el pic de CTC cau a l'inici de la vocal,
  // així que es mesura un poc més endavant (t_shift_s).
  const formants: SegmentEvidence['formants'] = {};
  for (const { category, hypIndex } of words.positions) {
    if (!FORMANT_CATEGORIES.includes(category)) continue;
    const phone = phones[hypIndex];
    const t = (phone.start_s + phone.end_s) / 2 + CONSTANTS.lpc.t_shift_s;
    const m = measureFormants(input.samples, input.sampleRate, t);
    if (m) (formants[category as FormantCategory] ??= []).push(m);
  }

  return {
    ok: true,
    segment: {
      startS,
      endS,
      text,
      evidence: words.evidence,
      formants,
      dPer: central.alignment.summary.per - valencian.alignment.summary.per,
      lex: known ? null : lexicalScore(text),
    },
  };
}

/* ── Puntuació ───────────────────────────────────────────────────────────── */

export type VariantResult = {
  verdict: Verdict
  /** Frase per a mostrar: descriu la pronunciació, no la persona. */
  label: string
  reason: IndeterminateReason | null
  /** Probabilitat de pronunciació valenciana; null si no hi ha cap segment útil. */
  pValencia: number | null
  model: ModelName
  /** Vocals àtones mesurades (a/e reduïbles); en calen almenys 6. */
  nAe: number
  features: Features
  /** w·(x − farciment) per variable: positiu empeny cap a valencià. */
  contributions: Partial<Record<FeatureKey, number>>
  usableSegments: number
  /** Durada total dels segments útils (s). */
  speechSeconds: number
  texts: string[]
};

const LABELS: Record<Verdict, string> = {
  valencia: 'Pronunciació valenciana',
  central: 'Pronunciació central',
  indeterminat: 'No es pot determinar la pronunciació',
};

/** Explicació curta de cada motiu d'indeterminació (per a la interfície). */
export const REASON_TEXT: Record<IndeterminateReason, string> = {
  'sense-veu-utilitzable': "No s'ha pogut analitzar cap tros de veu: cal parlar seguit uns quants segons.",
  'poca-evidencia': 'Encara hi ha poques vocals àtones per a decidir: cal parlar una mica més.',
  'zona-dubtosa': 'La pronunciació queda entre les dues variants: amb més veu es pot afinar.',
};

const mean = (values: number[]) => (values.length ? values.reduce((acc, v) => acc + v, 0) / values.length : null);

/** Variables del model a partir de l'evidència ajuntada de tots els segments. */
export function poolFeatures(segments: readonly SegmentEvidence[]): { features: Features; nAe: number } {
  const clip = (v: number) => Math.max(-CONSTANTS.CLIP, Math.min(CONSTANTS.CLIP, v));
  const pool = (key: EvidenceCategory) => segments.flatMap((s) => (s.evidence[key] ?? []).map(clip));
  const fpool = (key: FormantCategory) => segments.flatMap((s) => s.formants[key] ?? []);
  const med = (values: [number, number][], k: 0 | 1) =>
    (values.length < CONSTANTS.min_formant_tokens ? null : median(values.map((v) => v[k])));
  const logRatio = (num: number | null, den: number | null) => (num && den ? Math.log(num / den) : null);

  const target = [...pool('a_schwa'), ...pool('e_schwa')];
  const base = [...pool('base_a'), ...pool('base_e')];
  const ou = pool('o_u');
  const baseO = pool('base_o');
  const a1 = med(fpool('a_schwa'), 0);
  const e1 = med(fpool('e_schwa'), 0);
  const ba1 = med(fpool('base_a'), 0);
  const a2 = med(fpool('a_schwa'), 1);
  const e2 = med(fpool('e_schwa'), 1);
  const lexes = segments.map((s) => s.lex).filter((v): v is number => v !== null);
  const lexSum = lexes.reduce((acc, v) => acc + v, 0);

  return {
    nAe: target.length,
    features: {
      norm_ae: target.length && base.length ? mean(target)! - mean(base)! : null,
      norm_o_u: ou.length && baseO.length ? mean(ou)! - mean(baseO)! : null,
      f1_ae: logRatio(a1, e1),
      f2_ea: logRatio(e2, a2),
      f1_a_rel: logRatio(a1, ba1),
      d_per: mean(segments.map((s) => s.dPer)),
      // Sense límit: el model es va entrenar amb la suma crua de marcadors.
      lex: lexes.length ? lexSum : null,
    },
  };
}

export type ScoreOptions = {
  /** Força un model; per defecte `with_lex` si algun segment és parla lliure. */
  model?: ModelName
};

/** Puntua l'evidència ajuntada i dona el veredicte (`score` de `classify.py`). */
export function scoreSegments(segments: readonly SegmentEvidence[], options: ScoreOptions = {}): VariantResult {
  const anyFree = segments.some((s) => s.lex !== null);
  const model: ModelName = options.model ?? (anyFree ? 'with_lex' : 'no_lex');
  const emptyFeatures = Object.fromEntries(MODELS.with_lex.keys.map((k) => [k, null])) as Features;
  if (segments.length === 0) {
    return {
      verdict: 'indeterminat', label: LABELS.indeterminat, reason: 'sense-veu-utilitzable', pValencia: null, model,
      nAe: 0, features: emptyFeatures, contributions: {}, usableSegments: 0, speechSeconds: 0, texts: [],
    };
  }
  const { features, nAe } = poolFeatures(segments);
  const { pValencia, contributions } = scoreFeatures(features, model);
  const [lo, hi] = CONSTANTS.band;
  let reason: IndeterminateReason | null = null;
  if (nAe < CONSTANTS.min_ae_positions) reason = 'poca-evidencia';
  else if (lo < pValencia && pValencia < hi) reason = 'zona-dubtosa';
  const verdict: Verdict = reason ? 'indeterminat' : pValencia >= hi ? 'valencia' : 'central';
  return {
    verdict,
    label: LABELS[verdict],
    reason,
    pValencia,
    model,
    nAe,
    features,
    contributions,
    usableSegments: segments.length,
    speechSeconds: segments.reduce((acc, s) => acc + (s.endS - s.startS), 0),
    texts: segments.map((s) => s.text),
  };
}

/* ── Gravacions i sessions ───────────────────────────────────────────────── */

/** Una gravació: un WAV PCM16 sencer o mostres ja descodificades. */
export type RecordingInput = Uint8Array | MonoAudio;

export type RecordingOptions = AnalyseOptions & {
  /**
   * Talla la gravació en segments de 3–15 s (per defecte). Amb `false` es
   * puja tal qual com un sol segment, com feia el prototip amb cada clip.
   * Amb `referenceText` no es talla mai: el text descriu tota la gravació.
   */
  segment?: boolean | SegmentOptions
  /** Nom base dels fitxers pujats. */
  filename?: string
};

/** Analitza una gravació sencera (tots els seus segments, en fila). */
export async function analyseRecording(audio: RecordingInput, options: RecordingOptions = {}): Promise<SegmentAnalysis[]> {
  const isWav = audio instanceof Uint8Array;
  const mono = isWav ? decodeWav(audio) : audio;
  const base = (options.filename ?? 'gravacio').replace(/\.[a-z0-9]+$/i, '');
  // Amb text conegut va sencera (com `classify.py --ref`): alinear tot el
  // text contra un tros en faria fallar la referència.
  if (options.segment === false || options.referenceText?.trim()) {
    const wav = isWav ? audio : encodeWav(mono.samples, mono.sampleRate);
    return [await analyseSegment({ ...mono, wav, filename: `${base}.wav` }, options)];
  }
  const segments = segmentSpeech(mono, typeof options.segment === 'object' ? options.segment : {});
  const results: SegmentAnalysis[] = [];
  for (const [i, segment] of segments.entries()) {
    results.push(await analyseSegment({ ...segment, filename: `${base}-${i + 1}.wav` }, options));
  }
  return results;
}

/** Detecta la variant d'una o més gravacions d'UNA mateixa persona. */
export async function detectVariant(
  recordings: RecordingInput | RecordingInput[],
  options: RecordingOptions & ScoreOptions = {},
): Promise<VariantResult & { segments: SegmentAnalysis[] }> {
  const session = new VariantSession(options);
  for (const recording of Array.isArray(recordings) ? recordings : [recordings]) {
    await session.addRecording(recording, options);
  }
  return { ...session.result(), segments: session.analyses };
}

/**
 * Acumulador d'una persona al llarg de diverses gravacions: guarda
 * l'evidència en brut de cada segment i puntua sempre sobre el conjunt, de
 * manera que el veredicte s'afina com més parla (no es fa la mitjana de
 * probabilitats, que amb trossos curts seria massa sorollosa).
 */
export class VariantSession {
  private readonly evidence: SegmentEvidence[] = [];
  private readonly all: SegmentAnalysis[] = [];

  constructor(private readonly options: RecordingOptions & ScoreOptions = {}) {}

  /** Analitza una gravació i n'afig l'evidència; torna l'anàlisi de cada segment. */
  async addRecording(audio: RecordingInput, options: RecordingOptions = {}): Promise<SegmentAnalysis[]> {
    const analyses = await analyseRecording(audio, { ...this.options, ...options });
    this.addAnalyses(analyses);
    return analyses;
  }

  /** Afig anàlisis ja fetes (per exemple, des d'una fila de treball pròpia). */
  addAnalyses(analyses: readonly SegmentAnalysis[]): void {
    for (const analysis of analyses) {
      this.all.push(analysis);
      if (analysis.ok) this.evidence.push(analysis.segment);
    }
  }

  /** Totes les anàlisis de segments de la sessió (acceptats i descartats). */
  get analyses(): SegmentAnalysis[] {
    return [...this.all];
  }

  /** Veredicte amb tota l'evidència acumulada fins ara. */
  result(): VariantResult {
    return scoreSegments(this.evidence, { model: this.options.model });
  }

  reset(): void {
    this.evidence.length = 0;
    this.all.length = 0;
  }
}
