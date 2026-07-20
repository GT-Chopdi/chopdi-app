# Architecture

Chopdi is a monorepo containing the mobile client and the backend API.

```
chopdi-app/
├── apps/
│   ├── mobile/   # Flutter app (Isar, Riverpod)
│   └── api/      # NestJS backend (Neon/PostgreSQL, JWT, R2/S3, FCM)
└── docs/
```

## Components

### Mobile (`apps/mobile`)

Flutter application. Uses **Isar** for the local database, **Riverpod** for
state management, **Workmanager** for background tasks, and a custom sync queue
for offline-first behaviour. It talks to the API over HTTPS.

### API (`apps/api`)

NestJS service. Responsibilities as the platform grows:

- **Database** — Neon (serverless PostgreSQL)
- **Storage** — Cloudflare R2 / AWS S3 for file uploads
- **Auth** — JWT access tokens + refresh tokens
- **Push** — Firebase Cloud Messaging (FCM)
- **Sync** — server endpoints backing the mobile offline sync queue

The API is organised as feature modules under `src/modules`, with shared,
cross-cutting concerns under `src/common`. See `apps/api/README.md` and the
per-folder READMEs for conventions.

## Offline sync (planned)

The mobile app writes locally to Isar and enqueues mutations in a sync queue.
A background worker drains the queue to the API when connectivity is available;
the API reconciles and returns authoritative state. Conflict-resolution rules
will be documented here as the sync protocol is designed.

> This document describes the intended architecture. It is updated as each
> capability is actually implemented.
