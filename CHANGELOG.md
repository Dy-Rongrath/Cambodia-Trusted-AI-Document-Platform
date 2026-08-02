# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/2.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

The project is currently in **pre-release development**. `0.x` versions represent pre-release development iterations and may contain breaking changes. The `1.0.0` release will represent the first supported, production-ready contract after Phase 16 completion.

---

## [Unreleased]

### Added

- **PrismaModule (Phase 1 stub):** Added `apps/backend/src/prisma/prisma.module.ts`, `prisma.service.ts`, and `prisma.service.spec.ts`. Global `PrismaService` extends `PrismaClient` with the `PrismaPg` driver-adapter pattern (consistent with `DatabaseHealthService`) and implements `OnModuleInit`/`OnModuleDestroy` for clean lifecycle management. Phase 3 business modules inject this service instead of constructing their own clients.
- **DEVELOPMENT.md §18 — CHANGELOG Update Policy:** Documented the mandatory CHANGELOG update requirement for all user-visible PRs, Keep a Changelog categories, and the release rename procedure.
- **DEVELOPMENT.md — macOS `timeout` prerequisite:** Added `brew install coreutils` row to the Required Host Machine Tooling table and a callout note explaining the dependency for `./scripts/docker/keycloak.sh`.
- **NestJS Phase 3 hardening stubs:** Added commented-out `ValidationPipe`, Helmet, CORS, and `setGlobalPrefix` stubs in `apps/backend/src/main.ts` with `TODO (Phase 3)` markers and a structured log line at startup.

### Changed

- **`DEVELOPMENT.md` — Cloud SQL section:** Updated to describe the new `stop` (suspend) vs `down` (destroy) action distinction and documented that `start` also activates the `web` profile for Caddy.
- **`apps/backend/src/app.module.ts`:** Registered `PrismaModule` in `AppModule` imports so the global `PrismaService` is available application-wide.
- **`apps/backend/prisma/schema.prisma`:** Added comment explaining why the `datasource db` block has no `url` field (driver-adapter pattern reads `DATABASE_URL` in application code).
- **`.env.cloud-sql.example`:** Replaced the misleading "TLS is required by project policy" comment with a full explanation of why `sslmode=disable` is intentional and safe for the Cloud SQL Auth Proxy hop.
- **`scripts/docker/cloud-sql.sh`:** `start` now also brings up Caddy via `--profile web` (consistent with the deploy workflow). `stop` now suspends containers without destroying them. New `down` action performs the full teardown. Usage string updated.
- **`scripts/docker/stop.sh`:** Added `--profile web` to tear down Caddy alongside Keycloak when `stop.sh` is run.
- **`scripts/docker/reset.sh`:** Added `--profile web` so `caddy_data` and `caddy_config` named volumes are removed during a full reset.
- **`scripts/docker/db-check.sh`:** Clarified startup echo to indicate only `postgres` and `backend` are started (partial stack).
- **`scripts/docker/npm.sh`:** Added a block comment explaining the anonymous `node_modules` volume pattern.

### Fixed

- **`infra/docker/compose.yaml` — Caddyfile volume path:** Corrected `./infra/docker/Caddyfile` to `./Caddyfile`. The path previously double-resolved to the non-existent path `infra/docker/infra/docker/Caddyfile` when `docker compose config` expanded it (confirmed via `docker compose --profile web config`).
- **`scripts/docker/runtime-smoke.sh` — dead Trivy `--output` flag:** Removed `--format json --output /tmp/trivy-results.json` from the first Trivy `docker run`. The file was written inside the ephemeral container and silently discarded on exit.
- **`scripts/docker/format.sh` — explicit `.prettierignore` path:** Added `--ignore-path /workspace/.prettierignore` to the Prettier invocation so exclusions are honoured regardless of working directory.
- **`scripts/docker/keycloak.sh` — silent timeout:** Added an `|| { … }` failure handler that prints Keycloak container logs and exits non-zero when the 120-second health timeout expires (mirrors CI diagnostic pattern).

### Security

- **`deploy-dev.yml` — GCP GitHub Actions SHA pinning:** Pinned `google-github-actions/auth@v3.0.0` → `@7c6bc770dae815cd3e89ee6cdf493a5fab2cc093` and `setup-gcloud@v3.0.1` → `@aa5489c8933f4cc7a4f7d45035b3b1440c9c10db`. Mutable version tags on actions with `id-token:write` permission are a supply-chain risk.

### Added

- **Phase 1 Engineering Scaffold & Tooling:** Scaffolding NestJS backend (`apps/backend`), FastAPI AI service (`apps/ai-service`), standalone Angular frontend (`apps/frontend`), shared TypeScript types (`packages/shared-types`), root npm workspaces, multi-stage Dockerfiles, local Docker Compose environment (`compose.yaml`), POSIX helper scripts (`scripts/docker/`), and Docker-based GitHub Actions CI pipeline (`.github/workflows/ci.yml`).
- **Prisma & Database Connectivity:** Initialized Prisma in NestJS backend with postgresql provider and `SELECT 1` connectivity script (`npm run db:check`).
- **Dependency Inventory:** Created [docs/dependency-inventory.md](docs/dependency-inventory.md) auditing Node, Python, and container image dependencies, licenses, and ARM64 compatibility.
- **Phase 0 Documentation & Governance Foundation:** Complete initial foundation documents ([AGENTS.md](AGENTS.md), [PROJECT_CONTEXT.md](PROJECT_CONTEXT.md), [ARCHITECTURE.md](ARCHITECTURE.md), [SECURITY.md](SECURITY.md), [MCP_SECURITY.md](MCP_SECURITY.md), [DEVELOPMENT.md](DEVELOPMENT.md), [TESTING.md](TESTING.md), [DATA_GOVERNANCE.md](DATA_GOVERNANCE.md), [AI_GOVERNANCE.md](AI_GOVERNANCE.md), [ROADMAP.md](ROADMAP.md)).
- **Architecture Decision Records:** Established ADR-0001 through ADR-0007 (foundational stack & MCP strategy) and proposed [ADR-0008](docs/adr/ADR-0008-local-object-storage-strategy.md) for local object storage evaluation.
- **Open-Source Legal Foundation:** Adopted official [Apache License 2.0](LICENSE) for software and documentation, created [NOTICE](NOTICE) for project copyright, and established [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) for third-party standard text attributions.
- **Developer Certificate of Origin (DCO):** Added official [DCO.md](DCO.md) with verbatim Developer Certificate of Origin 1.1 text and established `git commit -s` sign-off policy for contributions.
- **Community Governance & Health:** Established [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) (Contributor Covenant v3.0), [GOVERNANCE.md](GOVERNANCE.md), [SUPPORT.md](SUPPORT.md), and [docs/open-source-dependency-policy.md](docs/open-source-dependency-policy.md).
- **GitHub Community Templates:** Created structured issue forms ([.github/ISSUE_TEMPLATE/](.github/ISSUE_TEMPLATE/)), issue chooser config, and pull request template ([.github/PULL_REQUEST_TEMPLATE.md](.github/PULL_REQUEST_TEMPLATE.md)).
- **Documented Security Reporting Workflow:** Documented a private vulnerability-reporting workflow in [SECURITY.md](SECURITY.md). Enabled GitHub Private Vulnerability Reporting at repository level.
