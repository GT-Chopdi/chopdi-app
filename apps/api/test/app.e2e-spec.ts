import { INestApplication } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import request from 'supertest';
import { App } from 'supertest/types';

import { AppModule } from './../src/app.module';
import { PrismaService } from './../src/common/prisma/prisma.service';

/**
 * Boots the full application graph but replaces PrismaService with a light
 * stub, so the suite verifies wiring (routes, health, global prefix) without
 * needing a live database.
 */
describe('App (e2e)', () => {
  let app: INestApplication<App>;

  // Terminus's Prisma indicator tries the Mongo `$runCommandRaw` first and only
  // falls back to the SQL `$queryRawUnsafe` when the error names the mongodb
  // provider — so the mock reproduces that PostgreSQL behaviour.
  const prismaMock = {
    $connect: jest.fn().mockResolvedValue(undefined),
    $disconnect: jest.fn().mockResolvedValue(undefined),
    $runCommandRaw: jest
      .fn()
      .mockRejectedValue(new Error('Use the mongodb provider')),
    $queryRawUnsafe: jest.fn().mockResolvedValue([{ result: 1 }]),
  };

  beforeEach(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    })
      .overrideProvider(PrismaService)
      .useValue(prismaMock)
      .compile();

    app = moduleFixture.createNestApplication();
    app.setGlobalPrefix('api');
    await app.init();
  });

  afterEach(async () => {
    await app.close();
  });

  it('/api/health (GET) reports the service and database are up', () => {
    return request(app.getHttpServer())
      .get('/api/health')
      .expect(200)
      .expect((res) => {
        const body = res.body as {
          status: string;
          info: { database: { status: string } };
        };
        expect(body.status).toBe('ok');
        expect(body.info.database.status).toBe('up');
      });
  });
});
