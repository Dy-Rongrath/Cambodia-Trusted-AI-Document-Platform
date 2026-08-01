#!/bin/sh
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$REPO_ROOT"
echo "Running lint checks inside containers..."
docker run --rm -v "$REPO_ROOT":/app -w /app node:24.15.0-alpine3.21 sh -c "npm ci && npm run lint"
docker run --rm -v "$REPO_ROOT/apps/ai-service":/app -w /app ghcr.io/astral-sh/uv:0.5-python3.12-alpine sh -c "uv sync --frozen --extra dev && uv run ruff check ."
echo "Lint checks completed successfully."
