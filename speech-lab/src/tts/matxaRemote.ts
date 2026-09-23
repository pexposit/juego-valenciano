/**
 * TTS remot via l'endpoint OpenAI-compatible de matxa-tts (DeepLab UJI).
 *
 * És el mateix contracte que `MatxaTts` del backend: `POST
 * /v1/audio/speech` amb `{model, input, voice, response_format, language}`
 * i el WAV en el cos de la resposta. Viure darrere de `StreamingTts` permet
 * canviar a un TTS local (fase D) sense tocar ni el servidor ni la pàgina.
 */
import { config } from '../config.js';
import type { StreamingTts, TtsAudio, TtsOptions } from './types.js';

class MatxaRemoteTts implements StreamingTts {
  readonly id = 'matxa';

  async voices(): Promise<string[]> {
    return [...config.tts.voices];
  }

  async synthesize(text: string, options: TtsOptions = {}): Promise<TtsAudio> {
    const clean = text.trim();
    if (!clean) throw new Error('No puc sintetitzar un text buit');
    const voice = options.voice?.trim() || config.tts.defaultVoice;

    const started = Date.now();
    const response = await fetch(`${config.tts.baseUrl}/v1/audio/speech`, {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify({
        model: config.tts.model,
        input: clean,
        voice,
        response_format: 'wav',
        language: options.language ?? config.tts.language,
      }),
      signal: AbortSignal.timeout(config.tts.timeoutMs),
    });
    if (!response.ok) {
      throw new Error(`Matxa TTS ha respost ${response.status}`);
    }
    const audio = Buffer.from(await response.arrayBuffer());
    if (audio.length === 0) throw new Error('Matxa TTS ha retornat un àudio buit');
    return { audio, mimeType: 'audio/wav', voice, firstByteMs: Date.now() - started };
  }

  async dispose(): Promise<void> {
    // Sense procés fill: res a aturar.
  }
}

/** Crea el proveïdor remot de matxa-tts (client HTTP sense estat). */
export function createMatxaRemoteTts(): StreamingTts {
  return new MatxaRemoteTts();
}
