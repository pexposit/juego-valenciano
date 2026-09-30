

import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { z } from 'zod';
import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

dotenv.config();

// Inicialització del client Supabase
const supabase = createClient(
  process.env.SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
);

const server = new McpServer({
  name: 'valencian-tutor-db',
  version: '1.0.0',
});

// Eina 1: Obtenir errors pendents del recurs que s'acaba de tancar
server.registerTool(
  'get_unresolved_errors',
  {
    description: "Obté la llista d'errors pendents (resolved = false) del recurs de sessió (session_resource) que s'està avaluant.",
    inputSchema: z.object({
      sessionResourceId: z.string().uuid().describe("UUID del session_resource (recurs concret) que s'acaba de tancar."),
      limit: z.number().int().default(30).describe('Límit màxim a consultar.'),
    }),
  },
  async ({ sessionResourceId, limit }) => {
    const { data, error } = await supabase
      .from('user_errors')
      .select('id, error_text, correction, category, explanation')
      .eq('session_resource_id', sessionResourceId)
      .eq('resolved', false)
      .order('id', { ascending: false })
      .limit(limit);

    if (error) {
      return {
        content: [{ type: 'text' as const, text: `Error de Supabase: ${error.message}` }],
        isError: true,
      };
    }

    if (!data || data.length === 0) {
      return {
        content: [{ type: 'text' as const, text: "L'usuari no té cap error pendent." }],
      };
    }

    return {
      content: [{ type: 'text' as const, text: JSON.stringify(data, null, 2) }],
    };
  }
);

// Eina 2: Obtenir avaluacions recents (les últimes 4)
server.registerTool(
  'get_recent_evaluations',
  {
    description: "Obté les darreres avaluacions o informes diagnòstics de l'usuari.",
    inputSchema: z.object({
      userId: z.string().uuid().describe("UUID de l'usuari."),
      limit: z.number().int().default(4).describe("Nombre d'avaluacions a recuperar."),
    }),
  },
  async ({ userId, limit }) => {
    const { data, error } = await supabase
      .from('user_evaluations')
      .select('id, summary, weaknesses, priority_focus, created_at')
      .eq('user_id', userId)
      .order('created_at', { ascending: false })
      .limit(limit);

    if (error) {
      return {
        content: [{ type: 'text' as const, text: `Error de Supabase: ${error.message}` }],
        isError: true,
      };
    }

    if (!data || data.length === 0) {
      return {
        content: [{ type: 'text' as const, text: "L'usuari no té avaluacions prèvies." }],
      };
    }

    return {
      content: [{ type: 'text' as const, text: JSON.stringify(data, null, 2) }],
    };
  }
);

// Eina 3: Guardar el nou informe diagnòstic
server.registerTool(
  'save_user_evaluation',
  {
    description: "Guarda un nou informe diagnòstic d'avaluació emés pel revisor per al recurs que s'acaba de tancar.",
    inputSchema: z.object({
      userId: z.string().uuid().describe("UUID de l'usuari."),
      sessionResourceId: z.string().uuid().describe("UUID del session_resource (recurs concret) avaluat."),
      summary: z.string().describe("Resum qualitatiu de l'estat de l'alumne."),
      weaknesses: z.array(z.string()).describe('Llista de conceptes clau que cal reforçar.'),
      priorityFocus: z.string().describe('Concepte prioritari per a la següent ruta.'),
    }),
  },
  async ({ userId, sessionResourceId, summary, weaknesses, priorityFocus }) => {
    const { data, error } = await supabase
      .from('user_evaluations')
      .insert({
        user_id: userId,
        session_resource_id: sessionResourceId,
        summary: summary,
        weaknesses: weaknesses,
        priority_focus: priorityFocus,
      })
      .select('id, created_at')
      .single();

    if (error) {
      return {
        content: [{ type: 'text' as const, text: `Error en guardar l'avaluació: ${error.message}` }],
        isError: true,
      };
    }

    return {
      content: [
        {
          type: 'text' as const,
          text: `Avaluació guardada amb èxit. ID: ${data.id} (${data.created_at})`,
        },
      ],
    };
  }
);

async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error('[MCP DB] Servidor Supabase funcionant sobre stdio.');
}

main().catch((err) => {
  console.error('[MCP DB] Error fatal:', err);
  process.exit(1);
});
