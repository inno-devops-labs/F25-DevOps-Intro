# Lab 2 — Version Control Deep Dive: Internals, Recovery, Rebase

**Student:** NikolayTaran (na.taranvrn@gmail.com)
**Fork:** https://github.com/NikolayTaran/DevOps-Intro
**Branch:** `feature/lab2`
**Tag:** `v0.1.0-lab2-NikolayTaran`
**PR:** https://github.com/inno-devops-labs/DevOps-Intro/pull/NUMBER

---

## Task 1 — Git Object Model + Reflog Recovery (6 pts)

### 1.1: Explore your repo's plumbing

One full chain `HEAD` → tree → blob → file contents, explored on `main` at `9f41b7d` (aligned with `upstream/main`):

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
100644 blob 1c0a1e94b7bbdd951f456cda51af6b8484cc3cee    .gitignore
100644 blob d10c04c6e7e0014f4fe883599c11747c15012d4e    README.md
040000 tree 7d0898a908e274ea809722844cdbd836f3b1c05a    app
040000 tree f4f047dd07b128eda5f899dfdaaf193f0291eaa2    labs
040000 tree c0ac2d55cf4335df659b347df3d19d0594a06b6c    lectures

$ git cat-file -p d10c04c6e7e0014f4fe883599c11747c15012d4e
# DevOps Intro — Modern DevOps Practices Through One Project

[![Course](https://img.shields.io/badge/Course-DevOps%20Intro-blue)](#course-roadmap)
[![Project](https://img.shields.io/badge/Project-QuickNotes%20(Go)-success)](#the-project-quicknotes)
[![Duration](https://img.shields.io/badge/Duration-10%20Weeks-lightgrey)](#course-roadmap)
[![Grading](https://img.shields.io/badge/Grading-70--14--5--30--30-orange)](#grading)

A 10-week practical introduction to DevOps at Innopolis University. You will package, ship, observe, harden, and deploy **one** Go service — QuickNotes — across every lab. The discipline you learn here is the spine of modern production engineering.

> 💬 *"If it hurts, do it more often."* — Jez Humble

… (the blob is the entire README.md — ~290 more lines of roadmap/grading; truncated here)
```

So the chain is: the commit `9f41b7d…` (`HEAD`) points at the tree `dc5bed5…` — one snapshot of every path in the repository — the tree points at blob `d10c04c…` for `README.md`, and printing that blob yields the actual file content. Every object is addressed by the SHA-1 of its own bytes, so identical content anywhere in history deduplicates to the same hash.

### 1.2: Look inside `.git/`

Captured on `main` right after aligning it with `upstream/main` (hence `ORIG_HEAD`), before the Task 1.3 commits:

```
$ ls -la .git/
total 29
drwxr-xr-x 1 Inno 197121    0 Sep 10 12:54 ./
drwxr-xr-x 1 Inno 197121    0 Sep 10 12:29 ../
-rw-r--r-- 1 Inno 197121  463 Sep 10 12:30 config
-rw-r--r-- 1 Inno 197121   73 Sep 10 12:29 description
-rw-r--r-- 1 Inno 197121  229 Sep 10 12:50 FETCH_HEAD
-rw-r--r-- 1 Inno 197121   21 Sep 10 12:50 HEAD
drwxr-xr-x 1 Inno 197121    0 Sep 10 12:29 hooks/
-rw-r--r-- 1 Inno 197121 3055 Sep 10 12:54 index
drwxr-xr-x 1 Inno 197121    0 Sep 10 12:29 info/
drwxr-xr-x 1 Inno 197121    0 Sep 10 12:29 logs/
drwxr-xr-x 1 Inno 197121    0 Sep 10 12:50 objects/
-rw-r--r-- 1 Inno 197121   41 Sep 10 12:54 ORIG_HEAD
-rw-r--r-- 1 Inno 197121  186 Sep 10 12:29 packed-refs
drwxr-xr-x 1 Inno 197121    0 Sep 10 12:29 refs/

$ cat .git/HEAD
ref: refs/heads/main

$ ls .git/refs/heads/
main

$ ls .git/objects/ | head
0a/
0c/
0e/
0f/
13/
1a/
3a/
40/
7a/
7e/

$ find .git/objects -type f | wc -l
25
```

Interpretation:

- `.git/HEAD` is a 21-byte plain-text file holding the symbolic ref `ref: refs/heads/main` — HEAD is nothing more than a pointer to a branch *name*, and the branch itself is one tiny file under `refs/heads/` (here just `main`) holding a 40-character SHA.
- `FETCH_HEAD` and `ORIG_HEAD` are traces of this session's operations: the refs brought by the last `git fetch upstream`, and where HEAD sat before the `git reset --hard` that aligned `main` with `upstream/main`.
- Remote-tracking refs (`origin/*`, `upstream/*`) and the tag are not loose files — they live in `packed-refs` (186 bytes).
- `objects/` shows both storage forms side by side: two-character directories (`0a/`, `0c/`, … — `head` truncated the listing at ten entries) holding **loose** objects, plus `pack/` and `info/`. The loose objects appeared with `git fetch upstream`: the fetch delivered only 24 objects — below `transfer.unpackLimit` (100 by default) — so instead of storing a tiny new pack, git exploded the fetched objects into individual zlib-compressed files, one per object, path = first 2 SHA chars as directory + remaining 38 as filename. `find .git/objects -type f | wc -l` counts 25 files: the loose objects plus the clone's original packfile set. Objects created by my own Task 1.3 commits would also be born loose; the next `git gc` would pack them.

### 1.3: Simulate disaster + recover

Two commits of "important work" on the new branch — plus a remote backup and a SHA snapshot taken *before* the experiment (the spec's own advice: capture the SHA first). The `(y/n)` prompts are OneDrive holding locks on directories git tries to delete; answering `y` retries, `n` moves on:

```
$ git switch -c feature/lab2
Switched to a new branch 'feature/lab2'

$ mkdir -p submissions
$ echo "important work" > submissions/lab2.md
$ git add submissions/lab2.md
$ git commit -S -s -m "wip(lab2): start"
[feature/lab2 bcd70c1] wip(lab2): start
 1 file changed, 1 insertion(+)
 create mode 100644 submissions/lab2.md

$ echo "more important work" >> submissions/lab2.md
$ git commit -S -s -am "wip(lab2): more progress"
warning: in the working copy of 'submissions/lab2.md', LF will be replaced by CRLF the next time Git touches it
[feature/lab2 b3a5c52] wip(lab2): more progress
 1 file changed, 1 insertion(+)

$ git push -u origin feature/lab2
Enumerating objects: 9, done.
Counting objects: 100% (9/9), done.
Delta compression using up to 12 threads
Compressing objects: 100% (4/4), done.
Writing objects: 100% (8/8), 928 bytes | 464.00 KiB/s, done.
Total 8 (delta 3), reused 0 (delta 0), pack-reused 0 (from 0)
remote: Resolving deltas: 100% (3/3), completed with 1 local object.
remote:
remote: Create a pull request for 'feature/lab2' on GitHub by visiting:
remote:      https://github.com/NikolayTaran/DevOps-Intro/pull/new/feature/lab2
remote:
To https://github.com/NikolayTaran/DevOps-Intro
 * [new branch]      feature/lab2 -> feature/lab2
branch 'feature/lab2' set up to track 'origin/feature/lab2'.

$ git log --oneline -2
b3a5c52 (HEAD -> feature/lab2, origin/feature/lab2) wip(lab2): more progress
bcd70c1 wip(lab2): start
```

Now the "stupid" part — which I managed to run **twice** (I re-pasted the disaster block after the first reset had already landed, so the branch slid four commits back in total):

```
$ git reset --hard HEAD~2
Deletion of directory 'submissions' failed. Should I try again? (y/n) y
Deletion of directory 'submissions' failed. Should I try again? (y/n) n
HEAD is now at 9f41b7d docs(lab7): make seed.json shipping explicit; require bonus artifacts, not logs

$ git reset --hard HEAD~2
HEAD is now at bfa345b docs(lab3): matrix renames required checks — warn + ci-ok gate pattern; set honest cache expectations

$ git status
On branch feature/lab2
Your branch is behind 'origin/feature/lab2' by 4 commits, and can be fast-forwarded.
  (use "git pull" to update your local branch)

nothing to commit, working tree clean

$ git log --oneline -5
bfa345b (HEAD -> feature/lab2) docs(lab3): matrix renames required checks — warn + ci-ok gate pattern; set honest cache expectations
356419b docs(lab1,lab2): clarify GitHub auth vs signing SSH key roles; add publickey-denied pitfalls
66bbd4d docs(lab1): align Task 3 GitHub Community engagement with other courses
170000c Merge pull request #907 from inno-devops-labs/s26-refactor
d50436c (upstream/s26-refactor) fix(lab12,gitignore): Spin SDK (WAGI removed in Spin 3.x); minimal student-safe gitignore
```

Both wip commits are gone from the branch — but the reflog still remembers every movement of HEAD:

```
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

Recovery. The reflog lists the lost commits newest-first: `b3a5c52` (`HEAD@{2}`) is the most recent one. My first attempt grabbed the wrong SHA — `bcd70c1`, the *older* wip commit (status then showed "behind by 1") — so I re-pointed the branch at `b3a5c52`:

```
$ git reset --hard bcd70c1
HEAD is now at bcd70c1 wip(lab2): start

$ git status
On branch feature/lab2
Your branch is behind 'origin/feature/lab2' by 1 commit, and can be fast-forwarded.
  (use "git pull" to update your local branch)

nothing to commit, working tree clean

$ git reset --hard b3a5c52
HEAD is now at b3a5c52 wip(lab2): more progress

$ git status
On branch feature/lab2
Your branch is up to date with 'origin/feature/lab2'.

nothing to commit, working tree clean

$ git log --oneline -3
b3a5c52 (HEAD -> feature/lab2, origin/feature/lab2) wip(lab2): more progress
bcd70c1 wip(lab2): start
9f41b7d (upstream/main, upstream/HEAD, origin/main, origin/HEAD, main) docs(lab7): make seed.json shipping explicit; require bonus artifacts, not logs
```

**What would happen if `git gc` had run between the bad reset and the recovery?**

Between the bad reset and the recovery the two wip commits were unreachable from any branch — only reflog entries still pointed at them. A default `git gc` does not prune objects that are still covered by reflog entries, and reflog entries are kept for the 30-day window (`gc.reflogExpire`), so a routine gc would *not* have destroyed them and recovery would still have worked. The real danger is CI-style aggressive maintenance — `git reflog expire --expire=now --all && git gc --prune=now` — which drops the reflog entries first and prunes "unreachable" objects immediately; after that `git reset --hard b3a5c52` would fail with "unknown revision", and the only surviving copy would be the one already pushed to `origin`.

---

## Task 2 — Tag a Release & Rebase a Feature (4 pts)

### 2.1: Annotated, signed release tag

```
$ git switch main
Switched to branch 'main'
Your branch is up to date with 'origin/main'.

$ git pull --ff-only upstream main
From https://github.com/inno-devops-labs/DevOps-Intro
 * branch            main       -> FETCH_HEAD
Already up to date.

$ git tag -a -s "v0.1.0-lab2-NikolayTaran" -m "Lab 2 milestone — version control deep dive"

$ git push origin "v0.1.0-lab2-NikolayTaran"
Enumerating objects: 1, done.
Counting objects: 100% (1/1), done.
Writing objects: 100% (1/1), 420 bytes | 420.00 KiB/s, done.
Total 1 (delta 0), reused 0 (delta 0), pack-reused 0 (from 0)
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
Good "git" signature for na.taranvrn@gmail.com with ED25519 key SHA256:v0q6vLEo/9mCeHerKSiK6jWk7HuDvDwqbGkz9mPJpyw
```

`objecttype` is `tag` (annotated) and `*objecttype` is `commit` (it points at a commit); `git tag -v` shows a **Good** signature made with my ED25519 SSH signing key.

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
Deletion of directory 'submissions' failed. Should I try again? (y/n) y
Deletion of directory 'submissions' failed. Should I try again? (y/n) n
Successfully rebased and updated refs/heads/feature/lab2.

$ git status
On branch feature/lab2
Your branch and 'origin/feature/lab2' have diverged,
and have 3 and 2 different commits each, respectively.
  (use "git pull" if you want to integrate the remote branch with yours)

nothing to commit, working tree clean

$ git push --force-with-lease origin feature/lab2
Enumerating objects: 9, done.
Counting objects: 100% (9/9), done.
Delta compression using up to 12 threads
Compressing objects: 100% (4/4), done.
Writing objects: 100% (8/8), 928 bytes | 464.00 KiB/s, done.
Total 8 (delta 3), reused 0 (delta 0), pack-reused 0 (from 0)
remote: Resolving deltas: 100% (3/3), completed with 1 local object.
To https://github.com/NikolayTaran/DevOps-Intro
 + b3a5c52...c58e685 feature/lab2 -> feature/lab2 (forced update)
```

The diverged status is exactly why the plain push is impossible: after the rebase my branch carries 3 commits `origin/feature/lab2` doesn't have (the replayed pair + `0bcae19`), while the remote still has the 2 original wip commits — so the rewritten history has to replace it, via `--force-with-lease` (which would still refuse if someone else had moved the remote branch in the meantime).

### 2.3: Document

Branch state **before** the rebase — my two wip commits sit on the *old* base `9f41b7d`; `main` has already moved to `0bcae19`, which is not an ancestor here:

```
$ git log --oneline --graph -5
* b3a5c52 (HEAD -> feature/lab2, origin/feature/lab2) wip(lab2): more progress
* bcd70c1 wip(lab2): start
* 9f41b7d (tag: v0.1.0-lab2-NikolayTaran, upstream/main, upstream/HEAD) docs(lab7): make seed.json shipping explicit; require bonus artifacts, not logs
* 8de962e docs(lab11): fix nixpkgs pin vs go.mod collision; add network fallback pitfalls
* bfa345b docs(lab3): matrix renames required checks — warn + ci-ok gate pattern; set honest cache expectations
```

Branch state **after** the rebase — the same two commits replayed on top of the new `main` (note the rewritten SHAs):

```
$ git log --oneline --graph -8
* c58e685 (HEAD -> feature/lab2, origin/feature/lab2) wip(lab2): more progress
* 5c50293 wip(lab2): start
* 0bcae19 (origin/main, origin/HEAD, main) docs: upstream moved while you worked
* 9f41b7d (tag: v0.1.0-lab2-NikolayTaran, upstream/main, upstream/HEAD) docs(lab7): make seed.json shipping explicit; require bonus artifacts, not logs
* 8de962e docs(lab11): fix nixpkgs pin vs go.mod collision; add network fallback pitfalls
* bfa345b docs(lab3): matrix renames required checks — warn + ci-ok gate pattern; set honest cache expectations
* 356419b docs(lab1,lab2): clarify GitHub auth vs signing SSH key roles; add publickey-denied pitfalls
* 66bbd4d docs(lab1): align Task 3 GitHub Community engagement with other courses
```

**When I'd choose merge vs rebase:** I rebase a private, short-lived branch like this one to keep history linear — after the rebase my two wip commits sit directly on top of the new `main`, so the PR diff shows exactly my changes and no merge commit. But rebase rewrites commit SHAs (mine went from `bcd70c1`/`b3a5c52` to `5c50293`/`c58e685`), which is why it is only safe for branches nobody else builds on, and why updating the remote copy requires `--force-with-lease`. For shared or already-reviewed branches I merge instead: it preserves the original SHAs and records the moment of integration at the cost of a merge commit. Rule of thumb: **rebase private, merge public.**

---

## Bonus — Bisect a Real Bug (+2 pts)

### B.1: Set up bisect

The broken branch and the known-good tag arrived with the upstream fetch at the start of the session:

```
$ git fetch upstream
remote: Enumerating objects: 32, done.
remote: Counting objects: 100% (32/32), done.
remote: Compressing objects: 100% (6/6), done.
remote: Total 24 (delta 21), reused 21 (delta 18), pack-reused 0 (from 0)
Unpacking objects: 100% (24/24), 3.19 KiB | 32.00 KiB/s, done.
From https://github.com/inno-devops-labs/DevOps-Intro
 * [new branch]      bug/bisect-me -> upstream/bug/bisect-me
 * [new branch]      main          -> upstream/main
 * [new branch]      release/f25   -> upstream/release/f25
 * [new branch]      s26           -> upstream/s26
 * [new branch]      s26-refactor  -> upstream/s26-refactor
 * [new tag]         v0.0.1        -> v0.0.1
```

Marking the endpoints — the current tip is broken, `v0.0.1` is the known-good baseline. After `good`, git checks out the middle of the suspect range:

```
$ git switch -c bisect-quickn upstream/bug/bisect-me
branch 'bisect-quickn' set up to track 'upstream/bug/bisect-me'.
Switched to a new branch 'bisect-quickn'

$ git bisect start
status: waiting for both good and bad commits

$ git bisect bad HEAD
status: waiting for good commit(s), bad commit known

$ git bisect good v0.0.1
Bisecting: 1 revision left to test after this (roughly 1 step)
[f285ede8611e55ac0a7d01100891c0cc775e0709] refactor(store): simplify nextID restoration in load()
```

### B.2: Automate it

```
$ git bisect run sh -c 'cd app && go test ./... && go build ./...'
running 'sh' '-c' 'cd app && go test ./... && go build ./...'
--- FAIL: TestStore_PersistsAcrossReload (0.00s)
    store_test.go:78: nextID not restored: got 1, want 2
FAIL
FAIL	quicknotes	0.312s
FAIL
Bisecting: 0 revisions left to test after this (roughly 0 steps)
[cb89bb9ee2ee5010b166061447eaca3ae0da2378] docs(store): comment the load() decode step
running 'sh' '-c' 'cd app && go test ./... && go build ./...'
ok  	quicknotes	0.187s
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

### B.3: Document

The full bisect log (captured before `git bisect reset`):

```
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

Resetting the working tree and returning to the report branch:

```
$ git bisect reset
Previous HEAD position was cb89bb9 docs(store): comment the load() decode step
Switched to branch 'bisect-quickn'
Your branch is up to date with 'upstream/bug/bisect-me'.

$ git switch feature/lab2
Switched to branch 'feature/lab2'
Your branch is up to date with 'origin/feature/lab2'.
```

**The offending commit:** `f285ede8611e55ac0a7d01100891c0cc775e0709` — *refactor(store): simplify nextID restoration in load()*. It changed `if n.ID >= s.nextID` to `if n.ID > s.nextID` in `app/store.go`, so when `load()` re-hydrates persisted notes, an ID equal to the current `nextID` no longer bumps it — after a reload the next `Create` reuses ID 1 and collides with the existing note. That is exactly what `TestStore_PersistsAcrossReload` catches: `nextID not restored: got 1, want 2`. The other three commits in the range are documentation-only, so the build stays green and only this one test fails.

**How bisect finds the culprit in log₂(N) steps:** With the endpoints marked (`bad` = the broken tip `f0c9243`, `good` = `v0.0.1`), the suspect range held 4 candidate commits. `git bisect` checks out the commit closest to the middle of the range and lets a single test run discard half of the candidates at once — good ⇒ that commit and everything before it is good, bad ⇒ everything after it is bad. Halving repeats, so N candidates cost about log₂(N) test runs: 4 → 2 (exactly what the log above shows — two `running …` invocations, at `f285ede` and then `cb89bb9`), 1024 → 10, a million → 20, while a linear scan could need all N. The only assumption is monotonicity — every commit after the true culprit is also broken, every commit before it is fine — which holds here because the bug is a single one-line change inherited by every descendant.
