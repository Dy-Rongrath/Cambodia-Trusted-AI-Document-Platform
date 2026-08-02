#!/bin/sh
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
ENV_FILE="${CLOUD_SQL_ENV_FILE:-$REPO_ROOT/.env.cloud-sql}"
ACTION="${1:-start}"

if [ ! -f "$ENV_FILE" ]; then
  echo "Cloud SQL environment file not found: $ENV_FILE" >&2
  echo "Copy .env.cloud-sql.example to .env.cloud-sql and fill in the required values." >&2
  exit 1
fi

# Run the non-root proxy as the host user so it can read a mode-0600 ADC file
# without weakening the credential file permissions.
CLOUD_SQL_PROXY_UID="$(id -u)"
CLOUD_SQL_PROXY_GID="$(id -g)"
export CLOUD_SQL_PROXY_UID CLOUD_SQL_PROXY_GID

cd "$REPO_ROOT"

compose() {
  docker compose \
    --env-file "$ENV_FILE" \
    -f compose.yaml \
    -f infra/docker/compose.cloud-sql.yaml \
    "$@"
}

case "$ACTION" in
  start)
    echo "Starting application services with the opt-in Cloud SQL connection..."
    compose config --quiet
    compose up -d cloud-sql-proxy backend ai-service frontend
    ;;
  start-web)
    echo "Starting application services with the opt-in Cloud SQL connection..."
    echo "(Caddy TLS proxy started via 'web' profile — ensure DNS records point to this host.)"
    compose config --quiet
    compose --profile web up -d cloud-sql-proxy backend ai-service frontend caddy
    ;;
  stop)
    # Suspends containers without destroying them. Use `down` for a full teardown.
    echo "Suspending the Cloud SQL development stack (containers preserved)..."
    compose --profile web stop
    ;;
  down)
    echo "Stopping and removing the Cloud SQL development stack..."
    compose --profile web down
    ;;
  check)
    echo "Checking backend connectivity through the Cloud SQL Auth Proxy..."
    compose exec backend npm run db:check --workspace=apps/backend
    ;;
  logs)
    compose logs --tail=100 cloud-sql-proxy backend
    ;;
  config)
    compose config --quiet
    echo "Cloud SQL Compose configuration is valid."
    ;;
  *)
    echo "Usage: $0 {start|start-web|stop|down|check|logs|config}" >&2
    exit 2
    ;;
esac
