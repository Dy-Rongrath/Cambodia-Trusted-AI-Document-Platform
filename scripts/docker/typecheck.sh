#!/bin/sh
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$REPO_ROOT"
echo "Running type checking inside containers..."
docker run --rm -v "$REPO_ROOT":/app -w /app node:24.15.0-alpine3.21 sh -c "npm ci && npm run build --workspace=packages/shared-types && npm run prisma:generate --workspace=apps/backend && npm run typecheck"
docker run --rm -v "$REPO_ROOT/apps/ai-service":/app -w /app ghcr.io/astral-sh/uv:0.5-python3.12-alpine sh -c "uv sync --frozen --extra dev && uv run mypy src"
echo "Type checking completed successfully."
