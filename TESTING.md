# TESTING.md — Cambodia Trusted AI Document Platform

> **Status:** Living document — updated as the project evolves.
> **Last updated:** 2026-08-01

> [!NOTE]
> **Current repository state:** Phase 0 documentation only.
>
> No application source code, test suites, CI workflows, Docker services, or coverage reports currently exist. Unless explicitly marked as applicable to Phase 0 documentation validation, the testing requirements below are planned controls for future phases.

---

## 1. Testing Philosophy

Every feature must be verifiable without a production environment. Tests are not an afterthought — they are part of the definition of done.

**Testing priorities, in order:**

1. **Correctness** — does the code do what it is supposed to do?
2. **Security** — does the code reject what it should reject?
3. **Isolation** — does a bug in one tenant affect another tenant?
4. **Regression** — does a new change break existing behaviour?
5. **Performance** — does the code perform acceptably under expected load?

---

## 2. Test Types and Scope

### 2.1 Unit Tests

**Scope:** Individual functions, classes, and services in isolation. No real database, no real HTTP, no real AI model.

**Framework:**
- NestJS backend: [Jest](https://jestjs.io/) with `ts-jest`.
- Python AI service: [pytest](https://pytest.org/) with `pytest-asyncio`.
- Angular frontend: [Karma + Jasmine](https://jasmine.github.io/) (default Angular testing) or [Jest](https://jestjs.io/) with `jest-preset-angular`.

**What to unit test:**
- All business logic functions (classification result processing, confidence threshold evaluation, etc.).
- All utility functions (file type validation, magic byte checking, sanitisation functions).
- DTO validation (confirm class-validator rules accept and reject correctly).
- Service methods (mocked repository and external dependencies).
- Error-handling paths.
- AI model evaluation functions.
- Confidence threshold logic.

**What NOT to unit test with unit tests:**
- Database queries (use integration tests).
- HTTP routes (use integration or API tests).
- AI model accuracy (use AI evaluation tests).

---

### 2.2 Integration Tests

**Scope:** Multiple modules working together, including a real test database. No real AI model (use a mock AI service).

**Framework:**
- NestJS: Jest with `@nestjs/testing` and a test database (PostgreSQL in Docker).
- FastAPI: pytest with an in-memory test database or a test PostgreSQL instance.

**What to integration test:**
- All API endpoints (success and failure cases).
- Database read and write operations via repositories.
- Prisma migration correctness (schema matches what is expected).
- NestJS module wiring (modules import what they declare).
- Background jobs (trigger and verify outcome).

**Setup:**
- Each integration test run starts with a clean database (seeded with minimal required data).
- Tests are run against a dedicated test database, never against a development database.
- Docker Compose provides the test database in CI.

---

### 2.3 API Contract Tests

**Scope:** Verify that the backend API matches the OpenAPI specification and that the frontend client matches the backend API.

**Framework:**
- [Spectral](https://github.com/stoplightio/spectral) for OpenAPI spec linting.
- [Pact](https://docs.pact.io/) or OpenAPI schema validation in integration tests.

**What to test:**
- Every endpoint response matches the OpenAPI schema.
- Every endpoint error response matches the OpenAPI error schema.
- The generated TypeScript client (from `packages/shared-types`) matches the backend API.

---

### 2.4 Database Tests

**Scope:** Verify Prisma schema, migrations, and repository functions against a real PostgreSQL instance.

**What to test:**
- Every Prisma migration applies cleanly to a fresh database.
- Every Prisma migration is idempotent (can be run twice without error).
- Every repository method returns correctly typed data.
- Tenant isolation: queries for one organisation do not return another organisation's data.
- Row-level security: verify RLS policies reject cross-tenant access at the database level.
- Unique constraint enforcement.
- Cascade delete behaviour.

---

### 2.5 Authentication and Authorisation Tests

**Scope:** Verify that every protected endpoint enforces authentication and that role-based authorisation is correct.

**What to test:**
- Every protected endpoint returns 401 with no token.
- Every protected endpoint returns 401 with an expired token.
- Every protected endpoint returns 401 with a forged token (wrong signature).
- Every protected endpoint returns 403 when the user's role lacks the required permission.
- `org_admin` actions are rejected for `org_staff`.
- `platform_admin` actions are rejected for `org_admin`.

---

### 2.6 Tenant Isolation Tests

**Scope:** Verify that users of Organisation A cannot access Organisation B's data under any condition.

**This is a critical security test category.** Every resource type must be tested.

**Scenarios to test for every tenant-scoped endpoint:**

1. User A (Org A) tries to read User B's (Org B's) resource by ID → expect 403 or 404.
2. User A (Org A) tries to list resources → result must contain only Org A resources.
3. User A (Org A) tries to update Org B's resource → expect 403 or 404.
4. User A (Org A) tries to delete Org B's resource → expect 403 or 404.

**PostgreSQL RLS verification:**
- Connect to the database as the application role.
- Execute a query without the application-layer tenant filter.
- Verify RLS blocks access to other tenants' rows.

---

### 2.7 File Upload Security Tests

**What to test:**
- Upload a file exceeding the size limit → expect 413 before the file is read into memory.
- Upload a file with a disallowed extension → expect 422.
- Upload a file with a valid extension but wrong magic bytes (e.g., a JPEG renamed to `.pdf`) → expect 422.
- Upload a file with a valid extension and valid magic bytes but malicious content → verify ClamAV scan is triggered (Phase 4+).
- Upload with a missing Content-Type header → expect 415.
- Upload with a valid file → expect 202 Accepted.

---

### 2.8 AI Evaluation Tests

**Scope:** Verify that the AI model meets the defined accuracy and performance thresholds.

**What to evaluate:**
- Classification accuracy on the held-out test set (overall and per-class).
- Classification accuracy specifically on Khmer-language documents.
- Classification accuracy on English-language documents.
- Confidence score calibration (does a 0.9 confidence score actually correspond to ~90% accuracy?).
- Confidence threshold behaviour (documents below the threshold correctly enter human review).
- Model inference latency (P50, P95, P99 for the classification endpoint).

**Khmer-language specific metrics:**
- Precision, recall, and F1 score per document class evaluated on Khmer documents only.
- Performance on documents with mixed Khmer and English text.
- Performance on documents with different Khmer Unicode rendering variants.

**Thresholds (to be defined in `AI_GOVERNANCE.md`):**
- Overall accuracy ≥ [threshold TBD].
- Khmer document accuracy ≥ [threshold TBD].
- Human review trigger rate ≤ [threshold TBD]% (to avoid reviewer overload).

---

### 2.9 Model Regression Tests

**Scope:** Verify that a new model version does not perform worse than the previous version on a fixed evaluation dataset.

**What to test:**
- Run the new model version against the fixed evaluation dataset.
- Compare metrics against the previously deployed model.
- Block deployment if metrics regress beyond a defined tolerance.

**Implementation:** Tracked in MLflow. Comparison run in CI after training completes.

---

### 2.10 Prompt Injection Tests (Phase 8+)

**Scope:** Verify that the AI explanation service resists prompt injection attempts.

**What to test:**
- Submit documents containing known prompt injection payloads (e.g., "Ignore previous instructions and...").
- Verify the output does not comply with the injected instruction.
- Verify the output does not include data from other users or system context.

---

### 2.11 End-to-End Tests

**Scope:** Complete user workflows from browser to database, using real services.

**Framework:** [Playwright](https://playwright.dev/).

**Future cross-phase vertical-slice E2E scenario — available after Phases 3–7:**
- User logs in via Keycloak (Phase 3).
- User uploads a valid synthetic document (Phase 4).
- Document appears in the document list with status `processing`.
- Document classification result appears with a confidence score (Phase 6).
- If confidence is below threshold, a human-review task is created (Phase 6–7).
- Reviewer logs in and completes the review task (Phase 7).
- Audit log contains all expected events (Phase 5).

**Rules:**
- End-to-end tests use synthetic data only.
- End-to-end tests run against a local Docker Compose environment.
- End-to-end tests are tagged as `e2e` and run separately from unit and integration tests.

---

### 2.12 Security Regression Tests

**Scope:** Verify that known security controls are not accidentally removed.

**What to test (automated):**
- CSRF protection header is present.
- CORS headers are correct (expected origin only).
- HSTS header is present.
- All protected endpoints return 401 without authentication.
- All endpoints validate Content-Type on POST/PUT requests.

**Planned CI security tooling (to be configured in CI as application manifests and pipelines are created):**
- Gitleaks: secret scanning on every commit (Planned Phase 1). Until CI is configured, manual checks are required.
- Semgrep: SAST on every push (Planned Phase 2).
- `npm audit` / `uv audit`: dependency vulnerability check on every push (Planned Phase 1/2).
- Trivy: container image scan on every image build (Planned Phase 2).
- OWASP ZAP: automated API scan on every release (Planned Phase 4).

---

### 2.13 Performance and Load Tests

**Framework:** [k6](https://k6.io/) (Phase 4+).

**What to test:**
- Document upload endpoint: 100 concurrent uploads, P95 latency < 3 seconds.
- AI classification endpoint: P95 latency < 5 seconds for a standard-sized document.
- Authentication flow: 500 concurrent logins do not degrade.
- Database: query performance does not degrade with 100,000 documents per organisation.

---

### 2.14 Model Context Protocol (MCP) Security and Tool Testing

**Scope:** Verify that MCP tools, permissions, input sanitisation, and security boundaries operate as intended across all phases.

#### Applicable Now — Phase 0 Documentation Checks
- **Gitignore Rule Verification:** Verify `.codex/config.toml`, `.codex/`, `.mcp-credentials`, `mcp-server-config.json`, and `.cursor/mcp.json` are in `.gitignore`.
- **Secret Scan:** Confirm no real GitHub PATs, access tokens, or private keys are committed in documentation files.
- **Link & Reference Validation:** Confirm all MCP documentation links and references resolve.
- **Config Syntax Check:** Confirm all MCP configuration examples use `mcp_servers` (Codex-compatible TOML) and environment-variable forwarding (`env_vars = ["GITHUB_PERSONAL_ACCESS_TOKEN"]`).
- **Version Pinning Check:** Confirm no `@latest` or unpinned Docker image tags are used in configuration examples (`<PINNED_VERSION>` placeholders required).
- **Security Flag Verification:** Confirm GitHub MCP configuration examples explicitly enable read-only (`GITHUB_READ_ONLY=1`) and lockdown (`GITHUB_LOCKDOWN_MODE=1`) modes.
- **Runtime Isolation Verification:** Confirm no application runtime files or production database connections are enabled for MCP tools.

#### Deferred to Phase 2 — Development MCP Integration Tests
- **MCP Client & Server Startup:** Test that Codex CLI loads approved local MCP servers (`ghcr.io/github/github-mcp-server`, `@upstash/context7-mcp`) without errors.
- **MCP Authentication & Credential Handling:** Verify credentials are read exclusively from environment variables (`GITHUB_PERSONAL_ACCESS_TOKEN`) and never logged or exposed in tool metadata.
- **Read-Only Tool Allowlist Enforcement:** Verify read-only tools accept valid queries and reject any write attempts (`create_pull_request`, `push_files`).
- **Path Traversal & Restricted Access Rejection:** Verify filesystem tools reject attempts to access paths outside the workspace root (`../`).
- **Tool Input Schema Validation:** Verify tools validate parameters against strict schemas and reject malformed arguments.
- **MCP Prompt Injection Resilience:** Test agent behaviour when retrieved tool outputs contain adversarial instructions. Verify the agent treats output strictly as untrusted data.
- **MCP Tool-Output Injection Protection:** Verify tool output content cannot hijack agent control flow or self-approve write operations.
- **Untrusted Server & Impersonation Rejection:** Test client rejection of unvetted servers or spoofed endpoints.
- **Timeout & Retry Limit Enforcement:** Test agent graceful degradation when an MCP server times out (30s limit) or disconnects.
- **Rate-Limit & Exhaustion Handling:** Test handling when API rate limits (e.g. GitHub API quota) are reached.
- **Audit Event Generation:** Verify stateful or external MCP tool invocations emit structured audit logs.

#### Deferred to Phase 15 — Product-Facing MCP Tests
- **OAuth 2.1 Authentication & Scope Validation:** Test external client authentication and token scope validation.
- **Tool-Level Authorisation & User Context:** Verify tools execute under the authenticated user's context and role permissions.
- **Tenant Isolation Boundaries:** Verify product-facing MCP tools strictly enforce tenant ID filtering and PostgreSQL Row-Level Security (RLS). Cross-tenant queries must fail with 403.
- **Output Data Minimisation & Sanitisation:** Verify tool responses filter out sensitive document content, personal identity data, and system internals.
- **Application Business-Rule Enforcement:** Verify MCP tools delegate to internal application services and cannot bypass validation or business logic.
- **Product MCP Audit Logging & Revocation:** Verify tool invocations are recorded in the central `audit_events` table and client revocation immediately disables tool access.

---


## 3. Coverage Thresholds

| Project | Threshold | Metric |
|---|---|---|
| `apps/backend` | 80% | Line coverage |
| `apps/ai-service` | 75% | Line coverage |
| `apps/frontend` | 70% | Line coverage |

Coverage is measured in CI on every push. PRs that reduce coverage by more than 2% are flagged for review.

---

## 4. Planned Quality Gates

The following quality gates are planned controls to be implemented incrementally beginning in Phase 1:

| Check | Tool | When | Intended phase |
|---|---|---|---|
| TypeScript compilation | `tsc --noEmit` | Every push | Phase 1 |
| TypeScript linting | ESLint | Every push | Phase 1 |
| TypeScript formatting | Prettier | Every push | Phase 1 |
| Python type checking | mypy | Every push | Phase 1 |
| Python linting + formatting | Ruff | Every push | Phase 1 |
| Backend unit tests | Jest | Every push | Phase 1 |
| AI service unit tests | pytest | Every push | Phase 1 |
| Frontend unit tests | Jest / Karma | Every push | Phase 1 |
| Integration tests | Jest + test database | Every push | Phase 1 |
| Coverage thresholds | Jest + coverage-reporter | Every push | Phase 1 |
| OpenAPI spec validation | Spectral | Every push | Phase 1 |
| Secret scanning | Gitleaks | Every push | Phase 1 |
| Dependency audit | npm audit + uv audit | Every push | Phase 1 or Phase 2 |
| SAST | Semgrep | Every push | Phase 2 or later |
| Container scanning | Trivy | Every image build | Phase 2 or later |
| End-to-end tests | Playwright | Every PR to main | Phase 3–7 onward |
| AI evaluation | pytest + MLflow | Every model change | Phase 6 onward |
| Product-facing MCP tests | OpenAPI / custom | Every release | Phase 15 |
| Kubernetes validation | Helm / kube-linter | Every release | Phase 16 |

---

## 5. Test Data Rules

- **No real personal, government, or production data in tests.** Synthetic data only.
- Test fixtures must be clearly labelled as synthetic (e.g., file names starting with `SYNTHETIC_`).
- Test database seeds are committed under `apps/backend/prisma/seeds/` (development seeds) and `apps/backend/prisma/seeds/test/` (test seeds).
- Test seeds use deterministic data (fixed UUIDs, fixed dates) for reproducible test runs.
- Synthetic Khmer document samples must be clearly marked as synthetic and not resemble real government documents.

---

## 6. Test File Organisation

Planned Phase 1 structure — these directories do not exist in Phase 0.

### Backend (NestJS)

```
apps/backend/
├── src/
│   └── <module>/
│       ├── <module>.service.ts
│       ├── <module>.service.spec.ts       ← unit test
│       └── <module>.controller.spec.ts    ← controller unit test
└── test/
    ├── <module>.e2e-spec.ts               ← integration test (full HTTP)
    └── helpers/                           ← test utilities and builders
```

### AI Service (Python)

```
apps/ai-service/
└── tests/
    ├── unit/
    │   └── test_<module>.py
    ├── integration/
    │   └── test_<module>_api.py
    └── evaluation/
        └── test_model_accuracy.py
```

---

## 7. Running Tests Locally

The following commands become valid only after Phase 1 scaffolding is merged.

```bash
# Backend unit tests
cd apps/backend && npm test

# Backend integration tests
cd apps/backend && npm run test:e2e

# Backend test coverage
cd apps/backend && npm run test:cov

# AI service tests
cd apps/ai-service && uv run pytest

# AI service tests with coverage
cd apps/ai-service && uv run pytest --cov=. --cov-report=term-missing

# Frontend tests
cd apps/frontend && npm test

# End-to-end tests (requires Docker Compose services running)
cd apps/frontend && npm run e2e
```

---

## 8. Writing Good Tests

### Rules

1. **Test the behaviour, not the implementation.** A test that breaks when you rename a variable is a fragile test.
2. **One concept per test.** If a test has ten assertions, split it into ten focused tests.
3. **Tests must be deterministic.** No random data unless explicitly seeded. No time-dependent logic without mocking `Date.now()`.
4. **Tests must be independent.** No test should depend on the execution order of other tests.
5. **Name tests clearly:** `it('should return 422 when file type is not allowed', ...)`.
6. **Include negative tests.** Test what the code rejects, not just what it accepts.
7. **Test boundary conditions.** File size exactly at the limit, confidence score exactly at the threshold.
8. **Test permission scenarios.** What happens when an `org_staff` tries an `org_admin` action?

### Arrange-Act-Assert (AAA) pattern

```typescript
it('should reject a PDF that has JPEG magic bytes', async () => {
  // Arrange
  const jpegBytes = Buffer.from([0xFF, 0xD8, 0xFF]); // JPEG magic bytes
  const fakeFile = { originalname: 'document.pdf', buffer: jpegBytes, mimetype: 'application/pdf' };

  // Act
  const result = await documentService.validateFile(fakeFile);

  // Assert
  expect(result.isValid).toBe(false);
  expect(result.rejectionReason).toBe('FILE_TYPE_MISMATCH');
});
```

---

*Read `DEVELOPMENT.md`, `SECURITY.md`, and `AI_GOVERNANCE.md` alongside this document.*
