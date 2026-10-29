import { z } from 'zod';
import { callMcpTool } from './subagentErrorDetector.js';

/**
 * Conjugació d'un verb segons el DNV de l'AVL, per al tutor del xat. Es demana a la ferramenta `consultar_conjugacio`
 * del servidor MCP (mcp/ErrorDetector), que torna la taula estructurada (structuredContent) a més del text.
 */

// mode -> temps -> formes (6 persones en els temps personals; en l'imperatiu la 1a és buida).
export interface VerbConjugation {
  verb: string;
  modes: Record<string, Record<string, string[]>>;
  observacions: string[];
  url: string;
}

const resultSchema = z.object({
  existeix: z.boolean(),
  modes: z.record(z.record(z.array(z.string()))).optional(),
  observacions: z.array(z.string()).optional(),
  url: z.string(),
});

/** La conjugació del verb, o `null` si el DNV no la té (no és un verb, porta pronoms...). Llança si el MCP falla. */
export async function consultarConjugacioVerb(verb: string): Promise<VerbConjugation | null> {
  // callMcpTool la guarda en memòria: el mateix verb no es torna a demanar al DNV.
  const result = await callMcpTool('consultar_conjugacio', { verb });
  // L'AVL no respon (xarxa, servidor caigut...): no és que el verb no existisca.
  if (result.isError) throw new Error('El DNV no està disponible ara mateix');
  const parsed = resultSchema.safeParse(result.structuredContent);
  if (!parsed.success) throw new Error('La ferramenta consultar_conjugacio no ha tornat una conjugació vàlida');
  const { existeix, modes, observacions, url } = parsed.data;
  if (!existeix || !modes) return null;
  return { verb, modes, observacions: observacions ?? [], url };
}

/** La conjugació en text, per a passar-la al LLM. */
export function conjugationContext(conjugation: VerbConjugation): string {
  return Object.entries(conjugation.modes)
    .map(([mode, temps]) => `${mode}: ${Object.entries(temps).map(([nom, formes]) => `${nom} (${formes.filter(Boolean).join(', ')})`).join('; ')}`)
    .concat(conjugation.observacions.map((o) => `Observació: ${o}`))
    .join('\n');
}
