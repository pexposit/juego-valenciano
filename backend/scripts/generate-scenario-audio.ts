/**
 * Genera la salutació en àudio de cada escenari amb `metadata.greeting_audio` (p. ex. el mag
 * Merlí): el seu `initial_prompt` amb el TTS (matxa, servidor DeepLab de la UJI) i la veu de
 * l'escenari, al fitxer que indica `greeting_audio` (dins de frontend/public). El xat el
 * reprodueix en obrir l'escenari en compte de demanar-lo al TTS.
 *
 *   npx tsx scripts/generate-scenario-audio.ts           # només els que falten
 *   npx tsx scripts/generate-scenario-audio.ts --force   # tots
 *
 * Cal tindre accés al servidor de la UJI (VPN) i la BDD local en marxa.
 */
import 'dotenv/config';
import { existsSync, mkdirSync, writeFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { getAdmin } from '../src/middleware/auth.js';
import { tts } from '../src/services/voice.js';

const PUBLIC_DIR = resolve(dirname(fileURLToPath(import.meta.url)), '../../frontend/public');
const force = process.argv.includes('--force');

async function main() {
  const client = getAdmin() as any;
  if (!client) throw new Error('Falta la configuració de Supabase (backend/.env)');
  const { data, error } = await client.from('resources').select('type, metadata').eq('category', 'escenari');
  if (error) throw error;

  let made = 0;
  const failed: string[] = [];
  for (const { type, metadata } of data ?? []) {
    const path: unknown = metadata?.greeting_audio;
    const text: unknown = metadata?.initial_prompt;
    if (typeof path !== 'string' || typeof text !== 'string') continue;
    const file = resolve(PUBLIC_DIR, `.${path}`);
    if (existsSync(file) && !force) continue;
    const audio = await synthesizeWithRetry(text, metadata?.voice);
    if (!audio) {
      failed.push(type);
      console.error(`! ${path}  «${text}» (el TTS ha fallat)`);
      continue;
    }
    mkdirSync(dirname(file), { recursive: true });
    writeFileSync(file, audio.audio);
    made++;
    console.log(`+ ${path}  «${text}»`);
  }
  console.log(`${made} àudios nous.`);
  if (failed.length) process.exitCode = 1;
}

async function synthesizeWithRetry(text: string, voice?: string, attempts = 4) {
  for (let i = 0; i < attempts; i++) {
    const audio = await tts.synthesize(text, voice);
    if (audio) return audio;
    await new Promise(r => setTimeout(r, 2000 * (i + 1)));
  }
  return null;
}

main().catch(error => {
  console.error(error);
  process.exit(1);
});
