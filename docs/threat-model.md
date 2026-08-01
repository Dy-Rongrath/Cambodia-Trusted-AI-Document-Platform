# Threat Model — Cambodia Trusted AI Document Platform

> **Methodology:** STRIDE (Spoofing, Tampering, Repudiation, Information Disclosure, Denial of Service, Elevation of Privilege)
> **Status:** Living document — reviewed and updated each phase.
> **Last updated:** 2026-08-01
> **Classification:** Public project policy — must not contain secrets or restricted operational details.
>
> **Specialist review required** before Phase 14 (production deployment).

---

## Scope

This threat model covers the platform as it will exist at the end of Phase 3 (secure document upload and initial classification). It will be extended as new capabilities are introduced.

**Assets in scope:**
- User credentials and sessions.
- Organisation and tenant data.
- Uploaded document files and metadata.
- Classification results and review decisions.
- AI model weights.
- Training datasets.
- Audit logs.
- Signing keys (Phase 10+).
- Verifiable credentials (Phase 10+).

**Out of scope (will be added in later phases):**
- Inter-organisation data exchange threats (Phase 12).
- European data-space threats (Phase 13).
- Flutter mobile wallet threats (Phase 11).

---

## Threat Register

### Category: Authentication

---

#### T-AUTH-001 — JWT Misuse: Missing or Invalid Signature Verification

| Field | Detail |
|---|---|
| **Asset** | All protected API endpoints |
| **Entry point** | Any HTTP request with a Bearer token |
| **STRIDE category** | Spoofing |
| **Threat** | An attacker crafts a forged JWT token with elevated privileges or a different `organisation_id`. If the backend does not verify the signature, the forged token is accepted. |
| **Impact** | Unauthorised access to any tenant's data. Full privilege escalation. |
| **Likelihood** | Medium (requires knowing the expected JWT format, but tools like `jwt.io` make this trivial if the secret is weak or verification is skipped) |
| **Prevention** | Always verify JWT signature using Keycloak's JWKS endpoint. Validate `iss`, `aud`, `exp` claims. Never use the `none` algorithm. |
| **Detection** | Keycloak rejects invalid tokens before they reach the backend. Invalid token format is caught by the passport-jwt middleware and logged. |
| **Remaining risk** | Low — if implemented correctly. Requires regular review of JWT validation code. |
| **Owner** | Backend developer |

---

#### T-AUTH-002 — Token Theft and Replay

| Field | Detail |
|---|---|
| **Asset** | User access and refresh tokens |
| **Entry point** | Browser storage, network interception, XSS |
| **STRIDE category** | Spoofing |
| **Threat** | An attacker steals a valid access token or refresh token and uses it to authenticate as the legitimate user. |
| **Impact** | Account takeover within the token's validity window. |
| **Likelihood** | Medium (XSS is a common attack vector for token theft from browser storage) |
| **Prevention** | Short access token lifetime (15 minutes). Refresh token rotation (each use issues a new refresh token). Store tokens in memory where possible (Angular in-memory storage, not localStorage). HTTPS + HSTS to prevent interception. Content Security Policy to reduce XSS risk. |
| **Detection** | Keycloak logs token usage. Refresh token rotation means a stolen refresh token is detected on next legitimate use (rotation conflict). |
| **Remaining risk** | Low-medium. XSS is the primary risk — must be mitigated in the Angular frontend. |
| **Owner** | Frontend developer, Backend developer |

---

#### T-AUTH-003 — Brute-Force Attack on Authentication

| Field | Detail |
|---|---|
| **Asset** | Keycloak user accounts |
| **Entry point** | Keycloak login endpoint |
| **STRIDE category** | Spoofing |
| **Threat** | An attacker makes repeated login attempts to guess user passwords. |
| **Impact** | Account compromise. |
| **Likelihood** | Medium |
| **Prevention** | Keycloak brute-force protection enabled (lockout after N failed attempts). Rate limiting on login endpoint. CAPTCHA or WebAuthn/Passkeys reduces reliance on passwords. |
| **Detection** | Keycloak audit logs for `auth.login.failed` events. Alert on repeated failures from the same IP. |
| **Remaining risk** | Low if Keycloak brute-force protection is correctly configured. |
| **Owner** | Platform administrator |

---

### Category: Tenant and Access Control

---

#### T-AC-001 — Broken Access Control: Cross-Tenant Data Access

| Field | Detail |
|---|---|
| **Asset** | All tenant-scoped data (documents, classifications, users, credentials) |
| **Entry point** | Any API endpoint that accepts a resource ID |
| **STRIDE category** | Information Disclosure, Elevation of Privilege |
| **Threat** | An authenticated user of Organisation A constructs a request with a resource ID belonging to Organisation B. If the application does not filter by `organisation_id`, they receive Organisation B's data. |
| **Impact** | Complete cross-tenant data breach. Loss of confidentiality for all affected tenants. |
| **Likelihood** | Medium (IDOR — Insecure Direct Object References — is a very common vulnerability) |
| **Prevention** | Every query against tenant data must include `WHERE organisation_id = :tenantId`. The `organisation_id` is always taken from the JWT token, never from the request. PostgreSQL RLS enforces this at the database layer. Dedicated integration tests verify cross-tenant access is rejected. |
| **Detection** | `tenant.isolation.violation` audit event when RLS rejects a query that the application layer should have prevented. |
| **Remaining risk** | Low if both application-layer and RLS controls are in place. **Highest-impact threat if either control fails.** |
| **Owner** | Backend developer |

---

#### T-AC-002 — Privilege Escalation via Role Manipulation

| Field | Detail |
|---|---|
| **Asset** | Role assignments and permissions |
| **Entry point** | API endpoints for user management |
| **STRIDE category** | Elevation of Privilege |
| **Threat** | A user with limited privileges modifies their role or another user's role to gain elevated access. |
| **Impact** | Privilege escalation within a tenant or across the platform. |
| **Likelihood** | Low-medium |
| **Prevention** | Role management API is restricted to `org_admin` role. Role changes are validated against allowed role assignments (org staff cannot assign platform admin roles). All role changes are audit-logged. |
| **Detection** | `user.role.changed` audit event. Alert on unexpected privilege changes. |
| **Remaining risk** | Low. |
| **Owner** | Backend developer |

---

### Category: Input Validation and Injection

---

#### T-INJ-001 — SQL Injection

| Field | Detail |
|---|---|
| **Asset** | PostgreSQL database |
| **Entry point** | Any API endpoint that accepts user input |
| **STRIDE category** | Tampering, Information Disclosure |
| **Threat** | An attacker injects SQL code into user-controlled input fields to manipulate database queries. |
| **Impact** | Data exfiltration. Data corruption. Authentication bypass. |
| **Likelihood** | Low (Prisma parameterises all queries by default) |
| **Prevention** | Use Prisma's standard query API (parameterised by default). If `$queryRaw` or `$executeRaw` must be used, use Prisma's tagged template literals (not string concatenation). Code review rule: all raw SQL requires security review. |
| **Detection** | Application error logs. Database error logs. Semgrep SAST rules for raw SQL construction. |
| **Remaining risk** | Low if developers follow the rule against string-concatenated raw SQL. |
| **Owner** | Backend developer |

---

#### T-INJ-002 — Prompt Injection (Phase 8+)

| Field | Detail |
|---|---|
| **Asset** | AI explanation service, any LLM-based feature |
| **Entry point** | Document content submitted for AI explanation |
| **STRIDE category** | Tampering, Information Disclosure |
| **Threat** | A malicious document contains instructions embedded in text that cause the LLM to deviate from its intended behaviour — for example, to reveal other users' documents, to produce harmful output, or to exfiltrate data. |
| **Impact** | AI system produces unintended output. Potential data leakage via model output. |
| **Likelihood** | High for LLM-based features (prompt injection is a well-documented class of LLM attack) |
| **Prevention** | Separate system prompt from user-supplied content. Sanitise document content before including in prompt. Validate and sanitise LLM output before returning to users. Monitor LLM outputs for anomalies. Apply output filtering. Never include personal data from other users in LLM context. |
| **Detection** | Output monitoring. Structured output validation that rejects unexpected formats. |
| **Remaining risk** | Medium — prompt injection is difficult to fully prevent. Mitigations reduce but do not eliminate risk. |
| **Owner** | AI/ML engineer |

---

#### T-INJ-003 — Indirect Prompt Injection via Document Content (Phase 8+)

| Field | Detail |
|---|---|
| **Asset** | AI explanation service |
| **Entry point** | Document content extracted from uploaded files |
| **STRIDE category** | Tampering |
| **Threat** | An attacker crafts a document whose content contains hidden instructions (in white text, metadata, or image text) that manipulate the AI model when the document is processed. |
| **Impact** | AI system produces incorrect or harmful output. Classification results are manipulated. |
| **Likelihood** | Medium |
| **Prevention** | Treat all document content as untrusted. Apply the same prompt injection mitigations as T-INJ-002. Do not allow AI output to directly influence security-critical decisions without human review. |
| **Detection** | Human review for low-confidence predictions catches anomalous results. |
| **Remaining risk** | Medium. Requires ongoing monitoring and human oversight. |
| **Owner** | AI/ML engineer |

---

### Category: File Upload

---

#### T-FILE-001 — Malicious File Upload

| Field | Detail |
|---|---|
| **Asset** | Object storage, server resources |
| **Entry point** | Document upload API |
| **STRIDE category** | Tampering, Denial of Service |
| **Threat** | An attacker uploads a malicious file disguised as a PDF or image — for example, a file containing a virus, a web shell, a bomb archive, or a file designed to exploit a vulnerability in the AI processing pipeline. |
| **Impact** | Malware spread. Service compromise. Denial of service (processing bomb). |
| **Likelihood** | Medium |
| **Prevention** | Allowlist of file types. Magic byte verification. File size limits enforced before reading. ClamAV malware scan before processing. Files stored in quarantine bucket until scanned. Files never executed. |
| **Detection** | ClamAV scan results logged. `file.rejected` audit event. Alert on scan detections. |
| **Remaining risk** | Low-medium. Zero-day malware may evade ClamAV. Defence-in-depth (no execution, quarantine) limits impact. |
| **Owner** | Backend developer |

---

#### T-FILE-002 — File Type Spoofing

| Field | Detail |
|---|---|
| **Asset** | Document processing pipeline |
| **Entry point** | Document upload API |
| **STRIDE category** | Tampering |
| **Threat** | An attacker uploads a malicious file (e.g., JavaScript, executable) and sets the Content-Type header to `application/pdf` to bypass content-type validation. |
| **Impact** | Bypass of file type controls. Potential execution of uploaded content. |
| **Likelihood** | High (trivial to change Content-Type with any HTTP client) |
| **Prevention** | **Never trust Content-Type header alone.** Read file magic bytes and verify the actual file type against the allowlist. |
| **Detection** | Magic byte verification failure logged as `file.rejected`. |
| **Remaining risk** | Low if magic byte verification is correctly implemented. |
| **Owner** | Backend developer |

---

### Category: Data Integrity and Repudiation

---

#### T-INT-001 — Audit Log Tampering

| Field | Detail |
|---|---|
| **Asset** | `audit_events` table |
| **Entry point** | Database access |
| **STRIDE category** | Tampering, Repudiation |
| **Threat** | An attacker with database access modifies or deletes audit records to hide evidence of malicious actions. |
| **Impact** | Loss of audit trail. Unable to detect or investigate incidents. Repudiation of actions. |
| **Likelihood** | Low (requires database access), but high impact |
| **Prevention** | Application database role has INSERT only on `audit_events` — no UPDATE or DELETE. Database-level audit logging (pg_audit) for audit table access. Separate privileged role for audit queries. Tamper-evident log (hash chaining or write-once storage) is a Phase 14 requirement. |
| **Detection** | pg_audit logs for any UPDATE or DELETE on audit_events. Alert on such events. |
| **Remaining risk** | Medium (a database superuser can bypass RLS and role restrictions). Tamper-evident storage reduces residual risk. |
| **Owner** | Platform administrator |

---

### Category: AI and Model Security

---

#### T-AI-001 — Malicious Model File

| Field | Detail |
|---|---|
| **Asset** | AI service, server resources |
| **Entry point** | Model loading during service startup or model deployment |
| **STRIDE category** | Tampering, Elevation of Privilege |
| **Threat** | An attacker substitutes or tampers with a model weight file. A pickle-based model file can contain arbitrary Python code that executes when the model is loaded. A tampered safetensors file can contain incorrect weights that degrade or manipulate predictions. |
| **Impact** | Remote code execution (if pickle). Incorrect AI predictions. Model backdoor. |
| **Likelihood** | Low-medium (supply chain attack) |
| **Prevention** | Use `safetensors` format. Verify model file hash before loading. Load models only from the MLflow model registry (not from arbitrary URLs). Pin Hugging Face model commit hashes. Never load `pickle`-based models from untrusted sources. |
| **Detection** | Hash verification failure logged and alerting triggered. |
| **Remaining risk** | Low if hash verification is correctly implemented. |
| **Owner** | AI/ML engineer |

---

#### T-AI-002 — Model Poisoning via Training Data

| Field | Detail |
|---|---|
| **Asset** | AI models, classification results |
| **Entry point** | Training dataset |
| **STRIDE category** | Tampering |
| **Threat** | An attacker poisons the training dataset by injecting malicious examples that cause the model to misclassify certain documents (e.g., classify a fraudulent document as authentic). |
| **Impact** | AI model systematically produces incorrect predictions. Fraudulent documents may bypass review. |
| **Likelihood** | Low (training data is controlled and versioned) |
| **Prevention** | All training data must come from approved, versioned sources (DVC). No user-supplied data used for training without explicit review. Dataset integrity checked before training. Human review for all low-confidence predictions. |
| **Detection** | Model evaluation metrics monitored. Drift detection in production. Anomalous prediction patterns trigger alerts. |
| **Remaining risk** | Low if data governance controls are followed. |
| **Owner** | AI/ML engineer |

---

#### T-AI-003 — AI Result as Sole Authority for Credential Authenticity

| Field | Detail |
|---|---|
| **Asset** | Issued credentials, trust in the platform |
| **Entry point** | Credential issuance workflow |
| **STRIDE category** | Tampering, Repudiation |
| **Threat** | The AI classification result is used as the sole basis for issuing a credential, without cryptographic verification of the underlying document. A manipulated or incorrect AI prediction results in a fraudulent credential being issued. |
| **Impact** | Fraudulent credentials issued and accepted as genuine. Complete loss of trust in the credential issuance system. |
| **Likelihood** | High if not explicitly prevented by design |
| **Prevention** | **ARCHITECTURAL RULE:** AI is never the final authority for credential authenticity. Cryptographic verification is the source of truth. AI classification may inform the credential issuance process, but credential signing is always performed by the platform with explicit human or rule-based authorisation based on verified source documents. |
| **Detection** | Every credential issuance is audit-logged. Human review is mandatory for any AI prediction that informs a credential issuance decision. |
| **Remaining risk** | Low if the architectural rule is enforced in code review and testing. |
| **Owner** | Backend developer, AI/ML engineer |

---

### Category: Sensitive Data Disclosure

---

#### T-DATA-001 — Sensitive Data in Logs

| Field | Detail |
|---|---|
| **Asset** | Log files, observability platforms |
| **Entry point** | Application logging |
| **STRIDE category** | Information Disclosure |
| **Threat** | Document content, personal data, secrets, or JWT tokens are accidentally logged by the application. Logs are accessible to platform operators and may be shipped to an external log aggregation service. |
| **Impact** | Personal data breach. Credential leakage. |
| **Likelihood** | Medium (developers often log request/response bodies for debugging) |
| **Prevention** | Logging policy prohibits document content, personal data, and secrets in logs. Structured logging (no raw request body logging). Log fields explicitly defined. Regular log review. |
| **Detection** | Periodic log audits. Gitleaks can scan log files if they are committed accidentally. |
| **Remaining risk** | Medium — requires developer discipline and code review enforcement. |
| **Owner** | All developers |

---

#### T-DATA-002 — Secret Leakage via Source Control

| Field | Detail |
|---|---|
| **Asset** | Secrets, API keys, private keys |
| **Entry point** | Git commits |
| **STRIDE category** | Information Disclosure |
| **Threat** | A developer accidentally commits a `.env` file, an API key, a private key, or another secret to the Git repository. If the repository is public, the secret is immediately exposed. |
| **Impact** | Full compromise of any system whose secret was leaked. |
| **Likelihood** | Medium (a very common mistake) |
| **Prevention** | Comprehensive `.gitignore` for `.env` files. Gitleaks pre-commit hook and CI scan. `.env.example` instead of `.env`. Code review process. |
| **Detection** | Gitleaks in CI on every push. `git log --all --diff-filter=A -- '*.env'` in code review. |
| **Remaining risk** | Low if Gitleaks is configured correctly and `.gitignore` is comprehensive. |
| **Owner** | All developers |

---

### Category: Availability

---

#### T-DOS-001 — Denial of Service via Large File Upload

| Field | Detail |
|---|---|
| **Asset** | Backend service, object storage |
| **Entry point** | Document upload API |
| **STRIDE category** | Denial of Service |
| **Threat** | An attacker uploads very large files repeatedly to exhaust backend memory, CPU, disk, or object storage quotas. |
| **Impact** | Service unavailability. Storage cost spike. |
| **Likelihood** | Medium |
| **Prevention** | File size limit enforced before reading the file into memory (at the reverse proxy and NestJS middleware). Rate limiting on upload endpoints. Per-tenant upload quotas (Phase 4+). |
| **Detection** | Metrics on request sizes and rejection rates. Alerts on rate limit triggers. |
| **Remaining risk** | Low if file size limits are applied before the file is buffered in memory. |
| **Owner** | Backend developer |

---

### Category: Credential Security (Phase 10+)

---

#### T-CRED-001 — Credential Forgery

| Field | Detail |
|---|---|
| **Asset** | Issued verifiable credentials |
| **Entry point** | Credential verification endpoint |
| **STRIDE category** | Spoofing, Tampering |
| **Threat** | An attacker creates a forged credential (SD-JWT VC) and presents it as genuine. |
| **Impact** | Fraudulent credential accepted as genuine. |
| **Likelihood** | Low-medium |
| **Prevention** | All credentials are signed with the platform's private key. Credential verification cryptographically validates the signature. Trusted issuer registry verifies the issuer is legitimate. |
| **Detection** | Signature verification failure is logged and the credential is rejected. |
| **Remaining risk** | Low if cryptographic verification is correctly implemented. |
| **Owner** | Backend developer |

---

#### T-CRED-002 — Credential Replay After Revocation

| Field | Detail |
|---|---|
| **Asset** | Revoked credentials |
| **Entry point** | Credential presentation |
| **STRIDE category** | Elevation of Privilege |
| **Threat** | An attacker presents a previously valid credential that has since been revoked. If the verifier does not check the revocation status, the revoked credential is accepted. |
| **Impact** | Revoked credentials remain usable. Trust in the revocation system is undermined. |
| **Likelihood** | Medium |
| **Prevention** | Every credential includes a revocation list URL or status list. Verifiers must check revocation status before accepting a credential. Short credential validity periods reduce the window for replay. |
| **Detection** | Revocation status check failures logged. |
| **Remaining risk** | Medium — verifiers outside the platform may not implement revocation checks correctly. |
| **Owner** | Backend developer |

---

### Category: Model Context Protocol (MCP) Security

---

#### T-MCP-001 — Malicious or Untrusted MCP Server

| Field | Detail |
|---|---|
| **Asset** | Developer workstation, repository content, environment secrets |
| **Entry point** | Local or remote MCP server connection |
| **STRIDE category** | Spoofing, Tampering, Information Disclosure, Elevation of Privilege |
| **Threat** | An unvetted third-party MCP server executes malicious payload locally, exfiltrates source code/secrets, or returns compromised responses. |
| **Impact** | Developer workstation compromise, credential exfiltration, source code leak. |
| **Likelihood** | Low-medium |
| **Prevention** | Mandatory 16-point review before installing third-party MCP servers. Prefer official/open-source servers. Default to stdio/Docker isolation. |
| **Detection** | Network monitoring, audit logs of server installations. |
| **Remaining risk** | Low if review process is followed strictly. |
| **Owner** | Cybersecurity Reviewer, DevSecOps Engineer |

---

#### T-MCP-002 — Compromised MCP Dependency

| Field | Detail |
|---|---|
| **Asset** | MCP server codebase and runtime environment |
| **Entry point** | MCP server package updates (npm/uv/Docker) |
| **STRIDE category** | Tampering, Information Disclosure |
| **Threat** | A supply-chain vulnerability in an installed MCP server package or base image allows remote command execution or token exfiltration. |
| **Impact** | System compromise via developer tooling. |
| **Likelihood** | Medium |
| **Prevention** | Pin MCP server versions/Docker hashes. Run `npm audit` / `uv audit` on MCP dependencies. |
| **Detection** | CI/CD dependency vulnerability scans. |
| **Remaining risk** | Low-medium. |
| **Owner** | DevSecOps Engineer |

---

#### T-MCP-003 — Misleading or Adversarial MCP Tool Description

| Field | Detail |
|---|---|
| **Asset** | AI Agent decision context |
| **Entry point** | MCP tool definitions returned by server |
| **STRIDE category** | Spoofing, Tampering |
| **Threat** | An MCP server provides a deceptive tool schema or description designed to trick the AI agent into invoking write operations or leaking sensitive data. |
| **Impact** | AI agent executes unintended tool calls or bypasses human review. |
| **Likelihood** | Low |
| **Prevention** | Strict tool allowlisting. Treat tool descriptions as untrusted during security review. Disable write tools in Stage 1/2. |
| **Detection** | AI tool invocation audit logging. |
| **Remaining risk** | Low. |
| **Owner** | Cybersecurity Reviewer |

---

#### T-MCP-004 — MCP Privilege Escalation

| Field | Detail |
|---|---|
| **Asset** | System files, database, production services |
| **Entry point** | MCP tool execution parameters |
| **STRIDE category** | Elevation of Privilege |
| **Threat** | An MCP server or tool allows the AI agent to execute shell commands, access files outside the workspace, or query restricted endpoints. |
| **Impact** | Arbitrary execution, unauthorized filesystem or network access. |
| **Likelihood** | Medium if broad tools are enabled |
| **Prevention** | Default to read-only tools. Prohibit generic shell/SQL tools. Limit file paths to workspace root. |
| **Detection** | MCP tool invocation audit logs. |
| **Remaining risk** | Low when least-privilege scoping is enforced. |
| **Owner** | DevSecOps Engineer |

---

#### T-MCP-005 — MCP Tool-Output Prompt Injection

| Field | Detail |
|---|---|
| **Asset** | AI Agent instruction flow |
| **Entry point** | Output returned by MCP tools (e.g. GitHub issues, documentation) |
| **STRIDE category** | Tampering |
| **Threat** | Content retrieved via an MCP tool contains embedded prompt-injection instructions attempting to hijack agent control flow. |
| **Impact** | Agent deviates from guardrails, executes unapproved actions. |
| **Likelihood** | Medium |
| **Prevention** | Treat all MCP tool output as untrusted data. Validate/sanitise tool output before processing. Enforce explicit approval boundaries regardless of tool responses. |
| **Detection** | Agent trace logs, monitoring anomalous agent requests. |
| **Remaining risk** | Medium. Requires strict human oversight on state changes. |
| **Owner** | AI/ML Engineer |

---

#### T-MCP-006 — MCP Credential Leakage

| Field | Detail |
|---|---|
| **Asset** | GitHub PAT, API keys, tokens |
| **Entry point** | MCP configuration files (`.codex/config.toml`), logs |
| **STRIDE category** | Information Disclosure |
| **Threat** | MCP configuration files containing secrets are accidentally committed to Git or exposed in error logs. |
| **Impact** | Leakage of GitHub PAT or external service keys. |
| **Likelihood** | Medium |
| **Prevention** | Enforce `.gitignore` rules for `.codex/config.toml` and `.mcp-credentials`. Run Gitleaks in pre-commit and CI. |
| **Detection** | Gitleaks secret scanning alerts. |
| **Remaining risk** | Low with automated secret scanning. |
| **Owner** | DevSecOps Engineer |

---

#### T-MCP-007 — MCP Tool Misuse or Unintended Invocation

| Field | Detail |
|---|---|
| **Asset** | Repository code, external APIs |
| **Entry point** | Agent tool invocation logic |
| **STRIDE category** | Tampering, Denial of Service |
| **Threat** | Agent misinterprets intent and calls an MCP tool with wrong arguments or in an unexpected loop. |
| **Impact** | Rate-limiting, corrupted local state, unwanted API usage. |
| **Likelihood** | Medium |
| **Prevention** | Apply strict tool input schemas, rate limits, and timeouts (30s max). Require approval for write tools. |
| **Detection** | MCP audit logs, execution timeouts. |
| **Remaining risk** | Low. |
| **Owner** | QA Engineer |

---

#### T-MCP-008 — Unauthorized MCP Write Operation

| Field | Detail |
|---|---|
| **Asset** | Repository main branch, issues, pull requests |
| **Entry point** | State-changing MCP tools (e.g., `create_pull_request`, `push_files`) |
| **STRIDE category** | Tampering |
| **Threat** | An MCP tool modifies repository state or opens PRs without explicit developer review and approval. |
| **Impact** | Unvetted changes pushed to repository or external services. |
| **Likelihood** | Medium |
| **Prevention** | Explicit human approval required for all state-modifying MCP operations (`AGENTS.md` Section 13). Disable write tools by default. |
| **Detection** | GitHub audit logs, git commit history. |
| **Remaining risk** | Low. |
| **Owner** | Lead Software Architect |

---

#### T-MCP-009 — MCP Bypass of Application Tenant Isolation

| Field | Detail |
|---|---|
| **Asset** | Multi-tenant database records |
| **Entry point** | MCP database inspection tools (future Phase) |
| **STRIDE category** | Information Disclosure |
| **Threat** | An MCP tool querying a development/staging database bypasses tenant ID filters or row-level security. |
| **Impact** | Exposure of cross-tenant development/test data. |
| **Likelihood** | Medium (if database tool is added in future) |
| **Prevention** | MCP access restricted to development database only. Never connect MCP to production database. Apply RLS to dev databases. |
| **Detection** | Database audit logs. |
| **Remaining risk** | Low (prohibited until explicit future phase review). |
| **Owner** | Backend Developer |

---

## Residual Risk Summary

| Risk ID | Threat | Residual Risk | Mitigation Status |
|---|---|---|---|
| T-AUTH-001 | JWT misuse | Low | Controlled by Keycloak + passport-jwt |
| T-AUTH-002 | Token theft | Low-medium | Controlled by short lifetime + rotation |
| T-AC-001 | Cross-tenant access | **Medium** (critical if exploited) | Dual-layer control required — **must be tested** |
| T-INJ-002 | Prompt injection | Medium | Phase 8+ — mitigations reduce but don't eliminate |
| T-INJ-003 | Indirect prompt injection | Medium | Phase 8+ |
| T-FILE-001 | Malicious upload | Low-medium | ClamAV integration in Phase 3 |
| T-INT-001 | Audit log tampering | Medium | Tamper-evident log deferred to Phase 14 |
| T-AI-001 | Malicious model file | Low | Hash verification mandatory |
| T-AI-003 | AI as authority for credentials | Low | Architectural rule — enforced by design |
| T-DATA-001 | Sensitive data in logs | Medium | Requires developer discipline |
| T-DATA-002 | Secret leakage | Low | Gitleaks + comprehensive .gitignore |
| T-CRED-002 | Credential replay | Medium | Revocation required in Phase 10 |
| T-MCP-001 | Untrusted MCP server | Low | 16-point review + stdio/Docker isolation |
| T-MCP-005 | MCP prompt injection | Medium | Tool output treated as untrusted data |
| T-MCP-006 | MCP credential leak | Low | Gitignore `.codex/config.toml` + Gitleaks |
| T-MCP-008 | Unauthorized MCP write | Low | Mandatory human approval boundary |

---

## Review Schedule

| Trigger | Action |
|---|---|
| Start of each new phase | Review threats relevant to new capabilities introduced |
| Security incident | Immediate review and update |
| New external integration / MCP server | Complete security review and update threat model |
| Phase 10 (credential issuance) | Full review of credential threat categories |
| Phase 14 (production) | Specialist penetration test. Full threat model review. |

---

*This threat model is a starting point. It does not substitute for a specialist security review before production deployment.*

