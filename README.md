# Cambodia Trusted AI Document Platform

> **An open-source, privacy-first platform for trusted Khmer and English document processing, human-reviewed AI assistance, and verifiable digital credentials.**

---

## Pre-Release Maturity Warning

> **Notice:** This project is under active pre-release development.
>
> Phase 1 creates the engineering scaffold and local development tooling. It is **not yet suitable for processing real personal, government, NSSF, client, or production data**. Synthetic test data must be used for all development and testing.

---

## Production Readiness Definition

Phase 1 establishes production-quality software engineering foundations, but it is **not the production-ready platform**.

The platform becomes production-ready incrementally as the security, functional, observability, AI evaluation, testing, verifiable credential, data-space, deployment, and governance requirements from later roadmap phases are completed and validated.

```text
Phase 0 — Documentation, governance, architecture, security, and open-source foundation (Complete)
Phase 1 — Engineering scaffold and tooling (Next)
Phases 2–15 — Incremental security, product, AI, credential, integration, and operational capabilities
Phase 16 — Production hardening, deployment, Kubernetes, signed releases, and final security review
```

The project may be called production-ready only after evidence exists for all 16 roadmap phases, comprehensive security audit completion, ALTAI evaluation, and formal legal review.

---

## Project Status

- **Phase 0 — Documentation and Governance Foundation:** Complete
- **Phase 1 — Engineering Scaffold and Tooling:** Next (Scaffolding NestJS, FastAPI, Angular, Docker Compose, CI)
- **Maintainer:** Dy Rongrath (Solo project owner & maintainer)

---

## Key Capabilities & Roadmap

| # | Capability | Target Phase |
|---|---|---|
| 1 | Engineering scaffold, local Docker Compose, & CI tooling | Phase 1 |
| 2 | Development MCP adoption & read-only tools | Phase 2 |
| 3 | Authentication & multi-tenant organisation management | Phase 3 |
| 4 | Secure document upload & quarantine malware validation | Phase 4 |
| 5 | Audit logging, OpenTelemetry & Prometheus observability | Phase 5 |
| 6 | Khmer & English document classification model | Phase 6 |
| 7 | Human review workflow for uncertain AI predictions | Phase 7 |
| 8 | Structured information extraction | Phase 8 |
| 9 | Multilingual AI assistant & LLM prompt-injection defenses | Phase 9 |
| 10 | MLOps pipeline, drift detection, & model cards | Phase 10 |
| 11 | Verifiable credential issuance & QR verification (SD-JWT VC) | Phase 11 |
| 12 | Flutter mobile credential wallet | Phase 12 |
| 13 | Secure inter-organisation data exchange | Phase 13 |
| 14 | European data-space integration (EDC connector) | Phase 14 |
| 15 | Product-facing MCP capabilities | Phase 15 |
| 16 | Production hardening, Kubernetes, & Cosign signed releases | Phase 16 |

---

## Local-First & Low-Cost Principles

The platform is designed to support local-first engineering and low-cost accessibility:

- **Single Developer & Community Friendly:** Maintained by Dy Rongrath with simple, maintainable governance for open-source contributors.
- **Zero Paid Cloud Requirement:** Early development runs entirely on a single machine without requiring paid cloud API subscriptions or proprietary vendor lock-in.
- **Apple Silicon M5 Optimization:** Local infrastructure and container targets execute natively on Apple Silicon (ARM64) without forced x86 emulation.
- **Minimal Resource Footprint:** Modular monorepo design ensures lightweight memory and CPU usage during local execution.

---

## Documentation Hierarchy

| Document | Purpose |
|---|---|
| [AGENTS.md](AGENTS.md) | Primary AI-agent guardrails, open-source rules, and approval boundaries |
| [PROJECT_CONTEXT.md](PROJECT_CONTEXT.md) | Product purpose, target users, business capabilities, glossary, and open-source constraints |
| [ARCHITECTURE.md](ARCHITECTURE.md) | System design, module responsibilities, trust boundaries, data flows, and MCP boundary |
| [SECURITY.md](SECURITY.md) | Security policy, file upload security, secrets management, and disclosure guidelines |
| [MCP_SECURITY.md](MCP_SECURITY.md) | Model Context Protocol security rules, tool allowlisting, and versioning policy |
| [DEVELOPMENT.md](DEVELOPMENT.md) | Technical standards, coding guidelines, commit rules, and definition of done |
| [TESTING.md](TESTING.md) | Testing strategy, planned quality gates, coverage thresholds, and security testing |
| [DATA_GOVERNANCE.md](DATA_GOVERNANCE.md) | Data sourcing rules, anonymisation, dataset lineage (DVC), and retention policy |
| [AI_GOVERNANCE.md](AI_GOVERNANCE.md) | Permitted AI uses, mandatory human oversight, model cards, and responsible-AI policy |
| [ROADMAP.md](ROADMAP.md) | 16-phase implementation roadmap |
| [LICENSE](LICENSE) | Official Apache License 2.0 legal text |
| [NOTICE](NOTICE) | Project copyright and primary attribution notice |
| [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) | Third-party legal and community text attributions (DCO 1.1, Contributor Covenant v3.0) |
| [DCO.md](DCO.md) | Developer Certificate of Origin 1.1 sign-off guidelines |
| [GOVERNANCE.md](GOVERNANCE.md) | Maintainer governance model, commercial neutrality, and trademark policy |
| [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) | Contributor Covenant 3.0 community standards |
| [SUPPORT.md](SUPPORT.md) | Best-effort community support policy |
| [CHANGELOG.md](CHANGELOG.md) | Project release changelog and semver policy |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Contribution workflow, PR rules, and DCO sign-off requirements |
| [docs/open-source-dependency-policy.md](docs/open-source-dependency-policy.md) | Open-source dependency evaluation and licensing rules |
| [docs/adr/](docs/adr/) | Architecture Decision Records (ADR-0001 through ADR-0008) |
| [docs/threat-model.md](docs/threat-model.md) | STRIDE threat model (including 15 MCP threat categories) |
| [docs/templates/](docs/templates/) | Reusable task templates (feature, bug-fix, mcp-integration, etc.) |
| [docs/roles/](docs/roles/) | Specialist AI agent role instructions |

---

## Technology Stack

| Layer | Technology |
|---|---|
| Backend | Node.js 24 · TypeScript · NestJS · PostgreSQL 17 · Prisma |
| AI Service | Python 3.12 · FastAPI · PyTorch · Hugging Face Transformers · uv |
| Frontend | Angular · TypeScript · Angular Signals |
| Mobile | Flutter (Phase 12) |
| AI Development | Model Context Protocol (MCP) · OpenAI Codex CLI · GitHub MCP · Context7 |
| Authentication | Keycloak 26 · OAuth 2.1 · OIDC · WebAuthn / Passkeys |
| Infrastructure | Docker · Docker Compose · (Kubernetes in Phase 16) |

---

## Repository Structure (Phase 0 Foundation)

```
trusted-ai-platform/
├── .github/
│   ├── ISSUE_TEMPLATE/       # Structured GitHub issue forms
│   └── PULL_REQUEST_TEMPLATE.md # Pull request checklist & DCO verification
├── docs/
│   ├── adr/                  # ADR-0001 through ADR-0008
│   ├── threat-model.md       # STRIDE threat model (including 15 MCP threats)
│   ├── open-source-dependency-policy.md # Dependency licensing rules
│   ├── templates/            # Task templates
│   └── roles/                # Specialist AI agent role instructions
├── AGENTS.md                 # Primary AI agent instructions & open-source guardrails
├── PROJECT_CONTEXT.md        # Product context, open-source scope, constraints
├── ARCHITECTURE.md           # System architecture & MCP boundary
├── SECURITY.md               # Security policy & data classification
├── MCP_SECURITY.md           # Model Context Protocol security policy
├── DEVELOPMENT.md            # Technical standards & local setup
├── TESTING.md                # Testing strategy & planned quality gates
├── DATA_GOVERNANCE.md        # Data sourcing, lineage & retention
├── AI_GOVERNANCE.md          # Permitted/prohibited AI uses & human oversight
├── ROADMAP.md                # 16-phase implementation roadmap
├── LICENSE                   # Official Apache License 2.0 legal text
├── NOTICE                    # Project copyright notice
├── THIRD_PARTY_NOTICES.md    # Third-party standard legal text attributions
├── DCO.md                    # Developer Certificate of Origin 1.1 rules
├── GOVERNANCE.md             # Maintainer governance & trademark policy
├── CODE_OF_CONDUCT.md        # Contributor Covenant 3.0 standards
├── SUPPORT.md                # Best-effort community support policy
├── CHANGELOG.md              # Project changelog (semver pre-release)
├── CONTRIBUTING.md           # Contribution guidelines & PR checklist
├── README.md                 # Repository overview
├── .gitignore                # Git ignore rules (secrets & MCP config)
├── .gitattributes           # Line-ending normalisation
└── .nvmrc                    # Pinned Node.js 24.15.0 version
```

---

## Planned Application Structure (Target Phase 1 Scaffolding)

```
trusted-ai-platform/
├── apps/
│   ├── backend/          # NestJS API server
│   ├── ai-service/       # FastAPI AI inference service
│   └── frontend/         # Angular web application
├── packages/
│   └── shared-types/     # Shared TypeScript types & OpenAPI schema client
├── infra/
│   └── docker/           # Docker Compose local development environment
└── [Foundation & Open-Source documents]
```

---

## Contributing & Developer Setup

The repository is open for review and limited contributions. Full external contributor onboarding remains pending configuration of a private conduct reporting channel.

Please review our contribution guides before submitting a pull request:

1. Read [AGENTS.md](AGENTS.md) and [CONTRIBUTING.md](CONTRIBUTING.md).
2. Check open issues or create a new issue using our [GitHub Issue Templates](.github/ISSUE_TEMPLATE/).
3. Sign off all commits using Developer Certificate of Origin (`git commit -s`, see [DCO.md](DCO.md)).
4. Follow the [Code of Conduct](CODE_OF_CONDUCT.md).

See [DEVELOPMENT.md](DEVELOPMENT.md) for detailed technical setup instructions.

---

## Security Reporting

This platform processes sensitive documents and credentials. If you discover a security vulnerability, please follow our disclosure policy in [SECURITY.md](SECURITY.md). **Do not report security vulnerabilities in public GitHub issues.**

---

## Open-Source Licence

The project’s original source code, infrastructure code, and original documentation are licensed under the **Apache License 2.0**.
See [LICENSE](LICENSE) for the official licence text and [NOTICE](NOTICE) for project copyright details.

Third-party standard legal and community texts ([THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)), third-party datasets, model weights, fonts, icons, media, dependencies, and user-uploaded content remain subject to their respective upstream licences and terms (see [docs/open-source-dependency-policy.md](docs/open-source-dependency-policy.md)).
