import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { z } from 'zod';
import { consultarDnv } from './dnvClient.js';
import { consultarConjugacio } from './dnvConjugacio.js';
import { traduirApertium } from './apertiumClient.js';
import { corregirSoftvalencia } from './softvalenciaClient.js';

// Un servidor per petició (el transport HTTP és sense estat): cada crida a /mcp en crea un de nou amb les 4 ferramentes.
export function createServer(): McpServer {
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

    // El portal torna l'entrada més pròxima per a una paraula que no hi és: no és cap confirmació.
    if (resultat.exacta === false) {
      return {
        content: [
          {
            type: 'text',
            text: [
              `El DNV no té una entrada exacta per a "${paraula}": l'entrada més pròxima és «${resultat.lema}»${resultat.variants?.length ? ` (admet també: ${resultat.variants.join(', ')})` : ''}.`,
              `Això NO confirma que "${paraula}" siga normativa (pot ser una errada d'escriptura) ni que siga errada: pot ser una forma flexionada (plural, femení, conjugació) que el diccionari no llista com a entrada. Decidix amb la morfologia i la norma, i no la marques com a error només per este resultat.`,
              `Font oficial: ${resultat.url}`,
            ].join('\n'),
          },
        ],
      };
    }

    const info = [
      `NORMATIVA CONFIRMADA: "${paraula}" ÉS una forma vàlida en el DNV de l'AVL${resultat.lema && resultat.lema.toLowerCase() !== paraula.trim().toLowerCase() ? ` (variant admesa de «${resultat.lema}»)` : ''}.`,
      resultat.variants?.length ? `Variants admeses: ${[resultat.lema, ...resultat.variants].join(', ')}. Cap d'elles és una errada.` : null,
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

// Eina 4: Conjugació verbal del DNV
server.registerTool(
  'consultar_conjugacio',
  {
    description:
      "Obté la conjugació completa d'un verb segons el Diccionari Normatiu Valencià (DNV) de l'AVL. Útil per a comprovar si una forma verbal és normativa.",
    inputSchema: z.object({
      verb: z
        .string()
        .describe('Verb en infinitiu, sense pronoms (ex: "anar", "cantar", "rentar").'),
    }),
    // A més del text per al LLM, la taula estructurada: el tutor del xat la mostra a l'aprenent.
    outputSchema: z.object({
      existeix: z.boolean(),
      modes: z.record(z.record(z.array(z.string()))).optional(),
      observacions: z.array(z.string()).optional(),
      url: z.string(),
    }),
  },
  async ({ verb }) => {
    const resultat = await consultarConjugacio(verb);

    if (!resultat.existeix || !resultat.modes) {
      return {
        content: [
          {
            type: 'text' as const,
            text: `No s'ha trobat la conjugació de "${verb}" al DNV. Comprova que siga un verb en infinitiu i sense pronoms.`,
          },
        ],
        structuredContent: { ...resultat },
      };
    }

    const seccions = Object.entries(resultat.modes).map(([mode, temps]) => {
      const linies = Object.entries(temps).map(
        ([nomTemps, formes]) => `  ${nomTemps}: ${formes.filter(Boolean).join(', ')}`
      );
      return `${mode.toUpperCase()}\n${linies.join('\n')}`;
    });

    const info = [
      `CONJUGACIÓ DEL VERB "${verb}" (DNV):`,
      ...seccions,
      resultat.observacions && resultat.observacions.length > 0
        ? `Observacions: ${resultat.observacions.join(' ')}`
        : null,
      `Font oficial: ${resultat.url}`,
    ]
      .filter(Boolean)
      .join('\n\n');

    return {
      content: [
        {
          type: 'text' as const,
          text: info,
        },
      ],
      structuredContent: { ...resultat },
    };
  }
);

return server;
}
