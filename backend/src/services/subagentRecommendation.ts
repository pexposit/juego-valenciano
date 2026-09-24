import OpenAI from 'openai';
import { Client } from '@modelcontextprotocol/sdk/client/index.js';
import { StdioClientTransport } from '@modelcontextprotocol/sdk/client/stdio.js';
import type {
  ChatCompletionMessageParam,
  ChatCompletionTool,
} from 'openai/resources/chat/completions';
import { z } from 'zod';
import { zodResponseFormat } from 'openai/helpers/zod';

// Variables d'entorn
const MODEL_NAME = process.env.OPENAI_MODEL!;
const EVALUATOR_MCP_SERVER_SCRIPT =
  process.env.MCPRECOMMENDATION_SERVER_PATH!

// 1. Client OpenAI
const openaiClient = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
  maxRetries: 1,
  timeout: 60_000,
});

// 2. Client MCP per a la base de dades (Lazy connection)
let mcpClient: Client | null = null;
let cachedTools: ChatCompletionTool[] = [];

async function getRecommendationMcpTools(): Promise<{
  client: Client;
  tools: ChatCompletionTool[];
}> {
  if (mcpClient && cachedTools.length > 0) {
    return { client: mcpClient, tools: cachedTools };
  }

  const transport = new StdioClientTransport({
    command: 'npx',
    args: ['tsx', EVALUATOR_MCP_SERVER_SCRIPT],
  });

  mcpClient = new Client(
    { name: 'valencian-evaluator-agent', version: '1.0.0' },
    { capabilities: {} }
  );

  await mcpClient.connect(transport);

  const { tools } = await mcpClient.listTools();
  cachedTools = tools.map((tool) => {
    const originalSchema = (tool.inputSchema as Record<string, any>) || {};
    const props = originalSchema.properties || {};

    // Forcem 'required' en totes les propietats per al mode strict d'OpenAI
    const strictParameters = {
      type: 'object',
      properties: props,
      required: Object.keys(props),
      additionalProperties: false,
    };

    return {
      type: 'function',
      function: {
        name: tool.name,
        description: tool.description || '',
        parameters: strictParameters,
        strict: true,
      },
    };
  });

  return { client: mcpClient, tools: cachedTools };
}

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
  saved: z
    .boolean()
    .describe("Confirma si s'ha executat amb èxit la ferramenta 'save_user_evaluation'."),
});

export type EvaluationReport = z.infer<typeof EvaluationReportSchema>;

// -------------------------------------------------------------
// SYSTEM PROMPT DEL SUBAGENT REVISOR
// -------------------------------------------------------------
export const SYSTEM_PROMPT_RECOMMENDATION = `
PROTOCOL D'AVALUACIÓ:

PAS 1: OBTENCIÓ DE DADES (OBLIGATORI)
- Invoca 'get_unresolved_errors' per a obtindre els errors actius.
- Invoca 'get_recent_evaluations' amb limit=4 per a obtindre les avaluacions anteriors.

PAS 2: ANÀLISI DIRECTA
- Compta quina 'category' és la més freqüent entre els errors recuperats de la base de dades.
- Compara amb el 'priority_focus' de l'informe anterior:
  * Si coincidixen, indica en el resum que el bloqueig en eixa categoria persistix.
  * Si no, indica que el focus canvia cap a la nova categoria predominant.

PAS 3: VEREDICTE
- 'priority_focus': serà exactament el nom de la categoria amb més errors no resolts.
- 'weaknesses': Selecciona els errors més greus o bloquejants per a la comunicació diària que han d'anar primers a la ruta (format: "error -> correcció").

PAS 4: PERSISTÈNCIA
- Invoca 'save_user_evaluation' passant:
  * userId: El UUID de l'usuari.    
  * summary: Un paràgraf explicant com evoluciona i quina categoria concentra les fallades.
  * weaknesses: Llista dels errors més crítics detectats.
  * priorityFocus: La categoria triada com a prioritària.`;

// -------------------------------------------------------------
// FUNCIÓ PRINCIPAL D'EXECUCIÓ DEL SUBAGENT
// -------------------------------------------------------------
export async function runPedagogicalEvaluation(userId: string): Promise<EvaluationReport | null> {
  const trimmedUserId = userId.trim();
  if (!trimmedUserId) return null;

  const tStart = Date.now();

  try {
    const { client: mcp, tools } = await getRecommendationMcpTools();

    const messages: ChatCompletionMessageParam[] = [
      { role: 'system', content: SYSTEM_PROMPT_RECOMMENDATION },
      {
        role: 'user',
        content: `Realitza l'avaluació diagnòstica periòdica per a l'usuari amb ID: "${trimmedUserId}". Consulta les seues dades i guarda l'informe resultant.`,
      },
    ];

    const responseFormat = zodResponseFormat(EvaluationReportSchema, 'evaluation_report');
    const toolsConfig = tools.length > 0 ? tools : undefined;

    // 1. Invocació inicial
    let response = await openaiClient.chat.completions.parse({
      model: MODEL_NAME,
      messages,
      tools: toolsConfig,
      response_format: responseFormat,
      reasoning_effort: 'none',
    });

    let choice = response.choices[0];

    // 2. Bucle de resolució de ferramentes (obtindre errors -> veure 4 avaluacions -> guardar nova avaluació)
    while (choice?.message?.tool_calls && choice.message.tool_calls.length > 0) {
      messages.push(choice.message);

      for (const toolCall of choice.message.tool_calls) {
        if (toolCall.type !== 'function') continue;

        console.log(`[MCP Evaluator Tool] ${toolCall.function.name}(${toolCall.function.arguments})`);

        let toolOutput: any;
        try {
          const result = await mcp.callTool({
            name: toolCall.function.name,
            arguments: JSON.parse(toolCall.function.arguments || '{}'),
          });
          toolOutput = result.content;
        } catch (err: any) {
          toolOutput = { error: `Error executant ferramenta: ${err.message}` };
        }

        messages.push({
          role: 'tool',
          tool_call_id: toolCall.id,
          content: typeof toolOutput === 'string' ? toolOutput : JSON.stringify(toolOutput),
        });
      }

      // Re-invocació amb l'estat actualitzat
      response = await openaiClient.chat.completions.parse({
        model: MODEL_NAME,
        messages,
        tools: toolsConfig,
        response_format: responseFormat,
        reasoning_effort: 'none',
      });

      choice = response.choices[0];
    }

    console.log(`[Evaluator-Agent] Avaluació completada en: ${Date.now() - tStart}ms`);

    return choice?.message?.parsed ?? null;
  } catch (error: any) {
    console.error('[Evaluator-Agent] Error processant avaluació:', error.message);
    return null;
  }
}