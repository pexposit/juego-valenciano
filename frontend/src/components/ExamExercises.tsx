import { useState } from 'react';
import { Check, ChevronLeft, ChevronRight, Loader2, Sparkles, X } from 'lucide-react';
import type { ExamCriterion, ExamOption, ExamProposal, ExamQuestion, ExamReading, ExamWritingChoice, WritingCriterionKey, WritingEvaluation } from '../lib/types';

// Respostes de l'aspirant (número de pregunta -> clau de l'opció) i si l'àrea ja
// s'ha corregit: en eixe cas es marquen les encertades i les errades.
export type AnswerProps = {
  answers: Record<number, string>;
  checked: boolean;
  onAnswer: (n: number, key: string) => void;
};

type Status = 'idle' | 'selected' | 'correct' | 'wrong' | 'missed';

// Estat visual d'una opció: abans de corregir només es marca la triada; després,
// l'encertada en verd-blau, la triada errònia en coral i la correcta no triada, puntejada.
function optionStatus(q: ExamQuestion, key: string, answers: Record<number, string>, checked: boolean): Status {
  const picked = answers[q.n] === key;
  if (!checked) return picked ? 'selected' : 'idle';
  if (key === q.answer) return picked ? 'correct' : 'missed';
  return picked ? 'wrong' : 'idle';
}

const RING: Record<Status, string> = {
  idle: 'border-transparent',
  selected: 'border-teal shadow-lg',
  correct: 'border-teal shadow-lg',
  wrong: 'border-coral shadow-lg',
  missed: 'border-teal border-dashed',
};

const CHIP: Record<Status, string> = {
  idle: 'bg-white text-ink/70 border-ink/15 hover:border-teal hover:text-teal',
  selected: 'bg-teal text-white border-teal',
  correct: 'bg-teal text-white border-teal',
  wrong: 'bg-coral text-white border-coral',
  missed: 'bg-white text-teal border-teal border-dashed',
};

function QuestionNumber({ n, result }: { n: number; result?: boolean }) {
  return (
    <span
      className={`grid h-8 w-8 shrink-0 place-items-center rounded-full text-sm font-black ${
        result === undefined ? 'bg-mustard/40 text-ink' : result ? 'bg-teal text-white' : 'bg-coral text-white'
      }`}
    >
      {result === undefined ? n : result ? <Check size={16} /> : <X size={16} />}
    </span>
  );
}

const resultOf = (q: ExamQuestion, answers: Record<number, string>, checked: boolean) =>
  checked ? answers[q.n] === q.answer : undefined;

// Lletres per a triar una opció compartida (V/F, Sí/No, a–f).
function OptionChips({ q, options, answers, checked, onAnswer }: AnswerProps & { q: ExamQuestion; options: ExamOption[] }) {
  return (
    <div className="flex flex-wrap gap-1.5">
      {options.map(o => {
        const status = optionStatus(q, o.key, answers, checked);
        return (
          <button
            key={o.key}
            disabled={checked}
            onClick={() => onAnswer(q.n, o.key)}
            aria-pressed={answers[q.n] === o.key}
            className={`btn-press min-w-10 rounded-full border-2 px-3 py-1.5 text-sm font-black uppercase transition-colors disabled:cursor-default ${CHIP[status]}`}
          >
            {o.text && o.text.length <= 8 ? o.text : o.key}
          </button>
        );
      })}
    </div>
  );
}

/* ── Text de lectura dels exercicis de comprensió escrita ─────────────── */
export function Reading({ reading }: { reading: ExamReading }) {
  return (
    <div className="mb-6 rounded-2xl border-l-4 border-mustard bg-cream px-6 py-5">
      {reading.title && <h3 className="mb-3 text-xl font-black">{reading.title}</h3>}
      <div className="flex flex-col gap-3 leading-relaxed">
        {reading.paragraphs.map(p => <p key={p.slice(0, 40)}>{p}</p>)}
      </div>
    </div>
  );
}

/* ── Opció de text en una llista (a, b, c) ─────────────────────────────── */
function TextOption({ q, option, ...props }: AnswerProps & { q: ExamQuestion; option: ExamOption }) {
  const status = optionStatus(q, option.key, props.answers, props.checked);
  const box = {
    idle: 'border-ink/10 bg-white hover:border-teal/60',
    selected: 'border-teal bg-teal/10',
    correct: 'border-teal bg-teal/10',
    wrong: 'border-coral bg-coral/10',
    missed: 'border-teal border-dashed bg-white',
  }[status];
  return (
    <button
      disabled={props.checked}
      onClick={() => props.onAnswer(q.n, option.key)}
      aria-pressed={props.answers[q.n] === option.key}
      className={`btn-press flex w-full items-center gap-3 rounded-xl border-2 px-4 py-2.5 text-left transition-colors disabled:cursor-default ${box}`}
    >
      <span className={`grid h-7 w-7 shrink-0 place-items-center rounded-full text-sm font-black uppercase ${CHIP[status]}`}>
        {option.key}
      </span>
      <span className="font-bold">{option.text}</span>
    </button>
  );
}

/* ── Exercici amb opcions pròpies per pregunta (imatges o frases a/b/c) ── */
export function ChoiceExercise({ questions, ...props }: AnswerProps & { questions: ExamQuestion[] }) {
  const { answers, checked, onAnswer } = props;
  return (
    <div className="flex flex-col gap-6">
      {questions.map(q => (
        <div key={q.n}>
          <div className="mb-3 flex items-center gap-3">
            <QuestionNumber n={q.n} result={resultOf(q, answers, checked)} />
            <p className="text-lg font-black">{q.prompt}</p>
          </div>
          {q.options?.every(o => !o.image) ? (
            <div className="flex flex-col gap-2 pl-11">
              {q.options.map(o => <TextOption key={o.key} q={q} option={o} {...props} />)}
            </div>
          ) : (
          <div className="grid grid-cols-3 gap-3">
            {(q.options ?? []).map(o => {
              const status = optionStatus(q, o.key, answers, checked);
              return (
                <button
                  key={o.key}
                  disabled={checked}
                  onClick={() => onAnswer(q.n, o.key)}
                  aria-pressed={answers[q.n] === o.key}
                  aria-label={`Opció ${o.key}`}
                  className={`btn-press group relative overflow-hidden rounded-2xl border-4 bg-white transition-all disabled:cursor-default ${RING[status]}`}
                >
                  <img src={o.image} alt="" className="aspect-[4/3] w-full object-contain p-1 transition-transform group-hover:scale-[1.03]" />
                  <span className={`absolute left-2 top-2 grid h-7 w-7 place-items-center rounded-full text-sm font-black uppercase shadow ${
                    status === 'idle' ? 'bg-white text-ink' : status === 'wrong' ? 'bg-coral text-white' : 'bg-teal text-white'
                  }`}>
                    {o.key}
                  </span>
                </button>
              );
            })}
          </div>
          )}
        </div>
      ))}
    </div>
  );
}

/* ── Exercici d'opció binària (V/F, Sí/No) ─────────────────────────────── */
export function BinaryExercise({ questions, options, ...props }: AnswerProps & { questions: ExamQuestion[]; options: ExamOption[] }) {
  const withImages = questions.some(q => q.image);
  if (withImages) {
    return (
      <div className="grid grid-cols-2 gap-3 sm:grid-cols-4">
        {questions.map(q => (
          <div key={q.n} className="flex flex-col items-center gap-2 rounded-2xl bg-cream p-3">
            <div className="flex w-full items-center justify-between">
              <QuestionNumber n={q.n} result={resultOf(q, props.answers, props.checked)} />
              <span className="text-sm font-bold opacity-70">{q.prompt}</span>
            </div>
            <img src={q.image} alt={q.prompt} className="h-24 w-full object-contain" />
            <OptionChips q={q} options={options} {...props} />
          </div>
        ))}
      </div>
    );
  }
  return (
    <ul className="flex flex-col divide-y divide-ink/10">
      {questions.map(q => (
        <li key={q.n} className="flex items-center gap-3 py-3">
          <QuestionNumber n={q.n} result={resultOf(q, props.answers, props.checked)} />
          <p className="flex-1 font-bold">{q.prompt}</p>
          <OptionChips q={q} options={options} {...props} />
        </li>
      ))}
    </ul>
  );
}

/* ── Exercici de relacionar amb opcions compartides (missatges, rètols, imatges) ── */
const SIGN_STYLES = [
  'rounded-3xl border-teal',
  'rounded-[50%] border-orange',
  'rounded-tl-[3rem] rounded-br-[3rem] border-mustard',
  'rounded-md border-navy',
  'rounded-2xl border-coral',
  'rounded-r-[3rem] border-teal',
];

function MatchOption({ option, index }: { option: ExamOption; index: number }) {
  const letter = (
    <span className="grid h-7 w-7 shrink-0 place-items-center rounded-full bg-ink text-sm font-black uppercase text-white">
      {option.key}
    </span>
  );
  if (option.image) {
    return (
      <figure className="relative overflow-hidden rounded-2xl bg-white shadow-sm">
        <img src={option.image} alt="" className="aspect-[4/3] w-full object-cover" />
        <span className="absolute left-2 top-2">{letter}</span>
      </figure>
    );
  }
  if (option.sign) {
    return (
      <div className="relative">
        <span className="absolute -left-2 -top-2 z-10">{letter}</span>
        <div className={`flex h-full flex-col items-center justify-center gap-1 border-4 bg-white px-6 py-5 text-center shadow-sm ${SIGN_STYLES[index % SIGN_STYLES.length]}`}>
          <p className="text-lg font-black uppercase tracking-wide">{option.sign.title}</p>
          {option.sign.lines.map(line => <p key={line} className="text-sm">{line}</p>)}
        </div>
      </div>
    );
  }
  // Missatge de text, amb forma de bombolla de xat.
  return (
    <div className="flex items-start gap-2">
      {letter}
      <p className="rounded-2xl rounded-tl-sm bg-white px-4 py-3 text-sm shadow-sm">{option.text}</p>
    </div>
  );
}

export function MatchExercise({ questions, options, optionsTitle, ...props }: AnswerProps & { questions: ExamQuestion[]; options: ExamOption[]; optionsTitle?: string }) {
  const grid = options.some(o => o.image || o.sign) ? 'grid-cols-2 sm:grid-cols-3' : 'grid-cols-1 sm:grid-cols-2';
  return (
    <div className="flex flex-col gap-5">
      <div className="rounded-2xl bg-cream p-4">
        {optionsTitle && <h3 className="mb-3 text-center text-lg font-black">{optionsTitle}</h3>}
        <div className={`grid gap-4 ${grid}`}>
          {options.map((o, i) => <MatchOption key={o.key} option={o} index={i} />)}
        </div>
      </div>
      <ul className="flex flex-col divide-y divide-ink/10">
        {questions.map(q => (
          <li key={q.n} className="flex flex-wrap items-center gap-3 py-3">
            <QuestionNumber n={q.n} result={resultOf(q, props.answers, props.checked)} />
            <p className="min-w-[12rem] flex-1 font-bold">{q.prompt}</p>
            <OptionChips q={q} options={options} {...props} />
          </li>
        ))}
      </ul>
    </div>
  );
}

/* ── Expressió escrita: formulari lliure amb la rúbrica d'avaluació ────── */
export function FormExercise({
  title, fields, criteria, maxPoints, values, onChange,
}: {
  title?: string;
  fields: string[];
  criteria: ExamCriterion[];
  maxPoints: number;
  values: Record<string, string>;
  onChange: (field: string, value: string) => void;
}) {
  const filled = fields.filter(f => values[f]?.trim()).length;
  return (
    <div className="flex flex-col gap-5">
      <div className="overflow-hidden rounded-2xl border-2 border-teal/30 bg-white">
        <div className="flex items-center justify-between bg-teal px-5 py-3 text-white">
          <p className="font-black">📝 {title ?? 'Formulari'}</p>
          <span className="rounded-full bg-white/20 px-3 py-1 text-xs font-black">{filled}/{fields.length} camps</span>
        </div>
        <div className="grid gap-4 p-5 sm:grid-cols-2">
          {fields.map(field => {
            const long = field.length > 30;
            return (
              <label key={field} className={`flex flex-col gap-1 ${long ? 'sm:col-span-2' : ''}`}>
                <span className="text-xs font-black uppercase tracking-wide opacity-60">{field}</span>
                {long ? (
                  <textarea
                    rows={2}
                    value={values[field] ?? ''}
                    onChange={e => onChange(field, e.target.value)}
                    className="rounded-xl border-2 border-ink/10 bg-cream px-3 py-2 outline-none transition-colors focus:border-teal"
                  />
                ) : (
                  <input
                    value={values[field] ?? ''}
                    onChange={e => onChange(field, e.target.value)}
                    className="rounded-xl border-2 border-ink/10 bg-cream px-3 py-2 outline-none transition-colors focus:border-teal"
                  />
                )}
              </label>
            );
          })}
        </div>
      </div>

      <details className="rounded-2xl bg-cream p-4">
        <summary className="cursor-pointer font-black">Com s'avalua? (fins a {maxPoints} punts)</summary>
        <div className="mt-3 grid gap-4 sm:grid-cols-2">
          {criteria.map(c => (
            <div key={c.title}>
              <p className="mb-1 text-sm font-black text-teal">{c.title}</p>
              <ul className="flex flex-col gap-1 text-sm">
                {c.items.map(i => <li key={i.name}><b>{i.name}.</b> {i.description}</li>)}
              </ul>
            </div>
          ))}
        </div>
      </details>
    </div>
  );
}

/* ── Expressió escrita: redacció lliure amb límit de paraules ─────────── */
const countWords = (text: string) => text.trim().split(/\s+/).filter(Boolean).length;
const normalize = (text: string) => text.toLocaleLowerCase('ca').normalize('NFD').replace(/\p{M}/gu, '');
// Formes acceptades d'una paraula: singular i plural (estoig/estoigs, agenda/agendes).
// Una paraula amb gènere com «malalt/a» accepta també el femení (malalta, malaltes).
const wordForms = (word: string) => {
  const [base, feminine] = normalize(word).split('/');
  const forms = (w: string) => [w, `${w}s`, w.endsWith('a') ? `${w.slice(0, -1)}es` : w];
  return new Set([...forms(base), ...(feminine ? forms(base + feminine) : [])]);
};

export function WritingExercise({
  title, minWords, maxWords, words = [], minWordsUsed = 0, image, choices = [], choice, onChoose, value, onChange,
}: {
  title?: string;
  minWords: number;
  maxWords: number;
  words?: string[];
  minWordsUsed?: number;
  image?: string;
  choices?: ExamWritingChoice[];
  choice?: string;
  onChoose?: (key: string) => void;
  value: string;
  onChange: (value: string) => void;
}) {
  const count = countWords(value);
  const inRange = count >= minWords && count <= maxWords;
  // Una paraula compta com a usada també en plural o amb majúscules (estoigs, Llapis...).
  const tokens = new Set(normalize(value).split(/[^\p{L}·]+/u).filter(Boolean));
  const used = new Set(words.filter(w => [...wordForms(w)].some(f => tokens.has(f))));
  const countColor = count === 0 ? 'bg-white/20' : inRange ? 'bg-white text-teal' : 'bg-coral';

  const picked = choices.find(c => c.key === choice);

  const editor = (
    <div className="flex flex-col gap-4">
      {words.length > 0 && (
        <div className="rounded-2xl bg-cream p-4">
          <p className="mb-2 text-sm font-black">
            Utilitza com a mínim {minWordsUsed} d'estes paraules (en singular o en plural):{' '}
            <span className={used.size >= minWordsUsed ? 'text-teal' : 'opacity-60'}>{used.size}/{minWordsUsed}</span>
          </p>
          <div className="flex flex-wrap gap-2">
            {words.map(w => (
              <span
                key={w}
                className={`flex items-center gap-1 rounded-full border-2 px-3 py-1 text-sm font-black transition-colors ${
                  used.has(w) ? 'border-teal bg-teal text-white' : 'border-ink/10 bg-white text-ink/70'
                }`}
              >
                {used.has(w) && <Check size={14} />} {w}
              </span>
            ))}
          </div>
        </div>
      )}

      <div className="overflow-hidden rounded-2xl border-2 border-teal/30 bg-white">
        <div className="flex items-center justify-between bg-teal px-5 py-3 text-white">
          <p className="font-black">📌 {picked ? `Opció ${picked.key}` : title ?? 'Redacció'}</p>
          <span className={`rounded-full px-3 py-1 text-xs font-black ${countColor}`}>
            {count} paraules · {minWords}–{maxWords}
          </span>
        </div>
        <textarea
          rows={9}
          value={value}
          onChange={e => onChange(e.target.value)}
          placeholder="Escriu ací el teu text..."
          className="w-full resize-y bg-[repeating-linear-gradient(transparent,transparent_31px,#E7E5E4_32px)] px-5 py-3 leading-8 outline-none"
        />
      </div>
    </div>
  );

  return (
    <div className="flex flex-col gap-4">
      {choices.length > 0 && (
        <div>
          <p className="mb-2 text-sm font-black uppercase tracking-wide opacity-60">Tria una de les dos opcions</p>
          <div className="grid gap-3 sm:grid-cols-2">
            {choices.map(c => (
              <button
                key={c.key}
                onClick={() => onChoose?.(c.key)}
                aria-pressed={c.key === choice}
                className={`btn-press flex flex-col gap-2 rounded-3xl border-2 p-5 text-left transition-colors ${
                  c.key === choice ? 'border-navy bg-navy text-white shadow-lg' : 'border-ink/10 bg-cream hover:border-navy/40'
                }`}
              >
                <span className={`text-xs font-black uppercase tracking-widest ${c.key === choice ? 'text-mustard' : 'text-teal'}`}>
                  Opció {c.key}{c.key === choice ? ' · triada' : ''}
                </span>
                <span className="leading-relaxed">{c.text}</span>
                {c.points && c.points.length > 0 && (
                  <ul className="mt-1 flex flex-col gap-1 text-sm">
                    {c.points.map(pt => (
                      <li key={pt} className="flex gap-2"><Check size={14} className="mt-1 shrink-0 opacity-70" /> {pt}</li>
                    ))}
                  </ul>
                )}
              </button>
            ))}
          </div>
        </div>
      )}

      {choices.length > 0 && !picked ? (
        <p className="rounded-2xl bg-cream p-4 text-center text-sm font-bold opacity-70">Tria una opció per a començar a escriure.</p>
      ) : image ? (
        <div className="grid gap-4 md:grid-cols-[minmax(0,16rem)_1fr]">
          <img src={image} alt="Imatge de suport de l'exercici" className="w-full rounded-2xl shadow-sm" />
          {editor}
        </div>
      ) : (
        editor
      )}
    </div>
  );
}

/* ── Expressió oral: propostes amb preguntes, imatges o diàleg per rols ── */
export function OralExercise({ proposals }: { proposals: ExamProposal[] }) {
  const [active, setActive] = useState(0);
  const [index, setIndex] = useState(0);
  const [role, setRole] = useState(0);
  const proposal = proposals[active];
  const total = proposal.questions.length;

  const choose = (i: number) => { setActive(i); setIndex(0); setRole(0); };

  return (
    <div className="flex flex-col gap-5">
      <div className="flex flex-wrap gap-2">
        {proposals.map((p, i) => (
          <button
            key={p.title}
            onClick={() => choose(i)}
            className={`btn-press rounded-full px-4 py-2 text-sm font-black transition-colors ${
              i === active ? 'bg-teal text-white' : 'bg-cream text-teal hover:bg-teal/10'
            }`}
          >
            {p.title}
          </button>
        ))}
      </div>

      {(proposal.intro || proposal.duration) && (
        <p className="flex flex-wrap items-center gap-2 font-bold opacity-80">
          {proposal.duration && (
            <span className="rounded-full bg-mustard/40 px-3 py-1 text-xs font-black text-ink">⏱ {proposal.duration}</span>
          )}
          {proposal.intro}
        </p>
      )}

      {total > 0 && (
      <div>
        <p className="mb-2 text-sm font-black uppercase tracking-wide opacity-60">Preguntes de l'examinador</p>
        <div className="flex items-center gap-3 rounded-3xl bg-navy p-6 text-white">
          <button
            onClick={() => setIndex(i => Math.max(0, i - 1))}
            disabled={index === 0}
            aria-label="Pregunta anterior"
            className="btn-press grid h-10 w-10 shrink-0 place-items-center rounded-full bg-white/10 hover:bg-white/20 disabled:opacity-30"
          >
            <ChevronLeft size={20} />
          </button>
          <div className="flex-1 text-center">
            <p className="text-xs font-black uppercase tracking-widest text-mustard">Pregunta {index + 1} de {total}</p>
            <p key={`${active}-${index}`} className="fade-up mt-2 text-2xl font-black">{proposal.questions[index]}</p>
          </div>
          <button
            onClick={() => setIndex(i => Math.min(total - 1, i + 1))}
            disabled={index === total - 1}
            aria-label="Pregunta següent"
            className="btn-press grid h-10 w-10 shrink-0 place-items-center rounded-full bg-white/10 hover:bg-white/20 disabled:opacity-30"
          >
            <ChevronRight size={20} />
          </button>
        </div>
        <div className="mt-2 flex justify-center gap-1">
          {proposal.questions.map((_, i) => (
            <button
              key={i}
              onClick={() => setIndex(i)}
              aria-label={`Pregunta ${i + 1}`}
              className={`h-2 rounded-full transition-all ${i === index ? 'w-6 bg-teal' : 'w-2 bg-ink/20'}`}
            />
          ))}
        </div>
      </div>
      )}

      {proposal.roles && proposal.roles.length > 0 && (
        <div>
          <p className="mb-2 text-sm font-black uppercase tracking-wide opacity-60">Tria el teu paper i defén la teua proposta</p>
          <div className="grid gap-3 sm:grid-cols-2">
            {proposal.roles.map((r, i) => (
              <button
                key={r.name}
                onClick={() => setRole(i)}
                aria-pressed={i === role}
                className={`btn-press flex flex-col gap-2 rounded-3xl border-2 p-5 text-left transition-colors ${
                  i === role ? 'border-navy bg-navy text-white shadow-lg' : 'border-ink/10 bg-cream hover:border-navy/40'
                }`}
              >
                <span className={`text-xs font-black uppercase tracking-widest ${i === role ? 'text-mustard' : 'text-teal'}`}>
                  {i === role ? `Tu eres la ${r.name.toLowerCase()}` : r.name}
                </span>
                <span className="leading-relaxed">{r.text}</span>
              </button>
            ))}
          </div>
        </div>
      )}

      {proposal.images.length > 0 && (
        <div>
          <p className="mb-2 text-sm font-black uppercase tracking-wide opacity-60">Segona part · Respon mirant les imatges</p>
          <div className="grid grid-cols-2 gap-3 sm:grid-cols-3">
            {proposal.images.map(item => (
              <figure key={item.prompt} className="overflow-hidden rounded-2xl bg-white shadow-sm">
                <img src={item.image} alt="" className="aspect-[4/3] w-full object-cover" />
                <figcaption className="px-3 py-2 text-sm font-black">{item.prompt}</figcaption>
              </figure>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}

const CRITERION_LABELS: Record<WritingCriterionKey, string> = {
  lexic: 'Lèxic',
  estructures: 'Estructures',
  ortografia: 'Ortografia',
  comprensibilitat_coherencia: 'Comprensibilitat i coherència',
  adequacio: 'Adequació',
};

// Color de cada franja: les dues de dalt aproven, les dues de baix són eliminatòries.
const BAND_STYLE: Record<string, string> = {
  '15-12': 'bg-teal text-white',
  '11-9': 'bg-mustard text-navy',
  '8-6': 'bg-orange text-white',
  '5-1': 'bg-coral text-white',
};

// Botó "Avaluar" i resultat de l'avaluació amb IA d'un exercici d'expressió escrita.
export function WritingEvaluationPanel({
  evaluation, loading, error, canEvaluate, onEvaluate,
}: {
  evaluation?: WritingEvaluation;
  loading: boolean;
  error?: string;
  canEvaluate: boolean;
  onEvaluate: () => void;
}) {
  const pass = evaluation?.resultat === 'no eliminatòria';
  return (
    <div className="mt-5 flex flex-col gap-4">
      <div className="flex flex-wrap items-center gap-3">
        <button
          onClick={onEvaluate}
          disabled={loading || !canEvaluate}
          className="btn-press flex items-center gap-2 rounded-full bg-orange px-6 py-3 font-black text-white shadow hover:bg-orange/90 disabled:cursor-not-allowed disabled:opacity-50"
        >
          {loading ? <Loader2 size={18} className="animate-spin" /> : <Sparkles size={18} />}
          {loading ? 'Avaluant…' : evaluation ? 'Tornar a avaluar' : 'Avaluar'}
        </button>
        {!canEvaluate && !loading && <p className="text-sm font-bold opacity-60">Omple el formulari per a poder avaluar-lo.</p>}
        {loading && <p className="text-sm font-bold opacity-60">L'avaluador està revisant el teu text amb la normativa de l'AVL. Pot tardar un poc.</p>}
      </div>
      {error && <p className="rounded-2xl bg-coral/10 p-4 text-sm font-bold text-coral">{error}</p>}

      {evaluation && !loading && (
        <section className={`fade-up flex flex-col gap-5 rounded-2xl border-2 p-5 ${pass ? 'border-teal/30' : 'border-coral/40'}`}>
          <div className="flex flex-wrap items-center gap-5">
            <div
              className="grid h-24 w-24 shrink-0 place-items-center rounded-full"
              style={{ background: `conic-gradient(${pass ? '#2CA99B' : '#FF675D'} ${(evaluation.puntuacio_global / 15) * 360}deg, #E7E5E4 0deg)` }}
              aria-label={`${evaluation.puntuacio_global} de 15 punts`}
            >
              <div className="grid place-items-center rounded-full bg-white" style={{ height: '4.5rem', width: '4.5rem' }}>
                <span className="text-center leading-none">
                  <span className="block text-xl font-black">{evaluation.puntuacio_global}/15</span>
                  <span className="text-[10px] font-black uppercase opacity-60">punts</span>
                </span>
              </div>
            </div>
            <div className="min-w-[12rem] flex-1">
              <p className={`text-sm font-black uppercase tracking-wide ${pass ? 'text-teal' : 'text-coral'}`}>Avaluació de l'expressió escrita</p>
              <p className="text-2xl font-black">{pass ? '✅ No eliminatòria' : '❌ Eliminatòria'}</p>
              <p className="mt-1 text-sm opacity-70">Cal arribar a 9 de 15 punts perquè no siga eliminatòria.</p>
            </div>
          </div>

          <p className="rounded-2xl bg-cream p-4 font-bold">{evaluation.retorn_pedagogic}</p>

          <div className="grid gap-3 sm:grid-cols-2">
            {(Object.keys(CRITERION_LABELS) as WritingCriterionKey[]).map(key => {
              const c = evaluation.criteris[key];
              return (
                <div key={key} className="rounded-2xl border-2 border-ink/10 p-4">
                  <div className="mb-1 flex items-center justify-between gap-2">
                    <p className="font-black">{CRITERION_LABELS[key]}</p>
                    <span className={`rounded-full px-3 py-1 text-xs font-black ${BAND_STYLE[c.franja] ?? 'bg-cream'}`}>{c.franja}</span>
                  </div>
                  <p className="text-sm opacity-80">{c.observacions}</p>
                </div>
              );
            })}
          </div>

          {evaluation.errors_destacats.length > 0 && (
            <div>
              <p className="mb-2 font-black">Errors destacats</p>
              <ul className="flex flex-col gap-2">
                {evaluation.errors_destacats.map((e, i) => (
                  <li key={i} className="flex flex-wrap items-center gap-2 rounded-xl bg-cream px-3 py-2 text-sm">
                    <span className="font-bold text-coral line-through">{e.element_original}</span>
                    <span aria-hidden="true">→</span>
                    <span className="font-black text-teal">{e.correccio_suggerida}</span>
                    <span className="ml-auto rounded-full bg-white px-2 py-0.5 text-xs font-black opacity-70">
                      {e.tipus} · {e.gravetat}
                    </span>
                  </li>
                ))}
              </ul>
            </div>
          )}
        </section>
      )}
    </div>
  );
}
