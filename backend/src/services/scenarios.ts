import { CHAT_CATEGORIES } from '@parlaval/shared';
import { getAdmin } from '../middleware/auth.js';

// Els escenaris (xats amb un personatge) viuen a la taula resources:
// category 'escenari', `type` com a clau i el personatge a `metadata`.
// Afegir una fila amb el personatge (`character_role` o `character`) fa jugable
// un escenari nou sense tocar codi; `system_prompt` és opcional i permet afinar-lo.
// Les àrees de conversa del temari (p. ex. 'expressio_oral') funcionen igual:
// CHAT_CATEGORIES les inclou totes. Els `type` no es poden repetir entre elles.
export const SCENARIO_CATEGORY = 'escenari';

export interface ScenarioDefinition {
  type: string;
  category: string;
  character: string;
  systemPrompt: string;
  objectius: string[];
  voice?: string;
}

type ResourceMetadata = Record<string, unknown> | null | undefined;
type ScenarioRow = { type: string; category: string; name: string; content: string | null; metadata: ResourceMetadata };

const text = (value: unknown) => (typeof value === 'string' && value.trim() ? value.trim() : undefined);

export const characterOf = (metadata: ResourceMetadata) =>
  text(metadata?.character) ?? text(metadata?.character_role);

// Un escenari és jugable com a xat si se sap quin personatge fer.
export function isScenarioPlayable(metadata: ResourceMetadata) {
  return !!(text(metadata?.system_prompt) || characterOf(metadata));
}

// Prompt per defecte quan la fila no porta `system_prompt`: es construïx amb
// les dades del recurs, amb les mateixes pautes que els escenaris escrits a mà.
function defaultSystemPrompt(character: string, row: ScenarioRow) {
  const greeting = text(row.metadata?.initial_prompt);
  return [
    `Ets ${character} en aquesta situació: ${row.name}.`,
    text(row.content) && `Objectiu de la pràctica: ${text(row.content)}`,
    greeting && `Comences la conversa amb una salutació com aquesta: "${greeting}"`,
    "Mantín una conversa natural en valencià general, amb el vocabulari propi de la situació.",
    "Adapta't al nivell de l'aprenent: principiant usa frases breus i clares; intermedi amplia amb preguntes; avançat usa registre espontani.",
    `No faces explicacions llargues: respon com a ${character} i, si cal, corregeix suaument amb un exemple. El teu objectiu és que continue la conversa.`,
  ].filter(Boolean).join(' ');
}

export function toScenarioDefinition(row: ScenarioRow): ScenarioDefinition | null {
  if (!CHAT_CATEGORIES.includes(row.category) || !isScenarioPlayable(row.metadata)) return null;
  const character = characterOf(row.metadata) ?? 'Personatge';
  const objectius = row.metadata?.objectius;
  return {
    type: row.type,
    category: row.category,
    character,
    systemPrompt: text(row.metadata?.system_prompt) ?? defaultSystemPrompt(character, row),
    objectius: Array.isArray(objectius) ? objectius.filter((o): o is string => typeof o === 'string') : [],
    voice: text(row.metadata?.voice),
  };
}

// Busca l'escenari pel seu `type`. El catàleg és públic, així que es llig amb
// el client admin també en mode demo. Retorna null si no existix o no és jugable.
export async function getScenario(type: string): Promise<ScenarioDefinition | null> {
  const client = getAdmin() as any;
  if (!client) return null;
  const { data, error } = await client
    .from('resources')
    .select('type, category, name, content, metadata')
    .in('category', CHAT_CATEGORIES)
    .eq('type', type)
    .limit(1)
    .maybeSingle();
  if (error) throw error;
  return data ? toScenarioDefinition(data) : null;
}
