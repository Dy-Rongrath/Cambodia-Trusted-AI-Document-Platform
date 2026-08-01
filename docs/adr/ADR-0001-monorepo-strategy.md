# ADR-0001 — Monorepo with npm Workspaces

## Status

`Accepted`

## Date

2026-08-01

## Context

The platform consists of three applications (NestJS backend, FastAPI AI service, Angular frontend) and a shared TypeScript types package. A decision is needed on whether to manage these in a single repository (monorepo) or separate repositories (polyrepo).

The primary developer is working solo during Phase 0–1. The team may grow in later phases. The chosen structure must support atomic cross-service changes and shared type safety without adding unnecessary tooling complexity.

Key forces:
- TypeScript types must be shared between the backend and frontend without manual synchronisation.
- Docker Compose must be able to reference all services from a single location.
- Changes that touch backend API contracts and frontend clients should be atomic.
- The tooling must be understandable without a dedicated DevOps engineer.
- Python has its own dependency management and is independent of npm workspaces.

## Decision

We will use a **monorepo with npm workspaces** to manage the NestJS backend, Angular frontend, and shared TypeScript types package. The FastAPI Python service lives in the same repository under `apps/ai-service/` but uses its own Python virtual environment managed by uv — it is not part of npm workspaces.

Repository layout:

```
trusted-ai-platform/
├── apps/
│   ├── backend/           # npm workspace — NestJS
│   ├── ai-service/        # NOT an npm workspace — Python (uv)
│   └── frontend/          # npm workspace — Angular
├── packages/
│   └── shared-types/      # npm workspace — shared TypeScript types
├── package.json           # Root workspace configuration
└── package-lock.json      # Root lock file
```

Root `package.json` will declare:
```json
{
  "workspaces": ["apps/backend", "apps/frontend", "packages/shared-types"]
}
```

## Alternatives Considered

| Option | Description | Why rejected or deferred |
|---|---|---|
| Polyrepo | Separate Git repositories per service | Cross-service changes require multiple PRs. Shared types require a published npm package. Significantly higher coordination overhead for a solo developer. |
| Nx monorepo | Advanced monorepo tool with build caching and affected-detection | Adds tooling complexity and a learning curve. npm workspaces are sufficient for this team size. Can be adopted later if build times become a problem. |
| pnpm workspaces | Alternative to npm workspaces with stricter isolation | pnpm is not currently installed. npm workspaces are sufficient. Can migrate later if performance becomes an issue. |
| Turborepo | Build orchestration layer over npm/pnpm workspaces | Premature optimisation for Phase 0. Can be added if build times become problematic. |

## Consequences

### Positive consequences
- Atomic commits across backend, frontend, and shared types.
- No npm package publishing required for shared types during development.
- Single `git clone` for local development.
- Single Docker Compose file referencing all services.
- Single CI pipeline with per-workspace job scoping.

### Negative consequences / trade-offs
- All contributors have read access to all application code. Cannot restrict per-service access at repository level.
- Repository size grows as all applications expand. Build times increase without build caching.
- The Python service is managed differently (uv, not npm) — contributors must understand both toolchains.

### Neutral consequences
- `package-lock.json` is shared at the root. Lock file conflicts are possible in large teams but manageable for the current team size.

## Security Impact

Low immediate impact. A monorepo means all secrets in `.env` files must be scoped carefully — different services may need different secrets. The `.gitignore` explicitly excludes all `.env` files. No cross-service secret sharing via the repository.

If a security-sensitive module (e.g., credential signing) must be restricted in the future, it can be extracted to a private repository. This ADR should be reviewed at that point.

## Privacy Impact

Low. The monorepo does not affect data privacy directly. All privacy controls are implemented in the application code.

## Operational Impact

Simple to start. Docker Compose references all services from one `infra/docker/` directory. CI/CD must be configured to build only changed workspaces. GitHub Actions path filters or Nx affected detection can optimise this.

## Migration Impact

Migrating from monorepo to polyrepo requires splitting the repository, setting up npm package publishing for shared types, and updating all import paths. This is a significant but manageable migration if ever required.

## Review Conditions

- Review if the repository exceeds 5 active concurrent contributors and permission scoping becomes a concern.
- Review if build times exceed 10 minutes in CI without a build-caching solution in place.
- Review if a security incident requires restricting access to a specific module.
