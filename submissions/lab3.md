# Lab 3 submission

Chosen path: **GitHub Actions**  
Repository: `Mimir-sma/DevOps-Intro`  
Branch: `feature/lab3`

GitHub Actions was selected because the fork is hosted on GitHub and the
repository can use the workflow and branch-protection features without a mirror.

## Task 1 — PR gate

The workflow is stored in `.github/workflows/ci.yml`. It has three independent
units and one aggregation gate:

| Job | Work |
|---|---|
| `vet (1.23)` / `vet (1.24)` | `go vet ./...` in `app/` |
| `test (1.23)` / `test (1.24)` | `go test -race -count=1 ./...` in `app/` |
| `lint` | `golangci-lint run` in `app/`, version `v2.5.0` |
| `ci-ok` | Fails unless every matrix cell and lint succeed |

The runner is pinned to `ubuntu-24.04`, workflow permissions are limited to
`contents: read`, and all actions use immutable 40-character SHAs:

```text
actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683           # v4.2.2
actions/setup-go@d35c59abb061a4a6fb18e82ac0862c26744d6ab5           # v5.5.0
golangci/golangci-lint-action@4afd733a84b1f43292c63897423277bb7f4313a9 # v8.0.0
```

### Go 1.23 compatibility cell

`app/go.mod` declares `go 1.24`. A Go 1.23 command with its default
`GOTOOLCHAIN=auto` could download Go 1.24, making a nominal 1.23 matrix cell
misleading. The workflow sets `GOTOOLCHAIN=local` and changes the `go` directive
to 1.23 only in the runner's disposable checkout before the 1.23 vet/test jobs.
The repository file is not modified, and those cells therefore exercise the
actual Go 1.23 toolchain.

### Green, red, and fixed runs

Optimized green run:
[cache + matrix run 30304385930](https://github.com/Mimir-sma/DevOps-Intro/actions/runs/30304385930).

The deliberate failure changed the expected health-note count from 1 to 2:

- Broken commit:
  [`3d2f244`](https://github.com/Mimir-sma/DevOps-Intro/commit/3d2f244c0c572fda96a5fb0ce5a650a93ad7cb96)
- Failed run:
  [30304622526](https://github.com/Mimir-sma/DevOps-Intro/actions/runs/30304622526)
- Failed checks: `test (1.23)`, `test (1.24)`, and the `ci-ok` aggregation gate
- Failed step in both test jobs: `Test with the race detector`
- Fix commit:
  [`52d839a`](https://github.com/Mimir-sma/DevOps-Intro/commit/52d839a410be85215e06083a44849582c9898461)
- Green run after the fix:
  [30304826225](https://github.com/Mimir-sma/DevOps-Intro/actions/runs/30304826225)

Local verification after the fix:

```text
$ go vet ./...

$ go test -count=1 ./...
ok      quicknotes      0.603s

$ golangci-lint run --timeout=5m
0 issues.

$ actionlint .github/workflows/ci.yml
# no output; exit 0
```

Branch protection to configure on `main`:

- [ ] Require status checks before merging
- [ ] Require branches to be up to date
- [ ] Require only the stable `ci-ok` aggregation check
- [ ] Add a branch-protection screenshot here

### Design questions

#### a) Why pin `ubuntu-24.04`?

`ubuntu-latest` is a moving label. When GitHub changes the image behind it, the
preinstalled compiler, system libraries, shell behavior, or package versions can
change without a repository commit and break a previously green pipeline.
Pinning an LTS image makes environment upgrades explicit and reviewable.

#### b) Why split vet, test, and lint?

Independent jobs run in parallel, report the exact failed concern, and can have
different setup or retry policies. A combined job is simpler but usually stops
at the first error, hides later failures, and makes the whole sequence take the
sum of all step durations.

#### c) What does SHA pinning prevent?

Tags and branches are mutable references. In the March 2025
`tj-actions/changed-files` compromise, an attacker moved existing tags to
malicious code, exposing secrets from affected workflows. A full commit SHA is
immutable, so compromise of a maintainer account cannot silently change the
already reviewed action revision.

#### d) What is `permissions:`?

It sets the GitHub token capabilities available to the workflow. This pipeline
needs only repository contents for checkout, so it grants `contents: read` and
nothing else, following least privilege: give automation only the access needed
for its current task.

#### e) Stage vs job on GitLab

This submission uses GitHub, but the concepts map as follows: GitLab stages are
ordered phases and normally run sequentially, while jobs within one stage can
run in parallel. `stages:` defines that order; `dependencies:` controls which
earlier jobs' artifacts a later job downloads and does not itself define the
pipeline phase order.

## Task 2 — fast and selective CI

### Measurements

The table uses `run_started_at` to `updated_at` from the public GitHub API. Each
scenario was a real push to `feature/lab3`; all three runs succeeded.

| Scenario | Run | Wall-clock |
|---|---|---:|
| Baseline: no cache, Go 1.24 only, no path filter | [30304055295](https://github.com/Mimir-sma/DevOps-Intro/actions/runs/30304055295) | 46 s |
| Cache enabled, Go 1.24 only | [30304251307](https://github.com/Mimir-sma/DevOps-Intro/actions/runs/30304251307) | 42 s |
| Cache + Go 1.23/1.24 matrix + path filter | [30304385930](https://github.com/Mimir-sma/DevOps-Intro/actions/runs/30304385930) | 46 s |

The four-second cache difference is within normal hosted-runner variance.
QuickNotes has no third-party module requirements and no `go.sum`, so there are
almost no module downloads to save; runner allocation, checkout, tool setup, and
the race-enabled test dominate. The final workflow keys `setup-go` caching from
`app/go.mod`, the only dependency manifest available in this zero-dependency
module.

### Applied optimizations

- `actions/setup-go` caches the module and Go build caches separately per
  toolchain using `app/go.mod` as the dependency input.
- `fail-fast: false` runs every Go-version cell even when another cell fails.
- Push/PR path filters run CI only when `app/**` or the workflow itself changes.
- `ci-ok` provides one stable required-check name even if the matrix changes.

Docs-only skip evidence: the submission-only commit
`DOCS_ONLY_COMMIT_SHA` did not produce a workflow run because it changed neither
`app/**` nor `.github/workflows/ci.yml`.

#### f) Why key caches from dependency inputs?

Dependency manifests and checksums describe reproducible inputs. A cache keyed
from them is invalidated when dependencies change, while released build
artifacts may depend on the OS, compiler, flags, or hidden state and should be
rebuilt and published as artifacts instead of trusted as a cache. The Go build
cache remains only a disposable accelerator, scoped by the runner/toolchain and
safe to regenerate on any miss.

#### g) What does `fail-fast: false` change?

It prevents the matrix controller from cancelling other cells after the first
failure, so the developer sees compatibility results for every supported Go
version in one run. `fail-fast: true` is useful when later cells are expensive
and the first failure already makes the result unusable, for example a large
deployment matrix where conserving runner minutes matters more than complete
diagnostics.

#### h) What is the cache-poisoning risk?

If untrusted PR code can write a cache later restored by a privileged workflow,
it can plant modified executables or generated files and gain code execution in
the trusted context. GitHub scopes `pull_request` caches to the PR merge ref, so
they are not restored by the base branch, and gives low-trust events read-only
access to default-branch caches. Caches still contain untrusted bytes, so they
must never hold secrets and a job must remain correct when it rebuilds from a
miss.

## Bonus — performance investigation

### Profile of the cache + matrix run

| Unit | Runner setup | Dependency/tool setup | Actual work | Cleanup | Job total |
|---|---:|---:|---:|---:|---:|
| `vet (1.23)` | 1 s | 10 s | 11 s | 2 s | 24 s |
| `vet (1.24)` | 1 s | 4 s | 6 s | 1 s | 15 s |
| `test (1.23)` | 1 s | 10 s | 16 s | 1 s | 31 s |
| `test (1.24)` | 1 s | 2 s | 18 s | 1 s | 25 s |
| `lint` | 1 s | 4 s | 5 s | 0 s | 11 s |

GitHub reports step durations in whole seconds, so grouped rows can differ
slightly from the job total. The overall wall-clock was 46 seconds because the
five work jobs ran concurrently and `ci-ok` added a final three-second gate.

### Additional optimizations

| Optimization | Evidence | Effect |
|---|---|---|
| Prebuilt pinned lint action instead of `go install` | `lint` work completed in 5 s | Avoids compiling the linter and its dependency graph on every run |
| `GOFLAGS=-buildvcs=false` | Workflow-level environment | Skips VCS stamping work in shallow CI checkouts |
| Cancel superseded runs with `concurrency` | Branch/PR-scoped group | Prevents obsolete pushes from consuming runners |
| Parallel independent jobs | Five work jobs overlap | 106 s of job time completed in 46 s wall-clock |

The measured baseline-to-final wall-clock stayed at 46 seconds while coverage
expanded from three Go-1.24 jobs to five Go-version jobs. The warm linter path
improved from a 27-second baseline job to 11 seconds in the final run. These are
end-to-end observations rather than isolated benchmarks; hosted-runner noise is
too large to claim that every small difference is caused by one option.

The longest remaining work is the race-enabled test step at 16–18 seconds; the
Go 1.23 tool setup also costs 9 seconds on a cold runner. Shortening the code
path would require making tests less dependent on filesystem setup or splitting
a much larger suite into balanced packages, but this tiny application does not
justify weakening race coverage. Hosted runner allocation and tool download are
outside QuickNotes itself, so a self-hosted warm runner would be the next
infrastructure change. I would stop optimizing below 60–90 seconds because the
pipeline is already fast enough for a PR feedback loop and further gains would
be smaller than normal runner variance.
