import { describe, expect, it } from 'vitest';
import { createLoopGuard, createRepeatTracker, isLoopError, LoopDetectedError } from './loopGuard.js';

const reasonOf = (fn: () => void) => {
  try {
    fn();
  } catch (error) {
    return isLoopError(error) ? error.reason : 'other';
  }
  return null;
};

describe('createLoopGuard', () => {
  it('deixa passar una execució normal', () => {
    const guard = createLoopGuard({ label: 't' });
    expect(reasonOf(() => {
      guard.llmCall('hola');
      guard.toolCall('softvalencia', '{"frase":"a"}');
      guard.llmCall('resultat de la ferramenta');
      guard.toolCall('softvalencia', '{"frase":"b"}');
    })).toBeNull();
  });

  it('talla quan es passa de crides al LLM', () => {
    const guard = createLoopGuard({ label: 't', maxIterations: 3 });
    expect(reasonOf(() => { for (let i = 0; i < 4; i += 1) guard.llmCall(`m${i}`); })).toBe('max_iterations');
  });

  it('talla quan el mateix missatge es repetix massa voltes', () => {
    const guard = createLoopGuard({ label: 't', maxRepeats: 2 });
    guard.llmCall('igual');
    guard.llmCall('igual');
    expect(reasonOf(() => guard.llmCall('igual'))).toBe('repeated_message');
  });

  it('talla quan la mateixa eina es crida amb els mateixos arguments', () => {
    const guard = createLoopGuard({ label: 't', maxRepeats: 2 });
    guard.toolCall('softvalencia', '{"x":1}');
    guard.toolCall('softvalencia', '{"x":2}'); // arguments diferents: no compta com a repetició
    guard.toolCall('softvalencia', '{"x":1}');
    expect(reasonOf(() => guard.toolCall('softvalencia', '{"x":1}'))).toBe('repeated_tool_call');
  });

  it('talla quan es passa de crides a eines', () => {
    const guard = createLoopGuard({ label: 't', maxToolCalls: 2, maxRepeats: 99 });
    guard.toolCall('a', '1');
    guard.toolCall('a', '2');
    expect(reasonOf(() => guard.toolCall('a', '3'))).toBe('max_tool_calls');
  });

  it('una vegada tallat, tot el que vinga després també falla i avorta la petició en vol', () => {
    const guard = createLoopGuard({ label: 't', maxIterations: 1 });
    guard.llmCall('a');
    expect(reasonOf(() => guard.llmCall('b'))).toBe('max_iterations');
    expect(guard.signal.aborted).toBe(true);
    expect(reasonOf(() => guard.llmCall('c'))).toBe('max_iterations');
    expect(reasonOf(() => guard.assertActive())).toBe('max_iterations');
  });

  it('respecta la cancel·lació externa', () => {
    const controller = new AbortController();
    const guard = createLoopGuard({ label: 't', signal: controller.signal });
    guard.llmCall('a');
    controller.abort();
    expect(guard.signal.aborted).toBe(true);
    let error: unknown;
    try { guard.llmCall('b'); } catch (e) { error = e; }
    expect(error).toBeInstanceOf(LoopDetectedError);
    expect((error as LoopDetectedError).userCancelled).toBe(true);
  });

  it('talla per temps', async () => {
    const guard = createLoopGuard({ label: 't', maxMs: 20 });
    await new Promise(resolve => setTimeout(resolve, 40));
    expect(reasonOf(() => guard.llmCall('a'))).toBe('timeout');
  });

  it('stopped() reconeix els errors del guard i els d\'una petició avortada', () => {
    const controller = new AbortController();
    const guard = createLoopGuard({ label: 't', signal: controller.signal });
    expect(guard.stopped(new Error('xarxa'))).toBeNull();
    controller.abort();
    expect(guard.stopped(new Error('Request was aborted.'))?.reason).toBe('cancelled');
  });
});

describe('createRepeatTracker', () => {
  it('detecta el mateix missatge repetit dins de la finestra', () => {
    const tracker = createRepeatTracker({ windowMs: 1000, max: 2 });
    expect(tracker.hit('u1', 'hola', 0).exceeded).toBe(false);
    expect(tracker.hit('u1', 'hola', 10).exceeded).toBe(false);
    expect(tracker.hit('u1', 'hola', 20).exceeded).toBe(true);
  });

  it('no barreja usuaris ni missatges', () => {
    const tracker = createRepeatTracker({ windowMs: 1000, max: 1 });
    tracker.hit('u1', 'hola', 0);
    expect(tracker.hit('u2', 'hola', 1).exceeded).toBe(false);
    expect(tracker.hit('u1', 'adéu', 2).exceeded).toBe(false);
  });

  it('reinicia el compte passada la finestra', () => {
    const tracker = createRepeatTracker({ windowMs: 1000, max: 1 });
    tracker.hit('u1', 'hola', 0);
    expect(tracker.hit('u1', 'hola', 1).exceeded).toBe(true);
    expect(tracker.hit('u1', 'hola', 1500).exceeded).toBe(false);
  });
});
