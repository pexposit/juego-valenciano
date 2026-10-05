import { useState } from 'react';
import { LayoutGrid } from 'lucide-react';
import { Logo, ProfileButton } from '../components/ui';
import type { Page } from '../data/content';
import { DashboardRobot, isRobotAvatarEnabled } from '../features/robot-avatar'; // [robot-avatar]

export function Dashboard({ name, setPage }: { name: string; setPage: (p: Page) => void }) {
  const [dashInput, setDashInput] = useState('');
  const [dashLoading, setDashLoading] = useState(false);
  const canSend = dashInput.trim() !== '' && !dashLoading;

  const handleDashChat = () => {
    if (!canSend) return;
    setDashLoading(true);
    setTimeout(() => setDashLoading(false), 600);
  };

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
          <Logo />
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
            <ProfileButton name={name} onClick={() => setPage('profile')} />
          </div>
        </div>
      </header>

      <div className="absolute left-2 top-2/3 -translate-y-1/2 z-20 flex items-center gap-3">
        {/* [robot-avatar] Robot 3D en lloc del professor SVG quan el mòdul està actiu. */}
        {isRobotAvatarEnabled('dashboard')
          ? <DashboardRobot className="relative left-16 drop-shadow-lg" size={400} />
          : <img src="/images/avatar_professor.svg" alt="El professor" className="float relative left-16 drop-shadow-lg" width={400} height={400} />}
        {/* Speech bubble to the right of the teacher */}
        <div className="relative -mt-48 w-[400px]" style={{ aspectRatio: '404.69 / 229.62' }}>
          <img
            src="/images/speachBubble.svg"
            alt=""
            aria-hidden="true"
            className="absolute inset-0 h-full w-full drop-shadow-lg"
          />
          {/* Inset perquè el contingut es centre dins la part rodona de la bombolla, sense envair la cua de baix. */}
          <div className="text-xl absolute inset-x-[10%] top-[6%] bottom-[16%] z-10 flex flex-col items-center justify-center gap-3 px-4 text-center text-base font-bold text-slate-800">
            <p>Començem la classe</p>
            <button
              id="dashboard-start-btn"
              onClick={() => setPage('learningpath')}
              className="text-xl btn-press w-full max-w-[220px] rounded-xl bg-teal px-4 py-2 text-sm font-black text-white hover:bg-teal/90"
            >
              Començem
            </button>
          </div>
        </div>
      </div>

      <div className="relative z-10 mx-auto mt-8 max-w-2xl rounded-2xl border border-orange bg-white/80 p-8">
        <h1 className="text-3xl font-black b-10 mb-4">Bon dia, {name}! 👋</h1>
        <p className="text-xl">Comença una <b>clase</b> o practica per lliure amb les <b>activitats disponibles</b></p>
      </div>
    </main>
  );
}
