import { Module } from '@nestjs/common';

import { ConfigModule } from './common/config/config.module';
import { PrismaModule } from './common/prisma/prisma.module';
import { HealthModule } from './health/health.module';

/**
 * Application root module.
 *
 * Composes cross-cutting infrastructure (configuration, health) with the
 * domain feature modules under `src/modules`. Add each new feature module to
 * the `imports` array as it is created.
 */
@Module({
  imports: [ConfigModule, PrismaModule, HealthModule],
})
export class AppModule {}
