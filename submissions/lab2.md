# Lab 2

## Task 1.1

### `git rev-parse HEAD`

```text
c833384d809321c42bd697f33a30c95ba6a3bc74
```

### `git cat-file -t HEAD`

```text
commit
```

### `git cat-file -p HEAD`

```text
tree 8f99f3f2471b6241a238154eebbbe0a14f54e41b
parent b1da0624f1c15ad27e7cdaca46cfb2edfebc2872
author AyazN <voridanaya@gmail.com> 1789079380 +0300
committer AyazN <voridanaya@gmail.com> 1789079380 +0300
gpgsig -----BEGIN SSH SIGNATURE-----
 U1NIU0lHAAAAAQAAADMAAAALc3NoLWVkMjU1MTkAAAAgrdVxCubEy+ryos03VM6pJHNU16
 /P6ScYbu20i5A5yycAAAADZ2l0AAAAAAAAAAZzaGE1MTIAAABTAAAAC3NzaC1lZDI1NTE5
 AAAAQC6dn6UntQNYeJicLsKfSbXfuwOAn5MX7I4qBg9Vq7H69MN/Uf5EehjO/sjfHJzb/q
 ga7Wtb2HDxwRqJqlf5Ag0=
 -----END SSH SIGNATURE-----

docs(lab1): finish submission

Signed-off-by: AyazN <voridanaya@gmail.com>
```

### `git cat-file -p 8f99f3f2471b6241a238154eebbbe0a14f54e41b`

```text
100644 blob 1c0a1e94b7bbdd951f456cda51af6b8484cc3cee    .gitignore
100644 blob d10c04c6e7e0014f4fe883599c11747c15012d4e    README.md
040000 tree 7d0898a908e274ea809722844cdbd836f3b1c05a    app
040000 tree f4f047dd07b128eda5f899dfdaaf193f0291eaa2    labs
040000 tree c0ac2d55cf4335df659b347df3d19d0594a06b6c    lectures
040000 tree 7827bbf78a09e276a6bffc5308175e6c30d75d48    submissions
```

### `git cat-file -p d10c04c6e7e0014f4fe883599c11747c15012d4e`

```text
# DevOps Intro — Modern DevOps Practices Through One Project

[![Course](https://img.shields.io/badge/Course-DevOps%20Intro-blue)](#course-roadmap)
[![Project](https://img.shields.io/badge/Project-QuickNotes%20(Go)-success)](#the-project-quicknotes)
[![Duration](https://img.shields.io/badge/Duration-10%20Weeks-lightgrey)](#course-roadmap)
[![Grading](https://img.shields.io/badge/Grading-70--14--5--30--30-orange)](#grading)

A 10-week practical introduction to DevOps at Innopolis University. You will package, ship, observe, harden, and deploy **one** Go service — QuickNotes — across every lab. The discipline you learn here is the spine of modern production engineering.
```

## Task 1.2

### `ls -la .git/`

```text
hooks
info
logs
objects
refs
COMMIT_EDITMSG
config
description
FETCH_HEAD
HEAD
ORIG_HEAD
index
packed-refs
```

### `cat .git/HEAD`

```text
ref: refs/heads/feature/lab1
```

### `ls .git/refs/heads/`

```text
feature
main
```

### `ls .git/objects/ | head`

```text
06
0a
0c
0d
0e
0f
11
13
1a
3a
```

### `find .git/objects -type f | wc -l`

```text
56
```

**Interpretation:** `.git/` contains Git's repository metadata, references, logs, and object database. `HEAD` points to the current `feature/lab1` branch, and the `objects` directory stores Git objects addressed by SHA.

## 1.3: Reflog and Recovery

### `git reflog`

```text
4fafb38 (HEAD -> feature/lab2, main) HEAD@{0}: reset: moving to HEAD~2
402c9f3 HEAD@{1}: commit: docs(lab2): add git internals notes
5f8e2ba HEAD@{2}: commit: docs(lab2): add git object inspection
4fafb38 (HEAD -> feature/lab2, main) HEAD@{3}: checkout: moving from main to feature/lab2
4fafb38 (HEAD -> feature/lab2, main) HEAD@{4}: checkout: moving from feature/lab1 to main
```

### Recovery

```text
git reset --hard 402c9f3
```

Output:

```text
HEAD is now at 402c9f3 docs(lab2): add git internals notes
```

If `git gc` had run before recovery, Git could have pruned the unreachable commits created by the reset. In that case, the reflog entry might still exist, but the commit objects could have been deleted, making recovery impossible through the reflog alone.

## Task 2 — Tag a Release & Rebase a Feature

### 2.1: Annotated, signed release tag

```text
v0.0.1 QuickNotes v0.0.1 — known-good baseline for the Lab 2 bisect exercise
v0.1.0-lab2-vorid Lab 2 release

object 4fafb3866c4e47f608dcf8f704c8ff24b7c51de5
type commit
tag v0.1.0-lab2-vorid
tagger AyazN <voridanaya@gmail.com> 1789083005 +0300

Lab 2 release
Good "git" signature for voridanaya@gmail.com with ED25519 key SHA256:NfNJWE1NIuw6ZnpMCLF+RXruNuQSg3VsvRMVAI41MNc
```

The signed annotated tag was pushed to `origin`.

### 2.2: Rebase + force-with-lease

#### Before rebase

```text
* 1069bfe (main) chore: simulate upstream movement
| * bc042db (HEAD -> feature/lab2) docs(lab2): document reflog recovery
| * 402c9f3 docs(lab2): add git internals notes
| * 5f8e2ba docs(lab2): add git object inspection
|/
| * c833384 (origin/feature/lab1, feature/lab1) docs(lab1): finish submission
| * b1da062 docs(lab1): finish submission
| * 83ea442 docs(lab1): finish submission
```

#### Rebase

```text
Successfully rebased and updated refs/heads/feature/lab2.
```

#### After rebase

```text
* 60a790b (HEAD -> feature/lab2) docs(lab2): document reflog recovery
* 18b5507 docs(lab2): add git internals notes
* ec14f2e docs(lab2): add git object inspection
* 84fd2fc (origin/main, origin/HEAD, main) chore: simulate upstream movement
* 9a0cb1d chore: simulate upstream movement
* e7ae82a test: unsigned commit
* 4fafb38 (tag: v0.1.0-lab2-vorid) docs: add PR template
```

The rebased branch was pushed using:

```text
git push --force-with-lease origin feature/lab2
```

Merge is preferable when preserving the exact existing branch history is important or when collaborating on a shared branch. Rebase is preferable for a private feature branch when a clean, linear history is desired before merging.

## Bonus: Git Bisect

### `git bisect log`

```text
git bisect start
# status: waiting for both 'good' and 'bad' commits
# bad: [f0c9243b7c80ebb930a1ce7048a1d65b4c2ac493] docs(app): mention go test invocation
git bisect bad f0c9243b7c80ebb930a1ce7048a1d65b4c2ac493
# status: waiting for 'good' commit(s), 'bad' commit known
# good: [0ec87b808ae6a257a98ecea4a3c8d38a7f2c5ac7] chore(app): document versioning scheme (bisect fixture baseline)
git bisect good 0ec87b808ae6a257a98ecea4a3c8d38a7f2c5ac7
# bad: [f285ede8611e55ac0a7d01100891c0cc775e0709] refactor(store): simplify nextID restoration in load()
git bisect bad f285ede8611e55ac0a7d01100891c0cc775e0709
# good: [cb89bb9ee2ee5010b166061447eaca3ae0da2378] docs(store): comment the load() decode step
git bisect good cb89bb9ee2ee5010b166061447eaca3ae0da2378
# first 'bad' commit: [f285ede8611e55ac0a7d01100891c0cc775e0709] refactor(store): simplify nextID restoration in load()
```

### Offending commit

```text
f285ede8611e55ac0a7d01100891c0cc775e0709
refactor(store): simplify nextID restoration in load()
```

### Explanation

Git bisect starts with a known good commit and a known bad commit, then tests a commit near the middle of the range. The first tested commit, `f285ede`, was bad because `TestStore_PersistsAcrossReload` failed. Git then tested `cb89bb9`, which was good, narrowing the range to the offending commit. With `N` commits, binary search requires approximately `log₂(N)` tests, so bisect efficiently identified `f285ede` as the first bad commit.


