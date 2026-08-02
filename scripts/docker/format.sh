#!/bin/sh
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TOOLING_IMAGE="trusted-ai-platform-node-tooling:local"

cd "$REPO_ROOT"
echo "Formatting codebase with Prettier inside Node container..."
docker build \
  --file infra/docker/tooling.Dockerfile \
  --target dependencies \
  --tag "$TOOLING_IMAGE" \
  .
docker run --rm \
  --user "$(id -u):$(id -g)" \
  --volume "$REPO_ROOT:/workspace" \
  --workdir /workspace \
  "$TOOLING_IMAGE" \
  /app/node_modules/.bin/prettier --write "**/*.{ts,js,json,md,yml,yaml,scss,css}"
echo "Formatting complete."
