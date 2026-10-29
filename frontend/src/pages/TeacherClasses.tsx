import { useEffect, useRef, useState, type FormEvent } from 'react';
import { Copy, LogOut, Plus, Trash2, UserMinus } from 'lucide-react';
import { Logo, OrangeHeader } from '../components/ui';
import { supabase } from '../lib/supabase';
import { CLASS_LEVELS, classLevelLabel, isLevel0Class, toggleClassLevel } from '@parlaval/shared';
import { ProgressReport } from '../features/kids/ProgressReport';
import { ClassPaths } from '../features/paths/ClassPaths';
import { ClassActivities } from '../features/paths/ClassActivities';
import { TeacherActivities } from '../features/activities/TeacherActivities';
import { TeacherPathsTab } from '../features/paths/TeacherPathsTab';
import { StudentsByClass } from '../features/kids/StudentsByClass';
import { ago, groupAdultStruggles, groupStruggles, percent, summarize, summarizeAdult } from '../features/kids/report';
import { useConfirm } from '../components/ConfirmDialog';
import {
  createClass, deleteClass, loadMyClasses, loadStudents, removeStudent, type KidsClass, type Student,
} from '../features/kids/tracking';

const FIELD_CLASS = 'w-full rounded-2xl border-2 border-gray-100 p-3 text-xl font-normal outline-none focus:border-[#0F47AF] transition-colors';

/**
 * Les classes del professorat (Nivell 0). La docent crea una classe i rep un codi; les
 * famílies l'escriuen en el seguiment del perfil del xiquet. Per a cada classe: la taula
 * de l'alumnat, les illes que costen al grup i la fitxa de seguiment de cada alumne (amb
 * les seues converses amb personatges, que també pot llegir).
 */
export function TeacherClasses({ uid, onLogOut }: { uid: string | undefined; onLogOut: () => void }) {
  const { confirm } = useConfirm();
  const [classes, setClasses] = useState<KidsClass[]>();
  const [selected, setSelected] = useState<KidsClass>();
  const [students, setStudents] = useState<Student[]>();
  const [student, setStudent] = useState<Student>();
  const [newName, setNewName] = useState('');
  const [newLevels, setNewLevels] = useState<string[]>([]);
  const [error, setError] = useState<string>();
  const [copied, setCopied] = useState(false);
  // Pantalla principal de la docent: les classes, l'alumnat, la biblioteca d'activitats o les rutes.
  const [tab, setTab] = useState<'classes' | 'students' | 'activities' | 'paths'>('classes');
  // Alumne que s'obri directament des de la pestanya «Alumnat» (en canviar de classe, l'efecte l'esborraria).
  const openStudent = useRef<Student>();
  // Si la fitxa s'ha obert des de «Alumnat», «Tornar» hi torna directament (no a la classe).
  const [fromStudents, setFromStudents] = useState(false);
  const online = !!supabase && !!uid;

  useEffect(() => {
    if (!online) return;
    loadMyClasses(uid!).then(setClasses).catch(e => {
      console.error(e);
      setError("No s'han pogut carregar les classes.");
    });
  }, [uid, online]);

  useEffect(() => {
    setStudents(undefined);
    setStudent(openStudent.current);
    openStudent.current = undefined;
    if (!selected) return;
    let cancelled = false;
    loadStudents(selected.id, !isLevel0Class(selected.levels))
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
      const created = await createClass(newName.trim(), newLevels);
      setClasses(c => [...(c ?? []), created]);
      setNewName('');
      setNewLevels([]);
      setSelected(created);
    } catch (e) {
      console.error(e);
      setError("No s'ha pogut crear la classe.");
    }
  };

  const remove = async (c: KidsClass) => {
    if (!(await confirm({ title: 'Esborrar la classe?', message: `Segur que vols esborrar la classe «${c.name}»? L'alumnat no perd el seu progrés.`, confirmLabel: 'Esborra', tone: 'danger' }))) return;
    await deleteClass(c.id).catch(console.error);
    setClasses(list => list?.filter(x => x.id !== c.id));
    setSelected(undefined);
  };

  const kick = async (s: Student) => {
    if (!selected) return;
    if (!(await confirm({ title: "Traure l'alumne?", message: `Vols traure ${s.data.name || 'este alumne'} de la classe?`, confirmLabel: 'Trau', tone: 'danger' }))) return;
    await removeStudent(selected.id, s.id).catch(console.error);
    setStudents(list => list?.filter(x => x.id !== s.id));
  };

  const copy = async (code: string) => {
    await navigator.clipboard?.writeText(code).catch(() => undefined);
    setCopied(true);
    window.setTimeout(() => setCopied(false), 1500);
  };

  const back = () => {
    if (student && fromStudents) {
      setFromStudents(false);
      setStudent(undefined);
      setSelected(undefined);
    } else if (student) setStudent(undefined);
    else setSelected(undefined);
  };

  return (
    <main className="fade-up" style={{ background: '#FAFAF9', minHeight: '100vh' }}>
      <OrangeHeader showOranges={false}>
        {/* El professorat només té esta pantalla: dins d'una classe es torna enrere; a la llista, es tanca la sessió. */}
        <div className="grid grid-cols-[1fr_auto_1fr] items-center gap-2 px-5 pb-2">
          {selected ? (
            <button onClick={back} className="text-xl btn-press justify-self-start rounded-full bg-white/90 px-4 py-2 text-sm font-extrabold text-teal shadow hover:bg-white transition-colors">
              ← Tornar
            </button>
          ) : <span />}
          <Logo size="lg" />
          <button onClick={async () => { if (await confirm({ title: 'Vols tancar la sessió?', message: "Tornaràs a la pantalla d'entrada.", confirmLabel: 'Tanca-la', icon: LogOut })) onLogOut(); }} id="classes-logout-btn" className="btn-press flex items-center gap-2 justify-self-end rounded-full bg-white/90 px-4 py-2 text-sm font-extrabold text-coral shadow hover:bg-white transition-colors">
            <LogOut size={16} /> <span className="hidden sm:inline">Tanca la sessió</span>
          </button>
        </div>
      </OrangeHeader>

      <div className="mx-auto max-w-4xl px-5 pt-6 pb-16">
        {error && <p className="mb-4 rounded-2xl bg-coral/10 p-3 text-lg text-coral">{error}</p>}

        {!online ? (
          <>
            <h1 className="text-5xl font-black">Les meues classes</h1>
            <p className="mt-3 text-lg opacity-70">Cal iniciar sessió amb un compte d'adult per a crear classes i seguir l'alumnat del Nivell 0.</p>
          </>
        ) : student ? (
          <>
            <h1 className="text-4xl font-black">{student.data.name || 'Alumne'}</h1>
            <p className="mt-1 mb-5 text-lg opacity-70">{selected?.name} · a la classe des de {new Date(student.joined_at).toLocaleDateString('ca-ES')}</p>
            <ProgressReport data={student.data} name={student.data.name} />
          </>
        ) : selected ? (
          <ClassView
            klass={selected}
            students={students}
            copied={copied}
            onCopy={() => void copy(selected.code)}
            onOpen={setStudent}
            onKick={s => void kick(s)}
            onDelete={() => void remove(selected)}
          />
        ) : (
          <>
            <div className="mb-6 flex gap-2 rounded-full bg-white p-1 shadow-sm sm:w-fit" role="tablist">
              {([['classes', 'Classes'], ['students', 'Alumnat'], ['activities', 'Activitats'], ['paths', 'Rutes']] as const).map(([id, label]) => (
                <button
                  key={id}
                  role="tab"
                  aria-selected={tab === id}
                  onClick={() => setTab(id)}
                  className={`btn-press flex-1 rounded-full px-5 py-2 text-lg font-extrabold sm:flex-none ${tab === id ? 'bg-[#0F47AF] text-white' : 'text-[#0F47AF]'}`}
                >
                  {label}
                </button>
              ))}
            </div>
            {tab === 'activities' ? <TeacherActivities classes={classes ?? []} /> : tab === 'paths' ? <TeacherPathsTab classes={classes ?? []} /> : tab === 'students' ? (
              <StudentsByClass classes={classes ?? []} onOpen={(c, s) => { openStudent.current = s; setFromStudents(true); setSelected(c); }} />
            ) : (
          <>
            <h1 className="text-5xl font-black">Les meues classes</h1>
            <p className="mt-2 text-lg opacity-70">Classes d'infantil (Nivell 0) i d'adults (A1-C2): l'alumnat s'hi unix amb el codi.</p>

            <ul className="mt-6 grid gap-3 sm:grid-cols-2">
              {classes?.map(c => (
                <li key={c.id}>
                  <button onClick={() => setSelected(c)} className="btn-press w-full rounded-3xl bg-white p-5 text-left shadow-sm hover:bg-white/80">
                    <span className="block text-2xl font-black">{c.name}</span>
                    <LevelBadges levels={c.levels} />
                    <span className="mt-1 block font-mono text-lg tracking-widest opacity-60">{c.code}</span>
                  </button>
                </li>
              ))}
            </ul>
            {classes?.length === 0 && <p className="mt-2 text-lg opacity-60">Encara no tens cap classe.</p>}

            <form onSubmit={create} className="mt-6 rounded-3xl bg-white p-5 shadow-sm">
              <label className="block text-xl font-extrabold" htmlFor="class-name">Crea una classe</label>
              <p className="mt-3 text-base font-extrabold">Nivell de l'alumnat</p>
              <p className="text-sm opacity-60">Només s'hi podrà unir alumnat d'estos nivells. Tria el Nivell 0 (infantil), o un o dos nivells contigus (per a qui està entre els dos).</p>
              <div className="mt-2 flex flex-wrap gap-2" role="group" aria-label="Nivell de la classe">
                {CLASS_LEVELS.map(l => (
                  <button
                    key={l.value}
                    type="button"
                    aria-pressed={newLevels.includes(l.value)}
                    onClick={() => setNewLevels(levels => toggleClassLevel(levels, l.value))}
                    className={`btn-press rounded-2xl border-2 px-4 py-2 text-lg font-extrabold ${newLevels.includes(l.value) ? 'border-[#0F47AF] bg-[#0F47AF]/10 text-[#0F47AF]' : 'border-gray-100 text-gray-600'}`}
                  >
                    {l.label}
                  </button>
                ))}
              </div>
              <div className="mt-3 flex gap-2">
                <input id="class-name" value={newName} onChange={e => setNewName(e.target.value.slice(0, 60))} placeholder="P. ex.: Infantil 5 anys B" className={FIELD_CLASS} />
                <button disabled={!newName.trim() || !newLevels.length} className="btn-press flex shrink-0 items-center gap-2 rounded-2xl bg-[#0F47AF] px-5 text-xl font-extrabold text-white disabled:opacity-40">
                  <Plus size={20} /> Crea
                </button>
              </div>
            </form>
          </>
            )}
          </>
        )}
      </div>
    </main>
  );
}

function LevelBadges({ levels }: { levels: string[] }) {
  return (
    <span className="mt-1 flex gap-1">
      {levels.map(l => <span key={l} className="rounded-full bg-[#0F47AF]/10 px-2.5 py-0.5 text-sm font-black text-[#0F47AF]">{classLevelLabel(l)}</span>)}
    </span>
  );
}

function ClassView({ klass, students, copied, onCopy, onOpen, onKick, onDelete }: {
  klass: KidsClass;
  students: Student[] | undefined;
  copied: boolean;
  onCopy: () => void;
  onOpen: (s: Student) => void;
  onKick: (s: Student) => void;
  onDelete: () => void;
}) {
  const struggles = students ? groupStruggles(students.map(s => s.data)) : [];
  const adultStruggles = students && !isLevel0Class(klass.levels) ? groupAdultStruggles(students.map(s => s.data)) : [];
  // Les illes, els cromos i les partides són del Nivell 0: en les classes d'adults només es veuen els escenaris.
  const kidsClass = isLevel0Class(klass.levels);
  const [pathsVersion, setPathsVersion] = useState(0);

  return (
    <>
      <div className="flex flex-wrap items-start justify-between gap-3">
        <div>
          <h1 className="text-4xl font-black sm:text-5xl">{klass.name}</h1>
          <LevelBadges levels={klass.levels} />
        </div>
        <button onClick={onDelete} className="btn-press flex items-center gap-1 rounded-full px-3 py-2 font-bold text-gray-500 hover:text-coral">
          <Trash2 size={18} /> Esborra la classe
        </button>
      </div>

      <section className="mt-4 flex flex-wrap items-center gap-4 rounded-3xl bg-white p-5 shadow-sm">
        <span className="flex-1 text-lg">
          <b>Codi de la classe.</b>{' '}
          {isLevel0Class(klass.levels)
            ? "Doneu-lo a les famílies, que l'escriuen en el perfil del xiquet («Seguiment», apartat «La classe», amb el PIN)."
            : "Doneu-lo a l'alumnat, que l'escriu en «Classe» o en el seu perfil («Les meues classes»)."}
        </span>
        <button onClick={onCopy} className="btn-press flex items-center gap-2 rounded-2xl bg-gray-50 px-4 py-2 font-mono text-3xl font-black tracking-[0.3em]" aria-label="Copia el codi">
          {klass.code} <Copy size={20} />
        </button>
        {copied && <span className="text-teal">Copiat!</span>}
      </section>

      {/* El Nivell 0 és massa bàsic per a activitats i rutes de la docent: només el seguiment infantil. */}
      {!isLevel0Class(klass.levels) && (
        <>
          {/* En guardar una ruta, les activitats pròpies que hi ha s'assignen a la classe: es tornen a carregar. */}
          <ClassActivities key={pathsVersion} classId={klass.id} classLevels={klass.levels} />
          <ClassPaths classId={klass.id} className={klass.name} classLevels={klass.levels} onSaved={() => setPathsVersion(v => v + 1)} />
        </>
      )}

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
                  <th>{kidsClass ? 'Última vegada' : 'Última activitat'}</th>
                  {kidsClass ? (
                    <>
                      <th>Aquesta setmana</th>
                      <th>Encerts</th>
                      <th>Cromos</th>
                      <th>Li costa</th>
                    </>
                  ) : (
                    <>
                      <th>Li costa</th>
                      <th>A practicar</th>
                      <th>Ho domina</th>
                    </>
                  )}
                  <th>{kidsClass ? 'Converses' : 'Objectius dels escenaris'}</th>
                  <th />
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100">
                {students.map(s => {
                  const r = summarize(s.data);
                  const a = summarizeAdult(s.data);
                  return (
                    <tr key={s.id} className="cursor-pointer hover:bg-gray-50" onClick={() => onOpen(s)}>
                      <td className="py-3 font-extrabold text-[#0F47AF] underline-offset-2 hover:underline">{s.data.name || 'Sense nom'}</td>
                      <td>{ago(kidsClass ? r.lastPlayed : a.lastActivity)}</td>
                      {kidsClass ? (
                        <>
                          <td>{r.week.minutes} min</td>
                          <td>{percent(r.accuracy)}</td>
                          <td>{r.cromos}/{r.islands.length}</td>
                          <td title={r.costa.map(i => i.name).join(', ')}>{r.costa.slice(0, 4).map(i => i.emoji).join(' ') || '—'}</td>
                        </>
                      ) : (
                        <>
                          <td title={a.costa.map(i => i.name).join(', ')}>{a.costa.length ? `${a.costa.length} · ${a.costa.slice(0, 3).map(i => i.emoji).join(' ')}` : '—'}</td>
                          <td title={a.practicar.map(i => i.name).join(', ')}>{a.practicar.length || '—'}</td>
                          <td title={a.domina.map(i => i.name).join(', ')}>{a.domina.length || '—'}</td>
                        </>
                      )}
                      <td title="Objectius complits en l'última conversa de cada escenari">
                        {!r.conversations.length ? '—' : kidsClass
                          ? r.conversations.map(c => `${c.latest.objectives.filter(o => o.met).length}/${c.total}`).join(' · ')
                          : (
                            <ul className="space-y-0.5 text-base">
                              {r.conversations.slice(0, 3).map(c => (
                                <li key={c.id}>{c.name} <b>{c.latest.objectives.filter(o => o.met).length}/{c.total}</b></li>
                              ))}
                              {r.conversations.length > 3 && <li className="opacity-60">+{r.conversations.length - 3} més</li>}
                            </ul>
                          )}
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

          {kidsClass && (
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
          {!kidsClass && (
            <section className="mt-5 rounded-3xl bg-white p-5 shadow-sm">
              <h3 className="text-2xl font-black">El que més costa al grup</h3>
              <p className="mt-1 text-base opacity-60">Activitats on l'alumne té el 50 % o menys d'encerts o d'objectius complits.</p>
              {adultStruggles.length ? (
                <ul className="mt-3 flex flex-wrap gap-2">
                  {adultStruggles.map(({ item, students: n }) => (
                    <li key={item.key} className="flex items-center gap-2 rounded-full bg-coral/10 px-3 py-1.5 text-lg">
                      <span aria-hidden="true">{item.emoji}</span>
                      <span className="font-bold">{item.name}</span>
                      <span className="text-sm opacity-60">{n} {n === 1 ? 'alumne' : 'alumnes'}</span>
                    </li>
                  ))}
                </ul>
              ) : (
                <p className="mt-2 text-lg opacity-70">De moment, no hi ha cap activitat que coste a ningú.</p>
              )}
            </section>
          )}
            </section>
          )}
        </>
      )}
    </>
  );
}
