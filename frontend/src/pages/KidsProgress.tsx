import { useEffect, useMemo, useState, type FormEvent } from 'react';
import { LogOut, Users } from 'lucide-react';
import { OrangeHeader } from '../components/ui';
import { supabase } from '../lib/supabase';
import { ProgressReport } from '../features/kids/ProgressReport';
import { joinClass, leaveClass, loadChildData, loadJoinedClasses, type ChildData } from '../features/kids/tracking';

const FIELD_CLASS = 'w-full rounded-2xl border-2 border-gray-100 p-3 text-2xl font-normal outline-none focus:border-[#0F47AF] transition-colors';

/**
 * Seguiment del Nivell 0 per a la família (s'hi entra des del perfil del compte infantil).
 * Primer, una pregunta que un xiquet de 3 a 6 anys no sap contestar; després, l'informe
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
          <AdultGate onPass={() => setAdult(true)} />
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

/** Porta per a adults: una multiplicació que un xiquet del Nivell 0 encara no sap fer. */
function AdultGate({ onPass }: { onPass: () => void }) {
  const [a, b] = useMemo(() => [3 + Math.floor(Math.random() * 7), 3 + Math.floor(Math.random() * 7)], []);
  const [answer, setAnswer] = useState('');
  const [wrong, setWrong] = useState(false);

  const check = (e: FormEvent) => {
    e.preventDefault();
    if (Number(answer) === a * b) return onPass();
    setWrong(true);
    setAnswer('');
  };

  return (
    <form onSubmit={check} className="mx-auto max-w-md rounded-3xl bg-white p-6 shadow-sm">
      <h1 className="text-3xl font-black">Només per a persones adultes</h1>
      <p className="mt-2 text-lg opacity-70">Per a vore el seguiment, contesteu esta pregunta:</p>
      <label className="mt-4 block text-2xl font-extrabold">
        Quant fan {a} × {b}?
        <input
          type="number"
          inputMode="numeric"
          value={answer}
          onChange={e => { setAnswer(e.target.value); setWrong(false); }}
          className={`mt-2 ${FIELD_CLASS}`}
          autoFocus
        />
      </label>
      {wrong && <p className="mt-2 text-base text-coral">No és correcte. Torneu-ho a provar.</p>}
      <button className="btn-press mt-4 w-full rounded-2xl bg-[#0F47AF] py-3 text-xl font-extrabold text-white">Entra</button>
    </form>
  );
}
