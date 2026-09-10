# Lab 3 — CI/CD: A PR-Gated Pipeline for QuickNotes

- Student: Arina Nikolaeva (Nik-ari-ai)
- Fork: https://github.com/Nik-ari-ai/DevOps-Intro
- Branch: feature/lab3
- **Path: GitHub Actions** — I can sign in to github.com, so I took the default path and wrote `.github/workflows/ci.yml`.

## Task 1 — Write the PR Gate

### Pipeline

`.github/workflows/ci.yml` (final):

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
    paths:
      - 'app/**'
      - '.github/workflows/ci.yml'

permissions:
  contents: read

jobs:
  vet:
    runs-on: ubuntu-24.04
    strategy:
      fail-fast: false
      matrix:
        go: ['1.23', '1.24']
    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2
      - uses: actions/setup-go@3041bf56c941b39c61721a86cd11f3bb1338122a # v5.2.0
        with:
          go-version: ${{ matrix.go }}
          cache-dependency-path: app/go.mod
      - name: go vet
        working-directory: app
        run: go vet ./...

  test:
    runs-on: ubuntu-24.04
    strategy:
      fail-fast: false
      matrix:
        go: ['1.23', '1.24']
    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2
      - uses: actions/setup-go@3041bf56c941b39c61721a86cd11f3bb1338122a # v5.2.0
        with:
          go-version: ${{ matrix.go }}
          cache-dependency-path: app/go.mod
      - name: go test -race
        working-directory: app
        run: go test -race -count=1 ./...

  lint:
    runs-on: ubuntu-24.04
    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2
      - uses: actions/setup-go@3041bf56c941b39c61721a86cd11f3bb1338122a # v5.2.0
        with:
          go-version: '1.24'
          cache-dependency-path: app/go.mod
      - name: Install golangci-lint v2.5.0
        run: |
          curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/v2.5.0/install.sh \
            | sh -s -- -b "$(go env GOPATH)/bin" v2.5.0
      - name: golangci-lint run
        working-directory: app
        run: golangci-lint run

  ci-ok:
    if: always()
    needs: [vet, test, lint]
    runs-on: ubuntu-24.04
    steps:
      - name: Aggregate gate
        run: |
          test "${{ contains(needs.*.result, 'failure') || contains(needs.*.result, 'cancelled') }}" = "false"
```

Meets the requirements: triggers on push to `main` and PRs to `main`; three units (vet, test, lint); runner pinned to `ubuntu-24.04`; every action pinned by 40-char SHA with a version comment; `permissions: contents: read`; golangci-lint pinned to v2.5.0; `go` commands run in `app/`.

### Green run

https://github.com/Nik-ari-ai/DevOps-Intro/actions/runs/34508430646 — all 6 checks green:

```
✓  CI/ci-ok (pull_request)        2s
✓  CI/lint (pull_request)         30s
✓  CI/test (1.23) (pull_request)  39s
✓  CI/test (1.24) (pull_request)  22s
✓  CI/vet (1.23) (pull_request)   38s
✓  CI/vet (1.24) (pull_request)   30s
```

### 1.5 The gate blocks a failure

Broke `app/handlers_test.go` line 52 (`got["notes"] != 1` → `!= 2`) and pushed. CI went red:

```
X  CI/ci-ok (pull_request)        3s
X  CI/test (1.23) (pull_request)  37s
X  CI/test (1.24) (pull_request)  26s
✓  CI/lint (pull_request)         45s
✓  CI/vet (1.23) (pull_request)   31s
✓  CI/vet (1.24) (pull_request)   23s
```

PR merge state with the failure:

```
{ "mergeStateStatus": "BLOCKED", "mergeable": "MERGEABLE", "state": "OPEN" }
```

Reverted the break with a follow-up commit; CI went green again and the PR unblocked:

```
All checks were successful — 6 successful
{ "mergeStateStatus": "CLEAN", "mergeable": "MERGEABLE", "state": "OPEN" }
```

### 1.6 Branch protection

Required status check `ci-ok` on the fork's `main` (plus the signing + PR + linear rules from earlier labs):

```
{
  "status_checks": ["ci-ok"],
  "strict": true,
  "signatures": true,
  "linear": true,
  "pr_required": true,
  "enforce_admins": true
}
```

`strict: true` also enforces "branch must be up to date before merging".

### 1.2 Design answers

**a) Why pin `ubuntu-24.04` instead of `ubuntu-latest`?**
`ubuntu-latest` is a moving alias — GitHub repoints it to the next LTS on their schedule. A workflow that passed yesterday can break tomorrow with no change from you: a bumped default tool, a removed package, a different image. Pinning `ubuntu-24.04` makes the runner reproducible, so a red build means your code changed, not the environment.

**b) Why split vet + test + lint into separate units?**
Separate jobs run in parallel and report independently, so you see at a glance which one failed while the others still run. One combined job stops at the first failing command (later failures stay hidden) and serializes the work, so it is slower and gives less signal.

**c) What attack does SHA pinning prevent?**
Referencing an action by a mutable tag (`@v4`) runs whatever commit that tag currently points to. If the action's repo is compromised, an attacker moves the tag to malicious code and it runs with your `GITHUB_TOKEN`. Pinning the 40-char commit SHA freezes the exact code. This is the **tj-actions/changed-files supply-chain compromise (March 2025)**, where a pushed tag was repointed to code that dumped CI secrets.

**d) What is `permissions:` and the principle?**
`permissions:` sets the scopes of the automatic `GITHUB_TOKEN` for the workflow or job. Starting from `contents: read` (least privilege) means a compromised step or action cannot push code, open PRs, or publish packages with the token. The principle is least privilege: grant only what the job needs, add scopes explicitly when required.

**e) GitLab: stage vs job; `dependencies:` vs `stages:`?**
A job is one unit of work (a script in a container). A stage is an ordered group of jobs: jobs inside a stage run in parallel, and stages run one after another. `stages:` controls ordering — every job in stage N finishes before stage N+1 starts. `dependencies:` controls which prior jobs' artifacts a job downloads, independent of ordering; `needs:` goes further and lets a job start as soon as its named jobs finish, ignoring stage boundaries (a DAG).

## Task 2 — Make It Fast and Smart

### Optimizations applied (described, not YAML)

- **Dependency cache** via `setup-go` (`cache: true`, keyed on `app/go.mod`) — caches the deterministic module inputs.
- **Build matrix** `go: ['1.23', '1.24']` with `fail-fast: false` on vet + test — runs both toolchains in parallel and shows every cell's result.
- **Path filter** `on.pull_request.paths: ['app/**', '.github/workflows/ci.yml']` — docs-only PRs (e.g. a README edit) do not trigger CI.
- **`ci-ok` aggregation job** (`needs: [vet, test, lint]`, `if: always()`) — one required check, so the matrix names can change without touching branch protection.

### Path-filter skip demonstration

Opened PR #2 (`docs-skip-demo`) with a README-only change. CI did not trigger:

```
$ gh pr checks docs-skip-demo
no checks reported on the 'docs-skip-demo' branch
$ gh run list --branch docs-skip-demo
[]
```

### 2.4 Timing (measured on PR #1, total run wall-clock)

| Scenario | Wall-clock |
|----------|-----------|
| Baseline (no cache, single Go, no path filter) | 55 s |
| With cache (single Go) | 36 s |
| With cache + matrix (1.23 + 1.24) | 48 s |

The numbers move within run-to-run **runner variance**, not because of caching. QuickNotes has **zero third-party dependencies** (`app/go.mod` has no `require` block, no `go.sum`), so `setup-go`'s module cache has nothing to store or restore — baseline vs cached differ only by how the runner happened to provision that minute. The matrix adds the `1.23` and `1.24` cells but they run in parallel, so wall-clock stays bounded by the slowest single job (~40 s) plus `ci-ok`, not the sum. Most of the ~40–55 s is runner provisioning + checkout + Go toolchain download — none of which the module cache touches. A dependency-heavy project would see the saving on the `setup-go` / `go mod download` step instead.

### 2.5 Design answers

**f) Why cache `go.sum`-keyed inputs and not build outputs?**
The cache key should hash the dependency inputs (`go.sum`), which are deterministic: the same `go.sum` always maps to the same downloaded modules, so a cache hit is always correct. Build outputs vary with toolchain version, build flags, and environment, so caching or keying on them risks restoring stale or mismatched artifacts that silently corrupt a build. Cache the reproducible inputs; let the compiler regenerate outputs.

**g) What does `fail-fast: false` change, and when do you want `fail-fast: true`?**
With `fail-fast: false`, one failing matrix cell does not cancel the others, so you see every combination's result — useful for a PR gate where you need to know if a bug is 1.23-only or 1.24-only. `fail-fast: true` (the default) cancels siblings on the first failure; you want that on a large, expensive matrix where any single failure means "stop and fix" and you would rather save the minutes.

**h) Risk of an attacker writing a cache that a protected branch reads?**
Cache poisoning: an attacker's PR could run, build a tampered artifact, and write it to a cache entry; a later run that restores that entry by key would execute attacker-controlled content. GitHub mitigates this by scoping caches to refs — a run can restore caches from its own branch or its base branch, but caches created in a PR/feature branch are not visible to the parent (default/protected) branch. So a PR's poisoned cache cannot be read by `main`'s runs.
