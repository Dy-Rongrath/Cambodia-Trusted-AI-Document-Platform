#!/bin/sh
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
AI_SERVICE_ROOT="$(cd "$SCRIPT_DIR/../../apps/ai-service" && pwd)"

cleanup_mountpoints() {
  rmdir "$AI_SERVICE_ROOT/.venv" >/dev/null 2>&1 || true
}

trap cleanup_mountpoints EXIT

if [ "$#" -eq 0 ]; then
  echo "Usage: $0 <uv arguments...>" >&2
  exit 2
fi

docker run --rm \
  --volume "$AI_SERVICE_ROOT:/workspace" \
  --volume /workspace/.venv \
  --volume trusted-ai-platform-uv-cache:/root/.cache/uv \
  --workdir /workspace \
  --env MYPY_CACHE_DIR=/tmp/mypy-cache \
  --env PYTHONDONTWRITEBYTECODE=1 \
  --env PYTHONPYCACHEPREFIX=/tmp/pycache \
  --env PYTEST_ADDOPTS=-p\ no:cacheprovider \
  --env RUFF_NO_CACHE=true \
  --env UV_LINK_MODE=copy \
  ghcr.io/astral-sh/uv:0.12.1-python3.12-trixie-slim \
  uv "$@"
