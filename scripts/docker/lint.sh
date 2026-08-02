#!/bin/sh
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$REPO_ROOT"
echo "Running Prettier and ESLint in cache-efficient Docker build stages..."
docker build \
  --file infra/docker/tooling.Dockerfile \
  --target lint \
  .

echo "Running Ruff lint and format checks in cache-efficient Docker build stages..."
docker build \
  --file apps/ai-service/Dockerfile \
  --target lint \
  .

echo "Lint checks completed successfully."
