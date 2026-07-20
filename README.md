# Chopdi

Monorepo for the Chopdi platform — an offline-first mobile app with a NestJS
backend.

## Structure

```
chopdi-app/
├── apps/
│   ├── mobile/   # Flutter app (Isar, Riverpod, Workmanager)
│   └── api/      # NestJS backend (Neon/PostgreSQL, JWT, R2/S3, FCM)
├── docs/         # architecture & design docs
└── README.md
```

## Tech stack

| Area              | Choice                              |
| ----------------- | ----------------------------------- |
| Mobile            | Flutter                             |
| Local database    | Isar                                |
| State management  | Riverpod                            |
| Backend           | NestJS                              |
| Cloud database    | Neon (PostgreSQL)                   |
| Storage           | Cloudflare R2 / AWS S3              |
| Authentication    | JWT + refresh tokens                |
| Push notifications| Firebase Cloud Messaging (FCM)      |
| Background tasks  | Workmanager (Flutter)               |
| Offline sync      | Custom sync queue                   |

## Getting started

Each app is self-contained and has its own README:

- **Mobile** — see [`apps/mobile/README.md`](apps/mobile/README.md)
  ```bash
  cd apps/mobile
  flutter pub get
  flutter run
  ```
- **API** — see [`apps/api/README.md`](apps/api/README.md)
  ```bash
  cd apps/api
  cp .env.example .env
  npm install
  npm run start:dev
  ```

## Documentation

See [`docs/architecture.md`](docs/architecture.md) for the overall design.
