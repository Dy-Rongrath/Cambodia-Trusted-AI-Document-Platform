> **Phase Status:** Phase 1 — Engineering Scaffold and Tooling: In Progress (Local implementation complete — remote CI pending)
> **Next Phase:** Phase 2 — Development MCP Adoption

---

## 1. Local Setup (Docker-First Workflow)

The developer environment is **Docker-first**. Language runtimes (Node.js 24, Python 3.12, PostgreSQL 17, Keycloak 26) and generator CLIs run entirely inside Docker containers.

### Required Host Machine Tooling

| Tool               | Version                                  | Install link                                    | Required on Host |
| ------------------ | ---------------------------------------- | ----------------------------------------------- | ---------------- |
| **Docker Desktop** | Latest (Docker Engine 29+ / Compose v5+) | https://www.docker.com/products/docker-desktop/ | **Yes**          |
| **Git**            | Recent                                   | https://git-scm.com/                            | **Yes**          |
| **Codex CLI**      | Pinned config                            | OpenAI Codex CLI (when using AI assistance)     | Optional         |

> **Note:** Node.js, npm, Python, `uv`, NestJS CLI, Angular CLI, and Prisma CLI are **not required on the host**. Host-installed runtimes are documented only as an optional advanced fallback.

---

### Primary Developer Workflow (Docker-Only Scripts)

```bash
# 1. Clone the repository
git clone git@github.com:Dy-Rongrath/Cambodia-Trusted-AI-Document-Platform.git
cd Cambodia-Trusted-AI-Document-Platform

# 2. Copy environment template
cp .env.example .env

# 3. Build container stack
./scripts/docker/build.sh

# 4. Start default services (postgres, backend, ai-service, frontend)
./scripts/docker/start.sh

# 5. Live development watch mode
./scripts/docker/watch.sh

# 6. Run quality gates (lint, typecheck, unit tests)
./scripts/docker/lint.sh
./scripts/docker/typecheck.sh
./scripts/docker/test.sh

# 7. Check database connectivity
./scripts/docker/db-check.sh

# 8. (Optional) Keycloak auth profile management
./scripts/docker/keycloak.sh start
./scripts/docker/keycloak.sh stop

# 9. Stop stack
./scripts/docker/stop.sh
```

---

## 2. Supported Runtime Versions

| Runtime    | Required version         | How to pin                                             |
| ---------- | ------------------------ | ------------------------------------------------------ |
| Node.js    | 24.15.0                  | `.nvmrc` in repository root                            |
| Python     | 3.12.x (latest patch)    | `pyenv local` in `apps/ai-service/`                    |
| npm        | 11.x (bundled with Node) | —                                                      |
| uv         | Latest stable            | Installed globally via the Astral install script       |
| PostgreSQL | 17 (Docker image)        | `postgres:17-alpine` in `docker-compose.yml`           |
| Keycloak   | 26 (Docker image)        | `quay.io/keycloak/keycloak:26` in `docker-compose.yml` |

**Caution:** The macOS system Python (`/usr/bin/python3`) is Apple's Xcode Python (3.9, EOL). Never use it for project code. Always use the Python installed by pyenv.

---

## 3. Package Management Rules

### Node.js (npm workspaces)

- Run all npm commands from the **repository root** unless working on a specific workspace.
- To add a dependency to a specific workspace:
  ```bash
  npm install <package> --workspace=apps/backend
  ```
- To add a dev dependency:
  ```bash
  npm install -D <package> --workspace=apps/backend
  ```
- Always commit the updated `package-lock.json`.
- **Do not add dependencies without reviewing licence, maintenance status, and known CVEs.**

### Python (uv)

- Always work inside `apps/ai-service/` for Python operations.
- To add a dependency:
  ```bash
  cd apps/ai-service
  uv add <package>
  ```
- To add a dev dependency:
  ```bash
  uv add --dev <package>
  ```
- Always commit the updated `uv.lock`.
- Run `uv sync` after pulling changes that update `uv.lock`.

### Dependency approval

Adding a new dependency requires:

1. Confirming no existing dependency provides the capability.
2. Checking the licence (MIT, Apache 2.0, or BSD preferred).
3. Checking the package's maintenance status.
4. Running `npm audit` or `uv audit` after adding.
5. Documenting the reason in the pull-request description.

---

## 4. Branching Strategy

We use a **trunk-based development** approach with short-lived feature branches.

| Branch                  | Purpose                                                                    | Protected?                   |
| ----------------------- | -------------------------------------------------------------------------- | ---------------------------- |
| `main`                  | Production-ready code. Always releasable.                                  | Yes — requires PR and review |
| `feature/<description>` | Feature development. Short-lived (≤ 5 days).                               | No                           |
| `fix/<description>`     | Bug fixes. Short-lived.                                                    | No                           |
| `hotfix/<description>`  | Emergency production fixes. Merged to main directly with expedited review. | No                           |
| `docs/<description>`    | Documentation-only changes.                                                | No                           |
| `chore/<description>`   | Non-functional changes (dependency updates, tooling).                      | No                           |

**Rules:**

- Feature branches are created from `main`.
- Feature branches are merged to `main` via pull request.
- Pull requests require at least one review (from yourself using a second account is not acceptable — get a genuine review when the team grows).
- Direct pushes to `main` are prohibited.
- Feature branches should be deleted after merging.

---

## 5. Commit Message Convention

We use **Conventional Commits** (https://www.conventionalcommits.org/).

Format:

```
<type>(<scope>): <short summary>

[optional body]

[optional footer: BREAKING CHANGE, Closes #issue]
```

### Types

| Type       | When to use                               |
| ---------- | ----------------------------------------- |
| `feat`     | A new feature                             |
| `fix`      | A bug fix                                 |
| `docs`     | Documentation changes only                |
| `style`    | Formatting, whitespace — no logic changes |
| `refactor` | Code restructuring — no feature or fix    |
| `test`     | Adding or updating tests                  |
| `chore`    | Maintenance — dependency updates, tooling |
| `ci`       | CI/CD configuration changes               |
| `security` | Security fix or control improvement       |
| `perf`     | Performance improvement                   |

### Scopes

| Scope            | Module                        |
| ---------------- | ----------------------------- |
| `backend`        | NestJS backend                |
| `ai-service`     | Python FastAPI AI service     |
| `frontend`       | Angular frontend              |
| `shared-types`   | Shared TypeScript types       |
| `infra`          | Docker, CI/CD, infrastructure |
| `docs`           | Documentation                 |
| `auth`           | Authentication module         |
| `document`       | Document module               |
| `classification` | Classification module         |
| `review`         | Human review module           |
| `audit`          | Audit log module              |

### Examples

```
feat(document): add file magic byte validation on upload
fix(auth): correct JWT audience claim validation
security(upload): enforce file size limit before buffer read
docs(architecture): add AI training flow diagram
chore(deps): update prisma to 6.2.1
```

---

## 6. TypeScript Coding Standards

### Configuration

All TypeScript projects use strict mode. Minimum `tsconfig.json` settings:

```json
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "exactOptionalPropertyTypes": true,
    "noFallthroughCasesInSwitch": true,
    "noUncheckedIndexedAccess": true
  }
}
```

### Rules

- **No `any`** without a comment explaining why. Use `unknown` and type guards instead.
- **No `@ts-ignore` or `@ts-nocheck`** without an explanatory comment and a linked issue.
- **Use `readonly`** for object properties and array parameters that should not be mutated.
- **Prefer `const`** over `let`. Never use `var`.
- **Use discriminated unions** instead of boolean flags for multi-state logic.
- **Explicit return types** on all exported functions and class methods.
- **Use `Result<T, E>` pattern or typed exceptions** — never return `null` to indicate failure.
- **No silent exception swallowing.** Always log and re-throw or convert to a typed error.
- **No `console.log` in committed code.** Use the structured logger.

### NestJS-specific

- Use DTOs for all request and response bodies.
- Use `class-validator` decorators on DTOs for input validation.
- Use `class-transformer` for request body transformation.
- Apply `ValidationPipe` globally with `transform: true` and `whitelist: true`.
- Use Guards for authentication and authorisation — not middleware.
- Use Interceptors for response transformation and logging.
- Use NestJS `ConfigModule` for all configuration. Never read `process.env` directly in business logic.
- Each module is responsible for its own entities, services, repositories, and controllers.

---

## 7. Python Coding Standards

### Configuration

All Python code is checked with:

- **Ruff** for linting and formatting (configured in `pyproject.toml`).
- **mypy** for static type checking (strict mode).

```toml
[tool.ruff]
target-version = "py312"
line-length = 100
select = ["E", "W", "F", "I", "N", "B", "S", "UP"]

[tool.mypy]
python_version = "3.12"
strict = true
warn_return_any = true
warn_unused_configs = true
```

### Rules

- **Type annotations on all functions.** `def foo(x: int) -> str:` — not `def foo(x, y):`.
- **Use Pydantic models** for all FastAPI request and response schemas. No raw `dict` in API handlers.
- **No `eval()`, `exec()`, or `pickle.loads()`** with any user-controlled or external data.
- **No `subprocess` with `shell=True`** and any user-controlled input.
- **Use `pathlib.Path`** instead of string path manipulation.
- **Log with Python's `logging` module** (structured JSON) — not `print()`.
- **Use `httpx`** for HTTP client calls — not `requests` (async-compatible).
- **Use `async def`** for all FastAPI endpoint handlers.

---

## 8. Validation

### Backend (NestJS)

- All incoming HTTP request data must go through a DTO with `class-validator` decorators.
- Apply `ValidationPipe` globally in `main.ts`:
  ```typescript
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true, // strip unknown properties
      forbidNonWhitelisted: true, // reject requests with unknown properties
      transform: true, // transform plain objects to class instances
    }),
  );
  ```
- Validate file uploads separately (size, type, magic bytes) before the file reaches business logic.

### AI Service (FastAPI)

- All endpoint request bodies use Pydantic `BaseModel` subclasses.
- All endpoint responses use Pydantic `BaseModel` subclasses (typed responses).
- Use `response_model` on all FastAPI routes.

---

## 9. Error Handling

### Backend

- All unhandled exceptions are caught by a global exception filter.
- All errors return structured JSON:
  ```json
  {
    "statusCode": 422,
    "error": "VALIDATION_ERROR",
    "message": "File type not allowed",
    "timestamp": "2026-08-01T06:00:00.000Z",
    "path": "/api/v1/documents"
  }
  ```
- Stack traces are **never** included in production error responses.
- Exception filters log errors with trace IDs before responding.
- Business logic errors use typed exception classes — not generic `Error`.

### AI Service

- All FastAPI endpoints return typed error responses using `HTTPException`.
- Internal errors are caught and returned as 500 with a generic message (no stack traces in responses).
- All errors are logged with the correlation ID from the incoming request header.

---

## 10. Structured Logging

### Backend (NestJS)

- Use Pino (recommended) or Winston with JSON output.
- Every log entry includes:
  ```json
  {
    "timestamp": "2026-08-01T06:00:00.000Z",
    "level": "info",
    "service": "backend",
    "traceId": "abc123",
    "message": "Document uploaded",
    "documentId": "uuid",
    "organisationId": "uuid"
  }
  ```
- Log levels: `error`, `warn`, `info`, `debug`. Set via `LOG_LEVEL` environment variable.
- Debug level is disabled in production.

### AI Service (FastAPI/Python)

- Use Python's `logging` module with a JSON formatter.
- Include `trace_id` from the `X-Trace-ID` request header in every log entry.
- Log every inference request: model version, document ID, prediction, confidence score, duration.

### Prohibited in all logs

- Document content or extracted text.
- Personal data (names, ID numbers, addresses, emails).
- Passwords, tokens, API keys, or secrets.
- Stack traces (production).
- Raw request/response bodies.

---

## 11. Configuration Management

- All configuration is provided via environment variables.
- NestJS: Use `@nestjs/config` with a typed `ConfigService`. Never read `process.env` directly in business logic.
- FastAPI: Use `pydantic-settings` (`BaseSettings`) for typed configuration.
- Every service has a `.env.example` file with all required variables listed with placeholder values.
- Configuration is validated at startup — the service should fail fast if required configuration is missing.

---

## 12. Database Migrations

- All schema changes use Prisma migrations (`prisma/migrations/`).
- **No direct DDL commands** on any environment other than local development.
- Migration workflow:
  1. Edit `prisma/schema.prisma`.
  2. Run `npx prisma migrate dev --name <description>` locally.
  3. Review the generated SQL migration file.
  4. Commit both `schema.prisma` and the migration file.
  5. Open a pull request for review.
  6. Apply to staging with `npx prisma migrate deploy`.
  7. Apply to production with approval.
- Every migration must include a rollback plan documented in the PR description.
- **Migrations that delete data require explicit approval** and a data-migration script.

---

## 13. API Versioning

- All API routes are prefixed with `/api/v1/`.
- Breaking changes to an existing API require a new version path (`/api/v2/`).
- Backward compatibility must be maintained for at least one full minor release cycle.
- Deprecation must be announced in the API changelog and returned via a `Deprecation` response header.

---

## 14. Dependency Approval

See `SECURITY.md` Section 13 for full dependency security requirements.

Before adding any dependency:

1. Check if an existing dependency already provides the capability.
2. Check the licence.
3. Check maintenance status.
4. Run `npm audit` / `uv audit` after adding.
5. Document the reason in the pull request.

**Major dependencies** (new frameworks, ORMs, auth libraries, AI libraries) require approval before being added.

---

## 15. Definition of Done

A feature task is considered complete only when all of the following are true:

- [ ] Requirements are satisfied as described in the task specification.
- [ ] Architecture rules (from `ARCHITECTURE.md` and `AGENTS.md`) are followed.
- [ ] All external input is validated.
- [ ] Authentication and authorisation are enforced on all protected endpoints.
- [ ] Tenant isolation is implemented and tested.
- [ ] Unit tests cover success, failure, boundary, and permission scenarios.
- [ ] Integration tests cover the complete request path.
- [ ] Security impact has been reviewed (by the developer and, for high-risk changes, by a specialist).
- [ ] Structured log entries are emitted for important operations.
- [ ] Audit events are recorded for all required actions.
- [ ] No secrets or personal data are exposed in code, tests, logs, or documentation.
- [ ] Validation evidence (test output, lint output) is provided.
- [ ] Known limitations and unresolved risks are documented.
- [ ] Documentation is updated.
- [ ] Pull request is reviewed and approved.
- [ ] CI pipeline passes (lint, type-check, tests, security scans).

---

## 16. Patterns to Avoid

| Anti-pattern                               | Why                                            | Alternative                                                      |
| ------------------------------------------ | ---------------------------------------------- | ---------------------------------------------------------------- |
| God classes                                | Impossible to test or reason about             | Small, focused classes with a single responsibility              |
| Duplicated business logic                  | Two sources of truth diverge                   | Extract to a shared module or service                            |
| Giant utility files                        | Becomes a dumping ground                       | Focused, well-named utility modules                              |
| Silent error handling (`catch {}`)         | Hides bugs                                     | Log and re-throw or convert to typed error                       |
| Inline secrets                             | Leaks to source control                        | Environment variables + secrets manager                          |
| Unstructured logs (`console.log`)          | Unsearchable, unparseable                      | Structured JSON logger                                           |
| `process.env` in business logic            | Untestable, unvalidated                        | `ConfigService` with validation at startup                       |
| Premature microservices                    | Distributed systems complexity without benefit | Modular monolith — extract only when justified                   |
| Premature Kubernetes                       | Operational complexity without benefit         | Docker Compose until the platform is stable                      |
| Unnecessary abstractions                   | Complexity without value                       | YAGNI — build what is needed now                                 |
| Trusting user input for security decisions | Security bypass                                | Always validate and sanitise; take security context from the JWT |

---

## 17. Model Context Protocol (MCP) Local Setup

Model Context Protocol (MCP) connects the OpenAI Codex CLI agent to approved local development context and tools.

> **Requirement:** Before Phase 2 MCP installation, verify the current stable Codex MCP configuration schema, GitHub MCP server release, Context7 release, and MCP protocol compatibility using official documentation. Record the selected versions in `ADR-0007` or an ADR amendment. Do not use `@latest` or unpinned Docker image tags.

### Approved Client & Servers (Stage 1)

- **Client:** OpenAI Codex CLI
- **Servers:**
  1. **GitHub MCP Server** (Docker stdio): `ghcr.io/github/github-mcp-server:<PINNED_VERSION>` (Read-only repository access)
  2. **Context7 MCP Server** (npx stdio): `@upstash/context7-mcp@<PINNED_VERSION>` (Official documentation lookup)

### Configuration Setup

Project-specific configuration is maintained in `.codex/config.toml` in the repository root (gitignored).

```toml
# .codex/config.toml
# Local developer configuration — never commit this file.

[mcp_servers.github]
command = "docker"
args = [
  "run",
  "-i",
  "--rm",
  "-e", "GITHUB_PERSONAL_ACCESS_TOKEN",
  "-e", "GITHUB_READ_ONLY=1",
  "-e", "GITHUB_LOCKDOWN_MODE=1",
  "-e", "GITHUB_TOOLSETS=repos,issues,pull_requests",
  "ghcr.io/github/github-mcp-server:<PINNED_VERSION>"
]
env_vars = ["GITHUB_PERSONAL_ACCESS_TOKEN"]
startup_timeout_sec = 20
tool_timeout_sec = 30

[mcp_servers.context7]
command = "npx"
args = [
  "-y",
  "@upstash/context7-mcp@<PINNED_VERSION>"
]
startup_timeout_sec = 20
tool_timeout_sec = 30
```

### Setup Steps

1. Generate a GitHub Personal Access Token (PAT) with fine-grained read-only repository permissions for `Dy-Rongrath/Cambodia-Trusted-AI-Document-Platform`.
2. Export the token in your local shell profile (outside the config file):
   ```bash
   export GITHUB_PERSONAL_ACCESS_TOKEN="your-read-only-token"
   ```
3. Create `.codex/config.toml` locally using the template above (substituting `<PINNED_VERSION>` with verified releases).
4. Verify `.codex/config.toml` is ignored by Git (`git status` must not list it).
5. Run `codex mcp list` to verify both servers load cleanly.

### Mandatory Rules

- **NEVER commit `.codex/config.toml` or any file containing GitHub PATs or secrets.**
- All MCP tools in Stage 1 are read-only. Do not enable write parameters without approval.
- See `MCP_SECURITY.md` for full governance rules.

---

_Read `ARCHITECTURE.md`, `SECURITY.md`, `MCP_SECURITY.md`, and `AGENTS.md` alongside this document._
