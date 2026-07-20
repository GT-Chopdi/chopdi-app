import 'dotenv/config';
import { defineConfig } from 'prisma/config';

/**
 * Prisma CLI configuration (migrations, generate, studio).
 *
 * The Prisma CLI runs outside the Nest application, so it reads `DATABASE_URL`
 * from `.env` via `dotenv`. `process.env` is used directly (rather than the
 * strict `env()` helper) so `prisma generate` — which only needs the schema —
 * still works before a connection string is configured; `prisma migrate`
 * naturally requires a real `DATABASE_URL`. At runtime the app instead injects
 * the URL through `ConfigService` and passes it to the driver adapter (see
 * PrismaService).
 */
export default defineConfig({
  schema: 'prisma/schema.prisma',
  datasource: {
    url: process.env.DATABASE_URL,
  },
});
