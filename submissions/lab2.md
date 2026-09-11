# Lab 2 submission

## Task 1: Git Object Model and Reflog Recovery

### 1.1 Git object chain

I inspected one full Git object chain: `HEAD` -> tree -> blob -> file.

Commands:

```text
git rev-parse HEAD
git cat-file -t HEAD
git cat-file -p HEAD

$TREE = git show -s --format=%T HEAD
Write-Host "TREE_SHA=$TREE"
git cat-file -p $TREE

$BLOB = git rev-parse HEAD:.gitignore
Write-Host "BLOB_SHA=$BLOB"
git cat-file -t $BLOB
git cat-file -p $BLOB
```

Output:

```text
5a4a8231e5923be7279a9cff6911f615701004f5
commit
tree 7414fdd85a7ef8c21714fc9dfec1d84f8cf10dba
parent 9f41b7deb32343a831b5e47c61533fbc7c0ce67d
author Valdezzar <rustamotatarian@gmail.com> 1789108120 +0300
committer Valdezzar <rustamotatarian@gmail.com> 1789108120 +0300
gpgsig -----BEGIN SSH SIGNATURE-----
 U1NIU0lHAAAAAQAAADMAAAALc3NoLWVkMjU1MTkAAAAgLsJIZAdQEr0eamAcWXWTW/kWAq
 wwZDNcusvUUs4LOEQAAAADZ2l0AAAAAAAAAAZzaGE1MTIAAABTAAAAC3NzaC1lZDI1NTE5
 AAAAQE1DwPmA7c8YL3sGL6TNaBxCMmpczM8soEl54NF4B3Mmsszl6B/z3fbFQEeKN5SjE8
 lIpP6VCOtgHm6cZ0TDeg4=
 -----END SSH SIGNATURE-----

docs: add PR template

Signed-off-by: Valdezzar <rustamotatarian@gmail.com>

TREE_SHA=7414fdd85a7ef8c21714fc9dfec1d84f8cf10dba
040000 tree af83e0b6652f6a4b35a626db6e147a5dd9fd6106    .github
100644 blob 1c0a1e94b7bbdd951f456cda51af6b8484cc3cee    .gitignore
100644 blob d10c04c6e7e0014f4fe883599c11747c15012d4e    README.md
040000 tree 7d0898a908e274ea809722844cdbd836f3b1c05a    app
040000 tree f4f047dd07b128eda5f899dfdaaf193f0291eaa2    labs
040000 tree c0ac2d55cf4335df659b347df3d19d0594a06b6c    lectures

BLOB_SHA=1c0a1e94b7bbdd951f456cda51af6b8484cc3cee
blob
# KEEP THIS FILE MINIMAL.
#
# This .gitignore is inherited by every student fork. Anything listed here
# is something a student CANNOT `git add` without `-f`. So this file must
# ONLY contain:
#   (a) instructor-only paths (refs/), and
#   (b) machine-generated junk that NOBODY should ever commit.
#
# Do NOT add lab DELIVERABLES here (scan reports, SBOMs, go.sum, k8s
# manifests, CI workflows, Dockerfiles, playbooks, dashboards, ...). Students
# are told to commit those in their submission PRs. Ignoring them upstream
# silently breaks the lab. When in doubt, leave it OUT of this file.

refs/

app/quicknotes
app/data/
/quicknotes
*.exe

.vagrant/

result
result-*

*.tfstate
*.tfstate.backup
.terraform/

.venv/
__pycache__/
*.pyc

.vscode/
.idea/
*.swp

.DS_Store
Thumbs.db

.claude/
```

Short interpretation:

`HEAD` points to a commit object. The commit points to a tree object, and the tree points to file blobs and subtrees. I picked the `.gitignore` blob, and `git cat-file -p` printed the actual file contents stored by Git.

### 1.2 Inside `.git`

Commands:

```text
Get-ChildItem -Force .git
Get-Content .git\HEAD
Get-ChildItem .git\refs\heads
Get-ChildItem .git\objects | Select-Object -First 20
(Get-ChildItem .git\objects -Recurse -File).Count
```

Output:

```text
Directory: C:\dev\DevOps-Intro\.git

Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
d-----         9/11/2026   9:26 AM                hooks
d-----         9/11/2026   9:26 AM                info
d-----         9/11/2026   9:26 AM                logs
d-----         9/11/2026  10:09 AM                objects
d-----         9/11/2026   9:26 AM                refs
-a----         9/11/2026  10:02 AM             93 COMMIT_EDITMSG
-a----         9/11/2026   9:57 AM            497 config
-a----         9/11/2026   9:26 AM             73 description
-a----         9/11/2026  10:09 AM            588 FETCH_HEAD
-a----         9/11/2026  10:09 AM             21 HEAD
-a----         9/11/2026  10:09 AM           3183 index
-a----         9/11/2026  10:09 AM             41 ORIG_HEAD
-a----         9/11/2026   9:26 AM            112 packed-refs

ref: refs/heads/main

Directory: C:\dev\DevOps-Intro\.git\refs\heads

Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
d-----         9/11/2026  10:02 AM                feature
-a----         9/11/2026   9:28 AM             41 main

Directory: C:\dev\DevOps-Intro\.git\objects

Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
d-----         9/11/2026  10:02 AM                03
d-----         9/11/2026   9:27 AM                0a
d-----         9/11/2026   9:27 AM                0c
d-----         9/11/2026   9:27 AM                0e
d-----         9/11/2026   9:27 AM                0f
d-----         9/11/2026   9:27 AM                13
d-----         9/11/2026  10:02 AM                75
d-----         9/11/2026   9:27 AM                7a
d-----         9/11/2026   9:27 AM                7e

47
```

Short interpretation:

The `.git` directory stores the real repository database. `HEAD` points to the current branch, `refs/heads` stores local branch refs, and `objects` stores Git objects split into folders by the first two SHA characters. I had 47 loose object files at this point.

### 1.3 Reset disaster and recovery

Commands:

```text
git switch -c feature/lab2
mkdir submissions -ErrorAction SilentlyContinue

"important work" | Set-Content submissions\lab2.md
git add submissions\lab2.md
git commit -S -s -m "wip(lab2): start"

"more important work" | Add-Content submissions\lab2.md
git commit -S -s -am "wip(lab2): more progress"

git log --oneline -n 5

git reset --hard HEAD~2

git status
git --no-pager log --oneline -n 5
git --no-pager reflog -n 10

$RECOVER_SHA = git rev-parse "HEAD@{1}"
Write-Host "RECOVER_SHA=$RECOVER_SHA"
git reset --hard $RECOVER_SHA

git status
git --no-pager log --oneline -n 5
```

Output:

```text
Switched to a new branch 'feature/lab2'

[feature/lab2 41875be] wip(lab2): start
 1 file changed, 1 insertion(+)
 create mode 100644 submissions/lab2.md

[feature/lab2 d3cd047] wip(lab2): more progress
 1 file changed, 1 insertion(+)

d3cd047 (HEAD -> feature/lab2) wip(lab2): more progress
41875be wip(lab2): start
5a4a823 (origin/main, origin/HEAD, main) docs: add PR template
9f41b7d (upstream/main, upstream/HEAD) docs(lab7): make seed.json shipping explicit; require bonus artifacts, not logs
8de962e docs(lab11): fix nixpkgs pin vs go.mod collision; add network fallback pitfalls

HEAD is now at 5a4a823 docs: add PR template

On branch feature/lab2
nothing to commit, working tree clean

5a4a823 (HEAD -> feature/lab2, origin/main, origin/HEAD, main) docs: add PR template
9f41b7d (upstream/main, upstream/HEAD) docs(lab7): make seed.json shipping explicit; require bonus artifacts, not logs
8de962e docs(lab11): fix nixpkgs pin vs go.mod collision; add network fallback pitfalls
bfa345b docs(lab3): matrix renames required checks - warn + ci-ok gate pattern; set honest cache expectations
356419b docs(lab1,lab2): clarify GitHub auth vs signing SSH key roles; add publickey-denied pitfalls

5a4a823 (HEAD -> feature/lab2, origin/main, origin/HEAD, main) HEAD@{0}: reset: moving to HEAD~2
d3cd047 HEAD@{1}: commit: wip(lab2): more progress
41875be HEAD@{2}: commit: wip(lab2): start
5a4a823 (HEAD -> feature/lab2, origin/main, origin/HEAD, main) HEAD@{3}: checkout: moving from main to feature/lab2
5a4a823 (HEAD -> feature/lab2, origin/main, origin/HEAD, main) HEAD@{4}: checkout: moving from main to main
5a4a823 (HEAD -> feature/lab2, origin/main, origin/HEAD, main) HEAD@{5}: checkout: moving from feature/lab1 to main
c7ff3fd (origin/feature/lab1, feature/lab1) HEAD@{6}: commit: docs(lab1): add PR template screenshot
57732b5 HEAD@{7}: commit: docs(lab1): add screenshots
2e0fbee HEAD@{8}: commit: docs(lab1): finish submission
9a77c17 HEAD@{9}: commit: docs(lab1): start submission

RECOVER_SHA=d3cd047f9734b80ed752015021b9de399fa9ad9c

HEAD is now at d3cd047 wip(lab2): more progress

On branch feature/lab2
nothing to commit, working tree clean

d3cd047 (HEAD -> feature/lab2) wip(lab2): more progress
41875be wip(lab2): start
5a4a823 (origin/main, origin/HEAD, main) docs: add PR template
9f41b7d (upstream/main, upstream/HEAD) docs(lab7): make seed.json shipping explicit; require bonus artifacts, not logs
8de962e docs(lab11): fix nixpkgs pin vs go.mod collision; add network fallback pitfalls
```

Short explanation:

After `git reset --hard HEAD~2`, the commits were no longer in normal branch history, but they were still visible in `git reflog`. I recovered the work by resetting back to `d3cd047f9734b80ed752015021b9de399fa9ad9c`. If `git gc` had run with aggressive pruning before recovery, the unreachable commit objects could have been deleted. In that case, the reflog entry might not be enough, because the SHA could point to an object that no longer exists.

## Task 2: Tag a Release and Rebase a Feature

### 2.1 Annotated signed release tag

Commands:

```text
git switch main
git pull --ff-only origin main

$LAB_USER = "Valdezzar"
$TAG = "v0.1.0-lab2-$LAB_USER"

git tag -a -s $TAG -m "Lab 2 milestone - version control deep dive"
git push origin $TAG

git tag -l --format='%(refname:short) %(objecttype) %(*objecttype)'
git tag -v $TAG
```

Output:

```text
Switched to branch 'main'
Your branch is up to date with 'origin/main'.
From github.com:Valdezzar/DevOps-Intro
 * branch            main       -> FETCH_HEAD
Already up to date.

To github.com:Valdezzar/DevOps-Intro.git
 * [new tag]         v0.1.0-lab2-Valdezzar -> v0.1.0-lab2-Valdezzar

v0.0.1 tag commit
v0.1.0-lab2-Valdezzar tag commit

object 5a4a8231e5923be7279a9cff6911f615701004f5
type commit
tag v0.1.0-lab2-Valdezzar
tagger Valdezzar <rustamotatarian@gmail.com> 1789110792 +0300

Lab 2 milestone - version control deep dive
Good "git" signature for rustamotatarian@gmail.com with ED25519 key SHA256:DCCGV8IMH/OoC2E1ZzKwwHSUCMVOBZ+DnFJJGr8esx4
```

Short interpretation:

The tag `v0.1.0-lab2-Valdezzar` is annotated because its object type is `tag` and it points to a commit. The verification output shows a good SSH signature for my GitHub email.

### 2.2 Rebase and force-with-lease

Commands:

```text
git switch main
git commit -S -s --allow-empty -m "docs: upstream moved while you worked"
git push origin main

git switch feature/lab2
git fetch origin

Write-Host "BEFORE_REBASE"
git --no-pager log --oneline --graph --decorate -n 12

git rebase origin/main

Write-Host "AFTER_REBASE"
git --no-pager log --oneline --graph --decorate -n 12

git push --force-with-lease origin feature/lab2
```

Output before rebase:

```text
BEFORE_REBASE
* d3cd047 (HEAD -> feature/lab2, origin/feature/lab2) wip(lab2): more progress
* 41875be wip(lab2): start
* 5a4a823 (tag: v0.1.0-lab2-Valdezzar) docs: add PR template
* 9f41b7d (upstream/main, upstream/HEAD) docs(lab7): make seed.json shipping explicit; require bonus artifacts, not logs
* 8de962e docs(lab11): fix nixpkgs pin vs go.mod collision; add network fallback pitfalls
* bfa345b docs(lab3): matrix renames required checks - warn + ci-ok gate pattern; set honest cache expectations
* 356419b docs(lab1,lab2): clarify GitHub auth vs signing SSH key roles; add publickey-denied pitfalls
* 66bbd4d docs(lab1): align Task 3 GitHub Community engagement with other courses
```

Output after rebase:

```text
Successfully rebased and updated refs/heads/feature/lab2.

AFTER_REBASE
* 7da7fc9 (HEAD -> feature/lab2) wip(lab2): more progress
* 425df30 wip(lab2): start
* 54d378e (origin/main, origin/HEAD, main) docs: upstream moved while you worked
* 5a4a823 (tag: v0.1.0-lab2-Valdezzar) docs: add PR template
* 9f41b7d (upstream/main, upstream/HEAD) docs(lab7): make seed.json shipping explicit; require bonus artifacts, not logs
* 8de962e docs(lab11): fix nixpkgs pin vs go.mod collision; add network fallback pitfalls
* bfa345b docs(lab3): matrix renames required checks - warn + ci-ok gate pattern; set honest cache expectations
* 356419b docs(lab1,lab2): clarify GitHub auth vs signing SSH key roles; add publickey-denied pitfalls
* 66bbd4d docs(lab1): align Task 3 GitHub Community engagement with other courses
```

Push output:

```text
To github.com:Valdezzar/DevOps-Intro.git
 + d3cd047...7da7fc9 feature/lab2 -> feature/lab2 (forced update)
```

Short interpretation:

Before the rebase, `feature/lab2` was based on commit `5a4a823`. After the rebase, my two Lab 2 commits were replayed on top of `54d378e`, so their SHAs changed from `41875be` and `d3cd047` to `425df30` and `7da7fc9`. I used `--force-with-lease` because the branch history was rewritten.

### Merge vs rebase

I would use rebase for my own feature branch before opening or updating a PR, because it keeps the history easier to read. I would use merge when the branch is shared with other people and I do not want to rewrite commits they may already have. Merge is safer for shared long-lived branches. Rebase is cleaner for private work.

## Bonus Task

Not attempted.