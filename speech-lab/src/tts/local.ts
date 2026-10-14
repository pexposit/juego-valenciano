/**
 * Generació local per a l'apartat «Generació d'àudio» del laboratori: catàleg
 * de models i síntesi amb el que hi haja en disc.
 *
 *  - `remot:<veu>`      matxa-tts de la UJI (el mateix que el joc).
 *  - `matxa:base:<spk>` checkpoint base de Matxa multiaccent en local.
 *  - `matxa:<run>:<spk>` fine-tunes de tts/runs/<run>/ (scripts/finetune-matxa.py).
 *  - `rvc:<nom>`        Matxa base (gina, o el locutor «base» de
 *                       scripts/rvc-personatges.json) + conversió RVC del
 *                       personatge (scripts/entrena-rvc.sh), com scripts/parla.sh.
 *
 * El catàleg es llig del disc a cada petició: un entrenament nou apareix sense
 * reiniciar el laboratori.
 */
import { existsSync, readdirSync, readFileSync } from 'node:fs';
import { mkdtemp, readFile, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import path from 'node:path';
import { config } from '../config.js';
import { NdjsonSidecar } from './ndjsonSidecar.js';
import { getStreamingTts } from './registry.js';

/** Locutors del model multiaccent (LaFrescat), en l'ordre dels seus id. */
const BASE_SPEAKERS = ['quim', 'olga', 'grau', 'elia', 'pere', 'emma', 'lluc', 'gina'];
const BASE_ACCENTS = ['balear', 'balear', 'central', 'central', 'nord-occidental', 'nord-occidental', 'valencià', 'valencià'];
const GINA = 7;

/** Petició mal formada (model o checkpoint fora del catàleg): és un 400, no un error del motor. */
export class TtsRequestError extends Error {}

export type TtsModel = {
  id: string
  label: string
  group: string
  /** Checkpoints triables (fine-tunes i RVC) i el que es fa servir si no se'n tria cap. */
  checkpoints?: string[]
  defaultCheckpoint?: string
  /** Semitons que es mou la veu de partida abans de la conversió (només RVC). */
  pitch?: number
  /** Locutor de Matxa base que es converteix (només RVC). */
  baseSpeaker?: number
  /** Pes per defecte del fitxer .index (només RVC). */
  indexRate?: number
};

export type LocalTtsRequest = {
  text: string
  model: string
  checkpoint?: string
  temperature?: number
  speed?: number
  pitch?: number
  indexRate?: number
};

export type LocalTtsResult = {
  audio: Buffer
  model: string
  checkpoint?: string
  matxaMs: number
  rvcMs?: number
  audioSecs: number
  /** El model ja era en memòria (sense temps de càrrega). */
  cached: boolean
};

const SETUP_MATXA = 'Executa `bash speech-lab/scripts/setup-matxa.sh`.';
const SETUP_RVC = 'Executa `bash speech-lab/scripts/setup-rvc.sh` i entrena un personatge amb `scripts/entrena-rvc.sh`.';

const matxa = new NdjsonSidecar<
  { ckpt: string, spk: number, text: string, out: string, temperatura?: number, velocitat?: number },
  { compute_ms: number, audio_secs: number, cached: boolean }
>({
  name: 'matxa',
  python: config.localTts.matxaPython,
  script: config.localTts.matxaScript,
  startTimeoutMs: config.localTts.startTimeoutMs,
  setupHint: SETUP_MATXA,
});

const rvc = new NdjsonSidecar<
  { input: string, output: string, pth: string, index: string, pitch: number, index_rate: number },
  { compute_ms: number }
>({
  name: 'rvc',
  python: config.localTts.rvcPython,
  script: config.localTts.rvcScript,
  cwd: config.localTts.applioDir,
  startTimeoutMs: config.localTts.startTimeoutMs,
  setupHint: SETUP_RVC,
});

const readJson = <T>(file: string): T | null => {
  try {
    return JSON.parse(readFileSync(file, 'utf8')) as T;
  } catch {
    return null;
  }
};

const listDir = (dir: string): string[] => {
  try {
    return readdirSync(dir);
  } catch {
    return [];
  }
};

/** «epoch=0049.ckpt» abans que «epoch=0399.ckpt», i «last.ckpt» al final. */
const byEpoch = (a: string, b: string) => a.localeCompare(b, 'ca', { numeric: true });

type RunManifest = { veus?: Record<string, string>, recomanat?: string };

function runSpeakers(runDir: string, manifest: RunManifest | null): Map<number, string> {
  const speakers = new Map<number, string>();
  for (const [spk, name] of Object.entries(manifest?.veus ?? {})) speakers.set(Number(spk), name);
  if (speakers.size) return speakers;
  // Sense veus.json: els locutors de les mostres que guarda el fine-tune.
  for (const sample of listDir(path.join(runDir, 'mostres'))
    .flatMap((dir) => listDir(path.join(runDir, 'mostres', dir)))) {
    const match = /_spk(\d+)\.wav$/.exec(sample);
    if (match) speakers.set(Number(match[1]), BASE_SPEAKERS[Number(match[1])] ?? `spk${match[1]}`);
  }
  return speakers;
}

function rvcWeights(name: string): string[] {
  return listDir(path.join(config.localTts.applioDir, 'logs', name))
    .filter((file) => new RegExp(`^${name}_\\d+e_\\d+s\\.pth$`).test(file))
    .sort(byEpoch);
}

export function localTtsModels(): TtsModel[] {
  const models: TtsModel[] = config.tts.voices.map((voice) => ({
    id: `remot:${voice}`, label: `${voice} (servidor UJI)`, group: 'Remot · matxa-tts UJI',
  }));

  if (existsSync(config.localTts.baseCheckpoint)) {
    BASE_SPEAKERS.forEach((name, spk) => models.push({
      id: `matxa:base:${spk}`, label: `${name} (${BASE_ACCENTS[spk]})`, group: 'Matxa local · model base',
    }));
  }

  for (const run of listDir(config.localTts.runsDir).sort()) {
    const runDir = path.join(config.localTts.runsDir, run);
    const checkpoints = listDir(path.join(runDir, 'checkpoints')).filter((f) => f.endsWith('.ckpt')).sort(byEpoch);
    if (!checkpoints.length) continue;
    const manifest = readJson<RunManifest>(path.join(runDir, 'veus.json'));
    const fallback = checkpoints.includes('last.ckpt') ? 'last.ckpt' : checkpoints.at(-1)!;
    const defaultCheckpoint = manifest?.recomanat && checkpoints.includes(manifest.recomanat)
      ? manifest.recomanat : fallback;
    for (const [spk, name] of runSpeakers(runDir, manifest)) {
      models.push({
        id: `matxa:${run}:${spk}`, label: `${name} (${run})`, group: 'Fine-tune Matxa',
        checkpoints, defaultCheckpoint,
      });
    }
  }

  const characters = readJson<Record<string, { base?: number, to?: number, index?: number }>>(config.localTts.rvcCharacters) ?? {};
  if (existsSync(config.localTts.baseCheckpoint)) {
    for (const name of listDir(path.join(config.localTts.applioDir, 'logs')).sort()) {
      const weights = rvcWeights(name);
      if (!weights.length) continue;
      const baseSpeaker = characters[name]?.base ?? GINA;
      models.push({
        id: `rvc:${name}`,
        label: `${name[0]!.toUpperCase()}${name.slice(1)} (${BASE_SPEAKERS[baseSpeaker] ?? `spk${baseSpeaker}`} + RVC)`,
        group: 'Matxa + RVC (personatges)', checkpoints: weights, defaultCheckpoint: weights.at(-1),
        pitch: characters[name]?.to ?? 0, baseSpeaker, indexRate: characters[name]?.index ?? 0.6,
      });
    }
  }
  return models;
}

/** Només noms de fitxer del catàleg: la petició no pot apuntar fora dels directoris de models. */
function pickCheckpoint(model: TtsModel, requested?: string): string | undefined {
  if (!model.checkpoints) return undefined;
  if (requested && !model.checkpoints.includes(requested)) {
    throw new TtsRequestError(`Checkpoint desconegut per a ${model.id}: ${requested}`);
  }
  return requested || model.defaultCheckpoint;
}

export async function synthesizeLocal(request: LocalTtsRequest): Promise<LocalTtsResult> {
  const model = localTtsModels().find((m) => m.id === request.model);
  if (!model) throw new TtsRequestError(`Model desconegut: ${request.model}`);
  const [kind, name, spk] = model.id.split(':') as [string, string, string | undefined];
  const checkpoint = pickCheckpoint(model, request.checkpoint);

  if (kind === 'remot') {
    const started = Date.now();
    const result = await getStreamingTts('matxa').synthesize(request.text, { voice: name });
    return {
      audio: result.audio, model: model.id, matxaMs: Date.now() - started,
      audioSecs: wavSeconds(result.audio), cached: true,
    };
  }

  const dir = await mkdtemp(path.join(tmpdir(), 'speech-lab-tts-'));
  try {
    const matxaWav = path.join(dir, 'matxa.wav');
    const ckpt = kind === 'matxa' && name !== 'base'
      ? path.join(config.localTts.runsDir, name, 'checkpoints', checkpoint!)
      : config.localTts.baseCheckpoint;
    const synth = await matxa.request({
      ckpt, spk: kind === 'rvc' ? model.baseSpeaker ?? GINA : Number(spk), text: request.text, out: matxaWav,
      temperatura: request.temperature, velocitat: request.speed,
    });
    if (kind !== 'rvc') {
      return {
        audio: await readFile(matxaWav), model: model.id, checkpoint, matxaMs: synth.compute_ms,
        audioSecs: synth.audio_secs, cached: synth.cached,
      };
    }

    const logs = path.join(config.localTts.applioDir, 'logs', name);
    const index = listDir(logs).find((file) => file.endsWith('.index'));
    const rvcWav = path.join(dir, 'rvc.wav');
    const converted = await rvc.request({
      input: matxaWav, output: rvcWav, pth: path.join(logs, checkpoint!),
      index: index ? path.join(logs, index) : '',
      pitch: request.pitch ?? model.pitch ?? 0, index_rate: request.indexRate ?? model.indexRate ?? 0.6,
    });
    return {
      audio: await readFile(rvcWav), model: model.id, checkpoint, matxaMs: synth.compute_ms,
      rvcMs: converted.compute_ms, audioSecs: synth.audio_secs, cached: synth.cached,
    };
  } finally {
    await rm(dir, { recursive: true, force: true });
  }
}

/** Durada d'un WAV PCM a partir de la capçalera (byte rate i mida del bloc data). */
function wavSeconds(wav: Buffer): number {
  if (wav.length < 44 || wav.toString('ascii', 0, 4) !== 'RIFF') return 0;
  const byteRate = wav.readUInt32LE(28);
  let offset = 12;
  while (offset + 8 <= wav.length) {
    const id = wav.toString('ascii', offset, offset + 4);
    const size = wav.readUInt32LE(offset + 4);
    if (id === 'data') return byteRate ? Number((Math.min(size, wav.length - offset - 8) / byteRate).toFixed(2)) : 0;
    offset += 8 + size + (size % 2);
  }
  return 0;
}

export async function disposeLocalTts(): Promise<void> {
  await Promise.all([matxa.dispose(), rvc.dispose()]);
}
