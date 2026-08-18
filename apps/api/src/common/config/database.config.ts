import { registerAs } from '@nestjs/config';

/**
 * Database configuration namespace.
 *
 * Neon exposes two endpoints and they are not interchangeable:
 *
 * - `url` is the **pooled** endpoint (`...-pooler...`), used by the running
 *   application. Neon caps direct connections per compute, and a Nest instance
 *   holding a `pg` pool will exhaust them — more so once it scales horizontally.
 * - `directUrl` is the **direct** endpoint, used only by `prisma migrate`. DDL
 *   and migration advisory locks need session-scoped state, which the
 *   transaction-mode pooler cannot carry.
 *
 * Consumed by `PrismaService`. Access via `configService.get('database.url')`.
 */
export const databaseConfig = registerAs('database', () => ({
  url: process.env.DATABASE_URL,
  directUrl: process.env.DIRECT_URL,

  /** `pg` for long-lived processes, `neon` for serverless. See env.validation.ts. */
  driver: process.env.DATABASE_DRIVER ?? 'pg',
}));
