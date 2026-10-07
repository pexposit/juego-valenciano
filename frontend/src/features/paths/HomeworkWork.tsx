import { useEffect, useState } from 'react';
import { BookOpen, Check, Clock, ListChecks, MessageCircle, X } from 'lucide-react';
import { loadAssignmentWork, loadPathItems, type PathItem, type StudyPath, type WorkRow } from '../../lib/paths';
import type { Resource } from '../../lib/types';
import { ConversationView } from '../kids/ConversationView';
import type { ConversationRow } from '../kids/tracking';
import { resolveItem } from './catalog';
import { ErrorsReview, PracticeReview, type SavedError } from './PracticeReview';

/** Una assignació per a revisar: uns deures (due_at) o una ruta permanent (due_at null). */
export type ReviewedAssignment = { id: string; due_at: string | null; path: StudyPath };

const when = (d: string) => new Date(d).toLocaleString('ca-ES', { weekday: 'short', day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit' });
const pct = (score: number | null, total: number | null) => (score !== null && total ? Math.round((score / total) * 100) : null);
const RESULT_KIND: Record<string, string> = { practice: 'Exercicis', exam: 'Examen', chat: 'Conversa' };

type Review = { resourceId: string; level: string | null; answers: Record<string, string>; at: string };
type ErrorsShown = { title: string; errors: SavedError[]; score: number | null; total: number | null; at: string };
// Les fallades guardades en user_errors es lliguen a l'intent que es va guardar al mateix moment.
const SAME_ATTEMPT_MS = 2 * 60_000;
type IslandWord = { word: string; emoji: string; missed: boolean };

/** Una línia per intent: què ha fet, quan i com li ha anat; d'on n'hi ha, els fallos. */
function Attempt({ row, resourceId, title, errors, late, onConversation, onReview, onErrors }: {
  row: WorkRow;
  resourceId: string | null;
  title: string;
  errors: WorkRow[];
  late: boolean;
  onConversation: (c: ConversationRow) => void;
  onReview: (r: Review) => void;
  onErrors: (e: ErrorsShown) => void;
}) {
  const p = pct(row.score, row.total);
  const tone = p === null ? '' : p >= 80 ? 'text-teal' : p > 50 ? 'text-ink' : 'text-coral';
  let what: React.ReactNode;
  if (row.source === 'island') {
    const minutes = Math.max(1, Math.round(Number(row.extra.seconds ?? 0) / 60));
    const missed = ((row.extra.words as IslandWord[] | undefined) ?? []).filter(w => w.missed);
    what = (
      <>
        Partida: <b className={tone}>{row.score}/{row.total} a la primera</b> · {minutes} min{row.extra.easy ? ' · mode fàcil' : ''}
        {missed.length > 0 && (
          <span className="ml-1">
            · li ha costat:{' '}
            {missed.map(w => (
              <span key={w.word} className="mr-1 inline-block rounded-full bg-coral/10 px-2 font-bold text-coral">{w.emoji} {w.word}</span>
            ))}
          </span>
        )}
      </>
    );
  } else if (row.source === 'lesson') {
    const missed = ((row.extra.words as IslandWord[] | undefined) ?? []).filter(w => w.missed);
    what = (
      <>
        <BookOpen size={14} className="inline" /> Lliçó acabada
        {missed.length > 0 ? (
          <span className="ml-1">
            · en els jocs li ha costat:{' '}
            {missed.map(w => (
              <span key={w.word} className="mr-1 inline-block rounded-full bg-coral/10 px-2 font-bold text-coral">{w.emoji} {w.word}</span>
            ))}
          </span>
        ) : Array.isArray(row.extra.words) && <span className="ml-1 text-teal">· sense errors en els jocs</span>}
      </>
    );
  } else if (row.source === 'conversation') {
    const objectives = (row.extra.objectives as ConversationRow['objectives']) ?? [];
    const met = objectives.filter(o => o.met).length;
    what = (
      <>
        <MessageCircle size={14} className="inline" /> Conversa: <b className={met === objectives.length ? 'text-teal' : 'text-ink'}>{met}/{objectives.length} objectius</b>
        <button
          onClick={() => onConversation({ ...(row.extra as unknown as ConversationRow), created_at: row.at })}
          className="btn-press ml-2 rounded-full bg-white px-3 py-0.5 text-xs font-black text-[#0F47AF] shadow-sm"
        >
          Llig-la
        </button>
      </>
    );
  } else {
    const kind = RESULT_KIND[String(row.extra.kind)] ?? 'Resultat';
    const answers = (row.extra.details as { answers?: Record<string, string> } | null)?.answers;
    what = (
      <>
        {row.score !== null && row.total ? <>{kind}: <b className={tone}>{row.score}/{row.total}</b> ({p} %)</> : <>{kind} acabat</>}
        {row.extra.kind === 'practice' && resourceId && (answers ? (
          <button
            onClick={() => onReview({ resourceId, level: (row.extra.level as string | null) ?? null, answers, at: row.at })}
            className="btn-press ml-2 inline-flex items-center gap-1 rounded-full bg-white px-3 py-0.5 text-xs font-black text-[#0F47AF] shadow-sm"
          >
            <ListChecks size={14} /> Mira les respostes
          </button>
        ) : errors.length > 0 ? (
          <button
            onClick={() => onErrors({
              title,
              errors: errors.map(e => e.extra as unknown as SavedError),
              score: row.score,
              total: row.total,
              at: row.at,
            })}
            className="btn-press ml-2 inline-flex items-center gap-1 rounded-full bg-white px-3 py-0.5 text-xs font-black text-coral shadow-sm"
          >
            <ListChecks size={14} /> Mira les fallades ({errors.length})
          </button>
        ) : <span className="ml-2 text-xs opacity-50">(sense detall de respostes)</span>)}
      </>
    );
  }
  return (
    <li className="flex flex-wrap items-center gap-x-2 gap-y-0.5 text-sm">
      <span className="opacity-60">{when(row.at)}</span>
      <span>· {what}</span>
      {late && <span className="rounded-full bg-mustard px-2 text-xs font-black">fora de termini</span>}
    </li>
  );
}

/**
 * El treball d'un aprenent en una assignació, pas per pas: cada intent (partida, lliçó,
 * exercicis, conversa) amb la data i el resultat, i si va ser dins del termini. Per a la
 * docent (en la taula de deures i en la fitxa de l'alumne) i per a la família.
 */
export function HomeworkWork({ assignment, student, name, resources }: {
  assignment: ReviewedAssignment;
  student: string;
  name: string;
  resources: Map<string, Resource>;
}) {
  const [items, setItems] = useState<PathItem[]>();
  const [work, setWork] = useState<WorkRow[]>();
  const [conversation, setConversation] = useState<ConversationRow>();
  const [review, setReview] = useState<Review>();
  const [errorsShown, setErrorsShown] = useState<ErrorsShown>();
  const [error, setError] = useState(false);

  useEffect(() => {
    let cancelled = false;
    Promise.all([loadPathItems(assignment.path.id), loadAssignmentWork(assignment.id, student)])
      .then(([i, w]) => { if (!cancelled) { setItems(i); setWork(w); } })
      .catch(e => {
        console.error(e);
        if (!cancelled) setError(true);
      });
    return () => { cancelled = true; };
  }, [assignment, student]);

  if (error) return <p className="text-coral">No s'ha pogut carregar el treball.</p>;
  if (!items || !work) return <p className="opacity-60">Carregant…</p>;

  const due = assignment.due_at ? Date.parse(assignment.due_at) : null;
  return (
    <>
      <ol className="flex flex-col gap-2">
        {items.map((item, i) => {
          const r = resolveItem(item, resources);
          // Les converses del Nivell 0 ja es veuen amb els objectius: el resultat del xat sobraria.
          const all = work.filter(w => w.item_id === item.id);
          const errors = all.filter(w => w.source === 'error');
          const rows = all.filter(w => w.source !== 'error');
          const shown = rows.some(w => w.source === 'conversation') ? rows.filter(w => !(w.source === 'result' && w.extra.kind === 'chat')) : rows;
          const first = rows[0];
          const late = due !== null && !!first && Date.parse(first.at) > due;
          return (
            <li key={item.id} className="rounded-2xl border border-stone-200 bg-white p-3">
              <div className="flex items-center gap-3">
                <span
                  className="grid h-9 w-9 shrink-0 place-items-center rounded-full font-black text-white"
                  style={{ background: first ? (late ? '#E6B800' : '#2CA99B') : '#A8A29E' }}
                  aria-label={first ? 'Fet' : 'Pendent'}
                >
                  {first ? <Check size={18} strokeWidth={3} /> : i + 1}
                </span>
                <span className="text-2xl" aria-hidden="true">{r.emoji}</span>
                <span className="min-w-0 flex-1">
                  <span className="block font-extrabold leading-tight">{r.title}</span>
                  <span className="block text-sm opacity-60">
                    {r.kindLabel} · {first ? `${shown.length} ${shown.length === 1 ? 'vegada' : 'vegades'}${late ? ' · fet fora de termini' : ''}` : 'Encara no l\'ha fet'}
                  </span>
                </span>
              </div>
              {shown.length > 0 && (
                <ul className="ml-12 mt-2 flex flex-col gap-1">
                  {shown.map((row, j) => (
                    <Attempt
                      key={j}
                      row={row}
                      resourceId={item.resource_id}
                      title={r.title}
                      errors={row.source === 'result' ? errors.filter(e => Math.abs(Date.parse(e.at) - Date.parse(row.at)) < SAME_ATTEMPT_MS) : []}
                      onErrors={setErrorsShown}
                      late={due !== null && Date.parse(row.at) > due}
                      onConversation={setConversation}
                      onReview={setReview}
                    />
                  ))}
                </ul>
              )}
            </li>
          );
        })}
      </ol>
      {conversation && <ConversationView conversation={conversation} name={name} onClose={() => setConversation(undefined)} />}
      {errorsShown && (
        <ErrorsReview
          title={errorsShown.title}
          errors={errorsShown.errors}
          score={errorsShown.score}
          total={errorsShown.total}
          name={name}
          when={when(errorsShown.at)}
          onClose={() => setErrorsShown(undefined)}
        />
      )}
      {review && (
        <PracticeReview
          resourceId={review.resourceId}
          level={review.level}
          answers={review.answers}
          name={name}
          when={when(review.at)}
          onClose={() => setReview(undefined)}
        />
      )}
    </>
  );
}

/** El treball d'un alumne en uns deures, en una finestra (des de la taula de deures). */
export function HomeworkWorkDialog({ assignment, student, name, resources, onClose }: {
  assignment: ReviewedAssignment;
  student: string;
  name: string;
  resources: Map<string, Resource>;
  onClose: () => void;
}) {
  useEffect(() => {
    const onKey = (e: KeyboardEvent) => e.key === 'Escape' && onClose();
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, [onClose]);

  return (
    <div className="fixed inset-0 z-50 grid place-items-center bg-ink/40 p-4" onClick={onClose} role="dialog" aria-modal="true" aria-label={`Treball de ${name}`}>
      <div className="max-h-[90vh] w-full max-w-2xl overflow-y-auto rounded-3xl bg-cream p-5 shadow-xl" onClick={e => e.stopPropagation()}>
        <div className="mb-4 flex items-start justify-between gap-3">
          <div>
            <h2 className="text-3xl font-black">{name || 'Alumne'}</h2>
            <p className="flex items-center gap-1 opacity-70">
              {assignment.path.title}
              {assignment.due_at && <><Clock size={14} className="ml-2" /> fins al {new Date(assignment.due_at).toLocaleDateString('ca-ES', { day: 'numeric', month: 'short' })}</>}
            </p>
          </div>
          <button onClick={onClose} aria-label="Tanca" className="btn-press rounded-full bg-white p-2 shadow-sm"><X size={20} /></button>
        </div>
        <HomeworkWork assignment={assignment} student={student} name={name} resources={resources} />
      </div>
    </div>
  );
}
