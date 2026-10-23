import { useRef, useState } from 'react';
import { FileText, Loader2, Paperclip, X } from 'lucide-react';
import { TEACHER_DOCUMENT_EXTENSIONS, TEACHER_DOCUMENT_MAX_BYTES, type AgentDocument } from '@parlaval/shared';
import { uploadAgentDocument } from '../../lib/api';

const MAX_MB = TEACHER_DOCUMENT_MAX_BYTES / 1024 / 1024;

/**
 * Adjunta un examen o un temari (PDF, Word o text) perquè l'agent el use de font. El servidor només n'extrau el text i
 * no guarda el fitxer. `disabled`: mentre l'agent treballa.
 */
export function DocumentAttach({ value, onChange, disabled }: { value?: AgentDocument; onChange: (document?: AgentDocument) => void; disabled?: boolean }) {
  const input = useRef<HTMLInputElement>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string>();

  const pick = async (file: File | undefined) => {
    if (!file) return;
    setError(undefined);
    if (file.size > TEACHER_DOCUMENT_MAX_BYTES) {
      setError(`El document pesa massa (màxim ${MAX_MB} MB).`);
      return;
    }
    setLoading(true);
    try {
      onChange(await uploadAgentDocument(file));
    } catch (e) {
      setError(e instanceof Error ? e.message : String(e));
    } finally {
      setLoading(false);
      if (input.current) input.current.value = '';
    }
  };

  return (
    <div className="mt-3">
      <input ref={input} type="file" accept={TEACHER_DOCUMENT_EXTENSIONS.join(',')} className="hidden" aria-label="Adjunta un document" onChange={e => void pick(e.target.files?.[0])} />
      {value ? (
        <div className="flex flex-wrap items-center gap-2 rounded-2xl bg-white p-3">
          <FileText size={20} className="shrink-0 text-[#0F47AF]" />
          <span className="min-w-0 flex-1">
            <span className="block truncate font-bold">{value.name}</span>
            <span className="block text-sm opacity-60">
              {value.chars.toLocaleString('ca-ES')} caràcters llegits{value.truncated && ' (document molt llarg: se n\'ha llegit només el principi)'}
            </span>
          </span>
          <button onClick={() => onChange(undefined)} disabled={disabled} aria-label="Lleva el document" className="btn-press p-1 text-gray-400 hover:text-coral disabled:opacity-40"><X size={18} /></button>
        </div>
      ) : (
        <button
          onClick={() => input.current?.click()}
          disabled={disabled || loading}
          className="btn-press flex items-center gap-2 rounded-2xl border-2 border-dashed border-[#0F47AF]/40 bg-white px-4 py-2 font-bold text-[#0F47AF] disabled:opacity-50"
        >
          {loading ? <><Loader2 size={18} className="animate-spin" /> Llegint el document...</> : <><Paperclip size={18} /> Adjunta un examen o temari (opcional)</>}
        </button>
      )}
      <p className="mt-1 text-sm opacity-60">PDF, Word (.docx) o text, de fins a {MAX_MB} MB. En cada petició la IA només usa els fragments del document que més hi tenen a vore. El fitxer no es guarda; el text es conserva una hora en la memòria del servidor.</p>
      {error && <p role="alert" className="mt-2 rounded-2xl bg-coral/10 p-3 text-coral">{error}</p>}
    </div>
  );
}
