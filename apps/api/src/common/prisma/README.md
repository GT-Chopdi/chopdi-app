# Prisma

Database access layer, built on [Prisma](https://www.prisma.io) (v7, driver-adapter
mode) against Neon (PostgreSQL).

- `prisma.service.ts` — `PrismaService` extends the generated `PrismaClient`, wires the
  node-postgres driver adapter from typed config, and manages the connection lifecycle.
- `prisma.module.ts` — `@Global()` module exporting `PrismaService`, so any feature
  module can inject it without re-importing.

## Usage

Inject `PrismaService` in a feature service:

```ts
constructor(private readonly prisma: PrismaService) {}
```

## Schema & migrations

- Schema: [`prisma/schema.prisma`](../../../prisma/schema.prisma) (models are added under
  feature work; empty at bootstrap).
- CLI config: [`prisma.config.ts`](../../../prisma.config.ts) (reads `DATABASE_URL` from `.env`).
- The generated client (`src/generated/`) is git-ignored — run `npm run prisma:generate`
  after cloning or changing the schema (the `postinstall` hook also runs it).

| Command                    | Purpose                              |
| -------------------------- | ------------------------------------ |
| `npm run prisma:generate`  | Regenerate the typed client          |
| `npm run prisma:migrate`   | Create/apply a dev migration         |
| `npm run prisma:studio`    | Open Prisma Studio                   |
