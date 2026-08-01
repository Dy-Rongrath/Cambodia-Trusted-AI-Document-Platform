FROM python:3.12.9-slim-bookworm AS base
WORKDIR /app
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

FROM base AS development
COPY --from=ghcr.io/astral-sh/uv:0.5-python3.12-alpine /uv /bin/uv
COPY pyproject.toml uv.lock* .python-version ./
RUN uv sync --extra dev
COPY src ./src
COPY tests ./tests
CMD ["uv", "run", "uvicorn", "trusted_ai_service.main:app", "--host", "0.0.0.0", "--port", "8000"]

FROM development AS test
RUN uv run ruff check .
RUN uv run ruff format --check .
RUN uv run mypy src
RUN uv run pytest

FROM base AS runtime
COPY --from=ghcr.io/astral-sh/uv:0.5-python3.12-alpine /uv /bin/uv
COPY pyproject.toml uv.lock* .python-version ./
RUN uv sync --no-dev
COPY src ./src
USER nobody
EXPOSE 8000
CMD ["uv", "run", "uvicorn", "trusted_ai_service.main:app", "--host", "0.0.0.0", "--port", "8000"]
