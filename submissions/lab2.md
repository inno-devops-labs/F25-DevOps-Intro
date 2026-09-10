# Lab 2 submission

## Task 1

PS C:\Users\tihon\ui-cources\DevOps-Intro> git rev-parse HEAD
09b1dfdf26cf35c86f4cb3159f7003f95e12d714
PS C:\Users\tihon\ui-cources\DevOps-Intro> git cat-file -t HEAD         # commit
commit
PS C:\Users\tihon\ui-cources\DevOps-Intro> git cat-file -p HEAD          # see tree SHA, parent SHA, author
tree 4e8941f4762188e39dde75dbbc42c9b8b0a2f920
parent 9f41b7deb32343a831b5e47c61533fbc7c0ce67d
author tikhonmakeev <t.makeev@edu.centraluniversity.ru> 1789074525 +0300
committer tikhonmakeev <t.makeev@edu.centraluniversity.ru> 1789075749 +0300
gpgsig -----BEGIN SSH SIGNATURE-----
 U1NIU0lHAAAAAQAAADMAAAALc3NoLWVkMjU1MTkAAAAgSBWtVHPDm1j+7E07IPjzfDOJaF
 SC4VpwAqhrLN75bAkAAAADZ2l0AAAAAAAAAAZzaGE1MTIAAABTAAAAC3NzaC1lZDI1NTE5
 AAAAQMgfIbAAjdIO/soifY33FetEMCQNf9eEbbVIoZ7GrKKjLLhnKbw4md+dtLEhp31YwC
 8IFWnOAYJEiHXogvLy1Qw=
 -----END SSH SIGNATURE-----

docs: add PR template

Signed-off-by: tikhonmakeev <t.makeev@edu.centraluniversity.ru>
PS C:\Users\tihon\ui-cources\DevOps-Intro> # pick a tree SHA from the output:
PS C:\Users\tihon\ui-cources\DevOps-Intro> git cat-file -p 4e8941f4762188e39dde75dbbc42c9b8b0a2f920
040000 tree 1d07791eee3c3dd0955a02402b05b3a357816d8d    .github
100644 blob 1c0a1e94b7bbdd951f456cda51af6b8484cc3cee    .gitignore
100644 blob d10c04c6e7e0014f4fe883599c11747c15012d4e    README.md
040000 tree 7d0898a908e274ea809722844cdbd836f3b1c05a    app
040000 tree f4f047dd07b128eda5f899dfdaaf193f0291eaa2    labs
040000 tree c0ac2d55cf4335df659b347df3d19d0594a06b6c    lectures
PS C:\Users\tihon\ui-cources\DevOps-Intro> git cat-file -p 1c0a1e94b7bbdd951f456cda51af6b8484cc3cee
# ⚠️  KEEP THIS FILE MINIMAL.
#
# This .gitignore is inherited by every student fork. Anything listed here
# is something a student CANNOT `git add` without `-f`. So this file must
# ONLY contain:
#   (a) instructor-only paths (refs/), and
#   (b) machine-generated junk that NOBODY should ever commit.
#
# Do NOT add lab DELIVERABLES here (scan reports, SBOMs, go.sum, k8s
# manifests, CI workflows, Dockerfiles, playbooks, dashboards, …). Students
# are told to commit those in their submission PRs — ignoring them upstream
# silently breaks the lab. When in doubt, leave it OUT of this file.

# ── Instructor-only ─────────────────────────────────────────────
# Reference submissions (dry-run worked examples). Never pushed upstream;
# students never see these. This is the one path that is intentionally hidden.
refs/

# ── Machine-generated junk (no one commits these) ───────────────
# Compiled binaries / local runtime state
app/quicknotes
app/data/
/quicknotes
*.exe

# Vagrant runtime state (Lab 5) — the Vagrantfile IS committed; .vagrant/ is not
.vagrant/

# Nix build symlinks (Lab 11) — flake.nix + flake.lock ARE committed; result is not
result
result-*

# Terraform state — MUST never be committed (can contain secrets)
*.tfstate
*.tfstate.backup
.terraform/

# Python virtualenvs / caches
.venv/
__pycache__/
*.pyc

# Editor / IDE
.vscode/
.idea/
*.swp

# OS noise
.DS_Store
Thumbs.db

# Local agent config (not part of the course)
.claude/

# NOTE: deliberately NOT ignored, because students commit them as lab evidence:
#   submissions/labN.md        (lab reports)
#   .github/workflows/*.yml    (Lab 3 CI)
#   Dockerfile, compose.yaml   (Lab 6)
#   ansible/                   (Lab 7)
#   monitoring/                (Lab 8)
#   *.sbom.cdx.json, zap-*.html/json, trivy-*.txt   (Lab 9 scan evidence)
#   flake.nix, flake.lock      (Lab 11)
#   wasm/main.go, spin.toml, go.sum   (Lab 12)
PS C:\Users\tihon\ui-cources\DevOps-Intro> git cat-file -p d10c04c6e7e0014f4fe883599c11747c15012d4e
# DevOps Intro — Modern DevOps Practices Through One Project

[![Course](https://img.shields.io/badge/Course-DevOps%20Intro-blue)](#course-roadmap)
[![Project](https://img.shields.io/badge/Project-QuickNotes%20(Go)-success)](#the-project-quicknotes)
[![Duration](https://img.shields.io/badge/Duration-10%20Weeks-lightgrey)](#course-roadmap)
[![Grading](https://img.shields.io/badge/Grading-70--14--5--30--30-orange)](#grading)

A 10-week practical introduction to DevOps at Innopolis University. You will package, ship, observe, harden, and deploy **one** Go service — QuickNotes — across every lab. The discipline you learn here is the spine of modern production engineering.

> 💬 *"If it hurts, do it more often."* — Jez Humble

---

## Course Roadmap

10 weekly labs + 2 optional bonus labs:

| Week | Lab | Module | Key Topics & Technologies |
|------|-----|--------|---------------------------|
| 1 | Lab 1 | DevOps Foundations & Git | DevOps history, fork → branch → PR, signed commits (SSH 2.34+), PR templates |
| 2 | Lab 2 | Version Control Deep Dive | Object model, reflog recovery, reset modes, signed tags, rebase, bisect |
| 3 | Lab 3 | CI/CD | GitHub Actions (matrix, cache, OIDC); Bonus: GitLab CI mirror |
| 4 | Lab 4 | OS & Networking | OSI, DNS, HTTP, TLS, `ss`/`dig`/`tcpdump`/`journalctl` debugging |
| 5 | Lab 5 | Virtualization | Vagrant + VirtualBox, snapshots, cloud-init |
| 6 | Lab 6 | Containers | Multi-stage Dockerfile, distroless, Compose, hardening |
| 7 | Lab 7 | Configuration Management | Ansible playbook to deploy QuickNotes to Lab 5 VM; ansible-pull GitOps preview |
| 8 | Lab 8 | SRE & Monitoring | Golden signals, Prometheus, Grafana, one good alert, Checkly |
| 9 | Lab 9 | DevSecOps | Trivy, OWASP ZAP, SBOM, govulncheck reachability |
| 10 | Lab 10 | Cloud Computing | `ghcr.io` push from CI, Hugging Face Spaces deploy (card-free), Cloudflare Tunnel comparison |
| — | Lab 11 | Reproducible Builds *(bonus)* | Nix flake for QuickNotes; deterministic OCI image |
| — | Lab 12 | WebAssembly Containers *(bonus)* | TinyGo + Spin/WAGI; perf comparison vs Docker |

---

## The Project: QuickNotes

A small Go 1.24 notes API. You don't write the app — you **operationalize** it.

```mermaid
graph LR
    C["💻 curl / browser"] -->|HTTP :8080| S["🟢 quicknotes<br/>Go 1.24"]
    S --> F["📄 data/notes.json"]
    S -->|GET /metrics| P["📊 Prometheus<br/>Lab 8"]
```

| Endpoint | Method | Returns |
|----------|--------|---------|
| `/notes` | GET | All notes |
| `/notes/{id}` | GET | One note / 404 |
| `/notes` | POST | Created note (201) |
| `/notes/{id}` | DELETE | 204 / 404 |
| `/health` | GET | `{"status":"ok","notes":N}` |
| `/metrics` | GET | Prometheus text format |

**Stack:** Go 1.24 + standard library (`net/http`, `encoding/json`). No third-party deps in the core app. Static binary, tiny container, clean WASM target.

See [app/README.md](app/README.md) for run instructions.

---

## Lectures

12 lecture files in `lectures/` — 10 main + 2 bonus readings:

| # | Title | File |
|---|-------|------|
| 1 | Introduction to DevOps: From Conflict to Collaboration | [lec1.md](lectures/lec1.md) |
| 2 | Version Control Deep Dive: Git Internals & Recovery | [lec2.md](lectures/lec2.md) |
| 3 | CI/CD: From `it works on my machine` to `it works on every machine` | [lec3.md](lectures/lec3.md) |
| 4 | Operating Systems & Networking: The Substrate Underneath | [lec4.md](lectures/lec4.md) |
| 5 | Virtualization: One Box, Many Worlds | [lec5.md](lectures/lec5.md) |
| 6 | Containers: Same Kernel, Different Worlds | [lec6.md](lectures/lec6.md) |
| 7 | Configuration Management with Ansible | [lec7.md](lectures/lec7.md) |
| 8 | SRE & Monitoring: Reliability Is an Engineering Discipline | [lec8.md](lectures/lec8.md) |
| 9 | DevSecOps: Shift Security Left | [lec9.md](lectures/lec9.md) |
| 10 | Cloud Computing: Ship QuickNotes to the Real World | [lec10.md](lectures/lec10.md) |
| R11 | Reading — Reproducible Builds with Nix *(bonus)* | [reading11.md](lectures/reading11.md) |
| R12 | Reading — WebAssembly Containers *(bonus)* | [reading12.md](lectures/reading12.md) |

Each main lecture has a 15-question post-quiz in EN + RU (uploaded to the course quiz platform — see [Quiz leaderboards](#quiz-leaderboards-the-5)).

---

## Technology Stack

Versions pinned to **April 2026**:

| Category | Tool | Version | Introduced |
|----------|------|---------|-----------|
| Application runtime | Go + std lib | 1.24 | Week 1 (provided) |
| Git | git | 2.49+ | Week 1 |
| CI/CD | GitHub Actions, GitLab CI | — | Week 3 |
| Hypervisor | VirtualBox | 7.1.x | Week 5 |
| VM provisioning | Vagrant | 2.4.x | Week 5 |
| Containers | Docker + Compose | 28.x | Week 6 |
| Configuration Mgmt | Ansible | 10.x | Week 7 |
| Metrics | Prometheus | v3.x | Week 8 |
| Dashboards | Grafana | 13.x | Week 8 |
| Security scan | Trivy | 0.59.x | Week 9 |
| DAST | OWASP ZAP | 2.16.x | Week 9 |
| Cloud | Hugging Face Spaces + Cloudflare Tunnel (card-free) | — | Week 10 |
| *(bonus)* Reproducibility | Nix Flakes | 2.x | Lab 11 |
| *(bonus)* WASM | TinyGo + Spin | 0.34 / 3.x | Lab 12 |

---

## What Ships vs What Students Produce

The upstream course repo provides plumbing. Students produce skill in their forks.

| Path | Ships in repo | Students produce |
|------|:-------------:|:----------------:|
| `app/` (Go service + tests + Makefile + seed.json) | ✅ | |
| `lectures/` | ✅ | |
| `labs/labN.md` (lab specs) | ✅ | |
| `.github/pull_request_template.md` | | ✅ Lab 1 |
| `.github/workflows/ci.yml` | | ✅ Lab 3 |
| `Vagrantfile` | | ✅ Lab 5 |
| `app/Dockerfile`, `compose.yaml` | | ✅ Lab 6 |
| `ansible/` (playbook, inventory, templates) | | ✅ Lab 7 |
| `monitoring/` (Prometheus + Grafana provisioning) | | ✅ Lab 8 |
| `docs/runbook/` | | ✅ Lab 8 |
| Security headers middleware, `.trivyignore` | | ✅ Lab 9 |
| `cloud/` (deploy scripts, fly.toml) | | ✅ Lab 10 |
| `flake.nix`, `flake.lock` | | ✅ Lab 11 (bonus) |
| `wasm/` (main.go, spin.toml) | | ✅ Lab 12 (bonus) |
| `submissions/labN.md` | | ✅ every lab |

---

## Lab Structure

Every main lab (1-10) follows the same shape:

| Task | Points | Description | Required? |
|------|-------:|-------------|:---------:|
| **Task 1** | 6 | Core step that advances the project. Future labs depend on it. | Yes |
| **Task 2** | 4 (3 in Lab 1) | Deeper dive into the week's topic. Skippable — won't affect future labs. | No |
| **Task 3** | 1 pt | *Lab 1 only* — open-source community engagement (GH or GitLab) | Lab 1 only |
| **Bonus Task** | 2 | Extension for motivated students (flat 2 pts each, no difficulty weighting). | No |

Bonus labs 11 & 12: **Task 1 (4 pts) + Task 2 (4 pts) + Bonus Task (2 pts) = 10 pts each.**

### Submission Workflow

```mermaid
graph LR
    A[Fork course repo] --> B[Clone locally]
    B --> C[git switch -c feature/labN]
    C --> D[Complete tasks; sign commits]
    D --> E[Push to your fork]
    E --> F[Open PR → course main]
    F --> G[Submit PR URL via Moodle]
```

PRs target the **upstream course repo's `main`**, not your fork's main.

---

## Grading

| Component | Weight | What it rewards |
|-----------|-------:|-----------------|
| **Main labs 1-10** (Task 1 + Task 2 + Task 3-where-applicable) | **70%** | Diligent project work — the floor for any serious student |
| **Bonus tasks 1-10** (2 pts each, flat — no difficulty weighting) | **14%** | Going above and beyond on weekly topics |
| **Quiz leaderboards** (5 rolling per-2-labs windows, top-10 share 1% pool each) | **up to 5%** | Engagement + excellence; rewards late-joining students too |
| **Bonus labs 11 + 12** (4+4+2 pts each — 10 pts each, 20 raw total) | **20%** | Mastering reproducibility + WebAssembly |
| **Final exam** | **30%** | Optional path — written, comprehensive |
| **Sum (capped at 100%)** | **139%** | Multiple paths to A |

### What this produces in practice

| Profile | Main | L-bonus | Bonus labs | Exam | Quiz | Total |
|---------|-----:|--------:|-----------:|-----:|-----:|------:|
| All Task 1 only, nothing else | 42% | 0% | 0% | 0% | 0% | **42%** |
| All Task 1+2, no bonuses, no exam | 70% | 0% | 0% | 0% | 0% | **70%** |
| Add all weekly bonuses | 70% | 14% | 0% | 0% | 0% | **84%** |
| + good quiz | 70% | 14% | 0% | 0% | 5% | **89%** ← *just short of A* |
| + finish at least one bonus lab (10 pts → 10% of grade) | 70% | 14% | 10% | 0% | 5% | **99%** (A) |
| + both bonus labs (20 pts → 20% of grade) | 70% | 14% | 20% | 0% | 5% | **109%** (capped 100%, A) |
| Or take the exam instead of bonus labs | 70% | 14% | 0% | 30% | 5% | **119%** (capped 100%, A) |
| Do everything | 70% | 14% | 20% | 30% | 5% | **139%** (capped 100%, A with overflow signal) |
| Coast (Task 1 only + lucky quiz) | 42% | 0% | 0% | 0% | 5% | **47%** |

### Quiz leaderboards (the 5%)

Each lecture has a post-quiz on the course quiz platform. Quizzes feed 5 rolling leaderboards:

| Window | Labs covered |
|-------:|--------------|
| 1 | labs 1-2 |
| 2 | labs 3-4 |
| 3 | labs 5-6 |
| 4 | labs 7-8 |
| 5 | labs 9-10 |

Top-10 per window share 1% of the total grade.

### Performance tiers

| Grade | Range | Required to reach |
|-------|------:|-------------------|
| **A** | 90-100 | All main labs + at least one of: bonus labs / exam (multiple paths) |
| **B** | 75-89 | Main labs + most bonuses, no extension work |
| **C** | 60-74 | Main lab Task 1 across most labs |
| **D** | 0-59 | Below expectations |

### Late submissions

- Within 1 week of deadline: max 6/10 for that lab
- After 1 week: 0
- Bonus tasks and bonus labs: no late credit

---

## Required Software

| Week | Add |
|-----:|-----|
| 1 | Git 2.49+, Go 1.24, an SSH client, a GitHub *or* GitLab account |
| 3 | (nothing new — CI runs in the cloud) |
| 4 | `tcpdump`, `ss` (iproute2), `dig`, `mtr`, `jq`, optionally Wireshark |
| 5 | VirtualBox 7.1.x, Vagrant 2.4.x |
| 6 | Docker 28.x (Compose v2 built in) |
| 7 | Ansible 10.x (Python 3.11+) |
| 8 | (Prometheus + Grafana run in containers — nothing host-side needed) |
| 9 | (Trivy + ZAP run in containers) |
| 10 | A Hugging Face account (free, no card); `cloudflared` for the Bonus tunnel |
| 11 (bonus) | Nix (Determinate installer recommended) |
| 12 (bonus) | TinyGo 0.34+, Spin 3.x |

---

## Repository Structure

```text
DevOps-Intro/
├── app/                      # QuickNotes Go service (provided)
│   ├── main.go, store.go, handlers.go
│   ├── *_test.go             # tests
│   ├── go.mod, Makefile
│   ├── .golangci.yml, README.md
│   └── seed.json
├── lectures/
│   ├── lec1.md … lec10.md    # 10 main lectures
│   ├── reading11.md          # Nix bonus reading
│   └── reading12.md          # WASM bonus reading
├── labs/
│   ├── lab1.md … lab10.md    # 10 main lab specs
│   ├── lab11.md, lab12.md    # 2 bonus lab specs
└── README.md                 # you are here
```

Students add (in their forks):

```text
├── .github/                  # Lab 1, Lab 3
├── Vagrantfile               # Lab 5
├── ansible/                  # Lab 7
├── monitoring/               # Lab 8
├── cloud/                    # Lab 10
├── flake.nix                 # Lab 11
├── wasm/                     # Lab 12
└── submissions/
    ├── lab1.md … labN.md
```

---

## Key Books & Resources

* 📕 *The Phoenix Project* — Gene Kim, Kevin Behr, George Spafford (2013) — DevOps via novel
* 📕 *The DevOps Handbook* — Kim, Humble, Debois, Willis (2nd ed 2021) — the practitioner's manual
* 📕 *Accelerate* — Forsgren, Humble, Kim (2018) — the scientific evidence behind DORA
* 📗 *Pro Git* — Chacon & Straub — free at [git-scm.com/book](https://git-scm.com/book)
* 📗 *Continuous Delivery* — Humble & Farley (2010) — Jolt-award winner
* 📘 *Site Reliability Engineering* — Beyer, Jones, Petoff, Murphy — free at [sre.google](https://sre.google/sre-book/table-of-contents/)
* 📘 *Docker Deep Dive* — Nigel Poulton — practical containers
* 📘 *Ansible: Up & Running* — Lorin Hochstein & René Moser (3rd ed)
* 📘 [Brendan Gregg — Linux Performance](https://www.brendangregg.com/linuxperf.html) — the canonical map of Linux observability

---

## Course Completion

By Week 10, you will have:
- Forked, signed-committed, and PR-merged your way through 10 weeks
- Built CI, containers, VMs, monitoring, security scans, and a real cloud deploy of **the same** Go service
- Filed a blameless mini-postmortem after each lab
- Maybe pushed yourself further with Nix and/or WebAssembly

The tools change every five years. The discipline doesn't. Welcome to DevOps.

> 🎯 *Reference: this course's Spring 2026 structure mirrors the SRE-Intro standard (Innopolis University, completed Apr 2026). DevOps-Intro is the broader intro to **how software is shipped**; SRE-Intro is the deeper dive into **keeping it reliable**.*


### 1.2

[root@tikhon DevOps-Intro]# ls -la .git/                       # high-level
cat .git/HEAD                      # ref: refs/heads/...
ls .git/refs/heads/                # branches
ls .git/objects/ | head            # subdirs by first 2 SHA chars
find .git/objects -type f | wc -l  # how many loose objects?
total 28
drwxrwxrwx 1 root root  4096 Sep 11 01:46 .
drwxrwxrwx 1 root root  4096 Sep 11 02:00 ..
-rwxrwxrwx 1 root root    90 Sep 11 01:40 COMMIT_EDITMSG
-rwxrwxrwx 1 root root   620 Sep 11 01:44 config
-rwxrwxrwx 1 root root    73 Sep  9 22:54 description
-rwxrwxrwx 1 root root   213 Sep 11 01:58 FETCH_HEAD
-rwxrwxrwx 1 root root    21 Sep 11 01:44 HEAD
drwxrwxrwx 1 root root  4096 Sep  9 22:54 hooks
-rwxrwxrwx 1 root root  3183 Sep 11 01:44 index
drwxrwxrwx 1 root root  4096 Sep  9 22:54 info
drwxrwxrwx 1 root root  4096 Sep  9 22:54 logs
-rwxrwxrwx 1 root root 12288 Sep 11 00:12 .MERGE_MSG.swp
drwxrwxrwx 1 root root  4096 Sep 11 01:58 objects
-rwxrwxrwx 1 root root    41 Sep 11 01:40 ORIG_HEAD
-rwxrwxrwx 1 root root   112 Sep  9 22:54 packed-refs
drwxrwxrwx 1 root root  4096 Sep 11 00:00 refs
ref: refs/heads/main
feature  main
00
02
04
07
09
0a
0c
0e
0f
12
151

### What I see
HEAD is not a commit, it is one line of text reffering branch I am on right now. Switching branches basically rewrites this file


refs/heads/ holds my local branches. feature branches shows up as a directory because they are called feature/lab2 etc.  So the 'slash' in the branch name is a real dir. A branch is just a file containing one sha


objects/ is first 2 chars of the sha. That is why there are all those two letter folders

find says 151 files - some of them are loose objects. The other arrived from the clone can be packed in .pack file (to save space)

index is the staging area. Is a single binary file, not a directory. That surprised me. Maybe it is for optimization

### 1.3

PS C:\Users\tihon\ui-cources\DevOps-Intro> git reflog            # 🎉 your commits are still here
09b1dfd (HEAD -> feature/lab2, origin/main, origin/HEAD, main) HEAD@{0}: reset: moving to HEAD~2
0f161d6 HEAD@{1}: commit: wip(lab2): more progress
8edcde5 HEAD@{2}: commit: wip(lab2): start
09b1dfd (HEAD -> feature/lab2, origin/main, origin/HEAD, main) HEAD@{3}: checkout: moving from main to feature/lab2


PS C:\Users\tihon\ui-cources\DevOps-Intro> git reset --hard 0f161d6
HEAD is now at 0f161d6 wip(lab2): more progress

### what would happen if git gc had run between the bad reset and your recovery?

If git gc would run after the bad reset, Git could eventually delete the 'unreachable' commits once they became garbage for him. Then we will be in trouble - commits might are not recoverable through reflog. git reset --hard would not help

## Task 2

### 2.1
PS C:\Users\tihon\ui-cources\DevOps-Intro> git tag -v "v0.1.0-lab2-${env:USER}"   # verifies signature; "Good" expected                                           
object 9f41b7deb32343a831b5e47c61533fbc7c0ce67d
type commit
tag v0.1.0-lab2-tikhonmakeev
tagger tikhonmakeev <t.makeev@edu.centraluniversity.ru> 1789073659 +0300


### 2.2

Graph before rebase
PS C:\Users\tihon\ui-cources\DevOps-Intro> git log --oneline --graph -4
* f5dd754 wip(lab2): more progress
* 592d21d wip(lab2): start
* 9f41b7d docs(lab7): make seed.json shipping explicit; require bonus artifacts, not logs
* 8de962e docs(lab11): fix nixpkgs pin vs go.mod collision; add network fallback pitfalls



Graph after the rebase
PS C:\Users\tihon\ui-cources\DevOps-Intro>git log --oneline --graph -5
* ea5ee10 wip(lab2): more progress
* 3f96ceb wip(lab2): start
* 4f21ae9 docs: upstream moved while you worked
* 9f41b7d docs(lab7): make seed.json shipping explicit; require bonus artifacts, not logs
* 8de962e docs(lab11): fix nixpkgs pin vs go.mod collision; add network fallback pitfalls

### when I choose merge vs rebase

I would rebase when the branch is mine and nobody else pull it, for PR to be readable. Two or three clean commits sitting on current main are much easier to review than a branch full of "Merge branch main into feature" noise. Also git bisect works better on a straight line

Merge when the branch is shared, or someone else might be working on it, because rebasing rewrites shas and others clones breaks


## Bonus

PS C:\Users\tihon\ui-cources\DevOps-Intro>git bisect log
```git bisect start
# status: waiting for both good and bad commits
# bad: [f0c9243b7c80ebb930a1ce7048a1d65b4c2ac493] docs(app): mention go test invocation
git bisect bad f0c9243b7c80ebb930a1ce7048a1d65b4c2ac493
# status: waiting for good commit(s), bad commit known
# good: [0ec87b808ae6a257a98ecea4a3c8d38a7f2c5ac7] chore(app): document versioning scheme (bisect fixture baseline)
git bisect good 0ec87b808ae6a257a98ecea4a3c8d38a7f2c5ac7
# bad: [f285ede8611e55ac0a7d01100891c0cc775e0709] refactor(store): simplify nextID restoration in load()
git bisect bad f285ede8611e55ac0a7d01100891c0cc775e0709
# good: [cb89bb9ee2ee5010b166061447eaca3ae0da2378] docs(store): comment the load() decode step
git bisect good cb89bb9ee2ee5010b166061447eaca3ae0da2378
# first bad commit: [f285ede8611e55ac0a7d01100891c0cc775e0709] refactor(store): simplify nextID restoration in load()

PS C:\Users\tihon\ui-cources\DevOps-Intro>git bisect reset
```

### The offending commit
f285ede8611e55ac0a7d01100891c0cc775e0709
Message: refactor(store): simplify nextID restoration in load()

### Why log2(N)

Bisect is binary search. Every result we find throws away half of the remaining candidates: bad means the bug exists now or exists before that commit, so everything after dont care.
good means the bug came later -- what was before is out. It turns N tests into log2(N) tests
