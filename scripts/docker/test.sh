#!/bin/sh
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$REPO_ROOT"
echo "Running test stages for all services inside Docker..."

echo "[1/3] Backend test stage..."
docker build --target test -f apps/backend/Dockerfile .

echo "[2/3] Frontend test stage..."
docker build --target test -f apps/frontend/Dockerfile .

echo "[3/3] AI service test stage..."
docker build --target test -f apps/ai-service/Dockerfile .

echo "All service test stages completed successfully."
