FROM node:24.15.0-alpine3.21 AS base
WORKDIR /app

FROM base AS dependencies
COPY package.json package-lock.json ./
COPY packages/shared-types/package.json ./packages/shared-types/
COPY apps/frontend/package.json ./apps/frontend/
RUN npm ci --workspace=apps/frontend --workspace=packages/shared-types

FROM dependencies AS build
COPY tsconfig.base.json ./
COPY packages/shared-types ./packages/shared-types
COPY apps/frontend ./apps/frontend
RUN npm run build --workspace=packages/shared-types
RUN npm run build --workspace=apps/frontend

FROM nginx:1.27-alpine AS runtime
COPY --from=build /app/apps/frontend/dist/frontend/browser /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
