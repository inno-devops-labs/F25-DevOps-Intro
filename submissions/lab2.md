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
