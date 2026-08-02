#!/bin/sh
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$REPO_ROOT"
echo "Stopping all Docker Compose services..."
docker compose --profile auth --profile web down
echo "Services stopped cleanly."
