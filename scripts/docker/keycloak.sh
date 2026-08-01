#!/bin/sh
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$REPO_ROOT"
ACTION="${1:-start}"

if [ "$ACTION" = "start" ]; then
  echo "Starting Keycloak under 'auth' profile..."
  docker compose --profile auth up -d keycloak
elif [ "$ACTION" = "stop" ]; then
  echo "Stopping Keycloak..."
  docker compose --profile auth stop keycloak
else
  echo "Usage: $0 [start|stop]"
  exit 1
fi
