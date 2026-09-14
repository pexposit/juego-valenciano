import { useState, useEffect, useRef } from 'react';
import {
  ChevronRight, ListTodo, Lock, MessageCircle,
  RotateCcw, Volume2, X, LogOut,
} from 'lucide-react';
import { SceneArt } from './components/SceneArt';
import { VoiceInput } from './components/VoiceInput';
import { HistoryModal, type Msg } from './components/HistoryModal';
import { createSession, fetchScenarios, sendTurn, type HistoryItem } from './lib/api';
import { supabase } from './lib/supabase';
import type { Mood, Scenario } from './lib/types';

type Page = 'home' | 'auth' | 'dashboard' | 'chat' | 'summary' | 'profile';

const scenarios: { id: Scenario; name: string; icon: string; required: number; color: string; bgIllustration: string }[] = [
  { id: 'mercat',     name: 'El Mercat',     icon: '🍊', required: 0, color: '#FFD98A', bgIllustration: '#FFF3CC' },
  { id: 'bar',        name: 'El Bar',        icon: '☕', required: 0, color: '#F2B47C', bgIllustration: '#FDE8D0' },
  { id: 'oficina',    name: "L'Oficina",     icon: '💻', required: 0, color: '#BDE9E8', bgIllustration: '#E2F5F4' },
  { id: 'ajuntament', name: "L'Ajuntament",  icon: '🏛️', required: 0, color: '#C8D7EE', bgIllustration: '#E8EFF8' },
  { id: 'colegi',     name: "L'Escola",      icon: '🎒', required: 0, color: '#C4E3A3', bgIllustration: '#EFF8E2' },
  { id: 'turisme',    name: 'Oficina de Turisme', icon: '🗺️', required: 0, color: '#9AD0EC', bgIllustration: '#E4F3FB' },
];

/* Objectius per defecte de cada escenari; es mostren mentres el backend respon. */
const scenarioGoals: Record<Scenario, { character: string; objectius: string[] }> = {
  mercat: { character: 'Vicent, venedor del mercat', objectius: ['Saluda en Vicent i pregunta com va tot.', 'Demana un quilo de taronges o una altra fruita.', 'Pregunta el preu o demana el canvi.', "Paga, dona les gràcies i acomiada't."] },
  bar: { character: 'Maria, cambrera', objectius: ['Saluda la Maria i busca una taula.', "Demana una beguda o l'esmorzar del dia.", 'Pregunta quant és o demana el compte.', "Paga, dona les gràcies i acomiada't."] },
  oficina: { character: "Joan, company d'oficina", objectius: ['Saluda en Joan i pregunta com està.', "Pregunta per la reunió o les tasques d'avui.", 'Demana ajuda o un aclariment sobre un tema.', "Confirma el que has de fer i acomiada't."] },
  ajuntament: { character: "Amparo, funcionària d'atenció", objectius: ["Saluda l'Amparo i digues què necessites.", 'Explica el tràmit que vols fer.', 'Pregunta els requisits o els horaris.', "Dona les gràcies i acomiada't."] },
  colegi: { character: 'Marta, mestra', objectius: ['Saluda la Marta i pregunta com està.', "Pregunta pels deures o la tasca d'avui.", 'Demana permís o explica un dubte.', "Dona les gràcies i acomiada't."] },
  turisme: { character: 'Laura, guia turística', objectius: ['Saluda la Laura i digues què busques.', 'Demana una recomanació de lloc per visitar.', 'Pregunta horaris, preus o com arribar-hi.', "Dona les gràcies i acomiada't."] },
};

/* ── Decorative oranges header ──────────────────────────────────── */
function OrangeHeader({ children, showOranges = true }: { children: React.ReactNode; showOranges?: boolean }) {
  return (
    <div
      className={`${
        showOranges ? 'azulejo-border bg-gradient-to-br from-[#FFF9ED] to-[#FFE8BA]' : 'border-b border-[#E7E5E4] bg-gradient-to-br from-[#FAFAF9] to-[#FFFFFF]'
      } relative overflow-hidden rounded-b-[40px] pb-4 pt-5 shadow-sm`}
    >
      {/* Decorative oranges */}
      {showOranges && (
        <>
          <span className="orange-deco absolute left-3 top-1 text-2xl select-none">🍊</span>
          <span className="orange-deco absolute left-14 top-0 text-xl select-none opacity-70">🍊</span>
          <span className="orange-deco absolute right-14 top-0 text-xl select-none opacity-70">🍊</span>
          <span className="orange-deco absolute right-3 top-1 text-2xl select-none">🍊</span>
        </>
      )}
      {/* Small sun rays */}
      {showOranges && (
        <div className="absolute inset-0 opacity-20 pointer-events-none"
             style={{ background: 'radial-gradient(ellipse at 50% -20%, #F9C74F 0%, transparent 70%)' }} />
      )}
      {children}
    </div>
  );
}

/* ── Logo ────────────────────────────────────────────────────────── */
function Logo({ size = 'md' }: { size?: 'sm' | 'md' | 'lg' }) {
  const cls = size === 'lg' ? 'text-4xl' : size === 'sm' ? 'text-xl' : 'text-2xl';
  return (
    <b className={`${cls} font-black tracking-tight`}>
      <span style={{ color: '#0D9488' }}>Parla</span>
      <span style={{ color: '#F97316' }}>Val</span>
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

/* ── Page transition wrapper ─────────────────────────────────────── */
function PageTransition({ children }: { children: React.ReactNode }) {
  return <div className="page-enter">{children}</div>;
}

/* ══════════════════ HOME PAGE ══════════════════════════════════════ */
const homeImages = [
  {
    src: '/images/Ciudad de las Artes y las Ciencias: Complejo arquitectónico moderno con edificios blancos y formas futuristas rodeados de agua, símbolo de innovación..jpeg',
    label: '🏛️ Ciutat de les Arts i les Ciències · València',
    alt: 'Ciutat de les Arts i les Ciències de València',
  },
  {
    src: '/images/Mercado Central: Espacio lleno de vida con puestos de comida fresca, colores y productos típicos valencianos.jpeg',
    label: '🍊 Mercat Central · València',
    alt: 'Mercat Central de València',
  },
  {
    src: '/images/Plaza del Ayuntamiento: Centro neurálgico de la ciudad, rodeado de edificios históricos y escenario de eventos importantes.jpeg',
    label: '🏙️ Plaça de l’Ajuntament · València',
    alt: 'Plaça de l’Ajuntament de València',
  },
  {
    src: '/images/Playa de la Malvarrosa: Amplia playa urbana con arena dorada y paseo marítimo muy animado.jpeg',
    label: '🌊 Platja de la Malva-rosa · València',
    alt: 'Platja de la Malva-rosa de València',
  },
  {
    src: '/images/Playa de Gandía: Playa extensa, de aguas tranquilas y arena fina, ideal para familias.jpeg',
    label: '🏖️ Platja de Gandia',
    alt: 'Platja de Gandia',
  },
  {
    src: '/images/Calas de Jávea: Pequeñas calas de aguas cristalinas y rocas, perfectas para bucear.jpeg',
    label: '🐠 Caletes de Xàbia',
    alt: 'Caletes de Xàbia',
  },
  {
    src: '/images/Castillo del Papa Luna: Fortaleza situada sobre una roca junto al mar, imponente y bien conservada..jpeg',
    label: '🏰 Castell del Papa Luna · Peníscola',
    alt: 'Castell del Papa Luna de Peníscola',
  },
];

function HomePage({ setPage }: { setPage: (p: Page) => void }) {
  const [activeImage, setActiveImage] = useState(0);

  useEffect(() => {
    const timer = window.setInterval(() => {
      setActiveImage(current => (current + 1) % homeImages.length);
    }, 5000);

    return () => window.clearInterval(timer);
  }, []);

  const image = homeImages[activeImage];

  return (
    <main className="fade-up min-h-screen flex flex-col">
      {/* Nav */}
      <nav className="flex items-center justify-between px-6 py-4">
        <Logo />
        <button
          onClick={() => setPage('auth')}
          className="btn-press rounded-full border-2 border-[#0D9488] px-4 py-1.5 text-sm font-extrabold text-[#0D9488] hover:bg-[#0D9488] hover:text-white transition-colors"
        >
          Entra
        </button>
      </nav>

      {/* Hero */}
      <section className="mx-auto grid max-w-6xl flex-1 items-center gap-10 px-6 pb-16 pt-6 md:grid-cols-2 md:pt-16">
        <div className="hero-stagger">
          <span
            className="inline-flex items-center gap-2 rounded-full px-4 py-2 text-sm font-extrabold"
            style={{ background: 'rgba(249,199,79,0.28)', color: '#9A6B00' }}
          >
            ✨ Valencià per a la vida real
          </span>
          <h1 className="mt-5 text-5xl font-black leading-[1.08] sm:text-6xl">
            Parla valencià.<br />
            <em className="not-italic" style={{ color: '#F97316' }}>Viu-lo.</em>
          </h1>
          <p className="mt-4 max-w-md text-lg leading-relaxed opacity-65">
            Practica converses reals, al teu ritme, amb personatges que t'acompanyen cada dia pels carrers de València.
          </p>
          <button
            onClick={() => setPage('auth')}
            id="hero-cta"
            className="btn-press mt-8 inline-flex items-center gap-2 rounded-2xl px-7 py-4 text-lg font-extrabold text-white shadow-lg transition hover:scale-[1.03] hover:shadow-xl active:scale-[0.98]"
            style={{ background: 'linear-gradient(135deg, #F97316, #FB923C)' }}
          >
            Comença ara <ChevronRight size={20} />
          </button>
          <p className="mt-4 text-sm opacity-50">🍊 Mercat · Bar · Oficina · Ajuntament · Escola · Turisme</p>
        </div>

        {/* Hero image carousel — Comunitat Valenciana */}
        <div className="relative h-[400px] overflow-hidden rounded-[44px] shadow-2xl">
          {homeImages.map((item, index) => (
            <img
              key={item.src}
              src={item.src}
              alt={index === activeImage ? item.alt : ''}
              aria-hidden={index !== activeImage}
              className="hero-carousel-image"
              style={{ opacity: index === activeImage ? 1 : 0 }}
            />
          ))}
          {/* Bottom gradient overlay for legibility */}
          <div
            className="absolute inset-0 rounded-[44px]"
            style={{ background: 'linear-gradient(to top, rgba(38,55,71,0.45) 0%, transparent 55%)' }}
          />
          {/* Caption */}
          <div className="absolute bottom-5 left-5 right-5 flex items-end justify-between">
            <span className="rounded-2xl bg-white/90 px-4 py-2 text-sm font-extrabold shadow backdrop-blur-sm">
              {image.label}
            </span>
          </div>
          {/* Floating chat preview */}
          <div className="absolute left-5 top-6 max-w-[58%] rounded-2xl bg-white/95 p-3 text-sm font-bold shadow-xl backdrop-blur-sm leading-snug">
            Bon dia! Què voldries practicar hui? 🍊
          </div>
          <div className="absolute bottom-6 right-6 flex gap-1.5" aria-label="Imatges de la Comunitat Valenciana">
            {homeImages.map((item, index) => (
              <button
                key={item.src}
                type="button"
                aria-label={`Veure ${item.alt}`}
                aria-current={index === activeImage ? 'true' : undefined}
                onClick={() => setActiveImage(index)}
                className="h-2.5 rounded-full transition-all"
                style={{
                  width: index === activeImage ? '24px' : '10px',
                  background: index === activeImage ? '#fff' : 'rgba(255,255,255,0.55)',
                }}
              />
            ))}
          </div>
        </div>
      </section>

      {/* Footer strip */}
      <div
        className="py-6 text-center text-white font-black text-lg"
        style={{ background: 'linear-gradient(90deg, #0D9488, #0F766E)' }}
      >
        Aprén parlant, no memoritzant.
      </div>
    </main>
  );
}

/* ══════════════════ AUTH PAGE ══════════════════════════════════════ */
function AuthPage({ setPage }: { setPage: (p: Page) => void }) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [level, setLevel] = useState('principiant');
  const [notice, setNotice] = useState('');
  const [busy, setBusy] = useState(false);

  // Registre directe amb email + contrasenya. Amb Supabase local
  // (enable_confirmations = false) no cal verificar cap correu: la sessió
  // es crea a l'instant i l'usuari entra directament al tauler.
  const signUp = async () => {
    if (!supabase) return setPage('dashboard');
    if (password.length < 6) {
      return setNotice('La contrasenya ha de tindre almenys 6 caràcters.');
    }
    try {
      setBusy(true);
      const { error } = await supabase.auth.signUp({
        email,
        password,
        options: { data: { level, display_name: email.split('@')[0] } },
      });
      if (error) {
        if (error.message?.toLowerCase().includes('already registered')) {
          setNotice('Ja hi ha un compte amb aquest correu. Utilitza «Inicia sessió» amb la teua contrasenya.');
        } else {
          setNotice(`No hem pogut crear el compte: ${error.message}`);
        }
        return;
      }
      setNotice('Compte creat! Entrant...');
      setPage('dashboard');
    } catch {
      setNotice('No hem pogut connectar. Revisa la connexió i torna-ho a provar.');
    } finally {
      setBusy(false);
    }
  };

  // Inici de sessió per a comptes ja creats (mateixa contrasenya).
  const logIn = async () => {
    if (!supabase) return setPage('dashboard');
    try {
      setBusy(true);
      const { error } = await supabase.auth.signInWithPassword({ email, password });
      if (error) return setNotice(`No hem pogut iniciar sessió: ${error.message}`);
      setPage('dashboard');
    } catch {
      setNotice('No hem pogut connectar. Revisa la connexió i torna-ho a provar.');
    } finally {
      setBusy(false);
    }
  };

  return (
    <main className="fade-up grid min-h-screen place-items-center p-6" style={{ background: '#FAFAF9' }}>
      <section className="w-full max-w-md rounded-[36px] bg-white p-8 shadow-xl">
        {/* Decorative top */}
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
          className="w-full rounded-2xl border-2 border-gray-100 p-3 outline-none focus:border-[#0D9488] transition-colors"
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
          className="w-full rounded-2xl border-2 border-gray-100 p-3 outline-none focus:border-[#0D9488] transition-colors"
        />

        <label className="mt-4 block text-sm font-extrabold mb-1">El teu nivell</label>
        <select
          value={level}
          onChange={e => setLevel(e.target.value)}
          id="auth-level"
          className="w-full rounded-2xl border-2 border-gray-100 bg-white p-3 outline-none focus:border-[#0D9488] transition-colors"
        >
          <option value="principiant">Principiant</option>
          <option value="intermedi">Intermedi</option>
          <option value="avancat">Avançat</option>
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

/* ══════════════════ DASHBOARD PAGE ════════════════════════════════ */
function Dashboard({
  name, xp, setPage, onScenario,
}: { name: string; xp: number; setPage: (p: Page) => void; onScenario: (s: Scenario) => void }) {
  const cardRefs = useRef<(HTMLButtonElement | null)[][]>([]);
  const xpBarRef = useRef<HTMLDivElement>(null);

  // Staggered card entrance
  useEffect(() => {
    cardRefs.current.flat().forEach((card, i) => {
      if (card) {
        card.style.animationDelay = `${i * 0.1}s`;
        card.classList.add('animate-in');
      }
    });
  }, []);

  // XP bar pulse when xp changes
  useEffect(() => {
    if (xpBarRef.current) {
      xpBarRef.current.classList.add('xp-pulse');
      const t = setTimeout(() => xpBarRef.current?.classList.remove('xp-pulse'), 550);
      return () => clearTimeout(t);
    }
  }, [xp]);

  return (
    <main className="fade-up min-h-screen" style={{ background: '#FAFAF9' }}>
      {/* Illustrated header */}
      <OrangeHeader showOranges={false}>
        <div className="flex items-center justify-between px-5 pb-2 pt-1">
          <Logo />
          <button
            id="dashboard-profile-btn"
            onClick={() => setPage('profile')}
            className="avatar-ring grid h-11 w-11 place-items-center rounded-full font-black text-lg text-white"
            style={{ background: '#F97316' }}
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
          <div className="grid grid-cols-3 text-sm font-extrabold mb-1">
            <span className="whitespace-nowrap">Nivell 1 · Exploradora</span>
            <span className="justify-self-center whitespace-nowrap" style={{ color: '#F97316' }}>⚡ {xp} / 100 XP</span>
          </div>
          <div className="h-3 overflow-hidden rounded-full" style={{ background: '#FFEDD5' }}>
            <div ref={xpBarRef} className="xp-bar-fill h-full rounded-full transition-all duration-700" style={{ width: `${xp}%` }} />
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
          {scenarios.map((s, i) => {
            const locked = xp < s.required;
            return (
              <button
                key={s.id}
                id={`scenario-${s.id}`}
                disabled={locked}
                onClick={() => onScenario(s.id)}
                className="scene-card text-left"
                style={{ background: locked ? '#F5F5F5' : '#fff' }}
                ref={el => { if (cardRefs.current[i]) cardRefs.current[i][0] = el; else cardRefs.current[i] = [el]; }}
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
                  <span className="text-xs font-bold" style={{ color: locked ? '#bbb' : '#0D9488' }}>
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
  const [userTranscription, setUserTranscription] = useState<string>();
  const [loading, setLoading] = useState(false);
  const [history, setHistory] = useState<Msg[]>([]);
  const [showHistory, setShowHistory] = useState(false);
  const [session, setSession] = useState<string>();
  const [bubbleKey, setBubbleKey] = useState(0);
  const [audioSource, setAudioSource] = useState<string>();
  const replyAudio = useRef<HTMLAudioElement | null>(null);
  const hasSubmitted = useRef(false);

  // Pissarra lateral amb els objectius: què ha de dir o demanar la persona.
  // S'obri per defecte en pantalles amples; en mòbils es pot mostrar amb el botó.
  const [showGoals, setShowGoals] = useState(() => typeof window === 'undefined' || window.innerWidth >= 900);
  const [goalsInfo, setGoalsInfo] = useState<{ character: string; objectius: string[] }>(() => scenarioGoals[scenario]);

  const loadTextAudio = async (text: string) => {
    try {
      const response = await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/tts`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ text, scenario }),
      });
      if (!response.ok) return;
      const payload = await response.json() as { audio_base64: string; mime_type: string };
      const source = `data:${payload.mime_type};base64,${payload.audio_base64}`;
      replyAudio.current = new Audio(source);
      setAudioSource(source);
    } catch {
      // Browser speech remains available from the replay button as a fallback.
    }
  };

  const replayCharacter = () => {
    const audio = replyAudio.current;
    if (audio) {
      audio.currentTime = 0;
      audio.play().catch(() => {
        speechSynthesis.speak(new SpeechSynthesisUtterance(character));
      });
      return;
    }
    speechSynthesis.speak(new SpeechSynthesisUtterance(character));
  };

  useEffect(() => {
    let cancelled = false;

    const loadGreetingAudio = async () => {
      try {
        const response = await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/greeting-audio?scenario=${scenario}`);
        if (!response.ok) return;
        const payload = await response.json() as { audio_base64: string; mime_type: string };
        if (!cancelled && !hasSubmitted.current) {
          const source = `data:${payload.mime_type};base64,${payload.audio_base64}`;
          replyAudio.current = new Audio(source);
          setAudioSource(source);
        }
      } catch {
        // The replay button falls back to the browser voice if TTS is unavailable.
      }
    };

    void loadGreetingAudio();
    return () => { cancelled = true; };
  }, []);

  // Carrega els objectius des del backend; si falla, es mostren els per defecte.
  useEffect(() => {
    let cancelled = false;
    void fetchScenarios()
      .then((data) => {
        if (!cancelled) {
          const found = data[scenario];
          if (found && Array.isArray(found.objectius) && found.objectius.length > 0) setGoalsInfo(found);
        }
      })
      .catch(() => {});
    return () => { cancelled = true; };
  }, [scenario]);

  const submit = async (text: string, audio?: string) => {
    if ((!text && !audio) || loading) return;
    hasSubmitted.current = true;
    replyAudio.current = null;
    setAudioSource(undefined);
    setUser(text || '🎙️ Missatge de veu');
    setUserTranscription(undefined);
    setBubbleKey(k => k + 1);
    setLoading(true);
    try {
      const activeSession = session || await createSession(scenario, level);
      if (!session) setSession(activeSession);
      // El personatge ha de recordar el que s'ha dit: li enviem el context de la
      // conversa actual (el primer missatge inclou el salut inicial del personatge).
      const context: HistoryItem[] = history.length > 0
        ? history.map((m) => ({ role: m.role, content_text: m.text }))
        : [{ role: 'character', content_text: character }];
      const r = await sendTurn({ session_id: activeSession, scenario, level, input_mode: audio ? 'voice' : 'text', text, audio_base64: audio || null, history: context });
      setCharacter(r.reply_text);
      setUserTranscription(r.transcription || undefined);
      setMood(r.mood);
      setXp(xp + r.xp_delta);
      setHistory(h => [...h, { role: 'user', text: text || '🎙️ Missatge de veu', transcription: r.transcription || undefined }, { role: 'character', text: r.reply_text }]);
      if (r.reply_audio_base64) {
        const mimeType = r.reply_audio_mime_type || 'audio/mpeg';
        const source = `data:${mimeType};base64,${r.reply_audio_base64}`;
        const a = new Audio(source);
        replyAudio.current = a;
        setAudioSource(source);
        a.play().catch(() => {});
      } else {
        replyAudio.current = null;
        setAudioSource(undefined);
      }
    } catch {
      const errorMessage = "No t'he sentit bé, pots repetir-ho?";
      setCharacter(errorMessage);
      setMood('confus');
      void loadTextAudio(errorMessage);
    } finally {
      setLoading(false);
    }
  };

  return (
    <main className="relative h-[100dvh] overflow-hidden">
      <SceneArt scenario={scenario} mood={mood} />

      {/* Top bar */}
      <header className="absolute inset-x-0 top-0 z-10 flex items-center justify-between p-4">
        <div className="flex items-center gap-3">
          <button
            onClick={onBack}
            id="chat-back-btn"
            className="btn-press rounded-full bg-white/90 px-4 py-2 font-bold shadow backdrop-blur-sm hover:bg-white transition-colors"
          >
            ← Eixir
          </button>
          <span
            className="rounded-full px-3.5 py-1.5 text-xs font-black tracking-wider uppercase shadow-md text-slate-800 border border-white/40 backdrop-blur-sm"
            style={{ background: 'rgba(255,255,255,0.92)' }}
          >
            {scenario === 'mercat' ? 'El Mercat' : scenario === 'bar' ? 'El Bar' : scenario === 'oficina' ? "L'Oficina" : scenario === 'ajuntament' ? "L'Ajuntament" : scenario === 'colegi' ? "L'Escola" : 'Oficina de Turisme'}
          </span>
        </div>
        <div
          className="absolute left-1/2 -translate-x-1/2 rounded-full px-4 py-2 text-sm font-black shadow backdrop-blur-sm"
          style={{ background: 'rgba(255,255,255,0.9)' }}
        >
          ⚡ {xp} XP
        </div>
        <div className="flex items-center gap-2">
          <button
            onClick={() => setShowGoals(!showGoals)}
            id="chat-goals-btn"
            aria-label={showGoals ? 'Amagar objectius' : 'Mostrar objectius'}
            title="Objectius"
            className={`btn-press grid h-10 w-10 place-items-center rounded-full bg-white/90 shadow backdrop-blur-sm hover:bg-white transition-colors ${showGoals ? 'text-teal' : 'text-slate-800'}`}
          >
            <ListTodo size={19} />
          </button>
          <button
            onClick={() => setShowHistory(true)}
            id="chat-history-btn"
            className="btn-press grid h-10 w-10 place-items-center rounded-full bg-white/90 shadow backdrop-blur-sm hover:bg-white transition-colors"
          >
            <MessageCircle size={19} />
          </button>
        </div>
      </header>

      {/* Character bubble with entrance animation */}
      <section key={`char-${bubbleKey}`} className="bubble-enter bubble absolute left-5 top-[13%] z-10 max-w-[min(76%,440px)] rounded-3xl bg-white p-5 font-bold shadow-xl text-base">
        <p className="leading-relaxed">
          {loading
            ? <span className="opacity-50">El personatge està escrivint…</span>
            : character
          }
        </p>
        {!loading && <>
          <button
            onClick={replayCharacter}
            className="btn-press mt-3 flex items-center gap-1 text-sm font-extrabold"
            style={{ color: '#0D9488' }}
          >
            <Volume2 size={15} /> Escolta de nou
          </button>
          {audioSource && (
            <audio
              controls
              preload="auto"
              src={audioSource}
              className="mt-2 h-9 w-full max-w-xs"
              aria-label="Àudio de la resposta"
            />
          )}
        </>}
      </section>

      {/* User bubble with entrance animation */}
      {user && (
        <div
          key={`user-${bubbleKey}`}
          className="user-bubble-enter user-bubble absolute bottom-36 right-5 z-10 max-w-[70%] rounded-3xl p-4 font-bold text-white shadow-lg"
          style={{ background: '#0D9488' }}
        >
          <p>{user}</p>
          {userTranscription && <p className="mt-2 border-t border-white/30 pt-2 text-sm font-normal">Transcripció: {userTranscription}</p>}
        </div>
      )}

      {/* Pissarra d'objectius (lateral dret) */}
      {showGoals && (
        <aside
          id="goals-board"
          className="goals-board goals-enter"
          aria-label="Objectius de la conversa"
        >
          <div className="goals-frame">
            <div className="goals-head">
              <b className="goals-title">📌 Objectius</b>
              <button
                onClick={() => setShowGoals(false)}
                id="goals-close-btn"
                aria-label="Amagar objectius"
                className="btn-press grid h-7 w-7 place-items-center rounded-full bg-white/10 hover:bg-white/20 transition-colors"
              >
                <X size={14} />
              </button>
            </div>
            <p className="goals-sub">
              Això és el que pots dir o demanar a {goalsInfo.character.split(',')[0]}:
            </p>
            <ul className="goals-list">
              {goalsInfo.objectius.map((goal, i) => (
                <li key={`${scenario}-${i}`} className="goals-item">
                  <span className="goals-num">{i + 1}</span>
                  <span>{goal}</span>
                </li>
              ))}
            </ul>
            <p className="goals-footer">✨ Practica en veu alta i diverteix-te!</p>
          </div>
        </aside>
      )}

      {/* Input */}
      <div className="absolute inset-x-4 bottom-5 z-20">
        <VoiceInput onSend={submit} disabled={loading} />
        <button
          onClick={onEnd}
          id="chat-end-btn"
          className="btn-press mx-auto mt-3 block rounded-full bg-white/80 px-4 py-2 text-xs font-extrabold backdrop-blur-sm hover:bg-white transition-colors"
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
    <main className="fade-up grid min-h-screen place-items-center p-5" style={{ background: '#FAFAF9' }}>
      <section className="w-full max-w-lg rounded-[40px] bg-white p-8 text-center shadow-xl">
        <div
          className="mx-auto grid h-20 w-20 place-items-center rounded-full text-4xl"
          style={{ background: '#FFE5B4' }}
        >
          🎉
        </div>
        <h1 className="mt-5 text-3xl font-black">Molt bé!</h1>
        <p className="mt-2 opacity-60">Has practicat valencià en una situació real.</p>

        {/* XP gained */}
        <div
          className="mt-7 rounded-3xl p-5"
          style={{ background: 'linear-gradient(135deg, #FFF7ED, #FFEDD5)' }}
        >
          <b className="text-4xl font-black" style={{ color: '#F97316' }}>+10 XP</b>
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
          className="btn-press mt-7 w-full rounded-2xl py-3 font-extrabold text-white transition hover:opacity-90"
          style={{ background: 'linear-gradient(135deg, #0D9488, #0F766E)' }}
        >
          Continuar
        </button>
        <button
          onClick={onMap}
          id="summary-map-btn"
          className="btn-press mt-3 font-bold"
          style={{ color: '#0D9488' }}
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
    <main className="fade-up" style={{ background: '#FAFAF9', minHeight: '100vh' }}>
      <OrangeHeader showOranges={false}>
        <div className="px-5 pb-2">
          <button
            onClick={back}
            className="btn-press font-bold text-sm"
            style={{ color: '#0D9488' }}
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
              className="mt-1 w-full rounded-2xl border-2 border-gray-100 p-3 font-normal outline-none focus:border-[#0D9488] transition-colors"
            />
          </label>
          <label className="block font-extrabold text-sm">
            Nivell
            <select
              value={level}
              onChange={e => setLevel(e.target.value)}
              id="profile-level"
              className="mt-1 w-full rounded-2xl border-2 border-gray-100 bg-white p-3 font-normal outline-none focus:border-[#0D9488] transition-colors"
            >
              <option value="principiant">Principiant</option>
              <option value="intermedi">Intermedi</option>
              <option value="avancat">Avançat</option>
            </select>
          </label>
        </div>

        <div className="mt-5 grid grid-cols-2 gap-3">
          <Stat icon="⚡" label="XP total" value={String(xp)} />
          <Stat icon="🗺️" label="Escenaris" value="1 / 6" />
          <Stat icon="💬" label="Paraules" value="24" />
          <Stat icon="🏆" label="Insígnies" value="1" />
        </div>

        <div className="mt-8 flex flex-col gap-3">
          <button
            onClick={() => confirm('Vols reiniciar el teu progrés?') && location.reload()}
            id="profile-reset-btn"
            className="btn-press flex items-center justify-center gap-2 rounded-2xl border-2 border-coral/20 bg-coral/5 py-3 text-sm font-extrabold text-coral hover:bg-coral/10 transition-colors"
          >
            <RotateCcw size={16} /> Reinicia el progrés
          </button>

          {!isDemo && (
            <button
              onClick={() => confirm('Segur que vols tancar la sessió?') && onLogOut()}
              id="profile-logout-btn"
              className="btn-press flex items-center justify-center gap-2 rounded-2xl border-2 border-gray-200 bg-white py-3 text-sm font-extrabold text-gray-500 hover:bg-gray-50 hover:text-gray-700 transition-colors"
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

  if (page === 'home')      return <PageTransition><HomePage setPage={setPage} /></PageTransition>;
  if (page === 'auth')      return <PageTransition><AuthPage setPage={setPage} /></PageTransition>;
  if (page === 'dashboard') return <PageTransition><Dashboard name={name} xp={xp} setPage={setPage} onScenario={s => { setScenario(s); setPage('chat'); }} /></PageTransition>;
  if (page === 'profile') {
    return (
      <PageTransition>
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
      </PageTransition>
    );
  }
  if (page === 'summary')   return <PageTransition><Summary xp={xp} onMap={() => setPage('dashboard')} onContinue={() => setPage('chat')} /></PageTransition>;
  return (
    <PageTransition>
      <Chat
        scenario={scenario}
        level={level}
        xp={xp}
        setXp={setXp}
        onEnd={() => setPage('summary')}
        onBack={() => setPage('dashboard')}
      />
    </PageTransition>
  );
}
