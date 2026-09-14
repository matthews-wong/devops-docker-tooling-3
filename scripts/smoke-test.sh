#!/usr/bin/env bash
# Starts the server on a scratch port and checks /healthz actually responds.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

readonly SMOKE_TEST_PORT=8099
readonly BASE_URL="http://localhost:${SMOKE_TEST_PORT}"

PORT="${SMOKE_TEST_PORT}" node src/server.js >/dev/null &
readonly server_pid=$!
trap 'kill "${server_pid}" 2>/dev/null || true' EXIT

healthy=""
for _ in $(seq 1 20); do
  if response=$(curl -sf "${BASE_URL}/healthz"); then
    healthy=1
    break
  fi
  sleep 0.25
done

if [[ -z "${healthy}" ]]; then
  echo "server never became healthy at ${BASE_URL}/healthz" >&2
  exit 1
fi

echo "${response}" | grep -q '"status":"ok"' || {
  echo "unexpected /healthz body: ${response}" >&2
  exit 1
}

status=$(curl -s -o /dev/null -w '%{http_code}' "${BASE_URL}/not-a-real-route")
[[ "${status}" == "404" ]] || {
  echo "expected 404 from an unknown route, got ${status}" >&2
  exit 1
}

echo "smoke test passed: healthz=${response} unknown-route=${status}"
