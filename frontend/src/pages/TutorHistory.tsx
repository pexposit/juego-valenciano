import { useEffect, useRef, useState } from 'react';
import { Check, ChevronLeft, MessageCircle, Pencil, X } from 'lucide-react';
import { ChatBubble } from '../components/ChatBubble';
import { Logo } from '../components/ui';
import { fetchTutorConversation, fetchTutorConversations, renameTutorConversation, resumeTutorConversation, type TutorConversation, type TutorMessage } from '../lib/api';

const formatDate = (iso: string) =>
  new Date(iso).toLocaleString('ca', { dateStyle: 'medium', timeStyle: 'short' });

// Màxim de caràcters del nom (el mateix límit que el backend).
const TITLE_MAX = 40;

// El nom d'una conversa, amb un llapis per a canviar-lo. Intro o ✓ guarda; Esc o ✕ cancel·la.
// Deixar-lo buit torna al títol automàtic (el resumix el LLM).
function ConversationTitle({ conversation, onRenamed }: { conversation: TutorConversation; onRenamed: (c: TutorConversation) => void }) {
  const [editing, setEditing] = useState(false);
  const [draft, setDraft] = useState(conversation.title);
  const [saving, setSaving] = useState(false);
  const [failed, setFailed] = useState(false);
  const input = useRef<HTMLInputElement>(null);

  useEffect(() => {
    if (editing) input.current?.select();
  }, [editing]);

  const start = () => {
    setDraft(conversation.title_edited ? conversation.title : '');
    setFailed(false);
    setEditing(true);
  };
  const save = async () => {
    if (saving) return;
    const title = draft.trim();
    if (title === (conversation.title_edited ? conversation.title : '')) return setEditing(false);
    setSaving(true);
    setFailed(false);
    try {
      const result = await renameTutorConversation(conversation.id, title);
      // Si torna a l'automàtic, mentre el LLM no en fa un de nou es veu el primer missatge.
      onRenamed({ ...conversation, title: result.title ?? conversation.preview, title_edited: result.title_edited });
      setEditing(false);
    } catch (error) {
      console.error('Error canviant el nom de la conversa:', error);
      setFailed(true);
    } finally {
      setSaving(false);
    }
  };

  if (!editing) {
    return (
      <div className="mb-3 flex items-start gap-2">
        <h2 className="line-clamp-2 min-w-0 flex-1 break-words text-3xl font-black leading-tight" title={conversation.title}>{conversation.title}</h2>
        <button
          onClick={start}
          aria-label="Canvia el nom de la conversa"
          title="Canvia el nom de la conversa"
          className="btn-press grid h-11 w-11 shrink-0 place-items-center rounded-full bg-white text-teal shadow ring-2 ring-white hover:bg-white/90"
        >
          <Pencil size={20} />
        </button>
      </div>
    );
  }
  return (
    <div className="mb-3">
      <form
        className="flex items-center gap-2"
        onSubmit={e => {
          e.preventDefault();
          void save();
        }}
      >
        <input
          ref={input}
          value={draft}
          maxLength={TITLE_MAX}
          disabled={saving}
          onChange={e => setDraft(e.target.value)}
          onKeyDown={e => e.key === 'Escape' && setEditing(false)}
          placeholder="Posa-li un nom (buit: nom automàtic)"
          aria-label="Nom de la conversa"
          className="min-w-0 flex-1 rounded-2xl bg-white px-4 py-2 text-2xl font-black shadow ring-2 ring-teal/40 outline-none focus:ring-teal"
        />
        <button type="submit" disabled={saving} aria-label="Guarda el nom" title="Guarda el nom" className="btn-press grid h-11 w-11 shrink-0 place-items-center rounded-full bg-teal text-white shadow disabled:opacity-40">
          <Check size={22} />
        </button>
        <button type="button" onClick={() => setEditing(false)} disabled={saving} aria-label="Cancel·la" title="Cancel·la" className="btn-press grid h-11 w-11 shrink-0 place-items-center rounded-full bg-white text-ink shadow disabled:opacity-40">
          <X size={22} />
        </button>
      </form>
      {failed && <p className="mt-2 text-lg font-bold text-orange">No hem pogut canviar el nom. Torna-ho a provar.</p>}
    </div>
  );
}

// Converses anteriors del xiquet amb el professor: una llista i, en triar-ne una, els seus missatges (només lectura).
export function TutorHistory({ onBack, onResume, showHelp }: { onBack: () => void; onResume: () => void; showHelp: boolean }) {
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

  // El nom nou es veu en el detall i en la llista sense tornar-la a carregar.
  const renamed = (conversation: TutorConversation) => {
    setSelected(conversation);
    setConversations(list => list?.map(c => (c.id === conversation.id ? conversation : c)));
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
              <p className="mt-2 truncate text-xl font-black">{c.title}</p>
              {c.title !== c.preview && <p className="mt-1 truncate text-base font-semibold opacity-60">{c.preview}</p>}
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
      <p className="mb-1 text-sm font-extrabold uppercase tracking-wider opacity-55">{selected && formatDate(selected.started_at)}</p>
      {selected && <ConversationTitle key={selected.id} conversation={selected} onRenamed={renamed} />}
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
        {messages?.map((m, i) => <ChatBubble key={i} role={m.role} text={m.text} showHelp={showHelp} />)}
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
