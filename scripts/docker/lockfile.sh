#!/bin/sh
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$REPO_ROOT"
echo "Generating complete root package-lock.json using Node Docker container..."
"$SCRIPT_DIR/npm.sh" install --package-lock-only
echo "Root package-lock.json generated successfully."
