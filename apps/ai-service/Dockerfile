# syntax=docker/dockerfile:1

# ---------------------------------------------------------------------------
# Base — Python 3.12.9 on Debian Bookworm Slim
# ---------------------------------------------------------------------------
FROM python:3.12.9-slim-bookworm AS base
WORKDIR /app/apps/ai-service
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# ---------------------------------------------------------------------------
# Development — install all deps (including dev) for hot-reload and testing
# ---------------------------------------------------------------------------
FROM base AS development
COPY --from=ghcr.io/astral-sh/uv:0.5-python3.12-bookworm-slim /uv /bin/uv
COPY apps/ai-service/pyproject.toml apps/ai-service/uv.lock* apps/ai-service/.python-version apps/ai-service/README.md ./
RUN uv sync --frozen --extra dev
COPY apps/ai-service/src ./src
COPY apps/ai-service/tests ./tests
EXPOSE 8000
CMD ["uv", "run", "uvicorn", "trusted_ai_service.main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]

# ---------------------------------------------------------------------------
# Test — runs ruff, mypy, and pytest inside the dev environment
# ---------------------------------------------------------------------------
FROM development AS test
RUN uv run ruff check .
RUN uv run ruff format --check .
RUN uv run mypy src
RUN uv run pytest

# ---------------------------------------------------------------------------
# Runtime — frozen production install, non-root user
# Uses --frozen to ensure the lockfile is respected exactly.
# USER nobody is replaced by a dedicated system user to avoid .venv
# ownership conflicts (venv is built as root, then ownership is corrected).
# ---------------------------------------------------------------------------
FROM base AS runtime
COPY --from=ghcr.io/astral-sh/uv:0.5-python3.12-bookworm-slim /uv /bin/uv
# Create a dedicated non-root system user before installing dependencies
RUN groupadd -r aiuser && useradd -r -g aiuser -d /app/apps/ai-service aiuser
COPY apps/ai-service/pyproject.toml apps/ai-service/uv.lock* apps/ai-service/.python-version apps/ai-service/README.md ./
# Install only production deps with frozen resolution; chown .venv to app user
RUN uv sync --frozen --no-dev && chown -R aiuser:aiuser .
COPY --chown=aiuser:aiuser apps/ai-service/src ./src
USER aiuser
EXPOSE 8000
CMD ["uv", "run", "uvicorn", "trusted_ai_service.main:app", "--host", "0.0.0.0", "--port", "8000"]
