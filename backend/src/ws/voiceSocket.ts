import { WebSocketServer, type WebSocket } from 'ws';
import type { IncomingMessage, Server } from 'node:http';
import { z } from 'zod';
import { getAdmin } from '../middleware/auth.js';
import { replyFromAgentStream, type AgentReply } from '../services/agent.js';
import { stt, tts, type SpeechAudio } from '../services/voice.js';
import { pcm16ToWav } from '../services/wav.js';
import { SCENARIO_XP, VOICE_BY_SCENARIO } from '../services/voices.js';
import type { ScenarioKey } from '../scenarios/types.js';

const PCM_SAMPLE_RATE = 16000;
const MIN_UTTERANCE_BYTES = Math.round(PCM_SAMPLE_RATE * 2 * 0.3); // 300 ms
const MAX_UTTERANCE_BYTES = PCM_SAMPLE_RATE * 2 * 45; // 45 s
const MAX_PARALLEL_TTS = 2; // síntesi simultània sense saturar el servidor Matxa

const startSchema = z.object({
  type: z.literal('start'),
  session_id: z.string().uuid(),
  scenario: z.enum(['mercat', 'bar', 'oficina', 'ajuntament', 'colegi', 'turisme']),
  level: z.enum(['principiant', 'intermedi', 'avancat']),
  voice: z.string().min(1).max(50).optional(),
  history: z.array(z.object({
    role: z.enum(['user', 'character']),
    content_text: z.string().max(2000),
  })).max(50).optional().default([]),
});

interface HistoryMessage { role: 'user' | 'character'; content_text: string }

interface ConnectionState {
  ws: WebSocket;
  userId: string;
  sessionId: string | null;
  scenario: ScenarioKey | null;
  level: string;
  voice: string | undefined;
  history: HistoryMessage[];
  turnCounter: number;
  abort: AbortController | null;
  queue: Promise<void>;
  closed: boolean;
}

/**
 * Conversa de veu en temps real (Camino A): el navegador envia el PCM de cada
 * intervenció detectada amb VAD per WebSocket; el servidor transcriu (Matxa
 * STT), genera la resposta en streaming (OpenAI) i sintetitza frase a frase
 * (Matxa TTS), enviant cada àudio en ordre. El client pot interrompre amb
 * barge_in mentre el personatge parla.
 */
export function attachVoiceSocket(server: Server): void {
  const wss = new WebSocketServer({ noServer: true });
  server.on('upgrade', (request, socket, head) => {
    const url = new URL(request.url ?? '/', 'http://localhost');
    if (url.pathname !== '/api/voice') return;
    if (!originAllowed(request.headers.origin)) {
      socket.write('HTTP/1.1 403 Forbidden\r\n\r\n');
      socket.destroy();
      return;
    }
    wss.handleUpgrade(request, socket, head, (ws) => {
      void handleConnection(ws, request).catch((error) => {
        console.error('[voice] connexió fallida:', error instanceof Error ? error.message : error);
        try { ws.close(); } catch { /* ja tancat */ }
      });
    });
  });
}

function originAllowed(origin?: string): boolean {
  if (!origin) return true; // curl / proves sense navegador
  if (/^https?:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/.test(origin)) return true;
  return (process.env.FRONTEND_ORIGIN?.split(',') || []).includes(origin);
}

/** Mateixa política que requireAuth: sense token o invàlid → usuari demo. */
async function resolveUserId(request: IncomingMessage): Promise<string> {
  const url = new URL(request.url ?? '/', 'http://localhost');
  const token = url.searchParams.get('token');
  if (!token) return 'demo-user';
  const client = getAdmin();
  if (!client) return 'demo-user';
  const { data } = await client.auth.getUser(token);
  return data?.user?.id ?? 'demo-user';
}

async function handleConnection(ws: WebSocket, request: IncomingMessage): Promise<void> {
  const userId = await resolveUserId(request);
  const state: ConnectionState = {
    ws,
    userId,
    sessionId: null,
    scenario: null,
    level: 'principiant',
    voice: undefined,
    history: [],
    turnCounter: 0,
    abort: null,
    queue: Promise.resolve(),
    closed: false,
  };

  ws.on('message', (data: Buffer, isBinary: boolean) => {
    if (state.closed) return;
    if (isBinary) {
      enqueueUtterance(state, data);
      return;
    }
    try {
      const message = JSON.parse(data.toString('utf8')) as { type?: string };
      if (message.type === 'start') void applyStart(state, data.toString('utf8'));
      else if (message.type === 'barge_in') state.abort?.abort();
    } catch {
      // Missatge de control invàlid: s'ignora.
    }
  });

  ws.on('close', () => {
    state.closed = true;
    state.abort?.abort();
  });
  ws.on('error', () => {
    state.closed = true;
    state.abort?.abort();
  });
}

/** Encola una intervenció (PCM 16 kHz 16 bits mono) rebuda del navegador. */
function enqueueUtterance(state: ConnectionState, pcm: Buffer): void {
  const trimmed = pcm.length > MAX_UTTERANCE_BYTES ? pcm.subarray(0, MAX_UTTERANCE_BYTES) : pcm;
  if (trimmed.length < MIN_UTTERANCE_BYTES) return; // massa curt: soroll
  state.queue = state.queue
    .then(() => runTurn(state, Buffer.from(trimmed)))
    .catch((error) => {
      console.error('[voice] torn fallit:', error instanceof Error ? error.message : error);
      sendJson(state, { type: 'error', turn: state.turnCounter, error: 'turn_failed' });
    });
}

async function applyStart(state: ConnectionState, raw: string): Promise<void> {
  let parsedJson: unknown;
  try {
    parsedJson = JSON.parse(raw);
  } catch {
    sendJson(state, { type: 'error', turn: 0, error: 'start_invalid' });
    return;
  }
  const parsed = startSchema.safeParse(parsedJson);
  if (!parsed.success) {
    sendJson(state, { type: 'error', turn: 0, error: 'start_invalid' });
    return;
  }
  const data = parsed.data;
  state.scenario = data.scenario;
  state.level = data.level;
  state.voice = data.voice ?? VOICE_BY_SCENARIO[data.scenario];
  state.history = data.history.map((m) => ({ role: m.role, content_text: m.content_text }));
  state.sessionId = data.session_id;

  // Validació de sessió idèntica a /api/turn (es salta en mode demo).
  const client: any = state.userId === 'demo-user' ? null : getAdmin();
  if (client) {
    const { data: session } = await client
      .from('conversation_sessions')
      .select('id,user_id,scenario')
      .eq('id', data.session_id)
      .single();
    if (!session || session.user_id !== state.userId || session.scenario !== data.scenario) {
      sendJson(state, { type: 'error', turn: 0, error: 'sessio_invalida' });
      try { state.ws.close(1008, 'Sessió no vàlida'); } catch { /* ja tancat */ }
      state.closed = true;
      return;
    }
  }
  sendJson(state, { type: 'ready', turn: 0 });
}

async function runTurn(state: ConnectionState, pcm: Buffer): Promise<void> {
  if (state.closed || !state.sessionId || !state.scenario) return;
  state.turnCounter += 1;
  const turn = state.turnCounter;
  const abort = new AbortController();
  state.abort = abort;
  try {
    const wav = pcm16ToWav(pcm, PCM_SAMPLE_RATE);
    const transcript = await stt.transcribe(wav, 'audio/wav');
    if (abort.signal.aborted) return;
    sendJson(state, { type: 'transcript', turn, text: transcript });

    let reply: AgentReply | null = null;
    // TTS amb concurrència limitada però enviament en ordre: mentre el model
    // continua generant, ja sintetitzem les frases següents.
    const sentences: string[] = [];
    const audioPromises: (Promise<SpeechAudio | null> | null)[] = [];
    let started = 0;
    let inFlight = 0;
    let nextToSend = 0;
    let drainRunning = false;

    const startPending = (): void => {
      while (inFlight < MAX_PARALLEL_TTS && started < sentences.length) {
        const promise = tts.synthesize(sentences[started], state.voice);
        audioPromises[started] = promise.finally(() => { inFlight -= 1; });
        started += 1;
        inFlight += 1;
      }
    };

    const sendReady = async (): Promise<void> => {
      while (nextToSend < started) {
        if (abort.signal.aborted) return;
        const audio = await audioPromises[nextToSend];
        if (abort.signal.aborted) return;
        if (audio) sendAudio(state, turn, nextToSend, sentences[nextToSend], audio);
        nextToSend += 1;
        startPending();
      }
    };

    try {
      for await (const event of replyFromAgentStream(
        { scenario: state.scenario, level: state.level, message: transcript, history: state.history },
        { signal: abort.signal },
      )) {
        if (event.type === 'sentence') {
          if (abort.signal.aborted) break;
          sentences.push(event.text);
          audioPromises.push(null);
          startPending();
          if (!drainRunning) {
            drainRunning = true;
            void sendReady().finally(() => { drainRunning = false; });
          }
        } else {
          reply = event.reply;
        }
      }
      // El generador ha acabat: drena els TTS pendents en ordre reutilitzant el
      // mateix runner (el guard drainRunning evita dobles enviaments).
      startPending();
      while (!abort.signal.aborted && nextToSend < sentences.length) {
        if (!drainRunning) {
          drainRunning = true;
          void sendReady().finally(() => { drainRunning = false; });
        }
        await new Promise((resolve) => setTimeout(resolve, 25));
      }
    } catch (error) {
      if (!abort.signal.aborted) throw error;
    }
    if (abort.signal.aborted) {
      // Barge-in: si ja s'ha arribat a parlar alguna cosa, es conserva al
      // context (sense XP) perquè el personatge no perda el fil.
      if (reply) {
        state.history.push({ role: 'user', content_text: transcript }, { role: 'character', content_text: reply.reply_text });
        await persistTurn(state, transcript, reply, 0);
      }
      return;
    }
    if (!reply) throw new Error('El model no ha retornat resposta');

    state.history.push({ role: 'user', content_text: transcript }, { role: 'character', content_text: reply.reply_text });
    sendJson(state, { type: 'done', turn, reply_text: reply.reply_text, mood: reply.mood, xp_delta: SCENARIO_XP, interrupted: false });
    await persistTurn(state, transcript, reply, SCENARIO_XP);
  } finally {
    if (state.abort === abort) state.abort = null;
  }
}

/** Persistència d'un torn: igual que /api/turn (es salta en mode demo). */
async function persistTurn(state: ConnectionState, transcript: string, reply: AgentReply, xpDelta: number): Promise<void> {
  const client: any = state.userId === 'demo-user' ? null : getAdmin();
  if (!client || !state.sessionId || !state.scenario) return;
  try {
    await client.from('conversation_messages').insert([
      {
        session_id: state.sessionId,
        role: 'user',
        content_text: transcript,
        input_mode: 'voice',
        detected_level_signal: reply.detected_level_signal,
        error_flags: reply.error_flags,
      },
      {
        session_id: state.sessionId,
        role: 'character',
        content_text: reply.reply_text,
        input_mode: 'text',
      },
    ]);
    if (xpDelta > 0) {
      await client.rpc('apply_turn_xp', {
        p_user_id: state.userId,
        p_session_id: state.sessionId,
        p_scenario: state.scenario,
        p_xp_delta: xpDelta,
        p_threshold: SCENARIO_XP,
      });
    }
  } catch (error) {
    console.error('[voice] persistència fallida:', error instanceof Error ? error.message : error);
  }
}

function sendJson(state: ConnectionState, payload: Record<string, unknown>): void {
  if (state.closed || state.ws.readyState !== state.ws.OPEN) return;
  state.ws.send(JSON.stringify(payload));
}

function sendAudio(state: ConnectionState, turn: number, index: number, text: string, audio: { audio: Buffer; mimeType: string }): void {
  if (state.closed) return;
  try {
    sendJson(state, { type: 'audio', turn, index, text, mime: audio.mimeType });
    state.ws.send(audio.audio);
  } catch (error) {
    console.error('[voice] enviament d\'àudio fallit:', error instanceof Error ? error.message : error);
  }
}
