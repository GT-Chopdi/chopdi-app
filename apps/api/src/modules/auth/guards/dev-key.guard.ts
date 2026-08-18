import { createHash, timingSafeEqual } from 'node:crypto';

import { CanActivate, ExecutionContext, Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

import { AppException, ErrorCode } from '../../../common/errors/app.exception';

/**
 * Gates the fixed-OTP bypass behind a shared secret while dev mode is on.
 *
 * Dev mode lets any phone number authenticate with a known code. Staging is
 * internet-reachable, so without this guard anyone who discovers the URL could
 * sign in as any number and read that ledger. When dev mode is off this guard
 * is inert, and production cannot enable dev mode at all — Joi refuses to boot
 * the process.
 */
@Injectable()
export class DevKeyGuard implements CanActivate {
  constructor(private readonly config: ConfigService) {}

  canActivate(context: ExecutionContext): boolean {
    if (this.config.get<boolean>('auth.dev.enabled') !== true) {
      return true;
    }

    const expected = this.config.getOrThrow<string>('auth.dev.key');
    const request = context.switchToHttp().getRequest<{
      headers: Record<string, string | string[] | undefined>;
    }>();

    const header = request.headers['x-dev-key'];
    const provided = Array.isArray(header) ? header[0] : header;

    if (!provided || !this.matches(provided, expected)) {
      throw new AppException(
        403,
        ErrorCode.DEV_KEY_REQUIRED,
        'A valid X-Dev-Key header is required on this environment.',
        true,
      );
    }

    return true;
  }

  /**
   * Hashing both sides first gives `timingSafeEqual` the equal-length buffers
   * it requires, and stops the comparison from leaking the secret's length.
   */
  private matches(provided: string, expected: string): boolean {
    const a = createHash('sha256').update(provided).digest();
    const b = createHash('sha256').update(expected).digest();

    return timingSafeEqual(a, b);
  }
}
