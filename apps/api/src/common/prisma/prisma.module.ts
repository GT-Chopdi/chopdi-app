import { Global, Module } from '@nestjs/common';

import { PrismaService } from './prisma.service';

/**
 * Global database access module.
 *
 * Provides and exports {@link PrismaService} so any feature module can inject
 * it without re-importing. Marked `@Global()` because database access is a
 * cross-cutting concern used throughout the application.
 */
@Global()
@Module({
  providers: [PrismaService],
  exports: [PrismaService],
})
export class PrismaModule {}
