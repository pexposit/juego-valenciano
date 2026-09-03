/** Voice providers live behind this interface so vendors can change without routes changing. */
export interface SpeechToText {
  transcribe(audio: Buffer, mimeType?: string): Promise<string>
}

export type SpeechAudio = { audio: Buffer; mimeType: string };

export interface TextToSpeech {
  synthesize(text: string): Promise<SpeechAudio | null>
}

export class UnconfiguredStt implements SpeechToText {
  async transcribe(_audio: Buffer, _mimeType?: string): Promise<string> {
    throw new Error('El proveïdor STT no està configurat');
  }
}

/**
 * Speech-to-text using the Hugging Face Inference API.
 * The default model is BSC-LT's Spanish/Catalan code-switching Whisper model.
 */
export class HuggingFaceWhisperStt implements SpeechToText {
  private readonly model = process.env.HF_STT_MODEL || 'BSC-LT/whisper-timestamped-cs';
  private readonly endpoint = (process.env.HF_STT_ENDPOINT
    || 'https://bsc-lt-asr-inference.hf.space').replace(/\/$/, '');

  async transcribe(audio: Buffer, mimeType = 'audio/webm'): Promise<string> {
    const token = process.env.HF_TOKEN || process.env.HUGGINGFACE_TOKEN;
    if (!token) throw new Error('Falta HF_TOKEN per al transcriptor de veu');

    const form = new FormData();
    form.append('files', new Blob([new Uint8Array(audio)], { type: mimeType }), 'input.webm');
    const upload = await fetch(`${this.endpoint}/gradio_api/upload`, {
      method: 'POST', headers: { authorization: `Bearer ${token}` }, body: form,
      signal: AbortSignal.timeout(120_000),
    });
    if (!upload.ok) throw new Error(`Hugging Face ASR no ha pogut pujar l'àudio (${upload.status})`);
    const [path] = await upload.json() as string[];
    const response = await fetch(`${this.endpoint}/gradio_api/call/predict`, {
      method: 'POST',
      headers: { authorization: `Bearer ${token}`, 'content-type': 'application/json' },
      body: JSON.stringify({ data: [{ path, orig_name: 'input.webm' }] }),
      signal: AbortSignal.timeout(120_000),
    });
    const { event_id: eventId } = await response.json() as { event_id?: string };
    if (!response.ok || !eventId) throw new Error(`Hugging Face ASR ha respost ${response.status}`);
    const resultResponse = await fetch(`${this.endpoint}/gradio_api/call/predict/${eventId}`, {
      headers: { authorization: `Bearer ${token}`, accept: 'text/event-stream' },
      signal: AbortSignal.timeout(120_000),
    });
    const stream = await resultResponse.text();
    const complete = stream.match(/event: complete\s*\ndata: (.+)/);
    if (!complete) throw new Error('Hugging Face ASR no ha finalitzat la transcripció');
    const output = JSON.parse(complete[1]) as [string];
    const text = output[0];
    if (!text?.trim()) throw new Error('Hugging Face STT no ha retornat text');
    return text.trim();
  }
}

type GradioFile = { path?: string; url?: string | null };

/**
 * Catalan TTS served by Projecte Aina's Matxa + alVoCat Gradio Space.
 * The Space queues generations and returns an SSE stream containing the output file.
 */
export class MatxaAlvocatTts implements TextToSpeech {
  private readonly baseUrl = (process.env.MATXA_ALVOCAT_TTS_URL
    || 'https://projecte-aina-matxa-alvocat-tts-ca.hf.space').replace(/\/$/, '');

  async synthesize(text: string): Promise<SpeechAudio | null> {
    try {
      return await this.generate(text, 'valencia', 'gina');
    } catch (valenciaError) {
      // The public Space sometimes advertises Valencian voices that its running
      // replica cannot serve. Its default Balearic voice is a reliable fallback.
      console.warn('Veu valenciana de Matxa Alvocat no disponible; s’usa la veu alternativa:', valenciaError instanceof Error ? valenciaError.message : valenciaError);
      try {
        return await this.generate(text, 'balear', 'quim');
      } catch (error) {
        // TTS must not prevent the learner from receiving the text response.
        console.warn('Matxa Alvocat TTS no disponible:', error instanceof Error ? error.message : error);
        return null;
      }
    }
  }

  private async generate(text: string, accent: string, speaker: string): Promise<SpeechAudio> {
    const start = await fetch(`${this.baseUrl}/gradio_api/call/predict`, {
        method: 'POST',
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify({
          data: [text, accent, speaker, 0.2, 0.89],
        }),
        signal: AbortSignal.timeout(30_000),
      });
    if (!start.ok) throw new Error(`Matxa Alvocat ha respost ${start.status}`);

    const { event_id: eventId } = await start.json() as { event_id?: string };
    if (!eventId) throw new Error('Matxa Alvocat no ha retornat cap identificador de feina');

    const result = await fetch(`${this.baseUrl}/gradio_api/call/predict/${eventId}`, {
      headers: { accept: 'text/event-stream' },
      signal: AbortSignal.timeout(90_000),
    });
    if (!result.ok) throw new Error(`No s'ha pogut recollir l'àudio (${result.status})`);

    const audioFile = extractGradioAudio(await result.text(), this.baseUrl);
    if (!audioFile) throw new Error('Matxa Alvocat no ha generat cap fitxer d’àudio');

    const audioResponse = await fetch(audioFile, { signal: AbortSignal.timeout(30_000) });
    if (!audioResponse.ok) throw new Error(`No s'ha pogut descarregar l'àudio (${audioResponse.status})`);

    const audio = Buffer.from(await audioResponse.arrayBuffer());
    const responseMimeType = audioResponse.headers.get('content-type')?.split(';')[0];
    return {
      audio,
      // Gradio serves the generated WAV as application/octet-stream. Infer its
      // actual media type so browsers can decode the base64 response.
      mimeType: responseMimeType && responseMimeType !== 'application/octet-stream'
        ? responseMimeType
        : isWav(audio) ? 'audio/wav' : 'audio/mpeg',
    };
  }
}

function isWav(audio: Buffer): boolean {
  return audio.subarray(0, 4).toString('ascii') === 'RIFF'
    && audio.subarray(8, 12).toString('ascii') === 'WAVE';
}

function extractGradioAudio(stream: string, baseUrl: string): string | null {
  const complete = stream.match(/event: complete\s*\ndata: (.+)/);
  if (!complete) return null;

  const files = JSON.parse(complete[1]) as GradioFile[];
  const file = files[0];
  if (!file) return null;
  if (file.url) return file.url;
  return file.path ? new URL(file.path, baseUrl).toString() : null;
}

export const stt: SpeechToText = new HuggingFaceWhisperStt();
export const tts: TextToSpeech = new MatxaAlvocatTts();
