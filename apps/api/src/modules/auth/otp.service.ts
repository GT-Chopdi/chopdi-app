import { randomInt } from 'node:crypto';

import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as argon2 from 'argon2';
import { uuidv7 } from '../../common/utils/uuid';

import { AppException, ErrorCode } from '../../common/errors/app.exception';
import { PrismaService } from '../../common/prisma/prisma.service';

export interface OtpChallengeIssued {
  challengeId: string;
  expiresInSeconds: number;
  resendAfterSeconds: number;
}

/**
 * One-time-password issuance and verification.
 *
 * Dev mode changes exactly one thing: the code is a fixed value instead of a
 * random one, and no SMS is sent. It is still hashed, still stored, still
 * verified through the same path, and still subject to expiry and the attempt
 * cap. Keeping the verification path identical is deliberate — a dev branch
 * that skips verification would mean the code you test is not the code that
 * ships.
 */
@Injectable()
export class OtpService {
  private readonly logger = new Logger(OtpService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly config: ConfigService,
  ) {}

  private get ttlSeconds(): number {
    return this.config.getOrThrow<number>('auth.otp.ttlSeconds');
  }

  private get maxAttempts(): number {
    return this.config.getOrThrow<number>('auth.otp.maxAttempts');
  }

  private get resendCooldownSeconds(): number {
    return this.config.getOrThrow<number>('auth.otp.resendCooldownSeconds');
  }

  private get devEnabled(): boolean {
    return this.config.get<boolean>('auth.dev.enabled') === true;
  }

  /**
   * Issues a challenge for any phone number, registered or not.
   *
   * The caller must return an identical response either way. Differing status
   * codes, bodies, or latencies would turn this endpoint into a
   * phone-enumeration oracle — an attacker could harvest which numbers hold
   * lending ledgers.
   */
  async createChallenge(phoneE164: string): Promise<OtpChallengeIssued> {
    await this.enforceResendCooldown(phoneE164);

    const code = this.generateCode();
    const codeHash = await argon2.hash(code, { type: argon2.argon2id });
    const expiresAt = new Date(Date.now() + this.ttlSeconds * 1000);

    const challenge = await this.prisma.otpChallenge.create({
      data: {
        id: uuidv7(),
        phoneE164,
        codeHash,
        maxAttempts: this.maxAttempts,
        expiresAt,
      },
      select: { id: true },
    });

    await this.deliver(phoneE164, code);

    return {
      challengeId: challenge.id,
      expiresInSeconds: this.ttlSeconds,
      resendAfterSeconds: this.resendCooldownSeconds,
    };
  }

  /**
   * Verifies a code and burns the challenge.
   *
   * @returns the phone number the challenge was issued for — never taken from
   *   the request, so a client cannot verify one number's code and claim
   *   another's identity.
   */
  async verifyChallenge(challengeId: string, code: string): Promise<string> {
    const challenge = await this.prisma.otpChallenge.findUnique({
      where: { id: challengeId },
    });

    // An unknown challenge id and a wrong code are the same failure to the
    // caller: revealing which one occurred would let an attacker enumerate
    // live challenges.
    if (!challenge) {
      throw new AppException(
        401,
        ErrorCode.INVALID_CODE,
        'Invalid or expired code.',
        true,
      );
    }

    if (challenge.consumedAt) {
      throw new AppException(
        401,
        ErrorCode.INVALID_CODE,
        'Invalid or expired code.',
        true,
      );
    }

    if (challenge.expiresAt.getTime() <= Date.now()) {
      throw new AppException(
        410,
        ErrorCode.CHALLENGE_EXPIRED,
        'This code has expired. Request a new one.',
        true,
      );
    }

    if (challenge.attempts >= challenge.maxAttempts) {
      throw new AppException(
        423,
        ErrorCode.TOO_MANY_ATTEMPTS,
        'Too many incorrect attempts. Request a new code.',
        true,
      );
    }

    // argon2.verify is constant-time with respect to the hash comparison.
    const matches = await argon2.verify(challenge.codeHash, code);

    if (!matches) {
      await this.prisma.otpChallenge.update({
        where: { id: challenge.id },
        data: { attempts: { increment: 1 } },
      });

      const remaining = challenge.maxAttempts - (challenge.attempts + 1);

      throw new AppException(
        401,
        ErrorCode.INVALID_CODE,
        'Invalid or expired code.',
        true,
        { attemptsRemaining: Math.max(0, remaining) },
      );
    }

    // Consume atomically. Two concurrent verifications of the same challenge
    // must not both succeed — the loser sees it as already consumed.
    const consumed = await this.prisma.otpChallenge.updateMany({
      where: { id: challenge.id, consumedAt: null },
      data: { consumedAt: new Date() },
    });

    if (consumed.count === 0) {
      throw new AppException(
        401,
        ErrorCode.INVALID_CODE,
        'Invalid or expired code.',
        true,
      );
    }

    return challenge.phoneE164;
  }

  // ------------------------------------------------------------------ internals

  /**
   * `crypto.randomInt` is CSPRNG-backed and rejection-samples, so the
   * distribution is uniform — `Math.random()` here would be predictable and
   * `% 1000000` would be biased.
   */
  private generateCode(): string {
    if (this.devEnabled) {
      return this.config.getOrThrow<string>('auth.dev.otp');
    }

    return randomInt(0, 1_000_000).toString().padStart(6, '0');
  }

  /**
   * Blocks a repeat request while an unused code is still live.
   *
   * The `consumedAt: null` filter is deliberate and load-bearing. The attack
   * this defends against is SMS-bombing — an attacker hammering "send a code"
   * at someone else's number, which produces a trail of challenges nobody ever
   * verifies. A *consumed* challenge means a login actually completed, so it
   * should not penalise the next one: a user who signs out and back in, or
   * switches accounts, would otherwise hit a pointless 60-second wall.
   *
   * Per-IP throttling on the controller bounds the remaining case (someone
   * who can complete verification requesting codes repeatedly).
   */
  private async enforceResendCooldown(phoneE164: string): Promise<void> {
    const since = new Date(Date.now() - this.resendCooldownSeconds * 1000);

    const recent = await this.prisma.otpChallenge.findFirst({
      where: {
        phoneE164,
        consumedAt: null,
        createdAt: { gt: since },
      },
      orderBy: { createdAt: 'desc' },
      select: { createdAt: true },
    });

    if (!recent) return;

    const elapsed = Math.floor((Date.now() - recent.createdAt.getTime()) / 1000);
    const retryAfter = Math.max(1, this.resendCooldownSeconds - elapsed);

    throw new AppException(
      429,
      ErrorCode.RATE_LIMITED,
      'A code was already sent. Please wait before requesting another.',
      false,
      { retryAfterSeconds: retryAfter },
    );
  }

  /**
   * Delivers the code.
   *
   * In dev mode nothing is sent — the code is fixed and already known to the
   * tester. In any other mode this needs a real SMS provider, and it fails
   * loudly rather than silently accepting a request it cannot fulfil.
   *
   * TODO(DLT): implement the SMS adapter once DLT registration clears, then
   * set AUTH_DEV_MODE=false. No other code changes.
   */
  private async deliver(phoneE164: string, code: string): Promise<void> {
    if (this.devEnabled) {
      // Logged at debug so it never reaches production log aggregation — and
      // production cannot enable dev mode anyway (Joi refuses to boot).
      this.logger.debug(`[dev-mode] OTP for ${phoneE164} is ${code}`);
      return;
    }

    throw new AppException(
      503,
      ErrorCode.SMS_NOT_CONFIGURED,
      'SMS delivery is not configured.',
      false,
    );
  }
}
