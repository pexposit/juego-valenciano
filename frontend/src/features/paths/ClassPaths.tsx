import { useCallback, useEffect, useMemo, useState } from 'react';
import { LEVEL_CEFR } from '@parlaval/shared';
import { ArrowDown, ArrowUp, Pencil, Plus, Route, Trash2, X } from 'lucide-react';
import { categoryLabel } from '../../components/ScenarioSelect';
import { ActivityPicker } from './ActivityPicker';
import { fetchResources } from '../../lib/api';
import type { Resource } from '../../lib/types';
import { deleteClassPath, loadClassPaths, PATH_LEVELS, saveClassPath, type ClassPath } from './teacherPaths';

const FIELD = 'w-full rounded-2xl border-2 border-gray-100 p-3 text-lg outline-none focus:border-[#0F47AF] transition-colors';
const MAX_STEPS = 40;
const levelLabel = (level: string) => PATH_LEVELS.find(l => l.value === level)?.label ?? level;
const messageOf = (error: unknown) => (error as { message?: string } | null)?.message ?? 'Hi ha hagut un error';

type Draft = { id?: string; level: string; title: string; description: string; resources: string[] };

/**
 * Rutes d'aprenentatge que la docent crea per a una classe (A2 o B1). L'alumnat de la classe
 * les veu en «La meua ruta», al costat de les rutes predefinides del seu nivell.
 */
export function ClassPaths({ classId, classLevels, onSaved }: { classId: string; classLevels: string[]; onSaved?: () => void }) {
  // Les rutes són per a l'A2 i el B1: només els d'estos nivells que té la classe.
  const levels = PATH_LEVELS.filter(l => LEVEL_CEFR[l.value].some(c => classLevels.includes(c)));
  const [paths, setPaths] = useState<ClassPath[]>();
  const [catalog, setCatalog] = useState<Resource[]>([]);
  const [draft, setDraft] = useState<Draft>();
  const [error, setError] = useState<string>();

  useEffect(() => {
    setPaths(undefined);
    setDraft(undefined);
    loadClassPaths(classId).then(setPaths).catch(e => { console.error(e); setError("No s'han pogut carregar les rutes."); });
  }, [classId]);

  useEffect(() => {
    fetchResources().then(rs => setCatalog(rs.filter(r => r.playable))).catch(console.error);
  }, []);

  const byId = useMemo(() => new Map(catalog.map(r => [r.id, r])), [catalog]);

  const remove = async (path: ClassPath) => {
    if (!confirm(`Segur que vols esborrar la ruta «${path.title}»?`)) return;
    try {
      await deleteClassPath(path.id);
      setPaths(list => list?.filter(p => p.id !== path.id));
    } catch (e) {
      setError(messageOf(e));
    }
  };

  const saved = (path: ClassPath) => {
    setPaths(list => {
      const others = (list ?? []).filter(p => p.id !== path.id);
      return [path, ...others];
    });
    setDraft(undefined);
    onSaved?.();
  };

  return (
    <section className="mt-5 rounded-3xl bg-white p-5 shadow-sm">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <h3 className="flex items-center gap-2 text-2xl font-black"><Route size={24} /> Rutes d'aprenentatge</h3>
        {!draft && levels.length > 0 && (
          <button
            onClick={() => setDraft({ level: levels[0].value, title: '', description: '', resources: [] })}
            className="btn-press flex items-center gap-2 rounded-2xl bg-[#0F47AF] px-4 py-2 font-extrabold text-white"
          >
            <Plus size={18} /> Nova ruta
          </button>
        )}
      </div>
      <p className="mt-1 text-base opacity-60">
        {levels.length
          ? "Rutes per a l'alumnat d'esta classe: les veuen en la secció «Classe»."
          : "Les rutes són per a classes d'A1 a B2."}
      </p>
      {error && <p className="mt-3 rounded-2xl bg-coral/10 p-3 text-coral">{error}</p>}

      {draft ? (
        <PathEditor
          draft={draft}
          levels={levels}
          classLevels={classLevels}
          catalog={catalog}
          byId={byId}
          onCancel={() => setDraft(undefined)}
          onSave={async d => {
            setError(undefined);
            try {
              saved(await saveClassPath(classId, d));
            } catch (e) {
              setError(messageOf(e));
            }
          }}
        />
      ) : paths === undefined ? (
        <p className="mt-4 text-lg opacity-60">Carregant les rutes...</p>
      ) : paths.length === 0 ? (
        <p className="mt-4 text-lg opacity-70">Encara no has creat cap ruta per a esta classe.</p>
      ) : (
        <ul className="mt-4 flex flex-col gap-3">
          {paths.map(path => (
            <li key={path.id} className="flex flex-wrap items-start gap-3 rounded-2xl border border-gray-100 p-4">
              <div className="min-w-0 flex-1">
                <p className="text-sm font-black text-teal">{levelLabel(path.level)} · {path.resources.length} activitats</p>
                <p className="text-xl font-black">{path.title}</p>
                {path.description && <p className="text-base opacity-70">{path.description}</p>}
              </div>
              <button onClick={() => setDraft({ ...path })} className="btn-press flex items-center gap-1 rounded-full px-3 py-2 font-bold text-[#0F47AF] hover:bg-gray-50">
                <Pencil size={16} /> Edita
              </button>
              <button onClick={() => void remove(path)} aria-label={`Esborra la ruta ${path.title}`} className="btn-press p-2 text-gray-400 hover:text-coral">
                <Trash2 size={18} />
              </button>
            </li>
          ))}
        </ul>
      )}
    </section>
  );
}

function PathEditor({ draft: initial, levels, classLevels, catalog, byId, onCancel, onSave }: {
  draft: Draft;
  classLevels: string[];
  levels: typeof PATH_LEVELS[number][];
  catalog: Resource[];
  byId: Map<string, Resource>;
  onCancel: () => void;
  onSave: (draft: Draft) => Promise<void>;
}) {
  const [draft, setDraft] = useState(initial);
  const [saving, setSaving] = useState(false);
  const set = (patch: Partial<Draft>) => setDraft(d => ({ ...d, ...patch }));

  const chosen = useMemo(() => new Set(draft.resources), [draft.resources]);
  // Activitats de la docent d'un altre nivell de la classe: no surten fins que es canvia el nivell.
  const ownElsewhere = catalog.filter(r => r.class_activity && r.difficulty !== draft.level && levels.some(l => l.value === r.difficulty)
    && classLevels.includes(r.cefr_level ?? ''));
  // Del nivell de la ruta; les de la docent, a més, d'un nivell del MECR de la classe.
  const accepts = useCallback(
    (r: Resource) => r.difficulty === draft.level && (!r.class_activity || classLevels.includes(r.cefr_level ?? '')),
    [draft.level, classLevels],
  );

  const move = (i: number, delta: number) => {
    const list = [...draft.resources];
    [list[i], list[i + delta]] = [list[i + delta], list[i]];
    set({ resources: list });
  };

  const changeLevel = (level: string) => {
    if (level === draft.level) return;
    if (draft.resources.length && !confirm("En canviar de nivell es buidarà la llista d'activitats. Vols continuar?")) return;
    set({ level, resources: [] });
  };

  const valid = draft.title.trim().length > 0 && draft.resources.length > 0;
  const save = async () => {
    if (!valid || saving) return;
    setSaving(true);
    await onSave({ ...draft, title: draft.title.trim(), description: draft.description.trim() });
    setSaving(false);
  };

  return (
    <div className="mt-4 flex flex-col gap-4">
      <div className="grid gap-3 sm:grid-cols-[1fr_auto]">
        <label className="block">
          <span className="text-sm font-extrabold">Títol</span>
          <input value={draft.title} maxLength={80} onChange={e => set({ title: e.target.value })} placeholder="Ex.: Repàs dels pronoms febles" className={FIELD} />
        </label>
        <label className="block">
          <span className="text-sm font-extrabold">Nivell</span>
          <select value={draft.level} onChange={e => changeLevel(e.target.value)} className={`${FIELD} bg-white`}>
            {levels.map(l => <option key={l.value} value={l.value}>{l.label}</option>)}
          </select>
        </label>
      </div>
      <label className="block">
        <span className="text-sm font-extrabold">Descripció (opcional)</span>
        <textarea value={draft.description} maxLength={400} rows={2} onChange={e => set({ description: e.target.value })} className={FIELD} />
      </label>

      <div className="grid gap-4 lg:grid-cols-2">
        <div>
          <p className="text-sm font-extrabold">Activitats de la ruta ({draft.resources.length}/{MAX_STEPS})</p>
          {draft.resources.length === 0 ? (
            <p className="mt-2 rounded-2xl bg-gray-50 p-4 text-base opacity-70">Afig activitats des de la llista del costat.</p>
          ) : (
            <ol className="mt-2 flex flex-col gap-2">
              {draft.resources.map((id, i) => {
                const r = byId.get(id);
                return (
                  <li key={id} className="flex items-center gap-2 rounded-2xl bg-gray-50 px-3 py-2">
                    <span className="w-6 text-right font-black opacity-50">{i + 1}</span>
                    <span className="text-xl" aria-hidden="true">{r?.icon ?? '📘'}</span>
                    <span className="min-w-0 flex-1">
                      <span className="block truncate font-bold">{r?.section_name ?? r?.name ?? id}</span>
                      <span className="block text-xs opacity-60">{r ? categoryLabel(r.category) : ''}</span>
                    </span>
                    <button onClick={() => move(i, -1)} disabled={i === 0} aria-label="Puja" className="btn-press p-1 disabled:opacity-20"><ArrowUp size={18} /></button>
                    <button onClick={() => move(i, 1)} disabled={i === draft.resources.length - 1} aria-label="Baixa" className="btn-press p-1 disabled:opacity-20"><ArrowDown size={18} /></button>
                    <button onClick={() => set({ resources: draft.resources.filter(x => x !== id) })} aria-label="Lleva" className="btn-press p-1 text-gray-400 hover:text-coral"><X size={18} /></button>
                  </li>
                );
              })}
            </ol>
          )}
        </div>

        <div>
          <p className="text-sm font-extrabold">Activitats del {levelLabel(draft.level)}</p>
          <div className="mt-2">
            <ActivityPicker
              catalog={catalog}
              accepts={accepts}
              showLevel
              exclude={chosen}
              disabled={draft.resources.length >= MAX_STEPS}
              onPick={r => set({ resources: [...draft.resources, r.id] })}
            />
          </div>
          {ownElsewhere.length > 0 && (
            <p className="mt-2 rounded-xl bg-mustard/20 px-3 py-2 text-sm">
              Tens {ownElsewhere.length} {ownElsewhere.length === 1 ? 'activitat pròpia' : 'activitats pròpies'} de{' '}
              {[...new Set(ownElsewhere.map(r => levelLabel(r.difficulty ?? '')))].join(' i ')}: canvia el nivell de la ruta per a vore-les.
            </p>
          )}
        </div>
      </div>

      <div className="flex flex-wrap justify-end gap-2">
        <button onClick={onCancel} className="btn-press rounded-2xl px-5 py-3 font-bold text-gray-600 hover:bg-gray-50">Cancel·la</button>
        <button onClick={() => void save()} disabled={!valid || saving} className="btn-press rounded-2xl bg-[#0F47AF] px-6 py-3 font-extrabold text-white disabled:opacity-50">
          {saving ? 'Guardant...' : draft.id ? 'Guarda els canvis' : 'Crea la ruta'}
        </button>
      </div>
    </div>
  );
}
