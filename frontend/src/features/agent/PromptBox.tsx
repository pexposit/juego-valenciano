import { useRef, useState, type ReactNode } from 'react';
import { Loader2, Sparkles, X } from 'lucide-react';
import { TEACHER_AGENT_PROMPT_MAX } from '@parlaval/shared';

const FIELD = 'w-full rounded-2xl border-2 border-gray-100 p-3 text-lg outline-none focus:border-[#0F47AF] transition-colors';

/**
 * Quadre per a escriure el prompt de l'agent: text, camps extra (p. ex. el nivell), botó de generar i botó
 * d'aturar mentre treballa (talla la petició al servidor). `onSubmit` rep el prompt i un senyal d'aturada.
 */
export function PromptBox({ title, hint, placeholder, extra, beforeSubmit, initialPrompt = '', submitLabel = 'Genera', onSubmit, onClose }: {
  title: string;
  hint: ReactNode;
  placeholder: string;
  extra?: ReactNode;
  // Es crida en generar, abans d'enviar res: si torna false, no es genera (i qui ho crida ja ha avisat de què falta,
  // p. ex. que no s'ha triat el nivell).
  beforeSubmit?: () => boolean;
  initialPrompt?: string;
  submitLabel?: string;
  onSubmit: (prompt: string, signal: AbortSignal) => Promise<void>;
  onClose: () => void;
}) {
  const [prompt, setPrompt] = useState(initialPrompt);
  const [busy, setBusy] = useState(false);
  const controller = useRef<AbortController>();
  const valid = prompt.trim().length >= 5;

  const submit = async () => {
    if (!valid || busy) return;
    if (beforeSubmit && !beforeSubmit()) return;
    controller.current = new AbortController();
    setBusy(true);
    try {
      await onSubmit(prompt.trim(), controller.current.signal);
    } finally {
      setBusy(false);
    }
  };

  const close = () => {
    controller.current?.abort();
    onClose();
  };

  return (
    <section className="mt-5 rounded-3xl border-2 border-[#0F47AF]/20 bg-[#0F47AF]/5 p-5">
      <div className="flex items-start justify-between gap-3">
        <h2 className="flex items-center gap-2 text-2xl font-black"><Sparkles size={22} className="text-[#0F47AF]" /> {title}</h2>
        <button onClick={close} aria-label="Tanca" className="btn-press p-1 text-gray-400"><X /></button>
      </div>
      <p className="mt-1 text-base opacity-70">{hint}</p>
      <textarea
        value={prompt}
        onChange={e => setPrompt(e.target.value.slice(0, TEACHER_AGENT_PROMPT_MAX))}
        rows={3}
        disabled={busy}
        placeholder={placeholder}
        aria-label="Descripció de la petició"
        className={`${FIELD} mt-3 bg-white`}
      />
      <div className="mt-1 text-right text-sm opacity-50">{prompt.length}/{TEACHER_AGENT_PROMPT_MAX}</div>
      {extra}
      <div className="mt-3 flex flex-wrap items-center justify-end gap-2">
        {busy ? (
          <>
            <span className="flex items-center gap-2 text-base font-bold opacity-70"><Loader2 size={18} className="animate-spin" /> Generant...</span>
            <button onClick={() => controller.current?.abort()} className="btn-press rounded-2xl px-5 py-3 font-bold text-gray-600 hover:bg-white">Atura</button>
          </>
        ) : (
          <button onClick={() => void submit()} disabled={!valid} className="btn-press flex items-center gap-2 rounded-2xl bg-[#0F47AF] px-6 py-3 font-extrabold text-white disabled:opacity-50">
            <Sparkles size={18} /> {submitLabel}
          </button>
        )}
      </div>
    </section>
  );
}

/** Un error de la petició; si l'ha aturat la docent, no és cap error. */
export const isAbort = (e: unknown) => (e as { name?: string } | null)?.name === 'AbortError';
