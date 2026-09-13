#!/usr/bin/env bash
# Starts the server on a scratch port and checks /healthz actually responds.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

readonly SMOKE_TEST_PORT=8099
readonly URL="http://localhost:${SMOKE_TEST_PORT}/healthz"

PORT="${SMOKE_TEST_PORT}" node src/server.js >/dev/null &
readonly server_pid=$!
trap 'kill "${server_pid}" 2>/dev/null || true' EXIT

for _ in $(seq 1 20); do
  if response=$(curl -sf "${URL}"); then
    echo "${response}" | grep -q '"status":"ok"' || {
      echo "unexpected /healthz body: ${response}" >&2
      exit 1
    }
    echo "smoke test passed: ${response}"
    exit 0
  fi
  sleep 0.25
done

echo "server never became healthy at ${URL}" >&2
exit 1
