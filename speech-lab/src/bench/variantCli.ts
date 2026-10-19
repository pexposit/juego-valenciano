/**
 * Detector de variant des del terminal: diu si la pronunciació d'un o més
 * WAV és valenciana o central, amb les contribucions de cada variable.
 * Usa l'API fonètica PhoneticXeus de la UJI (només des de la intranet).
 *
 * Ús:
 *   npm run variant -- veu-1.wav veu-2.wav          (una persona: s'ajunta tot)
 *   npm run variant -- *.wav --per-file             (cada fitxer per separat)
 *   npm run variant -- frase.wav --ref "Esta vesprada eixirem a sopar."
 *   npm run variant -- … --model no_lex             (força un model)
 *   npm run variant -- … --json                     (eixida en JSON)
 *
 * Els WAV han de ser PCM16 (mono o estèreo, qualsevol freqüència: es
 * remostregen a 16 kHz). Amb --ref, el text val per a CADA fitxer.
 */
import { readFile } from 'node:fs/promises';
import path from 'node:path';
import { config } from '../config.js';
import { VariantSession } from '../variant/detector.js';
import type { ModelName } from '../variant/model.js';
import { decodeWav } from '../variant/segment.js';
import {
  analyseRecordingTimed, describeResult, describeSegment, PHONETIC_HINT, pingPhoneticApi, resampleTo, speechNotes,
  type TimedAnalysis,
} from '../variant/service.js';

type Args = { files: string[]; perFile: boolean; ref: string | null; model: ModelName | undefined; json: boolean };

function parseArgs(argv: string[]): Args {
  const args: Args = { files: [], perFile: false, ref: null, model: undefined, json: false };
  for (let i = 0; i < argv.length; i += 1) {
    const token = argv[i];
    if (token === '--per-file') args.perFile = true;
    else if (token === '--json') args.json = true;
    else if (token === '--ref') args.ref = argv[++i] ?? null;
    else if (token === '--model') {
      const model = argv[++i];
      if (model !== 'with_lex' && model !== 'no_lex') throw new Error('--model ha de ser with_lex o no_lex');
      args.model = model;
    } else if (token.startsWith('--')) throw new Error(`Opció desconeguda: ${token}`);
    else args.files.push(token);
  }
  return args;
}

const pct = (p: number | null) => (p === null ? '—' : `${(p * 100).toFixed(1)} %`);
const signed = (v: number) => `${v >= 0 ? '+' : '−'}${Math.abs(v).toFixed(2)}`;

type Group = { name: string; files: string[] };

/** Analitza un grup de fitxers d'una mateixa persona i en torna el resultat ajuntat. */
async function classify(group: Group, args: Args) {
  const session = new VariantSession({ model: args.model });
  const segments: (ReturnType<typeof describeSegment> & { file: string })[] = [];
  const notes: string[] = [];
  let audioSeconds = 0;
  for (const file of group.files) {
    const decoded = decodeWav(await readFile(file));
    const audio = resampleTo(decoded);
    audioSeconds += audio.samples.length / audio.sampleRate;
    const run = await analyseRecordingTimed(audio, { referenceText: args.ref, filename: path.basename(file) });
    notes.push(...run.notes.map((n) => `${path.basename(file)}: ${n}`));
    session.addAnalyses(run.analyses.map((a: TimedAnalysis) => a.analysis));
    segments.push(...run.analyses.map((a) => ({ file: path.basename(file), ...describeSegment(a) })));
  }
  const result = session.result();
  notes.push(...speechNotes(result, audioSeconds));
  return {
    name: group.name,
    ...describeResult(result),
    nAe: result.nAe,
    speechSeconds: Number(result.speechSeconds.toFixed(2)),
    audioSeconds: Number(audioSeconds.toFixed(2)),
    segments,
    notes,
  };
}

function print(report: Awaited<ReturnType<typeof classify>>): void {
  console.log(`\n▸ ${report.name}`);
  console.log(`  ${report.label}  ·  p(valencià) = ${pct(report.pValencia)}  ·  model ${report.model}`);
  if (report.reasonText) console.log(`  ${report.reasonText}`);
  console.log(`  veu útil ${report.speechSeconds} s de ${report.audioSeconds} s · ${report.nAe} vocals àtones a/e mesurades`);
  console.log('  Contribucions (+ cap a valencià, − cap a central):');
  for (const c of report.contributions) {
    const value = c.value === null ? 'sense mesura' : `valor ${c.value.toFixed(3)}`;
    console.log(`    ${signed(c.contribution).padStart(6)}  ${c.text} (${value})`);
  }
  console.log('  Segments:');
  for (const s of report.segments) {
    const where = `${s.file} ${s.startS.toFixed(1)}–${s.endS.toFixed(1)} s`;
    console.log(s.usable
      ? `    ✓ ${where} · ${s.nAe} a/e · ${s.ms} ms · «${s.text}»`
      : `    ✗ ${where} · ${s.reasonText}${s.status !== undefined ? ` (${s.status})` : ''}`);
  }
  for (const note of report.notes) console.log(`  Nota: ${note}`);
}

async function main(): Promise<number> {
  const args = parseArgs(process.argv.slice(2));
  if (args.files.length === 0) {
    console.error('Ús: npm run variant -- fitxer.wav [més.wav…] [--per-file] [--ref "text llegit"] [--model with_lex|no_lex] [--json]');
    return 1;
  }
  const ping = await pingPhoneticApi();
  if (!ping.ok) {
    console.error(`[variant] No s'ha pogut connectar amb l'API fonètica (${ping.url}): ${ping.error}`);
    console.error(`[variant] ${PHONETIC_HINT}`);
    return 2;
  }
  if (!args.json) console.log(`[variant] API fonètica ${config.phonetic.baseUrl} (${ping.model ?? '?'}, ${ping.latencyMs} ms)`);

  const groups: Group[] = args.perFile
    ? args.files.map((file) => ({ name: path.basename(file), files: [file] }))
    : [{ name: args.files.length === 1 ? path.basename(args.files[0]) : `${args.files.length} fitxers ajuntats`, files: args.files }];
  const reports = [];
  for (const group of groups) {
    const report = await classify(group, args);
    reports.push(report);
    if (!args.json) print(report);
  }
  if (args.json) console.log(JSON.stringify(args.perFile ? reports : reports[0], null, 2));
  else {
    console.log('\nEl veredicte descriu la pronunciació de l’àudio, no la persona. Necessita 10–20 s de parla'
      + ' seguida; no val per a paraules soltes ni veus sintètiques, i només distingix valencià i central.');
  }
  return 0;
}

main().then((code) => process.exit(code), (error: unknown) => {
  console.error(`[variant] ${error instanceof Error ? error.message : String(error)}`);
  process.exit(1);
});
