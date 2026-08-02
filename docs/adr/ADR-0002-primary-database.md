# ADR-0002 — PostgreSQL 18 as Primary Relational Database

## Status

`Accepted`

## Decision Owner / Approved By

Dy Rongrath, Project Owner — PostgreSQL 17 baseline approved through review and merge of PR #1 on 2026-08-01; PostgreSQL 18 managed-target amendment explicitly approved on 2026-08-02.

## Date

2026-08-02

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

We will use **PostgreSQL 18** as the primary relational database and managed-service target.

PostgreSQL 18 was released in September 2025 and is supported through November 2030. The approved managed development target is Google Cloud SQL for PostgreSQL 18.4. The existing `postgres:17.4-alpine` local environment remains available during the transition so local data is not deleted or made inaccessible. Until local and CI move to PostgreSQL 18, schema and SQL changes must remain compatible with PostgreSQL 17.

Key PostgreSQL features used by this platform:

| Feature                  | Usage                                                              |
| ------------------------ | ------------------------------------------------------------------ |
| Row-level security (RLS) | Tenant isolation enforcement at the database layer                 |
| JSONB columns            | Flexible metadata storage for documents and audit events           |
| pgvector extension       | Future vector similarity search for document embeddings            |
| UUID support             | Primary keys as UUIDs for all tenant-scoped tables                 |
| Transactions             | Multi-step operations (upload + audit log) wrapped in transactions |
| Partial indexes          | Performance on tenant-scoped queries                               |
| pg_audit extension       | Database-level audit logging (Phase 14+)                           |

## Alternatives Considered

| Option            | Description                 | Why rejected or deferred                                                                                                                                                                   |
| ----------------- | --------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| PostgreSQL 17     | Previous major release      | Retained temporarily for local and CI compatibility, but it is no longer the managed-service target.                                                                                       |
| MySQL 8 / MariaDB | Popular relational database | Less robust JSON support. No native row-level security. pgvector not available. Community ecosystem for NestJS/Prisma favours PostgreSQL.                                                  |
| SQLite            | Embedded database           | Not suitable for a multi-user, multi-service production system.                                                                                                                            |
| MongoDB           | Document database           | Does not provide the relational integrity, row-level security, or transaction guarantees required. JSONB in PostgreSQL provides document flexibility without sacrificing these properties. |
| CockroachDB       | Distributed SQL             | PostgreSQL-compatible, but adds operational complexity without justification at current scale. Review if horizontal sharding becomes necessary.                                            |

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

- The `postgres:17.4-alpine` Docker image remains available for local compatibility while the managed target uses PostgreSQL 18.4.
- Features introduced only in PostgreSQL 18 cannot be used until local and CI environments complete the coordinated major-version migration.
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

- Local development: existing `postgres:17.4-alpine` Docker Compose service and volume retained as a compatibility environment.
- Remote development: Google Cloud SQL for PostgreSQL 18.4 through the Cloud SQL Auth Proxy.
- CI: PostgreSQL 17.4 through the existing Compose service until the coordinated major-version migration is separately approved and validated.
- Production: PostgreSQL 18 managed service; final provider and topology remain subject to Phase 14 infrastructure planning.
- Backups: Managed service point-in-time recovery. Local dev: manual `pg_dump` script.

## Migration Impact

The managed target moves from PostgreSQL 17 to PostgreSQL 18 without changing database technology or application contracts. Existing PostgreSQL 17 local data is retained. A later local/CI upgrade requires a tested `pg_upgrade` or dump/restore workflow because PostgreSQL major-version data directories are not directly compatible.

## Review Conditions

- Review if horizontal read scaling becomes necessary (add read replicas or consider CockroachDB).
- Review if a data-residency requirement prohibits use of the chosen managed service.
- Review when pgvector reaches a milestone that significantly changes the vector search architecture.
