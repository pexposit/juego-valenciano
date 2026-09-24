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
import {analyzeErrorsWithLocalLLM} from '../services/subagentErrorDetector.js';


export const turnRouter = Router();

// Cada torn consumix OpenAI i el TTS del servidor de la UJI: el límit protegix
// la factura. Els usuaris amb sessió poden conversar sense fricció; les
// peticions anònimes (mode demostració) van molt més limitades.




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
      if (!data.audio_base64) return res.status(400).json({ error: 'Falta l\'àudio' });
      const sttStart = Date.now();
      text = await stt.transcribe(Buffer.from(data.audio_base64, 'base64'), 'audio/webm');
      console.log(`[turn] stt=${Date.now() - sttStart}ms`);
    }
    if (!text) return res.status(400).json({ error: 'No hi ha cap missatge' });

    const client = db(req.userId);

    // Validate session (skip in demo mode)
    if (client) {
      const { data: session, error: sessionError } = await client
        .from('conversation_sessions')
        .select('id,user_id,scenario')
        .eq('id', data.session_id)
        .single();
      if (!session || session.user_id !== req.userId || session.scenario !== data.scenario) {
        // Un error de consulta (BD caiguda, permisos) es veu als logs; el client
        // rep el mateix 403 que si la sessió no existira.
        if (sessionError) console.warn('[turn] error consultant la sessió:', sessionError.message);
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
      const { data: historyData, error: historyError } = await client
        .from('conversation_messages')
        .select('role,content_text')
        .eq('session_id', data.session_id)
        .order('created_at', { ascending: false })
        .limit(HISTORY_MAX_MESSAGES);
      // Si la lectura falla, el torn continua sense context: pitjor resposta,
      // però el client no es queda sense contestació.
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

    console.log(reply)
    console.log(`[turn] agente=${Date.now() - agentStart}ms`);

    const xpDelta = 10;

    // La persistencia y el TTS corren en paralelo: el audio no depende de la BD.
    const persistPromise = client
      ? (async () => {
          const dbStart = Date.now();
          // Supabase NO llança excepcions: torna l'error dins del resultat. Si no
          // es comprova, l'usuari juga, veu pujar l'XP en pantalla i el progrés
          // es perd en silenci (i l'operador no se n'assabenta mai).
          const { error: insertTurn } = await client.from('conversation_messages').insert([
            {
              session_id: data.session_id,
              role: 'user',
              content_text: text,
              input_mode: data.input_mode,
            },
            {
              session_id: data.session_id,
              role: 'character',
              content_text: reply.reply_text,
              input_mode: 'text',
            },
          ]);
          if (insertTurn) {
            console.error('[turn] no hem pogut guardar els missatges:', insertTurn.message);
            return;
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
            return;
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

    //Añadido (Modelo LLM)

    if (client && req.userId) {
      const currentUserId = req.userId;
      const currentText = text;

      // Execució asíncrona lliure: no bloqueja la resposta ni fa cua
      void (async () => {
        const start = Date.now();
        try {
          const detectedErrors = await analyzeErrorsWithLocalLLM(currentText);

          if (!detectedErrors || detectedErrors.length === 0) return;

          const records = detectedErrors.map((item) => ({
            user_id: currentUserId,
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
            `[bgAnalysis] Guardats ${records.length} errors a Supabase en ${Date.now() - start}ms`,
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
