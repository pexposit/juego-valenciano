import { useEffect, useState } from 'react';
import { BookHeart, ChevronLeft } from 'lucide-react';
import { ProfileButton } from '../../components/ui';
import { stageCount } from './islandSession';
import { ROBOT_AVATAR } from '../robot-avatar';
import { fetchResources } from '../../lib/api';
import type { Resource } from '../../lib/types';
import { ISLANDS } from './lessons';
import { KidsPathStrip } from '../paths/KidsPathStrip';
import { loadCromos, loadStages, stagesDone } from './progress';
import { say, sayBriefly, stopVoice } from './sound';
import './kids.css';

/**
 * Mapa d'illes del Nivell 0. Tot es diu en veu alta: tocar una illa diu el seu nom i hi entra.
 * Cada illa a mig fer mostra les seues etapes (estrelles); les acabades, el seu cromo.
 * A dalt, en una franja pròpia, els escenaris de conversa del Nivell 0 (p. ex. el mag Merlí) i,
 * si la mestra n'ha assignat una, la ruta amb el següent pas.
 */
export function KidsHome({ name, uid, onBack, onIsland, onScenario, onRoute, onAlbum, onProfile }: {
  name: string;
  uid: string | undefined;
  onBack: () => void;
  onIsland: (id: string) => void;
  onScenario: (resource: Resource) => void;
  onRoute: (route: string) => void;
  onAlbum: () => void;
  onProfile: () => void;
}) {
  const [cromos, setCromos] = useState<string[]>([]);
  const [stages, setStages] = useState<string[]>([]);
  const [opening, setOpening] = useState<string>();
  // Escenaris de conversa del Nivell 0 (resources amb category 'escenari' i difficulty 'nivell0').
  const [resources, setResources] = useState<Resource[]>([]);
  const scenarios = resources.filter(r => r.category === 'escenari' && r.difficulty === 'nivell0');

  useEffect(() => {
    let cancelled = false;
    fetchResources()
      .then(data => {
        if (!cancelled) setResources(data);
      })
      .catch(error => console.error('Error carregant els escenaris:', error));
    return () => { cancelled = true; };
  }, []);

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

      <KidsPathStrip uid={uid} resources={resources} onRoute={onRoute} />

      {/* Els escenaris de conversa, en una franja a dalt, a banda de les illes. */}
      {scenarios.length > 0 && (
        <section className="kids-scenarios" aria-label="Escenaris">
          <span className="kids-scenarios-title"><span aria-hidden="true">🎭</span> Escenaris</span>
          <div className="kids-scenarios-list">
            {scenarios.map(scenario => (
              <button
                key={scenario.id}
                onClick={() => onScenario(scenario)}
                aria-label={scenario.name}
                title={scenario.name}
                className="kid-scenario btn-press"
              >
                <span className="kid-scenario-face" style={{ background: scenario.color ?? '#D1C4E9' }}>
                  {ROBOT_AVATAR.scenarioOutfits[scenario.type] ? (
                    // El personatge de l'escenari amb la seua roba (la mateixa imatge que el robot del xat).
                    <img src={ROBOT_AVATAR.scenarioOutfits[scenario.type].fallbackUrl} alt="" aria-hidden="true" />
                  ) : (
                    <span aria-hidden="true">{scenario.icon ?? '💬'}</span>
                  )}
                </span>
                <span className="kid-scenario-name">{scenario.section_name ?? scenario.name}</span>
              </button>
            ))}
          </div>
        </section>
      )}

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
