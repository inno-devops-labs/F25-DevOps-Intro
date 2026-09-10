# Lab 2 — Version Control Deep Dive: Internals, Recovery, Rebase

**Student:** Sophiia Sultanova  
**Email:** sultanova2202@gmail.com  
**GitHub:** [@fsstilerr](https://github.com/fsstilerr)  
**Environment:** macOS 26.6.2, git 2.55.0, Go 1.27.1 darwin/arm64

---

## Task 1 — Git Object Model and Reflog Recovery

### 1.1 One full chain: HEAD to tree to blob to file

```plaintext
$ git rev-parse HEAD
19b202059ba8f2363fcfdb4d3f7f5119a995cbd4

$ git cat-file -t HEAD
commit

$ git cat-file -p HEAD
tree 015db5b0f4f2ecd1ca96f927884a6b5c8ce3a53c
parent fbfcc3941d2ff1bb543c521383995e9d9e3f883e
author SophiiaSultanova <sultanova2202@gmail.com> 1789071422 +0300
committer SophiiaSultanova <sultanova2202@gmail.com> 1789071422 +0300
gpgsig -----BEGIN SSH SIGNATURE-----
 U1NIU0lHAAAAAQAAADMAAAALc3NoLWVkMjU1MTkAAAAgIVaSuy/g57dq5rC/QQA6pCHLfD
 AuPU9h+KRrUWmB/D8AAAADZ2l0AAAAAAAAAAZzaGE1MTIAAABTAAAAC3NzaC1lZDI1NTE5
 AAAAQPYZxN7/kx9jeySCmoIm6b3zNsiIOhRxujZMliXreqtfJJX2W2nntDlVQgZ0AuGs89
 etOqrD45duxky5OJiPswM=
 -----END SSH SIGNATURE-----

chore: verify signed push still works

Signed-off-by: SophiiaSultanova <sultanova2202@gmail.com>

$ git cat-file -p 015db5b0f4f2ecd1ca96f927884a6b5c8ce3a53c
040000 tree 4718e71bbbfe37e3d846cecbb1c43cf72b4fa94d    .github
100644 blob 1c0a1e94b7bbdd951f456cda51af6b8484cc3cee    .gitignore
100644 blob d10c04c6e7e0014f4fe883599c11747c15012d4e    README.md
040000 tree 7d0898a908e274ea809722844cdbd836f3b1c05a    app
040000 tree f4f047dd07b128eda5f899dfdaaf193f0291eaa2    labs
040000 tree c0ac2d55cf4335df659b347df3d19d0594a06b6c    lectures

$ git cat-file -t d10c04c6e7e0014f4fe883599c11747c15012d4e
blob

$ git cat-file -s d10c04c6e7e0014f4fe883599c11747c15012d4e
13033

$ git cat-file -p d10c04c6e7e0014f4fe883599c11747c15012d4e | head -5
# DevOps Intro — Modern DevOps Practices Through One Project
[![Course](https://img.shields.io/badge/Course-DevOps%20Intro-blue)](#course-roadmap)
[![Project](https://img.shields.io/badge/Project-QuickNotes%20(Go)-success)](#the-project-quicknotes)
[![Duration](https://img.shields.io/badge/Duration-10%20Weeks-lightgrey)](#course-roadmap)
```

Three object types form one chain. The commit stores the tree SHA, the parent SHA,
author and committer metadata, the commit message, and the SSH signature configured
in Lab 1. The tree maps filenames and modes to object SHAs. The blob contains only
file contents.

> The blob itself carries no filename. `README.md` exists as an entry in the tree
> that points to blob `d10c04c6...`. The SSH signature is visible inside the commit
> object as the `gpgsig` header, so it is part of the data hashed into the commit.

### 1.2 Inside `.git/`

```plaintext
$ ls -la .git/
total 64
drwxr-xr-x  15 sophiyasultanova  staff   480 Sep 11 02:17 .
drwxr-xr-x  11 sophiyasultanova  staff   352 Sep 11 02:11 ..
-rw-r--r--   1 sophiyasultanova  staff    97 Sep 11 02:06 COMMIT_EDITMSG
-rw-r--r--   1 sophiyasultanova  staff   588 Sep 11 02:09 FETCH_HEAD
-rw-r--r--   1 sophiyasultanova  staff    29 Sep 11 02:17 HEAD
-rw-r--r--   1 sophiyasultanova  staff    41 Sep 11 02:09 ORIG_HEAD
-rw-r--r--   1 sophiyasultanova  staff   508 Sep 11 02:11 config
-rw-r--r--   1 sophiyasultanova  staff    73 Sep 10 22:41 description
drwxr-xr-x  16 sophiyasultanova  staff   512 Sep 10 22:41 hooks
-rw-r--r--   1 sophiyasultanova  staff  3307 Sep 11 02:17 index
drwxr-xr-x   3 sophiyasultanova  staff    96 Sep 10 22:41 info
drwxr-xr-x   4 sophiyasultanova  staff   128 Sep 10 22:41 logs
drwxr-xr-x  32 sophiyasultanova  staff  1024 Sep 11 02:09 objects
-rw-r--r--   1 sophiyasultanova  staff   499 Sep 10 22:41 packed-refs
drwxr-xr-x   6 sophiyasultanova  staff   192 Sep 11 02:10 refs

$ cat .git/HEAD
ref: refs/heads/main

$ ls .git/refs/heads/
feature
main

$ ls .git/objects/
01
17
19
20
27
31
38
3d
47
5c
6e
c4
ca
d3
d9
dd
fb
info
pack

$ find .git/objects -type f | wc -l
      21

$ find .git/objects -type f -not -path "*pack*" | wc -l
      18

$ git count-objects -vH
count: 18
size: 220.00 KiB
in-pack: 242
packs: 1
size-pack: 552.09 KiB
prune-packable: 0
garbage: 0
size-garbage: 0 bytes
```

`.git/HEAD` is a symbolic reference to `refs/heads/main`. The files under
`.git/refs/heads/` are branch references, so a branch is fundamentally a name
pointing at a commit.

The raw file count under `.git/objects/` is not the same as the logical Git object
count because packfiles contain many objects inside a small number of files. Here
`git count-objects -vH` reports 18 loose objects plus 242 packed objects in one pack.

After creating the two signed Lab 2 work commits, the loose object count increased
from 18 to 26:

```plaintext
count: 26
size: 252
```

Objects received from a remote are normally packed and delta-compressed, while new
objects created locally are often written loose first and packed later by `git gc`.

### 1.3 Destroying and recovering work

Two signed commits were created on `feature/lab2`:

```plaintext
[feature/lab2 fe18ab2] wip(lab2): start
 1 file changed, 1 insertion(+)
 create mode 100644 submissions/lab2.md

[feature/lab2 d3aa42c] wip(lab2): more progress
 1 file changed, 1 insertion(+)
```

Then both were deliberately removed from the visible branch history with:

```bash
git reset --hard HEAD~2
```

The reflog still contained them:

```plaintext
19b2020 HEAD@{0}: reset: moving to HEAD~2
d3aa42c HEAD@{1}: commit: wip(lab2): more progress
fe18ab2 HEAD@{2}: commit: wip(lab2): start
19b2020 HEAD@{3}: checkout: moving from main to feature/lab2
19b2020 HEAD@{4}: checkout: moving from feature/lab1 to main
20b4587 HEAD@{5}: commit: docs(lab1): finish submission
d9c5541 HEAD@{6}: checkout: moving from feature/lab1 to feature/lab1
d9c5541 HEAD@{7}: checkout: moving from feature/lab1 to feature/lab1
d9c5541 HEAD@{8}: checkout: moving from main to feature/lab1
19b2020 HEAD@{9}: commit: chore: verify signed push still works
```

Recovery used the reflog entry for the second work commit:

```bash
LOST=$(git rev-parse 'HEAD@{1}')
git reset --hard "$LOST"
```

Result:

```plaintext
HEAD is now at d3aa42c wip(lab2): more progress

d3aa42c (HEAD -> feature/lab2) wip(lab2): more progress
fe18ab2 wip(lab2): start
19b2020 (main) chore: verify signed push still works
```

The recovered file contained both lines:

```plaintext
important work
more important work
```

`git log` stopped showing the commits after the hard reset because the branch
pointer moved. The commit objects were still present; the reflog recorded the old
positions of `HEAD`, which made the lost commit SHA recoverable.

### What if `git gc` had run in between

After the reset, the two commits were unreachable from the current branch but still
referenced by the reflog. A normal `git gc` does not immediately delete them because
Git keeps reflog-referenced unreachable objects for a grace period. The default
`gc.reflogExpireUnreachable` period is 30 days.

Aggressive cleanup such as expiring reflog entries and then running
`git gc --prune=now` can remove unreachable objects permanently. The practical rule
is to recover or record the SHA from the reflog before aggressive cleanup.

---

## Task 2 — Signed Tag and Rebase

### 2.1 Annotated and signed tag

The first tag attempt exposed an environment-variable mistake: `$GH_USER` was empty,
so Git created `v0.1.0-lab2-`. That incorrect tag was deleted locally and remotely
and then recreated with the actual GitHub username.

Final annotated-tag proof:

```plaintext
$ git tag -l --format='%(refname:short) %(objecttype) %(*objecttype)' | grep lab2
v0.1.0-lab2-fsstilerr tag commit
```

Final signature verification:

```plaintext
$ git tag -v v0.1.0-lab2-fsstilerr

object 19b202059ba8f2363fcfdb4d3f7f5119a995cbd4
type commit
tag v0.1.0-lab2-fsstilerr
tagger SophiiaSultanova <sultanova2202@gmail.com> 1789081698 +0300

Lab 2 milestone: version control deep dive

Good "git" signature for namespaces=git with ED25519 key SHA256:CTSiduWnTTyQUyw/FHZ94PD7ZJSArorlSL+STBbsmlc
```

The corrected tag was pushed successfully:

```plaintext
To https://github.com/fsstilerr/DevOps-Intro.git
 * [new tag]         v0.1.0-lab2-fsstilerr -> v0.1.0-lab2-fsstilerr
```

An annotated tag is a Git object of type `tag` that points to another object, in
this case commit `19b202059...`. Unlike a lightweight tag, it can store a tagger
identity, a message, and a cryptographic signature.

For the lab's upstream synchronization step:

```plaintext
$ git pull --ff-only upstream main
From github.com:inno-devops-labs/DevOps-Intro
 * branch            main       -> FETCH_HEAD
Already up to date.
```

So no merge or fast-forward was required at that moment.

### 2.2 Rebase

Before the first rebase:

```plaintext
* 6fe5512 docs: upstream moved while you worked
* 51abc24 docs: upstream moved while you worked
| * d3aa42c wip(lab2): more progress
| * fe18ab2 wip(lab2): start
| * 19b2020 chore: verify signed push still works
|/
| * 20b4587 docs(lab1): finish submission
| * d9c5541 docs(lab1): start submission
|/
* fbfcc39 docs: add PR template
```

The branch was rebased onto the current fork `main`. The first rebase also
replayed an unrelated Lab 1 test commit because it was part of the branch's
ancestry. Before final submission, the feature branch was cleaned so that only
the two Lab 2 work commits remained on top of `origin/main`.

Final graph:

```plaintext
* de121af (HEAD -> feature/lab2, origin/feature/lab2) wip(lab2): more progress
* 0fbf141 wip(lab2): start
* 6fe5512 (origin/main, origin/HEAD, main) docs: upstream moved while you worked
* 51abc24 docs: upstream moved while you worked
| * 20b4587 (origin/feature/lab1, feature/lab1) docs(lab1): finish submission
| * d9c5541 docs(lab1): start submission
|/
| * 19b2020 (tag: v0.1.0-lab2-fsstilerr) chore: verify signed push still works
|/
* fbfcc39 docs: add PR template
```

The original Lab 2 work commits were:

```plaintext
fe18ab2 wip(lab2): start
d3aa42c wip(lab2): more progress
```

After the history rewrite, the final Lab 2 commits are:

```plaintext
0fbf141 wip(lab2): start
de121af wip(lab2): more progress
```

They kept their messages and contents but received new SHAs because a commit
hash includes its parent relationship. Rebasing therefore creates new commit
objects rather than moving the old ones.

Both final commits have valid SSH signatures:

```plaintext
$ git log --show-signature --format='%h %s' origin/main..feature/lab2

Good "git" signature for namespaces=git with ED25519 key SHA256:CTSiduWnTTyQUyw/FHZ94PD7ZJSArorlSL+STBbsmlc

de121af wip(lab2): more progress

Good "git" signature for namespaces=git with ED25519 key SHA256:CTSiduWnTTyQUyw/FHZ94PD7ZJSArorlSL+STBbsmlc

0fbf141 wip(lab2): start
```

> Rebasing re-creates commits. With `commit.gpgsign` enabled globally, replayed
> commits were signed again automatically. The final verification above confirms
> that both commits in `feature/lab2` are signed.

The rewritten feature branch was pushed with:

```bash
git push --force-with-lease origin feature/lab2
```

`--force-with-lease` is safer than plain `--force` because it refuses to
overwrite the remote branch if it has moved unexpectedly since the local
repository last observed it.

A direct signed push to protected `main` was also tested. With owner bypass
disabled GitHub rejected it:

```plaintext
remote: error: GH006: Protected branch update failed for refs/heads/main.
remote:
remote: - Changes must be made through a pull request.
To https://github.com/fsstilerr/DevOps-Intro.git
 ! [remote rejected] main -> main (protected branch hook declined)
error: failed to push some refs to 'https://github.com/fsstilerr/DevOps-Intro.git'
```

After owner bypass was allowed, the push succeeded while GitHub still reported
the rule violation:

```plaintext
remote: Bypassed rule violations for refs/heads/main:
remote:
remote: - Changes must be made through a pull request.
To https://github.com/fsstilerr/DevOps-Intro.git
   51abc24..6fe5512  main -> main
```

This confirms that the earlier rejection came from the pull-request protection
rule rather than from an invalid commit signature.

### When to merge and when to rebase

Rebase is appropriate while preparing a feature branch for review, especially when
the goal is a clean linear sequence on top of current `main`. It rewrites commit
identities, so it should be used carefully once other developers may depend on the
published SHAs.

Merge is safer for shared history because it preserves existing commit identities
and records that two lines of development were integrated. A practical rule is:
rebase to prepare private or controlled feature work; merge to integrate shared
history.

---

## Bonus Task — Bisecting a Real Bug

### Bisect log

```plaintext
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

The automated command was:

```bash
git bisect run sh -c 'cd app && go test ./... && go build ./...'
```

The failing test was:

```plaintext
--- FAIL: TestStore_PersistsAcrossReload (0.00s)
    store_test.go:78: nextID not restored: got 1, want 2
FAIL
FAIL    quicknotes    0.290s
FAIL
```

Git identified:

```plaintext
f285ede8611e55ac0a7d01100891c0cc775e0709 is the first 'bad' commit
```

### The offending commit

`f285ede8611e55ac0a7d01100891c0cc775e0709` — *refactor(store): simplify nextID
restoration in load()*

```diff
    for _, n := range notes {
        s.notes[n.ID] = n
-       if n.ID >= s.nextID {
+       if n.ID > s.nextID {
            s.nextID = n.ID + 1
        }
    }
```

`nextID` starts at 1. If a stored note has `id == 1`, the new condition `1 > 1`
is false, so `nextID` is not advanced. The next note created after reload can reuse
ID 1 instead of continuing with ID 2. `TestStore_PersistsAcrossReload` detects this
exactly:

```plaintext
store_test.go:78: nextID not restored: got 1, want 2
```

### Why log2(N)

`git bisect` applies binary search to the commit range between a known good and a
known bad point. Every good/bad verdict eliminates roughly half of the remaining
candidates, so the number of tests grows approximately as `log2(N)` rather than
`N`.

For example, 1,000 candidate commits require about 10 verdicts in the ideal case
because `2^10 = 1024`; around one million require about 20. In this lab the marked
range was narrowed to `f285ede` after only a small number of test executions.

The practical cost is dominated by the test itself, so the best command for
`git bisect run` is the cheapest reliable test that clearly distinguishes good
revisions from bad ones.

---

## Summary

| Task | Deliverable | Status |
|------|-------------|--------|
| Task 1 | Object chain, `.git/` interpretation, reflog recovery, gc analysis | Done |
| Task 2 | Signed annotated tag verified, rebase before/after, merge vs rebase | Done |
| Bonus | Bisect log, `f285ede` identified, log2(N) reasoning | Done |

The three parts demonstrate the same Git model from different angles. Task 1 shows
that Git stores immutable content-addressed objects and branches are references to
commits, which is why reflog recovery can restore work after a hard reset. Task 2
shows that rebasing creates new commit objects because parent relationships change,
and that signed tags and signed commits provide verifiable metadata around those
objects. The bonus uses immutable commit snapshots to locate a regression by
bisection instead of manually inspecting every change.
