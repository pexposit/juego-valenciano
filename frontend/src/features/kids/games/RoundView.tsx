import type { Round } from '../content';
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
