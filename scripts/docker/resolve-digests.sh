#!/bin/sh
set -eu

echo "Resolving digests..."
echo "--- postgres:17.4-alpine ---"
docker buildx imagetools inspect postgres:17.4-alpine --raw || true
echo "--- caddy:2.10-alpine ---"
docker buildx imagetools inspect caddy:2.10-alpine --raw || true
echo "--- quay.io/keycloak/keycloak:26.1.3 ---"
docker buildx imagetools inspect quay.io/keycloak/keycloak:26.1.3 --raw || true
echo "--- gcr.io/cloud-sql-connectors/cloud-sql-proxy:2.14.2 ---"
docker buildx imagetools inspect gcr.io/cloud-sql-connectors/cloud-sql-proxy:2.14.2 --raw || true
echo "--- node:24.15.0-alpine3.22 ---"
docker buildx imagetools inspect node:24.15.0-alpine3.22 --raw || true
echo "--- ghcr.io/astral-sh/uv:0.12.1-python3.12-trixie-slim ---"
docker buildx imagetools inspect ghcr.io/astral-sh/uv:0.12.1-python3.12-trixie-slim --raw || true
echo "--- docker.io/aquasec/trivy:0.72.0 ---"
docker buildx imagetools inspect docker.io/aquasec/trivy:0.72.0 --raw || true
