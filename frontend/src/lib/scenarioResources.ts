import type { Scenario } from './types';

// Fila de la taula `resources` (catàleg compartit a la BD) que representa un
// escenari de conversa.
export type ScenarioResource = {
  id: string;
  name: string;
  content: string | null;
  xp_earned: number;
  scenario: Scenario;
};

// Relaciona el `name` de la BD amb el tipus `Scenario` del codi (l'id és un
// uuid aleatori i el nom no sempre coincideix, p. ex. "Ayuntament" davant
// "ajuntament"). Explícit en lloc de derivar-ho automàticament del nom
// perquè no depenga de com estiga escrit a la BD.
export const SCENARIO_BY_RESOURCE_NAME: Record<string, Scenario> = {
  Mercat: 'mercat',
  Bar: 'bar',
  Oficina: 'oficina',
  Ayuntament: 'ajuntament',
  'Oficina de Turisme': 'turisme',
};

// La BD no modela l'estil visual (icona/color): és presentació, no dades de
// domini, així que es queda com a taula local per escenari conegut.
export const SCENARIO_STYLE: Record<Scenario, { icon: string; color: string }> = {
  mercat: { icon: '🍊', color: '#FFD98A' },
  bar: { icon: '☕', color: '#F2B47C' },
  oficina: { icon: '💻', color: '#BDE9E8' },
  ajuntament: { icon: '🏛️', color: '#C8D7EE' },
  colegi: { icon: '📚', color: '#F6D6E3' },
  turisme: { icon: '🗺️', color: '#9AD0EC' },
};

// Ordre de presentació fix: l'ordre a la BD no és fiable (les 5 files es van
// inserir en una sola sentència, poden compartir el mateix created_at).
const DISPLAY_ORDER: Scenario[] = ['mercat', 'bar', 'oficina', 'ajuntament', 'colegi', 'turisme'];

export function sortByDisplayOrder(resources: ScenarioResource[]): ScenarioResource[] {
  return [...resources].sort((a, b) => DISPLAY_ORDER.indexOf(a.scenario) - DISPLAY_ORDER.indexOf(b.scenario));
}
