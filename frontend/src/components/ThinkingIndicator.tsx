/** Avís de que el robot està generant la resposta: text amb tres punts que botem. */
export function ThinkingIndicator({ className = '' }: { className?: string }) {
  return (
    <span role="status" aria-live="polite" className={`inline-flex items-center gap-2 ${className}`}>
      <span>El robot està pensant</span>
      <span className="inline-flex items-end gap-1" aria-hidden="true">
        {[0, 150, 300].map(delay => (
          <span key={delay} className="h-2 w-2 animate-bounce rounded-full bg-current" style={{ animationDelay: `${delay}ms` }} />
        ))}
      </span>
    </span>
  );
}
