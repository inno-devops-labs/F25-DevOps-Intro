## Task 1

```bash
git cat-file -p 439bf53     # commit_hash
```
Output
```
tree dcaa1e94d50c159627af01884315276133a3d548
parent d59bfed5ef4f292af5d591d6c1883333901b8e32
author Aleliya <aleliya2005@gmail.com> 1757689894 +0300
committer Aleliya <aleliya2005@gmail.com> 1757689894 +0300
gpgsig -----BEGIN SSH SIGNATURE-----
<SSH SIGNATURE was here>
 -----END SSH SIGNATURE-----

Update test1 file
```
---

```bash
git cat-file -p dcaa1e94d50c159627af01884315276133a3d548        # tree_hash
```
Output
```
040000 tree 6997d00fd149a3c2fee5d8b20c2b39ba815498f4    .github  
100644 blob 4db373667a50f14a411bb5c7e879690fd08aacc1    README.md
040000 tree 61d4d824c8deb93779f2620042486ccda0cd241b    labs
040000 tree 1865343f08695045014e0ed223b464e5403fca25    lectures
100644 blob c6a93f3dab646d08504b538a6ef9d44713fa030f    test1.txt
```
---
```bash
git cat-file -p c6a93f3dab646d08504b538a6ef9d44713fa030f #blob_hash for test1.txt
```
Output
```
Hello World
Hello Aleliya
```


- **Blob** is the contents of a file that Git stores
- **Tree** is a folder structure that shows which files are included in a commit
- **Commit** is information about a commit: author, date, parent commit, and tree

## Task 2

I run commands below separately
```bash
git switch -c git-reset-practice
echo "First commit" > file.txt && git add file.txt && git commit -m "First commit"
echo "Second commit" >> file.txt && git add file.txt && git commit -m "Second commit"
echo "Third commit" >> file.txt && git add file.txt && git commit -m "Third commit"

git reset --soft HEAD~1   # only move the pointer one commit back, but the files remain changed
  
git reset --hard HEAD~1    # moves back a commit and deletes the changes

git reflog    # shows the history of all actions in the git

git reset --hard 75c6e75   # restores the commit
```

After commits 
```bash
 git log --oneline
```
output
```
75c6e75 (HEAD -> git-reset-practice) Third commit
b512348 Second commit
60c05b2 First commit
```
After all the commands above
```bash
git reflog
```
Output
```
75c6e75 (HEAD -> git-reset-practice) HEAD@{0}: reset: moving to 75c6e75
60c05b2 HEAD@{1}: reset: moving to HEAD~1
b512348 HEAD@{2}: reset: moving to HEAD~1
75c6e75 (HEAD -> git-reset-practice) HEAD@{3}: commit: Third commit        
b512348 HEAD@{4}: commit: Second commit
60c05b2 HEAD@{5}: commit: First commit
```

### What has changed with each reset:

- **git reset --soft HEAD~1** - the "Third commit" has disappeared from history, but the changes have remained prepared for the commit.

- **git reset --hard HEAD~1** - the "Second commit" disappeared from history and was completely deleted, the file returned to the state after the "First commit"

- **git reset --hard 75c6e75** - returned deleted commits, all changes were restored


## Task 3

### Snippet of graph
```bash
* 5c06f37 (side-branch) Side branch commit
* 75c6e75 (HEAD -> git-reset-practice) Third commit
* b512348 Second commit
* 60c05b2 First commit
* 439bf53 (feature/lab2) Update test1 file
* d59bfed Add test1 file
| * 45304a3 (origin/feature/lab1, feature/lab1) docs: add commit signing summary
|/  
* dfc39bf (origin/main, origin/HEAD, main) docs: add PR template
* 3f80c83 feat: publish lec2
* 499f2ba feat: publish lab2
* af0da89 feat: update lab1
* 74a8c27 Publish lab1
* f0485c0 Publish lec1
```

### Commit messages list
- 5c06f37 Side branch commit
- 75c6e75 Third commit
- b512348 Second commit
- 60c05b2 First commit
- 439bf53 Update test1 file
- d59bfed Add test1 file
- 45304a3 docs: add commit signing summary
- dfc39bf docs: add PR template
- 3f80c83 feat: publish lec2
- 499f2ba feat: publish lab2
- af0da89 feat: update lab1
- 74a8c27 Publish lab1
- f0485c0 Publish lec1

The graph helps you see the structure of the branches and how they diverge from the main line.
You can immediately see which branch is located, which commits are included in it,
and how everything is connected to the main branch.


## Task 4

### The commands that I used
```bash
git tag v1.0.0          #created an tag for the current commit
git push origin v1.0.0
git tag                #checked the list of tags
git show v1.0.0       #ckecked at the information about the tag
```

### Information about tag
| tag name  | commit hash |
| --- | --- |
| v1.0.0  | 439bf531946cb6e9e4a669b54d1573bb391c1ab5  |


### Tags are important
- Note the stable versions of the application
- Help CI/CD systems to automatically assemble and deploy the necessary versions
- Used to create release notes and changelog
- Easily switch between project versions

## Task 5

### The commands that I used
```bash
git switch -c cmd-compare
git switch -

echo "test" > demo.txt
git status
```
Output of "git status"
```
On branch cmd-compare
```

```bash
echo "scratch" >> demo.txt
git add demo.txt
git status
```
Output of "git status"
```
On branch cmd-compare
Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
        new file:   demo.txt
```

```bash
git restore --staged demo.txt
git status
```
Output of "git status"
```
On branch cmd-compare
```
---
```bash
git branch
```
Output
```
* cmd-compare
  feature/lab1
  feature/lab2
  git-reset-practice
  main
  side-branch
```

### When to use each command
- **git switch** - only for switching between branches and creating new branches
- **git restore** - only for working with file (undo changes, restore from commits)
- **git checkout** is an old command, best avoided