import { BookOpen } from 'lucide-react';
import type { GnvRule } from '../lib/types';

// Bombolla d'un missatge del xat amb el tutor. En els missatges del professor, la primera línia és en
// valencià i la resta, en gris clar, l'ajuda en la llengua materna del xiquet (amagada si `showHelp` és fals).
// Si el professor ha respost un dubte de normativa amb la GNV, davall va la regla oficial.
export function ChatBubble({ role, text, gnv, showHelp = true }: { role: 'user' | 'character'; text: string; gnv?: GnvRule; showHelp?: boolean }) {
  const [valencian, ...help] = role === 'character' ? text.split('\n') : [text];
  return (
    <div
      className={`max-w-[85%] rounded-2xl px-4 py-2 text-xl font-bold ${
        role === 'user' ? 'ml-auto bg-teal text-white' : 'bg-cream text-slate-800'
      }`}
    >
      <p>{valencian}</p>
      {showHelp && help.length > 0 && <p className="mt-1 whitespace-pre-line text-lg font-semibold text-slate-400">{help.join('\n')}</p>}
      {gnv && <GnvRuleCard rule={gnv} />}
    </div>
  );
}

function GnvRuleCard({ rule }: { rule: GnvRule }) {
  const related = rule.relacionades ?? [];
  return (
    <section aria-label="Regla de la Gramàtica Normativa Valenciana" className="mt-3 rounded-xl bg-white/80 p-3 text-base font-semibold ring-2 ring-teal/30">
      <p className="flex items-start gap-2 text-sm font-extrabold uppercase tracking-wide text-teal">
        <BookOpen size={18} className="mt-0.5 shrink-0" aria-hidden />
        <span>Regla oficial · GNV{rule.seccio ? ` § ${rule.seccio}` : ''}</span>
      </p>
      <p className="mt-1 text-sm font-semibold text-slate-500">{rule.ruta}</p>
      {related.length > 0 && (
        <p className="mt-1 text-sm font-semibold text-slate-500">
          Completen la regla: {related.map(r => r.seccio ? `§ ${r.seccio}` : r.ruta).join(', ')}
        </p>
      )}

      <h3 className="mt-3 text-sm font-extrabold text-slate-700">Què diu la norma</h3>
      <p className="whitespace-pre-line">{rule.contingut}</p>

      <h3 className="mt-3 text-sm font-extrabold text-slate-700">Explicació fàcil</h3>
      <p className="whitespace-pre-line">{rule.explicacio}</p>

      <details className="mt-3">
        <summary className="cursor-pointer text-sm font-extrabold text-teal">Vore el text original de la GNV</summary>
        <div className="mt-2 max-h-72 space-y-3 overflow-y-auto text-sm font-medium text-slate-600">
          {[{ regla: rule.regla, text: rule.text_original }, ...related].map(source => (
            <div key={source.regla}>
              <p className="font-extrabold text-slate-700">{source.regla}</p>
              <p className="whitespace-pre-line">{source.text}</p>
            </div>
          ))}
        </div>
      </details>
    </section>
  );
}
