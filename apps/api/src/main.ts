import { ConfigService } from '@nestjs/config';

import { createApp } from './app.factory';

/**
 * Long-lived server entry point — local development and any container host
 * (Render, Cloud Run, a VPS).
 *
 * The app itself is assembled in {@link createApp}; this file owns only what is
 * specific to running as a persistent process. The Vercel serverless entry
 * point (`api/index.ts`) shares the same factory.
 */
async function bootstrap() {
  const app = await createApp();

  // Flush in-flight work on SIGTERM/SIGINT (clean container shutdowns).
  // Meaningless under serverless, which is why it lives here and not in the
  // factory.
  app.enableShutdownHooks();

  const port = app.get(ConfigService).get<number>('app.port', 3000);
  await app.listen(port);
}

void bootstrap();
