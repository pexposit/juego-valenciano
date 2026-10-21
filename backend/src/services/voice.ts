import { gnvRagUsesGpu } from './gnvRag.js';

/** Voice providers live behind this interface so vendors can change without routes changing. */
export interface SpeechToText {
  transcribe(audio: Buffer, mimeType?: string): Promise<string>
}

export type SpeechAudio = { audio: Buffer; mimeType: string };

export interface TextToSpeech {
  // `fallback: false` (scripts que generen àudios estàtics): si la veu demanada no està disponible, no se'n posa una altra.
  synthesize(text: string, voice?: string, options?: { fallback?: boolean }): Promise<SpeechAudio | null>
}

export class UnconfiguredStt implements SpeechToText {
  async transcribe(_audio: Buffer, _mimeType?: string): Promise<string> {
    throw new Error('El proveïdor STT no està configurat');
  }
}

/**
 * Speech-to-text via an OpenAI-compatible /v1/audio/transcriptions endpoint.
 * El servidor DeepLab de la UJI executa el model matxa (whisper-1) i retorna el JSON { text }.
 * Exemple: curl -X POST https://krono.act.uji.es/deeplab/speechv1/audio/transcriptions \
 *   -F model=whisper-1 -F language=ca -F file=audio.wav
 */
export class MatxaStt implements SpeechToText {
  private readonly baseUrl = (process.env.MATXA_STT_URL
    || process.env.MATXA_TTS_URL
    || 'https://krono.act.uji.es/deeplab/speech').replace(/\/$/, '');
  private readonly model = process.env.MATXA_STT_MODEL || 'whisper-1';
  private readonly language = process.env.MATXA_STT_LANGUAGE || 'ca';

  async transcribe(audio: Buffer, mimeType = 'audio/webm'): Promise<string> {
    const form = new FormData();
    form.append('model', this.model);
    form.append('language', this.language);
    form.append(
      'file',
      new Blob([new Uint8Array(audio)], { type: mimeType }),
      filenameFromMimeType(mimeType),
    );

    const response = await fetch(`${this.baseUrl}/v1/audio/transcriptions`, {
      method: 'POST',
      body: form,
      signal: AbortSignal.timeout(120_000),
    });
    if (!response.ok) throw new Error(`Matxa STT ha respost ${response.status}`);

    const body = await response.json() as { text?: string };
    const text = body.text?.trim();
    if (!text) throw new Error('Matxa STT no ha retornat text');
    return text;
  }
}

/** Deriva un nom de fitxer adequat a partir del MIME type enviat pel navegador. */
function filenameFromMimeType(mimeType: string): string {
  const extensionByMime: Record<string, string> = {
    'audio/webm': 'webm',
    'audio/wav': 'wav',
    'audio/x-wav': 'wav',
    'audio/wave': 'wav',
    'audio/mpeg': 'mp3',
    'audio/mp3': 'mp3',
    'audio/ogg': 'ogg',
    'audio/opus': 'ogg',
    'audio/mp4': 'm4a',
    'audio/x-m4a': 'm4a',
  };
  return `audio.${extensionByMime[mimeType.toLowerCase()] || 'webm'}`;
}

/**
 * Catalan TTS via an OpenAI-compatible /v1/audio/speech endpoint.
 * El servidor DeepLab de la UJI executa el model matxa-tts i retorna el WAV directament.
 */
export class MatxaTts implements TextToSpeech {
  private readonly baseUrl = (process.env.MATXA_TTS_URL
    || 'https://krono.act.uji.es/deeplab/speech').replace(/\/$/, '');
  private readonly model = process.env.MATXA_TTS_MODEL || 'matxa-tts';
  private readonly voice = process.env.MATXA_TTS_VOICE || 'gina';

  async synthesize(text: string, voice?: string, _options?: { fallback?: boolean }): Promise<SpeechAudio | null> {
    try {
      const response = await fetch(`${this.baseUrl}/v1/audio/speech`, {
        method: 'POST',
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify({
          model: this.model,
          input: text,
          voice: voice ?? this.voice,
          response_format: 'wav',
          language: 'ca-es',
        }),
        signal: AbortSignal.timeout(60_000),
      });
      if (!response.ok) throw new Error(`Matxa TTS ha respost ${response.status}`);

      const speechAudio = Buffer.from(await response.arrayBuffer());
      if (speechAudio.length === 0) throw new Error('Matxa TTS ha retornat un àudio buit');

      const responseMimeType = response.headers.get('content-type')?.split(';')[0];
      return {
        audio: speechAudio,
        mimeType: responseMimeType && responseMimeType !== 'application/octet-stream'
          ? responseMimeType
          : 'audio/wav',
      };
    } catch (error) {
      // TTS must not prevent the learner from receiving the text response.
      console.warn('Matxa TTS no disponible:', error instanceof Error ? error.message : error);
      return null;
    }
  }
}

/**
 * Router de veus. Amb SPEECH_LAB_URL (p. ex. http://localhost:3100) TOTES les veus les genera el laboratori de veu
 * (speech-lab, Matxa + RVC, necessita GPU) i no s'usa el DeepLab de la UJI ni de reserva: si el laboratori no respon,
 * no hi ha àudio. `gina` i `lluc` són els locutors valencians del Matxa local; les veus de personatge (`rvc:doraemon`,
 * `rvc:heidi`...) i qualsevol altre model del laboratori (`veu:nena`...) es passen tal qual.
 * Sense SPEECH_LAB_URL tot va al DeepLab com sempre, i una veu `rvc:*` cau a la veu per defecte.
 * `remot:<veu>` (p. ex. `remot:gina`, triada en el menú del robot) va sempre al DeepLab, amb laboratori o sense.
 * Mentre el RAG de la GNV ocupa la GPU té prioritat: el laboratori no es fa servir i tot va com si no hi haguera.
 */
const LAB_MODEL_BY_VOICE: Record<string, string> = { gina: 'matxa:base:7', lluc: 'matxa:base:6' };

export class RoutedTts implements TextToSpeech {
  constructor(private readonly base: TextToSpeech) {}

  async synthesize(text: string, voice?: string, options: { fallback?: boolean } = {}): Promise<SpeechAudio | null> {
    if (voice?.startsWith('remot:')) return this.base.synthesize(text, voice.slice('remot:'.length), options);
    const labUrl = speechLabUrl();
    if (labUrl && !(await gnvRagUsesGpu())) return this.fromLab(labUrl, text, labModelFor(voice));

    if (!voice?.startsWith('rvc:')) return this.base.synthesize(text, voice, options);
    if (options.fallback === false) return null;
    return this.base.synthesize(text, undefined, options);
  }

  private async fromLab(labUrl: string, text: string, model: string): Promise<SpeechAudio | null> {
    try {
      const response = await fetch(`${labUrl}/api/tts`, {
        method: 'POST',
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify({ text, model }),
        // La primera frase carrega els models a la GPU (~30 s).
        signal: AbortSignal.timeout(120_000),
      });
      if (!response.ok) throw new Error(`El laboratori de veu ha respost ${response.status}`);
      const audio = Buffer.from(await response.arrayBuffer());
      if (audio.length === 0) throw new Error("El laboratori de veu ha retornat un àudio buit");
      return { audio, mimeType: response.headers.get('content-type')?.split(';')[0] || 'audio/wav' };
    } catch (error) {
      console.warn(`Laboratori de veu no disponible (${model}):`, error instanceof Error ? error.message : error);
      return null;
    }
  }
}

const speechLabUrl = () => process.env.SPEECH_LAB_URL?.replace(/\/$/, '');

// `busy`: la veu necessita la GPU i ara l'ocupa el RAG; el menú la mostra desactivada amb este avís.
export type VoiceOption = { id: string; label: string; group: string; busy?: string };
const GPU_BUSY_MESSAGE = 'La GPU està ocupada amb el RAG';

// Del Matxa del servidor de la UJI només es poden triar els locutors valencians.
const SERVER_VOICES = ['gina', 'lluc'];
const capitalized = (name: string) => `${name[0]!.toUpperCase()}${name.slice(1)}`;
// Nom que veu l'aprenent dels personatges RVC que no es diuen com el seu model.
const RVC_LABELS: Record<string, string> = { parlant04: 'Miquel' };

/**
 * Veus que l'aprenent pot triar per al robot: gina i lluc del servidor de la UJI i, si hi ha laboratori de veu, els
 * personatges RVC que hi ha entrenats (Doraemon, Nobita, Heidi...). El catàleg es llig del laboratori, així un
 * entrenament nou ix sol. Mentre el RAG ocupa la GPU, els personatges ixen marcats com a ocupats.
 */
export async function voiceOptions(): Promise<VoiceOption[]> {
  const options: VoiceOption[] = SERVER_VOICES.map(voice => ({ id: `remot:${voice}`, label: capitalized(voice), group: 'Veus del servidor' }));
  const labUrl = speechLabUrl();
  if (!labUrl) return options;
  try {
    const response = await fetch(`${labUrl}/api/tts/models`, { signal: AbortSignal.timeout(3_000) });
    if (!response.ok) throw new Error(`El laboratori de veu ha respost ${response.status}`);
    const { models = [] } = await response.json() as { models?: { id: string }[] };
    const busy = (await gnvRagUsesGpu()) ? GPU_BUSY_MESSAGE : undefined;
    for (const { id } of models) {
      if (!id.startsWith('rvc:')) continue;
      const name = id.slice('rvc:'.length);
      options.push({ id, label: RVC_LABELS[name] ?? capitalized(name), group: 'Personatges', busy });
    }
  } catch (error) {
    console.warn('Catàleg del laboratori de veu no disponible:', error instanceof Error ? error.message : error);
  }
  return options;
}

/** El model del laboratori d'una veu del projecte: gina i lluc són locutors del Matxa local; un id amb «:» ja és d'un model. */
function labModelFor(voice?: string): string {
  if (voice?.includes(':')) return voice;
  return LAB_MODEL_BY_VOICE[voice ?? ''] ?? LAB_MODEL_BY_VOICE[process.env.MATXA_TTS_VOICE || 'gina'] ?? LAB_MODEL_BY_VOICE.gina;
}

export const stt: SpeechToText = new MatxaStt();
export const tts: TextToSpeech = new RoutedTts(new MatxaTts());
