#!/bin/sh
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$REPO_ROOT"
echo "Regenerating complete apps/ai-service/uv.lock using uv Docker container..."
docker run --rm -v "$REPO_ROOT/apps/ai-service":/app -w /app ghcr.io/astral-sh/uv:0.12.1-python3.12-trixie-slim uv lock
echo "apps/ai-service/uv.lock generated successfully."
