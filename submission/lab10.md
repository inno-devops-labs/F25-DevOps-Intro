# Lab 10 submission

### Release workflow
```yaml
name: Release
on:
  push:
    tags:
      - "v*"
  workflow_dispatch:

jobs:
  release-qn:
    name: Build & Publish QuickNotes image
    runs-on: ubuntu-24.04
    permissions:
      contents: read
      packages: write
    steps:
      - name: Setup Docker Buildx
        uses: docker/setup-buildx-action@d7f5e7f509e45cec5c76c4d5afdd7de93d0b3df5 # v4.1.0
      
      - name: Extract metadata
        uses: docker/metadata-action@80c7e94dd9b9319bd5eb7a0e0fe9291e23a2a2e9 # v6.1.0
        id: meta
        with:
          images: ghcr.io/${{ github.repository }}/quicknotes
          tags: |
            type=semver,pattern={{version}}
            type=raw,value=latest

      - name: Log in to GitHub Container Registry
        uses: docker/login-action@650006c6eb7dba73a995cc03b0b2d7f5ca915bee # v4.2.0
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build and push image
        uses: docker/build-push-action@f9f3042f7e2789586610d6e8b85c8f03e5195baf # v7.2.0
        with:
          context: '{{defaultContext}}:app'
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          annotations: ${{ steps.meta.outputs.annotations }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
          push: true
```

### Registry URL
`ghcr.io/arsenez2006/devops-intro/quicknotes:0.1.0` and `ghcr.io/arsenez2006/devops-intro/quicknotes:latest`

```sh
$ docker pull ghcr.io/arsenez2006/devops-intro/quicknotes:0.1.0
0.1.0: Pulling from arsenez2006/devops-intro/quicknotes
e102de8a9f66: Pull complete
b116f1a7952e: Pull complete
4f4fb700ef54: Pull complete
Digest: sha256:de230e158a3307b73763972d3867880b0d285938066d83a982ecb1f66dd27d3c
Status: Downloaded newer image for ghcr.io/arsenez2006/devops-intro/quicknotes:0.1.0
ghcr.io/arsenez2006/devops-intro/quicknotes:0.1.0
```

### Release action run
[Link](https://github.com/arsenez2006/DevOps-Intro/actions/runs/30260613915)

### Design questions
a) OIDC is used when authenticating to external cloud providers and services (AWS, GCP, Azure, Vault) without storing long-lived credentials in GitHub Secrets. Unlike `GITHUB_TOKEN`, OIDC provides keyless, short-lived authentication and allows external providers to enforce fine-grained access policies based on exact workflow claims (repository, branch, environment).\
b) The `:latest` tag serves as a convenient moving pointer (alias) for end users, local testing, and dev environments where hardcoding version updates is impractical. Meanwhile, immutable version tags like `:0.1.0` pin the image to a specific build context, ensuring deterministic deployments, reproducibility, and reliable rollbacks in production.\
c) This applies the Principle of Least Privilege (PoLP). Scoping permissions tightly ensures that if a workflow step or third-party dependency is compromised, an attacker can only push container images rather than rewriting repository source code (`contents: write`), altering workflow definitions, or deleting releases.
