# syntax=docker/dockerfile:1

# Cache Node dependencies independently from source code. This image is for
# local/CI quality gates only; it is never used as an application runtime.
FROM node:24.15.0-alpine3.22 AS dependencies
WORKDIR /app
COPY package.json package-lock.json ./
COPY apps/backend/package.json ./apps/backend/
COPY apps/frontend/package.json ./apps/frontend/
COPY packages/shared-types/package.json ./packages/shared-types/
RUN --mount=type=cache,target=/root/.npm npm ci

FROM dependencies AS source
COPY . .

FROM source AS lint
RUN npm run format:check
RUN npm run lint

FROM source AS typecheck
RUN npm run build --workspace=packages/shared-types
RUN npm run typecheck
