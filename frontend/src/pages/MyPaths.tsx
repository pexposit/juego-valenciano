import { useEffect, useMemo, useState, type FormEvent } from 'react';
import { ChevronRight, Compass, Sparkles } from 'lucide-react';
import { Logo } from '../components/ui';
import { fetchResources } from '../lib/api';
import { enrollPath, loadMyPaths, weekStart, loadPublicPaths, unenrollPath, type MyPath, type PathAudience, type StudyPath } from '../lib/paths';
import { supabase } from '../lib/supabase';
import type { Resource } from '../lib/types';
import { LEVEL_OPTIONS } from '../data/content';
import { countDone, PathSteps, ProgressBar, useAssignmentState } from '../features/paths/PathSteps';
import { joinClass } from '../features/kids/tracking';

const levelLabel = (level: string | null) => LEVEL_OPTIONS.find(o => o.value === level)?.label ?? 'Tots els nivells';
const shortDate = (d: string) => new Date(d).toLocaleDateString('ca-ES', { weekday: 'long', day: 'numeric', month: 'short' });
/** D'on ve una ruta o uns deures, per a l'etiqueta de dalt. */
const origin = (p: MyPath) => (p.due_at
  ? `Deures · fins ${shortDate(p.due_at)}${p.class_name ? '' : ' · només per a tu'}`
  : p.class_name ? `Classe ${p.class_name}` : 'Triada per tu');

/**
 * Les rutes de l'aprenent: les que li ha assignat la docent (per la classe) i les que ha
 * triat d'entre les públiques. Cada ruta mostra els seus passos amb el següent destacat;
 * es poden fer en qualsevol ordre. Les persones adultes s'unixen ací a una classe amb el
 * codi; per als xiquets ho fa la família, en el seguiment.
 */
export function MyPaths({ uid, ageGroup, onOpen, onAiPath, onBack }: {
  uid: string | undefined;
  ageGroup: string;
  onOpen: (route: string) => void;
  onAiPath: () => void;
  onBack: () => void;
}) {
  const audience: PathAudience = ageGroup === 'child' ? 'child' : 'adult';
  const [mine, setMine] = useState<MyPath[]>();
  const [available, setAvailable] = useState<StudyPath[]>([]);
  const [resources, setResources] = useState<Resource[]>([]);
  const [open, setOpen] = useState<MyPath>();
  const [code, setCode] = useState('');
  const [message, setMessage] = useState<string>();
  const online = !!supabase && !!uid;

  const reload = () => {
    if (!online) return;
    Promise.all([loadMyPaths(uid!), loadPublicPaths(audience)])
      .then(([m, pub]) => { setMine(m); setAvailable(pub); })
      .catch(e => {
        console.error(e);
        setMessage("No s'han pogut carregar les rutes.");
        setMine([]);
      });
  };

  useEffect(reload, [uid, online, audience]); // eslint-disable-line react-hooks/exhaustive-deps
  useEffect(() => { fetchResources().then(setResources).catch(console.error); }, []);

  const byId = useMemo(() => new Map(resources.map(r => [r.id, r])), [resources]);
  // Deures d'esta setmana i de les següents (els d'abans ja no es mostren); les rutes, sempre.
  const homework = mine?.filter(p => p.due_at && Date.parse(p.due_at) >= weekStart().getTime())
    .sort((a, b) => Date.parse(a.due_at!) - Date.parse(b.due_at!)) ?? [];
  const routes = mine?.filter(p => !p.due_at);
  const enrolled = new Set(routes?.map(p => p.id));

  const enroll = async (path: StudyPath) => {
    try {
      await enrollPath(uid!, path.id);
      reload();
    } catch (e) {
      console.error(e);
      setMessage("No t'hem pogut apuntar a la ruta.");
    }
  };

  const leave = async (path: MyPath) => {
    if (!confirm(`Vols deixar la ruta «${path.title}»? El que has fet no es perd.`)) return;
    await unenrollPath(path.assignment_id).catch(console.error);
    setOpen(undefined);
    reload();
  };

  const join = async (e: FormEvent) => {
    e.preventDefault();
    try {
      const joined = await joinClass(code);
      setCode('');
      setMessage(`T'has unit a la classe «${joined.name}».`);
      reload();
    } catch (error) {
      console.error(error);
      setMessage('No hi ha cap classe amb este codi.');
    }
  };

  return (
    <main className="fade-up relative min-h-screen bg-cream text-ink">
      <header className="classroom-header z-10">
        <div className="relative isolate flex items-center justify-between px-5 p-4">
          <button
            onClick={open ? () => setOpen(undefined) : onBack}
            className="text-xl btn-press rounded-full bg-white/90 px-4 py-2 text-sm font-extrabold text-teal shadow hover:bg-white transition-colors"
          >
            ← Tornar
          </button>
          <Logo />
          <span className="w-24" aria-hidden="true" />
        </div>
      </header>

      <div className="mx-auto flex max-w-3xl flex-col gap-6 px-5 pt-6 pb-24">
        {message && <p className="rounded-2xl bg-white p-3 text-lg font-bold text-teal shadow-sm">{message}</p>}

        {!online ? (
          <section className="rounded-[2rem] bg-white p-8 text-center shadow-sm">
            <Compass size={36} className="mx-auto text-teal" />
            <p className="mt-3 text-xl font-black">Inicia sessió per a seguir rutes d'aprenentatge.</p>
          </section>
        ) : open ? (
          <PathDetail uid={uid!} path={open} resources={byId} onOpen={onOpen} onLeave={() => void leave(open)} />
        ) : (
          <>
            {homework.length > 0 && (
              <section>
                <h1 className="text-4xl font-black">Els meus deures</h1>
                <ul className="mt-4 flex flex-col gap-3">
                  {homework.map(p => <li key={p.assignment_id}><PathCard uid={uid!} path={p} onClick={() => setOpen(p)} /></li>)}
                </ul>
              </section>
            )}

            <section>
              <h1 className="text-4xl font-black">Les meues rutes</h1>
              <p className="mt-1 text-lg opacity-70">Les activitats que t'ha preparat la teua docent i les rutes que has triat.</p>
              {!routes ? (
                <p className="mt-4 opacity-60">Carregant…</p>
              ) : !routes.length ? (
                <p className="mt-4 rounded-2xl bg-white p-5 text-lg shadow-sm">
                  Encara no tens cap ruta.
                  {available.some(p => !enrolled.has(p.id)) ? ` Tria'n una de baix${audience === 'adult' ? ' o uneix-te a la teua classe' : ''}.` : audience === 'adult' ? ' Uneix-te a la teua classe amb el codi.' : ''}
                </p>
              ) : (
                <ul className="mt-4 flex flex-col gap-3">
                  {routes.map(p => <li key={p.assignment_id}><PathCard uid={uid!} path={p} onClick={() => setOpen(p)} /></li>)}
                </ul>
              )}
            </section>

            {audience === 'adult' && (
              <form onSubmit={join} className="rounded-3xl bg-white p-5 shadow-sm">
                <label className="block text-xl font-extrabold" htmlFor="class-code">Uneix-te a una classe</label>
                <p className="text-base opacity-70">Escriu el codi que t'ha donat la teua docent o acadèmia.</p>
                <div className="mt-2 flex gap-2">
                  <input
                    id="class-code"
                    value={code}
                    onChange={e => setCode(e.target.value.toUpperCase().replace(/[^A-Z0-9]/g, '').slice(0, 6))}
                    placeholder="ABC234"
                    className="w-full rounded-2xl border-2 border-gray-100 p-3 font-mono text-2xl tracking-[0.3em] outline-none focus:border-[#0F47AF]"
                  />
                  <button disabled={code.length !== 6} className="btn-press shrink-0 rounded-2xl bg-[#0F47AF] px-5 text-xl font-extrabold text-white disabled:opacity-40">
                    Entra
                  </button>
                </div>
              </form>
            )}

            {available.some(p => !enrolled.has(p.id)) && (
              <section>
                <h2 className="text-2xl font-black">Tria una ruta</h2>
                <ul className="mt-3 grid gap-3 sm:grid-cols-2">
                  {available.filter(p => !enrolled.has(p.id)).map(p => (
                    <li key={p.id} className="flex flex-col rounded-3xl bg-white p-5 shadow-sm">
                      <span className="text-xs font-black uppercase tracking-wide text-teal">{levelLabel(p.level)}</span>
                      <span className="mt-1 text-xl font-black">{p.title}</span>
                      {p.description && <span className="mt-1 flex-1 opacity-70">{p.description}</span>}
                      <button onClick={() => void enroll(p)} className="btn-press mt-3 self-start rounded-full bg-teal px-5 py-2 font-black text-white hover:bg-teal/90">
                        Comença-la
                      </button>
                    </li>
                  ))}
                </ul>
              </section>
            )}

            {/* Mentre convisca amb les rutes predefinides. */}
            {audience === 'adult' && (
              <button onClick={onAiPath} className="btn-press flex items-center justify-center gap-2 self-center rounded-full bg-white px-5 py-2 font-black text-teal shadow hover:bg-teal/10">
                <Sparkles size={18} /> La meua ruta personalitzada
              </button>
            )}
          </>
        )}
      </div>
    </main>
  );
}

function PathCard({ uid, path, onClick }: { uid: string; path: MyPath; onClick: () => void }) {
  const state = useAssignmentState(path.assignment_id, path.id, uid);
  const complete = !!state && state.items.length > 0 && countDone(state) === state.items.length;
  return (
    <button onClick={onClick} className="btn-press flex w-full items-center gap-4 rounded-3xl bg-white p-5 text-left shadow-sm hover:bg-white/80">
      <span className="min-w-0 flex-1">
        <span className={`block text-xs font-black uppercase tracking-wide ${path.due_at ? 'text-orange' : 'text-teal'}`}>{origin(path)}</span>
        <span className="mt-1 block text-xl font-black">{path.title}{complete && ' ✅'}</span>
        <span className="mt-3 block">{state ? <ProgressBar done={countDone(state)} total={state.items.length} /> : <span className="opacity-50">…</span>}</span>
      </span>
      <ChevronRight className="shrink-0 opacity-40" />
    </button>
  );
}

function PathDetail({ uid, path, resources, onOpen, onLeave }: {
  uid: string;
  path: MyPath;
  resources: Map<string, Resource>;
  onOpen: (route: string) => void;
  onLeave: () => void;
}) {
  const state = useAssignmentState(path.assignment_id, path.id, uid);
  return (
    <>
      <section className="rounded-[2rem] bg-navy p-7 text-white shadow-xl">
        <p className="text-sm font-black uppercase tracking-widest text-mustard">{path.due_at || path.class_name ? origin(path) : levelLabel(path.level)}</p>
        <h1 className="mt-1 text-3xl font-black">{path.title}</h1>
        {path.description && <p className="mt-2 text-white/80">{path.description}</p>}
        {state && <div className="mt-5 text-white"><ProgressBar done={countDone(state)} total={state.items.length} onDark /></div>}
      </section>
      {state === undefined && <p className="opacity-60">Carregant…</p>}
      {state === null && <p className="text-coral">No s'ha pogut carregar la ruta.</p>}
      {state && <PathSteps state={state} resources={resources} onOpen={onOpen} />}
      {path.own && !path.due_at && (
        <button onClick={onLeave} className="btn-press self-center text-sm font-bold text-gray-500 hover:text-coral">Deixa esta ruta</button>
      )}
    </>
  );
}
