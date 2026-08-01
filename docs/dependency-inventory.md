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

| Image | Version / Tag | Application / Layer | License | Maintenance | ARM64 Support | Phase 1 Justification |
| --- | --- | --- | --- | --- | --- | --- |
| `node` | `24.15.0-alpine3.22` | Backend / Frontend build stage | MIT / Alpine BSD | Active LTS | Native (`linux/arm64`) | Exact Node.js 24.15.0 LTS runtime base image |
| `python` | `3.12.9-slim-bookworm` | AI Service base image | PSF / Debian | Active | Native (`linux/arm64`) | Python 3.12 target runtime for FastAPI |
| `ghcr.io/astral-sh/uv` | `0.5-python3.12-bookworm-slim` | AI Service dependency manager | Apache-2.0 / MIT | Active | Native (`linux/arm64`) | Fast Python package management inside Docker |
| `nginx` | `1.27.5-alpine` | Frontend runtime stage | BSD-2-Clause | Active | Native (`linux/arm64`) | Lightweight static asset web server |
| `postgres` | `17.4-alpine` | Database infrastructure service | PostgreSQL License | Active | Native (`linux/arm64`) | Primary relational database engine |
| `quay.io/keycloak/keycloak` | `26.1.3` | Identity infrastructure service | Apache-2.0 | Active | Native (`linux/arm64`) | OAuth 2.1 / OIDC identity provider container |

> [!NOTE]
> Image digest pinning (SHA256 multi-platform index digests) is deferred pending `docker manifest inspect`
> verification in the local Docker environment. Tags above are exact human-readable pins; digest annotation
> is a planned hardening step before Phase 1 is marked complete.

---

## 3. Node.js & TypeScript Direct Dependencies

### Workspace Root (`package.json`)

| Package | Version | Workspace | Purpose | Official Source | License | Type | Maintenance | Security Audit | ARM64 | Phase 1 Justification |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `eslint` | `9.20.0` | Root | Code linting engine | npm registry | MIT | Dev | Active | See [phase-1-dependency-audit.md](security/phase-1-dependency-audit.md) | Native | Code quality enforcement |
| `@eslint/js` | `9.20.0` | Root | ESLint core JS rules | npm registry | MIT | Dev | Active | See audit | Native | Standard JavaScript rule configs |
| `typescript-eslint` | `8.24.0` | Root | TypeScript parser for ESLint | npm registry | MIT | Dev | Active | See audit | Native | TypeScript strict linting rules |
| `eslint-config-prettier` | `10.0.1` | Root | Disable formatting rules in ESLint | npm registry | MIT | Dev | Active | See audit | Native | ESLint & Prettier compatibility |
| `prettier` | `3.5.1` | Root | Code formatting engine | npm registry | MIT | Dev | Active | See audit | Native | Monorepo code formatting |
| `typescript` | `5.8.3` | Root | TypeScript compiler | npm registry | Apache-2.0 | Dev | Active | See audit | Native | Monorepo type checking (updated to 5.8.3 for Angular 20) |

### Backend (`apps/backend/package.json`)

| Package | Version | Workspace | Purpose | Official Source | License | Type | Maintenance | Security Audit | ARM64 | Phase 1 Justification |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `@nestjs/core` | `10.4.15` | `apps/backend` | NestJS framework core | npm registry | MIT | Runtime | Active | See audit | Native | Backend web framework |
| `@nestjs/common` | `10.4.15` | `apps/backend` | NestJS utilities and decorators | npm registry | MIT | Runtime | Active | See audit | Native | Framework decorators |
| `@nestjs/platform-express` | `10.4.15` | `apps/backend` | HTTP server engine | npm registry | MIT | Runtime | Active | See audit | Native | HTTP request processing |
| `@prisma/client` | `6.3.1` | `apps/backend` | Database query client | npm registry | Apache-2.0 | Runtime | Active | See audit | Native | Prisma database client |
| `reflect-metadata` | `0.2.2` | `apps/backend` | TypeScript decorator reflection | npm registry | Apache-2.0 | Runtime | Active | See audit | Native | Required for NestJS metadata |
| `rxjs` | `7.8.1` | `apps/backend` | Reactive extensions library | npm registry | Apache-2.0 | Runtime | Active | See audit | Native | NestJS internal event streams |
| `@nestjs/cli` | `10.4.9` | `apps/backend` | NestJS build & dev tooling | npm registry | MIT | Dev | Active | See audit | Native | Application compilation and dev mode |
| `@nestjs/schematics` | `10.2.3` | `apps/backend` | NestJS code generators | npm registry | MIT | Dev | Active | See audit | Native | Code generation support |
| `@nestjs/testing` | `10.4.15` | `apps/backend` | NestJS testing utilities | npm registry | MIT | Dev | Active | See audit | Native | Framework test utilities |
| `@types/express` | `5.0.0` | `apps/backend` | TypeScript types for Express | npm registry | MIT | Dev | Active | See audit | Native | Express typing |
| `@types/jest` | `29.5.14` | `apps/backend` | TypeScript types for Jest | npm registry | MIT | Dev | Active | See audit | Native | Jest typing |
| `@types/node` | `22.13.4` | `apps/backend` | TypeScript types for Node.js | npm registry | MIT | Dev | Active | See audit | Native | Node runtime typing |
| `jest` | `29.7.0` | `apps/backend` | Unit test runner | npm registry | MIT | Dev | Active | See audit | Native | Unit testing engine |
| `prisma` | `6.3.1` | `apps/backend` | Prisma ORM CLI engine | npm registry | Apache-2.0 | Dev | Active | See audit | Native | Database client generation (`--allow-no-models`) |
| `ts-jest` | `29.2.5` | `apps/backend` | TypeScript preprocessor for Jest | npm registry | MIT | Dev | Active | See audit | Native | TypeScript unit testing |
| `ts-node` | `10.9.2` | `apps/backend` | Direct TypeScript execution | npm registry | MIT | Dev | Active | See audit | Native | Running db-check script |
| `typescript` | `5.8.3` | `apps/backend` | TypeScript compiler | npm registry | Apache-2.0 | Dev | Active | See audit | Native | Local workspace compilation |

### Frontend (`apps/frontend/package.json`)

Angular upgraded from 19.1.8 → 20.0.5. Angular 20 officially supports Node.js `^24.0.0`.
TypeScript upgraded 5.7.3 → 5.8.3 (Angular 20 requires `>=5.8 <5.9`).
Karma and `@angular-devkit/build-angular` removed; `@angular/build` + Vitest replace them.

| Package | Version | Workspace | Purpose | Official Source | License | Type | Maintenance | Security Audit | ARM64 | Phase 1 Justification |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `@angular/animations` | `20.0.5` | `apps/frontend` | Angular animations library | npm registry | MIT | Runtime | Active | See audit | Native | UI transition animations |
| `@angular/common` | `20.0.5` | `apps/frontend` | Common Angular directives | npm registry | MIT | Runtime | Active | See audit | Native | UI templates & formatting |
| `@angular/compiler` | `20.0.5` | `apps/frontend` | Angular template compiler | npm registry | MIT | Runtime | Active | See audit | Native | Template compilation |
| `@angular/core` | `20.0.5` | `apps/frontend` | Angular core framework | npm registry | MIT | Runtime | Active | See audit | Native | Frontend web framework (Node.js 24 compatible) |
| `@angular/forms` | `20.0.5` | `apps/frontend` | Angular forms module | npm registry | MIT | Runtime | Active | See audit | Native | Form handling primitives |
| `@angular/platform-browser` | `20.0.5` | `apps/frontend` | DOM rendering platform | npm registry | MIT | Runtime | Active | See audit | Native | Web browser bootstrap |
| `@angular/router` | `20.0.5` | `apps/frontend` | Client-side SPA router | npm registry | MIT | Runtime | Active | See audit | Native | Routing enablement |
| `rxjs` | `7.8.2` | `apps/frontend` | Reactive extensions library | npm registry | Apache-2.0 | Runtime | Active | See audit | Native | Angular async streams |
| `tslib` | `2.8.1` | `apps/frontend` | TypeScript helper library | npm registry | BSD-Zero-Clause | Runtime | Active | See audit | Native | Compiled TypeScript helpers |
| `zone.js` | `0.15.0` | `apps/frontend` | Angular change detection | npm registry | MIT | Runtime | Active | See audit | Native | Change detection tracking |
| `@angular/build` | `20.0.5` | `apps/frontend` | Angular 20 build system (esbuild/Vite) | npm registry | MIT | Dev | Active | See audit | Native | Application builder + unit-test builder (Vitest) |
| `@angular/cli` | `20.0.5` | `apps/frontend` | Angular build CLI | npm registry | MIT | Dev | Active | See audit | Native | Project CLI dev tool |
| `@angular/compiler-cli` | `20.0.5` | `apps/frontend` | Angular AOT compiler CLI | npm registry | MIT | Dev | Active | See audit | Native | AOT compilation |
| `@types/node` | `22.15.29` | `apps/frontend` | TypeScript types for Node.js | npm registry | MIT | Dev | Active | See audit | Native | Node build typing |
| `@vitest/coverage-v8` | `^2.2.0` | `apps/frontend` | Vitest V8 code coverage | npm registry | MIT | Dev | Active | See audit | Native | Test coverage reporting |
| `jsdom` | `^25.0.1` | `apps/frontend` | DOM emulation for Vitest | npm registry | MIT | Dev | Active | See audit | Native | Headless DOM for unit tests |
| `typescript` | `5.8.3` | `apps/frontend` | TypeScript compiler | npm registry | Apache-2.0 | Dev | Active | See audit | Native | Frontend type compilation |
| `vitest` | `^2.2.0` | `apps/frontend` | Test runner (replaces Karma) | npm registry | MIT | Dev | Active | See audit | Native | No-browser unit test runner |

**Removed in Angular 20 migration:** `@angular-devkit/build-angular`, `@angular/platform-browser-dynamic`,
`karma`, `karma-chrome-launcher`, `karma-coverage`, `karma-jasmine`, `karma-jasmine-html-reporter`,
`jasmine-core`, `@types/jasmine`.

### Shared Types (`packages/shared-types/package.json`)

| Package | Version | Workspace | Purpose | Official Source | License | Type | Maintenance | Security Audit | ARM64 | Phase 1 Justification |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `typescript` | `5.8.3` | `packages/shared-types` | TypeScript compiler | npm registry | Apache-2.0 | Dev | Active | See audit | Native | Shared types compilation |

---

## 4. Python Direct Dependencies (`apps/ai-service/pyproject.toml`)

Python version constraint: `>=3.12,<3.13` (bounded, matching `.python-version` = `3.12.9`).

| Package | Version | Service | Purpose | Official Source | License | Type | Maintenance | Security Audit | ARM64 | Phase 1 Justification |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `fastapi` | `0.115.8` | `apps/ai-service` | Web API framework | PyPI | MIT | Runtime | Active | `pip-audit`: no known CVEs at 2026-08-02 | Native | High-performance Python async API |
| `uvicorn` | `0.34.0` | `apps/ai-service` | ASGI web server | PyPI | BSD-3-Clause | Runtime | Active | `pip-audit`: no known CVEs at 2026-08-02 | Native | Serving FastAPI application |
| `pydantic` | `2.10.6` | `apps/ai-service` | Data validation & settings | PyPI | MIT | Runtime | Active | `pip-audit`: no known CVEs at 2026-08-02 | Native | Request/Response model typing |
| `pytest` | `8.3.4` | `apps/ai-service` | Test framework | PyPI | MIT | Dev | Active | No known CVEs (dev only) | Native | Unit testing for health endpoint |
| `httpx` | `0.28.1` | `apps/ai-service` | Async HTTP test client | PyPI | BSD-3-Clause | Dev | Active | No known CVEs (dev only) | Native | FastAPI TestClient support |
| `ruff` | `0.9.6` | `apps/ai-service` | Fast linter & formatter | PyPI | MIT | Dev | Active | No known CVEs (dev only) | Native | Code quality & formatting checks |
| `mypy` | `1.15.0` | `apps/ai-service` | Static type checker | PyPI | MIT | Dev | Active | No known CVEs (dev only) | Native | Strict type checking |

---

## 5. Security & Licensing Compliance Summary

- **Forbidden Licences:** Zero copyleft, GPL, AGPL, source-available, custom, or unlicensed dependencies are present.
- **Secrets Check:** No API keys, credentials, tokens, or `.env` files are committed.
- **Data Minimization:** No real personal, government, or institution-specific data is included.
- **Verification Evidence:** All direct dependencies are pinned in workspace manifests and locked in `package-lock.json` and `uv.lock`.
- **npm Audit Status:** 57 findings reported against Angular 19 lockfile (pre-migration). Post-Angular-20 re-audit pending. See [docs/security/phase-1-dependency-audit.md](security/phase-1-dependency-audit.md).
- **Python Audit Status:** No known CVEs reported by `pip-audit` at 2026-08-02 audit time.

> [!WARNING]
> Do not claim this document constitutes a passed security review while the post-Angular-20 npm re-audit
> is pending. See the security audit document for full classification and acceptance criteria.
