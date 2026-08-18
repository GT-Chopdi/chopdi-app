import { Module } from '@nestjs/common';
import { APP_FILTER, APP_GUARD } from '@nestjs/core';
import { ThrottlerGuard, ThrottlerModule } from '@nestjs/throttler';

import { ConfigModule } from './common/config/config.module';
import { AllExceptionsFilter } from './common/filters/all-exceptions.filter';
import { PrismaModule } from './common/prisma/prisma.module';
import { HealthModule } from './health/health.module';
import { AuthModule } from './modules/auth/auth.module';

/**
 * Application root module.
 *
 * Composes cross-cutting infrastructure (configuration, database, health,
 * rate limiting, error handling) with the domain feature modules under
 * `src/modules`. Add each new feature module to the `imports` array as it is
 * created.
 */
@Module({
  imports: [
    ConfigModule,

    // Baseline ceiling for every route. Individual endpoints tighten this with
    // `@Throttle` — auth routes in particular, where the limits are far lower.
    ThrottlerModule.forRoot([{ ttl: 60_000, limit: 300 }]),

    PrismaModule,
    HealthModule,
    AuthModule,
  ],
  providers: [
    { provide: APP_FILTER, useClass: AllExceptionsFilter },
    { provide: APP_GUARD, useClass: ThrottlerGuard },
  ],
})
export class AppModule {}
