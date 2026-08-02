# Task Template: Bug Fix

> Use this template for every bug fix task.

---

## Objective

[One sentence: what bug is being fixed.]

## Current behaviour (the bug)

[Describe precisely what the system currently does incorrectly. Include: steps to reproduce, actual output, expected output.]

## Root cause

[Describe the root cause of the bug. If unknown, write "Under investigation" and complete this field before implementing the fix.]

## Proposed fix

[Describe the fix at a high level. Which function, guard, query, or validation is being corrected?]

## Scope

[Files, modules, and tests that will be changed.]

## Out of scope

[Related improvements or refactoring that will NOT be done in this task.]

## Security impact

[Could this bug have security implications? Was it an access control bypass? A validation gap? A secret leak? Document honestly.]

## Regression risk

[What existing behaviour could break? What tests will verify it doesn't?]

## Acceptance criteria

- [ ] The bug no longer occurs under the documented reproduction steps.
- [ ] A regression test is added that would have caught this bug.
- [ ] All existing tests continue to pass.
- [ ] No unintended side effects.

## Verification commands

```bash
./scripts/docker/npm.sh test --workspace=apps/backend
./scripts/docker/npm.sh run test:e2e --workspace=apps/backend
./scripts/docker/lint.sh
```

## Rollback plan

[How can this fix be reverted if it introduces a regression?]
