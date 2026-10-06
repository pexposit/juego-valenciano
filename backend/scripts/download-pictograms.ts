/**
 * Descarrega els pictogrames d'ARASAAC de les lliçons de frases (PICTOGRAMS a
 * frontend/src/features/kids/pictograms.ts) a frontend/public/pictograms/<id>.png.
 * Llicència CC BY-NC-SA 4.0 d'ARASAAC (autor Sergio Palao, Govern d'Aragó): vegeu pictograms.ts.
 *
 *   npx tsx scripts/download-pictograms.ts           # només els que falten
 *   npx tsx scripts/download-pictograms.ts --force   # tots
 */
import { existsSync, mkdirSync, writeFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { PICTOGRAMS } from '../../frontend/src/features/kids/pictograms.js';

const OUT_DIR = resolve(dirname(fileURLToPath(import.meta.url)), '../../frontend/public/pictograms');
const force = process.argv.includes('--force');

async function main() {
  mkdirSync(OUT_DIR, { recursive: true });
  let made = 0;
  const failed: string[] = [];
  for (const [name, id] of Object.entries(PICTOGRAMS)) {
    const file = resolve(OUT_DIR, `${id}.png`);
    if (existsSync(file) && !force) continue;
    const res = await fetch(`https://static.arasaac.org/pictograms/${id}/${id}_300.png`).catch(() => null);
    if (!res?.ok) {
      failed.push(name);
      console.error(`! ${name} (${id}): no s'ha pogut descarregar`);
      continue;
    }
    writeFileSync(file, Buffer.from(await res.arrayBuffer()));
    made++;
    console.log(`+ ${id}.png  ${name}`);
  }
  console.log(`${made} pictogrames nous.`);
  if (failed.length) process.exitCode = 1;
}

main().catch(error => {
  console.error(error);
  process.exit(1);
});
