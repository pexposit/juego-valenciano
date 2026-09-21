/**
 * Proves unitàries del limitador de peticions (backend/src/middleware/rateLimit.ts).
 *
 * Cobrixen el que protegix el servici en producció:
 * - El límit es complix exactament i la petició de més respon 429 amb `Retry-After`.
 * - Els usuaris anònims (mode demostració) tenen un límit més estret que els
 *   que han iniciat sessió.
 * - Les comptabilitats estan aïllades per IP i per usuari.
 * - La finestra es reinicia quan passa el temps.
 * - Quan bloqueja, no crida `next()` (la ruta no s'executa).
 *
 * El rellotge s'injecta (`now`) per no dependre del temps real.
 */
import { describe, expect, it, vi } from 'vitest';
import type { NextFunction, Request, Response } from 'express';
import { rateLimit } from './rateLimit.js';

/** Petició mínima amb els únics camps que consulta el limitador. */
function createRequest(options: { ip?: string; userId?: string } = {}) {
  return { ip: options.ip ?? '10.0.0.1', userId: options.userId } as unknown as Request & {
    userId?: string;
  };
}

/** Resposta mínima que enregistra estat, capçaleres i cos. */
function createResponse() {
  const response = {
    statusCode: 200,
    headers: {} as Record<string, string>,
    body: undefined as unknown,
    setHeader(name: string, value: string) {
      response.headers[name] = value;
      return response;
    },
    status(code: number) {
      response.statusCode = code;
      return response;
    },
    json(payload: unknown) {
      response.body = payload;
      return response;
    },
  };
  return response;
}

/** Llança una petició contra el middleware i retorna el resultat observat. */
function call(
  middleware: ReturnType<typeof rateLimit>,
  request: Request & { userId?: string },
  next: NextFunction,
) {
  const response = createResponse();
  middleware(request, response as unknown as Response, next);
  return response;
}

describe('rateLimit', () => {
  it('permet exactament `max` peticions i bloqueja la següent amb 429', () => {
    const middleware = rateLimit({ windowMs: 60_000, max: 3, now: () => 0 });
    const request = createRequest({ userId: 'u1' });
    const next = vi.fn();

    for (let i = 0; i < 3; i += 1) {
      expect(call(middleware, request, next).statusCode).toBe(200);
    }
    expect(next).toHaveBeenCalledTimes(3);

    const blocked = call(middleware, request, next);
    expect(blocked.statusCode).toBe(429);
    expect(blocked.headers['Retry-After']).toBe('60');
    expect(String((blocked.body as { error: string }).error)).toMatch(/Massa peticions/);
    // La ruta protegida no s'arriba a executar.
    expect(next).toHaveBeenCalledTimes(3);
  });

  it('aplica un límit més estret a les peticions anònimes', () => {
    const middleware = rateLimit({ windowMs: 60_000, max: 30, maxAnonymous: 2, now: () => 0 });
    const anonymous = createRequest();
    const authenticated = createRequest({ userId: 'u1' });
    const next = vi.fn();

    expect(call(middleware, anonymous, next).statusCode).toBe(200);
    expect(call(middleware, anonymous, next).statusCode).toBe(200);
    expect(call(middleware, anonymous, next).statusCode).toBe(429);
    // El mateix límit no afecta qui té sessió.
    expect(call(middleware, authenticated, next).statusCode).toBe(200);
  });

  it('compta el mode demostració com a anònim encara que porti userId "demo-user"', () => {
    const middleware = rateLimit({ windowMs: 60_000, max: 10, maxAnonymous: 1, now: () => 0 });
    const next = vi.fn();

    expect(call(middleware, createRequest({ userId: 'demo-user' }), next).statusCode).toBe(200);
    expect(call(middleware, createRequest({ userId: 'demo-user' }), next).statusCode).toBe(429);
  });

  it('manté comptes separats per IP', () => {
    const middleware = rateLimit({ windowMs: 60_000, maxAnonymous: 1, max: 1, now: () => 0 });
    const next = vi.fn();

    expect(call(middleware, createRequest({ ip: '10.0.0.1' }), next).statusCode).toBe(200);
    expect(call(middleware, createRequest({ ip: '10.0.0.2' }), next).statusCode).toBe(200);
    expect(call(middleware, createRequest({ ip: '10.0.0.1' }), next).statusCode).toBe(429);
  });

  it('manté comptes separats per usuari amb sessió', () => {
    const middleware = rateLimit({ windowMs: 60_000, max: 1, now: () => 0 });
    const next = vi.fn();

    expect(call(middleware, createRequest({ ip: '10.0.0.1', userId: 'u1' }), next).statusCode).toBe(200);
    expect(call(middleware, createRequest({ ip: '10.0.0.1', userId: 'u2' }), next).statusCode).toBe(200);
    expect(call(middleware, createRequest({ ip: '10.0.0.1', userId: 'u1' }), next).statusCode).toBe(429);
  });

  it('reinicia el compte quan passa la finestra', () => {
    let currentTime = 0;
    const middleware = rateLimit({ windowMs: 1_000, max: 2, now: () => currentTime });
    const request = createRequest({ userId: 'u1' });
    const next = vi.fn();

    expect(call(middleware, request, next).statusCode).toBe(200);
    expect(call(middleware, request, next).statusCode).toBe(200);
    expect(call(middleware, request, next).statusCode).toBe(429);

    currentTime = 1_001;
    expect(call(middleware, request, next).statusCode).toBe(200);
  });

  it('no bloqueja quan no hi ha IP coneguda (servidor a servidor)', () => {
    const middleware = rateLimit({ windowMs: 60_000, maxAnonymous: 1, max: 1, now: () => 0 });
    const request = { userId: undefined } as unknown as Request & { userId?: string };
    const next = vi.fn();

    expect(call(middleware, request, next).statusCode).toBe(200);
    expect(call(middleware, request, next).statusCode).toBe(429);
  });
});
