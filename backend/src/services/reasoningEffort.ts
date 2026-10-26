/**
 * `reasoning_effort` només l'accepten els models de raonament (o1/o3/o4…,
 * gpt-5 i posteriors, com gpt-6-luna, on és obligatori per a usar tools en
 * /v1/chat/completions). Els gpt-4o/gpt-4.1 el rebutgen amb un 400, així que
 * només s'envia quan el model el suporta.
 */
export type ReasoningEffort = 'none' | 'low';

export function reasoningEffortFor(model: string, effort: ReasoningEffort = 'none'): { reasoning_effort?: ReasoningEffort } {
  return /^(o\d|gpt-([5-9]|\d{2}))/i.test(model.trim()) ? { reasoning_effort: effort } : {};
}
