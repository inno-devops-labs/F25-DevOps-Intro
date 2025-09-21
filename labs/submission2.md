# Task 1 — Git Object Model Exploration

## Blob

**Command:**
```
git cat-file -p d800886d9c86731ae5c4a62b0b77c437015e00d2
```

**Output:**
```
123
```

**Description:**  
A blob is an object that stores the content of a file. In this case, it stores the content of `text.txt`.

---

## Tree

**Command:**
```
git cat-file -p 48970b9c6f9b7db827089ec2a429e2627912d762
```

**Output:**
```
100644 blob b1f8af089a94f160ce00ed7710f07a7e9ba6c584    lab1.md
100644 blob 1468ba02d6bcacd3fee5fd378cc02717a8cb2fbc    lab2.md
100644 blob d800886d9c86731ae5c4a62b0b77c437015e00d2    text.txt
```

**Description:**  
A tree is an object that stores a list of files and directories (their blob and tree references). In our example, the tree stores files inside the `labs` folder and points to their blobs.

---

## Commit

**Command:**
```
git cat-file -p a258a2f
```

**Output:**
```
tree 88d87e56d7e3ad0064d3654e0e03035a718be458
parent fe7b4151d42d2e558d6a5a480fdc1ecb88c7e824
author spiriton <i.ershov@innopolis.university> 1757987099 +0300
committer spiriton <i.ershov@innopolis.university> 1757987099 +0300
gpgsig -----BEGIN SSH SIGNATURE-----
 U1NIU0lHAAAAAQAAADMAAAALc3NoLWVkMjU1MTkAAAAgV2Ts47r8/wWn+zLpM99qSDPbpH
 fAoXAdqbhalJYr53UAAAADZ2l0AAAAAAAAAAZzaGE1MTIAAABTAAAAC3NzaC1lZDI1NTE5
 AAAAQCLPtVn51xsb4rz0ZIZWcUU4JVZCAfYtRCQwH4AysLFql+6Cjr5UbQREKXn7gWBpad
 E2UsmeHOGXINXQmXLxFgg=
 -----END SSH SIGNATURE-----

feat: add text.txt
```

**Description:**  
A commit is an object that points to a tree (the state of files), references a parent commit, and stores author, committer, and message information. In this case, the commit records the addition of text.txt to the repository.

# Task 2 — Reset and Reflog Recovery

**Objective:** Practice using `git reset` variants and `git reflog` to navigate history.

**Commands run:**
```
git switch -c git-reset-practice
echo "First commit" > file.txt && git add file.txt && git commit -m "First commit"
echo "Second commit" >> file.txt && git add file.txt && git commit -m "Second commit"
echo "Third commit"  >> file.txt && git add file.txt && git commit -m "Third commit"

git log --oneline 

git reset --soft HEAD~1   # move HEAD; keep index & working tree

git log --oneline 

git reset --hard HEAD~1   # move HEAD; discard index & working tree

git log --oneline 

git reflog                # view HEAD movement

git reset --hard 9c83b89 # recover a previous state

git log --oneline

git reflog
```

**Git log snippets:**

1. After three commits:
```
3472c49 (HEAD -> git-reset-practice) Third commit
9c83b89 Second commit
92c642f First commit
```

2. After `git reset --soft HEAD~1`:
```
9c83b89 (HEAD -> git-reset-practice) Second commit
92c642f First commit
```
- Working tree: unchanged, staged changes from `Third commit` remain.  

3. After `git reset --hard HEAD~1`:
```
92c642f (HEAD -> git-reset-practice) First commit
```
- Working tree and index: cleared.

4. After `git reset --hard 9c83b89`:
```
9c83b89 (HEAD -> git-reset-practice) Second commit
92c642f First commit
```
- Working tree and index: cleared.  

**Reflog snippet:**
```
9c83b89 (HEAD -> git-reset-practice) HEAD@{0}: reset: moving to 9c83b89
92c642f HEAD@{1}: reset: moving to HEAD~1
9c83b89 (HEAD -> git-reset-practice) HEAD@{2}: reset: moving to HEAD~1
3472c49 HEAD@{3}: commit: Third commit
9c83b89 (HEAD -> git-reset-practice) HEAD@{4}: commit: Second commit
92c642f HEAD@{5}: commit: First commit
```

# Task 3 — Visualize Commit History

**Graph Snippet:**
```
* 1fe42e5 (side-branch) Side branch commit
| * 6a9df4e (origin/feature/lab2, feature/lab2) docs: Task2
| * bc13571 docs: add lab2 submission
| * 36475b2 delete text.txt
| * a258a2f feat: add text.txt
|/
| * 9c83b89 (git-reset-practice) Second commit
| * 92c642f First commit
|/
* fe7b415 (HEAD -> main, origin/main, origin/HEAD) docs: add PR template
| * 0c38e2d (origin/feature/lab1, feature/lab1) docs: add lab1 submission stub
| * ad8e7db docs: add commit signing summary
|/
* 3f80c83 feat: publish lec2
* 499f2ba feat: publish lab2
* af0da89 feat: update lab1
* 74a8c27 Publish lab1
* f0485c0 Publish lec1
* 31dd11b Publish README.md
```

**Commit Messages List:**
- First commit  
- Second commit   
- feat: add text.txt  
- delete text.txt  
- docs: add lab2 submission  
- docs: Task2  
- Side branch commit  
- docs: add PR template  
- docs: add lab1 submission stub  
- docs: add commit signing summary  
- feat: publish lec2  
- feat: publish lab2  
- feat: update lab1  
- Publish lab1  
- Publish lec1  
- Publish README.md  

**Reflection:**
The graph visually shows the branching structure, including where side branches diverge from main development. This makes it easier to understand which commits belong to which branch and how changes flow between them.

# Task 4 — Tagging Commits

**Commands Used:**
```
git tag v1.0.0
git push origin v1.0.0
git show v1.0.0
```

**Tag Names and Associated Commits:**
- Tag: `v1.0.0`
- Commit Hash: `ac042771fe1f4cb23d279f3bb996d0ceb3e7f155`

**Note on Tags:**
Tags mark specific points in history as releases, useful for versioning, triggering CI/CD pipelines, and keeping track of release notes.

# Task 5 — git switch vs git checkout vs git restore

**1. Branch switching with git switch:**
```bash
git switch -c cmd-compare   # create and switch
git branch
git switch -                # toggle back to previous branch
```

**Git branch output:**
```
* cmd-compare
  feature/lab1
  feature/lab2
  git-reset-practice
  main
  side-branch
```

**2. Legacy git checkout:**
```bash
git checkout -b cmd-compare-2  # create and switch
git branch
```

**Git branch output:**
```
  cmd-compare
* cmd-compare-2
  feature/lab1
  feature/lab2
  git-reset-practice
  main
  side-branch
```

**3. Restoring files with git restore:**
```bash
git add demo.txt
echo "scratch" >> demo.txt
git status
git restore demo.txt                 # discard working tree changes
git status
git restore --staged demo.txt        # unstage but keep working tree
git status
git add demo.txt
git restore --source=HEAD~1 demo.txt # restore from another commit
git status
```

**Git status 1 output:**
```
On branch cmd-compare-2
Changes to be committed:
        new file:   demo.txt

Changes not staged for commit:
        modified:   demo.txt
```


**Git status 2 output:**
```
On branch cmd-compare-2
Changes to be committed:
        new file:   demo.txt

```


**Git status 3 output:**
```
On branch cmd-compare-2
Untracked files:
        demo.txt

```


**Git status 4 output:**
```
On branch cmd-compare-2
Changes to be committed:
        new file:   demo.txt

Changes not staged for commit:
        deleted:    demo.txt

```

**Summary:**  
- `git switch`: branch operations only. Safe and explicit.  
- `git restore`: file restoration only. Explicit and clear.  
- `git checkout`: legacy, can do both branch switching and file restoration, confusing.

# Bonus — GitHub Social Interactions

Stars and follows help highlight valuable projects, allow tracking of updates from contributors, and support collaboration by showing interest and engagement in the open-source community.