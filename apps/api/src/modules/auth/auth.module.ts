import { Module } from '@nestjs/common';
import { APP_GUARD } from '@nestjs/core';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';

import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { DeviceGuard } from './guards/device.guard';
import { DevKeyGuard } from './guards/dev-key.guard';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { OtpService } from './otp.service';
import { JwtStrategy } from './strategies/jwt.strategy';
import { TokenService } from './token.service';

/**
 * Identity and authentication.
 *
 * Registers {@link JwtAuthGuard} and {@link DeviceGuard} globally, in that
 * order — the device guard reads the user that the JWT guard attaches, so the
 * ordering here is load-bearing, not stylistic.
 *
 * Signing options are passed per-call in TokenService rather than configured
 * here, because access and refresh use different secrets.
 */
@Module({
  imports: [PassportModule, JwtModule.register({})],
  controllers: [AuthController],
  providers: [
    AuthService,
    OtpService,
    TokenService,
    JwtStrategy,
    DevKeyGuard,
    { provide: APP_GUARD, useClass: JwtAuthGuard },
    { provide: APP_GUARD, useClass: DeviceGuard },
  ],
  exports: [TokenService],
})
export class AuthModule {}
