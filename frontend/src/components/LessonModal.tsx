import { Fragment, useEffect, useState, type ReactNode } from 'react';
import { createPortal } from 'react-dom';
import { ArrowLeft, ArrowRight, Check, ExternalLink, Loader2, Play, TriangleAlert, X } from 'lucide-react';
import { fetchLesson } from '../lib/api';
import type { Lesson, LessonBlock, Resource } from '../lib/types';

// Format en línia dels textos de les lliçons: `**` obri o tanca la negreta i `*`
// la cursiva, i es poden niuar (*secret**à**ria*, ***gros***). Es convertix a
// elements de React (mai a HTML), així el contingut no pot injectar res.
function Inline({ text }: { text: string }) {
  const nodes: ReactNode[] = [];
  let bold = false;
  let italic = false;
  for (const [i, token] of text.split(/(\*\*|\*)/g).entries()) {
    if (token === '**') bold = !bold;
    else if (token === '*') italic = !italic;
    else if (token) {
      let node: ReactNode = token;
      if (italic) node = <em>{node}</em>;
      if (bold) node = <strong>{node}</strong>;
      nodes.push(<Fragment key={i}>{node}</Fragment>);
    }
  }
  return <>{nodes}</>;
}

function Block({ block, accent }: { block: LessonBlock; accent: string }) {
  return (
    <div className="lesson-step space-y-4">
      <h3 className="text-2xl font-black leading-tight"><Inline text={block.title} /></h3>
      <p className="text-[17px] leading-relaxed"><Inline text={block.text} /></p>

      {block.table && (
        <div className="overflow-x-auto rounded-2xl border border-black/5">
          <table className="lesson-table w-full text-left">
            <thead style={{ background: accent }}>
              <tr>{block.table.head.map((h, i) => <th key={i}><Inline text={h} /></th>)}</tr>
            </thead>
            <tbody>
              {block.table.rows.map((row, i) => (
                <tr key={i}>{row.map((cell, j) => <td key={j}><Inline text={cell} /></td>)}</tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {block.examples && block.examples.length > 0 && (
        <ul className="space-y-2">
          {block.examples.map((example, i) => (
            <li key={i} className="rounded-xl border-l-4 bg-white px-4 py-2 text-[16px]" style={{ borderColor: '#0D9488' }}>
              <Inline text={example} />
            </li>
          ))}
        </ul>
      )}

      {block.watch && block.watch.length > 0 && (
        <div className="rounded-2xl bg-[#FFF7ED] p-4">
          <p className="mb-2 flex items-center gap-1.5 text-sm font-black uppercase tracking-wide text-[#C2410C]">
            <TriangleAlert className="h-4 w-4" /> Compte!
          </p>
          <ul className="space-y-1.5">
            {block.watch.map((w, i) => (
              <li key={i} className="flex flex-wrap items-center gap-x-2 gap-y-1 text-[16px]">
                <span className="text-[#B91C1C] line-through decoration-2 opacity-80"><Inline text={w.wrong} /></span>
                <ArrowRight className="h-4 w-4 shrink-0 opacity-50" />
                <span className="font-bold text-[#15803D]"><Inline text={w.right} /></span>
              </li>
            ))}
          </ul>
        </div>
      )}
    </div>
  );
}

// Lliçó fixa d'un contingut, pas a pas: una regla per pantalla i, al final, el
// resum («Recorda») amb les fonts de l'AVL i l'accés als exercicis.
export function LessonModal({ resource, onClose, onPractice }: {
  resource: Resource;
  onClose: () => void;
  onPractice?: () => void;
}) {
  const [lesson, setLesson] = useState<Lesson | null>();
  const [loadError, setLoadError] = useState(false);
  const [step, setStep] = useState(0);

  useEffect(() => {
    let cancelled = false;
    fetchLesson(resource.id)
      .then(data => { if (!cancelled) setLesson(data); })
      .catch(error => {
        console.error('Error carregant la lliçó:', error);
        if (!cancelled) setLoadError(true);
      });
    return () => { cancelled = true; };
  }, [resource.id]);

  const steps = lesson ? lesson.blocks.length + 1 : 0; // + el pas final «Recorda»
  const last = steps - 1;

  // Escape tanca; les fletxes passen de pas. Mentre està obert, la pàgina de darrere no fa scroll.
  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if (e.key === 'Escape') onClose();
      if (e.key === 'ArrowRight') setStep(s => Math.min(s + 1, Math.max(last, 0)));
      if (e.key === 'ArrowLeft') setStep(s => Math.max(s - 1, 0));
    };
    const overflow = document.body.style.overflow;
    document.body.style.overflow = 'hidden';
    window.addEventListener('keydown', onKey);
    return () => {
      window.removeEventListener('keydown', onKey);
      document.body.style.overflow = overflow;
    };
  }, [onClose, last]);

  const accent = resource.color ?? '#E7E5E4';
  const title = resource.section_name ?? resource.name;

  let body: ReactNode;
  if (loadError || lesson === null) {
    body = <p className="py-16 text-center text-sm font-bold opacity-60">No hem pogut carregar la lliçó. Torna-ho a provar més tard.</p>;
  } else if (!lesson) {
    body = (
      <p className="flex items-center justify-center gap-2 py-16 text-sm font-bold opacity-60">
        <Loader2 className="h-4 w-4 animate-spin" /> Carregant la lliçó…
      </p>
    );
  } else if (step < lesson.blocks.length) {
    body = <Block key={step} block={lesson.blocks[step]} accent={accent} />;
  } else {
    body = (
      <div key="recorda" className="lesson-step space-y-5">
        <h3 className="text-2xl font-black">Recorda</h3>
        <ul className="space-y-3">
          {lesson.remember.map((idea, i) => (
            <li key={i} className="flex items-start gap-3 text-[17px] leading-snug">
              <span className="mt-0.5 grid h-6 w-6 shrink-0 place-items-center rounded-full bg-teal text-white"><Check className="h-4 w-4" /></span>
              <span><Inline text={idea} /></span>
            </li>
          ))}
        </ul>
        {onPractice && (
          <button
            onClick={onPractice}
            className="btn-press inline-flex items-center gap-2 rounded-full bg-[#F97316] px-6 py-3 text-lg font-black text-white shadow hover:brightness-105"
          >
            <Play className="h-5 w-5" /> Practicar ara
          </button>
        )}
        <div className="border-t border-black/5 pt-4 text-xs opacity-70">
          <p className="mb-1 font-bold">Basat en les gramàtiques de l'Acadèmia Valenciana de la Llengua:</p>
          <ul className="flex flex-wrap gap-1.5">
            {lesson.sources.map(s => (
              <li key={`${s.gram}-${s.section}`}>
                <a
                  href={s.url}
                  target="_blank"
                  rel="noopener noreferrer"
                  title={`${s.gram === 'GVB' ? 'Gramàtica valenciana bàsica' : 'Gramàtica normativa valenciana'}: ${s.title}`}
                  className="inline-flex items-center gap-0.5 rounded-full bg-white px-2 py-0.5 font-bold hover:text-teal"
                >
                  {s.gram} § {s.section} <ExternalLink className="h-3 w-3" />
                </a>
              </li>
            ))}
          </ul>
        </div>
      </div>
    );
  }

  // En un portal: les pantalles tenen animacions amb transform, i un `fixed`
  // dins d'elles es posicionaria respecte a la pantalla sencera, no a la finestra.
  return createPortal(
    <div
      className="modal-backdrop fixed inset-0 z-50 grid place-items-center bg-navy/40 p-3 sm:p-5"
      onClick={e => e.target === e.currentTarget && onClose()}
    >
      <section
        role="dialog"
        aria-modal="true"
        aria-labelledby="lesson-title"
        className="modal-content flex max-h-[92vh] w-full max-w-2xl flex-col overflow-hidden rounded-[28px] bg-cream shadow-2xl"
      >
        <header className="relative px-6 pb-4 pt-6" style={{ background: `linear-gradient(135deg, ${accent} 0%, #FFF9ED 85%)` }}>
          <button onClick={onClose} aria-label="Tancar la lliçó" className="btn-press absolute right-4 top-4 rounded-full bg-white/70 p-1.5 hover:bg-white">
            <X className="h-5 w-5" />
          </button>
          <div className="flex items-center gap-3 pr-10">
            <span className="grid h-14 w-14 shrink-0 place-items-center rounded-2xl bg-white/80 text-3xl shadow-sm">{resource.icon ?? '📘'}</span>
            <div className="min-w-0">
              <p className="text-xs font-black uppercase tracking-wider text-teal">Lliçó · Nivell B1</p>
              <h2 id="lesson-title" className="text-2xl font-black leading-tight">{title}</h2>
            </div>
          </div>
          {lesson && step === 0 && <p className="mt-3 text-[15px] leading-snug opacity-80"><Inline text={lesson.intro} /></p>}
          {lesson && (
            <div className="mt-4 flex gap-1.5" role="tablist" aria-label="Passos de la lliçó">
              {Array.from({ length: steps }, (_, i) => (
                <button
                  key={i}
                  role="tab"
                  aria-selected={i === step}
                  aria-label={i < lesson.blocks.length ? lesson.blocks[i].title : 'Recorda'}
                  title={i < lesson.blocks.length ? lesson.blocks[i].title : 'Recorda'}
                  onClick={() => setStep(i)}
                  className={`h-2 flex-1 rounded-full transition-colors ${i <= step ? 'bg-teal' : 'bg-white/70 hover:bg-white'}`}
                />
              ))}
            </div>
          )}
        </header>

        <div className="min-h-[18rem] overflow-y-auto px-6 py-6">{body}</div>

        {lesson && (
          <footer className="flex items-center justify-between gap-3 border-t border-black/5 bg-white/60 px-6 py-3">
            <button
              onClick={() => setStep(s => Math.max(s - 1, 0))}
              disabled={step === 0}
              className="btn-press inline-flex items-center gap-1 rounded-full px-4 py-2 font-black text-teal hover:bg-teal/10 disabled:invisible"
            >
              <ArrowLeft className="h-4 w-4" /> Anterior
            </button>
            <span className="text-sm font-bold opacity-50">{step + 1} / {steps}</span>
            {step < last ? (
              <button
                onClick={() => setStep(s => Math.min(s + 1, last))}
                className="btn-press inline-flex items-center gap-1 rounded-full bg-teal px-5 py-2 font-black text-white hover:brightness-110"
              >
                Següent <ArrowRight className="h-4 w-4" />
              </button>
            ) : (
              <button onClick={onClose} className="btn-press rounded-full bg-teal/10 px-5 py-2 font-black text-teal hover:bg-teal hover:text-white">
                Tancar
              </button>
            )}
          </footer>
        )}
      </section>
    </div>,
    document.body,
  );
}
