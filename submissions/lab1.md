# Lab 1 Submission

## QuickNotes

### Health check

Command:

curl -s http://localhost:8080/health | python3 -m json.tool

Output:

{
    "notes": 4,
    "status": "ok"
}

### Get notes

Command:

curl -s http://localhost:8080/notes | python3 -m json.tool

The endpoint returned 4 seed notes.

### Create a note

Command:

curl -s -X POST http://localhost:8080/notes \
  -H 'Content-Type: application/json' \
  -d '{"title":"hello","body":"first POST"}' | python3 -m json.tool

Output:

{
    "id": 5,
    "title": "hello",
    "body": "first POST",
    "created_at": "2026-09-08T19:05:45.516446Z"
}

The POST request successfully created a fifth note.

## SSH Commit Signing

Git was configured to use SSH keys for commit signing.

The latest commit was verified with:

git log --show-signature -1

The verification output included:

Good "git" signature for a.nizamieva@innopolis.university

## Why signed commits matter

Signed commits help verify that a commit was created by the expected developer and make it harder to impersonate another contributor. The XZ Utils incident showed the security risks of malicious changes entering a trusted open-source software supply chain, so verifying the origin of commits is an important security practice.

## GitHub Community

- GitHub username: allniluv
- Course repository: DevOps-Intro

I starred the course repository and the `simple-container-com/api` repository, and followed the professor, TAs, and at least three classmates. Stars help recognize and support useful open-source projects, while following teammates helps with collaboration, team projects, and professional growth.
