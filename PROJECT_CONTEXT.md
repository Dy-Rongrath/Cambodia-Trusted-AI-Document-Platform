# PROJECT_CONTEXT.md

> **Status:** Living document — updated as the project evolves.
> **Last updated:** 2026-08-01
> **Phase:** Phase 0 — Engineering Foundation

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
- External API consumers (Phase 12+).

---

## 3. Main Business Capabilities

| # | Capability | Target phase |
|---|---|---|
| 1 | Secure document upload with file-type and malware validation | Phase 3 |
| 2 | Khmer and English document classification | Phase 5 |
| 3 | Human review workflow for uncertain AI predictions | Phase 6 |
| 4 | AI-assisted document explanation | Phase 8 |
| 5 | Structured information extraction | Phase 7 |
| 6 | Digitally signed certificate issuance | Phase 10 |
| 7 | Verifiable credential issuance (OpenID4VCI / SD-JWT VC) | Phase 10 |
| 8 | Credential verification and QR-code scanning | Phase 10 |
| 9 | Mobile credential wallet (Flutter) | Phase 11 |
| 10 | Organisation-to-organisation verified data exchange | Phase 12 |
| 11 | European data-space connector integration | Phase 13 |
| 12 | MLOps pipeline and model governance | Phase 9 |
| 13 | Full observability, security monitoring, and Kubernetes deployment | Phase 14 |

---

## 4. Current Phase

**Phase 0 — Engineering Foundation**

Objectives:
- Establish the monorepo structure.
- Initialise all foundation documents (this file and its siblings).
- Define architecture, security policy, and governance before any code is written.
- Set up local developer toolchain.
- Create the first vertical-slice specification.

No feature code exists yet.

---

## 5. Scope

### In scope for Phase 0

- Foundation documentation (architecture, security, governance, development standards).
- Repository structure and tooling configuration.
- Local Docker Compose environment definition.
- Initial ADR set.

### In scope for Phase 1 (Engineering Foundation — code)

- Monorepo scaffold with npm workspaces.
- NestJS backend application skeleton.
- FastAPI AI service skeleton.
- Angular frontend skeleton.
- PostgreSQL database with initial schema and Prisma setup.
- Keycloak authentication integration.
- Docker Compose local development environment.
- CI/CD pipeline basics.
- Code-quality tooling (ESLint, Prettier, Ruff, mypy).

---

## 6. Out of Scope

The following are explicitly out of scope until a later phase:

| Item | Reason |
|---|---|
| Kubernetes deployment | Not justified until the platform works reliably in Docker Compose. |
| Service mesh (Istio, Linkerd) | Premature for current scale. |
| Event broker (Kafka, RabbitMQ) | Not yet justified; direct HTTP communication is sufficient. |
| Open Policy Agent | Not yet justified; application-layer authorisation is sufficient for initial phases. |
| Production LLM fine-tuning on paid compute | Requires formal data governance approval and budget authorisation. |
| Real government or personal data | Prohibited during development. Synthetic data only. |
| Eclipse Dataspace Components connector | Phase 13 target. |
| European Digital Identity Wallet interoperability | Phase 10–11 target. |
| Multi-cloud or hybrid-cloud infrastructure | Phase 14 target. |

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
| C-1 | **No real personal, government, NSSF, or confidential data** during development. | Security and privacy policy. |
| C-2 | **No secrets in source code**, logs, tests, or documentation. | Security policy. |
| C-3 | **No model is the final authority for credential authenticity.** Cryptographic verification is the source of truth. | AI governance policy. |
| C-4 | **All major dependencies must be open-source or have a clear open-source path.** Avoid unnecessary vendor lock-in. | Technology selection principles. |
| C-5 | **No Kubernetes until the platform works reliably in Docker Compose.** | Architecture principle. |
| C-6 | **All security-sensitive changes require manual human review.** AI agents may not self-approve such changes. | AI-agent permission policy. |
| C-7 | **TypeScript strict mode is mandatory** in all TypeScript code. | Coding standards. |
| C-8 | **Python must use a declared virtual environment.** The system Python must never be used for project code. | Development standards. |

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
| **NSSF** | National Social Security Fund — a Cambodian government agency. Data from NSSF is classified as sensitive and prohibited in development environments. |

---

## 10. Success Criteria

### Phase 0 (Engineering Foundation)

- All foundation documents created and approved.
- Repository structure defined.
- Local Docker Compose environment boots cleanly.
- Git repository with branch protection configured.

### Phase 1 (First Vertical Slice)

- An authenticated organisation user can upload a safe synthetic Khmer or English document.
- The backend validates, stores metadata, and records an audit event.
- The AI service classifies the document and returns a prediction with a confidence score.
- The frontend displays the predicted document type and confidence.
- Predictions below the confidence threshold enter the human-review workflow.
- All important actions are recorded in the audit log.
- All unit, integration, and security tests pass.

### Production readiness (Phase 14)

- All 14 roadmap phases completed and validated.
- Security audit completed.
- Threat model reviewed by a specialist.
- Data-governance controls verified.
- Performance and load tests completed.
- Kubernetes deployment documented and tested.
- GDPR/PDPA compliance review completed.

---

*This document must be updated at the start of each phase to reflect the current scope and assumptions.*
