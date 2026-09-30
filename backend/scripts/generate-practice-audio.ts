/**
 * Genera els àudios estàtics de Comprensió oral (practice_passages amb media 'audio').
 * Cada torn de la transcripció se sintetitza amb el TTS i la veu de qui parla, i es
 * junten en un sol WAV (PCM de 16 bits) amb una pausa entre torns, a
 * frontend/public + audio_url.
 *
 *   npx tsx scripts/generate-practice-audio.ts           # només els que falten
 *   npx tsx scripts/generate-practice-audio.ts --force   # tots
 *
 * El TTS no suporta bé peticions simultànies: els torns es demanen d'un en un.
 */
import 'dotenv/config';
import { existsSync, mkdirSync, writeFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { getAdmin } from '../src/middleware/auth.js';
import { tts } from '../src/services/voice.js';

const PUBLIC_DIR = resolve(dirname(fileURLToPath(import.meta.url)), '../../frontend/public');
const PAUSE_SECONDS = 0.7;
const force = process.argv.includes('--force');

type Pcm = { sampleRate: number; channels: number; samples: Int16Array };

// Llig un WAV PCM (16 o 24 bits) i el torna com a mostres de 16 bits.
function readWav(buffer: Buffer): Pcm {
  if (buffer.toString('ascii', 0, 4) !== 'RIFF' || buffer.toString('ascii', 8, 12) !== 'WAVE') throw new Error('No és un WAV');
  let offset = 12;
  let format: { channels: number; sampleRate: number; bits: number } | undefined;
  while (offset + 8 <= buffer.length) {
    const id = buffer.toString('ascii', offset, offset + 4);
    const size = buffer.readUInt32LE(offset + 4);
    const body = offset + 8;
    if (id === 'fmt ') {
      format = { channels: buffer.readUInt16LE(body + 2), sampleRate: buffer.readUInt32LE(body + 4), bits: buffer.readUInt16LE(body + 14) };
    } else if (id === 'data' && format) {
      const bytes = format.bits / 8;
      const end = Math.min(body + size, buffer.length);
      const samples = new Int16Array(Math.floor((end - body) / bytes));
      for (let i = 0; i < samples.length; i++) {
        const at = body + i * bytes;
        samples[i] = bytes === 3 ? buffer.readIntLE(at, 3) >> 8 : buffer.readInt16LE(at);
      }
      return { sampleRate: format.sampleRate, channels: format.channels, samples };
    }
    offset = body + size + (size % 2);
  }
  throw new Error('WAV sense dades PCM');
}

function writeWav({ sampleRate, channels, samples }: Pcm): Buffer {
  const data = Buffer.alloc(samples.length * 2);
  samples.forEach((s, i) => data.writeInt16LE(s, i * 2));
  const header = Buffer.alloc(44);
  header.write('RIFF', 0, 'ascii');
  header.writeUInt32LE(36 + data.length, 4);
  header.write('WAVEfmt ', 8, 'ascii');
  header.writeUInt32LE(16, 16);
  header.writeUInt16LE(1, 20);
  header.writeUInt16LE(channels, 22);
  header.writeUInt32LE(sampleRate, 24);
  header.writeUInt32LE(sampleRate * channels * 2, 28);
  header.writeUInt16LE(channels * 2, 32);
  header.writeUInt16LE(16, 34);
  header.write('data', 36, 'ascii');
  header.writeUInt32LE(data.length, 40);
  return Buffer.concat([header, data]);
}

async function main() {
  const client = getAdmin() as any;
  if (!client) throw new Error('Cal SUPABASE_URL i SUPABASE_SERVICE_ROLE_KEY a backend/.env');
  const { data, error } = await client
    .from('practice_passages')
    .select('audio_url, title, lines')
    .eq('media', 'audio')
    .not('audio_url', 'is', null);
  if (error) throw error;

  for (const passage of data as { audio_url: string; title: string | null; lines: { text: string; voice?: string }[] }[]) {
    const file = resolve(PUBLIC_DIR, `.${passage.audio_url}`);
    if (existsSync(file) && !force) {
      console.log(`= ${passage.audio_url} (ja existix)`);
      continue;
    }
    const turns: Pcm[] = [];
    for (const line of passage.lines) {
      const audio = await tts.synthesize(line.text, line.voice);
      if (!audio) throw new Error(`El TTS no ha pogut generar «${line.text.slice(0, 40)}…»`);
      turns.push(readWav(audio.audio));
    }
    const { sampleRate, channels } = turns[0];
    if (turns.some(t => t.sampleRate !== sampleRate || t.channels !== channels)) throw new Error('Els torns tenen formats diferents');
    const pause = new Int16Array(Math.round(sampleRate * PAUSE_SECONDS) * channels);
    const parts = turns.flatMap((t, i) => (i === 0 ? [t.samples] : [pause, t.samples]));
    const samples = new Int16Array(parts.reduce((n, p) => n + p.length, 0));
    parts.reduce((at, p) => (samples.set(p, at), at + p.length), 0);

    mkdirSync(dirname(file), { recursive: true });
    writeFileSync(file, writeWav({ sampleRate, channels, samples }));
    console.log(`+ ${passage.audio_url} (${passage.lines.length} torns, ${(samples.length / channels / sampleRate).toFixed(1)} s)`);
  }
}

main().catch(error => {
  console.error(error);
  process.exit(1);
});
