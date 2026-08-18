import { INestApplication, ValidationPipe } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { NestFactory } from '@nestjs/core';
import express from 'express';
import helmet from 'helmet';

import { AppModule } from './app.module';
import { requestIdMiddleware } from './common/middleware/request-id.middleware';

/**
 * Builds the application, fully configured but not listening.
 *
 * This is the single source of truth for how the app is assembled. Two entry
 * points consume it:
 *
 *   - `src/main.ts`  — adds shutdown hooks and listens on a port (local, Render)
 *   - `api/index.ts` — initialises and hands the Express instance to Vercel
 *
 * Neither entry point configures anything itself, so the two deployment
 * targets cannot drift apart. That matters more than it looks: the middleware
 * below includes the security controls (`forbidNonWhitelisted`, helmet, the
 * body limit), and a serverless entry point that quietly forgot one would be a
 * vulnerability nobody notices until it is exploited.
 *
 * Process lifecycle — shutdown hooks, listening — deliberately stays with the
 * entry points, since that is the one thing that genuinely differs by platform.
 */
export async function createApp(): Promise<INestApplication> {
  const app = await NestFactory.create(AppModule);
  const config = app.get(ConfigService);

  // Namespace every route under /api so the mobile client has a stable base path.
  app.setGlobalPrefix('api');

  // Correlation id first, so everything downstream — including the exception
  // filter — can reference it.
  app.use(requestIdMiddleware);

  app.use(helmet());

  // Body limit is set explicitly in both directions. The framework default
  // (100 KB) is too small for a full 200-operation sync batch, and leaving it
  // unbounded would let one request exhaust memory.
  const bodyLimit = config.get<string>('sync.bodyLimit', '1mb');
  app.use(express.json({ limit: bodyLimit }));
  app.use(express.urlencoded({ extended: true, limit: bodyLimit }));

  // Reject unknown/invalid payloads globally; DTOs opt into their own rules.
  // `forbidNonWhitelisted` is load-bearing security, not tidiness: it is what
  // rejects a request trying to smuggle `userId` or `version` into a payload.
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );

  return app;
}
