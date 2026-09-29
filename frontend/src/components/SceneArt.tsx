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

// La foto de fons ve de resources.metadata.background; els personatges dibuixats
// només existixen per a alguns escenaris (la resta es mostren sense il·lustració).
export function SceneArt({ scenario, background, mood }: { scenario: Scenario; background: string | null; mood: Mood }) {
  return (
    <div className="absolute inset-0 overflow-hidden bg-[#FFF9ED]">
      {/* Foto real de l'escenari darrere del personatge i el taulell il·lustrats. */}
      {background && (
        <img
          src={background}
          alt=""
          aria-hidden="true"
          className="absolute inset-0 h-full w-full object-cover opacity-40"
        />
      )}
      <svg
        viewBox="0 0 400 550"
        className="relative h-full w-full object-cover select-none"
        xmlns="http://www.w3.org/2000/svg"
        preserveAspectRatio="xMidYMid slice"
      >
        {/* --- EL MERCAT --- */}
        {scenario === 'mercat' && (
          <>
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
          </>
        )}

        {/* --- EL BAR --- */}
        {scenario === 'bar' && (
          <>
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

          </>
        )}

        {/* --- L'OFICINA --- */}
        {scenario === 'oficina' && (
          <>
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
          </>
        )}

        {/* --- L'AJUNTAMENT --- */}
        {scenario === 'ajuntament' && (
          <>
            {/* CHARACTER: Amparo (Town Hall Clerk) */}
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
          </>
        )}
{/* --- L'OFICINA DE TURISME --- */}
        {scenario === 'turisme' && (
          <>
            {/* CHARACTER: Laura (The Tourist Guide) */}
            <g className="float mood-transition" style={{ animationDuration: '3.7s' }} key={`turisme-${mood}`}>
              {/* Body / polo */}
              <path d="M 135 390 Q 200 120 265 390 Z" fill="#0D9488" />
              {/* Info badge */}
              <circle cx="200" cy="288" r="10" fill="#FFF" />
              <text x="200" y="292" fill="#0D9488" fontSize="12" fontWeight="900" textAnchor="middle">i</text>
              {/* Neck */}
              <rect x="187" y="244" width="26" height="20" fill="#F8C9A1" rx="4" />
              {/* Head */}
              <circle cx="200" cy="215" r="38" fill="#F8C9A1" />
              {/* Blonde ponytail */}
              <path d="M 162 215 C 162 158, 238 158, 238 215 C 230 190, 170 190, 162 215" fill="#F1C40F" />
              <path d="M 224 182 Q 250 194 228 210 Z" fill="#F1C40F" />
              {/* Visor cap */}
              <path d="M 164 196 C 164 172, 236 172, 236 196 C 232 188, 168 188, 164 196" fill="#0D9488" />
              {/* Cap logo */}
              <circle cx="200" cy="180" r="7" fill="#FFF" />
              <text x="200" y="184" fill="#0D9488" fontSize="10" fontWeight="900" textAnchor="middle">i</text>

              {/* Eyes */}
              <g className="gaze">
                <g className="blink-eyes">
                  <circle cx="186" cy="214" r="4" fill="#263747" />
                  <circle cx="214" cy="214" r="4" fill="#263747" />
                </g>
              </g>

              {/* Eyebrows & Mouth */}
              {moodFace(mood, 'eyebrows')}
              {moodFace(mood, 'mouth')}

              {/* Blush */}
              <circle cx="172" cy="224" r="4" fill="#FF8A8A" opacity="0.45" />
              <circle cx="228" cy="224" r="4" fill="#FF8A8A" opacity="0.45" />

              {/* Arm pointing at the map on the counter */}
              <path d="M 255 330 Q 282 296 260 262 Q 246 248 252 244" fill="none" stroke="#F8C9A1" strokeWidth="15" strokeLinecap="round" className="sway" style={{ transformOrigin: '255px 330px' }} />
            </g>
          </>
        )}
      </svg>

    </div>
  );
}
