#!/bin/sh
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SMOKE_SUFFIX="${RUNTIME_SMOKE_SUFFIX:-$$}"

BACKEND_IMAGE="trusted-ai-backend:runtime-smoke-$SMOKE_SUFFIX"
AI_IMAGE="trusted-ai-service:runtime-smoke-$SMOKE_SUFFIX"
FRONTEND_IMAGE="trusted-ai-frontend:runtime-smoke-$SMOKE_SUFFIX"

POSTGRES_CONTAINER="trusted-ai-postgres-runtime-smoke-$SMOKE_SUFFIX"
BACKEND_CONTAINER="trusted-ai-backend-runtime-smoke-$SMOKE_SUFFIX"
AI_CONTAINER="trusted-ai-service-runtime-smoke-$SMOKE_SUFFIX"
FRONTEND_CONTAINER="trusted-ai-frontend-runtime-smoke-$SMOKE_SUFFIX"
SMOKE_NETWORK="trusted-ai-runtime-smoke-$SMOKE_SUFFIX"

cleanup() {
  docker rm --force "$POSTGRES_CONTAINER" "$BACKEND_CONTAINER" "$AI_CONTAINER" "$FRONTEND_CONTAINER" >/dev/null 2>&1 || true
  docker network rm "$SMOKE_NETWORK" >/dev/null 2>&1 || true
  docker image rm "$BACKEND_IMAGE" "$AI_IMAGE" "$FRONTEND_IMAGE" >/dev/null 2>&1 || true
}

wait_for_command() {
  container_name="$1"
  shift
  attempt=1

  while [ "$attempt" -le 30 ]; do
    if docker exec "$container_name" "$@" >/dev/null 2>&1; then
      return 0
    fi
    attempt=$((attempt + 1))
    sleep 1
  done

  echo "Runtime smoke check failed for $container_name." >&2
  docker logs "$container_name" >&2 || true
  return 1
}

trap cleanup EXIT HUP INT TERM

cd "$REPO_ROOT"

echo "Building production runtime images..."
docker build --target runtime --tag "$BACKEND_IMAGE" -f apps/backend/Dockerfile .
docker build --target runtime --tag "$AI_IMAGE" -f apps/ai-service/Dockerfile .
docker build --target runtime --tag "$FRONTEND_IMAGE" -f apps/frontend/Dockerfile .

echo "Starting isolated production runtime containers..."
docker network create "$SMOKE_NETWORK" >/dev/null
docker run --detach --name "$POSTGRES_CONTAINER" --network "$SMOKE_NETWORK" --env POSTGRES_USER=runtime_smoke --env POSTGRES_PASSWORD=runtime_smoke_password --env POSTGRES_DB=runtime_smoke postgres:17.4-alpine >/dev/null

echo "Waiting for isolated PostgreSQL..."
wait_for_command "$POSTGRES_CONTAINER" pg_isready -U runtime_smoke -d runtime_smoke

docker run --detach --name "$BACKEND_CONTAINER" --network "$SMOKE_NETWORK" --env "DATABASE_URL=postgresql://runtime_smoke:runtime_smoke_password@$POSTGRES_CONTAINER:5432/runtime_smoke?schema=public" "$BACKEND_IMAGE" >/dev/null
docker run --detach --name "$AI_CONTAINER" --network "$SMOKE_NETWORK" "$AI_IMAGE" >/dev/null
docker run --detach --name "$FRONTEND_CONTAINER" --network "$SMOKE_NETWORK" "$FRONTEND_IMAGE" >/dev/null

echo "Checking backend production liveness and PostgreSQL readiness..."
wait_for_command "$BACKEND_CONTAINER" wget --no-verbose --tries=1 --spider http://127.0.0.1:3000/health/live
wait_for_command "$BACKEND_CONTAINER" wget --no-verbose --tries=1 --spider http://127.0.0.1:3000/health/ready

echo "Confirming backend stays live but becomes unready when PostgreSQL stops..."
docker stop "$POSTGRES_CONTAINER" >/dev/null
wait_for_command "$BACKEND_CONTAINER" wget --no-verbose --tries=1 --spider http://127.0.0.1:3000/health/live
docker exec "$BACKEND_CONTAINER" node -e 'fetch("http://127.0.0.1:3000/health/ready").then(async (response) => { const body = await response.json(); console.log(JSON.stringify({ status: response.status, body })); if (response.status !== 503 || body.dependencies?.postgres !== "unavailable") process.exit(1); }).catch((error) => { console.error(error); process.exit(1); })'

echo "Checking AI service production liveness and readiness..."
wait_for_command "$AI_CONTAINER" python -c \
  'import urllib.request; urllib.request.urlopen("http://127.0.0.1:8000/health/live", timeout=2)'
wait_for_command "$AI_CONTAINER" python -c \
  'import urllib.request; urllib.request.urlopen("http://127.0.0.1:8000/health/ready", timeout=2)'

echo "Checking frontend non-root runtime and health endpoints..."
test "$(docker exec "$FRONTEND_CONTAINER" id -u)" -ne 0
wait_for_command "$FRONTEND_CONTAINER" wget --no-verbose --tries=1 --spider http://127.0.0.1:8080/health/live
wait_for_command "$FRONTEND_CONTAINER" wget --no-verbose --tries=1 --spider http://127.0.0.1:8080/health/ready
wait_for_command "$FRONTEND_CONTAINER" wget --no-verbose --tries=1 --spider http://127.0.0.1:8080/

echo "Confirming final images define runtime health checks..."
for image in "$BACKEND_IMAGE" "$AI_IMAGE" "$FRONTEND_IMAGE"; do
  test "$(docker image inspect --format '{{if .Config.Healthcheck}}configured{{end}}' "$image")" = "configured"
done

echo "All production runtime smoke checks passed."
