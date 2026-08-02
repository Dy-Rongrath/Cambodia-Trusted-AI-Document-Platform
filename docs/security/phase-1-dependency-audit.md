# Phase 1 Dependency Security Audit

> **Status:** Active — latest-stable dependency upgrade audited.
> **Last updated:** 2026-08-02
> **Classification:** Public project policy — must not contain secrets or restricted operational details.
> **Audit tools:** `npm audit` (npm 11.12.1) and `pip-audit` 2.10.1 (ephemeral execution through `uvx`)
> **Audit scope:** npm workspaces and `apps/ai-service/uv.lock`

---

## Executive Summary

| Ecosystem          | Full dependency graph | Runtime findings | Status                                                       |
| ------------------ | --------------------: | ---------------: | ------------------------------------------------------------ |
| npm (Node.js)      |            3 moderate |                0 | Runtime compliant; upstream development-tool findings remain |
| Python (`uv.lock`) |               0 known |          0 known | Compliant at audit time                                      |

The previous Angular 19 lockfile baseline contained 57 findings. After upgrading to Angular 22.1.x and
regenerating `package-lock.json`, no critical or high findings remain. The three remaining moderate findings
are reachable only through the Angular CLI development toolchain and are absent from `npm audit --omit=dev`.

---

## 1. npm Audit — Upgraded Lockfile

### Commands executed

```bash
npm audit --json
npm audit --omit=dev --json
npm run audit:production
```

### Results

| Severity  | Full graph | Production graph |
| --------- | ---------: | ---------------: |
| Critical  |          0 |                0 |
| High      |          0 |                0 |
| Moderate  |          3 |                0 |
| Low       |          0 |                0 |
| **Total** |      **3** |            **0** |

### Remaining finding classification

| Package                            | Severity | Direct/Transitive     | Scope            | Dependency path                                                    | Remediation status                                             |
| ---------------------------------- | -------- | --------------------- | ---------------- | ------------------------------------------------------------------ | -------------------------------------------------------------- |
| `@angular/cli` 22.1.2              | Moderate | Direct dev dependency | Development only | `@angular/cli` → `@modelcontextprotocol/sdk` → `@hono/node-server` | No patched Angular 22 release available at audit time          |
| `@modelcontextprotocol/sdk` 1.29.0 | Moderate | Transitive            | Development only | Angular CLI tooling                                                | Await upstream Angular CLI dependency update                   |
| `@hono/node-server` `<2.0.5`       | Moderate | Transitive            | Development only | Angular CLI MCP tooling                                            | Path traversal advisory affects Hono static serving on Windows |

`npm audit` proposes Angular CLI 21.0.4 as the available resolution. That is a major downgrade and would
break alignment with Angular 22.1.0/22.1.2, so it was not applied. The application does not import or expose
these packages at runtime, and the production-only audit reports zero findings.

An upstream version check on 2026-08-02 confirmed that Angular CLI 22.1.2 remains the latest release. Although
`@modelcontextprotocol/sdk` 1.30.0 and `@hono/node-server` 2.0.12 are available, Angular CLI pins MCP SDK
1.29.0 exactly. Overriding that pin would be an untested MCP SDK change and requires the separate MCP approval
and review process defined in `MCP_SECURITY.md`; it was not applied.

Static dependency tracing confirms that Angular CLI loads the MCP SDK through the separate `ng mcp` command.
The platform build and application runtime do not execute that command. GHSA-frvp-7c67-39w9 additionally
requires a Windows host serving static files through the affected Hono adapter; supported local development is
Apple Silicon and the container runtime is Linux. The finding is therefore not exploitable in the approved
platform paths, but remains tracked until Angular publishes a patched CLI dependency graph.

### Operational control

- Do not expose `ng serve` or other development servers to untrusted networks.
- Do not execute or configure the Angular CLI MCP server without completing the mandatory MCP server review
  and receiving maintainer approval.
- Keep `npm run audit:production` in the canonical local and GitHub Actions quality gates. It fails on high or
  critical production findings while the full dependency graph retains its separate critical-only CI check.
- Re-run the audit when a newer Angular CLI 22 patch is published.
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

| Risk                                     | Severity | Reason unresolved                                                                  | Required next action                                                           | Owner approval                   |
| ---------------------------------------- | -------- | ---------------------------------------------------------------------------------- | ------------------------------------------------------------------------------ | -------------------------------- |
| Angular CLI transitive MCP/Hono findings | Moderate | No patched Angular CLI 22 release exists; npm recommends an incompatible downgrade | Upgrade to the first patched Angular CLI 22 release and re-run both npm audits | Track until upstream remediation |

---

## 4. References

- [npm audit documentation](https://docs.npmjs.com/cli/v11/commands/npm-audit)
- [GHSA-frvp-7c67-39w9](https://github.com/advisories/GHSA-frvp-7c67-39w9)
- [PyPA Advisory Database](https://github.com/pypa/advisory-database)
- [pip-audit](https://github.com/pypa/pip-audit)
- [docs/dependency-inventory.md](../dependency-inventory.md)
- [docs/open-source-dependency-policy.md](../open-source-dependency-policy.md)
