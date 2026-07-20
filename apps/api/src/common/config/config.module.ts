import { Module } from '@nestjs/common';
import { ConfigModule as NestConfigModule } from '@nestjs/config';

import { appConfig } from './app.config';
import { databaseConfig } from './database.config';
import { envValidationSchema } from './env.validation';

/**
 * Global configuration module.
 *
 * Loads and validates environment variables once at startup and exposes a
 * typed `ConfigService` everywhere via `isGlobal`. Register new config
 * namespaces in the `load` array as infrastructure is added.
 */
@Module({
  imports: [
    NestConfigModule.forRoot({
      isGlobal: true,
      cache: true,
      load: [appConfig, databaseConfig],
      validationSchema: envValidationSchema,
      validationOptions: {
        abortEarly: false,
      },
    }),
  ],
})
export class ConfigModule {}
