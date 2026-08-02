#!/bin/sh
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$REPO_ROOT"
echo "Regenerating complete apps/ai-service/uv.lock using uv Docker container..."
"$SCRIPT_DIR/uv.sh" lock
echo "apps/ai-service/uv.lock generated successfully."
