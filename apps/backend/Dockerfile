FROM node:24.15.0-alpine3.21 AS base
WORKDIR /app

FROM base AS dependencies
COPY package.json package-lock.json ./
COPY packages/shared-types/package.json ./packages/shared-types/
COPY apps/backend/package.json ./apps/backend/
RUN npm ci --workspace=apps/backend --workspace=packages/shared-types

FROM dependencies AS test
COPY tsconfig.base.json ./
COPY packages/shared-types ./packages/shared-types
COPY apps/backend ./apps/backend
RUN npm run build --workspace=packages/shared-types
RUN npm run prisma:generate --workspace=apps/backend
CMD ["npm", "run", "test", "--workspace=apps/backend"]

FROM test AS build
RUN npm run build --workspace=apps/backend

FROM base AS runtime
ENV NODE_ENV=production
USER node
COPY --chown=node:node --from=dependencies /app/node_modules ./node_modules
COPY --chown=node:node --from=build /app/packages/shared-types ./packages/shared-types
COPY --chown=node:node --from=build /app/apps/backend/dist ./apps/backend/dist
COPY --chown=node:node --from=build /app/apps/backend/node_modules ./apps/backend/node_modules
COPY --chown=node:node --from=build /app/apps/backend/package.json ./apps/backend/package.json

EXPOSE 3000
CMD ["node", "apps/backend/dist/main.js"]
