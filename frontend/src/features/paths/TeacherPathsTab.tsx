import { useState } from 'react';
import { classLevelLabel, isLevel0Class } from '@parlaval/shared';
import type { KidsClass } from '../kids/tracking';
import { ClassPaths } from './ClassPaths';
import { PATH_LEVELS } from './teacherPaths';

/**
 * Pestanya «Rutes» de la docent: tria una classe i hi crea, edita o genera amb IA les rutes d'aprenentatge.
 * Una ruta sempre és d'una classe (l'alumnat la veu en «Classe»), per això primer es tria la classe; les rutes són
 * de l'A1 al C2, així que les classes del Nivell 0 no hi surten.
 */
export function TeacherPathsTab({ classes }: { classes: KidsClass[] }) {
  const eligible = classes.filter(c => !isLevel0Class(c.levels) && c.levels.some(l => PATH_LEVELS.some(p => p.value === l)));
  const [selectedId, setSelectedId] = useState<string>();
  const selected = eligible.find(c => c.id === selectedId) ?? eligible[0];

  return (
    <>
      <h1 className="text-5xl font-black">Rutes d'aprenentatge</h1>
      <p className="mt-2 text-lg opacity-70">
        Crea rutes d'activitats per a una classe (de l'A1 al C2), a mà o amb IA. L'alumnat les veu en la secció «Classe».
      </p>

      {!selected ? (
        <p className="mt-6 rounded-3xl bg-white p-5 text-lg opacity-80 shadow-sm">
          Encara no tens cap classe d'A1 a C2. Crea'n una en la pestanya «Classes» per a poder crear-hi rutes.
        </p>
      ) : (
        <>
          <div className="mt-5" role="group" aria-label="Classe de les rutes">
            <p className="text-base font-extrabold">Classe</p>
            <div className="mt-2 flex flex-wrap gap-2">
              {eligible.map(c => (
                <button
                  key={c.id}
                  aria-pressed={c.id === selected.id}
                  onClick={() => setSelectedId(c.id)}
                  className={`btn-press rounded-2xl border-2 px-4 py-2 text-lg font-extrabold ${c.id === selected.id ? 'border-[#0F47AF] bg-[#0F47AF]/10 text-[#0F47AF]' : 'border-gray-100 bg-white text-gray-600'}`}
                >
                  {c.name} <span className="text-sm opacity-60">{c.levels.map(classLevelLabel).join(' · ')}</span>
                </button>
              ))}
            </div>
          </div>
          {/* key: en canviar de classe es torna a carregar des de zero (rutes, esborrany i avisos). */}
          <ClassPaths key={selected.id} classId={selected.id} className={selected.name} classLevels={selected.levels} />
        </>
      )}
    </>
  );
}
