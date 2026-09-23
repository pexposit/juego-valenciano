import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { z } from 'zod';
import { consultarDnv } from './dnvClient.js';
import { traduirApertium } from './apertiumClient.js';
import { corregirSoftvalencia } from './softvalenciaClient.js';

// 1. Instanciem el McpServer
const server = new McpServer({
  name: 'avl-valencia-mcp',
  version: '1.0.0',
});

// 2. Registrem la ferramenta amb la nova signatura registerTool()
server.registerTool(
  'consultar_dnv',
  {
    description:
      "Consulta oficial al Diccionari Normatiu Valencià (DNV) de l'AVL. Verifica si una paraula és normativa abans de marcar-la com a errada o castellanisme.",
    inputSchema: z.object({
      paraula: z
        .string()
        .describe('Paraula exacta en valencià a verificar (ex: "gitar", "guantera", "coche").'),
    }),
  },
  async ({ paraula }) => {
    const resultat = await consultarDnv(paraula);

    if (!resultat.existeix) {
      return {
        content: [
          {
            type: 'text',
            text: `La paraula "${paraula}" NO apareix al Diccionari Normatiu Valencià (DNV). Podria ser un castellanisme o una forma no normativa segons l'AVL.`,
          },
        ],
      };
    }

    const info = [
      `NORMATIVA CONFIRMADA: "${paraula}" ÉS una forma vàlida en el DNV de l'AVL.`,
      resultat.categoria ? `Categoria gramatical: ${resultat.categoria}` : null,
      resultat.definicions && resultat.definicions.length > 0
        ? `Definicions: ${resultat.definicions.join('; ')}`
        : null,
      `Font oficial: ${resultat.url}`,
    ]
      .filter(Boolean)
      .join('\n');

    return {
      content: [
        {
          type: 'text',
          text: info,
        },
      ],
    };
  }
);


// Eina 2: Apertium (Traducció exclusiva variant valenciana)
server.registerTool(
  'traduir_valencia_apertium',
  {
    description:
      "Tradueix text entre castellà i valencià utilitzant el diccionari específic de valencià normatiu (cat_valencia) d'Apertium.",
    inputSchema: z.object({
      text: z.string().describe('Text que es vol traduir.'),
      direccio: z
        .enum(['es_a_va', 'va_a_es'])
        .default('es_a_va')
        .describe("Direcció: 'es_a_va' (castellà a valencià) o 'va_a_es' (valencià a castellà)."),
    }),
  },
  async ({ text, direccio }) => {
    try {
      const res = await traduirApertium(text, direccio);
      return {
        content: [
          {
            type: 'text' as const,
            text: `Traducció (${res.direccio}):\n${res.traduccio}`,
          },
        ],
      };
    } catch (err) {
      return {
        content: [
          {
            type: 'text' as const,
            text: `Error en la traducció d'Apertium: ${err instanceof Error ? err.message : String(err)}`,
          },
        ],
      };
    }
  }
);

// Eina 3: Softvalencià (Corrector segons criteris AVL)
server.registerTool(
  'corregir_valencia_softvalencia',
  {
    description:
      "Corregeix ortografia, morfologia i gramàtica d'un text aplicant exclusivament els criteris de l'Acadèmia Valenciana de la Llengua (AVL).",
    inputSchema: z.object({
      text: z.string().describe('Text en valencià a analitzar i corregir.'),
    }),
  },
  async ({ text }) => {
    try {
      const res = await corregirSoftvalencia(text);

      if (res.esValid) {
        return {
          content: [
            {
              type: 'text' as const,
              text: "Text revisat: no s'ha trobat cap errada segons els criteris normatius de l'AVL.",
            },
          ],
        };
      }

      const llistaErrors = res.errors
        .map(
            (e, idx) =>
            `${idx + 1}. [${e.tipus}] a "${e.paraula}": ${e.missatge}\n   Suggeriments normatius: ${e.suggeriments.join(', ') || 'Cap'}`
        )
        .join('\n\n');

      return {
        content: [
          {
            type: 'text' as const,
            text: `S'han detectat ${res.errors.length} formes no normatives o errades segons l'AVL:\n\n${llistaErrors}`,
          },
        ],
      };
    } catch (err) {
      return {
        content: [
          {
            type: 'text' as const,
            text: `Error en la consulta a Softvalencià: ${err instanceof Error ? err.message : String(err)}`,
          },
        ],
      };
    }
  }
);















// 3. Connexió via StdioTransport
async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error('[MCP Server] Servidor DNV AVL funcionant sobre stdio');
}

main().catch((err) => {
  console.error('[MCP Server] Error fatal:', err);
  process.exit(1);
});