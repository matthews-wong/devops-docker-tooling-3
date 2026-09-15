# syntax=docker/dockerfile:1
FROM node:26.8-alpine@sha256:ef24c5053d50fdc3e4e56eb4e7ddb7861874ab0fdc797046ba897581deb8e868 AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --omit=dev
COPY src ./src

FROM node:26.8-alpine@sha256:ef24c5053d50fdc3e4e56eb4e7ddb7861874ab0fdc797046ba897581deb8e868 AS runtime
LABEL org.opencontainers.image.source="https://github.com/matthews-wong/devops-docker-tooling-3" \
      org.opencontainers.image.description="Minimal HTTP service with a /healthz endpoint" \
      org.opencontainers.image.licenses="MIT"
ENV NODE_ENV=production
WORKDIR /app
COPY --from=build /app ./
# The image is never used to install or run npm packages at runtime, so drop
# the bundled npm CLI — it pulls in far more third-party code (and CVEs)
# than the service itself does.
RUN rm -rf /usr/local/lib/node_modules/npm /usr/local/bin/npm /usr/local/bin/npx /usr/local/bin/corepack
USER node
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:8080/healthz || exit 1
CMD ["node", "src/server.js"]
