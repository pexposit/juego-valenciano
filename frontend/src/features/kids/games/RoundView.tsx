import type { Round } from '../content';
import { phraseText } from '../sound';
import { Translation, useKidsTranslation } from '../translations';
import { BubbleGame, ChoiceGame, CountGame, DotsGame } from './ChoiceGames';
import { DragGame } from './DragGame';
import { MemoryGame, SeqGame, SortGame } from './MoreGames';
import { TraceGame } from './TraceGame';

/** El joc de cada tipus de ronda (en les illes i en la pràctica de les lliçons). */
export function RoundView({ round, onDone }: { round: Round; onDone: () => void }) {
  switch (round.kind) {
    case 'tap':
    case 'odd': return <ChoiceGame round={round} onDone={onDone} />;
    case 'dots': return <DotsGame round={round} onDone={onDone} />;
    case 'bubbles': return <BubbleGame round={round} onDone={onDone} />;
    case 'count': return <CountGame round={round} onDone={onDone} />;
    case 'drag': return <DragGame round={round} onDone={onDone} />;
    case 'trace': return <TraceGame round={round} onDone={onDone} />;
    case 'memory': return <MemoryGame round={round} onDone={onDone} />;
    case 'seq': return <SeqGame round={round} onDone={onDone} />;
    case 'sort': return <SortGame round={round} onDone={onDone} />;
  }
}

// Les claus de la consigna d'una ronda (els jocs d'arrossegar no en tenen: diuen cada tasca).
const promptKeys = (round: Round): string[] => {
  const prompt = 'prompt' in round ? round.prompt : undefined;
  if (!prompt) return [];
  return Array.isArray(prompt) ? prompt : [prompt];
};

/**
 * La consigna escrita: en valencià i, davall, en la llengua materna si està activada. Amb
 * `onlyTranslated`, només es mostra quan hi ha traducció (les illes no porten text si no).
 */
export function RoundCaption({ round, className, onlyTranslated }: { round: Round; className: string; onlyTranslated?: boolean }) {
  const translate = useKidsTranslation();
  const keys = promptKeys(round);
  const text = keys.map(phraseText).join(' ');
  // En les consignes de diversos passos («Primer, toca... El gos!»), el vocabulari no té
  // traducció i es queda en valencià.
  const translations = keys.map(translate);
  const translated = translations.some(Boolean) ? keys.map((k, i) => translations[i] ?? phraseText(k)).join(' ') : undefined;
  if (!text || (onlyTranslated && !translated)) return null;
  return (
    <p className={className}>
      {text}
      <Translation text={translated} />
    </p>
  );
}
