import type { ReactNode } from 'react';

/* ── Logo ────────────────────────────────────────────────────────── */
export function Logo({ size = 'md' }: { size?: 'sm' | 'md' | 'lg' }) {
  const cls = size === 'lg' ? 'text-4xl' : size === 'sm' ? 'text-xl' : 'text-2xl';
  return (
    <b className={`${cls} font-black tracking-tight`}>
      <span style={{ color: '#0D9488' }}>Parla</span>
      <span style={{ color: '#F97316' }}>Val</span>
    </b>
  );
}

/* ── Stat pill ───────────────────────────────────────────────────── */
export function Stat({ icon, label, value }: { icon: string; label: string; value: string }) {
  return (
    <div className="stat-pill flex-1 flex-col text-center min-w-0">
      <span className="text-xl block">{icon}</span>
      <b className="text-sm block">{value}</b>
      <small className="text-[11px] font-semibold opacity-55">{label}</small>
    </div>
  );
}

/* ── Profile access button (avatar with the user's initial) ────────── */
export function ProfileButton({ name, onClick }: { name: string; onClick: () => void }) {
  return (
    <button
      id="profile-btn"
      aria-label="El teu perfil"
      title="El teu perfil"
      onClick={onClick}
      className="avatar-ring grid h-11 w-11 place-items-center rounded-full font-black text-lg text-white"
      style={{ background: '#F9731C' }}
    >
      {name[0]}
    </button>
  );
}

/* ── Page transition wrapper ─────────────────────────────────────── */
export function PageTransition({ children }: { children: ReactNode }) {
  return <div className="page-enter">{children}</div>;
}

/* ── Decorative oranges header ──────────────────────────────────── */
export function OrangeHeader({ children, showOranges = true }: { children: ReactNode; showOranges?: boolean }) {
  return (
    <div
      className={`${
        showOranges ? 'azulejo-border bg-gradient-to-br from-[#FFF9ED] to-[#FFE8BA]' : 'border-b border-[#E7E5E4] bg-gradient-to-br from-[#FAFAF9] to-[#FFFFFF]'
      } relative overflow-hidden rounded-b-[40px] pb-4 pt-5 shadow-sm`}
    >
      {showOranges && (
        <>
          {/* Decorative oranges */}
          <span className="orange-deco absolute left-3 top-1 text-2xl select-none">🍊</span>
          <span className="orange-deco absolute left-14 top-0 text-xl select-none opacity-70">🍊</span>
          <span className="orange-deco absolute right-14 top-0 text-xl select-none opacity-70">🍊</span>
          <span className="orange-deco absolute right-3 top-1 text-2xl select-none">🍊</span>
          {/* Small sun rays */}
          <div className="absolute inset-0 opacity-20 pointer-events-none"
               style={{ background: 'radial-gradient(ellipse at 50% -20%, #F9C74F 0%, transparent 70%)' }} />
        </>
      )}
      {children}
    </div>
  );
}
