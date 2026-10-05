// Bombolla d'un missatge del xat amb el tutor. En els missatges del professor, la primera línia és en
// valencià i la resta, en gris clar, l'ajuda en la llengua materna del xiquet (amagada si `showHelp` és fals).
// Amb `onlyHelp` (Nivell 0) es mostra només l'ajuda en la llengua materna, com a text principal; sense ajuda, el valencià.
export function ChatBubble({ role, text, showHelp = true, onlyHelp = false }: { role: 'user' | 'character'; text: string; showHelp?: boolean; onlyHelp?: boolean }) {
  const [valencian, ...help] = role === 'character' ? text.split('\n') : [text];
  if (onlyHelp && help.length > 0) {
    return (
      <div className="max-w-[85%] rounded-2xl bg-cream px-4 py-2 text-xl font-bold text-slate-800">
        <p className="whitespace-pre-line">{help.join('\n')}</p>
      </div>
    );
  }
  return (
    <div
      className={`max-w-[85%] rounded-2xl px-4 py-2 text-xl font-bold ${
        role === 'user' ? 'ml-auto bg-teal text-white' : 'bg-cream text-slate-800'
      }`}
    >
      <p>{valencian}</p>
      {showHelp && help.length > 0 && <p className="mt-1 whitespace-pre-line text-lg font-semibold text-slate-400">{help.join('\n')}</p>}
    </div>
  );
}
