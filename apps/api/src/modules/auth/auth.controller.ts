import { Body, Controller, HttpCode, Post, UseGuards } from '@nestjs/common';
import { Throttle } from '@nestjs/throttler';

import type { AuthenticatedUser, TokenPair } from './auth.types';
import { AuthService, type AuthSession } from './auth.service';
import { CurrentUser } from './decorators/current-user.decorator';
import { Public } from '../../common/decorators/public.decorator';
import { RefreshDto } from './dto/refresh.dto';
import { RequestOtpDto } from './dto/request-otp.dto';
import { VerifyOtpDto } from './dto/verify-otp.dto';
import { DevKeyGuard } from './guards/dev-key.guard';
import type { OtpChallengeIssued } from './otp.service';

const HOUR = 3_600_000;

@Controller('v1/auth')
export class AuthController {
  constructor(private readonly auth: AuthService) {}

  /**
   * Requests a verification code.
   *
   * Responds identically whether or not the number is registered — see
   * OtpService.createChallenge.
   *
   * Two limits guard this endpoint and they do different jobs:
   *
   *  - The **per-phone resend cooldown** in OtpService is the precise control.
   *    It is what stops an attacker SMS-bombing one victim's number, and it is
   *    keyed on the thing being abused.
   *  - The per-IP limit here is a coarse backstop against mass enumeration
   *    across many numbers.
   *
   * The IP limit is deliberately not tight. Real testers share an office NAT
   * and real users share carrier-grade NAT, so a handful-per-hour ceiling locks
   * out legitimate people in blocks while barely inconveniencing an attacker
   * with a proxy pool. Precision belongs on the phone number, not the IP.
   */
  @Public()
  @UseGuards(DevKeyGuard)
  @Throttle({ default: { limit: 20, ttl: HOUR } })
  @Post('otp/request')
  @HttpCode(200)
  requestOtp(@Body() dto: RequestOtpDto): Promise<OtpChallengeIssued> {
    return this.auth.requestOtp(dto);
  }

  /**
   * Brute force is bounded by the per-challenge attempt cap (5, then the
   * challenge is burned), so this limit only needs to stop someone cycling
   * fresh challenges to get more guesses.
   */
  @Public()
  @UseGuards(DevKeyGuard)
  @Throttle({ default: { limit: 30, ttl: HOUR } })
  @Post('otp/verify')
  @HttpCode(200)
  verifyOtp(@Body() dto: VerifyOtpDto): Promise<AuthSession> {
    return this.auth.verifyOtp(dto);
  }

  /**
   * Exchanges a refresh token for a new pair.
   *
   * Public because the access token is expected to be expired by the time a
   * client calls this — the refresh token is itself the credential.
   */
  @Public()
  @Throttle({ default: { limit: 60, ttl: HOUR } })
  @Post('refresh')
  @HttpCode(200)
  refresh(@Body() dto: RefreshDto): Promise<TokenPair> {
    return this.auth.refresh(dto);
  }

  @Post('logout')
  @HttpCode(204)
  logout(@CurrentUser() user: AuthenticatedUser): Promise<void> {
    return this.auth.logout(user);
  }
}
