import * as Joi from 'joi';

/**
 * Validation schema for environment variables.
 *
 * The application refuses to boot if any required variable is missing or
 * malformed, so misconfiguration surfaces immediately instead of at the
 * first request. Add new variables here as infrastructure is wired up
 * (database, storage, auth, FCM, ...).
 */
export const envValidationSchema = Joi.object({
  NODE_ENV: Joi.string()
    .valid('development', 'test', 'production')
    .default('development'),
  PORT: Joi.number().port().default(3000),
  DATABASE_URL: Joi.string()
    .uri({ scheme: ['postgres', 'postgresql'] })
    .required(),
});
