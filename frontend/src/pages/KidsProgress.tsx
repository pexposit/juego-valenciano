import { useEffect, useState, type FormEvent } from 'react';
import { LogOut, Users } from 'lucide-react';
import { OrangeHeader } from '../components/ui';
import { supabase } from '../lib/supabase';
import { ProgressReport } from '../features/kids/ProgressReport';
import { checkPin, hasPin, isPin, resetPin, setPin } from '../features/kids/parentPin';
import { joinClass, leaveClass, loadChildData, loadJoinedClasses, type ChildData } from '../features/kids/tracking';

const FIELD_CLASS = 'w-full rounded-2xl border-2 border-gray-100 p-3 text-2xl font-normal outline-none focus:border-[#0F47AF] transition-colors';

/**
 * Seguiment del Nivell 0 per a la família (s'hi entra des del perfil del compte infantil).
 * Primer, el PIN de la família (parentPin.ts); després, l'informe
 * del xiquet i les classes del professorat on està (amb el codi que dona la docent).
 */
export function KidsProgress({ uid, name, onBack, onLesson }: { uid: string | undefined; name: string; onBack: () => void; onLesson: (lesson: string) => void }) {
  const [adult, setAdult] = useState(false);
  const [data, setData] = useState<ChildData | null>();
  const [classes, setClasses] = useState<{ id: string; name: string }[]>([]);
  const [code, setCode] = useState('');
  const [message, setMessage] = useState<{ ok: boolean; text: string }>();
  const online = !!supabase && !!uid;

  useEffect(() => {
    if (!adult) return;
    let cancelled = false;
    loadChildData(uid)
      .then(d => { if (!cancelled) setData(d); })
      .catch(error => {
        console.error('Error carregant el seguiment:', error);
        if (!cancelled) setData(null);
      });
    if (online) void loadJoinedClasses(uid!).then(c => { if (!cancelled) setClasses(c); }).catch(console.error);
    return () => { cancelled = true; };
  }, [adult, uid, online]);

  const join = async (e: FormEvent) => {
    e.preventDefault();
    try {
      const joined = await joinClass(code);
      setClasses(c => (c.some(x => x.id === joined.id) ? c : [...c, joined]));
      setCode('');
      setMessage({ ok: true, text: `Ja és en la classe «${joined.name}». La docent ja pot vore el seu seguiment.` });
    } catch {
      setMessage({ ok: false, text: 'No hi ha cap classe amb este codi. Reviseu-lo amb la docent.' });
    }
  };

  const leave = async (id: string, className: string) => {
    if (!confirm(`Segur que voleu eixir de la classe «${className}»? La docent deixarà de vore el seguiment.`)) return;
    try {
      await leaveClass(id, uid!);
      setClasses(c => c.filter(x => x.id !== id));
    } catch (error) {
      console.error(error);
    }
  };

  return (
    <main className="fade-up" style={{ background: '#FAFAF9', minHeight: '100vh' }}>
      <OrangeHeader showOranges={false}>
        <div className="px-5 pb-2">
          <button onClick={onBack} className="text-xl btn-press rounded-full bg-white/90 px-4 py-2 text-sm font-extrabold text-teal shadow hover:bg-white transition-colors">
            ← Tornar
          </button>
        </div>
      </OrangeHeader>

      <div className="mx-auto max-w-3xl px-5 pt-6 pb-16">
        {!adult ? (
          <PinGate uid={uid} onPass={() => setAdult(true)} />
        ) : (
          <>
            <h1 className="text-4xl font-black sm:text-5xl">Seguiment{name ? ` de ${name}` : ''}</h1>
            <p className="mt-2 text-lg opacity-70">Què domina, què li costa i com avança en les illes del Nivell 0.</p>
            {!online && <p className="mt-3 rounded-2xl bg-amber-50 p-3 text-base text-amber-900">Mode demostració: el seguiment només es guarda en este navegador.</p>}

            <div className="mt-6">
              {data === undefined && <p className="text-lg opacity-60">Carregant...</p>}
              {data === null && <p className="text-lg text-coral">No s'ha pogut carregar el seguiment. Torneu-ho a provar més tard.</p>}
              {data && <ProgressReport data={data} name={name} onLesson={onLesson} />}
            </div>

            {online && (
              <section className="mt-5 rounded-3xl bg-white p-5 shadow-sm">
                <h3 className="flex items-center gap-2 text-2xl font-black"><Users size={24} /> La classe</h3>
                <p className="mt-1 text-base opacity-60">Si la docent us ha donat un codi, escriviu-lo ací perquè puga seguir el progrés a classe.</p>
                {classes.length > 0 && (
                  <ul className="mt-3 space-y-2">
                    {classes.map(c => (
                      <li key={c.id} className="flex items-center gap-3 rounded-2xl bg-gray-50 p-3 text-lg">
                        <span className="flex-1 font-extrabold">{c.name}</span>
                        <button onClick={() => void leave(c.id, c.name)} className="btn-press flex items-center gap-1 text-base font-bold text-gray-500 hover:text-coral">
                          <LogOut size={16} /> Eixir
                        </button>
                      </li>
                    ))}
                  </ul>
                )}
                <form onSubmit={join} className="mt-3 flex gap-2">
                  <input
                    value={code}
                    onChange={e => setCode(e.target.value.toUpperCase().replace(/[^A-Z0-9]/g, '').slice(0, 6))}
                    placeholder="Codi de la classe"
                    aria-label="Codi de la classe"
                    className={`${FIELD_CLASS} font-mono tracking-widest`}
                  />
                  <button disabled={code.length !== 6} className="btn-press shrink-0 rounded-2xl bg-[#0F47AF] px-5 text-xl font-extrabold text-white disabled:opacity-40">
                    Uneix
                  </button>
                </form>
                {message && <p className={`mt-2 text-base ${message.ok ? 'text-teal' : 'text-coral'}`}>{message.text}</p>}
              </section>
            )}
          </>
        )}
      </div>
    </main>
  );
}

/** Camp del PIN: quatre xifres grans i amagades. */
function PinField({ value, onChange, label, autoFocus }: { value: string; onChange: (pin: string) => void; label: string; autoFocus?: boolean }) {
  return (
    <label className="mt-4 block text-xl font-extrabold">
      {label}
      <input
        type="password"
        inputMode="numeric"
        autoComplete="off"
        maxLength={4}
        value={value}
        onChange={e => onChange(e.target.value.replace(/\D/g, '').slice(0, 4))}
        className={`mt-2 ${FIELD_CLASS} text-center font-mono text-4xl tracking-[0.6em]`}
        placeholder="••••"
        autoFocus={autoFocus}
      />
    </label>
  );
}

/**
 * Porta per a adults: el PIN de la família. Si el compte encara no en té (comptes antics
 * o creats sense), es crea ací; si s'ha oblidat, se'n posa un de nou amb la contrasenya.
 */
function PinGate({ uid, onPass }: { uid: string | undefined; onPass: () => void }) {
  const [mode, setMode] = useState<'loading' | 'create' | 'enter' | 'forgot'>('loading');
  const [pin, setPinValue] = useState('');
  const [repeat, setRepeat] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState<string>();
  const [busy, setBusy] = useState(false);

  useEffect(() => {
    hasPin(uid)
      .then(has => setMode(has ? 'enter' : 'create'))
      .catch(e => {
        console.error(e);
        setError("No s'ha pogut comprovar el PIN. Torneu-ho a provar més tard.");
      });
  }, [uid]);

  const go = (next: typeof mode) => {
    setMode(next);
    setPinValue('');
    setRepeat('');
    setPassword('');
    setError(undefined);
  };

  const locked = (seconds: number) => `Massa intents. Torneu-ho a provar d'ací a ${Math.ceil(seconds / 60)} ${seconds > 60 ? 'minuts' : 'minut'}.`;

  const submit = async (e: FormEvent) => {
    e.preventDefault();
    if (!isPin(pin)) return setError('El PIN ha de tindre 4 xifres.');
    if ((mode === 'create' || mode === 'forgot') && pin !== repeat) return setError('Els dos PIN no coincidixen.');
    setBusy(true);
    try {
      if (mode === 'create') {
        await setPin(uid, pin);
        return onPass();
      }
      if (mode === 'forgot') {
        const result = await resetPin(uid, password, pin);
        if (result.ok) return onPass();
        return setError(result.lockedSeconds ? locked(result.lockedSeconds) : 'La contrasenya no és correcta.');
      }
      const result = await checkPin(uid, pin);
      if (result.ok) return onPass();
      setPinValue('');
      setError(result.lockedSeconds
        ? locked(result.lockedSeconds)
        : `PIN incorrecte. ${result.attemptsLeft === 1 ? 'Queda 1 intent' : `Queden ${result.attemptsLeft} intents`}.`);
    } catch (e) {
      console.error(e);
      setError("No s'ha pogut comprovar. Torneu-ho a provar.");
    } finally {
      setBusy(false);
    }
  };

  if (mode === 'loading') return error ? <p className="text-lg text-coral">{error}</p> : <p className="text-lg opacity-60">Carregant...</p>;

  return (
    <form onSubmit={submit} className="mx-auto max-w-md rounded-3xl bg-white p-6 shadow-sm">
      <span className="text-4xl" aria-hidden="true">🔒</span>
      <h1 className="mt-2 text-3xl font-black">
        {mode === 'create' ? 'Creeu el PIN de la família' : mode === 'forgot' ? 'Un PIN nou' : 'Només per a persones adultes'}
      </h1>
      <p className="mt-2 text-lg opacity-70">
        {mode === 'create'
          ? 'Quatre xifres per a entrar al seguiment. Trieu-ne unes que el xiquet o la xiqueta no sàpia.'
          : mode === 'forgot'
            ? 'Escriviu la contrasenya del compte i trieu un PIN nou.'
            : 'Escriviu el PIN de la família per a vore el seguiment.'}
      </p>

      {mode === 'forgot' && (
        <label className="mt-4 block text-xl font-extrabold">
          Contrasenya del compte
          <input type="password" autoComplete="current-password" value={password} onChange={e => setPassword(e.target.value)} className={`mt-2 ${FIELD_CLASS}`} autoFocus />
        </label>
      )}
      <PinField label={mode === 'enter' ? 'PIN' : 'PIN nou'} value={pin} onChange={p => { setPinValue(p); setError(undefined); }} autoFocus={mode !== 'forgot'} />
      {mode !== 'enter' && <PinField label="Repetiu el PIN" value={repeat} onChange={p => { setRepeat(p); setError(undefined); }} />}

      {error && <p className="mt-3 text-base text-coral">{error}</p>}
      <button disabled={busy} className="btn-press mt-5 w-full rounded-2xl bg-[#0F47AF] py-3 text-xl font-extrabold text-white disabled:opacity-60">
        {busy ? 'Espera...' : mode === 'enter' ? 'Entra' : 'Guarda el PIN i entra'}
      </button>
      {mode === 'enter' && (
        <button type="button" onClick={() => go('forgot')} className="mt-3 w-full text-base font-bold text-gray-500 hover:text-[#0F47AF]">
          Heu oblidat el PIN?
        </button>
      )}
      {mode === 'forgot' && (
        <button type="button" onClick={() => go('enter')} className="mt-3 w-full text-base font-bold text-gray-500 hover:text-[#0F47AF]">
          ← Tinc el PIN
        </button>
      )}
    </form>
  );
}
