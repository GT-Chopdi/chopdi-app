import { Controller, Get } from '@nestjs/common';
import {
  HealthCheck,
  HealthCheckService,
  PrismaHealthIndicator,
} from '@nestjs/terminus';
import { SkipThrottle } from '@nestjs/throttler';

import { Public } from '../common/decorators/public.decorator';
import { PrismaService } from '../common/prisma/prisma.service';

/**
 * Liveness/readiness endpoint used by load balancers, container orchestrators
 * and uptime monitors. Register additional indicators (storage, external
 * services) in the check array as those dependencies are wired up.
 */
@Controller('health')
export class HealthController {
  constructor(
    private readonly health: HealthCheckService,
    private readonly db: PrismaHealthIndicator,
    private readonly prisma: PrismaService,
  ) {}

  /**
   * Unauthenticated and unthrottled by necessity: Render's health check, load
   * balancers, and uptime monitors have no credentials and poll frequently.
   * It exposes only up/down, never any user data.
   */
  @Public()
  @SkipThrottle()
  @Get()
  @HealthCheck()
  check() {
    return this.health.check([
      // Neon is serverless: the first query after idle can be slow, so allow
      // more than Terminus's default 1s before reporting the database down.
      () => this.db.pingCheck('database', this.prisma, { timeout: 5000 }),
    ]);
  }
}
