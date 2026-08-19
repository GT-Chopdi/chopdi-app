import * as Joi from 'joi';

/**
 * Validation schema for environment variables.
 *
 * The application refuses to boot if any required variable is missing or
 * malformed, so misconfiguration surfaces immediately instead of at the
 * first request. Add new variables here as infrastructure is wired up
 * (storage, FCM, ...).
 */
export const envValidationSchema = Joi.object({
  // ---------------------------------------------------------------- runtime
  /**
   * Node's build-mode flag. Platforms own this — Vercel forces it to
   * `production` on every deployment and will not let you override it — so it
   * is deliberately NOT what any security decision keys on. See APP_ENV.
   */
  NODE_ENV: Joi.string()
    .valid('development', 'test', 'staging', 'production')
    .default('development'),

  /**
   * Which environment this deployment *is*, as opposed to how Node was built.
   *
   * These are genuinely different questions, and conflating them is what broke
   * the first Vercel deploy: Vercel legitimately owns NODE_ENV, but only we
   * know whether a given deployment is staging or production. APP_ENV is ours,
   * so no platform can claim it.
   *
   * Defaults to NODE_ENV when unset, so local development and Render behave
   * exactly as before and the protection below cannot be lost by omission.
   */
  APP_ENV: Joi.string()
    .valid('development', 'test', 'staging', 'production')
    .default(() => process.env.NODE_ENV ?? 'development'),
  PORT: Joi.number().port().default(3000),

  // --------------------------------------------------------------- database
  // Pooled Neon endpoint (`...-pooler...`) — used by the running application.
  DATABASE_URL: Joi.string()
    .uri({ scheme: ['postgres', 'postgresql'] })
    .required(),

  // Direct (non-pooled) Neon endpoint — used only by `prisma migrate`. DDL and
  // migration advisory locks need a session-scoped connection, which the
  // transaction-mode pooler cannot provide. Not needed by the app at runtime,
  // so it is optional here but required in any environment that runs migrations.
  DIRECT_URL: Joi.string()
    .uri({ scheme: ['postgres', 'postgresql'] })
    .optional(),

  /**
   * Which Prisma driver adapter to use.
   *
   * `pg` — node-postgres over TCP. Correct for a long-lived process (local,
   *        Render, any container host), where one pool is reused for the
   *        process lifetime.
   * `neon` — Neon's serverless driver over WebSocket. Correct for serverless
   *        (Vercel), where each function instance would otherwise open its own
   *        TCP pool and churn through Neon's connection budget.
   */
  DATABASE_DRIVER: Joi.string().valid('pg', 'neon').default('pg'),

  // ----------------------------------------------------------------- tokens
  JWT_ACCESS_SECRET: Joi.string().min(32).required(),
  JWT_REFRESH_SECRET: Joi.string().min(32).required(),
  ACCESS_TOKEN_TTL: Joi.string().default('15m'),
  REFRESH_TOKEN_TTL_DAYS: Joi.number().integer().min(1).default(30),

  // -------------------------------------------------------------------- OTP
  OTP_TTL_SECONDS: Joi.number().integer().min(60).default(300),
  OTP_MAX_ATTEMPTS: Joi.number().integer().min(1).default(5),
  OTP_RESEND_COOLDOWN_SECONDS: Joi.number().integer().min(0).default(60),

  // --------------------------------------------------------------- dev mode
  /**
   * When true, any phone number authenticates with a fixed code and no SMS is
   * sent. Everything downstream is real: a real user row, a real device row,
   * real tokens, real sync.
   *
   * The `when` below is a hard interlock, not a warning: the process refuses
   * to start if dev mode is enabled in production. A bypass that can reach
   * production is the same vulnerability as the hardcoded client-side OTP it
   * replaces.
   *
   * Keyed on APP_ENV, not NODE_ENV — a deployed staging environment needs
   * NODE_ENV=production for sane runtime behaviour while still being staging.
   */
  AUTH_DEV_MODE: Joi.boolean()
    .default(false)
    .when('APP_ENV', {
      is: 'production',
      then: Joi.valid(false).messages({
        'any.only':
          'AUTH_DEV_MODE must be false when APP_ENV=production. ' +
          'Dev mode lets any phone number authenticate with a fixed code. ' +
          'For an internet-reachable test environment set APP_ENV=staging.',
      }),
    }),

  AUTH_DEV_OTP: Joi.string()
    .length(6)
    .pattern(/^\d{6}$/)
    .default('123456'),

  /**
   * Shared secret required on auth requests while dev mode is on. Staging is
   * internet-reachable, so without this anyone who finds the URL can sign in
   * as any phone number.
   */
  AUTH_DEV_KEY: Joi.string()
    .min(16)
    .when('AUTH_DEV_MODE', {
      is: true,
      then: Joi.required().messages({
        'any.required':
          'AUTH_DEV_KEY is required when AUTH_DEV_MODE=true — it gates the ' +
          'fixed-OTP bypass on internet-reachable environments.',
      }),
      otherwise: Joi.optional(),
    }),

  // ------------------------------------------------------------------- sync
  SYNC_MAX_BATCH_SIZE: Joi.number().integer().min(1).max(1000).default(200),
  SYNC_MAX_PULL_LIMIT: Joi.number().integer().min(1).max(2000).default(500),
  SYNC_BODY_LIMIT: Joi.string().default('1mb'),
});
