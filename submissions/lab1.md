# Lab 1 submission

## QuickNotes

### GET /health

```json
{
    "notes": 5,
    "status": "ok"
}
```

### GET /notes

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
    },
    {
        "id": 5,
        "title": "hello",
        "body": "first POST",
        "created_at": "2026-09-11T00:29:29.378018Z"
    }
]
```

### POST /notes

```json
{
    "id": 6,
    "title": "hello",
    "body": "first POST",
    "created_at": "2026-09-11T01:04:31.124812Z"
}
```

## Signed commit verification

```text
Good "git" signature for v.kolpakova@innopolis.university with ED25519 key
Author: Valeriia Kolpakova <v.kolpakova@innopolis.university>

docs(lab1): start submission

Signed-off-by: Valeriia Kolpakova <v.kolpakova@innopolis.university>
```

## Why signed commits matter

Signed commits help verify that a commit was really created by the claimed developer and was not impersonated or modified by someone else. The xz-utils supply-chain attack discovered in March 2024 showed how dangerous compromised trust in software maintainers can be, so cryptographic commit signing provides an additional way to verify the origin of changes.

## GitHub Verified badge

![Verified commit](images/verified.png)

## GitHub Community

Starring useful repositories helps me find important projects again and shows support for open-source projects. Following classmates and course staff helps me stay connected with their work and discover useful updates and contributions.
