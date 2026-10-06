import { useEffect, useState } from 'react';
import { X } from 'lucide-react';
import { fetchKidsConversation, type TutorMessage } from '../../lib/api';
import { ago } from './report';
import type { ConversationRow } from './tracking';

/**
 * Una conversa del Nivell 0 (escenari), per a la família: els objectius que ha complit i,
 * davall, tota la conversa, frase a frase (el personatge a l'esquerra, el xiquet a la dreta).
 */
export function ConversationView({ conversation, name, onClose }: { conversation: ConversationRow; name: string; onClose: () => void }) {
  const [messages, setMessages] = useState<TutorMessage[] | null>();

  useEffect(() => {
    let cancelled = false;
    fetchKidsConversation(conversation.session_resource_id)
      .then(m => { if (!cancelled) setMessages(m); })
      .catch(error => {
        console.error(error);
        if (!cancelled) setMessages(null);
      });
    return () => { cancelled = true; };
  }, [conversation.session_resource_id]);

  // Es tanca amb Escape, com qualsevol finestra.
  useEffect(() => {
    const close = (e: KeyboardEvent) => e.key === 'Escape' && onClose();
    window.addEventListener('keydown', close);
    return () => window.removeEventListener('keydown', close);
  }, [onClose]);

  const met = conversation.objectives.filter(o => o.met).length;

  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center bg-black/40 sm:items-center sm:p-6" onClick={onClose}>
      <section
        role="dialog"
        aria-modal="true"
        aria-label={`Conversa: ${conversation.scenario_name}`}
        onClick={e => e.stopPropagation()}
        className="flex max-h-[92vh] w-full max-w-2xl flex-col rounded-t-3xl bg-[#FAFAF9] shadow-xl sm:rounded-3xl"
      >
        <header className="flex items-start gap-3 border-b border-gray-100 p-5">
          <span className="flex-1">
            <span className="block text-2xl font-black">{conversation.scenario_name}</span>
            <span className="block text-base opacity-60">
              {ago(conversation.created_at)} · {new Date(conversation.created_at).toLocaleString('ca-ES', { dateStyle: 'medium', timeStyle: 'short' })}
            </span>
          </span>
          <button onClick={onClose} aria-label="Tanca" className="btn-press grid h-11 w-11 place-items-center rounded-full bg-white text-gray-500 shadow-sm hover:text-gray-800">
            <X size={22} />
          </button>
        </header>

        <div className="overflow-y-auto p-5">
          <div className="rounded-2xl bg-white p-4 shadow-sm">
            <p className="text-lg font-extrabold">
              Objectius{conversation.objectives.some(o => o.met !== null) && `: ${met} de ${conversation.objectives.length}`}
            </p>
            <ul className="mt-2 space-y-1 text-base">
              {conversation.objectives.map(o => (
                <li key={o.text} className="flex items-start gap-2">
                  <span aria-hidden="true" className={o.met ? 'text-teal' : 'text-gray-300'}>{o.met === null ? '·' : o.met ? '✓' : '○'}</span>
                  <span className={o.met ? '' : 'opacity-60'}>{o.text}</span>
                </li>
              ))}
            </ul>
          </div>

          <div className="mt-5 space-y-3">
            {messages === undefined && <p className="text-lg opacity-60">Carregant la conversa...</p>}
            {messages === null && <p className="text-lg text-coral">No s'ha pogut carregar la conversa.</p>}
            {messages?.map((m, i) => (
              <div key={i} className={`flex ${m.role === 'user' ? 'justify-end' : 'justify-start'}`}>
                <div className={`max-w-[85%] rounded-2xl px-4 py-2.5 text-lg ${m.role === 'user' ? 'rounded-br-md bg-[#0F47AF] text-white' : 'rounded-bl-md bg-white shadow-sm'}`}>
                  <span className={`block text-xs font-extrabold uppercase tracking-wide ${m.role === 'user' ? 'opacity-70' : 'opacity-50'}`}>
                    {m.role === 'user' ? name || 'Xiquet' : 'Personatge'}
                  </span>
                  {m.text}
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>
    </div>
  );
}
