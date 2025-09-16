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
### Task 3 — Visualize Commit History (2 pts)