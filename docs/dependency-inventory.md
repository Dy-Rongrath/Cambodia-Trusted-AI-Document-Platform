# Dependency and Container Image Inventory — Phase 1

> **Status:** Active baseline document for Phase 1.
> **Last updated:** 2026-08-01

---

## 1. Overview

This document records the exact version, license, security status, and ARM64 compatibility of all direct dependencies and Docker base images introduced during **Phase 1 — Engineering Scaffold and Tooling**.

All dependencies adhere to [docs/open-source-dependency-policy.md](file:///Users/dyrongrath/Documents/trusted-ai-platform/docs/open-source-dependency-policy.md).

---

## 2. Base Docker Images

| Image | Version / Tag | Application / Layer | License | Maintenance | ARM64 Support | Phase 1 Justification |
| ----- | ------------- | ------------------- | ------- | ----------- | ------------- | --------------------- |
| `node` | `24.15.0-alpine3.21` | Backend / Frontend build stage | MIT / Alpine BSD | Active LTS | Native (`linux/arm64`) | Pinned Node.js 24 LTS runtime base image |
| `python` | `3.12.9-slim-bookworm` | AI Service base image | PSF / Debian | Active | Native (`linux/arm64`) | Python 3.12 target runtime for FastAPI |
| `ghcr.io/astral-sh/uv` | `0.5-python3.12-alpine` | AI Service dependency manager | Apache-2.0 / MIT | Active | Native (`linux/arm64`) | Fast Python package management inside Docker |
| `nginx` | `1.27-alpine` | Frontend runtime stage | BSD-2-Clause | Active | Native (`linux/arm64`) | Lightweight static asset web server |
| `postgres` | `17.4-alpine` | Database infrastructure service | PostgreSQL License | Active | Native (`linux/arm64`) | Primary relational database engine |
| `quay.io/keycloak/keycloak` | `26.1.3` | Identity infrastructure service | Apache-2.0 | Active | Native (`linux/arm64`) | OAuth 2.1 / OIDC identity provider container |

---

## 3. Node.js & TypeScript Direct Dependencies

### Workspace Root (`package.json`)

| Package | Version | Workspace | Purpose | Official Source | License | Type | Maintenance | Security Audit | ARM64 | Phase 1 Justification |
| ------- | ------- | --------- | ------- | --------------- | ------- | ---- | ----------- | -------------- | ----- | --------------------- |
| `eslint` | `9.20.0` | Root | Code linting engine | npm registry | MIT | Dev | Active | Passed | Native | Code quality enforcement |
| `@eslint/js` | `9.20.0` | Root | ESLint core JS rules | npm registry | MIT | Dev | Active | Passed | Native | Standard JavaScript rule configs |
| `typescript-eslint` | `8.24.0` | Root | TypeScript parser for ESLint | npm registry | MIT | Dev | Active | Passed | Native | TypeScript strict linting rules |
| `eslint-config-prettier` | `10.0.1` | Root | Disable formatting rules in ESLint | npm registry | MIT | Dev | Active | Passed | Native | ESLint & Prettier compatibility |
| `prettier` | `3.5.1` | Root | Code formatting engine | npm registry | MIT | Dev | Active | Passed | Native | Monorepo code formatting |
| `typescript` | `5.7.3` | Root | TypeScript compiler | npm registry | Apache-2.0 | Dev | Active | Passed | Native | Monorepo type checking |

### Backend (`apps/backend/package.json`)

| Package | Version | Workspace | Purpose | Official Source | License | Type | Maintenance | Security Audit | ARM64 | Phase 1 Justification |
| ------- | ------- | --------- | ------- | --------------- | ------- | ---- | ----------- | -------------- | ----- | --------------------- |
| `@nestjs/core` | `10.4.15` | `apps/backend` | NestJS framework core | npm registry | MIT | Runtime | Active | Passed | Native | Backend web framework |
| `@nestjs/common` | `10.4.15` | `apps/backend` | NestJS utilities and decorators | npm registry | MIT | Runtime | Active | Passed | Native | Framework decoratots |
| `@nestjs/platform-express` | `10.4.15` | `apps/backend` | HTTP server engine | npm registry | MIT | Runtime | Active | Passed | Native | HTTP request processing |
| `@prisma/client` | `6.3.1` | `apps/backend` | Database query client | npm registry | Apache-2.0 | Runtime | Active | Passed | Native | Prisma database client |
| `reflect-metadata` | `0.2.2` | `apps/backend` | TypeScript decorator reflection | npm registry | Apache-2.0 | Runtime | Active | Passed | Native | Required for NestJS metadata |
| `rxjs` | `7.8.1` | `apps/backend` | Reactive extensions library | npm registry | Apache-2.0 | Runtime | Active | Passed | Native | NestJS internal event streams |
| `@nestjs/cli` | `10.4.9` | `apps/backend` | NestJS build & dev tooling | npm registry | MIT | Dev | Active | Passed | Native | Application compilation and dev mode |
| `prisma` | `6.3.1` | `apps/backend` | Prisma ORM CLI engine | npm registry | Apache-2.0 | Dev | Active | Passed | Native | Database client generation |
| `ts-node` | `10.9.2` | `apps/backend` | Direct TypeScript execution | npm registry | MIT | Dev | Active | Passed | Native | Running db-check script |
| `jest` | `29.7.0` | `apps/backend` | Unit test runner | npm registry | MIT | Dev | Active | Passed | Native | Unit testing for health controller |

### Frontend (`apps/frontend/package.json`)

| Package | Version | Workspace | Purpose | Official Source | License | Type | Maintenance | Security Audit | ARM64 | Phase 1 Justification |
| ------- | ------- | --------- | ------- | --------------- | ------- | ---- | ----------- | -------------- | ----- | --------------------- |
| `@angular/core` | `19.1.8` | `apps/frontend` | Angular core framework | npm registry | MIT | Runtime | Active | Passed | Native | Frontend web framework |
| `@angular/common` | `19.1.8` | `apps/frontend` | Common Angular directives | npm registry | MIT | Runtime | Active | Passed | Native | UI templates & formatting |
| `@angular/platform-browser` | `19.1.8` | `apps/frontend` | DOM rendering platform | npm registry | MIT | Runtime | Active | Passed | Native | Web browser bootstrap |
| `@angular/router` | `19.1.8` | `apps/frontend` | Client-side SPA router | npm registry | MIT | Runtime | Active | Passed | Native | Routing enablement |
| `@angular/cli` | `19.1.8` | `apps/frontend` | Angular build CLI | npm registry | MIT | Dev | Active | Passed | Native | Compilation & asset bundling |
| `zone.js` | `0.15.0` | `apps/frontend` | Angular change detection | npm registry | MIT | Runtime | Active | Passed | Native | Required for Angular change detection |

---

## 4. Python Direct Dependencies (`apps/ai-service/pyproject.toml`)

| Package | Version | Service | Purpose | Official Source | License | Type | Maintenance | Security Audit | ARM64 | Phase 1 Justification |
| ------- | ------- | ------- | ------- | --------------- | ------- | ---- | ----------- | -------------- | ----- | --------------------- |
| `fastapi` | `0.115.8` | `apps/ai-service` | Web API framework | PyPI | MIT | Runtime | Active | Passed | Native | High-performance Python async API |
| `uvicorn` | `0.34.0` | `apps/ai-service` | ASGI web server | PyPI | BSD-3-Clause | Runtime | Active | Passed | Native | Serving FastAPI application |
| `pydantic` | `2.10.6` | `apps/ai-service` | Data validation & settings | PyPI | MIT | Runtime | Active | Passed | Native | Request/Response model typing |
| `pytest` | `8.3.4` | `apps/ai-service` | Test framework | PyPI | MIT | Dev | Active | Passed | Native | Unit testing for health endpoint |
| `httpx` | `0.28.1` | `apps/ai-service` | Async HTTP test client | PyPI | BSD-3-Clause | Dev | Active | Passed | Native | FastAPI TestClient support |
| `ruff` | `0.9.6` | `apps/ai-service` | Fast linter & formatter | PyPI | MIT | Dev | Active | Passed | Native | Code quality & formatting checks |
| `mypy` | `1.15.0` | `apps/ai-service` | Static type checker | PyPI | MIT | Dev | Active | Passed | Native | Strict type checking |

---

## 5. Security & Licensing Compliance Summary

- **Forbidden Licences:** Zero copyleft, GPL, AGPL, source-available, custom, or unlicensed dependencies are present.
- **Secrets Check:** No API keys, credentials, tokens, or `.env` files are committed.
- **Data Minimization:** No real personal, government, institution-specific, or NSSF data is included.
