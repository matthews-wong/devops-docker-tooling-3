# syntax=docker/dockerfile:1
FROM node:26.13.1-alpine@sha256:6bd9ab43c0ec0190ca7b2d193906cb8b7edf6e7f4afa43ddeccd6452710bffb5 AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --omit=dev
COPY src ./src

FROM node:26.13.1-alpine@sha256:6bd9ab43c0ec0190ca7b2d193906cb8b7edf6e7f4afa43ddeccd6452710bffb5 AS runtime
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
