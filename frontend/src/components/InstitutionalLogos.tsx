/* ══════════════════ LOGOS INSTITUCIONALS ════════════════════════════
   Atribució de les entitats que donen suport al projecte. Els fitxers
   són estàtics a frontend/public/logos/ i Vite els copia al build.
   El logo de la Generalitat no és transparent (fons blanc), per això la
   banda té fons blanc i una vora superior per separar-se del #FAFAF9. */

const INSTITUCIONS = [
  { name: 'Generalitat Valenciana', src: '/logos/generalitat-valenciana.png', href: 'https://www.gva.es', height: 'h-10', bar: 'h-9 sm:h-12' },
  { name: 'ValgrAI', src: '/logos/valgrai.png', href: 'https://valgrai.eu', height: 'h-9', bar: 'h-8 sm:h-10' },
  { name: 'Universitat Jaume I', src: '/logos/universitat-jaume-i.png', href: 'https://www.uji.es', height: 'h-7', bar: 'h-6 sm:h-8' },
];

/* ── Barra institucional compacta ────────────────────────────────── */
// Fixa al peu de totes les pantalles (menys la d'inici, que té el peu complet). L'alçada és
// --app-footer (styles.css): el cos de la pàgina hi reserva espai perquè no tape res.
export function InstitutionalBar() {
  return (
    <footer
      className="fixed inset-x-0 bottom-0 z-40 flex items-center justify-center gap-x-4 border-t border-[#E7E5E4] bg-white px-3 sm:gap-x-7"
      style={{ height: 'var(--app-footer)' }}
      aria-label="Entitats que donen suport"
    >
      <span className="hidden text-sm font-extrabold uppercase tracking-wider opacity-45 sm:inline">Amb el suport de</span>
      <ul className="flex items-center gap-x-4 sm:gap-x-7">
        {INSTITUCIONS.map(({ name, src, bar }) => (
          <li key={name}>
            <img src={src} alt={name} loading="lazy" decoding="async" className={`${bar} w-auto`} />
          </li>
        ))}
      </ul>
    </footer>
  );
}

/* ── Peu institucional ───────────────────────────────────────────── */
export function InstitutionalLogos({ className = '' }: { className?: string }) {
  return (
    <footer
      className={`border-t border-[#E7E5E4] bg-white px-6 py-6 ${className}`}
      aria-label="Entitats que donen suport"
    >
      <p className="text-center text-[11px] font-extrabold uppercase tracking-wider opacity-45">
        Amb el suport de
      </p>
      <ul className="mt-4 flex flex-wrap items-center justify-center gap-x-9 gap-y-5">
        {INSTITUCIONS.map(({ name, src, href, height }) => (
          <li key={name}>
            <a
              href={href}
              target="_blank"
              rel="noreferrer"
              title={name}
              className="block opacity-90 transition-opacity hover:opacity-100"
            >
              <img
                src={src}
                alt={name}
                loading="lazy"
                decoding="async"
                className={`${height} w-auto`}
              />
            </a>
          </li>
        ))}
      </ul>
    </footer>
  );
}
