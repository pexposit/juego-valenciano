import { categoryLabel } from '../../components/ScenarioSelect';
import { activityRoute, KIDS_ROUTES } from '../../data/content';
import type { PathItemDraft } from '../../lib/paths';
import type { Resource } from '../../lib/types';
import { ALL_LESSONS, ISLANDS, islandById, lessonById, PRE_A1_LESSONS } from '../kids/lessons';

/**
 * El catàleg que es pot posar en una ruta: els recursos de la BD (escenaris, pràctica,
 * exàmens) i les lliçons i illes del Nivell 0, que són en el codi i s'identifiquen per id.
 */

export type CatalogEntry = { key: string; group: string; title: string; emoji: string; item: PathItemDraft };
/** Com es mostra i on s'obri un pas. route null: el recurs ja no existix o no es pot jugar. */
export type ResolvedItem = { title: string; emoji: string; kindLabel: string; route: string | null };

export const itemKey = (item: Pick<PathItemDraft, 'kind' | 'resource_id' | 'kids_ref'>) =>
  item.kind === 'resource' ? `r:${item.resource_id}` : `${item.kind}:${item.kids_ref}`;

const kidsEntry = (kind: 'kids_lesson' | 'kids_island', id: string, group: string, title: string, emoji: string): CatalogEntry =>
  ({ key: `${kind}:${id}`, group, title, emoji, item: { kind, resource_id: null, kids_ref: id, note: '' } });

/** Totes les activitats que es poden afegir, agrupades. Els recursos, del nivell indicat (o tots). */
export function catalogEntries(resources: Resource[], level: string | null, audience: 'child' | 'adult'): CatalogEntry[] {
  const fromDb = resources
    .filter(r => r.playable && (!level || r.difficulty === level))
    .map(r => ({
      key: `r:${r.id}`,
      group: categoryLabel(r.category),
      title: r.section_name ?? r.name,
      emoji: r.icon ?? '📘',
      item: { kind: 'resource' as const, resource_id: r.id, kids_ref: null, note: '' },
    }));
  if (audience === 'adult') return fromDb;
  const preA1 = new Set(PRE_A1_LESSONS.map(l => l.id));
  return [
    ...ALL_LESSONS.map(l => kidsEntry('kids_lesson', l.id, preA1.has(l.id) ? 'Lliçons · Guia Pre-A1' : 'Lliçons · Taronjeta', l.title, l.emoji)),
    ...ISLANDS.map(i => kidsEntry('kids_island', i.id, 'Illes', i.name, i.emoji)),
    ...fromDb,
  ];
}

export function resolveItem(item: Pick<PathItemDraft, 'kind' | 'resource_id' | 'kids_ref'>, resources: Map<string, Resource>): ResolvedItem {
  if (item.kind === 'kids_lesson') {
    const lesson = lessonById(item.kids_ref ?? undefined);
    return { title: lesson?.title ?? 'Lliçó retirada', emoji: lesson?.emoji ?? '📖', kindLabel: 'Lliçó', route: lesson ? `${KIDS_ROUTES.lesson}/${lesson.id}` : null };
  }
  if (item.kind === 'kids_island') {
    const island = islandById(item.kids_ref ?? undefined);
    return { title: island?.name ?? 'Illa retirada', emoji: island?.emoji ?? '🏝️', kindLabel: 'Illa', route: island ? `${KIDS_ROUTES.island}/${island.id}` : null };
  }
  const resource = resources.get(item.resource_id ?? '');
  return {
    title: resource ? resource.section_name ?? resource.name : 'Activitat no disponible',
    emoji: resource?.icon ?? '📘',
    kindLabel: resource ? categoryLabel(resource.category) : '',
    route: resource?.playable ? activityRoute(resource) : null,
  };
}
