# Dependency and Container Image Inventory — Phase 1

> **Status:** Active baseline document for Phase 1.
> **Last updated:** 2026-08-02

---

## 1. Overview

This document records the exact version, license, security status, and ARM64 compatibility of all direct dependencies and Docker base images introduced during **Phase 1 — Engineering Scaffold and Tooling**.

All dependencies adhere to [docs/open-source-dependency-policy.md](docs/open-source-dependency-policy.md).

For the full security audit findings and classification, see [docs/security/phase-1-dependency-audit.md](security/phase-1-dependency-audit.md).

---

## 2. Base Docker Images

| Image                                         | Version / Tag           | Application / Layer                  | License            | Maintenance | ARM64 Support          | Phase 1 Justification                                                                          |
| --------------------------------------------- | ----------------------- | ------------------------------------ | ------------------ | ----------- | ---------------------- | ---------------------------------------------------------------------------------------------- |
| `node`                                        | `24.15.0-alpine3.22`    | Backend / Frontend build stage       | MIT / Alpine BSD   | Active LTS  | Native (`linux/arm64`) | Exact Node.js 24.15.0 LTS runtime base image                                                   |
| `python`                                      | `3.12.9-slim-bookworm`  | AI Service base image                | PSF / Debian       | Active      | Native (`linux/arm64`) | Python 3.12 target runtime for FastAPI                                                         |
| `ghcr.io/astral-sh/uv`                        | `0.12.1`                | AI Service dependency manager        | Apache-2.0 / MIT   | Active      | Native (`linux/arm64`) | Pinned uv binary copied into the Python runtime image                                          |
| `nginx`                                       | `1.27.5-alpine`         | Frontend runtime stage               | BSD-2-Clause       | Active      | Native (`linux/arm64`) | Lightweight static asset web server                                                            |
| `postgres`                                    | `17.4-alpine`           | Database infrastructure service      | PostgreSQL License | Active      | Native (`linux/arm64`) | Primary relational database engine                                                             |
| `quay.io/keycloak/keycloak`                   | `26.1.3`                | Identity infrastructure service      | Apache-2.0         | Active      | Native (`linux/arm64`) | OAuth 2.1 / OIDC identity provider container                                                   |
| `gcr.io/cloud-sql-connectors/cloud-sql-proxy` | `2.23.0`                | Optional Cloud SQL development proxy | Apache-2.0         | Active      | Native (`linux/arm64`) | IAM-authorized TLS tunnel to a development Cloud SQL instance                                  |
| `aquasec/trivy`                               | `0.72.0` + index digest | CI runtime-image vulnerability scan  | Apache-2.0         | Active      | Native (`linux/arm64`) | Pinned, development-only scanner; see the [review](security/trivy-container-scanner-review.md) |

> [!NOTE]
> Image digest pinning (SHA256 multi-platform index digests) is deferred pending `docker manifest inspect`
> verification in the local Docker environment. Tags above are exact human-readable pins; digest annotation
> is a planned hardening step before Phase 1 is marked complete.

---

## 3. Node.js & TypeScript Direct Dependencies

### Workspace Root (`package.json`)

| Package                  | Version  | Workspace | Purpose                            | Official Source | License    | Type | Maintenance | Security Audit                                                          | ARM64  | Phase 1 Justification                                          |
| ------------------------ | -------- | --------- | ---------------------------------- | --------------- | ---------- | ---- | ----------- | ----------------------------------------------------------------------- | ------ | -------------------------------------------------------------- |
| `eslint`                 | `10.8.0` | Root      | Code linting engine                | npm registry    | MIT        | Dev  | Active      | See [phase-1-dependency-audit.md](security/phase-1-dependency-audit.md) | Native | Code quality enforcement                                       |
| `@eslint/js`             | `10.0.1` | Root      | ESLint core JS rules               | npm registry    | MIT        | Dev  | Active      | See audit                                                               | Native | Standard JavaScript rule configs                               |
| `typescript-eslint`      | `8.65.0` | Root      | TypeScript parser for ESLint       | npm registry    | MIT        | Dev  | Active      | See audit                                                               | Native | TypeScript strict linting rules                                |
| `eslint-config-prettier` | `10.1.8` | Root      | Disable formatting rules in ESLint | npm registry    | MIT        | Dev  | Active      | See audit                                                               | Native | ESLint & Prettier compatibility                                |
| `prettier`               | `3.9.6`  | Root      | Code formatting engine             | npm registry    | MIT        | Dev  | Active      | See audit                                                               | Native | Monorepo code formatting                                       |
| `typescript`             | `6.0.3`  | Root      | TypeScript compiler                | npm registry    | Apache-2.0 | Dev  | Active      | See audit                                                               | Native | Latest release supported by Angular 22 and typescript-eslint 8 |

### Backend (`apps/backend/package.json`)

| Package                    | Version   | Workspace      | Purpose                                | Official Source | License    | Type    | Maintenance | Security Audit | ARM64  | Phase 1 Justification                           |
| -------------------------- | --------- | -------------- | -------------------------------------- | --------------- | ---------- | ------- | ----------- | -------------- | ------ | ----------------------------------------------- |
| `@nestjs/core`             | `11.1.28` | `apps/backend` | NestJS framework core                  | npm registry    | MIT        | Runtime | Active      | See audit      | Native | Backend web framework                           |
| `@nestjs/common`           | `11.1.28` | `apps/backend` | NestJS utilities and decorators        | npm registry    | MIT        | Runtime | Active      | See audit      | Native | Framework decorators                            |
| `@nestjs/platform-express` | `11.1.28` | `apps/backend` | HTTP server engine                     | npm registry    | MIT        | Runtime | Active      | See audit      | Native | HTTP request processing                         |
| `@prisma/client`           | `7.9.1`   | `apps/backend` | Database query client                  | npm registry    | Apache-2.0 | Runtime | Active      | See audit      | Native | Prisma database client                          |
| `@prisma/adapter-pg`       | `7.9.1`   | `apps/backend` | Prisma PostgreSQL driver adapter       | npm registry    | Apache-2.0 | Runtime | Active      | See audit      | Native | Mandatory direct database adapter for Prisma 7  |
| `pg`                       | `8.22.0`  | `apps/backend` | PostgreSQL driver                      | npm registry    | MIT        | Runtime | Active      | See audit      | Native | Database transport used by the Prisma 7 adapter |
| `reflect-metadata`         | `0.2.2`   | `apps/backend` | TypeScript decorator reflection        | npm registry    | Apache-2.0 | Runtime | Active      | See audit      | Native | Required for NestJS metadata                    |
| `rxjs`                     | `7.8.2`   | `apps/backend` | Reactive extensions library            | npm registry    | Apache-2.0 | Runtime | Active      | See audit      | Native | NestJS internal event streams                   |
| `@nestjs/cli`              | `11.0.24` | `apps/backend` | NestJS build & dev tooling             | npm registry    | MIT        | Dev     | Active      | See audit      | Native | Application compilation and dev mode            |
| `@nestjs/schematics`       | `11.1.0`  | `apps/backend` | NestJS code generators                 | npm registry    | MIT        | Dev     | Active      | See audit      | Native | Code generation support                         |
| `@nestjs/testing`          | `11.1.28` | `apps/backend` | NestJS testing utilities               | npm registry    | MIT        | Dev     | Active      | See audit      | Native | Framework test utilities                        |
| `@types/express`           | `5.0.6`   | `apps/backend` | TypeScript types for Express           | npm registry    | MIT        | Dev     | Active      | See audit      | Native | Express typing                                  |
| `@types/jest`              | `30.0.0`  | `apps/backend` | TypeScript types for Jest              | npm registry    | MIT        | Dev     | Active      | See audit      | Native | Jest typing                                     |
| `@types/node`              | `26.1.2`  | `apps/backend` | TypeScript types for Node.js           | npm registry    | MIT        | Dev     | Active      | See audit      | Native | Node runtime typing                             |
| `@types/pg`                | `8.20.3`  | `apps/backend` | TypeScript types for PostgreSQL driver | npm registry    | MIT        | Dev     | Active      | See audit      | Native | PostgreSQL adapter typing                       |
| `jest`                     | `30.4.2`  | `apps/backend` | Unit test runner                       | npm registry    | MIT        | Dev     | Active      | See audit      | Native | Unit testing engine                             |
| `prisma`                   | `7.9.1`   | `apps/backend` | Prisma ORM CLI engine                  | npm registry    | Apache-2.0 | Dev     | Active      | See audit      | Native | Database client generation and schema tooling   |
| `ts-jest`                  | `29.4.12` | `apps/backend` | TypeScript preprocessor for Jest       | npm registry    | MIT        | Dev     | Active      | See audit      | Native | TypeScript unit testing                         |
| `ts-node`                  | `10.9.2`  | `apps/backend` | Direct TypeScript execution            | npm registry    | MIT        | Dev     | Active      | See audit      | Native | Running db-check script                         |
| `typescript`               | `6.0.3`   | `apps/backend` | TypeScript compiler                    | npm registry    | Apache-2.0 | Dev     | Active      | See audit      | Native | Local workspace compilation                     |

### Frontend (`apps/frontend/package.json`)

Angular is upgraded to 22.1.x and remains on the repository's Node.js 24 runtime line.
TypeScript 6.0.3 is the newest version satisfying Angular 22's `>=6.0 <6.1` peer range.
The Angular unit-test builder uses Vitest 4 with jsdom 30.

| Package                     | Version   | Workspace       | Purpose                             | Official Source | License         | Type    | Maintenance | Security Audit | ARM64  | Phase 1 Justification                            |
| --------------------------- | --------- | --------------- | ----------------------------------- | --------------- | --------------- | ------- | ----------- | -------------- | ------ | ------------------------------------------------ |
| `@angular/animations`       | `22.1.0`  | `apps/frontend` | Angular animations library          | npm registry    | MIT             | Runtime | Active      | See audit      | Native | UI transition animations                         |
| `@angular/common`           | `22.1.0`  | `apps/frontend` | Common Angular directives           | npm registry    | MIT             | Runtime | Active      | See audit      | Native | UI templates & formatting                        |
| `@angular/compiler`         | `22.1.0`  | `apps/frontend` | Angular template compiler           | npm registry    | MIT             | Runtime | Active      | See audit      | Native | Template compilation                             |
| `@angular/core`             | `22.1.0`  | `apps/frontend` | Angular core framework              | npm registry    | MIT             | Runtime | Active      | See audit      | Native | Frontend web framework                           |
| `@angular/forms`            | `22.1.0`  | `apps/frontend` | Angular forms module                | npm registry    | MIT             | Runtime | Active      | See audit      | Native | Form handling primitives                         |
| `@angular/platform-browser` | `22.1.0`  | `apps/frontend` | DOM rendering platform              | npm registry    | MIT             | Runtime | Active      | See audit      | Native | Web browser bootstrap                            |
| `@angular/router`           | `22.1.0`  | `apps/frontend` | Client-side SPA router              | npm registry    | MIT             | Runtime | Active      | See audit      | Native | Routing enablement                               |
| `rxjs`                      | `7.8.2`   | `apps/frontend` | Reactive extensions library         | npm registry    | Apache-2.0      | Runtime | Active      | See audit      | Native | Angular async streams                            |
| `tslib`                     | `2.8.1`   | `apps/frontend` | TypeScript helper library           | npm registry    | BSD-Zero-Clause | Runtime | Active      | See audit      | Native | Compiled TypeScript helpers                      |
| `zone.js`                   | `0.16.2`  | `apps/frontend` | Angular change detection            | npm registry    | MIT             | Runtime | Active      | See audit      | Native | Change detection tracking                        |
| `@angular/build`            | `22.1.2`  | `apps/frontend` | Angular build system (esbuild/Vite) | npm registry    | MIT             | Dev     | Active      | See audit      | Native | Application builder + unit-test builder (Vitest) |
| `@angular/cli`              | `22.1.2`  | `apps/frontend` | Angular build CLI                   | npm registry    | MIT             | Dev     | Active      | See audit      | Native | Project CLI dev tool                             |
| `@angular/compiler-cli`     | `22.1.0`  | `apps/frontend` | Angular AOT compiler CLI            | npm registry    | MIT             | Dev     | Active      | See audit      | Native | AOT compilation                                  |
| `@types/node`               | `26.1.2`  | `apps/frontend` | TypeScript types for Node.js        | npm registry    | MIT             | Dev     | Active      | See audit      | Native | Node build typing                                |
| `@vitest/coverage-v8`       | `^4.1.10` | `apps/frontend` | Vitest V8 code coverage             | npm registry    | MIT             | Dev     | Active      | See audit      | Native | Test coverage reporting                          |
| `jsdom`                     | `^30.0.1` | `apps/frontend` | DOM emulation for Vitest            | npm registry    | MIT             | Dev     | Active      | See audit      | Native | Headless DOM for unit tests                      |
| `typescript`                | `6.0.3`   | `apps/frontend` | TypeScript compiler                 | npm registry    | Apache-2.0      | Dev     | Active      | See audit      | Native | Frontend type compilation                        |
| `vitest`                    | `^4.1.10` | `apps/frontend` | Test runner                         | npm registry    | MIT             | Dev     | Active      | See audit      | Native | No-browser unit test runner                      |

**Previously removed during the Angular build migration:** `@angular-devkit/build-angular`, `@angular/platform-browser-dynamic`,
`karma`, `karma-chrome-launcher`, `karma-coverage`, `karma-jasmine`, `karma-jasmine-html-reporter`,
`jasmine-core`, `@types/jasmine`.

### Shared Types (`packages/shared-types/package.json`)

| Package      | Version | Workspace               | Purpose             | Official Source | License    | Type | Maintenance | Security Audit | ARM64  | Phase 1 Justification    |
| ------------ | ------- | ----------------------- | ------------------- | --------------- | ---------- | ---- | ----------- | -------------- | ------ | ------------------------ |
| `typescript` | `6.0.3` | `packages/shared-types` | TypeScript compiler | npm registry    | Apache-2.0 | Dev  | Active      | See audit      | Native | Shared types compilation |

---

## 4. Python Direct Dependencies (`apps/ai-service/pyproject.toml`)

Python version constraint: `>=3.12,<3.13` (bounded, matching `.python-version` = `3.12.9`).

| Package     | Version   | Service           | Purpose                    | Official Source | License      | Type    | Maintenance | Security Audit                           | ARM64  | Phase 1 Justification             |
| ----------- | --------- | ----------------- | -------------------------- | --------------- | ------------ | ------- | ----------- | ---------------------------------------- | ------ | --------------------------------- |
| `fastapi`   | `0.141.1` | `apps/ai-service` | Web API framework          | PyPI            | MIT          | Runtime | Active      | `pip-audit`: no known CVEs at 2026-08-02 | Native | High-performance Python async API |
| `uvicorn`   | `0.52.1`  | `apps/ai-service` | ASGI web server            | PyPI            | BSD-3-Clause | Runtime | Active      | `pip-audit`: no known CVEs at 2026-08-02 | Native | Serving FastAPI application       |
| `pydantic`  | `2.13.4`  | `apps/ai-service` | Data validation & settings | PyPI            | MIT          | Runtime | Active      | `pip-audit`: no known CVEs at 2026-08-02 | Native | Request/Response model typing     |
| `pytest`    | `9.1.1`   | `apps/ai-service` | Test framework             | PyPI            | MIT          | Dev     | Active      | No known CVEs (dev only)                 | Native | Unit testing for health endpoint  |
| `httpx`     | `0.28.1`  | `apps/ai-service` | Async HTTP test client     | PyPI            | BSD-3-Clause | Dev     | Active      | No known CVEs (dev only)                 | Native | FastAPI TestClient support        |
| `ruff`      | `0.16.1`  | `apps/ai-service` | Fast linter & formatter    | PyPI            | MIT          | Dev     | Active      | No known CVEs (dev only)                 | Native | Code quality & formatting checks  |
| `mypy`      | `2.3.0`   | `apps/ai-service` | Static type checker        | PyPI            | MIT          | Dev     | Active      | No known CVEs (dev only)                 | Native | Strict type checking              |
| `hatchling` | `1.31.0`  | `apps/ai-service` | Python build backend       | PyPI            | MIT          | Build   | Active      | No known CVEs                            | Native | Reproducible package builds       |

---

## 5. Security & Licensing Compliance Summary

- **Forbidden Licences:** Zero copyleft, GPL, AGPL, source-available, custom, or unlicensed dependencies are present.
- **Secrets Check:** No API keys, credentials, tokens, or `.env` files are committed.
- **Data Minimization:** No real personal, government, or institution-specific data is included.
- **Verification Evidence:** All direct dependencies are pinned in workspace manifests and locked in `package-lock.json` and `uv.lock`.
- **npm Audit Status:** No known findings in the full or production dependency graph after the reviewed Angular CLI-scoped MCP SDK 1.30.0 security override. See [docs/security/phase-1-dependency-audit.md](security/phase-1-dependency-audit.md).
- **Python Audit Status:** No known CVEs reported by `pip-audit` at 2026-08-02 audit time.
- **Container Audit Status:** Trivy blocks fixable High/Critical findings in all three final runtime images; scanner adoption and residual risks are documented in the [Trivy review](security/trivy-container-scanner-review.md).
- **Digest Update Policy:** Image digests are strictly resolved using `docker buildx imagetools inspect` to ensure correct multi-platform index digests are pinned.

## 6. GitHub Actions

| Action | Version / SHA | Purpose |
| --- | --- | --- |
| `actions/checkout` | `8e8c483db84b4bee98b60c0593521ed34d9990e8` | Repository checkout |
| `google-github-actions/auth` | `7c6bc770dae815cd3e89ee6cdf493a5fab2cc093` | GCP Workload Identity auth |
| `google-github-actions/setup-gcloud` | `aa5489c8933f4cc7a4f7d45035b3b1440c9c10db` | gcloud CLI setup |
| `docker/setup-buildx-action` | `6524bf65af31da8d45b59e8c27de4bd072b392f5` | Docker Buildx setup |
| `docker/build-push-action` | `ca877d9245402d1537745e0e356eab47c3520991` | Docker image build & push |

> [!NOTE]
> The MCP SDK override affects Angular CLI development tooling only; it does not install, enable, or configure
> an MCP server. Re-evaluate the override when Angular CLI adopts the patched SDK directly.
