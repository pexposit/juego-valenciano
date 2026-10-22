import { Router } from 'express';
import { z } from 'zod';
import { sanitizeHistory, type HistoryMessage } from '@parlaval/shared';
import { requireAuth, type AuthRequest } from '../middleware/auth.js';
import { rateLimit } from '../middleware/rateLimit.js';
import { db } from '../db.js';
import { validationError } from '../validation.js';
import { turnSchema } from '../schemas.js';
import { replyFromAgent } from '../services/agent.js';
import { findSkillActivity, findTutorActivity, pickTutorExercise, TOO_HIGH, TOO_HIGH_MESSAGE, type TutorActivity, type TutorExercise } from '../services/tutorExercise.js';
import { getScenario } from '../services/scenarios.js';
import { ASSISTANT_CATEGORY, isVoiceOnlyCategory } from '@parlaval/shared';
import { motherTongueInstructions } from '../services/motherTongue.js';
import { ADULT_VALENCIAN_ONLY_INSTRUCTIONS, assistantLevelInstructions } from '../services/assistantLevel.js';
import { stt, tts } from '../services/voice.js';
import { gnvRagEnabled } from '../services/gnvRag.js';

export const turnRouter = Router();

// Transcripció d'un àudio en què no s'ha entés res, i l'única resposta que ha de rebre.
const UNINTELLIGIBLE = 'Intel·ligible';
const ASK_TO_REPEAT = "Ho sent, no t'he escoltat bé. El pots repetir?";

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
    const scenario = await getScenario(data.scenario, req.userId ?? null);
    if (!scenario) return res.status(404).json({ error: "L'escenari no existix o encara no està disponible" });
    // En l'Expressió oral es practica parlant: no s'admeten missatges escrits.
    if (isVoiceOnlyCategory(scenario.category) && data.input_mode !== 'voice') {
      return res.status(400).json({ error: 'En esta activitat només es pot parlar' });
    }

    if (data.input_mode === 'voice') {
      if (!data.audio_base64) return res.status(400).json({ error: "Falta l'àudio" });
      const sttStart = Date.now();
      // Si el model no reconeix cap paraula, la transcripció per defecte és «Intel·ligible». El frontend envia
      // «silence» en lloc de l'àudio quan la gravació és silenci (whisper s'inventaria el text).
      const silent = data.audio_base64 === 'silence';
      const heard = silent ? '' : await stt.transcribe(Buffer.from(data.audio_base64, 'base64'), 'audio/webm');
      text = heard || UNINTELLIGIBLE;
      console.log(`[turn] stt=${Date.now() - sttStart}ms ${silent ? '(silenci detectat pel client)' : `audio=${data.audio_base64.length}B text="${heard}"`}`);
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

    // Si no s'ha entés l'àudio, el personatge només demana que ho repetisca (sense passar pel model ni donar XP).
    if (data.input_mode === 'voice' && text === UNINTELLIGIBLE) {
      const audio = data.include_audio ? await tts.synthesize(ASK_TO_REPEAT, scenario.voice) : null;
      return res.json({
        reply_text: ASK_TO_REPEAT,
        mood: 'confus',
        detected_level_signal: 'on',
        error_flags: [],
        transcription: text,
        reply_audio_base64: audio?.audio.toString('base64') || null,
        reply_audio_mime_type: audio?.mimeType || null,
        xp_delta: 0,
        analyze_errors: false,
      });
    }

    // 2. Historial de la conversa, enviat pel client (no es guarda al servidor).
    const history = sanitizeHistory(data.history as HistoryMessage[]);

    // El tutor del tauler té en compte la llengua materna, el nivell i el públic (xiquet o adult) de l'usuari.
    let extraInstructions: string | undefined;
    let levelInstructions: string | undefined;
    let level = data.level;
    let levelZero = false;
    let gnvTool = false;
    let exerciseTool = false;
    let lessons: { id: string; title: string; summary: string }[] = [];
    if (client && scenario.category === ASSISTANT_CATEGORY) {
      const { data: profile } = await client.from('profiles').select('mother_tongue, level, age_group').eq('id', req.userId!).maybeSingle();
      extraInstructions = motherTongueInstructions(profile?.mother_tongue);
      levelInstructions = assistantLevelInstructions(profile?.level, profile?.age_group);
      level = profile?.level ?? level;
      levelZero = profile?.level === 'nivell0';
      // Els dubtes de normativa es responen amb la GNV (RAG), però no en el Nivell 0 (xiquets que no lligen).
      gnvTool = gnvRagEnabled() && !levelZero;
      // Els exercicis del catàleg són per a qui sap llegir: no per al Nivell 0.
      exerciseTool = !levelZero;
      // El Nivell 0 no fa exercicis del catàleg: als xiquets se'ls enllaça una lliçó de l'app (les envia el client).
      // Els adults del Nivell 0 no tenen lliçons.
      lessons = levelZero && profile?.age_group === 'child' ? data.lessons : [];
    } else if (client) {
      // Escenaris del Nivell 0: si el xiquet té activada la llengua materna, el personatge hi afig
      // la traducció de cada resposta (segona línia), que el xat mostra com a subtítol.
      const { data: profile } = await client.from('profiles').select('mother_tongue, level, show_mother_tongue, age_group').eq('id', req.userId!).maybeSingle();
      levelZero = profile?.level === 'nivell0';
      if (profile?.age_group && profile.age_group !== 'child') levelInstructions = ADULT_VALENCIAN_ONLY_INSTRUCTIONS;
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
      gnvTool,
      exerciseTool,
      lessons,
    });

    // El tutor ha oferit un exercici: se'n tria un de real del catàleg (mai inventat).
    const { exercici_tema, area_practica, leccio_id, ...replyBody } = reply;
    // Només una lliçó de les que s'han enviat (el model no pot inventar-ne).
    const lessonId = lessons.some(l => l.id === leccio_id) ? leccio_id : undefined;
    let exercise: TutorExercise | null = null;
    let activity: TutorActivity | null = null;
    let tooHigh = false;
    // Si ha respost amb una regla de la GNV, l'exercici és del seu tema (l'últim apartat de la ruta, sense numeració)
    // encara que el model no haja escrit el tema: primer la norma i després la pràctica.
    const gnvTopic = reply.gnv?.ruta.split('>').pop()?.replace(/^[\s\d.]+/, '').trim();
    const topic = exercici_tema?.trim() || gnvTopic;
    // Seccions de la GNV de la regla (la principal i les que la completen): les activitats que citen la mateixa, primer.
    const gnvSections = reply.gnv ? [reply.gnv.seccio, ...(reply.gnv.relacionades ?? []).map(x => x.seccio)] : [];
    // Destreses que no es poden fer dins del xat (redactar, escoltar, llegir, parlar): s'enllaça una activitat de l'àrea.
    // Si vol practicar la conversa, sempre se li enllaça un escenari concret, encara que el model no ho haja marcat.
    const wantsConversation = /convers|xarr|xat|xatej|joc de rol|escenari|situaci/i.test(text) && !/exerci/i.test(text);
    const skill = area_practica || (wantsConversation ? 'escenari' : '');
    if (exerciseTool && skill) activity = await findSkillActivity(skill, level, text);
    if (exerciseTool && topic && !activity) {
      // Només es mostra un exercici si n'hi ha un prou relacionat amb el tema (també quan l'aprenent demana practicar).
      const askedToPractice = /exerci|practic|prova|test/i.test(text);
      const picked = await pickTutorExercise(topic, level, data.shown_exercises, gnvSections, `${text}. ${gnvTopic ?? ''}`.trim());
      if (picked === TOO_HIGH) {
        // Només hi ha exercicis d'un nivell superior: la resposta passa a ser l'avís (el text del model, com «Prova este
        // exercici!», ja no té sentit, ni la seua traducció) i no s'enllaça cap activitat.
        replyBody.reply_text = `${TOO_HIGH_MESSAGE}.`;
        tooHigh = true;
      } else exercise = picked;
      // Hi ha pràctica del tema però cap exercici que càpiga en el xat: s'enllaça l'activitat.
      // Només amb una regla de la GNV al darrere o si ho ha demanat: un tema solt (p. ex. el significat d'una paraula) no en dóna prou.
      if (!exercise && !tooHigh && (reply.gnv || askedToPractice)) activity = await findTutorActivity(topic, gnvSections);
    }

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
      ...replyBody,
      ...(exercise ? { exercise } : {}),
      ...(activity ? { activity } : {}),
      ...(lessonId ? { lesson_id: lessonId } : {}),
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