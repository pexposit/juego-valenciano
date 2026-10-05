/**
 * Tradueix els subtítols del Nivell 0 infantil (consignes, explicacions i diàlegs de
 * frontend/src/features/kids/content.ts i lessons.ts) a les llengües maternes amb
 * traducció, amb el LLM (OPENAI_MODEL). El vocabulari que s'aprén no es tradueix.
 *
 * Cada llengua és un fitxer frontend/src/features/kids/i18n/<llengua>.json amb
 * { clau: { ca: frase en valencià, t: traducció } }. Si la frase en valencià canvia,
 * la traducció antiga ja no es mostra i el script la torna a fer.
 *
 *   npx tsx scripts/generate-kids-translations.ts             # només les que falten
 *   npx tsx scripts/generate-kids-translations.ts --force     # totes
 *   npx tsx scripts/generate-kids-translations.ts es uk       # només eixes llengües
 */
import 'dotenv/config';
import { existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import OpenAI from 'openai';
import { motherTongueLabel, TRANSLATED_TONGUES } from '@parlaval/shared';
import { KIDS_AUDIO } from '../../frontend/src/features/kids/content.js';
import { LESSON_AUDIO, translatableKeys } from '../../frontend/src/features/kids/lessons.js';

type Entry = { ca: string; t: string };
const OUT_DIR = resolve(dirname(fileURLToPath(import.meta.url)), '../../frontend/src/features/kids/i18n');
const BATCH = 40;
const force = process.argv.includes('--force');
const only = process.argv.slice(2).filter(a => !a.startsWith('--'));

const SOURCE: Record<string, string> = { ...KIDS_AUDIO, ...LESSON_AUDIO };
const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY, maxRetries: 2, timeout: 120_000 });

// «al castellà», «a l'anglés»
const toLanguage = (language: string) => (/^[aeiouàèéíòóú]/.test(language) ? `a l'${language}` : `al ${language}`);

const instructions = (language: string) => [
  `Tradueixes ${toLanguage(language)} els subtítols d'una app per a aprendre valencià, per a xiquets de 4 a 7 anys que juguen acompanyats d'un adult.`,
  'Cada frase la diu la Taronjeta, una mascota taronja; el subtítol traduït ix davall del text en valencià.',
  `Traduccions naturals, curtes i afectuoses, com parlaria una mestra d'infantil, tractant de tu.`,
  "MOLT IMPORTANT: les paraules valencianes que la frase ensenya o posa d'exemple (articles com EL, LA, L', ELS, LES; " +
    "noms d'animals, colors, números, parts del cos, dies, sons com «ny» o «ç»...) es deixen en valencià, tal com estan, " +
    'i si ajuda, la traducció entre parèntesis. Exemple: «Moltes paraules van amb EL: el gos, el pa, el sol.» → en castellà ' +
    '«Muchas palabras van con EL: el gos (el perro), el pa (el pan), el sol (el sol).»',
  'Els noms propis (Taronjeta, Pep, Pelut, València) no es tradueixen. Conserva els signes ! i ? i no afigues emojis.',
  'Respon amb un JSON {"translations": [{"key": ..., "text": ...}]} amb exactament les mateixes claus.',
].join('\n');

async function translateBatch(language: string, batch: [string, string][]): Promise<Record<string, string>> {
  const response = await openai.chat.completions.create({
    model: process.env.OPENAI_MODEL!,
    response_format: { type: 'json_object' },
    messages: [
      { role: 'system', content: instructions(language) },
      { role: 'user', content: JSON.stringify(batch.map(([key, text]) => ({ key, text }))) },
    ],
  });
  const parsed = JSON.parse(response.choices[0]?.message?.content ?? '{}') as { translations?: { key: string; text: string }[] };
  const out: Record<string, string> = {};
  for (const { key, text } of parsed.translations ?? []) {
    if (typeof key === 'string' && typeof text === 'string' && text.trim() && key in SOURCE) out[key] = text.trim();
  }
  return out;
}

async function main() {
  if (!process.env.OPENAI_API_KEY || !process.env.OPENAI_MODEL) throw new Error('Cal OPENAI_API_KEY i OPENAI_MODEL en backend/.env');
  mkdirSync(OUT_DIR, { recursive: true });
  const keys = translatableKeys(KIDS_AUDIO);
  const tongues = TRANSLATED_TONGUES.filter(t => !only.length || only.includes(t));

  let failed = 0;
  for (const tongue of tongues) {
    const file = resolve(OUT_DIR, `${tongue}.json`);
    const old: Record<string, Entry> = existsSync(file) ? JSON.parse(readFileSync(file, 'utf8')) : {};
    // Es queden només les frases que encara existixen i no han canviat.
    const current: Record<string, Entry> = {};
    for (const key of keys) if (!force && old[key]?.ca === SOURCE[key]) current[key] = old[key];
    const pending = keys.filter(key => !current[key]).map(key => [key, SOURCE[key]] as [string, string]);
    const language = motherTongueLabel(tongue)!.toLowerCase();
    console.log(`${tongue}: ${pending.length} frases per traduir`);

    for (let i = 0; i < pending.length; i += BATCH) {
      const batch = pending.slice(i, i + BATCH);
      try {
        const result = await translateBatch(language, batch);
        for (const [key, ca] of batch) if (result[key]) current[key] = { ca, t: result[key] };
        const missing = batch.filter(([key]) => !result[key]).length;
        failed += missing;
        console.log(`  ${Math.min(i + BATCH, pending.length)}/${pending.length}${missing ? ` (${missing} sense traducció)` : ''}`);
      } catch (error) {
        failed += batch.length;
        console.error(`  error en el lot ${i / BATCH + 1}:`, error instanceof Error ? error.message : error);
      }
      // Es guarda després de cada lot: si es para, la pròxima execució continua.
      const sorted = Object.fromEntries(keys.filter(k => current[k]).map(k => [k, current[k]]));
      writeFileSync(file, `${JSON.stringify(sorted, null, 1)}\n`);
    }
    if (!pending.length) writeFileSync(file, `${JSON.stringify(Object.fromEntries(keys.filter(k => current[k]).map(k => [k, current[k]])), null, 1)}\n`);
  }
  if (failed) {
    console.error(`${failed} frases sense traduir: torna a executar el script per a reintentar-les.`);
    process.exitCode = 1;
  }
}

main().catch(error => {
  console.error(error);
  process.exit(1);
});
