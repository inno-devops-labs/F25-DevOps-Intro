# Lab 1 Submission

## Task 1 — SSH Commit Signing & QuickNotes

### curl output

**GET /health**

{
"notes": 4,
"status": "ok"
}


**GET /notes**

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
"body": "GET /notes GET /notes/{id} POST /notes DELETE /notes/{id} GET /health GET /metrics",
"created_at": "2026-01-15T10:15:00Z"
}
]


**POST /notes**

{
"id": 5,
"title": "hello",
"body": "first POST",
"created_at": "2026-09-10T18:04:40.35716Z"
}


### Signature verification

commit c186e9aed7c6de88da616ae3b147536e1123a517 (HEAD -> feature/lab1)
Good "git" signature for qumcom720@gmail.com with ED25519 key SHA256:pZWx6J6g/ZNH5KiztrcpMDzZz2EZescxvMwt9Vzwxjs
Author: Ilia Kulichenko qumcom720@gmail.com
Date: Thu Sep 10 21:16:54 2026 +0300

docs(lab1): start submission

Signed-off-by: Ilia Kulichenko <qumcom720@gmail.com>

### Verified badge

![Verified badge](PASTE_SCREENSHOT_HERE)

### Why signed commits matter

Signed commits let reviewers confirm a commit genuinely came from the person who claims to have authored it, rather than from someone who merely set a matching name and email in their local Git config — which anyone can fake. This matters because malicious actors can impersonate trusted contributors to sneak in harmful changes, as seen in the March 2024 xz-utils incident, where a contributor spent years building trust before inserting a backdoor into a widely-used compression library. Commit signing does not prevent malicious code by itself, but it raises the bar by tying every change to a cryptographically verifiable identity.

## Task 2 — Pull Request Template

Added `.github/pull_request_template.md` on `main`, committed and pushed (commit `5690a67`).

![PR template auto-populated](PASTE_SCREENSHOT_HERE)

## Task 3 — GitHub Community

Starred `inno-devops-labs/DevOps-Intro` and `simple-container-com/api`. Followed the professor (@Cre-eD), both TAs (@Naghme98, @pierrepicaud), and 3 classmates.

Starring a repository signals interest and makes it easy to find again later, and it also gives maintainers a visible signal of how many people find their project useful - a small but real form of community feedback. Following other developers helps in team projects because it keeps their activity visible in your feed, making it easier to stay aware of what teammates are working on, spot useful repos they create, and build the kind of ongoing professional network that matters when job-hunting or collaborating across projects later.
