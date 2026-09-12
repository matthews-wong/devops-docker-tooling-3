# healthcheck-api

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

More setup and validation notes will land in this README as the project
grows.
