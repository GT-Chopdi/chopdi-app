import { Controller, Get } from '@nestjs/common';
import { HealthCheck, HealthCheckService } from '@nestjs/terminus';

/**
 * Liveness/readiness endpoint used by load balancers, container orchestrators
 * and uptime monitors. Register additional indicators (database, storage,
 * external services) in the check array as those dependencies are wired up.
 */
@Controller('health')
export class HealthController {
  constructor(private readonly health: HealthCheckService) {}

  @Get()
  @HealthCheck()
  check() {
    return this.health.check([]);
  }
}
