#!/bin/sh
set -eu

NPM_CACHE_VOLUME="trusted-ai-platform-npm-cache"
UV_CACHE_VOLUME="trusted-ai-platform-uv-cache"

case "${1:-status}" in
  status)
    echo "Docker-managed dependency cache volumes:"
    for volume in "$NPM_CACHE_VOLUME" "$UV_CACHE_VOLUME"; do
      if docker volume inspect "$volume" >/dev/null 2>&1; then
        docker volume inspect --format '{{.Name}}: {{.Mountpoint}}' "$volume"
      else
        echo "$volume: not created"
      fi
    done
    ;;
  clear)
    if [ "${2:-}" != "--confirm" ]; then
      echo "This removes only the npm and uv download cache volumes." >&2
      echo "To confirm execution, run: $0 clear --confirm" >&2
      exit 1
    fi

    for volume in "$NPM_CACHE_VOLUME" "$UV_CACHE_VOLUME"; do
      if docker volume inspect "$volume" >/dev/null 2>&1; then
        docker volume rm "$volume"
      else
        echo "$volume: already absent"
      fi
    done
    ;;
  *)
    echo "Usage: $0 [status|clear --confirm]" >&2
    exit 2
    ;;
esac
