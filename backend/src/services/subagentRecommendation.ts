import OpenAI from 'openai';
import { z } from 'zod';
import { zodResponseFormat } from 'openai/helpers/zod';

// Avaluació pedagògica en tancar un recurs (xat). Els errors i les avaluacions anteriors els
// envia el client (es guarden en el seu navegador, no al servidor): el LLM els rep directament
// i el resultat es torna al client. Al servidor només es guarda el priority_focus.

const MODEL_NAME = process.env.OPENAI_MODEL!;
// Es crea en la primera crida: així el mòdul es pot importar (p. ex. als tests) sense clau.
let openaiClient: OpenAI | undefined;
const openai = () => (openaiClient ??= new OpenAI({ apiKey: process.env.OPENAI_API_KEY, maxRetries: 1, timeout: 60_000 }));

// -------------------------------------------------------------
// ESQUEMES DE VALIDACIÓ ZOD (Eixida estructurada de l'avaluació)
// -------------------------------------------------------------
export const EvaluationReportSchema = z.object({
  summary: z
    .string()
    .describe(
      "Diagnòstic qualitatiu de l'estat de l'aprenentatge del xiquet/inmigrant, comparant amb les 4 avaluacions prèvies si existixen."
    ),
  weaknesses: z
    .array(z.string())
    .describe(
      "Llista de patrons o conceptes febles recurrents detectats (ex: ['calcs_lexics', 'apostrofacio_pronoms'])."
    ),
  priority_focus: z
    .string()
    .describe(
      "L'àrea o concepte crític prioritari que ha d'atacar de manera immediata la següent ruta d'aprenentatge."
    ),
});

export type EvaluationReport = z.infer<typeof EvaluationReportSchema>;

export type EvaluationError = { error_text: string; correction: string; category: string; explanation: string };
export type PreviousEvaluation = { summary: string; weaknesses: string[]; priority_focus: string; created_at: string };

// -------------------------------------------------------------
// SYSTEM PROMPT DEL SUBAGENT REVISOR
// -------------------------------------------------------------
export const SYSTEM_PROMPT_RECOMMENDATION = `
PROTOCOL D'AVALUACIÓ:

DADES QUE REPS
- errors: els errors pendents del recurs que s'acaba de tancar (error_text, correction, category, explanation).
- avaluacions_anteriors: les últimes avaluacions de l'usuari (pot estar buida).

PAS 1: ANÀLISI DIRECTA
- Compta quina 'category' és la més freqüent entre els errors rebuts.
- Compara amb el 'priority_focus' de l'avaluació anterior més recent:
  * Si coincidixen, indica en el resum que el bloqueig en eixa categoria persistix.
  * Si no, indica que el focus canvia cap a la nova categoria predominant.

PAS 2: VEREDICTE
- 'priority_focus': serà exactament el nom de la categoria amb més errors no resolts.
- 'weaknesses': Selecciona els errors més greus o bloquejants per a la comunicació diària que han d'anar primers a la ruta (format: "error -> correcció").
- 'summary': Un paràgraf explicant com evoluciona i quina categoria concentra les fallades.`;

// -------------------------------------------------------------
// FUNCIÓ PRINCIPAL D'EXECUCIÓ DEL SUBAGENT
// -------------------------------------------------------------
export async function runPedagogicalEvaluation(
  errors: EvaluationError[],
  previous: PreviousEvaluation[],
): Promise<EvaluationReport | null> {
  if (errors.length === 0) return null;
  const tStart = Date.now();

  try {
    const response = await openai().chat.completions.parse({
      model: MODEL_NAME,
      messages: [
        { role: 'system', content: SYSTEM_PROMPT_RECOMMENDATION },
        { role: 'user', content: JSON.stringify({ errors, avaluacions_anteriors: previous }) },
      ],
      response_format: zodResponseFormat(EvaluationReportSchema, 'evaluation_report'),
      reasoning_effort: 'none',
    });

    console.log(`[Evaluator-Agent] Avaluació completada en: ${Date.now() - tStart}ms`);
    return response.choices[0]?.message?.parsed ?? null;
  } catch (error: any) {
    console.error('[Evaluator-Agent] Error processant avaluació:', error.message);
    return null;
  }
}
