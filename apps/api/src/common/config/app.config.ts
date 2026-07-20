import { registerAs } from '@nestjs/config';

/**
 * Strongly-typed application configuration namespace.
 *
 * Access it via `configService.get('app.port')` or by injecting the typed
 * config. Additional namespaces (database, storage, auth, ...) should live in
 * sibling `*.config.ts` files and be registered in {@link ConfigModule}.
 */
export const appConfig = registerAs('app', () => ({
  env: process.env.NODE_ENV ?? 'development',
  port: parseInt(process.env.PORT ?? '3000', 10),
}));
