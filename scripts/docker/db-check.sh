#!/bin/sh
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$REPO_ROOT"

if [ -f ".env.cloud-sql" ]; then
  echo "Cloud SQL environment file (.env.cloud-sql) detected — checking Cloud SQL database connection..."
  exec "$SCRIPT_DIR/cloud-sql.sh" check
fi

echo "Ensuring postgres and backend are running (partial stack — ai-service and frontend not started)..."
docker compose up -d postgres backend

echo "Running backend database connectivity check inside container..."
docker compose exec backend npm run db:check --workspace=apps/backend

echo "Database check complete."
