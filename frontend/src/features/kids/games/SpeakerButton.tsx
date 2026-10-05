import { Volume2 } from 'lucide-react';

/** Torna a dir la consigna (els xiquets no la poden llegir). */
export function SpeakerButton({ onClick }: { onClick: () => void }) {
  return (
    <button onClick={onClick} aria-label="Escolta una altra vegada" className="kid-speaker btn-press">
      <Volume2 className="h-9 w-9" />
    </button>
  );
}
