import { useState } from 'react';
import { classLevelLabel } from '@parlaval/shared';
import { supabase } from '../lib/supabase';
import { MOTHER_TONGUE_OPTIONS } from '../data/content';
import { ensureSession } from '../lib/api';

/**
 * Tercera forma d'entrar: amb el codi d'una classe, sense compte (ni correu ni contrasenya). L'alumne escriu el
 * codi, tria un apodo (i el nivell, si la classe en té dos) i entra amb una sessió anònima de Supabase: el
 * navegador la guarda i el servidor només té l'apodo i el seguiment que veu la docent. El que escriu o diu
 * l'alumne es queda en el seu navegador. Si tanca la sessió o esborra les dades del navegador, la perd.
 */

const NICK_PATTERN = /^[A-Za-zÀ-ÖØ-öø-ÿ0-9._-]{2,20}$/;
const INPUT_CLASS = 'w-full rounded-2xl border-2 border-gray-100 p-3 outline-none focus:border-[#0F47AF] transition-colors';
const NETWORK_ERROR = 'No hem pogut connectar. Revisa la connexió i torna-ho a provar.';

type ClassPreview = { name: string; levels: string[] };
const errorText = (error: unknown) => (error as { message?: string } | null)?.message ?? NETWORK_ERROR;

export function ClassCodeEntry({ onBack, onDone }: { onBack: () => void; onDone: (level: string) => void }) {
  const [code, setCode] = useState('');
  const [klass, setKlass] = useState<ClassPreview>();
  const [nick, setNick] = useState('');
  const [level, setLevel] = useState('');
  const [motherTongue, setMotherTongue] = useState('');
  const [busy, setBusy] = useState(false);
  const [notice, setNotice] = useState('');

  // Pas 1: el codi diu a quina classe va (nom i nivells), sense crear res.
  const checkCode = async () => {
    if (!supabase) return onDone('A2'); // mode demostració
    if (code.length < 6) return setNotice('El codi de la classe té 6 caràcters.');
    setBusy(true);
    try {
      const { data, error } = await supabase.rpc('class_code_preview', { p_code: code });
      if (error) return setNotice(errorText(error));
      const row = (data as { name: string; levels: string[] }[])[0];
      if (!row) return setNotice('No hi ha cap classe amb este codi');
      setKlass({ name: row.name, levels: row.levels });
      setLevel(row.levels[0]);
      setNotice('');
    } catch {
      setNotice(NETWORK_ERROR);
    } finally {
      setBusy(false);
    }
  };

  // Pas 2: l'apodo (i el nivell). Es comprova que no el tinga ningú més de la classe abans de crear la sessió.
  const join = async () => {
    if (!supabase || !klass) return;
    const trimmed = nick.trim();
    if (!NICK_PATTERN.test(trimmed)) {
      return setNotice("L'apodo ha de tindre entre 2 i 20 caràcters: lletres, xifres, punt, guionet o guionet baix, sense espais.");
    }
    const kid = level === 'nivell0'; // les classes del Nivell 0 són infantils
    setBusy(true);
    try {
      const { data: preview, error: previewError } = await supabase.rpc('class_code_preview', { p_code: code, p_nick: trimmed });
      if (previewError) return setNotice(errorText(previewError));
      if ((preview as { nick_taken: boolean }[])[0]?.nick_taken) return setNotice("Este apodo ja el té algú de la classe: tria'n un altre.");

      // Sessió anònima: el nivell, el grup d'edat i l'apodo van com a metadades i el trigger de registre en fa el perfil.
      const { error: signInError } = await supabase.auth.signInAnonymously({
        options: {
          data: {
            level,
            age_group: kid ? 'child' : 'adult',
            display_name: trimmed,
            ...(level === 'nivell0' && motherTongue ? { mother_tongue: motherTongue } : {}),
          },
        },
      });
      if (signInError) return setNotice(errorText(signInError));

      const { error: joinError } = await supabase.rpc('kids_join_class', { p_code: code });
      if (joinError) {
        // No s'ha pogut entrar a la classe: es tanca la sessió acabada de crear perquè no quede un compte buit.
        await supabase.auth.signOut();
        return setNotice(errorText(joinError));
      }
      void ensureSession(level).catch(error => console.error('Error creant la sessió:', error));
      onDone(level);
    } catch {
      setNotice(NETWORK_ERROR);
    } finally {
      setBusy(false);
    }
  };

  return (
    <main className="fade-up grid min-h-screen place-items-center p-6" style={{ background: '#FAFAF9' }}>
      <section className="w-full max-w-md rounded-[36px] bg-white p-8 shadow-xl">
        <div className="mb-6 flex items-center gap-3">
          <button onClick={klass ? () => { setKlass(undefined); setNotice(''); } : onBack} className="text-sm font-bold opacity-50 hover:opacity-100 transition-opacity">
            ← Tornar
          </button>
        </div>
        <div className="mb-6 text-center">
          <span className="text-4xl">🏫</span>
          <h1 className="mt-2 text-3xl font-black">Entra a la teua classe</h1>
          <p className="mt-1 opacity-60">
            Escriu el codi que t'ha donat el teu professor o professora. No cal compte, ni correu, ni contrasenya.
          </p>
        </div>

        {!klass ? (
          <>
            <label className="block text-sm font-extrabold mb-1" htmlFor="class-code-input">Codi de la classe</label>
            <input
              id="class-code-input"
              value={code}
              onChange={e => { setCode(e.target.value.toUpperCase().replace(/[^A-Z0-9]/g, '').slice(0, 6)); setNotice(''); }}
              onKeyDown={e => { if (e.key === 'Enter') void checkCode(); }}
              placeholder="ABC234"
              autoComplete="off"
              autoCapitalize="characters"
              spellCheck={false}
              className={`${INPUT_CLASS} text-center font-mono text-3xl font-black tracking-[0.3em]`}
            />
            <button
              onClick={() => void checkCode()}
              disabled={busy || code.length < 6}
              id="class-code-continue"
              className="btn-press mt-6 w-full rounded-2xl py-3 font-extrabold text-white transition hover:opacity-90 active:scale-[0.98] disabled:opacity-60"
              style={{ background: 'linear-gradient(135deg, #0F47AF, #0B3785)' }}
            >
              {busy ? 'Espera...' : 'Continua'}
            </button>
          </>
        ) : (
          <>
            <p className="mb-4 rounded-2xl bg-[#E8EFFC] p-3 text-center font-bold text-[#0B3785]">
              Classe: {klass.name}
              <span className="block text-sm font-semibold opacity-70">{klass.levels.map(classLevelLabel).join(' i ')}</span>
            </p>

            <label className="block text-sm font-extrabold mb-1" htmlFor="class-nick">Tria un apodo</label>
            <input
              id="class-nick"
              value={nick}
              onChange={e => { setNick(e.target.value.replace(/\s/g, '')); setNotice(''); }}
              onKeyDown={e => { if (e.key === 'Enter') void join(); }}
              placeholder="El nom que vulgues"
              autoComplete="off"
              autoCapitalize="none"
              spellCheck={false}
              maxLength={20}
              className={INPUT_CLASS}
            />
            <p className="mt-1 text-xs opacity-60">
              No cal que siga el teu nom real. El teu professor veurà el teu progrés amb este apodo.
            </p>

            {klass.levels.length > 1 && (
              <>
                <label className="mt-4 block text-sm font-extrabold mb-1" htmlFor="class-level">Amb quin nivell vols treballar?</label>
                <select id="class-level" value={level} onChange={e => setLevel(e.target.value)} className={`${INPUT_CLASS} bg-white`}>
                  {klass.levels.map(l => <option key={l} value={l}>{classLevelLabel(l)}</option>)}
                </select>
              </>
            )}

            {level === 'nivell0' && (
              <>
                <label className="mt-4 block text-sm font-extrabold mb-1" htmlFor="class-mother-tongue">La teua llengua (opcional)</label>
                <select id="class-mother-tongue" value={motherTongue} onChange={e => setMotherTongue(e.target.value)} className={`${INPUT_CLASS} bg-white`}>
                  <option value="">Sense traducció</option>
                  {MOTHER_TONGUE_OPTIONS.map(o => <option key={o.value} value={o.value}>{o.label}</option>)}
                </select>
              </>
            )}

            <button
              onClick={() => void join()}
              disabled={busy || nick.trim().length < 2}
              id="class-join"
              className="btn-press mt-6 w-full rounded-2xl py-3 font-extrabold text-white transition hover:opacity-90 active:scale-[0.98] disabled:opacity-60"
              style={{ background: 'linear-gradient(135deg, #0F47AF, #0B3785)' }}
            >
              {busy ? 'Espera...' : 'Entra'}
            </button>
            <p className="mt-3 text-xs opacity-60">
              El teu progrés es guarda en este navegador. Si tanques la sessió o esborres les dades del navegador, hauràs d'entrar de nou amb el codi (i un altre apodo).
            </p>
          </>
        )}

        {notice && (
          <div
            role="status"
            className="mt-4 rounded-2xl p-4 text-sm font-bold"
            style={{ background: '#E8EFFC', color: '#0B3785', border: '1px solid #B9D0F5' }}
          >
            {notice}
          </div>
        )}
      </section>
    </main>
  );
}
