import { STAGE_PASS, stageCount } from './islandSession';
import { ALL_LESSONS, ISLANDS } from './lessons';
import type { ChildData, SessionRow } from './tracking';

/**
 * El resum del seguiment d'un xiquet per a les persones adultes (família i professorat):
 * com va cada illa segons les rondes encertades a la primera, què domina, què li costa
 * i què ha de practicar. Només càlculs.
 */

const DAY = 86_400_000;

/**
 * Com va una illa, segons els encerts a la primera: li costa (50 % o menys), ho domina
 * (el 80 % o més i totes les etapes fetes, el mateix llindar que el joc demana per a passar
 * d'etapa) o a practicar (la resta: entre el 50 % i el 80 %, el 80 % o més però amb etapes
 * per fer, o encara no hi ha jugat).
 */
export type Mastery = 'costa' | 'practicar' | 'domina';
export const masteryOf = (accuracy: number | null, complete: boolean): Mastery =>
  accuracy === null ? 'practicar' : accuracy <= 0.5 ? 'costa' : accuracy >= STAGE_PASS && complete ? 'domina' : 'practicar';

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
};

const ratio = (part: number, whole: number) => (whole > 0 ? part / whole : null);
const minutes = (sessions: SessionRow[]) => Math.round(sessions.reduce((s, x) => s + x.seconds, 0) / 60);

export function summarize({ badges, sessions }: ChildData, now = Date.now()): Report {
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
