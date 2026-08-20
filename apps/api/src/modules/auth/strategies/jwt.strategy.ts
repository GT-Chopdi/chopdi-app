import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';

import { AppException, ErrorCode } from '../../../common/errors/app.exception';
import { PrismaService } from '../../../common/prisma/prisma.service';
import type { AuthenticatedUser, JwtPayload } from '../auth.types';

/** How long a device/user liveness check is trusted before re-reading it. */
const CACHE_TTL_MS = 60_000;

/** Crude bound so a long-lived process cannot grow this map without limit. */
const CACHE_MAX_ENTRIES = 10_000;

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy, 'jwt') {
  /**
   * Device revocation and account status have to be checked against the
   * database — they are exactly the things a token cannot carry, because a
   * claim baked into a signed token cannot be withdrawn.
   *
   * Doing that read on every request would put a Neon round-trip in front of
   * all traffic, so results are cached briefly. The cost is that revoking a
   * device takes up to a minute to take effect; the alternative costs a query
   * per request forever. Note this cache is per-instance, so with several
   * instances the worst case is still one TTL.
   */
  private readonly cache = new Map<
    string,
    { user: AuthenticatedUser; expiresAt: number }
  >();

  constructor(
    config: ConfigService,
    private readonly prisma: PrismaService,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: config.getOrThrow<string>('auth.accessSecret'),
    });
  }

  async validate(payload: JwtPayload): Promise<AuthenticatedUser> {
    const key = `${payload.sub}:${payload.did}`;
    const cached = this.cache.get(key);

    if (cached && cached.expiresAt > Date.now()) {
      return cached.user;
    }

    const device = await this.prisma.device.findUnique({
      where: { id: payload.did },
      select: {
        id: true,
        userId: true,
        revokedAt: true,
        user: { select: { phoneE164: true, status: true } },
      },
    });

    // A device that belongs to a different user than the token claims means
    // the token was tampered with or the device was reassigned. Either way the
    // pairing is not trustworthy.
    if (!device || device.userId !== payload.sub) {
      throw new AppException(
        401,
        ErrorCode.UNAUTHENTICATED,
        'Session is no longer valid.',
        true,
      );
    }

    if (device.revokedAt) {
      throw new AppException(
        403,
        ErrorCode.DEVICE_REVOKED,
        'This device has been signed out.',
        true,
      );
    }

    if (device.user.status !== 'active') {
      throw new AppException(
        403,
        ErrorCode.USER_SUSPENDED,
        'This account is not active.',
        true,
      );
    }

    const user: AuthenticatedUser = {
      userId: device.userId,
      deviceId: device.id,
      phoneE164: device.user.phoneE164,
    };

    if (this.cache.size >= CACHE_MAX_ENTRIES) {
      this.cache.clear();
    }

    this.cache.set(key, { user, expiresAt: Date.now() + CACHE_TTL_MS });

    return user;
  }
}
