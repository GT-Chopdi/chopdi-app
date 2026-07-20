import { registerAs } from '@nestjs/config';

/**
 * Database configuration namespace.
 *
 * Exposes the Neon (PostgreSQL) connection string. Consumed by `PrismaService`
 * to build the driver adapter. Access via `configService.get('database.url')`.
 */
export const databaseConfig = registerAs('database', () => ({
  url: process.env.DATABASE_URL,
}));
