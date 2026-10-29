import { useCallback, useEffect, useRef, useState } from 'react';
import { Loader2, RotateCcw, Square, Volume2 } from 'lucide-react';
import { useDelayedFlag } from './AudioLoading';
import { KID_ASSISTANT_TYPE } from '@parlaval/shared';
import { ChatBubble } from './ChatBubble';
import { VoiceInput } from './VoiceInput';
import { RobotVoiceMenu, savedRobotVoice } from './RobotVoiceMenu';
import { DashboardRobot, isRobotAvatarEnabled } from '../features/robot-avatar'; // [robot-avatar]
import { analyzeMessage, ensureSession, fetchErrorCitations, fetchTts, fetchTutorPractice, generateOwnPath, openAssistant, recordPracticeAnswers, restartAssistant, sendTurn, type AssistantConversation, type HistoryItem, type TextError } from '../lib/api';
import { addMessages, saveExerciseAnswer, savePracticeResult, saveRouteOfferAnswer, withPracticeResult } from '../lib/localStore';
import { correctionsText } from '../lib/corrections';
import { useThinkingSound } from '../lib/useThinkingSound';
import { ThinkingIndicator } from './ThinkingIndicator';
import { ALL_LESSONS } from '../features/kids/lessons';
import type { Mood, PracticeOffer, RouteOffer, TutorExercise } from '../lib/types';

// `transcription`: en un missatge de veu, el que ha entés el model; es mostra davall l'etiqueta del missatge.
type Message = AssistantConversation['messages'][number] & { transcription?: string };

// El tutor dels xiquets parla com en l'A1 (és el que fixa el registre infantil).
const CHILD_LEVEL = 'A1';
const VOICE_MESSAGE_LABEL = '🎙️ Missatge de veu';
const ERROR_REPLY = "No t'he sentit bé, pots repetir-ho?";
// Rutes d'aprenentatge: si no s'ha pogut preparar la ruta i si l'aprenent diu que no la vol.
const ROUTE_ERROR_REPLY = "No he pogut preparar la ruta ara mateix. Torna-ho a provar d'ací a un moment.";
const ROUTE_DECLINED_REPLY = "D'acord! Si més endavant la vols, només m'ho has de dir.";
const PRACTICE_ERROR_REPLY = "Ara no he pogut buscar l'exercici. Torna-ho a provar d'ací a un moment.";
const TTS_ATTEMPTS = 2;
// El professor ho diu en triar una veu nova en el menú del robot, perquè se senta com sona.
const VOICE_SAMPLE = 'Hola! Ara parle amb esta veu.';

// Mida del professor segons l'amplada de la pantalla: més xicotet en mòbils i tauletes.
// En horitzontal en un mòbil (poca altura) el professor va a l'esquerra i ha de cabre en l'altura.
const isShortLandscape = () => window.matchMedia('(max-height: 500px) and (orientation: landscape)').matches;
// En ordenador (≥ 1024 px) el professor creix amb la finestra, tant en amplada com en altura (entre 280 i 560 px): en un
// monitor gran no es queda xicotet i en un portàtil baix no tapa el xat. Reserva la capçalera i la barra del peu.
const DESKTOP_MIN_WIDTH = 1024;
// Ordenador: entre 280 i 560 px, un 26 % de l'amplada. Mòbils i tauletes: entre 140 i 320 px, un 32 % (el professor va
// al costat del xat i no ha de menjar-se'l). Sempre limitat per l'altura que queda sota la capçalera i damunt del peu.
const AVATAR_LIMITS = {
  desktop: { min: 280, max: 560, ofWidth: 0.26 },
  compact: { min: 140, max: 320, ofWidth: 0.32 },
};
const HEADER_AND_PADDING = 140;

// Mida del text del xat: creix de forma contínua amb l'amplada de la pantalla (15 px en mòbils i tauletes, 17 px a 1366 px,
// 22 px en monitors grans). Tot el que hi ha dins de les bombolles (targetes, exercicis) va en em, relatiu a esta.
const CHAT_FONT_STYLE = { '--chat-font': 'clamp(15px, 0.5vw + 10px, 22px)' } as React.CSSProperties;
const adaptiveAvatarSize = (width: number, height: number) => {
  const { min, max, ofWidth } = width >= DESKTOP_MIN_WIDTH ? AVATAR_LIMITS.desktop : AVATAR_LIMITS.compact;
  const footer = parseInt(getComputedStyle(document.documentElement).getPropertyValue('--app-footer'), 10) || 0;
  const availableHeight = height - footer - HEADER_AND_PADDING;
  const size = Math.min(width * ofWidth, availableHeight * 0.85);
  return Math.round(Math.max(min, Math.min(max, size)));
};
const avatarSizeFor = (width: number, height = window.innerHeight) =>
  isShortLandscape() ? Math.min(200, height - 160) : adaptiveAvatarSize(width, height);

function useAvatarSize() {
  const [size, setSize] = useState(() => avatarSizeFor(window.innerWidth));
  useEffect(() => {
    const update = () => setSize(avatarSizeFor(window.innerWidth, window.innerHeight));
    window.addEventListener('resize', update);
    window.addEventListener('orientationchange', update);
    return () => {
      window.removeEventListener('resize', update);
      window.removeEventListener('orientationchange', update);
    };
  }, []);
  return size;
}

// Xat del tauler infantil: el xiquet pregunta al professor dubtes de valencià, escrivint o parlant.
// Reutilitza el xat de les activitats (/api/turn): els missatges es guarden en este navegador (no
// al servidor) i la conversa continua entre visites. El professor també respon en veu alta.
export function ChildAssistant({ showHelp }: { showHelp: boolean }) {
  const [messages, setMessages] = useState<Message[]>([]);
  const [ready, setReady] = useState(false);
  const [openFailed, setOpenFailed] = useState(false);
  const [loading, setLoading] = useState(false);
  const [talking, setTalking] = useState(false);
  const [mood, setMood] = useState<Mood>('neutral');
  const avatarSize = useAvatarSize();
  const listRef = useRef<HTMLDivElement>(null);
  const audio = useRef<{ text: string; element: HTMLAudioElement } | null>(null);
  // false quan el tauler ja no és en pantalla: una resposta del TTS que arribe tard no ha de sonar.
  const mounted = useRef(true);
  // Es guarda la promesa perquè el primer torn la puga esperar i perquè StrictMode no obri la conversa dues vegades.
  const conversation = useRef<Promise<AssistantConversation>>();

  // Número de l'última petició de veu: si en arriba una de vella, es descarta (si no, sonarien dues veus alhora).
  const speakRequest = useRef(0);
  // true mentre la veu del professor es demana o es descarrega i encara no pot sonar.
  const [voiceLoading, setVoiceLoading] = useState(false);
  const showVoiceLoading = useDelayedFlag(voiceLoading);
  // El robot pensa des que s'envia la pregunta (resposta del tutor, amb el RAG de la GNV si cal) fins que comença a parlar.
  const thinking = loading || voiceLoading;
  useThinkingSound(thinking);
  // Veu triada tocant el robot (undefined = la del professor). Es llig en cada frase, per això va en una ref.
  const [voice, setVoice] = useState(savedRobotVoice);
  const voiceRef = useRef(voice);
  const [voiceMenuOpen, setVoiceMenuOpen] = useState(false);
  const robotRef = useRef<HTMLDivElement>(null);
  const closeVoiceMenu = useCallback(() => setVoiceMenuOpen(false), []);
  const stopAudio = () => {
    speakRequest.current += 1;
    setVoiceLoading(false);
    audio.current?.element.pause();
    audio.current = null;
    setTalking(false);
  };

  // Reprodueix el text amb la veu del professor (TTS del backend; mai la del navegador).
  const speak = async (text: string) => {
    stopAudio();
    const mine = speakRequest.current;
    setVoiceLoading(true);
    // Només la primera línia (en valencià): la resta és l'ajuda en la llengua materna del xiquet.
    const spoken = text.split('\n')[0].trim();
    for (let attempt = 1; attempt <= TTS_ATTEMPTS; attempt += 1) {
      try {
        const source = await fetchTts(spoken, KID_ASSISTANT_TYPE, voiceRef.current);
        if (!mounted.current || mine !== speakRequest.current) return;
        const element = new Audio(source);
        element.oncanplay = element.onerror = () => setVoiceLoading(false);
        element.onplay = () => setTalking(true);
        element.onpause = element.onended = () => setTalking(false);
        audio.current = { text, element };
        return void element.play().catch(() => {}); // sense gest de l'usuari el navegador pot bloquejar l'autoplay
      } catch {
        // Es torna a provar; si falla sense àudio, el botó de repetir ho reintenta.
      }
    }
    if (mine === speakRequest.current) setVoiceLoading(false);
  };

  const changeVoice = (next: string | undefined) => {
    voiceRef.current = next;
    setVoice(next);
    void speak(VOICE_SAMPLE);
  };

  const lastReply = [...messages].reverse().find(m => m.role === 'character')?.text;
  const replay = () => {
    if (!lastReply) return;
    if (audio.current?.text === lastReply) {
      audio.current.element.currentTime = 0;
      void audio.current.element.play().catch(() => {});
    } else {
      void speak(lastReply);
    }
  };

  useEffect(() => {
    let cancelled = false;
    mounted.current = true;
    conversation.current ??= ensureSession(CHILD_LEVEL).then(openAssistant);
    conversation.current
      .then(opened => {
        if (cancelled) return;
        setMessages(opened.messages);
        setReady(true);
        // Conversa nova: el professor diu la salutació ("En què et puc ajudar?").
        if (opened.messages.length === 1) void speak(opened.messages[0].text);
      })
      .catch(error => {
        console.error('Error obrint el xat del professor:', error);
        conversation.current = undefined;
        if (!cancelled) setOpenFailed(true);
      });
    return () => { cancelled = true; mounted.current = false; stopAudio(); turnAbort.current?.abort(); };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // Tanca la conversa i en comença una de nova: el professor torna a saludar.
  const restart = async () => {
    if (loading || !ready) return;
    if (!window.confirm('Vols començar una conversa nova amb el professor?')) return;
    stopAudio();
    setLoading(true);
    try {
      const fresh = await ensureSession(CHILD_LEVEL).then(restartAssistant);
      conversation.current = Promise.resolve(fresh);
      setMessages(fresh.messages);
      setMood('neutral');
      void speak(fresh.messages[0].text);
    } catch (error) {
      console.error('Error reiniciant la conversa:', error);
      setMessages(m => [...m, { role: 'character', text: ERROR_REPLY }]);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    listRef.current?.scrollTo({ top: listRef.current.scrollHeight, behavior: 'smooth' });
  }, [messages, loading]);

  // Petició al professor en curs: el botó d'aturar la cancel·la (el servidor talla la crida al model en tancar-se la connexió).
  const turnAbort = useRef<AbortController | null>(null);
  const [sending, setSending] = useState(false);
  const stopTurn = () => turnAbort.current?.abort();
  // Corregint un text: l'anàlisi d'errors tarda; el botó d'aturar descarta el resultat (l'anàlisi continua i es guarda igual).
  const [correcting, setCorrecting] = useState(false);
  const correctionCancelled = useRef(false);

  // Mostra en el xat els errors que l'anàlisi ha trobat en el text de l'aprenent, amb la cita de la GNV de cada contingut.
  const showCorrections = async (sessionResourceId: string, analysis: Promise<TextError[]>) => {
    correctionCancelled.current = false;
    setCorrecting(true);
    try {
      const errors = await analysis;
      const citations = errors.length ? await fetchErrorCitations(errors) : [];
      if (correctionCancelled.current || !mounted.current) return;
      const text = errors.length ? correctionsText(errors, citations) : "No he trobat cap error en el teu text. Bona feina!";
      setMessages(m => [...m, { role: 'character', text }]);
      void addMessages(sessionResourceId, 'tutor', [{ role: 'character', text }]).catch(error => console.error('Error guardant la conversa:', error));
    } finally {
      setCorrecting(false);
    }
  };

  // Rutes d'aprenentatge: l'aprenent ha contestat l'oferta del tutor (amb els botons o escrivint). Es marca en el xat i
  // en este navegador perquè no se li tornen a mostrar els botons.
  const markRouteOffer = (topic: string, answer: 'yes' | 'no') => {
    setMessages(m => m.map(x => (x.routeOffer?.topic === topic && !x.routeOffer.answer ? { ...x, routeOffer: { ...x.routeOffer, answer } } : x)));
    void conversation.current
      ?.then(opened => saveRouteOfferAnswer(opened.session_resource_id, topic, answer))
      .catch(error => console.error("Error guardant la resposta a l'oferta de ruta:", error));
  };

  // Afig un missatge del professor que no ve del model (ruta preparada, resposta a «No, gràcies»...) i el guarda.
  const addTutorMessage = (message: Message) => {
    setMessages(m => [...m, message]);
    void conversation.current
      ?.then(opened => addMessages(opened.session_resource_id, 'tutor', [message]))
      .catch(error => console.error('Error guardant la conversa:', error));
  };

  // Prepara la ruta pròpia (l'ha acceptada) i l'enllaça en el xat; tarda com una crida al model.
  const [buildingRoute, setBuildingRoute] = useState(false);
  const buildRoute = async (topic: string) => {
    setBuildingRoute(true);
    try {
      const result = await generateOwnPath(topic);
      if (!mounted.current) return;
      addTutorMessage(result.status === 'ok' ? { role: 'character', text: result.message, studyPath: result.path } : { role: 'character', text: result.message });
      void speak(result.message);
    } catch (error) {
      console.error('Error preparant la ruta:', error);
      if (mounted.current) addTutorMessage({ role: 'character', text: ROUTE_ERROR_REPLY });
    } finally {
      setBuildingRoute(false);
    }
  };

  const answerRouteOffer = (offer: RouteOffer, answer: 'yes' | 'no') => {
    if (offer.answer || buildingRoute) return;
    markRouteOffer(offer.topic, answer);
    if (answer === 'yes') void buildRoute(offer.topic);
    else addTutorMessage({ role: 'character', text: ROUTE_DECLINED_REPLY });
  };

  const send = async (text: string, voice?: string) => {
    if ((!text && !voice) || loading || buildingRoute || !conversation.current) return;
    // L'última oferta de ruta encara sense contestar: el tutor sabrà si este missatge l'accepta.
    const pendingOffer = [...messages].reverse().find(m => m.role === 'character')?.routeOffer;
    const pendingRouteOffer = pendingOffer && !pendingOffer.answer ? pendingOffer.topic : undefined;
    stopAudio();
    const abort = new AbortController();
    turnAbort.current = abort;
    setSending(true);
    const context: HistoryItem[] = messages.map(m => ({ role: m.role, content_text: m.transcription ?? m.text }));
    setMessages(m => [...m, { role: 'user', text: text || VOICE_MESSAGE_LABEL }]);
    setLoading(true);
    try {
      const opened = await conversation.current;
      // El text del missatge de veu l'envia el backend ja transcrit; el sobrescrivim en tornar.
      const reply = await sendTurn({
        session_id: opened.session_id,
        session_resource_id: opened.session_resource_id,
        scenario: KID_ASSISTANT_TYPE,
        level: CHILD_LEVEL,
        input_mode: voice ? 'voice' : 'text',
        text,
        audio_base64: voice || null,
        history: context,
        shown_exercises: messages.flatMap(m => (m.exercise ? [m.exercise.id] : [])),
        // El tutor del Nivell 0 pot enllaçar una lliçó: el catàleg és ací, així que s'envia (el servidor només el fa servir amb el Nivell 0).
        lessons: ALL_LESSONS.map(l => ({ id: l.id, title: l.title, summary: l.summary })),
        include_audio: false,
        pending_route_offer: pendingRouteOffer,
      }, abort.signal);
      // Amb este missatge, l'oferta pendent queda contestada: l'ha acceptada escrivint o ha parlat d'una altra cosa.
      if (pendingRouteOffer) markRouteOffer(pendingRouteOffer, reply.generate_route ? 'yes' : 'no');
      const routeOffer = reply.route_offer ? { topic: reply.route_offer } : undefined;
      setMood(reply.mood);
      const said = reply.transcription || text;
      setMessages(m => {
        const next = [...m];
        if (reply.transcription) next[next.length - 1] = { role: 'user', text: VOICE_MESSAGE_LABEL, transcription: reply.transcription };
        return [...next, { role: 'character', text: reply.reply_text, gnv: reply.gnv, conjugacio: reply.conjugacio, studyPath: reply.study_path, routeOffer, exercise: reply.exercise, activity: reply.activity, practiceOffer: reply.practice_offer, lessonId: reply.lesson_id }];
      });
      void addMessages(opened.session_resource_id, 'tutor', [
        { role: 'user', text: said || VOICE_MESSAGE_LABEL },
        { role: 'character', text: reply.reply_text, gnv: reply.gnv, conjugacio: reply.conjugacio, studyPath: reply.study_path, routeOffer, exercise: reply.exercise, activity: reply.activity, practiceOffer: reply.practice_offer, lessonId: reply.lesson_id },
      ]).catch(error => console.error('Error guardant la conversa:', error));
      // Els errors del xat amb el professor compten per a la ruta, però no es practiquen.
      if (reply.analyze_errors && said) {
        const analysis = analyzeMessage({ session_id: opened.session_id, session_resource_id: opened.session_resource_id, text: said }, { scenario: null, practicable: false });
        if (reply.correct_text) void showCorrections(opened.session_resource_id, analysis);
      }
      void speak(reply.reply_text);
      if (reply.generate_route) void buildRoute(reply.generate_route);
    } catch {
      // Aturada per l'usuari: no és un error, simplement no hi ha resposta.
      if (!abort.signal.aborted) setMessages(m => [...m, { role: 'character', text: ERROR_REPLY }]);
    } finally {
      turnAbort.current = null;
      setSending(false);
      setLoading(false);
    }
  };

  // Botó «Practica-ho»: es busca l'exercici del tema i es mostra dins del mateix missatge (o l'activitat, o l'avís).
  const [practicingId, setPracticingId] = useState<string | null>(null);
  const practice = async (offer: PracticeOffer) => {
    if (practicingId || offer.done) return;
    setPracticingId(offer.id);
    try {
      const result = await fetchTutorPractice(offer, messages.flatMap(m => (m.exercise ? [m.exercise.id] : [])));
      if (!mounted.current) return;
      setMessages(m => m.map(x => (x.practiceOffer?.id === offer.id ? { ...x, ...withPracticeResult(x, result) } : x)));
      void conversation.current
        ?.then(opened => savePracticeResult(opened.session_resource_id, offer.id, result))
        .catch(error => console.error("Error guardant l'exercici:", error));
    } catch (error) {
      console.error("Error buscant l'exercici:", error);
      if (mounted.current) addTutorMessage({ role: 'character', text: PRACTICE_ERROR_REPLY });
    } finally {
      setPracticingId(null);
    }
  };

  // L'aprenent respon l'exercici del catàleg mostrat en el xat: es marca, es guarda i es corregix com a pràctica.
  const answerExercise = (exercise: TutorExercise, chosen: string) => {
    setMessages(m => m.map(x => (x.exercise?.id === exercise.id && !x.exercise.chosen ? { ...x, exercise: { ...x.exercise, chosen } } : x)));
    void conversation.current
      ?.then(opened => saveExerciseAnswer(opened.session_resource_id, exercise.id, chosen))
      .catch(error => console.error("Error guardant la resposta de l'exercici:", error));
    void recordPracticeAnswers([{ exercise_id: exercise.id, answer: chosen }]).catch(error => console.error("Error registrant la resposta de l'exercici:", error));
  };

  return (
    <div className="relative z-20 flex min-h-0 flex-1 items-center gap-4 px-5 lg:justify-center lg:gap-8pb-6 pt-4 [@media(max-height:500px)_and_(orientation:landscape)]:flex-row [@media(max-height:500px)_and_(orientation:landscape)]:gap-5 [@media(max-height:500px)_and_(orientation:landscape)]:pb-3 [@media(max-height:500px)_and_(orientation:landscape)]:pt-2">
      {/* Tocant el professor ix el menú per a triar-li la veu. */}
      <div ref={robotRef} className="relative shrink-0" title="Toca'm per a canviar-me la veu">
        {isRobotAvatarEnabled('dashboard')
          ? <DashboardRobot className="drop-shadow-lg" size={avatarSize} talking={talking} thinking={thinking} mood={mood} onClick={() => setVoiceMenuOpen(open => !open)} />
          : <img src="/images/avatar_professor.svg" alt="El professor" className="float cursor-pointer drop-shadow-lg" width={avatarSize} height={avatarSize} onClick={() => setVoiceMenuOpen(open => !open)} />}
        {!voiceMenuOpen && (
          <button
            onClick={() => setVoiceMenuOpen(true)}
            className="absolute left-1/2 top-0 z-10 w-max max-w-full -translate-x-1/2 -translate-y-1/2 rounded-2xl lg:translate-y-0 bg-white px-3 py-1.5 text-center text-sm font-bold text-teal shadow-lg ring-2 ring-white after:absolute after:left-1/2 after:top-full after:-translate-x-1/2 after:border-8 after:border-transparent after:border-t-white after:content-['']"
          >
            Fes-me clic i canvia'm la veu!
          </button>
        )}
        {voiceMenuOpen && <RobotVoiceMenu anchor={robotRef} voice={voice} onChange={changeVoice} onClose={closeVoiceMenu} />}
      </div>

      <section className="flex min-h-0 w-full max-w-4xl flex-1 flex-col lg:self-stretch lg:pb-4 lg:max-w-[clamp(40rem,62vw,90rem)] [@media(max-height:500px)_and_(orientation:landscape)]:min-w-0 [@media(max-height:500px)_and_(orientation:landscape)]:flex-1" aria-label="Xat amb el professor" style={CHAT_FONT_STYLE}>
        <div
          ref={listRef}
          aria-live="polite"
          className="flex max-h-[36rem] min-h-24 flex-1 flex-col gap-3 overflow-y-auto rounded-3xl bg-white/85 p-4 shadow-lg ring-2 ring-white lg:max-h-none lg:min-h-0 lg:p-5[@media(max-height:500px)_and_(orientation:landscape)]:max-h-[calc(100dvh-var(--app-footer,0px)-14rem)]"
        >
          {openFailed && <p className="text-center text-[length:var(--chat-font,1.125rem)] font-bold text-orange">No hem pogut connectar amb el professor. Torna-ho a provar més tard.</p>}
          {!ready && !openFailed && <p className="text-center text-[length:var(--chat-font,1.125rem)] font-bold opacity-60">Un moment...</p>}
          {messages.map((m, i) => <ChatBubble key={i} role={m.role} text={m.text} transcription={m.transcription} gnv={m.gnv} conjugacio={m.conjugacio} studyPath={m.studyPath} routeOffer={m.routeOffer} exercise={m.exercise} activity={m.activity} practiceOffer={m.practiceOffer} practicing={practicingId === m.practiceOffer?.id} lessonId={m.lessonId} onAnswer={answerExercise} onRouteAnswer={answerRouteOffer} onPractice={practice} showHelp={showHelp} />)}
          {(loading || correcting || buildingRoute) && <p className="max-w-[85%] rounded-2xl bg-cream px-4 py-2 text-[length:var(--chat-font,1rem)] font-bold opacity-60"><ThinkingIndicator /></p>}
        </div>

        <div className="mt-3 flex items-center gap-3">
          <div className="min-w-0 flex-1">
            <VoiceInput onSend={send} disabled={!ready || loading || correcting || buildingRoute} />
          </div>
          {(sending || correcting) && (
            <button
              onClick={() => { if (correcting) correctionCancelled.current = true; setCorrecting(false); stopTurn(); }}
              aria-label="Atura la resposta del professor"
              title="Atura la resposta del professor"
              className="btn-press grid h-12 w-12 shrink-0 place-items-center rounded-full bg-white/90 text-red-600 shadow-lg ring-2 ring-white"
            >
              <Square size={20} fill="currentColor" />
            </button>
          )}
          <button
            onClick={() => void restart()}
            disabled={!ready || loading}
            aria-label="Torna a començar la conversa"
            title="Torna a començar la conversa"
            className="btn-press grid h-12 w-12 shrink-0 place-items-center rounded-full bg-white/90 text-orange shadow-lg ring-2 ring-white disabled:opacity-40"
          >
            <RotateCcw size={22} />
          </button>
          <button
            onClick={replay}
            disabled={!lastReply}
            aria-label="Torna a escoltar el professor"
            aria-busy={showVoiceLoading}
            title={showVoiceLoading ? "Carregant l'àudio…" : 'Torna a escoltar el professor'}
            className="btn-press grid h-12 w-12 shrink-0 place-items-center rounded-full bg-white/90 text-teal shadow-lg ring-2 ring-white disabled:opacity-40"
          >
            {showVoiceLoading ? <Loader2 size={22} className="animate-spin" /> : <Volume2 size={22} />}
          </button>
        </div>
      </section>
    </div>
  );
}
