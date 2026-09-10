# Lab 2 submission

Author: Telman Nuruzov (`Telman3000`)
Branch: `feature/lab2`
Fork: https://github.com/Telman3000/DevOps-Intro
Tag: `v0.1.0-lab2-Telman3000`

---

## Task 1 — Git object model + reflog recovery

### 1.1 Plumbing chain: HEAD -> tree -> blob -> file

**`git rev-parse HEAD`** (on `main` at the time of exploration)

```text
f5d463e18a5a01e86b7c074f5934512a6876d5ae
```

**`git cat-file -t HEAD`**

```text
commit
```

**`git cat-file -p HEAD`**

```text
tree 79945d5f1a532e946415020e8f52050979f190c6
parent 9f41b7deb32343a831b5e47c61533fbc7c0ce67d
author Telman Nuruzov <telmannuruzov364@gmail.com> 1788986670 +0300
committer Telman Nuruzov <telmannuruzov364@gmail.com> 1788986670 +0300
gpgsig -----BEGIN SSH SIGNATURE-----
...
-----END SSH SIGNATURE-----

docs: add PR template

Signed-off-by: Telman Nuruzov <telmannuruzov364@gmail.com>
```

**`git cat-file -p 79945d5f1a532e946415020e8f52050979f190c6`** (tree)

```text
040000 tree e366152dd54f8a73bca079c23c3173f7a5d8ed6d    .github
100644 blob 1c0a1e94b7bbdd951f456cda51af6b8484cc3cee    .gitignore
100644 blob d10c04c6e7e0014f4fe883599c11747c15012d4e    README.md
040000 tree 7d0898a908e274ea809722844cdbd836f3b1c05a    app
040000 tree f4f047dd07b128eda5f899dfdaaf193f0291eaa2    labs
040000 tree c0ac2d55cf4335df659b347df3d19d0594a06b6c    lectures
```

**`git cat-file -p 1c0a1e94b7bbdd951f456cda51af6b8484cc3cee`** (blob = contents of `.gitignore`)

```text
# KEEP THIS FILE MINIMAL.
# ...
refs/
app/quicknotes
app/data/
...
```

Interpretation: a commit points at a tree; the tree lists entries that are either nested trees (directories) or blobs (file contents). Printing the blob SHA for `.gitignore` returns the exact file bytes stored in the object database.

### 1.2 Looking inside `.git/`

- `HEAD` contained `ref: refs/heads/main` (symbolic ref to the current branch).
- `refs/heads/` listed `main` and a `feature/` directory (branch tips are tiny files with commit SHAs).
- `objects/` is sharded by the first two hex digits of object IDs; loose object files lived under those subdirs.
- Loose object file count at exploration time: **79**.

### 1.3 Disaster simulation + reflog recovery

Created `feature/lab2` with two signed commits, then:

```text
git reset --hard HEAD~2
# HEAD moved to f5d463e — WIP commits disappeared from `git log`
```

**`git reflog` (relevant lines)**

```text
f5d463e HEAD@{0}: reset: moving to HEAD~2
978078f HEAD@{1}: commit: wip(lab2): more progress
680c834 HEAD@{2}: commit: wip(lab2): start
f5d463e HEAD@{3}: checkout: moving from main to feature/lab2
```

**Recovery**

```text
git reset --hard 978078f
HEAD is now at 978078f wip(lab2): more progress
```

After recovery, `submissions/lab2.md` again contained:

```text
important work
more important work
```

#### What if `git gc` ran before recovery?

Reflog entries and unreachable objects are not deleted immediately, but `git gc` (especially with aggressive pruning) can expire reflog entries and permanently remove dangling commits after the grace period. If GC had pruned `978078f` before recovery, `git reset --hard 978078f` would fail and the WIP history would be gone for good. That is why capturing the SHA from reflog quickly matters.

---

## Task 2 — Signed tag + rebase

### 2.1 Annotated signed tag

```text
git tag -a -s "v0.1.0-lab2-Telman3000" -m "Lab 2 milestone — version control deep dive"
git push origin "v0.1.0-lab2-Telman3000"
```

**`git tag -l --format=...`**

```text
v0.0.1 tag commit
v0.1.0-lab2-Telman3000 tag commit
```

**`git tag -v v0.1.0-lab2-Telman3000`**

```text
object f5d463e18a5a01e86b7c074f5934512a6876d5ae
type commit
tag v0.1.0-lab2-Telman3000
tagger Telman Nuruzov <telmannuruzov364@gmail.com> 1789040444 +0300

Lab 2 milestone — version control deep dive
Good "git" signature for telmannuruzov364@gmail.com with ED25519 key SHA256:D/h04PtvQMmjzUnLOj+qSeOLLrksAeYOk4PLy/FCJ0s
```

### 2.2 Rebase after main moved

**Before rebase**

```text
* 978078f wip(lab2): more progress
* 680c834 wip(lab2): start
* f5d463e docs: add PR template
```

Simulated upstream movement on fork `main`:

```text
git commit --trailer "Co-authored-by: Cursor <cursoragent@cursor.com>" -S -s --allow-empty -m "docs: upstream moved while you worked"
git push origin main
```

(Lab 1 branch protection initially blocked the push until the `main protection` ruleset was temporarily set to Disabled; after push it can be re-enabled.)

**After `git rebase origin/main`**

```text
* 8ee12a5 wip(lab2): more progress
* 6e4ad3a wip(lab2): start
* 0d5ab2c docs: upstream moved while you worked
* f5d463e docs: add PR template
```

Then:

```text
git push --force-with-lease origin feature/lab2
```

### Merge vs rebase

Merge preserves exact branch history and is safer for shared branches; rebase replays commits for a linear story and cleaner `git log --graph`. I would rebase private feature branches before opening a PR, and prefer merge (or avoid rewriting) once a branch is shared with others — which is also why this lab uses `--force-with-lease` instead of blind `--force`.

---

## Bonus — Bisect a real bug

Checked out `upstream/bug/bisect-me` as `bisect-quickn`, marked HEAD bad and `v0.0.1` good, then automated:

```text
git bisect run powershell -NoProfile -File bisect-run.ps1
# script: cd app; go test ./...; go build ./...
```

### `git bisect log`

```text
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

### Offending commit

- SHA: `f285ede8611e55ac0a7d01100891c0cc775e0709`
- Message: `refactor(store): simplify nextID restoration in load()`
- Symptom during bisect: `TestStore_PersistsAcrossReload` failed with `nextID not restored: got 1, want 2`

### Why log2(N) steps

Bisect is binary search over the commit range between a known-good and known-bad revision. Each step tests the midpoint and halves the remaining search space, so finding the first bad commit takes about `log2(N)` test runs for N commits in the range — far cheaper than linear blame through every commit when a regression appears.