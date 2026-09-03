import { X } from 'lucide-react';
export type Msg={role:'user'|'character';text:string;transcription?:string};
export function HistoryModal({messages,onClose}:{messages:Msg[];onClose:()=>void}){
  return <div className="modal-backdrop fixed inset-0 z-50 grid place-items-center bg-navy/40 p-5">
    <section className="modal-content max-h-[75vh] w-full max-w-lg overflow-auto rounded-3xl bg-cream p-6 shadow-2xl">
      <header className="mb-5 flex items-center justify-between">
        <h2 className="text-xl font-black">La conversa</h2>
        <button onClick={onClose} className="btn-press"><X/></button>
      </header>
      {messages.map((m,i)=><div key={i} className={`mb-3 max-w-[85%] rounded-2xl px-4 py-3 ${m.role==='user'?'ml-auto bg-teal text-white':'bg-white'}`}><p>{m.text}</p>{m.transcription && <p className="mt-2 border-t border-white/30 pt-2 text-sm font-normal opacity-90">Transcripció: {m.transcription}</p>}</div>)}
    </section>
  </div>;
}
