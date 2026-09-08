# Lab 2 Submission

## Task 1 — Git Object Model + Reflog Recovery

### 1.1 Git Object Model

```bash
git rev-parse HEAD
```

```text
c79bea7a25ef4053ceb357256701730f5868bec7
```

```bash
git cat-file -t HEAD
```

```text
commit
```

```bash
git cat-file -p HEAD
```

```text
tree 4e8941f4762188e39dde75dbbc42c9b8b0a2f920
parent 9f41b7deb32343a831b5e47c61533fbc7c0ce67d
author amiranabiullina <amiranabiullina@gmail.com> 1788785951 +0300
committer amiranabiullina <amiranabiullina@gmail.com> 1788785951 +0300
gpgsig -----BEGIN SSH SIGNATURE-----
 U1NIU0lHAAAAAQAAADMAAAALc3NoLWVkMjU1MTkAAAAg/n+8HEamIqnuiEDt0x7xsgXEyN
 2Yp2UUlQzicAXJp+MAAAADZ2l0AAAAAAAAAAZzaGE1MTIAAABTAAAAC3NzaC1lZDI1NTE5
 AAAAQMb+IzS+mGGe9Dq4FgZFO8qsfK1+kDUp2nih0LkDG5dt6E5tprpvL1Hh4t6bA4ufsI
 Kn46S5wHc/hhsHJTDoFQA=
 -----END SSH SIGNATURE-----

docs: add PR template

Signed-off-by: amiranabiullina <amiranabiullina@gmail.com>
```

```bash
git cat-file -p 4e8941f4762188e39dde75dbbc42c9b8b0a2f920
```

```text
040000 tree 1d07791eee3c3dd0955a02402b05b3a357816d8d    .github
100644 blob 1c0a1e94b7bbdd951f456cda51af6b8484cc3cee    .gitignore
100644 blob d10c04c6e7e0014f4fe883599c11747c15012d4e    README.md
040000 tree 7d0898a908e274ea809722844cdbd836f3b1c05a    app
040000 tree f4f047dd07b128eda5f899dfdaaf193f0291eaa2    labs
040000 tree c0ac2d55cf4335df659b347df3d19d0594a06b6c    lectures
```

```bash
git cat-file -p 1c0a1e94b7bbdd951f456cda51af6b8484cc3cee
```

```text
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
```

### 1.2 Inside `.git`

```bash
ls -la .git/
```

```text
total 64
drwxr-xr-x  15 amiranabiullina  staff   480 Sep  7 22:58 .
drwxr-xr-x   9 amiranabiullina  staff   288 Sep  7 22:53 ..
-rw-r--r--   1 amiranabiullina  staff    96 Sep  7 17:12 COMMIT_EDITMSG
-rw-r--r--   1 amiranabiullina  staff   799 Sep  7 15:12 FETCH_HEAD
-rw-r--r--   1 amiranabiullina  staff    21 Sep  7 22:53 HEAD
-rw-r--r--   1 amiranabiullina  staff    41 Sep  7 22:57 ORIG_HEAD
-rw-r--r--   1 amiranabiullina  staff   609 Sep  7 15:56 config
-rw-r--r--   1 amiranabiullina  staff    73 Sep  7 15:11 description
drwxr-xr-x  16 amiranabiullina  staff   512 Sep  7 15:11 hooks
-rw-r--r--   1 amiranabiullina  staff  3183 Sep  7 22:57 index
drwxr-xr-x   3 amiranabiullina  staff    96 Sep  7 15:11 info
drwxr-xr-x   4 amiranabiullina  staff   128 Sep  7 15:11 logs
drwxr-xr-x  53 amiranabiullina  staff  1696 Sep  7 17:12 objects
-rw-r--r--   1 amiranabiullina  staff   112 Sep  7 15:11 packed-refs
drwxr-xr-x   5 amiranabiullina  staff   160 Sep  7 16:00 refs
```

```bash
cat .git/HEAD
```

```text
ref: refs/heads/main
```

```bash
ls .git/refs/heads/
```

```text
feature main
```

```bash
ls .git/objects/ | head
```

```text
02
07
0a
0c
0e
0f
13
1a
1d
27
```

```bash
find .git/objects -type f | wc -l
```

```text
      60
```

The `.git` directory stores Git metadata, references, logs, and objects. `HEAD` pointed to `main`, local branches were stored under `refs/heads`, and the repository contained 60 loose objects.

### 1.3 Reflog Recovery

I created two commits on `feature/lab2`.

```bash
git commit -S -s -m "wip(lab2): start"
```

```text
[feature/lab2 81752a8] wip(lab2): start
 1 file changed, 1 insertion(+)
 create mode 100644 submissions/lab2.md
```

```bash
git commit -S -s -am "wip(lab2): more progress"
```

```text
[feature/lab2 d8a94af] wip(lab2): more progress
 1 file changed, 1 insertion(+)
```

Before the reset:

```bash
git log --oneline -3
```

```text
d8a94af (HEAD -> feature/lab2) wip(lab2): more progress
81752a8 wip(lab2): start
c79bea7 (origin/main, origin/HEAD, main) docs: add PR template
```

Then I simulated losing the commits:

```bash
git reset --hard HEAD~2
```

```text
HEAD is now at c79bea7 docs: add PR template
```

```bash
git status
```

```text
On branch feature/lab2
nothing to commit, working tree clean
```

The commits disappeared from the normal branch history, but they were still visible in the reflog.

```bash
git reflog
```

```text
c79bea7 (HEAD -> feature/lab2, origin/main, origin/HEAD, main) HEAD@{0}: reset: moving to HEAD~2
d8a94af HEAD@{1}: commit: wip(lab2): more progress
81752a8 HEAD@{2}: commit: wip(lab2): start
c79bea7 (HEAD -> feature/lab2, origin/main, origin/HEAD, main) HEAD@{3}: checkout: moving from main to feature/lab2
c79bea7 (HEAD -> feature/lab2, origin/main, origin/HEAD, main) HEAD@{4}: reset: moving to c79bea7
b873c23 HEAD@{5}: checkout: moving from feature/lab1 to main
615e276 (origin/feature/lab1, feature/lab1) HEAD@{6}: commit: docs(lab1): add community and bonus
6d13345 HEAD@{7}: checkout: moving from main to feature/lab1
b873c23 HEAD@{8}: commit: test: unsigned commit (should fail)
6d9e3c5 HEAD@{9}: commit: test: unsigned commit (should fail)
c79bea7 (HEAD -> feature/lab2, origin/main, origin/HEAD, main) HEAD@{10}: checkout: moving from feature/lab1 to main
6d13345 HEAD@{11}: commit: docs(lab1): add community section
ee34937 HEAD@{12}: commit: docs(lab1): finish submission
02c5ba5 HEAD@{13}: checkout: moving from main to feature/lab1
c79bea7 (HEAD -> feature/lab2, origin/main, origin/HEAD, main) HEAD@{14}: commit: docs: add PR template
9f41b7d (upstream/main, upstream/HEAD) HEAD@{15}: checkout: moving from feature/lab1 to main
02c5ba5 HEAD@{16}: reset: moving to HEAD
02c5ba5 HEAD@{17}: commit: docs(lab1): start submission
9f41b7d (upstream/main, upstream/HEAD) HEAD@{18}: checkout: moving from main to feature/lab1
9f41b7d (upstream/main, upstream/HEAD) HEAD@{19}: clone: from github.com:amiranabiullina/DevOps-Intro.git
```

I recovered the most recent lost commit using its SHA from the reflog:

```bash
git reset --hard d8a94af
```

```text
HEAD is now at d8a94af wip(lab2): more progress
```

```bash
git status
```

```text
On branch feature/lab2
nothing to commit, working tree clean
```

The hard reset only made the commits unreachable from the branch; the reflog still referenced their SHAs, so they could be recovered. A normal `git gc` during the reflog retention period would usually keep these objects, but aggressive pruning or expired reflog entries could remove them. If the unreachable commit objects were actually pruned, recovery by their SHA would no longer be possible.

## Bonus — Git Bisect

### Bisect Log

```text
git bisect start
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
```

The offending commit was:

```text
f285ede8611e55ac0a7d01100891c0cc775e0709
refactor(store): simplify nextID restoration in load()
```

The automated bisect confirmed the same result:

```text
f285ede8611e55ac0a7d01100891c0cc775e0709 is the first bad commit
bisect found first bad commit
```

Git bisect uses binary search, testing a commit near the middle of the remaining range each time. Each result removes roughly half of the possible commits, so the search takes approximately `log₂(N)` steps instead of checking all `N` commits one by one.