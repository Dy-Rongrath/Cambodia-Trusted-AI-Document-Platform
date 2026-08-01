# ADR-0004 — Keycloak 26 as Authentication Provider

## Status

`Accepted`

## Decision Owner / Approved By

Dy Rongrath (Project Owner) — Explicit user requirement: "Keycloak 26 (IdP)"

## Date

2026-08-01

## Context

The platform requires a production-grade identity provider (IdP) to handle:

- User authentication for web and mobile clients.
- OAuth 2.1 authorisation flows.
- OpenID Connect (OIDC) token issuance.
- WebAuthn / Passkeys (passwordless authentication).
- Multi-tenant organisation management (Keycloak realms or organisations feature).
- Integration with NestJS backend JWT validation.
- Self-hostable in Docker for local development and production.
- A path toward OpenID4VCI credential issuance in Phase 10+.

The platform must avoid vendor lock-in to a cloud-managed identity provider.

## Decision

We will use **Keycloak 26** (current stable release as of 2025–2026) as the identity provider.

Keycloak is the leading open-source identity and access management (IAM) solution. It implements OAuth 2.1, OIDC, SAML 2.0, and WebAuthn standards. It is self-hostable, runs in Docker, and has strong NestJS ecosystem support.

Key features used:
- **Realm per environment** (development, staging, production).
- **Keycloak Organisations** (introduced in Keycloak 24+) for multi-tenant organisation management.
- **WebAuthn authenticator** for Passkey support.
- **Custom claims mapper** to include `organisation_id` and `roles` in JWT tokens.
- **JWKS endpoint** for JWT verification in the NestJS backend.
- **Client credentials flow** for service-to-service authentication (backend → AI service internal token validation).

## Alternatives Considered

| Option | Description | Why rejected or deferred |
|---|---|---|
| ZITADEL | Modern Go-based IAM with excellent OpenID4VCI roadmap | Strong candidate. More modern codebase, better native credential issuance support, lighter resource footprint (Go vs. Java). Rejected for Phase 0 because Keycloak has a larger community, more documentation, and more NestJS integration examples. ZITADEL is recommended for re-evaluation when OpenID4VCI credential issuance is implemented in Phase 10. |
| Auth0 | Managed cloud IAM | Vendor lock-in. Data residency concerns. Cost at scale. Not self-hostable. Rejected. |
| Supabase Auth | Simpler managed auth | Insufficient for enterprise multi-tenant management, WebAuthn, and OIDC compliance at the required level. |
| custom JWT implementation | Build authentication from scratch | Never acceptable. Authentication must not be implemented from scratch. |
| AWS Cognito / Azure AD B2C | Cloud-managed IAM | Vendor lock-in. Not self-hostable. Cost concerns. Rejected. |

## Consequences

### Positive consequences
- Full OAuth 2.1 + OIDC compliance out of the box.
- WebAuthn / Passkeys supported natively.
- NestJS passport strategy (`@nestjs/passport` + `passport-jwt`) integrates cleanly with Keycloak-issued JWTs.
- Keycloak Organisations feature (24+) supports multi-tenant user management without custom code.
- Admin REST API allows programmatic user and realm management.
- Keycloak is widely deployed in European production environments.
- Active development and long-term support (Red Hat backing).

### Negative consequences / trade-offs
- Keycloak is Java-based — higher memory footprint than Go-based alternatives (ZITADEL). Not a concern at current scale.
- Keycloak configuration is complex. The admin UI is powerful but can be overwhelming. Infrastructure-as-code for Keycloak configuration is recommended (Terraform Keycloak provider or Keycloak export/import).
- OpenID4VCI credential issuance support in Keycloak is limited — this is why ZITADEL is flagged for re-evaluation in Phase 10.
- Keycloak upgrades can require realm migration. Plan upgrades carefully.

### Neutral consequences
- Local development: `quay.io/keycloak/keycloak:26` Docker image with volume-mounted realm export.
- Realm configuration is exported to JSON and committed to the repository for reproducibility.
- The NestJS backend validates Keycloak-issued JWTs using the JWKS endpoint — no shared secret.

## Security Impact

High positive impact. Keycloak provides:
- Brute-force protection.
- MFA (TOTP, WebAuthn).
- Token revocation.
- Secure session management.
- PKCE enforcement (OAuth 2.1 requirement).
- Configurable token lifetimes and refresh token rotation.

Security configuration requirements:
- Disable unused authentication flows.
- Enforce PKCE for all public clients.
- Set short access token lifetimes (15 minutes recommended).
- Enable refresh token rotation.
- Configure CORS correctly for the Angular frontend origin.
- Restrict admin API access to internal network only.

## Privacy Impact

Keycloak stores user credentials and profile data. In production, the Keycloak database must:
- Be a separate PostgreSQL instance (not shared with application data).
- Be encrypted at rest.
- Be backed up regularly.
- Be subject to the same data retention and deletion policies as application data.

Keycloak logs may contain personal data (usernames, IP addresses). Log retention must comply with the platform's privacy policy.

## Operational Impact

- Local: Docker Compose service. Realm exported to `infra/docker/keycloak/realm-export.json`.
- Production: Keycloak deployed in Kubernetes (Phase 14) or as a managed instance. Active-passive HA configuration for production.
- Monitoring: Keycloak exposes metrics in Prometheus format.
- Upgrades: Keycloak minor versions are generally safe. Major version upgrades require realm migration and must be tested in staging.

## Migration Impact

Migrating from Keycloak to another IdP would require:
- Exporting user data and re-importing it into the new IdP.
- Updating JWT claims mapping in the NestJS backend.
- Updating OIDC client configuration in the Angular frontend.
- Updating all environment variables and infrastructure configuration.

This is a medium-high cost migration. Mitigated by the fact that the NestJS backend validates JWTs generically (using JWKS) — the JWT validation layer is IdP-agnostic.

## Review Conditions

- Review in Phase 10 when OpenID4VCI credential issuance is implemented. ZITADEL may be the better choice at that point.
- Review if Keycloak's memory footprint becomes a cost concern in production.
- Review if a Keycloak security vulnerability requires an emergency migration.
