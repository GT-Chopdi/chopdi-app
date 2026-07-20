import {
  Injectable,
  Logger,
  OnModuleDestroy,
  OnModuleInit,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaPg } from '@prisma/adapter-pg';

import { PrismaClient } from '../../generated/prisma/client';

/**
 * Application-wide Prisma client.
 *
 * Prisma 7 runs without the Rust engine, so the client is constructed with a
 * node-postgres driver adapter. The connection string comes from the typed
 * configuration (`database.url`) rather than the schema. Connection lifecycle
 * is tied to the Nest module lifecycle; `main.ts` enables shutdown hooks so
 * `onModuleDestroy` runs on SIGTERM/SIGINT.
 */
@Injectable()
export class PrismaService
  extends PrismaClient
  implements OnModuleInit, OnModuleDestroy
{
  private readonly logger = new Logger(PrismaService.name);

  constructor(config: ConfigService) {
    super({
      adapter: new PrismaPg(config.getOrThrow<string>('database.url')),
    });
  }

  async onModuleInit(): Promise<void> {
    await this.$connect();
    this.logger.log('Database connection established');
  }

  async onModuleDestroy(): Promise<void> {
    await this.$disconnect();
  }
}
