import { createContext, useCallback, useContext, useEffect, useMemo, useRef, useState, type ReactNode } from 'react';
import { CircleHelp, Info, TriangleAlert, type LucideIcon } from 'lucide-react';

// Finestres de confirmació i d'avís de l'app: substituïxen el `confirm()` i l'`alert()` del navegador. S'usen amb el hook
// `useConfirm()` (un sol <ConfirmProvider> a l'arrel):
//   const { confirm, notify } = useConfirm();
//   if (!(await confirm({ title: 'Esborrar la ruta?', message: '…', confirmLabel: 'Esborra', tone: 'danger' }))) return;
//   await notify({ title: 'Cal el micròfon', message: '…' });

export type ConfirmOptions = {
  title: string;
  message?: string;
  confirmLabel?: string;
  cancelLabel?: string;
  // `danger`: acció destructiva o que fa perdre coses (botó roig); `default`: la resta.
  tone?: 'danger' | 'default';
  icon?: LucideIcon;
};

type DialogProps = ConfirmOptions & {
  // Avís (un sol botó): sense «Cancel·la»; Escape i el fons també l'accepten.
  notice?: boolean;
  onConfirm: () => void;
  onCancel: () => void;
};

// El focus comença en el botó segur («Cancel·la», o l'únic de l'avís) perquè un Intro sense voler no confirme una acció destructiva.
export function ConfirmDialog({ title, message, confirmLabel, cancelLabel = 'Cancel·la', tone = 'default', icon, notice = false, onConfirm, onCancel }: DialogProps) {
  const safeRef = useRef<HTMLButtonElement>(null);
  const dismiss = notice ? onConfirm : onCancel;
  const danger = tone === 'danger';
  const Icon = icon ?? (danger ? TriangleAlert : notice ? Info : CircleHelp);

  useEffect(() => {
    safeRef.current?.focus();
  }, []);

  useEffect(() => {
    const onKey = (event: KeyboardEvent) => {
      if (event.key === 'Escape') dismiss();
    };
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, [dismiss]);

  const confirmButton = (
    <button
      ref={notice ? safeRef : undefined}
      onClick={onConfirm}
      id="confirm-dialog-ok"
      className={`btn-press flex items-center justify-center gap-2 rounded-2xl py-3 text-lg font-extrabold text-white shadow hover:opacity-90 ${danger ? 'bg-orange' : 'bg-teal'}`}
    >
      {confirmLabel ?? (notice ? "D'acord" : 'Accepta')}
    </button>
  );

  return (
    <div
      className="modal-backdrop fixed inset-0 z-[60] grid place-items-center bg-navy/40 p-5"
      onMouseDown={event => { if (event.target === event.currentTarget) dismiss(); }}
    >
      <section
        role={notice ? 'dialog' : 'alertdialog'}
        aria-modal="true"
        aria-labelledby="confirm-title"
        aria-describedby={message ? 'confirm-message' : undefined}
        className="modal-content w-full max-w-sm rounded-3xl bg-cream p-6 text-center shadow-2xl"
      >
        <div className={`mx-auto grid h-16 w-16 place-items-center rounded-full ${danger ? 'bg-orange/15 text-orange' : 'bg-white text-teal shadow'}`}>
          <Icon size={30} aria-hidden />
        </div>
        <h2 id="confirm-title" className="mt-4 text-2xl font-black">{title}</h2>
        {message && <p id="confirm-message" className="mt-2 text-lg font-semibold opacity-70">{message}</p>}
        {notice ? (
          <div className="mt-6">{confirmButton}</div>
        ) : (
          <div className="mt-6 grid grid-cols-2 gap-3">
            <button
              ref={safeRef}
              onClick={onCancel}
              className="btn-press rounded-2xl border-2 border-gray-200 bg-white py-3 text-lg font-extrabold text-gray-600 hover:bg-gray-50"
            >
              {cancelLabel}
            </button>
            {confirmButton}
          </div>
        )}
      </section>
    </div>
  );
}

type Pending = { options: ConfirmOptions; notice: boolean; resolve: (accepted: boolean) => void };
type ConfirmApi = { confirm: (options: ConfirmOptions) => Promise<boolean>; notify: (options: ConfirmOptions) => Promise<void> };

const ConfirmContext = createContext<ConfirmApi | null>(null);

// Un sol diàleg alhora: si se'n demana un altre mentre n'hi ha un obert, l'anterior es dona per cancel·lat.
export function ConfirmProvider({ children }: { children: ReactNode }) {
  const [pending, setPending] = useState<Pending | null>(null);
  const current = useRef<Pending | null>(null);

  const open = useCallback((options: ConfirmOptions, notice: boolean) => new Promise<boolean>(resolve => {
    current.current?.resolve(false);
    const next = { options, notice, resolve };
    current.current = next;
    setPending(next);
  }), []);

  const close = useCallback((accepted: boolean) => {
    current.current?.resolve(accepted);
    current.current = null;
    setPending(null);
  }, []);

  // Si el proveïdor es desmunta amb un diàleg obert, la promesa no es queda penjada.
  useEffect(() => () => { current.current?.resolve(false); }, []);

  const api = useMemo<ConfirmApi>(() => ({
    confirm: options => open(options, false),
    notify: async options => { await open(options, true); },
  }), [open]);

  return (
    <ConfirmContext.Provider value={api}>
      {children}
      {pending && (
        <ConfirmDialog
          {...pending.options}
          notice={pending.notice}
          onConfirm={() => close(true)}
          onCancel={() => close(false)}
        />
      )}
    </ConfirmContext.Provider>
  );
}

export function useConfirm(): ConfirmApi {
  const api = useContext(ConfirmContext);
  if (!api) throw new Error('useConfirm s\'ha d\'usar dins de <ConfirmProvider>');
  return api;
}
