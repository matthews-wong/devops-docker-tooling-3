# healthcheck-api

[![validate](https://github.com/matthews-wong/devops-docker-tooling-3/actions/workflows/validate.yml/badge.svg)](https://github.com/matthews-wong/devops-docker-tooling-3/actions/workflows/validate.yml)

A minimal HTTP service with a `/healthz` endpoint, packaged as a hardened
container image. No framework, no external dependencies — just Node's
built-in `http` module — so the Dockerfile and compose setup are the whole
point of the exercise, not incidental to it.

## Run it locally

```sh
node src/server.js
curl localhost:8080/healthz
```

## Run it in a container

```sh
docker build -t healthcheck-api .
docker run --rm -p 8080:8080 healthcheck-api
```

## Run it with Compose

```sh
docker compose up --build
```

## Validation

`scripts/validate.sh` runs the checks that don't need a Docker daemon:
Node syntax check, [hadolint](https://github.com/hadolint/hadolint) against
the Dockerfile, and `docker compose config` to catch a malformed compose
file before anyone tries to run it.

```sh
./scripts/validate.sh
```

CI runs the same script on every push and pull request (see
`.github/workflows/validate.yml`).

## Design decisions

- **Zero runtime dependencies.** The service only needs `http.createServer`,
  so there's nothing to audit, patch, or pin in `node_modules`. The
  multi-stage Dockerfile still runs `npm install` in its own stage so the
  pattern is there once real dependencies show up.
- **`read_only: true` in Compose.** The app never writes to disk, so the
  container filesystem doesn't need to be writable. If a future version
  needs a scratch directory, mount a `tmpfs` for just that path rather than
  dropping `read_only`.
- **`wget --spider` for the healthcheck**, not `curl`, because Alpine ships
  `wget` via BusyBox and adding `curl` would mean an extra package layer for
  a single HTTP GET.

More setup and validation notes will land in this README as the project
grows.
