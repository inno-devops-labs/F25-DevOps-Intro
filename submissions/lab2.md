# Lab 2 — Version Control Deep Dive

## Task 1 — Git Object Model and Reflog Recovery

### 1.1 Git Object Model

I inspected the Git object chain from HEAD to a tree and then to a blob.

```text
$ git rev-parse HEAD
9f41b7d...

$ git cat-file -t HEAD
commit

$ git cat-file -p HEAD
tree dc5bed5bbbbe3384cd66ce31edafc7afd1a77399
...

$ git cat-file -t dc5bed5bbbbe3384cd66ce31edafc7afd1a77399
tree

$ git cat-file -p dc5bed5bbbbe3384cd66ce31edafc7afd1a77399
100644 blob 1c0a1e94b7bbbd951f456cda51af6b8484c3cee .gitignore
100644 blob d10c04c6e7e0014f4fe883599c11747c15012d4e README.md
040000 tree 7d0898a908e274ea809722844cdbd836f3b1c05a app
040000 tree f4f047dd07b128eda5f899dfdaaf193f0291eaa2 labs
040000 tree c0ac2d55cf4335df659b347df3d19d0594a06b6c lectures

$ git cat-file -p HEAD:README.md
README.md contents were successfully read from the blob referenced by the HEAD tree.
```

A commit object references a tree object. The tree describes the repository contents and contains references to blobs and other trees. A blob stores the actual contents of a file.

### 1.2 Inside .git

I inspected the internal Git directory using:

```text
$ ls -la .git/
$ cat .git/HEAD
ref: refs/heads/feature/lab2

$ ls .git/refs/heads/
feature
main

$ ls .git/objects/ | head
```

The `.git` directory contains the repository metadata and object database. `HEAD` identifies the currently checked-out branch. `refs/heads` stores local branch references, while `.git/objects` contains Git objects addressed by their hashes.

### 1.3 Reflog Recovery

I created two signed commits:

```text
6a791b0 wip(lab2): start
971a7b8 wip(lab2): more progress
```

Then I deliberately removed them from the branch with:

```text
$ git reset --hard HEAD~2
HEAD is now at 9f41b7d docs(lab7): make seed.json shipping explicit; require bonus artifacts, not logs
```

The reflog still contained the previous positions of HEAD:

```text
9f41b7d HEAD@{0}: reset: moving to HEAD~2
971a7b8 HEAD@{1}: commit: wip(lab2): more progress
6a791b0 HEAD@{2}: commit: wip(lab2): start
```

I recovered the lost work using:

```text
$ git reset --hard 971a7b8
HEAD is now at 971a7b8 wip(lab2): more progress
```

After recovery, both commits were present again.

The reflog keeps local records of recent reference movements, so commits that are no longer reachable from a branch can still be recovered while their objects exist. If `git gc` had run and the unreachable objects had already expired and been pruned, the commits might have been permanently removed from the object database, making recovery through the reflog impossible.

## Task 2 — Tag Release and Rebase Feature

### 2.1 Signed Annotated Tag

I created and pushed the signed annotated tag:

```text
v0.1.0-lab2-lera
```

Verification:

```text
$ git tag -v "v0.1.0-lab2-${USER}"

Lab 2 milestone — version control deep dive
Good "git" signature
```

This confirms that the annotated milestone tag has a valid SSH signature.

### 2.2 Rebase

To simulate the main branch moving while I was working, I created a signed empty commit:

```text
$ git commit -S -s --allow-empty -m "docs: upstream moved while you worked"
[main 8b4481c] docs: upstream moved while you worked
```

Before the rebase, the feature commits were based on the older history:

```text
971a7b8 wip(lab2): more progress
6a791b0 wip(lab2): start
```

I rebased the feature branch onto `origin/main`:

```text
$ git rebase origin/main
Successfully rebased and updated refs/heads/feature/lab2.
```

After the rebase, the commits received new hashes:

```text
2da3d1d wip(lab2): more progress
548c88c wip(lab2): start
8b4481c docs: upstream moved while you worked
```

I then safely updated the remote feature branch with:

```text
$ git push --force-with-lease -u origin feature/lab2
```

`merge` preserves the histories of both branches and normally creates a merge commit. `rebase` rewrites the feature commits on top of the new base, producing a cleaner linear history. Because rebase changes commit hashes, I used `--force-with-lease` instead of `--force` so Git would refuse to overwrite unexpected remote changes.

## Bonus — Bisect a Real Bug

I fetched the provided buggy branch and started a bisect session using the known bad HEAD and known good `v0.0.1` tag.

The automated test command was:

```text
$ git bisect run sh -c 'cd app && go test ./... && go build ./...'
```

The failing test included:

```text
--- FAIL: TestStore_PersistsAcrossReload
store_test.go:78: nextID not restored: got 1, want 2
```

Git bisect identified the first bad commit as:

```text
f285ede8611e55ac0a7d01100891c0cc775e0709
refactor(store): simplify nextID restoration in load()
```

Bisect log:

```text
git bisect start
# status: waiting for both 'good' and 'bad' commits
# bad: [f0c9243b7c80ebb930a1ce7048a1d65b4c2ac493] docs(app): mention go test invocation
git bisect bad f0c9243b7c80ebb930a1ce7048a1d65b4c2ac493
# status: waiting for 'good' commit(s), bad commit known
# good: [0ec87b808ae6a257a98ecea4a3c8d38a7f2c5ac7] chore(app): document versioning scheme (bisect fixture baseline)
git bisect good 0ec87b808ae6a257a98ecea4a3c8d38a7f2c5ac7
# bad: [f285ede8611e55ac0a7d01100891c0cc775e0709] refactor(store): simplify nextID restoration in load()
git bisect bad f285ede8611e55ac0a7d01100891c0cc775e0709
# good: [cb89bb9ee2ee5010b166061447eaca3ae0da2378] docs(store): comment the load() decode step
git bisect good cb89bb9ee2ee5010b166061447eaca3ae0da2378
# first bad commit: [f285ede8611e55ac0a7d01100891c0cc775e0709] refactor(store): simplify nextID restoration in load()
```

Git bisect uses binary search. At every step it approximately halves the remaining range of candidate commits. Therefore, instead of checking all N commits one by one, it needs approximately log2(N) test steps. This makes it much faster for locating a regression in a long commit history.

Finally, I returned the repository to its original state with:

```text
$ git bisect reset
```