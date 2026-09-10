important work
more important work

# Task 1

### 1.1
Output of `git rev-parse HEAD`:
```
af676b7812e21022fbd705628aaa7fd01fdceb95
```

Output of `git cat-file -t HEAD`
```
commit
```

Output of `git cat-file -p HEAD`
```
tree 4e8941f4762188e39dde75dbbc42c9b8b0a2f920
parent 9f41b7deb32343a831b5e47c61533fbc7c0ce67d
author witch2256 <dudnyashka2006@gmail.com> 1789054740 +0300
committer witch2256 <dudnyashka2006@gmail.com> 1789054740 +0300
gpgsig -----BEGIN SSH SIGNATURE-----
U1NIU0lHAAAAAQAAADMAAAALc3NoLWVkMjU1MTkAAAAgSdMKb+go+166gS8+srDRzY0kIH
ubDiMkMdUaEebODW8AAAADZ2l0AAAAAAAAAAZzaGE1MTIAAABTAAAAC3NzaC1lZDI1NTE5
AAAAQCEHuNYls9l5faHWBssPgvSHEPbiFxb+2kj7Ke3Nw5bSYHg8zKBIYWj+wMRlVO+B61
097oWylqknLRYCc2eUSAs=
-----END SSH SIGNATURE-----

docs: add PR template

Signed-off-by: witch2256 <dudnyashka2006@gmail.com>
```

Output of `git cat-file -p 4e8941f4762188e39dde75dbbc42c9b8b0a2f920`
```
040000 tree 1d07791eee3c3dd0955a02402b05b3a357816d8d	.github
100644 blob 1c0a1e94b7bbdd951f456cda51af6b8484cc3cee	.gitignore
100644 blob d10c04c6e7e0014f4fe883599c11747c15012d4e	README.md
040000 tree 7d0898a908e274ea809722844cdbd836f3b1c05a	app
040000 tree f4f047dd07b128eda5f899dfdaaf193f0291eaa2	labs
040000 tree c0ac2d55cf4335df659b347df3d19d0594a06b6c	lectures
```

Output of `git cat-file -p 1c0a1e94b7bbdd951f456cda51af6b8484cc3cee`
```
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

### 1.2 — Inside `.git/`

The `.git/` directory *is* the repository — all history and metadata live here,
while the working tree is just a checkout of one commit.

- **`HEAD`** — a text pointer to the current branch (`ref: refs/heads/main`).
  A detached HEAD would contain a raw commit SHA instead.
- **`refs/heads/`** — one file per local branch; filename = branch name,
  contents = SHA of the branch tip. I have two entries: `main` and `feature`
  (the latter is a directory because `feature/lab1` is stored as a path).
- **`objects/`** — the content-addressable store for all Git objects
  (blobs, trees, commits, tags). Objects are split into subdirectories named
  after the first 2 hex chars of their SHA to keep directory sizes manageable.
  44 loose objects currently means nothing has been packed yet.
- **`packed-refs`** — a compressed version of refs (tags and remote branches
  from `upstream`), so Git doesn't scatter thousands of tiny files under `refs/`.
- **`config`** — local repository config (remotes, pull strategy), separate
  from the global `~/.gitconfig`.
- **`index`** — the staging area; exactly what `git add` mutates.
- **`logs/`** — backing store for `git reflog`: every movement of HEAD and
  branches is recorded here, which is why "lost" commits can be recovered.
- **`hooks/`** — sample Git hooks, inactive by default.
- **`FETCH_HEAD`** — result of the last `git fetch`, used by `git merge FETCH_HEAD`.

**Key takeaway:** Git is a content-addressable store on top of the filesystem —
everything is keyed by the SHA of its contents, and branches are just tiny
human-readable pointers to those SHAs.

### 1.3

`git reflog` output:
```
af676b7 (HEAD -> feature/lab2, origin/main, origin/HEAD, main) HEAD@{0}: reset: moving to HEAD~2
405226c HEAD@{1}: commit: wip(lab2): more progress
7f8c936 HEAD@{2}: commit: wip(lab2): start
af676b7 (HEAD -> feature/lab2, origin/main, origin/HEAD, main) HEAD@{3}: checkout: moving from main to feature/lab2
af676b7 (HEAD -> feature/lab2, origin/main, origin/HEAD, main) HEAD@{4}: checkout: moving from feature/lab1 to main
cdc2aa4 (origin/feature/lab1, feature/lab1) HEAD@{5}: commit: docs(lab1): tasks 2 and 3 completed
d2bec34 HEAD@{6}: checkout: moving from main to feature/lab1
af676b7 (HEAD -> feature/lab2, origin/main, origin/HEAD, main) HEAD@{7}: checkout: moving from feature/lab1 to main
d2bec34 HEAD@{8}: commit: docs(lab1): finish submission
a7e7503 HEAD@{9}: checkout: moving from feature/lab1 to feature/lab1
a7e7503 HEAD@{10}: checkout: moving from main to feature/lab1
af676b7 (HEAD -> feature/lab2, origin/main, origin/HEAD, main) HEAD@{11}: commit: docs: add PR template
9f41b7d (upstream/main, upstream/HEAD) HEAD@{12}: checkout: moving from feature/lab1 to main
a7e7503 HEAD@{13}: commit: docs(lab1): start submission
9f41b7d (upstream/main, upstream/HEAD) HEAD@{14}: checkout: moving from main to feature/lab1
9f41b7d (upstream/main, upstream/HEAD) HEAD@{15}: clone: from https://github.com/witch2256/DevOps-Intro
```

`git reset --hard 405226c` output:
```
HEAD is now at 405226c wip(lab2): more progress
```

If `git gc` had run between the bad reset and the recovery, the two commits would
have become unreachable and, once past the `gc.reflogExpire` window (30 days by
default), would have been physically deleted from `.git/objects/` — leaving
`git reflog` with nothing to recover from. In practice the 30-day default gives
plenty of slack for local work, but CI environments and aggressive server-side
configurations often shrink this window to hours or days, so the safe habit is
to copy the commit SHA immediately after a bad reset rather than rely on reflog
persistence.

## Task 2

`git tag -v "v0.1.0-lab2-${USER}"` output:
```
object af676b7812e21022fbd705628aaa7fd01fdceb95
type commit
tag v0.1.0-lab2-witch
tagger witch2256 <dudnyashka2006@gmail.com> 1789058768 +0300

Lab 2 milestone — version control deep dive
Good "git" signature for dudnyashka2006@gmail.com with ED25519 key SHA256:oEWn13cEcnUOUln62wZs8LycYNs3T9wO45UZALKw4Ro
```

`git reflog feature/lab2` output:
```
c269f74 (HEAD -> feature/lab2, origin/feature/lab2) feature/lab2@{0}: rebase (finish): refs/heads/feature/lab2 onto abd7461c5e6fc40ea0e4aa4ad35e74622e98aed4
405226c feature/lab2@{1}: reset: moving to 405226c
af676b7 (tag: v0.1.0-lab2-witch) feature/lab2@{2}: reset: moving to HEAD~2
405226c feature/lab2@{3}: commit: wip(lab2): more progress
7f8c936 feature/lab2@{4}: commit: wip(lab2): start
af676b7 (tag: v0.1.0-lab2-witch) feature/lab2@{5}: branch: Created from HEAD
```

Before rebase(`git log --oneline --graph --decorate 405226c main`):
```
* abd7461 (origin/main, origin/HEAD, main) docs: upstream moved while you worked
  | * 405226c wip(lab2): more progress
  | * 7f8c936 wip(lab2): start
  |/
* af676b7 (tag: v0.1.0-lab2-witch) docs: add PR template
* 9f41b7d (upstream/main, upstream/HEAD) docs(lab7): make seed.json shipping explicit; require bonus artifacts, not logs
* 8de962e docs(lab11): fix nixpkgs pin vs go.mod collision; add network fallback pitfalls
* bfa345b docs(lab3): matrix renames required checks — warn + ci-ok gate pattern; set honest cache expectations
* 356419b docs(lab1,lab2): clarify GitHub auth vs signing SSH key roles; add publickey-denied pitfalls
* 66bbd4d docs(lab1): align Task 3 GitHub Community engagement with other courses
*   170000c Merge pull request #907 from inno-devops-labs/s26-refactor
    |\  
    | * d50436c (upstream/s26-refactor) fix(lab12,gitignore): Spin SDK (WAGI removed in Spin 3.x); minimal student-safe gitignore
    | * 4705a3d fix(.gitignore): stop ignoring submissions/
    | * 4082340 docs(grading,lab11,lab12): bonus labs to 4+4+2; grading rebalanced to 70-14-5-20-30 = 139%
    | * 7b16dc5 docs(lab10): switch deploy targets to card-free platforms — HF Spaces + Cloudflare Tunnel
    | * 4a05efa docs(labs): scaffold the skill — labs 5-12 stop handing students copy-paste answers
    | * 8387fb9 docs(lab3): scaffold the skill — students write their own CI yaml; GitLab as parallel path
    | * 983fba0 docs(course): rewrite README + add .gitignore for project-threaded structure
    | * 7914e37 docs(labs): refactor 12 labs to 6+4+2 (lab1) / 6+4+bonus (lab2-10) / 10pts (lab11-12)
    | * aa5aa1c docs(lectures): rewrite lec1-10 + add reading11/12 for project-threaded course
    | * b8fc480 feat(app): introduce QuickNotes Go service for project-threaded course
    |/
* 6f044dd (upstream/s26) Replace IPFS with Nix
* 0a87e1c refactor: reduce prescriptiveness in GitLab CI instructions
* eaea715 feat: add GitLab CI alternative instructions to lab3
* d6b6a03 Update lab2
* 87810a0 feat: remove old Exam Exemption Policy
* 1e1c32b feat: update structure
* 6c27ee7 feat: publish lecs 9 & 10
* 1826c36 feat: update lab7
* 3049f08 feat: publish lec8
* da8f635 feat: introduce all labs and revised structure
* 04b174e feat: publish lab and lec #5
* 67f12f1 feat: publish labs 4&5, revise others
* 82d1989 feat: publish lab3 and lec3
* 3f80c83 feat: publish lec2
* 499f2ba feat: publish lab2
* af0da89 feat: update lab1
* 74a8c27 Publish lab1
* f0485c0 Publish lec1
* 31dd11b Publish README.md
```

After rebase(`git log --oneline --graph --decorate feature/lab2 main`):
```
* c269f74 (HEAD -> feature/lab2, origin/feature/lab2) wip(lab2): more progress
* 98b3db2 wip(lab2): start
* abd7461 (origin/main, origin/HEAD, main) docs: upstream moved while you worked
* af676b7 (tag: v0.1.0-lab2-witch) docs: add PR template
* 9f41b7d (upstream/main, upstream/HEAD) docs(lab7): make seed.json shipping explicit; require bonus artifacts, not logs
* 8de962e docs(lab11): fix nixpkgs pin vs go.mod collision; add network fallback pitfalls
* bfa345b docs(lab3): matrix renames required checks — warn + ci-ok gate pattern; set honest cache expectations
* 356419b docs(lab1,lab2): clarify GitHub auth vs signing SSH key roles; add publickey-denied pitfalls
* 66bbd4d docs(lab1): align Task 3 GitHub Community engagement with other courses
*   170000c Merge pull request #907 from inno-devops-labs/s26-refactor
|\  
| * d50436c (upstream/s26-refactor) fix(lab12,gitignore): Spin SDK (WAGI removed in Spin 3.x); minimal student-safe gitignore
| * 4705a3d fix(.gitignore): stop ignoring submissions/
| * 4082340 docs(grading,lab11,lab12): bonus labs to 4+4+2; grading rebalanced to 70-14-5-20-30 = 139%
| * 7b16dc5 docs(lab10): switch deploy targets to card-free platforms — HF Spaces + Cloudflare Tunnel
| * 4a05efa docs(labs): scaffold the skill — labs 5-12 stop handing students copy-paste answers
| * 8387fb9 docs(lab3): scaffold the skill — students write their own CI yaml; GitLab as parallel path
| * 983fba0 docs(course): rewrite README + add .gitignore for project-threaded structure
| * 7914e37 docs(labs): refactor 12 labs to 6+4+2 (lab1) / 6+4+bonus (lab2-10) / 10pts (lab11-12)
| * aa5aa1c docs(lectures): rewrite lec1-10 + add reading11/12 for project-threaded course
| * b8fc480 feat(app): introduce QuickNotes Go service for project-threaded course
|/  
* 6f044dd (upstream/s26) Replace IPFS with Nix
* 0a87e1c refactor: reduce prescriptiveness in GitLab CI instructions
* eaea715 feat: add GitLab CI alternative instructions to lab3
* d6b6a03 Update lab2
* 87810a0 feat: remove old Exam Exemption Policy
* 1e1c32b feat: update structure
* 6c27ee7 feat: publish lecs 9 & 10
* 1826c36 feat: update lab7
* 3049f08 feat: publish lec8
* da8f635 feat: introduce all labs and revised structure
* 04b174e feat: publish lab and lec #5
* 67f12f1 feat: publish labs 4&5, revise others
* 82d1989 feat: publish lab3 and lec3
* 3f80c83 feat: publish lec2
* 499f2ba feat: publish lab2
* af0da89 feat: update lab1
* 74a8c27 Publish lab1
* f0485c0 Publish lec1
* 31dd11b Publish README.md
```

### Merge vs Rebase — When to Choose Which

**Rebase** rewrites commit history by replaying my commits on top of a new base,
producing a clean linear graph — I use it for **my own local feature branches**
that nobody else has pulled, right before opening a PR, to keep the history
readable and avoid noise from merge commits. **Merge** preserves the actual
branching that happened, at the cost of an extra merge commit — I use it when
the branch is **shared or already public** (e.g. `main`, `develop`, a teammate's
branch), because rewriting public history would break everyone else's clones and
force them into painful recovery.

The golden rule I follow: **never rebase a branch someone else is based on**.
If a branch has been pushed and a colleague may have pulled it, I use merge; if
it's still purely mine, I rebase to keep history linear before it lands in `main`.

## Bonus Task

`go test ./...`
```
--- FAIL: TestStore_PersistsAcrossReload (0.00s)
store_test.go:78: nextID not restored: got 1, want 2
FAIL
FAIL	quicknotes	0.422s
FAIL
```

`git bisect run sh -c 'cd app && go test ./... && go build ./...'`
```
running 'sh' '-c' 'cd app && go test ./... && go build ./...'
--- FAIL: TestStore_PersistsAcrossReload (0.00s)
store_test.go:78: nextID not restored: got 1, want 2
FAIL
FAIL	quicknotes	0.576s
FAIL
Bisecting: 0 revisions left to test after this (roughly 0 steps)
[cb89bb9ee2ee5010b166061447eaca3ae0da2378] docs(store): comment the load() decode step
running 'sh' '-c' 'cd app && go test ./... && go build ./...'
ok  	quicknotes	0.345s
f285ede8611e55ac0a7d01100891c0cc775e0709 is the first bad commit
commit f285ede8611e55ac0a7d01100891c0cc775e0709
Author: Dmitrii Creed <creeed22@gmail.com>
Date:   Fri Jun 5 13:36:56 2026 +0400

    refactor(store): simplify nextID restoration in load()
    
    Signed-off-by: Dmitrii Creed <creeed22@gmail.com>

app/store.go | 2 +-
1 file changed, 1 insertion(+), 1 deletion(-)
bisect found first bad commit
```