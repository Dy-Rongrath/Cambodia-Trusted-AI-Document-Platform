# syntax=docker/dockerfile:1

# ---------------------------------------------------------------------------
# Base — exact pinned Node.js 24.15.0 on Alpine 3.22
# ---------------------------------------------------------------------------
FROM node:24.15.0-alpine3.22 AS base
WORKDIR /app

# ---------------------------------------------------------------------------
# Dependencies — install workspace packages for backend and shared-types
# ---------------------------------------------------------------------------
FROM base AS dependencies
COPY package.json package-lock.json ./
COPY packages/shared-types/package.json ./packages/shared-types/
COPY apps/backend/package.json ./apps/backend/
RUN npm ci --workspace=apps/backend --workspace=packages/shared-types

# ---------------------------------------------------------------------------
# Development — hot-reload NestJS dev server with Prisma Client generation
# ---------------------------------------------------------------------------
FROM dependencies AS development
COPY tsconfig.base.json ./
COPY packages/shared-types ./packages/shared-types
COPY apps/backend ./apps/backend
RUN npm run build --workspace=packages/shared-types
RUN npm run prisma:generate --workspace=apps/backend
EXPOSE 3000
CMD ["npm", "run", "dev", "--workspace=apps/backend"]

# ---------------------------------------------------------------------------
# Test — Jest unit tests (pass-through with no tests in Phase 1)
# ---------------------------------------------------------------------------
FROM development AS test
CMD ["npm", "run", "test:ci", "--workspace=apps/backend"]

# ---------------------------------------------------------------------------
# Build — compile TypeScript to dist/
# ---------------------------------------------------------------------------
FROM development AS build
RUN npm run build --workspace=apps/backend

# ---------------------------------------------------------------------------
# Runtime — non-root production image. Includes only built output,
# hoisted node_modules, and generated Prisma Client.
# ---------------------------------------------------------------------------
FROM base AS runtime
ENV NODE_ENV=production
USER node
COPY --chown=node:node --from=build /app/node_modules ./node_modules
COPY --chown=node:node --from=build /app/packages/shared-types ./packages/shared-types
COPY --chown=node:node --from=build /app/apps/backend/dist ./apps/backend/dist
COPY --chown=node:node --from=build /app/apps/backend/package.json ./apps/backend/package.json

EXPOSE 3000
CMD ["node", "apps/backend/dist/main.js"]
