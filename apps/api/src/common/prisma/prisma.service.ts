import {
  Injectable,
  Logger,
  OnModuleDestroy,
  OnModuleInit,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { neonConfig } from '@neondatabase/serverless';
import { PrismaNeon } from '@prisma/adapter-neon';
import { PrismaPg } from '@prisma/adapter-pg';
import ws from 'ws';

import { PrismaClient } from '../../generated/prisma/client';

// Neon's serverless driver reaches Postgres over a WebSocket. Node 20 has no
// global WebSocket, so one must be supplied or every `neon` connection fails
// with an unhelpful error. Harmless when the `pg` driver is selected.
neonConfig.webSocketConstructor = ws;

/**
 * Application-wide Prisma client.
 *
 * Prisma 7 runs without the Rust engine, so the client is built with a driver
 * adapter. Which adapter is a **deployment** decision, not a code one — see
 * `DATABASE_DRIVER` in env.validation.ts:
 *
 *   - `pg`   — one TCP pool reused for the process lifetime. Right for a
 *              long-lived server.
 *   - `neon` — WebSocket-based serverless driver. Right for Vercel, where each
 *              function instance is ephemeral and TCP pools accumulate faster
 *              than they are released.
 *
 * Using `pg` on serverless does not fail immediately; it fails under
 * concurrency, once instances multiply and Neon's connection budget runs out.
 * That is the worst failure mode to debug, which is why this is configurable
 * rather than assumed.
 *
 * `PrismaNeon` (WebSocket) is used rather than `PrismaNeonHttp` because the
 * sync engine relies on interactive transactions, which the HTTP driver cannot
 * carry.
 */
@Injectable()
export class PrismaService
  extends PrismaClient
  implements OnModuleInit, OnModuleDestroy
{
  private readonly logger = new Logger(PrismaService.name);

  constructor(config: ConfigService) {
    super({ adapter: PrismaService.buildAdapter(config) });
  }

  /**
   * Static so it can run before `super()` — a derived constructor cannot touch
   * `this` beforehand.
   */
  private static buildAdapter(config: ConfigService) {
    const connectionString = config.getOrThrow<string>('database.url');
    const driver = config.get<string>('database.driver', 'pg');

    return driver === 'neon'
      ? new PrismaNeon({ connectionString })
      : new PrismaPg(connectionString);
  }

  async onModuleInit(): Promise<void> {
    await this.$connect();
    this.logger.log(
      `Database connection established (driver: ${process.env.DATABASE_DRIVER ?? 'pg'})`,
    );
  }

  async onModuleDestroy(): Promise<void> {
    await this.$disconnect();
  }
}
