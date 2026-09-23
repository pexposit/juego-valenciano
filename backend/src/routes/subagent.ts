import OpenAI from 'openai';
import { Client } from '@modelcontextprotocol/sdk/client/index.js';
import { StdioClientTransport } from '@modelcontextprotocol/sdk/client/stdio.js';
import type {
  ChatCompletionMessageParam,
  ChatCompletionTool,
} from 'openai/resources/chat/completions';

// Variables de entorno
const UJI_HOST = process.env.UJI_HOST;
const UJI_MODEL = process.env.UJI_LLM_MODEL || 'qwen2.5:32b';
const MCP_SERVER_SCRIPT = process.env.MCP_SERVER_PATH || './mcp/index.js';

// 1. Cliente OpenAI persistente
const ujiClient = new OpenAI({
  baseURL: `${UJI_HOST}/v1`,
  apiKey: 'not-needed-uji',
  maxRetries: 1,
  timeout: 60_000,
});

// 2. Cliente MCP persistente (Lazy connection)
let mcpClient: Client | null = null;
let cachedTools: ChatCompletionTool[] = [];

async function getMcpTools(): Promise<{ client: Client; tools: ChatCompletionTool[] }> {
  if (mcpClient && cachedTools.length > 0) {
    return { client: mcpClient, tools: cachedTools };
  }

  const transport = new StdioClientTransport({
    command: 'npx',
    args: ['tsx', MCP_SERVER_SCRIPT],
  });

  mcpClient = new Client(
    { name: 'uji-valencian-corrector', version: '1.0.0' },
    { capabilities: {} }
  );

  await mcpClient.connect(transport);

  // Mapeamos el esquema MCP al esquema JSON Schema de OpenAI
  const { tools } = await mcpClient.listTools();
  cachedTools = tools.map((tool) => ({
    type: 'function',
    function: {
      name: tool.name,
      description: tool.description,
      parameters: tool.inputSchema as Record<string, unknown>,
    },
  }));

  return { client: mcpClient, tools: cachedTools };
}

export interface DetectedError {
  error_text: string;
  correction: string;
  category: string;
  explanation: string;
}

const ERROR_PATTERN = /^\s*(.+?)\s*->\s*(.+?)\s*\|\s*(.+?)\s*\|\s*(.+)\s*$/;

// Hemos añadido una directriz al final para que use las tools sin romper la regla de salida
const SYSTEM_PROMPT_AVL = `Ets un motor automàtic d'extracció d'errades lingüístiques segons la normativa de l'Acadèmia Valenciana de la Llengua (AVL).

REGLA CRÍTICA D'EIXIDA:
- La teua resposta final ha de contindre ÚNICAMENT les línies de correcció.
- PROHIBIT escriure salutacions, comiat, introduccions ("Ací tens les errades:"), conclusions o resums.
- PROHIBIT mostrar processos de reflexió, justificacions o explicacions fora del format establit.
- Comença DIRECTAMENT en el primer caràcter amb la primera línia de correcció.

CRITERIS NORMATIUS AVL:
- Possessius: "meua, teua, seua" són vàlides i preferents. MAI corregir a "meva, teva, seva".
- Subjuntius en "-e": formes com "porte, cante, parle" són correctes. MAI canviar a "-i" ("porti").
- Perífrasis: "Tindre que + infinitiu" és SEMPRE calc del castellà. Cal corregir a "Haver de + infinitiu".
- Pronoms febles davant consonant: la forma reforçada és obligatòria ("em, et, es"). "Me diu" és errada ("em diu").

ÚS DE FERRAMENTES:
- Pots executar les ferramentes (tools) que necessites per a verificar dubtes lexicogràfics o validar regles abans de donar el veredicte final.

FORMAT EXCLUSIU:
Cada errada ha d'anar en una línia seguint exactament esta estructura:
ERRADA -> CORRECCIÓ | CATEGORIA | EXPLICACIÓ

Si el text no té cap errada, respon exactament:
CORRECTE`;

export async function analyzeErrorsWithLocalLLM(content: string): Promise<DetectedError[]> {
  const trimmed = content.trim();
  if (!trimmed) return [];

  const tStart = Date.now();

  try {
    // Obtenemos el cliente MCP y las tools ya convertidas
    const { client: mcp, tools } = await getMcpTools();

    const messages: ChatCompletionMessageParam[] = [
      {
        role: 'system',
        content: SYSTEM_PROMPT_AVL,
      },
      {
        role: 'user',
        content: `Text a analitzar:\n"${trimmed}"`,
      },
    ];

    // 1. Primera llamada al modelo con las tools inyectadas
    let response = await ujiClient.chat.completions.create({
        model: UJI_MODEL,
        messages,
        temperature: 0.1,        // Forzar determinismo
        presence_penalty: 0.0,   // Desactivar castigo por repetición
        frequency_penalty: 0.0,
        top_p: 0.8,
      });

    let choice = response.choices[0];

    // 2. Bucle para resolver tool calls (si el modelo decide ejecutar alguna)
    while (choice?.message?.tool_calls && choice.message.tool_calls.length > 0) {
      messages.push(choice.message); // Guardamos la petición del asistente

      for (const toolCall of choice.message.tool_calls) {
        // Verificación de tipo para estrechar la unión (type guard de TS)
        if (toolCall.type !== 'function') continue;

        console.log(`[MCP Tool Exec] ${toolCall.function.name}(${toolCall.function.arguments})`);

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

        // Devolvemos el resultado al contexto del modelo
        messages.push({
          role: 'tool',
          tool_call_id: toolCall.id,
          content: typeof toolOutput === 'string' ? toolOutput : JSON.stringify(toolOutput),
        });
      }

      // Segunda llamada tras resolver las tools
      response = await ujiClient.chat.completions.create({
        model: UJI_MODEL,
        temperature: 0.1,
        messages,
      });

      choice = response.choices[0];
    }

    const outputText = choice?.message?.content || '';
    const jsonStr = outputText.replace(/<think>[\s\S]*?<\/think>/gi, '').trim();

    console.log(`\n--- [RESPOSTA BRUTA DEL MODEL UJI ${UJI_MODEL}] ---`);
    console.log(jsonStr || '(Sense errades)');
    console.log('--------------------------------------');
    console.log('Tokens:', response.usage);
    console.log(`[OpenAI-UJI] Temps: ${Date.now() - tStart}ms\n`);

    const lines = jsonStr.split('\n');
    const errors: DetectedError[] = [];

    for (const line of lines) {
      const trimmedLine = line.trim();
      if (!trimmedLine) continue;

      const match = trimmedLine.match(ERROR_PATTERN);
      if (!match) continue;

      const [, errText, corrText, category, tip] = match;
      const cleanErr = errText.trim();
      const cleanCorr = corrText.trim();

      if (cleanErr.toLowerCase() === cleanCorr.toLowerCase()) continue;

      errors.push({
        error_text: cleanErr,
        correction: cleanCorr,
        category: category.trim(),
        explanation: tip.trim(),
      });
    }

    return errors;
  } catch (error: any) {
    console.error('[OpenAI-UJI] Error consultando el modelo:', error.message);
    return [];
  }
}