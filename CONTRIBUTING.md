# Contributing Guidelines — Cambodia Trusted AI Document Platform

Thank you for your interest in contributing to the **Cambodia Trusted AI Document Platform**!

This project is an open-source, privacy-first platform licensed under the [Apache License 2.0](LICENSE). We welcome contributions from developers, security researchers, AI specialists, and documentation authors.

---

## 1. Before Contributing

Before writing code or documentation:

1. Read [README.md](README.md) and [PROJECT_CONTEXT.md](PROJECT_CONTEXT.md) to understand the platform's vision, scope, and pre-release maturity model.
2. Read [AGENTS.md](AGENTS.md) — mandatory guidelines for AI-assisted development and human approval boundaries.
3. Read [GOVERNANCE.md](GOVERNANCE.md), [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md), and [SECURITY.md](SECURITY.md).
4. Search existing GitHub Issues and Pull Requests to avoid duplicate work.
5. Review [docs/open-source-dependency-policy.md](docs/open-source-dependency-policy.md) before proposing any new third-party dependency.

> **Privacy & Security Rule:** Never submit real personal identification, government, client, organisational, confidential, or production data. Always use synthetic test data fixtures.

---

## 2. Contribution Workflow

We follow **Trunk-Based Development** with focused, short-lived feature branches:

### Step 1: Create a Branch

Fork the repository or create a branch from `main` using standard prefix conventions:

- `feat/<description>` — New feature or capability
- `fix/<description>` — Bug fix
- `docs/<description>` — Documentation or governance updates
- `security/<description>` — Security enhancements or vulnerability fixes
- `chore/<description>` — Maintenance, tooling, or dependency updates

### Step 2: Make Focused Changes

- Keep changes small, self-contained, and focused on a single purpose.
- Do not perform unsolicited refactoring or styling changes outside your task scope.
- Follow technical standards defined in [DEVELOPMENT.md](DEVELOPMENT.md).

### Step 3: DCO Sign-off on Commits

All contributions must be certified under the **Developer Certificate of Origin (DCO 1.1)**. Sign off every commit message using `git commit -s`:

```bash
git commit -s -m "feat(auth): validate JWT audience claim via Keycloak JWKS"
```

This adds a `Signed-off-by: Your Name <your.email@example.com>` line certifying that you have the legal right to submit your work under the Apache-2.0 licence (see [DCO.md](DCO.md)). Automated DCO bot enforcement is not currently configured.

### Step 4: Run Validation

Run local linters, type checks, and tests before opening a PR:

```bash
npm run lint         # TypeScript/NestJS linting
tsc --noEmit         # Type check
uv run ruff check    # Python AI service linting
```

### Step 5: Submit a Pull Request

- Open a PR against the `main` branch using our [.github/PULL_REQUEST_TEMPLATE.md](.github/PULL_REQUEST_TEMPLATE.md).
- Ensure all items in the PR checklist are completed.
- Address review feedback promptly. The project maintainer will review and merge approved PRs.

---

## 3. Pull Request Expectations

Every pull request must meet the following criteria:

- **Single Purpose:** Solves one clear issue or implements one documented feature.
- **Clear Description:** Explains what changed and why, linking to relevant GitHub Issues.
- **Tests Included:** Unit and integration tests cover success, failure, and security edge cases.
- **Documentation Updated:** Relevant specifications, ADRs, or README files are updated to reflect the code changes.
- **Zero Secrets:** Automated secret scanning is not currently configured. Contributors and maintainers must manually inspect changes for credentials, tokens, private keys, personal data, and restricted configuration until a scanner is implemented (`.env` files or secret tokens strictly prohibited).
- **No Real Data:** Synthetic data fixtures only.
- **Dependency Compliance:** Every dependency and asset must have a known licence and complete the review process in [docs/open-source-dependency-policy.md](docs/open-source-dependency-policy.md). Generally approved permissive licences use normal maintainer review; copyleft, source-available, custom, or restricted terms require explicit maintainer and legal review.
- **Architecture Compliance:** Architecture or auth changes include an approved ADR in `docs/adr/`.
- **DCO Certification:** All commits include valid `Signed-off-by` lines (`git commit -s`).

---

## 4. AI-Assisted Contribution Rules

AI coding assistants (such as OpenAI Codex CLI, GitHub Copilot, or Claude) are welcome tools, but contributors must adhere to strict responsible-AI rules:

1. **Human Understanding Mandatory:** Contributors must review, understand, and take full responsibility for all AI-generated code submitted in a pull request.
2. **Licensing Integrity:** AI outputs must not introduce code snippets copied from third-party repositories with un-cleared or copyleft licences.
3. **No Automated Self-Approval:** AI agents and automated bots cannot approve or merge pull requests (`AGENTS.md` Section 7).
4. **Accurate PR Descriptions:** PR summaries generated by AI tools must accurately describe actual code changes without hallucinated features or non-existent test evidence.
5. **AGENTS.md Compliance:** All AI-assisted contributions must strictly follow [AGENTS.md](AGENTS.md).

---

## 5. Getting Help & Contact

- **Questions & Proposals:** Use the most appropriate [GitHub Issue Form](.github/ISSUE_TEMPLATE/) for questions or proposals that can be discussed publicly.
- **Bug Reports:** Open a GitHub Issue using the [Bug Report Form](.github/ISSUE_TEMPLATE/bug_report.yml).
- **Security Disclosures:** Follow [SECURITY.md](SECURITY.md) to submit a confidential security advisory under the Security tab.

Thank you for contributing to the Cambodia Trusted AI Document Platform!
