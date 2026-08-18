import { registerAs } from '@nestjs/config';

/**
 * Authentication configuration namespace.
 *
 * Values are validated at startup by {@link envValidationSchema}, so the
 * fallbacks here only mirror the Joi defaults — they are never the sole
 * source of truth. Access via `configService.get('auth.<key>')`.
 */
export const authConfig = registerAs('auth', () => ({
  accessSecret: process.env.JWT_ACCESS_SECRET,
  refreshSecret: process.env.JWT_REFRESH_SECRET,
  accessTokenTtl: process.env.ACCESS_TOKEN_TTL ?? '15m',
  refreshTokenTtlDays: parseInt(process.env.REFRESH_TOKEN_TTL_DAYS ?? '30', 10),

  otp: {
    ttlSeconds: parseInt(process.env.OTP_TTL_SECONDS ?? '300', 10),
    maxAttempts: parseInt(process.env.OTP_MAX_ATTEMPTS ?? '5', 10),
    resendCooldownSeconds: parseInt(
      process.env.OTP_RESEND_COOLDOWN_SECONDS ?? '60',
      10,
    ),
  },

  /**
   * Dev mode: any phone authenticates with `devOtp`, no SMS is sent, and
   * `devKey` must be presented on every auth request. Joi refuses to boot the
   * process if this is true while NODE_ENV=production.
   */
  dev: {
    enabled: process.env.AUTH_DEV_MODE === 'true',
    otp: process.env.AUTH_DEV_OTP ?? '123456',
    key: process.env.AUTH_DEV_KEY,
  },
}));
