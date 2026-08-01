# ROADMAP.md — Cambodia Trusted AI Document Platform

> **Status:** Living document — updated as phases complete and priorities evolve.
> **Last updated:** 2026-08-01

---

## Overview

The platform is built in 14 phases. Each phase builds on the previous and delivers a testable, reviewable increment. No phase introduces Kubernetes, an event broker, or a service mesh unless it is explicitly listed.

---

## Phase 0 — Engineering Foundation (Documentation)

**Status:** 🟡 In progress

### Objective
Establish all foundation documents, repository structure, and toolchain before any feature code is written.

### Prerequisites
- Empty repository with Git initialised.

### Scope
- All foundation documents (this file and its siblings).
- Repository structure defined.
- Git repository with `.gitignore`, `.gitattributes`, `.nvmrc`.
- AI-agent guardrails (`AGENTS.md`).
- Architecture documentation and initial ADRs.
- Security policy and threat model.
- Development and testing standards.
- Data and AI governance policies.
- Roadmap and task templates.
- Role-specific AI agent instructions.

### Out of scope
- Any application code.
- Any Docker configuration.
- Any CI/CD pipeline.

### Acceptance criteria
- All foundation documents created and reviewed.
- Git repository initialised with proper `.gitignore`.
- Remote repository connected.

### Risks
- Document quality insufficient to guide Phase 1. Mitigation: review each document before proceeding.

### Deliverables
- All foundation documents committed to `main`.

---

## Phase 1 — Engineering Foundation (Code)

**Status:** 🔜 Next

### Objective
Create the monorepo scaffold, application skeletons, local Docker Compose environment, and CI/CD basics. No business logic yet.

### Prerequisites
- Phase 0 complete and approved.
- Developer toolchain set up (Node 24, Python 3.12, uv, Docker).

### Scope
- Root `package.json` with npm workspaces.
- `apps/backend`: NestJS application skeleton (health endpoint only).
- `apps/ai-service`: FastAPI application skeleton (health endpoint only).
- `apps/frontend`: Angular application skeleton (placeholder page).
- `packages/shared-types`: TypeScript types package skeleton.
- `infra/docker/docker-compose.yml` with PostgreSQL 17, Keycloak 26, MinIO.
- `.env.example` files for all services.
- ESLint + Prettier configured for TypeScript workspaces.
- Ruff + mypy configured for the AI service.
- Basic GitHub Actions CI: lint, type-check, unit test on every push.
- Prisma initialised in the backend with a connection test.
- Basic `README.md`.

### Out of scope
- Authentication implementation (Phase 2).
- Database schema (Phase 2).
- Any AI model (Phase 5).

### Security requirements
- Docker Compose must not expose any service other than the frontend and backend on external ports.
- `.env.example` must contain placeholder values only.
- `docker-compose.yml` must not contain any secrets (use `${ENV_VAR}` references).

### Testing requirements
- Health endpoint tests for backend and AI service.
- NestJS application bootstraps without error.
- FastAPI application bootstraps without error.
- Angular application builds without error.
- All linters and type checkers pass.

### Acceptance criteria
- `docker compose up` starts all infrastructure services cleanly.
- All three application skeletons start without errors.
- CI pipeline passes on first commit.

### Deliverables
- Monorepo scaffold committed to `main`.
- CI pipeline passing.

---

## Phase 2 — Authentication and Organisation Management

### Objective
Implement secure authentication and multi-tenant organisation management.

### Prerequisites
- Phase 1 complete.

### Scope
- Keycloak realm configuration (realm export committed to repository).
- NestJS JWT validation (Keycloak JWKS endpoint).
- NestJS `AuthModule`, `OrganisationModule`, `UserModule`.
- Organisation CRUD API (platform admin only).
- User invitation and role management.
- Tenant context middleware (extracts `organisation_id` from JWT).
- PostgreSQL schema for `organisations` and `users` (Prisma migration).
- Row-level security policies for all tenant-scoped tables.
- Angular login flow (OIDC with PKCE via Keycloak adapter).
- Protected routes in Angular.
- Organisation dashboard (placeholder).
- WebAuthn / Passkey setup in Keycloak (configuration only).

### Security requirements
- JWT validation tests: expired, forged, wrong audience.
- Tenant isolation tests for user queries.
- Cross-tenant access tests must fail.

### Testing requirements
- Unit tests for JWT validation guards.
- Integration tests for all auth and organisation endpoints.
- Dedicated tenant-isolation test suite.

### Acceptance criteria
- A user can log in via Keycloak and reach a protected dashboard.
- An admin can create an organisation.
- A user in Org A cannot access Org B's data.

---

## Phase 3 — Secure Document Upload

### Objective
Allow authenticated organisation users to upload documents securely.

### Prerequisites
- Phase 2 complete.

### Scope
- `DocumentModule` in NestJS.
- Prisma schema: `documents`, `document_files` tables.
- File upload API with:
  - File size limit enforced before buffering.
  - Content-Type validation.
  - Magic byte verification (allowlist: PDF, JPEG, PNG, TIFF).
  - Quarantine bucket storage (MinIO).
  - ClamAV integration point (stub that can be wired to a real scanner).
- Object storage service (`ObjectStorageService`).
- Document list and detail APIs.
- Document metadata storage.
- `AuditModule` with `document.upload` audit event.
- Frontend: document upload UI with progress indicator.
- Frontend: document list view.

### Security requirements
- File type spoofing attack must be rejected.
- Oversized file must be rejected before buffering.
- Audit event recorded for every upload (success and failure).
- Uploaded files not accessible directly from storage (pre-signed URLs only).

### Testing requirements
- File upload security test suite (see `TESTING.md` Section 2.7).
- Integration tests for all document endpoints.
- Audit event tests.

### Acceptance criteria
- A valid PDF can be uploaded and stored.
- A JPEG disguised as a PDF is rejected with 422.
- A file exceeding the size limit is rejected with 413.
- An audit event is recorded for every upload.

---

## Phase 4 — Audit Logging and Observability

### Objective
Make the platform's behaviour observable and auditable.

### Prerequisites
- Phase 3 complete.

### Scope
- Complete `AuditModule` with structured `audit_events` table (append-only).
- Audit log query API (platform admin only).
- OpenTelemetry SDK integration in NestJS backend.
- OpenTelemetry SDK integration in FastAPI AI service.
- Prometheus metrics endpoint in both services.
- Grafana + Loki + Tempo added to Docker Compose.
- Structured JSON logging in all services.
- Rate limiting on document upload and authentication endpoints.
- OWASP ZAP automated API scan in CI.

### Testing requirements
- Audit event integrity tests (verify INSERT-only constraint).
- Metrics endpoint tests.
- Rate-limiting tests.

### Acceptance criteria
- Every important action produces an audit event.
- Grafana dashboard shows request rates, error rates, and latency.
- Loki receives all structured log output.

---

## Phase 5 — Basic Document Classification Model

### Objective
Train, evaluate, and deploy the first document classification model.

### Prerequisites
- Phase 4 complete.
- An approved synthetic dataset exists (see `DATA_GOVERNANCE.md`).
- Model card template complete.

### Scope
- Dataset card for the first training dataset.
- Data preprocessing pipeline in `apps/ai-service`.
- Fine-tuning script using Hugging Face Transformers and PEFT/LoRA.
- MLflow experiment tracking for all training runs.
- DVC dataset versioning.
- Model evaluation suite (overall and Khmer-specific metrics).
- `ClassificationModule` in NestJS.
- FastAPI classification endpoint.
- Integration between NestJS backend and AI service.
- Classification result storage.
- Confidence threshold configuration.
- Frontend: display predicted document type and confidence score.
- `ai.prediction` audit event.

### Security requirements
- AI service endpoint authenticated with internal API key.
- Model hash verification before loading.
- No document content in logs.

### Testing requirements
- AI evaluation test suite (see `TESTING.md` Section 2.8).
- Model regression tests.
- Confidence threshold boundary tests.

### Acceptance criteria
- Model achieves defined accuracy thresholds on the test set.
- Khmer documents evaluated separately and meet the Khmer threshold.
- Predictions below the threshold create a human-review task.
- `ai.prediction` audit event recorded for every inference.

---

## Phase 6 — Human Review Workflow

### Objective
Build the human-review workflow for uncertain AI predictions.

### Prerequisites
- Phase 5 complete.

### Scope
- `ReviewModule` in NestJS.
- Prisma schema: `review_tasks`, `review_decisions` tables.
- Review task creation when confidence < threshold.
- Review task queue API.
- Review decision API.
- Frontend: reviewer dashboard with document view and prediction.
- Frontend: ability to confirm or override AI prediction.
- Audit events: `review.task.created`, `review.decision.submitted`.
- Override rate monitoring metric.

### Testing requirements
- Review workflow integration tests.
- Permission tests (only org_reviewer role can submit decisions).
- Audit event tests.

### Acceptance criteria
- Documents below the confidence threshold appear in the reviewer dashboard.
- Reviewers can confirm or override AI predictions.
- Override rate is tracked as a metric.

---

## Phase 7 — Information Extraction

### Objective
Extract structured fields from classified documents.

### Prerequisites
- Phase 6 complete.

### Scope
- Information extraction model training and evaluation.
- FastAPI extraction endpoint.
- Extracted field storage and API.
- Human validation of extracted fields.
- Frontend: display extracted fields alongside the source document.

### Testing requirements
- Extraction accuracy evaluation.
- Human validation workflow tests.

---

## Phase 8 — Multilingual AI Assistant

### Objective
Provide AI-generated document explanations in Khmer and English.

### Prerequisites
- Phase 7 complete.
- Prompt injection protection design approved.

### Scope
- LLM integration for document explanation (self-hosted or approved managed model).
- Prompt injection mitigations (see `AI_GOVERNANCE.md` Section 15).
- Explanation API.
- Frontend: explanation display alongside document.

### Security requirements
- Prompt injection protection tests.
- Indirect prompt injection protection tests.
- No personal data from other users in prompt context.

---

## Phase 9 — MLOps and Model Governance

### Objective
Operationalise model training, evaluation, and monitoring.

### Prerequisites
- Phase 8 complete.

### Scope
- Automated model evaluation pipeline in CI.
- Model regression gate (block deployment if metrics regress).
- Drift detection (data drift and prediction drift).
- MLflow model registry integration for production model management.
- Label Studio integration for ongoing data annotation.
- Automated retraining trigger on drift detection.
- Model card automation.

---

## Phase 10 — Verifiable Credentials

### Objective
Issue and verify digitally signed credentials using European identity standards.

### Prerequisites
- Phase 9 complete.
- Key management strategy approved.
- EU AI Act compliance assessment completed.

### Scope
- SD-JWT VC credential format implementation.
- OpenID4VCI credential issuance endpoint.
- OpenID4VP credential presentation verification.
- Selective disclosure support.
- Credential revocation (status list).
- Trusted issuer registry integration.
- QR-code generation for credential presentation.
- Keycloak or ZITADEL migration assessment for OpenID4VCI (see ADR-0004).

### Security requirements
- Human approval mandatory before every credential issuance.
- Cryptographic signature verification is the source of truth — AI classification is never sufficient alone.
- Credential forgery tests.
- Revocation replay tests.

---

## Phase 11 — Flutter Mobile Wallet

### Objective
Allow credential holders to store and present credentials on a mobile device.

### Prerequisites
- Phase 10 complete.

### Scope
- Flutter mobile application.
- OpenID4VCI credential reception.
- OpenID4VP credential presentation.
- QR-code scanning.
- Biometric protection for credential access.
- iOS and Android support.

---

## Phase 12 — Secure Inter-Organisation Data Exchange

### Objective
Allow verified data sharing between trusted organisations on the platform.

### Prerequisites
- Phase 11 complete.

### Scope
- Organisation-to-organisation data-sharing protocol.
- Consent and usage-control policies.
- Data-sharing audit events.
- Frontend: data-sharing management interface.

---

## Phase 13 — European Data-Space Integration

### Objective
Connect the platform to European data-space infrastructure.

### Prerequisites
- Phase 12 complete.
- Eclipse Dataspace Components evaluated and approved.

### Scope
- Eclipse Dataspace Components (EDC) connector integration.
- Dataspace Protocol implementation.
- Gaia-X trust concept alignment.
- Data contracts and usage-control policies.
- JSON-LD and DCAT metadata.

---

## Phase 14 — Production Hardening and Kubernetes

### Objective
Deploy the platform to a production environment with full observability, security, and operational maturity.

### Prerequisites
- All previous phases validated in a staging environment.
- Security audit completed by a specialist.
- EU AI Act compliance assessment completed.
- Production secrets management solution in place.
- Incident response plan documented and tested.

### Scope
- Kubernetes manifests for all services.
- Helm charts.
- Argo CD GitOps deployment.
- OpenTofu infrastructure as code.
- Production PostgreSQL (managed service, HA).
- Production secrets management (Vault or cloud secrets manager).
- Wazuh security monitoring.
- Falco runtime security.
- Cosign container image signing.
- Full SBOM pipeline.
- Penetration test.
- ALTAI self-assessment.
- Backup and disaster recovery testing.
- SLA and incident response plan.

---

*This roadmap is a living document. Phases may be reordered or split based on evidence from earlier phases.*
