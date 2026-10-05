import { BookOpen, LayoutGrid, MessageCircle, Target } from 'lucide-react';
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
        <div className="relative isolate flex items-center justify-between px-5 p-4">
          <Logo onDark />
          <div className="flex items-center gap-5">
            <button
              id="dashboard-scenario-btn"
              aria-label="Tria activitat"
              title="Tria activitat"
              onClick={() => setPage('scenarioselect')}
              className="scenario-fab btn-press flex h-10 items-center gap-1.5 rounded-full bg-teal px-3 py-2 text-xl font-black text-white hover:bg-teal/90"
            >
              <LayoutGrid size={18} />
              Activitats
            </button>
            {isChild ? (
              <button
                aria-label="Lliçons de valencià"
                title="Lliçons de valencià"
                onClick={() => setPage('lessons')}
                className="btn-press shadow-md ring-2 ring-white flex h-10 items-center gap-1.5 rounded-full bg-orange px-3 py-2 text-xl font-black text-white hover:bg-orange/90"
              >
                <BookOpen size={18} />
                Lliçons
              </button>
            ) : (
              <button
                aria-label="Practica els teus errors"
                title="Practica els teus errors"
                onClick={() => setPage('errors')}
                className="btn-press shadow-md ring-2 ring-white flex h-10 items-center gap-1.5 rounded-full bg-orange px-3 py-2 text-xl font-black text-white hover:bg-orange/90"
              >
                <Target size={18} />
                Errors
              </button>
            )}
            <button
              aria-label="Les meues converses amb el professor"
              title="Les meues converses amb el professor"
              onClick={() => setPage('tutorhistory')}
              className="btn-press shadow-md ring-2 ring-white flex h-10 items-center gap-1.5 rounded-full bg-white px-3 py-2 text-xl font-black text-teal hover:bg-white/90"
            >
              <MessageCircle size={18} />
              Converses
            </button>
            <ProfileButton name={name} onClick={() => setPage('profile')} />
          </div>
        </div>
      </header>

      {/* Mateix tauler per a tots: el professor al centre i el xat a sota. */}
      <ChildAssistant showHelp={showMotherTongue} />
    </main>
  );
}
