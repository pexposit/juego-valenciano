import { useEffect, useState, type FormEvent } from 'react';
import { School, X } from 'lucide-react';
import { invalidateResources } from '../../lib/api';
import { joinClass, leaveClass, loadJoinedClasses } from '../kids/tracking';

/**
 * Les classes de l'alumne adult (qualsevol nivell): s'hi unix amb el codi que li dona la docent,
 * sense PIN (el PIN de la família és només per als comptes infantils, des del seguiment). La BDD
 * comprova que el nivell de l'alumne és d'algun dels de la classe.
 */
export function StudentClasses({ uid }: { uid: string }) {
  const [classes, setClasses] = useState<{ id: string; name: string }[]>();
  const [code, setCode] = useState('');
  const [message, setMessage] = useState<{ ok: boolean; text: string }>();

  useEffect(() => {
    loadJoinedClasses(uid).then(setClasses).catch(() => setClasses([]));
  }, [uid]);

  const join = async (e: FormEvent) => {
    e.preventDefault();
    try {
      const joined = await joinClass(code);
      setClasses(list => (list?.some(c => c.id === joined.id) ? list : [...(list ?? []), joined]));
      setCode('');
      // Les activitats i les rutes de la classe ja hi han de sortir.
      invalidateResources();
      setMessage({ ok: true, text: `T'has unit a «${joined.name}». Les seues activitats i rutes són en la secció «Classe».` });
    } catch (error) {
      setMessage({ ok: false, text: (error as { message?: string } | null)?.message ?? "No t'hem pogut unir a la classe" });
    }
  };

  const leave = async (id: string, name: string) => {
    if (!confirm(`Segur que vols eixir de la classe «${name}»?`)) return;
    try {
      await leaveClass(id, uid);
      setClasses(list => list?.filter(c => c.id !== id));
      invalidateResources();
    } catch (error) {
      setMessage({ ok: false, text: (error as { message?: string } | null)?.message ?? "No has pogut eixir de la classe" });
    }
  };

  return (
    <section className="mt-8 rounded-3xl bg-white p-5 shadow-sm">
      <h2 className="flex items-center gap-2 text-2xl font-black"><School size={22} /> Les meues classes</h2>
      {classes?.length ? (
        <ul className="mt-3 flex flex-col gap-2">
          {classes.map(c => (
            <li key={c.id} className="flex items-center gap-3 rounded-2xl bg-gray-50 px-4 py-2">
              <span className="flex-1 text-lg font-bold">{c.name}</span>
              <button onClick={() => void leave(c.id, c.name)} className="btn-press flex items-center gap-1 text-sm font-bold text-gray-500 hover:text-coral">
                <X size={16} /> Eixir
              </button>
            </li>
          ))}
        </ul>
      ) : (
        classes && <p className="mt-2 text-base opacity-60">Encara no estàs en cap classe.</p>
      )}
      <form onSubmit={join} className="mt-4">
        <label htmlFor="profile-class-code" className="block text-base font-extrabold">Tens un codi de classe?</label>
        <div className="mt-2 flex flex-wrap gap-2">
          <input
            id="profile-class-code"
            value={code}
            onChange={e => { setCode(e.target.value.toUpperCase().slice(0, 6)); setMessage(undefined); }}
            placeholder="ABC234"
            autoComplete="off"
            className="w-40 rounded-2xl border-2 border-gray-100 p-3 text-center font-mono text-xl font-black tracking-[0.3em] outline-none focus:border-[#0F47AF]"
          />
          <button type="submit" disabled={code.trim().length < 6} className="btn-press rounded-2xl bg-[#0F47AF] px-5 py-3 font-black text-white disabled:opacity-50">
            Uneix-me
          </button>
        </div>
        {message && <p className={`mt-2 text-sm font-bold ${message.ok ? 'text-teal' : 'text-coral'}`}>{message.text}</p>}
      </form>
    </section>
  );
}
