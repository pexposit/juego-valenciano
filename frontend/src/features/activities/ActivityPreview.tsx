import { createPortal } from 'react-dom';
import { Target, X } from 'lucide-react';
import type { TeacherActivityInput } from '@parlaval/shared';
import { Practice } from '../../pages/Practice';
import { toPracticePreview } from './drafts';
import { asset } from '../../lib/basePath';

/** Vista prèvia d'una activitat a pantalla completa: així ho veurà l'alumnat. No es guarda res. */
export function ActivityPreview({ activity, onClose }: { activity: TeacherActivityInput; onClose: () => void }) {
  const practice = toPracticePreview(activity);
  // Es pinta en el <body>: un ancestre amb `transform` (.fade-up) faria que el `fixed` no cobrira la finestra.
  return createPortal(
    <div className="fixed inset-0 z-50 overflow-y-auto bg-cream">
      <div className="sticky top-0 z-[60] flex items-center justify-between gap-3 bg-[#0F47AF] px-5 py-2 text-white">
        <span className="font-extrabold">Vista prèvia: així ho veurà l'alumnat. No es guarda res.</span>
        <button onClick={onClose} className="btn-press flex items-center gap-1 rounded-full bg-white/20 px-3 py-1 font-bold">
          <X size={18} /> Tanca
        </button>
      </div>
      {practice ? (
        <Practice practice={practice} userLevel={activity.level} onBack={onClose} preview />
      ) : activity.content.kind === 'scenario' && <ScenarioPreview activity={activity} />}
    </div>,
    document.body,
  );
}

/** Com veurà l'alumne l'escenari en obrir-lo: el lloc, el personatge, la primera frase i els objectius. */
function ScenarioPreview({ activity }: { activity: TeacherActivityInput }) {
  const c = activity.content;
  if (c.kind !== 'scenario') return null;
  return (
    <div className="relative min-h-[calc(100dvh-2.5rem)] bg-cover bg-center" style={{ backgroundImage: `url('${asset(c.background)}')` }}>
      <div className="absolute left-[8%] top-[12%] max-w-[min(72%,440px)] rounded-3xl bg-white p-5 text-lg font-bold shadow-xl">{c.greeting}</div>
      <aside className="absolute right-5 top-24 w-[min(calc(100%-2.5rem),320px)] rounded-3xl bg-white/95 p-5 shadow-xl">
        <h2 className="mb-2 flex items-center gap-2 text-sm font-black uppercase tracking-wider text-[#0F47AF]"><Target size={16} /> Objectius</h2>
        {activity.description && <p className="mb-3 text-sm font-bold opacity-70">{activity.description}</p>}
        <ol className="flex list-decimal flex-col gap-1.5 pl-5 text-sm font-bold">
          {c.objectives.map(o => <li key={o}>{o}</li>)}
        </ol>
      </aside>
      <div className="absolute bottom-24 left-1/2 -translate-x-1/2 rounded-full bg-white/90 px-4 py-1.5 text-base font-black uppercase tracking-wide shadow">{c.character}</div>
      <p className="absolute inset-x-4 bottom-6 mx-auto max-w-xl rounded-2xl bg-white/90 p-3 text-center text-sm font-bold">
        En la vista prèvia no es pot xarrar: la conversa amb la IA la fa l'alumnat de les classes on l'assignes, des de «Activitats».
      </p>
    </div>
  );
}
