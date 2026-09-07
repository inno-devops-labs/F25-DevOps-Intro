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