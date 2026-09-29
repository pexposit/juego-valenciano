import type { ScenarioKey } from './types.js';

// Relaciona cada escenari amb el `name` de la seua fila a `resources`
// (l'id és un uuid aleatori i el nom a la BD no sempre coincideix amb la
// clau de l'escenari, p. ex. "Ayuntament" davant "ajuntament").
export const RESOURCE_NAME_BY_SCENARIO: Partial<Record<ScenarioKey, string>> = {
  mercat: 'Mercat',
  bar: 'Bar',
  oficina: 'Oficina',
  ajuntament: 'Ayuntament',
  turisme: 'Oficina de Turisme',
};
