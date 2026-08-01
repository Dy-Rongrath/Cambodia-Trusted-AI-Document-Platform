# SECURITY.md — Cambodia Trusted AI Document Platform

> **Status:** Living document — reviewed and updated each phase.
> **Last updated:** 2026-08-01
> **Classification:** Internal — do not include secret values in this document.

---

## 1. Security Objectives

| Objective | Description |
|---|---|
| **Confidentiality** | Sensitive document content, personal data, and credentials are accessible only to authorised users within the correct organisation. |
| **Integrity** | Documents, classifications, audit records, and credentials cannot be tampered with by unauthorised parties. |
| **Availability** | The platform remains available to legitimate users under normal operating conditions and degrades gracefully under failures. |
| **Authenticity** | Issued credentials are cryptographically verifiable. AI is never the final authority for credential authenticity. |
| **Non-repudiation** | All important actions are recorded in an immutable audit log that attributes actions to specific actors. |
| **Privacy** | Personal data is collected and processed in accordance with applicable privacy laws. Unnecessary data is not collected. |

---

## 2. Data Classifications

| Classification | Description | Examples | Controls |
|---|---|---|---|
| **Restricted** | Data that, if disclosed, would cause serious harm to individuals or the organisation. | Real government-issued documents, NSSF records, personal identity data, private keys, production secrets. | **Prohibited in development environments.** Encrypted at rest and in transit. Access logged. Strict need-to-know. |
| **Confidential** | Business-sensitive data. Harm if disclosed but not catastrophic. | Organisation data, document metadata, classification results, user accounts, audit logs. | Encrypted in transit (TLS). Access controlled by role. Logged. |
| **Internal** | Operational data for internal use only. | Service configuration, non-sensitive logs, health metrics. | Not exposed externally. Accessible to platform staff. |
| **Public** | Intentionally public data. | Public API documentation, credential verification endpoints, public credential schemas. | No special controls beyond availability. |

### Development data policy

**CRITICAL:** Real data from any of these sources is **prohibited** in development, staging, or test environments:
- Cambodian government documents
- NSSF records
- Real personal identification documents
- Production database dumps
- Client or organisation confidential documents

Only synthetic, anonymised, pseudonymised, or explicitly approved datasets may be used. All synthetic data must be clearly labelled.

---

## 3. Trust Boundaries

| Boundary | Between | Control |
|---|---|---|
| **External ↔ Reverse Proxy** | Public internet and the platform | TLS termination, rate limiting, WAF (Phase 14). |
| **Reverse Proxy ↔ Backend** | DMZ and internal network | Internal HTTP only. No direct external access to backend. |
| **Backend ↔ AI Service** | Backend and AI inference | Private Docker network. Internal API key authentication. |
| **Backend ↔ Database** | Application and data layer | TLS database connection. Least-privilege database role. RLS. |
| **Backend ↔ Object Storage** | Application and file storage | TLS. Short-lived pre-signed URLs for file access. |
| **Backend ↔ Keycloak** | Application and identity provider | OIDC. JWKS-based JWT validation (no shared secrets). |
| **User ↔ Application** | User browser and the application | TLS. HTTPS enforced. HSTS. |
| **Tenant ↔ Tenant** | Organisation A and Organisation B | `organisation_id` filter in every query. PostgreSQL RLS. Separate encryption keys per tenant (Phase 14). |

---

## 4. Authentication

- **Standard:** OAuth 2.1 + OpenID Connect (implemented by Keycloak 26).
- **Client flows:** Authorization Code with PKCE (mandatory for all public clients — browser and mobile).
- **Passwordless:** WebAuthn / Passkeys supported from Phase 2.
- **MFA:** TOTP (Phase 2). WebAuthn as second factor.
- **Token types:** Short-lived access tokens (15-minute lifetime). Refresh token rotation enabled.
- **Session management:** Stateless on the backend — JWTs are validated on every request. No server-side sessions.
- **Logout:** Keycloak backchannel logout for session termination on all clients.

**Prohibited:**
- Basic authentication for user-facing endpoints.
- Long-lived API keys for user authentication.
- Storing passwords in the application database.
- Custom JWT implementation.

---

## 5. Authorisation

- **Model:** Role-based access control (RBAC) with tenant scope.
- **Roles (initial):** `platform_admin`, `org_admin`, `org_staff`, `org_reviewer`.
- **Enforcement:** Application layer (NestJS guards) as primary control. PostgreSQL RLS as secondary control.
- **Token claims:** `organisation_id` and `roles` included as custom claims in Keycloak-issued JWTs.
- **Principle:** Least privilege. Users have only the roles required for their job function.
- **Tenant context:** `organisation_id` is always extracted from the JWT — never from request parameters.
- **Super-admin access:** Platform admin role has access across tenants for operational purposes only. All platform-admin actions are logged.

**Prohibited:**
- Trusting `organisation_id` from query parameters or request body.
- Skipping authorisation checks in any protected endpoint.
- Hard-coded role checks in business logic (use decorators/guards).

---

## 6. Tenant Isolation

Tenant isolation is a critical security requirement. See `ARCHITECTURE.md` Section 8 for the full isolation architecture.

**Verification requirements:**
- Dedicated integration tests that attempt cross-tenant access and verify rejection.
- PostgreSQL RLS policies must be tested independently of application-layer checks.
- Cross-tenant access attempts must produce `tenant.isolation.violation` audit events.

---

## 7. API Security

- **Transport:** TLS 1.2 minimum, TLS 1.3 preferred. HTTPS enforced. HSTS header set.
- **Authentication:** Bearer token (JWT) required for all protected endpoints.
- **Input validation:** All request data validated using NestJS DTOs + `class-validator`. Validation errors return 422 with structured error response.
- **Output encoding:** JSON responses only. No HTML output from the API. No reflected user input in error messages.
- **Rate limiting:** Applied at the reverse proxy level (Phase 2). Applied at the NestJS level for sensitive endpoints (login, file upload) from Phase 1.
- **CORS:** Configured to allow only the known Angular frontend origin. No wildcard origins.
- **Content Security Policy:** Applied to any HTML responses (Phase 2 — Angular frontend).
- **Error handling:** All errors return structured JSON. Stack traces are never exposed in production responses.
- **API versioning:** `/api/v1/` prefix. Breaking changes require a new version path.

---

## 8. File Upload Security

File uploads are a high-risk attack surface. All of the following controls are mandatory:

| Control | Implementation | Phase |
|---|---|---|
| File size limit | Reject files exceeding the limit before reading content. Applied at the reverse proxy and NestJS middleware. | Phase 3 |
| Content-Type validation | Reject unexpected Content-Type headers. | Phase 3 |
| Magic byte verification | Read file magic bytes (file signature) and verify against the declared type. Reject mismatches. | Phase 3 |
| Allowed file types | Allowlist: PDF, JPEG, PNG, TIFF (document images). All other types rejected. | Phase 3 |
| Quarantine storage | Store uploaded files in a quarantine bucket before processing. | Phase 3 |
| Malware scanning | Scan with ClamAV before moving to permanent storage. Integration point defined in Phase 1. | Phase 3 |
| No execution | Uploaded files are never executed, imported, or included in any code path. | Phase 3 |
| Secure URLs | Files served via short-lived pre-signed URLs — never exposed directly from storage. | Phase 3 |
| Content-Disposition | File downloads served with `Content-Disposition: attachment` to prevent browser execution. | Phase 3 |

---

## 9. Secrets Management

### Development
- All secrets are stored in `.env` files.
- `.env` files are excluded from Git via `.gitignore`.
- `.env.example` files with placeholder values are committed to the repository.
- Developers copy `.env.example` to `.env` and fill in their local values.
- Secrets must never appear in source code, test files, logs, comments, or documentation.

### CI/CD
- Secrets are stored as GitHub Actions encrypted secrets.
- Secrets are injected as environment variables into CI jobs.
- CI logs must not echo secret values.

### Production
- Production secrets management solution to be decided in Phase 14.
- Candidates: HashiCorp Vault (self-hosted), AWS Secrets Manager, Azure Key Vault.
- Rotation: All secrets must be rotatable without service downtime.

### Required secrets (by service)

| Secret | Service | Notes |
|---|---|---|
| `DATABASE_URL` | Backend | PostgreSQL connection string with credentials |
| `KEYCLOAK_CLIENT_SECRET` | Backend | Keycloak confidential client secret |
| `INTERNAL_AI_API_KEY` | Backend + AI service | Shared key for internal service-to-service authentication |
| `OBJECT_STORAGE_ACCESS_KEY` | Backend | Object storage access key |
| `OBJECT_STORAGE_SECRET_KEY` | Backend | Object storage secret key |
| `CREDENTIAL_SIGNING_PRIVATE_KEY` | Backend | Private key for credential issuance (Phase 10+) |

---

## 10. Encryption

### In transit
- TLS 1.3 for all external traffic.
- TLS for all internal service-to-database communication.
- HTTPS enforced via HSTS.

### At rest
- Database encryption at the filesystem level (managed service) or via pgcrypto for specific sensitive columns.
- Object storage: server-side encryption (AES-256) enabled for all buckets.
- Model weights and datasets: encrypted at rest in object storage.
- Encryption keys managed separately from encrypted data.

### Cryptographic standards
- Symmetric: AES-256-GCM or ChaCha20-Poly1305.
- Asymmetric: ECDSA P-256 / P-384 or Ed25519 for signatures.
- Hashing: SHA-256 or SHA-3 for integrity. SHA-512 for password hashing contexts.
- No MD5 or SHA-1 for security purposes.
- No custom cryptographic implementations.

---

## 11. Key Management

- Credential signing keys (Phase 10+) are separate from all other keys.
- Keys are stored in a secrets manager — never in the application database.
- Key rotation must be possible without service downtime.
- Old keys must be retained for credential verification until all credentials signed with them have expired.
- Key management changes require specialist review and explicit approval.

---

## 12. Security Logging and Audit Events

Mandatory audit events are defined in `ARCHITECTURE.md` Section 13.

Additional security-specific logging requirements:
- All authentication events (success and failure).
- All authorisation failures (403 responses).
- All file upload rejections (with rejection reason — without document content).
- All rate-limit triggers.
- All tenant isolation violation attempts.
- All admin actions.
- All AI model deployment events.

**Prohibited in logs:**
- Document content or extracted text.
- Personal data (name, ID numbers, addresses).
- Passwords, tokens, or keys.
- Raw error stack traces (production).

---

## 13. Dependency Security

- All dependencies pinned in lock files (`package-lock.json`, `uv.lock`).
- `npm audit` run in CI on every push.
- `uv audit` run in CI on every push (when available).
- Trivy container scanning run in CI on every Docker image build (Phase 2).
- Gitleaks secret scanning run in CI on every push (Phase 2).
- Semgrep SAST run in CI on every push (Phase 2).
- Syft SBOM generated for every Docker image (Phase 2).
- Licence checks for all new dependencies before they are added.

---

## 14. Container Security

- All Docker images built from official base images (Node.js Alpine, Python Alpine, etc.).
- No running containers as root. Use `USER nonroot` in Dockerfiles.
- Read-only filesystem where possible. Only explicitly required write paths mounted.
- No unnecessary tools installed in production images (no shell, curl, wget in production).
- Trivy scans all images for known CVEs.
- Cosign signs all production images (Phase 14).
- All base image versions are pinned (e.g., `node:24.15.0-alpine3.20` — not `node:24-alpine`).

---

## 15. AI and Model Security

- Model files verified by hash before loading.
- `safetensors` format preferred over `pickle`-based formats.
- `pickle.loads()` prohibited with any untrusted data.
- Model weights stored in object storage — not in the repository.
- Model files downloaded only from trusted registries (Hugging Face with pinned commit hashes).
- The AI service must not accept model file uploads via its API.
- Prompt injection mitigations applied when using LLMs (Phase 8+).
- Indirect prompt injection mitigation applied when processing document content (Phase 8+).

---

## 16. Vulnerability Management

| Activity | Frequency | Owner |
|---|---|---|
| `npm audit` in CI | Every push | CI pipeline |
| `uv audit` in CI | Every push | CI pipeline |
| Trivy container scan | Every image build | CI pipeline |
| Gitleaks scan | Every push | CI pipeline |
| Semgrep SAST | Every push | CI pipeline |
| Dependency update review | Weekly | Developer |
| OWASP ZAP API scan | Every release | Phase 4+ |
| Manual security review | Each phase milestone | Developer + specialist reviewer |
| Full penetration test | Before Phase 14 (production) | External specialist (requires approval) |

---

## 17. Incident Response (Initial — pre-production)

| Step | Action |
|---|---|
| 1. Detect | Automated scan, audit log alert, or developer report. |
| 2. Contain | Rotate affected secrets. Revoke affected tokens in Keycloak. Block affected accounts. |
| 3. Assess | Determine scope. Identify affected tenants, data, and systems. |
| 4. Remediate | Apply patches. Deploy fix. Verify fix. |
| 5. Document | Record the incident, timeline, impact, and remediation. |
| 6. Review | Post-incident review. Update threat model and controls. |

A formal incident response plan is required before Phase 14 (production deployment).

---

## 18. Manual Approval Requirements

The following changes require explicit human review and approval before implementation:

- Authentication provider configuration changes.
- Authorisation policy changes.
- Database schema changes affecting personal data.
- Production database migrations.
- Cryptography or key management changes.
- New external service integrations.
- CI/CD pipeline security control changes.
- Docker base image changes.
- AI model deployment to production.
- Any change to audit-log schema or retention policy.
- Infrastructure configuration changes.

AI agents must not self-approve any of the above changes.

---

*This document must be reviewed at the start of each phase and updated to reflect the current security posture.*
