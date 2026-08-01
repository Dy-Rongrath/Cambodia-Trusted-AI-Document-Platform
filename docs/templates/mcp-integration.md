# Task Template: MCP Integration Proposal

> Use this template when proposing a new MCP server integration or capability. Complete all sections before submitting for approval.

---

## Objective

[What MCP integration is being proposed and why it is needed for development productivity or product capabilities.]

## Server Details

| Field                      | Value                                                             |
| -------------------------- | ----------------------------------------------------------------- |
| **Server Name**            | [e.g. github-mcp-server]                                          |
| **Source / Repository**    | [URL or npm package / Docker image tag]                           |
| **Publisher / Maintainer** | [Official org, trusted vendor, open-source maintainer]            |
| **Transport Type**         | stdio / Streamable HTTP / Docker stdio                            |
| **Target Environment**     | Local Development (Stages 1–3) / Staging / Production (Phase 15+) |

## Proposed Tools and Capabilities

| Tool Name | Scope / Action     | Access Level | Purpose       |
| --------- | ------------------ | ------------ | ------------- |
| [tool_1]  | Read-only search   | Read-only    | [Description] |
| [tool_2]  | Read file contents | Read-only    | [Description] |

## Security & Privacy Impact

- [ ] Security review template (`docs/templates/mcp-server-review.md`) completed.
- [ ] Tool access default is Read-Only.
- [ ] No write, generic shell execution, or arbitrary SQL execution tools enabled.
- [ ] Credentials (if required) stored in `.codex/config.toml` (gitignored).
- [ ] No personal data, sensitive documents, or production secrets passed in tool arguments.
- [ ] Network destinations verified: [List external hosts/APIs contacted].

## Audit & Observability

- [ ] Audit logging configured for tool invocations.
- [ ] Timeouts configured (max 30s per tool call).

## Rollback / Removal Plan

1. Remove server block from `.codex/config.toml`.
2. Revoke associated API tokens or access keys.
3. Verify client operates cleanly without server (`codex mcp list`).

## Approval Requirements

- [ ] **Approval Required:** Installing or connecting any MCP server requires explicit human approval per `AGENTS.md` Section 13.
