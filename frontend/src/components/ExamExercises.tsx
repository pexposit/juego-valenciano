import { useState } from 'react';
import { Check, ChevronLeft, ChevronRight, X } from 'lucide-react';
import type { ExamCriterion, ExamOption, ExamProposal, ExamQuestion } from '../lib/types';

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

/* ── Exercici amb opcions pròpies per pregunta (imatges a/b/c) ─────────── */
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

export function MatchExercise({ questions, options, ...props }: AnswerProps & { questions: ExamQuestion[]; options: ExamOption[] }) {
  const grid = options.some(o => o.image || o.sign) ? 'grid-cols-2 sm:grid-cols-3' : 'grid-cols-1 sm:grid-cols-2';
  return (
    <div className="flex flex-col gap-5">
      <div className={`grid gap-4 rounded-2xl bg-cream p-4 ${grid}`}>
        {options.map((o, i) => <MatchOption key={o.key} option={o} index={i} />)}
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
  fields, criteria, maxPoints, values, onChange,
}: {
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
          <p className="font-black">📚 Biblioteca municipal · Sol·licitud de carnet</p>
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

/* ── Expressió oral: propostes amb targetes de preguntes i imatges ─────── */
export function OralExercise({ proposals }: { proposals: ExamProposal[] }) {
  const [active, setActive] = useState(0);
  const [index, setIndex] = useState(0);
  const proposal = proposals[active];
  const total = proposal.questions.length;

  const choose = (i: number) => { setActive(i); setIndex(0); };

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

      <div>
        <p className="mb-2 text-sm font-black uppercase tracking-wide opacity-60">Primera part · Preguntes de l'examinador</p>
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
