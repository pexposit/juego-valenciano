import { useEffect, useMemo, useState } from 'react';
import { ArrowDown, ArrowUp, Trash2, X } from 'lucide-react';
import { LEVEL_OPTIONS } from '../../data/content';
import { loadPathItems, savePath, type PathAudience, type PathItemDraft, type StudyPath } from '../../lib/paths';
import type { Resource } from '../../lib/types';
import { itemKey, resolveItem } from './catalog';
import { CatalogPicker } from './CatalogPicker';

const FIELD_CLASS = 'w-full rounded-2xl border-2 border-gray-100 p-3 text-lg font-normal outline-none focus:border-[#0F47AF] transition-colors';

/**
 * Editor d'una ruta: les dades (títol, públic, nivell) i els passos, en ordre, triats del
 * catàleg. `base` és la ruta que s'edita; si no és de la docent (una pública), se'n fa una
 * còpia. Es guarda tot de colp.
 */
export function PathEditor({ uid, base, canPublish, resources, onSaved, onCancel }: {
  uid: string;
  base: StudyPath | null;
  canPublish: boolean;
  resources: Resource[];
  onSaved: (path: StudyPath) => void;
  onCancel: () => void;
}) {
  const copying = !!base && base.owner_id !== uid;
  const [title, setTitle] = useState(base ? (copying ? `${base.title} (còpia)`.slice(0, 80) : base.title) : '');
  const [description, setDescription] = useState(base?.description ?? '');
  const [audience, setAudience] = useState<PathAudience>(base?.audience ?? 'adult');
  const [level, setLevel] = useState<string>(base?.level ?? '');
  const [isPublic, setIsPublic] = useState(!copying && !!base?.is_public);
  const [items, setItems] = useState<PathItemDraft[]>();
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string>();

  useEffect(() => {
    if (!base) return setItems([]);
    loadPathItems(base.id)
      .then(list => setItems(list.map(({ kind, resource_id, kids_ref, note }) => ({ kind, resource_id, kids_ref, note }))))
      .catch(e => {
        console.error(e);
        setError("No s'han pogut carregar els passos.");
        setItems([]);
      });
  }, [base]);

  const byId = useMemo(() => new Map(resources.map(r => [r.id, r])), [resources]);
  const added = new Set((items ?? []).map(itemKey));

  const move = (i: number, delta: number) => setItems(list => {
    if (!list) return list;
    const copy = [...list];
    [copy[i], copy[i + delta]] = [copy[i + delta], copy[i]];
    return copy;
  });
  const update = (i: number, note: string) => setItems(list => list?.map((it, j) => (j === i ? { ...it, note } : it)));

  const save = async () => {
    if (!items) return;
    setSaving(true);
    setError(undefined);
    try {
      const saved = await savePath({
        id: copying ? undefined : base?.id,
        owner_id: uid,
        title: title.trim(),
        description: description.trim(),
        audience,
        level: level || null,
        is_public: canPublish && isPublic,
      }, items);
      onSaved(saved);
    } catch (e) {
      console.error(e);
      setError("No s'ha pogut guardar la ruta.");
      setSaving(false);
    }
  };

  return (
    <>
      <div className="flex flex-wrap items-center justify-between gap-3">
        <h1 className="text-4xl font-black">{base && !copying ? 'Edita la ruta' : 'Nova ruta'}</h1>
        <div className="flex gap-2">
          <button onClick={onCancel} className="btn-press rounded-2xl px-4 py-2 text-lg font-bold text-gray-500 hover:text-ink">Cancel·la</button>
          <button
            onClick={() => void save()}
            disabled={saving || !title.trim() || !items?.length}
            className="btn-press rounded-2xl bg-[#0F47AF] px-5 py-2 text-lg font-extrabold text-white disabled:opacity-40"
          >
            {saving ? 'Guardant…' : 'Guarda'}
          </button>
        </div>
      </div>
      {error && <p className="mt-4 rounded-2xl bg-coral/10 p-3 text-lg text-coral">{error}</p>}

      <section className="mt-5 grid gap-3 rounded-3xl bg-white p-5 shadow-sm sm:grid-cols-2">
        <label className="sm:col-span-2">
          <span className="block font-extrabold">Títol</span>
          <input value={title} onChange={e => setTitle(e.target.value.slice(0, 80))} placeholder="P. ex.: Preparació del B1 · Trimestre 1" className={FIELD_CLASS} />
        </label>
        <label className="sm:col-span-2">
          <span className="block font-extrabold">Descripció per a l'alumnat</span>
          <textarea value={description} onChange={e => setDescription(e.target.value.slice(0, 600))} rows={2} className={FIELD_CLASS} />
        </label>
        <label>
          <span className="block font-extrabold">Per a</span>
          <select value={audience} onChange={e => setAudience(e.target.value as PathAudience)} className={FIELD_CLASS}>
            <option value="adult">Persones adultes</option>
            <option value="child">Xiquets i xiquetes</option>
          </select>
        </label>
        <label>
          <span className="block font-extrabold">Nivell</span>
          <select value={level} onChange={e => setLevel(e.target.value)} className={FIELD_CLASS}>
            <option value="">Tots els nivells</option>
            {LEVEL_OPTIONS.map(o => <option key={o.value} value={o.value}>{o.label}</option>)}
          </select>
        </label>
        {canPublish && (
          <label className="flex items-center gap-3 sm:col-span-2">
            <input type="checkbox" checked={isPublic} onChange={e => setIsPublic(e.target.checked)} className="h-5 w-5" />
            <span className="text-lg">Ruta pública: la pot triar qualsevol aprenent{audience === 'child' ? ' (la família, en el compte del xiquet)' : ''}.</span>
          </label>
        )}
      </section>

      <div className="mt-5 grid gap-5 lg:grid-cols-2">
        <section className="rounded-3xl bg-white p-5 shadow-sm">
          <h2 className="text-2xl font-black">Passos ({items?.length ?? 0})</h2>
          {!items ? (
            <p className="mt-3 opacity-60">Carregant…</p>
          ) : !items.length ? (
            <p className="mt-3 text-lg opacity-60">Afig activitats del catàleg.</p>
          ) : (
            <ol className="mt-3 flex flex-col gap-2">
              {items.map((item, i) => {
                const r = resolveItem(item, byId);
                return (
                  <li key={itemKey(item)} className="rounded-2xl border border-gray-100 p-3">
                    <div className="flex items-center gap-2">
                      <span className="w-6 text-right font-black opacity-40">{i + 1}</span>
                      <span className="text-2xl" aria-hidden="true">{r.emoji}</span>
                      <span className="min-w-0 flex-1">
                        <span className="block truncate font-extrabold">{r.title}</span>
                        <span className="block text-sm opacity-60">{r.kindLabel}</span>
                      </span>
                      <button onClick={() => move(i, -1)} disabled={i === 0} aria-label="Puja" className="btn-press p-1 text-gray-400 hover:text-ink disabled:opacity-20"><ArrowUp size={18} /></button>
                      <button onClick={() => move(i, 1)} disabled={i === items.length - 1} aria-label="Baixa" className="btn-press p-1 text-gray-400 hover:text-ink disabled:opacity-20"><ArrowDown size={18} /></button>
                      <button onClick={() => setItems(list => list?.filter((_, j) => j !== i))} aria-label="Lleva" className="btn-press p-1 text-gray-400 hover:text-coral"><X size={18} /></button>
                    </div>
                    <input
                      value={item.note}
                      onChange={e => update(i, e.target.value.slice(0, 300))}
                      placeholder="Indicació per a l'alumnat (opcional)"
                      className="mt-2 w-full rounded-xl bg-gray-50 px-3 py-1.5 text-sm outline-none focus:bg-white focus:ring-2 focus:ring-[#0F47AF]/30"
                    />
                  </li>
                );
              })}
            </ol>
          )}
        </section>

        <section className="rounded-3xl bg-white p-5 shadow-sm">
          <h2 className="text-2xl font-black">Catàleg</h2>
          <div className="mt-3">
            <CatalogPicker resources={resources} level={level || null} audience={audience} exclude={added} onAdd={item => setItems(list => [...(list ?? []), item])} />
          </div>
        </section>
      </div>
    </>
  );
}

/** Botó d'esborrar una ruta (amb confirmació). */
export function DeletePathButton({ path, onDelete }: { path: StudyPath; onDelete: () => void }) {
  return (
    <button
      onClick={() => confirm(`Segur que vols esborrar la ruta «${path.title}»? Es traurà de totes les classes.`) && onDelete()}
      className="btn-press flex items-center gap-1 rounded-full px-3 py-2 font-bold text-gray-500 hover:text-coral"
    >
      <Trash2 size={18} /> Esborra
    </button>
  );
}
