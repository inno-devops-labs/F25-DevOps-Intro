# Lab 2 submission

## Task 1 — Git Object Model + Reflog Recovery

### 1.1 Git Object Model

The Git object chain was explored from `HEAD` to a commit object, then to its tree object, and finally to a blob containing the actual contents of `.gitignore`.

#### HEAD and commit object

```text
$ git rev-parse HEAD
b7875cd1cba2bdc9ab4e9d03838ee4b1a1eba57e

$ git cat-file -t HEAD
commit

$ git cat-file -p HEAD
tree a4db3e2191b0e8e43a8d737a45ebd860033fcddc
parent 9f41b7deb32343a831b5e47c61533fbc7c0ce67d
author ttrlen <e.tuturina@innopolis.university> 1789046141 +0300
committer ttrlen <e.tuturina@innopolis.university> 1789046141 +0300
gpgsig -----BEGIN SSH SIGNATURE-----
 U1NIU0lHAAAAAQAAAZcAAAAHc3NoLXJzYQAAAAMBAAEAAAGBAJnk+7l4GQ4D6heLhNIt6p
 W4vXm5G4uJeXMXZaYnw7w/rgYgFbVE2c8yyoHyPwVLP63vIxs22mCqHFAC08JmTnDqpQzh
 r/8K2wBu8Wi8UjJVnquYnWvYDgIOYzF/HeBXswj+J6ruaAEBf0GP1461JlypVtj6guUxgh
 VcT99PS4/tAPaRj7cOcpTWOZ2sjvQrWreKUJHCyce3ULLfA4RndsUqNn2yofyTWCmXX/Q3
 jIwJZYeNchqwt1cK0i9XO4ZnxSl2PYeqsXPiWUqgBYIhn5Qqo7SqSoxeW1XJ4mdNUyFpTu
 uZSmTSojYOhk9/8b/PRuFmwDMeB9TIinW6ykJWKs1HicDDnksIYdNQuWkB+sqj57wvRs4+
 erWR5ddIb5epLGMgIFL2OspNyDWcQUbr7vPkn7eCh7ouyHz2NgvHu3He16B/UuO5IyQS3D
 9uOV/Ha9W6CzAVgI8k8ZSkryzOKmo8Su4vuAWwWCPWQ3JCdjvPrMp1sB6GUtM8dCfRtfH9
 7QAAAANnaXQAAAAAAAAABnNoYTUxMgAAAZQAAAAMcnNhLXNoYTItNTEyAAABgD2kOdXA+X
 AiNBr/IV6NVKYAR/6heaSWK0t3BJCNYZ5/HcFdMenIgnAR789GJNNZGAZwrLSJzZ45feGt
 ADoutfjEWq3TdB9xxHN+iXO/HDHUmcoytlf0KcBr/I93sK1d8GiWsDVjPXutUgoFoM6VnT
 s+DYSOgNPJpKOOwoZsvFFKqI6TnZzMBlgnaqzry/R0xQQcPwW7q/yyhWl7OPOJ1nCgwkj0
 h6dCGZJqzqfMO/N/huGw8pnqR6+ylvhCsxsKi+2gEO1XF0MYwYTq6NofBSHSL5VZLORpCq
 ev+4ujuOVCza1UFpUMAt6xx/L6+6nbti/jcWp3tGeCurxnbuWzcX2tBFYJew21HnTh+bQZ
 MPzkAIfonnuoFy4d/WA5JcYk4FbaiJH6bLYqfz8nmhjjbZMP0cnGVhucHcBJaGjOvI6p5d
 4Oonk2eQ3UxkF7ZZLcBfC8+yt9593MvSL5iFXUX3Q9MsMZEP3eaHFn4bFhTZFp2bg5YBWG
 fYY1Q+pt2X+jbw==
 -----END SSH SIGNATURE-----

docs: add PR template

Signed-off-by: ttrlen <e.tuturina@innopolis.university>
```

The `HEAD` object is a commit. The commit stores metadata such as the author, parent commit, signature, commit message, and a reference to the root tree object. In this case, the tree SHA is `a4db3e2191b0e8e43a8d737a45ebd860033fcddc`.

#### Tree object

```text
$ git cat-file -p a4db3e2191b0e8e43a8d737a45ebd860033fcddc
040000 tree b5514176f2f0c0a1d05dfbe43d125af0b003bf27    .github
100644 blob 1c0a1e94b7bbdd951f456cda51af6b8484cc3cee    .gitignore
100644 blob d10c04c6e7e0014f4fe883599c11747c15012d4e    README.md
040000 tree 7d0898a908e274ea809722844cdbd836f3b1c05a    app
040000 tree f4f047dd07b128eda5f899dfdaaf193f0291eaa2    labs
040000 tree c0ac2d55cf4335df659b347df3d19d0594a06b6c    lectures
```

The tree object describes the repository snapshot. Entries of type `tree` correspond to directories, while entries of type `blob` correspond to file contents. For the next step, the `.gitignore` blob with SHA `1c0a1e94b7bbdd951f456cda51af6b8484cc3cee` was selected.

#### Blob object

Instead of printing the much larger `README.md`, I selected the smaller `.gitignore` blob from the same tree:

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

This confirms the complete object chain:

`HEAD` → commit → tree → blob → file contents.

---

### 1.2 Inside `.git`

```text
$ ls -la .git/
total 30
drwxr-xr-x 1 tutur 197609    0 Sep 10 19:59 ./
drwxr-xr-x 1 tutur 197609    0 Sep 10 19:58 ../
-rw-r--r-- 1 tutur 197609   87 Sep 10 17:26 COMMIT_EDITMSG
-rw-r--r-- 1 tutur 197609  560 Sep 10 15:03 config
-rw-r--r-- 1 tutur 197609   73 Sep 10 14:29 description
-rw-r--r-- 1 tutur 197609  790 Sep 10 14:32 FETCH_HEAD
-rw-r--r-- 1 tutur 197609   21 Sep 10 19:58 HEAD
drwxr-xr-x 1 tutur 197609    0 Sep 10 14:29 hooks/
-rw-r--r-- 1 tutur 197609 3183 Sep 10 19:59 index
drwxr-xr-x 1 tutur 197609    0 Sep 10 14:29 info/
drwxr-xr-x 1 tutur 197609    0 Sep 10 14:29 logs/
drwxr-xr-x 1 tutur 197609    0 Sep 10 17:26 objects/
-rw-r--r-- 1 tutur 197609   41 Sep 10 17:20 ORIG_HEAD
-rw-r--r-- 1 tutur 197609  112 Sep 10 14:29 packed-refs
drwxr-xr-x 1 tutur 197609    0 Sep 10 14:29 refs/


$ cat .git/HEAD
ref: refs/heads/main

$ ls .git/refs/heads/
feature/  main

$ ls .git/objects/ | head
01/
06/
0a/
0c/
0e/
0f/
13/
1a/
24/
28/

$ find .git/objects -type f | wc -l
51
```

The `.git` directory contains the repository's internal metadata and object database. `HEAD` points to the currently checked-out branch, `refs/heads` stores local branch references, and `objects` stores Git objects addressed by SHA hashes. The two-character directories under `.git/objects` are derived from the first two characters of object hashes. At the time of inspection, the repository contained 51 loose object files.

---

### 1.3 Reflog Recovery

Two signed work-in-progress commits were created on `feature/lab2`:

```text
$ git log --oneline -5
fdaabc5 (HEAD -> feature/lab2) wip(lab2): more progress
5ee6b20 wip(lab2): start
b7875cd (origin/main, origin/HEAD, main) docs: add PR template
9f41b7d (upstream/main, upstream/HEAD) docs(lab7): make seed.json shipping explicit; require bonus artifacts, not logs
8de962e docs(lab11): fix nixpkgs pin vs go.mod collision; add network fallback pitfalls
```

Then the branch was deliberately moved back by two commits with:

```bash
git reset --hard HEAD~2
```

The commits disappeared from the normal branch history, but `git reflog` still contained the previous positions of `HEAD`.

```text
$ git log --oneline -5
fdaabc5 (HEAD -> feature/lab2) wip(lab2): more progress
5ee6b20 wip(lab2): start
b7875cd (origin/main, origin/HEAD, main) docs: add PR template
9f41b7d (upstream/main, upstream/HEAD) docs(lab7): make seed.json shipping explicit; require bonus artifacts, not logs
8de962e docs(lab11): fix nixpkgs pin vs go.mod collision; add network fallback pitfalls

$ git reflog
b7875cd (HEAD -> feature/lab2, origin/main, origin/HEAD, main) HEAD@{0}: reset: moving to HEAD~2
fdaabc5 HEAD@{1}: commit: wip(lab2): more progress
5ee6b20 HEAD@{2}: commit: wip(lab2): start
b7875cd (HEAD -> feature/lab2, origin/main, origin/HEAD, main) HEAD@{3}: checkout: moving from main to feature/lab2
b7875cd (HEAD -> feature/lab2, origin/main, origin/HEAD, main) HEAD@{4}: checkout: moving from feature/lab1 to main
ba7271d (origin/feature/lab1, feature/lab1) HEAD@{5}: commit: docs(lab1): finish submission
fe09d54 HEAD@{6}: checkout: moving from main to feature/lab1
b7875cd (HEAD -> feature/lab2, origin/main, origin/HEAD, main) HEAD@{7}: reset: moving to origin/main
06559b7 HEAD@{8}: commit: test: unsigned commit (should fail)
b7875cd (HEAD -> feature/lab2, origin/main, origin/HEAD, main) HEAD@{9}: reset: moving to b7875cd
d855336 HEAD@{10}: commit: test: unsigned commit (should fail)
b7875cd (HEAD -> feature/lab2, origin/main, origin/HEAD, main) HEAD@{11}: checkout: moving from feature/lab1 to main
fe09d54 HEAD@{12}: commit: docs(lab1): add bonus evidence
1a92d7c HEAD@{13}: checkout: moving from main to feature/lab1
b7875cd (HEAD -> feature/lab2, origin/main, origin/HEAD, main) HEAD@{14}: commit: docs: add PR template
9f41b7d (upstream/main, upstream/HEAD) HEAD@{15}: checkout: moving from feature/lab1 to main
1a92d7c HEAD@{16}: commit: docs(lab1): add task 1 evidence
13bcb6d HEAD@{17}: commit: docs(lab1): start submission
9f41b7d (upstream/main, upstream/HEAD) HEAD@{18}: checkout: moving from main to feature/lab1
:

$ git reset --hard fdaabc5
HEAD is now at fdaabc5 wip(lab2): more progress

$ git log --oneline -5
fdaabc5 (HEAD -> feature/lab2) wip(lab2): more progress
5ee6b20 wip(lab2): start
b7875cd (origin/main, origin/HEAD, main) docs: add PR template
9f41b7d (upstream/main, upstream/HEAD) docs(lab7): make seed.json shipping explicit; require bonus artifacts, not logs
8de962e docs(lab11): fix nixpkgs pin vs go.mod collision; add network fallback pitfalls

tutur@DESKTOP-QB0HM16 MINGW64 /d/Dowlands/DO labs/DevOps-Intro (feature/lab2)
$ cat submissions/lab2.md
important work
more important work

tutur@DESKTOP-QB0HM16 MINGW64 /d/Dowlands/DO labs/DevOps-Intro (feature/lab2)
$ git status
On branch feature/lab2
nothing to commit, working tree clean
```

The most recent lost commit was `fdaabc5`, so the branch was restored with:

```text
$ git reset --hard fdaabc5
HEAD is now at fdaabc5 wip(lab2): more progress
```

After recovery, both commits and the contents of `submissions/lab2.md` were restored, and the working tree was clean.

### Garbage Collection Risk

After git reset --hard, the two commits became unreachable from the branch, but they were still referenced by the reflog. Normally Git keeps unreachable objects for a grace period, so recovery is still possible. However, if an aggressive garbage collection pruned those objects before recovery, their SHA values would no longer resolve and the lost commits could become permanently unrecoverable.

---

## Task 2 — Signed Tag and Rebase

### 2.1 Signed Annotated Release Tag

The release tag was created as an annotated and signed tag:

```bash
git tag -a -s "v0.1.0-lab2-${USER}" -m "Lab 2 milestone — version control deep dive"
```

The signature verification produced:

```text
$ git tag -v "v0.1.0-lab2-${USER}"
object b7875cd1cba2bdc9ab4e9d03838ee4b1a1eba57e
type commit
tag v0.1.0-lab2-ttrlen
tagger ttrlen <e.tuturina@innopolis.university> 1789062549 +0300

Lab 2 milestone — version control deep dive
Good "git" signature for e.tuturina@innopolis.university with RSA key SHA256:58a0VfUddYu80cRXN0pwferyuQEnlBBm5v/CWZ31xSU
```

The output reports `tag v0.1.0-lab2-ttrlen`, identifies the referenced object as a commit, and shows a `Good "git" signature`, confirming that the release tag is signed and valid.

---

### 2.2 Rebase

While `feature/lab2` contained the two Lab 2 commits, `main` was advanced with the commit `docs: upstream moved while you worked (#1)`.

#### Before rebase

```text
$ git log --oneline --graph --decorate --all -15
* 9525dcc (origin/main, origin/HEAD, main) docs: upstream moved while you worked (#1)
| * 03e99b1 (origin/lab2/upstream-move, lab2/upstream-move) docs: upstream moved while you worked
|/
| * fdaabc5 (HEAD -> feature/lab2) wip(lab2): more progress
| * 5ee6b20 wip(lab2): start
|/
* b7875cd (tag: v0.1.0-lab2-ttrlen) docs: add PR template
| * ba7271d (origin/feature/lab1, feature/lab1) docs(lab1): finish submission
| * fe09d54 docs(lab1): add bonus evidence
| * 1a92d7c docs(lab1): add task 1 evidence
| * 13bcb6d docs(lab1): start submission
|/  
* 9f41b7d (upstream/main, upstream/HEAD) docs(lab7): make seed.json shipping explicit; require bonus artifacts, not logs
* 8de962e docs(lab11): fix nixpkgs pin vs go.mod collision; add network fallback pitfalls
* bfa345b docs(lab3): matrix renames required checks — warn + ci-ok gate pattern; set honest cache expectations
* 356419b docs(lab1,lab2): clarify GitHub auth vs signing SSH key roles; add publickey-denied pitfalls
| * f0c9243 (upstream/bug/bisect-me) docs(app): mention go test invocation
| * 9fe75cc docs(store): document Count()
```

Before the rebase, `feature/lab2` and `main` had diverged: the feature branch still contained the two Lab 2 commits based on the older commit, while `main` had moved forward.

The feature branch was rebased onto the updated `origin/main` with:

```bash
git rebase origin/main
```

#### After rebase

```text
$ git log --oneline --graph --decorate --all -15
* 80b568b (HEAD -> feature/lab2) wip(lab2): more progress
* 7a7b31a wip(lab2): start
* 9525dcc (origin/main, origin/HEAD, main) docs: upstream moved while you worked (#1)
| * 03e99b1 (origin/lab2/upstream-move, lab2/upstream-move) docs: upstream moved while you worked
|/  
* b7875cd (tag: v0.1.0-lab2-ttrlen) docs: add PR template
| * ba7271d (origin/feature/lab1, feature/lab1) docs(lab1): finish submission
| * fe09d54 docs(lab1): add bonus evidence
| * 1a92d7c docs(lab1): add task 1 evidence
| * 13bcb6d docs(lab1): start submission
|/  
* 9f41b7d (upstream/main, upstream/HEAD) docs(lab7): make seed.json shipping explicit; require bonus artifacts, not logs
* 8de962e docs(lab11): fix nixpkgs pin vs go.mod collision; add network fallback pitfalls
* bfa345b docs(lab3): matrix renames required checks — warn + ci-ok gate pattern; set honest cache expectations
* 356419b docs(lab1,lab2): clarify GitHub auth vs signing SSH key roles; add publickey-denied pitfalls
| * f0c9243 (upstream/bug/bisect-me) docs(app): mention go test invocation
| * 9fe75cc docs(store): document Count()
```

After the rebase, the Lab 2 commits were replayed on top of the new `main`. Their SHAs changed from `5ee6b20` and `fdaabc5` to `7a7b31a` and `80b568b`, which is expected because rebase rewrites commit history.

The rebased branch was pushed using the safer force-push variant:

```bash
git push --force-with-lease origin feature/lab2
```

### Merge vs Rebase Reflection

I would use rebase when working on my own feature branch and I want to keep a clean, linear history before merging it. I would prefer merge when multiple people are already working with the same published branch because merge preserves the original shared history and does not rewrite commit SHAs.

---

## Bonus Task — Git Bisect

### Automated Bisect

The deliberately broken `upstream/bug/bisect-me` history was tested automatically with:

```text
$ git bisect run sh -c 'cd app && go test ./... && go build ./...'
running 'sh' '-c' 'cd app && go test ./... && go build ./...'
--- FAIL: TestStore_PersistsAcrossReload (0.01s)
    store_test.go:78: nextID not restored: got 1, want 2
FAIL
FAIL    quicknotes      0.498s
FAIL
Bisecting: 0 revisions left to test after this (roughly 0 steps)
[cb89bb9ee2ee5010b166061447eaca3ae0da2378] docs(store): comment the load() decode step
running 'sh' '-c' 'cd app && go test ./... && go build ./...'
ok      quicknotes      0.540s
f285ede8611e55ac0a7d01100891c0cc775e0709 is the first bad commit
commit f285ede8611e55ac0a7d01100891c0cc775e0709
Author: Dmitrii Creed <creeed22@gmail.com>
Date:   Fri Jun 5 13:36:56 2026 +0400

    refactor(store): simplify nextID restoration in load()
    
    Signed-off-by: Dmitrii Creed <creeed22@gmail.com>

 app/store.go | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
bisect found first bad commit
```

The test failure showed that `nextID` was not restored correctly after reloading the store. Git bisect identified the following first bad commit:

```text
SHA: f285ede8611e55ac0a7d01100891c0cc775e0709
Message: refactor(store): simplify nextID restoration in load()
```

### Bisect Log

```text
$ git bisect log
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

The offending commit was also confirmed directly:

```text
$ git show --oneline --no-patch f285ede8611e55ac0a7d01100891c0cc775e0709
f285ede refactor(store): simplify nextID restoration in load()

$ git bisect reset
Previous HEAD position was cb89bb9 docs(store): comment the load() decode step
Switched to branch 'bisect-quickn'
Your branch is up to date with 'upstream/bug/bisect-me'.

Git bisect uses binary search over the commit history. Instead of testing every commit one by one, it checks a commit near the middle and eliminates approximately half of the remaining candidates after every good/bad result. Therefore, finding a faulty commit among N commits requires approximately log₂(N) test steps.
```

### Why Bisect Is Efficient

Git bisect uses binary search over the commit history. It tests a commit near the middle of the remaining candidate range and marks it as good or bad based on the test result. Each decision removes approximately half of the remaining commits from consideration. Therefore, finding the first faulty commit among `N` candidate commits takes approximately `log₂(N)` test steps instead of checking every commit one by one.
