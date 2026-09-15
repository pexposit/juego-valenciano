import type { ScenarioKey } from '@parlaval/shared';
import { mercat } from './mercat.js'; import { bar } from './bar.js'; import { oficina } from './oficina.js'; import { ajuntament } from './ajuntament.js'; import { colegi } from './colegi.js'; import { turisme } from './turisme.js';
// Record<ScenarioKey, ...> obliga a definir tots els escenaris de la font
// compartida: si s'hi afegeix un de nou, el compilador marca l'omissió aquí.
export const scenarios: Record<ScenarioKey, (typeof mercat | typeof bar | typeof oficina | typeof ajuntament | typeof colegi | typeof turisme)>={mercat,bar,oficina,ajuntament,colegi,turisme};

