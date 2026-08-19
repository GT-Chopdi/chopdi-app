import { registerAs } from '@nestjs/config';

/**
 * Strongly-typed application configuration namespace.
 *
 * Access it via `configService.get('app.port')` or by injecting the typed
 * config. Additional namespaces (database, storage, auth, ...) should live in
 * sibling `*.config.ts` files and be registered in {@link ConfigModule}.
 */
export const appConfig = registerAs('app', () => ({
  /** Node's build mode. Owned by the platform; do not branch on it. */
  nodeEnv: process.env.NODE_ENV ?? 'development',

  /**
   * Which environment this deployment is. Owned by us, so it is safe to make
   * security decisions on — see APP_ENV in env.validation.ts.
   */
  env: process.env.APP_ENV ?? process.env.NODE_ENV ?? 'development',

  port: parseInt(process.env.PORT ?? '3000', 10),
}));
