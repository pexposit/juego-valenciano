import { useEffect, useState } from 'react';
import { BookHeart, GraduationCap } from 'lucide-react';
import { ProfileButton } from '../../components/ui';
import { ISLANDS } from './content';
import { LESSONS } from './lessons';
import { loadCromos, loadLessonsDone } from './progress';
import { say, stopVoice } from './sound';
import './kids.css';

/** Mapa d'illes del Nivell 0. Tot es diu en veu alta: tocar una illa diu el seu nom i hi entra. */
export function KidsHome({ name, uid, onIsland, onAlbum, onLessons, onProfile }: {
  name: string;
  uid: string | undefined;
  onIsland: (id: string) => void;
  onAlbum: () => void;
  onLessons: () => void;
  onProfile: () => void;
}) {
  const [cromos, setCromos] = useState<string[]>([]);
  const [lessonsDone, setLessonsDone] = useState<string[]>([]);
  const [opening, setOpening] = useState<string>();

  useEffect(() => {
    let cancelled = false;
    void loadCromos(uid).then(c => { if (!cancelled) setCromos(c); });
    void loadLessonsDone(uid).then(d => { if (!cancelled) setLessonsDone(d); });
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
    await say(`illa-${id}`);
    onIsland(id);
  };

  return (
    <main className="kids-world kids-sea">
      <header className="kids-bar">
        <button onClick={() => void say('hola')} aria-label="La Taronjeta" className="kid-mascot-btn btn-press">
          <span className="kid-mascot-small" aria-hidden="true">🍊</span>
        </button>
        {/* Les lliçons: la teoria, explicada pas a pas per la Taronjeta. */}
        <button
          onClick={async () => {
            await say('llicons-boto');
            onLessons();
          }}
          aria-label="Les lliçons"
          className="kid-lessons-btn btn-press"
        >
          <GraduationCap className="h-9 w-9" />
          <span className="kid-lessons-btn-text">Lliçons</span>
          <span className="kid-album-count" style={{ background: '#7C3AED' }}>{lessonsDone.length}/{LESSONS.length}</span>
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
            {cromos.includes(island.id) && <span className="kid-island-done" aria-hidden="true">{island.cromo.emoji}</span>}
          </button>
        ))}
      </div>
    </main>
  );
}
