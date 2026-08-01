# ADR-0006 — uv as Python Dependency and Project Manager

## Status

`Accepted`

## Decision Owner / Approved By

Dy Rongrath, Project Owner — approved through review and merge of PR #1 on 2026-08-01.

## Date

2026-08-01

## Context

The Python FastAPI AI service requires a reproducible, auditable dependency management system. The chosen tool must:

- Produce a lock file for reproducible installs across developer machines and CI.
- Manage virtual environments automatically.
- Be fast enough to not slow down Docker image builds and CI pipelines.
- Support `pyproject.toml` as the package configuration standard.
- Support hash verification of installed packages.
- Support Python version management.
- Be installable without root privileges.
- Be actively maintained with a clear security posture.

## Decision

We will use **uv** (version 0.7.x or latest stable) as the Python package and project manager for the AI service.

uv is developed by Astral (the same team behind Ruff). It is written in Rust and is a drop-in replacement for pip, pip-tools, pip-compile, virtualenv, and parts of pyenv. It creates and manages virtual environments automatically and produces a `uv.lock` file for reproducible installs.

Key commands:
- `uv sync` — install all dependencies from the lock file.
- `uv add <package>` — add a dependency and update the lock file.
- `uv run <command>` — run a command inside the virtual environment.
- `uv python install 3.12` — install a specific Python version.
- `uv lock` — regenerate the lock file without installing.

The `uv.lock` file is committed to the repository for reproducible installs.

## Alternatives Considered

| Option | Description | Why rejected or deferred |
|---|---|---|
| Poetry | Mature Python dependency manager | Widely used, good documentation. Rejected because uv is significantly faster (10–100x), supports the same `pyproject.toml` standard, and is the emerging community standard. Poetry is a valid fallback if uv proves unstable. |
| pip + requirements.txt | Simple pip-based dependency tracking | Non-reproducible without pip-tools. Does not manage virtual environments. Does not support pyproject.toml natively for complex projects. Not suitable for production-grade Python. |
| pip + pip-tools | pip-compile for reproducible requirements | Better than plain pip, but slower and more manual than uv. Superseded by uv's design. |
| conda / mamba | Conda package manager | Heavier than needed. Primarily for scientific computing environments with non-Python binary dependencies. Not aligned with the standard Python packaging ecosystem (pyproject.toml, PyPI). |
| Pipenv | Earlier standard for Python project management | Slower than uv. Less actively developed. Largely superseded by Poetry and now uv in the community. |
| Hatch | Modern Python project manager | Valid choice. Less community momentum than uv at this time. |

## Consequences

### Positive consequences
- Extremely fast dependency resolution and installation (Rust-based, 10–100x faster than pip).
- `uv.lock` provides a fully reproducible, hash-verified install across all environments.
- Virtual environment management is automatic — no manual `python -m venv` required.
- Compatible with standard `pyproject.toml` — no proprietary lock file format dependencies.
- `uv run` ensures commands always execute inside the virtual environment.
- Docker image builds are significantly faster than with pip or poetry.
- Active development and responsive maintainer team (Astral).

### Negative consequences / trade-offs
- uv is newer than Poetry — some edge cases may be less documented or have fewer community answers.
- The `uv.lock` format is different from Poetry's `poetry.lock` — migration requires re-resolving dependencies.
- uv does not yet support all pip plugins and features.

### Neutral consequences
- The `.venv/` directory is created inside `apps/ai-service/` — excluded from Git via `.gitignore`.
- The root `package.json` npm workspaces do not include the Python service.
- CI installs uv as the first step of the Python CI job via `curl -LsSf https://astral.sh/uv/install.sh | sh` or via the `astral-sh/setup-uv` GitHub Actions action.

## Security Impact

- uv verifies package hashes during installation using the lock file. This provides supply-chain integrity for Python dependencies.
- `uv audit` can check for known CVEs in installed packages (when available — feature is in active development).
- The virtual environment is isolated from the system Python — no risk of contaminating or being contaminated by system packages.
- The system Python (3.9 EOL) is never used for project code.

## Privacy Impact

No direct privacy impact from the choice of package manager.

## Operational Impact

- Docker: The AI service Dockerfile installs uv and uses `uv sync --frozen` to install from the lock file. This is fast and reproducible.
- CI: The uv binary is cached between runs. Dependency installation takes seconds rather than minutes.
- Developer setup: `curl -LsSf https://astral.sh/uv/install.sh | sh` installs uv. Then `uv sync` from inside `apps/ai-service/` is sufficient to set up the complete environment.

## Migration Impact

Migrating from uv to Poetry would require:
- Converting `uv.lock` to `poetry.lock` by re-resolving all dependencies.
- Updating Dockerfiles and CI scripts.
- This is a low-cost migration if needed.

## Review Conditions

- Review if uv introduces a breaking change that affects the lock file format or project workflow.
- Review if Poetry significantly closes the performance gap and becomes the preferred community standard.
- Review if a supply-chain security incident in the uv distribution chain occurs.
