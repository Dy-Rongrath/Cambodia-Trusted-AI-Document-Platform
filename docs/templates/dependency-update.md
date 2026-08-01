# Task Template: Dependency Update

> Use this template for every dependency update, whether security-driven or routine.

---

## Objective

Update [dependency name] from [current version] to [target version].

## Reason

- [ ] Security vulnerability (CVE: [ID] — Severity: [Critical / High / Medium / Low])
- [ ] Bug fix in the dependency.
- [ ] New feature required by the platform.
- [ ] Routine maintenance update.

## Dependency details

| Field                      | Value                                                                  |
| -------------------------- | ---------------------------------------------------------------------- |
| **Package name**           |                                                                        |
| **Current version**        |                                                                        |
| **Target version**         |                                                                        |
| **Package manager**        | npm / uv                                                               |
| **Affected workspace**     | apps/backend / apps/ai-service / apps/frontend / packages/shared-types |
| **Licence**                | [Confirm licence has not changed]                                      |
| **Changelog**              | [Link to CHANGELOG or release notes]                                   |
| **Known breaking changes** | Yes / No — describe if yes                                             |

## Vulnerability details (if security-driven)

- **CVE ID:** [e.g., CVE-2025-XXXX]
- **Severity:** Critical / High / Medium / Low
- **CVSS score:** [e.g., 9.8]
- **Description:** [Brief description of the vulnerability]
- **Affected code paths:** [Which platform features use the vulnerable code path?]
- **Exploitability in this platform:** [Is the vulnerable code path exercised in this project?]

## Breaking changes assessment

[Describe any breaking changes introduced by this version and what code changes are required to accommodate them.]

## Testing plan

- [ ] Run `npm audit` / `uv audit` after update — confirm vulnerability resolved.
- [ ] Run all unit tests.
- [ ] Run all integration tests.
- [ ] Run affected end-to-end tests.
- [ ] Manual smoke test of the most affected features.

## Rollback plan

[Revert to the previous version by running `npm install <package>@<previous-version>` and committing the updated lock file.]

## Approval requirements

- [ ] Major version updates require approval (potential breaking changes).
- [ ] Security updates: if severity is Critical or High, treat as a priority fix — normal approval process still applies.
