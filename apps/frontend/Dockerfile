# syntax=docker/dockerfile:1

# ---------------------------------------------------------------------------
# Base — exact pinned Node.js 24.15.0 on Alpine 3.22
# ---------------------------------------------------------------------------
FROM node:24.15.0-alpine3.22 AS base
WORKDIR /app

# ---------------------------------------------------------------------------
# Dependencies — install workspace packages for frontend and shared-types
# ---------------------------------------------------------------------------
FROM base AS dependencies
COPY package.json package-lock.json ./
COPY packages/shared-types/package.json ./packages/shared-types/
COPY apps/frontend/package.json ./apps/frontend/
RUN npm ci --workspace=apps/frontend --workspace=packages/shared-types

# ---------------------------------------------------------------------------
# Development — hot-reload dev server (Angular Vite dev server)
# ---------------------------------------------------------------------------
FROM dependencies AS development
COPY tsconfig.base.json ./
COPY packages/shared-types ./packages/shared-types
COPY apps/frontend ./apps/frontend
RUN npm run build --workspace=packages/shared-types
EXPOSE 4200
CMD ["npm", "run", "start", "--workspace=apps/frontend", "--", "--host", "0.0.0.0", "--port", "4200"]

# ---------------------------------------------------------------------------
# Test — Vitest unit tests run in Node.js (no browser required)
# Angular @angular/build:unit-test uses Vitest with jsdom emulation.
# No Chromium or Xvfb needed.
# ---------------------------------------------------------------------------
FROM development AS test
ENV CI=true
RUN npm run test --workspace=apps/frontend

# ---------------------------------------------------------------------------
# Build — production AOT compilation
# ---------------------------------------------------------------------------
FROM development AS build
RUN npm run build --workspace=apps/frontend

# ---------------------------------------------------------------------------
# Runtime — non-root Nginx serves only the pre-built static assets.
# No Angular CLI, no Node.js, no Chromium in the final image.
# ---------------------------------------------------------------------------
FROM nginx:1.27.5-alpine AS runtime

COPY apps/frontend/nginx.conf /etc/nginx/nginx.conf
COPY --chown=nginx:nginx --from=build /app/apps/frontend/dist/frontend/browser /usr/share/nginx/html
USER nginx
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://127.0.0.1:8080/health/ready || exit 1
CMD ["nginx", "-g", "daemon off;"]
