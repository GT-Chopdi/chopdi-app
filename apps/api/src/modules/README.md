# Feature Modules

Domain-driven feature modules live here. Each module owns a single bounded
context (e.g. `auth`, `customers`, `chopdi`, `sync`, `notifications`) and is
self-contained so it can be developed, tested, and reasoned about in isolation.

## Conventions

Create one folder per feature and add its module to `AppModule`'s `imports`.
A typical module looks like:

```
modules/<feature>/
├── <feature>.module.ts        # wires the module together
├── <feature>.controller.ts    # HTTP layer (thin)
├── <feature>.service.ts       # business logic
├── dto/                        # request/response DTOs (+ validation)
├── entities/                   # persistence models
└── <feature>.service.spec.ts  # unit tests
```

## Rules

- Controllers stay thin; business logic belongs in services.
- Cross-cutting concerns (config, filters, guards, interceptors) live in
  [`../common`](../common), not here.
- A module exports only what other modules legitimately need.

> This directory is intentionally empty at bootstrap. Do not add placeholder
> modules — create a module only when its feature is actually being built.
