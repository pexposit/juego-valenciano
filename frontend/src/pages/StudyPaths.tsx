import { useCallback, useEffect, useState } from 'react';
import { levelLabel } from '@parlaval/shared';
import { Logo } from '../components/ui';
import { LessonModal } from '../components/LessonModal';
import { fetchResources, fetchStudyPaths } from '../lib/api';
import { PathCard, PathDetail } from '../features/paths/PathViews';
import type { Resource, StudyPath } from '../lib/types';

/**
 * Rutes recomanades de l'A2 i el B1 (substituïxen la ruta generada per la IA): les predefinides
 * del nivell. Les rutes del professorat són en «Classe». Un pas està fet quan l'usuari ha acabat
 * l'activitat alguna vegada.
 */
export function StudyPaths({ onOpen, onBack }: { onOpen: (resource: Resource) => void; onBack: () => void }) {
  // undefined = carregant; null = error.
  const [data, setData] = useState<{ level: string; paths: StudyPath[] } | null>();
  const [error, setError] = useState<string>();
  const [catalog, setCatalog] = useState<Map<string, Resource>>(new Map());
  const [selectedId, setSelectedId] = useState<string>();
  const [lesson, setLesson] = useState<Resource>();

  // El progrés canvia en acabar activitats: es torna a demanar en entrar i en recuperar el focus.
  const load = useCallback(() => {
    fetchStudyPaths()
      .then(d => { setData(d); setError(undefined); })
      .catch(err => { setError(err instanceof Error ? err.message : 'No hem pogut carregar les rutes'); setData(null); });
  }, []);

  useEffect(() => {
    load();
    fetchResources().then(rs => setCatalog(new Map(rs.map(r => [r.id, r])))).catch(() => {});
    window.addEventListener('focus', load);
    return () => window.removeEventListener('focus', load);
  }, [load]);

  const selected = data?.paths.find(p => p.id === selectedId);

  return (
    <main className="fade-up relative min-h-screen bg-cream text-ink">
      <header className="classroom-header z-10">
        <div className="relative isolate flex items-center justify-between px-5 p-4">
          <button
            onClick={selected ? () => setSelectedId(undefined) : onBack}
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
                  una activitat que ja has fet compta en totes les rutes on apareix. Les rutes del teu professorat són en «Classe».
                </p>
              </div>
            </section>

            <ul className="flex flex-col gap-3">
              {data.paths.map(path => <PathCard key={path.id} path={path} onSelect={() => setSelectedId(path.id)} />)}
            </ul>
          </>
        )}

        {selected && <PathDetail path={selected} eyebrow="Ruta recomanada" catalog={catalog} onOpen={onOpen} onLesson={setLesson} />}
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
