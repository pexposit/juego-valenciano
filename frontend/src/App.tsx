import { useState, useEffect } from 'react';
import {
  ChevronRight, Lock, MessageCircle,
  RotateCcw, Volume2, X, LogOut,
} from 'lucide-react';
import heroImg from './assets/hero-valencia.png';
import { SceneArt } from './components/SceneArt';
import { VoiceInput } from './components/VoiceInput';
import { HistoryModal, type Msg } from './components/HistoryModal';
import { createSession, sendTurn } from './lib/api';
import { supabase } from './lib/supabase';
import type { Mood, Scenario } from './lib/types';

type Page = 'home' | 'auth' | 'dashboard' | 'chat' | 'summary' | 'profile';

const scenarios: { id: Scenario; name: string; icon: string; required: number; color: string; bgIllustration: string }[] = [
  { id: 'mercat',     name: 'El Mercat',     icon: '🍊', required: 0, color: '#FFD98A', bgIllustration: '#FFF3CC' },
  { id: 'bar',        name: 'El Bar',        icon: '☕', required: 0, color: '#F2B47C', bgIllustration: '#FDE8D0' },
  { id: 'oficina',    name: "L'Oficina",     icon: '💻', required: 0, color: '#BDE9E8', bgIllustration: '#E2F5F4' },
  { id: 'ajuntament', name: "L'Ajuntament",  icon: '🏛️', required: 0, color: '#C8D7EE', bgIllustration: '#E8EFF8' },
];

/* ── Decorative oranges header ──────────────────────────────────── */
function OrangeHeader({ children }: { children: React.ReactNode }) {
  return (
    <div className="azulejo-border relative overflow-hidden rounded-b-[40px] bg-gradient-to-br from-[#FFF9ED] to-[#FFE8BA] pb-4 pt-5 shadow-sm">
      {/* Decorative oranges */}
      <span className="orange-deco absolute left-3 top-1 text-2xl select-none">🍊</span>
      <span className="orange-deco absolute left-14 top-0 text-xl select-none opacity-70">🍊</span>
      <span className="orange-deco absolute right-14 top-0 text-xl select-none opacity-70">🍊</span>
      <span className="orange-deco absolute right-3 top-1 text-2xl select-none">🍊</span>
      {/* Small sun rays */}
      <div className="absolute inset-0 opacity-20 pointer-events-none"
           style={{ background: 'radial-gradient(ellipse at 50% -20%, #F9C74F 0%, transparent 70%)' }} />
      {children}
    </div>
  );
}

/* ── Logo ────────────────────────────────────────────────────────── */
function Logo({ size = 'md' }: { size?: 'sm' | 'md' | 'lg' }) {
  const cls = size === 'lg' ? 'text-4xl' : size === 'sm' ? 'text-xl' : 'text-2xl';
  return (
    <b className={`${cls} font-black tracking-tight`}>
      <span style={{ color: '#2CA99B' }}>Parla</span>
      <span style={{ color: '#FF675D' }}>Val</span>
    </b>
  );
}

/* ── Stat pill ───────────────────────────────────────────────────── */
function Stat({ icon, label, value }: { icon: string; label: string; value: string }) {
  return (
    <div className="stat-pill flex-1 flex-col text-center min-w-0">
      <span className="text-xl block">{icon}</span>
      <b className="text-sm block">{value}</b>
      <small className="text-[11px] font-semibold opacity-55">{label}</small>
    </div>
  );
}

/* ══════════════════ HOME PAGE ══════════════════════════════════════ */
function HomePage({ setPage }: { setPage: (p: Page) => void }) {
  return (
    <main className="fade-up min-h-screen flex flex-col">
      {/* Nav */}
      <nav className="flex items-center justify-between px-6 py-4">
        <Logo />
        <button
          onClick={() => setPage('auth')}
          className="rounded-full border-2 border-[#2CA99B] px-4 py-1.5 text-sm font-extrabold text-[#2CA99B] hover:bg-[#2CA99B] hover:text-white transition-colors"
        >
          Entra
        </button>
      </nav>

      {/* Hero */}
      <section className="mx-auto grid max-w-6xl flex-1 items-center gap-10 px-6 pb-16 pt-6 md:grid-cols-2 md:pt-16">
        <div>
          <span
            className="inline-flex items-center gap-2 rounded-full px-4 py-2 text-sm font-extrabold"
            style={{ background: 'rgba(249,199,79,0.28)', color: '#9A6B00' }}
          >
            ✨ Valencià per a la vida real
          </span>
          <h1 className="mt-5 text-5xl font-black leading-[1.08] sm:text-6xl">
            Parla valencià.<br />
            <em className="not-italic" style={{ color: '#FF675D' }}>Viu-lo.</em>
          </h1>
          <p className="mt-4 max-w-md text-lg leading-relaxed opacity-65">
            Practica converses reals, al teu ritme, amb personatges que t'acompanyen cada dia pels carrers de València.
          </p>
          <button
            onClick={() => setPage('auth')}
            id="hero-cta"
            className="mt-8 inline-flex items-center gap-2 rounded-2xl px-7 py-4 text-lg font-extrabold text-white shadow-lg transition hover:scale-[1.03] hover:shadow-xl active:scale-[0.98]"
            style={{ background: 'linear-gradient(135deg, #FF675D, #FF8A4C)' }}
          >
            Comença ara <ChevronRight size={20} />
          </button>
          <p className="mt-4 text-sm opacity-50">🍊 Mercat · Bar · Oficina · Ajuntament</p>
        </div>

        {/* Hero illustration — Valencia */}
        <div className="relative h-[400px] overflow-hidden rounded-[44px] shadow-2xl">
          <img
            src={heroImg}
            alt="La Ciutat de les Arts i les Ciències de València"
            className="h-full w-full object-cover object-center"
          />
          {/* Bottom gradient overlay for legibility */}
          <div
            className="absolute inset-0 rounded-[44px]"
            style={{ background: 'linear-gradient(to top, rgba(38,55,71,0.45) 0%, transparent 55%)' }}
          />
          {/* Caption */}
          <div className="absolute bottom-5 left-5 right-5 flex items-end justify-between">
            <span className="rounded-2xl bg-white/90 px-4 py-2 text-sm font-extrabold shadow backdrop-blur-sm">
              🏛️ Ciutat de les Arts i les Ciències · València
            </span>
          </div>
          {/* Floating chat preview */}
          <div className="absolute left-5 top-6 max-w-[58%] rounded-2xl bg-white/95 p-3 text-sm font-bold shadow-xl backdrop-blur-sm leading-snug">
            Bon dia! Què voldries practicar hui? 🍊
          </div>
        </div>
      </section>

      {/* Footer strip */}
      <div
        className="py-6 text-center text-white font-black text-lg"
        style={{ background: 'linear-gradient(90deg, #2CA99B, #23877C)' }}
      >
        Aprén parlant, no memoritzant.
      </div>
    </main>
  );
}

/* ══════════════════ AUTH PAGE ══════════════════════════════════════ */
function AuthPage({ setPage }: { setPage: (p: Page) => void }) {
  const [email, setEmail] = useState('');
  const [level, setLevel] = useState('principiant');
  const [notice, setNotice] = useState('');

  const start = async () => {
    if (supabase && email) {
      try {
        const { error } = await supabase.auth.signInWithOtp({
          email,
          options: { emailRedirectTo: location.origin, data: { level } },
        });
        setNotice(
          error
            ? `No hem pogut enviar el correu: ${error.message}`
            : `T'hem enviat un missatge a ${email}. Revisa la safata d'entrada.`
        );
      } catch {
        setNotice("No hem pogut connectar. Revisa la connexió i torna-ho a provar.");
      }
    } else {
      setPage('dashboard');
    }
  };

  return (
    <main className="fade-up grid min-h-screen place-items-center p-6" style={{ background: '#FFF9ED' }}>
      <section className="w-full max-w-md rounded-[36px] bg-white p-8 shadow-xl">
        {/* Decorative top */}
        <div className="mb-6 flex items-center gap-3">
          <button onClick={() => setPage('home')} className="text-sm font-bold opacity-50 hover:opacity-100 transition-opacity">
            ← Tornar
          </button>
        </div>
        <div className="text-center mb-6">
          <span className="text-4xl">🍊</span>
          <h1 className="mt-2 text-3xl font-black"><span style={{ color: '#2CA99B' }}>Parla</span><span style={{ color: '#FF675D' }}>Val</span></h1>
          <p className="mt-1 opacity-60">Comença la teua aventura lingüística.</p>
        </div>

        <label className="block text-sm font-extrabold mb-1">Correu electrònic</label>
        <input
          value={email}
          onChange={e => { setEmail(e.target.value); setNotice(''); }}
          type="email"
          placeholder="tu@exemple.com"
          id="auth-email"
          className="w-full rounded-2xl border-2 border-gray-100 p-3 outline-none focus:border-[#2CA99B] transition-colors"
        />

        <label className="mt-4 block text-sm font-extrabold mb-1">El teu nivell</label>
        <select
          value={level}
          onChange={e => setLevel(e.target.value)}
          id="auth-level"
          className="w-full rounded-2xl border-2 border-gray-100 bg-white p-3 outline-none focus:border-[#2CA99B] transition-colors"
        >
          <option value="principiant">Principiant</option>
          <option value="intermedi">Intermedi</option>
          <option value="avancat">Avançat</option>
        </select>

        <button
          onClick={start}
          id="auth-submit"
          className="mt-6 w-full rounded-2xl py-3 font-extrabold text-white transition hover:opacity-90 active:scale-[0.98]"
          style={{ background: 'linear-gradient(135deg, #2CA99B, #23877C)' }}
        >
          Crear el compte
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

        <button
          onClick={() => supabase?.auth.signInWithOAuth({ provider: 'google', options: { redirectTo: location.origin } })}
          className="mt-3 w-full rounded-2xl border-2 border-gray-100 py-3 font-bold transition hover:border-gray-200 hover:bg-gray-50"
        >
          Continua amb Google
        </button>
        <p className="mt-5 text-center text-xs opacity-40">Mode demo disponible sense Supabase.</p>
      </section>
    </main>
  );
}

/* ══════════════════ DASHBOARD PAGE ════════════════════════════════ */
function Dashboard({
  name, xp, setPage, onScenario,
}: { name: string; xp: number; setPage: (p: Page) => void; onScenario: (s: Scenario) => void }) {
  return (
    <main className="fade-up min-h-screen" style={{ background: '#FFF9ED' }}>
      {/* Illustrated header */}
      <OrangeHeader>
        <div className="flex items-center justify-between px-5 pb-2 pt-1">
          <Logo />
          <button
            id="dashboard-profile-btn"
            onClick={() => setPage('profile')}
            className="avatar-ring grid h-11 w-11 place-items-center rounded-full font-black text-lg"
            style={{ background: '#F9C74F', color: '#263747' }}
          >
            {name[0]}
          </button>
        </div>
      </OrangeHeader>

      <div className="mx-auto max-w-2xl px-5 pt-6 pb-10">
        {/* Greeting */}
        <h1 className="text-3xl font-black">Bon dia, {name}! 👋</h1>

        {/* XP progress */}
        <div className="mt-5 rounded-3xl bg-white p-5 shadow-sm">
          <div className="flex justify-between text-sm font-extrabold mb-1">
            <span>Nivell 1 · Exploradora</span>
            <span style={{ color: '#FF675D' }}>⚡ {xp} / 100 XP</span>
          </div>
          <div className="h-3 overflow-hidden rounded-full" style={{ background: '#FFDFDB' }}>
            <div className="xp-bar-fill h-full rounded-full transition-all duration-700" style={{ width: `${xp}%` }} />
          </div>
        </div>

        {/* Stats */}
        <div className="mt-4 flex gap-3">
          <Stat icon="🔥" label="Racha" value="3 dies" />
          <Stat icon="🏅" label="Insígnies" value="1" />
          <Stat icon="💬" label="Paraules" value="24" />
        </div>

        {/* Scenario grid */}
        <h2 className="mt-8 text-2xl font-black">Tria una situació</h2>
        <p className="text-sm opacity-50 mt-1">On vols practicar hui?</p>

        <div className="mt-4 grid grid-cols-2 gap-4">
          {scenarios.map(s => {
            const locked = xp < s.required;
            return (
              <button
                key={s.id}
                id={`scenario-${s.id}`}
                disabled={locked}
                onClick={() => onScenario(s.id)}
                className="scene-card text-left"
                style={{ background: locked ? '#F5F5F5' : '#fff' }}
              >
                {/* Illustration area */}
                <div
                  className="relative flex h-28 items-center justify-center overflow-hidden rounded-t-[20px]"
                  style={{ background: locked ? '#E8E8E8' : s.color }}
                >
                  <span className="text-6xl select-none">{s.icon}</span>
                  {locked && (
                    <div className="absolute inset-0 flex items-center justify-center bg-black/20 rounded-t-[20px]">
                      <Lock size={24} className="text-white drop-shadow" />
                    </div>
                  )}
                </div>
                {/* Label */}
                <div className="px-4 py-3">
                  <b className="block text-base font-black" style={{ color: locked ? '#aaa' : '#263747' }}>
                    {s.name}
                  </b>
                  <span className="text-xs font-bold" style={{ color: locked ? '#bbb' : '#2CA99B' }}>
                    {locked ? `🔒 ${s.required} XP necessaris` : '✓ Disponible'}
                  </span>
                </div>
              </button>
            );
          })}
        </div>
      </div>
    </main>
  );
}

/* ══════════════════ CHAT PAGE ══════════════════════════════════════ */
function Chat({
  scenario, level, xp, setXp, onEnd, onBack,
}: { scenario: Scenario; level: string; xp: number; setXp: (n: number) => void; onEnd: () => void; onBack: () => void }) {
  const [mood, setMood] = useState<Mood>('neutral');
  const [character, setCharacter] = useState('Bon dia! Com et puc ajudar hui?');
  const [user, setUser] = useState('');
  const [loading, setLoading] = useState(false);
  const [history, setHistory] = useState<Msg[]>([]);
  const [showHistory, setShowHistory] = useState(false);
  const [session, setSession] = useState<string>();

  const submit = async (text: string, audio?: string) => {
    if ((!text && !audio) || loading) return;
    setUser(text || '🎙️ Missatge de veu');
    setLoading(true);
    try {
      const activeSession = session || await createSession(scenario, level);
      if (!session) setSession(activeSession);
      const r = await sendTurn({ session_id: activeSession, scenario, level, input_mode: audio ? 'voice' : 'text', text, audio_base64: audio || null });
      setCharacter(r.reply_text);
      setMood(r.mood);
      setXp(xp + r.xp_delta);
      setHistory(h => [...h, { role: 'user', text: text || '🎙️ Missatge de veu' }, { role: 'character', text: r.reply_text }]);
      if (r.reply_audio_base64) {
        const a = new Audio(`data:audio/mpeg;base64,${r.reply_audio_base64}`);
        a.play().catch(() => {});
      }
    } catch {
      setCharacter("No t'he sentit bé, pots repetir-ho?");
      setMood('confus');
    } finally {
      setLoading(false);
    }
  };

  return (
    <main className="relative h-[100dvh] overflow-hidden">
      <SceneArt scenario={scenario} mood={mood} />

      {/* Top bar */}
      <header className="absolute inset-x-0 top-0 z-10 flex items-center justify-between p-4">
        <button
          onClick={onBack}
          id="chat-back-btn"
          className="rounded-full bg-white/90 px-4 py-2 font-bold shadow backdrop-blur-sm hover:bg-white transition-colors"
        >
          ← Eixir
        </button>
        <div
          className="rounded-full px-4 py-2 text-sm font-black shadow backdrop-blur-sm"
          style={{ background: 'rgba(255,255,255,0.9)' }}
        >
          ⚡ {xp} XP
        </div>
        <button
          onClick={() => setShowHistory(true)}
          id="chat-history-btn"
          className="grid h-10 w-10 place-items-center rounded-full bg-white/90 shadow backdrop-blur-sm hover:bg-white transition-colors"
        >
          <MessageCircle size={19} />
        </button>
      </header>

      {/* Character bubble */}
      <section className="bubble absolute left-5 top-[13%] z-10 max-w-[min(76%,440px)] rounded-3xl bg-white p-5 font-bold shadow-xl text-base">
        <p className="leading-relaxed">
          {loading
            ? <span className="opacity-50">El personatge està escrivint…</span>
            : character
          }
        </p>
        {!loading && (
          <button
            onClick={() => speechSynthesis.speak(new SpeechSynthesisUtterance(character))}
            className="mt-3 flex items-center gap-1 text-sm font-extrabold"
            style={{ color: '#2CA99B' }}
          >
            <Volume2 size={15} /> Escolta de nou
          </button>
        )}
      </section>

      {/* User bubble */}
      {user && (
        <div
          className="user-bubble absolute bottom-28 right-5 z-10 max-w-[70%] rounded-3xl p-4 font-bold text-white shadow-lg"
          style={{ background: '#2CA99B' }}
        >
          {user}
        </div>
      )}

      {/* Input */}
      <div className="absolute inset-x-4 bottom-5 z-20">
        <VoiceInput onSend={submit} disabled={loading} />
        <button
          onClick={onEnd}
          id="chat-end-btn"
          className="mx-auto mt-3 block rounded-full bg-white/80 px-4 py-2 text-xs font-extrabold backdrop-blur-sm hover:bg-white transition-colors"
        >
          Acabar conversa
        </button>
      </div>

      {showHistory && <HistoryModal messages={history} onClose={() => setShowHistory(false)} />}
    </main>
  );
}

/* ══════════════════ SUMMARY PAGE ═══════════════════════════════════ */
function Summary({ xp, onMap, onContinue }: { xp: number; onMap: () => void; onContinue: () => void }) {
  return (
    <main className="fade-up grid min-h-screen place-items-center p-5" style={{ background: '#FFF9ED' }}>
      <section className="w-full max-w-lg rounded-[40px] bg-white p-8 text-center shadow-xl">
        <div
          className="mx-auto grid h-20 w-20 place-items-center rounded-full text-4xl"
          style={{ background: '#FFD98A' }}
        >
          🎉
        </div>
        <h1 className="mt-5 text-3xl font-black">Molt bé!</h1>
        <p className="mt-2 opacity-60">Has practicat valencià en una situació real.</p>

        {/* XP gained */}
        <div
          className="mt-7 rounded-3xl p-5"
          style={{ background: 'linear-gradient(135deg, #FFF3E0, #FFE8BA)' }}
        >
          <b className="text-4xl font-black" style={{ color: '#FF675D' }}>+10 XP</b>
          <p className="mt-1 text-sm font-bold opacity-60">Total: {xp} XP</p>
        </div>

        {/* Vocabulary */}
        <div className="mt-6 text-left">
          <h2 className="font-black text-lg">Paraules noves 🌟</h2>
          <p
            className="mt-2 rounded-2xl p-3 text-sm font-bold"
            style={{ background: '#E8F7F5', color: '#1a7a6f' }}
          >
            bon dia · voldria · gràcies
          </p>
          <h2 className="mt-5 font-black text-lg">A millorar 💪</h2>
          <p className="mt-2 text-sm opacity-60">Continua practicant la concordança de gènere.</p>
        </div>

        <button
          onClick={onContinue}
          id="summary-continue-btn"
          className="mt-7 w-full rounded-2xl py-3 font-extrabold text-white transition hover:opacity-90"
          style={{ background: 'linear-gradient(135deg, #2CA99B, #23877C)' }}
        >
          Continuar
        </button>
        <button
          onClick={onMap}
          id="summary-map-btn"
          className="mt-3 font-bold"
          style={{ color: '#2CA99B' }}
        >
          Tornar al mapa
        </button>
      </section>
    </main>
  );
}

/* ══════════════════ PROFILE PAGE ════════════════════════════════════ */
function Profile({
  name, setName, level, setLevel, xp, back, onLogOut, isDemo,
}: {
  name: string;
  setName: (v: string) => void;
  level: string;
  setLevel: (v: string) => void;
  xp: number;
  back: () => void;
  onLogOut: () => void;
  isDemo: boolean;
}) {
  return (
    <main className="fade-up" style={{ background: '#FFF9ED', minHeight: '100vh' }}>
      <OrangeHeader>
        <div className="px-5 pb-2">
          <button
            onClick={back}
            className="font-bold text-sm"
            style={{ color: '#2CA99B' }}
          >
            ← Tornar al mapa
          </button>
        </div>
      </OrangeHeader>

      <div className="mx-auto max-w-lg px-5 pt-6 pb-10">
        <h1 className="text-3xl font-black">El teu progrés 🏆</h1>

        <div className="mt-5 rounded-3xl bg-white p-6 shadow-sm space-y-4">
          <label className="block font-extrabold text-sm">
            Nom
            <input
              value={name}
              onChange={e => setName(e.target.value)}
              id="profile-name"
              className="mt-1 w-full rounded-2xl border-2 border-gray-100 p-3 font-normal outline-none focus:border-[#2CA99B] transition-colors"
            />
          </label>
          <label className="block font-extrabold text-sm">
            Nivell
            <select
              value={level}
              onChange={e => setLevel(e.target.value)}
              id="profile-level"
              className="mt-1 w-full rounded-2xl border-2 border-gray-100 bg-white p-3 font-normal outline-none focus:border-[#2CA99B] transition-colors"
            >
              <option value="principiant">Principiant</option>
              <option value="intermedi">Intermedi</option>
              <option value="avancat">Avançat</option>
            </select>
          </label>
        </div>

        <div className="mt-5 grid grid-cols-2 gap-3">
          <Stat icon="⚡" label="XP total" value={String(xp)} />
          <Stat icon="🗺️" label="Escenaris" value="1 / 4" />
          <Stat icon="💬" label="Paraules" value="24" />
          <Stat icon="🏆" label="Insígnies" value="1" />
        </div>

        <div className="mt-8 flex flex-col gap-3">
          <button
            onClick={() => confirm('Vols reiniciar el teu progrés?') && location.reload()}
            id="profile-reset-btn"
            className="flex items-center justify-center gap-2 rounded-2xl border-2 border-coral/20 bg-coral/5 py-3 text-sm font-extrabold text-coral hover:bg-coral/10 transition-colors"
          >
            <RotateCcw size={16} /> Reinicia el progrés
          </button>

          {!isDemo && (
            <button
              onClick={() => confirm('Segur que vols tancar la sessió?') && onLogOut()}
              id="profile-logout-btn"
              className="flex items-center justify-center gap-2 rounded-2xl border-2 border-gray-200 bg-white py-3 text-sm font-extrabold text-gray-500 hover:bg-gray-50 hover:text-gray-700 transition-colors"
            >
              <LogOut size={16} /> Tanca la sessió
            </button>
          )}
        </div>
      </div>
    </main>
  );
}

/* ══════════════════ APP ROOT ════════════════════════════════════════ */
export function App() {
  const [page, setPage] = useState<Page>('home');
  const [xp, setXp] = useState(35);
  const [scenario, setScenario] = useState<Scenario>('mercat');
  const [level, setLevel] = useState('principiant');
  const [name, setName] = useState('Aina');
  const [user, setUser] = useState<any>(null);

  // Sync profile details from Supabase if logged in
  const fetchAndLoadProfile = async (uid: string) => {
    if (!supabase) return;
    try {
      const { data, error } = await supabase
        .from('profiles')
        .select('display_name, level, xp')
        .eq('id', uid)
        .single();
      if (data) {
        setName(data.display_name || 'Aina');
        setLevel(data.level || 'principiant');
        setXp(data.xp || 0);
      }
    } catch (e) {
      console.error('Error carregant perfil:', e);
    }
  };

  useEffect(() => {
    if (!supabase) return;

    // Check active session on mount
    supabase.auth.getSession().then(({ data: { session } }) => {
      if (session?.user) {
        setUser(session.user);
        fetchAndLoadProfile(session.user.id);
        setPage('dashboard');
      }
    });

    // Listen for auth state changes
    const { data: { subscription } } = supabase.auth.onAuthStateChange(async (event, session) => {
      if (session?.user) {
        setUser(session.user);
        await fetchAndLoadProfile(session.user.id);
        setPage((prev) => (prev === 'home' || prev === 'auth' ? 'dashboard' : prev));
      } else {
        setUser(null);
        setName('Aina');
        setLevel('principiant');
        setXp(35);
        setPage('home');
      }
    });

    return () => {
      subscription.unsubscribe();
    };
  }, []);

  const updateProfileName = async (newName: string) => {
    setName(newName);
    if (supabase && user) {
      try {
        await supabase.from('profiles').update({ display_name: newName }).eq('id', user.id);
      } catch (err) {
        console.error('Error desant nom:', err);
      }
    }
  };

  const updateProfileLevel = async (newLevel: string) => {
    setLevel(newLevel);
    if (supabase && user) {
      try {
        await supabase.from('profiles').update({ level: newLevel }).eq('id', user.id);
      } catch (err) {
        console.error('Error desant nivell:', err);
      }
    }
  };

  const handleLogOut = async () => {
    if (supabase) {
      await supabase.auth.signOut();
    }
  };

  if (page === 'home')      return <HomePage setPage={setPage} />;
  if (page === 'auth')      return <AuthPage setPage={setPage} />;
  if (page === 'dashboard') return <Dashboard name={name} xp={xp} setPage={setPage} onScenario={s => { setScenario(s); setPage('chat'); }} />;
  if (page === 'profile') {
    return (
      <Profile
        name={name}
        setName={updateProfileName}
        level={level}
        setLevel={updateProfileLevel}
        xp={xp}
        back={() => setPage('dashboard')}
        onLogOut={handleLogOut}
        isDemo={!user}
      />
    );
  }
  if (page === 'summary')   return <Summary xp={xp} onMap={() => setPage('dashboard')} onContinue={() => setPage('chat')} />;
  return (
    <Chat
      scenario={scenario}
      level={level}
      xp={xp}
      setXp={setXp}
      onEnd={() => setPage('summary')}
      onBack={() => setPage('dashboard')}
    />
  );
}
