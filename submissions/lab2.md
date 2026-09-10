important work
more important work

### 1
(.venv) kriss@kabanchik:~/VSProjects/DevOps-Intro$ git rev-parse HEAD
c9e87e05b2f60878c9f9337b18b4a6e43033fd0b
(.venv) kriss@kabanchik:~/VSProjects/DevOps-Intro$ git cat-file -t HEAD
commit
(.venv) kriss@kabanchik:~/VSProjects/DevOps-Intro$ git cat-file -p HEAD
tree 9fccddb495795349aaa7192db36cf2d84b744d84
parent 9f41b7deb32343a831b5e47c61533fbc7c0ce67d
author kriss <kristinsoll221@gmail.com> 1788967281 +0300
committer kriss <kristinsoll221@gmail.com> 1788967281 +0300
gpgsig -----BEGIN SSH SIGNATURE-----
 U1NIU0lHAAAAAQAAADMAAAALc3NoLWVkMjU1MTkAAAAgtmoyZgfjhJJrq0b4z68DvlyxEQ
 m2WAY1rRt9SnZXzoYAAAADZ2l0AAAAAAAAAAZzaGE1MTIAAABTAAAAC3NzaC1lZDI1NTE5
 AAAAQCA6xKxYVjKmEiKVgZ4yUuRuHzATEJNJMmMEdXe6eLJnMaYP2GHASpY0uTg1iDSJPt
 IrR80MyOqofK+gCPwosgU=
 -----END SSH SIGNATURE-----

docs: add PR template

Signed-off-by: kriss <kristinsoll221@gmail.com>
(.venv) kriss@kabanchik:~/VSProjects/DevOps-Intro$ git cat-file -p 9fccddb495795349aaa7192db36cf2d84b744d84
040000 tree 108a8195110106082dc57f62eb6b52178a955d39    .github
100644 blob 1c0a1e94b7bbdd951f456cda51af6b8484cc3cee    .gitignore
100644 blob d10c04c6e7e0014f4fe883599c11747c15012d4e    README.md
040000 tree 7d0898a908e274ea809722844cdbd836f3b1c05a    app
040000 tree f4f047dd07b128eda5f899dfdaaf193f0291eaa2    labs
040000 tree c0ac2d55cf4335df659b347df3d19d0594a06b6c    lectures
(.venv) kriss@kabanchik:~/VSProjects/DevOps-Intro$ git cat-file -p d10c04c6e7e0014f4fe883599c11747c15012d4e
# DevOps Intro — Modern DevOps Practices Through One Project

![Course](#course-roadmap)
![Project-success)](#the-project-quicknotes)
![Duration](#course-roadmap)
![Grading](#grading)

A 10-week practical introduction to DevOps at Innopolis University. You will package, ship, observe, harden, and deploy one Go service — QuickNotes — across every lab. The discipline you learn here is the spine of modern production engineering.

> 💬 *"If it hurts, do it more often."* — Jez Humble

---

## Course Roadmap

10 weekly labs + 2 optional bonus labs:

| Week | Lab | Module | Key Topics & Technologies |
|------|-----|--------|---------------------------|
| 1 | Lab 1 | DevOps Foundations & Git | DevOps history, fork → branch → PR, signed commits (SSH 2.34+), PR templates |
| 2 | Lab 2 | Version Control Deep Dive | Object model, reflog recovery, reset modes, signed tags, rebase, bisect |
| 3 | Lab 3 | CI/CD | GitHub Actions (matrix, cache, OIDC); Bonus: GitLab CI mirror |
| 4 | Lab 4 | OS & Networking | OSI, DNS, HTTP, TLS, ss`/`dig`/`tcpdump`/`journalctl debugging |
| 5 | Lab 5 | Virtualization | Vagrant + VirtualBox, snapshots, cloud-init |
| 6 | Lab 6 | Containers | Multi-stage Dockerfile, distroless, Compose, hardening |
| 7 | Lab 7 | Configuration Management | Ansible playbook to deploy QuickNotes to Lab 5 VM; ansible-pull GitOps preview |
| 8 | Lab 8 | SRE & Monitoring | Golden signals, Prometheus, Grafana, one good alert, Checkly |
| 9 | Lab 9 | DevSecOps | Trivy, OWASP ZAP, SBOM, govulncheck reachability |
| 10 | Lab 10 | Cloud Computing | ghcr.io push from CI, Hugging Face Spaces deploy (card-free), Cloudflare Tunnel comparison |
| — | Lab 11 | Reproducible Builds *(bonus)* | Nix flake for QuickNotes; deterministic OCI image |
| — | Lab 12 | WebAssembly Containers *(bonus)* | TinyGo + Spin/WAGI; perf comparison vs Docker |

---

## The Project: QuickNotes

A small Go 1.24 notes API. You don't write the app — you operationalize it.

graph LR
    C["💻 curl / browser"] -->|HTTP :8080| S["🟢 quicknotes<br/>Go 1.24"]
    S --> F["📄 data/notes.json"]
    S -->|GET /metrics| P["📊 Prometheus<br/>Lab 8"]

| Endpoint | Method | Returns |
|----------|--------|---------|
| /notes | GET | All notes |
| /notes/{id} | GET | One note / 404 |
| /notes | POST | Created note (201) |
| /notes/{id} | DELETE | 204 / 404 |
| /health | GET |

{"status":"ok","notes":N} |
| /metrics | GET | Prometheus text format |

Stack: Go 1.24 + standard library (`net/http`, `encoding/json`). No third-party deps in the core app. Static binary, tiny container, clean WASM target.

See app/README.md for run instructions.

---

## Lectures

12 lecture files in lectures/ — 10 main + 2 bonus readings:

| # | Title | File |
|---|-------|------|
| 1 | Introduction to DevOps: From Conflict to Collaboration | lec1.md |
| 2 | Version Control Deep Dive: Git Internals & Recovery | lec2.md |
| 3 | CI/CD: From it works on my machine to it works on every machine | lec3.md |
| 4 | Operating Systems & Networking: The Substrate Underneath | lec4.md |
| 5 | Virtualization: One Box, Many Worlds | lec5.md |
| 6 | Containers: Same Kernel, Different Worlds | lec6.md |
| 7 | Configuration Management with Ansible | lec7.md |
| 8 | SRE & Monitoring: Reliability Is an Engineering Discipline | lec8.md |
| 9 | DevSecOps: Shift Security Left | lec9.md |
| 10 | Cloud Computing: Ship QuickNotes to the Real World | lec10.md |
| R11 | Reading — Reproducible Builds with Nix *(bonus)* | reading11.md |
| R12 | Reading — WebAssembly Containers *(bonus)* | reading12.md |

Each main lecture has a 15-question post-quiz in EN + RU (uploaded to the course quiz platform — see Quiz leaderboards).

---

## Technology Stack

Versions pinned to April 2026:

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
| app/ (Go service + tests + Makefile + seed.json) | ✅ | |
| lectures/ | ✅ | |
| labs/labN.md (lab specs) | ✅ | |
| .github/pull_request_template.md | | ✅ Lab 1 |
| .github/workflows/ci.yml | | ✅ Lab 3 |
| Vagrantfile | | ✅ Lab 5 |
| app/Dockerfile, compose.yaml | | ✅ Lab 6 |
| ansible/ (playbook, inventory, templates) | | ✅ Lab 7 |
| monitoring/ (Prometheus + Grafana provisioning) | | ✅ Lab 8 |
| docs/runbook/ | | ✅ Lab 8 |
| Security headers middleware, .trivyignore | | ✅ Lab 9 |
| cloud/ (deploy scripts, fly.toml) | | ✅ Lab 10 |
| flake.nix, flake.lock | | ✅ Lab 11 (bonus) |
| wasm/ (main.go, spin.toml) | | ✅ Lab 12 (bonus) |
| submissions/labN.md | | ✅ every lab |

---

## Lab Structure

a lot of info about README file

(.venv) kriss@kabanchik:~/VSProjects/DevOps-Intro$ ls -la .git/
total 64
drwxrwxr-x  8 kriss kriss 4096 Sep 10 11:22 .
drwxrwxr-x  7 kriss kriss 4096 Sep 10 11:22 ..
drwxrwxr-x  2 kriss kriss 4096 Sep  9 16:50 branches
-rw-rw-r--  1 kriss kriss   81 Sep  9 22:54 COMMIT_EDITMSG
-rw-rw-r--  1 kriss kriss  524 Sep  9 17:49 config
-rw-rw-r--  1 kriss kriss   73 Sep  9 16:50 description
-rw-rw-r--  1 kriss kriss  792 Sep  9 16:51 FETCH_HEAD
-rw-rw-r--  1 kriss kriss   21 Sep 10 11:22 HEAD
drwxrwxr-x  2 kriss kriss 4096 Sep  9 16:50 hooks
-rw-rw-r--  1 kriss kriss 3183 Sep 10 11:22 index
drwxrwxr-x  2 kriss kriss 4096 Sep  9 16:50 info
drwxrwxr-x  3 kriss kriss 4096 Sep  9 16:51 logs
drwxrwxr-x 49 kriss kriss 4096 Sep  9 22:54 objects
-rw-rw-r--  1 kriss kriss   41 Sep  9 21:57 ORIG_HEAD
-rw-rw-r--  1 kriss kriss  112 Sep  9 16:51 packed-refs
drwxrwxr-x  5 kriss kriss 4096 Sep  9 16:51 refs
(.venv) kriss@kabanchik:~/VSProjects/DevOps-Intro$ cat .git/HEAD
ref: refs/heads/main
(.venv) kriss@kabanchik:~/VSProjects/DevOps-Intro$ ls .git/refs/heads/
feature  main
(.venv) kriss@kabanchik:~/VSProjects/DevOps-Intro$ ls .git/objects/ | head
08
0a
0c
0e
0f
10
13
1a
1f
27
(.venv) kriss@kabanchik:~/VSProjects/DevOps-Intro$ find .git/objects -type f | wc -l
55
(.venv) kriss@kabanchik:~/VSProjects/DevOps-Intro$

### 1.2 Git internal structure

The .git directory stores Git's internal repository data, including configuration, references, logs, the index, and Git objects.

The HEAD file contains ref: refs/heads/main, which means that the currently checked-out branch is main.

The .git/refs/heads/ directory contains main and feature. The feature directory exists because branches such as feature/lab1 are stored using a nested path.

The .git/objects/ directory contains subdirectories such as 08, 0a, and 0c. Git organizes objects using the first two characters of their SHA hash as the directory name.

The command for counting files inside .git/objects returned 55, showing how many object-related files are currently stored there.

After creating two commits on feature/lab2, I intentionally ran git reset --hard HEAD~2, which moved HEAD back to commit c9e87e0 and made the two Lab 2 commits disappear from the normal git log. I then used git reflog, where I could still see 18e26f0 (wip(lab2): more progress) and 416dc63 (wip(lab2): start), showing the previous movements of HEAD. To recover the work, I ran git reset --hard 18e26f0, after which both commits became visible again in the branch history. If git gc had run immediately after the bad reset, the commits would normally still be recoverable because recent reflog entries protect them for some time. However, if those reflog entries had expired or aggressive garbage collection had pruned the unreachable objects, the lost commits could have been permanently removed, so recovering the SHA from git reflog as soon as possible is important

### 2.3 Tag Verification and Rebase

I created an annotated and signed release tag and verified it using `git tag -v "v0.1.0-lab2-${USER}"`. The verification output was: `object c9e87e05b2f60878c9f9337b18b4a6e43033fd0b`, `type commit`, `tag v0.1.0-lab2-kriss`, `tagger kriss <kristinsoll221@gmail.com> 1789034040 +0300`, followed by the message `Lab 2 milestone — version control deep dive` and `Good "git" signature for k.soloveva@innopolis.university with ED25519 key SHA256:U8gMwP7jZA2a0xvvr82zZnQrDYqHcYPaF+WVWnRGndM`. Before the rebase, the branch history from `git log --oneline --graph --decorate -8` was: `* 18e26f0 (HEAD -> feature/lab2) wip(lab2): more progress`, `* 416dc63 wip(lab2): start`, `* c9e87e0 (tag: v0.1.0-lab2-kriss) docs: add PR template`, `* 9f41b7d (upstream/main) docs(lab7): make seed.json shipping explicit; require bonus artifacts, not logs`, `* 8de962e docs(lab11): fix nixpkgs pin vs go.mod collision; add network fallback pitfalls`, `* bfa345b docs(lab3): matrix renames required checks — warn + ci-ok gate pattern; set honest cache expectations`, `* 356419b docs(lab1,lab2): clarify GitHub auth vs signing SSH key roles; add publickey-denied pitfalls`, and `* 66bbd4d docs(lab1): align Task 3 GitHub Community engagement with other courses`. I then ran `git fetch origin` and `git rebase origin/main`, and Git reported `Successfully rebased and updated refs/heads/feature/lab2.` After the rebase, the branch history became: `* 79ad37e (HEAD -> feature/lab2) wip(lab2): more progress`, `* bb43389 wip(lab2): start`, `* 21a6041 (origin/main, origin/HEAD, main) docs: upstream moved while you worked`, `* c9e87e0 (tag: v0.1.0-lab2-kriss) docs: add PR template`, `* 9f41b7d (upstream/main) docs(lab7): make seed.json shipping explicit; require bonus artifacts, not logs`, `* 8de962e docs(lab11): fix nixpkgs pin vs go.mod collision; add network fallback pitfalls`, `* bfa345b docs(lab3): matrix renames required checks — warn + ci-ok gate pattern; set honest cache expectations`, and `* 356419b docs(lab1,lab2): clarify GitHub auth vs signing SSH key roles; add publickey-denied pitfalls`. The rebase replayed the two Lab 2 commits on top of the updated `main`, so their SHAs changed from `416dc63` and `18e26f0` to `bb43389` and `79ad37e`. I would choose rebase when working on my own feature branch because it keeps the history clean and linear by replaying my commits on top of the latest `main`. I would choose merge when working with shared branches because it preserves the original history and does not rewrite existing commits. In general, rebase is useful for cleaning up feature work, while merge is safer when the branch history has already been shared with other developers.