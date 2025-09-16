# Lab 2 Submission - Version Control & Advanced Git

Switch to a new branch
```bash
git switch -c feature/lab2
```
Create `labs/submission2.md` 

Inspect dir structure:

```bash
cd .git
tree /f
```
**Output:**

```bash
Структура папок
Серийный номер тома: 6060-C934
C:.
│   COMMIT_EDITMSG
│   config
│   description
│   FETCH_HEAD
│   HEAD
│   index
│   ORIG_HEAD
│   packed-refs
│
├───hooks
│       applypatch-msg.sample
│       commit-msg.sample
│       fsmonitor-watchman.sample
│       post-update.sample
│       pre-applypatch.sample
│       pre-commit.sample
│       pre-merge-commit.sample
│       pre-push.sample
│       pre-rebase.sample
│       pre-receive.sample
│       prepare-commit-msg.sample
│       push-to-checkout.sample
│       sendemail-validate.sample
│       update.sample
│
├───info
│       exclude
│
├───logs
│   │   HEAD
│   │
│   └───refs
│       ├───heads
│       │   │   main
│       │   │
│       │   └───feature
│       │           lab1
│       │           lab2
│       │
│       └───remotes
│           └───origin
│               │   HEAD
│               │   main
│               │
│               └───feature
│                       lab1
│
├───objects
│   ├───00
│   │       d002ae5cb6c1353c59980a7bd0cd2cb083f426
│   │
│   ├───28
│   │       61f1c8b7701af7712f4840478e0507099f1f14
│   │
│   ├───43
│   │       5f28893cc37d3807a0bb5bfa1d02c46d8576a5
│   │
│   ├───57
│   │       98f806bd18d0967d1da7014403becf55f0efac
│   │
│   ├───78
│   │       5aaab61d215a2446fc623ad38d43b4b3e3efbe
│   │
│   ├───80
│   │       514d49b64a053a45a21b9225d143eb4cdc3ac2
│   │
│   ├───8f
│   │       2325cc3c55cdfda120d2fed9f95b3d916bdc57
│   │
│   ├───a7
│   │       e4bcc5c9c38c4f727a7d9e94b8bcecc34ef936
│   │
│   ├───b3
│   │       d33688293bf4345395c3ec4ea3896620302ecf
│   │
│   ├───b7
│   │       2c0289cec77300d6137bbf793f21a7a5550979
│   │
│   ├───f1
│   │       7801abe1cfd7d682bd441ef2a5b624110b41ed
│   │
│   ├───f6
│   │       a8282fb3061798da8732c13305deb5fc5626ce
│   │
│   ├───info
│   └───pack
│           pack-1e5f810973f120cddd2275aede8d4d4c95046122.idx
│           pack-1e5f810973f120cddd2275aede8d4d4c95046122.pack
│           pack-1e5f810973f120cddd2275aede8d4d4c95046122.rev
│
└───refs
    ├───heads
    │   │   main
    │   │
    │   └───feature
    │           lab1
    │           lab2
    │
    ├───remotes
    │   └───origin
    │       │   HEAD
    │       │   main
    │       │
    │       └───feature
    │               lab1
    │
    └───tags

```

Let's check the object type from the objects folder:

```bash
git cat-file 8f23 -t
```
**Output:**
commit

```bash
git cat-file 785a -t
```
**Output:**
tree

Easily found commit and tree obj-s from list. Now lets create a new file for commit and catch blob:
```bash
echo hello it is file created to see blob type obj for task1 >labs/one.txt
git add labs/one.txt 
```
Repeat `cd .git` and `tree /f` and find new obj 07e2.

Check its type:


```bash
git cat-file 07e2 -t
```
**Output:**
```bash
blob
```

---
### Task 1 — Git Object Model Exploration (2 pts)


### Inspect objects with git cat-file

```bash
    git cat-file -p <blob_hash>
    git cat-file -p <tree_hash>
    git cat-file -p <commit_hash>
```
### Blob
**Command**: `git cat-file 07e26a865a5804dfa1f9402778bb739ea589dd22 -p`

**Output**:
```bash
hello
it
is
file
created
to
see
blob
type
obj
for
task1
```

**Explanation**: We can see that the **blob (Binary Large Object)** stores only the content of the file (one.txt) without any metadata like filename and etc.


### Tree
**Command**: `git cat-file 8d64903a316c4b3a9d40c6b4e9d14b3f088f5226 -p`

**Output**:
```bash
100644 blob 4db373667a50f14a411bb5c7e879690fd08aacc1    README.md
040000 tree b997f8ee1e0b3217235d28f7db4a85f603fc8c38    labs
040000 tree 2f0387f9eebb6ad846cd02dbd1e7a4a151c06a7e    lectures
```

**Explanation**: The `git cat-file -p` command on a `tree` object shows:

file mode | object type | object hash | file/directory name.

So, **Tree Object**- Represents a directory snapshot by storing references to obj-s along with their names and permissions(file modes).

### Commit
**Command**: `git cat-file 8ca7625dd3dfaa7cc16df3d4c002203a72e3a36b -p`

**Output**:
```bash
tree 8d64903a316c4b3a9d40c6b4e9d14b3f088f5226
parent a7e4bcc5c9c38c4f727a7d9e94b8bcecc34ef936
author Gppovrm <gpp_ovrm@mail.ru> 1758025791 +0300
committer Gppovrm <gpp_ovrm@mail.ru> 1758025791 +0300
gpgsig -----BEGIN SSH SIGNATURE-----
 U1NIU0lHAAAAAQAAADMAAAALc3NoLWVkMjU1MTkAAAAgaZbRVb/EMTsLoqGOrsET3Q0usv
 xzXMbVccVJbuwOzEUAAAADZ2l0AAAAAAAAAAZzaGE1MTIAAABTAAAAC3NzaC1lZDI1NTE5
 AAAAQNTkS056kLEVuZ/AUV+A+SGVXn6aPRkxW1XVV/m9DDVyrVXSNaF5seNF4yw7BylEIk
 xRDJ45Uo9VeM2WqDwoBgM=
 -----END SSH SIGNATURE-----

commit for task 1
```

**Explanation**: This **Сommit Object** represents a complete project snapshot that links the file system state (via tree reference), historical continuity (via parent reference), authorship metadata, SSH signature, and context (via commit message).

---
### Task 2 — Reset and Reflog Recovery (3 pts)
Create a practice branch and several commits:

```sh
    git switch -c git-reset-practice
    echo "First commit" > file.txt && git add file.txt && git commit -m "First commit"
    echo "Second commit" >> file.txt && git add file.txt && git commit -m "Second commit"
    echo "Third commit"  >> file.txt && git add file.txt && git commit -m "Third commit"
```

Before starting, let's see the current status:
```bash
# git log --oneline

2614ef1 (HEAD -> git-reset-practice) Third commit
a031e42 Second commit
c02040b First commit
851ad92 (feature/lab2) task 1 - done and described in submission2
8ca7625 commit for task 1

# git status

On branch git-reset-practice
nothing to commit, working tree clean

# cat file.txt

First commit
Second commit
Third commit
```


### git reset --soft HEAD~1   # move HEAD; keep index & working tree

```bash
# git status
On branch git-reset-practice
Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
        modified:   file.txt
# cat file.txt
First commit
Second commit
Third commit
# git log --oneline
a031e42 (HEAD -> git-reset-practice) Second commit
c02040b First commit
851ad92 (feature/lab2) task 1 - done and described in submission2
8ca7625 commit for task 1

```

**Changes observed:**  `git reset --soft` moved the branch history  back 1 commit (from "Third commit" to "Second commit"), but working tree unchanged and all file changes from the removed commit were kept and now staged and ready to be recommitted.

### git reset --hard HEAD~1   # move HEAD; discard index & working tree
**Command**: `git reset --hard HEAD~1`

**Output**: HEAD is now at c02040b First commit
```bash
# git status
On branch git-reset-practice
nothing to commit, working tree clean
# cat file.txt
First commit
# git log --oneline
c02040b (HEAD -> git-reset-practice) First commit
851ad92 (feature/lab2) task 1 - done and described in submission2
8ca7625 commit for task 1
```
**Changes observed:**  `git reset --hard` moved history back to "First commit" and completely discarded all subsequent changes from both staging area and working tree. File content reverted to only "First commit".


### View HEAD movement

**Command**: `git reflog`

**Output**:
```bash
c02040b (HEAD -> git-reset-practice) HEAD@{0}: reset: moving to HEAD~1
a031e42 HEAD@{1}: reset: moving to HEAD~1
2614ef1 HEAD@{2}: commit: Third commit
a031e42 HEAD@{3}: commit: Second commit
c02040b (HEAD -> git-reset-practice) HEAD@{4}: commit: First commit
```
**Summary:** `reflog` shows full history of HEAD movements, including both commits made **and** reset operations performed, allowing recovery of any previous state

### git reset --hard <reflog_hash>  # recover a previous state

Recover to the "Third commit" state: `git reset --hard 2614ef1`

**Output**:
HEAD is now at 2614ef1 Third commit


```bash
# git status
On branch git-reset-practice
nothing to commit, working tree clean
# cat file.txt
First commit
Second commit
Third commit
# git log --oneline
2614ef1 (HEAD -> git-reset-practice) Third commit
a031e42 Second commit
c02040b First commit
851ad92 (feature/lab2) task 1 - done and described in submission2
8ca7625 commit for task 1
```
**Summary:** Working tree, staging area, and commit history were fully restored to the exact same state as before any reset operations.

---


### Task 3 — Visualize Commit History (2 pts)

```bash
* 3db6099 (side-branch) Side branch commit
* 2614ef1 (HEAD -> git-reset-practice) Third commit
* a031e42 Second commit
* c02040b First commit
* 851ad92 (feature/lab2) task 1 - done and described in submission2
* 8ca7625 commit for task 1
* a7e4bcc (origin/feature/lab1, feature/lab1) docs: add lab1 submission stub
* 435f288 docs: add commit signing summary
| * 8f2325c (origin/main, origin/HEAD, main) docs: add PR template
|/  
* 82d1989 feat: publish lab3 and lec3
* 3f80c83 feat: publish lec2
* 499f2ba feat: publish lab2
* af0da89 feat: update lab1
* 74a8c27 Publish lab1
* f0485c0 Publish lec1
* 31dd11b Publish README.md
```

**Summary:** The commit history graph visualization shows an overview of the entire repository structure n helps quickly identify how branches relate to each other.

---

### Task 4 — Tagging Commits (1 pt)

**Commands used:**
```bash
git tag v1.0.0
git push origin v1.0.0

echo "New feature" >> feature.txt
git add feature.txt 
git commit -m "Add commit ffor tag v1.1.0"
git tag v1.1.0
git push origin v1.1.0
```
Associated commit hashes:
```bash
# git ls-remote --tags origin
2614ef1cbe26d0df2c32743b0552ecc8d2364863        refs/tags/v1.0.0
79e8ac2d28abc97c45a26ad14855600373333a74        refs/tags/v1.1.0
```
**A short note on why tags matter:** Git tags like v1.0.0 and v1.1.0 provide clear version control by marking specific project releases. They trigger CI/CD pipelines to automate building, testing, and deployment of the tagged version. The associated commit hashes ensure reproducibility allowing teams to reliably return to the exact code state of any release.

---

### Task 5 — git switch vs git checkout vs git restore (2 pts)

1.  **Creating and switching branches with `git switch`:**
    ```bash
    git switch -c cmd-compare
    git branch
    ```
    **Output:**
    ```
    * cmd-compare
      feature/lab1
      feature/lab2
      git-reset-practice
      main
      side-branch
    ```
    Back:
    ```bash
    git switch -
    git branch
    ```
    **Output:**
    ```
      cmd-compare
      feature/lab1
      feature/lab2
    * git-reset-practice
      main
      side-branch
    ```
2.  **Comparison with legacy `git checkout`:**
    **Command**:
    ```bash
    git checkout -b cmd-compare-2
    git branch
    ```
    **Output:**
    ```
      cmd-compare
    * cmd-compare-2
      feature/lab1
      feature/lab2
      git-reset-practice
      main
      side-branch
    ```

**Summary:** Both commands successfully create and switch branches. The difference is semantic: git switch is a modern, dedicated command for branch operations, while git checkout is a legacy, overloaded command that handles both branch switching and file operations, creating potential confusion. Use git switch for branches and git restore for files.

3.  **Restoring files with `git restore`:**
    ```sh
    echo "scratch" >> demo.txt
    git restore demo.txt                 # discard working tree changes
    git restore --staged demo.txt        # unstage (keep working tree)
    git restore --source=HEAD~1 demo.txt # restore from another commit
    ```
**Summary:** The `git restore demo.txt` command  discards uncommitted changes in the working directory, restoring the file to the state of the last commit. The `git restore --staged demo.txt` command only works with files previously added to the index (`git add`) and removes them from the index while preserving changes in the working directory. The `git restore --source=HEAD~1 demo.txt` command restores the file from a specific commit.

---

### Task 6 — Bonus — GitHub Social Interactions (optional)


**Actions completed:**
- ⭐ Starred the course repository
- 👥 Followed professor and TAs
- 👥 Followed at least 3 classmates

**Why stars/follows matter:** Starring the repository is a signal of quality and appreciation, which increases the project's visibility in GitHub ratings and helps others learn more about it. Following  teachers, classmates, or just people whose projects interest you creates a vital collaboration network that makes it easy to track each other's contributions, stay up-to-date with project changes, and build a learning community.