#!/bin/sh
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$REPO_ROOT"
echo "Formatting codebase with Prettier inside Node container..."
docker run --rm -v "$REPO_ROOT":/app -w /app node:24-alpine3.21 sh -c "npm ci && npm run format"
echo "Formatting complete."
