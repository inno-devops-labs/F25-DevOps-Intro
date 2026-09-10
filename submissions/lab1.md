# Lab 1 submission

## Task 1 — SSH Commit Signing & First Signed Commit

### QuickNotes local run

`GET /health`

```json
{
    "notes": 4,
    "status": "ok"
}
```

`GET /notes`

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
```

`POST /notes` with `{"title":"hello","body":"first POST"}`

```json
{
    "id": 5,
    "title": "hello",
    "body": "first POST",
    "created_at": "2026-09-10T18:52:56.124547Z"
}
```

### Signed commit verification

```
commit 5265dd183b7d4f8db845c8cd4979232fa34cd1e0 (HEAD -> feature/lab1)
Good "git" signature for i.usmanova@innopolis.university with ED25519 key SHA256:nRzoNCSkOdnU0U/32ngInt766BQ5tAat1U3SzWZzrb0
Author: illmmmiira <i.usmanova@innopolis.university>
Date:   Thu Sep 10 21:59:32 2026 +0300

    docs(lab1): start submission

    Signed-off-by: illmmmiira <i.usmanova@innopolis.university>
```

### Why signed commits matter

In March 2024, someone using the name "Jia Tan" spent about two years building trust as a maintainer of xz-utils, a compression tool used in most Linux systems. They quietly added a hidden backdoor that could have let attackers skip SSH login checks on huge numbers of servers. It was only found by chance, when a developer noticed logins were running a little slower than normal — not because anyone reviewing the code caught it. Signed commits would not have stopped a trusted maintainer from adding bad code, but they do prove who actually made each commit, which makes it much harder for an attacker to fake being someone else or hide behind a false identity.

![Verified badge](verified-badge.png)
