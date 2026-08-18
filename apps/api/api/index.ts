import type { IncomingMessage, ServerResponse } from 'node:http';

import { createApp } from '../dist/app.factory';

/**
 * Vercel serverless entry point.
 *
 * Imports from `../dist` rather than `../src` on purpose: `npm run build`
 * already compiles the Nest app with the decorator metadata it needs, and
 * asking Vercel's bundler to recompile the whole DI graph with its own
 * TypeScript settings is a reliable way to get subtle, hard-to-diagnose
 * failures. This file stays free of decorators so it compiles trivially.
 *
 * The app is assembled by the shared factory in `src/app.factory.ts`, the same
 * one `src/main.ts` uses. Neither entry point configures middleware itself, so
 * the serverless deployment cannot silently lose a security control.
 */

type NodeHandler = (req: IncomingMessage, res: ServerResponse) => void;

/**
 * The *promise* is cached, not the resolved handler.
 *
 * A cold instance can receive several concurrent invocations before the first
 * bootstrap finishes. Caching the resolved value would let each of them start
 * its own Nest app — several DI containers and several database pools on one
 * instance. Caching the promise means they all await the same bootstrap.
 *
 * This survives only as long as the instance stays warm; Vercel may discard it
 * at any time, which is normal and simply means paying bootstrap again.
 */
let appPromise: Promise<NodeHandler> | undefined;

function getHandler(): Promise<NodeHandler> {
  if (!appPromise) {
    appPromise = createApp()
      .then(async (app) => {
        // init() runs the full lifecycle (module init, guards, filters) without
        // binding a port — there is no port to bind under serverless.
        await app.init();
        return app.getHttpAdapter().getInstance() as NodeHandler;
      })
      .catch((error) => {
        // Clear the cache so a transient bootstrap failure (a cold Neon
        // instance refusing the first connection) does not poison this
        // container for its entire lifetime.
        appPromise = undefined;
        throw error;
      });
  }

  return appPromise;
}

export default async function handler(
  req: IncomingMessage,
  res: ServerResponse,
): Promise<void> {
  const express = await getHandler();
  express(req, res);
}
