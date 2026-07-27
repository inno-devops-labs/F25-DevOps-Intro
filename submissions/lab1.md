# Lab 1 submission

Platform: GitHub  
Repository: `Mimir-sma/DevOps-Intro`  
Branch: `feature/lab1`

## Task 1 — SSH commit signing and QuickNotes

### Environment

```text
$ git --version
git version 2.55.0.windows.3

$ go version
go version go1.24.13 windows/amd64
```

The Go 1.24.13 portable archive was downloaded from the official Go distribution
site and its SHA-256 checksum was verified before use.

### Local verification

The service was built and started on `127.0.0.1:18083` with an isolated
temporary data file. Before the HTTP checks, `go vet ./...` and
`go test -count=1 ./...` both completed successfully.

```text
$ curl -s http://127.0.0.1:18083/health
{"notes":4,"status":"ok"}

$ curl -s http://127.0.0.1:18083/notes
[{"id":3,"title":"DevOps mantra","body":"If it hurts, do it more often.","created_at":"2026-01-15T10:10:00Z"},{"id":4,"title":"Endpoint cheat-sheet","body":"GET /notes  GET /notes/{id}  POST /notes  DELETE /notes/{id}  GET /health  GET /metrics","created_at":"2026-01-15T10:15:00Z"},{"id":1,"title":"Welcome to QuickNotes","body":"This is the project you'll containerize, deploy, monitor, and harden across all 10 labs.","created_at":"2026-01-15T10:00:00Z"},{"id":2,"title":"Read app/main.go first","body":"Start by understanding the entry point — env vars, signal handling, graceful shutdown.","created_at":"2026-01-15T10:05:00Z"}]

$ curl -s -X POST http://127.0.0.1:18083/notes \
    -H "Content-Type: application/json" \
    --data-binary @request.json
{"id":5,"title":"hello","body":"first POST","created_at":"2026-07-27T20:24:56.6297396Z"}

$ curl -s http://127.0.0.1:18083/health
{"notes":5,"status":"ok"}
```

The order of notes in the GET response is not an API guarantee; the important
result is that all four seed notes were returned and the POST created note 5.

### Signature verification

Git is configured locally with `gpg.format=ssh`, automatic commit and tag
signing, and the ED25519 public key whose fingerprint is
`SHA256:d+1+7nScChodUrIJ/EkVIMngcdBd1QGaLK1ZM+cghl4`.

```text
$ git log --show-signature -1 --format=fuller
commit 260de0de962c1e05e35e975647d8f98909769842
Good "git" signature for arsengobozov15region@gmail.com with ED25519 key SHA256:d+1+7nScChodUrIJ/EkVIMngcdBd1QGaLK1ZM+cghl4
Author:     Mimir-sma <arsengobozov15region@gmail.com>
Commit:     Mimir-sma <arsengobozov15region@gmail.com>

    docs: add PR template

    Signed-off-by: Mimir-sma <arsengobozov15region@gmail.com>
```

Verified-badge evidence: **add a screenshot after the branch is pushed and
GitHub recognizes the signing key**.

Signed commits provide cryptographic provenance: an author name and email alone
can be forged, while a valid signature proves control of the registered key.
This matters in the context of the March 2024 xz-utils attack, where a long
social-engineering campaign compromised trust in a critical dependency; verified
provenance is one useful layer in a broader supply-chain review process.

## Task 2 — Pull request template

The repository contains `.github/pull_request_template.md` with Goal, Changes,
Testing, and Checklist sections. The template was committed on `main` before
this feature branch was created so GitHub can load it from the default branch.

PR URL: **add after the PR is opened against the course repository's `main`**.

PR verification checklist:

- [ ] Description auto-populates from the template
- [ ] All PR checklist items are completed
- [ ] Every commit displays the Verified badge

## Task 3 — GitHub community

External actions to confirm in the GitHub UI:

- [ ] Star the course repository
- [ ] Star `simple-container-com/api`
- [ ] Follow `Cre-eD`, `Naghme98`, and `pierrepicaud`
- [ ] Follow at least three classmates

Stars are a lightweight way to bookmark useful repositories and improve their
visibility to other open-source users. Following developers makes their public
work easier to discover, which supports collaboration with classmates and helps
build a professional learning network.

## Bonus — branch protection

Required GitHub settings for `main`:

- [ ] Require signed commits
- [ ] Require a pull request before merging
- [ ] Require linear history

Branch-protection screenshot: **add after the rule is enabled**.  
Unsigned-push rejection: **capture after the rule is enabled; do not fabricate
this output**.

Knight Capital's August 2012 failure involved an inconsistent manual deployment:
one of eight servers retained old code and generated erroneous orders. Requiring
signed commits and reviewed pull requests would have improved accountability
and prevented unreviewed history from reaching the protected branch, while
linear history would have made the deployed state easier to audit. These Git
controls alone would not have fixed the missed server, so an automated,
all-or-nothing deployment, health checks, and a kill switch would still have
been essential.
