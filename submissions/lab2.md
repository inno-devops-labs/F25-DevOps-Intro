# Lab 2 — Version Control Deep Dive

## Task 1 — Git Object Model + Reflog Recovery

### 1.1 Git Object Model

```text
$ git rev-parse HEAD
479cbd80d767e5a525a5280c07784305f4d0a1e0

$ git cat-file -t HEAD
commit

$ git cat-file -p HEAD
tree ff41b8c65eb89a5337f4bc15940420e8fbe15b3e
parent 9f41b7deb32343a831b5e47c61533fbc7c0ce67d
author Renata Salikhzyanova <reny.zel@mail.ru> 1788526229 +0300
committer Renata Salikhzyanova <reny.zel@mail.ru> 1788526229 +0300
gpgsig -----BEGIN SSH SIGNATURE-----
...
-----END SSH SIGNATURE-----

docs: add PR template

Signed-off-by: Renata Salikhzyanova <reny.zel@mail.ru>

$ git cat-file -p ff41b8c65eb89a5337f4bc15940420e8fbe15b3e
040000 tree d0f15a494317a8a43f617b9d4784429b9c5167ab    .github
100644 blob 1c0a1e94b7bbdd951f456cda51af6b8484cc3cee    .gitignore
100644 blob d10c04c6e7e0014f4fe883599c11747c15012d4e    README.md
040000 tree 7d0898a908e274ea809722844cdbd836f3b1c05a    app
040000 tree f4f047dd07b128eda5f899dfdaaf193f0291eaa2    labs
040000 tree c0ac2d55cf4335df659b347df3d19d0594a06b6c    lectures

$ git cat-file -p d10c04c6e7e0014f4fe883599c11747c15012d4e
# DevOps Intro — Modern DevOps Practices Through One Project
...
```

This shows the Git object chain: `HEAD → commit → tree → blob → file contents`

### 1.2 Inside `.git/`

```text
$ ls -la .git/
COMMIT_EDITMSG
FETCH_HEAD
HEAD
ORIG_HEAD
config
description
hooks
index
info
logs
objects
packed-refs
refs

$ cat .git/HEAD
ref: refs/heads/main

$ ls .git/refs/heads/
feature main

$ ls .git/objects/ | head
03
0a
0c
0d
0e
0f
10
13
1a
1d

$ find .git/objects -type f | wc -l
68
```

`HEAD` points to the current branch, while `refs/heads` stores local branch references. The `objects` directory contains Git objects organized by SHA, and there were 68 loose object files

### 1.3 Reflog Recovery

I created two commits:

```text
1122549 wip(lab2): start
1560e10 wip(lab2): more progress
```

Then I performed a hard reset:

```text
$ git reset --hard HEAD~2
HEAD is now at 479cbd8 docs: add PR template

$ git status
On branch feature/lab2
nothing to commit, working tree clean

$ git log --oneline
479cbd8 docs: add PR template
9f41b7d docs(lab7): make seed.json shipping explicit; require bonus artifacts, not logs
...
```

The commits were still visible in the reflog:

```text
$ git reflog
479cbd8 HEAD@{0}: reset: moving to HEAD~2
1560e10 HEAD@{1}: commit: wip(lab2): more progress
1122549 HEAD@{2}: commit: wip(lab2): start
479cbd8 HEAD@{3}: checkout: moving from main to feature/lab2
...
```

I recovered the latest commit:

```text
$ git reset --hard 1560e10
HEAD is now at 1560e10 wip(lab2): more progress

$ git status
On branch feature/lab2
nothing to commit, working tree clean
```

After the reset, the commits were unreachable from the branch but were still referenced by the reflog. A normal `git gc` would usually not remove them immediately, but if the unreachable objects were pruned before recovery, the commits could be permanently lost and could no longer be restored using their SHA

## Task 2 — Signed Tag + Rebase

### 2.1 Signed Annotated Tag

I created and pushed a signed annotated tag:

```text
$ git tag -a -s "v0.1.0-lab2-${USER}" -m "Lab 2 milestone — version control deep dive"

$ git push origin "v0.1.0-lab2-${USER}"
To github.com:rslwqr/DevOps-Intro.git
 * [new tag]         v0.1.0-lab2-renatasalikhzianova -> v0.1.0-lab2-renatasalikhzianova
```

The tag is an annotated tag pointing to a commit:

```text
$ git tag -l --format='%(refname:short) %(objecttype) %(*objecttype)'
v0.0.1 tag commit
v0.1.0-lab2-renatasalikhzianova tag commit
```

The signature was successfully verified:

```text
$ git tag -v "v0.1.0-lab2-${USER}"
object 479cbd80d767e5a525a5280c07784305f4d0a1e0
type commit
tag v0.1.0-lab2-renatasalikhzianova
tagger Renata Salikhzyanova <reny.zel@mail.ru> 1788942683 +0300

Lab 2 milestone — version control deep dive
Good "git" signature for reny.zel@mail.ru with ED25519 key SHA256:VaUm+fcb8tsKSbhThnrXU1LNuh7A6H9ojNi8OyAD82U
```

### 2.2 Rebase

I created a new signed commit on `main` to simulate the base branch moving:

```text
$ git commit -S -s --allow-empty -m "docs: upstream moved while you worked"
[main 84143e7] docs: upstream moved while you worked
```

Before the rebase, `main` and `feature/lab2` had diverged:

```text
$ git log --oneline --graph --all --decorate -8
* 84143e7 (origin/main, origin/HEAD, main) docs: upstream moved while you worked
| *   4f4fcce (refs/stash) WIP on feature/lab2: 1560e10 wip(lab2): more progress
| |\
| | * 1383643 index on feature/lab2: 1560e10 wip(lab2): more progress
| |/
| * 1560e10 (HEAD -> feature/lab2) wip(lab2): more progress
| * 1122549 wip(lab2): start
|/
* 479cbd8 (tag: v0.1.0-lab2-renatasalikhzianova) docs: add PR template
```

I rebased the feature branch onto the updated `origin/main`:

```text
$ git rebase origin/main
Successfully rebased and updated refs/heads/feature/lab2.
```

After the rebase, the history became linear:

```text
$ git log --oneline --graph --decorate -6
* d83d2a0 (HEAD -> feature/lab2) wip(lab2): more progress
* 817ae89 wip(lab2): start
* 84143e7 (origin/main, origin/HEAD, main) docs: upstream moved while you worked
* 479cbd8 (tag: v0.1.0-lab2-renatasalikhzianova) docs: add PR template
* 9f41b7d (upstream/main, upstream/HEAD) docs(lab7): make seed.json shipping explicit; require bonus artifacts, not logs
* 8de962e docs(lab11): fix nixpkgs pin vs go.mod collision; add network fallback pitfalls
```

Rebase keeps the history linear by replaying the feature commits on top of the updated base branch, which changes their commit SHAs. Merge preserves the existing commit history and usually adds a merge commit, so it is safer for already shared history, while rebase is useful for keeping local feature branch history clean

## Bonus — Git Bisect

I used `git bisect` with `v0.0.1` as the known good commit and `f0c9243` as the known bad commit. The test and build were automated with:

```text
$ git bisect run sh -c 'cd app && go test ./... && go build ./...'

running 'sh' '-c' 'cd app && go test ./... && go build ./...'
--- FAIL: TestStore_PersistsAcrossReload (0.00s)
    store_test.go:78: nextID not restored: got 1, want 2
FAIL
FAIL    quicknotes      2.717s
FAIL
Bisecting: 0 revisions left to test after this (roughly 0 steps)
[cb89bb9ee2ee5010b166061447eaca3ae0da2378] docs(store): comment the load() decode step
running 'sh' '-c' 'cd app && go test ./... && go build ./...'
ok      quicknotes      0.353s
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

Full bisect log:

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

The first bad commit was:

```text
f285ede8611e55ac0a7d01100891c0cc775e0709
refactor(store): simplify nextID restoration in load()
```

`git bisect` uses binary search, so it does not need to test every commit one by one. At each step it checks a commit near the middle of the remaining range and eliminates approximately half of the candidates. Therefore, finding a bad commit among `N` commits requires roughly `log₂(N)` tests instead of `N` tests