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
- [ ] Documentation / Legal / Governance update
- [ ] Security / Refactoring

## Architectural & Governance Impact

- Does this change require an Architecture Decision Record (ADR)? Yes/No
- Does this change modify security, authentication, tenant isolation, or MCP rules? Yes/No

## Resource & Platform Impact

- [ ] Verified native execution on Apple Silicon (ARM64) / Linux ARM64 / x86_64.
- [ ] Requires zero paid cloud infrastructure services during local development.

## Testing & Verification Performed

Describe the commands and tests executed to verify the change (or N/A for documentation-only PRs):

- [ ] Code formatting & linting (`./scripts/docker/lint.sh`)
- [ ] Type checking (`./scripts/docker/typecheck.sh`)
- [ ] Unit tests (`./scripts/docker/test.sh`)
- [ ] Documentation links, formatting, and legal notices verified

---

## Contributor Checklist

- [ ] **Non-Security Confirmation:** This PR is NOT a security vulnerability disclosure. (Security vulnerabilities must be submitted confidentially under the Security tab per SECURITY.md).
- [ ] **Policy & Rule Compliance:** I have read [AGENTS.md](AGENTS.md) and relevant project policies.
- [ ] **Focused Scope:** The change is focused and contains no unsolicited or unrelated refactoring.
- [ ] **Planned Control Transparency:** Planned future controls (e.g. CI scanners, DCO bots) are NOT described as already active or implemented.
- [ ] **Legal & Attribution:** Third-party texts, standard specifications, or assets include required attribution and licence notices in `THIRD_PARTY_NOTICES.md`.
- [ ] **Zero Secrets & Real Data:** No secrets, API tokens, `.env` files, or real personal/government data are included.
- [ ] **Dependency Compliance:** New dependencies and assets have known licences, are pinned where appropriate, are documented, and have completed the required dependency-review process ([docs/open-source-dependency-policy.md](docs/open-source-dependency-policy.md)).
- [ ] **DCO Certification:** My commits include DCO sign-off (`git commit -s` / `Signed-off-by: Name <email>`).
- [ ] **Understanding:** I understand and take responsibility for the code and documentation I am submitting.
