import 'dotenv/config';
import { defineConfig } from 'prisma/config';

/**
 * Prisma CLI configuration (migrations, generate, studio).
 *
 * The Prisma CLI runs outside the Nest application, so it reads its connection
 * string from `.env` via `dotenv`. `process.env` is used directly (rather than
 * the strict `env()` helper) so `prisma generate` — which only needs the schema
 * — still works before a connection string is configured; `prisma migrate`
 * naturally requires a real URL. At runtime the app instead injects the URL
 * through `ConfigService` and passes it to the driver adapter (see
 * PrismaService).
 *
 * `DIRECT_URL` is preferred here: Neon's pooled endpoint is PgBouncer in
 * transaction mode, which cannot hold the session-scoped state that DDL and
 * migration advisory locks require. Falls back to `DATABASE_URL` for local
 * Postgres, where there is no pooler and the two are the same thing.
 */
export default defineConfig({
  schema: 'prisma/schema.prisma',
  datasource: {
    url: process.env.DIRECT_URL ?? process.env.DATABASE_URL,
  },
});
