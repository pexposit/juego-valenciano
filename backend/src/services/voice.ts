/** Voice providers live behind this interface so vendors can change without routes changing. */
export interface SpeechToText {
  transcribe(audio: Buffer, mimeType?: string): Promise<string>
}

export type SpeechAudio = { audio: Buffer; mimeType: string };

export interface TextToSpeech {
  synthesize(text: string, voice?: string): Promise<SpeechAudio | null>
}

export class UnconfiguredStt implements SpeechToText {
  async transcribe(_audio: Buffer, _mimeType?: string): Promise<string> {
    throw new Error('El proveïdor STT no està configurat');
  }
}

/**
 * Speech-to-text via an OpenAI-compatible /v1/audio/transcriptions endpoint.
 * El servidor DeepLab de la UJI executa el model matxa (whisper-1) i retorna el JSON { text }.
 * Exemple: curl -X POST http://deeplab.lsi.uji.es:11000/v1/audio/transcriptions \
 *   -F model=whisper-1 -F language=ca -F file=audio.wav
 */
export class MatxaStt implements SpeechToText {
  private readonly baseUrl = (process.env.MATXA_STT_URL
    || process.env.MATXA_TTS_URL
    || 'http://deeplab.lsi.uji.es:11000').replace(/\/$/, '');
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
    || 'http://deeplab.lsi.uji.es:11000').replace(/\/$/, '');
  private readonly model = process.env.MATXA_TTS_MODEL || 'matxa-tts';
  private readonly voice = process.env.MATXA_TTS_VOICE || 'gina';

  async synthesize(text: string, voice?: string): Promise<SpeechAudio | null> {
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

export const stt: SpeechToText = new MatxaStt();
export const tts: TextToSpeech = new MatxaTts();
