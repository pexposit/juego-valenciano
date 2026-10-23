import { useRef, useState } from 'react';
import { CEFR_LEVELS, type AgentDocument, type CefrLevel, type TeacherActivityInput } from '@parlaval/shared';
import { generateActivityDraft } from '../../lib/api';
import { DocumentAttach } from './DocumentAttach';
import { isAbort, PromptBox } from './PromptBox';

const SELECT = 'rounded-2xl border-2 bg-white p-2 text-lg font-bold outline-none focus:border-[#0F47AF]';

/**
 * «Genera amb IA» en la biblioteca d'activitats. El resultat és un esborrany que s'obri en l'editor (amb vista prèvia)
 * perquè la docent el revise abans de guardar-lo. Si no es pot generar, es mostra el motiu.
 */
export function ActivityAgent({ onDraft, onClose }: { onDraft: (activity: TeacherActivityInput, notes: string) => void; onClose: () => void }) {
  const [level, setLevel] = useState<CefrLevel | ''>('');
  const [message, setMessage] = useState<string>();
  const [document, setDocument] = useState<AgentDocument>();
  // S'ha intentat generar sense triar el nivell: es marca el camp i s'avisa.
  const [levelMissing, setLevelMissing] = useState(false);
  const levelSelect = useRef<HTMLSelectElement>(null);

  return (
    <>
      <PromptBox
        title="Crea una activitat amb IA"
        hint={<>Descriu l'activitat que vols. Pot ser: <b>exercicis</b> (fonètica i ortografia, morfosintaxi o lèxic), <b>comprensió lectora</b>, <b>redacció</b> o <b>escenari de conversa</b>. Altres tipus (àudios, imatges, jocs...) encara no es poden crear.</>}
        placeholder={document ? "Ex.: 8 exercicis sobre el tema 3 del document, amb preguntes d'opció múltiple" : "Ex.: 8 exercicis de B1 sobre els pronoms febles de complement directe, amb preguntes d'opció múltiple i d'escriure la resposta"}
        extra={(
          <>
          <DocumentAttach value={document} onChange={setDocument} />
          <label className="mt-3 flex items-center gap-2 text-base font-extrabold">
            Nivell (obligatori)
            <select
              ref={levelSelect}
              value={level}
              onChange={e => { setLevel(e.target.value as CefrLevel | ''); setLevelMissing(false); }}
              required
              aria-required="true"
              aria-invalid={levelMissing}
              aria-describedby={levelMissing ? 'level-missing' : undefined}
              className={`${SELECT} ${levelMissing ? 'border-coral' : 'border-gray-100'}`}
            >
              <option value="" disabled>Tria un nivell</option>
              {CEFR_LEVELS.map(l => <option key={l} value={l}>{l}</option>)}
            </select>
          </label>
          {levelMissing && (
            <p id="level-missing" role="alert" className="mt-2 rounded-2xl bg-coral/10 p-3 font-bold text-coral">
              Falta triar el nivell. Tria el nivell de l'activitat per a poder generar-la.
            </p>
          )}
          </>
        )}
        beforeSubmit={() => {
          if (level) return true;
          setLevelMissing(true);
          levelSelect.current?.focus();
          return false;
        }}
        onClose={onClose}
        onSubmit={async (prompt, signal) => {
          if (!level) return;
          setMessage(undefined);
          try {
            const result = await generateActivityDraft(prompt, level, signal, document?.id);
            if (result.ok) onDraft(result.activity, result.notes);
            else setMessage(result.message);
          } catch (e) {
            if (!isAbort(e)) setMessage(e instanceof Error ? e.message : String(e));
          }
        }}
      />
      {message && (
        <p role="alert" className="mt-3 rounded-2xl bg-mustard/20 p-4 text-lg">
          <b>No s'ha pogut crear l'activitat.</b> {message}
        </p>
      )}
    </>
  );
}
