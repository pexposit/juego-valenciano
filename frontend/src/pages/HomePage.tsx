import { useEffect, useState } from 'react';
import { ChevronRight } from 'lucide-react';
import { InstitutionalLogos } from '../components/InstitutionalLogos';
import { Logo } from '../components/ui';
import { HOME_IMAGES, type Page } from '../data/content';

const CAROUSEL_INTERVAL_MS = 5000;

export function HomePage({ setPage }: { setPage: (p: Page) => void }) {
  const [activeImage, setActiveImage] = useState(0);

  useEffect(() => {
    const timer = window.setInterval(() => {
      setActiveImage(current => (current + 1) % HOME_IMAGES.length);
    }, CAROUSEL_INTERVAL_MS);
    return () => window.clearInterval(timer);
  }, []);

  const image = HOME_IMAGES[activeImage];

  return (
    <main className="fade-up min-h-screen flex flex-col">
      {/* Nav */}
      <nav className="flex items-center justify-between px-6 py-4">
        <Logo />
        <button
          onClick={() => setPage('auth')}
          className="btn-press rounded-full border-2 border-[#0F47AF] px-4 py-1.5 text-sm font-extrabold text-[#0F47AF] hover:bg-[#0F47AF] hover:text-white transition-colors"
        >
          Entra
        </button>
      </nav>

      {/* Hero */}
      <section className="mx-auto grid max-w-6xl flex-1 items-center gap-10 px-6 pb-16 pt-6 md:grid-cols-2 md:pt-16">
        <div className="hero-stagger">
          <span
            className="inline-flex items-center gap-2 rounded-full px-4 py-2 text-sm font-extrabold"
            style={{ background: 'rgba(252,221,9,0.28)', color: '#8A6D00' }}
          >
            ✨ Valencià per a la vida real
          </span>
          <h1 className="mt-5 text-5xl font-black leading-[1.08] sm:text-6xl">
            Parla valencià.<br />
            <em className="not-italic" style={{ color: '#FF3B3B' }}>Viu-lo.</em>
          </h1>
          <p className="mt-4 max-w-md text-lg leading-relaxed opacity-65">
            Practica converses reals, al teu ritme, amb personatges que t'acompanyen cada dia pels carrers de València.
          </p>
          <button
            onClick={() => setPage('auth')}
            id="hero-cta"
            className="btn-press mt-8 inline-flex items-center gap-2 rounded-2xl px-7 py-4 text-lg font-extrabold text-white shadow-lg transition hover:scale-[1.03] hover:shadow-xl active:scale-[0.98]"
            style={{ background: 'linear-gradient(135deg, #FF3B3B, #FF6B6B)' }}
          >
            Comença ara <ChevronRight size={20} />
          </button>
          <p className="mt-4 text-sm opacity-50">🍊 Mercat · Bar · Oficina · Ajuntament · Escola · Turisme</p>
        </div>

        {/* Hero image carousel — Comunitat Valenciana */}
        <div className="relative h-[400px] overflow-hidden rounded-[44px] shadow-2xl">
          {HOME_IMAGES.map((item, index) => (
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
            {HOME_IMAGES.map((item, index) => (
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

      {/* Entitats que donen suport al projecte */}
      <InstitutionalLogos />

      {/* Footer strip */}
      <div
        className="py-6 text-center text-white font-black text-lg"
        style={{ background: 'linear-gradient(90deg, #0F47AF, #0B3785)' }}
      >
        Aprén parlant, no memoritzant.
      </div>
    </main>
  );
}
