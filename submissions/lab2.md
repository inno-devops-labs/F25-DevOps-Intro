# Lab 2 — Version Control Deep Dive

Student: Arina ([@sonder314](https://github.com/sonder314))

Branch: `feature/lab2`

Tag: `v0.1.0-lab2-arina`

Submission PR: [inno-devops-labs/DevOps-Intro#1522](https://github.com/inno-devops-labs/DevOps-Intro/pull/1522)

## Task 1 — Git object model and reflog recovery

### HEAD → tree → blob → file

I followed one complete object chain from commit `579f5c9cc6f9bb2accda8a57985c5706ec8e82f1` to its root tree, then to the `.gitignore` blob and the stored file contents:

```text
$ git rev-parse HEAD
579f5c9cc6f9bb2accda8a57985c5706ec8e82f1

$ git cat-file -t HEAD
commit

$ git cat-file -p HEAD
tree 4e8941f4762188e39dde75dbbc42c9b8b0a2f920
parent 9f41b7deb32343a831b5e47c61533fbc7c0ce67d
author Arina <uzersamsung873@gmail.com> 1788863043 +0300
committer Arina <uzersamsung873@gmail.com> 1788865002 +0300
gpgsig -----BEGIN SSH SIGNATURE-----
 U1NIU0lHAAAAAQAAADMAAAALc3NoLWVkMjU1MTkAAAAgPfrLDWS/4N3gsZoccOTj1fA1nu
 e4UhooWZgBcw0azDkAAAADZ2l0AAAAAAAAAAZzaGE1MTIAAABTAAAAC3NzaC1lZDI1NTE5
 AAAAQH78vyptABIQzZiAXQfVuLuwqsFga0NbLC8C0UfBlTCm9ZlozfyoiDTLyyMUh/Kux6
 TaFSjakpolxbmJqxCf2Qc=
 -----END SSH SIGNATURE-----

docs: add PR template

Signed-off-by: Arina <uzersamsung873@gmail.com>

$ git rev-parse HEAD^{tree}
4e8941f4762188e39dde75dbbc42c9b8b0a2f920

$ git cat-file -p 4e8941f4762188e39dde75dbbc42c9b8b0a2f920
040000 tree 1d07791eee3c3dd0955a02402b05b3a357816d8d	.github
100644 blob 1c0a1e94b7bbdd951f456cda51af6b8484cc3cee	.gitignore
100644 blob d10c04c6e7e0014f4fe883599c11747c15012d4e	README.md
040000 tree 7d0898a908e274ea809722844cdbd836f3b1c05a	app
040000 tree f4f047dd07b128eda5f899dfdaaf193f0291eaa2	labs
040000 tree c0ac2d55cf4335df659b347df3d19d0594a06b6c	lectures

$ git rev-parse HEAD:.gitignore
1c0a1e94b7bbdd951f456cda51af6b8484cc3cee

$ git cat-file -t 1c0a1e94b7bbdd951f456cda51af6b8484cc3cee
blob

$ git cat-file -p 1c0a1e94b7bbdd951f456cda51af6b8484cc3cee
# ⚠️  KEEP THIS FILE MINIMAL.
#
# This .gitignore is inherited by every student fork. Anything listed here
# is something a student CANNOT `git add` without `-f`. So this file must
# ONLY contain:
#   (a) instructor-only paths (refs/), and
#   (b) machine-generated junk that NOBODY should ever commit.
#
# Do NOT add lab DELIVERABLES here (scan reports, SBOMs, go.sum, k8s
# manifests, CI workflows, Dockerfiles, playbooks, dashboards, …). Students
# are told to commit those in their submission PRs — ignoring them upstream
# silently breaks the lab. When in doubt, leave it OUT of this file.

# ── Instructor-only ─────────────────────────────────────────────
# Reference submissions (dry-run worked examples). Never pushed upstream;
# students never see these. This is the one path that is intentionally hidden.
refs/

# ── Machine-generated junk (no one commits these) ───────────────
# Compiled binaries / local runtime state
app/quicknotes
app/data/
/quicknotes
*.exe

# Vagrant runtime state (Lab 5) — the Vagrantfile IS committed; .vagrant/ is not
.vagrant/

# Nix build symlinks (Lab 11) — flake.nix + flake.lock ARE committed; result is not
result
result-*

# Terraform state — MUST never be committed (can contain secrets)
*.tfstate
*.tfstate.backup
.terraform/

# Python virtualenvs / caches
.venv/
__pycache__/
*.pyc

# Editor / IDE
.vscode/
.idea/
*.swp

# OS noise
.DS_Store
Thumbs.db

# Local agent config (not part of the course)
.claude/

# NOTE: deliberately NOT ignored, because students commit them as lab evidence:
#   submissions/labN.md        (lab reports)
#   .github/workflows/*.yml    (Lab 3 CI)
#   Dockerfile, compose.yaml   (Lab 6)
#   ansible/                   (Lab 7)
#   monitoring/                (Lab 8)
#   *.sbom.cdx.json, zap-*.html/json, trivy-*.txt   (Lab 9 scan evidence)
#   flake.nix, flake.lock      (Lab 11)
#   wasm/main.go, spin.toml, go.sum   (Lab 12)
```

Git stores a commit as metadata plus references to its parent and root tree. The tree maps names to blobs and other trees, while the blob contains the file bytes without its filename or history. The SHA identifies the object's type and content, so a content change creates a different object ID.

Raw output: [objects.txt](evidence/lab2/objects.txt).

### Inside `.git`

```text
$ ls -la .git/
total 72
drwxrwxr-x  9 arina arina 4096 Sep  8 14:39 .
drwxrwxr-x  8 arina arina 4096 Sep  8 14:39 ..
-rw-rw-r--  1 arina arina  104 Sep  8 14:37 COMMIT_EDITMSG
-rw-rw-r--  1 arina arina   93 Sep  8 14:24 FETCH_HEAD
-rw-rw-r--  1 arina arina   29 Sep  8 14:39 HEAD
-rw-rw-r--  1 arina arina   41 Sep  8 13:56 ORIG_HEAD
-rw-rw-r--  1 arina arina  318 Sep  8 14:16 allowed_signers
-rw-rw-r--  1 arina arina  908 Sep  8 14:16 config
-rw-rw-r--  1 arina arina   73 Sep  7 14:08 description
drwxrwxr-x  2 arina arina 4096 Sep  8 14:33 gk
drwxrwxr-x  2 arina arina 4096 Sep  7 14:08 hooks
-rw-rw-r--  1 arina arina 3183 Sep  8 14:39 index
drwxrwxr-x  2 arina arina 4096 Sep  7 14:08 info
drwxrwxr-x  3 arina arina 4096 Sep  7 14:08 logs
drwxrwxr-x 81 arina arina 4096 Sep  8 14:37 objects
-rw-rw-r--  1 arina arina  112 Sep  7 14:08 packed-refs
drwxrwxr-x  5 arina arina 4096 Sep  7 14:08 refs
drwxrwxr-x  3 arina arina 4096 Sep  8 14:39 worktrees

$ cat .git/HEAD
ref: refs/heads/feature/lab2

$ ls .git/refs/heads/
backup
feature
main

$ ls .git/objects/ | head
02
03
04
0a
0c
0e
0f
13
18
1a

$ find .git/objects -type f | wc -l
92

$ git count-objects -v
count: 87
size: 672
in-pack: 220
packs: 1
size-pack: 547
prune-packable: 0
garbage: 0
size-garbage: 0
```

`.git/HEAD` points to my current branch reference. `refs/heads` stores local branch tips, while `objects` stores loose objects in directories named from the first two SHA characters; `git count-objects -v` also shows packed objects. These files form the repository database and local reference history.

Raw output: [git-directory.txt](evidence/lab2/git-directory.txt).

### Destructive reset and recovery

I created and signed two commits, reset the branch two commits backwards, found the lost tip in the reflog, and restored it with `git reset --hard 8e97c287913bdf14c52525cc9bcb6de628647ea8`:

```text
$ git reset --hard 'HEAD~2'
HEAD is now at 579f5c9 docs: add PR template

$ git status
On branch feature/lab2
nothing to commit, working tree clean

$ git log --oneline -5
579f5c9 docs: add PR template
9f41b7d docs(lab7): make seed.json shipping explicit; require bonus artifacts, not logs
8de962e docs(lab11): fix nixpkgs pin vs go.mod collision; add network fallback pitfalls
bfa345b docs(lab3): matrix renames required checks — warn + ci-ok gate pattern; set honest cache expectations
356419b docs(lab1,lab2): clarify GitHub auth vs signing SSH key roles; add publickey-denied pitfalls

$ git reflog -12
579f5c9 HEAD@{0}: reset: moving to HEAD~2
8e97c28 HEAD@{1}: commit: wip(lab2): more progress
9b17313 HEAD@{2}: commit: wip(lab2): start
579f5c9 HEAD@{3}: checkout: moving from feature/lab1 to feature/lab2
848f810 HEAD@{4}: commit: docs(lab1): confirm final checks and Moodle submission
2a088ce HEAD@{5}: commit: docs(lab1): record submission PR and completed bonus
44ea453 HEAD@{6}: commit: docs(lab1): add GitHub verification and branch protection evidence
1841e41 HEAD@{7}: commit: docs(lab1): correct email and finalize report wording
728295b HEAD@{8}:
9b1a031 HEAD@{9}: commit: docs(lab1): update evidence for sonder314 signing key
9294d79 HEAD@{10}: rebase (finish): returning to refs/heads/feature/lab1
9294d79 HEAD@{11}: rebase (pick): docs(lab1): record completed community engagement

$ git rev-parse 'HEAD@{1}'
8e97c287913bdf14c52525cc9bcb6de628647ea8

$ git reset --hard 8e97c287913bdf14c52525cc9bcb6de628647ea8
HEAD is now at 8e97c28 wip(lab2): more progress

$ git status
On branch feature/lab2
nothing to commit, working tree clean

$ cat submissions/lab2.md
important work
more important work
```

The reflog kept a reference to my unreachable commits, so Git had not immediately deleted their objects. A normal `git gc` usually retains recently unreachable objects because reflog entries default to 30 days, but an aggressively configured expiry and prune could remove both the reflog entry and objects. If that happened before I recorded the SHA, ordinary reflog recovery would no longer work and I would need another copy or backup.

Raw output: [recovery.txt](evidence/lab2/recovery.txt).

## Task 2 — Signed tag and rebased feature

### Annotated signed tag

```text
$ git tag -l v0.1.0-lab2-arina --format='%(refname:short) %(objecttype) %(*objecttype)'
v0.1.0-lab2-arina tag commit

$ git tag -v v0.1.0-lab2-arina
Good "git" signature for uzersamsung873@gmail.com with ED25519 key SHA256:RhLO1q1uCo2ao0SZqhu1c77Gq/mG6sUkLS/fdDMqXQA
object 579f5c9cc6f9bb2accda8a57985c5706ec8e82f1
type commit
tag v0.1.0-lab2-arina
tagger Arina <uzersamsung873@gmail.com> 1789048521 +0300

Lab 2 milestone — version control deep dive
```

The output `tag commit` confirms that this is an annotated tag object pointing to a commit. The `Good "git" signature` line verifies its SSH signature. I also pushed the tag to `origin` and checked that the remote tag object ID matched the local one.

Raw output: [tag-verification.txt](evidence/lab2/tag-verification.txt).

### Rebase and squash

My Lab 1 branch protection required changes to `main` through a pull request, so I moved my fork's `main` with the signed `lab2/main-update` PR instead of bypassing that rule. I then rebased `feature/lab2` onto the new `origin/main`, squashed the two WIP commits into one, signed the rewritten commit, and used `--force-with-lease` to update the published feature branch.

Before rebase:

```text
* 97b2dae (origin/main, origin/HEAD) docs: clarify PR testing evidence for Lab 2 (#1)
| * 8e97c28 (HEAD -> feature/lab2, origin/feature/lab2) wip(lab2): more progress
| * 9b17313 wip(lab2): start
|/
* 579f5c9 (tag: v0.1.0-lab2-arina, main) docs: add PR template
o 9f41b7d (upstream/main, upstream/HEAD) docs(lab7): make seed.json shipping explicit; require bonus artifacts, not logs
```

After rebase and squash:

```text
* ab67619 (HEAD -> feature/lab2) wip(lab2): start
* 97b2dae (origin/main, origin/HEAD) docs: clarify PR testing evidence for Lab 2 (#1)
* 579f5c9 (tag: v0.1.0-lab2-arina, main) docs: add PR template
o 9f41b7d (upstream/main, upstream/HEAD) docs(lab7): make seed.json shipping explicit; require bonus artifacts, not logs
```

Raw graphs: [before](evidence/lab2/graph-before.txt) and [after](evidence/lab2/graph-after.txt).

Before opening the course PR, I rebased the two Lab 2 commits onto `upstream/main`. This removed the unrelated PR-template commit inherited from my fork, so the final course PR contains only the Lab 2 report and its evidence.

I choose merge when preserving the exact branch structure and shared history is useful. I choose rebase for my private feature work when I want a clean linear sequence on top of the latest base. Because rebase rewrites commit IDs, I use `--force-with-lease` only on my own branch after checking the remote tip.

## Bonus — Find the regression with git bisect

```text
# bad: [f0c9243b7c80ebb930a1ce7048a1d65b4c2ac493] docs(app): mention go test invocation
# good: [0ec87b808ae6a257a98ecea4a3c8d38a7f2c5ac7] chore(app): document versioning scheme (bisect fixture baseline)
git bisect start 'upstream/bug/bisect-me' 'v0.0.1'
# bad: [f285ede8611e55ac0a7d01100891c0cc775e0709] refactor(store): simplify nextID restoration in load()
git bisect bad f285ede8611e55ac0a7d01100891c0cc775e0709
# good: [cb89bb9ee2ee5010b166061447eaca3ae0da2378] docs(store): comment the load() decode step
git bisect good cb89bb9ee2ee5010b166061447eaca3ae0da2378
# first bad commit: [f285ede8611e55ac0a7d01100891c0cc775e0709] refactor(store): simplify nextID restoration in load()
```

The first bad commit is `f285ede8611e55ac0a7d01100891c0cc775e0709` — `refactor(store): simplify nextID restoration in load()`. It changed the next-ID restoration condition in `app/store.go` from `>=` to `>`, allowing an existing maximum ID to be reused after loading stored notes. `git bisect` repeatedly tested the midpoint between the known-good tag and bad branch tip. The range contained four candidate commits, so binary search isolated the regression in two decisions, matching `log₂(4) = 2` instead of testing each commit sequentially.

Raw evidence: [bisect log](evidence/lab2/bisect-log.txt) and [offending commit](evidence/lab2/bad-commit.txt).

## Submission readiness

- [x] Complete HEAD → tree → blob → file chain recorded.
- [x] `.git` structure inspected and interpreted.
- [x] Hard-reset recovery demonstrated with reflog evidence.
- [x] Annotated signed tag published and verified.
- [x] Before/after rebase graphs recorded.
- [x] Feature history rebased, squashed and signed.
- [x] Bonus regression identified with full bisect log.
- [x] `feature/lab2` PR opened against the course repository and its URL recorded.
- [x] Every submitted commit passes local SSH-signature verification.
