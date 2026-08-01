# Task Template: Database Migration

> Use this template for every database schema change. Complete all sections before creating the migration.

---

## Objective

[What schema change is being made and why.]

## Current schema state

[Describe the relevant tables and columns as they currently exist. Or "New table" if this is a new addition.]

## Proposed schema change

```sql
-- Describe the intended change in plain SQL or Prisma schema format.
-- Do not paste actual generated migration SQL here — that goes in the migration file.
```

## Impact analysis

### Affected tables
- [Table name] — [what changes]

### Affected modules
- [Module name] — [what code changes are required]

### Affected queries
- [Query or Prisma call] — [how it changes]

## Migration plan

1. Edit `prisma/schema.prisma` with the proposed changes.
2. Run `npx prisma migrate dev --name <description>` locally.
3. Review the generated SQL migration file in `prisma/migrations/`.
4. Verify the migration applies cleanly to a fresh database.
5. Verify all existing tests still pass.
6. Write new tests for the new schema behaviour.
7. Open a pull request with the schema change, migration file, and tests.

## Rollback plan

```sql
-- SQL that would reverse this migration if it needs to be rolled back.
-- For a new table: DROP TABLE IF EXISTS <name>;
-- For a new column: ALTER TABLE <name> DROP COLUMN <col>;
-- For a renamed column: ALTER TABLE <name> RENAME COLUMN <new> TO <old>;
```

## Data migration

[If this migration moves or transforms existing data, describe the data migration steps here. Data migrations require explicit approval.]

## Security and privacy impact

- [ ] Does this change affect tenant-isolated tables? If yes, RLS policy must be reviewed.
- [ ] Does this change add new personal data fields? If yes, document in the privacy register.
- [ ] Does this change affect audit-event schema? If yes, approval required.

## Approval requirements

- [ ] This migration was reviewed in a pull request.
- [ ] This migration was applied to a local development database successfully.
- [ ] Production migration requires explicit approval before execution.

## Verification commands

```bash
# Apply migration locally
cd apps/backend && npx prisma migrate dev --name <description>

# Verify Prisma client regenerated correctly
cd apps/backend && npx prisma generate

# Run all tests after migration
cd apps/backend && npm test
cd apps/backend && npm run test:e2e
```
