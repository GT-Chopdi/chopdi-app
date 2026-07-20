# Chopdi API

Backend service for the Chopdi app, built with [NestJS](https://nestjs.com).

## Requirements

- Node.js 20+
- npm 10+

## Getting started

```bash
# from apps/api
cp .env.example .env
npm install
npm run start:dev
```

The server listens on `PORT` (default `3000`) and namespaces all routes under
`/api`. A health check is available at `GET /api/health`.

## Scripts

| Script                | Description                          |
| --------------------- | ------------------------------------ |
| `npm run start:dev`   | Start with hot-reload                |
| `npm run start:prod`  | Run the compiled build (`dist/`)     |
| `npm run build`       | Compile to `dist/`                   |
| `npm run lint`        | Lint and auto-fix                    |
| `npm run test`        | Unit tests                           |
| `npm run test:e2e`    | End-to-end tests                     |

## Project structure

```
src/
├── main.ts                 # bootstrap: global prefix, validation, shutdown hooks
├── app.module.ts           # root module — composes infrastructure + features
├── common/                 # cross-cutting building blocks (see common/README.md)
│   └── config/             # typed, validated environment configuration
├── health/                 # liveness/readiness endpoint
└── modules/                # domain feature modules (see modules/README.md)
```

New features go under [`src/modules`](src/modules); shared concerns go under
[`src/common`](src/common). See each folder's README for conventions.
