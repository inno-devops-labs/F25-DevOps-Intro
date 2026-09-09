# Lab 1 submission

## First output

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
{
    "id": 5,
    "title": "hello",
    "body": "first POST",
    "created_at": "2026-09-09T14:06:49.376774855Z"
}

## SSH commit signature

commit df41462e1d3dc5765a2ab3a6016a25e4d5e608f9 (HEAD -> feature/lab1)
Good "git" signature for k.soloveva@innopolis.university with ED25519 key SHA256:U8gMwP7jZA2a0xvvr82zZnQrDYqHcYPaF+WVWnRGndM
Author: kriss <kristinsoll221@gmail.com>
Date:   Wed Sep 9 17:54:26 2026 +0300

    docs(lab1): start submission
    
    Signed-off-by: kriss <k.soloveva@innopolis.university>
    Signed-off-by: kriss <kristinsoll221@gmail.com>

## Screen
![Verified commit](images/image.png)

## Summary
Signed commits help ensure that commit was created by the intended developer and not by someone else. This is important for ensuring the seccurity of the software supply chain  as trusted repositories can become targets for attackers/hackers. The xz-utils case demonstrated how dangerous compromised or malicious changes can be in widely used open‑source software