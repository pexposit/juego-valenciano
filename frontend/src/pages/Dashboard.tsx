import { BookOpen, Compass, LayoutGrid, MessageCircle, Target } from 'lucide-react';
import { ChildAssistant } from '../components/ChildAssistant';
import { Logo, ProfileButton } from '../components/ui';
import type { Page } from '../data/content';

export function Dashboard({ name, ageGroup, showMotherTongue, setPage }: { name: string; ageGroup: string; showMotherTongue: boolean; setPage: (p: Page) => void }) {
  const isChild = ageGroup === 'child';
  return (
    <main className="fade-up relative min-h-screen">
      {/* Fons amb transparència perquè el text i els botons per damunt es lligen bé. */}
      <div
        className="absolute inset-0 z-0 bg-cover bg-center bg-no-repeat opacity-30"
        style={{ backgroundImage: "url('/images/classroom.jpg')" }}
      />

      {/* Classroom header: top-right scenario selector + profile */}
      <header className="classroom-header z-10">
        <div className="relative isolate flex items-center justify-between gap-2 px-3 py-3 sm:px-5 sm:py-4">
          <span className="shrink-0"><Logo onDark /></span>
          <div className="flex items-center gap-2 sm:gap-5">
            <button
              id="dashboard-scenario-btn"
              aria-label="Tria activitat"
              title="Tria activitat"
              onClick={() => setPage('scenarioselect')}
              className="scenario-fab btn-press flex h-10 items-center gap-1.5 rounded-full bg-teal px-3 py-2 text-xl font-black text-white hover:bg-teal/90"
            >
              <LayoutGrid size={18} />
              <span className="hidden sm:inline">Activitats</span>
            </button>
            {isChild ? (
              <button
                aria-label="Lliçons de valencià"
                title="Lliçons de valencià"
                onClick={() => setPage('lessons')}
                className="btn-press shadow-md ring-2 ring-white flex h-10 items-center gap-1.5 rounded-full bg-yellow-400 px-3 py-2 text-xl font-black text-gray-900 hover:bg-yellow-400/90"
              >
                <BookOpen size={18} />
                <span className="hidden sm:inline">Lliçons</span>
              </button>
            ) : (
              <button
                aria-label="Practica els teus errors"
                title="Practica els teus errors"
                onClick={() => setPage('errors')}
                className="btn-press shadow-md ring-2 ring-white flex h-10 items-center gap-1.5 rounded-full bg-orange px-3 py-2 text-xl font-black text-white hover:bg-orange/90"
              >
                <Target size={18} />
                <span className="hidden sm:inline">Errors</span>
              </button>
            )}
            <button
              aria-label="Les meues rutes"
              title="Les meues rutes"
              onClick={() => setPage('paths')}
              className="btn-press shadow-md ring-2 ring-white flex h-10 items-center gap-1.5 rounded-full bg-white px-3 py-2 text-xl font-black text-teal hover:bg-white/90"
            >
              <Compass size={18} />
              <span className="hidden sm:inline">Rutes</span>
            </button>
            <button
              aria-label="Les meues converses amb el professor"
              title="Les meues converses amb el professor"
              onClick={() => setPage('tutorhistory')}
              className="btn-press shadow-md ring-2 ring-white flex h-10 items-center gap-1.5 rounded-full bg-white px-3 py-2 text-xl font-black text-teal hover:bg-white/90"
            >
              <MessageCircle size={18} />
              <span className="hidden sm:inline">Converses</span>
            </button>
            <ProfileButton name={name} onClick={() => setPage('profile')} />
          </div>
        </div>
      </header>

      {/* Mateix tauler per a tots: el professor i el xat. */}
      <ChildAssistant showHelp={showMotherTongue} />

      {!isChild && (
        <div className="relative z-20 flex justify-center px-5 pb-10">
          <button
            id="dashboard-start-btn"
            onClick={() => setPage('paths')}
            className="btn-press rounded-full bg-teal px-6 py-2 text-xl md:px-8 md:py-3 md:text-2xl font-black text-white shadow-lg ring-2 ring-white hover:bg-teal/90"
          >
            Començar classe
          </button>
        </div>
      )}
    </main>
  );
}
