import { randomUUID } from 'node:crypto';
import { Router } from 'express';
import { z } from 'zod';
import { sanitizeHistory, type HistoryMessage } from '@parlaval/shared';
import { requireAuth, type AuthRequest } from '../middleware/auth.js';
import { rateLimit } from '../middleware/rateLimit.js';
import { db } from '../db.js';
import { validationError } from '../validation.js';
import { turnSchema } from '../schemas.js';
import { replyFromAgent } from '../services/agent.js';
import { findSkillActivity, findTutorActivity, hasTutorPractice, pickTutorExercise, NO_AT_LEVEL, NO_AT_LEVEL_MESSAGE, NO_EXERCISE_MESSAGE, CHAT_SKILLS, CHAT_ACTIVITY_MESSAGE, NO_CHAT_ACTIVITY_MESSAGE, type ExerciseMode, type PracticeOffer, type TutorActivity, type TutorExercise } from '../services/tutorExercise.js';
import { getScenario } from '../services/scenarios.js';
import { ASSISTANT_CATEGORY, hasOwnPaths, hasStudyPaths, isVoiceOnlyCategory, type StudyPathRef } from '@parlaval/shared';
import { motherTongueInstructions } from '../services/motherTongue.js';
import { ADULT_VALENCIAN_ONLY_INSTRUCTIONS, assistantLevelInstructions } from '../services/assistantLevel.js';
import { stt, tts } from '../services/voice.js';
import { loadVisiblePaths } from '../services/ownPaths.js';
import { gnvRagEnabled } from '../services/gnvRag.js';
import { detectPromptInjection, INJECTION_REPLY } from '../services/promptInjection.js';
import { createRepeatTracker, isLoopError, LOOP_STOPPED_MESSAGE, requestAbortSignal } from '../services/loopGuard.js';

export const turnRouter = Router();

// Transcripció d'un àudio en què no s'ha entés res, i l'única resposta que ha de rebre.
const UNINTELLIGIBLE = 'Intel·ligible';
const ASK_TO_REPEAT = "Ho sent, no t'he escoltat bé. El pots repetir?";

// El mateix missatge enviat una vegada i una altra (p. ex. un bucle de reintents al client) no arriba al model.
const repeatedTurns = createRepeatTracker();

// Resposta (sense passar pel model) quan s'ha tallat un bucle: l'usuari rep l'avís dins del xat.
const loopStoppedReply = () => ({
  reply_text: LOOP_STOPPED_MESSAGE,
  mood: 'confus',
  detected_level_signal: 'on',
  error_flags: [],
  transcription: null,
  reply_audio_base64: null,
  reply_audio_mime_type: null,
  xp_delta: 0,
  analyze_errors: false,
  loop_stopped: true,
});

const TURN_RATE_LIMIT = {
  windowMs: 60_000,
  max: Number(process.env.RATE_LIMIT_AUTHED_PER_MIN) || 30,
  maxAnonymous: Number(process.env.RATE_LIMIT_ANON_PER_MIN) || 6,
};

const TOXICITY_CLASSIFICATOR_URL = (process.env.TOXICITY_CLASSIFICATOR_URL || 'http://localhost:8001').replace(/\/$/, '');
let lastToxicityErrorWarningAt = 0;

// La detecció és només informativa: no bloqueja ni altera la resposta del xat.
// No escrivim el text del missatge al log per a no guardar contingut personal.
function logToxicityInBackground(text: string, userId?: string | null) {
  void (async () => {
    try {
      let mode: 'adult' | 'infantil' = 'adult';
      const client = db(userId ?? undefined);
      if (client && userId) {
        const { data: profile, error } = await client
          .from('profiles')
          .select('age_group')
          .eq('id', userId)
          .maybeSingle();
        if (error) {
          if (Date.now() - lastToxicityErrorWarningAt > 60_000) {
            lastToxicityErrorWarningAt = Date.now();
            console.warn('[toxicity] no s’ha pogut llegir age_group; s’aplica el mode adult', error.message);
          }
        } else if (profile?.age_group === 'child') mode = 'infantil';
      }

      const response = await fetch(`${TOXICITY_CLASSIFICATOR_URL}/classify`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ text, mode }),
        signal: AbortSignal.timeout(30_000),
      });
      if (!response.ok) throw new Error(`HTTP ${response.status}`);

      const result = await response.json() as {
        toxic: boolean;
        mode: 'adult' | 'infantil';
        reasons: string[];
        p_model: number;
        probabilities: { Nucli: number; Vulgar: number };
        message_threshold: number;
        phrase_threshold: number;
      };
      if (result.toxic) {
        console.warn(
          `[toxicity] missatge_toxic=True mode=${result.mode} ` +
          `llindar_missatge=${result.message_threshold.toFixed(2)} llindar_frase=${result.phrase_threshold.toFixed(2)} ` +
          `p_model=${result.p_model.toFixed(3)} Nucli=${result.probabilities.Nucli.toFixed(3)} ` +
          `Vulgar=${result.probabilities.Vulgar.toFixed(3)} motius=${result.reasons.join(',')}`,
        );
      }
    } catch (error) {
      // Si el classificador cau, el xat continua funcionant. Limitem l'avís per a no omplir el log.
      if (Date.now() - lastToxicityErrorWarningAt > 60_000) {
        lastToxicityErrorWarningAt = Date.now();
        console.warn('[toxicity] classificador no disponible; el torn continua sense classificar', error);
      }
    }
  })();
}

// Un torn del xat. Els missatges no es guarden al servidor: el client envia l'historial de la
// conversa (que guarda en el seu navegador) i rep la resposta. Els errors del missatge es busquen
// a banda, amb /api/errors/analyze, perquè la resposta no haja d'esperar-los.
turnRouter.post('/api/turn', requireAuth, rateLimit(TURN_RATE_LIMIT), async (req: AuthRequest, res) => {
  // S'avorta si el client tanca la connexió (botó «Aturar», pestanya tancada): talla també les crides al model en vol.
  const abortSignal = requestAbortSignal(req, res);
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
      console.log(`[turn] stt=${Date.now() - sttStart}ms ${silent ? '(silenci detectat pel client)' : `audio=${data.audio_base64.length}B transcriptionChars=${heard.length}`}`);
    }
    if (!text) return res.status(400).json({ error: 'No hi ha cap missatge' });

    // Analitza cada missatge nou (incloses les transcripcions de veu) sense canviar la conversa.
    if (text !== UNINTELLIGIBLE) logToxicityInBackground(text, req.userId);

    // Mateix missatge repetit massa voltes en poc de temps: es talla abans de gastar cap crida.
    if (repeatedTurns.hit(req.userId, text).exceeded) {
      console.warn(`[turn] missatge repetit massa voltes (usuari=${req.userId ?? '-'}); petició aturada`);
      return res.json(loopStoppedReply());
    }

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

    // Prompt injection: si el missatge intenta manipular el model, el personatge no passa pel model, ho
    // desvia amb una frase fixa i no se'n donen XP.
    const injection = detectPromptInjection(text);
    if (injection.flagged) {
      console.warn(`[turn] possible prompt injection (usuari=${req.userId ?? '-'} motius=${injection.reasons.join(',')} puntuació=${injection.score})`);
      const audio = data.include_audio ? await tts.synthesize(INJECTION_REPLY, scenario.voice) : null;
      return res.json({
        reply_text: INJECTION_REPLY,
        mood: 'neutral',
        detected_level_signal: 'on',
        error_flags: [],
        transcription: data.input_mode === 'voice' ? text : null,
        reply_audio_base64: audio?.audio.toString('base64') || null,
        reply_audio_mime_type: audio?.mimeType || null,
        xp_delta: 0,
        analyze_errors: false,
      });
    }

    // 2. Historial de la conversa, enviat pel client (no es guarda al servidor). El client el pot haver manipulat:
    // els missatges de l'aprenent que semblen una injecció es descarten abans d'arribar al model.
    const history = sanitizeHistory(data.history as HistoryMessage[])
      .filter(message => message.role !== 'user' || !detectPromptInjection(message.content_text).flagged);

    // El tutor del tauler té en compte la llengua materna, el nivell i el públic (xiquet o adult) de l'usuari.
    let extraInstructions: string | undefined;
    let levelInstructions: string | undefined;
    let level = data.level;
    let levelZero = false;
    let gnvTool = false;
    let conjugationTool = false;
    let exerciseTool = false;
    let lessons: { id: string; title: string; summary: string }[] = [];
    let routeTool = false;
    let paths: StudyPathRef[] = [];
    let pendingRouteOffer: string | undefined;
    if (client && scenario.category === ASSISTANT_CATEGORY) {
      const { data: profile } = await client.from('profiles').select('mother_tongue, level, age_group').eq('id', req.userId!).maybeSingle();
      extraInstructions = motherTongueInstructions(profile?.mother_tongue);
      levelInstructions = assistantLevelInstructions(profile?.level, profile?.age_group);
      level = profile?.level ?? level;
      levelZero = profile?.level === 'nivell0';
      // Els dubtes de normativa es responen amb la GNV (RAG), però no en el Nivell 0 (xiquets que no lligen).
      gnvTool = gnvRagEnabled() && !levelZero;
      // La conjugació d'un verb (DNV, via el MCP) es mostra en una taula: tampoc per al Nivell 0.
      conjugationTool = !levelZero;
      // Els exercicis del catàleg són per a qui sap llegir: no per al Nivell 0.
      exerciseTool = !levelZero;
      // El Nivell 0 no fa exercicis del catàleg: als xiquets se'ls enllaça una lliçó de l'app (les envia el client).
      // Els adults del Nivell 0 no tenen lliçons.
      lessons = levelZero && profile?.age_group === 'child' ? data.lessons : [];
      // Rutes d'aprenentatge (/ruta): el tutor hi porta l'aprenent i li n'ofereix de pròpies sobre el que li costa.
      routeTool = !levelZero && hasStudyPaths(profile?.level);
      if (routeTool) {
        paths = await loadVisiblePaths(client, req.userId!, profile!.level).catch((error) => {
          console.warn('[turn] no hem pogut carregar les rutes:', error instanceof Error ? error.message : error);
          return [];
        });
        // L'oferta pendent l'envia el client: si sembla una injecció, es descarta.
        const offer = data.pending_route_offer?.trim();
        pendingRouteOffer = offer && hasOwnPaths(level) && !detectPromptInjection(offer).flagged ? offer : undefined;
      }
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
      conjugationTool,
      exerciseTool,
      lessons,
      routeTool,
      paths,
      pendingRouteOffer,
      // El tutor del tauler: sempre gpt-6-luna amb esforç 'low' (DASHBOARD_AGENT).
      dashboardAgent: scenario.category === ASSISTANT_CATEGORY,
      signal: abortSignal,
    });

    // El tutor ha oferit un exercici: se'n tria un de real del catàleg (mai inventat).
    const { exercici_tema, tipus_dubte, area_practica, leccio_id, corregir_text, ruta, ...replyBody } = reply;
    // Rutes: obrir-ne una o acceptar l'oferta ja és la resposta (sense exercicis ni activitats). Una oferta de ruta nova
    // només en els nivells que en poden tindre de pròpies; l'acceptació, només si hi havia una oferta pendent.
    const studyPath = ruta?.path;
    const generateRoute = ruta?.accepted && pendingRouteOffer ? pendingRouteOffer : undefined;
    const routeOffer = ruta?.offer && hasOwnPaths(level) ? ruta.offer : undefined;
    const routeAction = Boolean(studyPath || generateRoute);
    // Text per a corregir: el client mostra després la llista d'errors de l'anàlisi; ací ni exercicis ni activitats.
    const correctText = Boolean(corregir_text) && exerciseTool && !levelZero;
    // Només una lliçó de les que s'han enviat (el model no pot inventar-ne).
    const lessonId = lessons.some(l => l.id === leccio_id) ? leccio_id : undefined;
    let exercise: TutorExercise | null = null;
    let activity: TutorActivity | null = null;
    let practiceOffer: PracticeOffer | undefined;
    let noAtLevel = false;
    // Si ha respost amb una regla de la GNV, l'exercici és del seu tema (l'últim apartat de la ruta, sense numeració)
    // encara que el model no haja escrit el tema: primer la norma i després la pràctica.
    const gnvTopic = reply.gnv?.ruta.split('>').pop()?.replace(/^[\s\d.]+/, '').trim();
    // Tipus de pregunta: una regla de la GNV és sempre un dubte complex; si no, el que diu el model. Qui demana practicar
    // sempre rep l'exercici (o l'avís que no n'hi ha); «cap» no en dóna mai.
    const askedToPractice = tipus_dubte === 'demana_exercici' || /exerci/i.test(text);
    const mode: ExerciseMode | null = correctText || routeAction ? null
      : askedToPractice ? 'request'
      : reply.gnv || tipus_dubte === 'complex' ? 'complex'
      : tipus_dubte === 'simple' ? 'simple' : null;
    // El tema que normalitza el model; el de la GNV només hi ajuda en els dubtes complexos.
    const topic = exercici_tema?.trim() || (mode === 'complex' || mode === 'request' ? gnvTopic : undefined) || (mode === 'request' ? text : undefined);
    // Seccions de la GNV de la regla (la principal i les que la completen): les activitats que citen la mateixa, primer.
    const gnvSections = reply.gnv ? [reply.gnv.seccio, ...(reply.gnv.relacionades ?? []).map(x => x.seccio)] : [];
    // Destreses que no es poden fer dins del xat (redactar, escoltar, llegir, parlar): s'enllaça una activitat de l'àrea.
    // Si vol practicar la conversa, sempre se li enllaça un escenari concret, encara que el model no ho haja marcat.
    const wantsConversation = /convers|xarr|xat|xatej|joc de rol|escenari|situaci/i.test(text) && !/exerci/i.test(text);
    const wantsOral = /expres+i[oó]n?\s+oral/i.test(text);
    const skill = correctText || routeAction ? '' : area_practica || (wantsOral ? 'expressio_oral' : '') || (wantsConversation ? 'escenari' : '');
    if (exerciseTool && skill) activity = await findSkillActivity(skill, level, text);
    // Conversa i expressió oral: només s'enllaça un escenari real del catàleg i la frase la posa l'app, perquè el model
    // no puga descriure ni proposar escenaris inventats (ni enllaçar-ne cap si no n'hi ha).
    const chatSkill = exerciseTool && CHAT_SKILLS.includes(skill);
    if (chatSkill) replyBody.reply_text = activity ? CHAT_ACTIVITY_MESSAGE : NO_CHAT_ACTIVITY_MESSAGE;
    if (exerciseTool && topic && mode === 'complex' && !activity && !chatSkill) {
      // Dubte complex: no es busca l'exercici, es mostra el botó «Practica-ho» si el catàleg en té del tema (es busca en
      // prémer-lo, /api/assistant/practice). Amb regla de la GNV, el tema és el de la secció (fix per a la mateixa regla).
      const offerTopic = gnvTopic || topic;
      if (await hasTutorPractice(offerTopic, gnvSections)) practiceOffer = { id: randomUUID(), topic: offerTopic, sections: gnvSections };
    } else if (exerciseTool && topic && mode === 'request' && !activity && !chatSkill) {
      // Ha demanat practicar: l'exercici es busca ara (o l'avís si no n'hi ha). Els dubtes simples no en reben cap.
      const picked = await pickTutorExercise(topic, level, data.shown_exercises, gnvSections, `${text}. ${gnvTopic ?? ''}`.trim(), mode);
      if (picked === NO_AT_LEVEL) {
        // Hi ha exercicis del tema però no del seu nivell: no se'n mostra cap d'un altre ni s'enllaça cap activitat.
        noAtLevel = true;
        replyBody.reply_text = `${NO_AT_LEVEL_MESSAGE}.`;
      } else exercise = picked;
      // Hi ha pràctica del tema però cap exercici que càpiga en el xat: s'enllaça l'activitat.
      if (!exercise && !noAtLevel) activity = await findTutorActivity(topic, gnvSections);
      // Ha demanat un exercici i no n'hi ha cap (ni activitat que enllaçar): se li diu, en lloc de callar.
      if (!exercise && !noAtLevel && !activity) replyBody.reply_text = NO_EXERCISE_MESSAGE;
    }

    console.log(`[turn] agente=${Date.now() - agentStart}ms`);
    const xpDelta = 10;

    const wantsAudio = data.include_audio;
    const ttsStart = Date.now();
    const audioPromise = wantsAudio
      ? tts.synthesize(replyBody.reply_text.split('\n')[0], scenario.voice)
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
      ...(correctText ? { correct_text: true } : {}),
      ...(studyPath ? { study_path: studyPath } : {}),
      ...(routeOffer ? { route_offer: routeOffer } : {}),
      ...(generateRoute ? { generate_route: generateRoute } : {}),
      ...(exercise ? { exercise } : {}),
      ...(activity ? { activity } : {}),
      ...(practiceOffer ? { practice_offer: practiceOffer } : {}),
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
    // Bucle tallat: si l'ha cancel·lat el client no hi ha ningú a qui avisar; si no, l'avís va dins de la resposta.
    if (isLoopError(error)) {
      console.warn(error.message);
      if (error.userCancelled || res.headersSent) return;
      return res.json(loopStoppedReply());
    }
    console.error(error);
    res.status(500).json({ error: 'No hem pogut processar el torn' });
  }
});
