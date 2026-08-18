import type { NextFunction, Request, Response } from 'express';
import { v7 as uuidv7 } from 'uuid';

export const REQUEST_ID_HEADER = 'x-request-id';

declare module 'express' {
  interface Request {
    requestId?: string;
  }
}

/**
 * Attaches a correlation id to every request and echoes it back.
 *
 * An inbound `X-Request-Id` is honoured so a client can tie its own logs to
 * the server's — which is what makes a bug report like "sync failed, request
 * 018f…" actionable instead of a hunt through timestamps.
 *
 * Written as a plain Express middleware and registered with `app.use()` rather
 * than through `MiddlewareConsumer`: Nest 11 runs Express 5, whose path
 * matching rejects the bare `'*'` route pattern, and a global concern like this
 * has no reason to go through route matching at all.
 */
export function requestIdMiddleware(
  req: Request,
  res: Response,
  next: NextFunction,
): void {
  const inbound = req.headers[REQUEST_ID_HEADER];
  const provided = Array.isArray(inbound) ? inbound[0] : inbound;

  // Cap the length so a hostile client cannot inject an unbounded string into
  // every downstream log line.
  const requestId = provided && provided.length <= 128 ? provided : uuidv7();

  req.requestId = requestId;
  res.setHeader(REQUEST_ID_HEADER, requestId);

  next();
}
