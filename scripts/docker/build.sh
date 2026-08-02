#!/bin/sh
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$REPO_ROOT"
echo "Building all Docker Compose development service images..."
docker compose build

echo "Building and smoke-testing application production runtimes..."
"$SCRIPT_DIR/runtime-smoke.sh"

echo "Build complete."
