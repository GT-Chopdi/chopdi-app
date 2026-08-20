import type { IncomingMessage, ServerResponse } from 'node:http';

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
    appPromise = (async () => {
      // Imported lazily, inside the handler's try/catch, rather than at module
      // scope. A top-level import that fails to resolve kills the whole module
      // before any of our code runs, and Vercel can then only report
      // FUNCTION_INVOCATION_FAILED — no module name, no stack. Deferring it
      // turns that same failure into a catchable error we can actually report.
      //
      // `includeFiles: "dist/**"` in vercel.json is what puts the target in the
      // bundle; this import does not rely on static tracing to find it.
      // The `.js` extension is required: under `moduleResolution: nodenext` a
      // dynamic import() follows ESM rules even inside a CJS module, and ESM
      // does not do extensionless resolution. The static import this replaced
      // needed no extension because it used CJS resolution.
      const factory = (await import('../dist/app.factory.js')) as {
        createApp: () => Promise<{
          init: () => Promise<unknown>;
          getHttpAdapter: () => { getInstance: () => NodeHandler };
        }>;
      };

      const app = await factory.createApp();

      // init() runs the full lifecycle (module init, guards, filters) without
      // binding a port — there is no port to bind under serverless.
      await app.init();

      return app.getHttpAdapter().getInstance();
    })().catch((error) => {
      // Clear the cache so a transient bootstrap failure (a cold Neon instance
      // refusing the first connection) does not poison this container for its
      // entire lifetime.
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
  try {
    const express = await getHandler();
    express(req, res);
  } catch (error) {
    // A bootstrap failure never reaches Nest's exception filter — the app does
    // not exist yet. Without this, Vercel reports only
    // FUNCTION_INVOCATION_FAILED, which is indistinguishable between a missing
    // env var, an unbundled file, and a dead database.
    //
    // Details are withheld once APP_ENV=production, where an opaque 500 is the
    // correct answer and the stack belongs only in the logs.
    const isProduction = process.env.APP_ENV === 'production';
    const err = error as { message?: string; stack?: string };

    // Always log in full — this is what shows up in `vercel logs`.
    console.error('Bootstrap failed:', error);

    res.statusCode = 500;
    res.setHeader('content-type', 'application/json');
    res.end(
      JSON.stringify({
        error: {
          code: 'BOOTSTRAP_FAILED',
          message: isProduction
            ? 'Service unavailable.'
            : (err?.message ?? String(error)),
          ...(isProduction
            ? {}
            : {
                appEnv: process.env.APP_ENV ?? '(unset)',
                nodeEnv: process.env.NODE_ENV ?? '(unset)',
                stack: String(err?.stack ?? '')
                  .split('\n')
                  .slice(0, 15),
              }),
        },
      }),
    );
  }
}
