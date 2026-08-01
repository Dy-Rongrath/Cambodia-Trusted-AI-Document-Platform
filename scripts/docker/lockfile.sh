#!/bin/sh
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$REPO_ROOT"
echo "Generating complete root package-lock.json using Node Docker container..."
docker run --rm -v "$REPO_ROOT":/workspace -w /workspace node:24-alpine3.21 npm install --package-lock-only
echo "Root package-lock.json generated successfully."
