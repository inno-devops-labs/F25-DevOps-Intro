# Git Objects and Commands: A Comprehensive Guide

## Task 1: Git Objects

### Commit Object
A commit object points to a tree, contains parent commit, author/committer information with timestamps, GPG signature for verification, and the commit message.

### Tree Object
A tree object represents a directory structure, listing files (blobs) and other trees with their permissions, object types, hashes, and names.

### Blob Object
A blob object stores the actual content of a file without any metadata - just the raw data that was in the file when it was committed.

---

## Task 2: Reset Operations

### Commands Used
```bash
git reset --soft HEAD~1   # move HEAD; keep index & working tree
git reset --hard HEAD~1   # move HEAD; discard index & working tree
git reflog                # view HEAD movement
git reset --hard <reflog_hash>  # recover a previous state
```

### Commit Log
```
72f8033 (HEAD -> git-reset-practice) Second commit
80adfb0 First commit
f5bca88 (feature/lab2) Task 1
4d3e215 add notes x2
491c15c add notes
ccc8bf7 (feature/lab1) Minor fix in pull_request_template
2fe432f (origin/main, origin/feature/lab1, origin/HEAD, main) docs: add commit signing summary
1cefd20 docs: add PR template
74a8c27 Publish lab1
f0485c0 Publish lec1
31dd11b Publish README.md
```

### Reflog Output
```
72f8033 (HEAD -> git-reset-practice) HEAD@{0}: reset: moving to 72f8033
80adfb0 HEAD@{1}: reset: moving to HEAD~1
72f8033 (HEAD -> git-reset-practice) HEAD@{2}: reset: moving to HEAD~1
10b07fc HEAD@{3}: commit: Third commit
72f8033 (HEAD -> git-reset-practice) HEAD@{4}: commit: Second commit
80adfb0 HEAD@{5}: commit: First commit
f5bca88 (feature/lab2) HEAD@{6}: checkout: moving from feature/lab2 to git-reset-practice
f5bca88 (feature/lab2) HEAD@{7}: commit: Task 1
4d3e215 HEAD@{8}: commit: add notes x2
491c15c HEAD@{9}: commit: add notes
ccc8bf7 (feature/lab1) HEAD@{10}: checkout: moving from feature/lab1 to feature/lab2
ccc8bf7 (feature/lab1) HEAD@{11}: commit: Minor fix in pull_request_template
```

### Changes After Each Reset Operation

#### Soft Reset (git reset --soft HEAD~1)
- **Working Tree**: Unchanged (still contained "First commit", "Second commit", "Third commit")
- **Index**: Changes from "Third commit" remained staged
- **History**: HEAD moved from "Third commit" to "Second commit"

#### Hard Reset (git reset --hard HEAD~1)
- **Working Tree**: Reverted to state of "First commit" (only contained "First commit")
- **Index**: Cleared of all staged changes from "Second commit"
- **History**: HEAD moved from "Second commit" to "First commit"

#### Recovery Reset (git reset --hard <reflog_hash>)
- **Working Tree**: Restored to state before hard reset (contained all three commits)
- **Index**: Restored staged changes that were present before hard reset
- **History**: HEAD moved back to "Third commit" state

---

## Task 3: Branch Visualization

![alt text](/files/Screenshot.png "Title")

```
* 83e4a8b (side-branch) Side branch commit
* 72f8033 (HEAD -> git-reset-practice) Second commit
* 80adfb0 First commit
* f5bca88 (feature/lab2) Task 1
* 4d3e215 add notes x2
* 491c15c add notes
* ccc8bf7 (feature/lab1) Minor fix in pull_request_template
* 2fe432f (origin/main, origin/feature/lab1, origin/HEAD, main) docs: add commit signing summary
* 1cefd20 docs: add PR template
* 74a8c27 Publish lab1
* f0485c0 Publish lec1
* 31dd11b Publish README.md
```

Even with a linear history, the graph visualization helps confirm there are no divergent branches and shows the straightforward progression of commits. This clarity is valuable for understanding that all development happened sequentially on a single branch, making it easier to trace the complete history without any merge complications or parallel work streams.

---

## Task 4: Tagging

v1.0.0 → Main branch commit

### Why Tags Matter
Tags provide stable reference points for releases, enabling precise version tracking and facilitating CI/CD pipeline triggers for specific versions. They serve as anchors for release notes, documentation, and deployment processes, marking significant milestones in a project's history and making it easy to revert to or reference specific production states.

---

## Task 5: Command Usage Guidelines

### When to Use Each Command
Use git switch exclusively for branch operations (creating, switching, and navigating between branches) as it's purpose-built and more intuitive than the overloaded git checkout. Use git restore for all file-level operations (discarding changes, unstaging files, restoring from specific commits) as it provides explicit, clear functionality without the ambiguity of git checkout -- <file>. Avoid using git checkout for new work except in legacy contexts, as the modern commands offer better clarity and reduce the risk of accidental misuse.