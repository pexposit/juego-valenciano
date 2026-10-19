import { STAGE_PASS, stageCount } from './islandSession';
import { ALL_LESSONS, ISLANDS } from './lessons';
import type { ChildData, ConversationRow, SessionRow } from './tracking';

/**
 * El resum del seguiment d'un xiquet per a les persones adultes (família i professorat):
 * com va cada illa segons les rondes encertades a la primera, què domina, què li costa
 * i què ha de practicar. Només càlculs.
 */

const DAY = 86_400_000;

/**
 * Com va una illa. Acabada (totes les etapes, les tres estrelles) és que la domina, siga
 * quina siga la mitjana: cada etapa ja s'ha superat amb el 80 % en una partida, i als
 * xiquets no se'ls diu que han de repassar el que ja han guanyat. Si no està acabada, segons
 * els encerts a la primera: li costa (50 % o menys) o a practicar (la resta, o encara no hi ha jugat).
 */
export type Mastery = 'costa' | 'practicar' | 'domina';
export const masteryOf = (accuracy: number | null, complete: boolean): Mastery =>
  complete ? 'domina' : accuracy !== null && accuracy <= 0.5 ? 'costa' : 'practicar';

const COUNT = ['una', 'dues', 'tres', 'quatre', 'cinc'];
/**
 * Per a les illes que va molt bé però que encara no ha acabat: «Domina la primera etapa,
 * però encara li'n falten dues.» Res si no és el cas.
 */
export function stageNote(island: IslandSummary): string | null {
  if (island.cromo || island.accuracy === null || island.accuracy < STAGE_PASS || !island.stagesDone) return null;
  const left = island.stages - island.stagesDone;
  const done = island.stagesDone === 1 ? 'la primera etapa' : `les ${COUNT[island.stagesDone - 1]} primeres etapes`;
  return `Domina ${done}, però encara li'n ${left === 1 ? 'falta una' : `falten ${COUNT[left - 1]}`}.`;
}

export type IslandSummary = {
  id: string;
  name: string;
  emoji: string;
  color: string;
  lesson?: string;
  stages: number;
  stagesDone: number;
  cromo: boolean;
  sessions: number;
  accuracy: number | null; // rondes encertades a la primera (0-1)
  lastPlayed: string | null;
  easy: boolean; // l'última partida era en mode fàcil
  mastery: Mastery;
};

export type Report = {
  week: { minutes: number; sessions: number; days: number };
  total: { minutes: number; sessions: number };
  accuracy: number | null;
  lastPlayed: string | null;
  cromos: number;
  medals: number;
  medalsTotal: number;
  islands: IslandSummary[];
  // Les illes de cada grup, de menys a més encerts (les no jugades, al final de «practicar»).
  costa: IslandSummary[];
  practicar: IslandSummary[];
  domina: IslandSummary[];
  recent: (SessionRow & { name: string; emoji: string })[];
  conversations: ScenarioSummary[];
};

/** Les converses amb un personatge: quantes, l'última (amb els seus objectius) i el millor resultat. */
export type ScenarioSummary = {
  id: string;
  name: string;
  count: number;
  minutes: number;
  latest: ConversationRow;
  all: ConversationRow[]; // de més nova a més antiga
  best: number; // màxim d'objectius complits en una conversa
  total: number;
};

const metCount = (c: ConversationRow) => c.objectives.filter(o => o.met).length;

function summarizeConversations(conversations: ConversationRow[]): ScenarioSummary[] {
  const byScenario = new Map<string, ConversationRow[]>();
  for (const c of conversations) byScenario.set(c.resource_id, [...(byScenario.get(c.resource_id) ?? []), c]);
  return [...byScenario.entries()]
    .map(([id, list]) => ({
      id,
      name: list[0].scenario_name,
      count: list.length,
      minutes: minutes(list),
      latest: list[0],
      all: list,
      best: Math.max(...list.map(metCount)),
      total: list[0].objectives.length,
    }))
    .sort((a, b) => Date.parse(b.latest.created_at) - Date.parse(a.latest.created_at));
}

const ratio = (part: number, whole: number) => (whole > 0 ? part / whole : null);
const minutes = (rows: { seconds: number }[]) => Math.round(rows.reduce((s, x) => s + x.seconds, 0) / 60);

export function summarize({ badges, sessions, conversations = [] }: ChildData, now = Date.now()): Report {
  const week = sessions.filter(s => now - Date.parse(s.created_at) < 7 * DAY);
  const cromos = badges.filter(b => b.startsWith('cromo:')).map(b => b.slice(6));
  const stages = badges.filter(b => b.startsWith('etapa:')).map(b => b.slice(6));

  const islands = ISLANDS.map((island): IslandSummary => {
    const played = sessions.filter(s => s.island === island.id);
    const cromo = cromos.includes(island.id);
    const total = stageCount(island);
    const stagesDone = cromo ? total : Math.min(total, stages.filter(s => s.startsWith(`${island.id}:`)).length);
    const accuracy = ratio(played.reduce((s, x) => s + x.first_try, 0), played.reduce((s, x) => s + x.rounds, 0));
    return {
      id: island.id, name: island.name, emoji: island.emoji, color: island.color, lesson: island.lesson,
      stages: total,
      stagesDone,
      cromo,
      sessions: played.length,
      accuracy,
      lastPlayed: played[0]?.created_at ?? null,
      easy: played[0]?.easy ?? false,
      mastery: masteryOf(accuracy, cromo || stagesDone >= total),
    };
  });
  const byAccuracy = (a: IslandSummary, b: IslandSummary) => (a.accuracy ?? 2) - (b.accuracy ?? 2);
  const group = (mastery: Mastery) => islands.filter(i => i.mastery === mastery).sort(byAccuracy);

  return {
    week: { minutes: minutes(week), sessions: week.length, days: new Set(week.map(s => s.created_at.slice(0, 10))).size },
    total: { minutes: minutes(sessions), sessions: sessions.length },
    accuracy: ratio(sessions.reduce((s, x) => s + x.first_try, 0), sessions.reduce((s, x) => s + x.rounds, 0)),
    lastPlayed: sessions[0]?.created_at ?? null,
    cromos: cromos.filter(c => ISLANDS.some(i => i.id === c)).length,
    medals: badges.filter(b => b.startsWith('llico:')).length,
    medalsTotal: ALL_LESSONS.length,
    islands,
    costa: group('costa'),
    practicar: group('practicar'),
    domina: group('domina'),
    recent: sessions.slice(0, 8).map(s => {
      const island = ISLANDS.find(i => i.id === s.island);
      return { ...s, name: island?.name ?? s.island, emoji: island?.emoji ?? '🏝️' };
    }),
    conversations: summarizeConversations(conversations),
  };
}

/** Les illes que costen (50 % o menys) a més alumnes d'una classe, amb quants. */
export function groupStruggles(students: ChildData[]) {
  const reports = students.map(s => summarize(s));
  return ISLANDS
    .map(island => ({ island, students: reports.filter(r => r.costa.some(i => i.id === island.id)).length }))
    .filter(x => x.students > 0)
    .sort((a, b) => b.students - a.students);
}

/** «avui», «ahir», «fa 3 dies»... */
export function ago(date: string | null, now = Date.now()) {
  if (!date) return 'mai';
  const days = Math.floor((new Date(now).setHours(0, 0, 0, 0) - new Date(date).setHours(0, 0, 0, 0)) / DAY);
  if (days <= 0) return 'avui';
  if (days === 1) return 'ahir';
  if (days < 30) return `fa ${days} dies`;
  return new Date(date).toLocaleDateString('ca-ES', { day: 'numeric', month: 'short' });
}

export const percent = (value: number | null) => (value === null ? '—' : `${Math.round(value * 100)} %`);


/* ── Persones adultes ─────────────────────────────────────────────────── */

/**
 * El mateix resum (li costa, a practicar, ho domina) per a qui no és del Nivell 0, amb les seues activitats en
 * compte d'illes: les pràctiques i els exàmens (última nota) i els escenaris (objectius de l'última conversa).
 *   - ho domina: 80 % o més i, si és una pràctica, sense errors pendents de corregir;
 *   - li costa: 50 % o menys;
 *   - a practicar: la resta (entre el 50 i el 80 %, o amb errors encara sense corregir).
 */
export type AdultItem = {
  key: string;
  name: string;
  emoji: string;
  kind: 'practice' | 'exam' | 'scenario';
  ratio: number;
  detail: string; // «7/10», «2/5 objectius»
  pendingErrors: number;
  lastAt: string;
  mastery: Mastery;
};
export type AdultReport = { costa: AdultItem[]; practicar: AdultItem[]; domina: AdultItem[]; items: AdultItem[]; lastActivity: string | null };

const adultMastery = (ratio: number, pendingErrors: number): Mastery =>
  ratio <= 0.5 ? 'costa' : ratio >= 0.8 && pendingErrors === 0 ? 'domina' : 'practicar';

export function summarizeAdult({ activities = [], conversations = [] }: ChildData): AdultReport {
  const items: AdultItem[] = [];
  for (const a of activities) {
    if (a.score === null || !a.total) continue;
    const r = a.score / a.total;
    items.push({
      key: `${a.kind}:${a.resource_id}`, name: a.name, emoji: a.icon ?? (a.kind === 'exam' ? '📝' : '📘'), kind: a.kind,
      ratio: r, detail: `${a.score}/${a.total}`, pendingErrors: a.pending_errors, lastAt: a.last_at, mastery: adultMastery(r, a.pending_errors),
    });
  }
  for (const c of summarizeConversations(conversations)) {
    if (!c.total || c.latest.objectives.every(o => o.met === null)) continue;
    const met = metCount(c.latest);
    const r = met / c.total;
    items.push({
      key: `scenario:${c.id}`, name: c.name, emoji: '💬', kind: 'scenario',
      ratio: r, detail: `${met}/${c.total} objectius`, pendingErrors: 0, lastAt: c.latest.created_at, mastery: adultMastery(r, 0),
    });
  }
  const group = (mastery: Mastery) => items.filter(i => i.mastery === mastery).sort((a, b) => a.ratio - b.ratio);
  const dates = items.map(i => i.lastAt).sort();
  return { costa: group('costa'), practicar: group('practicar'), domina: group('domina'), items, lastActivity: dates[dates.length - 1] ?? null };
}

/** Les activitats que costen (50 % o menys) a més alumnes adults d'una classe, amb quants. */
export function groupAdultStruggles(students: ChildData[]) {
  const counts = new Map<string, { item: AdultItem; students: number }>();
  for (const report of students.map(summarizeAdult)) {
    for (const item of report.costa) {
      const entry = counts.get(item.key);
      if (entry) entry.students += 1;
      else counts.set(item.key, { item, students: 1 });
    }
  }
  return [...counts.values()].sort((a, b) => b.students - a.students);
}
