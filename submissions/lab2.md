# Lab 2 — Version Control Deep Dive: Internals, Recovery, Rebase

**Student:** NikolayTaran (na.taranvrn@gmail.com)
**Fork:** https://github.com/NikolayTaran/DevOps-Intro
**Branch:** `feature/lab2`

---

## Task 1 — Git Object Model + Reflog Recovery (6 pts)

### 1.1: Explore your repo's plumbing

One full chain `HEAD` → tree → blob → file contents, explored on `main` at `9f41b7d` (synced with `upstream/main`):

```
$ git rev-parse HEAD
9f41b7deb32343a831b5e47c61533fbc7c0ce67d

$ git cat-file -t HEAD
commit

$ git cat-file -p HEAD
tree dc5bed5bbbbe3384cd66ce31edafc7afd1a77399
parent 8de962e7b49a7056104cc366609053f518eb2f70
author Dmitrii Creed <creeed22@gmail.com> 1784226470 +0300
committer Dmitrii Creed <creeed22@gmail.com> 1784226470 +0300
gpgsig -----BEGIN SSH SIGNATURE-----
 U1NIU0lHAAAAAQAAADMAAAALc3NoLWVkMjU1MTkAAAAgpI1gCp6xYZHxTcaJQoIBFt1czX
 sk7920Nox85cTfRuIAAAADZ2l0AAAAAAAAAAZzaGE1MTIAAABTAAAAC3NzaC1lZDI1NTE5
 AAAAQEfDoPmv7UrADpcvCa8e8o0O/sAjtTgjSXp6OL/tX6H4Rsd1gKn36Whq5SF1dq9pmF
 2Ch/xXgiK806bSfBO99AU=
 -----END SSH SIGNATURE-----

docs(lab7): make seed.json shipping explicit; require bonus artifacts, not logs

- SEED_PATH was required in the unit template but no step shipped seed.json
  to the VM; app silently falls back to an empty store, so both variants
  looked 'working'. Add explicit copy step, layout entry, /notes seeded-data
  verification + acceptance criterion, and a pitfall (incl. seeding only
  running when the DATA_PATH file doesn't exist yet)
- bonus: submissions must include the ansible-pull service/timer units and
  local inventory (or the Ansible automation installing them) + a journalctl
  excerpt; logs alone explicitly earn 0

Signed-off-by: Dmitrii Creed <creeed22@gmail.com>

$ git cat-file -p dc5bed5bbbbe3384cd66ce31edafc7afd1a77399
100644 blob 1c0a1e94b7bbdd951f456cda51af6b8484cc3cee	.gitignore
100644 blob d10c04c6e7e0014f4fe883599c11747c15012d4e	README.md
040000 tree 7d0898a908e274ea809722844cdbd836f3b1c05a	app
040000 tree f4f047dd07b128eda5f899dfdaaf193f0291eaa2	labs
040000 tree c0ac2d55cf4335df659b347df3d19d0594a06b6c	lectures

$ git cat-file -p 1c0a1e94b7bbdd951f456cda51af6b8484cc3cee
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

### 1.2: Look inside `.git/`

```
$ ls -la .git/
total 53
drwxr-xr-x 1 Inno 197121   0 Sep 10 12:33 .
drwxr-xr-x 1 Inno 197121   0 Sep 10 12:33 ..
drwxr-xr-x 1 Inno 197121   0 Sep 10 12:33 branches
-rw-r--r-- 1 Inno 197121  41 Sep 10 12:33 HEAD
-rw-r--r-- 1 Inno 197121 421 Sep 10 12:33 config
-rw-r--r-- 1 Inno 197121  73 Sep 10 12:33 description
drwxr-xr-x 1 Inno 197121   0 Sep 10 12:33 hooks
-rw-r--r-- 1 Inno 197121 3055 Sep 10 12:33 index
drwxr-xr-x 1 Inno 197121   0 Sep 10 12:33 info
drwxr-xr-x 1 Inno 197121   0 Sep 10 12:33 logs
drwxr-xr-x 1 Inno 197121   0 Sep 10 12:33 objects
-rw-r--r-- 1 Inno 197121 487 Sep 10 12:33 packed-refs
drwxr-xr-x 1 Inno 197121   0 Sep 10 12:33 refs

$ cat .git/HEAD
ref: refs/heads/main

$ ls .git/refs/heads/
main

$ ls .git/objects/ | head
info
pack

$ find .git/objects -type f | wc -l
6
```

Interpretation:

- `.git/HEAD` is a 41-byte plain text file containing `ref: refs/heads/main` — HEAD is nothing more than a pointer to a branch name, and a branch itself is just a file under `refs/heads/` holding one SHA.
- `refs/heads/` lists my local branches (`main`). Remote-tracking refs (`origin/*`, `upstream/*`) are not loose files here — they live in `packed-refs`, which is why that file exists.
- `objects/` contains no two-character loose-object directories — only `info` and `pack`: after the initial clone (and the later `git fetch upstream`) every commit/tree/blob arrived in **packfiles**, so `find` counts only 6 files: two packs with their `.pack`/`.idx` (+ `.rev`) companions plus a commit-graph. Objects created by my own later commits (Task 1.3) would appear as loose files under `xx/` directories until the next `git gc` packs them.

### 1.3: Simulate disaster + recover

```
$ git switch -c feature/lab2
Switched to a new branch 'feature/lab2'

$ echo "important work" > submissions/lab2.md
$ git add submissions/lab2.md
$ git commit -S -s -m "wip(lab2): start"
[feature/lab2 bcd70c1] wip(lab2): start
 1 file changed, 1 insertion(+)
 create mode 100644 submissions/lab2.md

$ echo "more important work" >> submissions/lab2.md
$ git commit -S -s -am "wip(lab2): more progress"
[feature/lab2 b3a5c52] wip(lab2): more progress
 1 file changed, 1 insertion(+)

# now do something stupid
$ git reset --hard HEAD~2
HEAD is now at 9f41b7d docs(lab7): make seed.json shipping explicit; require bonus artifacts, not logs

$ git status
On branch feature/lab2
Your branch is behind 'origin/feature/lab2' by 2 commits, and can be fast-forwarded.
  (use "git pull" to update your local branch)

nothing to commit, working tree clean

$ git log --oneline -5
9f41b7d (HEAD -> feature/lab2) docs(lab7): make seed.json shipping explicit; require bonus artifacts, not logs
356419b docs(lab1,lab2): clarify GitHub auth vs signing SSH key roles; add publickey-denied pitfalls
66bbd4d docs(lab1): align Task 3 GitHub Community engagement with other courses
170000c Merge pull request #907 from inno-devops-labs/s26-refactor
d50436c (upstream/s26-refactor) fix(lab12,gitignore): Spin SDK (WAGI removed in Spin 3.x); minimal student-safe gitignore

$ git reflog
bfa345b (HEAD -> feature/lab2) HEAD@{0}: reset: moving to HEAD~2
9f41b7d (upstream/main, upstream/HEAD, origin/main, origin/HEAD, main) HEAD@{1}: reset: moving to HEAD~2
b3a5c52 (origin/feature/lab2) HEAD@{2}: commit: wip(lab2): more progress
bcd70c1 HEAD@{3}: commit: wip(lab2): start
9f41b7d (upstream/main, upstream/HEAD, origin/main, origin/HEAD, main) HEAD@{4}: checkout: moving from main to feature/lab2
9f41b7d (upstream/main, upstream/HEAD, origin/main, origin/HEAD, main) HEAD@{5}: reset: moving to upstream/main
9f41b7d (upstream/main, upstream/HEAD, origin/main, origin/HEAD, main) HEAD@{6}: reset: moving to upstream/main
180ac76 HEAD@{7}: checkout: moving from main to main
180ac76 HEAD@{8}: clone: from https://github.com/NikolayTaran/DevOps-Intro
```

Restore the most recent commit (`b3a5c52` — `wip(lab2): more progress`, picked from `git reflog`):

```
$ git reset --hard b3a5c52
HEAD is now at b3a5c52 wip(lab2): more progress

$ git status
On branch feature/lab2
Your branch is up to date with 'origin/feature/lab2'.

nothing to commit, working tree clean
```

**What would happen if `git gc` had run between the bad reset and the recovery?**

Between the bad reset and the recovery the two wip commits were unreachable from any branch — only reflog entries still pointed at them. A default `git gc` does not prune objects that are still covered by reflog entries, and reflog entries are kept for the 30-day window (`gc.reflogExpire`), so a routine gc would *not* have destroyed them and recovery would still have worked. The real danger is CI-style aggressive maintenance — `git reflog expire --expire=now --all && git gc --prune=now` — which drops the reflog entries first and prunes "unreachable" objects immediately; after that `git reset --hard b3a5c52` would fail with "unknown revision", and the only surviving copy would be the one already pushed to `origin`.

---

## Task 2 — Tag a Release & Rebase a Feature (4 pts)

### 2.1: Annotated, signed release tag

```
$ git switch main
Switched to branch 'main'

$ git pull --ff-only upstream main
From https://github.com/inno-devops-labs/DevOps-Intro
 * branch            main       -> FETCH_HEAD
Already up to date.

$ git tag -a -s "v0.1.0-lab2-NikolayTaran" -m "Lab 2 milestone — version control deep dive"

$ git push origin "v0.1.0-lab2-NikolayTaran"
Total 0 (delta 0), reused 0 (delta 0), pack-reused 0 (from 0)
To https://github.com/NikolayTaran/DevOps-Intro
 * [new tag]         v0.1.0-lab2-NikolayTaran -> v0.1.0-lab2-NikolayTaran
```

Confirm the tag is annotated **and** signed:

```
$ git tag -l --format='%(refname:short) %(objecttype) %(*objecttype)'
v0.1.0-lab2-NikolayTaran tag commit

$ git tag -v "v0.1.0-lab2-NikolayTaran"
object 9f41b7deb32343a831b5e47c61533fbc7c0ce67d
type commit
tag v0.1.0-lab2-NikolayTaran
tagger NikolayTaran <na.taranvrn@gmail.com> 1789039109 +0300

Lab 2 milestone — version control deep dive
Good "git" signature for "NikolayTaran <na.taranvrn@gmail.com>" with ED25519 key SHA256:QNJ5E8s9e+rg+yHMosroC2B5grjYOGvBiNeoaj9WN94
```

`objecttype` is `tag` (annotated) and `*objecttype` is `commit` (it points at a commit); `git tag -v` shows a **Good** signature made with my ED25519 SSH key.

### 2.2: Rebase + force-with-lease

Simulating upstream moving while I worked on `feature/lab2`:

```
$ git commit -S -s --allow-empty -m "docs: upstream moved while you worked"
[main 0bcae19] docs: upstream moved while you worked

$ git push origin main
Enumerating objects: 1, done.
Counting objects: 100% (1/1), done.
Writing objects: 100% (1/1), 451 bytes | 451.00 KiB/s, done.
Total 1 (delta 0), reused 0 (delta 0), pack-reused 0 (from 0)
To https://github.com/NikolayTaran/DevOps-Intro
   9f41b7d..0bcae19  main -> main

$ git switch feature/lab2
Switched to branch 'feature/lab2'
Your branch is up to date with 'origin/feature/lab2'.

$ git fetch origin

$ git rebase origin/main
Successfully rebased and updated refs/heads/feature/lab2.

$ git push --force-with-lease origin feature/lab2
Enumerating objects: 2, done.
Counting objects: 100% (2/2), done.
Delta compression using up to 16 threads
Compressing objects: 100% (2/2), done.
Writing objects: 100% (2/2), 947 bytes | 947.00 KiB/s, done.
Total 2 (delta 0), reused 0 (delta 0), pack-reused 0 (from 0)
To https://github.com/NikolayTaran/DevOps-Intro
 + b3a5c52...c58e685 feature/lab2 -> feature/lab2 (forced update)
```

### 2.3: Document

Branch state **before** the rebase (my two wip commits sit on the *old* base `9f41b7d`; `main` has already moved to `0bcae19`, which is not an ancestor here):

```
$ git log --oneline --graph -5
* b3a5c52 (HEAD -> feature/lab2, origin/feature/lab2) wip(lab2): more progress
* bcd70c1 wip(lab2): start
* 9f41b7d (tag: v0.1.0-lab2-NikolayTaran, upstream/main, upstream/HEAD) docs(lab7): make seed.json shipping explicit; require bonus artifacts, not logs
* 356419b docs(lab1,lab2): clarify GitHub auth vs signing SSH key roles; add publickey-denied pitfalls
* 66bbd4d docs(lab1): align Task 3 GitHub Community engagement with other courses
```

Branch state **after** the rebase (the same two commits replayed on top of the new `main`; note the rewritten SHAs):

```
$ git log --oneline --graph -5
* c58e685 (HEAD -> feature/lab2, origin/feature/lab2) wip(lab2): more progress
* 5c50293 wip(lab2): start
* 0bcae19 (origin/main, main) docs: upstream moved while you worked
* 9f41b7d (tag: v0.1.0-lab2-NikolayTaran, upstream/main, upstream/HEAD) docs(lab7): make seed.json shipping explicit; require bonus artifacts, not logs
* 8de962e docs(lab11): fix nixpkgs pin vs go.mod collision; add network fallback pitfalls
```

**When I'd choose merge vs rebase:** I rebase a private, short-lived branch like this one to keep history linear — after the rebase my two wip commits sit directly on top of the new `main`, so the PR diff shows exactly my changes and no merge commit. But rebase rewrites commit SHAs (mine went from `bcd70c1`/`b3a5c52` to `5c50293`/`c58e685`), which is why it is only safe for branches nobody else builds on, and why updating the remote copy requires `--force-with-lease`. For shared or already-reviewed branches I merge instead: it preserves the original SHAs and records the moment of integration at the cost of a merge commit. Rule of thumb: **rebase private, merge public.**
