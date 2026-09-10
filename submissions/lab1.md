# Lab 1 submission

## Task 1 — SSH Commit Signing & QuickNotes

### Health Check

The QuickNotes application was started locally and the health endpoint was tested successfully.

```json
{
  "notes": 4,
  "status": "ok"
}
```

### Initial Notes

Before creating a new note, the `/notes` endpoint returned 4 existing notes:

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

### POST Request

A new note was created using the `POST /notes` endpoint:

```json
{
  "id": 5,
  "title": "hello",
  "body": "first POST",
  "created_at": "2026-09-10T11:39:08.2643786Z"
}
```

After the POST request, the `/notes` endpoint returned 5 notes, which confirms that the new note was added successfully.

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
    "created_at": "2026-09-10T11:39:08.2643786Z"
  }
]
```

### Signed Commit Verification

SSH commit signing was configured successfully. The latest commit was verified locally using `git log --show-signature -1`.

```text
commit 13bcb6d64c9d7c707274143245db198f2ca44b67 (HEAD -> feature/lab1)
Good "git" signature for e.tuturina@innopolis.university with RSA key SHA256:58a0VfUddYu80cRXN0pwferyuQEnlBBm5v/CWZ31xSU
Author: ttrlen <e.tuturina@innopolis.university>
Date:   Thu Sep 10 14:54:28 2026 +0300

    docs(lab1): start submission

    Signed-off-by: ttrlen <e.tuturina@innopolis.university>
```

### Verified Commit

The commit also appears as **Verified** on GitHub:

![Verified commit](images/verified.jpg)

### Why Signed Commits Matter

Signed commits help verify that a commit was actually created by the expected developer and was not impersonated by another person. The xz-utils March 2024 incident referenced in Lecture 1 shows why trust and verification are important in the software supply chain. Commit signing adds another layer of protection by making the authorship of changes verifiable.

## Task 2 — Pull Request Template & First PR

A pull request template was added to `.github/pull_request_template.md` on the `main` branch.

The template contains the Goal, Changes, Testing, and Checklist sections and will be used when opening the Lab 1 pull request.

## Task 3 — GitHub Community

Starring repositories makes useful open-source projects easier to find again and also helps increase their visibility in the developer community. Following developers helps me discover their work, stay aware of projects my classmates and colleagues contribute to, and makes future collaboration easier.

## Bonus Task — Branch Protection & Required Signed Commits

### Branch Protection Rules

The `main` branch is protected with required pull requests, signed commits, and linear history.

![Branch protection rules](images/branch-protection.jpg)

### Unsigned Push Rejection

The branch protection rule successfully rejected an unsigned commit pushed directly to `main`.

```text
remote: error: GH006: Protected branch update failed for refs/heads/main.

remote: - Commits must have verified signatures.
remote:   Found 1 violation:

remote:   06559b79be63a22afe0dd1bd7507b357be2b6f20

remote: - Changes must be made through a pull request.

! [remote rejected] main -> main (protected branch hook declined)
error: failed to push some refs to 'github.com:ttrlen/DevOps-Intro.git'
```

### Reflection

With branch protection enabled, direct changes to the production branch could have been prevented. Requiring pull requests would have introduced an additional review step before deployment, while required signed commits would make the author of each change verifiable. Linear history would also make it easier to track exactly which changes reached production. These controls could have reduced the risk of an unreviewed or unintended change being deployed.