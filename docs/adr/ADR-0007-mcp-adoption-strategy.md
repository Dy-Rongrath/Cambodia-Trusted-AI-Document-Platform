# ADR-0007 — Model Context Protocol (MCP) Adoption Strategy and Governance

## Status

`Accepted`

## Decision Owner / Approved By

Dy Rongrath, Project Owner — approved through review and merge of PR #1 on 2026-08-01.

## Date

2026-08-01

## Context

The Model Context Protocol (MCP) provides a standard JSON-RPC protocol for AI agents (MCP clients) to connect to tools, data sources, and documentation servers (MCP servers). Adopting MCP can significantly accelerate developer productivity by giving AI coding assistants up-to-date documentation and scoped repository context.

However, ungoverned MCP integration introduces critical security risks:

- Exposing secrets if configuration files containing credentials (e.g. GitHub PATs) are committed.
- Unintended execution of shell commands, database queries, or write actions if broad tools are enabled.
- Prompt injection via retrieved file contents or documentation tool outputs.
- Supply-chain risks from unvetted third-party MCP servers.

Clear architectural and governance decisions are required to define how MCP is adopted safely.

## Decision

We adopt a **phased, read-only-first Model Context Protocol (MCP) adoption strategy** governed by `MCP_SECURITY.md` and `AGENTS.md`.

Specific decision choices:

1. **MCP Client (D-MCP-1):** OpenAI Codex CLI using `.codex/config.toml` (gitignored) for per-project workspace configuration.
2. **Initial Stage 1 MCP Servers (D-MCP-2):**
   - **GitHub MCP Server** (Docker container `ghcr.io/github/github-mcp-server:<PINNED_VERSION>`) with fine-grained read-only Personal Access Token (PAT) forwarded via `GITHUB_PERSONAL_ACCESS_TOKEN`, with `GITHUB_READ_ONLY=1` and `GITHUB_LOCKDOWN_MODE=1` explicitly enabled.
   - **Context7 MCP Server** (`@upstash/context7-mcp@<PINNED_VERSION>` via stdio) for version-specific official library documentation (NestJS, Prisma, FastAPI, Angular, PyTorch).
3. **Credential Management (D-MCP-3):** Credentials (such as GitHub PAT) are exported as environment variables in the developer's local shell profile and referenced via `env_vars` in `.codex/config.toml` (`mcp_servers` block). The config file is strictly **gitignored**. No credentials or tokens are stored in configuration files, source control, or `.env` files.
4. **Hosting Model (D-MCP-4):**

   - **Stages 1–3:** Local-only stdio and Docker processes running on the developer's machine.
   - **Post-Phase 1 Team Sharing:** Transition GitHub server to GitHub's managed remote endpoint (`https://api.githubcopilot.com/mcp/`) after Phase 1 code is validated, leveraging GitHub Copilot OAuth authentication for team access.

5. **Tool Restrictions:** All state-modifying write tools (`create_pull_request`, `push_files`, generic shell execution, SQL execution) are disabled. Only read-only context tools are approved in Stages 1–2.
6. **Tool Output Security:** All tool outputs from MCP servers are treated strictly as untrusted data. The AI agent must not execute instructions embedded in retrieved file contents or issue bodies.

## Alternatives Considered

| Option                                 | Description                                             | Why rejected or deferred                                                                                                                         |
| -------------------------------------- | ------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| Claude Desktop / Cursor client         | IDE-integrated MCP clients                              | Codex CLI is chosen as the primary client. Cursor remains a valid alternative; both follow the same gitignored per-project configuration policy. |
| Unrestricted third-party MCP servers   | Installing public MCP marketplace servers directly      | Rejected due to supply-chain risk and lack of security review. Every server requires a 16-point review before installation.                      |
| Storing PATs in `.env` files           | Putting MCP credentials in `.env`                       | Rejected. `.env` files are for application configuration. `.codex/config.toml` isolates developer tool secrets.                                  |
| Full write access tools in Stage 1     | Enabling automated PR creation and file pushing via MCP | Rejected. Human approval is mandatory for all repository state changes (`AGENTS.md` Section 13).                                                 |
| Custom internal MCP server immediately | Building a custom NestJS/Python MCP server in Phase 0/1 | Deferred. Custom MCP servers will only be considered in Stage 3 if read-only Stage 1/2 tools prove insufficient.                                 |

## Consequences

### Positive consequences

- Developers gain real-time, accurate context from official documentation and repository state.
- Prevents documentation hallucinations for fast-evolving libraries (FastAPI, Prisma, NestJS).
- Strict gitignore rules and read-only PAT scopes minimise credential exposure risk.
- Explicit approval boundaries prevent unauthorized automated write actions.

### Negative consequences / trade-offs

- Developers must manually set up `.codex/config.toml` and generate a read-only GitHub PAT.
- External API calls to Context7/Upstash are made for documentation lookups (no personal data transmitted).

## Security Impact

- See `MCP_SECURITY.md` for full security controls.
- 15 MCP threat categories added to `docs/threat-model.md` (T-MCP-001 through T-MCP-015).
- `.gitignore` updated to block `.codex/config.toml`, `.codex/`, `.mcp-credentials`, and `mcp-server-config.json`.
- Gitleaks secret scanning and pre-commit secret checks must be configured in Phase 1 before code or credentials are introduced.

## Operational Impact

- MCP is purely a **developer productivity tool** for Phases 1–14. It is completely isolated from application runtime and production infrastructure.
- Zero impact on production build artifacts, Docker images, or application deployment.

## Review Conditions

- Review when switching from local GitHub Docker server to GitHub managed remote endpoint after Phase 1.
- Review if any write-capable tool is requested for Stage 2.
- Review if a new third-party MCP server is proposed.
