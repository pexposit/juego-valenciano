import { describe, expect, it } from 'vitest';
import { activityFromLlm, isCreatableRequest, loadPathCandidates, MIN_PATH_STEPS, PATH_LEVELS, pathFromLlm, type LlmActivity, type PathCandidate } from './teacherAgent.js';

const base: LlmActivity = {
  feasible: true, message: '', kind: 'exercises', level: 'B1', title: 'Pronoms febles', description: 'Repàs', icon: '🧩',
  area: 'morfosintaxi', text_title: '', text: '', questions: [], writing_prompt: '', min_words: 0, max_words: 0,
  character: '', situation: '', greeting: '', objectives: [], voice: '', background: '',
};
const choice = (prompt: string, correct = 0) => ({ type: 'choice' as const, prompt, options: ['a', 'b', 'c'], correct, answers: [], explanation: 'Perquè sí.' });
const fill = (prompt: string) => ({ type: 'fill' as const, prompt, options: [], correct: 0, answers: ['ho'], explanation: '' });

describe('activityFromLlm', () => {
  it('construïx un full d\'exercicis vàlid', () => {
    const result = activityFromLlm({ ...base, questions: [choice('Q1'), fill('Q2')] });
    expect(result).toMatchObject({ activity: { level: 'B1', class_ids: [], content: { kind: 'exercises', area: 'morfosintaxi' } } });
  });

  it('respecta el nivell demanat per la docent', () => {
    const result = activityFromLlm({ ...base, level: 'B1', questions: [choice('Q1')] }, 'A2');
    expect(result).toMatchObject({ activity: { level: 'A2' } });
  });

  it('torna el motiu quan el model diu que no es pot', () => {
    expect(activityFromLlm({ ...base, feasible: false, message: 'No puc crear àudios.' })).toEqual({ refused: 'No puc crear àudios.' });
    expect(activityFromLlm({ ...base, feasible: false, message: '' })).toMatchObject({ refused: expect.stringContaining('comprensió lectora') });
  });

  it('en una lectura només deixa les preguntes tancades', () => {
    const result = activityFromLlm({ ...base, kind: 'reading', text: 'Un text.', questions: [choice('Q1'), fill('Q2')] });
    expect(result).toMatchObject({ activity: { content: { kind: 'reading', questions: [{ type: 'choice' }] } } });
  });

  it('ajusta les paraules d\'una redacció als límits', () => {
    const result = activityFromLlm({ ...base, kind: 'writing', writing_prompt: 'Escriu una carta.', min_words: 5, max_words: 5000 });
    expect(result).toMatchObject({ activity: { content: { kind: 'writing', min_words: 20, max_words: 300 } } });
  });

  it('valida un escenari complet i rebutja un amb valors no permesos', () => {
    const scenario = { ...base, kind: 'scenario', character: 'Camarera', situation: 'En un bar', greeting: 'Bon dia!', objectives: ['Demanar un cafè'], voice: 'gina', background: '/images/bar.jpg' };
    expect(activityFromLlm(scenario)).toMatchObject({ activity: { content: { kind: 'scenario' } } });
    expect(activityFromLlm({ ...scenario, voice: 'robot' })).toHaveProperty('problems');
  });

  it('demana correcció si la pregunta és invàlida (resposta correcta fora de les opcions, sense preguntes)', () => {
    expect(activityFromLlm({ ...base, questions: [choice('Q1', 7)] })).toHaveProperty('problems');
    expect(activityFromLlm({ ...base, questions: [] })).toHaveProperty('problems');
  });

  it('demana correcció si el tipus no és vàlid', () => {
    expect(activityFromLlm({ ...base, kind: 'audio' })).toHaveProperty('problems');
  });

  it('usa la icona del tipus si la del model no val', () => {
    const result = activityFromLlm({ ...base, icon: 'x'.repeat(40), questions: [choice('Q1')] });
    expect(result).toMatchObject({ activity: { icon: '🧩' } });
  });
});

const cand = (n: number, level = 'B1', own = false): PathCandidate => ({ id: `id-${n}`, title: `Activitat ${n}`, category: 'morfosintaxi', icon: null, own, level });
const candidates = [1, 2, 3, 4, 5].map(n => cand(n)).concat([cand(6, 'B2')]);
const raw = (over: Partial<Parameters<typeof pathFromLlm>[0]> = {}) => ({
  status: 'ok' as const, level: 'B1', title: 'Pronoms', description: 'Ruta de pronoms', message: '',
  steps: [1, 2, 3].map(n => ({ n, reason: `Perquè ${n}` })), missing: [], ...over,
});

describe('pathFromLlm', () => {
  it('construïx una ruta amb activitats existents i el motiu de cada pas', () => {
    const result = pathFromLlm(raw(), candidates, 'pronoms febles');
    expect(result).toMatchObject({ status: 'ok', level: 'B1', title: 'Pronoms' });
    if (result.status !== 'ok') throw new Error('esperava ok');
    expect(result.steps.map(s => s.resource_id)).toEqual(['id-1', 'id-2', 'id-3']);
    expect(result.steps[0].reason).toBe('Perquè 1');
  });

  it('descarta números inventats i repetits', () => {
    const result = pathFromLlm(raw({ steps: [1, 1, 99, 0, -2, 2, 3, 4].map(n => ({ n, reason: 'x' })) }), candidates, 'p');
    expect(result.status).toBe('ok');
    if (result.status !== 'ok') return;
    expect(result.steps.map(s => s.resource_id)).toEqual(['id-1', 'id-2', 'id-3', 'id-4']);
  });

  it('només deixa activitats d\'un nivell', () => {
    const result = pathFromLlm(raw({ steps: [1, 2, 3, 6].map(n => ({ n, reason: 'x' })) }), candidates, 'p');
    if (result.status !== 'ok') throw new Error('esperava ok');
    expect(result.steps.map(s => s.resource_id)).toEqual(['id-1', 'id-2', 'id-3']);
  });

  it('és parcial quan hi ha prou activitats però falta alguna cosa', () => {
    const missing = [{ title: 'Pronoms combinats', why: 'No n\'hi ha', suggested_prompt: 'Exercicis de pronoms combinats B1', kind: 'exercises' as const }];
    const result = pathFromLlm(raw({ status: 'partial', missing }), candidates, 'p');
    expect(result).toMatchObject({ status: 'partial', missing });
  });

  it('informa i proposa crear-ne de noves quan no hi ha prou activitats', () => {
    const result = pathFromLlm(raw({ status: 'insufficient', steps: [{ n: 1, reason: 'x' }], missing: [{ title: 'T', why: 'W', suggested_prompt: 'Crea exercicis de T', kind: 'exercises' }] }), candidates, 'p');
    expect(result.status).toBe('insufficient');
    if (result.status !== 'insufficient') return;
    expect(result.steps).toHaveLength(1);
    expect(result.missing).toEqual([{ title: 'T', why: 'W', suggested_prompt: 'Crea exercicis de T', kind: 'exercises' }]);
    expect(result.message).not.toBe('');
  });

  it('si queden menys de les mínimes tot i que el model diga ok, és insuficient i proposa la petició', () => {
    const result = pathFromLlm(raw({ steps: [{ n: 99, reason: 'x' }] }), candidates, 'verbs irregulars');
    expect(MIN_PATH_STEPS).toBeGreaterThan(0);
    expect(result.status).toBe('insufficient');
    if (result.status !== 'insufficient') return;
    expect(result.missing[0].suggested_prompt).toBe('verbs irregulars');
  });

  it('un ok amb propostes de noves passa a parcial', () => {
    const result = pathFromLlm(raw({ missing: [{ title: 'T', why: 'W', suggested_prompt: 'P', kind: 'reading' }] }), candidates, 'p');
    expect(result.status).toBe('partial');
  });
});

/* ── Flux complet amb un fetch simulat (sense OpenAI) ─────────────────── */
import { afterEach, beforeEach, vi } from 'vitest';
import { generateActivity, generatePath } from './teacherAgent.js';
import { clearOpenAiCache } from './openaiGuard.js';

const completion = (payload: unknown) =>
  new Response(JSON.stringify({ choices: [{ message: { content: JSON.stringify(payload) }, finish_reason: 'stop' }] }), { status: 200, headers: { 'content-type': 'application/json' } });

describe('generateActivity / generatePath (fetch simulat)', () => {
  const fetchMock = vi.fn();
  beforeEach(() => {
    process.env.OPENAI_API_KEY = 'test';
    process.env.OPENAI_MODEL = 'test-model';
    clearOpenAiCache();
    fetchMock.mockReset();
    vi.stubGlobal('fetch', fetchMock);
  });
  afterEach(() => vi.unstubAllGlobals());

  it('genera una activitat dins dels tipus establerts', async () => {
    fetchMock.mockResolvedValueOnce(completion({ ...base, questions: [choice('Q1'), fill('Q2')] }));
    const result = await generateActivity('exercicis de pronoms febles B1', 'B1');
    expect(result).toMatchObject({ ok: true, activity: { level: 'B1', content: { kind: 'exercises' } } });
    expect(fetchMock).toHaveBeenCalledTimes(1);
  });

  it('envia un missatge si la activitat no es pot generar', async () => {
    fetchMock.mockResolvedValueOnce(completion({ ...base, feasible: false, message: 'No puc crear activitats d\'àudio.' }));
    const result = await generateActivity('una activitat amb àudio', 'B1');
    expect(result).toEqual({ ok: false, message: "No puc crear activitats d'àudio." });
  });

  it('reintenta una vegada amb les correccions si el primer intent no és vàlid', async () => {
    fetchMock
      .mockResolvedValueOnce(completion({ ...base, questions: [] }))
      .mockResolvedValueOnce(completion({ ...base, questions: [choice('Q1')] }));
    const result = await generateActivity('exercicis de pronoms', 'B1');
    expect(result.ok).toBe(true);
    expect(fetchMock).toHaveBeenCalledTimes(2);
    const secondBody = JSON.parse(fetchMock.mock.calls[1][1].body as string);
    expect(JSON.parse(secondBody.messages[1].content).correccions.length).toBeGreaterThan(0);
  });

  it('informa si després del reintent segueix sent invàlida', async () => {
    fetchMock.mockImplementation(async () => completion({ ...base, questions: [] }));
    const result = await generateActivity('exercicis', 'B1');
    expect(result).toMatchObject({ ok: false });
    expect(fetchMock).toHaveBeenCalledTimes(2);
  });

  it('informa (sense error) si OpenAI falla', async () => {
    fetchMock.mockResolvedValue(new Response('{}', { status: 500, headers: { 'content-type': 'application/json' } }));
    const result = await generateActivity('exercicis de pronoms', 'B1');
    expect(result).toMatchObject({ ok: false, message: expect.any(String) });
  });

  it("envia el document adjunt al model, com a dades, en generar una activitat", async () => {
    fetchMock.mockResolvedValueOnce(completion({ ...base, questions: [choice('Q1')] }));
    await generateActivity('exercicis del temari', 'B1', undefined, 'Tema 3: els pronoms febles.');
    const body = JSON.parse(fetchMock.mock.calls[0][1].body as string);
    expect(JSON.parse(body.messages[1].content).document).toBe('Tema 3: els pronoms febles.');
    expect(body.messages[0].content).toContain('DOCUMENT ADJUNT');
  });

  it("no envia cap camp «document» si no n'hi ha", async () => {
    fetchMock.mockResolvedValueOnce(completion({ ...base, questions: [choice('Q1')] }));
    await generateActivity('exercicis', 'B1');
    const body = JSON.parse(fetchMock.mock.calls[0][1].body as string);
    expect(JSON.parse(body.messages[1].content)).not.toHaveProperty('document');
  });

  it("envia el document adjunt al model en generar una ruta", async () => {
    fetchMock.mockResolvedValueOnce(completion(raw()));
    await generatePath('ruta del temari', candidates, ['B1'], undefined, 'Tema 1: accents.');
    const body = JSON.parse(fetchMock.mock.calls[0][1].body as string);
    expect(JSON.parse(body.messages[1].content).document).toBe('Tema 1: accents.');
  });

  it('genera una ruta amb activitats existents i només envia al model la llista numerada', async () => {
    fetchMock.mockResolvedValueOnce(completion(raw()));
    const result = await generatePath('pronoms febles', candidates, ['B1', 'B2']);
    expect(result).toMatchObject({ status: 'ok', level: 'B1' });
    const body = JSON.parse(fetchMock.mock.calls[0][1].body as string);
    const user = JSON.parse(body.messages[1].content);
    expect(user.activitats[0]).toBe('1|B1|morfosintaxi|Activitat 1');
    expect(JSON.stringify(user)).not.toContain('id-1');
  });

  it('sense activitats disponibles informa i proposa crear-ne sense cridar al model', async () => {
    const result = await generatePath('pronoms febles', [], ['B1']);
    expect(result).toMatchObject({ status: 'insufficient', missing: [{ suggested_prompt: 'pronoms febles' }] });
    expect(fetchMock).not.toHaveBeenCalled();
  });

  it("informa d'un error si el model falla", async () => {
    fetchMock.mockResolvedValue(new Response('{}', { status: 500, headers: { 'content-type': 'application/json' } }));
    expect(await generatePath('pronoms', candidates, ['B1'])).toMatchObject({ status: 'error' });
  });
});

describe('rutes de nivell C1 i C2', () => {
  it('el C1 i el C2 són nivells on la docent pot crear rutes', () => {
    expect(PATH_LEVELS).toContain('C1');
    expect(PATH_LEVELS).toContain('C2');
  });

  it("carrega com a candidates les activitats de C1 d'una classe de C1", async () => {
    const row = (id: string, difficulty: string) => ({
      id, name: `Activitat ${id}`, category: 'morfosintaxi', difficulty, url: null, teacher_id: null, metadata: null, practice_exercises: [{ count: 5 }],
    });
    const levelsAsked: string[][] = [];
    const client = { from: () => { const q: any = {
      select: () => q, or: () => q, limit: () => Promise.resolve({ data: [row('a', 'C1'), row('b', 'C1')], error: null }),
      in: (_: string, levels: string[]) => { levelsAsked.push(levels); return q; },
    }; return q; } };
    const result = await loadPathCandidates(client, 'teacher-1', ['C1'], 'subordinades');
    expect(levelsAsked).toEqual([['C1']]);
    expect(result.map(c => c.id)).toEqual(['a', 'b']);
    expect(result.every(c => c.level === 'C1')).toBe(true);
  });

  it("carrega com a candidates les activitats de C2 d'una classe de C2", async () => {
    const levelsAsked: string[][] = [];
    const client = { from: () => { const q: any = {
      select: () => q, or: () => q,
      limit: () => Promise.resolve({ data: [{ id: 'c', name: 'Activitat c', category: 'lexic_semantica', difficulty: 'C2', url: null, teacher_id: null, metadata: null, practice_exercises: [{ count: 5 }] }], error: null }),
      in: (_: string, levels: string[]) => { levelsAsked.push(levels); return q; },
    }; return q; } };
    const result = await loadPathCandidates(client, 'teacher-1', ['C2'], 'registres');
    expect(levelsAsked).toEqual([['C2']]);
    expect(result.map(c => c.id)).toEqual(['c']);
  });

  it('una classe del Nivell 0 sola no té rutes', async () => {
    const client = { from: () => { throw new Error('no hauria de consultar la BDD'); } };
    expect(await loadPathCandidates(client, 'teacher-1', ['nivell0'], 'x')).toEqual([]);
  });
});

/* ── Les activitats proposades per a crear són d'un tipus que es pot crear ── */
const kindsFetch = vi.fn();
const missingOf = (result: Awaited<ReturnType<typeof generatePath>>) => ('missing' in result ? result.missing : undefined);
describe('propostes d\'activitats noves', () => {
  const proposal = (over: Record<string, string> = {}) => ({ title: 'Pronoms combinats', why: 'Falta', suggested_prompt: 'Exercicis de pronoms combinats', kind: 'exercises', ...over });

  it.each([
    'Activitat d\'àudio per a escoltar una conversa',
    'Un vídeo sobre els pronoms febles',
    'Joc de preguntes tipus Kahoot',
    'Comprensió oral d\'una notícia',
    'Un examen complet de B1',
    'Mots creuats de lèxic',
    'Fitxa per a imprimir amb imatges',
    'Practica la pronunciació de la v',
  ])('no es pot crear: «%s»', text => expect(isCreatableRequest(text)).toBe(false));

  it.each([
    'Exercicis de pronoms febles amb preguntes d\'opció múltiple',
    'Lectura d\'un article sobre el canvi climàtic amb preguntes',
    'Redacció d\'una carta formal de 120 paraules',
    'Escenari de conversa en una farmàcia',
    'Joc de rol: reservar una taula al restaurant',
  ])('sí que es pot crear: «%s»', text => expect(isCreatableRequest(text)).toBe(true));

  it('descarta les propostes que demanen coses que no es poden crear i manté les altres', () => {
    const result = pathFromLlm(raw({
      status: 'partial',
      missing: [
        proposal({ title: 'Àudio de pronoms', suggested_prompt: 'Un àudio per a escoltar exemples' }),
        proposal({ title: 'Lectura sobre pronoms', suggested_prompt: 'Lectura sobre els pronoms amb preguntes', kind: 'reading' }),
        proposal({ title: 'Joc de pronoms', suggested_prompt: 'Un joc de cartes' }),
      ],
    }), candidates, 'p');
    expect(result.status).toBe('partial');
    expect(missingOf(result)).toEqual([expect.objectContaining({ title: 'Lectura sobre pronoms', kind: 'reading' })]);
  });

  it('descarta les propostes amb un tipus que no existix', () => {
    const result = pathFromLlm(raw({ missing: [proposal({ kind: 'audio' }), proposal({ kind: '' })] }), candidates, 'p');
    expect(missingOf(result)).toEqual([]);
    expect(result.status).toBe('ok');
  });

  it('en una ruta insuficient, si res del que falta es pot crear, no proposa res i ho explica', () => {
    const result = pathFromLlm(raw({
      status: 'insufficient', steps: [{ n: 1, reason: 'x' }],
      missing: [proposal({ title: 'Àudio', suggested_prompt: 'Un àudio' })],
    }), candidates, 'comprensió oral de notícies');
    expect(result.status).toBe('insufficient');
    if (result.status !== 'insufficient') return;
    expect(result.missing).toEqual([]);
    expect(result.message).toContain('no es pot crear');
    expect(result.message).toContain('comprensió lectora');
  });

  it('la proposta de reserva (la petició mateixa) només s\'ofereix si es pot crear, amb el seu tipus', () => {
    const creatable = pathFromLlm(raw({ steps: [] }), candidates, 'una lectura sobre el clima');
    expect(missingOf(creatable)).toEqual([expect.objectContaining({ kind: 'reading', suggested_prompt: 'una lectura sobre el clima' })]);
    const notCreatable = pathFromLlm(raw({ steps: [] }), candidates, 'un joc per a aprendre pronoms');
    expect(missingOf(notCreatable)).toEqual([]);
  });

  it('sense activitats existents tampoc no proposa res que no es puga crear', async () => {
    const fetchSpy = vi.fn();
    vi.stubGlobal('fetch', fetchSpy);
    try {
      const result = await generatePath('podcast sobre pronoms', [], ['B1']);
      expect(result).toMatchObject({ status: 'insufficient', missing: [] });
      expect(fetchSpy).not.toHaveBeenCalled();
    } finally {
      vi.unstubAllGlobals();
    }
  });
});

describe('generateActivity amb un tipus demanat (propostes d\'una ruta)', () => {
  beforeEach(() => {
    process.env.OPENAI_API_KEY = 'test';
    process.env.OPENAI_MODEL = 'test-model';
    clearOpenAiCache();
    kindsFetch.mockReset();
    vi.stubGlobal('fetch', kindsFetch);
  });
  afterEach(() => vi.unstubAllGlobals());

  it('envia el tipus al model', async () => {
    kindsFetch.mockResolvedValueOnce(completion({ ...base, questions: [choice('Q1')] }));
    await generateActivity('exercicis de pronoms', 'B1', undefined, undefined, 'exercises');
    const body = JSON.parse(kindsFetch.mock.calls[0][1].body as string);
    expect(JSON.parse(body.messages[1].content).tipus_demanat).toBe('exercises');
  });

  it('si el model fa un altre tipus, ho torna a demanar i accepta el correcte', async () => {
    const reading = { ...base, kind: 'reading', text: 'Un text.', questions: [choice('Q1')] };
    kindsFetch
      .mockResolvedValueOnce(completion(reading))
      .mockResolvedValueOnce(completion({ ...base, questions: [choice('Q1')] }));
    const result = await generateActivity('exercicis de pronoms', 'B1', undefined, undefined, 'exercises');
    expect(result).toMatchObject({ ok: true, activity: { content: { kind: 'exercises' } } });
    expect(kindsFetch).toHaveBeenCalledTimes(2);
  });

  it('si no aconseguix el tipus, ho diu i no torna una activitat d\'un altre tipus', async () => {
    kindsFetch.mockImplementation(async () => completion({ ...base, kind: 'writing', writing_prompt: 'Escriu.', min_words: 60, max_words: 90 }));
    const result = await generateActivity('exercicis de pronoms', 'B1', undefined, undefined, 'exercises');
    expect(result.ok).toBe(false);
  });

  it('sense tipus demanat no envia el camp', async () => {
    kindsFetch.mockResolvedValueOnce(completion({ ...base, questions: [choice('Q1')] }));
    await generateActivity('exercicis', 'B1');
    const body = JSON.parse(kindsFetch.mock.calls[0][1].body as string);
    expect(JSON.parse(body.messages[1].content)).not.toHaveProperty('tipus_demanat');
  });
});
