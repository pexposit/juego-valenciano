import type { Response } from 'express';
import type { z } from 'zod';

// Resposta comuna per als errors de validació (Zod): 400 amb el detall de cada camp.
export function validationError(res: Response, error: z.ZodError) {
  return res.status(400).json({
    error: 'Petició invàlida',
    issues: error.issues.map((i) => ({ path: i.path.join('.'), message: i.message })),
  });
}
