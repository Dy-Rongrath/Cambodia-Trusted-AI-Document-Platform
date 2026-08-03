# syntax=docker/dockerfile:1

# ---------------------------------------------------------------------------
# Base — Python 3.12.9 on Debian Bookworm Slim
# ---------------------------------------------------------------------------
FROM python:3.12.9-slim-bookworm AS base
WORKDIR /app/apps/ai-service
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1
RUN apt-get update \
    && apt-get upgrade -y \
    && rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------------------------
# Development — install all deps (including dev) for hot-reload and testing
# ---------------------------------------------------------------------------
FROM base AS development
COPY --from=ghcr.io/astral-sh/uv:0.12.1 /uv /bin/uv
COPY apps/ai-service/pyproject.toml apps/ai-service/uv.lock* apps/ai-service/.python-version apps/ai-service/README.md ./
RUN uv sync --frozen --extra dev
COPY apps/ai-service/src ./src
COPY apps/ai-service/tests ./tests
EXPOSE 8000
CMD ["uv", "run", "uvicorn", "trusted_ai_service.main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]

# ---------------------------------------------------------------------------
# Lint — runs source-format and lint checks inside the dev environment
# ---------------------------------------------------------------------------
FROM development AS lint
RUN uv run ruff check .
RUN uv run ruff format --check .

# ---------------------------------------------------------------------------
# Typecheck — checks static types independently from the lint target
# ---------------------------------------------------------------------------
FROM development AS typecheck
RUN uv run mypy src

# ---------------------------------------------------------------------------
# Test — preserves the complete lint, typecheck, and test quality gate
# ---------------------------------------------------------------------------
FROM lint AS test
RUN uv run mypy src
RUN uv run pytest

# ---------------------------------------------------------------------------
# Production dependencies — create the frozen virtual environment with uv.
# ---------------------------------------------------------------------------
FROM base AS production-dependencies
COPY --from=ghcr.io/astral-sh/uv:0.12.1 /uv /bin/uv
COPY apps/ai-service/pyproject.toml apps/ai-service/uv.lock* apps/ai-service/.python-version apps/ai-service/README.md ./
RUN uv sync --frozen --no-dev

# ---------------------------------------------------------------------------
# Runtime — production virtual environment only, without uv build tooling.
# ---------------------------------------------------------------------------
FROM base AS runtime
ENV PATH="/app/apps/ai-service/.venv/bin:${PATH}" \
    PYTHONPATH="/app/apps/ai-service/src"
RUN groupadd -r aiuser && useradd -r -g aiuser -d /app/apps/ai-service aiuser
COPY --chown=aiuser:aiuser --from=production-dependencies /app/apps/ai-service/.venv ./.venv
COPY --chown=aiuser:aiuser apps/ai-service/src ./src
USER aiuser
EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD python -c 'import urllib.request; urllib.request.urlopen("http://127.0.0.1:8000/health/ready", timeout=2)'
CMD ["uvicorn", "trusted_ai_service.main:app", "--host", "0.0.0.0", "--port", "8000"]
