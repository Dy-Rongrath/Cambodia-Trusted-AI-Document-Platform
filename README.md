# Cambodia Trusted AI Document Platform

> **A production-grade, privacy-first platform for secure Khmer and English document processing, AI-assisted classification, digital identity, and verifiable credentials.**

---

## Project status

**Phase 0 — Engineering Foundation (complete)**

All foundation documents have been created. The platform is ready for Phase 1 (code implementation).

## Documentation

| Document | Purpose |
|---|---|
| [PROJECT_CONTEXT.md](PROJECT_CONTEXT.md) | Product purpose, users, scope, glossary, and success criteria |
| [ARCHITECTURE.md](ARCHITECTURE.md) | System design, module responsibilities, trust boundaries, data flows, and MCP boundary |
| [SECURITY.md](SECURITY.md) | Security policy, controls, and incident response |
| [MCP_SECURITY.md](MCP_SECURITY.md) | Model Context Protocol security rules, tool governance, and client setup |
| [DEVELOPMENT.md](DEVELOPMENT.md) | Local setup, coding standards, MCP dev workflow, definition of done |
| [TESTING.md](TESTING.md) | Testing strategy, quality gates, coverage thresholds, MCP security testing |
| [DATA_GOVERNANCE.md](DATA_GOVERNANCE.md) | Data sourcing rules, lineage, retention, and governance |
| [AI_GOVERNANCE.md](AI_GOVERNANCE.md) | Permitted AI uses, human oversight, model governance, responsible-AI commitments |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Contribution guidelines, PR requirements, and security rules |
| [ROADMAP.md](ROADMAP.md) | 16-phase implementation plan |
| [docs/adr/](docs/adr/) | Architecture Decision Records (ADR-0001 through ADR-0007) |
| [docs/threat-model.md](docs/threat-model.md) | STRIDE threat model (including MCP threat categories) |
| [docs/templates/](docs/templates/) | Reusable task templates (feature, bug-fix, mcp-integration, mcp-review, etc.) |
| [docs/roles/](docs/roles/) | Specialist AI agent role instructions |
| [.agents/AGENTS.md](.agents/AGENTS.md) | AI-agent guardrails and approval boundaries |

## Technology stack

| Layer | Technology |
|---|---|
| Backend | Node.js 24 · TypeScript · NestJS · PostgreSQL 17 · Prisma |
| AI Service | Python 3.12 · FastAPI · PyTorch · Hugging Face Transformers · uv |
| Frontend | Angular · TypeScript · Angular Signals |
| Mobile | Flutter (Phase 12) |
| AI Development | Model Context Protocol (MCP) · OpenAI Codex CLI · GitHub MCP · Context7 |
| Authentication | Keycloak 26 · OAuth 2.1 · OIDC · WebAuthn / Passkeys |
| Infrastructure | Docker · Docker Compose · (Kubernetes in Phase 16) |


## Repository structure

```
trusted-ai-platform/
├── apps/
│   ├── backend/          # NestJS API server
│   ├── ai-service/       # FastAPI AI inference service
│   └── frontend/         # Angular web application
├── packages/
│   └── shared-types/     # Shared TypeScript types
├── infra/
│   └── docker/           # Docker Compose files
├── docs/
│   ├── adr/              # Architecture Decision Records
│   ├── templates/        # Task templates
│   ├── roles/            # AI agent role instructions
│   └── threat-model.md
└── [Foundation documents]
```

## Developer setup

See [DEVELOPMENT.md](DEVELOPMENT.md) for complete setup instructions.

**Quick reference:**
```bash
nvm use                          # Activate Node 24.15.0
npm install                      # Install workspace dependencies
cd apps/ai-service && uv sync    # Set up Python environment
docker compose -f infra/docker/docker-compose.yml up -d  # Start infrastructure
```

## Security

This platform processes sensitive documents. All contributors must read [SECURITY.md](SECURITY.md) and [AGENTS.md](.agents/AGENTS.md) before contributing.

**Critical rules:**
- Never use real personal, government, or production data in development.
- Never commit `.env` files.
- All security-sensitive changes require human review before merging.

## Licence

To be determined.
