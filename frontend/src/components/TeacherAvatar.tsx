/**
 * Animated teacher avatar used as a friendly guide on the classroom dashboard.
 * Idle "bob" (gentle breathing) on the outer group + a subtle chalk-hand wave
 * on the right arm give the scene life without distracting the learner.
 * SVG-only => no extra image assets.
 */
export function TeacherAvatar({ className = '', size = 64 }: { className?: string; size?: number }) {
  return (
    <svg
      viewBox="0 0 100 120"
      width={size}
      height={size}
      className={className}
      xmlns="http://www.w3.org/2000/svg"
      role="img"
      aria-label="Avatar de la professora"
    >
      {/* Idle breathing on the whole figure */}
      <g className="teacher-bob">
        {/* Drop shadow */}
        <ellipse cx="50" cy="118" rx="14" ry="4" fill="#000" opacity="0.12" />
        {/* Shoulders / teacher shirt (teal) */}
        <path
          d="M22,70 C14,76 12,90 20,100 C30,114 70,114 80,100 C88,90 86,76 78,70 C78,68 22,68 22,70 Z"
          fill="#0D9488"
        />
        {/* Neck */}
        <rect x="42" y="62" width="16" height="10" rx="3" fill="#F5D9C9" />
        {/* Head */}
        <circle cx="50" cy="54" r="20" fill="#F5D9C9" />
        {/* Hair — bob cut */}
        <path d="M32,44 C28,50 28,58 34,62 C40,58 40,50 36,44 C34,38 28,38 32,44 Z" fill="#5D4A3A" />
        <path d="M68,44 C72,50 72,58 66,62 C60,58 60,50 64,44 C62,38 68,38 68,44 Z" fill="#5D4A3A" />
        <path d="M34,34 C40,30 48,32 50,38 C52,32 60,30 66,34" fill="#5D4A3A" />
        {/* Face */}
        <circle cx="42" cy="52" r="3" fill="#263747" />
        <circle cx="58" cy="52" r="3" fill="#263747" />
        <path d="M44,62 C46,64 54,64 56,62" stroke="#263747" strokeWidth="2" fill="none" strokeLinecap="round" />
        {/* Left arm (resting) */}
        <path d="M22,76 C18,86 16,96 22,104" stroke="#0D9488" strokeWidth="6" fill="none" strokeLinecap="round" />
        {/* Right arm + chalk — the animated hand group (swings from the right shoulder) */}
        <g className="teacher-wave" style={{ transformOrigin: '78px 78px' }}>
          <path d="M78,78 C84,82 86,92 78,98" stroke="#0D9488" strokeWidth="6" fill="none" strokeLinecap="round" />
          <path d="M76,98 L82,104 L86,100" stroke="#263747" strokeWidth="4" strokeLinecap="round" />
          {/* Chalk in hand */}
          <rect x="82" y="98" width="14" height="4" rx="2" fill="#FFE74C" />
          <rect x="86" y="98" width="6" height="4" fill="#FFE74C" />
        </g>
      </g>
    </svg>
  );
}
