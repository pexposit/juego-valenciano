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
import { rateLimit } from '../middleware/rateLimit.js';
import { db } from '../db.js';
import { validationError } from '../validation.js';
import { turnSchema } from '../schemas.js';
import { replyFromAgent } from '../services/agent.js';
import { stt, tts } from '../services/voice.js';
import { analyzeErrorsWithLocalLLM } from '../services/subagentErrorDetector.js';

export const turnRouter = Router();

const TURN_RATE_LIMIT = {
  windowMs: 60_000,
  max: Number(process.env.RATE_LIMIT_AUTHED_PER_MIN) || 30,
  maxAnonymous: Number(process.env.RATE_LIMIT_ANON_PER_MIN) || 6,
};

turnRouter.post('/api/turn', requireAuth, rateLimit(TURN_RATE_LIMIT), async (req: AuthRequest, res) => {
  try {
    // 1. Asegúrate de que turnSchema acepte opcionalmente recurso_id
    // Si viene en el body: data.recurso_id
    const data = turnSchema.parse(req.body);
    let text = data.text.trim();
    const startedAt = Date.now();

    if (data.input_mode === 'voice') {
      if (!data.audio_base64) return res.status(400).json({ error: "Falta l'àudio" });
      const sttStart = Date.now();
      text = await stt.transcribe(Buffer.from(data.audio_base64, 'base64'), 'audio/webm');
      console.log(`[turn] stt=${Date.now() - sttStart}ms`);
    }
    if (!text) return res.status(400).json({ error: 'No hi ha cap missatge' });

    const client = db(req.userId);

    // 2. Validar que la sesión pertenece al usuario
    if (client) {
      const { data: session, error: sessionError } = await client
        .from('conversation_sessions') // Asegura el nombre correcto de la tabla
        .select('id, user_id')
        .eq('id', data.session_id)
        .eq('user_id', req.userId)
        .maybeSingle();

      if (sessionError || !session) {
        if (sessionError) console.warn('[turn] error consultant la sessió:', sessionError.message);
        return res.status(403).json({ error: 'Sessió no vàlida o no autoritzada' });
      }
    }

    // 3. Obtener historial filtrado por sesión (y opcionalmente por recurso_id si cada actividad tiene su hilo aislado)
    let history: HistoryMessage[];
    if (client) {
      let query = client
        .from('conversation_messages')
        .select('role, content_text')
        .eq('session_id', data.session_id);

      // Si quieres aislar el historial por actividad concreta dentro de la sesión:
      if ((data as any).recurso_id) {
        query = query.eq('recurso_id', (data as any).recurso_id);
      }

      const { data: historyData, error: historyError } = await query
        .order('created_at', { ascending: false })
        .limit(HISTORY_MAX_MESSAGES);

      if (historyError) console.error("[turn] no hem pogut llegir l'historial:", historyError.message);
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

    // Variable para guardar el ID del mensaje del usuario y enlazar los errores después
    let userMessageId: string | null = null;

    // 4. Persistencia en conversation_messages incluyendo recurso_id
    const persistPromise = client
      ? (async () => {
          const dbStart = Date.now();
          const recursoId = (data as any).recurso_id || null;

          // A. Insertamos el mensaje del usuario y recuperamos su ID
          const { data: userMsgInsert, error: userMsgError } = await client
            .from('conversation_messages')
            .insert({
              session_id: data.session_id,
              recurso_id: recursoId,
              role: 'user',
              content_text: text,
              input_mode: data.input_mode,
            })
            .select('id')
            .single();

          if (userMsgError) {
            console.error('[turn] Error guardant missatge d\'usuari:', userMsgError.message);
            return;
          }

          userMessageId = userMsgInsert.id;

          // B. Insertamos la respuesta del agente/personaje
          const { error: characterMsgError } = await client
            .from('conversation_messages')
            .insert({
              session_id: data.session_id,
              recurso_id: recursoId,
              role: 'character',
              content_text: reply.reply_text,
              input_mode: 'text',
            });

          if (characterMsgError) {
            console.error('[turn] Error guardant missatge de personatge:', characterMsgError.message);
          }

          // C. Aplicar XP
          const { error: xpError } = await client.rpc('apply_turn_xp', {
            p_user_id: req.userId,
            p_session_id: data.session_id,
            p_scenario: data.scenario,
            p_xp_delta: xpDelta,
            p_threshold: SCENARIO_XP,
          });

          if (xpError) {
            console.error('[turn] no hem pogut aplicar els XP:', xpError.message);
          }

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

    // 5. Análisis asíncrono de errores con LLM local vinculado a message_id
    if (client && req.userId) {
      const currentText = text;

      void (async () => {
        const start = Date.now();
        try {
          const detectedErrors = await analyzeErrorsWithLocalLLM(currentText);

          if (!detectedErrors || detectedErrors.length === 0) return;

          // Insertamos en user_errors con message_id tal como pide tu esquema
          const records = detectedErrors.map((item) => ({
            message_id: userMessageId, // Enlace con conversation_messages.id
            error_text: item.error_text,
            correction: item.correction,
            category: item.category,
            explanation: item.explanation,
            resolved: false,
          }));

          const { error: insertErr } = await client.from('user_errors').insert(records);
          if (insertErr) {
            console.error('[bgAnalysis] Error guardant a user_errors:', insertErr.message);
            return;
          }

          console.log(
            `[bgAnalysis] Guardats ${records.length} errors vinculats al missatge ${userMessageId} en ${Date.now() - start}ms`,
          );
        } catch (err: any) {
          console.error('[bgAnalysis] Error analitzant el missatge:', err.message);
        }
      })();
    }

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