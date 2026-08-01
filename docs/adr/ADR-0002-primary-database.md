# ADR-0002 — PostgreSQL 17 as Primary Relational Database

## Status

`Accepted`

## Decision Owner / Approved By

Dy Rongrath, Project Owner — approved through review and merge of PR #1 on 2026-08-01.

## Date

2026-08-01

## Context

The platform requires a relational database to store user data, organisation data, document metadata, classification results, review decisions, credentials, and audit events. The database must support:

- Full ACID compliance for data integrity.
- Multi-tenant data isolation with enforcement at the database layer.
- JSON storage for flexible metadata fields.
- Future vector search capability for semantic document retrieval.
- Strong ecosystem support for Prisma ORM (see ADR-0003).
- Self-hostable in Docker for local development.
- Available as a managed cloud service for production.
- European data-residency deployments.

## Decision

We will use **PostgreSQL 17** as the primary relational database.

PostgreSQL 17 is the current stable release (released September 2024) and will receive security fixes through at least 2029. It is available as a Docker image (`postgres:17-alpine`) and as a managed service on all major cloud providers.

Key PostgreSQL features used by this platform:

| Feature | Usage |
|---|---|
| Row-level security (RLS) | Tenant isolation enforcement at the database layer |
| JSONB columns | Flexible metadata storage for documents and audit events |
| pgvector extension | Future vector similarity search for document embeddings |
| UUID support | Primary keys as UUIDs for all tenant-scoped tables |
| Transactions | Multi-step operations (upload + audit log) wrapped in transactions |
| Partial indexes | Performance on tenant-scoped queries |
| pg_audit extension | Database-level audit logging (Phase 14+) |

## Alternatives Considered

| Option | Description | Why rejected or deferred |
|---|---|---|
| PostgreSQL 16 | Previous stable release | Still supported, but 17 adds performance improvements relevant to JSON and vacuum operations. No reason to use an older version for a new project. |
| MySQL 8 / MariaDB | Popular relational database | Less robust JSON support. No native row-level security. pgvector not available. Community ecosystem for NestJS/Prisma favours PostgreSQL. |
| SQLite | Embedded database | Not suitable for a multi-user, multi-service production system. |
| MongoDB | Document database | Does not provide the relational integrity, row-level security, or transaction guarantees required. JSONB in PostgreSQL provides document flexibility without sacrificing these properties. |
| CockroachDB | Distributed SQL | PostgreSQL-compatible, but adds operational complexity without justification at current scale. Review if horizontal sharding becomes necessary. |

## Consequences

### Positive consequences
- Full ACID compliance protects data integrity across all operations.
- Row-level security provides a second enforcement layer for tenant isolation.
- pgvector enables future semantic search without introducing a separate vector database.
- Excellent Prisma support — schema, migrations, and type-safe queries are all first-class.
- Widely deployed in European production environments. Good managed-service options (AWS RDS, Azure Database for PostgreSQL, Supabase, Neon).
- Strong community and long-term support track record.

### Negative consequences / trade-offs
- Requires careful schema design and migration discipline.
- RLS policies add complexity to the database setup and must be tested explicitly.
- Slightly higher operational complexity than a managed cloud-only database.
- Horizontal scaling requires read replicas or sharding — not needed at current scale.

### Neutral consequences
- The `postgres:17-alpine` Docker image is used for local development.
- For production, a managed PostgreSQL service is recommended to reduce operational burden.

## Security Impact

High positive impact. PostgreSQL row-level security provides a mandatory second layer of tenant isolation. Even if application-layer isolation is bypassed by a bug, RLS prevents cross-tenant data access.

The database user used by the application has the minimum required privileges:
- Application role: `SELECT`, `INSERT`, `UPDATE`, `DELETE` on specific tables. `INSERT` only on `audit_events`.
- Migration role: `CREATE TABLE`, `ALTER TABLE` — used only during migrations.
- No `SUPERUSER` for the application role.

Connection must use TLS in all environments.

## Privacy Impact

PostgreSQL supports column-level encryption and encryption at rest (via filesystem-level encryption or managed service encryption). Personal data fields should be encrypted where feasible. Data retention is enforced via application logic with periodic cleanup jobs.

## Operational Impact

- Local development: `postgres:17-alpine` in Docker Compose. Volume-mounted data directory.
- CI: `postgres:17-alpine` service container in GitHub Actions.
- Production: Managed PostgreSQL service (provider to be decided in Phase 14 infrastructure planning).
- Backups: Managed service point-in-time recovery. Local dev: manual `pg_dump` script.

## Migration Impact

Migrating away from PostgreSQL would require rewriting all Prisma schema definitions, all RLS policies, and potentially replacing pgvector with a separate vector database. This is a high-cost migration. Only consider if a fundamental scaling or sovereignty requirement forces it.

## Review Conditions

- Review if horizontal read scaling becomes necessary (add read replicas or consider CockroachDB).
- Review if a data-residency requirement prohibits use of the chosen managed service.
- Review when pgvector reaches a milestone that significantly changes the vector search architecture.
