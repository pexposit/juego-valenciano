import type { ReactNode } from 'react';
import { BookOpen } from 'lucide-react';
import { ago, percent, stageNote, summarize, summarizeAdult, type AdultItem, type IslandSummary, type Report } from './report';
import type { ChildData } from './tracking';

/**
 * Informe del seguiment d'un xiquet del Nivell 0, per a persones adultes (la família en
 * el seu perfil i el professorat en la fitxa de cada alumne): temps de joc, encerts i les
 * illes agrupades per encerts a la primera: li costa, a practicar i ho domina. A banda,
 * les converses amb personatges, amb els objectius que ha complit (sense errors).
 */
export function ProgressReport({ data, name, onLesson }: {
  data: ChildData;
  name: string;
  onLesson?: (lesson: string) => void;
}) {
  const report = summarize(data);
  const who = name || 'el xiquet o la xiqueta';
  // Les illes, les partides i les lliçons són del Nivell 0 (xiquets): de qui té un altre nivell només es veuen els escenaris.
  const adult = Boolean(data.level) && data.level !== 'nivell0';
  if (adult) return <AdultReport data={data} report={report} />;

  return (
    <div className="space-y-5">
      {/* Sense partides, totes les illes queden «a practicar». */}
      {!report.total.sessions && (
        <Card>
          <p className="text-xl font-extrabold">Encara no hi ha partides</p>
          <p className="mt-1 text-lg opacity-70">Quan {who} jugue a les illes, ací veureu què domina, què li costa i com avança.</p>
        </Card>
      )}
      <div className="grid grid-cols-2 gap-3 sm:grid-cols-4">
        <Tile label="Aquesta setmana" value={`${report.week.minutes} min`} detail={`${plural(report.week.sessions, 'partida', 'partides')} · ${plural(report.week.days, 'dia', 'dies')}`} />
        <Tile label="Encerts a la primera" value={percent(report.accuracy)} detail={`Última vegada: ${ago(report.lastPlayed)}`} />
        <Tile label="Cromos" value={`${report.cromos}/${report.islands.length}`} detail="illes acabades" />
        <Tile label="Medalles" value={`${report.medals}/${report.medalsTotal}`} detail="lliçons acabades" />
      </div>

      <Group
        title="Li costa"
        hint="Illes que encara no ha acabat on encerta a la primera la meitat de les rondes o menys (50 % o menys)."
        empty="Cap illa, de moment. 🎉"
        tone="coral"
        islands={report.costa}
        onLesson={onLesson}
      />
      <Group
        title="A practicar"
        hint="Illes que encara no ha acabat amb més del 50 % d'encerts, i les que encara no ha jugat."
        empty="Cap: totes les illes jugades van molt bé o costen."
        tone="amber"
        islands={report.practicar}
        onLesson={onLesson}
      />
      <Group
        title="Ho domina"
        hint="Illes acabades: ha superat totes les etapes (cada una amb el 80 % d'encerts o més en una partida)."
        empty="Encara cap: cal jugar-hi unes quantes vegades."
        tone="teal"
        islands={report.domina}
      />

      <Conversations report={report} />

      {report.recent.length > 0 && (
        <Card>
          <h3 className="text-2xl font-black">Últimes partides</h3>
          <ul className="mt-3 space-y-2 text-lg">
            {report.recent.map(s => (
              <li key={s.created_at} className="flex items-center gap-3">
                <span aria-hidden="true">{s.emoji}</span>
                <span className="flex-1">{s.name}{s.stage === null ? ' (repàs)' : ''}</span>
                <span className="opacity-60">{s.first_try}/{s.rounds} a la primera · {Math.max(1, Math.round(s.seconds / 60))} min · {ago(s.created_at)}</span>
              </li>
            ))}
          </ul>
        </Card>
      )}
    </div>
  );
}

const plural = (n: number, one: string, many: string) => `${n} ${n === 1 ? one : many}`;

function Card({ children }: { children: ReactNode }) {
  return <section className="rounded-3xl bg-white p-5 shadow-sm">{children}</section>;
}

function Tile({ label, value, detail }: { label: string; value: string; detail: string }) {
  return (
    <div className="rounded-3xl bg-white p-4 shadow-sm">
      <span className="block text-sm font-extrabold uppercase tracking-wide opacity-50">{label}</span>
      <span className="mt-1 block text-3xl font-black">{value}</span>
      <span className="block text-sm opacity-60">{detail}</span>
    </div>
  );
}

/** Les converses amb personatges: no es corregixen errors, es mira quins objectius ha complit. */
function Conversations({ report, adult = false }: { report: Report; adult?: boolean }) {
  return (
    <Card>
      <h3 className="text-2xl font-black">Converses</h3>
      <p className="mt-1 text-base opacity-60">
        {adult
          ? "Escenaris de conversa amb personatges. Ací no es corregixen errors: es mira quins objectius de l'escenari ha complit en valencià."
          : 'Parla amb personatges, com el mag Merlí. Ací no es corregixen errors: es mira quins objectius de la conversa ha complit en valencià.'}
      </p>
      {report.conversations.length ? (
        <ul className="mt-3 divide-y divide-gray-100">
          {report.conversations.map(c => {
            const met = c.latest.objectives.filter(o => o.met).length;
            const reviewed = c.latest.objectives.some(o => o.met !== null);
            return (
              <li key={c.id} className="py-3">
                <div className="flex flex-wrap items-center gap-3">
                  <span className="grid h-12 w-12 shrink-0 place-items-center rounded-full bg-[#EDE7F6] text-2xl" aria-hidden="true">💬</span>
                  <span className="min-w-0 flex-1">
                    <span className="block text-lg font-extrabold">{c.name}</span>
                    <span className="block text-base opacity-60">
                      {plural(c.count, 'conversa', 'converses')} · {c.minutes} min · {ago(c.latest.created_at)}
                      {c.count > 1 && reviewed && ` · millor: ${c.best} de ${c.total}`}
                    </span>
                  </span>
                  {reviewed && (
                    <span className={`shrink-0 rounded-full px-3 py-1 text-lg font-black ${met === c.total ? TONES.teal : met === 0 ? TONES.coral : TONES.amber}`}>
                      {met}/{c.total}
                    </span>
                  )}
                </div>
                <p className="mt-2 text-sm font-extrabold uppercase tracking-wide opacity-50">L'última conversa</p>
                <ul className="mt-1 space-y-1 text-base">
                  {c.latest.objectives.map(o => (
                    <li key={o.text} className="flex items-start gap-2">
                      <span aria-hidden="true" className={o.met ? 'text-teal' : 'text-gray-300'}>{o.met === null ? '·' : o.met ? '✓' : '○'}</span>
                      <span className={o.met ? '' : 'opacity-60'}>{o.text}</span>
                    </li>
                  ))}
                </ul>
                {!reviewed && <p className="mt-1 text-sm opacity-60">Encara no s'ha pogut revisar esta conversa.</p>}
              </li>
            );
          })}
        </ul>
      ) : (
        <p className="mt-3 text-lg">{adult ? 'Encara no ha acabat cap escenari de conversa.' : 'Encara no ha parlat amb cap personatge.'}</p>
      )}
    </Card>
  );
}

const TONES = { coral: 'bg-coral/10 text-coral', amber: 'bg-amber-100 text-amber-800', teal: 'bg-teal/10 text-teal' };

/** Un grup d'illes (li costa, a practicar, ho domina), amb els encerts i la lliçó per a repassar. */
function Group({ title, hint, empty, tone, islands, onLesson }: {
  title: string;
  hint: string;
  empty: string;
  tone: keyof typeof TONES;
  islands: IslandSummary[];
  onLesson?: (lesson: string) => void;
}) {
  return (
    <Card>
      <h3 className="flex items-center gap-2 text-2xl font-black">
        {title}
        <span className={`rounded-full px-2.5 py-0.5 text-base font-extrabold ${TONES[tone]}`}>{islands.length}</span>
      </h3>
      <p className="mt-1 text-base opacity-60">{hint}</p>
      {islands.length ? (
        <ul className="mt-3 divide-y divide-gray-100">
          {islands.map(i => (
            <li key={i.id} className="flex flex-wrap items-center gap-3 py-3">
              <span className="grid h-12 w-12 shrink-0 place-items-center rounded-full text-2xl" style={{ background: i.color }} aria-hidden="true">{i.emoji}</span>
              <span className="min-w-0 flex-1">
                <span className="block text-lg font-extrabold">
                  {i.name}
                  {i.easy && <span className="ml-2 rounded-full bg-amber-100 px-2 py-0.5 text-sm font-bold text-amber-800">mode fàcil</span>}
                </span>
                <span className="block text-base opacity-60">
                  {i.sessions ? `${plural(i.sessions, 'partida', 'partides')} · ${ago(i.lastPlayed)}` : 'Encara no hi ha jugat'}
                  <span className="ml-2" aria-label={i.cromo ? 'Illa acabada' : `${i.stagesDone} de ${i.stages} parts`}>
                    {i.cromo ? '🏆' : Array.from({ length: i.stages }, (_, s) => <span key={s} className={s < i.stagesDone ? 'text-amber-400' : 'text-gray-300'}>★</span>)}
                  </span>
                </span>
                {stageNote(i) && <span className="mt-0.5 block text-base font-bold text-teal">{stageNote(i)}</span>}
              </span>
              {i.accuracy !== null && <span className={`shrink-0 rounded-full px-3 py-1 text-lg font-black ${TONES[tone]}`}>{percent(i.accuracy)}</span>}
              {/* La lliçó, per a repassar les illes jugades que encara no domina (a les no jugades no cal). */}
              {onLesson && i.lesson && i.sessions > 0 && (
                <button
                  onClick={() => onLesson(i.lesson!)}
                  className="btn-press flex shrink-0 items-center gap-2 rounded-full bg-[#7C3AED] px-4 py-2 font-extrabold text-white"
                >
                  <BookOpen size={18} /> Fes la lliçó
                </button>
              )}
            </li>
          ))}
        </ul>
      ) : (
        <p className="mt-3 text-lg">{empty}</p>
      )}
    </Card>
  );
}

/**
 * L'informe d'una persona adulta: com el dels xiquets (li costa, a practicar, ho domina), però amb les seues
 * activitats (pràctiques, exàmens i escenaris) en compte d'illes. Els escenaris porten els objectius complits.
 */
function AdultReport({ data, report }: { data: ChildData; report: Report }) {
  const adult = summarizeAdult(data);
  return (
    <div className="space-y-5">
      {!adult.items.length && (
        <Card>
          <p className="text-xl font-extrabold">Encara no hi ha activitats</p>
          <p className="mt-1 text-lg opacity-70">Quan acabe pràctiques, exàmens o escenaris, ací veureu què domina, què li costa i què ha de practicar.</p>
        </Card>
      )}
      <div className="grid grid-cols-2 gap-3 sm:grid-cols-4">
        <Tile label="Activitats" value={`${adult.items.length}`} detail="amb nota o objectius" />
        <Tile label="Ho domina" value={`${adult.domina.length}`} detail="80 % o més" />
        <Tile label="Li costa" value={`${adult.costa.length}`} detail="50 % o menys" />
        <Tile label="Última activitat" value={ago(adult.lastActivity)} detail="pràctica, examen o escenari" />
      </div>

      <AdultGroup
        title="Li costa"
        hint="Activitats on té el 50 % o menys d'encerts (o d'objectius complits)."
        empty="Cap activitat, de moment. 🎉"
        tone="coral"
        items={adult.costa}
      />
      <AdultGroup
        title="A practicar"
        hint="Activitats entre el 50 i el 80 %, o ben fetes però amb errors encara sense corregir."
        empty="Cap: tot el que ha fet va molt bé o costa."
        tone="amber"
        items={adult.practicar}
      />
      <AdultGroup
        title="Ho domina"
        hint="Activitats amb el 80 % o més, i sense errors pendents de corregir."
        empty="Encara cap: cal fer unes quantes activitats."
        tone="teal"
        items={adult.domina}
      />

      <Conversations report={report} adult />
    </div>
  );
}

const KIND_LABEL = { practice: 'Pràctica', exam: 'Examen', scenario: 'Escenari' } as const;

/** Un grup d'activitats d'una persona adulta, amb la nota i, si en té, els errors per corregir. */
function AdultGroup({ title, hint, empty, tone, items }: { title: string; hint: string; empty: string; tone: keyof typeof TONES; items: AdultItem[] }) {
  return (
    <Card>
      <h3 className="flex items-center gap-2 text-2xl font-black">
        {title}
        <span className={`rounded-full px-2.5 py-0.5 text-base font-extrabold ${TONES[tone]}`}>{items.length}</span>
      </h3>
      <p className="mt-1 text-base opacity-60">{hint}</p>
      {items.length ? (
        <ul className="mt-3 divide-y divide-gray-100">
          {items.map(i => (
            <li key={i.key} className="flex flex-wrap items-center gap-3 py-3">
              <span className="grid h-12 w-12 shrink-0 place-items-center rounded-full bg-gray-100 text-2xl" aria-hidden="true">{i.emoji}</span>
              <span className="min-w-0 flex-1">
                <span className="block text-lg font-extrabold">{i.name}</span>
                <span className="block text-base opacity-60">
                  {KIND_LABEL[i.kind]} · {i.detail} · {ago(i.lastAt)}
                </span>
                {i.pendingErrors > 0 && (
                  <span className="mt-0.5 block text-base font-bold text-amber-700">
                    {i.pendingErrors} {i.pendingErrors === 1 ? 'error' : 'errors'} per corregir
                  </span>
                )}
              </span>
              <span className={`shrink-0 rounded-full px-3 py-1 text-lg font-black ${TONES[tone]}`}>{percent(i.ratio)}</span>
            </li>
          ))}
        </ul>
      ) : (
        <p className="mt-2 text-lg opacity-70">{empty}</p>
      )}
    </Card>
  );
}
