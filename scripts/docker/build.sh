#!/bin/sh
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$REPO_ROOT"
echo "Building all Docker Compose development service images..."
docker compose build

echo "Validating application production runtime build stages..."
docker build --target runtime -f apps/backend/Dockerfile .
docker build --target runtime -f apps/ai-service/Dockerfile .
docker build --target runtime -f apps/frontend/Dockerfile .

echo "Build complete."
