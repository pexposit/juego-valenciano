import { useEffect, useState } from 'react';
import { Pencil, Plus, Target, Trash2, X } from 'lucide-react';
import { learnerLevelOf, type TeacherActivity, type TeacherActivityInput, type TeacherActivityKind } from '@parlaval/shared';
import { categoryLabel } from '../../components/ScenarioSelect';
import { deleteTeacherActivity, fetchTeacherActivities } from '../../lib/api';
import { Practice } from '../../pages/Practice';
import type { KidsClass } from '../kids/tracking';
import { ActivityEditor } from './ActivityEditor';
import { ACTIVITY_KINDS, emptyActivity, toPracticePreview } from './drafts';

type Editing = { id?: string; initial: TeacherActivityInput };

const kindOf = (kind: TeacherActivityKind) => ACTIVITY_KINDS.find(k => k.kind === kind)!;

/**
 * Biblioteca d'activitats de la docent: les crea amb les plantilles, les previsualitza amb
 * les mateixes pantalles que l'alumnat i les assigna a les seues classes.
 */
export function TeacherActivities({ classes }: { classes: KidsClass[] }) {
  const [activities, setActivities] = useState<TeacherActivity[]>();
  const [error, setError] = useState<string>();
  const [choosing, setChoosing] = useState(false);
  const [editing, setEditing] = useState<Editing>();
  const [preview, setPreview] = useState<TeacherActivityInput>();

  useEffect(() => {
    fetchTeacherActivities().then(setActivities).catch(e => setError(e instanceof Error ? e.message : String(e)));
  }, []);

  const className = (id: string) => classes.find(c => c.id === id)?.name ?? '';

  const remove = async (a: TeacherActivity) => {
    if (!confirm(`Segur que vols esborrar «${a.title}»? Desapareixerà de les classes i de les rutes on estiga.`)) return;
    try {
      await deleteTeacherActivity(a.id);
      setActivities(list => list?.filter(x => x.id !== a.id));
    } catch (e) {
      setError(e instanceof Error ? e.message : String(e));
    }
  };

  const saved = (activity: TeacherActivity) => {
    setActivities(list => [activity, ...(list ?? []).filter(a => a.id !== activity.id)]);
    setEditing(undefined);
  };

  const previewModal = preview && (() => {
    const practice = toPracticePreview(preview);
    return (
      <div className="fixed inset-0 z-50 overflow-y-auto bg-cream">
        <div className="sticky top-0 z-[60] flex items-center justify-between gap-3 bg-[#0F47AF] px-5 py-2 text-white">
          <span className="font-extrabold">Vista prèvia: així ho veurà l'alumnat. No es guarda res.</span>
          <button onClick={() => setPreview(undefined)} className="btn-press flex items-center gap-1 rounded-full bg-white/20 px-3 py-1 font-bold">
            <X size={18} /> Tanca
          </button>
        </div>
        {practice ? (
          <Practice practice={practice} userLevel={learnerLevelOf(preview.level)} onBack={() => setPreview(undefined)} preview />
        ) : preview.content.kind === 'scenario' && <ScenarioPreview activity={preview} />}
      </div>
    );
  })();

  if (editing) {
    return (
      <>
        <ActivityEditor
          initial={editing.initial}
          id={editing.id}
          classes={classes}
          onSaved={saved}
          onCancel={() => setEditing(undefined)}
          onPreview={setPreview}
        />
        {previewModal}
      </>
    );
  }

  return (
    <>
      <div className="flex flex-wrap items-end justify-between gap-3">
        <div>
          <h1 className="text-5xl font-black">Les meues activitats</h1>
          <p className="mt-2 text-lg opacity-70">Crea activitats per a l'alumnat adult (A2 i B1) i assigna-les a les teues classes.</p>
        </div>
        {!choosing && (
          <button onClick={() => setChoosing(true)} className="btn-press flex items-center gap-2 rounded-2xl bg-[#0F47AF] px-5 py-3 text-lg font-extrabold text-white">
            <Plus size={20} /> Nova activitat
          </button>
        )}
      </div>

      {error && <p className="mt-4 rounded-2xl bg-coral/10 p-3 text-lg text-coral">{error}</p>}

      {choosing && (
        <section className="mt-6 rounded-3xl bg-white p-5 shadow-sm">
          <div className="flex items-center justify-between">
            <h2 className="text-2xl font-black">Quin tipus d'activitat?</h2>
            <button onClick={() => setChoosing(false)} aria-label="Tanca" className="btn-press p-2 text-gray-400"><X /></button>
          </div>
          <ul className="mt-3 grid gap-3 sm:grid-cols-2">
            {ACTIVITY_KINDS.map(k => (
              <li key={k.kind}>
                <button
                  onClick={() => { setChoosing(false); setEditing({ initial: emptyActivity(k.kind) }); }}
                  className="btn-press flex h-full w-full items-start gap-3 rounded-2xl border-2 border-gray-100 p-4 text-left hover:border-[#0F47AF]"
                >
                  <span className="text-4xl" aria-hidden="true">{k.icon}</span>
                  <span>
                    <span className="block text-xl font-black">{k.label}</span>
                    <span className="block text-base opacity-70">{k.hint}</span>
                  </span>
                </button>
              </li>
            ))}
          </ul>
        </section>
      )}

      {activities === undefined && !error ? (
        <p className="mt-6 text-lg opacity-60">Carregant les activitats...</p>
      ) : activities?.length === 0 ? (
        <p className="mt-6 text-lg opacity-60">Encara no has creat cap activitat.</p>
      ) : (
        <ul className="mt-6 flex flex-col gap-3">
          {activities?.map(a => {
            const kind = kindOf(a.content.kind);
            return (
              <li key={a.id} className="flex flex-wrap items-center gap-4 rounded-3xl bg-white p-5 shadow-sm">
                <span className="text-4xl" aria-hidden="true">{a.icon}</span>
                <div className="min-w-0 flex-1">
                  <p className="text-sm font-black text-teal">
                    {kind.label}{a.content.kind === 'exercises' && ` · ${categoryLabel(a.content.area)}`} · {a.level}
                  </p>
                  <p className="text-xl font-black">{a.title}</p>
                  <p className="text-base opacity-70">
                    {a.class_ids.length
                      ? `Assignada a: ${a.class_ids.map(className).filter(Boolean).join(', ')}`
                      : 'Sense assignar: no la veu cap alumne.'}
                  </p>
                </div>
                <button onClick={() => setPreview(a)} className="btn-press flex items-center gap-1 rounded-full px-3 py-2 font-bold text-[#0F47AF] hover:bg-gray-50">
                  <Target size={16} /> Prova-la
                </button>
                <button
                  onClick={() => setEditing({ id: a.id, initial: { level: a.level, title: a.title, description: a.description, icon: a.icon, class_ids: a.class_ids, content: a.content } })}
                  className="btn-press flex items-center gap-1 rounded-full px-3 py-2 font-bold text-[#0F47AF] hover:bg-gray-50"
                >
                  <Pencil size={16} /> Edita
                </button>
                <button onClick={() => void remove(a)} aria-label={`Esborra ${a.title}`} className="btn-press p-2 text-gray-400 hover:text-coral">
                  <Trash2 size={18} />
                </button>
              </li>
            );
          })}
        </ul>
      )}
      {previewModal}
    </>
  );
}

/** Com veurà l'alumne l'escenari en obrir-lo: el lloc, el personatge, la primera frase i els objectius. */
function ScenarioPreview({ activity }: { activity: TeacherActivityInput }) {
  const c = activity.content;
  if (c.kind !== 'scenario') return null;
  return (
    <div className="relative min-h-[calc(100dvh-2.5rem)] bg-cover bg-center" style={{ backgroundImage: `url('${c.background}')` }}>
      <div className="absolute left-[8%] top-[12%] max-w-[min(72%,440px)] rounded-3xl bg-white p-5 text-lg font-bold shadow-xl">{c.greeting}</div>
      <aside className="absolute right-5 top-24 w-[min(calc(100%-2.5rem),320px)] rounded-3xl bg-white/95 p-5 shadow-xl">
        <h2 className="mb-2 flex items-center gap-2 text-sm font-black uppercase tracking-wider text-[#0F47AF]"><Target size={16} /> Objectius</h2>
        {activity.description && <p className="mb-3 text-sm font-bold opacity-70">{activity.description}</p>}
        <ol className="flex list-decimal flex-col gap-1.5 pl-5 text-sm font-bold">
          {c.objectives.map(o => <li key={o}>{o}</li>)}
        </ol>
      </aside>
      <div className="absolute bottom-24 left-1/2 -translate-x-1/2 rounded-full bg-white/90 px-4 py-1.5 text-base font-black uppercase tracking-wide shadow">{c.character}</div>
      <p className="absolute inset-x-4 bottom-6 mx-auto max-w-xl rounded-2xl bg-white/90 p-3 text-center text-sm font-bold">
        En la vista prèvia no es pot xarrar: la conversa amb la IA la fa l'alumnat de les classes on l'assignes, des de «Activitats».
      </p>
    </div>
  );
}
