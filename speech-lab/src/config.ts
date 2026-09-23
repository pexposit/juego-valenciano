/**
 * Configuració del laboratori de veu en temps real.
 * Mateix patró que `backend/src/services/voice.ts`: variables d'entorn amb
 * valors per defecte raonables i cap secret (tot és local).
 */
import { existsSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

/** Arrel del laboratori: val igual executant `src/` amb tsx que `dist/`. */
export const labRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');

/** Resol una ruta relativa a l'arrel del laboratori; les absolutes es respecten. */
function resolveFromLab(value: string): string {
  return path.isAbsolute(value) ? value : path.join(labRoot, value);
}

function positiveNumber(value: string | undefined, fallback: number): number {
  const parsed = Number(value);
  return Number.isFinite(parsed) && parsed > 0 ? parsed : fallback;
}

export const config = {
  port: positiveNumber(process.env.SPEECH_LAB_PORT, 3100),
  provider: process.env.SPEECH_PROVIDER?.trim() || 'vosk',
  /** Proveïdor de transcripció per lots (`aina`: faster-whisper català). */
  batchProvider: process.env.BATCH_PROVIDER?.trim() || 'aina',
  /** Proveïdor de síntesi (`matxa`: TTS remot de la UJI, el mateix que el joc). */
  tts: {
    provider: process.env.TTS_PROVIDER?.trim() || 'matxa',
    baseUrl: (process.env.MATXA_TTS_URL?.trim() || 'http://deeplab.lsi.uji.es:11000').replace(/\/$/, ''),
    model: process.env.MATXA_TTS_MODEL?.trim() || 'matxa-tts',
    language: process.env.MATXA_TTS_LANGUAGE?.trim() || 'ca-es',
    defaultVoice: process.env.MATXA_TTS_VOICE?.trim() || 'gina',
    voices: (process.env.MATXA_TTS_VOICES?.trim() || 'gina,lluc').split(',').map((v) => v.trim()).filter(Boolean),
    timeoutMs: positiveNumber(process.env.MATXA_TTS_TIMEOUT_MS, 120_000),
  },
  /** Freqüència d'amostratge que espera el reconeixedor (els models Vosk són de 16 kHz). */
  sampleRate: positiveNumber(process.env.VOSK_SAMPLE_RATE, 16000),
  publicDir: path.join(labRoot, 'public'),
  vosk: {
    python: resolveFromLab(process.env.VOSK_PYTHON?.trim() || '.venv/bin/python'),
    modelPath: resolveFromLab(process.env.VOSK_MODEL_PATH?.trim() || 'models/vosk-model-small-ca-0.4'),
    script: path.join(labRoot, 'sidecar', 'vosk_stream.py'),
    host: '127.0.0.1',
    port: positiveNumber(process.env.VOSK_SIDECAR_PORT, 2700),
    startTimeoutMs: positiveNumber(process.env.VOSK_START_TIMEOUT_MS, 30_000),
  },
  /** Transcripció per lots amb faster-whisper (model català d'Aina, GPU si hi és). */
  batch: {
    python: resolveFromLab(process.env.AINA_PYTHON?.trim() || process.env.VOSK_PYTHON?.trim() || '.venv/bin/python'),
    modelPath: resolveFromLab(
      process.env.AINA_MODEL_PATH?.trim() || 'models/faster-whisper-large-v3-ca-3catparla',
    ),
    modelId: process.env.AINA_MODEL_ID?.trim() || 'projecte-aina/faster-whisper-large-v3-ca-3catparla',
    script: path.join(labRoot, 'sidecar', 'whisper_batch.py'),
    /** El model pesa GB: la primera càrrega pot tardar minuts en màquines lentes. */
    startTimeoutMs: positiveNumber(process.env.AINA_START_TIMEOUT_MS, 600_000),
  },
} as const;

/** Missatge d'ajuda comú quan falta la posada a punt del laboratori. */
export const SETUP_HINT =
  "Executa `npm run setup:speech` per a crear l'entorn de Python i descarregar el model català.";

/** Missatge d'ajuda quan falta el reconeixedor per lots (faster-whisper + Aina). */
export const SETUP_AINA_HINT =
  'Executa `bash speech-lab/scripts/setup-aina.sh` per a instal·lar faster-whisper i descarregar el model català d\u2019Aina.';

/** Comprova que hi ha intèrpret, model i sidecar abans d'intentar arrancar res. */
export function assertVoskSetup(): void {
  if (!existsSync(config.vosk.python)) {
    throw new Error(`No trobe l'intèrpret de Python de Vosk a ${config.vosk.python}. ${SETUP_HINT}`);
  }
  if (!existsSync(config.vosk.modelPath)) {
    throw new Error(`No trobe el model català a ${config.vosk.modelPath}. ${SETUP_HINT}`);
  }
  if (!existsSync(config.vosk.script)) {
    throw new Error(`No trobe el sidecar de Vosk a ${config.vosk.script}.`);
  }
}
