import { useEffect, useState } from 'react';
import { BookHeart, ChevronLeft } from 'lucide-react';
import { ProfileButton } from '../../components/ui';
import { stageCount } from './islandSession';
import { ISLANDS } from './lessons';
import { loadCromos, loadStages, stagesDone } from './progress';
import { say, sayBriefly, stopVoice } from './sound';
import './kids.css';

/**
 * Mapa d'illes del Nivell 0. Tot es diu en veu alta: tocar una illa diu el seu nom i hi entra.
 * Cada illa a mig fer mostra les seues etapes (estrelles); les acabades, el seu cromo.
 */
export function KidsHome({ name, uid, onBack, onIsland, onAlbum, onProfile }: {
  name: string;
  uid: string | undefined;
  onBack: () => void;
  onIsland: (id: string) => void;
  onAlbum: () => void;
  onProfile: () => void;
}) {
  const [cromos, setCromos] = useState<string[]>([]);
  const [stages, setStages] = useState<string[]>([]);
  const [opening, setOpening] = useState<string>();

  useEffect(() => {
    let cancelled = false;
    void loadCromos(uid).then(c => { if (!cancelled) setCromos(c); });
    void loadStages(uid).then(s => { if (!cancelled) setStages(s); });
    const timer = window.setTimeout(() => void say('hola'), 500);
    return () => {
      cancelled = true;
      window.clearTimeout(timer);
      stopVoice();
    };
  }, [uid]);

  const open = async (id: string) => {
    if (opening) return;
    setOpening(id);
    await sayBriefly(`illa-${id}`);
    onIsland(id);
  };

  return (
    <main className="kids-world kids-sea">
      <header className="kids-bar">
        <button onClick={onBack} aria-label="Tornar al tauler" title="Tornar al tauler" className="kid-round-btn btn-press">
          <ChevronLeft className="h-9 w-9" />
        </button>
        <button onClick={onAlbum} aria-label="L'àlbum de cromos" className="kid-album-btn btn-press">
          <BookHeart className="h-9 w-9" />
          <span className="kid-album-count">{cromos.length}/{ISLANDS.length}</span>
        </button>
        {/* Per als adults: perfil i tancar la sessió. */}
        <ProfileButton name={name} onClick={onProfile} />
      </header>

      <div className="kids-islands">
        {ISLANDS.map((island, i) => (
          <button
            key={island.id}
            onClick={() => void open(island.id)}
            aria-label={island.name}
            className={`kid-island btn-press ${opening === island.id ? 'kid-jump' : ''}`}
            style={{ ['--island' as string]: island.color, animationDelay: `${i * 0.35}s` }}
          >
            <span className="kid-island-emoji" aria-hidden="true">{island.emoji}</span>
            {cromos.includes(island.id) ? (
              <span className="kid-island-done" aria-hidden="true">{island.cromo.emoji}</span>
            ) : stagesDone(stages, island.id) > 0 && (
              <span className="kid-island-stages" aria-hidden="true">
                {Array.from({ length: stageCount(island) }, (_, s) => <i key={s} className={s < stagesDone(stages, island.id) ? 'on' : ''}>★</i>)}
              </span>
            )}
          </button>
        ))}
      </div>
    </main>
  );
}
