import { Link } from 'react-router-dom';
import { BookOpen, Check, Dumbbell, ExternalLink, Puzzle, SpellCheck, Table, Tag, X } from 'lucide-react';
import { isGroupLine, isItemLine, parseCorrections, type CorrectionGroup } from '../lib/corrections';
import { activityRoute, KIDS_ROUTES, practiceRoute } from '../data/content';
import { lessonById } from '../features/kids/lessons';
import type { GnvRule, TutorActivity, TutorExercise, VerbConjugation } from '../lib/types';

// Bombolla d'un missatge del xat amb el tutor. En els missatges del professor, la primera línia és en
// valencià i la resta, en gris clar, l'ajuda en la llengua materna del xiquet (amagada si `showHelp` és fals).
// Si el professor ha respost un dubte de normativa amb la GNV, davall va la regla oficial; si li han demanat la
// conjugació d'un verb, la taula del DNV.
export function ChatBubble({ role, text, transcription, gnv, conjugacio, exercise, activity, lessonId, onAnswer, showHelp = true }: { role: 'user' | 'character'; text: string; transcription?: string; gnv?: GnvRule; conjugacio?: VerbConjugation; exercise?: TutorExercise; activity?: TutorActivity; lessonId?: string; onAnswer?: (exercise: TutorExercise, chosen: string) => void; showHelp?: boolean }) {
  const [valencian, ...rest] = role === 'character' ? text.split('\n') : [text];
  // Correcció d'un text: després de la primera línia, una línia per error numerada («1) ...»), que es mostra com a llista.
  // La resta de línies són l'ajuda en la llengua materna.
  const isCorrection = (line: string) => isGroupLine(line) || isItemLine(line);
  const corrections = parseCorrections(rest.filter(isCorrection));
  const help = rest.filter(line => !isCorrection(line));
  return (
    <div
      className={`max-w-[85%] rounded-2xl px-4 py-2 text-[length:var(--chat-font,1rem)] font-bold ${
        role === 'user' ? 'ml-auto bg-teal text-white' : 'bg-cream text-slate-800'
      }`}
    >
      <p>{valencian}</p>
      {corrections.length > 0 && <CorrectionGroups groups={corrections} />}
      {transcription && <p className="mt-2 border-t border-white/30 pt-2 text-[0.85em] font-normal">Transcripció: {transcription}</p>}
      {showHelp && help.length > 0 && <p className="mt-1 whitespace-pre-line text-[0.85em] font-semibold text-slate-400">{help.join('\n')}</p>}
      {gnv && <GnvRuleCard rule={gnv} />}
      {conjugacio && <ConjugationCard conjugation={conjugacio} />}
      {lessonId && <LessonLink lessonId={lessonId} />}
      {exercise && <ExerciseCard exercise={exercise} onAnswer={onAnswer} />}
      {!exercise && activity && (
        <Link to={activityRoute({ id: activity.resource_id, type: activity.type, category: activity.category }) ?? practiceRoute(activity.resource_id)} className="mt-3 flex items-center gap-2 rounded-xl bg-white/80 px-3 py-2 text-[0.9em] font-extrabold text-orange ring-2 ring-orange/30 hover:ring-orange">
          <Dumbbell size={20} className="shrink-0" aria-hidden />
          <span>{activity.category === 'escenari' || activity.category === 'expressio_oral' ? 'Practica la conversa' : 'Practica-ho'}: {activity.resource_name}</span>
        </Link>
      )}
    </div>
  );
}

// Estil de cada tipologia d'error (per títol de grup): color i icona.
const GROUP_STYLE: Record<string, { Icon: typeof SpellCheck; box: string; badge: string }> = {
  'Ortografia i fonètica': { Icon: SpellCheck, box: 'border-sky-400 bg-sky-50', badge: 'bg-sky-500' },
  Morfosintaxi: { Icon: Puzzle, box: 'border-violet-400 bg-violet-50', badge: 'bg-violet-500' },
  'Lèxic i semàntica': { Icon: BookOpen, box: 'border-amber-400 bg-amber-50', badge: 'bg-amber-500' },
};
const DEFAULT_GROUP_STYLE = { Icon: Tag, box: 'border-slate-300 bg-slate-50', badge: 'bg-slate-500' };

// Errors d'un text corregit, agrupats per tipologia: cada error mostra el fragment erroni ratllat i la forma correcta.
function CorrectionGroups({ groups }: { groups: CorrectionGroup[] }) {
  return (
    <div className="mt-3 space-y-3">
      {groups.map(group => {
        const { Icon, box, badge } = GROUP_STYLE[group.title] ?? DEFAULT_GROUP_STYLE;
        return (
          <section key={group.title} aria-label={group.title} className={`rounded-xl border-l-4 p-3 ${box}`}>
            <h3 className="flex items-center gap-2 text-[0.8em] font-extrabold uppercase tracking-wide text-slate-600">
              <Icon size={18} className="shrink-0" aria-hidden />
              <span>{group.title}</span>
              <span className={`ml-auto rounded-full px-2 py-0.5 text-[0.9em] text-white ${badge}`}>{group.items.length}</span>
            </h3>
            <ul className="mt-2 space-y-2">
              {group.items.map(item => (
                <li key={item.number} className="rounded-lg bg-white/90 px-3 py-2 text-[0.9em] font-semibold shadow-sm">
                  {(item.wrong || item.right) && (
                    <p className="flex flex-wrap items-center gap-x-2 gap-y-1">
                      <span className="rounded-md bg-red-100 px-2 py-0.5 font-extrabold text-red-700 line-through decoration-2">{item.wrong}</span>
                      <span aria-hidden className="text-slate-400">→</span>
                      <span className="rounded-md bg-green-100 px-2 py-0.5 font-extrabold text-green-700">{item.right}</span>
                    </p>
                  )}
                  {item.explanation && <p className="mt-1 text-[0.95em] font-normal text-slate-600">{item.explanation}</p>}
                  {item.cite && <p className="mt-1 inline-flex items-center gap-1 rounded-full bg-teal/10 px-2 py-0.5 text-[0.8em] font-extrabold text-teal"><BookOpen size={14} aria-hidden />GNV § {item.cite}</p>}
                </li>
              ))}
            </ul>
          </section>
        );
      })}
    </div>
  );
}

function GnvRuleCard({ rule }: { rule: GnvRule }) {
  const related = rule.relacionades ?? [];
  return (
    <section aria-label="Regla de la Gramàtica Normativa Valenciana" className="mt-3 rounded-xl bg-white/80 p-3 text-[0.9em] font-semibold ring-2 ring-teal/30">
      <p className="flex items-start gap-2 text-[0.8em] font-extrabold uppercase tracking-wide text-teal">
        <BookOpen size={18} className="mt-0.5 shrink-0" aria-hidden />
        <span>Regla oficial · GNV{rule.seccio ? ` § ${rule.seccio}` : ''}</span>
      </p>
      <p className="mt-1 text-[0.8em] font-semibold text-slate-500">{rule.ruta}</p>
      {related.length > 0 && (
        <p className="mt-1 text-[0.8em] font-semibold text-slate-500">
          Completen la regla: {related.map(r => r.seccio ? `§ ${r.seccio}` : r.ruta).join(', ')}
        </p>
      )}

      <h3 className="mt-3 text-[0.8em] font-extrabold text-slate-700">Què diu la norma</h3>
      <p className="whitespace-pre-line">{rule.contingut}</p>

      <h3 className="mt-3 text-[0.8em] font-extrabold text-slate-700">Explicació fàcil</h3>
      <p className="whitespace-pre-line">{rule.explicacio}</p>

      <details className="mt-3">
        <summary className="cursor-pointer text-[0.8em] font-extrabold text-teal">Vore el text original de la GNV</summary>
        <div className="mt-2 max-h-72 space-y-3 overflow-y-auto text-[0.8em] font-medium text-slate-600">
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

// Persones dels temps personals, en l'ordre en què les dona el DNV.
const PERSONS = ['jo', 'tu', 'ell, ella, vosté', 'nosaltres', 'vosaltres', 'ells, elles, vostés'];

// Conjugació d'un verb del DNV: un desplegable per mode (l'indicatiu, obert) amb un bloc per temps.
function ConjugationCard({ conjugation }: { conjugation: VerbConjugation }) {
  return (
    <section aria-label={`Conjugació del verb ${conjugation.verb}`} className="mt-3 rounded-xl bg-white/80 p-3 text-[0.9em] font-semibold ring-2 ring-teal/30">
      <p className="flex items-start gap-2 text-[0.8em] font-extrabold uppercase tracking-wide text-teal">
        <Table size={18} className="mt-0.5 shrink-0" aria-hidden />
        <span>Conjugació · DNV</span>
      </p>
      <p className="mt-1 text-[1.1em] font-black text-slate-800">{conjugation.verb}</p>

      {Object.entries(conjugation.modes).map(([mode, tenses], i) => (
        <details key={mode} open={i === 0} className="mt-3">
          <summary className="cursor-pointer text-[0.85em] font-extrabold capitalize text-slate-700">{mode}</summary>
          <div className="mt-2 grid gap-2 sm:grid-cols-2">
            {Object.entries(tenses).map(([tense, forms]) => (
              <div key={tense} className="rounded-lg bg-cream/60 px-3 py-2">
                {tense !== 'formes' && <p className="text-[0.75em] font-extrabold uppercase tracking-wide text-teal">{tense}</p>}
                {forms.length === PERSONS.length ? (
                  <dl className="text-[0.85em]">
                    {forms.map((form, person) => form && (
                      <div key={person} className="flex gap-2">
                        <dt className="w-24 shrink-0 font-medium text-slate-400">{PERSONS[person]}</dt>
                        <dd className="font-bold text-slate-800">{form}</dd>
                      </div>
                    ))}
                  </dl>
                ) : (
                  <p className="text-[0.85em] font-bold text-slate-800">{forms.filter(Boolean).join(', ')}</p>
                )}
              </div>
            ))}
          </div>
        </details>
      ))}

      {conjugation.observacions.length > 0 && (
        <>
          <h3 className="mt-3 text-[0.8em] font-extrabold text-slate-700">Observacions</h3>
          {conjugation.observacions.map(o => <p key={o} className="text-[0.8em] font-medium text-slate-600">{o}</p>)}
        </>
      )}

      <a href={conjugation.url} target="_blank" rel="noreferrer" className="mt-3 inline-flex items-center gap-1 text-[0.8em] font-extrabold text-teal underline">
        Vore-la en el DNV de l'AVL <ExternalLink size={14} aria-hidden />
      </a>
    </section>
  );
}

// Exercici real del catàleg dins de la bombolla: es respon amb un toc i es corregix al moment.
function ExerciseCard({ exercise, onAnswer }: { exercise: TutorExercise; onAnswer?: (exercise: TutorExercise, chosen: string) => void }) {
  const answered = exercise.chosen !== undefined;
  const correct = answered && exercise.chosen === exercise.answer;
  return (
    <section aria-label="Exercici" className="mt-3 rounded-xl bg-white/80 p-3 text-[0.9em] font-semibold ring-2 ring-orange/30">
      <p className="text-[0.8em] font-extrabold uppercase tracking-wide text-orange">Exercici · {exercise.resource_name} · {exercise.level}</p>
      <p className="mt-2 whitespace-pre-line text-[0.95em] font-bold">{exercise.prompt}</p>
      <div className="mt-2 flex flex-col gap-2">
        {exercise.options.map(option => {
          const isRight = answered && option === exercise.answer;
          const isWrong = answered && option === exercise.chosen && !isRight;
          return (
            <button
              key={option}
              disabled={answered}
              onClick={() => onAnswer?.(exercise, option)}
              className={`btn-press flex items-center justify-between gap-2 rounded-xl px-4 py-2 text-left font-bold ring-2 disabled:cursor-default ${
                isRight ? 'bg-green-100 ring-green-500' : isWrong ? 'bg-red-100 ring-red-400' : 'bg-white ring-slate-200 hover:ring-orange'
              }`}
            >
              <span>{option}</span>
              {isRight && <Check size={20} className="shrink-0 text-green-600" aria-hidden />}
              {isWrong && <X size={20} className="shrink-0 text-red-500" aria-hidden />}
            </button>
          );
        })}
      </div>
      {answered && (
        <div className="mt-3">
          <p className={`font-extrabold ${correct ? 'text-green-600' : 'text-red-500'}`}>{correct ? 'Molt bé! 🎉' : `Quasi! La correcta és «${exercise.answer}».`}</p>
          {exercise.explanation && <p className="mt-1 whitespace-pre-line text-[0.8em] font-semibold text-slate-600">{exercise.explanation}</p>}
          <Link to={practiceRoute(exercise.resource_id)} className="mt-2 inline-block text-[0.8em] font-extrabold text-teal underline">Fer més exercicis d'esta activitat</Link>
        </div>
      )}
    </section>
  );
}

// Enllaç a una lliçó de l'app (tutor del Nivell 0): gran i amb el dibuix, perquè els xiquets xicotets el reconeguen.
function LessonLink({ lessonId }: { lessonId: string }) {
  const lesson = lessonById(lessonId);
  if (!lesson) return null;
  return (
    <Link
      to={`${KIDS_ROUTES.lesson}/${lesson.id}`}
      style={{ backgroundColor: lesson.color }}
      className="btn-press mt-3 flex items-center gap-3 rounded-2xl px-4 py-3 text-[1em] font-black text-slate-800 shadow ring-2 ring-white"
    >
      <span className="text-4xl" aria-hidden>{lesson.emoji}</span>
      <span>Lliçó: {lesson.title}</span>
    </Link>
  );
}
