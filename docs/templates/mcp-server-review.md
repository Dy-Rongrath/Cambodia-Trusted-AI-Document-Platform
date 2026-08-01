# Task Template: MCP Third-Party Server Security Review

> Use this template to perform the mandatory 16-point security review before installing any third-party MCP server.

---

## Target MCP Server

- **Server Name:** [Name]
- **Publisher / Maintainer:** [Org / Author]
- **Repository / Source Code:** [URL]
- **Package / Container Image:** [npm package or Docker image digest]
- **Reviewer:** [Developer / Security Reviewer]
- **Date:** [YYYY-MM-DD]

---

## 16-Point Security Checklist

| #   | Review Item                  | Verification Question                                                      | Pass / Fail     | Findings / Notes |
| --- | ---------------------------- | -------------------------------------------------------------------------- | --------------- | ---------------- |
| 1   | **Maintainer & Publisher**   | Is the server published by an official or trusted maintainer?              | ☐ Pass / ☐ Fail |                  |
| 2   | **Source Code Availability** | Is full source code available and audited?                                 | ☐ Pass / ☐ Fail |                  |
| 3   | **Licence**                  | Is the licence compatible with the project (MIT, Apache 2.0, BSD)?         | ☐ Pass / ☐ Fail |                  |
| 4   | **Required Permissions**     | Are filesystem permissions restricted strictly to workspace path?          | ☐ Pass / ☐ Fail |                  |
| 5   | **Authentication Method**    | Are credentials passed via environment variables in gitignored config?     | ☐ Pass / ☐ Fail |                  |
| 6   | **Data Collected**           | What data is transmitted outbound? (Verify no secrets/personal data sent)  | ☐ Pass / ☐ Fail |                  |
| 7   | **Data Retention**           | Does the external server store or log tool query contents?                 | ☐ Pass / ☐ Fail |                  |
| 8   | **Network Destinations**     | Are network endpoints restricted to known, trusted APIs?                   | ☐ Pass / ☐ Fail |                  |
| 9   | **Dependency Risks**         | Have dependencies been checked with `npm audit` / `uv audit` / Trivy?      | ☐ Pass / ☐ Fail |                  |
| 10  | **Tool Definitions**         | Are tool schemas accurate, honest, and non-misleading?                     | ☐ Pass / ☐ Fail |                  |
| 11  | **Write Capabilities**       | Are all state-changing write, shell execution, or delete tools disabled?   | ☐ Pass / ☐ Fail |                  |
| 12  | **Update Mechanism**         | Is the package version or Docker image tag pinned to a specific hash?      | ☐ Pass / ☐ Fail |                  |
| 13  | **Vulnerability History**    | Are there open or past unpatched CVEs for this server?                     | ☐ Pass / ☐ Fail |                  |
| 14  | **MCP Spec Compatibility**   | Is the server compatible with the current stable MCP specification?        | ☐ Pass / ☐ Fail |                  |
| 15  | **Removal Procedure**        | Is there a documented procedure to cleanly remove and revoke credentials?  | ☐ Pass / ☐ Fail |                  |
| 16  | **Credential Revocation**    | Can credentials used by this server be revoked immediately without impact? | ☐ Pass / ☐ Fail |                  |

---

## Recommendation

- [ ] **APPROVED:** Server passes all 16 checks. Scoped to read-only development use.
- [ ] **CONDITIONAL APPROVAL:** Approved subject to specific tool disables or configuration restrictions: [List restrictions].
- [ ] **REJECTED:** Server fails critical checks. Must not be installed.

---

## Review Approval

- **Reviewed by:** [Security Reviewer Name]
- **Approval Date:** [YYYY-MM-DD]
