import { Controller, Get } from '@nestjs/common';
import {
  HealthCheck,
  HealthCheckService,
  PrismaHealthIndicator,
} from '@nestjs/terminus';

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
