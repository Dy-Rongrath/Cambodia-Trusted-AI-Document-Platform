# Task Template: Security Review

> Use this template when performing a security review of a feature, module, or change.

---

## Objective

[What is being reviewed and why.]

## Scope

[List the specific files, modules, endpoints, or configurations being reviewed.]

## Review checklist

### Authentication and authorisation

- [ ] All protected endpoints require a valid JWT.
- [ ] JWT validation includes: signature, expiry, issuer, audience.
- [ ] Authorisation checks enforce the required role.
- [ ] `organisation_id` is taken from the JWT — not from request parameters.
- [ ] No hard-coded role checks in business logic.

### Tenant isolation

- [ ] Every database query against tenant data includes an `organisation_id` filter.
- [ ] PostgreSQL RLS policies are in place for all affected tables.
- [ ] Cross-tenant access tests exist and pass.

### Input validation

- [ ] All incoming HTTP request data is validated with DTOs + `class-validator`.
- [ ] File uploads validate size, Content-Type, and magic bytes.
- [ ] Query parameters are validated and sanitised.
- [ ] No user input is used in raw SQL queries.

### Output encoding

- [ ] API responses are JSON — no reflected user input.
- [ ] Error messages do not expose stack traces or internal details.
- [ ] File downloads use `Content-Disposition: attachment`.

### Secrets and sensitive data

- [ ] No secrets in source code, tests, logs, or documentation.
- [ ] No personal data or document content in logs.
- [ ] `.env.example` has only placeholder values.

### Dependency security

- [ ] No new dependencies added without review.
- [ ] `npm audit` and `uv audit` run and pass.

### AI-specific (if applicable)

- [ ] AI is not the final authority for credential authenticity.
- [ ] Human review is triggered for low-confidence predictions.
- [ ] Document content is not logged.
- [ ] Model files are hash-verified before loading.
- [ ] Prompt injection mitigations are in place (if LLM used).

### Cryptography (if applicable)

- [ ] No custom cryptographic implementation.
- [ ] Standard algorithms used (AES-256-GCM, Ed25519, SHA-256).
- [ ] No MD5 or SHA-1 for security purposes.

## Findings

| #   | Severity                     | Finding       | Evidence    | Recommendation |
| --- | ---------------------------- | ------------- | ----------- | -------------- |
| 1   | Critical / Important / Minor | [Description] | [File:line] | [Action]       |

## Risk assessment

| Finding     | Residual risk       | Mitigation   |
| ----------- | ------------------- | ------------ |
| [Finding #] | Low / Medium / High | [Mitigation] |

## Recommendation

- [ ] **Approved** — no security concerns identified.
- [ ] **Approved with conditions** — approved if the following conditions are met: [list].
- [ ] **Rejected** — the following critical findings must be resolved before approval: [list].

## Areas requiring specialist review

[List any findings that exceed your own expertise and require a specialist security review.]
