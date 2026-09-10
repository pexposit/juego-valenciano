/**
 * Smoke test del canal de veu en temps real (Camino A).
 * Envia un fitxer WAV pel WebSocket /api/voice i imprimeix els events rebuts.
 *
 *   node scripts/smoke-voice-ws.mjs [fitxer.wav] [escenari]
 *
 * Necessita el backend arrencat (per defecte ws://localhost:3001).
 */
import { readFileSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import WebSocket from 'ws';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const wavPath = process.argv[2] ?? path.join(__dirname, '..', '..', 'audio-bon-dia.wav');
const scenario = process.argv[3] ?? 'bar';
const wsUrl = process.env.SMOKE_WS_URL || 'ws://localhost:3001/api/voice';

/** Extreu el PCM del WAV, el passa a mono 16 bits i el remostreja a 16 kHz. */
function wavToPcm16k(buffer) {
  let offset = 12;
  let fmt = null;
  let dataOffset = -1;
  let dataSize = -1;
  while (offset + 8 <= buffer.length) {
    const id = buffer.toString('ascii', offset, offset + 4);
    const size = buffer.readUInt32LE(offset + 4);
    if (id === 'fmt ') {
      fmt = {
        audioFormat: buffer.readUInt16LE(offset + 8),
        channels: buffer.readUInt16LE(offset + 10),
        sampleRate: buffer.readUInt32LE(offset + 12),
        bitsPerSample: buffer.readUInt16LE(offset + 22),
      };
    }
    if (id === 'data') { dataOffset = offset + 8; dataSize = size; break; }
    offset += 8 + size + (size % 2);
  }
  if (!fmt || dataOffset < 0) throw new Error('WAV invalid');
  if (fmt.audioFormat !== 1 || ![16, 24, 32].includes(fmt.bitsPerSample)) {
    throw new Error(`WAV no PCM16/24/32: ${JSON.stringify(fmt)}`);
  }
  const bytes = fmt.bitsPerSample / 8;
  let raw = buffer.subarray(dataOffset, dataOffset + dataSize);
  if (fmt.channels > 1) {
    const frameBytes = bytes * fmt.channels;
    const samples = Math.floor(raw.length / frameBytes);
    const mono = Buffer.alloc(samples * bytes);
    for (let i = 0; i < samples; i += 1) raw.copy(mono, i * bytes, i * frameBytes, i * frameBytes + bytes);
    raw = mono;
  }
  // Converteix qualsevol profunditat a Int16 LE.
  const srcSamples = Math.floor(raw.length / bytes);
  const pcm = Buffer.alloc(srcSamples * 2);
  for (let i = 0; i < srcSamples; i += 1) {
    let value;
    if (fmt.bitsPerSample === 16) value = raw.readInt16LE(i * 2);
    else if (fmt.bitsPerSample === 24) {
      value = raw[i * 3] | (raw[i * 3 + 1] << 8) | (raw[i * 3 + 2] << 16);
      if (value & 0x800000) value -= 0x1000000;
      value >>= 8;
    } else value = Math.max(-32768, Math.min(32767, raw.readInt32LE(i * 4) >> 16));
    pcm.writeInt16LE(value, i * 2);
  }
  if (fmt.sampleRate === 16000) return pcm;
  const ratio = fmt.sampleRate / 16000;
  const outSamples = Math.floor(srcSamples / ratio);
  const out = Buffer.alloc(outSamples * 2);
  for (let i = 0; i < outSamples; i += 1) {
    const src = i * ratio;
    const i0 = Math.floor(src);
    const i1 = Math.min(i0 + 1, srcSamples - 1);
    const frac = src - i0;
    const s0 = pcm.readInt16LE(i0 * 2);
    const s1 = pcm.readInt16LE(i1 * 2);
    out.writeInt16LE(Math.round(s0 + (s1 - s0) * frac), i * 2);
  }
  return out;
}

const pcm = wavToPcm16k(readFileSync(wavPath));
const totalTurns = Number(process.env.SMOKE_TURNS || 1);
console.log(`Enviant ${(pcm.length / 2 / 16000).toFixed(1)}s de PCM 16 kHz (${pcm.length} bytes) → ${wsUrl} (${totalTurns} torn/s)`);

const ws = new WebSocket(wsUrl);
let audioFrames = 0;
let turns = 0;
const started = Date.now();

function sendUtterance() {
  turns += 1;
  console.log(`\n── Torn ${turns} ──`);
  ws.send(pcm);
}

ws.on('open', () => {
  ws.send(JSON.stringify({
    type: 'start',
    session_id: '00000000-0000-4000-8000-000000000000',
    scenario,
    level: 'principiant',
    history: [{ role: 'character', content_text: 'Bon dia! Com et puc ajudar hui?' }],
  }));
  sendUtterance();
});

ws.on('message', (data, isBinary) => {
  if (isBinary) {
    audioFrames += 1;
    console.log(`🔊 [+${((Date.now() - started) / 1000).toFixed(1)}s] audio #${audioFrames}: ${data.length} bytes`);
    return;
  }
  const msg = JSON.parse(data.toString('utf8'));
  if (msg.type === 'transcript') console.log(`📝 [+${((Date.now() - started) / 1000).toFixed(1)}s] transcript: ${msg.text}`);
  else if (msg.type === 'audio') console.log(`🗣️  [+${((Date.now() - started) / 1000).toFixed(1)}s] frase #${msg.index}: ${msg.text}`);
  else if (msg.type === 'done') {
    console.log(`✅ [+${((Date.now() - started) / 1000).toFixed(1)}s] done (mood=${msg.mood}, xp=${msg.xp_delta}): ${msg.reply_text}`);
    if (turns < totalTurns) sendUtterance();
    else { ws.close(); process.exit(0); }
  } else if (msg.type === 'error') {
    console.error(`❌ error del servidor: ${msg.error}`);
    process.exit(1);
  } else {
    console.log(`📨 ${JSON.stringify(msg).slice(0, 200)}`);
  }
});

ws.on('error', (error) => {
  console.error(`WS error: ${error.message}`);
  process.exit(1);
});

setTimeout(() => {
  console.error('⏱️ timeout de 120 s');
  process.exit(1);
}, 120000);