import { useCallback, useEffect, useMemo, useState } from 'react';
import { BookOpen } from 'lucide-react';
import { CONVERSATION_AREAS, PRACTICE_AREAS } from '@parlaval/shared';
import { Logo, ProfileButton } from './ui';
import { LessonModal } from './LessonModal';
import { fetchResources } from '../lib/api';
import type { Resource } from '../lib/types';
import { isRobotAvatarEnabled, preloadRobotAvatar } from '../features/robot-avatar'; // [robot-avatar]

// Noms visibles de les categories conegudes, en l'ordre en què es mostren; la
// resta van darrere, capitalitzades.
const CATEGORY_LABELS: Record<string, string> = {
  escenari: 'Escenaris',
  comprensio_oral: PRACTICE_AREAS.comprensio_oral,
  comprensio_escrita: PRACTICE_AREAS.comprensio_escrita,
  expressio_escrita: PRACTICE_AREAS.expressio_escrita,
  expressio_oral: CONVERSATION_AREAS.expressio_oral,
  fonetica_ortografia: PRACTICE_AREAS.fonetica_ortografia,
  morfosintaxi: PRACTICE_AREAS.morfosintaxi,
  lexic_semantica: PRACTICE_AREAS.lexic_semantica,
  examen: 'Exàmens',
};
const CATEGORY_ORDER = Object.keys(CATEGORY_LABELS);
const categoryRank = (c: string) => {
  const i = CATEGORY_ORDER.indexOf(c);
  return i === -1 ? CATEGORY_ORDER.length : i;
};

// La pantalla es desmunta en entrar en una activitat; la categoria triada es
// guarda a sessionStorage perquè en tornar es mostre la mateixa.
const SELECTED_KEY = 'parlaval.activities.category';
const readSelected = () => {
  try { return sessionStorage.getItem(SELECTED_KEY) ?? undefined; } catch { return undefined; }
};
const writeSelected = (id: string) => {
  try { sessionStorage.setItem(SELECTED_KEY, id); } catch { /* sense emmagatzematge: es perd en tornar */ }
};

const capitalize = (s: string) => s.charAt(0).toUpperCase() + s.slice(1).replace(/_/g, ' ');
const categoryLabel = (c: string) => CATEGORY_LABELS[c] ?? capitalize(c);

type Section = { type: string; resources: Resource[] };
type Category = { id: string; sections: Section[] };

// Agrupa els recursos per categoria i, dins de cada categoria, per tipus
// (secció). Les categories segueixen CATEGORY_LABELS i, dins de cadascuna, es
// manté l'ordre en què arriben del backend.
function groupResources(resources: Resource[]): Category[] {
  const categories = new Map<string, Map<string, Resource[]>>();
  for (const r of resources) {
    const sections = categories.get(r.category) ?? new Map<string, Resource[]>();
    sections.set(r.type, [...(sections.get(r.type) ?? []), r]);
    categories.set(r.category, sections);
  }
  return [...categories]
    .map(([id, sections]) => ({
      id,
      sections: [...sections].map(([type, list]) => ({ type, resources: list })),
    }))
    .sort((a, b) => categoryRank(a.id) - categoryRank(b.id));
}

export function ScenarioSelect({
  name,
  level,
  onSelect,
  onBack,
  onProfile,
}: {
  name: string;
  level: string;
  onSelect: (resource: Resource) => void;
  onBack: () => void;
  onProfile: () => void;
}) {
  const [resources, setResources] = useState<Resource[] | null>(null);
  const [loadError, setLoadError] = useState(false);
  const [selected, setSelected] = useState<string | undefined>(readSelected);
  const [lesson, setLesson] = useState<Resource>();
  const closeLesson = useCallback(() => setLesson(undefined), []);

  useEffect(() => {
    let cancelled = false;
    fetchResources()
      .then(data => { if (!cancelled) setResources(data); })
      .catch(error => {
        console.error('Error carregant les activitats:', error);
        if (!cancelled) setLoadError(true);
      });
    return () => { cancelled = true; };
  }, []);

  // [robot-avatar] En obrir, three.js i el robot normal; en apuntar a un escenari, només
  // la seua roba, perquè el robot del xat aparega de seguida sense baixar-les totes.
  const robotChat = isRobotAvatarEnabled('chat');
  useEffect(() => { if (robotChat) preloadRobotAvatar(); }, [robotChat]);
  const preloadScenario = (type: string) => { if (robotChat) preloadRobotAvatar(type); };

  // Només les activitats del nivell de l'aprenent: resources.difficulty fa servir
  // els mateixos valors que profiles.level (principiant, intermedi, avancat).
  const categories = useMemo(
    () => groupResources((resources ?? []).filter(r => r.difficulty === level)),
    [resources, level],
  );
  const current = categories.find(c => c.id === selected) ?? categories[0];

  return (
    <main className="fade-up relative min-h-screen" style={{ background: '#FFF9ED' }}>
      {/* Classroom header */}
      <header className="classroom-header z-10">
        <div className="relative isolate flex items-center justify-between px-5 p-4">
          <button
            onClick={onBack}
            className="text-xl btn-press rounded-full bg-white/90 px-4 py-2 text-sm font-extrabold text-teal shadow hover:bg-white transition-colors"
          >
            ← Tornar
          </button>
          <Logo onDark />
          <ProfileButton name={name} onClick={onProfile} />
        </div>
      </header>

      <div className="relative z-10 mx-auto max-w-4xl px-5 pt-6 pb-20">
        <h1 className="mb-6 text-4xl text-center font-black uppercase tracking-wider opacity-55">
          ACTIVITATS
        </h1>

        {loadError && (
          <p className="mt-10 text-center text-sm font-bold opacity-50">
            No hem pogut carregar les activitats. Torna-ho a provar més tard.
          </p>
        )}

        {!loadError && !resources && (
          <p className="mt-10 text-center text-sm font-bold opacity-50">Carregant activitats…</p>
        )}

        {resources && categories.length === 0 && (
          <p className="mt-10 text-center text-sm font-bold opacity-50">Encara no hi ha activitats per al teu nivell.</p>
        )}

        {/* Categories (resources.category), generades a partir de la BDD. */}
        {categories.length > 0 && (
          <div className="mb-6 flex flex-wrap items-center justify-center gap-3">
            {categories.map(c => (
              <button
                key={c.id}
                onClick={() => { setSelected(c.id); writeSelected(c.id); }}
                className={`btn-press rounded-full px-4 py-2 text-xl font-black transition-colors ${
                  current?.id === c.id ? 'bg-teal text-white' : 'bg-white text-teal hover:bg-teal/10'
                }`}
              >
                {categoryLabel(c.id)}
              </button>
            ))}
          </div>
        )}

        {/* Seccions de la categoria triada (resources.type). */}
        {current && (
          <div key={current.id} className="desk-grid grid gap-4">
            {current.sections.map(({ type, resources: list }) => {
              const [first] = list;
              // L'aparença de la secció ve de metadata; es pren del primer recurs que la tinga.
              const icon = list.find(r => r.icon)?.icon ?? '📘';
              const color = list.find(r => r.color)?.color ?? '#E7E5E4';
              const title = list.find(r => r.section_name)?.section_name ?? capitalize(type);
              // El backend decidix si la categoria té pantalla i la fila en té les dades.
              const playable = list.find(r => r.playable);
              const withLesson = list.find(r => r.has_lesson);
              return (
                <div
                  key={type}
                  className={`desk-card flex flex-col ${playable ? '' : 'desk-card-disabled'}`}
                  style={{ background: '#fff' }}
                >
                  <button
                    id={`activity-${current.id}-${type}`}
                    disabled={!playable}
                    title={playable ? undefined : 'Pròximament disponible'}
                    onClick={() => playable && onSelect(playable)}
                    onPointerEnter={() => playable && preloadScenario(type)}
                    onFocus={() => playable && preloadScenario(type)}
                    className="flex flex-1 items-stretch text-left disabled:cursor-not-allowed"
                  >
                    <div
                      className="relative flex min-h-28 w-28 shrink-0 self-stretch items-center justify-center overflow-hidden rounded-l-[20px]"
                      style={{ background: color }}
                    >
                      <span className="text-6xl select-none">{icon}</span>
                    </div>
                    <div className="flex flex-1 flex-col justify-center gap-1 px-4 py-3">
                      <h2 className="block text-2xl font-black">{title}</h2>
                      {list.length === 1 ? (
                        <>
                          <p className="text-sm font-bold">{first.name}</p>
                          {first.content && <p className="text-sm opacity-70">{first.content}</p>}
                        </>
                      ) : (
                        <ul className="list-disc pl-4 text-sm">
                          {list.map(r => <li key={r.id}>{r.name}</li>)}
                        </ul>
                      )}
                      {!playable && <p className="text-xs font-bold opacity-50">Pròximament disponible</p>}
                    </div>
                  </button>
                  {/* Lliçó fixa del contingut (metadata.lesson), en un modal. */}
                  {withLesson && (
                    <div className="flex justify-end border-t border-black/5 px-4 py-2">
                      <button
                        id={`lesson-${current.id}-${type}`}
                        onClick={() => setLesson(withLesson)}
                        className="btn-press inline-flex items-center gap-1.5 rounded-full bg-teal/10 px-4 py-1.5 text-sm font-black text-teal hover:bg-teal hover:text-white transition-colors"
                      >
                        <BookOpen className="h-4 w-4" /> Aprendre lliçó
                      </button>
                    </div>
                  )}
                </div>
              );
            })}
          </div>
        )}
      </div>

      {lesson && (
        <LessonModal
          resource={lesson}
          onClose={closeLesson}
          onPractice={lesson.playable ? () => { setLesson(undefined); onSelect(lesson); } : undefined}
        />
      )}
    </main>
  );
}
