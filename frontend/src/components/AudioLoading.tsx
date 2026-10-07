import { useEffect, useState } from 'react';
import { Loader2 } from 'lucide-react';

/** `flag`, però només després de `ms`: un àudio que carrega al moment no ha de fer pampallugues. */
export function useDelayedFlag(flag: boolean, ms = 350) {
  const [shown, setShown] = useState(false);
  useEffect(() => {
    if (!flag) return setShown(false);
    const timer = window.setTimeout(() => setShown(true), ms);
    return () => window.clearTimeout(timer);
  }, [flag, ms]);
  return shown;
}

/** Avís de que l'àudio encara està carregant (per això encara no sona). */
export function AudioLoading({ className = '' }: { className?: string }) {
  return (
    <span role="status" aria-live="polite" className={`inline-flex items-center gap-1.5 text-sm font-extrabold text-slate-500 ${className}`}>
      <Loader2 size={14} className="animate-spin" aria-hidden="true" /> Carregant l'àudio…
    </span>
  );
}
