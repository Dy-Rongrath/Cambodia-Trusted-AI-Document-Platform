# Pull Request Summary

## Description
Provide a concise summary of the changes made and the problem being solved.

## Related Issue
Fixes # (issue number)

## Roadmap Phase
Targeted Phase: e.g. Phase 0, Phase 1

## Type of Change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Documentation update
- [ ] Security / Refactoring

## Architectural & Governance Impact
- Does this change require an Architecture Decision Record (ADR)? Yes/No
- Does this change modify security, authentication, tenant isolation, or MCP rules? Yes/No

## Resource & Platform Impact
- [ ] Verified native execution on Apple Silicon (M5 / ARM64).
- [ ] Requires zero paid cloud infrastructure services during local development.

## Testing & Verification Performed
Describe the commands and tests executed to verify the change:
- [ ] Code formatting & linting (`npm run lint`, `uv run ruff check`)
- [ ] Type checking (`tsc --noEmit`, `uv run mypy`)
- [ ] Unit & integration tests (`npm test`, `uv run pytest`)
- [ ] Documentation links and formatting verified

---

## Contributor Checklist

- [ ] I have read [AGENTS.md](AGENTS.md) and relevant project policies.
- [ ] The change is focused and contains no unsolicited or unrelated refactoring.
- [ ] No secrets, passwords, API tokens, or `.env` files are included.
- [ ] No real government, NSSF, personal, client, or production data are included.
- [ ] New dependencies (if any) are necessary, pinned, permissively licensed (Apache-2.0 / MIT / BSD / ISC), and documented in `docs/open-source-dependency-policy.md`.
- [ ] All tests and validation pass locally.
- [ ] Relevant documentation has been created or updated.
- [ ] I understand and take responsibility for the code I am submitting.
- [ ] My commits include DCO sign-off (`git commit -s` / `Signed-off-by: Name <email>`).
