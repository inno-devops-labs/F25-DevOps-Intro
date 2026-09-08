# Lab 1 — DevOps Foundations

Student: Arina ([@sonder314](https://github.com/sonder314))  
Repository: [sonder314/DevOps-Intro](https://github.com/sonder314/DevOps-Intro)  
Branch: `feature/lab1`  
Status: **Prepared locally; outstanding evidence is explicitly marked below.**

## Task 1 — QuickNotes and SSH commit signing

### Environment

Verified locally on 8 September 2026:

```text
git version 2.53.0
go version go1.26.7 linux/amd64
OpenSSH_10.2p1 Ubuntu-2ubuntu3.5
```

Go is installed in the repository-local `.goenv/toolchain`, with separate build and module caches. Activate it from the repository root using `source .goenv/activate`, then run `cd app && go run .`. The local environment is excluded from version control.

### QuickNotes endpoint evidence

<!-- BEGIN HTTP EVIDENCE -->
Captured at 2026-09-08T13:27:05+0300.

Fresh isolated data: four seed notes; POST returned HTTP 201; five notes afterwards.

### `GET /health` (HTTP 200)

```bash
curl -s http://localhost:8080/health | python3 -m json.tool
```

```json
{
    "notes": 4,
    "status": "ok"
}
```

### `GET /notes` (HTTP 200)

```bash
curl -s http://localhost:8080/notes | python3 -m json.tool
```

```json
[
    {
        "id": 1,
        "title": "Welcome to QuickNotes",
        "body": "This is the project you'll containerize, deploy, monitor, and harden across all 10 labs.",
        "created_at": "2026-01-15T10:00:00Z"
    },
    {
        "id": 2,
        "title": "Read app/main.go first",
        "body": "Start by understanding the entry point \u2014 env vars, signal handling, graceful shutdown.",
        "created_at": "2026-01-15T10:05:00Z"
    },
    {
        "id": 3,
        "title": "DevOps mantra",
        "body": "If it hurts, do it more often.",
        "created_at": "2026-01-15T10:10:00Z"
    },
    {
        "id": 4,
        "title": "Endpoint cheat-sheet",
        "body": "GET /notes  GET /notes/{id}  POST /notes  DELETE /notes/{id}  GET /health  GET /metrics",
        "created_at": "2026-01-15T10:15:00Z"
    }
]
```

### `POST /notes` (HTTP 201)

```bash
curl -s -X POST -H 'Content-Type: application/json' -d '{"title":"hello","body":"first POST"}' http://localhost:8080/notes | python3 -m json.tool
```

```json
{
    "id": 5,
    "title": "hello",
    "body": "first POST",
    "created_at": "2026-09-08T10:27:05.276015472Z"
}
```

### `GET /notes` (HTTP 200)

```bash
curl -s http://localhost:8080/notes | python3 -m json.tool
```

```json
[
    {
        "id": 3,
        "title": "DevOps mantra",
        "body": "If it hurts, do it more often.",
        "created_at": "2026-01-15T10:10:00Z"
    },
    {
        "id": 4,
        "title": "Endpoint cheat-sheet",
        "body": "GET /notes  GET /notes/{id}  POST /notes  DELETE /notes/{id}  GET /health  GET /metrics",
        "created_at": "2026-01-15T10:15:00Z"
    },
    {
        "id": 5,
        "title": "hello",
        "body": "first POST",
        "created_at": "2026-09-08T10:27:05.276015472Z"
    },
    {
        "id": 1,
        "title": "Welcome to QuickNotes",
        "body": "This is the project you'll containerize, deploy, monitor, and harden across all 10 labs.",
        "created_at": "2026-01-15T10:00:00Z"
    },
    {
        "id": 2,
        "title": "Read app/main.go first",
        "body": "Start by understanding the entry point \u2014 env vars, signal handling, graceful shutdown.",
        "created_at": "2026-01-15T10:05:00Z"
    }
]
```

### `GET /health` (HTTP 200)

```bash
curl -s http://localhost:8080/health | python3 -m json.tool
```

```json
{
    "notes": 5,
    "status": "ok"
}
```
<!-- END HTTP EVIDENCE -->

### Tests

The repository's existing tests passed with `cd app && go test ./...`:

```text
ok  	quicknotes	0.011s
```

These tests exercise the handlers and store; the live HTTP checks above separately confirm the running application.

Raw runtime evidence: [curl responses](evidence/lab1/http.md) and [server log](evidence/lab1/server.txt).

### SSH signing

Signing is enabled for this repository using `gpg.format=ssh`, `commit.gpgsign=true`, `tag.gpgsign=true`, and the existing `~/.ssh/id_ed25519.pub` key. Local verification uses `.git/allowed_signers`; private key material is not included in this submission.

The signed template commit was verified with `git log --show-signature -1`:

```text
commit 0ce5837ababb9cfcd4c032404353c9755dd4a468
Good "git" signature for usersamsung873@gmail.com with ED25519 key SHA256:HJ3GjAUvvTz8stL0wfExxm3SO3v6T0R9NtxtMBwlJi0
Author: Arina <usersamsung873@gmail.com>
Date:   Tue Sep 8 13:24:03 2026 +0300

    docs: add PR template
    
    Signed-off-by: Arina <usersamsung873@gmail.com>

```

Raw evidence: [signature.txt](evidence/lab1/signature.txt).

**Pending GitHub verification:** ensure the public key is registered as both an Authentication Key and a Signing Key in the `sonder314` account; confirm SSH authentication, push the branches, and verify the commits on GitHub. Local signature verification alone does not prove a GitHub Verified badge.

**Pending screenshot:** save a real screenshot of the commit's Verified badge as `submissions/evidence/lab1/verified.png`, then embed it here.

### Why signing matters

Commit signatures bind a commit to a signing key and make changes to its signed contents detectable, supporting attribution and audit trails. The [March 2024 xz-utils backdoor disclosure](https://openwall.com/lists/oss-security/2024/03/29/4) shows why supply-chain trust needs more than a familiar maintainer identity: an authorized contributor or compromised key can still deliver malicious code. Signing therefore complements code review, reproducible builds and testing; it does not certify that code is safe.

## Task 2 — PR template and first pull request

The required template is committed on local `main` at `0ce5837` and inherited by `feature/lab1`: [pull_request_template.md](../.github/pull_request_template.md). It contains Goal, Changes, Testing and Checklist sections.

- [x] Template committed on local `main` with a valid SSH signature.
- [ ] Template pushed to the fork's `main` before PR creation.
- [ ] Template auto-population captured in a real screenshot.
- [ ] PR opened from `sonder314:feature/lab1` to `inno-devops-labs:main`.
- [ ] PR checklist completed and every contributed commit shows Verified.

**Pending PR URL:** add the actual upstream PR link after publication.

**Template scope:** GitHub loads templates from the base repository's default branch. A template on the fork's `main` can be demonstrated in the fork's PR creation form; it does not by itself install a template in the course repository. If the upstream form is empty, use the same sections manually and document that distinction rather than claiming automatic population. See [GitHub's template documentation](https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/creating-a-pull-request-template-for-your-repository).

## Task 3 — GitHub Community

Starring repositories bookmarks useful tools and helps maintainers' projects gain visibility. Following developers makes it easier to discover their work, keep up with classmates' projects and identify opportunities to collaborate and learn.

The actions below require verification in the `sonder314` account:

- [ ] Star [inno-devops-labs/DevOps-Intro](https://github.com/inno-devops-labs/DevOps-Intro).
- [ ] Star [simple-container-com/api](https://github.com/simple-container-com/api).
- [ ] Follow [Cre-eD](https://github.com/Cre-eD).
- [ ] Follow [Naghme98](https://github.com/Naghme98).
- [ ] Follow [pierrepicaud](https://github.com/pierrepicaud).
- [ ] Follow at least three classmates; record their actual profile links here.

## Bonus — Branch protection and required signing

**Status: configuration and remote rejection evidence pending.**

Required policy on the fork's `main`: require signed commits, require a pull request before merging, and require linear history. Enforce the policy for administrators as well so that an owner cannot bypass the rejection test.

**Pending screenshot:** capture the actual enabled rules as `submissions/evidence/lab1/branch-protection.png` and embed it here.

**Pending rejection evidence:** record the exact output of a real unsigned push to protected `main`, including the `remote: error:` lines. A local signing failure, DNS failure or authentication error does not demonstrate branch protection.

### Knight Capital reflection

The [SEC's Knight Capital order](https://www.sec.gov/files/litigation/admin/2013/34-70694.pdf) describes an inconsistent deployment in which one of eight servers did not receive the new code. Requiring reviewed pull requests and signed commits on a production deployment branch could have improved traceability and created a review checkpoint before deployment. Linear history would have made the sequence of approved changes easier to audit, but neither signatures nor branch protection would have ensured that every server received the same artifact. Automated deployment verification, staged rollouts, monitoring and a tested rollback mechanism would still have been necessary to reduce the risk of a similar incident.

## Submission readiness

- [x] Existing application tests pass.
- [x] Local SSH signing is configured and verified.
- [x] Template exists on local `main`.
- [x] Live curl evidence captured (4 seed notes → 5 after POST).
- [ ] GitHub Verified screenshot included.
- [ ] Published template and auto-population evidence included.
- [ ] Stars and all six required follows confirmed.
- [ ] Bonus rules screenshot and genuine rejection output included.
- [ ] Actual upstream PR URL recorded and PR checklist completed.
- [ ] PR URL submitted through Moodle before the deadline.
