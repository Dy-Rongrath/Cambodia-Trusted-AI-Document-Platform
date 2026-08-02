#!/bin/sh
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$REPO_ROOT"


echo "Starting Phase 1 default Docker Compose services (postgres, backend, ai-service, frontend)..."
docker compose up -d
echo "Services started successfully."
