import type { Mood, Scenario } from '../lib/types';

const moodFace = (mood: Mood, part: 'eyes' | 'eyebrows' | 'mouth') => {
  if (part === 'eyebrows') {
    if (mood === 'confus') {
      return (
        <>
          <path d="M 175 202 Q 185 197 195 204" fill="none" stroke="#263747" strokeWidth="3" strokeLinecap="round" className="eyebrow-subtle" />
          <path d="M 205 204 Q 215 206 225 198" fill="none" stroke="#263747" strokeWidth="3" strokeLinecap="round" className="eyebrow-subtle" />
        </>
      );
    }
    return (
      <>
        <path d="M 175 198 Q 185 194 195 199" fill="none" stroke="#263747" strokeWidth="3" strokeLinecap="round" className="eyebrow-subtle" />
        <path d="M 205 199 Q 215 194 225 198" fill="none" stroke="#263747" strokeWidth="3" strokeLinecap="round" className="eyebrow-subtle" />
      </>
    );
  }

  if (part === 'mouth') {
    if (mood === 'content') {
      return <path d="M 190 238 Q 200 254 210 238" fill="none" stroke="#263747" strokeWidth="4.5" strokeLinecap="round" />;
    }
    if (mood === 'confus') {
      return <path d="M 193 243 Q 200 238 207 243" fill="none" stroke="#263747" strokeWidth="3.5" strokeLinecap="round" />;
    }
    return <path d="M 192 241 Q 200 246 208 241" fill="none" stroke="#263747" strokeWidth="3.5" strokeLinecap="round" />;
  }

  return null;
};

export function SceneArt({ scenario, mood }: { scenario: Scenario; mood: Mood }) {
  return (
    <div className="absolute inset-0 overflow-hidden bg-[#FFF9ED]">
      <svg
        viewBox="0 0 400 550"
        className="h-full w-full object-cover select-none"
        xmlns="http://www.w3.org/2000/svg"
        preserveAspectRatio="xMidYMid slice"
      >
        <defs>
          <linearGradient id="skyGrad" x1="0" y1="0" x2="0" y2="1">
            <stop offset="0%" stopColor="#FFF2D4" />
            <stop offset="100%" stopColor="#FFE09E" />
          </linearGradient>
          <linearGradient id="woodGrad" x1="0" y1="0" x2="1" y2="0">
            <stop offset="0%" stopColor="#A0633C" />
            <stop offset="50%" stopColor="#BD8458" />
            <stop offset="100%" stopColor="#A0633C" />
          </linearGradient>
          <linearGradient id="darkWoodGrad" x1="0" y1="0" x2="1" y2="0">
            <stop offset="0%" stopColor="#4A2F1D" />
            <stop offset="50%" stopColor="#69442C" />
            <stop offset="100%" stopColor="#4A2F1D" />
          </linearGradient>
          <linearGradient id="stoneGrad" x1="0" y1="0" x2="0" y2="1">
            <stop offset="0%" stopColor="#EAE4D8" />
            <stop offset="100%" stopColor="#CEBFA8" />
          </linearGradient>
          <linearGradient id="flagGrad" x1="0" y1="0" x2="1" y2="0">
            <stop offset="0%" stopColor="#FFD166" />
            <stop offset="100%" stopColor="#FFB03B" />
          </linearGradient>
        </defs>

        {/* ══════════════════ 1. SCENARIO BACKGROUNDS ══════════════════ */}

        {/* --- EL MERCAT --- */}
        {scenario === 'mercat' && (
          <>
            {/* Sky */}
            <rect width="400" height="550" fill="url(#skyGrad)" />
            {/* Sun */}
            <circle cx="340" cy="80" r="28" fill="#FFC857" opacity="0.9" />
            <circle cx="340" cy="80" r="45" fill="#FFC857" opacity="0.25" className="animate-ping" style={{ animationDuration: '3s' }} />

            {/* Tree leaves hanging */}
            <g className="sway" style={{ transformOrigin: '20px 20px', animationDuration: '7s' }}>
              <path d="M 0 0 C 50 15, 100 45, 130 90 C 90 90, 50 60, 0 0" fill="#77B255" />
              <path d="M 20 0 C 70 10, 110 30, 140 50 C 110 60, 60 40, 20 0" fill="#5B933E" />
              <circle cx="75" cy="50" r="10" fill="#FF9F1C" />
              <circle cx="110" cy="65" r="8" fill="#FF9F1C" />
            </g>

            {/* Market awning roof arches */}
            <path d="M 0 110 Q 200 60 400 110" fill="none" stroke="#4A5862" strokeWidth="6" opacity="0.3" />

            {/* Stripe Awning */}
            <path d="M 10 50 L 390 50 L 370 115 L 30 115 Z" fill="#77B255" />
            <path d="M 55 50 L 95 50 L 85 115 L 45 115 Z" fill="#FFF" opacity="0.85" />
            <path d="M 135 50 L 175 50 L 165 115 L 125 115 Z" fill="#FFF" opacity="0.85" />
            <path d="M 225 50 L 265 50 L 255 115 L 215 115 Z" fill="#FFF" opacity="0.85" />
            <path d="M 305 50 L 345 50 L 335 115 L 295 115 Z" fill="#FFF" opacity="0.85" />
            {/* Awning frills */}
            <path d="M 30 115 Q 50 130 70 115 Q 90 130 110 115 Q 130 130 150 115 Q 170 130 190 115 Q 210 130 230 115 Q 250 130 270 115 Q 290 130 310 115 Q 330 130 350 115 Q 370 130 390 115" fill="none" stroke="#77B255" strokeWidth="14" strokeLinecap="round" />

              {/* CHARACTER: Vicent (The Orange Vendor) */}
              <g className="float mood-transition" style={{ animationDuration: '3.6s' }} key={`mercat-${mood}`}>
              {/* Body */}
              <path d="M 135 390 Q 200 120 265 390 Z" fill="#F0ECE1" />
              {/* Green Apron */}
              <path d="M 160 320 L 240 320 L 252 405 L 148 405 Z" fill="#3D7A34" />
              <path d="M 175 275 L 175 320 M 225 275 L 225 320" stroke="#263747" strokeWidth="4" />
              {/* Neck */}
              <rect x="187" y="244" width="26" height="20" fill="#F8C9A1" rx="4" />
              {/* Head */}
              <circle cx="200" cy="215" r="38" fill="#F8C9A1" />
              {/* Hair */}
              <path d="M 162 215 C 162 158, 238 158, 238 215 C 230 193, 170 193, 162 215" fill="#423124" />
              {/* Valencian headband (mocador) */}
              <path d="M 160 192 Q 200 178 240 192 L 242 201 Q 200 187 158 201 Z" fill="#E63946" />
              <path d="M 160 192 L 152 205 L 163 208 Z" fill="#E63946" /> {/* knot */}

              {/* Eyes */}
              <g className="gaze">
                <g className="blink-eyes">
                  <circle cx="186" cy="208" r="4.5" fill="#263747" />
                  <circle cx="214" cy="208" r="4.5" fill="#263747" />
                </g>
              </g>

              {/* Eyebrows & Mouth */}
              {moodFace(mood, 'eyebrows')}
              {moodFace(mood, 'mouth')}

              {/* Mustache */}
              <path d="M 186 229 Q 200 229 200 233 Q 200 229 214 229 Q 220 236 210 236 Q 200 236 200 233 Q 200 236 190 236 Q 180 236 186 229 Z" fill="#423124" />
              {/* Blush */}
              <circle cx="172" cy="218" r="4.5" fill="#FF8A8A" opacity="0.45" />
              <circle cx="228" cy="218" r="4.5" fill="#FF8A8A" opacity="0.45" />

              {/* Arm waving holding orange */}
              <path d="M 135 340 Q 110 300 110 270" fill="none" stroke="#F8C9A1" strokeWidth="15" strokeLinecap="round" className="sway" style={{ transformOrigin: '135px 340px' }} />
              <circle cx="110" cy="262" r="10" fill="#FF9F1C" className="sway" style={{ transformOrigin: '135px 340px' }} />
            </g>

            {/* Counter */}
            <rect x="0" y="380" width="400" height="170" fill="url(#woodGrad)" />
            <rect x="0" y="380" width="400" height="15" fill="#844E2E" />

            {/* Crates of fruits */}
            <g transform="translate(20, 362)">
              <rect x="0" y="20" width="100" height="38" fill="#DDBB99" rx="2" stroke="#B08A68" strokeWidth="2" />
              <circle cx="18" cy="18" r="11" fill="#FF9F1C" />
              <circle cx="42" cy="14" r="11" fill="#FF9F1C" />
              <circle cx="66" cy="16" r="11" fill="#FF9F1C" />
              <circle cx="84" cy="18" r="11" fill="#FF9F1C" />
              <circle cx="30" cy="6" r="11" fill="#FF9F1C" />
              <circle cx="54" cy="4" r="11" fill="#FF9F1C" />
              <circle cx="76" cy="6" r="11" fill="#FF9F1C" />
              <line x1="0" y1="32" x2="100" y2="32" stroke="#B08A68" strokeWidth="2" />
              <text x="50" y="44" fill="#5A3F2C" fontSize="8" fontWeight="900" textAnchor="middle">TARONGES</text>
            </g>

            <g transform="translate(280, 362)">
              <rect x="0" y="20" width="100" height="38" fill="#DDBB99" rx="2" stroke="#B08A68" strokeWidth="2" />
              <circle cx="18" cy="18" r="10" fill="#E63946" />
              <circle cx="42" cy="14" r="10" fill="#E63946" />
              <circle cx="66" cy="16" r="10" fill="#E63946" />
              <circle cx="84" cy="18" r="10" fill="#E63946" />
              <circle cx="30" cy="6" r="10" fill="#E63946" />
              <circle cx="54" cy="4" r="10" fill="#E63946" />
              <circle cx="76" cy="6" r="10" fill="#E63946" />
              <line x1="0" y1="32" x2="100" y2="32" stroke="#B08A68" strokeWidth="2" />
              <text x="50" y="44" fill="#5A3F2C" fontSize="8" fontWeight="900" textAnchor="middle">TOMATES</text>
            </g>
          </>
        )}

        {/* --- EL BAR --- */}
        {scenario === 'bar' && (
          <>
            {/* Background Arch */}
            <rect width="400" height="550" fill="#9C4C38" />
            <path d="M -40 550 L -40 220 Q 200 40 440 220 L 440 550 Z" fill="#823F2E" />

            {/* Cozy Shelves */}
            <rect x="30" y="110" width="120" height="8" fill="#6D3325" />
            <rect x="50" y="80" width="20" height="30" fill="#E9D8A6" rx="2" opacity="0.7" />
            <rect x="90" y="70" width="25" height="40" fill="#94D2BD" rx="2" opacity="0.6" />

            {/* CAFÈ sign */}
            <g transform="translate(240, 90) rotate(-2)">
              <rect x="0" y="0" width="130" height="42" fill="#E9D8A6" rx="6" stroke="#263747" strokeWidth="3" />
              <text x="65" y="27" fill="#263747" fontSize="13" fontWeight="900" textAnchor="middle">CAFÈ PARLAVAL</text>
            </g>

            {/* CHARACTER: Maria (The Barista) */}
            <g className="float mood-transition" style={{ animationDuration: '3.8s' }} key={`bar-${mood}`}>
              <path d="M 135 390 Q 200 120 265 390 Z" fill="#3D3D3D" />
              {/* Red Apron */}
              <path d="M 160 320 L 240 320 L 252 405 L 148 405 Z" fill="#B23A22" />
              <path d="M 180 270 L 180 320 M 220 270 L 220 320" stroke="#FFF" strokeWidth="3.5" />
              {/* Neck */}
              <rect x="187" y="244" width="26" height="20" fill="#F4D3B5" rx="4" />
              {/* Head */}
              <circle cx="200" cy="215" r="38" fill="#F4D3B5" />
              {/* Hair (Black bun with flower) */}
              <path d="M 162 215 C 162 158, 238 158, 238 215 C 230 195, 170 195, 162 215" fill="#1A1510" />
              <circle cx="230" cy="180" r="12" fill="#1A1510" /> {/* Bun */}
              <path d="M 235 178 L 241 173 M 238 184 L 245 186" stroke="#FFF" strokeWidth="4" strokeLinecap="round" /> {/* flower decoration */}

              {/* Eyes */}
              <g className="gaze">
                <g className="blink-eyes">
                  <circle cx="186" cy="210" r="4" fill="#263747" />
                  <circle cx="214" cy="210" r="4" fill="#263747" />
                </g>
              </g>

              {/* Eyebrows & Mouth */}
              {moodFace(mood, 'eyebrows')}
              {moodFace(mood, 'mouth')}

              {/* Blush */}
              <circle cx="172" cy="220" r="4.5" fill="#FF9E9E" opacity="0.5" />
              <circle cx="228" cy="220" r="4.5" fill="#FF9E9E" opacity="0.5" />

              {/* Arm carrying coffee tray */}
              <path d="M 255 330 Q 285 300 275 270" fill="none" stroke="#F4D3B5" strokeWidth="14" strokeLinecap="round" className="sway" style={{ transformOrigin: '255px 330px' }} />
              <ellipse cx="275" cy="265" rx="20" ry="6" fill="#A8A8A8" className="sway" style={{ transformOrigin: '255px 330px' }} />
              <rect x="268" y="248" width="14" height="15" fill="#3D7A34" rx="2" className="sway" style={{ transformOrigin: '255px 330px' }} /> {/* green cup */}
            </g>

            {/* Counter */}
            <rect x="0" y="380" width="400" height="170" fill="url(#darkWoodGrad)" />
            <rect x="0" y="380" width="400" height="15" fill="#362013" />

            {/* Espresso machine */}
            <g transform="translate(15, 305)">
              <rect x="0" y="10" width="90" height="65" fill="#D0D4D9" rx="3" stroke="#8C939D" strokeWidth="2.5" />
              <rect x="15" y="45" width="22" height="30" fill="#EAEAEA" />
              <rect x="52" y="45" width="22" height="30" fill="#EAEAEA" />
              {/* steam particles */}
              <circle cx="26" cy="-2" r="3" fill="#FFF" opacity="0" className="steam-particle" />
              <circle cx="24" cy="-5" r="4.5" fill="#FFF" opacity="0" className="steam-particle" style={{ animationDelay: '0.6s' }} />
              <circle cx="28" cy="-8" r="4" fill="#FFF" opacity="0" className="steam-particle" style={{ animationDelay: '1.2s' }} />
              <circle cx="63" cy="-4" r="3.5" fill="#FFF" opacity="0" className="steam-particle" style={{ animationDelay: '0.3s' }} />
              <circle cx="60" cy="-6" r="4" fill="#FFF" opacity="0" className="steam-particle" style={{ animationDelay: '0.9s' }} />
            </g>

            {/* Plate and coffee cup on counter */}
            <g transform="translate(145, 360)">
              <ellipse cx="25" cy="20" rx="25" ry="7" fill="#E9D8A6" stroke="#263747" strokeWidth="2" />
              <path d="M 12 8 C 12 -2, 38 -2, 38 8 Z" fill="#94D2BD" stroke="#263747" strokeWidth="2" />
              <path d="M 38 4 Q 45 4 43 10 Q 38 12 38 8" fill="none" stroke="#263747" strokeWidth="2" /> {/* Handle */}
              {/* Steam */}
              <path d="M 22 -6 Q 25 -14 21 -20" fill="none" stroke="#FFF" strokeWidth="2" strokeLinecap="round" className="steam-particle" />
              <path d="M 27 -6 Q 29 -12 28 -18" fill="none" stroke="#FFF" strokeWidth="1.5" strokeLinecap="round" className="steam-particle" style={{ animationDelay: '0.8s' }} />
            </g>
          </>
        )}

        {/* --- L'OFICINA --- */}
        {scenario === 'oficina' && (
          <>
            {/* Office wall */}
            <rect width="400" height="550" fill="#CEECEF" />

            {/* Large Window */}
            <rect x="75" y="45" width="250" height="260" fill="#E9F7F8" stroke="#A8DADE" strokeWidth="6" />
            {/* Window panes grid */}
            <line x1="200" y1="45" x2="200" y2="305" stroke="#A8DADE" strokeWidth="4" />
            <line x1="75" y1="175" x2="325" y2="175" stroke="#A8DADE" strokeWidth="4" />
            {/* Valencia distant roofs & Micalet tower silhouette outside window */}
            <path d="M 175 305 L 175 250 Q 185 240 185 220 L 190 220 L 190 240 L 195 245 L 195 305 Z" fill="#D8B192" opacity="0.65" />
            <path d="M 80 305 L 110 275 L 140 305 Z" fill="#E08E79" opacity="0.65" />
            <path d="M 240 305 L 275 265 L 310 305 Z" fill="#E08E79" opacity="0.65" />

            {/* Office plant */}
            <g className="sway" style={{ transformOrigin: '40px 330px', animationDuration: '6.5s' }}>
              {/* Plant pot */}
              <rect x="25" y="310" width="30" height="35" fill="#E08E79" rx="3" />
              <path d="M 40 310 Q 5 270 12 245 Q 25 240 40 310" fill="#2A9D8F" />
              <path d="M 40 310 Q 75 265 65 240 Q 50 240 40 310" fill="#2A9D8F" />
              <path d="M 40 310 Q 40 250 40 230 Q 30 245 40 310" fill="#264653" />
            </g>

            {/* CHARACTER: Joan (The Coworker) */}
            <g className="float mood-transition" style={{ animationDuration: '3.4s' }} key={`oficina-${mood}`}>
              <path d="M 135 390 Q 200 120 265 390 Z" fill="#457B9D" />
              <rect x="195" y="295" width="10" height="25" fill="#FFF" /> {/* Tie */}
              <path d="M 190 320 L 200 345 L 210 320 Z" fill="#E63946" />
              {/* Neck */}
              <rect x="187" y="244" width="26" height="20" fill="#F5D3B5" rx="4" />
              {/* Head */}
              <circle cx="200" cy="215" r="38" fill="#F5D3B5" />
              {/* Hair */}
              <path d="M 162 212 C 162 158, 238 158, 238 212 C 238 185, 162 185, 162 212" fill="#5C3D2E" />

              {/* Eyes */}
              <g className="gaze">
                <g className="blink-eyes">
                  <circle cx="186" cy="210" r="4.5" fill="#263747" />
                  <circle cx="214" cy="210" r="4.5" fill="#263747" />
                </g>
              </g>

              {/* Stylish glasses */}
              <circle cx="186" cy="210" r="11" fill="none" stroke="#E63946" strokeWidth="2.5" />
              <circle cx="214" cy="210" r="11" fill="none" stroke="#E63946" strokeWidth="2.5" />
              <line x1="197" y1="210" x2="203" y2="210" stroke="#E63946" strokeWidth="2.5" />

              {/* Eyebrows & Mouth */}
              {moodFace(mood, 'eyebrows')}
              {moodFace(mood, 'mouth')}

              {/* Blush */}
              <circle cx="172" cy="222" r="4" fill="#FF9E9E" opacity="0.4" />
              <circle cx="228" cy="222" r="4" fill="#FF9E9E" opacity="0.4" />
            </g>

            {/* Desk */}
            <rect x="0" y="380" width="400" height="170" fill="#D8B192" />
            <rect x="0" y="380" width="400" height="15" fill="#BD9473" />

            {/* Glowing Laptop */}
            <g transform="translate(230, 320)">
              <polygon points="10,48 100,48 115,62 -5,62" fill="#EAEAEA" stroke="#A8A8A8" strokeWidth="2" /> {/* base */}
              <rect x="15" y="10" width="80" height="42" fill="#264653" rx="2" stroke="#A8A8A8" strokeWidth="2" /> {/* screen */}
              <rect x="20" y="15" width="70" height="32" fill="#E9C46A" opacity="0.9" /> {/* webpage glow */}
              <line x1="25" y1="22" x2="65" y2="22" stroke="#FFF" strokeWidth="3" />
              <line x1="25" y1="30" x2="55" y2="30" stroke="#264653" strokeWidth="2" />
            </g>

            {/* Cup of tea */}
            <g transform="translate(60, 360)">
              <rect x="0" y="4" width="22" height="20" fill="#E63946" rx="2" />
              <path d="M 22 8 Q 28 8 26 14 Q 22 16 22 14" fill="none" stroke="#E63946" strokeWidth="2" />
            </g>
          </>
        )}

        {/* --- L'AJUNTAMENT --- */}
        {scenario === 'ajuntament' && (
          <>
            {/* Sky */}
            <rect width="400" height="550" fill="#D2E8FA" />

            {/* Classical columns & arches of Town Hall */}
            <rect x="0" y="130" width="400" height="300" fill="url(#stoneGrad)" />
            {/* Archway silhouettes */}
            <path d="M 40 430 L 40 230 Q 100 170 160 230 L 160 430 Z" fill="#A1927F" opacity="0.6" />
            <path d="M 240 430 L 240 230 Q 300 170 360 230 L 360 430 Z" fill="#A1927F" opacity="0.6" />
            {/* Columns */}
            <rect x="28" y="130" width="16" height="280" fill="#EAE4D8" />
            <rect x="176" y="130" width="16" height="280" fill="#EAE4D8" />
            <rect x="208" y="130" width="16" height="280" fill="#EAE4D8" />
            <rect x="356" y="130" width="16" height="280" fill="#EAE4D8" />
            {/* Pediment top */}
            <polygon points="-10,130 200,60 410,130" fill="url(#stoneGrad)" />
            <polygon points="120,130 200,95 280,130" fill="#F4ECE1" />

            {/* Waving Valencian Flag (Senyera) */}
            <g className="wave-flag" style={{ transformOrigin: '80px 60px' }}>
              <rect x="80" y="60" width="65" height="40" fill="url(#flagGrad)" />
              {/* Red Stripes */}
              <rect x="80" y="68" width="65" height="4" fill="#E63946" />
              <rect x="80" y="76" width="65" height="4" fill="#E63946" />
              <rect x="80" y="84" width="65" height="4" fill="#E63946" />
              <rect x="80" y="92" width="65" height="4" fill="#E63946" />
              {/* Blue strip at hoist */}
              <rect x="80" y="60" width="14" height="40" fill="#1D3557" />
              {/* Flag crown stars / gold motifs */}
              <circle cx="87" cy="70" r="2" fill="#FFC857" />
              <circle cx="87" cy="80" r="2" fill="#FFC857" />
              <circle cx="87" cy="90" r="2" fill="#FFC857" />
              {/* Flagpole */}
              <line x1="80" y1="50" x2="80" y2="120" stroke="#3D3D3D" strokeWidth="4.5" strokeLinecap="round" />
            </g>

            {/* CHARACTER: Amparo (The Tour Guide) */}
            <g className="float mood-transition" style={{ animationDuration: '3.7s' }} key={`ajuntament-${mood}`}>
              <path d="M 135 390 Q 200 120 265 390 Z" fill="#1D3557" />
              {/* Yellow/Red Scarf */}
              <path d="M 175 295 Q 200 325 225 295 Z" fill="#FFC857" />
              <path d="M 182 308 L 175 345 M 218 308 L 225 345" stroke="#E63946" strokeWidth="3" />
              {/* Neck */}
              <rect x="187" y="244" width="26" height="20" fill="#F8C9A1" rx="4" />
              {/* Head */}
              <circle cx="200" cy="215" r="38" fill="#F8C9A1" />
              {/* Short blonde hair */}
              <path d="M 160 215 C 160 158, 240 158, 240 215 C 235 185, 165 185, 160 215" fill="#F1C40F" />
              {/* Headset microphone */}
              <path d="M 230 205 Q 235 225 212 228" fill="none" stroke="#3D3D3D" strokeWidth="2.5" />
              <circle cx="210" cy="228" r="3" fill="#3D3D3D" />

              {/* Eyes */}
              <g className="gaze">
                <g className="blink-eyes">
                  <circle cx="186" cy="210" r="4" fill="#263747" />
                  <circle cx="214" cy="210" r="4" fill="#263747" />
                </g>
              </g>

              {/* Eyebrows & Mouth */}
              {moodFace(mood, 'eyebrows')}
              {moodFace(mood, 'mouth')}

              {/* Blush */}
              <circle cx="172" cy="220" r="4" fill="#FF8A8A" opacity="0.45" />
              <circle cx="228" cy="220" r="4" fill="#FF8A8A" opacity="0.45" />
            </g>

            {/* Info Counter */}
            <rect x="0" y="380" width="400" height="170" fill="url(#stoneGrad)" />
            <rect x="0" y="380" width="400" height="15" fill="#A89E8C" />

            {/* Tourist map and brochures */}
            <g transform="translate(130, 360)">
              <polygon points="10,24 80,20 100,45 20,50" fill="#FFF" stroke="#263747" strokeWidth="2" /> {/* open map */}
              <path d="M 28 26 L 38 42 M 52 24 L 62 40" stroke="#E63946" strokeWidth="1.5" /> {/* map routes */}
              <rect x="110" y="24" width="22" height="30" fill="#E63946" rx="2" stroke="#263747" strokeWidth="1.5" />
              <text x="121" y="44" fill="#FFF" fontSize="9" fontWeight="900" textAnchor="middle">i</text>
            </g>
          </>
        )}
      </svg>

    </div>
  );
}
