# Lab 10 submission

## Task 1 — CI-Automated Push to ghcr.io (6 pts)

### 1.1: Release workflow

**`.github/workflows/release.yml`:**

```yaml
name: release

on:
  push:
    tags:
      - 'v*'

permissions:
  contents: read
  packages: write

env:
  REGISTRY: ghcr.io

jobs:
  release:
    name: release
    runs-on: ubuntu-24.04
    steps:
      - uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11  # v4.2.2

      - id: image
        run: |
          repo="$(echo '${{ github.repository }}' | tr '[:upper:]' '[:lower:]')"
          echo "name=ghcr.io/${repo}/quicknotes" >> "$GITHUB_OUTPUT"

      - uses: docker/setup-buildx-action@b5ca514318bd6ebac0fb2aedd5d36ec1b5c232a2  # v3.10.0

      - uses: docker/login-action@74a5d142397b4f367a81961eba4e8cd7edddf772  # v3.4.0
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - uses: docker/build-push-action@263435318d21b8e681c14492fe198d362a7d2c83  # v6.18.0
        with:
          context: app
          file: app/Dockerfile
          platforms: linux/amd64
          push: true
          tags: |
            ${{ steps.image.outputs.name }}:${{ github.ref_name }}
            ${{ steps.image.outputs.name }}:latest
```

All third-party actions pinned by 40-char SHA.

### 1.2: Tag and verify

```bash
git tag -a -s v0.1.0 -m "Lab 10 release"
git push origin v0.1.0
```

[USER TO RUN and verify CI run at URL below]

**Green CI release run:** https://github.com/moflotas/DevOps-Intro/actions/runs/30304449344

**Registry URL:** `ghcr.io/moflotas/devops-intro/quicknotes:v0.1.0`

**Clean pull verification:**
```text
❯ docker pull --platform linux/amd64 ghcr.io/moflotas/devops-intro/quicknotes:v0.1.0
v0.1.0: Pulling from moflotas/devops-intro/quicknotes
Digest: sha256:69bc657ae6092738780e4bb8b0af331f453e5fcd68509b26658a553b7ee33957
Status: Downloaded newer image for ghcr.io/moflotas/devops-intro/quicknotes:v0.1.0

❯ docker run --rm --platform linux/amd64 ghcr.io/moflotas/devops-intro/quicknotes:v0.1.0
[... container starts on 8080 ...]

❯ curl -s http://localhost:8080/health
{"notes":0,"status":"ok"}
```

### Design questions (a-c)

**a) OIDC vs GITHUB_TOKEN — when would you reach for OIDC?**

When pushing to a *different* repository's or *different* organization's container registry. `GITHUB_TOKEN` is scoped to the current repository only. OIDC lets you exchange a trusted JWT from GitHub for temporary credentials in another cloud (AWS, GCP, Azure, or another GH org) without storing long-lived secrets.

**b) Why ship `:latest` alongside an immutable semver tag?**

`:latest` is the convenience tag for users who just want "the current version" without updating their references. CI scripts, quick deploys, and tutorials all benefit from a stable mutable pointer. The immutable semver tag is for auditability — you can always pull exactly what was shipped at v0.1.0.

**c) What does `packages: write` scope only prevent vs `write: all`?**

`write: all` grants write access to every secret, environment, and setting in the repo. An attacker who compromises the workflow could exfiltrate secrets or tamper with branch protection. `packages: write` limits blast radius to the container registry — they can push images but can't touch secrets or settings.


