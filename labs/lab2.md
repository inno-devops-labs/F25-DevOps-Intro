# Lab 2 — Version Control & Advanced Git

![difficulty](https://img.shields.io/badge/difficulty-beginner-success)
![topic](https://img.shields.io/badge/topic-Git%20%26%20Version%20Control-blue)
![points](https://img.shields.io/badge/points-10-orange)

> **Goal:** Deepen Git fundamentals: object model, reset/reflog, history visualization, tagging, and modern commands (`git switch`/`git restore`).  
> **Deliverable:** A PR from `feature/lab2` to the course repo with `labs/submission2.md` including outputs and brief explanations for each task. Submit the PR link via Moodle.

---

## Overview

In this lab you will practice:
- Inspecting Git’s object model with `git cat-file`.
- Recovering work with `git reset` and `git reflog` safely.
- Visualizing history and branches with `git log --graph`.
- Tagging commits for releases.
- Using modern commands: `git switch` and `git restore` vs `git checkout`.

---

## Tasks

### Task 1 — Git Object Model Exploration (2 pts)

**Objective:** Understand how Git stores data as blobs, trees, and commits.

#### 1.1: Create Sample Commits

1. **Make Sample Commits:**

   ```sh
   # Create a few test commits for analysis
   echo "Test content" > test.txt
   git add test.txt
   git commit -m "Add test file"
   ```

#### 1.2: Inspect Git Objects

1. **Examine Git Objects:**

   ```sh
   # Replace with real object IDs from your repo
   git cat-file -p <blob_hash>
   git cat-file -p <tree_hash>
   git cat-file -p <commit_hash>
   ```

In `labs/submission2.md`, document:
- All command outputs for object inspection.
- A 1–2 sentence explanation of what each object type represents.
- Analysis of how Git stores repository data.
- Example of blob, tree, and commit object content.

---

### Task 2 — Reset and Reflog Recovery (3 pts)

**Objective:** Practice using `git reset` variants and `git reflog` to navigate history.

#### 2.1: Create Practice Branch

1. **Set Up Practice Environment:**

   ```sh
   git switch -c git-reset-practice
   echo "First commit" > file.txt && git add file.txt && git commit -m "First commit"
   echo "Second commit" >> file.txt && git add file.txt && git commit -m "Second commit"
   echo "Third commit"  >> file.txt && git add file.txt && git commit -m "Third commit"
   ```

#### 2.2: Explore Reset Modes

1. **Test Different Reset Options:**

   ```sh
   git reset --soft HEAD~1   # move HEAD; keep index & working tree
   git reset --hard HEAD~1   # move HEAD; discard index & working tree
   git reflog                # view HEAD movement
   git reset --hard <reflog_hash>  # recover a previous state
   ```

In `labs/submission2.md`, document:
- The exact commands you ran and why.
- Snippets of `git log --oneline` and `git reflog`.
- What changed in the working tree, index, and history for each reset.
- Analysis of recovery process using reflog.

---

### Task 3 — Visualize Commit History (2 pts)

**Objective**: Use Git’s log graph to see branching and merges.

1. Create a short-lived branch, commit, then view the graph:

    ```sh
    git switch -c side-branch
    echo "Branch commit" >> history.txt
    git add history.txt && git commit -m "Side branch commit"
    git switch -
    git log --oneline --graph --all
    ```

2. In `labs/submission2.md`, include:
- A snippet/screenshot of the graph.  
- Commit messages list.  
- A 1–2 sentence reflection on how the graph aids understanding.

---

### Task 4 — Tagging Commits (1 pt)

**Objective**: Create and push lightweight tags to mark releases.

1. Tag the latest commit and push:

    ```sh
    git tag v1.0.0
    git push origin v1.0.0
    ```

2. Optionally make one more commit and tag `v1.1.0`.

3. In `labs/submission2.md`, include tag names, commands used, and associated commit hashes, plus a short note on why tags matter (versioning, CI/CD triggers, release notes).

---

### Task 5 — git switch vs git checkout vs git restore (2 pts)

**Objective**: Learn modern Git commands and when to use each.

1. Branch switching with `git switch` (preferred):

    ```sh
    git switch -c cmd-compare   # create and switch
    git switch -                # toggle back to previous branch
    ```

2. Compare with legacy `git checkout` (overloaded):

    ```sh
    git checkout -b cmd-compare-2   # also creates + switches branches
    # Note: `git checkout -- <file>` used to restore files (confusing!).
    ```

3. Restoring files with `git restore` (modern and explicit):

    ```sh
    echo "scratch" >> demo.txt
    git restore demo.txt                 # discard working tree changes
    git restore --staged demo.txt        # unstage (keep working tree)
    git restore --source=HEAD~1 demo.txt # restore from another commit
    ```

4. Summarize differences in `labs/submission2.md`.

Include the commands you ran, `git status`/`git branch` outputs, and 2–3 sentences on when to use each.

---

### Bonus — GitHub Social Interactions (optional)

**Objective**: Explore GitHub’s social features and how they support collaboration.

1. Star the course repository.  
2. Follow your professor, TAs, and at least 3 classmates.  
3. In `labs/submission2.md`, add 1–2 sentences on why stars/follows matter in open source and team projects.

---

## How to Submit

1. Create a branch for this lab and push it:

    ```bash
    git switch -c feature/lab2
    # add labs/submission2.md with your findings
    git add labs/submission2.md
    git commit -m "docs: add lab2 submission"
    git push -u origin feature/lab2
    ```

2. Open a PR from your fork's `feature/lab2` branch → **course repository's main branch**.  
3. In the PR description, include:

    ```text
    - [x] Task 1 done
    - [x] Task 2 done
    - [x] Task 3 done
    - [x] Task 4 done
    - [x] Task 5 done
    ```

4. **Copy the PR URL** and submit it via **Moodle before the deadline**.

---

## Acceptance Criteria

- ✅ Branch `feature/lab2` exists with commits for each task.
- ✅ File `labs/submission2.md` contains required outputs/explanations for Tasks 1–5.
- ✅ A tag (e.g., `v1.0.0`) is created locally and pushed to origin.
- ✅ PR from `feature/lab2` → **course repo main branch** is open.
- ✅ PR link submitted via Moodle before the deadline.

---

## Rubric (10 pts)

| Criterion                                   | Points |
| ------------------------------------------- | -----: |
| Task 1 — Object model exploration           |   **2**|
| Task 2 — Reset and reflog recovery          |   **3**|
| Task 3 — History visualization              |   **2**|
| Task 4 — Tagging commits                    |   **1**|
| Task 5 — switch vs checkout vs restore      |   **2**|
| **Total**                                   |  **10**|
---

## References

- https://git-scm.com/doc  
- https://git-scm.com/book/en/v2

---

## Guidelines

- Use clear Markdown headers to organize sections in `submission2.md`.
- Include both command outputs and written analysis for each task.
- Use clear commit messages and keep screenshots/snippets concise.
- Organize files under `labs/` and name them predictably.

> **Git Command Notes**  
> 1. Prefer `git switch`/`git restore` over legacy `git checkout` for clarity.  
> 2. Always check `git status` after reset operations to understand the state.  
> 3. Use `git reflog` for recovery when commits seem lost.

> Note: Actively explore and document your findings to gain hands-on experience with Git.
