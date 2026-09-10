# Lab 2 submission

## Task 1 — Git object model and reflog recovery

### HEAD → tree → blob → file

```console
$ git rev-parse HEAD
f2c7c5cd41f3089f545a8da4f09ea4d0b892b5d3

$ git cat-file -t HEAD
commit

$ git cat-file -p HEAD
tree 4e8941f4762188e39dde75dbbc42c9b8b0a2f920
parent 9f41b7deb32343a831b5e47c61533fbc7c0ce67d
author Anastasiia Mikhelson <a.mikhelson@innopolis.university> 1789069975 +0500
committer Anastasiia Mikhelson <a.mikhelson@innopolis.university> 1789069975 +0500
gpgsig -----BEGIN SSH SIGNATURE-----
 U1NIU0lHAAAAAQAAADMAAAALc3NoLWVkMjU1MTkAAAAgOpj0LwpK28kfMLx+PZ4b7Syf6C
 qmeFDDYlLiMEm/fYwAAAADZ2l0AAAAAAAAAAZzaGE1MTIAAABTAAAAC3NzaC1lZDI1NTE5
 AAAAQAcnucmhTVg1lzZfCEf+BD9oa3I8X538vbvPWu4kZZ0kLJBcWPiXAtsKXR7pukkbfg
 hZXm7CH7c+8JXAAQq1Gww=
 -----END SSH SIGNATURE-----

docs: add PR template

Signed-off-by: Anastasiia Mikhelson <a.mikhelson@innopolis.university>

$ git cat-file -p 4e8941f4762188e39dde75dbbc42c9b8b0a2f920
040000 tree 1d07791eee3c3dd0955a02402b05b3a357816d8d .github
100644 blob 1c0a1e94b7bbdd951f456cda51af6b8484cc3cee .gitignore
100644 blob d10c04c6e7e0014f4fe883599c11747c15012d4e README.md
040000 tree 7d0898a908e274ea809722844cdbd836f3b1c05a app
040000 tree f4f047dd07b128eda5f899dfdaaf193f0291eaa2 labs
040000 tree c0ac2d55cf4335df659b347df3d19d0594a06b6c lectures

$ git cat-file -t d10c04c6e7e0014f4fe883599c11747c15012d4e
blob

$ git cat-file -p d10c04c6e7e0014f4fe883599c11747c15012d4e | head -5
# DevOps Intro — Modern DevOps Practices Through One Project

[![Course](https://img.shields.io/badge/Course-DevOps%20Intro-blue)](#course-roadmap)
[![Project](https://img.shields.io/badge/Project-QuickNotes%20(Go)-success)](#the-project-quicknotes)
[![Duration](https://img.shields.io/badge/Duration-10%20Weeks-lightgrey)](#course-roadmap)
```

The commit stores metadata and points to the root tree. That tree maps names to
subtrees and blobs; the README blob stores the actual file bytes.

### Inside `.git`

The repository was inspected on Windows; the final command below is the
PowerShell equivalent that counts only loose object files.

```console
$ ls -la .git/
hooks/  info/  logs/  objects/  refs/
COMMIT_EDITMSG  config  description  FETCH_HEAD  HEAD  index  packed-refs

$ cat .git/HEAD
ref: refs/heads/main

$ ls .git/refs/heads/
feature/  main

$ ls .git/objects/ | head
0a  0c  0e  0f  13  1a  1d  27  38  3a

$ (Get-ChildItem -Recurse -File .git/objects |
    Where-Object { $_.Directory.Name -match '^[0-9a-f]{2}$' -and
                   $_.Name -match '^[0-9a-f]{38}$' }).Count
34
```

`HEAD` is a symbolic reference to the checked-out branch. Branch files under
`refs/heads` contain commit IDs, while loose objects are split into directories
named by the first two hexadecimal characters of their object IDs. Packfiles
may hold additional objects, so the loose-object count is not the total object
count of the repository.

### Destructive reset and recovery

Before the reset:

```text
* 51b5687 wip(lab2): more progress
* ce7fa72 wip(lab2): start
* f2c7c5c docs: add PR template
```

```console
$ git reset --hard HEAD~2
HEAD is now at f2c7c5c docs: add PR template

$ git status
On branch feature/lab2
nothing to commit, working tree clean

$ git reflog -8
f2c7c5c HEAD@{0}: reset: moving to HEAD~2
51b5687 HEAD@{1}: commit: wip(lab2): more progress
ce7fa72 HEAD@{2}: commit: wip(lab2): start
f2c7c5c HEAD@{3}: checkout: moving from main to feature/lab2
f2c7c5c HEAD@{4}: checkout: moving from feature/lab1 to main
3fbe896 HEAD@{5}: commit: docs(lab1): finish submission
4b26bf3 HEAD@{6}: commit: docs(lab1): start submission
f2c7c5c HEAD@{7}: checkout: moving from main to feature/lab1

$ git reset --hard 51b5687
HEAD is now at 51b5687 wip(lab2): more progress

$ git status
On branch feature/lab2
nothing to commit, working tree clean
```

The reset made the commits unreachable from the branch but the reflog still
retained their IDs. A normal immediate `git gc` generally respects reflog and
prune grace periods, so recovery would usually still work; aggressive GC or a
configuration such as immediate reflog expiry plus `git prune --expire=now`
could delete the unreachable objects permanently. Capturing the lost SHA before
experimentation is therefore important.

## Task 2 — Signed tag and rebased feature

### Signed annotated tag

```console
$ git tag -l 'v0.1.0-lab2-4rni4ka' --format='%(refname:short) %(objecttype) %(*objecttype)'
v0.1.0-lab2-4rni4ka tag commit

$ git tag -v v0.1.0-lab2-4rni4ka
object f2c7c5cd41f3089f545a8da4f09ea4d0b892b5d3
type commit
tag v0.1.0-lab2-4rni4ka
tagger Anastasiia Mikhelson <a.mikhelson@innopolis.university> 1789070346 +0500

Lab 2 milestone — version control deep dive
Good "git" signature for a.mikhelson@innopolis.university with ED25519 key SHA256:qAmJ3kpUCV9WcYg5PdEFfFrrlzE0FCCV6eNjYjGoKwQ
```

### Rebase

Before:

```text
* d155537 (origin/main, main) docs: upstream moved while you worked
| * 51b5687 (feature/lab2) wip(lab2): more progress
| * ce7fa72 wip(lab2): start
|/
* f2c7c5c (tag: v0.1.0-lab2-4rni4ka) docs: add PR template
```

After `git rebase origin/main`:

```text
* 926c8bc (feature/lab2) wip(lab2): more progress
* 4a47e01 wip(lab2): start
* d155537 (origin/main, main) docs: upstream moved while you worked
* f2c7c5c (tag: v0.1.0-lab2-4rni4ka) docs: add PR template
```

The two feature commits were replayed and received new IDs. The rebased branch
was published with `git push --force-with-lease origin feature/lab2`, which
protects against overwriting remote changes that were not seen locally.

I prefer rebase for a private feature branch when a clean, linear review story
is useful. I prefer merge for a shared branch when preserving the exact branch
topology and avoiding rewritten commit IDs matters more.

## Bonus — Bisect a real bug

```console
$ git bisect run pwsh -NoProfile -File C:/.../bisect-test.ps1
f285ede8611e55ac0a7d01100891c0cc775e0709 is the first bad commit

$ git bisect log
git bisect start
# bad: [f0c9243b7c80ebb930a1ce7048a1d65b4c2ac493] docs(app): mention go test invocation
git bisect bad f0c9243b7c80ebb930a1ce7048a1d65b4c2ac493
# good: [0ec87b808ae6a257a98ecea4a3c8d38a7f2c5ac7] chore(app): document versioning scheme (bisect fixture baseline)
git bisect good 0ec87b808ae6a257a98ecea4a3c8d38a7f2c5ac7
# bad: [f285ede8611e55ac0a7d01100891c0cc775e0709] refactor(store): simplify nextID restoration in load()
git bisect bad f285ede8611e55ac0a7d01100891c0cc775e0709
# good: [cb89bb9ee2ee5010b166061447eaca3ae0da2378] docs(store): comment the load() decode step
git bisect good cb89bb9ee2ee5010b166061447eaca3ae0da2378
# first bad commit: [f285ede8611e55ac0a7d01100891c0cc775e0709] refactor(store): simplify nextID restoration in load()
```

Offending commit: `f285ede8611e55ac0a7d01100891c0cc775e0709`
(`refactor(store): simplify nextID restoration in load()`). The automated test
reported `nextID not restored: got 1, want 2`. Bisect tests the midpoint and
discards half of the remaining interval after every result. There were four
candidate commits between the known-good tag and bad tip, so two test rounds
matched `log₂(4) = 2`, instead of checking all candidates sequentially.
