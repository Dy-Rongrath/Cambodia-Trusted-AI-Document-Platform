# Task Template: MCP Tool Addition

> Use this template when proposing to add or enable a new tool on an existing approved MCP server.

---

## Objective

[Describe the new tool capability being added and why it is required.]

## Tool Specification

- **Parent MCP Server:** [Server name]
- **Tool Identifier:** [Name of tool function]
- **Tool Access Level:** Read-only / Stateful Write (requires explicit approval)
- **Input Parameters:**
  ```json
  {
    "param_1": "type and description",
    "param_2": "type and description"
  }
  ```

## Security & Validation Checks

- [ ] Parameter validation schema is strictly defined.
- [ ] Tool parameters reject arbitrary code execution, SQL strings, or path traversal syntax (`../`).
- [ ] Output sanitisation is implemented (output treated as untrusted data).
- [ ] Tool does not expose secrets, credentials, or personal data in returns.
- [ ] If tool is state-modifying: human approval requirement is explicitly enforced in agent rules.

## Verification Command

```bash
# Test MCP tool call via Codex CLI or test script
codex mcp call <server_name> <tool_name> '<arguments_json>'
```
