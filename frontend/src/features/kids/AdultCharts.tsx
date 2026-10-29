import { useState, type ReactNode } from 'react';
import { ago, percent, type AdultItem } from './report';

// Un color per nivell de domini (mateixos llindars que la resta de l'informe: ≤ 50 % costa, ≥ 80 % sense errors domina).
const MASTERY = {
  domina: { label: 'Ho domina', color: '#0F47AF' },
  practicar: { label: 'A practicar', color: '#D97706' },
  costa: { label: 'Li costa', color: '#E34948' },
} as const;
const ORDER = ['domina', 'practicar', 'costa'] as const;
const KIND_LABEL = { practice: 'Pràctica', exam: 'Examen', scenario: 'Escenari' } as const;
const ROWS_SHOWN = 10;
const TOOLTIP_ROWS = 8;

const Card = ({ children }: { children: ReactNode }) => <section className="rounded-3xl bg-white p-5 shadow-sm">{children}</section>;

/** Resum visual de les activitats d'una persona adulta: la distribució per domini i la nota de cada activitat. */
export function AdultCharts({ items }: { items: AdultItem[] }) {
  if (!items.length) return null;
  return (
    <>
      <MasteryBar items={items} />
      <ScoreBars items={items} />
    </>
  );
}

/** Barra apilada: quantes activitats hi ha en cada nivell de domini (part del total). */
function MasteryBar({ items }: { items: AdultItem[] }) {
  const counts = ORDER.map(key => ({ key, n: items.filter(i => i.mastery === key).length }));
  const summary = counts.map(c => `${MASTERY[c.key].label}: ${c.n}`).join(', ');
  const visible = counts.filter(c => c.n > 0);
  return (
    <Card>
      <h3 className="text-2xl font-black">Com vas</h3>
      <p className="mt-1 text-base opacity-60">Les teues {items.length} activitats, segons la nota de l'última vegada.</p>
      {/* Segments separats per 2 px; el nom i el nombre van sempre en text, no només en color. En passar-hi per damunt
          (o enfocar-los amb el teclat) es llisten les activitats d'eixe nivell. */}
      <div role="group" aria-label={summary} className="mt-4 flex h-9 gap-0.5">
        {visible.map((c, idx) => {
          const names = items.filter(i => i.mastery === c.key).sort((x, y) => x.ratio - y.ratio);
          return (
            <div
              key={c.key}
              tabIndex={0}
              aria-label={`${MASTERY[c.key].label}: ${names.map(i => i.name).join(', ')}`}
              style={{ flexGrow: c.n, backgroundColor: MASTERY[c.key].color }}
              className="group relative grid min-w-9 place-items-center rounded-md text-lg font-black text-white outline-none focus-visible:ring-4 focus-visible:ring-[#0F47AF]/40 focus-visible:ring-offset-2"
            >
              {c.n}
              <div
                role="tooltip"
                className={`pointer-events-none absolute top-full z-10 mt-2 hidden w-64 max-w-[80vw] rounded-2xl bg-white p-3 text-left text-base font-normal text-ink shadow-lg ring-1 ring-black/10 group-hover:block group-focus:block ${idx === visible.length - 1 && visible.length > 1 ? 'right-0' : 'left-0'}`}
              >
                <span className="block font-extrabold">{MASTERY[c.key].label} · {c.n}</span>
                <ul className="mt-1 space-y-0.5">
                  {names.slice(0, TOOLTIP_ROWS).map(i => (
                    <li key={i.key} className="flex items-baseline gap-2">
                      <span aria-hidden="true">{i.emoji}</span>
                      <span className="min-w-0 flex-1 truncate">{i.name}</span>
                      <span className="shrink-0 font-bold tabular-nums opacity-70">{percent(i.ratio)}</span>
                    </li>
                  ))}
                  {names.length > TOOLTIP_ROWS && <li className="opacity-60">+{names.length - TOOLTIP_ROWS} més</li>}
                </ul>
              </div>
            </div>
          );
        })}
      </div>
      <ul className="mt-3 flex flex-wrap gap-x-5 gap-y-1 text-base">
        {counts.map(c => (
          <li key={c.key} className="flex items-center gap-2">
            <span aria-hidden="true" className="h-3 w-3 rounded-sm" style={{ backgroundColor: MASTERY[c.key].color }} />
            <span className="font-bold">{MASTERY[c.key].label}</span>
            <span className="opacity-60">{c.n}</span>
          </li>
        ))}
      </ul>
    </Card>
  );
}

/** Una barra per activitat (de la nota més baixa a la més alta), amb les marques del 50 % i el 80 %. */
function ScoreBars({ items }: { items: AdultItem[] }) {
  const [all, setAll] = useState(false);
  const sorted = [...items].sort((a, b) => a.ratio - b.ratio);
  const shown = all ? sorted : sorted.slice(0, ROWS_SHOWN);
  return (
    <Card>
      <h3 className="text-2xl font-black">Nota de cada activitat</h3>
      <p className="mt-1 text-base opacity-60">Ordenades de la que més costa a la que millor va. Les ratlles marquen el 50 % i el 80 %.</p>
      <ul className="mt-4 space-y-2">
        {shown.map(i => (
          <li key={i.key} className="grid grid-cols-[minmax(0,2fr)_minmax(0,3fr)_auto] items-center gap-3" title={`${i.name} · ${KIND_LABEL[i.kind]} · ${i.detail} · ${ago(i.lastAt)}`}>
            <span className="flex min-w-0 items-center gap-2">
              <span aria-hidden="true">{i.emoji}</span>
              <span className="min-w-0">
                <span className="block truncate text-base font-extrabold">{i.name}</span>
                <span className="block truncate text-sm opacity-60">
                  {KIND_LABEL[i.kind]}{i.pendingErrors > 0 ? ` · ${i.pendingErrors} ${i.pendingErrors === 1 ? 'error' : 'errors'} per corregir` : ''}
                </span>
              </span>
            </span>
            <span role="img" aria-label={`${percent(i.ratio)} (${i.detail})`} className="relative block h-3 rounded-full bg-gray-100">
              <span className="block h-full rounded-full" style={{ width: `${Math.max(2, Math.round(i.ratio * 100))}%`, backgroundColor: MASTERY[i.mastery].color }} />
              <span aria-hidden="true" className="absolute inset-y-[-3px] left-1/2 w-px bg-gray-400" />
              <span aria-hidden="true" className="absolute inset-y-[-3px] left-[80%] w-px bg-gray-400" />
            </span>
            <span className="w-28 text-right text-base font-black tabular-nums">{percent(i.ratio)} <span className="font-normal opacity-60">{i.detail}</span></span>
          </li>
        ))}
      </ul>
      {sorted.length > ROWS_SHOWN && (
        <button type="button" onClick={() => setAll(a => !a)} className="btn-press mt-3 text-base font-extrabold text-[#0F47AF] hover:underline">
          {all ? 'Mostra menys' : `Mostra les ${sorted.length - ROWS_SHOWN} restants`}
        </button>
      )}
    </Card>
  );
}
