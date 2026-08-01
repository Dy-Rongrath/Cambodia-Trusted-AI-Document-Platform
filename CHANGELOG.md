# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/2.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

The project is currently in **pre-release development**. `0.x` versions represent pre-release development iterations and may contain breaking changes. The `1.0.0` release will represent the first supported, production-ready contract after Phase 16 completion.

---

## [Unreleased]

### Added

- **Phase 1 Engineering Scaffold & Tooling:** Scaffolding NestJS backend (`apps/backend`), FastAPI AI service (`apps/ai-service`), standalone Angular frontend (`apps/frontend`), shared TypeScript types (`packages/shared-types`), root npm workspaces, multi-stage Dockerfiles, local Docker Compose environment (`compose.yaml`), POSIX helper scripts (`scripts/docker/`), and Docker-based GitHub Actions CI pipeline (`.github/workflows/ci.yml`).
- **Prisma & Database Connectivity:** Initialized Prisma in NestJS backend with postgresql provider and `SELECT 1` connectivity script (`npm run db:check`).
- **Dependency Inventory:** Created [docs/dependency-inventory.md](docs/dependency-inventory.md) auditing Node, Python, and container image dependencies, licenses, and ARM64 compatibility.
- **Phase 0 Documentation & Governance Foundation:** Complete initial foundation documents ([AGENTS.md](AGENTS.md), [PROJECT_CONTEXT.md](PROJECT_CONTEXT.md), [ARCHITECTURE.md](ARCHITECTURE.md), [SECURITY.md](SECURITY.md), [MCP_SECURITY.md](MCP_SECURITY.md), [DEVELOPMENT.md](DEVELOPMENT.md), [TESTING.md](TESTING.md), [DATA_GOVERNANCE.md](DATA_GOVERNANCE.md), [AI_GOVERNANCE.md](AI_GOVERNANCE.md), [ROADMAP.md](ROADMAP.md)).
- **Architecture Decision Records:** Established ADR-0001 through ADR-0007 (foundational stack & MCP strategy) and proposed [ADR-0008](docs/adr/ADR-0008-local-object-storage-strategy.md) for local object storage evaluation.
- **Open-Source Legal Foundation:** Adopted official [Apache License 2.0](LICENSE) for software and documentation, created [NOTICE](NOTICE) for project copyright, and established [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) for third-party standard text attributions.
- **Developer Certificate of Origin (DCO):** Added official [DCO.md](DCO.md) with verbatim Developer Certificate of Origin 1.1 text and established `git commit -s` sign-off policy for contributions.
- **Community Governance & Health:** Established [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) (Contributor Covenant v3.0), [GOVERNANCE.md](GOVERNANCE.md), [SUPPORT.md](SUPPORT.md), and [docs/open-source-dependency-policy.md](docs/open-source-dependency-policy.md).
- **GitHub Community Templates:** Created structured issue forms ([.github/ISSUE_TEMPLATE/](.github/ISSUE_TEMPLATE/)), issue chooser config, and pull request template ([.github/PULL_REQUEST_TEMPLATE.md](.github/PULL_REQUEST_TEMPLATE.md)).
- **Documented Security Reporting Workflow:** Documented a private vulnerability-reporting workflow in [SECURITY.md](SECURITY.md). Enabled GitHub Private Vulnerability Reporting at repository level.
