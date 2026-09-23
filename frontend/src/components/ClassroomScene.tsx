/**
 * Decorative classroom scene (wall, window + sun, blackboard, teacher's desk,
 * student desks) rendered as a dimmed, pointer-events-none watermark behind
 * the dashboard and the scenario-select page. Inline SVG keeps it asset-free.
 */
export function ClassroomScene({ opacity = 0.2 }: { opacity?: number }) {
  return (
    <svg
      viewBox="0 0 400 560"
      className="absolute inset-0 h-full w-full object-cover select-none"
      style={{ opacity, pointerEvents: 'none' }}
      xmlns="http://www.w3.org/2000/svg"
      preserveAspectRatio="xMidYMid slice"
      aria-hidden="true"
    >
      {/* Wall */}
      <rect width="400" height="560" fill="#FFF3DE" />

      {/* Sun + window (top-left) */}
      <g opacity="0.28">
        <circle cx="50" cy="80" r="56" fill="#FFC857" />
        <circle cx="50" cy="80" r="90" fill="#FFC857" opacity="0.45" />
      </g>
      <rect x="30" y="58" width="56" height="76" rx="10" fill="#A8D8EA" stroke="#7FB3D5" strokeWidth="2" />
      <line x1="58" y1="58" x2="58" y2="134" stroke="#7FB3D5" strokeWidth="1.5" />
      <line x1="30" y1="96" x2="86" y2="96" stroke="#7FB3D5" strokeWidth="1.5" />

      {/* Blackboard */}
      <rect x="60" y="170" width="280" height="160" rx="14" fill="#2F5D50" stroke="#1e3d32" strokeWidth="3" />
      <rect x="70" y="178" width="260" height="8" fill="#FFF7E0" rx="2" opacity="0.15" />
      <text x="200" y="218" textAnchor="middle" fill="#FFF7E0" fontSize="26" fontWeight="900">Parla Val</text>
      <text x="200" y="250" textAnchor="middle" fill="#FFD166" fontSize="13" fontWeight="700">a b c · objectius</text>
      <rect x="290" y="300" width="20" height="6" fill="#FFF7E0" rx="2" />
      <circle cx="90" cy="230" r="2" fill="#FFF7E0" />
      <circle cx="310" cy="215" r="1.5" fill="#FFF7E0" />

      {/* Teacher desk */}
      <rect x="108" y="362" width="184" height="36" rx="8" fill="#8B5A2B" stroke="#4A2F1D" strokeWidth="1" />
      <rect x="140" y="336" width="26" height="26" rx="4" fill="#5C3D2E" />
      <circle cx="153" cy="346" r="4" fill="#E63946" />

      {/* Student desks facing the board */}
      <rect x="68" y="424" width="72" height="40" rx="6" fill="#D8B192" stroke="#BD9473" strokeWidth="1" />
      <rect x="150" y="436" width="100" height="32" rx="6" fill="#D8B192" stroke="#BD9473" strokeWidth="1" />
      <rect x="260" y="424" width="72" height="40" rx="6" fill="#D8B192" stroke="#BD9473" strokeWidth="1" />
      <ellipse cx="186" cy="470" rx="92" ry="4" fill="#000" opacity="0.06" />
    </svg>
  );
}
