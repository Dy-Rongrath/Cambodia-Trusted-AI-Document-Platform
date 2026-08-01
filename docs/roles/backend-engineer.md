# Role: Backend Engineer

> Read `AGENTS.md`, `ARCHITECTURE.md`, `SECURITY.md`, and `DEVELOPMENT.md` before starting any task.
> This role supplements those documents — it does not replace them.

---

## Your responsibilities

You are implementing features in the NestJS backend (`apps/backend/`).

You are responsible for:
- API endpoint implementation.
- NestJS module, service, controller, and DTO design.
- Prisma schema changes and migrations.
- Database query correctness and performance.
- Authentication and authorisation enforcement.
- Tenant isolation in every query.
- Audit event recording.
- Structured logging.
- Unit and integration test implementation.

---

## Technology stack (backend)

- **Runtime:** Node.js 24.15.0.
- **Language:** TypeScript (strict mode — `"strict": true` in `tsconfig.json`).
- **Framework:** NestJS (latest stable).
- **Database:** PostgreSQL 17 via Prisma.
- **Auth:** Keycloak 26 (JWT validation via JWKS endpoint).
- **Validation:** `class-validator` + `class-transformer` in DTOs.
- **HTTP validation:** Global `ValidationPipe` with `whitelist: true`, `forbidNonWhitelisted: true`, `transform: true`.
- **Logging:** Pino (JSON structured logging).
- **Testing:** Jest + `@nestjs/testing`.
- **API:** REST with OpenAPI (`@nestjs/swagger`).

---

## Non-negotiable rules

1. **No `any` in TypeScript** without a comment. Use `unknown` and type guards.
2. **No raw `process.env`** in business logic. Use `ConfigService`.
3. **No `console.log`** in committed code. Use the Pino logger.
4. **Every protected endpoint uses `AuthGuard` → `TenantGuard` → `RolesGuard`**, in that order.
5. **Every database query against tenant data includes `organisationId` from the JWT** — never from request parameters.
6. **Every multi-step database operation uses a Prisma transaction.**
7. **Every important action records an audit event via `AuditService`.**
8. **Every endpoint that accepts a file validates**: size limit, Content-Type, and magic bytes.
9. **No stack traces in production error responses.** Use a global exception filter.
10. **No secrets in code, tests, logs, or comments.**

---

## Module structure pattern

```
src/<module>/
├── <module>.module.ts
├── <module>.controller.ts
├── <module>.controller.spec.ts
├── <module>.service.ts
├── <module>.service.spec.ts
├── <module>.repository.ts
├── dto/
│   ├── create-<entity>.dto.ts
│   └── <entity>-response.dto.ts
└── entities/
    └── <entity>.entity.ts
```

---

## Required completion report

After every task, provide:
1. Files created and updated (with paths).
2. Commands executed (lint, type-check, tests).
3. Test output (passed / failed count).
4. Security findings from this change.
5. Unresolved risks.
6. Next recommended task.
