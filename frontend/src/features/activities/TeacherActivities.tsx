import { useEffect, useState } from 'react';
import { Pencil, Plus, Sparkles, Target, Trash2, X } from 'lucide-react';
import { type TeacherActivity, type TeacherActivityInput, type TeacherActivityKind } from '@parlaval/shared';
import { categoryLabel } from '../../components/ScenarioSelect';
import { deleteTeacherActivity, fetchTeacherActivities } from '../../lib/api';
import type { KidsClass } from '../kids/tracking';
import { ActivityEditor } from './ActivityEditor';
import { ActivityAgent } from '../agent/ActivityAgent';
import { ACTIVITY_KINDS, emptyActivity } from './drafts';
import { ActivityPreview } from './ActivityPreview';

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
  // «Genera amb IA»: el quadre del prompt i, quan hi ha esborrany, l'avís que s'ha de revisar.
  const [generating, setGenerating] = useState(false);
  const [draftNotes, setDraftNotes] = useState<string>();
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
    setDraftNotes(undefined);
  };

  if (editing) {
    return (
      <>
        {draftNotes && (
          <p className="mb-4 flex items-start gap-2 rounded-2xl bg-[#0F47AF]/10 p-4 text-lg" role="status">
            <Sparkles size={20} className="mt-1 shrink-0 text-[#0F47AF]" />
            <span><b>Esborrany creat amb IA.</b> {draftNotes} Comprova que el contingut és rellevant i que les respostes són correctes.</span>
          </p>
        )}
        <ActivityEditor
          initial={editing.initial}
          id={editing.id}
          classes={classes}
          onSaved={saved}
          onCancel={() => { setEditing(undefined); setDraftNotes(undefined); }}
          onPreview={setPreview}
        />
        {preview && <ActivityPreview activity={preview} onClose={() => setPreview(undefined)} />}
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
          <div className="flex flex-wrap gap-2">
            {!generating && (
              <button onClick={() => setGenerating(true)} className="btn-press flex items-center gap-2 rounded-2xl border-2 border-[#0F47AF] px-5 py-3 text-lg font-extrabold text-[#0F47AF]">
                <Sparkles size={20} /> Genera amb IA
              </button>
            )}
            <button onClick={() => setChoosing(true)} className="btn-press flex items-center gap-2 rounded-2xl bg-[#0F47AF] px-5 py-3 text-lg font-extrabold text-white">
              <Plus size={20} /> Nova activitat
            </button>
          </div>
        )}
      </div>

      {error && <p className="mt-4 rounded-2xl bg-coral/10 p-3 text-lg text-coral">{error}</p>}

      {generating && (
        <ActivityAgent
          onClose={() => setGenerating(false)}
          onDraft={(activity, notes) => { setGenerating(false); setDraftNotes(notes); setEditing({ initial: activity }); }}
        />
      )}

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
      {preview && <ActivityPreview activity={preview} onClose={() => setPreview(undefined)} />}
    </>
  );
}
