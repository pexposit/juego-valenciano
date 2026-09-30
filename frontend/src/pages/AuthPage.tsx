import { useState } from 'react';
import { supabase } from '../lib/supabase';
import { LEVEL_OPTIONS, type Page } from '../data/content';
import { startSession } from '../lib/api';

const NETWORK_ERROR = 'No hem pogut connectar. Revisa la connexió i torna-ho a provar.';
const INPUT_CLASS = 'w-full rounded-2xl border-2 border-gray-100 p-3 outline-none focus:border-[#0D9488] transition-colors';

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
  const [notice, setNotice] = useState('');
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
    return withAuth(async client => {
      const { error } = await client.auth.signUp({
        email,
        password,
        options: { data: { level, display_name: email.split('@')[0] } },
      });
      if (error) {
        setNotice(error.message?.toLowerCase().includes('already registered')
          ? 'Ja hi ha un compte amb aquest correu. Utilitza «Inicia sessió» amb la teua contrasenya.'
          : `No hem pogut crear el compte: ${error.message}`);
        return;
      }
      setNotice('Compte creat! Entrant...');
      await recordLogin(level);
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
          <h1 className="mt-2 text-3xl font-black"><span style={{ color: '#0D9488' }}>Parla</span><span style={{ color: '#F97316' }}>Val</span></h1>
          <p className="mt-1 opacity-60">Crea el teu compte i comença, sense necessitat de correu de verificació.</p>
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
          autoComplete="new-password"
          onKeyDown={e => { if (e.key === 'Enter') void signUp(); }}
          className={INPUT_CLASS}
        />

        <label className="mt-4 block text-sm font-extrabold mb-1">El teu nivell</label>
        <select
          value={level}
          onChange={e => setLevel(e.target.value)}
          id="auth-level"
          className={`${INPUT_CLASS} bg-white`}
        >
          {LEVEL_OPTIONS.map(o => <option key={o.value} value={o.value}>{o.label}</option>)}
        </select>

        <button
          onClick={() => void signUp()}
          disabled={busy}
          id="auth-submit"
          className="btn-press mt-6 w-full rounded-2xl py-3 font-extrabold text-white transition hover:opacity-90 active:scale-[0.98] disabled:opacity-60"
          style={{ background: 'linear-gradient(135deg, #0D9488, #0F766E)' }}
        >
          {busy ? 'Espera...' : 'Crear el compte'}
        </button>

        <button
          onClick={() => void logIn()}
          disabled={busy}
          id="auth-login"
          className="btn-press mt-3 w-full rounded-2xl border-2 border-gray-200 py-3 font-bold text-gray-700 transition hover:border-gray-300 hover:bg-gray-50 disabled:opacity-60"
        >
          Ja tinc compte · Inicia sessió
        </button>

        {notice && (
          <div
            role="status"
            className="mt-4 rounded-2xl p-4 text-sm font-bold"
            style={{ background: '#E8F7F5', color: '#1a7a6f', border: '1px solid #b2ddd9' }}
          >
            {notice}
          </div>
        )}

        <p className="mt-5 text-center text-xs opacity-40">Mode demo disponible sense Supabase.</p>
      </section>
    </main>
  );
}
