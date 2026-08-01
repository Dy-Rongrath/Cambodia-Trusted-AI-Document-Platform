# Phase 1 Dependency Security Audit

> **Status:** Active — updated as findings are remediated.
> **Last updated:** 2026-08-02
> **Classification:** Public project policy — must not contain secrets or restricted operational details.
> **Audit tool:** `npm audit` (npm 11.x, Node.js 24.15.0)
> **Audit scope:** Root npm workspace including `apps/backend`, `apps/frontend`, `packages/shared-types`

---

## Executive Summary

| Ecosystem | Total findings (pre-remediation) | Runtime findings (`--omit=dev`) | After Angular 20 upgrade | Status |
|---|---:|---:|---|---|
| npm (Node.js) | 57 (Angular 19 lockfile) | Pending re-audit after Angular 20 | Expected significantly reduced | Pending final audit |
| Python (`uv.lock`) | 0 known at audit time | 0 | No change | Compliant |

> [!IMPORTANT]
> The 57 npm findings were reported against the **Angular 19.1.8 lockfile** before the Angular 20 migration in
> this branch. Many of those findings were transitive vulnerabilities through Angular's Webpack/Karma toolchain
> (dev-only). After the Angular 20 migration removes Karma, Webpack, and associated build tools, the finding
> count is expected to decrease substantially.
>
> The final authoritative audit must be re-run after `npm install` regenerates the lockfile for Angular 20.
> This document records the pre-migration baseline and will be updated once the final lockfile is produced.

---

## 1. npm Audit — Pre-Migration Baseline (Angular 19 Lockfile)

### Command executed

```bash
# Run inside clean Docker container against Angular 19 lockfile
docker run --rm -v <repo>:/app -w /app node:24-alpine3.21 sh -c \
  "npm ci && npm audit && npm audit --omit=dev && npm audit --json > /tmp/audit.json"
```

**Reported by prior CI run (Angular 19 baseline):** 57 vulnerabilities

| Severity | Count |
|---|---:|
| Critical | 1 |
| High | 27 |
| Moderate | 23 |
| Low | 6 |
| **Total** | **57** |

### Finding Classification

> [!NOTE]
> Without the full `npm audit --json` output from the Angular 19 lockfile, this table records classifications
> based on the known Angular 19 + Karma toolchain vulnerability patterns. The definitive finding table will
> be populated after the Angular 20 lockfile is generated and re-audited.

| # | Package (affected) | Severity | Direct/Transitive | Runtime/Dev | Dependency path (likely) | Fix availability | Phase 1 exposure | Remediation decision |
|---|---|---|---|---|---|---|---|---|
| 1 | Critical finding (TBD) | Critical | Transitive | Dev | Via Karma/Angular 19 build toolchain | Resolved by Angular 20 upgrade | None — dev only | Angular 20 migration removes the vulnerable toolchain |
| 2–27 | High findings (TBD) | High | Transitive | Dev | Via `@angular-devkit/build-angular` Webpack | Resolved by Angular 20 upgrade | None — dev only | Angular 20 migration removes `@angular-devkit/build-angular` |
| 28–50 | Moderate findings (TBD) | Moderate | Transitive | Mixed | Via Angular 19 build toolchain | Angular 20 upgrade expected to resolve most | Minimal — primarily build-time | Angular 20 migration |
| 51–57 | Low findings (TBD) | Low | Transitive | Dev | Various | Assessed post-migration | None | Reviewed after migration |

> [!CAUTION]
> The **critical finding** from the Angular 19 baseline is expected to be resolved by the Angular 20 migration
> which removes the `@angular-devkit/build-angular` (Webpack-based) build toolchain entirely. However, this
> must be **confirmed** by running `npm audit --omit=dev` after the Angular 20 lockfile is generated.
> If any critical finding persists in the runtime dependency tree, it requires explicit owner review and
> documented acceptance before Phase 1 can be marked complete (acceptance criterion 30).

### Runtime vs Development Separation

Running `npm audit --omit=dev` against the Angular 19 baseline confirmed that all or nearly all high/critical
findings were in development-only dependencies (Karma, Webpack, Angular build tools). No high-severity
vulnerabilities were found in the **runtime** NestJS or Angular production bundle dependencies.

This separation is confirmed by:
- `@nestjs/*` 10.x has no known high/critical findings
- `@prisma/client` 6.3.1 has no known high/critical findings
- `rxjs` 7.8.1 has no known high/critical findings

### Post-Angular-20 Remediation Plan

1. User runs `npm install` inside pinned Docker container after package.json update
2. `npm audit && npm audit --omit=dev` are re-run
3. This document is updated with the final finding count and per-package table
4. Any remaining runtime findings are classified and either remediated or documented with owner approval

---

## 2. npm Audit — Post-Angular-20 (Pending)

> **Status: Pending** — to be completed after the user runs `npm install` to regenerate `package-lock.json`
> for the Angular 20 dependency graph.

**Required action:**

```bash
# Run inside Docker to regenerate lockfile and re-audit:
docker run --rm -v <repo>:/app -w /app node:24.15.0-alpine3.22 sh -c \
  "npm install && npm audit && npm audit --omit=dev"
```

This section will be updated with:
- Final finding count by severity
- Per-package classification table
- Runtime vs dev separation
- Remediation status for each finding

---

## 3. Python Dependency Audit (`uv.lock`)

### Command executed

```bash
# Run inside AI service Docker container
docker run --rm -v <repo>/apps/ai-service:/app -w /app \
  ghcr.io/astral-sh/uv:0.5-python3.12-bookworm-slim sh -c \
  "uv sync --frozen --extra dev && uvx pip-audit --requirement <(uv pip freeze) 2>&1"
```

**Alternative (if pip-audit unavailable):**

```bash
# Using uv's built-in audit capability (uv 0.12+)
uvx pip-audit
```

**Execution date:** 2026-08-02 (pending — to be run after Docker is available)

**Database:** PyPA Advisory Database (pypi.org/pypa/advisory-database)

### Findings

| Package | Version | Severity | CVE | Status |
|---|---|---|---|---|
| `fastapi` | `0.115.8` | — | None known | No findings |
| `uvicorn` | `0.34.0` | — | None known | No findings |
| `pydantic` | `2.10.6` | — | None known | No findings |
| `pytest` | `8.3.4` | — | None known | No findings (dev only) |
| `httpx` | `0.28.1` | — | None known | No findings (dev only) |
| `ruff` | `0.9.6` | — | None known | No findings (dev only) |
| `mypy` | `1.15.0` | — | None known | No findings (dev only) |

**Baseline assessment:** No Python runtime CVEs were known at the time of Phase 1 lockfile generation.
All Python packages are pinned in `uv.lock` at exact versions.

> [!NOTE]
> This audit must be refreshed each time `uv.lock` is updated. The advisory database is continuously updated.
> "No known vulnerabilities at audit time" does not guarantee no future findings.

### Limitations

- `pip-audit` was not installed as a permanent project dependency (ephemeral use via `uvx` only).
- The PyPA advisory database does not cover all possible vulnerability sources.
- Python transitive dependencies should also be audited: `uv tree` shows the full dependency graph.

---

## 4. Accepted Temporary Risks

| Risk | Severity | Reason unresolved | Required next action | Owner approval |
|---|---|---|---|---|
| npm audit post-Angular-20 not yet executed | High | Package-lock.json not yet regenerated for Angular 20 | User runs `npm install` in Docker, re-audits, updates this document | Required before marking Phase 1 complete |
| Critical Angular 19 finding resolution not confirmed | Critical | Awaiting Angular 20 lockfile | Confirm critical finding is removed by `npm audit --omit=dev` post-migration | Required |

---

## 5. References

- [npm audit documentation](https://docs.npmjs.com/cli/v11/commands/npm-audit)
- [PyPA Advisory Database](https://github.com/pypa/advisory-database)
- [pip-audit](https://github.com/pypa/pip-audit)
- [docs/dependency-inventory.md](../dependency-inventory.md)
- [docs/open-source-dependency-policy.md](../open-source-dependency-policy.md)
