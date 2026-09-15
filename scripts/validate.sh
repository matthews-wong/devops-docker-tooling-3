#!/usr/bin/env bash
# Lightweight, no-daemon-required checks for this repo's Docker artifacts.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

echo "==> node --check src/server.js"
node --check src/server.js

echo "==> unit tests"
npm test

echo "==> shellcheck scripts/*.sh"
shellcheck scripts/validate.sh scripts/smoke-test.sh

echo "==> smoke test /healthz"
./scripts/smoke-test.sh

echo "==> hadolint Dockerfile"
hadolint Dockerfile

echo "==> docker compose config"
docker compose config >/dev/null

echo "==> docker compose config (dev override)"
docker compose -f docker-compose.yml -f docker-compose.dev.yml config >/dev/null

echo "All checks passed."
