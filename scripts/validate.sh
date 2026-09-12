#!/usr/bin/env bash
# Lightweight, no-daemon-required checks for this repo's Docker artifacts.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

echo "==> node --check src/server.js"
node --check src/server.js

echo "==> hadolint Dockerfile"
hadolint Dockerfile

echo "==> docker compose config"
docker compose config >/dev/null

echo "All checks passed."
