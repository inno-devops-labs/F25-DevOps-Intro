# Lab 2
## Ezovskikh Dmitriy
## d.ezovskikh@innopolis.university

## Task 1
### 1.1
```
thebruh@thebruh-PC MINGW64 ~/Desktop/DevOpsCourse/DevOps-Intro (main)
$ git rev-parse HEAD
```
```
50f7cf124ab7529c138130e3254c40fe1e604004
```

```
thebruh@thebruh-PC MINGW64 ~/Desktop/DevOpsCourse/DevOps-Intro (main)
$ git cat-file -t HEAD
```
```
commit
```

```
thebruh@thebruh-PC MINGW64 ~/Desktop/DevOpsCourse/DevOps-Intro (main)
$ git cat-file -p HEAD
```
```
tree 4e8941f4762188e39dde75dbbc42c9b8b0a2f920
parent 9f41b7deb32343a831b5e47c61533fbc7c0ce67d
author TheBruh78 <mit@ezovskih.ru> 1788821190 +0300
committer TheBruh78 <mit@ezovskih.ru> 1788821190 +0300
gpgsig -----BEGIN SSH SIGNATURE-----
 U1NIU0lHAAAAAQAAADMAAAALc3NoLWVkMjU1MTkAAAAg/IPrRWcxQeMfR1sy5R5FPtE6hm
 QRGKhvycoJxPlG65MAAAADZ2l0AAAAAAAAAAZzaGE1MTIAAABTAAAAC3NzaC1lZDI1NTE5
 AAAAQDhPoNTcxsLPCYkpEf61wcKnX2L3JJBKcHBfiYNHU9TVf4IOUxQErPQnxS/YWAgjXx
 yazSD19+17uCcXjZPqnQM=
 -----END SSH SIGNATURE-----

docs: add PR template

Signed-off-by: TheBruh78 <mit@ezovskih.ru>
```

```
thebruh@thebruh-PC MINGW64 ~/Desktop/DevOpsCourse/DevOps-Intro (main)
$ git cat-file -p 4e8941f4762188e39dde75dbbc42c9b8b0a2f920
```
```
040000 tree 1d07791eee3c3dd0955a02402b05b3a357816d8d    .github
100644 blob 1c0a1e94b7bbdd951f456cda51af6b8484cc3cee    .gitignore
100644 blob d10c04c6e7e0014f4fe883599c11747c15012d4e    README.md
040000 tree 7d0898a908e274ea809722844cdbd836f3b1c05a    app
040000 tree f4f047dd07b128eda5f899dfdaaf193f0291eaa2    labs
040000 tree c0ac2d55cf4335df659b347df3d19d0594a06b6c    lectures
```

```
thebruh@thebruh-PC MINGW64 ~/Desktop/DevOpsCourse/DevOps-Intro (main)
$ git cat-file -p 1c0a1e94b7bbdd951f456cda51af6b8484cc3cee
```
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

### 1.2
```
thebruh@thebruh-PC MINGW64 ~/Desktop/DevOpsCourse/DevOps-Intro (main)
$ ls -la .git/
total 30
drwxr-xr-x 1 thebruh 197121    0 Sep  8 23:51 ./
drwxr-xr-x 1 thebruh 197121    0 Sep  8 23:51 ../
-rw-r--r-- 1 thebruh 197121   74 Sep  8 03:23 COMMIT_EDITMSG
-rw-r--r-- 1 thebruh 197121  793 Sep  8 23:51 FETCH_HEAD
-rw-r--r-- 1 thebruh 197121   21 Sep  8 23:51 HEAD
-rw-r--r-- 1 thebruh 197121   41 Sep  8 02:16 ORIG_HEAD
-rw-r--r-- 1 thebruh 197121  562 Sep  8 01:42 config
-rw-r--r-- 1 thebruh 197121   73 Sep  8 01:09 description
drwxr-xr-x 1 thebruh 197121    0 Sep  8 01:09 hooks/
-rw-r--r-- 1 thebruh 197121 3183 Sep  8 23:51 index
drwxr-xr-x 1 thebruh 197121    0 Sep  8 01:09 info/
drwxr-xr-x 1 thebruh 197121    0 Sep  8 01:09 logs/
drwxr-xr-x 1 thebruh 197121    0 Sep  8 23:51 objects/
-rw-r--r-- 1 thebruh 197121  112 Sep  8 01:09 packed-refs
drwxr-xr-x 1 thebruh 197121    0 Sep  8 01:09 refs/

thebruh@thebruh-PC MINGW64 ~/Desktop/DevOpsCourse/DevOps-Intro (main)
$ cat .git/HEAD
ref: refs/heads/main

thebruh@thebruh-PC MINGW64 ~/Desktop/DevOpsCourse/DevOps-Intro (main)
$ ls .git/refs/heads/
feature/  main

thebruh@thebruh-PC MINGW64 ~/Desktop/DevOpsCourse/DevOps-Intro (main)
$ ls .git/objects/ | head
0a/
0c/
0e/
0f/
11/
13/
1a/
1d/
27/
31/

thebruh@thebruh-PC MINGW64 ~/Desktop/DevOpsCourse/DevOps-Intro (main)
$ find .git/objects -type f | wc -l
44
```
#### What is going on there?
`.git/HEAD` holds a pointer to a current branch. in this case - main. \
`.git/refs/heads/` shows a list of local branches \
`ls .git/objects/ | head` shows folders in a database of objects. \
`find .git/objects -type f | wc -l` shows amount of objects.
### 1.3. Reflog and disaster recovery

```
thebruh@thebruh-PC MINGW64 ~/Desktop/DevOpsCourse/DevOps-Intro (main)
$ git switch -c feature/lab2
Switched to a new branch 'feature/lab2'

thebruh@thebruh-PC MINGW64 ~/Desktop/DevOpsCourse/DevOps-Intro (feature/lab2)
$ echo "important work" > submissions/lab2.md
bash: submissions/lab2.md: No such file or directory

thebruh@thebruh-PC MINGW64 ~/Desktop/DevOpsCourse/DevOps-Intro (feature/lab2)
$ mkdir -p submissions

thebruh@thebruh-PC MINGW64 ~/Desktop/DevOpsCourse/DevOps-Intro (feature/lab2)
$ echo "important work" > submissions/lab2.md

thebruh@thebruh-PC MINGW64 ~/Desktop/DevOpsCourse/DevOps-Intro (feature/lab2)
$ git add submissions/lab2.md
warning: in the working copy of 'submissions/lab2.md', LF will be replaced by CRLF the next time Git touches it

thebruh@thebruh-PC MINGW64 ~/Desktop/DevOpsCourse/DevOps-Intro (feature/lab2)
$ git commit -S -s -m "wip(lab2): start"
[feature/lab2 b484d49] wip(lab2): start
 1 file changed, 1 insertion(+)
 create mode 100644 submissions/lab2.md

thebruh@thebruh-PC MINGW64 ~/Desktop/DevOpsCourse/DevOps-Intro (feature/lab2)
$ echo "more important work" >> submissions/lab2.md

thebruh@thebruh-PC MINGW64 ~/Desktop/DevOpsCourse/DevOps-Intro (feature/lab2)
$ git commit -S -s -am "wip(lab2): more progress"
warning: in the working copy of 'submissions/lab2.md', LF will be replaced by CRLF the next time Git touches it
[feature/lab2 6c71774] wip(lab2): more progress
 1 file changed, 1 insertion(+)

thebruh@thebruh-PC MINGW64 ~/Desktop/DevOpsCourse/DevOps-Intro (feature/lab2)
$ git reset --hard HEAD~2
HEAD is now at 50f7cf1 docs: add PR template

thebruh@thebruh-PC MINGW64 ~/Desktop/DevOpsCourse/DevOps-Intro (feature/lab2)
$ git status
On branch feature/lab2
nothing to commit, working tree clean

thebruh@thebruh-PC MINGW64 ~/Desktop/DevOpsCourse/DevOps-Intro (feature/lab2)
$ git log --oneline
50f7cf1 (HEAD -> feature/lab2, origin/main, origin/HEAD, main) docs: add PR template
9f41b7d (upstream/main, upstream/HEAD) docs(lab7): make seed.json shipping explicit; require bonus artifacts, not logs
8de962e docs(lab11): fix nixpkgs pin vs go.mod collision; add network fallback pitfalls
bfa345b docs(lab3): matrix renames required checks — warn + ci-ok gate pattern; set honest cache expectations
356419b docs(lab1,lab2): clarify GitHub auth vs signing SSH key roles; add publickey-denied pitfalls
66bbd4d docs(lab1): align Task 3 GitHub Community engagement with other courses
170000c Merge pull request #907 from inno-devops-labs/s26-refactor
d50436c (upstream/s26-refactor) fix(lab12,gitignore): Spin SDK (WAGI removed in Spin 3.x); minimal student-safe gitignore
4705a3d fix(.gitignore): stop ignoring submissions/
4082340 docs(grading,lab11,lab12): bonus labs to 4+4+2; grading rebalanced to 70-14-5-20-30 = 139%
7b16dc5 docs(lab10): switch deploy targets to card-free platforms — HF Spaces + Cloudflare Tunnel
4a05efa docs(labs): scaffold the skill — labs 5-12 stop handing students copy-paste answers
8387fb9 docs(lab3): scaffold the skill — students write their own CI yaml; GitLab as parallel path
983fba0 docs(course): rewrite README + add .gitignore for project-threaded structure
7914e37 docs(labs): refactor 12 labs to 6+4+2 (lab1) / 6+4+bonus (lab2-10) / 10pts (lab11-12)
aa5aa1c docs(lectures): rewrite lec1-10 + add reading11/12 for project-threaded course
b8fc480 feat(app): introduce QuickNotes Go service for project-threaded course
6f044dd (upstream/s26) Replace IPFS with Nix
0a87e1c refactor: reduce prescriptiveness in GitLab CI instructions
eaea715 feat: add GitLab CI alternative instructions to lab3
d6b6a03 Update lab2
87810a0 feat: remove old Exam Exemption Policy
1e1c32b feat: update structure
6c27ee7 feat: publish lecs 9 & 10
1826c36 feat: update lab7
3049f08 feat: publish lec8
da8f635 feat: introduce all labs and revised structure
04b174e feat: publish lab and lec #5
67f12f1 feat: publish labs 4&5, revise others
82d1989 feat: publish lab3 and lec3
3f80c83 feat: publish lec2
499f2ba feat: publish lab2
af0da89 feat: update lab1
74a8c27 Publish lab1
f0485c0 Publish lec1
31dd11b Publish README.md

thebruh@thebruh-PC MINGW64 ~/Desktop/DevOpsCourse/DevOps-Intro (feature/lab2)
$ git reflog
50f7cf1 (HEAD -> feature/lab2, origin/main, origin/HEAD, main) HEAD@{0}: reset: moving to HEAD~2
6c71774 HEAD@{1}: commit: wip(lab2): more progress
b484d49 HEAD@{2}: commit: wip(lab2): start
50f7cf1 (HEAD -> feature/lab2, origin/main, origin/HEAD, main) HEAD@{3}: checkout: moving from main to feature/lab2
50f7cf1 (HEAD -> feature/lab2, origin/main, origin/HEAD, main) HEAD@{4}: checkout: moving from feature/lab1 to main
115a1ec (origin/feature/lab1, feature/lab1) HEAD@{5}: commit: docs(lab1): finish submission
3721490 HEAD@{6}: checkout: moving from main to feature/lab1
50f7cf1 (HEAD -> feature/lab2, origin/main, origin/HEAD, main) HEAD@{7}: reset: moving to origin/main
a6ff3f3 HEAD@{8}: commit: test: unsigned commit (should fail)
50f7cf1 (HEAD -> feature/lab2, origin/main, origin/HEAD, main) HEAD@{9}: checkout: moving from main to main
50f7cf1 (HEAD -> feature/lab2, origin/main, origin/HEAD, main) HEAD@{10}: commit: docs: add PR template
9f41b7d (upstream/main, upstream/HEAD) HEAD@{11}: checkout: moving from feature/lab1 to main
3721490 HEAD@{12}: commit: docs(lab1): start submission
9f41b7d (upstream/main, upstream/HEAD) HEAD@{13}: checkout: moving from main to feature/lab1
9f41b7d (upstream/main, upstream/HEAD) HEAD@{14}: clone: from github.com:Salamer2/DevOps-Intro.git

= After Recovery:=
git reset --hard 6c71774

$ git status
On branch feature/lab2
nothing to commit, working tree clean

$ git log --oneline
6c71774 (HEAD -> feature/lab2) wip(lab2): more progress
b484d49 wip(lab2): start
50f7cf1 (origin/main, origin/HEAD, main) docs: add PR template
9f41b7d (upstream/main, upstream/HEAD) docs(lab7): make seed.json shipping explicit; require bonus artifacts, not logs
8de962e docs(lab11): fix nixpkgs pin vs go.mod collision; add network fallback pitfalls
bfa345b docs(lab3): matrix renames required checks — warn + ci-ok gate pattern; set honest cache expectations
356419b docs(lab1,lab2): clarify GitHub auth vs signing SSH key roles; add publickey-denied pitfalls
66bbd4d docs(lab1): align Task 3 GitHub Community engagement with other courses
170000c Merge pull request #907 from inno-devops-labs/s26-refactor
d50436c (upstream/s26-refactor) fix(lab12,gitignore): Spin SDK (WAGI removed in Spin 3.x); minimal student-safe gitignore
4705a3d fix(.gitignore): stop ignoring submissions/
4082340 docs(grading,lab11,lab12): bonus labs to 4+4+2; grading rebalanced to 70-14-5-20-30 = 139%
7b16dc5 docs(lab10): switch deploy targets to card-free platforms — HF Spaces + Cloudflare Tunnel
4a05efa docs(labs): scaffold the skill — labs 5-12 stop handing students copy-paste answers
8387fb9 docs(lab3): scaffold the skill — students write their own CI yaml; GitLab as parallel path
983fba0 docs(course): rewrite README + add .gitignore for project-threaded structure
7914e37 docs(labs): refactor 12 labs to 6+4+2 (lab1) / 6+4+bonus (lab2-10) / 10pts (lab11-12)
aa5aa1c docs(lectures): rewrite lec1-10 + add reading11/12 for project-threaded course
b8fc480 feat(app): introduce QuickNotes Go service for project-threaded course
6f044dd (upstream/s26) Replace IPFS with Nix
0a87e1c refactor: reduce prescriptiveness in GitLab CI instructions
eaea715 feat: add GitLab CI alternative instructions to lab3
d6b6a03 Update lab2
87810a0 feat: remove old Exam Exemption Policy
1e1c32b feat: update structure
6c27ee7 feat: publish lecs 9 & 10
1826c36 feat: update lab7
3049f08 feat: publish lec8
da8f635 feat: introduce all labs and revised structure
04b174e feat: publish lab and lec #5
67f12f1 feat: publish labs 4&5, revise others
82d1989 feat: publish lab3 and lec3
3f80c83 feat: publish lec2
499f2ba feat: publish lab2
af0da89 feat: update lab1
74a8c27 Publish lab1
f0485c0 Publish lec1
31dd11b Publish README.md
```

#### What would happen if git gc had run between the bad reset and your recovery?
In my case - nothing bad would happen. gc has timings, for example gc.reflogExpire. It determines, how
many days reflog will keep the entries. After a specified amount of days, reflog will delete everything that
is expired. I searched, and it appears git uses 90 days as a default value. In my case, i did everything in a
several minutes, so there was no risk of git gc deleting anything.

## Task 2. Tagging and Rebasing
### Signed tag
I succesfully created a signed tag:
```
thebruh@thebruh-PC MINGW64 ~/Desktop/DevOpsCourse/DevOps-Intro (main)
$ git tag -a -s "v0.1.0-lab2-Salamer2" -m "Lab 2 milestone — version control deep dive"

thebruh@thebruh-PC MINGW64 ~/Desktop/DevOpsCourse/DevOps-Intro (main)
$ git push origin "v0.1.0-lab2-Salamer2"
Enumerating objects: 1, done.
Counting objects: 100% (1/1), done.
Writing objects: 100% (1/1), 418 bytes | 418.00 KiB/s, done.
Total 1 (delta 0), reused 0 (delta 0), pack-reused 0 (from 0)
To github.com:Salamer2/DevOps-Intro.git
 * [new tag]         v0.1.0-lab2-Salamer2 -> v0.1.0-lab2-Salamer2

thebruh@thebruh-PC MINGW64 ~/Desktop/DevOpsCourse/DevOps-Intro (main)
$ git tag -l --format='%(refname:short) %(objecttype) %(*objecttype)'
v0.0.1 tag commit
v0.1.0-lab2-Salamer2 tag commit

thebruh@thebruh-PC MINGW64 ~/Desktop/DevOpsCourse/DevOps-Intro (main)
$ git tag -v "v0.1.0-lab2-Salamer2"
object 50f7cf124ab7529c138130e3254c40fe1e604004
type commit
tag v0.1.0-lab2-Salamer2
tagger TheBruh78 <mit@ezovskih.ru> 1788902854 +0300

Lab 2 milestone — version control deep dive
Good "git" signature for mit@ezovskih.ru with ED25519 key SHA256:+QEfxZR/v3MFcTTPH80A22V01jea3eqxxefeMcPFa0U
```
### Rebasing
#### Before rebasing
```
thebruh@thebruh-PC MINGW64 ~/Desktop/DevOpsCourse/DevOps-Intro (feature/lab2)
$ git log --oneline --graph
* 6c71774 (HEAD -> feature/lab2) wip(lab2): more progress
* b484d49 wip(lab2): start
* 50f7cf1 (tag: v0.1.0-lab2-Salamer2, origin/main, origin/HEAD, main) docs: add PR template
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
#### After rebasing
```
thebruh@thebruh-PC MINGW64 ~/Desktop/DevOpsCourse/DevOps-Intro (feature/lab2)
$ git log --oneline --graph
* 72a1106 (HEAD -> feature/lab2) wip(lab2): more progress
* 11a1f99 wip(lab2): start
* 57f14d1 (origin/main, origin/HEAD, main) docs: upstream moved while you worked
* 50f7cf1 (tag: v0.1.0-lab2-Salamer2) docs: add PR template
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

### Merge or Rebase?
I would use rebase if I'm working on a branch alone, since it modifies history to make it linear.
While it's pretty and clean, it is appropriate to use when several people are working on a branch.
For example, in outputs above, it is clearly visible, that rebasing changed the SHAs.
In case of several people working on a branch i would use merge, since it preserves history as it is and
doesn't disrupt SHAs.

## Additional task
### Bisect log
```
git bisect start
# status: waiting for both good and bad commits
# bad: [f0c9243b7c80ebb930a1ce7048a1d65b4c2ac493] docs(app): mention go test invocation
git bisect bad f0c9243b7c80ebb930a1ce7048a1d65b4c2ac493
# status: waiting for good commit(s), bad commit known
# good: [0ec87b808ae6a257a98ecea4a3c8d38a7f2c5ac7] chore(app): document versioning scheme (bisect fixture baseline)
git bisect good 0ec87b808ae6a257a98ecea4a3c8d38a7f2c5ac7
# bad: [f285ede8611e55ac0a7d01100891c0cc775e0709] refactor(store): simplify nextID restoration in load()
git bisect bad f285ede8611e55ac0a7d01100891c0cc775e0709
# good: [cb89bb9ee2ee5010b166061447eaca3ae0da2378] docs(store): comment the load() decode step
git bisect good cb89bb9ee2ee5010b166061447eaca3ae0da2378
# first bad commit: [f285ede8611e55ac0a7d01100891c0cc775e0709] refactor(store): simplify nextID restoration in load()
```

### Offending commit
```
thebruh@thebruh-PC MINGW64 ~/Desktop/DevOpsCourse/DevOps-Intro ((f285ede...)|BISECTING)
$ git bisect run sh -c 'cd app && go test ./... && go build ./...'
running 'sh' '-c' 'cd app && go test ./... && go build ./...'
--- FAIL: TestStore_PersistsAcrossReload (0.00s)
    store_test.go:78: nextID not restored: got 1, want 2
FAIL
FAIL    quicknotes      0.031s
FAIL
Bisecting: 0 revisions left to test after this (roughly 0 steps)
[cb89bb9ee2ee5010b166061447eaca3ae0da2378] docs(store): comment the load() decode step
running 'sh' '-c' 'cd app && go test ./... && go build ./...'
ok      quicknotes      0.035s
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

### How bisect found the bug in log₂(N) steps?
Basically bisect finds a problematic commit in log₂(N) steps because it uses a binary search.
Binary search algorithm is known to have log₂(N) complexity. It achieves that by eliminating half of the data each
step. In git case, it eliminates half of the commits each step. Therefore, making it extremely efficient on projects, where commits amount is huge. For example, a project with 65536 commits will be fully scanned by bisect in 16 steps.