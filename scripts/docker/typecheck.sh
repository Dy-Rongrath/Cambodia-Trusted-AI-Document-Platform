#!/bin/sh
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$REPO_ROOT"
echo "Running type checking inside containers..."
# Always run npm ci — do not reuse host node_modules which may be stale,
# built for a different architecture, or created with a different Node version.
docker run --rm -v "$REPO_ROOT":/app -w /app node:24.15.0-alpine3.22 sh -c "npm ci && npm run build --workspace=packages/shared-types && npm run prisma:generate --workspace=apps/backend && npm run typecheck"
docker run --rm -v "$REPO_ROOT/apps/ai-service":/app -w /app ghcr.io/astral-sh/uv:0.12.1-python3.12-trixie-slim sh -c "uv sync --frozen --extra dev && uv run mypy src"
echo "Type checking completed successfully."
