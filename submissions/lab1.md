# Lab 1 — DevOps Foundations: Fork, Sign, and Open Your First PR

- Student: Arina Nikolaeva (Nik-ari-ai)
- Fork: https://github.com/Nik-ari-ai/DevOps-Intro
- Branch: feature/lab1

## Task 1 — SSH Commit Signing & First Signed Commit

### curl /health, /notes, POST /notes

```
{
    "notes": 4,
    "status": "ok"
}
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
        "body": "Start by understanding the entry point — env vars, signal handling, graceful shutdown.",
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
{
    "id": 5,
    "title": "hello",
    "body": "first POST",
    "created_at": "2026-09-10T11:34:42.197004Z"
}
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
        "body": "Start by understanding the entry point — env vars, signal handling, graceful shutdown.",
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
    },
    {
        "id": 5,
        "title": "hello",
        "body": "first POST",
        "created_at": "2026-09-10T11:34:42.197004Z"
    }
]
```

4 seed notes, 5 after POST.

### git log --show-signature -1

```
commit 1be41bb97a98708145322e6dbb7003a515762657 (HEAD -> feature/lab1)
Good "git" signature for a.nikolaeva@innopolis.university with ED25519 key SHA256:8GSxlvdecN00j5Mus9SElUSDbK6BYcUOIagqME2SBsA
Author: Arina Nikolaeva <a.nikolaeva@innopolis.university>
Date:   Thu Sep 10 14:37:01 2026 +0300

    docs(lab1): start submission

    Signed-off-by: Arina Nikolaeva <a.nikolaeva@innopolis.university>
```

### Verified (GitHub API)

```
{
  "reason": "valid",
  "sha": "1be41bb97a98708145322e6dbb7003a515762657",
  "verified": true
}
```

### Why signing matters

Git does not check the name and email in a commit, so authorship is easy to forge. A signed commit is tied to a verified key, so a reviewer can confirm who made it. The xz-utils backdoor (March 2024, CVE-2024-3094) is the example: a maintainer under a fake identity slipped a backdoor into a library used by most Linux distributions, and trusted commit metadata alone would not have caught it.

## Task 2 — Pull Request Template & First PR

`.github/pull_request_template.md` on `main` (signed commit `ebfaeb1`):

```markdown
## Goal
<!-- What does this PR accomplish? 1 sentence. -->

## Changes
- 

## Testing
<!-- How did you verify it? -->

## Checklist
- [ ] Title is a clear sentence (<= 70 chars)
- [ ] Commits are signed (`git log --show-signature`)
- [ ] `submissions/labN.md` updated
```

PR: `Nik-ari-ai:feature/lab1` -> `inno-devops-labs:main`, description filled from the template, checklist ticked. URL submitted via Moodle.

## Task 3 — GitHub Community Engagement

```
OK: starred DevOps-Intro
OK: starred simple-container-com/api
OK: following Cre-eD
OK: following Naghme98
OK: following pierrepicaud
OK: following uSs3ewa
OK: following Telman3000
OK: following fishkadealer229
--- verify ---
star DevOps-Intro: yes
star simple-container-com/api: yes
following Cre-eD: yes
following Naghme98: yes
following pierrepicaud: yes
following uSs3ewa: yes
following Telman3000: yes
following fishkadealer229: yes
```

### GitHub Community

Starring bookmarks a project, and its star count shows how much the community trusts it, which helps when picking tools. Following developers keeps their new work visible, so on a team project you see what classmates are building instead of duplicating it.

## Bonus — Branch Protection & Required Signed Commits

### Rules on main

```
{
  "enforce_admins": true,
  "linear": true,
  "pr_required": true,
  "signatures": true
}
```

Require signed commits, require a pull request before merging, require linear history, applied to admins too.

### Unsigned push rejected

```
remote: error: GH006: Protected branch update failed for refs/heads/main.
remote: 
remote: - Commits must have verified signatures.
remote:   Found 1 violation:
remote: 
remote:   6743b17bcc8c4024d439327b4aa5a09dda076895
remote: 
remote: - Changes must be made through a pull request.
To https://github.com/Nik-ari-ai/DevOps-Intro.git
 ! [remote rejected] main -> main (protected branch hook declined)
error: не удалось отправить некоторые ссылки в «https://github.com/Nik-ari-ai/DevOps-Intro.git»
```

### Reflection — Knight Capital

Knight Capital lost about $440M in 45 minutes in 2012 when a deploy reached only 7 of 8 servers and a reused flag turned on old code on the eighth. With required signing and required pull requests on the prod branch, that change would have gone through a reviewed PR instead of a direct push, so one operator could not push a half-applied release live. Required signatures would also tie the change to a known identity. It does not fix the deploy script itself, but it removes the direct-to-prod path that made the incident possible.
