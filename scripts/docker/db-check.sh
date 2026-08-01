#!/bin/sh
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$REPO_ROOT"
echo "Ensuring database service is running and healthy..."
docker compose up -d postgres backend

echo "Running backend database connectivity check inside container..."
docker compose exec backend npm run db:check

echo "Database check complete."
