#!/bin/sh
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

cleanup_mountpoints() {
  rmdir "$REPO_ROOT/node_modules" >/dev/null 2>&1 || true
}

trap cleanup_mountpoints EXIT

if [ "$#" -eq 0 ]; then
  echo "Usage: $0 <npm arguments...>" >&2
  exit 2
fi

docker run --rm \
  --volume "$REPO_ROOT:/workspace" \
  --volume /workspace/node_modules \
  --volume trusted-ai-platform-npm-cache:/root/.npm \
  --workdir /workspace \
  node:24.15.0-alpine3.22 \
  npm "$@"
