import { ValidationPipe } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { NestFactory } from '@nestjs/core';

import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  const config = app.get(ConfigService);

  // Namespace every route under /api so the mobile client has a stable base path.
  app.setGlobalPrefix('api');

  // Reject unknown/invalid payloads globally; DTOs opt into their own rules.
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );

  // Flush in-flight work on SIGTERM/SIGINT (clean container shutdowns).
  app.enableShutdownHooks();

  const port = config.get<number>('app.port', 3000);
  await app.listen(port);
}

void bootstrap();
