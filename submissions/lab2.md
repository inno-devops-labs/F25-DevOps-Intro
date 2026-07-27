# Lab 2 submission

Repository: `Mimir-sma/DevOps-Intro`  
Branch: `feature/lab2`  
Git version: `2.55.0.windows.3`

## Task 1 — object model and reflog recovery

### HEAD → tree → blob → file

```text
$ git rev-parse HEAD
260de0de962c1e05e35e975647d8f98909769842

$ git cat-file -t HEAD
commit

$ git cat-file -p HEAD
tree a124f7daa6588e22550439a28d6460f2bf57a823
parent 9f41b7deb32343a831b5e47c61533fbc7c0ce67d
author Mimir-sma <arsengobozov15region@gmail.com> 1785183437 +0300
committer Mimir-sma <arsengobozov15region@gmail.com> 1785183437 +0300
gpgsig -----BEGIN SSH SIGNATURE-----
...
-----END SSH SIGNATURE-----

docs: add PR template

$ git cat-file -p a124f7daa6588e22550439a28d6460f2bf57a823
040000 tree 67a39c9813be55c1ec7079f10e7a8c58bc4c1bd5  .github
100644 blob 1c0a1e94b7bbdd951f456cda51af6b8484cc3cee  .gitignore
100644 blob d10c04c6e7e0014f4fe883599c11747c15012d4e  README.md
040000 tree 7d0898a908e274ea809722844cdbd836f3b1c05a  app
040000 tree f4f047dd07b128eda5f899dfdaaf193f0291eaa2  labs
040000 tree c0ac2d55cf4335df659b347df3d19d0594a06b6c  lectures

$ git cat-file -t d10c04c6e7e0014f4fe883599c11747c15012d4e
blob

$ git cat-file -p d10c04c6e7e0014f4fe883599c11747c15012d4e
# DevOps Intro — Modern DevOps Practices Through One Project

[![Course](https://img.shields.io/badge/Course-DevOps%20Intro-blue)](#course-roadmap)
[![Project](https://img.shields.io/badge/Project-QuickNotes%20(Go)-success)](#the-project-quicknotes)
...
```

A commit stores metadata and points to the root tree. The tree maps file names
and modes to other trees or blobs; the selected blob contains the actual bytes
of `README.md`, but no file name of its own.

### Inside `.git`

```text
$ cat .git/HEAD
ref: refs/heads/feature/lab2

$ ls .git/refs/heads
main
feature/lab1
feature/lab2

$ ls .git/objects | head
0b
21
26
2c
67
a1
e5
info
pack

$ find .git/objects -type f | wc -l   # excluding pack files
8

$ git count-objects -v
count: 8
size: 4
in-pack: 220
packs: 1
size-pack: 547
prune-packable: 0
garbage: 0
size-garbage: 0
```

`HEAD` is a symbolic reference to the checked-out branch. Branch files under
`refs/heads` point to commits. Most historical objects are compressed into one
pack, while the eight recently created objects are still loose in two-character
fan-out directories.

### Destructive reset and recovery

Two signed commits were created first:

```text
* 1fde3c8 wip(lab2): more progress
* c02d242 wip(lab2): start
* 260de0d docs: add PR template
```

The branch name and clean working tree were checked before running the
destructive exercise.

```text
$ git reset --hard HEAD~2
HEAD is now at 260de0d docs: add PR template

$ git status --short --branch
## feature/lab2

$ git reflog -8 --date=iso
260de0d HEAD@{2026-07-27 23:28:32 +0300}: reset: moving to HEAD~2
1fde3c8 HEAD@{2026-07-27 23:28:32 +0300}: commit: wip(lab2): more progress
c02d242 HEAD@{2026-07-27 23:28:13 +0300}: commit: wip(lab2): start
260de0d HEAD@{2026-07-27 23:27:49 +0300}: checkout: moving from main to feature/lab2
260de0d HEAD@{2026-07-27 23:27:49 +0300}: checkout: moving from feature/lab1 to main
e50193d HEAD@{2026-07-27 23:26:57 +0300}: commit: docs(lab1): complete submission
```

Recovery used the most recent lost commit:

```text
$ git reset --hard 1fde3c8
HEAD is now at 1fde3c8 wip(lab2): more progress

$ git status --short --branch
## feature/lab2
```

After the bad reset, the WIP commits were unreachable from the branch but still
referenced by the reflog and present in the object database. A normal `git gc`
would generally keep them during the reflog/unreachable-object grace periods,
but an aggressive prune after reflog expiry could delete them permanently.
The safest response is to capture the SHA immediately and create a rescue branch
or reset to it before running maintenance.

## Task 2 — signed tag and rebase

### Signed annotated tag

The username-specific release tag is `v0.1.0-lab2-Mimir-sma`.

```text
$ git tag -l v0.1.0-lab2-Mimir-sma \
    --format='%(refname:short) %(objecttype) %(*objecttype)'
v0.1.0-lab2-Mimir-sma tag commit

$ git tag -v v0.1.0-lab2-Mimir-sma
object 260de0de962c1e05e35e975647d8f98909769842
type commit
tag v0.1.0-lab2-Mimir-sma
tagger Mimir-sma <arsengobozov15region@gmail.com> 1785184255 +0300

Lab 2 milestone — version control deep dive
Good "git" signature for arsengobozov15region@gmail.com with ED25519 key SHA256:d+1+7nScChodUrIJ/EkVIMngcdBd1QGaLK1ZM+cghl4
```

### Before and after rebase

Before:

```text
* 28a306f (main) docs: upstream moved while you worked
| * 1fde3c8 (feature/lab2) wip(lab2): more progress
| * c02d242 wip(lab2): start
|/
| * e50193d (feature/lab1) docs(lab1): complete submission
|/
* 260de0d (tag: v0.1.0-lab2-Mimir-sma) docs: add PR template
```

After `git rebase main`:

```text
* 86e655f (feature/lab2) wip(lab2): more progress
* cde4583 wip(lab2): start
* 28a306f (main) docs: upstream moved while you worked
| * e50193d (feature/lab1) docs(lab1): complete submission
|/
* 260de0d (tag: v0.1.0-lab2-Mimir-sma) docs: add PR template
```

Both rewritten commits have Good SSH signatures. Because their parents changed,
their SHAs changed as expected; the remote update must therefore use
`git push --force-with-lease`, never an unconditional `--force`.

I prefer rebase for a private feature branch because it produces a small,
linear series on top of the current base. I choose merge for public/shared
history or when the branch topology is useful context, because merge does not
rewrite commits other people may already depend on.

## Bonus — automated bisect

The official `upstream/bug/bisect-me` branch and known-good `v0.0.1` tag were
fetched. The test command ran `go test -count=1 ./...` and `go build ./...`
inside `app/`.

```text
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
# first 'bad' commit: [f285ede8611e55ac0a7d01100891c0cc775e0709] refactor(store): simplify nextID restoration in load()
```

The first bad commit is
`f285ede8611e55ac0a7d01100891c0cc775e0709`
(`refactor(store): simplify nextID restoration in load()`). It changed the
next-ID restoration condition from `n.ID >= s.nextID` to `n.ID > s.nextID`,
causing `TestStore_PersistsAcrossReload` to report `got 1, want 2`.

Bisect tests the midpoint of the remaining candidate range after every result,
discarding roughly half the commits at each step. Therefore it needs about
`log₂(N)` test runs instead of checking all `N` commits linearly. Here Git
classified only two intermediate revisions after the known-good and bad
boundaries were supplied.
