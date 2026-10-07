import { useEffect, useRef, useState } from 'react';
import { MessageCircle, Target, Volume2, X } from 'lucide-react';
import { AudioLoading, useDelayedFlag } from '../components/AudioLoading';
import { SceneArt } from '../components/SceneArt';
import { VoiceInput } from '../components/VoiceInput';
import { HistoryModal, type Msg } from '../components/HistoryModal';
import { analyzeMessage, ensureSession, fetchTts, finishSessionResource, sendTurn, startSessionResource, type HistoryItem } from '../lib/api';
import { addMessages } from '../lib/localStore';
import type { Mood, Scenario, ScenarioTranslation } from '../lib/types';
import { GREETING_BY_VOICE } from '../data/content';
import { isVoiceOnlyCategory } from '@parlaval/shared';

const INITIAL_GREETING = 'Bon dia! Com et puc ajudar hui?';
const VOICE_MESSAGE_LABEL = '🎙️ Missatge de veu';
const ERROR_REPLY = "No t'he sentit bé, pots repetir-ho?";
const TTS_ATTEMPTS = 2;
const ROUND_BUTTON = 'btn-press grid h-10 w-10 place-items-center rounded-full bg-white/90 shadow backdrop-blur-sm hover:bg-white transition-colors';

export function Chat({
  scenario, category, title, voice, background, initialPrompt, greetingAudio, actor, summary, objectives, translation, level, xp, onXpGained, onEnd, onBack,
}: {
  scenario: Scenario;
  // Categoria del recurs a la BDD: 'escenari' o una àrea de conversa del temari.
  category: string;
  title: string;
  // Veu TTS i foto de fons de l'escenari (resources.metadata).
  voice: string | null;
  background: string | null;
  // Primer missatge del personatge (resources.metadata.initial_prompt); si no en té, es fa servir la salutació genèrica.
  initialPrompt: string | null;
  // Àudio estàtic de la salutació (resources.metadata.greeting_audio, generat amb matxa), si n'hi ha.
  greetingAudio?: string | null;
  // Nom i rol del personatge (resources.metadata.character, p. ex. "Vicent, venedor del mercat"),
  // mostrat tal qual en una etiqueta davall l'actor.
  actor: string | null;
  // Quadre d'objectius: el resum de la situació (resources.content) i les tasques (metadata.objectius).
  summary: string | null;
  objectives: string[];
  // Traducció de l'escenari a la llengua materna (subtítols), o null si no n'hi ha o no estan activats.
  translation?: ScenarioTranslation | null;
  level: string;
  xp: number;
  onXpGained: (delta: number) => void;
  onEnd: () => void;
  onBack: () => void;
}) {
  const [mood, setMood] = useState<Mood>('neutral');
  // Salutació del personatge (primer missatge de la conversa), amb la traducció si n'hi ha.
  const [greeting] = useState(() => {
    const text = initialPrompt || INITIAL_GREETING;
    return translation?.initial_prompt ? `${text}
${translation.initial_prompt}` : text;
  });
  const [character, setCharacter] = useState(greeting);
  // La primera línia del personatge és en valencià i la resta, la traducció (subtítol).
  const [characterText, ...characterHelp] = character.split('\n');
  const [user, setUser] = useState('');
  const [userTranscription, setUserTranscription] = useState<string>();
  const [loading, setLoading] = useState(false);
  const [history, setHistory] = useState<Msg[]>([]);
  const [showHistory, setShowHistory] = useState(false);
  // En pantalles estretes el quadre tapa la bombolla del personatge: comença tancat.
  const [showObjectives, setShowObjectives] = useState(() => window.matchMedia('(min-width: 768px) and (min-height: 501px)').matches);
  const hasObjectives = Boolean(summary) || objectives.length > 0;
  const [bubbleKey, setBubbleKey] = useState(0);
  const [audioSource, setAudioSource] = useState<string>();
  const [talking, setTalking] = useState(false); // [robot-avatar] true mentre sona l'àudio del personatge
  const replyAudio = useRef<HTMLAudioElement | null>(null);
  // false quan s'ix de la pantalla: para l'àudio i evita que en comence un altre amb una resposta que arriba tard.
  const alive = useRef(true);
  // Número de l'última petició d'àudio: si en arriba una de vella (la salutació, en reaccionar ràpid), es descarta.
  const audioRequest = useRef(0);
  // true mentre l'àudio del personatge es demana o es descarrega i encara no pot sonar.
  const [audioLoading, setAudioLoading] = useState(false);
  const showAudioLoading = useDelayedFlag(audioLoading);
  useEffect(() => {
    alive.current = true;
    return () => {
      alive.current = false;
      replyAudio.current?.pause();
    };
  }, []);
  const hasSubmitted = useRef(false);
  // Sessió del login + entrada de session_resource d'aquest escenari. Es guarda
  // la promesa perquè el primer torn puga esperar-la i perquè StrictMode no
  // en cree dues en muntar el component dues vegades.
  const activity = useRef<Promise<{ sessionId: string; sessionResourceId: string }>>();
  const openedActivity = useRef<{ sessionId: string; sessionResourceId: string }>();

  const openActivity = () => {
    activity.current ??= (async () => {
      const sessionId = await ensureSession(level);
      const { id } = await startSessionResource(sessionId, scenario, category);
      openedActivity.current = { sessionId, sessionResourceId: id };
      return openedActivity.current;
    })().catch(error => {
      // Permet tornar-ho a provar en el següent torn.
      activity.current = undefined;
      throw error;
    });
    return activity.current;
  };

  // Nunca se usa la voz del navegador (speechSynthesis): solo audio generado
  // por el backend o los saludos pregenerados.
  const setReplyAudio = (source: string | undefined, autoplay = false) => {
    if (!alive.current) return; // la pantalla ja s'ha tancat: un àudio que arriba tard no ha de sonar
    replyAudio.current?.pause(); // l'anterior no ha de continuar sonant per davall del nou
    const audio = source ? new Audio(source) : null;
    setAudioLoading(Boolean(audio));
    if (audio) audio.oncanplay = audio.onerror = () => setAudioLoading(false);
    setTalking(false); // [robot-avatar]
    if (audio) { audio.onplay = () => setTalking(true); audio.onpause = audio.onended = () => setTalking(false); } // [robot-avatar]
    replyAudio.current = audio;
    setAudioSource(source);
    if (audio && autoplay) void audio.play().catch(() => {});
  };

  // Solo TTS real (matxa). Si falla tras los reintentos se queda sin audio y el
  // usuario puede reintentar.
  const loadTextAudio = async (text: string, autoplay = false) => {
    const mine = ++audioRequest.current;
    setAudioLoading(true);
    for (let attempt = 1; attempt <= TTS_ATTEMPTS; attempt += 1) {
      try {
        const source = await fetchTts(text, scenario);
        if (mine !== audioRequest.current) return; // n'hi ha una petició més nova: esta ja no cal
        return setReplyAudio(source, autoplay);
      } catch {
        if (attempt === TTS_ATTEMPTS) setReplyAudio(undefined);
      }
    }
  };

  // Tanca el recurs (no la sessió, que es tanca en fer logout) i el backend en fa l'avaluació
  // pedagògica. En el Nivell 0 s'envia la conversa, per a revisar-ne els objectius.
  const finishActivity = () => {
    const opened = openedActivity.current;
    if (opened) {
      void finishSessionResource(opened.sessionId, opened.sessionResourceId, { includeMessages: level === 'nivell0' })
        .catch(error => console.error("Error tancant l'escenari:", error));
    }
  };
  const handleExit = () => {
    finishActivity();
    onBack();
  };
  // «Acabar conversa» també tanca el recurs: així sempre s'avalua i s'actualitza la ruta.
  const handleEnd = () => {
    finishActivity();
    onEnd();
  };

  const replayCharacter = () => {
    const audio = replyAudio.current;
    if (!audio) return;
    audio.currentTime = 0;
    void audio.play().catch(() => {});
  };

  // Salutació pregenerada: fitxer estàtic servit per Vite, es reprodueix en obrir
  // l'escenari sense processar res (autoplay si el navegador ho permet; sinó,
  // el botó de repetir la llança amb un gest de l'usuari). Només és vàlida quan
  // l'escenari no té una salutació pròpia (initial_prompt), ja que el fitxer
  // pregenerat només diu el text genèric; si no, es genera amb el TTS.
  useEffect(() => {
    if (hasSubmitted.current) return;
    if (greetingAudio) {
      // Només si el fitxer existix de veritat (Vite torna la pàgina d'inici per als que falten).
      let cancelled = false;
      void fetch(greetingAudio, { method: 'HEAD' })
        .then(res => res.ok && (res.headers.get('content-type') ?? '').startsWith('audio'))
        .catch(() => false)
        .then(found => {
          if (cancelled || hasSubmitted.current) return;
          if (found) setReplyAudio(greetingAudio, true);
          else void loadTextAudio(initialPrompt || INITIAL_GREETING, true);
        });
      return () => { cancelled = true; };
    }
    const greeting = !initialPrompt && voice ? GREETING_BY_VOICE[voice] : undefined;
    if (greeting) setReplyAudio(greeting, true);
    else void loadTextAudio(initialPrompt || INITIAL_GREETING, true);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [scenario, voice]);

  // En entrar a l'escenari es crea la seua entrada a session_resource.
  useEffect(() => {
    openActivity().catch(error => console.error('Error obrint l\'escenari:', error));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const submit = async (text: string, audio?: string) => {
    if ((!text && !audio) || loading) return;
    const userLabel = text || VOICE_MESSAGE_LABEL;
    hasSubmitted.current = true;
    audioRequest.current += 1; // cancel·la l'àudio que encara s'estiga demanant
    setReplyAudio(undefined);
    setUser(userLabel);
    setUserTranscription(undefined);
    setBubbleKey(k => k + 1);
    setLoading(true);
    try {
      const { sessionId, sessionResourceId } = await openActivity();
      // El personatge ha de recordar el que s'ha dit: li enviem el context de la
      // conversa actual (el primer missatge inclou el salut inicial del personatge).
      const context: HistoryItem[] = history.length > 0
        ? history.map((m) => ({ role: m.role, content_text: m.text }))
        : [{ role: 'character', content_text: characterText }];
      // include_audio:false → el turno responde solo con texto (el usuario ve la
      // respuesta al instante) y el audio se pide en paralelo a /api/tts.
      const r = await sendTurn({
        session_id: sessionId,
        session_resource_id: sessionResourceId,
        scenario,
        level,
        input_mode: audio ? 'voice' : 'text',
        text,
        audio_base64: audio || null,
        history: context,
        include_audio: false,
      });
      const transcription = r.transcription || undefined;
      const said = transcription ?? text;
      // La conversa es guarda només en este navegador; el primer cop, amb la salutació del personatge.
      void addMessages(sessionResourceId, 'scenario', [
        ...(history.length === 0 ? [{ role: 'character' as const, text: greeting }] : []),
        { role: 'user', text: said || userLabel },
        { role: 'character', text: r.reply_text },
      ]).catch(error => console.error('Error guardant la conversa:', error));
      // Els errors del missatge es busquen a banda, sense fer esperar la resposta.
      if (r.analyze_errors && said) {
        analyzeMessage({ session_id: sessionId, session_resource_id: sessionResourceId, text: said }, { scenario: title, practicable: true });
      }
      setCharacter(r.reply_text);
      setUserTranscription(transcription);
      setMood(r.mood);
      onXpGained(r.xp_delta);
      setHistory(h => [...h, { role: 'user', text: userLabel, transcription }, { role: 'character', text: r.reply_text }]);
      if (r.reply_audio_base64) {
        setReplyAudio(`data:${r.reply_audio_mime_type || 'audio/mpeg'};base64,${r.reply_audio_base64}`, true);
      } else {
        void loadTextAudio(r.reply_text.split('\n')[0], true);
      }
    } catch {
      setCharacter(ERROR_REPLY);
      setMood('confus');
      void loadTextAudio(ERROR_REPLY);
    } finally {
      setLoading(false);
    }
  };

  return (
    <main className="relative h-[calc(100dvh-var(--app-footer,0px))] overflow-hidden">
      <SceneArt scenario={scenario} background={background} mood={mood} thinking={loading} talking={talking} />

      {/* Nom i rol de l'actor, davall seu (resources.metadata.character). */}
      {actor && (
        <div
          className="absolute left-1/2 top-[76%] z-10 [@media(max-height:500px)_and_(orientation:landscape)]:hidden max-w-[90vw] -translate-x-1/2 truncate rounded-full px-3 py-1 text-sm font-black uppercase tracking-wide [@media(max-width:1023px)_and_(orientation:portrait)]:top-[68%] sm:px-4 sm:py-1.5 sm:text-base sm:tracking-wider lg:text-xl text-slate-800 shadow-md backdrop-blur-sm"
          style={{ background: 'rgba(255,255,255,0.92)' }}
        >
          {actor}
        </div>
      )}

      {/* Top bar */}
      <header className="absolute inset-x-0 top-0 z-10 flex items-center justify-between p-4">
        <div className="flex items-center gap-3">
          <button
            onClick={handleExit}
            id="chat-back-btn"
            className="btn-press rounded-full bg-white/90 px-4 py-2 font-bold shadow backdrop-blur-sm hover:bg-white transition-colors"
          >
            ← Eixir
          </button>
          <span
            className="max-w-[26vw] truncate rounded-full px-3.5 py-1.5 text-xs font-black tracking-wider uppercase shadow-md text-slate-800 border border-white/40 backdrop-blur-sm sm:max-w-none"
            style={{ background: 'rgba(255,255,255,0.92)' }}
          >
            {title}
          </span>
        </div>
        <div
          className="absolute left-1/2 hidden -translate-x-1/2 rounded-full px-4 py-2 text-sm font-black shadow backdrop-blur-sm sm:block"
          style={{ background: 'rgba(255,255,255,0.9)' }}
        >
          ⚡ {xp} XP
        </div>
        <div className="flex items-center gap-2">
          {hasObjectives && (
            <button
              onClick={() => setShowObjectives(v => !v)}
              id="chat-objectives-btn"
              aria-label="Objectius"
              aria-pressed={showObjectives}
              className={ROUND_BUTTON}
            >
              <Target size={19} />
            </button>
          )}
          <button
            onClick={() => setShowHistory(true)}
            id="chat-history-btn"
            className={ROUND_BUTTON}
          >
            <MessageCircle size={19} />
          </button>
        </div>
      </header>

      {/* Quadre d'objectius de l'escenari */}
      {hasObjectives && showObjectives && (
        <aside
          id="chat-objectives"
          className="absolute right-5 top-20 z-20 max-h-[calc(100dvh-11rem)] w-[min(calc(100%-2.5rem),320px)] overflow-y-auto rounded-3xl bg-white/95 p-5 shadow-xl backdrop-blur-sm [@media(max-height:500px)_and_(orientation:landscape)]:inset-x-3 [@media(max-height:500px)_and_(orientation:landscape)]:top-14 [@media(max-height:500px)_and_(orientation:landscape)]:max-h-[calc(100dvh-8.5rem)] [@media(max-height:500px)_and_(orientation:landscape)]:w-auto [@media(max-height:500px)_and_(orientation:landscape)]:p-3"
        >
          <div className="mb-2 flex items-center justify-between gap-2">
            <h2 className="flex items-center gap-2 text-sm font-black uppercase tracking-wider" style={{ color: '#0F47AF' }}>
              <Target size={16} /> Objectius
            </h2>
            <button onClick={() => setShowObjectives(false)} aria-label="Tancar els objectius" className="btn-press rounded-full p-1 opacity-60 hover:opacity-100">
              <X size={16} />
            </button>
          </div>
          {summary && (
            <p className="mb-3 text-sm font-bold opacity-70">
              {summary}
              {translation?.content && <span className="mt-0.5 block text-xs font-semibold text-slate-400">{translation.content}</span>}
            </p>
          )}
          {objectives.length > 0 && (
            <ol className="flex list-decimal flex-col gap-1.5 pl-5 text-sm font-bold">
              {objectives.map((o, i) => (
                <li key={o}>
                  {o}
                  {translation?.objectius[i] && <span className="block text-xs font-semibold text-slate-400">{translation.objectius[i]}</span>}
                </li>
              ))}
            </ol>
          )}
        </aside>
      )}

      {/* Character bubble with entrance animation */}
      <section key={`char-${bubbleKey}`} className="bubble-enter bubble bubble-to-avatar absolute left-[8%] top-[17%] z-10 max-w-[min(72%,440px)] rounded-3xl bg-white p-5 font-bold shadow-xl text-base [@media(max-height:500px)_and_(orientation:landscape)]:left-3 [@media(max-height:500px)_and_(orientation:landscape)]:top-14 [@media(max-height:500px)_and_(orientation:landscape)]:max-w-[56%] [@media(max-height:500px)_and_(orientation:landscape)]:p-3 [@media(max-height:500px)_and_(orientation:landscape)]:text-sm">
        <div className="[@media(max-height:500px)_and_(orientation:landscape)]:max-h-[calc(100dvh-10.5rem)] [@media(max-height:500px)_and_(orientation:landscape)]:overflow-y-auto">
        <p className="leading-relaxed">
          {loading ? <span className="opacity-50">El personatge està escrivint…</span> : characterText}
        </p>
        {!loading && translation && characterHelp.length > 0 && (
          <p className="mt-1 whitespace-pre-line text-sm font-semibold text-slate-400">{characterHelp.join('\n')}</p>
        )}
        {!loading && (
          <>
            {showAudioLoading && <AudioLoading className="mt-3" />}
            <button
              onClick={replayCharacter}
              className="btn-press mt-3 flex items-center gap-1 text-sm font-extrabold"
              style={{ color: '#0F47AF' }}
            >
              <Volume2 size={15} /> Escolta de nou
            </button>
            {audioSource && (
              <audio
                controls
                preload="auto"
                src={audioSource}
                onPlay={() => setTalking(true)} onPause={() => setTalking(false)} onEnded={() => setTalking(false)} // [robot-avatar]
                className="mt-2 h-9 w-full max-w-xs"
                aria-label="Àudio de la resposta"
              />
            )}
          </>
        )}
              </div>
      </section>

      {/* User bubble with entrance animation */}
      {user && (
        <div
          key={`user-${bubbleKey}`}
          className="user-bubble-enter user-bubble absolute bottom-36 right-5 z-10 max-w-[70%] [@media(max-height:500px)_and_(orientation:landscape)]:bottom-24 [@media(max-height:500px)_and_(orientation:landscape)]:max-w-[40%] [@media(max-height:500px)_and_(orientation:landscape)]:p-2 [@media(max-height:500px)_and_(orientation:landscape)]:text-sm rounded-3xl p-4 font-bold text-white shadow-lg"
          style={{ background: '#0F47AF' }}
        >
          <p>{user}</p>
          {userTranscription && <p className="mt-2 border-t border-white/30 pt-2 text-sm font-normal">Transcripció: {userTranscription}</p>}
        </div>
      )}

      {/* Input */}
      <div className="absolute inset-x-4 bottom-5 z-20">
        <VoiceInput onSend={submit} disabled={loading} voiceOnly={isVoiceOnlyCategory(category)} />
        <button
          onClick={handleEnd}
          id="chat-end-btn"
          className="btn-press mx-auto mt-3 block rounded-full bg-white/80 px-6 py-2.5 text-lg font-extrabold backdrop-blur-sm hover:bg-white transition-colors"
        >
          Acabar conversa
        </button>
      </div>

      {showHistory && <HistoryModal messages={history} showHelp={Boolean(translation)} onClose={() => setShowHistory(false)} />}
    </main>
  );
}
