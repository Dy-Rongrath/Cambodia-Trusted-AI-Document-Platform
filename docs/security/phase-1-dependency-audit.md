# Phase 1 Dependency Security Audit

> **Status:** Active — latest-stable dependency upgrade audited.
> **Last updated:** 2026-08-02
> **Classification:** Public project policy — must not contain secrets or restricted operational details.
> **Audit tools:** `npm audit` (npm 11.12.1) and `pip-audit` 2.10.1 (ephemeral execution through `uvx`)
> **Audit scope:** npm workspaces and `apps/ai-service/uv.lock`

---

## Executive Summary

| Ecosystem          | Full dependency graph | Runtime findings | Status                  |
| ------------------ | --------------------: | ---------------: | ----------------------- |
| npm (Node.js)      |               0 known |          0 known | Compliant at audit time |
| Python (`uv.lock`) |               0 known |          0 known | Compliant at audit time |

The previous Angular 19 lockfile baseline contained 57 findings. After upgrading to Angular 22.1.x and
applying the reviewed development-tool override described below, the full and production dependency graphs
contain no known npm audit findings.

---

## 1. npm Audit — Upgraded Lockfile

### Commands executed

```bash
npm run audit:full
npm audit --omit=dev --json
npm run audit:production
```

### Results

| Severity  | Full graph | Production graph |
| --------- | ---------: | ---------------: |
| Critical  |          0 |                0 |
| High      |          0 |                0 |
| Moderate  |          0 |                0 |
| Low       |          0 |                0 |
| **Total** |      **0** |            **0** |

### Resolved development-tool finding

| Dependency path                                                    | Previous resolution  | Patched resolution  | Result                          |
| ------------------------------------------------------------------ | -------------------- | ------------------- | ------------------------------- |
| `@angular/cli` → `@modelcontextprotocol/sdk` → `@hono/node-server` | `1.29.0` → `1.19.17` | `1.30.0` → `2.0.12` | GHSA finding no longer reported |

`npm audit` proposes Angular CLI 21.0.4 as the available resolution. That is a major downgrade and would
break alignment with Angular 22.1.0/22.1.2, so it was not applied. Angular CLI remains pinned at 22.1.2.

An upstream version and release review on 2026-08-02 confirmed that Angular CLI 22.1.2 remains the latest
release. MCP SDK 1.30.0 is the supported v1 security release that widens its Hono range specifically for
GHSA-frvp-7c67-39w9. The root npm override is scoped to Angular CLI and pins MCP SDK 1.30.0; the lockfile then
resolves Hono Node Server 2.0.12. Both packages retain the MIT licence and support the project's Node 24 ARM64
container runtime.

Static dependency tracing confirms that Angular CLI loads the MCP SDK through the separate `ng mcp` command.
The platform build and application runtime do not execute that command. No MCP server was installed, enabled,
or configured by this remediation. A clean Docker `npm ci`, full-graph audit, production audit, Angular build,
and test suite validate the overridden development-tool graph.

### Operational control

- Do not expose `ng serve` or other development servers to untrusted networks.
- Do not execute or configure the Angular CLI MCP server without completing the mandatory MCP server review
  and receiving maintainer approval.
- Keep `npm run audit:full` and `npm run audit:production` in the canonical local and GitHub Actions quality
  gates. The full graph fails on moderate, high, or critical findings; the production graph independently fails
  on high or critical findings.
- Re-evaluate and remove the override when Angular CLI directly adopts MCP SDK 1.30.0 or newer.
- Do not use `npm audit fix --force`; it would silently downgrade the approved framework toolchain.

---

## 2. Python Dependency Audit (`uv.lock`)

### Production CI command

```bash
docker run --rm -v <repo>/apps/ai-service:/workspace -w /workspace \
  --entrypoint sh ghcr.io/astral-sh/uv:0.12.1-python3.12-trixie-slim -c \
  'uv export --frozen --no-dev --no-emit-project --format requirements-txt \
     --output-file /tmp/requirements.txt >/dev/null && \
   uvx pip-audit==2.10.1 --strict --progress-spinner off --require-hashes \
     --disable-pip -r /tmp/requirements.txt'
```

The CI export excludes development groups and the unpublished local project, retains the lockfile hashes, and
audits only pinned third-party production packages. `--disable-pip` prevents dependency re-resolution from
drifting away from `uv.lock`, while `--strict` fails if dependency collection is incomplete.

**Execution date:** 2026-08-02

**Production CI result:** No known vulnerabilities found in the locked third-party runtime dependencies. The
unpublished local package is deliberately excluded from the export rather than passed to the advisory scanner.

**Most recent full-graph result:** No known vulnerabilities found in the locked runtime, development, or build
dependencies listed below.

| Direct package | Version   | Scope       | Result            |
| -------------- | --------- | ----------- | ----------------- |
| `fastapi`      | `0.141.1` | Runtime     | No known findings |
| `uvicorn`      | `0.52.1`  | Runtime     | No known findings |
| `pydantic`     | `2.13.4`  | Runtime     | No known findings |
| `pytest`       | `9.1.1`   | Development | No known findings |
| `httpx`        | `0.28.1`  | Development | No known findings |
| `ruff`         | `0.16.1`  | Development | No known findings |
| `mypy`         | `2.3.0`   | Development | No known findings |
| `hatchling`    | `1.31.0`  | Build       | No known findings |

> [!NOTE]
> Vulnerability databases change continuously. Refresh both audits whenever either lockfile changes.

---

## 3. Accepted Temporary Risks

No dependency vulnerability is currently accepted in the audited npm or Python lockfiles. Audit databases
change continuously, so this statement must be refreshed whenever either lockfile changes.

---

## 4. References

- [npm audit documentation](https://docs.npmjs.com/cli/v11/commands/npm-audit)
- [npm overrides documentation](https://docs.npmjs.com/cli/v11/configuring-npm/package-json/#overrides)
- [MCP TypeScript SDK 1.29.0...1.30.0 comparison](https://github.com/modelcontextprotocol/typescript-sdk/compare/e12cbd7078db388152f6e839abdbe09ba01f3f32...2d889f2b329e46680ec9bdd565de4616c497825a)
- [GHSA-frvp-7c67-39w9](https://github.com/advisories/GHSA-frvp-7c67-39w9)
- [PyPA Advisory Database](https://github.com/pypa/advisory-database)
- [pip-audit](https://github.com/pypa/pip-audit)
- [docs/dependency-inventory.md](../dependency-inventory.md)
- [docs/open-source-dependency-policy.md](../open-source-dependency-policy.md)
