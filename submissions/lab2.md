# Lab 2 — Git Internals, Recovery, Tags, and Rebase

## Task 1.1 — Git object model

HEAD:
f9cd98f4a8ee5aaf577314f7990bab1f28d29740

HEAD object type:
commit

HEAD tree:
4e8941f4762188e39dde75dbbc42c9b8b0a2f920

README.md blob:
d10c04c6e7e0014f4fe883599c11747c15012d4e

Object chain:
HEAD -> tree -> blob -> README.md

The HEAD points to a commit object. The commit points to a tree containing the repository structure, and the README.md file is represented by a blob object.

## Task 1.2 — .git structure

.git/ contains HEAD, config, index, logs, objects, refs and other Git metadata.

.git/HEAD:
ref: refs/heads/main

Local branches:
feature
main

The .git/objects directory contains Git's stored objects. Objects are stored under directories named by the first two characters of their SHA.

Object files counted:
42

## Task 1.3 — Reflog recovery

First commit:
e64170f wip(lab2): start

Second commit:
2d91887 wip(lab2): more progress

The command `git reset --hard HEAD~2` moved HEAD back to f9cd98f and removed the two commits from the visible branch history.

The reflog still contained the previous commit:
2d91887 HEAD@{1}: commit: wip(lab2): more progress

Recovery was performed with:
git reset --hard 2d91887

The lost commit and its changes were successfully restored.

If git gc ran before recovery, unreachable Git objects could be pruned. In that case, the lost commits might no longer be recoverable through the reflog.

## Task 2.1 — Signed annotated tag

Tag:
v0.1.0-lab2-alsu

The tag is an annotated tag pointing to commit f9cd98f4a8ee5aaf577314f7990bab1f28d29740.

Verification:
Good "git" signature

The tag was pushed to origin successfully.

## Task 2.2 — Rebase

Before rebase, feature/lab2 contained:
2d91887 wip(lab2): more progress
e64170f wip(lab2): start

After rebase:
de6bc80 wip(lab2): more progress
5490cbd wip(lab2): start
0d0b4a6 docs: upstream moved while you worked

The rebase replayed the feature commits on top of the updated main branch. Their commit IDs changed because rebase creates new commit objects.

The branch was pushed using:
git push --force-with-lease origin feature/lab2

The rebase approach keeps the project history linear, while a merge preserves the original branch structure and creates a merge commit. Rebase can make history easier to read, but it rewrites commit history, so force-with-lease is needed when pushing a rebased branch.
