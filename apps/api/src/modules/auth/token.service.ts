import { createHash, randomBytes } from 'node:crypto';

import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { uuidv7 } from '../../common/utils/uuid';

import { AppException, ErrorCode } from '../../common/errors/app.exception';
import { PrismaService } from '../../common/prisma/prisma.service';
import type { JwtPayload, TokenPair } from './auth.types';

/**
 * Issues and rotates the access/refresh token pair.
 *
 * Access tokens are stateless JWTs with a short life. Refresh tokens are
 * opaque random strings stored as SHA-256 hashes.
 *
 * SHA-256 rather than Argon2 for refresh tokens is deliberate. Argon2 exists
 * to make *low-entropy* secrets expensive to guess — passwords, a 6-digit OTP.
 * A refresh token is 384 bits from a CSPRNG; there is nothing to brute-force,
 * and Argon2's per-hash random salt would make the indexed `token_hash` lookup
 * impossible, forcing a table scan on every refresh.
 */
@Injectable()
export class TokenService {
  private readonly logger = new Logger(TokenService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly config: ConfigService,
    private readonly jwt: JwtService,
  ) {}

  /**
   * Mints a fresh pair. Pass `familyId` to continue an existing rotation
   * lineage; omit it for a new login, which starts a new family.
   */
  async issuePair(
    userId: string,
    deviceId: string,
    options: { familyId?: string; parentId?: string } = {},
  ): Promise<TokenPair> {
    const payload: JwtPayload = { sub: userId, did: deviceId };

    // Resolved to seconds once, then used for both the signature and the
    // `expiresIn` we hand the client — so the token's real lifetime and the
    // client's refresh schedule cannot drift apart.
    const accessTtlSeconds = this.ttlToSeconds(
      this.config.getOrThrow<string>('auth.accessTokenTtl'),
    );

    const accessToken = await this.jwt.signAsync(payload, {
      secret: this.config.getOrThrow<string>('auth.accessSecret'),
      expiresIn: accessTtlSeconds,
    });

    const rawRefresh = randomBytes(48).toString('base64url');
    const ttlDays = this.config.getOrThrow<number>('auth.refreshTokenTtlDays');

    await this.prisma.refreshToken.create({
      data: {
        id: uuidv7(),
        userId,
        deviceId,
        tokenHash: this.hash(rawRefresh),
        familyId: options.familyId ?? uuidv7(),
        parentId: options.parentId ?? null,
        expiresAt: new Date(Date.now() + ttlDays * 86_400_000),
      },
      select: { id: true },
    });

    return {
      accessToken,
      refreshToken: rawRefresh,
      expiresIn: accessTtlSeconds,
    };
  }

  /**
   * Redeems a refresh token for a new pair, invalidating the old one.
   *
   * Reuse detection is the point of this method. A token that has already been
   * redeemed being presented again means two parties hold the lineage — one of
   * them stole it — so the entire family is revoked. The legitimate user
   * re-authenticates with an OTP; the thief cannot.
   */
  async rotate(
    rawRefreshToken: string,
    deviceId: string,
  ): Promise<{ pair: TokenPair; userId: string }> {
    const tokenHash = this.hash(rawRefreshToken);

    const existing = await this.prisma.refreshToken.findUnique({
      where: { tokenHash },
      include: { user: true, device: true },
    });

    if (!existing) {
      throw this.invalid();
    }

    if (existing.usedAt) {
      await this.revokeFamily(existing.familyId);

      this.logger.warn(
        `Refresh token reuse detected — family ${existing.familyId} revoked ` +
          `(user=${existing.userId}, device=${existing.deviceId})`,
      );

      throw new AppException(
        401,
        ErrorCode.REFRESH_REUSED,
        'This session was ended for security reasons. Please sign in again.',
        true,
      );
    }

    if (existing.revokedAt || existing.expiresAt.getTime() <= Date.now()) {
      throw this.invalid();
    }

    // Device binding: a token lifted onto another handset fails here.
    if (existing.deviceId !== deviceId) {
      this.logger.warn(
        `Refresh token presented from mismatched device ` +
          `(expected=${existing.deviceId}, got=${deviceId})`,
      );
      throw this.invalid();
    }

    if (existing.device.revokedAt) {
      throw new AppException(
        403,
        ErrorCode.DEVICE_REVOKED,
        'This device has been signed out.',
        true,
      );
    }

    if (existing.user.status !== 'active') {
      throw new AppException(
        403,
        ErrorCode.USER_SUSPENDED,
        'This account is not active.',
        true,
      );
    }

    // Atomic claim. If two requests race with the same token, exactly one wins
    // — and the loser is, by definition, a second use of a redeemed token.
    const claimed = await this.prisma.refreshToken.updateMany({
      where: { id: existing.id, usedAt: null },
      data: { usedAt: new Date() },
    });

    if (claimed.count === 0) {
      await this.revokeFamily(existing.familyId);

      throw new AppException(
        401,
        ErrorCode.REFRESH_REUSED,
        'This session was ended for security reasons. Please sign in again.',
        true,
      );
    }

    const pair = await this.issuePair(existing.userId, existing.deviceId, {
      familyId: existing.familyId,
      parentId: existing.id,
    });

    return { pair, userId: existing.userId };
  }

  /** Revokes every token in a rotation lineage. */
  async revokeFamily(familyId: string): Promise<void> {
    await this.prisma.refreshToken.updateMany({
      where: { familyId, revokedAt: null },
      data: { revokedAt: new Date() },
    });
  }

  /** Revokes every live token for a device — used on logout. */
  async revokeDeviceTokens(deviceId: string): Promise<void> {
    await this.prisma.refreshToken.updateMany({
      where: { deviceId, revokedAt: null },
      data: { revokedAt: new Date() },
    });
  }

  // ------------------------------------------------------------------ internals

  private hash(raw: string): string {
    return createHash('sha256').update(raw).digest('hex');
  }

  /**
   * An unknown, revoked, expired, or device-mismatched token all produce the
   * same response — distinguishing them would tell an attacker which of their
   * guesses was closest.
   */
  private invalid(): AppException {
    return new AppException(
      401,
      ErrorCode.REFRESH_INVALID,
      'Session expired. Please sign in again.',
      true,
    );
  }

  private ttlToSeconds(ttl: string): number {
    const match = /^(\d+)([smhd])$/.exec(ttl.trim());

    if (!match) {
      const asNumber = Number(ttl);
      return Number.isFinite(asNumber) ? asNumber : 900;
    }

    const value = Number(match[1]);
    const unit = match[2];
    const multipliers: Record<string, number> = { s: 1, m: 60, h: 3600, d: 86400 };

    return value * multipliers[unit];
  }
}
