#!/bin/sh
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$REPO_ROOT"
echo "Checking PostgreSQL database connectivity from backend container..."
docker compose exec backend npm run db:check
echo "Database check complete."
