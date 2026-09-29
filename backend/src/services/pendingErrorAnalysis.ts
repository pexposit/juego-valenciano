// Registre en memòria dels torns (i les seues anàlisis d'errors amb LLM) encara en
// curs per a cada session_resource_id. L'endpoint que tanca un recurs ("Eixir") ha
// d'esperar que acaben tots abans de disparar l'avaluació pedagògica.
const pending = new Map<string, Set<Promise<void>>>();

const MAX_WAIT_MS = 120_000;

// Es crida en rebre el torn (abans de STT/agent/TTS), no en llançar l'anàlisi:
// si l'usuari prem "Eixir" mentre el torn encara es processa, ja consta com a pendent.
export function beginErrorAnalysis(sessionResourceId: string): () => void {
  let resolve!: () => void;
  const promise = new Promise<void>((r) => { resolve = r; });

  let set = pending.get(sessionResourceId);
  if (!set) {
    set = new Set();
    pending.set(sessionResourceId, set);
  }
  set.add(promise);

  let finished = false;
  return () => {
    if (finished) return;
    finished = true;
    set!.delete(promise);
    if (set!.size === 0 && pending.get(sessionResourceId) === set) pending.delete(sessionResourceId);
    resolve();
  };
}

export async function waitForPendingErrorAnalysis(sessionResourceId: string): Promise<void> {
  const deadline = Date.now() + MAX_WAIT_MS;
  // En bucle: mentre s'espera pot arribar un altre torn del mateix recurs.
  while (Date.now() < deadline) {
    const set = pending.get(sessionResourceId);
    if (!set || set.size === 0) return;
    let timer: NodeJS.Timeout | undefined;
    await Promise.race([
      Promise.all(Array.from(set)),
      new Promise((r) => { timer = setTimeout(r, deadline - Date.now()); }),
    ]);
    clearTimeout(timer);
  }
  console.warn(`[pendingErrorAnalysis] Temps d'espera esgotat per a ${sessionResourceId}; s'avalua igualment.`);
}
