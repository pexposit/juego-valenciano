import { useState, type ReactNode } from 'react';
import { ArrowDown, ArrowUp, Eye, Plus, Trash2, X } from 'lucide-react';
import {
  CEFR_LEVELS,
  classLevelLabel,
  isLevel0Class,
  SCENARIO_BACKGROUNDS,
  SCENARIO_VOICES,
  TEACHER_ACTIVITY_LIMITS as L,
  TEACHER_EXERCISE_AREAS,
  type TeacherActivity,
  type TeacherActivityInput,
  type TeacherChoiceQuestion,
  type TeacherFillQuestion,
} from '@parlaval/shared';
import { categoryLabel } from '../../components/ScenarioSelect';
import { saveTeacherActivity } from '../../lib/api';
import type { KidsClass } from '../kids/tracking';
import { ACTIVITY_KINDS, cleanActivity, emptyChoice, emptyFill, ICONS, problemsOf } from './drafts';

const FIELD = 'w-full rounded-2xl border-2 border-gray-100 p-3 text-lg outline-none focus:border-[#0F47AF] transition-colors bg-white';
const SMALL_FIELD = 'w-full rounded-xl border-2 border-gray-100 px-3 py-2 outline-none focus:border-[#0F47AF] transition-colors bg-white';
const ICON_BUTTON = 'btn-press grid h-9 w-9 shrink-0 place-items-center rounded-full text-gray-500 hover:bg-gray-100 disabled:opacity-25';

function Field({ label, hint, children }: { label: string; hint?: string; children: ReactNode }) {
  return (
    <label className="block">
      <span className="text-sm font-extrabold">{label}</span>
      {hint && <span className="ml-2 text-sm opacity-50">{hint}</span>}
      <span className="mt-1 block">{children}</span>
    </label>
  );
}

/** Mou un element d'una llista (per a reordenar preguntes). */
const moved = <T,>(list: T[], i: number, delta: number) => {
  const next = [...list];
  [next[i], next[i + delta]] = [next[i + delta], next[i]];
  return next;
};

/* ── Preguntes (exercicis i comprensió) ───────────────────────────────── */

type Question = TeacherChoiceQuestion | TeacherFillQuestion;

function QuestionEditor({ q, n, total, choiceOnly, onChange, onMove, onRemove }: {
  q: Question;
  n: number;
  total: number;
  choiceOnly: boolean;
  onChange: (q: Question) => void;
  onMove: (delta: number) => void;
  onRemove: () => void;
}) {
  const switchType = (type: Question['type']) => {
    if (type === q.type) return;
    onChange(type === 'choice'
      ? { ...emptyChoice(), prompt: q.prompt, explanation: q.explanation }
      : { ...emptyFill(), prompt: q.prompt, explanation: q.explanation });
  };

  return (
    <li className="rounded-2xl border-2 border-gray-100 p-4">
      <div className="mb-3 flex flex-wrap items-center gap-2">
        <span className="grid h-8 w-8 place-items-center rounded-full bg-[#0F47AF] font-black text-white">{n}</span>
        {!choiceOnly && (
          <div className="flex rounded-full bg-gray-100 p-1 text-sm font-bold">
            {(['choice', 'fill'] as const).map(type => (
              <button
                key={type}
                type="button"
                onClick={() => switchType(type)}
                className={`rounded-full px-3 py-1 ${q.type === type ? 'bg-white shadow' : 'opacity-60'}`}
              >
                {type === 'choice' ? 'Opció múltiple' : 'Escriure la resposta'}
              </button>
            ))}
          </div>
        )}
        <span className="flex-1" />
        <button type="button" onClick={() => onMove(-1)} disabled={n === 1} aria-label="Puja la pregunta" className={ICON_BUTTON}><ArrowUp size={18} /></button>
        <button type="button" onClick={() => onMove(1)} disabled={n === total} aria-label="Baixa la pregunta" className={ICON_BUTTON}><ArrowDown size={18} /></button>
        <button type="button" onClick={onRemove} disabled={total === 1} aria-label="Esborra la pregunta" className={`${ICON_BUTTON} hover:text-coral`}><Trash2 size={18} /></button>
      </div>

      <Field label="Enunciat">
        <input value={q.prompt} maxLength={L.prompt} onChange={e => onChange({ ...q, prompt: e.target.value })}
          placeholder={q.type === 'choice' ? 'Ex.: ___ he vist (el cotxe).' : 'Ex.: Escriu la contracció: a + els'} className={SMALL_FIELD} />
      </Field>

      {q.type === 'choice' ? (
        <div className="mt-3">
          <span className="text-sm font-extrabold">Opcions</span>
          <span className="ml-2 text-sm opacity-50">marca la correcta</span>
          <ul className="mt-1 flex flex-col gap-2">
            {q.options.map((option, i) => (
              <li key={i} className="flex items-center gap-2">
                <input
                  type="radio"
                  name={`correct-${n}`}
                  checked={q.correct === i}
                  onChange={() => onChange({ ...q, correct: i })}
                  aria-label={`L'opció ${i + 1} és la correcta`}
                  className="h-5 w-5 accent-teal"
                />
                <input
                  value={option}
                  maxLength={L.option}
                  onChange={e => onChange({ ...q, options: q.options.map((o, j) => (j === i ? e.target.value : o)) })}
                  placeholder={`Opció ${i + 1}`}
                  className={`${SMALL_FIELD} ${q.correct === i ? 'border-teal/50' : ''}`}
                />
                <button
                  type="button"
                  disabled={q.options.length <= 2}
                  onClick={() => onChange({ ...q, options: q.options.filter((_, j) => j !== i), correct: q.correct === i ? 0 : q.correct > i ? q.correct - 1 : q.correct })}
                  aria-label={`Lleva l'opció ${i + 1}`}
                  className={ICON_BUTTON}
                >
                  <X size={16} />
                </button>
              </li>
            ))}
          </ul>
          {q.options.length < L.options && (
            <button type="button" onClick={() => onChange({ ...q, options: [...q.options, ''] })} className="btn-press mt-2 flex items-center gap-1 text-sm font-bold text-[#0F47AF]">
              <Plus size={16} /> Afig una opció
            </button>
          )}
        </div>
      ) : (
        <div className="mt-3">
          <span className="text-sm font-extrabold">Respostes correctes</span>
          <span className="ml-2 text-sm opacity-50">en la correcció no compten les majúscules ni els espais</span>
          <ul className="mt-1 flex flex-col gap-2">
            {q.answers.map((answer, i) => (
              <li key={i} className="flex items-center gap-2">
                <input
                  value={answer}
                  maxLength={L.option}
                  onChange={e => onChange({ ...q, answers: q.answers.map((a, j) => (j === i ? e.target.value : a)) })}
                  placeholder={i === 0 ? 'Resposta' : 'Una altra resposta vàlida'}
                  className={SMALL_FIELD}
                />
                <button type="button" disabled={q.answers.length <= 1} onClick={() => onChange({ ...q, answers: q.answers.filter((_, j) => j !== i) })}
                  aria-label={`Lleva la resposta ${i + 1}`} className={ICON_BUTTON}>
                  <X size={16} />
                </button>
              </li>
            ))}
          </ul>
          {q.answers.length < L.answers && (
            <button type="button" onClick={() => onChange({ ...q, answers: [...q.answers, ''] })} className="btn-press mt-2 flex items-center gap-1 text-sm font-bold text-[#0F47AF]">
              <Plus size={16} /> Afig una altra resposta vàlida
            </button>
          )}
        </div>
      )}

      <div className="mt-3">
        <Field label="Explicació" hint="opcional: es mostra en corregir">
          <input value={q.explanation} maxLength={L.explanation} onChange={e => onChange({ ...q, explanation: e.target.value })} className={SMALL_FIELD} />
        </Field>
      </div>
    </li>
  );
}

function QuestionList<Q extends Question>({ questions, max, choiceOnly, onChange }: {
  questions: Q[];
  max: number;
  choiceOnly: boolean;
  onChange: (questions: Q[]) => void;
}) {
  return (
    <div>
      <p className="text-sm font-extrabold">Preguntes ({questions.length}/{max})</p>
      <ol className="mt-2 flex flex-col gap-3">
        {questions.map((q, i) => (
          <QuestionEditor
            key={i}
            q={q}
            n={i + 1}
            total={questions.length}
            choiceOnly={choiceOnly}
            onChange={next => onChange(questions.map((x, j) => (j === i ? next : x)) as Q[])}
            onMove={delta => onChange(moved(questions, i, delta))}
            onRemove={() => onChange(questions.filter((_, j) => j !== i))}
          />
        ))}
      </ol>
      {questions.length < max && (
        <div className="mt-3 flex flex-wrap gap-2">
          <button type="button" onClick={() => onChange([...questions, emptyChoice() as Q])} className="btn-press flex items-center gap-1 rounded-2xl bg-gray-50 px-4 py-2 font-bold text-[#0F47AF] hover:bg-gray-100">
            <Plus size={18} /> Pregunta d'opció múltiple
          </button>
          {!choiceOnly && (
            <button type="button" onClick={() => onChange([...questions, emptyFill() as Q])} className="btn-press flex items-center gap-1 rounded-2xl bg-gray-50 px-4 py-2 font-bold text-[#0F47AF] hover:bg-gray-100">
              <Plus size={18} /> Pregunta d'escriure la resposta
            </button>
          )}
        </div>
      )}
    </div>
  );
}

/* ── L'editor ─────────────────────────────────────────────────────────── */

/**
 * Formulari d'una activitat de la docent. Cada tipus és una plantilla tancada amb la mateixa
 * forma que les activitats del catàleg: la docent només omplin camps, i l'activitat es pinta
 * amb les mateixes pantalles que la resta.
 */
export function ActivityEditor({ initial, id, classes, onSaved, onCancel, onPreview }: {
  initial: TeacherActivityInput;
  id?: string;
  classes: KidsClass[];
  onSaved: (activity: TeacherActivity) => void;
  onCancel: () => void;
  onPreview: (activity: TeacherActivityInput) => void;
}) {
  const [draft, setDraft] = useState(initial);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string>();
  const [showProblems, setShowProblems] = useState(false);
  const set = (patch: Partial<TeacherActivityInput>) => setDraft(d => ({ ...d, ...patch }));
  const c = draft.content;
  const setContent = (patch: Partial<typeof c>) => setDraft(d => ({ ...d, content: { ...d.content, ...patch } as typeof d.content }));
  const kind = ACTIVITY_KINDS.find(k => k.kind === c.kind)!;
  const problems = problemsOf(draft);

  const save = async () => {
    if (problems.length) return setShowProblems(true);
    setSaving(true);
    setError(undefined);
    try {
      onSaved(await saveTeacherActivity(cleanActivity(draft), id));
    } catch (e) {
      setError(e instanceof Error ? e.message : "No hem pogut guardar l'activitat");
    } finally {
      setSaving(false);
    }
  };

  const toggleClass = (classId: string) =>
    set({ class_ids: draft.class_ids.includes(classId) ? draft.class_ids.filter(x => x !== classId) : [...draft.class_ids, classId] });

  return (
    <div className="flex flex-col gap-5">
      <div>
        <p className="text-sm font-black uppercase tracking-wide text-teal">{kind.icon} {kind.label}</p>
        <p className="text-base opacity-60">{kind.hint}</p>
      </div>

      <section className="grid gap-4 rounded-3xl bg-white p-5 shadow-sm sm:grid-cols-[1fr_auto]">
        <Field label="Títol" hint="el veu l'alumnat en «Activitats»">
          <input value={draft.title} maxLength={L.title} onChange={e => set({ title: e.target.value })} placeholder="Ex.: Pronoms febles del tema 3" className={FIELD} />
        </Field>
        <Field label="Nivell">
          <select
            value={draft.level}
            // Les classes d'un altre nivell no poden tindre l'activitat: es lleven de la tria.
            onChange={e => {
              const level = e.target.value as TeacherActivityInput['level'];
              set({ level, class_ids: draft.class_ids.filter(id => classes.find(k => k.id === id)?.levels.includes(level)) });
            }}
            className={FIELD}
          >
            {CEFR_LEVELS.map(l => <option key={l} value={l}>{l}</option>)}
          </select>
        </Field>
        <div className="sm:col-span-2">
          <Field label="Descripció" hint="opcional">
            <input value={draft.description} maxLength={L.description} onChange={e => set({ description: e.target.value })} className={FIELD} />
          </Field>
        </div>
        <div className="sm:col-span-2">
          <span className="text-sm font-extrabold">Icona</span>
          <div className="mt-1 flex flex-wrap gap-1">
            {ICONS.map(icon => (
              <button
                key={icon}
                type="button"
                onClick={() => set({ icon })}
                aria-label={`Icona ${icon}`}
                aria-pressed={draft.icon === icon}
                className={`btn-press grid h-11 w-11 place-items-center rounded-xl text-2xl ${draft.icon === icon ? 'bg-[#0F47AF]/15 ring-2 ring-[#0F47AF]' : 'hover:bg-gray-100'}`}
              >
                {icon}
              </button>
            ))}
          </div>
        </div>
      </section>

      <section className="flex flex-col gap-4 rounded-3xl bg-white p-5 shadow-sm">
        {c.kind === 'exercises' && (
          <>
            <Field label="Àrea" hint="on l'agrupen les rutes i el seguiment d'errors">
              <select value={c.area} onChange={e => setContent({ area: e.target.value as typeof c.area })} className={FIELD}>
                {TEACHER_EXERCISE_AREAS.map(area => <option key={area} value={area}>{categoryLabel(area)}</option>)}
              </select>
            </Field>
            <QuestionList questions={c.questions} max={L.questions} choiceOnly={false} onChange={questions => setContent({ questions })} />
          </>
        )}

        {c.kind === 'reading' && (
          <>
            <Field label="Títol del text" hint="opcional">
              <input value={c.text_title} maxLength={L.readingTitle} onChange={e => setContent({ text_title: e.target.value })} className={FIELD} />
            </Field>
            <Field label="Text" hint={`${c.text.length}/${L.readingText} · deixa una línia en blanc entre paràgrafs`}>
              <textarea value={c.text} maxLength={L.readingText} rows={9} onChange={e => setContent({ text: e.target.value })} className={FIELD} />
            </Field>
            <QuestionList questions={c.questions} max={L.readingQuestions} choiceOnly onChange={questions => setContent({ questions })} />
          </>
        )}

        {c.kind === 'writing' && (
          <>
            <Field label="Enunciat" hint="què ha d'escriure l'alumne, a qui i per a què">
              <textarea value={c.prompt} maxLength={L.writingPrompt} rows={5} onChange={e => setContent({ prompt: e.target.value })}
                placeholder="Ex.: Escriu un correu a un amic per a convidar-lo a la festa del teu barri. Explica-li quan és, què fareu i com pot arribar-hi."
                className={FIELD} />
            </Field>
            <div className="grid grid-cols-2 gap-3 sm:max-w-sm">
              <Field label="Mínim de paraules">
                <input type="number" min={L.minWords} max={L.maxWords} value={c.min_words} onChange={e => setContent({ min_words: Number(e.target.value) })} className={FIELD} />
              </Field>
              <Field label="Màxim de paraules">
                <input type="number" min={L.minWords} max={L.maxWords} value={c.max_words} onChange={e => setContent({ max_words: Number(e.target.value) })} className={FIELD} />
              </Field>
            </div>
            <p className="text-sm opacity-60">La IA la corregix amb la rúbrica oficial de la JQCV ({['A1', 'A2'].includes(draft.level) ? 'la de l\'A2' : 'la del B1'}).</p>
          </>
        )}

        {c.kind === 'scenario' && (
          <>
            <Field label="Personatge" hint="nom i rol, com el veurà l'alumne">
              <input value={c.character} maxLength={L.character} onChange={e => setContent({ character: e.target.value })} placeholder="Ex.: Anna, bibliotecària" className={FIELD} />
            </Field>
            <Field label="Situació" hint="què passa i què vol l'alumne">
              <textarea value={c.situation} maxLength={L.situation} rows={3} onChange={e => setContent({ situation: e.target.value })}
                placeholder="Ex.: L'alumne vol fer-se el carnet de la biblioteca i demanar en préstec un llibre que no troba." className={FIELD} />
            </Field>
            <Field label="Primera frase del personatge">
              <input value={c.greeting} maxLength={L.greeting} onChange={e => setContent({ greeting: e.target.value })} placeholder="Ex.: Bon dia! En què et puc ajudar?" className={FIELD} />
            </Field>
            <div>
              <span className="text-sm font-extrabold">Objectius de l'alumne</span>
              <span className="ml-2 text-sm opacity-50">el personatge el guiarà perquè els complisca</span>
              <ul className="mt-1 flex flex-col gap-2">
                {c.objectives.map((objective, i) => (
                  <li key={i} className="flex items-center gap-2">
                    <span className="w-5 text-right font-black opacity-40">{i + 1}</span>
                    <input value={objective} maxLength={L.objective}
                      onChange={e => setContent({ objectives: c.objectives.map((o, j) => (j === i ? e.target.value : o)) })}
                      placeholder="Ex.: Demanar el carnet de la biblioteca." className={SMALL_FIELD} />
                    <button type="button" disabled={c.objectives.length <= 1} onClick={() => setContent({ objectives: c.objectives.filter((_, j) => j !== i) })}
                      aria-label={`Lleva l'objectiu ${i + 1}`} className={ICON_BUTTON}>
                      <X size={16} />
                    </button>
                  </li>
                ))}
              </ul>
              {c.objectives.length < L.objectives && (
                <button type="button" onClick={() => setContent({ objectives: [...c.objectives, ''] })} className="btn-press mt-2 flex items-center gap-1 text-sm font-bold text-[#0F47AF]">
                  <Plus size={16} /> Afig un objectiu
                </button>
              )}
            </div>
            <div className="grid gap-3 sm:grid-cols-2">
              <Field label="Veu del personatge">
                <select value={c.voice} onChange={e => setContent({ voice: e.target.value })} className={FIELD}>
                  {SCENARIO_VOICES.map(v => <option key={v.value} value={v.value}>{v.label}</option>)}
                </select>
              </Field>
              <Field label="Lloc">
                <select value={c.background} onChange={e => setContent({ background: e.target.value })} className={FIELD}>
                  {SCENARIO_BACKGROUNDS.map(b => <option key={b.value} value={b.value}>{b.label}</option>)}
                </select>
              </Field>
            </div>
          </>
        )}
      </section>

      <section className="rounded-3xl bg-white p-5 shadow-sm">
        <p className="text-sm font-extrabold">Assigna-la a les classes</p>
        <p className="text-sm opacity-60">L'alumnat d'estes classes la veurà en la secció «Classe». Sense cap classe no la veu ningú. Només es pot assignar a classes del seu nivell.</p>
        {classes.length ? (
          <div className="mt-2 flex flex-wrap gap-2">
            {classes.map(k => {
              const fits = !isLevel0Class(k.levels) && k.levels.includes(draft.level);
              return (
                <label
                  key={k.id}
                  title={fits ? undefined : isLevel0Class(k.levels) ? 'Les classes del Nivell 0 no tenen activitats' : "Esta classe és d'un altre nivell"}
                  className={`flex items-center gap-2 rounded-2xl border-2 px-4 py-2 font-bold ${!fits ? 'cursor-not-allowed opacity-40' : 'btn-press cursor-pointer'} ${draft.class_ids.includes(k.id) ? 'border-[#0F47AF] bg-[#0F47AF]/10' : 'border-gray-100'}`}
                >
                  <input type="checkbox" disabled={!fits} checked={draft.class_ids.includes(k.id)} onChange={() => toggleClass(k.id)} className="h-4 w-4 accent-[#0F47AF]" />
                  {k.name}
                  <span className="text-sm font-normal opacity-60">{k.levels.map(classLevelLabel).join(' · ')}</span>
                </label>
              );
            })}
          </div>
        ) : (
          <p className="mt-2 text-base opacity-70">Encara no tens cap classe: crea'n una per a poder assignar-la.</p>
        )}
      </section>

      {showProblems && problems.length > 0 && (
        <ul className="list-disc rounded-2xl bg-coral/10 p-4 pl-8 text-coral">
          {problems.map(p => <li key={p}>{p}</li>)}
        </ul>
      )}
      {error && <p className="rounded-2xl bg-coral/10 p-3 text-coral">{error}</p>}

      <div className="flex flex-wrap justify-end gap-2">
        <button type="button" onClick={onCancel} className="btn-press rounded-2xl px-5 py-3 font-bold text-gray-600 hover:bg-gray-100">Cancel·la</button>
        <button
          type="button"
          onClick={() => (problems.length ? setShowProblems(true) : onPreview(cleanActivity(draft)))}
          className="btn-press flex items-center gap-2 rounded-2xl bg-white px-5 py-3 font-extrabold text-[#0F47AF] shadow-sm"
        >
          <Eye size={18} /> Vista prèvia
        </button>
        <button type="button" onClick={() => void save()} disabled={saving} className="btn-press rounded-2xl bg-[#0F47AF] px-6 py-3 font-extrabold text-white disabled:opacity-50">
          {saving ? 'Guardant...' : id ? 'Guarda els canvis' : "Crea l'activitat"}
        </button>
      </div>
    </div>
  );
}
