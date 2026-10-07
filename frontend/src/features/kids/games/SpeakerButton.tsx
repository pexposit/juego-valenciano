import { Loader2, Volume2 } from 'lucide-react';
import { useDelayedFlag } from '../../../components/AudioLoading';
import { useVoiceState } from '../sound';

/** Torna a dir la consigna (els xiquets no la poden llegir). */
export function SpeakerButton({ onClick }: { onClick: () => void }) {
  // Mentre la veu carrega (i per això encara no sona), l'altaveu mostra una rodeta.
  const loadingVoice = useDelayedFlag(useVoiceState() === 'loading');
  return (
    <button onClick={onClick} aria-label="Escolta una altra vegada" aria-busy={loadingVoice} className="kid-speaker btn-press">
      {loadingVoice ? <Loader2 className="h-9 w-9 animate-spin" /> : <Volume2 className="h-9 w-9" />}
    </button>
  );
}
