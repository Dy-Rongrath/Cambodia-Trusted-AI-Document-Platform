# Contributing Guidelines — Cambodia Trusted AI Document Platform

Thank you for contributing to the Cambodia Trusted AI Document Platform!

This document outlines the workflow, coding standards, and security requirements for contributing to this repository.

---

## 1. Core Principles

Before writing any code or documentation, read the foundational documents:
- [AGENTS.md](.agents/AGENTS.md) — Mandatory AI agent & developer guardrails.
- [SECURITY.md](SECURITY.md) — Core security policies and data classification.
- [MCP_SECURITY.md](MCP_SECURITY.md) — Model Context Protocol security rules.
- [DEVELOPMENT.md](DEVELOPMENT.md) — Technical coding standards and setup guide.
- [TESTING.md](TESTING.md) — Testing strategy and quality gates.

---

## 2. Branching & Commit Workflow

We follow **Trunk-Based Development** with short-lived feature branches:

1. Create a branch from `main`:
   - Feature: `feat/<description>`
   - Bug fix: `fix/<description>`
   - Security: `security/<description>`
   - Docs: `docs/<description>`
2. Follow **Conventional Commits** format:
   ```
   <type>(<scope>): <short summary>

   [optional body]
   ```
   *Example:* `feat(auth): validate JWT audience claim via Keycloak JWKS`

---

## 3. Pull Request Requirements

Every pull request must include:
- A completed task template from `docs/templates/`.
- Unit and integration tests covering success, failure, and security boundary cases.
- Verification evidence (`npm test`, `uv run pytest`, `npm run lint`, `tsc --noEmit`).
- No committed `.env` files or secrets (verified by Gitleaks).
- Documentation updates matching the code changes.

---

## 4. Security & Data Policy

- **No Real Data:** Never commit or process real government, NSSF, client, or personal identification data during development. Use synthetic test data only.
- **No Secrets:** Never commit passwords, private keys, API tokens, or `.codex/config.toml` files.
- **Approval Boundaries:** Major dependencies, schema changes, auth policy changes, and MCP server installations require explicit approval before execution (`AGENTS.md` Section 13).
