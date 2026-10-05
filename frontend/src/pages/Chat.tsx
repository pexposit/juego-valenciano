import { useEffect, useRef, useState } from 'react';
import { MessageCircle, Target, Volume2, X } from 'lucide-react';
import { SceneArt } from '../components/SceneArt';
import { VoiceInput } from '../components/VoiceInput';
import { HistoryModal, type Msg } from '../components/HistoryModal';
import { ensureSession, fetchTts, finishSessionResource, sendTurn, startSessionResource, type HistoryItem } from '../lib/api';
import type { Mood, Scenario } from '../lib/types';
import { GREETING_BY_VOICE } from '../data/content';
import { isVoiceOnlyCategory } from '@parlaval/shared';

const INITIAL_GREETING = 'Bon dia! Com et puc ajudar hui?';
const VOICE_MESSAGE_LABEL = '🎙️ Missatge de veu';
const ERROR_REPLY = "No t'he sentit bé, pots repetir-ho?";
const TTS_ATTEMPTS = 2;
const ROUND_BUTTON = 'btn-press grid h-10 w-10 place-items-center rounded-full bg-white/90 shadow backdrop-blur-sm hover:bg-white transition-colors';

export function Chat({
  scenario, category, title, voice, background, initialPrompt, actor, summary, objectives, level, xp, onXpGained, onEnd, onBack,
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
  // Nom i rol del personatge (resources.metadata.character, p. ex. "Vicent, venedor del mercat"),
  // mostrat tal qual en una etiqueta davall l'actor.
  actor: string | null;
  // Quadre d'objectius: el resum de la situació (resources.content) i les tasques (metadata.objectius).
  summary: string | null;
  objectives: string[];
  level: string;
  xp: number;
  onXpGained: (delta: number) => void;
  onEnd: () => void;
  onBack: () => void;
}) {
  const [mood, setMood] = useState<Mood>('neutral');
  const [character, setCharacter] = useState(initialPrompt || INITIAL_GREETING);
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
    const audio = source ? new Audio(source) : null;
    setTalking(false); // [robot-avatar]
    if (audio) { audio.onplay = () => setTalking(true); audio.onpause = audio.onended = () => setTalking(false); } // [robot-avatar]
    replyAudio.current = audio;
    setAudioSource(source);
    if (audio && autoplay) void audio.play().catch(() => {});
  };

  // Solo TTS real (matxa). Si falla tras los reintentos se queda sin audio y el
  // usuario puede reintentar.
  const loadTextAudio = async (text: string, autoplay = false) => {
    for (let attempt = 1; attempt <= TTS_ATTEMPTS; attempt += 1) {
      try {
        return setReplyAudio(await fetchTts(text, scenario), autoplay);
      } catch {
        if (attempt === TTS_ATTEMPTS) setReplyAudio(undefined);
      }
    }
  };

  // Tanca el recurs (no la sessió, que es tanca en fer logout) i el backend
  // llança l'avaluació pedagògica d'aquest escenari en segon pla.
  const finishActivity = () => {
    const opened = openedActivity.current;
    if (opened) void finishSessionResource(opened.sessionId, opened.sessionResourceId);
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
        : [{ role: 'character', content_text: character }];
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
      setCharacter(r.reply_text);
      setUserTranscription(transcription);
      setMood(r.mood);
      onXpGained(r.xp_delta);
      setHistory(h => [...h, { role: 'user', text: userLabel, transcription }, { role: 'character', text: r.reply_text }]);
      if (r.reply_audio_base64) {
        setReplyAudio(`data:${r.reply_audio_mime_type || 'audio/mpeg'};base64,${r.reply_audio_base64}`, true);
      } else {
        void loadTextAudio(r.reply_text, true);
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
    <main className="relative h-[100dvh] overflow-hidden">
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
          {summary && <p className="mb-3 text-sm font-bold opacity-70">{summary}</p>}
          {objectives.length > 0 && (
            <ol className="flex list-decimal flex-col gap-1.5 pl-5 text-sm font-bold">
              {objectives.map(o => <li key={o}>{o}</li>)}
            </ol>
          )}
        </aside>
      )}

      {/* Character bubble with entrance animation */}
      <section key={`char-${bubbleKey}`} className="bubble-enter bubble bubble-to-avatar absolute left-[8%] top-[17%] z-10 max-w-[min(72%,440px)] rounded-3xl bg-white p-5 font-bold shadow-xl text-base [@media(max-height:500px)_and_(orientation:landscape)]:left-3 [@media(max-height:500px)_and_(orientation:landscape)]:top-14 [@media(max-height:500px)_and_(orientation:landscape)]:max-w-[56%] [@media(max-height:500px)_and_(orientation:landscape)]:p-3 [@media(max-height:500px)_and_(orientation:landscape)]:text-sm">
        <div className="[@media(max-height:500px)_and_(orientation:landscape)]:max-h-[calc(100dvh-10.5rem)] [@media(max-height:500px)_and_(orientation:landscape)]:overflow-y-auto">
        <p className="leading-relaxed">
          {loading ? <span className="opacity-50">El personatge està escrivint…</span> : character}
        </p>
        {!loading && (
          <>
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
          className="btn-press mx-auto mt-3 block rounded-full bg-white/80 px-4 py-2 text-xs font-extrabold backdrop-blur-sm hover:bg-white transition-colors"
        >
          Acabar conversa
        </button>
      </div>

      {showHistory && <HistoryModal messages={history} onClose={() => setShowHistory(false)} />}
    </main>
  );
}
