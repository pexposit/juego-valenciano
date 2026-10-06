/**
 * Genera els àudios estàtics del Nivell 0 infantil (frontend/src/features/kids/content.ts
 * i lessons.ts): una frase de KIDS_AUDIO o de LESSON_AUDIO per fitxer, amb el TTS (matxa, servidor DeepLab de la UJI),
 * a frontend/public/audio/kids/<clau>.wav. Els xiquets no llegixen: tot s'escolta.
 *
 *   npx tsx scripts/generate-kids-audio.ts           # només els que falten
 *   npx tsx scripts/generate-kids-audio.ts --force   # tots
 *   npx tsx scripts/generate-kids-audio.ts --check   # només comprova que no en falte cap (ix amb error si en falten)
 *
 * El TTS no suporta bé peticions simultànies: les frases es demanen d'una en una.
 * De tant en tant el servidor respon 500 a una frase que després genera bé: cada
 * frase es reintenta i, si continua fallant, es deixa per a la pròxima execució.
 */
import 'dotenv/config';
import { existsSync, mkdirSync, writeFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { tts } from '../src/services/voice.js';
import { KIDS_AUDIO } from '../../frontend/src/features/kids/content.js';
import { LESSON_AUDIO } from '../../frontend/src/features/kids/lessons.js';

const OUT_DIR = resolve(dirname(fileURLToPath(import.meta.url)), '../../frontend/public/audio/kids');
const VOICE = 'gina';
const force = process.argv.includes('--force');
const check = process.argv.includes('--check');

async function main() {
  mkdirSync(OUT_DIR, { recursive: true });
  const entries = Object.entries({ ...KIDS_AUDIO, ...LESSON_AUDIO });
  if (check) {
    const missing = entries.filter(([key]) => !existsSync(resolve(OUT_DIR, `${key}.wav`)));
    for (const [key, text] of missing) console.error(`- ${key}.wav  «${text}»`);
    console.log(missing.length ? `Falten ${missing.length} àudios de ${entries.length}.` : `Hi són tots els àudios (${entries.length}).`);
    if (missing.length) process.exitCode = 1;
    return;
  }
  let made = 0;
  const failed: string[] = [];
  for (const [key, text] of entries) {
    const file = resolve(OUT_DIR, `${key}.wav`);
    if (existsSync(file) && !force) continue;
    const audio = await synthesizeWithRetry(text);
    if (!audio) {
      failed.push(key);
      console.error(`! ${key}.wav  «${text}» (el TTS ha fallat)`);
      continue;
    }
    writeFileSync(file, audio.audio);
    made++;
    console.log(`+ ${key}.wav  «${text}»`);
  }
  console.log(`${made} àudios nous, ${entries.length} en total.`);
  if (failed.length) {
    console.error(`${failed.length} frases no s'han pogut generar: torna a executar el script per a reintentar-les.`);
    process.exitCode = 1;
  }
}

async function synthesizeWithRetry(text: string, attempts = 4) {
  for (let i = 0; i < attempts; i++) {
    const audio = await tts.synthesize(text, VOICE);
    if (audio) return audio;
    await new Promise(r => setTimeout(r, 2000 * (i + 1)));
  }
  return null;
}

main().catch(error => {
  console.error(error);
  process.exit(1);
});
