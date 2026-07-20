# Common

Cross-cutting, application-wide building blocks that are **not** tied to any
single feature. Feature modules under [`../modules`](../modules) consume these;
nothing here should import from a feature module.

## Layout

| Folder     | Purpose                                                             |
| ---------- | ------------------------------------------------------------------- |
| `config/`  | Typed, validated environment configuration (global `ConfigModule`). |

Add sibling folders here only when a real, shared concern needs them, e.g.
`filters/` (exception filters), `interceptors/` (logging, transforms),
`guards/` (auth/roles), `decorators/`, or `pipes/`. Keep this directory free of
feature-specific logic.
