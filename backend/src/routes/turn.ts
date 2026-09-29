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

    // 1. Validar la sessió amb conversation_sessions
    if (client) {
      const { data: session, error: sessionError } = await client
        .from('sessions')
        .select('id, user_id')
        .eq('id', data.session_id)
        .eq('user_id', req.userId!)
        .maybeSingle();

      if (sessionError || !session) {
        if (sessionError) console.warn('[turn] error consultant la sessió:', sessionError.message);
        return res.status(403).json({ error: 'Sessió no vàlida o no autoritzada' });
      }

      // El session_resource ha de pertànyer a eixa sessió
      const { data: sessionResource, error: sessionResourceError } = await client
        .from('session_resource')
        .select('id')
        .eq('id', data.session_resource_id)
        .eq('sesion_id', data.session_id)
        .maybeSingle();

      if (sessionResourceError || !sessionResource) {
        if (sessionResourceError) console.warn('[turn] error consultant el session_resource:', sessionResourceError.message);
        return res.status(403).json({ error: 'Recurs de sessió no vàlid o no autoritzat' });
      }
    }

    // 2. Historial aïllat per recurs
    let history: HistoryMessage[];
    if (client) {
      const { data: historyData, error: historyError } = await client
        .from('conversation_messages')
        .select('role, content_text')
        .eq('session_resource_id', data.session_resource_id)
        .order('created_at', { ascending: false })
        .limit(HISTORY_MAX_MESSAGES);

      if (historyError) {
        console.error("[turn] no hem pogut llegir l'historial:", historyError.message);
      }
      history = sanitizeHistory(((historyData || []).reverse()) as HistoryMessage[]);
    } else {
      history = sanitizeHistory(data.history as HistoryMessage[]);
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

    // Sincronitzador per assegurar que l'ID del missatge existix abans d'inserir errors
    let resolveMessageId: (id: string | null) => void;
    const messageIdPromise = new Promise<string | null>((resolve) => {
      resolveMessageId = resolve;
    });

    // 3. Persistència de missatges i XP
    const persistPromise = client
      ? (async () => {
          const dbStart = Date.now();

          const { data: userMsgInsert, error: userMsgError } = await client
            .from('conversation_messages')
            .insert({
              session_resource_id: data.session_resource_id,
              role: 'user',
              content_text: text,
              input_mode: data.input_mode,
            })
            .select('id')
            .single();

          if (userMsgError || !userMsgInsert) {
            console.error('[turn] Error guardant missatge usuari:', userMsgError?.message);
            resolveMessageId!(null);
            return;
          }

          resolveMessageId!(userMsgInsert.id);

          const { error: characterMsgError } = await client
            .from('conversation_messages')
            .insert({
              session_resource_id: data.session_resource_id,
              role: 'character',
              content_text: reply.reply_text,
              input_mode: 'text',
            });

          if (characterMsgError) {
            console.error('[turn] Error guardant missatge personatge:', characterMsgError.message);
          }

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

    // 4. Anàlisi asíncrona segura
    if (client && req.userId) {
      const currentText = text;

      void (async () => {
        const start = Date.now();
        try {
          const [detectedErrors, targetMessageId] = await Promise.all([
            analyzeErrorsWithLocalLLM(currentText),
            messageIdPromise,
          ]);

          if (!targetMessageId) {
            console.warn('[bgAnalysis] No es poden guardar errors: fallada en persistir el missatge pare.');
            return;
          }

          if (!detectedErrors || detectedErrors.length === 0) return;

          const records = detectedErrors.map((item) => ({
            message_id: targetMessageId,
            session_resource_id: data.session_resource_id,
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
            `[bgAnalysis] Guardats ${records.length} errors vinculats a ${targetMessageId} en ${Date.now() - start}ms`,
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
    if (error instanceof z.ZodError) {
      console.warn('[turn] Petició invàlida:', error.issues);
      return validationError(res, error);
    }
    console.error(error);
    res.status(500).json({ error: 'No hem pogut processar el torn' });
  }
});