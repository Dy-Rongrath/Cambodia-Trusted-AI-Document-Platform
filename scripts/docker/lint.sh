#!/bin/sh
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$REPO_ROOT"
echo "Running Prettier formatting check and ESLint inside Node container..."
docker run --rm -v "$REPO_ROOT":/app -w /app node:24-alpine3.21 sh -c "npm ci && npm run format:check && npm run lint"

echo "Running Ruff lint and format checks inside AI container..."
docker run --rm -v "$REPO_ROOT/apps/ai-service":/app -w /app ghcr.io/astral-sh/uv:0.5-python3.12-bookworm-slim sh -c "uv sync --frozen --extra dev && uv run ruff check . && uv run ruff format --check ."

echo "Lint checks completed successfully."
