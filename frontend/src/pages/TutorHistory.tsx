import { useEffect, useState } from 'react';
import { ChevronLeft, MessageCircle } from 'lucide-react';
import { ChatBubble } from '../components/ChatBubble';
import { Logo } from '../components/ui';
import { fetchTutorConversation, fetchTutorConversations, resumeTutorConversation, type TutorConversation, type TutorMessage } from '../lib/api';

const formatDate = (iso: string) =>
  new Date(iso).toLocaleString('ca', { dateStyle: 'medium', timeStyle: 'short' });

// Converses anteriors del xiquet amb el professor: una llista i, en triar-ne una, els seus missatges (només lectura).
export function TutorHistory({ onBack, onResume, showHelp, level }: { onBack: () => void; onResume: () => void; showHelp: boolean; level: string }) {
  const [resuming, setResuming] = useState(false);
  const [resumeFailed, setResumeFailed] = useState(false);
  // undefined = carregant; null = error de càrrega.
  const [conversations, setConversations] = useState<TutorConversation[] | null>();
  const [selected, setSelected] = useState<TutorConversation>();
  const [messages, setMessages] = useState<TutorMessage[] | null>();

  useEffect(() => {
    let cancelled = false;
    fetchTutorConversations()
      .then(data => { if (!cancelled) setConversations(data); })
      .catch(error => {
        console.error('Error carregant les converses:', error);
        if (!cancelled) setConversations(null);
      });
    return () => { cancelled = true; };
  }, []);

  const open = (conversation: TutorConversation) => {
    setSelected(conversation);
    setMessages(undefined);
    fetchTutorConversation(conversation.id)
      .then(setMessages)
      .catch(error => {
        console.error('Error carregant la conversa:', error);
        setMessages(null);
      });
  };

  const resume = async () => {
    if (!selected || resuming) return;
    setResuming(true);
    setResumeFailed(false);
    try {
      await resumeTutorConversation(selected.id);
      onResume();
    } catch (error) {
      console.error('Error reprenent la conversa:', error);
      setResumeFailed(true);
      setResuming(false);
    }
  };

  const list = () => {
    if (conversations === undefined) return <p className="text-center text-lg font-bold opacity-60">Carregant…</p>;
    if (conversations === null) return <p className="text-center text-lg font-bold text-orange">No hem pogut carregar les converses. Torna-ho a provar més tard.</p>;
    if (conversations.length === 0) {
      return (
        <div className="rounded-3xl bg-white p-8 text-center shadow-lg">
          <p className="text-2xl font-black">Encara no has parlat amb el professor</p>
          <p className="mt-2 text-lg font-semibold opacity-70">Les teues converses apareixeran ací.</p>
        </div>
      );
    }
    return (
      <ul className="flex flex-col gap-4">
        {conversations.map(c => (
          <li key={c.id}>
            <button
              onClick={() => open(c)}
              className="btn-press w-full rounded-3xl bg-white p-5 text-left shadow-lg ring-2 ring-white hover:bg-white/90"
            >
              <p className="flex items-center justify-between gap-3 text-sm font-extrabold uppercase tracking-wider opacity-55">
                <span>{formatDate(c.started_at)}</span>
                <span>{c.current ? 'Conversa actual · ' : ''}{c.message_count} missatges</span>
              </p>
              <p className="mt-2 truncate text-xl font-bold">{c.preview}</p>
            </button>
          </li>
        ))}
      </ul>
    );
  };

  const detail = () => (
    <div>
      <button
        onClick={() => setSelected(undefined)}
        className="btn-press mb-4 flex items-center gap-1 rounded-full bg-white/90 px-4 py-2 text-lg font-extrabold text-teal shadow"
      >
        <ChevronLeft size={20} /> Totes les converses
      </button>
      <p className="mb-3 text-sm font-extrabold uppercase tracking-wider opacity-55">{selected && formatDate(selected.started_at)}</p>
      <button
        onClick={resume}
        disabled={resuming || !messages}
        className="btn-press mb-4 flex items-center gap-2 rounded-full bg-teal px-5 py-3 text-lg font-extrabold text-white shadow-lg disabled:opacity-40"
      >
        <MessageCircle size={20} /> Continua esta conversa
      </button>
      {resumeFailed && <p className="mb-3 text-lg font-bold text-orange">No hem pogut reprendre la conversa. Torna-ho a provar.</p>}
      <div className="flex flex-col gap-3 rounded-3xl bg-white/85 p-4 shadow-lg ring-2 ring-white">
        {messages === undefined && <p className="text-center text-lg font-bold opacity-60">Carregant…</p>}
        {messages === null && <p className="text-center text-lg font-bold text-orange">No hem pogut carregar la conversa.</p>}
        {messages?.map((m, i) => <ChatBubble key={i} role={m.role} text={m.text} showHelp={showHelp} onlyHelp={showHelp && level === 'nivell0'} />)}
      </div>
    </div>
  );

  return (
    <main className="fade-up relative min-h-screen bg-cream text-ink">
      <header className="classroom-header z-10">
        <div className="relative isolate flex items-center justify-between px-5 p-4">
          <button
            onClick={onBack}
            className="text-xl btn-press rounded-full bg-white/90 px-4 py-2 text-sm font-extrabold text-teal shadow hover:bg-white transition-colors"
          >
            ← Tornar
          </button>
          <Logo onDark />
          <span className="w-24" aria-hidden="true" />
        </div>
      </header>
      <div className="mx-auto max-w-2xl px-5 pt-6 pb-24">
        <h1 className="mb-6 text-center text-4xl font-black uppercase tracking-wider opacity-55">Les meues converses</h1>
        {selected ? detail() : list()}
      </div>
    </main>
  );
}
