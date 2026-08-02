#!/bin/sh
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$REPO_ROOT"
echo "Running Node and frontend type checks in cache-efficient Docker build stages..."
docker build \
  --file infra/docker/tooling.Dockerfile \
  --target typecheck \
  .

echo "Running Python type checks in cache-efficient Docker build stages..."
docker build \
  --file apps/ai-service/Dockerfile \
  --target typecheck \
  .

echo "Type checking completed successfully."
