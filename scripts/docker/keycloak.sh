#!/bin/sh
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$REPO_ROOT"
ACTION="${1:-start}"

if [ "$ACTION" = "start" ]; then
  echo "Starting Keycloak under 'auth' profile..."
  docker compose --profile auth up -d keycloak
  echo "Waiting for Keycloak readiness (health/ready on management port 9000)..."
  # Wait until Docker reports the container healthy (KC_HEALTH_ENABLED=true)
  timeout 120s sh -c '
    until [ "$(docker inspect --format={{.State.Health.Status}} trusted-ai-keycloak 2>/dev/null)" = "healthy" ]; do
      printf "."
      sleep 5
    done
  ' || {
    echo ""
    echo "FAIL: Keycloak did not become healthy within 120 seconds."
    echo "=== Keycloak container logs ==="
    docker compose --profile auth logs keycloak --tail=50 || true
    exit 1
  }
  echo ""
  echo "Keycloak is ready."
elif [ "$ACTION" = "stop" ]; then
  echo "Stopping Keycloak..."
  docker compose --profile auth stop keycloak
else
  echo "Usage: $0 [start|stop]"
  exit 1
fi
