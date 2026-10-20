/**
 * Model logístic del detector i puntuació d'un conjunt de segments.
 *
 * Els pesos (`model.json`) són els del prototip en Python, entrenat amb parla
 * real contínua (validació deixant fora un parlant cada vegada): ~80 %
 * d'encert amb un tros de 5 s, ~89–93 % amb 10–20 s. Hi ha dos models:
 * `with_lex` per a parla lliure (compta formes com «este», «hui», «eixir»)
 * i `no_lex` quan el text és conegut (llegir una frase donada no diu res del
 * lèxic de qui parla).
 *
 * Cada variable que falta es substituïx pel seu valor de farciment, de
 * manera que no empeny cap a cap costat: la contribució d'una variable a
 * l'explicació és w·(x − farciment).
 */
import modelJson from './model.json' with { type: 'json' };

export type FeatureKey = 'norm_ae' | 'norm_o_u' | 'f1_ae' | 'f2_ea' | 'f1_a_rel' | 'd_per' | 'lex';
export type ModelName = 'with_lex' | 'no_lex';

export type LogisticModel = {
  keys: FeatureKey[]
  w: number[]
  b: number
  fill: Partial<Record<FeatureKey, number>>
};

export type ModelConstants = {
  EPS: number
  CLIP: number
  min_phones: number
  band: [number, number]
  min_ae_positions: number
  min_formant_tokens: number
  lpc: {
    resample_hz: number
    order: number
    frame_ms: number
    offsets_ms: number[]
    preemph: number
    f1_range: [number, number]
    max_bw: number
    t_shift_s: number
  }
};

type ModelFile = Record<ModelName, LogisticModel> & { constants: ModelConstants };

const MODEL_FILE = modelJson as unknown as ModelFile;

export const MODELS: Record<ModelName, LogisticModel> = { with_lex: MODEL_FILE.with_lex, no_lex: MODEL_FILE.no_lex };
export const CONSTANTS: ModelConstants = MODEL_FILE.constants;

/** Variables d'una persona (null = no s'ha pogut mesurar). */
export type Features = Record<FeatureKey, number | null>;

export type Score = {
  /** Probabilitat (0–1) que la pronunciació siga valenciana. */
  pValencia: number
  /** Contribució de cada variable al logit: w·(x − farciment). */
  contributions: Partial<Record<FeatureKey, number>>
};

/** Puntuació logística, igual que `score` de `classify.py`. */
export function scoreFeatures(features: Features, name: ModelName): Score {
  const model = MODELS[name];
  let z = model.b;
  const contributions: Partial<Record<FeatureKey, number>> = {};
  model.keys.forEach((key, i) => {
    const fill = model.fill[key] ?? 0;
    const value = features[key] ?? fill;
    contributions[key] = model.w[i] * (value - fill);
    z += model.w[i] * value;
  });
  return { pValencia: 1 / (1 + Math.exp(-z)), contributions };
}
