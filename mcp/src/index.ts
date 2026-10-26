import { createServer as createHttpServer, type IncomingMessage, type ServerResponse } from 'node:http';
import { timingSafeEqual } from 'node:crypto';
import { StreamableHTTPServerTransport } from '@modelcontextprotocol/sdk/server/streamableHttp.js';
import { createServer } from './server.js';

// Servidor MCP lingüístic (DNV, conjugació, Apertium i SoftValència) per HTTP. El backend el crida per la xarxa en lloc
// de llançar-lo per stdio: no té ports publicats en docker compose, només és accessible des de la xarxa interna.
//   POST /mcp    transport Streamable HTTP (sense estat: un servidor i un transport per petició)
//   GET  /health comprovació de salut
const PORT = Number(process.env.PORT) || 3002;
const AUTH_TOKEN = process.env.MCP_AUTH_TOKEN?.trim();
const MAX_BODY_BYTES = 1_000_000;

const json = (res: ServerResponse, status: number, body: unknown) => {
  res.writeHead(status, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify(body));
};
const rpcError = (res: ServerResponse, status: number, message: string) =>
  json(res, status, { jsonrpc: '2.0', error: { code: -32000, message }, id: null });

// Compara el token en temps constant.
function authorized(req: IncomingMessage): boolean {
  if (!AUTH_TOKEN) return true;
  const given = Buffer.from(req.headers.authorization ?? '');
  const wanted = Buffer.from(`Bearer ${AUTH_TOKEN}`);
  return given.length === wanted.length && timingSafeEqual(given, wanted);
}

async function readBody(req: IncomingMessage): Promise<unknown> {
  const chunks: Buffer[] = [];
  let size = 0;
  for await (const chunk of req) {
    size += (chunk as Buffer).length;
    if (size > MAX_BODY_BYTES) throw new Error('Cos massa gran');
    chunks.push(chunk as Buffer);
  }
  return JSON.parse(Buffer.concat(chunks).toString('utf8') || 'null');
}

const httpServer = createHttpServer(async (req, res) => {
  const path = (req.url ?? '').split('?')[0];
  if (path === '/health') return json(res, 200, { ok: true });
  if (path !== '/mcp') return json(res, 404, { error: 'No trobat' });
  if (!authorized(req)) return rpcError(res, 401, 'No autoritzat');
  if (req.method !== 'POST') return rpcError(res, 405, 'Només es admet POST');

  try {
    const body = await readBody(req);
    const server = createServer();
    const transport = new StreamableHTTPServerTransport({ sessionIdGenerator: undefined, enableJsonResponse: true });
    res.on('close', () => {
      void transport.close();
      void server.close();
    });
    await server.connect(transport);
    await transport.handleRequest(req, res, body);
  } catch (error) {
    console.error('[MCP Server] Error en la petició:', error instanceof Error ? error.message : error);
    if (!res.headersSent) rpcError(res, 500, 'Error intern del servidor MCP');
  }
});

httpServer.listen(PORT, () => {
  console.error(`[MCP Server] Servidor DNV AVL funcionant per HTTP al port ${PORT}${AUTH_TOKEN ? ' (amb token)' : ' (sense token)'}`);
});

for (const signal of ['SIGTERM', 'SIGINT'] as const) process.on(signal, () => httpServer.close(() => process.exit(0)));
