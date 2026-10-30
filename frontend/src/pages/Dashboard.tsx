import { useEffect, useRef, useState, type ReactNode } from 'react';
import { BookOpen, LayoutGrid, Menu, MessageCircle, Route, School, Target, X } from 'lucide-react';
import { ChildAssistant } from '../components/ChildAssistant';
import { Logo, ProfileButton } from '../components/ui';
import type { Page } from '../data/content';
import { asset } from '../lib/basePath';
import { useMediaQuery } from '../lib/useMediaQuery';

// Mòbil (vertical, i horitzontal amb poca alçada): les opcions de la capçalera van en un menú desplegable.
const COMPACT_HEADER = '(max-width: 639px), (orientation: landscape) and (max-height: 500px)';

type HeaderItem = { id?: string; page: Page; label: string; title: string; icon: ReactNode; className: string };

/** Les opcions de la capçalera segons el grup d'edat: mateix ordre i colors en els botons i en el menú. */
function headerItems(isChild: boolean): HeaderItem[] {
  const pill = 'btn-press flex h-10 items-center gap-1.5 rounded-full px-3 py-2 text-xl font-black';
  const shadow = 'shadow-md ring-2 ring-white';
  return [
    { id: 'dashboard-scenario-btn', page: 'scenarioselect', label: 'Activitats', title: 'Tria activitat', icon: <LayoutGrid size={18} />, className: `scenario-fab ${pill} bg-teal text-white hover:bg-teal/90` },
    ...(isChild
      ? [{ page: 'lessons' as Page, label: 'Lliçons', title: 'Lliçons de valencià', icon: <BookOpen size={18} />, className: `${pill} ${shadow} bg-yellow-400 text-gray-900 hover:bg-yellow-400/90` }]
      : [
        { page: 'learningpath' as Page, label: 'Rutes', title: "Les rutes d'aprenentatge", icon: <Route size={18} />, className: `${pill} ${shadow} bg-navy text-white hover:bg-navy/90` },
        { page: 'myclasses' as Page, label: 'Classe', title: 'La teua classe', icon: <School size={18} />, className: `${pill} ${shadow} bg-mustard text-navy hover:bg-mustard/90` },
        { page: 'errors' as Page, label: 'Errors', title: 'Practica els teus errors', icon: <Target size={18} />, className: `${pill} ${shadow} bg-orange text-white hover:bg-orange/90` },
      ]),
    { page: 'tutorhistory', label: 'Converses', title: 'Les meues converses amb el professor', icon: <MessageCircle size={18} />, className: `${pill} ${shadow} bg-white text-teal hover:bg-white/90` },
  ];
}

/** Menú desplegable de la capçalera en mòbil: un sol botó en lloc de totes les icones. Es tanca en triar, en tocar fora o amb Escape. */
function HeaderMenu({ items, setPage }: { items: HeaderItem[]; setPage: (p: Page) => void }) {
  const [open, setOpen] = useState(false);
  const root = useRef<HTMLDivElement>(null);
  useEffect(() => {
    if (!open) return;
    const onPointerDown = (e: PointerEvent) => { if (!root.current?.contains(e.target as Node)) setOpen(false); };
    const onKeyDown = (e: KeyboardEvent) => { if (e.key === 'Escape') setOpen(false); };
    document.addEventListener('pointerdown', onPointerDown);
    document.addEventListener('keydown', onKeyDown);
    return () => {
      document.removeEventListener('pointerdown', onPointerDown);
      document.removeEventListener('keydown', onKeyDown);
    };
  }, [open]);
  return (
    <div ref={root} className="relative">
      <button
        id="dashboard-menu-btn"
        type="button"
        aria-label={open ? 'Tanca el menú' : 'Obri el menú'}
        aria-haspopup="menu"
        aria-expanded={open}
        onClick={() => setOpen(o => !o)}
        className="btn-press grid h-10 w-10 place-items-center rounded-full bg-white text-teal shadow-md ring-2 ring-white"
      >
        {open ? <X size={20} /> : <Menu size={20} />}
      </button>
      {open && (
        <div role="menu" className="absolute right-0 top-full z-30 mt-3 w-56 overflow-hidden rounded-2xl bg-white p-1.5 shadow-xl ring-1 ring-black/10">
          {items.map(item => (
            <button
              key={item.page}
              role="menuitem"
              type="button"
              onClick={() => { setOpen(false); setPage(item.page); }}
              className="flex w-full items-center gap-3 rounded-xl px-3 py-2.5 text-left !text-base font-extrabold text-ink hover:bg-teal/10 [&_svg]:!h-5 [&_svg]:!w-5 [&_svg]:shrink-0 [&_svg]:text-teal"
            >
              {item.icon}
              {item.label}
            </button>
          ))}
        </div>
      )}
    </div>
  );
}

export function Dashboard({ name, ageGroup, showMotherTongue, setPage }: { name: string; ageGroup: string; showMotherTongue: boolean; setPage: (p: Page) => void }) {
  const isChild = ageGroup === 'child';
  const items = headerItems(isChild);
  const compact = useMediaQuery(COMPACT_HEADER);
  return (
    <main className="fade-up relative flex h-[calc(100dvh-var(--app-footer,0px))] flex-col overflow-y-auto">
      {/* Fons amb transparència perquè el text i els botons per damunt es lligen bé. */}
      <div
        className="absolute inset-0 z-0 bg-cover bg-center bg-no-repeat opacity-30"
        style={{ backgroundImage: `url('${asset('/images/classroom.jpg')}')` }}
      />

      {/* Classroom header: opcions (en mòbil, en un menú desplegable) + perfil */}
      {/* z-30: per damunt del professor (z-10/z-20) perquè el menú desplegable no quede tapat. */}
      <header className="classroom-header z-30">
        <div className="relative isolate flex items-center justify-between gap-2 px-3 py-3 sm:px-5 sm:py-4">
          <span className="shrink-0"><Logo onDark /></span>
          <div className="flex items-center gap-2 sm:gap-5">
            {compact ? (
              <HeaderMenu items={items} setPage={setPage} />
            ) : (
              items.map(item => (
                <button key={item.page} id={item.id} aria-label={item.title} title={item.title} onClick={() => setPage(item.page)} className={item.className}>
                  {item.icon}
                  <span className="hidden sm:inline">{item.label}</span>
                </button>
              ))
            )}
            <ProfileButton name={name} onClick={() => setPage('profile')} />
          </div>
        </div>
      </header>

      {/* Mateix tauler per a tots: el professor i el xat. */}
      <ChildAssistant showHelp={showMotherTongue} />
    </main>
  );
}
