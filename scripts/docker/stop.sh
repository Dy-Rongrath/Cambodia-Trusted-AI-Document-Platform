#!/bin/sh
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$REPO_ROOT"

if [ -f ".env.cloud-sql" ]; then
  echo "Cloud SQL environment file (.env.cloud-sql) detected — stopping Cloud SQL stack..."
  exec "$SCRIPT_DIR/cloud-sql.sh" stop
fi

echo "Stopping all Docker Compose services..."
docker compose --profile auth --profile web down
echo "Services stopped cleanly."
