import { useState } from 'react';
import { Check, Lightbulb, Plus } from 'lucide-react';
import type { AgentDocument, AgentMissingActivity, AgentPathResult, AgentPathStep, CefrLevel, TeacherActivity } from '@parlaval/shared';
import { categoryLabel } from '../../components/ScenarioSelect';
import { generatePathDraft } from '../../lib/api';
import type { KidsClass } from '../kids/tracking';
import { PATH_LEVELS } from '../paths/teacherPaths';
import { CreateMissingActivity } from './CreateMissingActivity';
import { ACTIVITY_KINDS } from '../activities/drafts';
import { DocumentAttach } from './DocumentAttach';
import { isAbort, PromptBox } from './PromptBox';

export type PathDraftFromAgent = { level: string; title: string; description: string; resources: string[] };
type Generated = Exclude<AgentPathResult, { status: 'error' }>;
// `from`: la proposta (índex de `missing`) que va originar l'activitat.
type Created = { id: string; title: string; from: number };

/**
 * «Genera amb IA» en les rutes d'una classe. Munta la ruta amb activitats que ja existixen i diu per què cada una és
 * rellevant. Si en falten, les proposa i es poden crear ací mateix; les creades s'afigen a la ruta. L'esborrany s'obri
 * en l'editor de rutes perquè la docent el revise.
 */
export function PathAgent({ classId, className, classLevels, onDraft, onActivityCreated, onClose }: {
  classId: string;
  className: string;
  classLevels: string[];
  onDraft: (draft: PathDraftFromAgent, message: string) => void;
  /** S'ha creat una activitat nova: el catàleg de l'editor s'ha de tornar a carregar perquè hi aparega. */
  onActivityCreated?: () => void;
  onClose: () => void;
}) {
  const [result, setResult] = useState<Generated>();
  const [error, setError] = useState<string>();
  const [lastPrompt, setLastPrompt] = useState('');
  const [created, setCreated] = useState<Created[]>([]);
  const [creating, setCreating] = useState<number>();
  const [document, setDocument] = useState<AgentDocument>();
  const pathLevels = PATH_LEVELS.map(l => l.value).filter(l => classLevels.includes(l));
  // Nivell de les activitats noves: el de la ruta; si no n'hi ha cap (ruta insuficient), el que tria la docent.
  const [pickedLevel, setPickedLevel] = useState<string>(pathLevels[0]);
  const level = (result && result.status !== 'insufficient' ? result.level : pickedLevel) as CefrLevel;

  const klass: KidsClass = { id: classId, name: className, code: '', created_at: '', levels: classLevels };
  const steps = result?.steps ?? [];
  const resources = [...steps.map(s => s.resource_id), ...created.map(c => c.id)];

  const use = () => {
    if (!result || !resources.length) return;
    onDraft(
      result.status === 'insufficient'
        ? { level, title: lastPrompt.slice(0, 80), description: '', resources }
        : { level: result.level, title: result.title, description: result.description, resources },
      result.status === 'insufficient'
        ? "S'ha muntat amb les activitats trobades i les que has creat. Posa-li un títol."
        : result.message,
    );
  };

  return (
    <>
      <PromptBox
        title="Crea una ruta amb IA"
        hint="Descriu el que vols treballar, o adjunta un examen o un temari i digues què en vols. La ruta es munta amb activitats que ja existixen (les del catàleg i les teues); podràs revisar-la i canviar-la abans de guardar-la."
        extra={<DocumentAttach value={document} onChange={setDocument} />}
        placeholder="Ex.: Una ruta de B1 per a repassar els pronoms febles i la combinació de pronoms, de menys a més difícil"
        submitLabel="Genera la ruta"
        onClose={onClose}
        onSubmit={async (prompt, signal) => {
          setError(undefined);
          setResult(undefined);
          setCreated([]);
          setLastPrompt(prompt);
          try {
            const generated = await generatePathDraft(prompt, classId, signal, document?.id);
            if (generated.status === 'error') setError(generated.message);
            else setResult(generated);
          } catch (e) {
            if (!isAbort(e)) setError(e instanceof Error ? e.message : String(e));
          }
        }}
      />
      {error && <p role="alert" className="mt-3 rounded-2xl bg-mustard/20 p-4 text-lg"><b>No s'ha pogut crear la ruta.</b> {error}</p>}

      {result && (
        <section className="mt-3 rounded-3xl bg-white p-5 shadow-sm" aria-live="polite">
          {result.status === 'insufficient' ? (
            <p className="rounded-2xl bg-mustard/20 p-4 text-lg"><b>No hi ha prou activitats per a esta ruta.</b> {result.message}</p>
          ) : (
            <>
              <p className="text-sm font-black text-teal">{result.level} · {result.steps.length} activitats</p>
              <h3 className="text-2xl font-black">{result.title}</h3>
              {result.description && <p className="text-base opacity-70">{result.description}</p>}
              <p className={`mt-2 rounded-2xl p-3 text-base ${result.status === 'partial' ? 'bg-mustard/20' : 'bg-teal/10'}`}>{result.message}</p>
            </>
          )}

          {steps.length > 0 && <StepList steps={steps} />}
          {created.length > 0 && <CreatedList created={created} />}
          {result.missing.length > 0 && (
            <MissingList
              missing={result.missing}
              created={created}
              creating={creating}
              level={result.status === 'insufficient' ? { value: pickedLevel, options: pathLevels, onChange: setPickedLevel } : undefined}
              onCreate={setCreating}
            />
          )}

          {resources.length > 0 && (
            <div className="mt-4 flex justify-end">
              <button onClick={use} className="btn-press rounded-2xl bg-[#0F47AF] px-6 py-3 font-extrabold text-white">
                {created.length && result.status === 'insufficient' ? 'Munta la ruta amb estes activitats' : 'Revisa i edita la ruta'}
              </button>
            </div>
          )}
        </section>
      )}

      {result && creating !== undefined && result.missing[creating] && (
        <CreateMissingActivity
          title={result.missing[creating].title}
          prompt={result.missing[creating].suggested_prompt}
          level={level}
          kind={result.missing[creating].kind}
          klass={klass}
          documentId={document?.id}
          onClose={() => setCreating(undefined)}
          onSaved={(activity: TeacherActivity) => {
            setCreated(list => [...list, { id: activity.id, title: activity.title, from: creating }]);
            setCreating(undefined);
            onActivityCreated?.();
          }}
        />
      )}
    </>
  );
}

function StepList({ steps }: { steps: AgentPathStep[] }) {
  return (
    <div className="mt-4">
      <p className="text-sm font-extrabold">{steps.length === 1 ? 'Activitat trobada' : 'Activitats trobades'} i per què hi són</p>
      <ol className="mt-2 flex flex-col gap-2">
        {steps.map((s, i) => (
          <li key={s.resource_id} className="flex items-start gap-3 rounded-2xl bg-gray-50 px-3 py-2">
            <span className="w-6 text-right font-black opacity-50">{i + 1}</span>
            <span className="text-xl" aria-hidden="true">{s.icon ?? '📘'}</span>
            <span className="min-w-0 flex-1">
              <span className="block font-bold">{s.title}{s.own && <span className="ml-2 rounded-full bg-[#0F47AF]/10 px-2 py-0.5 text-xs font-black text-[#0F47AF]">Pròpia</span>}</span>
              <span className="block text-xs opacity-60">{categoryLabel(s.category)}</span>
              <span className="block text-sm">{s.reason}</span>
            </span>
          </li>
        ))}
      </ol>
    </div>
  );
}

function CreatedList({ created }: { created: Created[] }) {
  return (
    <div className="mt-4">
      <p className="text-sm font-extrabold">Activitats noves creades per a la ruta</p>
      <ul className="mt-2 flex flex-col gap-2">
        {created.map(c => (
          <li key={c.id} className="flex items-center gap-2 rounded-2xl bg-teal/10 px-3 py-2 font-bold"><Check size={18} /> {c.title}</li>
        ))}
      </ul>
    </div>
  );
}

function MissingList({ missing, created, creating, level, onCreate }: {
  missing: AgentMissingActivity[];
  created: Created[];
  creating: number | undefined;
  /** Només amb una ruta insuficient: la docent tria el nivell de les activitats noves. */
  level?: { value: string; options: string[]; onChange: (level: string) => void };
  onCreate: (index: number) => void;
}) {
  // Les propostes ja creades no es tornen a oferir.
  const done = new Set(created.map(c => c.from));
  return (
    <div className="mt-4">
      <p className="flex items-center gap-2 text-sm font-extrabold"><Lightbulb size={16} /> Activitats que caldria crear</p>
      <p className="text-sm opacity-60">Crea-les ací mateix: la IA te'n farà un esborrany, el revises i es guarda. Després s'afig a la ruta.</p>
      {level && level.options.length > 1 && (
        <label className="mt-2 flex items-center gap-2 text-sm font-extrabold">
          Nivell de les activitats noves
          <select value={level.value} onChange={e => level.onChange(e.target.value)} className="rounded-xl border-2 border-gray-100 bg-white p-1 font-bold">
            {level.options.map(l => <option key={l} value={l}>{l}</option>)}
          </select>
        </label>
      )}
      <ul className="mt-2 flex flex-col gap-2">
        {missing.map((m, i) => (
          <li key={m.title + i} className="rounded-2xl border border-gray-100 p-3">
            <p className="font-bold">
              {m.title}
              <span className="ml-2 rounded-full bg-[#0F47AF]/10 px-2 py-0.5 align-middle text-xs font-black text-[#0F47AF]">
                {ACTIVITY_KINDS.find(k => k.kind === m.kind)?.label ?? m.kind}
              </span>
            </p>
            <p className="text-sm opacity-70">{m.why}</p>
            <div className="mt-2 flex items-start gap-2">
              <p className="min-w-0 flex-1 rounded-xl bg-gray-50 p-2 text-sm italic">{m.suggested_prompt}</p>
              <button
                onClick={() => onCreate(i)}
                disabled={creating !== undefined || done.has(i)}
                className="btn-press flex shrink-0 items-center gap-1 rounded-full bg-[#0F47AF] px-4 py-2 text-sm font-extrabold text-white disabled:opacity-40"
              >
                {done.has(i) ? <><Check size={14} /> Creada</> : <><Plus size={14} /> Crea-la</>}
              </button>
            </div>
          </li>
        ))}
      </ul>
    </div>
  );
}
