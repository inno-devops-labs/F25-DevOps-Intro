# Lab 2 submission

## Task 1 — Git Object Model and Recovery

### Git object model

Current commit:

```text
9f41b7deb32343a831b5e47c61533fbc7c0ce67d
```

Object type:

```text
commit
```

The commit points to the following tree:

```text
dc5bed5bbbbe3384cd66ce31edafc7afd1a77399
```

The tree contains, among other objects:

```text
100644 blob d10c04c6e7e0014f4fe883599c11747c15012d4e README.md
```

The object type of that SHA is:

```text
blob
```

Using `git cat-file -p`, the blob contents matched the contents of `README.md`.

### `.git` object storage

The repository contains both loose and packed Git objects.

```text
count: 67
size: 1168
in-pack: 220
packs: 1
size-pack: 547
prune-packable: 0
garbage: 0
size-garbage: 0
```

### Reflog recovery

Two signed commits were created:

```text
5fa7123 test: recovery commit 2
cc23840 test: recovery commit 1
```

After running:

```bash
git reset --hard HEAD~2
```

both commits disappeared from the normal branch history.

The reflog still contained them:

```text
9f41b7d HEAD@{0}: reset: moving to HEAD~2
5fa7123 HEAD@{1}: commit: test: recovery commit 2
cc23840 HEAD@{2}: commit: test: recovery commit 1
```

The commits were recovered with:

```bash
git reset --hard 5fa7123
```

After recovery:

```text
5fa7123 test: recovery commit 2
cc23840 test: recovery commit 1
9f41b7d docs(lab7): make seed.json shipping explicit; require bonus artifacts, not logs
```

`git reflog` records recent movements of references such as `HEAD`, so commits can often be recovered even after a hard reset. If `git gc` had already pruned the unreachable objects after their expiration period, reflog entries alone would not be enough because the underlying commit objects could already be deleted from the object database.

## Task 2 — Signed Tag and Rebase

### Signed tag

A signed annotated tag was created:

```text
v0.1.0-lab2-arinaagafonova
```

Verification output:

```text
Good "git" signature for agafonova_arina@icloud.com with ED25519 key SHA256:IrCUPC4DTS87Y/H7GEphaSNlZoYPZJH7jOFCI0C1SPY
```

The tag was pushed to the fork with:

```bash
git push origin "v0.1.0-lab2-$USER"
```

### Rebase

Before rebase:

```text
* e4e76ca (origin/main, origin/HEAD, main) docs: upstream moved while you worked
| * e02f206 (HEAD -> feature/lab2) docs(lab2): document git recovery
| * 5fa7123 test: recovery commit 2
| * cc23840 test: recovery commit 1
```

After rebase:

```text
* 03580ba (HEAD -> feature/lab2) docs(lab2): document git recovery
* ef26c9a test: recovery commit 2
* 4bc5b69 test: recovery commit 1
* e4e76ca (origin/main, origin/HEAD, main) docs: upstream moved while you worked
```

The feature branch was rebased onto the updated `origin/main`, so its commits were replayed on top of the latest main branch. Rebase keeps the history linear and avoids an extra merge commit, which makes the sequence of changes easier to read. Since rebase rewrites commit hashes, the branch was pushed using `git push --force-with-lease`, which is safer than a plain `--force` because it refuses to overwrite unexpected remote changes.