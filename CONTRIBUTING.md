# Contributing

## Before opening a PR

Run the full validation suite locally:

```sh
./scripts/validate.sh
```

It checks `src/server.js` syntax, shellchecks the scripts, smoke-tests the
running server, hadolints the Dockerfile, and renders both compose files.
CI runs the same script, so a clean local run means CI should be clean too.

## Commit style

Commits follow [Conventional Commits](https://www.conventionalcommits.org/):
`type(scope): subject`, imperative mood, no trailing period. Common types
here are `feat`, `fix`, `chore`, `docs`, `test`, and `ci`.

## Conventions

- Base images and GitHub Actions are pinned to a digest or full commit SHA,
  never a mutable tag — see the design decisions in the README for why.
- Every container-facing change should keep `hadolint` and
  `docker compose config` clean; every shell script change should keep
  `shellcheck` clean.
- Keep PRs focused: one logical change per commit, one theme per PR.
