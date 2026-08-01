# PROJECT_CONTEXT.md

> **Status:** Living document — updated as the project evolves.
> **Last updated:** 2026-08-01
> **Phase:** Phase 0 — Documentation and Governance Foundation: Complete
> **Next Phase:** Phase 1 — Engineering Scaffold and Tooling: Next

---

## 1. Product Purpose

The **Cambodia Trusted AI Document Platform** is a privacy-first, security-by-design platform that enables organisations in Cambodia to:

- Upload and securely store sensitive Khmer and English documents.
- Automatically classify documents using AI models trained on Khmer and English text.
- Extract structured information from documents under human supervision.
- Receive AI-assisted explanations of document content.
- Issue and verify digitally signed certificates and verifiable credentials.
- Exchange verified document data with trusted partner organisations.
- Maintain a complete, tamper-evident audit trail of every important action.

The platform is designed to support Cambodia's digital transformation while respecting the privacy rights of individuals and the data-sovereignty requirements of participating organisations.

This is an independent open-source project. It is not affiliated with, endorsed by, commissioned by, or operated by any Cambodian government institution or public agency.

---

## 2. Target Users

### Primary users

| User type | Description |
|---|---|
| **Organisation staff** | Employees of a participating organisation who upload, review, and manage documents on behalf of the organisation. |
| **Document reviewers** | Staff who perform human review of AI predictions that fall below the confidence threshold. |
| **Organisation administrators** | Staff who manage user accounts, permissions, and organisation settings within a tenant. |

### Secondary users

| User type | Description |
|---|---|
| **Credential verifiers** | External parties (other organisations, government officers) who verify digitally signed credentials or certificates via QR code or API. |
| **Platform administrators** | Technical staff who operate the platform, manage tenants, monitor system health, and respond to security incidents. |
| **Credential holders** | Individuals who hold credentials in a mobile wallet and present them for verification. |

### Out-of-scope users (Phase 0–3)

- Members of the general public with self-service access.
- External API consumers (Phase 13+).

---

## 3. Main Business Capabilities

| # | Capability | Target phase |
|---|---|---|
| 1 | Secure document upload with file-type and malware validation | Phase 4 |
| 2 | Khmer and English document classification | Phase 6 |
| 3 | Human review workflow for uncertain AI predictions | Phase 7 |
| 4 | AI-assisted document explanation | Phase 9 |
| 5 | Structured information extraction | Phase 8 |
| 6 | Digitally signed certificate issuance | Phase 11 |
| 7 | Verifiable credential issuance (OpenID4VCI / SD-JWT VC) | Phase 11 |
| 8 | Credential verification and QR-code scanning | Phase 11 |
| 9 | Mobile credential wallet (Flutter) | Phase 12 |
| 10 | Organisation-to-organisation verified data exchange | Phase 13 |
| 11 | European data-space connector integration | Phase 14 |
| 12 | MLOps pipeline and model governance | Phase 10 |
| 13 | Product-facing MCP capabilities | Phase 15 |
| 14 | Full observability, security monitoring, and Kubernetes deployment | Phase 16 |

---

## 4. Current Phase

**Phase 0 — Documentation and Governance Foundation: Complete**

Phase 0 established the platform's foundation documentation and governance rules:
- Foundation documentation (`AGENTS.md`, `PROJECT_CONTEXT.md`, `ARCHITECTURE.md`, `SECURITY.md`, `MCP_SECURITY.md`, `DEVELOPMENT.md`, `TESTING.md`, `DATA_GOVERNANCE.md`, `AI_GOVERNANCE.md`, `ROADMAP.md`, `CONTRIBUTING.md`, `README.md`).
- Architecture documentation and initial ADR set (ADR-0001 through ADR-0007).
- Security policy and STRIDE threat model (including 15 MCP threat categories).
- Development standards and testing standards.
- Data governance and AI governance policies.
- Repository-level AI-agent instructions (`AGENTS.md`).
- Task templates and specialist AI-agent role instructions.
- Repository configuration files (`.gitignore`, `.gitattributes`, `.nvmrc`).

Phase 0 defined the planned monorepo architecture but did not create the application scaffold. No application code, databases, health endpoints, CI workflows, or Docker services exist yet.

---

## 5. Scope

### In scope for Phase 0

- Foundation documentation (architecture, security, governance, development standards).
- Repository structure definition and tooling configuration files (`.gitignore`, `.gitattributes`, `.nvmrc`).
- Local Docker Compose environment specifications.
- Initial ADR set.

### In scope for Phase 1 (Engineering Scaffold and Tooling — Next)

- Root `package.json` with npm workspaces initialisation.
- `apps/backend`: NestJS application skeleton (health endpoint only).
- `apps/ai-service`: FastAPI application skeleton (health endpoint only).
- `apps/frontend`: Angular application skeleton (placeholder page).
- `packages/shared-types`: TypeScript types package skeleton.
- `infra/docker/docker-compose.yml` with PostgreSQL 17 and optional Keycloak 26 local-development configuration. Object storage is subject to [ADR-0008](docs/adr/ADR-0008-local-object-storage-strategy.md).
- PostgreSQL connection setup and Prisma initialisation & connection verification.
- Keycloak local-development configuration placeholder.
- Local object storage evaluation subject to ADR-0008.
- Health endpoints for backend and AI service.
- Code-quality tooling (ESLint, Prettier, Ruff, mypy).
- Basic GitHub Actions CI workflow execution.
- `.env.example` files for all services.

Phase 1 does not implement authentication business flows, full database schemas, document upload, AI models, or human review.

---

## 6. Out of Scope

The following are explicitly out of scope until a later phase:

| Item | Reason |
|---|---|
| Kubernetes deployment | Phase 16 target. Not justified until the platform works reliably in Docker Compose. |
| Service mesh (Istio, Linkerd) | Premature for current scale. |
| Event broker (Kafka, RabbitMQ) | Not yet justified; direct HTTP communication is sufficient. |
| Open Policy Agent | Not yet justified; application-layer authorisation is sufficient for initial phases. |
| Production LLM fine-tuning on paid compute | Requires formal data governance approval and budget authorisation. |
| Real government or personal data | Prohibited during development. Synthetic data only. |
| Eclipse Dataspace Components connector | Phase 14 target. |
| European Digital Identity Wallet interoperability | Phases 11–12 target. |
| Multi-cloud or hybrid-cloud infrastructure | Phase 16 target. |

---

## 7. Assumptions

| # | Assumption | Risk if wrong |
|---|---|---|
| A-1 | The platform will be deployed in a cloud environment that supports Docker and PostgreSQL. | Infrastructure rework required. |
| A-2 | Khmer-language documents will be in Unicode (UTF-8) encoding. Legacy encodings (e.g., Limon font encoding) are out of scope initially. | Encoding pre-processing layer required. |
| A-3 | The primary Khmer document types are administrative forms, certificates, and legal documents. Training data will reflect this distribution. | Model retraining required if distribution differs. |
| A-4 | All participating organisations will use the same platform instance (multi-tenant SaaS). A single-tenant deployment mode may be added later. | Architecture changes to isolation model. |
| A-5 | Internet connectivity is available for the deployment environment. Offline or air-gapped operation is out of scope. | Significant offline-mode engineering required. |
| A-6 | The developer (Dy Rongrath) is the sole contributor during Phase 0–1. A team contribution model will be defined in Phase 2+. | Contributor onboarding documentation must be ready earlier. |

---

## 8. Constraints

| # | Constraint | Source |
|---|---|---|
| C-1 | **No real personal, government, client, organisational, confidential, or production data** during development. | Security and privacy policy. |
| C-2 | **No secrets in source code**, logs, tests, or documentation. | Security policy. |
| C-3 | **No model is the final authority for credential authenticity.** Cryptographic verification is the source of truth. | AI governance policy. |
| C-4 | **Open-Source Licensing:** Application code, infrastructure code, and documentation are licensed under the Apache License 2.0 (`SPDX-License-Identifier: Apache-2.0`). Every dependency and third-party asset must have a known licence and complete the project dependency-review process ([docs/open-source-dependency-policy.md](docs/open-source-dependency-policy.md)). Generally approved permissive licences may use normal maintainer review. Copyleft, weak-copyleft, source-available, custom, unlicensed, or commercially restricted terms require explicit maintainer and legal review before adoption. | Open-source policy. |
| C-5 | **No Kubernetes until the platform works reliably in Docker Compose.** | Architecture principle. |
| C-6 | **All security-sensitive changes require manual human review.** AI agents may not self-approve such changes. | AI-agent permission policy. |
| C-7 | **TypeScript strict mode is mandatory** in all TypeScript code. | Coding standards. |
| C-8 | **Python must use a declared virtual environment.** The system Python must never be used for project code. | Development standards. |
| C-9 | **Local-First & Zero Paid Cloud:** Core development must remain usable locally without requiring paid cloud API keys or cloud subscriptions during early phases. | Development principle. |
| C-10 | **Apple Silicon Native Execution:** Local infrastructure containers and development tools must support Apple Silicon M5 (ARM64) natively without forced AMD64 emulation. | Infrastructure principle. |
| C-11 | **Maintainable Governance:** Initial contributor workflow must remain simple and maintainable by one project owner (Dy Rongrath) without premature enterprise-team complexity. | Governance policy. |

---

## 9. Glossary

| Term | Definition |
|---|---|
| **Khmer** | The official language and script of Cambodia. Unicode range: U+1780–U+17FF (Khmer block). |
| **Tenant** | An organisation that uses the platform. Each tenant's data is strictly isolated from all other tenants. |
| **Organisation** | Synonymous with Tenant in this project. A legal entity that has registered to use the platform. |
| **Document classification** | The AI task of assigning a document to one of a predefined set of document-type categories (e.g., birth certificate, employment contract, identity card). |
| **Information extraction** | The AI task of identifying and structuring specific data fields from a document (e.g., name, date of birth, document number). |
| **Human review** | A workflow step where a human reviewer examines an AI prediction that falls below the confidence threshold and either confirms or corrects it. |
| **Confidence threshold** | A probability score below which an AI prediction is flagged for human review rather than accepted automatically. The threshold value is defined in AI_GOVERNANCE.md. |
| **Verifiable credential (VC)** | A cryptographically signed digital attestation issued to a subject. Follows the W3C Verifiable Credentials Data Model. |
| **SD-JWT VC** | A Verifiable Credential format using Selective Disclosure JSON Web Tokens. The preferred VC format for this platform. |
| **OpenID4VCI** | OpenID for Verifiable Credential Issuance — the protocol used to issue credentials to a wallet. |
| **OpenID4VP** | OpenID for Verifiable Presentations — the protocol used to present credentials for verification. |
| **EUDI Wallet** | European Digital Identity Wallet — the European framework for mobile credential wallets. |
| **Dataspace** | A federated data-sharing ecosystem where organisations exchange data under agreed usage-control policies. |
| **Audit event** | A structured record of an important action (e.g., document upload, AI prediction, human review decision, credential issuance). |
| **ADR** | Architecture Decision Record — a document that records a significant architectural decision, its context, alternatives, and consequences. |
| **STRIDE** | A threat-modelling methodology covering: Spoofing, Tampering, Repudiation, Information Disclosure, Denial of Service, Elevation of Privilege. |
| **MLOps** | Machine Learning Operations — practices and tooling for reproducible, monitored, and governed model training and deployment. |
| **DVC** | Data Version Control — a tool for versioning datasets and ML models alongside source code. |
| **pgvector** | A PostgreSQL extension that adds vector similarity search, required for semantic search and embedding-based retrieval. |
| **Row-level security (RLS)** | A PostgreSQL feature that enforces data-access policies at the database row level, used for tenant isolation. |
| **Social-protection record** | Employment, insurance, healthcare, or social-welfare records issued by a public-sector agency. Classified as sensitive data and prohibited in development environments. |

---

## 10. Success Criteria

### Phase 0 (Documentation and Governance Foundation: Complete)

- Foundation documents created, reviewed, and aligned (`PROJECT_CONTEXT.md`, `ARCHITECTURE.md`, `SECURITY.md`, `MCP_SECURITY.md`, `DEVELOPMENT.md`, `TESTING.md`, `DATA_GOVERNANCE.md`, `AI_GOVERNANCE.md`, `ROADMAP.md`, `AGENTS.md`, `README.md`, `CONTRIBUTING.md`).
- System architecture and MCP integration boundary documented with Mermaid diagrams.
- Initial ADRs recorded (ADR-0001 through ADR-0007).
- Security policy and STRIDE threat model created (including 15 MCP threat categories).
- Development and testing standards created.
- Data and AI governance policies created.
- Repository-level AI-agent instructions (`AGENTS.md`) created.
- MCP security policy (`MCP_SECURITY.md`) created.
- No application code, secrets, or real data introduced.

### Phase 1 (Engineering Scaffold and Tooling: Next)

- Monorepo scaffold (`apps/backend`, `apps/frontend`, `apps/ai-service`, `packages/shared-types`) created.
- Root `package.json` with npm workspaces initialized.
- Local Docker Compose environment boots cleanly with PostgreSQL 17 and optional Keycloak 26 (object storage subject to ADR-0008).
- NestJS backend and FastAPI AI service health endpoints operational.
- Angular frontend placeholder builds and runs cleanly.
- Basic GitHub Actions CI pipeline passes (lint, type-check, unit test).
- Git repository branch protection configured.
- Local code-quality tooling (ESLint, Prettier, Ruff, mypy) operational.

### Production readiness (Phase 16)

- All 16 roadmap phases completed and validated.
- Security audit completed by an external specialist.
- STRIDE threat model reviewed and mitigated.
- Data-governance and privacy controls verified.
- Performance and load tests completed.
- Kubernetes deployment, Helm charts, and Argo CD GitOps tested.
- ALTAI self-assessment and EU AI Act compliance review completed.

---

*This document must be updated at the start of each phase to reflect the current scope and assumptions.*
