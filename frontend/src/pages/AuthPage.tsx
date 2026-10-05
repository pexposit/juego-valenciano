import { useState } from 'react';
import { supabase } from '../lib/supabase';
import { AGE_GROUP_OPTIONS, LEVEL_OPTIONS, MOTHER_TONGUE_OPTIONS, type Page } from '../data/content';
import { startSession } from '../lib/api';

const NETWORK_ERROR = 'No hem pogut connectar. Revisa la connexió i torna-ho a provar.';
const INPUT_CLASS = 'w-full rounded-2xl border-2 border-gray-100 p-3 outline-none focus:border-[#0F47AF] transition-colors';

// Crea la sessió al backend en entrar. Si falla, no impedix l'accés:
// el xat en crearà una en obrir l'escenari.
async function recordLogin(level: string) {
  try {
    await startSession(level);
  } catch (error) {
    console.error('Error creant la sessió:', error);
  }
}

// Marca la data d'avui com a última activitat. Un error no ha d'impedir l'accés.
async function updateLastActive(client: NonNullable<typeof supabase>, userId: string) {
  const today = new Date().toISOString().slice(0, 10);
  const { error } = await client.from('profiles').update({ last_active_on: today }).eq('id', userId);
  if (error) console.error('Error actualitzant last_active_on:', error.message);
}

export function AuthPage({ setPage }: { setPage: (p: Page) => void }) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [level, setLevel] = useState('principiant');
  const [ageGroup, setAgeGroup] = useState('');
  const [motherTongue, setMotherTongue] = useState('');
  const [notice, setNotice] = useState('');
  // El nivell només es tria en crear el compte: en iniciar sessió es llig del perfil.
  const [creating, setCreating] = useState(false);
  const [busy, setBusy] = useState(false);

  // Executa una acció d'autenticació amb l'estat d'espera i l'error de xarxa
  // comuns. Sense Supabase (mode demo) entra directament al tauler.
  const withAuth = async (action: (client: NonNullable<typeof supabase>) => Promise<void>) => {
    if (!supabase) return setPage('dashboard');
    try {
      setBusy(true);
      await action(supabase);
    } catch {
      setNotice(NETWORK_ERROR);
    } finally {
      setBusy(false);
    }
  };

  // Registre directe amb email + contrasenya. Amb Supabase local
  // (enable_confirmations = false) no cal verificar cap correu: la sessió
  // es crea a l'instant i l'usuari entra directament al tauler.
  const signUp = () => {
    if (supabase && password.length < 6) {
      return setNotice('La contrasenya ha de tindre almenys 6 caràcters.');
    }
    if (supabase && !ageGroup) return setNotice('Indica si el compte és per a un xiquet o per a una persona adulta.');
    if (supabase && !motherTongue) return setNotice('Tria la teua llengua materna.');
    // Només les persones adultes trien nivell; els xiquets comencen en principiant.
    const startLevel = ageGroup === 'adult' ? level : 'principiant';
    return withAuth(async client => {
      const { error } = await client.auth.signUp({
        email,
        password,
        options: { data: { level: startLevel, age_group: ageGroup || 'adult', mother_tongue: motherTongue, display_name: email.split('@')[0] } },
      });
      if (error) {
        setNotice(error.message?.toLowerCase().includes('already registered')
          ? 'Ja hi ha un compte amb aquest correu. Utilitza «Inicia sessió» amb la teua contrasenya.'
          : `No hem pogut crear el compte: ${error.message}`);
        return;
      }
      setNotice('Compte creat! Entrant...');
      await recordLogin(startLevel);
      setPage('dashboard');
    });
  };

  // Inici de sessió per a comptes ja creats (mateixa contrasenya). Cal tindre
  // un perfil a la taula `profiles`: si no n'hi ha (p. ex. es va esborrar),
  // es tanca la sessió acabada d'obrir i es rebutja l'accés.
  const logIn = () => withAuth(async client => {
    const { data, error } = await client.auth.signInWithPassword({ email, password });
    if (error) return setNotice(`No hem pogut iniciar sessió: ${error.message}`);

    const { data: profile } = await client.from('profiles').select('level').eq('id', data.user.id).single();
    if (!profile) {
      await client.auth.signOut();
      return setNotice('Este compte no té cap perfil associat. Contacta amb l\'administrador.');
    }

    await updateLastActive(client, data.user.id);
    await recordLogin(profile.level);
    setPage('dashboard');
  });

  return (
    <main className="fade-up grid min-h-screen place-items-center p-6" style={{ background: '#FAFAF9' }}>
      <section className="w-full max-w-md rounded-[36px] bg-white p-8 shadow-xl">
        <div className="mb-6 flex items-center gap-3">
          <button onClick={() => setPage('home')} className="text-sm font-bold opacity-50 hover:opacity-100 transition-opacity">
            ← Tornar
          </button>
        </div>
        <div className="text-center mb-6">
          <span className="text-4xl">🍊</span>
          <h1 className="mt-2 text-3xl font-black"><span style={{ color: '#0F47AF' }}>Parla</span><span style={{ color: '#FF3B3B' }}>Val</span></h1>
          <p className="mt-1 opacity-60">{creating ? 'Crea el teu compte i comença, sense necessitat de correu de verificació.' : 'Inicia sessió per continuar.'}</p>
        </div>

        <label className="block text-sm font-extrabold mb-1">Correu electrònic</label>
        <input
          value={email}
          onChange={e => { setEmail(e.target.value); setNotice(''); }}
          type="email"
          placeholder="tu@exemple.com"
          id="auth-email"
          autoComplete="email"
          className={INPUT_CLASS}
        />

        <label className="mt-4 block text-sm font-extrabold mb-1">Contrasenya</label>
        <input
          value={password}
          onChange={e => { setPassword(e.target.value); setNotice(''); }}
          type="password"
          placeholder="Mínim 6 caràcters"
          id="auth-password"
          autoComplete={creating ? 'new-password' : 'current-password'}
          onKeyDown={e => { if (e.key === 'Enter') void (creating ? signUp() : logIn()); }}
          className={INPUT_CLASS}
        />

        {creating && (
          <>
            <span id="auth-age-group-label" className="mt-4 block text-sm font-extrabold mb-1">Aquest compte és per a...</span>
            <div role="radiogroup" aria-labelledby="auth-age-group-label" id="auth-age-group" className="grid grid-cols-2 gap-3">
              {AGE_GROUP_OPTIONS.map(o => (
                <button
                  key={o.value}
                  type="button"
                  role="radio"
                  aria-checked={ageGroup === o.value}
                  onClick={() => setAgeGroup(o.value)}
                  className={`btn-press rounded-2xl border-2 p-3 text-sm font-extrabold transition-colors ${
                    ageGroup === o.value ? 'border-[#0F47AF] bg-[#0F47AF]/10 text-[#0F47AF]' : 'border-gray-100 bg-white text-gray-600'
                  }`}
                >
                  {o.label}
                </button>
              ))}
            </div>

            {ageGroup === 'adult' && (
              <>
                <label className="mt-4 block text-sm font-extrabold mb-1" htmlFor="auth-level">El teu nivell</label>
                <select
                  value={level}
                  onChange={e => setLevel(e.target.value)}
                  id="auth-level"
                  className={`${INPUT_CLASS} bg-white`}
                >
                  {LEVEL_OPTIONS.map(o => <option key={o.value} value={o.value}>{o.label}</option>)}
                </select>
              </>
            )}

            <label className="mt-4 block text-sm font-extrabold mb-1" htmlFor="auth-mother-tongue">La teua llengua materna</label>
            <select
              value={motherTongue}
              onChange={e => setMotherTongue(e.target.value)}
              id="auth-mother-tongue"
              className={`${INPUT_CLASS} bg-white`}
            >
              <option value="" disabled>Tria una llengua</option>
              {MOTHER_TONGUE_OPTIONS.map(o => <option key={o.value} value={o.value}>{o.label}</option>)}
            </select>
          </>
        )}

        {creating ? (
          <>
            <button
              onClick={() => void signUp()}
              disabled={busy}
              id="auth-submit"
              className="btn-press mt-6 w-full rounded-2xl py-3 font-extrabold text-white transition hover:opacity-90 active:scale-[0.98] disabled:opacity-60"
              style={{ background: 'linear-gradient(135deg, #0F47AF, #0B3785)' }}
            >
              {busy ? 'Espera...' : 'Crear compte'}
            </button>

            <button
              onClick={() => { setCreating(false); setNotice(''); }}
              disabled={busy}
              id="auth-login"
              className="btn-press mt-3 w-full rounded-xl py-1.5 text-sm font-bold text-gray-500 transition hover:text-[#0F47AF] disabled:opacity-60"
            >
              Ja tinc compte · Inicia sessió
            </button>
          </>
        ) : (
          <>
            <button
              onClick={() => void logIn()}
              disabled={busy}
              id="auth-login"
              className="btn-press mt-6 w-full rounded-2xl py-3 font-extrabold text-white transition hover:opacity-90 active:scale-[0.98] disabled:opacity-60"
              style={{ background: 'linear-gradient(135deg, #0F47AF, #0B3785)' }}
            >
              {busy ? 'Espera...' : 'Inicia sessió'}
            </button>

            <button
              onClick={() => { setCreating(true); setNotice(''); }}
              disabled={busy}
              id="auth-submit"
              className="btn-press mt-3 w-full rounded-2xl border-2 border-gray-200 py-3 font-bold text-gray-700 transition hover:border-gray-300 hover:bg-gray-50 disabled:opacity-60"
            >
              Crear compte
            </button>
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

        <p className="mt-5 text-center text-xs opacity-40">Mode demo disponible sense Supabase.</p>
      </section>
    </main>
  );
}
