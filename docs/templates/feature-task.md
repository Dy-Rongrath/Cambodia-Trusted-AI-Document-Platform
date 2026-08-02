# Task Template: Feature Implementation

> Copy this template for every new feature task. Fill in all sections before starting implementation.

---

## Objective

[One sentence: what this feature does and why it is needed.]

## Current behaviour

[Describe what the system currently does in the area being changed. If this is a new area, write "Does not exist."]

## Desired behaviour

[Describe precisely what the system should do after this change.]

## Scope

[List the specific files, modules, endpoints, and database tables that will be created or changed.]

## Out of scope

[List related things that will NOT be done in this task. Be explicit.]

## Constraints

- Follow all rules in `AGENTS.md`, `ARCHITECTURE.md`, `SECURITY.md`, and `DEVELOPMENT.md`.
- [Any task-specific constraints.]

## Security impact

[Describe the security implications. Examples: new endpoint (authentication required?), file handling (validation required?), database change (tenant isolation affected?). Write "None identified" only if you have actively checked.]

## Privacy impact

[Describe any privacy implications. Does this change collect, store, process, or expose personal data?]

## Data impact

[Does this change affect the database schema? Training data? Audit log schema?]

## Acceptance criteria

- [ ] [Specific, testable condition 1]
- [ ] [Specific, testable condition 2]
- [ ] Authentication and authorisation enforced.
- [ ] Tenant isolation verified.
- [ ] Audit event recorded (if required).
- [ ] Unit tests: success, failure, boundary, permission cases.
- [ ] Integration tests pass.
- [ ] No secrets or personal data in code, tests, or logs.
- [ ] Documentation updated.

## Verification commands

```bash
# Run after implementation to verify the change
./scripts/docker/npm.sh test --workspace=apps/backend
./scripts/docker/npm.sh run test:e2e --workspace=apps/backend
./scripts/docker/lint.sh
cd apps/backend && npx tsc --noEmit
```

## Rollback plan

[How would this change be reversed if it causes a problem? For schema changes: migration rollback SQL. For API changes: backward-compatible version. For config changes: revert to previous value.]

## Documentation requirements

- [ ] Inline code comments for non-obvious logic.
- [ ] JSDoc for all exported functions.
- [ ] API documentation (OpenAPI) updated.
- [ ] Relevant foundation documents updated if the change affects architecture or governance.

## Approval requirements

- [ ] Does this change require approval per `AGENTS.md`? If yes, list which approval is needed before proceeding.
