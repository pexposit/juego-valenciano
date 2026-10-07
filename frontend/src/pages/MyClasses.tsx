import { useCallback, useEffect, useState, type FormEvent } from 'react';
import { Check, LayoutGrid, Route, School } from 'lucide-react';
import { classLevelLabel, levelLabel } from '@parlaval/shared';
import { Logo } from '../components/ui';
import { LessonModal } from '../components/LessonModal';
import { categoryLabel } from '../components/ScenarioSelect';
import { fetchMyClasses, fetchResources, invalidateResources } from '../lib/api';
import { joinClass } from '../features/kids/tracking';
import { PathCard, PathDetail, startActivity } from '../features/paths/PathViews';
import type { MyClass, Resource } from '../lib/types';

// La classe triada es guarda a sessionStorage perquè en tornar d'una activitat es mostre la mateixa.
const SELECTED_KEY = 'parlaval.classe';
const readSelected = () => {
  try { return sessionStorage.getItem(SELECTED_KEY) ?? undefined; } catch { return undefined; }
};
const writeSelected = (id: string) => {
  try { sessionStorage.setItem(SELECTED_KEY, id); } catch { /* sense emmagatzematge: es perd en tornar */ }
};

function JoinForm({ onJoined, compact = false }: { onJoined: () => void; compact?: boolean }) {
  const [code, setCode] = useState('');
  const [message, setMessage] = useState<{ ok: boolean; text: string }>();
  const join = async (e: FormEvent) => {
    e.preventDefault();
    try {
      const joined = await joinClass(code);
      setCode('');
      setMessage({ ok: true, text: `T'has unit a «${joined.name}».` });
      onJoined();
    } catch (error) {
      setMessage({ ok: false, text: (error as { message?: string } | null)?.message ?? "No t'hem pogut unir a la classe" });
    }
  };
  return (
    <form onSubmit={join} className="rounded-[1.5rem] bg-white p-5 shadow-sm">
      <label htmlFor="class-code" className="block font-black">{compact ? 'Uneix-te a una altra classe' : 'Tens un codi de classe?'}</label>
      {!compact && <p className="mt-1 text-sm opacity-70">Escriu el codi que t'ha donat el teu professor o professora.</p>}
      <div className="mt-3 flex flex-wrap gap-2">
        <input
          id="class-code"
          value={code}
          onChange={e => { setCode(e.target.value.toUpperCase().slice(0, 6)); setMessage(undefined); }}
          placeholder="ABC234"
          autoComplete="off"
          className="w-40 rounded-2xl border-2 border-gray-100 p-3 text-center font-mono text-xl font-black tracking-[0.3em] outline-none focus:border-teal"
        />
        <button type="submit" disabled={code.trim().length < 6} className="btn-press rounded-2xl bg-teal px-5 py-3 font-black text-white disabled:opacity-50">
          Uneix-me
        </button>
      </div>
      {message && <p className={`mt-2 text-sm font-bold ${message.ok ? 'text-teal' : 'text-coral'}`}>{message.text}</p>}
    </form>
  );
}

/**
 * Secció «Classe» de l'alumne: el que el professorat ha posat a les seues classes. Es tria la
 * classe dalt i, de cada una, es veuen les activitats soltes i les rutes, amb el progrés.
 */
export function MyClasses({ onOpen, onBack }: { onOpen: (resource: Resource) => void; onBack: () => void }) {
  // undefined = carregant; null = error.
  const [classes, setClasses] = useState<MyClass[] | null>();
  const [error, setError] = useState<string>();
  const [catalog, setCatalog] = useState<Map<string, Resource>>(new Map());
  const [selectedId, setSelectedId] = useState<string | undefined>(readSelected);
  const [pathId, setPathId] = useState<string>();
  const [lesson, setLesson] = useState<Resource>();

  // El progrés canvia en acabar activitats: es torna a demanar en entrar i en recuperar el focus.
  const load = useCallback(() => {
    fetchMyClasses()
      .then(c => { setClasses(c); setError(undefined); })
      .catch(err => { setError(err instanceof Error ? err.message : 'No hem pogut carregar les teues classes'); setClasses(null); });
  }, []);
  const loadCatalog = useCallback(() => {
    fetchResources().then(rs => setCatalog(new Map(rs.map(r => [r.id, r])))).catch(() => {});
  }, []);

  useEffect(() => {
    load();
    loadCatalog();
    window.addEventListener('focus', load);
    return () => window.removeEventListener('focus', load);
  }, [load, loadCatalog]);

  const joined = () => {
    // Les activitats de la classe nova han d'entrar en el catàleg per a poder obrir-les.
    invalidateResources();
    loadCatalog();
    load();
  };

  const current = classes?.find(c => c.id === selectedId) ?? classes?.[0];
  const path = current?.paths.find(p => p.id === pathId);
  const choose = (id: string) => { setSelectedId(id); writeSelected(id); setPathId(undefined); };

  return (
    <main className="fade-up relative min-h-screen bg-cream text-ink">
      <header className="classroom-header z-10">
        <div className="relative isolate flex items-center justify-between px-5 p-4">
          <button
            onClick={path ? () => setPathId(undefined) : onBack}
            className="text-xl btn-press rounded-full bg-white/90 px-4 py-2 text-sm font-extrabold text-teal shadow hover:bg-white transition-colors"
          >
            ← Tornar
          </button>
          <Logo onDark />
          <span className="w-24" aria-hidden="true" />
        </div>
      </header>

      <div className="mx-auto flex max-w-3xl flex-col gap-6 px-5 pt-6 pb-24">
        {classes === undefined && <p className="text-center text-lg font-bold opacity-60">Carregant les teues classes…</p>}

        {classes === null && (
          <section className="rounded-[2rem] bg-white p-8 text-center shadow-sm">
            <p className="text-xl font-black">{error}</p>
            <button onClick={load} className="btn-press mt-4 rounded-full bg-teal px-6 py-3 font-black text-white hover:bg-teal/90">
              Tornar-ho a provar
            </button>
          </section>
        )}

        {classes?.length === 0 && (
          <>
            <section className="rounded-[2rem] bg-navy p-8 text-white shadow-xl">
              <p className="text-sm font-black uppercase tracking-widest text-mustard">Classe</p>
              <h1 className="mt-1 text-3xl font-black">Encara no estàs en cap classe</h1>
              <p className="mt-3 max-w-xl text-white/80">
                Si el teu professor o professora t'ha donat un codi, escriu-lo ací: veuràs les activitats i les rutes que prepara per a la classe.
              </p>
            </section>
            <JoinForm onJoined={joined} />
          </>
        )}

        {current && path && (
          <PathDetail path={path} eyebrow={`Ruta de la classe ${current.name}`} catalog={catalog} onOpen={onOpen} onLesson={setLesson} />
        )}

        {current && !path && (
          <>
            {classes!.length > 1 && (
              <div className="flex flex-wrap gap-2" role="tablist" aria-label="Les teues classes">
                {classes!.map(c => (
                  <button
                    key={c.id}
                    role="tab"
                    aria-selected={c.id === current.id}
                    onClick={() => choose(c.id)}
                    className={`btn-press rounded-full px-4 py-2 text-lg font-black ${c.id === current.id ? 'bg-teal text-white' : 'bg-white text-teal hover:bg-teal/10'}`}
                  >
                    {c.name}
                  </button>
                ))}
              </div>
            )}

            <section className="relative overflow-hidden rounded-[2rem] bg-navy p-8 text-white shadow-xl">
              <div className="absolute -right-10 -top-10 h-48 w-48 rounded-full bg-mustard/20" aria-hidden="true" />
              <div className="relative">
                <p className="flex items-center gap-2 text-sm font-black uppercase tracking-widest text-mustard">
                  <School size={16} /> Classe · {current.levels.map(classLevelLabel).join(' · ')}
                </p>
                <h1 className="mt-1 text-3xl font-black">{current.name}</h1>
                {current.teacher && <p className="mt-2 text-white/80">Amb {current.teacher}</p>}
              </div>
            </section>

            <section>
              <h2 className="mb-3 flex items-center gap-2 text-lg font-black"><LayoutGrid size={20} /> Activitats</h2>
              {current.activities.length ? (
                <ul className="grid gap-3 sm:grid-cols-2">
                  {current.activities.map(a => {
                    const r = catalog.get(a.resource_id);
                    return (
                      <li key={a.resource_id}>
                        <button
                          onClick={() => r && startActivity(r, a.done, onOpen, setLesson)}
                          disabled={!r}
                          className="btn-press flex h-full w-full items-center gap-4 rounded-[1.5rem] border border-stone-200 bg-white p-4 text-left shadow-sm hover:border-teal disabled:opacity-60"
                        >
                          <span className="grid h-14 w-14 shrink-0 place-items-center rounded-2xl text-3xl" style={{ background: r?.color ?? '#FFF1D6' }}>
                            {r?.icon ?? '📘'}
                          </span>
                          <span className="min-w-0 flex-1">
                            <span className="block text-xs font-black uppercase tracking-wide text-teal">
                              {r ? `${categoryLabel(r.category)} · ${r.class_activity && r.cefr_level ? r.cefr_level : levelLabel(r.difficulty ?? '')}` : 'Activitat'}
                            </span>
                            <span className="block text-lg font-black leading-tight">{r?.section_name ?? r?.name ?? 'Carregant…'}</span>
                            {r?.section_name && <span className="block truncate text-sm opacity-70">{r.name}</span>}
                          </span>
                          {a.done && (
                            <span className="flex shrink-0 items-center gap-1 rounded-full bg-teal/10 px-2.5 py-1 text-xs font-black text-teal">
                              <Check size={14} strokeWidth={3} /> Feta
                            </span>
                          )}
                        </button>
                      </li>
                    );
                  })}
                </ul>
              ) : (
                <p className="rounded-[1.5rem] bg-white p-5 text-base opacity-70">El teu professorat encara no hi ha posat cap activitat.</p>
              )}
            </section>

            <section>
              <h2 className="mb-3 flex items-center gap-2 text-lg font-black"><Route size={20} /> Rutes</h2>
              {current.paths.length ? (
                <ul className="flex flex-col gap-3">
                  {current.paths.map(p => <PathCard key={p.id} path={p} onSelect={() => setPathId(p.id)} />)}
                </ul>
              ) : (
                <p className="rounded-[1.5rem] bg-white p-5 text-base opacity-70">El teu professorat encara no hi ha posat cap ruta.</p>
              )}
            </section>

            <JoinForm onJoined={joined} compact />
          </>
        )}
      </div>

      {lesson && (
        <LessonModal
          resource={lesson}
          onClose={() => setLesson(undefined)}
          onPractice={lesson.playable ? () => { const r = lesson; setLesson(undefined); onOpen(r); } : undefined}
        />
      )}
    </main>
  );
}
