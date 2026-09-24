import OpenAI from 'openai';
import { Client } from '@modelcontextprotocol/sdk/client/index.js';
import { StdioClientTransport } from '@modelcontextprotocol/sdk/client/stdio.js';
import type {
  ChatCompletionMessageParam,
  ChatCompletionTool,
} from 'openai/resources/chat/completions';
import { z } from 'zod';
import { zodResponseFormat } from 'openai/helpers/zod';

// Variables de entorno
const UJI_HOST = process.env.UJI_HOST;
const UJI_MODEL = process.env.UJI_LLM_MODEL || 'qwen2.5:32b';
const MCP_SERVER_SCRIPT = process.env.MCPDETECTOR_SERVER_PATH || './mcp/ErrorDetector/index.js';
const MODEL_NAME = process.env.OPENAI_MODEL || 'gpt-4o';
// 1. Cliente OpenAI persistente
const ujiClient = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
  maxRetries: 1,
  timeout: 60_000,
});


// 1. Cliente OpenAI persistente
//const ujiClient = new OpenAI({
//  baseURL: `${UJI_HOST}/v1`,
//  apiKey: 'not-needed-uji',
//  maxRetries: 1,
//  timeout: 60_000,
//});

// 2. Cliente MCP (Lazy connection)
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

  const { tools } = await mcpClient.listTools();
  cachedTools = tools.map((tool) => {
    const originalSchema = (tool.inputSchema as Record<string, any>) || {};
    const props = originalSchema.properties || {};

    // Per a strict: true en OpenAI, 'required' ha de contindre TOTS els camps de properties
    const strictParameters = {
      type: 'object',
      properties: props,
      required: Object.keys(props), // <-- Força sempre totes les claus
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
// DEFINICIÓN DE ESQUEMA Y TIPOS INFERIDOS (Evita error ts(2322))
// -------------------------------------------------------------
export const ErrorCategoryEnum = z.enum([
  'accentuació',
  'apostrofació',
  'concordança',
  'morfologia',
  'sintaxi',
  'lèxic',
  'preposicions',
  'pronoms',
  'ortografia',
  'altres',
]);

export type ErrorCategory = z.infer<typeof ErrorCategoryEnum>;

export const DetectedErrorSchema = z.object({
  error_text: z.string().describe('El fragment erroni original.'),
  correction: z.string().describe('La correcció proposada segons la normativa AVL.'),
  category: ErrorCategoryEnum.describe("La categoria lingüística de l'error."),
  explanation: z.string().describe('Explicació succinta de la regla gramatical aplicada.'),
});

export const CorrectionResultSchema = z.object({
  errors: z.array(DetectedErrorSchema).describe("Llista d'errades trobades. Buida si el text és correcte."),
});

// Tipo TypeScript exportado directamente desde el validador Zod
export type DetectedError = z.infer<typeof DetectedErrorSchema>;
export type CorrectionResult = z.infer<typeof CorrectionResultSchema>;

export const SYSTEM_PROMPT_AVL = `Ets un auditor lingüístic d'elit especialitzat exclusivament en la normativa de l'Acadèmia Valenciana de la Llengua (AVL). 

La teua missió és aconseguir la perfecció absoluta en cada text: detectar tant el «subratllat roig» (ortografia, grafies impròpies, lèxic no admés) com el «subratllat blau» (calcos sintàctics de l'espanyol, redoblament incorrecte de pronoms, règim preposicional, concordança, falsos amics i cohesió textual). No pots passar per alt CAP DETALL, per mínim que siga.

Tingues en compte que la rapidesa és secundària: pren-te tot el temps necessari per a analitzar cada racó de l'oració i assegurar una efectivitat total.

==================================================
FERRAMENTES DISPONIBLES:
==================================================
1. 'consultar_dnv': L'autoritat màxima lexicogràfica. Consulta-la de manera obligatòria davant qualsevol dubte lèxic, morfològic o ortogràfic.
2. 'softvalencia': Motor de verificació creuada de concordança, morfologia i patrons d'estil genuí.
3. 'apertium': Suport per a desambiguació morfològica i anàlisi de categories gramaticals.

==================================================
PROTOCOL OBLIGATORI D'AUDITORIA PAS A PAS:
==================================================

FASE 1: DESPIECE I COMPROVACIÓ LÈXICA (TOLERÀNCIA ZERO)
- Analitza cada terme de la frase de manera aïllada.
- Si una paraula NO estàs al 100% segur que és normativa segons l'AVL, o si presenta qualsevol indici de castellanisme (ex: arrels estranyes, sufixos dubtosos, grafies no valencianes com 'ch' final, 'k', 'j/g' dubtoses, etc.), invoca 'consultar_dnv'.
- Si la paraula remet a una altra forma principal o apareix com a no normativa, aplica la substitució pel terme formal i genuí fixat per l'AVL.

FASE 2: ANÀLISI DE SINTAGMES I COL·LOCACIONS (COMBINATÒRIA CONTEXTUAL)
- Molt important: analitza la combinació de 2, 3 o més paraules consecutives. Recorda que paraules que per separat són 100% vàlides poden:
  * Generar una expressió sense sentit, redundant o incoherent en valencià.
  * Formar un calc sintàctic o fraseològic ocult (ex: 'donar-se conte', 'tindre que', 'fer front a', 'a mida que' en lloc de 'a mesura que', 'portar a terme' quan convé 'dur a terme', etc.).
  * Xocar per incompatibilitat de règim verbal o preposicional.
- Desmunta qualsevol combinació espúria i substitueix-la per la fórmula genuïna i natural en valencià formal.

FASE 3: CONSTRUCCIÓ I TEST EN 'SOFTVALENCIA'
- Amb el lèxic i les combinacions ja depurades, munta la proposta de frase resolent:
  * Pronoms febles (ordre, combinatòria, apostrofació i eliminació de redoblaments pleonàstics incorrectes).
  * Perífrasis d'obligació genuïnes ('haver de' en compte de 'tindre que').
  * Preposicions i règims verbals estrictes.
- Executa 'softvalencia' enviant la frase completa per a validar la concordança i la integració sintàctica.

FASE 4: BUCLE D'AUDITORIA PROFUNDA (SENTIT, COHESIÓ I RE-VALIDACIÓ)
- Analitza críticament el resultat tornat per 'softvalencia':
  * Té sentit lògic profund i naturalitat expressiva pròpia del valencià culte?
  * S'han produït falsos positius o adaptacions que desvirtuen el sentit original?
  * Persistix algun calc semàntic o sintàctic subtil?
- SI DETECTES QUALSEVOL MANCA DE SENTIT, FRASE FORÇADA O DETALL IMPERFECTE:
  1. Modifica la redacció per a fer-la impecable.
  2. TORNA a passar la nova frase resultant per 'softvalencia'.
  3. Repetix este bucle fins que la frase supere simultàniament el test del filtre i el teu propi criteri d'excel·lència.

==================================================
CRITERIS INNEGOCIABLES D'ESTIL AVL:
==================================================
- Morfologia verbal genuïna (formes d'indicatiu i subjuntiu normatives valencianes: 'tingueren', 'hagen', etc.).
- Absència total de pleonasmes pronominals davant complements indirectes en posició postverbal ('va demanar al seu amic', MAI 'li va demanar al seu amic').
- Grafia i accentuació estricta (accents oberts/tancats segons la fonètica i norma de l'AVL).
- Col·locacions i locucions genuïnes sobre calcos literals de l'espanyol.

==================================================
EIXIDA:
==================================================
Genera directament l'eixida estructurada en JSON segons l'esquema requerit, sense preàmbuls ni texts meta-comunicatius.`


export async function analyzeErrorsWithLocalLLM(content: string): Promise<DetectedError[]> {
  const trimmed = content.trim();
  if (!trimmed) return [];

  const tStart = Date.now();

  try {
    const { client: mcp, tools } = await getMcpTools();

    const messages: ChatCompletionMessageParam[] = [
      { role: 'system', content: SYSTEM_PROMPT_AVL },
      { role: 'user', content: `Analitza lingüísticament el text següent:\n"${trimmed}"` },
    ];

    // Configuración compartida con tools y response_format simultáneos
    const responseFormat = zodResponseFormat(CorrectionResultSchema, 'correction_result');
    const toolsConfig = tools.length > 0 ? tools : undefined;

    // 1. Invocación única: el modelo recibe el esquema forzado y las tools al mismo tiempo
    let response = await ujiClient.chat.completions.parse({
      model: MODEL_NAME,
      messages,
      tools: toolsConfig,
      response_format: responseFormat,
      reasoning_effort: 'none', // Obligatori per a usar tools amb gpt-6-luna en /v1/chat/completions
    });

    let choice = response.choices[0];

    // 2. Bucle de resolución de tools (solo se activa si el modelo decide llamar a una herramienta)
    while (choice?.message?.tool_calls && choice.message.tool_calls.length > 0) {
      messages.push(choice.message);

      for (const toolCall of choice.message.tool_calls) {
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

        messages.push({
          role: 'tool',
          tool_call_id: toolCall.id,
          content: typeof toolOutput === 'string' ? toolOutput : JSON.stringify(toolOutput),
        });
      }

      // Siguiente llamada manteniendo tools y response_format activos
      response = await ujiClient.chat.completions.parse({
        model: MODEL_NAME,
        messages,
        tools: toolsConfig,
        response_format: responseFormat,
        reasoning_effort: 'none', // Obligatori per a usar tools amb gpt-6-luna en /v1/chat/completions

      });

      choice = response.choices[0];
    }

    const parsedResult = choice?.message?.parsed;

    console.log(`[OpenAI-UJI] Temps total: ${Date.now() - tStart}ms`);

    if (!parsedResult?.errors) return [];

    // Filtro de cambios idénticos garantizando compatibilidad de tipos
    return parsedResult.errors.filter(
      (err: DetectedError) => err.error_text.trim().toLowerCase() !== err.correction.trim().toLowerCase()
    );
  } catch (error: any) {
    console.error('[OpenAI-UJI] Error processant resposta estructurada:', error.message);
    return [];
  }
}