import type { TextError } from './api';

// Correcció d'un text en el xat del tauler. S'envia i es guarda com a text pla (igual que la resta de missatges):
//   «He trobat N errors...»
//   «## Ortografia i fonètica»           (títol de grup: tipologia de l'error)
//   «1) «error» → «correcció»: explicació (GNV § 5.1.1)»
// ChatBubble el torna a llegir amb `parseCorrections` i el mostra agrupat.

// Tipologies, en l'ordre en què es mostren (l'àrea general de l'error, la mateixa que classifica la ruta d'aprenentatge).
const GROUPS: { area: string; title: string }[] = [
  { area: 'fonetica_ortografia', title: 'Ortografia i fonètica' },
  { area: 'morfosintaxi', title: 'Morfosintaxi' },
  { area: 'lexic_semantica', title: 'Lèxic i semàntica' },
];
const OTHER_TITLE = 'Altres';

const groupTitle = (area: string) => GROUPS.find(g => g.area === area)?.title ?? OTHER_TITLE;

export function correctionsText(errors: TextError[], citations: ({ seccio: string } | null)[]): string {
  const seen = new Set<string>();
  const byTitle = new Map<string, { error: TextError; cite: string }[]>();
  errors.forEach((error, i) => {
    const key = `${error.error_text.trim().toLowerCase()}|${error.correction.trim().toLowerCase()}`;
    if (seen.has(key)) return;
    seen.add(key);
    const title = groupTitle(error.category);
    byTitle.set(title, [...(byTitle.get(title) ?? []), { error, cite: citations[i] ? ` (GNV § ${citations[i]!.seccio})` : '' }]);
  });

  const titles = [...GROUPS.map(g => g.title), OTHER_TITLE].filter(title => byTitle.has(title));
  let n = 0;
  const lines = titles.flatMap(title => [
    `## ${title}`,
    ...byTitle.get(title)!.map(({ error, cite }) => `${++n}) «${error.error_text}» → «${error.correction}»: ${error.explanation.trim()}${cite}`),
  ]);
  const intro = n === 1 ? 'He trobat 1 error en el teu text:' : `He trobat ${n} errors en el teu text:`;
  return [intro, ...lines].join('\n');
}

export type ParsedCorrection = { number: string; wrong: string; right: string; explanation: string; cite: string | null };
export type CorrectionGroup = { title: string; items: ParsedCorrection[] };

const ITEM = /^(\d+)\)\s+«(.*?)»\s*→\s*«(.*?)»:?\s*(.*)$/;
const CITE = /\s*\(GNV § ([\d.]+)\)\s*$/;

export const isGroupLine = (line: string) => line.startsWith('## ');
export const isItemLine = (line: string) => /^\d+\)\s/.test(line);

// Els grups d'un missatge de correcció. Una línia numerada que no seguix el format es mostra sencera com a explicació.
export function parseCorrections(lines: string[]): CorrectionGroup[] {
  const groups: CorrectionGroup[] = [];
  for (const line of lines) {
    if (isGroupLine(line)) {
      groups.push({ title: line.slice(3).trim(), items: [] });
    } else if (isItemLine(line)) {
      if (groups.length === 0) groups.push({ title: OTHER_TITLE, items: [] });
      const match = line.match(ITEM);
      const [, number, wrong, right, rest] = match ?? [undefined, line.match(/^\d+/)![0], '', '', line.replace(/^\d+\)\s*/, '')];
      const cite = rest.match(CITE)?.[1] ?? null;
      groups[groups.length - 1].items.push({ number, wrong, right, explanation: rest.replace(CITE, '').trim(), cite });
    }
  }
  return groups.filter(g => g.items.length > 0);
}
