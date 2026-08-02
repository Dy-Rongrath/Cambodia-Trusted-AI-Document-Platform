#!/bin/sh
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$REPO_ROOT"

if [ "${1:-}" != "--confirm" ]; then
  echo "WARNING: Resetting Docker Compose stack with -v deletes named volumes (including database data)."
  echo "To confirm execution, run: $0 --confirm"
  exit 1
fi

echo "Resetting Docker Compose stack and removing named volumes..."
docker compose --profile auth --profile web down -v
echo "Reset complete."
