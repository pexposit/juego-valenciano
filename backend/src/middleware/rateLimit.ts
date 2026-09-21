import type { NextFunction, Request, Response } from 'express';

/**
 * Limitador de peticions en memòria, sense dependències externes.
 *
 * S'ha de muntar DESPRÉS de `requireAuth`, així ja coneix la identitat i pot
 * aplicar dos límits diferents:
 * - Amb sessió iniciada: es compta per `userId` (límit ampli, conversar és normal).
 * - Sense sessió (mode demostració): es compta per IP (límit estret), perquè
 *   una persona anònima no puga cremar crèdit d'OpenAI ni el TTS de la UJI.
 *
 * L'estat viu a la memòria del procés: suficient per a una sola instància
 * (Render/Railway/Fly per defecte). Amb diverses instàncies caldria un
 * magatzem compartit (Redis) o comptadors a la base de dades.
 */
export interface RateLimitOptions {
  /** Peticions permeses per finestra amb sessió iniciada. */
  max: number;
  /** Peticions permeses per finestra sense sessió (per defecte, `max`). */
  maxAnonymous?: number;
  /** Durada de la finestra en mil·lisegons. */
  windowMs: number;
  /** Rellotge injectable per als tests (per defecte `Date.now`). */
  now?: () => number;
}

interface Counter {
  count: number;
  resetAt: number;
}

/** Nombre d'entrades a partir del qual es purguen les finestres caducades. */
const PURGE_THRESHOLD = 5_000;

export function rateLimit(options: RateLimitOptions) {
  const { windowMs, max, maxAnonymous = max, now = Date.now } = options;
  const counters = new Map<string, Counter>();

  /** Allibera les finestres caducades perquè el mapa no cresca sense control. */
  function purge(currentTime: number) {
    if (counters.size < PURGE_THRESHOLD) return;
    for (const [key, counter] of counters) {
      if (counter.resetAt <= currentTime) counters.delete(key);
    }
  }

  return function rateLimitMiddleware(
    req: Request & { userId?: string },
    res: Response,
    next: NextFunction,
  ): void {
    const anonymous = !req.userId || req.userId === 'demo-user';
    const limit = anonymous ? maxAnonymous : max;
    const key = anonymous ? `ip:${req.ip ?? 'desconeguda'}` : `user:${req.userId}`;
    const currentTime = now();

    purge(currentTime);

    const counter = counters.get(key);
    if (!counter || counter.resetAt <= currentTime) {
      counters.set(key, { count: 1, resetAt: currentTime + windowMs });
      next();
      return;
    }

    counter.count += 1;
    if (counter.count > limit) {
      const retryAfterSeconds = Math.ceil((counter.resetAt - currentTime) / 1000);
      res.setHeader('Retry-After', String(retryAfterSeconds));
      res.status(429).json({
        error: 'Massa peticions seguides. Espera un moment i torna-ho a provar.',
      });
      return;
    }

    next();
  };
}
