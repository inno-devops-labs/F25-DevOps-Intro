# Git Object Model Exploration

## Blob Object
**Command**: `git cat-file -p 5753557b7c185256cf1d3f1a71a0fbf1a74ca7a1`
**Output**:
Hello Git Object Model

**Explanation**: Blob shows the content of the file

## Tree Object  
**Command**: `git cat-file -p 45ad2926ecf07cd963559bc30ab27d502e2a0e6c `
**Output**:
040000 tree 7ccb11d3f3a0ba03046ebab850a16cfa3808677c    .github
100644 blob 4db373667a50f14a411bb5c7e879690fd08aacc1    README.md
100644 blob 91e1d54d437291d9db210d04b9e3d85cae568b27    file1.txt
100644 blob 65fff8b3268f1903c52e82d39d2f90eb2cf7b8a5    file2.txt
040000 tree d2759bc92060101699b9848d2b0478df00de55b1    labs
040000 tree 2f0387f9eebb6ad846cd02dbd1e7a4a151c06a7e    lectures

**Explanation**: A tree represents a directory: it contains a list of files (blobs) and subdirectories with their access rights, names, and hashes.

## Commit Object
**Command**: `git cat-file -p <commit_hash>`
**Output**:
tree 45ad2926ecf07cd963559bc30ab27d502e2a0e6c
parent e5e24ade0995ad7269dca266f5a24484d25c0fea
author vougeress <petrova.kate-8530@yandex.ru> 1758005201 +0300
committer vougeress <petrova.kate-8530@yandex.ru> 1758005201 +0300
gpgsig -----BEGIN SSH SIGNATURE-----
 U1NIU0lHAAAAAQAAADMAAAALc3NoLWVkMjU1MTkAAAAgwC5yxiyY6w8T0ziuX2V7Yba3z7
 KVGzVrSjAvKPFoKjkAAAADZ2l0AAAAAAAAAAZzaGE1MTIAAABTAAAAC3NzaC1lZDI1NTE5
 AAAAQJy2HilO3PdoLS6mXPWsSfeNivROPs7aJeMZ+MifhfSwBiGnYfZJ6tJniArTUKi9oU
 CUT6aRLFzgfrVw8uz8KAg=
 -----END SSH SIGNATURE-----

Third commit: modified file1

**Explanation**: A commit represents a snapshot of the project at a certain point in time, containing a link to the tree, the parent commit, the author, and the message.


**Soft reset one commit:**
```bash
git reset --soft HEAD~1
# No output
```


```bash
git reset --hard HEAD~1
#HEAD is now at a4dde6c Third commit: modified file1
```

```bash
git reflog
#a4dde6c (HEAD -> git-reset-practice, labs/submission2.md) HEAD@{0}: reset: moving to HEAD~1
#4ba94e3 HEAD@{1}: reset: moving to HEAD~1
#1f8543f HEAD@{2}: reset: moving to HEAD~1
#e39da2b HEAD@{3}: commit: Third commit
#1f8543f HEAD@{4}: commit: Second commit
#4ba94e3 HEAD@{5}: commit: First commit
#a4dde6c (HEAD -> git-reset-practice, labs/submission2.md) HEAD@{6}: checkout: moving from labs/submission2.md to git-reset-practice
```


```bash
git reset --hard e39da2b
#HEAD is now at e39da2b Third commit
```

**Explanation**
--soft reset: Moves the HEAD, saves the changes in the staged state and the working directory. Useful for changing history without losing your job.

--hard reset: Completely deletes all changes after the target commit. A dangerous operation, but it can be restored via a reflog.

reflog: Stores the history of all HEAD movements, allowing you to restore any previous states, even after destructive operations like hard reset.

The importance of reflog: reflog is a powerful recovery tool that can save you from job loss in case of erroneous operations with git.

Specific hashes: The following hashes were used in this repository: e39da2b (Third), 1f8543f (Second), 4ba94e3 (First)

## Task 3 — Visualize Commit History

**Log output:**

```bash
* b2c5166 (side-branch) Side branch commit
| * e39da2b (git-reset-practice) Third commit
| * 1f8543f Second commit
| * 4ba94e3 First commit
|/  
* a4dde6c (HEAD -> labs/submission2.md) Third commit: modified file1
* e5e24ad Second commit: added file2
*   8a6aba3 (main) First commit: added file1
|\  
```


b2c5166 (side-branch) Side branch commit
e39da2b (HEAD -> git-reset-practice) Third commit
1f8543f Second commit
4ba94e3 First commit
a4dde6c (labs/submission2.md) Third commit: modified file1
e5e24ad Second commit: added file2
8a6aba3 (main) First commit: added file1

**Explanation**
The commit history graph visualizes the branch structure and the relationship between commits, which makes it much easier to understand the development history and track changes in different branches of the project.


# Task 4 — Tagging Commits

## Creating and Pushing Tags

**Commands used:**
```bash
git tag v1.0.0
git push origin v1.0.0

echo "New feature" >> feature.txt
git add feature.txt && git commit -m "Add new feature"
git tag v1.1.0
git push origin v1.1.0
```

**Explanation**
Tags provide immutable reference points in Git history that are essential for versioning, as they mark specific releases and enable precise tracking of production deployments. They serve as triggers for CI/CD pipelines, automate release processes, facilitate generating release notes from specific points in history, and help maintain semantic versioning consistency across development and operations teams.

## Task 5 — git switch vs git checkout vs git restore

### Branch Switching


# Task 5 — git switch vs git checkout vs git restore

## Modern Branch Operations with git switch

**Commands used:**
```bash
# Create and switch to new branch (modern)
git switch -c cmd-compare

# Toggle back to previous branch
git switch -

# Verify branch status
git branch
```
* cmd-compare
  feature/lab1
  git-reset-practice
  labs/submission2.md
  main
  side-branch

**Explanation**
  Use git switch exclusively for branch operations - creating new branches (-c flag), switching between existing branches, and toggling between recent branches (-)



  ```bash
# Create and switch with legacy command
git checkout -b cmd-compare-2

# Check current branches
git branch
```

  cmd-compare
* cmd-compare-2
  feature/lab1
  git-reset-practice
  labs/submission2.md
  main
  side-branch



 git status


 On branch cmd-compare-2
Untracked files:
  (use "git add <file>..." to include in what will be committed)
        demo.txt
        labs/submission2.md

nothing added to commit but untracked files present (use "git add" to track)


**Explanation**
Use git switch for all branch operations - it's the modern, purpose-built command specifically for creating, switching, and managing branches without the confusion of overloaded functionality.

Use git restore for file-level operations - this command clearly separates file restoration (discarding changes, unstaging, restoring from history) from branch management, making Git workflows more intuitive.

Use git checkout primarily for historical context - checking out specific commits or exploring repository history, while avoiding it for routine branch and file operations where more specific commands exist.