# Lab 2 — Submission

## Task 1 — Git Object Model Exploration


**Commit hash:**  
e527cce07b2591686f7dd201296b7ad94fa6277a

**Tree hash:**  
f30432be3fc4867c3f8eb14d1c7fbb2c309a421d

**List of files (ls-tree -r HEAD):**
100644 blob 033f11449f9494a3bc949e8925b773a2fd056630 .github/pull_request_template.md
100644 blob 4db373667a50f14a411bb5c7e879690fd08aacc1 README.md
100644 blob b1f8af089a94f160ce00ed7710f07a7e9ba6c584 labs/lab1.md
100644 blob 1468ba02d6bcacd3fee5fd378cc02717a8cb2fbc labs/lab2.md
100644 blob 304628578f83a142e37ad867c4d94e0dfe3797de lectures/lec1.md
100644 blob c4f16b6b7ad4b9c00970949aba60b8d26aae656f lectures/lec2.md
100644 blob ea2355e2a67210ea365c12374146bc8c4883241c notes.txt

**Blob example (notes.txt):**
Hello

### Explanation

- **Blob:** contains content `notes.txt` with word `Hello`.
- **Tree:** describes files structure and their blob-hashe for current commit.

## Task 2 — Reset and Reflog Recovery

**Soft reset one commit:**
```bash
git reset --soft HEAD~1
# No output
```

Hard reset one commit:

```bash
git reset --hard HEAD~1
# HEAD is now at 91999d7 First commit
```

**View reflog:**

```bash
git reflog
# 91999d7 HEAD@{0}: reset: moving to HEAD~1
# 8370acf HEAD@{1}: reset: moving to HEAD~1
# c379bd4 HEAD@{2}: commit: Third commit
# 8370acf HEAD@{3}: commit: Second commit
# 91999d7 HEAD@{4}: commit: First commit
# e527cce HEAD@{5}: checkout: moving from feature/lab2 to git-reset-practice
```

**Restore branch to Second commit using reflog:**

```bash
git reset --hard "HEAD@{3}"
# HEAD is now at 8370acf Second commit
```

**Explanation:**

- --soft moves HEAD but keeps index and working directory.
- --hard moves HEAD and discards all changes in index and working directory.
- git reflog tracks HEAD movements, allowing recovery of any previous state.
- git reset --hard "HEAD@{3}" restored the branch to the state after the second commit, removing the third commit completely.


## Task 3 — Visualize Commit History

**Log output:**

```bash
* fab17fd (side-branch) Side branch commit
* 8370acf (git-reset-practice) Second commit
* 91999d7 First commit
* e527cce (feature/lab2) Task 1: add notes.txt
*   dc7bfd7 (HEAD -> main) Conflicts: removing conflicts
|\
| | *   e3d5b6d (origin/feature/lab1) Merge branch 'main' into feature/lab1
| | |\
| | |/
```

**Explanation**

The graph shows commits from multiple branches and merges.

'*' indicates commits on a branch, | and \ show branch structure and merge points.

## Task 4 — Tagging Commits

**Tags created:** `v0.1.0`, `v0.1.1`

### Commands and Outputs

List tags locally:

```bash
git tag
# v0.1.0
# v0.1.1
```

**List tags on remote:**

```bash
git ls-remote --tags origin
# dc7bfd7e8f9cb254781c04bf57bf7e61e5a1017a        refs/tags/v0.1.0
# 5368ca1fb45fa3a0022c0099f0585c5f133767f8        refs/tags/v0.1.1
```

**Explanation:**

- Tags mark specific commits as release points.
- v0.1.0 and v0.1.1 correspond to different stages of the repository

## Task 5 — git switch vs git checkout vs git restore

### Branch Switching

**Create and switch to a new branch using `git switch`:**

```bash
git switch -c cmd-compare
# Switched to a new branch 'cmd-compare'
git switch -
# Switched to branch 'main'
```

**Compare with legacy git checkout:**
```bash
git checkout -b cmd-compare-2
# Switched to a new branch 'cmd-compare-2'
```

**File restoration:**
Modify labs/lab1.md and restore changes:

```bash
echo "scratch" >> labs/lab1.md
git restore labs/lab1.md
# No output

git add labs/lab1.md
git restore --staged labs/lab1.md
# No output

git restore --source=HEAD~1 labs/lab1.md
# No output
```

**Explanation:**

- git switch — modern command for branch switching. -c creates and switches, - returns to the previous branch.
- git checkout — legacy command that also switches branches or restores files; can be confusing due to overloaded functionality.
- git restore — restores file contents explicitly. --staged removes from the index, --source restores from another commit.