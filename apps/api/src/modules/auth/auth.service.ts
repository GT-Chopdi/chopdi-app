import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { v7 as uuidv7 } from 'uuid';

import { AppException, ErrorCode } from '../../common/errors/app.exception';
import { PrismaService } from '../../common/prisma/prisma.service';
import type { AuthenticatedUser, TokenPair } from './auth.types';
import type { RefreshDto } from './dto/refresh.dto';
import type { RequestOtpDto } from './dto/request-otp.dto';
import type { VerifyOtpDto } from './dto/verify-otp.dto';
import { OtpService, type OtpChallengeIssued } from './otp.service';
import { TokenService } from './token.service';

export interface AuthSession extends TokenPair {
  user: { id: string; phone: string; displayName: string | null };
  deviceId: string;
  /** Cursor to start syncing from. Always 0 until Phase 1 wires the change log. */
  syncCursor: number;
  isNewUser: boolean;
}

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly config: ConfigService,
    private readonly otp: OtpService,
    private readonly tokens: TokenService,
  ) {}

  requestOtp(dto: RequestOtpDto): Promise<OtpChallengeIssued> {
    return this.otp.createChallenge(dto.phone);
  }

  /**
   * Verifies the code, resolves the user, binds the device, and issues tokens.
   *
   * The phone number comes from the *challenge*, never from this request —
   * otherwise a client could verify a code issued for its own number and then
   * claim someone else's identity.
   */
  async verifyOtp(dto: VerifyOtpDto): Promise<AuthSession> {
    const phoneE164 = await this.otp.verifyChallenge(dto.challengeId, dto.code);

    const existing = await this.prisma.appUser.findUnique({
      where: { phoneE164 },
      select: { id: true, phoneE164: true, displayName: true, status: true },
    });

    // Upsert rather than create: two concurrent verifications for a brand-new
    // number would otherwise collide on the unique phone index.
    const user =
      existing ??
      (await this.prisma.appUser.upsert({
        where: { phoneE164 },
        create: { id: uuidv7(), phoneE164 },
        update: {},
        select: { id: true, phoneE164: true, displayName: true, status: true },
      }));

    if (user.status !== 'active') {
      throw new AppException(
        403,
        ErrorCode.USER_SUSPENDED,
        'This account is not active.',
        true,
      );
    }

    // Keyed on (userId, installId) so a second user signing in on the same
    // handset gets their own device row rather than inheriting the first's.
    // Clearing `revokedAt` is intentional: completing an OTP challenge proves
    // control of the phone number, which is enough to bring a device back.
    const device = await this.prisma.device.upsert({
      where: {
        userId_installId: { userId: user.id, installId: dto.installId },
      },
      create: {
        id: uuidv7(),
        userId: user.id,
        installId: dto.installId,
        platform: dto.platform,
        appVersion: dto.appVersion,
        lastSeenAt: new Date(),
      },
      update: {
        platform: dto.platform,
        appVersion: dto.appVersion,
        lastSeenAt: new Date(),
        revokedAt: null,
      },
      select: { id: true },
    });

    const pair = await this.tokens.issuePair(user.id, device.id);

    if (this.config.get<boolean>('auth.dev.enabled')) {
      this.logger.warn(
        `[dev-mode] authenticated ${phoneE164} (user=${user.id}, device=${device.id})`,
      );
    }

    return {
      ...pair,
      user: {
        id: user.id,
        phone: user.phoneE164,
        displayName: user.displayName,
      },
      deviceId: device.id,
      syncCursor: 0,
      isNewUser: !existing,
    };
  }

  async refresh(dto: RefreshDto): Promise<TokenPair> {
    const { pair } = await this.tokens.rotate(dto.refreshToken, dto.deviceId);
    return pair;
  }

  /** Revokes this device's tokens. Local data is untouched. */
  async logout(user: AuthenticatedUser): Promise<void> {
    await this.tokens.revokeDeviceTokens(user.deviceId);
  }
}
