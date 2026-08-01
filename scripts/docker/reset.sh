#!/bin/sh
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$REPO_ROOT"
echo "Resetting Docker Compose stack and removing named volumes..."
docker compose --profile auth down -v
echo "Reset complete."
