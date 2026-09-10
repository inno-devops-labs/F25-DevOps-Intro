# Lab 2 Submission

## Task 1.1 — Object Model Chain (HEAD → tree → blob → file)

### git rev-parse HEAD

5690a67a300f1e8e861fe6da9c69323fa14e2757


### git cat-file -t HEAD

commit


### git cat-file -p HEAD

tree 4e8941f4762188e39dde75dbbc42c9b8b0a2f920
parent 9f41b7deb32343a831b5e47c61533fbc7c0ce67d
author Ilia Kulichenko qumcom720@gmail.com 1789064503 +0300
committer Ilia Kulichenko qumcom720@gmail.com 1789064503 +0300
gpgsig -----BEGIN SSH SIGNATURE-----
...
-----END SSH SIGNATURE-----

docs: add PR template

Signed-off-by: Ilia Kulichenko qumcom720@gmail.com


### git cat-file -p <TREE_SHA> (4e8941f4762188e39dde75dbbc42c9b8b0a2f920)

040000 tree 1d07791eee3c3dd0955a02402b05b3a357816d8d .github
100644 blob 1c0a1e94b7bbdd951f456cda51af6b8484cc3cee .gitignore
100644 blob d10c04c6e7e0014f4fe883599c11747c15012d4e README.md
040000 tree 7d0898a908e274ea809722844cdbd836f3b1c05a app
040000 tree f4f047dd07b128eda5f899dfdaaf193f0291eaa2 labs
040000 tree c0ac2d55cf4335df659b347df3d19d0594a06b6c lectures


### git cat-file -p <BLOB_SHA> (d10c04c6e7e0014f4fe883599c11747c15012d4e — README.md)
DevOps Intro — Modern DevOps Practices Through One Project

A 10-week practical introduction to DevOps at Innopolis University...
(full README content — truncated here for brevity)


### Interpretation
The commit object stores a pointer to one tree (the project's root snapshot), a pointer to its parent commit, author/committer metadata, an SSH signature, and the commit message. The tree lists every file and subfolder at that snapshot, each as either a `blob` (file content) or another `tree` (subfolder). Following `README.md`'s blob SHA reveals the exact raw bytes of that file at this commit — Git stores content-addressed by SHA-1 hash of the content itself, so identical file content anywhere in history shares the same blob.

## Task 1.2 — Inside .git/

### ls -la .git/

COMMIT_EDITMSG config description FETCH_HEAD HEAD hooks/
index info/ logs/ objects/ packed-refs refs/


### cat .git/HEAD

ref: refs/heads/feature/lab2


### ls .git/refs/heads/

feature main


### ls .git/objects/ | head

00
0a
0c
0e
0f
11
13
1a
1d
27


### find .git/objects -type f | wc -l

41


### Interpretation
`.git/HEAD` is a pointer to a pointer — it holds a reference like `refs/heads/feature/lab2`, and that ref file (under `.git/refs/heads/`) holds the actual commit SHA the branch currently points to. This indirection is what makes `git switch` cheap — moving branches just rewrites a few bytes in `HEAD`. The `objects/` directory is Git's content-addressable store: every commit, tree, and blob is saved as a "loose object" in a folder named after the first two characters of its SHA-1 hash, sharding storage to keep any one directory from holding too many files. Currently there are 41 loose objects — every commit, tree, and blob created so far across both labs, none of them compacted into a packfile yet.


## Task 1.3 — Disaster Recovery via Reflog

### git reflog (showing HEAD movements)

5690a67 (HEAD -> feature/lab2, origin/main, origin/HEAD, main) HEAD@{0}: reset: moving to HEAD~2
d68077c HEAD@{1}: commit: wip(lab2): more progress
5c8f6e6 HEAD@{2}: commit: wip(lab2): start
5690a67 (HEAD -> feature/lab2, origin/main, origin/HEAD, main) HEAD@{3}: checkout: moving from main to feature/lab2
5690a67 (HEAD -> feature/lab2, origin/main, origin/HEAD, main) HEAD@{4}: checkout: moving from feature/lab1 to main
6f7bc25 (origin/feature/lab1, feature/lab1) HEAD@{5}: commit: docs(lab1): complete task 3
d13cd00 HEAD@{6}: commit: docs(lab1): finish submission
c186e9a HEAD@{7}: checkout: moving from main to feature/lab1
5690a67 (HEAD -> feature/lab2, origin/main, origin/HEAD, main) HEAD@{8}: commit: docs: add PR template
9f41b7d (upstream/main, upstream/HEAD) HEAD@{9}: checkout: moving from feature/lab1 to main


### Recovery command

$ git reset --hard d68077c
HEAD is now at d68077c wip(lab2): more progress


### Verification

d68077c (HEAD -> feature/lab2) wip(lab2): more progress
5c8f6e6 wip(lab2): start
5690a67 (origin/main, origin/HEAD, main) docs: add PR template


### What if git gc had run between the bad reset and recovery?

`git reset --hard` only moves branch/HEAD pointers — it doesn't delete the underlying commit objects, so they remain recoverable via `reflog` as "dangling" commits. However, `git gc` periodically prunes objects that are unreachable from any ref and older than the `gc.pruneExpire` window (default 2 weeks) or when the reflog entry itself expires (default 90 days for reachable, 30 days for unreachable tips). If `git gc --aggressive` or a manual `git gc --prune=now` had run in that window, the dangling commits could be garbage collected and permanently lost before the reflog entry pointing to them was used — meaning the reflog is a safety net, but not an infinite one.


## Task 2.1 — Signed Annotated Tag

### Tag type verification

v0.0.1 tag commit
v0.1.0-lab2-kulichcom tag commit


### Signature verification (git tag -v)

object 5690a67a300f1e8e861fe6da9c69323fa14e2757
type commit
tag v0.1.0-lab2-kulichcom
tagger Ilia Kulichenko qumcom720@gmail.com 1789067419 +0300

Lab 2 milestone — version control deep dive
Good "git" signature for qumcom720@gmail.com with ED25519 key SHA256:pZWx6J6g/ZNH5KiztrcpMDzZz2EZescxvMwt9Vzwxjs


## Task 2.2 — Rebase + force-with-lease

### Before rebase (reflog evidence)
Prior to rebase, `feature/lab2` contained two commits (`5c8f6e6`, `d68077c`) branched directly off `5690a67`. Meanwhile `main` advanced with an empty commit `ca36d3b` simulating upstream progress.

### After rebase
a281224 (HEAD -> feature/lab2, origin/feature/lab2) wip(lab2): more progress
44f0526 wip(lab2): start
ca36d3b (origin/main, origin/HEAD, main) docs: upstream moved while you worked
5690a67 (tag: v0.1.0-lab2-kulichcom) docs: add PR template
9f41b7d (upstream/main, upstream/HEAD) docs(lab7): make seed.json shipping explicit; require bonus artifacts, not logs

Rebase replayed both `wip(lab2)` commits (new SHAs `44f0526`, `a281224` — rebase always creates new commit objects since the parent changed) on top of the updated `main`, producing a clean linear history with no merge commit. Pushed safely with `--force-with-lease`, which refuses the push if the remote branch moved unexpectedly since your last fetch — protecting against silently overwriting a collaborator's work, unlike plain `--force`.

### Merge vs rebase — when I'd choose each

I'd use **rebase** on a personal feature branch before opening a PR, to keep history linear and make the final diff easy to review — nobody else depends on those commits yet, so rewriting SHAs is safe. I'd use **merge** once a branch is shared or already reviewed, or when preserving the exact chronological record of parallel work matters (e.g., a release branch), since merge never rewrites existing commits and is safe even if others have already pulled the branch.
