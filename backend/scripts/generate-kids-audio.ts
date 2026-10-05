/**
 * Genera els àudios estàtics del Nivell 0 infantil (frontend/src/features/kids/content.ts):
 * una frase de KIDS_AUDIO per fitxer, amb el TTS (matxa, servidor DeepLab de la UJI),
 * a frontend/public/audio/kids/<clau>.wav. Els xiquets no llegixen: tot s'escolta.
 *
 *   npx tsx scripts/generate-kids-audio.ts           # només els que falten
 *   npx tsx scripts/generate-kids-audio.ts --force   # tots
 *
 * El TTS no suporta bé peticions simultànies: les frases es demanen d'una en una.
 */
import 'dotenv/config';
import { existsSync, mkdirSync, writeFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { tts } from '../src/services/voice.js';
import { KIDS_AUDIO } from '../../frontend/src/features/kids/content.js';

const OUT_DIR = resolve(dirname(fileURLToPath(import.meta.url)), '../../frontend/public/audio/kids');
const VOICE = 'gina';
const force = process.argv.includes('--force');

async function main() {
  mkdirSync(OUT_DIR, { recursive: true });
  const entries = Object.entries(KIDS_AUDIO);
  let made = 0;
  for (const [key, text] of entries) {
    const file = resolve(OUT_DIR, `${key}.wav`);
    if (existsSync(file) && !force) continue;
    const audio = await tts.synthesize(text, VOICE);
    if (!audio) throw new Error(`El TTS no ha pogut generar «${text}»`);
    writeFileSync(file, audio.audio);
    made++;
    console.log(`+ ${key}.wav  «${text}»`);
  }
  console.log(`${made} àudios nous, ${entries.length} en total.`);
}

main().catch(error => {
  console.error(error);
  process.exit(1);
});
