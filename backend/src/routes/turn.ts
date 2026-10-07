import { Router } from 'express';
import { z } from 'zod';
import { sanitizeHistory, type HistoryMessage } from '@parlaval/shared';
import { requireAuth, type AuthRequest } from '../middleware/auth.js';
import { rateLimit } from '../middleware/rateLimit.js';
import { db } from '../db.js';
import { validationError } from '../validation.js';
import { turnSchema } from '../schemas.js';
import { replyFromAgent } from '../services/agent.js';
import { getScenario } from '../services/scenarios.js';
import { ASSISTANT_CATEGORY, isVoiceOnlyCategory } from '@parlaval/shared';
import { motherTongueInstructions } from '../services/motherTongue.js';
import { assistantLevelInstructions } from '../services/assistantLevel.js';
import { stt, tts } from '../services/voice.js';

export const turnRouter = Router();

const TURN_RATE_LIMIT = {
  windowMs: 60_000,
  max: Number(process.env.RATE_LIMIT_AUTHED_PER_MIN) || 30,
  maxAnonymous: Number(process.env.RATE_LIMIT_ANON_PER_MIN) || 6,
};

// Un torn del xat. Els missatges no es guarden al servidor: el client envia l'historial de la
// conversa (que guarda en el seu navegador) i rep la resposta. Els errors del missatge es busquen
// a banda, amb /api/errors/analyze, perquè la resposta no haja d'esperar-los.
turnRouter.post('/api/turn', requireAuth, rateLimit(TURN_RATE_LIMIT), async (req: AuthRequest, res) => {
  try {
    const data = turnSchema.parse(req.body);
    let text = data.text.trim();
    const startedAt = Date.now();

    // L'escenari (prompt, personatge, veu) es llig de la taula resources.
    const scenario = await getScenario(data.scenario);
    if (!scenario) return res.status(404).json({ error: "L'escenari no existix o encara no està disponible" });
    // En l'Expressió oral es practica parlant: no s'admeten missatges escrits.
    if (isVoiceOnlyCategory(scenario.category) && data.input_mode !== 'voice') {
      return res.status(400).json({ error: 'En esta activitat només es pot parlar' });
    }

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

    // 2. Historial de la conversa, enviat pel client (no es guarda al servidor).
    const history = sanitizeHistory(data.history as HistoryMessage[]);

    // El tutor del tauler té en compte la llengua materna, el nivell i el públic (xiquet o adult) de l'usuari.
    let extraInstructions: string | undefined;
    let levelInstructions: string | undefined;
    let level = data.level;
    let levelZero = false;
    if (client && scenario.category === ASSISTANT_CATEGORY) {
      const { data: profile } = await client.from('profiles').select('mother_tongue, level, age_group').eq('id', req.userId!).maybeSingle();
      extraInstructions = motherTongueInstructions(profile?.mother_tongue);
      levelInstructions = assistantLevelInstructions(profile?.level, profile?.age_group);
      level = profile?.level ?? level;
      levelZero = profile?.level === 'nivell0';
    } else if (client) {
      // Escenaris del Nivell 0: si el xiquet té activada la llengua materna, el personatge hi afig
      // la traducció de cada resposta (segona línia), que el xat mostra com a subtítol.
      const { data: profile } = await client.from('profiles').select('mother_tongue, level, show_mother_tongue').eq('id', req.userId!).maybeSingle();
      levelZero = profile?.level === 'nivell0';
      if (levelZero && profile?.show_mother_tongue !== false) {
        extraInstructions = motherTongueInstructions(profile.mother_tongue);
      }
    }

    const agentStart = Date.now();
    const reply = await replyFromAgent({
      scenario,
      level,
      message: text,
      history,
      extraInstructions,
      levelInstructions,
    });

    console.log(`[turn] agente=${Date.now() - agentStart}ms`);
    const xpDelta = 10;

    const wantsAudio = data.include_audio;
    const ttsStart = Date.now();
    const audioPromise = wantsAudio
      ? tts.synthesize(reply.reply_text.split('\n')[0], scenario.voice)
      : Promise.resolve(null);

    // 3. XP del torn (els missatges no es guarden).
    const xpPromise = client
      ? (async () => {
          const { error: xpError } = await client.rpc('apply_turn_xp', {
            p_user_id: req.userId,
            p_session_id: data.session_id,
            p_xp_delta: xpDelta,
          });
          if (xpError) console.error('[turn] no hem pogut aplicar els XP:', xpError.message);
        })()
      : Promise.resolve();

    const [audio] = await Promise.all([audioPromise, xpPromise]);

    console.log(
      `[turn] tts=${wantsAudio ? Date.now() - ttsStart : 0}ms total=${Date.now() - startedAt}ms`,
    );

    res.json({
      ...reply,
      transcription: data.input_mode === 'voice' ? text : null,
      reply_audio_base64: audio?.audio.toString('base64') || null,
      reply_audio_mime_type: audio?.mimeType || null,
      xp_delta: xpDelta,
      // Nivell 0 (xiquets): no es busquen errors gramaticals de la conversa; en acabar-la només
      // es revisen els objectius de l'escenari (services/kidsObjectives.ts).
      analyze_errors: !levelZero,
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