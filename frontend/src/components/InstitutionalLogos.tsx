/* ══════════════════ LOGOS INSTITUCIONALS ════════════════════════════
   Atribució de les entitats que donen suport al projecte. Els fitxers
   són estàtics a frontend/public/logos/ i Vite els copia al build.
   El logo de la Generalitat no és transparent (fons blanc), per això la
   banda té fons blanc i una vora superior per separar-se del #FAFAF9. */

const INSTITUCIONS = [
  { name: 'Generalitat Valenciana', src: '/logos/generalitat-valenciana.png', href: 'https://www.gva.es', height: 'h-10' },
  { name: 'ValgrAI', src: '/logos/valgrai.png', href: 'https://valgrai.eu', height: 'h-9' },
  { name: 'Universitat Jaume I', src: '/logos/universitat-jaume-i.png', href: 'https://www.uji.es', height: 'h-7' },
];

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
