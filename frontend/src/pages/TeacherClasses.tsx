import { useEffect, useMemo, useState, type FormEvent } from 'react';
import { Copy, Pencil, Plus, Trash2, UserMinus } from 'lucide-react';
import { OrangeHeader } from '../components/ui';
import { supabase } from '../lib/supabase';
import { ProgressReport } from '../features/kids/ProgressReport';
import { ConversationView } from '../features/kids/ConversationView';
import { ago, groupStruggles, percent, summarize } from '../features/kids/report';
import {
  createClass, deleteClass, loadMyClasses, loadStudents, removeStudent, type ConversationRow, type KidsClass, type Student,
} from '../features/kids/tracking';
import { ClassPaths, StudentPaths } from '../features/paths/ClassPaths';
import { ClassHomework, StudentHomework } from '../features/paths/ClassHomework';
import { DeletePathButton, PathEditor } from '../features/paths/PathEditor';
import { PathClassPicker } from '../features/paths/PathClassPicker';
import { fetchResources } from '../lib/api';
import { deletePath, loadTeacher, loadTeacherPaths, type StudyPath } from '../lib/paths';
import type { Resource } from '../lib/types';

const FIELD_CLASS = 'w-full rounded-2xl border-2 border-gray-100 p-3 text-xl font-normal outline-none focus:border-[#0F47AF] transition-colors';

/**
 * Les classes i les rutes del professorat (comptes de la taula teachers). La docent crea
 * una classe i rep un codi: les famílies l'escriuen en el seguiment del perfil del xiquet,
 * i les persones adultes en «Les meues rutes». Per a cada classe: la taula de l'alumnat,
 * les rutes assignades amb el progrés de cadascú, les illes que costen al grup i la fitxa
 * de seguiment de cada alumne (amb les seues converses amb personatges, que també pot
 * llegir). En la pestanya «Rutes», la docent crea i edita les seues rutes.
 */
export function TeacherClasses({ uid, onBack }: { uid: string | undefined; onBack: () => void }) {
  const [classes, setClasses] = useState<KidsClass[]>();
  const [selected, setSelected] = useState<KidsClass>();
  const [students, setStudents] = useState<Student[]>();
  const [student, setStudent] = useState<Student>();
  const [conversation, setConversation] = useState<ConversationRow>();
  const [newName, setNewName] = useState('');
  const [error, setError] = useState<string>();
  const [copied, setCopied] = useState(false);
  const [tab, setTab] = useState<'classes' | 'paths'>('classes');
  // undefined: carregant; null: el compte no és docent.
  const [teacher, setTeacher] = useState<{ canPublish: boolean } | null>();
  const [paths, setPaths] = useState<{ mine: StudyPath[]; shared: StudyPath[] }>({ mine: [], shared: [] });
  // undefined: no s'edita; null: ruta nova.
  const [editing, setEditing] = useState<StudyPath | null>();
  const [resources, setResources] = useState<Resource[]>([]);
  const online = !!supabase && !!uid;
  const resourcesById = useMemo(() => new Map(resources.map(r => [r.id, r])), [resources]);

  useEffect(() => {
    if (!online) return;
    loadTeacher(uid!)
      .then(t => {
        setTeacher(t);
        if (!t) return;
        loadMyClasses(uid!).then(setClasses).catch(e => {
          console.error(e);
          setError("No s'han pogut carregar les classes.");
        });
        loadTeacherPaths(uid!).then(setPaths).catch(console.error);
        fetchResources().then(setResources).catch(console.error);
      })
      .catch(e => {
        console.error(e);
        setTeacher(null);
      });
  }, [uid, online]);

  const reloadPaths = () => loadTeacherPaths(uid!).then(setPaths).catch(console.error);

  useEffect(() => {
    setStudents(undefined);
    setStudent(undefined);
    if (!selected) return;
    let cancelled = false;
    loadStudents(selected.id)
      .then(s => { if (!cancelled) setStudents(s); })
      .catch(e => {
        console.error(e);
        if (!cancelled) setError("No s'ha pogut carregar l'alumnat.");
      });
    return () => { cancelled = true; };
  }, [selected]);

  const create = async (e: FormEvent) => {
    e.preventDefault();
    try {
      const created = await createClass(newName.trim());
      setClasses(c => [...(c ?? []), created]);
      setNewName('');
      setSelected(created);
    } catch (e) {
      console.error(e);
      setError("No s'ha pogut crear la classe.");
    }
  };

  const remove = async (c: KidsClass) => {
    if (!confirm(`Segur que vols esborrar la classe «${c.name}»? L'alumnat no perd el seu progrés.`)) return;
    await deleteClass(c.id).catch(console.error);
    setClasses(list => list?.filter(x => x.id !== c.id));
    setSelected(undefined);
  };

  const kick = async (s: Student) => {
    if (!selected || !confirm(`Vols traure ${s.data.name || 'este alumne'} de la classe?`)) return;
    await removeStudent(selected.id, s.id).catch(console.error);
    setStudents(list => list?.filter(x => x.id !== s.id));
  };

  const copy = async (code: string) => {
    await navigator.clipboard?.writeText(code).catch(() => undefined);
    setCopied(true);
    window.setTimeout(() => setCopied(false), 1500);
  };

  const back = () => (editing !== undefined ? setEditing(undefined) : student ? setStudent(undefined) : selected ? setSelected(undefined) : onBack());

  return (
    <main className="fade-up" style={{ background: '#FAFAF9', minHeight: '100vh' }}>
      <OrangeHeader showOranges={false}>
        <div className="px-5 pb-2">
          <button onClick={back} className="text-xl btn-press rounded-full bg-white/90 px-4 py-2 text-sm font-extrabold text-teal shadow hover:bg-white transition-colors">
            ← Tornar
          </button>
        </div>
      </OrangeHeader>

      <div className="mx-auto max-w-4xl px-5 pt-6 pb-16">
        {error && <p className="mb-4 rounded-2xl bg-coral/10 p-3 text-lg text-coral">{error}</p>}

        {!online ? (
          <>
            <h1 className="text-5xl font-black">Les meues classes</h1>
            <p className="mt-3 text-lg opacity-70">Cal iniciar sessió amb un compte de docent per a crear classes i rutes.</p>
          </>
        ) : teacher === undefined ? (
          <p className="text-lg opacity-60">Carregant…</p>
        ) : teacher === null ? (
          <>
            <h1 className="text-5xl font-black">Les meues classes</h1>
            <p className="mt-3 text-lg opacity-70">
              Este compte encara no és de docent. Demana a l'administració de ParlaVal que l'active per a poder crear classes i rutes.
            </p>
          </>
        ) : editing !== undefined ? (
          <PathEditor
            uid={uid!}
            base={editing}
            canPublish={teacher.canPublish}
            resources={resources}
            onCancel={() => setEditing(undefined)}
            onSaved={() => {
              setEditing(undefined);
              setTab('paths');
              void reloadPaths();
            }}
          />
        ) : student ? (
          <>
            <h1 className="text-4xl font-black">{student.data.name || 'Alumne'}</h1>
            <p className="mt-1 mb-5 text-lg opacity-70">{selected?.name} · a la classe des de {new Date(student.joined_at).toLocaleDateString('ca-ES')}</p>
            {selected && <StudentHomework uid={uid!} classId={selected.id} student={student} resources={resourcesById} />}
            {selected && <StudentPaths classId={selected.id} student={student.id} resources={resourcesById} />}
            {student.data.ageGroup !== 'adult' && (
              <ProgressReport data={student.data} name={student.data.name} onOpenConversation={setConversation} />
            )}
            {conversation && <ConversationView conversation={conversation} name={student.data.name} onClose={() => setConversation(undefined)} />}
          </>
        ) : selected ? (
          <ClassView
            uid={uid!}
            paths={[...paths.mine, ...paths.shared]}
            resources={resources}
            klass={selected}
            students={students}
            copied={copied}
            onCopy={() => void copy(selected.code)}
            onOpen={setStudent}
            onKick={s => void kick(s)}
            onDelete={() => void remove(selected)}
          />
        ) : tab === 'paths' ? (
          <>
            <Tabs tab={tab} onTab={setTab} />
            <PathList uid={uid!} classes={classes ?? []} paths={paths} onEdit={setEditing} onDelete={p => void deletePath(p.id).then(reloadPaths).catch(console.error)} />
          </>
        ) : (
          <>
            <Tabs tab={tab} onTab={setTab} />
            <h1 className="mt-6 text-5xl font-black">Les meues classes</h1>
            <p className="mt-2 text-lg opacity-70">Seguiment de l'alumnat: xiquets del Nivell 0 i persones adultes.</p>

            <ul className="mt-6 grid gap-3 sm:grid-cols-2">
              {classes?.map(c => (
                <li key={c.id}>
                  <button onClick={() => setSelected(c)} className="btn-press w-full rounded-3xl bg-white p-5 text-left shadow-sm hover:bg-white/80">
                    <span className="block text-2xl font-black">{c.name}</span>
                    <span className="mt-1 block font-mono text-lg tracking-widest opacity-60">{c.code}</span>
                  </button>
                </li>
              ))}
            </ul>
            {classes?.length === 0 && <p className="mt-2 text-lg opacity-60">Encara no tens cap classe.</p>}

            <form onSubmit={create} className="mt-6 rounded-3xl bg-white p-5 shadow-sm">
              <label className="block text-xl font-extrabold" htmlFor="class-name">Crea una classe</label>
              <div className="mt-2 flex gap-2">
                <input id="class-name" value={newName} onChange={e => setNewName(e.target.value.slice(0, 60))} placeholder="P. ex.: Infantil 5 anys B" className={FIELD_CLASS} />
                <button disabled={!newName.trim()} className="btn-press flex shrink-0 items-center gap-2 rounded-2xl bg-[#0F47AF] px-5 text-xl font-extrabold text-white disabled:opacity-40">
                  <Plus size={20} /> Crea
                </button>
              </div>
            </form>
          </>
        )}
      </div>
    </main>
  );
}

function Tabs({ tab, onTab }: { tab: 'classes' | 'paths'; onTab: (t: 'classes' | 'paths') => void }) {
  const style = (t: string) => `btn-press rounded-full px-5 py-2 text-xl font-black ${tab === t ? 'bg-[#0F47AF] text-white' : 'bg-white text-[#0F47AF] shadow-sm'}`;
  return (
    <div className="flex gap-2" role="tablist">
      <button role="tab" aria-selected={tab === 'classes'} onClick={() => onTab('classes')} className={style('classes')}>Classes</button>
      <button role="tab" aria-selected={tab === 'paths'} onClick={() => onTab('paths')} className={style('paths')}>Rutes</button>
    </div>
  );
}

/** Les rutes de la docent (editables) i les públiques (que pot assignar o duplicar). */
function PathList({ uid, classes, paths, onEdit, onDelete }: {
  uid: string;
  classes: KidsClass[];
  paths: { mine: StudyPath[]; shared: StudyPath[] };
  onEdit: (p: StudyPath | null) => void;
  onDelete: (p: StudyPath) => void;
}) {
  const card = (p: StudyPath, own: boolean) => (
    <li key={p.id} className="flex flex-col rounded-3xl bg-white p-5 shadow-sm">
      <span className="text-xs font-black uppercase tracking-wide text-teal">
        {p.audience === 'child' ? 'Xiquets' : 'Adults'}{p.is_public ? ' · Pública' : ''}
      </span>
      <span className="mt-1 text-2xl font-black">{p.title}</span>
      {p.description && <span className="mt-1 opacity-70">{p.description}</span>}
      <span className="mt-3 flex flex-wrap gap-2">
        <button onClick={() => onEdit(p)} className="btn-press flex items-center gap-1 rounded-full bg-cream px-4 py-2 font-black text-teal hover:bg-teal/10">
          {own ? <><Pencil size={16} /> Edita</> : <><Copy size={16} /> Duplica i adapta</>}
        </button>
        {own && <DeletePathButton path={p} onDelete={() => onDelete(p)} />}
      </span>
      <PathClassPicker uid={uid} pathId={p.id} classes={classes} />
    </li>
  );
  return (
    <>
      <div className="mt-6 flex flex-wrap items-center justify-between gap-3">
        <h1 className="text-4xl font-black">Les meues rutes</h1>
        <button onClick={() => onEdit(null)} className="btn-press flex items-center gap-2 rounded-2xl bg-[#0F47AF] px-5 py-2 text-xl font-extrabold text-white">
          <Plus size={20} /> Nova ruta
        </button>
      </div>
      <p className="mt-1 text-lg opacity-70">Tria activitats del catàleg, posa-les en ordre i, en cada ruta, toca les classes on la vols assignar.</p>
      {paths.mine.length ? <ul className="mt-4 grid gap-3 sm:grid-cols-2">{paths.mine.map(p => card(p, true))}</ul>
        : <p className="mt-4 text-lg opacity-60">Encara no has creat cap ruta.</p>}
      {paths.shared.length > 0 && (
        <>
          <h2 className="mt-8 text-2xl font-black">Rutes públiques</h2>
          <p className="mt-1 opacity-70">Les pots assignar tal com són o duplicar-les per a adaptar-les.</p>
          <ul className="mt-3 grid gap-3 sm:grid-cols-2">{paths.shared.map(p => card(p, false))}</ul>
        </>
      )}
    </>
  );
}

function ClassView({ uid, paths, resources, klass, students, copied, onCopy, onOpen, onKick, onDelete }: {
  uid: string;
  paths: StudyPath[];
  resources: Resource[];
  klass: KidsClass;
  students: Student[] | undefined;
  copied: boolean;
  onCopy: () => void;
  onOpen: (s: Student) => void;
  onKick: (s: Student) => void;
  onDelete: () => void;
}) {
  const struggles = students ? groupStruggles(students.map(s => s.data)) : [];

  return (
    <>
      <div className="flex flex-wrap items-start justify-between gap-3">
        <h1 className="text-4xl font-black sm:text-5xl">{klass.name}</h1>
        <button onClick={onDelete} className="btn-press flex items-center gap-1 rounded-full px-3 py-2 font-bold text-gray-500 hover:text-coral">
          <Trash2 size={18} /> Esborra la classe
        </button>
      </div>

      <section className="mt-4 flex flex-wrap items-center gap-4 rounded-3xl bg-white p-5 shadow-sm">
        <span className="flex-1 text-lg">
          <b>Codi de la classe.</b> Les famílies l'escriuen en el perfil del xiquet («Seguiment», apartat «La classe»); les persones adultes, en «Les meues rutes».
        </span>
        <button onClick={onCopy} className="btn-press flex items-center gap-2 rounded-2xl bg-gray-50 px-4 py-2 font-mono text-3xl font-black tracking-[0.3em]" aria-label="Copia el codi">
          {klass.code} <Copy size={20} />
        </button>
        {copied && <span className="text-teal">Copiat!</span>}
      </section>

      {!students ? (
        <p className="mt-6 text-lg opacity-60">Carregant l'alumnat...</p>
      ) : !students.length ? (
        <p className="mt-6 text-lg opacity-60">Encara no s'hi ha unit ningú.</p>
      ) : (
        <>
          <section className="mt-5 overflow-x-auto rounded-3xl bg-white p-5 shadow-sm">
            <h3 className="text-2xl font-black">L'alumnat</h3>
            <table className="mt-3 w-full min-w-[720px] text-left text-lg">
              <thead className="text-sm font-extrabold uppercase tracking-wide opacity-50">
                <tr>
                  <th className="py-2">Nom</th>
                  <th>Última vegada</th>
                  <th>Aquesta setmana</th>
                  <th>Encerts</th>
                  <th>Cromos</th>
                  <th>Li costa</th>
                  <th>Converses</th>
                  <th />
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100">
                {students.map(s => {
                  const r = summarize(s.data);
                  return (
                    <tr key={s.id} className="cursor-pointer hover:bg-gray-50" onClick={() => onOpen(s)}>
                      <td className="py-3 font-extrabold text-[#0F47AF] underline-offset-2 hover:underline">{s.data.name || 'Sense nom'}</td>
                      <td>{ago(r.lastPlayed)}</td>
                      <td>{r.week.minutes} min</td>
                      <td>{percent(r.accuracy)}</td>
                      <td>{r.cromos}/{r.islands.length}</td>
                      <td title={r.costa.map(i => i.name).join(', ')}>{r.costa.slice(0, 4).map(i => i.emoji).join(' ') || '—'}</td>
                      <td title="Objectius complits en l'última conversa de cada escenari">
                        {r.conversations.length
                          ? r.conversations.map(c => `${c.latest.objectives.filter(o => o.met).length}/${c.total}`).join(' · ')
                          : '—'}
                      </td>
                      <td className="text-right">
                        <button
                          onClick={e => { e.stopPropagation(); onKick(s); }}
                          aria-label={`Trau ${s.data.name} de la classe`}
                          className="btn-press p-2 text-gray-400 hover:text-coral"
                        >
                          <UserMinus size={18} />
                        </button>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </section>

          <ClassHomework uid={uid} classId={klass.id} students={students} paths={paths} resources={resources} />

          <ClassPaths uid={uid} classId={klass.id} students={students.map(s => ({ id: s.id, name: s.data.name }))} paths={paths} />

          <section className="mt-5 rounded-3xl bg-white p-5 shadow-sm">
            <h3 className="text-2xl font-black">El que més costa al grup</h3>
            <p className="mt-1 text-base opacity-60">Illes on l'alumne encerta a la primera el 50 % de les rondes o menys.</p>
            {struggles.length ? (
              <ul className="mt-3 flex flex-wrap gap-2">
                {struggles.map(({ island, students: n }) => (
                  <li key={island.id} className="flex items-center gap-2 rounded-full bg-coral/10 px-3 py-1.5 text-lg">
                    <span aria-hidden="true">{island.emoji}</span>
                    <span className="font-bold">{island.name}</span>
                    <span className="text-sm opacity-60">{n} {n === 1 ? 'alumne' : 'alumnes'}</span>
                  </li>
                ))}
              </ul>
            ) : (
              <p className="mt-2 text-lg opacity-70">De moment, no hi ha cap illa que coste a ningú.</p>
            )}
          </section>
        </>
      )}
    </>
  );
}
