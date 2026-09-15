import { Router } from 'express';
import { z } from 'zod';
import {
  HISTORY_MAX_MESSAGES,
  SCENARIO_XP,
  VOICE_BY_SCENARIO,
  sanitizeHistory,
  type HistoryMessage,
} from '@parlaval/shared';
import { requireAuth, type AuthRequest } from '../middleware/auth.js';
import { db } from '../db.js';
import { validationError } from '../validation.js';
import { turnSchema } from '../schemas.js';
import { replyFromAgent } from '../services/agent.js';
import { stt, tts } from '../services/voice.js';

export const turnRouter = Router();

turnRouter.post('/api/turn', requireAuth, async (req: AuthRequest, res) => {
  try {
    const data = turnSchema.parse(req.body);
    let text = data.text.trim();
    const startedAt = Date.now();

    if (data.input_mode === 'voice') {
      if (!data.audio_base64) return res.status(400).json({ error: 'Falta l\'àudio' });
      const sttStart = Date.now();
      text = await stt.transcribe(Buffer.from(data.audio_base64, 'base64'), 'audio/webm');
      console.log(`[turn] stt=${Date.now() - sttStart}ms`);
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

    // El historial enviado por el cliente NO es de confianza (un cliente
    // malicioso podría inventarlo para manipular al agente o inflar tokens):
    // - Con usuario real (hay BD y la sesión ya se validó) se reconstruye
    //   siempre desde `conversation_messages`, la fuente verificada.
    // - En modo demo (sin BD) se acepta el del cliente, pero pasa por
    //   `sanitizeHistory`, que recorta al presupuesto de mensajes y
    //   caracteres definido en el paquete compartido.
    let history: HistoryMessage[];
    if (client) {
      const { data: historyData } = await client
        .from('conversation_messages')
        .select('role,content_text')
        .eq('session_id', data.session_id)
        .order('created_at', { ascending: false })
        .limit(HISTORY_MAX_MESSAGES);
      history = sanitizeHistory(((historyData || []).reverse()) as HistoryMessage[]);
    } else {
      history = sanitizeHistory(data.history);
    }

    const agentStart = Date.now();
    const reply = await replyFromAgent({
      scenario: data.scenario,
      level: data.level,
      message: text,
      history,
    });
    console.log(`[turn] agente=${Date.now() - agentStart}ms`);

    const xpDelta = 10;

    // La persistencia y el TTS corren en paralelo: el audio no depende de la BD.
    const persistPromise = client
      ? (async () => {
          const dbStart = Date.now();
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
          console.log(`[turn] db=${Date.now() - dbStart}ms`);
        })()
      : Promise.resolve();

    const wantsAudio = data.include_audio;
    const ttsStart = Date.now();
    const [audio] = await Promise.all([
      wantsAudio
        ? tts.synthesize(reply.reply_text, VOICE_BY_SCENARIO[data.scenario])
        : Promise.resolve(null),
      persistPromise,
    ]);
    console.log(
      `[turn] tts=${wantsAudio ? Date.now() - ttsStart : 0}ms total=${Date.now() - startedAt}ms`,
    );

    res.json({
      ...reply,
      transcription: data.input_mode === 'voice' ? text : null,
      reply_audio_base64: audio?.audio.toString('base64') || null,
      reply_audio_mime_type: audio?.mimeType || null,
      xp_delta: xpDelta,
    });
  } catch (error) {
    if (error instanceof z.ZodError) return validationError(res, error);
    console.error(error);
    res.status(500).json({ error: 'No hem pogut processar el torn' });
  }
});
