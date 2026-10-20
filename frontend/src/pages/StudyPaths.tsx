import { useCallback, useEffect, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { ChevronRight, Sparkles } from 'lucide-react';
import { levelLabel } from '@parlaval/shared';
import { ROUTES } from '../data/content';
import { Logo } from '../components/ui';
import { LessonModal } from '../components/LessonModal';
import { fetchMyClasses, fetchResources, fetchStudyPaths } from '../lib/api';
import { PathCard, PathDetail } from '../features/paths/PathViews';
import { studyPathRoute } from '../data/content';
import type { MyClass, Resource, StudyPath } from '../lib/types';

/**
 * Les rutes de l'alumne, en dos grups: les recomanades (predefinides del nivell: A2, B1 i B2) i les del seu
 * professorat (les que crea la docent per a les classes on és). Un pas està fet quan l'usuari ha acabat
 * l'activitat alguna vegada. En el B1 i el B2, a més, s'hi enllaça la ruta personalitzada de la IA (`onAiPath`).
 */
export function StudyPaths({ onOpen, onBack, onAiPath }: { onOpen: (resource: Resource) => void; onBack: () => void; onAiPath?: () => void }) {
  // undefined = carregant; null = error.
  const [data, setData] = useState<{ level: string; paths: StudyPath[] } | null>();
  const [error, setError] = useState<string>();
  // Les classes de l'alumne, amb les rutes que hi ha posat el professorat.
  const [classes, setClasses] = useState<MyClass[]>([]);
  const [catalog, setCatalog] = useState<Map<string, Resource>>(new Map());
  // La ruta oberta és la de l'adreça (/ruta/<id>): així «Tornar» d'una activitat hi torna exactament.
  const navigate = useNavigate();
  const selectedId = useParams<{ pathId?: string }>().pathId;
  const [lesson, setLesson] = useState<Resource>();

  // El progrés canvia en acabar activitats: es torna a demanar en entrar i en recuperar el focus.
  const load = useCallback(() => {
    fetchStudyPaths()
      .then(d => { setData(d); setError(undefined); })
      .catch(err => { setError(err instanceof Error ? err.message : 'No hem pogut carregar les rutes'); setData(null); });
    // Si les classes no carreguen, es veuen només les recomanades.
    fetchMyClasses().then(setClasses).catch(() => setClasses([]));
  }, []);

  useEffect(() => {
    load();
    fetchResources().then(rs => setCatalog(new Map(rs.map(r => [r.id, r])))).catch(() => {});
    window.addEventListener('focus', load);
    return () => window.removeEventListener('focus', load);
  }, [load]);

  // Les rutes del professorat, per classe; les recomanades són les predefinides.
  const teacherGroups = classes.filter(c => c.paths.length > 0);
  const allPaths = [...(data?.paths ?? []), ...teacherGroups.flatMap(c => c.paths)];
  const selected = allPaths.find(p => p.id === selectedId);
  const selectedClass = selected && teacherGroups.find(c => c.paths.some(p => p.id === selected.id));

  return (
    <main className="fade-up relative min-h-screen bg-cream text-ink">
      <header className="classroom-header z-10">
        <div className="relative isolate flex items-center justify-between px-5 p-4">
          <button
            onClick={selected ? () => navigate(ROUTES.learningpath) : onBack}
            className="text-xl btn-press rounded-full bg-white/90 px-4 py-2 text-sm font-extrabold text-teal shadow hover:bg-white transition-colors"
          >
            ← Tornar
          </button>
          <Logo onDark />
          <span className="w-24" aria-hidden="true" />
        </div>
      </header>

      <div className="mx-auto flex max-w-3xl flex-col gap-6 px-5 pt-6 pb-24">
        {data === undefined && <p className="text-center text-lg font-bold opacity-60">Carregant les rutes…</p>}

        {data === null && (
          <section className="rounded-[2rem] bg-white p-8 text-center shadow-sm">
            <p className="text-xl font-black">{error}</p>
            <button onClick={load} className="btn-press mt-4 rounded-full bg-teal px-6 py-3 font-black text-white hover:bg-teal/90">
              Tornar-ho a provar
            </button>
          </section>
        )}

        {data && !selected && (
          <>
            <section className="relative overflow-hidden rounded-[2rem] bg-navy p-8 text-white shadow-xl">
              <div className="absolute -right-10 -top-10 h-48 w-48 rounded-full bg-mustard/20" aria-hidden="true" />
              <div className="relative">
                <p className="text-sm font-black uppercase tracking-widest text-mustard">Rutes d'aprenentatge · {levelLabel(data.level)}</p>
                <h1 className="mt-1 text-3xl font-black">Tria per on vols començar</h1>
                <p className="mt-3 max-w-xl text-white/80">
                  Cada ruta és una tria d'activitats en un ordre pensat per a avançar. Pots seguir-ne diverses alhora:
                  una activitat que ja has fet compta en totes les rutes on apareix. Les rutes que prepara el teu professorat són més avall.
                </p>
              </div>
            </section>

            {onAiPath && (
              <button
                onClick={onAiPath}
                className="btn-press flex items-center gap-4 rounded-3xl border-2 border-teal bg-white p-5 text-left shadow-sm transition-colors hover:bg-teal/5"
              >
                <span className="grid h-12 w-12 shrink-0 place-items-center rounded-2xl bg-teal text-white" aria-hidden="true">
                  <Sparkles size={24} />
                </span>
                <span className="flex-1">
                  <span className="block text-lg font-black">La teua ruta personalitzada</span>
                  <span className="block text-sm opacity-70">Una ruta feta a partir dels teus errors i resultats. La generes quan vulgues.</span>
                </span>
                <ChevronRight className="shrink-0 text-teal" aria-hidden="true" />
              </button>
            )}

            {/* Grup 1: rutes recomanades (predefinides). */}
            <section aria-labelledby="paths-recommended" className="flex flex-col gap-3">
              <h2 id="paths-recommended" className="text-xl font-black">Rutes recomanades</h2>
              <p className="-mt-2 text-sm opacity-60">Preparades per a tots els qui estan en el teu nivell.</p>
              {data.paths.length ? (
                <ul className="flex flex-col gap-3">
                  {data.paths.map(path => <PathCard key={path.id} path={path} onSelect={() => navigate(studyPathRoute(path.id))} />)}
                </ul>
              ) : (
                <p className="rounded-[1.5rem] bg-white p-5 text-base opacity-70">Encara no hi ha rutes recomanades per al teu nivell.</p>
              )}
            </section>

            {/* Grup 2: rutes creades pel professorat, per classe. */}
            {teacherGroups.length > 0 && (
              <section aria-labelledby="paths-teacher" className="flex flex-col gap-3">
                <h2 id="paths-teacher" className="text-xl font-black">Rutes del teu professorat</h2>
                <p className="-mt-2 text-sm opacity-60">Les ha creades la teua docent per a la classe on estàs.</p>
                {teacherGroups.map(c => (
                  <div key={c.id} className="flex flex-col gap-3">
                    <h3 className="text-sm font-black uppercase tracking-wide text-teal">Classe {c.name}</h3>
                    <ul className="flex flex-col gap-3">
                      {c.paths.map(path => <PathCard key={path.id} path={path} onSelect={() => navigate(studyPathRoute(path.id))} />)}
                    </ul>
                  </div>
                ))}
              </section>
            )}
          </>
        )}

        {selected && <PathDetail path={selected} eyebrow={selectedClass ? `Ruta de la classe ${selectedClass.name}` : 'Ruta recomanada'} catalog={catalog} onOpen={onOpen} onLesson={setLesson} />}
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
