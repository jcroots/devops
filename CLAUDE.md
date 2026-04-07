# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Does

Builds two Docker container images (AWS and GCloud variants) pre-loaded with cloud infrastructure tools for DevOps work. Images are published to GHCR as multi-arch (amd64/arm64).

## Build Commands

```bash
make all        # Build both aws and gcloud images (parallel -j2)
make aws        # Build only the AWS container
make gcloud     # Build only the GCloud container
make check      # Run shellcheck on all .sh files
make ci-check   # CI verification (runs check target)
make prune      # Docker system prune
```

Build uses `build.sh <container-name>` which runs `docker build` with the container directory as context and `root/` copied in for shared scripts.

## Linting

All shell scripts are linted with `shellcheck`. Run `make check` before committing. CI runs this on pushes to `main` and `next` branches.

## Architecture

- **`aws/`** and **`gcloud/`** — Each contains a `Dockerfile` and `user-login.sh` entry point. AWS uses `debian:forky-*-slim` base; GCloud uses the official `google-cloud-cli` image.
- **`root/bin/`** — Individual install scripts for each tool (terraform, claude-code, aws-ssm, gcloud-sql-proxy, apt packages). These are copied into the build context and executed during `docker build`.
- **`root/etc/`** — APT package lists. `devops.list` is shared; `devops-aws.list` adds AWS-specific packages.
- **`usr/local/etc/devops.bashrc`** — Shared shell configuration sourced via `/home/devops/.profile`.
- **`upgrade.py`** — Checks for newer versions of Terraform, Cloud SQL Proxy, Debian base image, and GCloud SDK via their respective APIs. Supports `--dry-run`.

## Versioning

- `JCROOTS_VERSION` in Dockerfiles uses YYMMDD format (e.g., `260406` = 2026-04-06).
- Tool versions are hardcoded in install scripts and Dockerfiles. Use `upgrade.py` to check for updates.

## Release Process

Tag with `release/<version>` to trigger the release workflow. It builds multi-arch images via Docker Buildx and pushes to `ghcr.io/<owner>/devops/{aws,gcloud}-<version>`.

## Container User

Containers run as non-root user `devops` (UID 1980) with home at `/home/devops`.
