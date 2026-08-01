# AGENTS.md — AI-Agent Instructions for trusted-ai-platform

> **Scope:** Workspace-level. Applies to all AI agents operating on this repository.
> **Last updated:** 2026-08-01
> **Supersedes:** Any generic agent instructions that conflict with this file.

Read this file completely before taking any action on the codebase.

---

## 1. Project Objective

Build a production-grade, privacy-first platform that combines secure software engineering, AI-assisted document processing, digital identity (verifiable credentials), cybersecurity-by-design, and European interoperability standards.

The platform processes Khmer and English documents on behalf of multiple organisations. Every design decision must consider:
- Multi-tenant data isolation.
- Privacy by design.
- Human oversight of AI decisions.
- Cryptographic integrity of credentials.
- Least privilege at every layer.

See `PROJECT_CONTEXT.md` for full product context.

---

## 2. Approved Technology Stack

### Backend
- **Runtime:** Node.js 24.15.0 (pinned in `.nvmrc`)
- **Language:** TypeScript (strict mode mandatory)
- **Framework:** NestJS (latest stable)
- **Database:** PostgreSQL 17
- **ORM:** Prisma (latest stable)
- **Authentication:** Keycloak 26 (OAuth 2.1, OIDC, WebAuthn/Passkeys)
- **API:** REST with OpenAPI (no GraphQL unless explicitly approved)
- **Validation:** `class-validator` + `class-transformer`
- **Logging:** Structured JSON (Pino or Winston — to be decided in ADR)

### AI/ML Service
- **Runtime:** Python 3.12 (via pyenv)
- **Dependency manager:** uv
- **Framework:** FastAPI (latest stable)
- **ML framework:** PyTorch (latest stable)
- **Transformers:** Hugging Face Transformers
- **Experiment tracking:** MLflow
- **Data versioning:** DVC
- **Serving:** vLLM (when justified for production inference)

### Frontend
- **Framework:** Angular (latest stable LTS)
- **State:** Angular Signals + RxJS
- **Styling:** Angular Material or custom CSS — to be decided
- **API client:** OpenAPI-generated TypeScript client

### Mobile
- **Framework:** Flutter (latest stable)
- **Platform:** iOS and Android

### Infrastructure (local development)
- **Containers:** Docker 29 + Docker Compose v5
- **Kubernetes:** NOT YET — only after platform is validated in Docker Compose

### DevSecOps (to be introduced incrementally)
- **Secret scanning:** Gitleaks
- **SAST:** Semgrep
- **Container scanning:** Trivy
- **SBOM:** Syft + CycloneDX
- **Observability:** OpenTelemetry → Prometheus + Grafana + Loki + Tempo (Phase 4+)

### DO NOT introduce without explicit approval
- Kafka, RabbitMQ, or any event broker
- Open Policy Agent
- Istio or any service mesh
- Eclipse Dataspace Components
- Any cloud provider SDK not explicitly approved
- Any LLM inference service that receives real user data

---

## 3. Repository Structure

```
trusted-ai-platform/
├── apps/
│   ├── backend/          # NestJS — main API server
│   ├── ai-service/       # FastAPI — document classification and AI inference
│   └── frontend/         # Angular — web application
├── packages/
│   └── shared-types/     # Shared TypeScript types and OpenAPI schemas
├── infra/
│   ├── docker/           # Docker Compose files
│   └── k8s/              # Kubernetes manifests (Phase 14+)
├── docs/
│   ├── adr/              # Architecture Decision Records
│   ├── threat-model.md   # STRIDE threat model
│   ├── templates/        # Reusable task templates
│   └── roles/            # Specialist AI role instructions
├── scripts/              # Developer utility scripts
├── .agents/
│   └── AGENTS.md         # This file
├── PROJECT_CONTEXT.md
├── ARCHITECTURE.md
├── SECURITY.md
├── DEVELOPMENT.md
├── TESTING.md
├── DATA_GOVERNANCE.md
├── AI_GOVERNANCE.md
├── CONTRIBUTING.md
├── ROADMAP.md
├── .gitignore
├── .gitattributes
└── .nvmrc
```

---

## 4. Architecture Rules

1. **Modular monolith first.** Do not split the NestJS backend into separate deployable services until a genuine scaling or isolation reason is demonstrated and approved.
2. **AI service is always a separate process.** The Python FastAPI service communicates with the NestJS backend over HTTP only. Never embed Python in the Node.js process.
3. **Clear module boundaries.** Each NestJS module owns its own database tables, business logic, and API routes. Do not reach directly into another module's internals.
4. **No duplicated business logic.** Shared logic belongs in a NestJS shared module or in `packages/shared-types`. Do not copy-paste logic between modules.
5. **Strong typing everywhere.** TypeScript strict mode. Python type annotations on all functions. No `any` in TypeScript without a documented justification comment.
6. **Validate every external input.** All incoming HTTP request data must be validated using DTOs with `class-validator` in NestJS. All FastAPI routes must use Pydantic models. Never trust raw request data.
7. **Authorisation on the server.** Never rely solely on frontend checks for access control. Every protected route must verify the JWT and enforce permissions on the backend.
8. **Tenant isolation is non-negotiable.** Every database query that accesses tenant data must include a tenant/organisation ID filter. Row-level security in PostgreSQL enforces this as a second layer. Tenant isolation must be tested.
9. **No direct database access from the AI service.** The AI service communicates with the backend via REST API only. It does not have database credentials.
10. **Human review for uncertain AI decisions.** Any AI prediction below the confidence threshold must be flagged for human review. The AI must never be the final authority for credential authenticity.

---

## 5. Coding Rules

### TypeScript
- `"strict": true` in all `tsconfig.json` files.
- No `@ts-ignore` or `@ts-nocheck` without a comment explaining why.
- No `any` without a documented justification.
- Use `readonly` for properties that should not be mutated.
- Use `Result` types or explicit error classes — never return `null` to indicate failure silently.
- Prefer `const` over `let`. Never use `var`.
- All public API functions must have JSDoc comments.

### Python
- Python 3.12+. Use type annotations on all functions (`def foo(x: int) -> str:`).
- Use Pydantic models for all FastAPI request and response schemas.
- Use `ruff` for linting and formatting (configured in `pyproject.toml`).
- Use `mypy` for static type checking.
- No `eval()`, `exec()`, or `pickle.loads()` with untrusted data.
- No `subprocess.shell=True` with user-controlled input.

### General
- No hard-coded secrets, passwords, connection strings, or API keys anywhere in source code.
- No `TODO` comments in committed code unless they reference an open issue.
- All HTTP errors must return structured JSON error responses (not plain text stack traces).
- All important operations must produce structured log entries.
- All database transactions involving multiple writes must use explicit transactions.
- Never swallow exceptions silently. Log and re-raise or convert to a typed error.

---

## 6. Security Rules

The following rules are mandatory and non-negotiable:

### Data and secrets
- **Never use real personal, government, NSSF, or production data** during development. Use synthetic or anonymised data only.
- **Never include secrets, tokens, passwords, private keys, or sensitive values** in source code, tests, logs, prompts, screenshots, or documentation.
- **Never commit `.env` files.** Only commit `.env.example` with placeholder values.
- **Never expose production infrastructure to an AI agent.**

### Authentication and authorisation
- Validate JWT tokens correctly (signature, expiry, issuer, audience). Never skip validation.
- Enforce authorisation on every protected endpoint.
- Apply least privilege to every service account and database role.
- Enforce tenant isolation at the application layer AND at the database layer (PostgreSQL RLS).

### File upload security
- Never trust file type based on filename extension or `Content-Type` header alone.
- Validate file magic bytes (file signature).
- Enforce file-size limits before reading file content.
- Scan uploaded files for malware before processing (ClamAV integration point).
- Never execute or import uploaded files.
- Store uploaded files in object storage, not in the application filesystem.
- Serve uploaded files through the application layer, not directly from storage.

### AI model security
- Treat model files, datasets, packages, and containers as supply-chain risks.
- Never load untrusted model files with `pickle.loads()` or equivalent.
- Prefer `safetensors` format for model weights.
- Verify model integrity (hash or signature) before loading.
- Never pass user-supplied text directly to a model prompt without sanitisation.
- Apply prompt-injection mitigations when using LLMs.

### Dependency security
- Do not add a new dependency without reviewing its licence, maintenance status, and known vulnerabilities.
- Pin dependency versions in lock files (`package-lock.json`, `uv.lock`).
- Run `npm audit` and `uv audit` regularly.

### Cryptography
- Never implement custom cryptography.
- Use well-established libraries (e.g., `node:crypto`, `cryptography` for Python, `jose` for JWT).
- Never use MD5 or SHA-1 for security purposes.
- Use AES-256-GCM or ChaCha20-Poly1305 for symmetric encryption.
- Use ECDSA (P-256 or P-384) or Ed25519 for signatures.

### Logging and monitoring
- Never log personal data, secrets, or sensitive document content.
- Log all authentication events, authorisation failures, and important administrative actions.
- Log all AI prediction events with document ID, prediction, confidence score, and whether human review was triggered.

---

## 7. Privacy Rules

- Apply privacy by design in every feature.
- Collect only the minimum personal data necessary.
- Document the purpose and legal basis for any personal data collection.
- Store personal data encrypted at rest where feasible.
- Apply data retention limits.
- Support data-subject access and deletion requests in the architecture.
- Never send personal data to external services (including public AI/LLM APIs) without explicit consent and a legal basis.
- Anonymise or pseudonymise data used for model training and evaluation.
- Record data provenance for all training datasets.

---

## 8. AI and Data Rules

- The AI must never be the final authority for credential authenticity. Cryptographic verification is the source of truth.
- Human review is mandatory for any AI prediction below the configured confidence threshold.
- All AI predictions must be logged with model version, confidence score, and input document ID.
- Model training must use only approved, documented, versioned datasets.
- No real personal data may be used for training without formal approval and documented consent.
- Model evaluations must include Khmer-language-specific metrics.
- Model drift must be monitored and trigger a retraining or review process.
- AI experiment results must be logged in MLflow.
- All dataset changes must be versioned using DVC.

---

## 9. Testing Requirements

Every feature must include:

- **Unit tests** for all business logic, utility functions, and AI model evaluation functions.
- **Integration tests** for all API endpoints (including authentication, authorisation, and tenant isolation).
- **Database tests** for all Prisma repository functions.
- **Security tests** for file upload validation, JWT validation, and tenant-isolation boundaries.
- **AI evaluation tests** for model accuracy, Khmer-language performance, and confidence-threshold behaviour.

Tests must include:
- Success paths.
- Failure paths.
- Boundary conditions.
- Permission and authorisation scenarios.
- Negative tests (what the system must refuse to do).

Test coverage thresholds and quality gates are defined in `TESTING.md`.

---

## 10. Dependency Rules

Before adding any new dependency, you must:

1. Check whether an existing dependency already provides the capability.
2. Check the dependency's licence (must be compatible with the project — MIT, Apache 2.0, BSD preferred).
3. Check the dependency's maintenance status (last release, open issues, community health).
4. Check for known vulnerabilities (`npm audit` or `uv audit`).
5. Record the reason for adding the dependency in the pull-request description.

**Approval required before adding:**
- Any new npm package that is not a type definition (`@types/*`).
- Any new Python package.
- Any new Docker base image.
- Any new external service or cloud dependency.

---

## 11. Database-Change Rules

- All schema changes must be made through Prisma migrations. No direct database modifications.
- Migrations must be reviewed and approved before being applied to any environment other than local development.
- Every migration must be tested with a rollback plan.
- Migrations must never delete data without an explicit data-migration step and approval.
- Production migrations require separate approval.

---

## 12. Approval Boundaries

### Allowed without additional approval

- Inspect repository files.
- Analyse architecture and code.
- Read configuration (without displaying secret values).
- Run safe, local, non-destructive inspection and linting commands.
- Create plans and documentation.
- Generate synthetic test data.
- Propose refactoring.
- Create draft migrations (without applying them).
- Create threat-model drafts.
- Generate tests.
- Run existing formatting, linting, type-checking, and test commands.
- Report risks and inconsistencies.

### Requires explicit approval before execution

- Adding, removing, or replacing major dependencies.
- Changing the database schema.
- Applying database migrations.
- Changing authentication configuration.
- Changing authorisation or permission rules.
- Modifying cryptography or key management.
- Changing CI/CD pipelines.
- Changing infrastructure configuration.
- Introducing Kubernetes.
- Introducing an event broker.
- Introducing a new external service or cloud dependency.
- Deleting or moving important files.
- Running destructive commands.
- Downloading or executing AI models.
- Starting paid compute.
- Fine-tuning models on paid resources.
- Publishing packages or Docker images.
- Pushing branches or creating pull requests.
- Deploying any environment.

---

## 13. Prohibited Actions

You must never, under any circumstances:

- Access production secrets or credentials.
- Deploy directly to production.
- Delete production data.
- Disable, skip, or comment out security controls, tests, or linting rules to make a test pass.
- Bypass the approval requirements defined above.
- Use real personal, government, NSSF, or confidential data with any AI service.
- Approve your own security-sensitive changes.
- Hide command failures, errors, or test failures.
- Claim work is completed when it is not.
- Describe placeholder or incomplete code as production-ready.
- Commit `.env` files or secrets.
- Execute untrusted model files or unsafe serialised objects.
- Use `pickle.loads()` with untrusted data.
- Implement custom cryptographic algorithms.
- Return a 200 OK for an operation that failed.

---

## 14. Required Workflow

For every implementation task:

1. Read the relevant files in the repository before making changes.
2. Explain the current behaviour and what will change.
3. Reference the relevant files and directories.
4. Identify affected modules.
5. Identify assumptions and unknowns — do not present assumptions as facts.
6. Identify security, privacy, compatibility, migration, and operational risks.
7. Propose the smallest safe change.
8. State whether approval is required.
9. Implement only the approved scope.
10. Add or update tests.
11. Run safe verification commands (lint, type-check, unit tests).
12. Update relevant documentation.
13. Report changed files.
14. Report validation evidence.
15. Report failed checks and unresolved risks.
16. Recommend one logical next task.

---

## 15. Required Completion Report

After every approved implementation task, produce a completion report with:

### Work completed
- Summary of changes.
- Files created (path and purpose).
- Files updated (path, what changed, and why).

### Decisions
- Decisions made during implementation.
- Decisions awaiting approval.
- Assumptions made.

### Verification
- Commands executed.
- Tests passed.
- Tests failed.
- Checks not executed and why.

### Security and privacy
- Security findings from this change.
- Privacy findings from this change.
- Areas requiring manual specialist review.

### Remaining work
- Known limitations.
- Unresolved risks.
- Recommended next task.

---

*All agents operating on this repository must comply with this file. If this file conflicts with a generic instruction, this file takes precedence.*
