import { useEffect, useRef, useState } from 'react';
import { RotateCcw, Volume2 } from 'lucide-react';
import { KID_ASSISTANT_TYPE } from '@parlaval/shared';
import { ChatBubble } from './ChatBubble';
import { VoiceInput } from './VoiceInput';
import { DashboardRobot, isRobotAvatarEnabled } from '../features/robot-avatar'; // [robot-avatar]
import { ensureSession, fetchTts, openAssistant, restartAssistant, sendTurn, type AssistantConversation, type HistoryItem } from '../lib/api';

type Message = AssistantConversation['messages'][number];

// Els xiquets comencen en principiant (és el que fixa el registre infantil).
const CHILD_LEVEL = 'principiant';
const VOICE_MESSAGE_LABEL = '🎙️ Missatge de veu';
const ERROR_REPLY = "No t'he sentit bé, pots repetir-ho?";
const TTS_ATTEMPTS = 2;

// Xat del tauler infantil: el xiquet pregunta al professor dubtes de valencià, escrivint o parlant.
// Reutilitza el xat de les activitats (/api/turn): els missatges es guarden a la BDD i la
// conversa continua entre visites. El professor també respon en veu alta.
export function ChildAssistant({ showHelp, level }: { showHelp: boolean; level: string }) {
  const [messages, setMessages] = useState<Message[]>([]);
  const [ready, setReady] = useState(false);
  const [openFailed, setOpenFailed] = useState(false);
  const [loading, setLoading] = useState(false);
  const [talking, setTalking] = useState(false);
  const listRef = useRef<HTMLDivElement>(null);
  const audio = useRef<{ text: string; element: HTMLAudioElement } | null>(null);
  // Es guarda la promesa perquè el primer torn la puga esperar i perquè StrictMode no obri la conversa dues vegades.
  const conversation = useRef<Promise<AssistantConversation>>();

  const stopAudio = () => {
    audio.current?.element.pause();
    audio.current = null;
    setTalking(false);
  };

  // Reprodueix el text amb la veu del professor (TTS del backend; mai la del navegador).
  const speak = async (text: string) => {
    stopAudio();
    // Només la primera línia (en valencià): la resta és l'ajuda en la llengua materna del xiquet.
    const spoken = text.split('\n')[0].trim();
    for (let attempt = 1; attempt <= TTS_ATTEMPTS; attempt += 1) {
      try {
        const element = new Audio(await fetchTts(spoken, KID_ASSISTANT_TYPE));
        element.onplay = () => setTalking(true);
        element.onpause = element.onended = () => setTalking(false);
        audio.current = { text, element };
        return void element.play().catch(() => {}); // sense gest de l'usuari el navegador pot bloquejar l'autoplay
      } catch {
        // Es torna a provar; si falla sense àudio, el botó de repetir ho reintenta.
      }
    }
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
    return () => { cancelled = true; stopAudio(); };
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

  const send = async (text: string, voice?: string) => {
    if ((!text && !voice) || loading || !conversation.current) return;
    stopAudio();
    const context: HistoryItem[] = messages.map(m => ({ role: m.role, content_text: m.text }));
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
        include_audio: false,
      });
      setMessages(m => {
        const next = [...m];
        if (reply.transcription) next[next.length - 1] = { role: 'user', text: reply.transcription };
        return [...next, { role: 'character', text: reply.reply_text }];
      });
      void speak(reply.reply_text);
    } catch {
      setMessages(m => [...m, { role: 'character', text: ERROR_REPLY }]);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="relative z-20 flex flex-col items-center gap-4 px-5 pb-10 pt-4">
      {isRobotAvatarEnabled('dashboard')
        ? <DashboardRobot className="drop-shadow-lg" size={320} talking={talking} thinking={loading} />
        : <img src="/images/avatar_professor.svg" alt="El professor" className="float drop-shadow-lg" width={320} height={320} />}

      <section className="w-full max-w-4xl" aria-label="Xat amb el professor">
        <div
          ref={listRef}
          aria-live="polite"
          className="flex max-h-[clamp(10rem,calc(100dvh_-_34rem),36rem)] min-h-24 flex-col gap-3 overflow-y-auto rounded-3xl bg-white/85 p-4 shadow-lg ring-2 ring-white"
        >
          {openFailed && <p className="text-center text-lg font-bold text-orange">No hem pogut connectar amb el professor. Torna-ho a provar més tard.</p>}
          {!ready && !openFailed && <p className="text-center text-lg font-bold opacity-60">Un moment...</p>}
          {messages.map((m, i) => <ChatBubble key={i} role={m.role} text={m.text} showHelp={showHelp} onlyHelp={showHelp && level === 'nivell0'} />)}
          {loading && <p className="max-w-[85%] rounded-2xl bg-cream px-4 py-2 text-xl font-bold opacity-60">...</p>}
        </div>

        <div className="mt-3 flex items-center gap-3">
          <div className="min-w-0 flex-1">
            <VoiceInput onSend={send} disabled={!ready || loading} />
          </div>
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
            title="Torna a escoltar el professor"
            className="btn-press grid h-12 w-12 shrink-0 place-items-center rounded-full bg-white/90 text-teal shadow-lg ring-2 ring-white disabled:opacity-40"
          >
            <Volume2 size={22} />
          </button>
        </div>
      </section>
    </div>
  );
}
