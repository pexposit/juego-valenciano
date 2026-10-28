import { useEffect, useState } from 'react';
import { createPortal } from 'react-dom';
import { Loader2, Sparkles, X } from 'lucide-react';
import type { CefrLevel, TeacherActivity, TeacherActivityInput, TeacherActivityKind } from '@parlaval/shared';
import { generateActivityDraft } from '../../lib/api';
import { ActivityEditor } from '../activities/ActivityEditor';
import { ActivityPreview } from '../activities/ActivityPreview';
import type { KidsClass } from '../kids/tracking';
import { isAbort } from './PromptBox';

import { useConfirm } from '../../components/ConfirmDialog';
/**
 * Crea, sense eixir de la ruta, una activitat que l'agent ha proposat: la genera amb el prompt de la proposta, la docent
 * la revisa (editor i vista prèvia) i la guarda. En guardar-la torna l'activitat perquè s'afija a la ruta.
 */
export function CreateMissingActivity({ title, prompt, level, kind, klass, documentId, onSaved, onClose }: {
  title: string;
  prompt: string;
  level: CefrLevel;
  // El tipus que ha proposat l'agent: l'activitat creada serà exactament d'este tipus.
  kind: TeacherActivityKind;
  klass: KidsClass;
  // L'examen o temari adjuntat a la ruta: l'activitat nova es basa en ell (amb els fragments més rellevants per a la proposta).
  documentId?: string;
  onSaved: (activity: TeacherActivity) => void;
  onClose: () => void;
}) {
  const { confirm } = useConfirm();
  const [draft, setDraft] = useState<{ activity: TeacherActivityInput; notes: string }>();
  const [message, setMessage] = useState<string>();
  const [preview, setPreview] = useState<TeacherActivityInput>();

  useEffect(() => {
    const controller = new AbortController();
    generateActivityDraft(prompt, level, controller.signal, documentId, kind)
      .then(result => {
        if (result.ok) setDraft({ activity: { ...result.activity, class_ids: [klass.id] }, notes: result.notes });
        else setMessage(result.message);
      })
      .catch(e => { if (!isAbort(e)) setMessage(e instanceof Error ? e.message : String(e)); });
    return () => controller.abort();
  }, [prompt, level, kind, klass.id, documentId]);

  // Tancar amb un esborrany a mig revisar es confirma: es perdria el que la docent ha canviat.
  const requestClose = async () => {
    if (draft && !(await confirm({ title: 'Tancar sense guardar?', message: "L'esborrany de l'activitat es perdrà.", confirmLabel: 'Tanca', tone: 'danger' }))) return;
    onClose();
  };

  // Escape tanca el pop-up; i mentre és obert, la pàgina de darrere no es desplaça.
  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if (e.key === 'Escape' && !preview) requestClose();
    };
    document.addEventListener('keydown', onKey);
    const previous = document.body.style.overflow;
    document.body.style.overflow = 'hidden';
    return () => {
      document.removeEventListener('keydown', onKey);
      document.body.style.overflow = previous;
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [draft, preview]);

  // Es pinta en el <body>: dins de la pantalla de la docent hi ha un ancestre amb `transform` (l'animació .fade-up) i un
  // `position: fixed` dins d'ell no cobriria la finestra, sinó tota la pàgina.
  return createPortal(
    <div
      className="modal-backdrop fixed inset-0 z-40 grid place-items-center bg-navy/40 p-3 sm:p-5"
      // El fons només tanca el pop-up si encara no hi ha esborrany (carregant o amb error).
      onClick={e => e.target === e.currentTarget && !draft && onClose()}
    >
      <section
        role="dialog"
        aria-modal="true"
        aria-labelledby="create-missing-title"
        className="modal-content flex max-h-[92vh] w-full max-w-4xl flex-col overflow-hidden rounded-[28px] bg-cream shadow-2xl"
      >
        <header className="flex items-start justify-between gap-3 border-b border-black/5 bg-white px-6 py-4">
          <div className="min-w-0">
            <p className="flex items-center gap-1 text-xs font-black uppercase tracking-wider text-[#0F47AF]"><Sparkles size={14} /> Activitat nova per a la ruta</p>
            <h2 id="create-missing-title" className="truncate text-2xl font-black leading-tight">{title}</h2>
          </div>
          <button onClick={requestClose} aria-label="Tanca" className="btn-press shrink-0 rounded-full bg-gray-100 p-1.5 hover:bg-gray-200">
            <X className="h-5 w-5" />
          </button>
        </header>

        <div className="overflow-y-auto p-5 sm:p-6">
          {draft ? (
            <>
              <p className="mb-4 flex items-start gap-2 rounded-2xl bg-[#0F47AF]/10 p-4 text-base" role="status">
                <Sparkles size={20} className="mt-0.5 shrink-0 text-[#0F47AF]" />
                <span>{draft.notes} Comprova que el contingut és rellevant i que les respostes són correctes. En guardar-la s'afegirà a la ruta.</span>
              </p>
              <ActivityEditor
                initial={draft.activity}
                classes={[klass]}
                onSaved={onSaved}
                onCancel={requestClose}
                onPreview={setPreview}
              />
              {preview && <ActivityPreview activity={preview} onClose={() => setPreview(undefined)} />}
            </>
          ) : message ? (
            <div className="rounded-3xl bg-white p-6 shadow-sm" role="alert">
              <p className="text-lg"><b>No s'ha pogut crear l'activitat.</b> {message}</p>
              <button onClick={onClose} className="btn-press mt-4 rounded-2xl bg-[#0F47AF] px-6 py-3 font-extrabold text-white">Tanca</button>
            </div>
          ) : (
            <div className="rounded-3xl bg-white p-6 shadow-sm" aria-live="polite">
              <p className="flex items-center gap-2 text-xl font-black"><Loader2 className="animate-spin" size={22} /> Creant l'activitat...</p>
              <p className="mt-1 text-base opacity-60">La IA està preparant un esborrany; trigarà uns segons.</p>
              <button onClick={onClose} className="btn-press mt-4 rounded-2xl px-5 py-3 font-bold text-gray-600 hover:bg-gray-50">Atura</button>
            </div>
          )}
        </div>
      </section>
    </div>,
    document.body,
  );
}
