import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import { z } from 'zod';
import { requireAuth, getAdmin, type AuthRequest } from './middleware/auth.js';
import { replyFromAgent } from './services/agent.js';
import { stt, tts } from './services/voice.js';

const app = express();
app.use(cors({
  origin: (origin, callback) => {
    // Allow requests with no origin (server-to-server, curl, etc.)
    if (!origin) return callback(null, true);
    // Allow any localhost origin (any port)
    if (/^https?:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/.test(origin)) return callback(null, true);
    // Allow explicitly configured origins
    const allowed = process.env.FRONTEND_ORIGIN?.split(',') || [];
    if (allowed.includes(origin)) return callback(null, true);
    callback(new Error('Not allowed by CORS'));
  },
}));
app.use(express.json({ limit: '12mb' }));

const turnSchema = z.object({
  session_id: z.string().uuid(),
  scenario: z.enum(['mercat', 'bar', 'oficina', 'ajuntament', 'colegi', 'turisme']),
  level: z.enum(['principiant', 'intermedi', 'avancat']),
  input_mode: z.enum(['text', 'voice']),
  text: z.string().max(2000).optional().default(''),
  audio_base64: z.string().nullable().optional(),
  // Historial de la conversación enviado por el cliente en tiempo real; permite
  // mantener el contexto del personaje también en modo demo (sin base de datos).
  history: z.array(z.object({
    role: z.enum(['user', 'character']),
    content_text: z.string().max(2000),
  })).max(50).optional().default([]),
});
const SCENARIO_XP = 100;
// Cada escenari té el seu personatge amb una veu TTS pròpia.
const VOICE_BY_SCENARIO: Record<'mercat' | 'bar' | 'oficina' | 'ajuntament' | 'colegi' | 'turisme', string> = {
  mercat: 'lluc',
  bar: 'gina',
  oficina: 'lluc',
  ajuntament: 'gina',
  colegi: 'gina',
  turisme: 'gina',
};

/** Helper to get the Supabase client cast to `any` so it works without generated types */
function db(userId?: string) {
  // Demo user: skip database operations
  if (userId === 'demo-user') return null;
  const client = getAdmin();
  if (!client) return null;
  return client as any;
}

app.get('/health', (_req, res) => res.json({ ok: true }));

// The first greeting must be audible even when the conversation provider is unavailable.
app.get('/api/greeting-audio', async (req, res) => {
  const scenario = typeof req.query.scenario === 'string' ? req.query.scenario : undefined;
  const voice = scenario && scenario in VOICE_BY_SCENARIO
    ? VOICE_BY_SCENARIO[scenario as keyof typeof VOICE_BY_SCENARIO]
    : undefined;
  const audio = await tts.synthesize('Bon dia! Com et puc ajudar hui?', voice);
  if (!audio) return res.status(503).json({ error: 'No hem pogut generar l’àudio' });
  res.json({
    audio_base64: audio.audio.toString('base64'),
    mime_type: audio.mimeType,
  });
});

app.post('/api/tts', async (req, res) => {
  const { text, scenario, voice } = z.object({
    text: z.string().min(1).max(500),
    scenario: z.enum(['mercat', 'bar', 'oficina', 'ajuntament', 'colegi', 'turisme']).optional(),
    voice: z.string().min(1).max(50).optional(),
  }).parse(req.body);
  const audio = await tts.synthesize(
    text,
    voice ?? (scenario ? VOICE_BY_SCENARIO[scenario] : undefined),
  );
  if (!audio) return res.status(503).json({ error: 'No hem pogut generar l’àudio' });
  res.json({
    audio_base64: audio.audio.toString('base64'),
    mime_type: audio.mimeType,
  });
});

app.post('/api/sessions', requireAuth, async (req: AuthRequest, res) => {
  try {
    const body = z.object({
      scenario: z.enum(['mercat', 'bar', 'oficina', 'ajuntament', 'colegi', 'turisme']),
      level: z.enum(['principiant', 'intermedi', 'avancat']),
    }).parse(req.body);

    const client = db(req.userId);
    if (!client) {
      // Demo mode: return a fake session
      return res.status(201).json({ session_id: crypto.randomUUID() });
    }

    const { data, error } = await client
      .from('conversation_sessions')
      .insert({ user_id: req.userId!, scenario: body.scenario, level_at_start: body.level })
      .select('id')
      .single();
    if (error) throw error;
    res.status(201).json({ session_id: data.id });
  } catch (error) {
    console.error(error);
    res.status(400).json({ error: 'No hem pogut iniciar la sessió' });
  }
});

app.post('/api/turn', requireAuth, async (req: AuthRequest, res) => {
  try {
    const data = turnSchema.parse(req.body);
    let text = data.text.trim();

    if (data.input_mode === 'voice') {
      if (!data.audio_base64) return res.status(400).json({ error: 'Falta l\'àudio' });
      text = await stt.transcribe(Buffer.from(data.audio_base64, 'base64'), 'audio/webm');
    }
    if (!text) return res.status(400).json({ error: 'No hi ha cap missatge' });

    const client = db(req.userId);

    // Validate session (skip in demo mode)
    if (client) {
      const { data: session } = await client
        .from('conversation_sessions')
        .select('id,user_id,scenario')
        .eq('id', data.session_id)
        .single();
      if (!session || session.user_id !== req.userId || session.scenario !== data.scenario) {
        return res.status(403).json({ error: 'Sessió no vàlida' });
      }
    }

    // Conversation context: prefer the history sent by the client (fresh and works
    // even in demo mode without database); fall back to the stored one otherwise.
    let history: { role: string; content_text: string }[] = data.history.map((m) => ({
      role: m.role,
      content_text: m.content_text,
    }));
    if (history.length === 0 && client) {
      const { data: historyData } = await client
        .from('conversation_messages')
        .select('role,content_text')
        .eq('session_id', data.session_id)
        .order('created_at', { ascending: false })
        .limit(12);
      history = (historyData || []).reverse();
    }

    const reply = await replyFromAgent({
      scenario: data.scenario,
      level: data.level,
      message: text,
      history,
    });

    const audio = await tts.synthesize(reply.reply_text, VOICE_BY_SCENARIO[data.scenario]);
    const xpDelta = 10;

    // Persist to database (skip in demo mode)
    if (client) {
      await client.from('conversation_messages').insert([
        {
          session_id: data.session_id,
          role: 'user',
          content_text: text,
          input_mode: data.input_mode,
          detected_level_signal: reply.detected_level_signal,
          error_flags: reply.error_flags,
        },
        {
          session_id: data.session_id,
          role: 'character',
          content_text: reply.reply_text,
          input_mode: 'text',
        },
      ]);
      await client.rpc('apply_turn_xp', {
        p_user_id: req.userId,
        p_session_id: data.session_id,
        p_scenario: data.scenario,
        p_xp_delta: xpDelta,
        p_threshold: SCENARIO_XP,
      });
    }

    res.json({
      ...reply,
      transcription: data.input_mode === 'voice' ? text : null,
      reply_audio_base64: audio?.audio.toString('base64') || null,
      reply_audio_mime_type: audio?.mimeType || null,
      xp_delta: xpDelta,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'No hem pogut processar el torn' });
  }
});

app.listen(Number(process.env.PORT) || 3001, () => console.log('ParlaVal agent listening'));
