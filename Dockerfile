# syntax=docker/dockerfile:1
FROM node:22.23.2-alpine@sha256:c610fcdfb1d5b4740dd70c284ed3cb16bb857e0f7166196e36a5501df7a3aa32 AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --omit=dev
COPY src ./src

FROM node:22.23.2-alpine@sha256:c610fcdfb1d5b4740dd70c284ed3cb16bb857e0f7166196e36a5501df7a3aa32 AS runtime
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
