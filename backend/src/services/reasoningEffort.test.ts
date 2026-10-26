import { describe, expect, it } from 'vitest';
import { reasoningEffortFor } from './reasoningEffort.js';

describe('reasoningEffortFor', () => {
  it('no envia reasoning_effort als models que no raonen', () => {
    for (const m of ['gpt-4o-mini', 'gpt-4o', 'gpt-4.1', 'gpt-3.5-turbo', 'qwen2.5:32b']) {
      expect(reasoningEffortFor(m)).toEqual({});
    }
  });
  it('l\'envia als models de raonament', () => {
    for (const m of ['gpt-6-luna', 'gpt-5-mini', 'o3', 'o4-mini']) {
      expect(reasoningEffortFor(m)).toEqual({ reasoning_effort: 'none' });
      expect(reasoningEffortFor(m, 'low')).toEqual({ reasoning_effort: 'low' });
    }
  });
});
