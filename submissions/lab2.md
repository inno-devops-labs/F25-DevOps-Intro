# Lab 2 submission

## Task 1 — Git Object Model + Reflog Recovery

### 1.1 The object chain: HEAD → tree → blob → file

```
$ git rev-parse HEAD
9606dc4341e182418dba2e2bc989d5f6be60f94d

$ git cat-file -t HEAD
commit

$ git cat-file -p HEAD
tree 4e8941f4762188e39dde75dbbc42c9b8b0a2f920
parent 9f41b7deb32343a831b5e47c61533fbc7c0ce67d
author illmmmiira <i.usmanova@innopolis.university> 1789068783 +0300
committer illmmmiira <i.usmanova@innopolis.university> 1789068783 +0300
gpgsig -----BEGIN SSH SIGNATURE-----
 (signature omitted for brevity)
 -----END SSH SIGNATURE-----

docs: add PR template

Signed-off-by: illmmmiira <i.usmanova@innopolis.university>

$ git cat-file -p 4e8941f4762188e39dde75dbbc42c9b8b0a2f920
040000 tree 1d07791eee3c3dd0955a02402b05b3a357816d8d .github
100644 blob 1c0a1e94b7bbdd951f456cda51af6b8484cc3cee .gitignore
100644 blob d10c04c6e7e0014f4fe883599c11747c15012d4e README.md
040000 tree 7d0898a908e274ea809722844cdbd836f3b1c05a app
040000 tree f4f047dd07b128eda5f899dfdaaf193f0291eaa2 labs
040000 tree c0ac2d55cf4335df659b347df3d19d0594a06b6c lectures

$ git cat-file -p d10c04c6e7e0014f4fe883599c11747c15012d4e
# DevOps Intro — Modern DevOps Practices Through One Project
... (full README content)
```

**What this shows:** a commit object doesn't store files directly — it points at one tree object (the root directory snapshot) plus a parent commit. The tree lists each entry as either a blob (a file's raw content, addressed by the SHA of that content) or another tree (a subdirectory). Following `HEAD` → tree → blob → file content is literally walking the four object types Git has: commit, tree, blob, and (for annotated tags) tag.

### 1.2 Inside `.git/`

```
$ cat .git/HEAD
ref: refs/heads/main

$ ls .git/refs/heads/
feature   main

$ ls .git/objects/ | head
0a
0c
0e
0f
13
1a
1d
27
31
32

$ find .git/objects -type f | wc -l
52
```

**Interpretation:** `.git/HEAD` is a symbolic reference — it doesn't hold a commit SHA directly, it points at a branch ref (`refs/heads/main`), so checking out a different branch just rewrites this one line. `.git/refs/heads/` has one file per local branch, each containing the SHA of that branch's tip commit — that's the entire "branch" concept in Git, just a movable pointer to a commit. `.git/objects/` is the actual object database: every blob, tree, and commit ever created in this repo is stored there as a compressed file named after its own SHA-1 hash, split into subdirectories by the hash's first two characters so the filesystem isn't dealing with one folder containing thousands of files. 52 loose objects is a small, young repo — a real project accumulates many more before Git's garbage collector packs them into compact packfiles.

### 1.3 Disaster + recovery

```
$ git switch -c feature/lab2
Switched to a new branch 'feature/lab2'

$ mkdir -p submissions
$ echo "important work" > submissions/lab2.md
$ git add submissions/lab2.md
$ git commit -S -s -m "wip(lab2): start"
[feature/lab2 9fbd5b8] wip(lab2): start
 1 file changed, 1 insertion(+)
 create mode 100644 submissions/lab2.md

$ echo "more important work" >> submissions/lab2.md
$ git commit -S -s -am "wip(lab2): more progress"
[feature/lab2 0e81eaa] wip(lab2): more progress
 1 file changed, 1 insertion(+)

$ git reset --hard HEAD~2
HEAD is now at 9606dc4 docs: add PR template

$ git log --oneline
(the wip commits no longer appear — they look gone)

$ git reflog
9606dc4 HEAD@{0}: reset: moving to HEAD~2
0e81eaa HEAD@{1}: commit: wip(lab2): more progress
9fbd5b8 HEAD@{2}: commit: wip(lab2): start
...
```

Recovery:

```
$ git reset --hard 0e81eaa
HEAD is now at 0e81eaa wip(lab2): more progress

$ cat submissions/lab2.md
important work
more important work
```

Both commits are back — `git reset --hard` only moves where the branch pointer looks; it doesn't actually delete the commit objects themselves, so as long as something (here, the reflog) still remembers their SHAs, they're fully recoverable.

**What if `git gc` had run between the reset and the recovery?** Once a commit is no longer reachable from any branch or tag, it's only being kept alive by the reflog entry pointing at it. `git gc` (or the automatic gc Git runs periodically) is allowed to prune objects that are both unreachable *and* older than the reflog expiry window (30 days by default, but much shorter in some CI setups) — so a `gc` running in that gap could permanently delete the "lost" commits before you got to `git reset --hard <SHA>`, making recovery impossible. That's why the safe move is to grab the SHA from `git reflog` immediately and only then decide what to do next, rather than poking around first.

## Task 2 — Tag a Release & Rebase a Feature

### Signed annotated tag

```
$ git tag -a -s "v0.1.0-lab2-ilmira" -m "Lab 2 milestone — version control deep dive"
$ git push origin v0.1.0-lab2-ilmira
 * [new tag]         v0.1.0-lab2-ilmira -> v0.1.0-lab2-ilmira

$ git tag -l --format='%(refname:short) %(objecttype) %(*objecttype)' v0.1.0-lab2-ilmira
v0.1.0-lab2-ilmira tag commit

$ git tag -v v0.1.0-lab2-ilmira
object 9606dc4341e182418dba2e2bc989d5f6be60f94d
type commit
tag v0.1.0-lab2-ilmira
tagger illmmmiira <i.usmanova@innopolis.university> 1789073416 +0300

Lab 2 milestone — version control deep dive
Good "git" signature for i.usmanova@innopolis.university with ED25519 key SHA256:nRzoNCSkOdnU0U/32ngInt766BQ5tAat1U3SzWZzrb0
```

Confirmed: the tag is an annotated tag object pointing at a commit, and its signature verifies as Good.

### Rebase + force-with-lease

Note: the branch protection ruleset added in Lab 1's Bonus task ("require a pull request before merging" on `main`) initially blocked the lab's simulated direct push to `main`. I temporarily disabled the ruleset's enforcement, pushed the empty commit, then re-enabled it — a legitimate, deliberate bypass rather than working around the protection accidentally.

**Before rebase** (`feature/lab2` sitting on the old tip of `main`):
```
* 91dffb3 docs(lab2): document object model chain, .git internals, and reflog recovery
* 0e81eaa wip(lab2): more progress
* 9fbd5b8 wip(lab2): start
* 9606dc4 (tag: v0.1.0-lab2-ilmira) docs: add PR template
* 9f41b7d (upstream/main, upstream/HEAD) docs(lab7): ...
```

**After rebase** (same three commits, rewritten, now sitting on the new tip of `main`):
```
* 26d7bad (HEAD -> feature/lab2) docs(lab2): document object model chain, .git internals, and reflog recovery
* 5357eac wip(lab2): more progress
* b7e8413 wip(lab2): start
* 78efcf2 (origin/main, origin/HEAD, main) docs: upstream moved while you worked
* 9606dc4 (tag: v0.1.0-lab2-ilmira) docs: add PR template
```

```
$ git rebase origin/main
Successfully rebased and updated refs/heads/feature/lab2.

$ git push --force-with-lease origin feature/lab2
 * [new branch]      feature/lab2 -> feature/lab2
```

No conflicts occurred. `--force-with-lease` was used instead of plain `--force` because it refuses to overwrite the remote branch if someone else has pushed to it since my last fetch — it checks the remote's current state before force-pushing, so it can't silently blow away work I don't know about, unlike plain `--force` which pushes no matter what's there.

### Merge vs. rebase — when I'd choose each

I'd rebase when the branch is still mine and not yet shared — cleaning up my own commit history (like squashing "wip" commits, or catching up with a moved `main`) before opening a PR, so the history stays linear and easy to read. I'd merge instead once a branch has been pushed and other people might already be building on top of it, or once it represents a real point-in-time integration worth preserving (like merging a finished feature into `main`) — rebasing a branch other people have already based work on rewrites its history and can break their local copies, so at that point merge is the safer, more honest option.

## Bonus Task — Bisect a Real Bug

### Setup

```
$ git fetch upstream
$ git switch -c bisect-quickn upstream/bug/bisect-me
$ git bisect start
$ git bisect bad HEAD
$ git bisect good v0.0.1
Bisecting: 1 revision left to test after this (roughly 1 step)
[f285ede8611e55ac0a7d01100891c0cc775e0709] refactor(store): simplify nextID restoration in load()
```

### Automated run

```
$ git bisect run sh -c 'cd app && go test ./... && go build ./...'
--- FAIL: TestStore_PersistsAcrossReload (0.00s)
    store_test.go:78: nextID not restored: got 1, want 2
FAIL
Bisecting: 0 revisions left to test after this (roughly 0 steps)
[cb89bb9ee2ee5010b166061447eaca3ae0da2378] docs(store): comment the load() decode step
running 'sh' '-c' 'cd app && go test ./... && go build ./...'
ok  quicknotes 0.449s
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

### Offending commit

**`f285ede8611e55ac0a7d01100891c0cc775e0709`** — `refactor(store): simplify nextID restoration in load()`. This change to `app/store.go` broke `TestStore_PersistsAcrossReload`: after reloading stored notes, the next auto-incremented note ID wasn't being restored correctly (test expected `2`, got `1`), meaning a fresh note created after a reload could collide with or reuse an existing note's ID.

### Full bisect log

```
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

### Why bisect finds it in log₂(N) steps

Bisect treats the commit range between a known-good and known-bad commit as a sorted sequence (sorted by "does the bug exist yet") and does binary search over it rather than testing every commit one by one. Each test — build + run the test suite at the midpoint commit — throws away half of the remaining candidates: if that midpoint is good, the bug was introduced later, so everything before it is ruled out; if it's bad, everything after it is ruled out. Halving the search space every step is exactly what gives binary search its log₂(N) complexity: for N commits between good and bad, only about log₂(N) tests are needed to pin down the exact one, instead of up to N tests with a linear walk. In this case the range was small (only a handful of commits), so it converged in essentially one automated step — but the same halving approach scales fine even across a range of thousands of commits, which is the real value of bisect over manually `git log`-ing and guessing.
