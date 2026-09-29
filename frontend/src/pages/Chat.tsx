import { useEffect, useRef, useState } from 'react';
import { MessageCircle, Volume2 } from 'lucide-react';
import { SceneArt } from '../components/SceneArt';
import { VoiceInput } from '../components/VoiceInput';
import { HistoryModal, type Msg } from '../components/HistoryModal';
import { createSession, fetchTts, finishSession, sendTurn, type HistoryItem } from '../lib/api';
import type { Mood, Scenario } from '../lib/types';
import { GREETING_BY_SCENARIO, scenarioName } from '../data/content';

const INITIAL_GREETING = 'Bon dia! Com et puc ajudar hui?';
const VOICE_MESSAGE_LABEL = '🎙️ Missatge de veu';
const ERROR_REPLY = "No t'he sentit bé, pots repetir-ho?";
const TTS_ATTEMPTS = 2;
const ROUND_BUTTON = 'btn-press grid h-10 w-10 place-items-center rounded-full bg-white/90 shadow backdrop-blur-sm hover:bg-white transition-colors';

export function Chat({
  scenario, level, xp, onXpGained, onEnd, onBack,
}: {
  scenario: Scenario;
  level: string;
  xp: number;
  onXpGained: (delta: number) => void;
  onEnd: () => void;
  onBack: () => void;
}) {
  const [mood, setMood] = useState<Mood>('neutral');
  const [character, setCharacter] = useState(INITIAL_GREETING);
  const [user, setUser] = useState('');
  const [userTranscription, setUserTranscription] = useState<string>();
  const [loading, setLoading] = useState(false);
  const [history, setHistory] = useState<Msg[]>([]);
  const [showHistory, setShowHistory] = useState(false);
  const [session, setSession] = useState<string>();
  const [bubbleKey, setBubbleKey] = useState(0);
  const [audioSource, setAudioSource] = useState<string>();
  const replyAudio = useRef<HTMLAudioElement | null>(null);
  const hasSubmitted = useRef(false);
  const sessionPromise = useRef<Promise<string>>();

  // Crea la sessió (i el vincle session_resource al backend) en entrar a
  // l'escenari, no en el primer missatge: un mateix escenari no ha de crear
  // dos sessions encara que `submit` també la demane abans que acabe açò.
  const getSession = () => {
    if (!sessionPromise.current) {
      sessionPromise.current = createSession(scenario, level).then(id => { setSession(id); return id; });
    }
    return sessionPromise.current;
  };

  useEffect(() => {
    getSession().catch(() => {});
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [scenario]);

  // Nunca se usa la voz del navegador (speechSynthesis): solo audio generado
  // por el backend o los saludos pregenerados.
  const setReplyAudio = (source: string | undefined, autoplay = false) => {
    const audio = source ? new Audio(source) : null;
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

  // Si no ha arribat a iniciar cap sessió amb el personatge, eixim sense fer
  // petició. Avisa el backend perquè llance l'avaluació pedagògica en segon pla.
  const handleExit = () => {
    if (session) void finishSession(session);
    onBack();
  };

  const replayCharacter = () => {
    const audio = replyAudio.current;
    if (!audio) return;
    audio.currentTime = 0;
    void audio.play().catch(() => {});
  };

  // Salutació pregenerada: fitxer estàtic servit per Vite, es reprodueix en obrir
  // l'escenari sense processar res (autoplay si el navegador ho permet; sinó,
  // el botó de repetir la llança amb un gest de l'usuari).
  useEffect(() => {
    if (!hasSubmitted.current) setReplyAudio(GREETING_BY_SCENARIO[scenario], true);
  }, [scenario]);

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
      const activeSession = session || await getSession();
      // El personatge ha de recordar el que s'ha dit: li enviem el context de la
      // conversa actual (el primer missatge inclou el salut inicial del personatge).
      const context: HistoryItem[] = history.length > 0
        ? history.map((m) => ({ role: m.role, content_text: m.text }))
        : [{ role: 'character', content_text: character }];
      // include_audio:false → el turno responde solo con texto (el usuario ve la
      // respuesta al instante) y el audio se pide en paralelo a /api/tts.
      const r = await sendTurn({
        session_id: activeSession,
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
      <SceneArt scenario={scenario} mood={mood} />

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
            className="rounded-full px-3.5 py-1.5 text-xs font-black tracking-wider uppercase shadow-md text-slate-800 border border-white/40 backdrop-blur-sm"
            style={{ background: 'rgba(255,255,255,0.92)' }}
          >
            {scenarioName(scenario)}
          </span>
        </div>
        <div
          className="absolute left-1/2 -translate-x-1/2 rounded-full px-4 py-2 text-sm font-black shadow backdrop-blur-sm"
          style={{ background: 'rgba(255,255,255,0.9)' }}
        >
          ⚡ {xp} XP
        </div>
        <div className="flex items-center gap-2">
          <button
            onClick={() => setShowHistory(true)}
            id="chat-history-btn"
            className={ROUND_BUTTON}
          >
            <MessageCircle size={19} />
          </button>
        </div>
      </header>

      {/* Character bubble with entrance animation */}
      <section key={`char-${bubbleKey}`} className="bubble-enter bubble absolute left-5 top-[13%] z-10 max-w-[min(76%,440px)] rounded-3xl bg-white p-5 font-bold shadow-xl text-base">
        <p className="leading-relaxed">
          {loading ? <span className="opacity-50">El personatge està escrivint…</span> : character}
        </p>
        {!loading && (
          <>
            <button
              onClick={replayCharacter}
              className="btn-press mt-3 flex items-center gap-1 text-sm font-extrabold"
              style={{ color: '#0D9488' }}
            >
              <Volume2 size={15} /> Escolta de nou
            </button>
            {audioSource && (
              <audio
                controls
                preload="auto"
                src={audioSource}
                className="mt-2 h-9 w-full max-w-xs"
                aria-label="Àudio de la resposta"
              />
            )}
          </>
        )}
      </section>

      {/* User bubble with entrance animation */}
      {user && (
        <div
          key={`user-${bubbleKey}`}
          className="user-bubble-enter user-bubble absolute bottom-36 right-5 z-10 max-w-[70%] rounded-3xl p-4 font-bold text-white shadow-lg"
          style={{ background: '#0D9488' }}
        >
          <p>{user}</p>
          {userTranscription && <p className="mt-2 border-t border-white/30 pt-2 text-sm font-normal">Transcripció: {userTranscription}</p>}
        </div>
      )}

      {/* Input */}
      <div className="absolute inset-x-4 bottom-5 z-20">
        <VoiceInput onSend={submit} disabled={loading} />
        <button
          onClick={onEnd}
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
