# Task 1

## Blob
The blob object is a file that contains the content of the file.

`git cat-file -p 4db373667a50f14a411bb5c7e879690fd08aacc1`:
``````sh
# 🚀 DevOps Introduction Course: Principles, Practices & Tooling

[![Labs](https://img.shields.io/badge/Labs-80%25-blue)](#-lab-based-learning-experience)
[![Exam](https://img.shields.io/badge/Exam-20%25-orange)](#-evaluation-framework)
[![Hands-On](https://img.shields.io/badge/Focus-Hands--On%20Labs-success)](#-lab-based-learning-experience)
[![Level](https://img.shields.io/badge/Level-Bachelor-lightgrey)](#-course-roadmap)

Welcome to the **DevOps Introduction Course**, where you will gain a **solid foundation in DevOps principles and practical skills**.  
This course is designed to provide a comprehensive understanding of DevOps and its key components.  

Through **hands-on labs and lectures**, you’ll explore version control, software distribution, CI/CD, containerization, cloud computing, and beyond — the same workflows used by modern engineering teams.

---

## 📚 Course Roadmap

Practical modules designed for incremental skill development:

| #  | Module                              | Key Topics & Technologies                                                                                                 |
|----|-------------------------------------|--------------------------------------------------------------------------------------------------------------------------|
| 1  | **Introduction to DevOps**          | Core principles, essential tools, DevOps concepts                                                                        |
| 2  | **Version Control**                 | Collaborative development workflows, Git tooling                                                                         |
| 3  | **CI/CD**                           | Continuous integration/deployment practices                                                                              |
| 4  | **Networking & OS for DevOps**      | IP/DNS, firewalls, Linux fundamentals (shell/systemd/logs), permissions, troubleshooting, DevOps-friendly distros        |
| 5  | **Virtualization**                  | Virtualization concepts, benefits in modern IT infrastructures                                                           |
| 6  | **Containers**                      | Docker containerization, Kubernetes orchestration                                                                        |
| 7  | **GitOps & Progressive Delivery**   | Git as source of truth, Argo CD, canary/blue-green deployments, feature flags, rollbacks                                |
| 8  | **SRE & Resilience**                | SLOs/SLAs/SLIs, error budgets, incident management, chaos engineering, postmortems                                       |
| 9  | **Security in DevOps (DevSecOps)**  | Shift-left security, SAST/DAST, SBOM, container/image scanning (Trivy/Snyk), secret management                           |
| 10 | **Cloud Fundamentals**              | AWS/Azure/GCP basics, IaaS/PaaS/SaaS, regions/zones, pricing, core services (EC2/S3/IAM/VPC), cloud-native patterns      |
| 11 | **Bonus**                           | Web3 Infrastructure, decentralized storage, IPFS, Fleek                                                                 |

---

## 🖼 Module Flow Diagram

```mermaid
flowchart TD
    A[Intro to DevOps] --> B[Version Control]
    B --> C[CI/CD]
    C --> D[Networking & OS]
    D --> E[Virtualization]
    E --> F[Containers]
    F --> G[GitOps & Progressive Delivery]
    G --> H[SRE & Resilience]
    H --> I[Security in DevOps]
    I --> J[Cloud Fundamentals]
    J --> K[Bonus: Web3 Infrastructure]
````

---

## 🛠 Lab-Based Learning Experience

**80% of your grade comes from hands-on labs** — each designed to build real-world skills:

1. **Lab Structure**

   * Task-oriented challenges with clear objectives
   * Safe environments using containers or local VMs

2. **Submission Workflow**

   * Fork course repository → Create lab branch → Complete tasks
   * Push to fork → Open Pull Request → Receive feedback & evaluation

3. **Grading Advantage**

   * **Perfect Lab Submissions (10/10)**: Exam exemption + bonus points
   * **On-Time Submissions (≥6/10)**: Guaranteed pass (C or higher)
   * **Late Submissions**: Maximum 6/10

---

## 📊 Evaluation Framework

*Transparent assessment for skill validation*

### Grade Composition

* Labs (10 × 8 points each): **80%**
* Final Exam (comprehensive): **20%**

### Performance Tiers

* **A (90-100)**: Mastery of core concepts, innovative solutions
* **B (75-89)**: Consistent completion, minor improvements needed
* **C (60-74)**: Basic competency, needs reinforcement
* **D (0-59)**: Fundamental gaps, re-attempt required

---

## ✅ Success Path

> *"Complete all labs with ≥6/10 to pass. Perfect lab submissions grant exam exemption and bonus points toward an A."*

---
``````
## Tree
The tree object is a directory that contains the files and directories in the directory.

`git cat-file -p 6dab98cab4057b74b6857333a0609234cd4607f5`:
``````sh
040000 tree 42fc83f3f205ee536ce1006d644fff2cb36211e6    .github
100644 blob 4db373667a50f14a411bb5c7e879690fd08aacc1    README.md
040000 tree 61d4d824c8deb93779f2620042486ccda0cd241b    labs
040000 tree 1865343f08695045014e0ed223b464e5403fca25    lectures
``````
## Commit
The commit object is a commit that contains the changes to the files and directories in the directory.

`git cat-file -p d51cc37cf079ce0bc7c3346ad3b47344fa7669de`:
``````sh
tree 6dab98cab4057b74b6857333a0609234cd4607f5
parent a59c96fbda0e53d5ddbe78b8901068759c674835
parent 3f80c83133a0bfb1fb551ed31bf459e4b52fa22a
author Alexander Malyy <al3xmalyy@gmail.com> 1757428453 +0300
committer GitHub <noreply@github.com> 1757428453 +0300
gpgsig -----BEGIN PGP SIGNATURE-----
 
 wsFcBAABCAAQBQJowDrlCRC1aQ7uu5UhlAAA0TcQAHvjjvdtnBj/IOGjg2BG9c4G
 ynzcfv3vgwJ0HtMx1YS5fMMqf1F2pbYxlpfUQS3/+4szDOHZXPGl+WUQnn4cAH3C
 K68wk2nhpycD6OI0bDD9PJXfkc9bB3ndubaI36MI89blmUQry+236i4zZbu1NHva
 WGfjCToEf/lkTFzSyzZ+O4VK4XCJtgtlgbYJjRjZsz4yXOBsGCcrnUEf5tZ2b6/F
 Enrq02cfz+PGOGEYfgdnKMWssQTDufs8Ft/gkkX/CjaqSJNJh+gTENhjc6rig6c8
 xPO7rW/32sEerax/NTAGFXIhKUTJEn6MTtIZUKDMxa79MPcfTzAUydZHkgZ5ZuoN
 YtRiz/Qhceavf33G4pv7QikoH5FlOCvk66zh6Ssx0spiGEX4WgxCFsEpsPZ/ui/6
 xRaBbizYWbhRulLd+40NHaaQ01KGcRnaj1UfYtqpMOe7md+thUgjUYcqrNSzU2j6
 8b6EfE80tYzW9UD8YzQe7dOR13BwLWLy/uPjKkkPJYvFLf10w1J8oekMPyLK5K5U
 yAc9oqicJo0ayqA695dPBNryaUNSQqN1GPfEl2FVrX2CKLCMSdilm2ycwJOwtCco
 2MKuW+91vjXh/n7XiVfDRIDBaAW9PLaOsUOzKNjmkkqmU7630oWv3+lubXgkvMg+
 r0Xjd/ugWxMAupDt/yI6
 =0TRo
 -----END PGP SIGNATURE-----
 

Merge branch 'inno-devops-labs:main' into main
``````

# Task 2

## Initial State

I created a new branch `git-reset-practice` and added three commits. Below are the commands executed and the `git log --oneline` output at this stage.

```sh
git switch -c git-reset-practice
echo "First commit" > file.txt && git add file.txt && git commit -m "First commit"
echo "Second commit" >> file.txt && git add file.txt && git commit -m "Second commit"
echo "Third commit"  >> file.txt && git add file.txt && git commit -m "Third commit"
```

### `git log --oneline` after initial commits:
```
4c625ef (HEAD -> git-reset-practice) Third commit
31d4e20 Second commit
15474a4 First commit
d51cc37 (origin/main, origin/HEAD, main, feature/lab2) Merge branch 'inno-devops-labs:main' into main
```

## `git reset --soft HEAD~1`

I ran `git reset --soft HEAD~1` to move `HEAD` back by one commit (`Third commit` was removed from history), but keep the changes from `Third commit` in both the staging area (index) and the working directory.

```sh
git reset --soft HEAD~1
```

### `git log --oneline` after `git reset --soft HEAD~1`:
```
31d4e20 (HEAD -> git-reset-practice) Second commit
15474a4 First commit
d51cc37 (origin/main, origin/HEAD, main, feature/lab2) Merge branch 'inno-devops-labs:main' into main
```

### Changes:
- **Working Tree:** No changes. The `file.txt` still contains "First commit\nSecond commit\nThird commit".
- **Index:** No changes. The changes from "Third commit" are still staged.
- **History:** `HEAD` now points to `31d4e20` (Second commit). The "Third commit" (`4c625ef`) is no longer in the branch history, but its changes are preserved.

## `git reset --hard HEAD~1`

Next, I executed `git reset --hard HEAD~1`. This command moved `HEAD` back by one more commit (`Second commit` was removed from history) and also discarded the changes from both the staging area and the working directory, effectively reverting `file.txt` to the state after "First commit".

```sh
git reset --hard HEAD~1
```

### `git log --oneline` after `git reset --hard HEAD~1`:
```
15474a4 (HEAD -> git-reset-practice) First commit
d51cc37 (origin/main, origin/HEAD, main, feature/lab2) Merge branch 'inno-devops-labs:main' into main
```

### Changes:
- **Working Tree:** `file.txt` reverted to the state of "First commit", removing "Second commit" and "Third commit" content.
- **Index:** Staging area was cleared of changes from "Second commit" and "Third commit".
- **History:** `HEAD` now points to `15474a4` (First commit). Both "Second commit" and "Third commit" are removed from the branch history.

## `git reflog` and Recovery

I used `git reflog` to view the history of `HEAD` movements and then recovered a previous state using `git reset --hard <reflog_hash>`. I recovered to the `d51cc37` commit, which was the state before any commits were made on the `git-reset-practice` branch.

```sh
git reflog
git reset --hard d51cc37
```

### `git reflog` output:
```
15474a4 (HEAD -> git-reset-practice) HEAD@{0}: reset: moving to HEAD~1
31d4e20 HEAD@{1}: reset: moving to HEAD~1
4c625ef HEAD@{2}: commit: Third commit
31d4e20 HEAD@{3}: commit: Second commit
15474a4 (HEAD -> git-reset-practice) HEAD@{4}: commit: First commit
d51cc37 (origin/main, origin/HEAD, main, feature/lab2) HEAD@{5}: checkout: moving from feature/lab2 to git-reset-practice
d51cc37 (origin/main, origin/HEAD, main, feature/lab2) HEAD@{6}: checkout: moving from main to feature/lab2
d51cc37 (origin/main, origin/HEAD, main, feature/lab2) HEAD@{7}: pull --tags origin main: Fast-forward
a59c96f HEAD@{8}: commit: docs: add PR template
74a8c27 HEAD@{9}: checkout: moving from feature/lab1 to main
6dfe8fa (origin/feature/lab1, feature/lab1) HEAD@{10}: commit: docs: add commit signing summary
74a8c27 HEAD@{11}: checkout: moving from main to feature/lab1
74a8c27 HEAD@{12}: clone: from https://github.com/n4rly-boop/F25-DevOps-Intro.git
```

### `git log --oneline` after `git reset --hard d51cc37`:
```
d51cc37 (HEAD -> git-reset-practice, origin/main, origin/HEAD, main, feature/lab2) Merge branch 'inno-devops-labs:main' into main
```

### Changes:
- **Working Tree:** `file.txt` was deleted, as `d51cc37` did not contain `file.txt`.
- **Index:** Staging area was updated to reflect the `d51cc37` commit.
- **History:** `HEAD` now points to `d51cc37`. All commits made on the `git-reset-practice` branch were effectively undone, but are still recoverable via `git reflog`.

# Task 3

## Visualize Commit History
`git log --oneline --graph --all`:

```
* 227e850 (side-branch) Side branch commit
*   d51cc37 (HEAD -> git-reset-practice, origin/main, origin/HEAD, main, feature/lab2) Merge branch 'inno-devops-labs:main' into main
|\  
| * 3f80c83 feat: publish lec2
| * 499f2ba feat: publish lab2
| * af0da89 feat: update lab1
* | a59c96f docs: add PR template
|/  
| * 6dfe8fa (origin/feature/lab1, feature/lab1) docs: add commit signing summary
|/  
* 74a8c27 Publish lab1
* f0485c0 Publish lec1
* 31dd11b Publish README.md
```

### Reflection

The `git log --oneline --graph --all` command provides a clear visual representation of the repository's history, making it easy to see when branches were created, merged, or diverged. The graphical lines and asterisks visually connect commits and branches, illustrating the flow of development. This greatly aids understanding complex branching strategies and the relationships between different lines of work. By the way I am using vs code with git extension that provides a nice visual representation of the repository's history.

# Task 4

## Tagging Commits

Tags are important for marking significant points in history, such as release versions. They provide a permanent, easy-to-reference name for a specific commit, which is crucial for versioning, CI/CD triggers, and generating release notes.

```sh
git tag v1.0.0 d51cc37
git push origin v1.0.0
```

- **Tag Name:** `v1.0.0`
- **Associated Commit Hash:** `d51cc37cf079ce0bc7c3346ad3b47344fa7669de`

# Task 5

`git switch` is the preferred command for switching branches. It's designed to be clearer and less ambiguous than `git checkout` when dealing with branches.

**`git branch` output after using `git switch`:**
```
* cmd-compare
  feature/lab1
  feature/lab2
  git-reset-practice
  main
  side-branch
```


`git checkout` is a versatile but overloaded command that historically handled both branch switching and file restoration. While it can still be used for branch operations, `git switch` is now recommended for clarity.

**`git branch` output after using `git checkout`:**
```
  cmd-compare
* cmd-compare-2
  feature/lab1
  feature/lab2
  git-reset-practice
  main
  side-branch
```

### Restoring Files with `git restore`

`git restore` is the modern and explicit command for restoring files in the working tree or staging area.

**`git status` output during `git restore` demonstrations:**

*   **After `echo "scratch" > demo.txt` (untracked):**
    ```
    On branch cmd-compare-2
    Untracked files:
      (use "git add <file>..." to include in what will be committed)
            demo.txt
            labs/submission2.md

    nothing added to commit but untracked files present (use "git add" to track)
    ```

*   **After `git add demo.txt` (staged):**
    ```
    On branch cmd-compare-2
    Changes to be committed:
      (use "git restore --staged <file>..." to unstage)
            new file:   demo.txt

    Untracked files:
      (use "git add <file>..." to include in what will be committed)
            labs/submission2.md
    ```

*   **After `git restore --staged demo.txt` (unstaged, working tree intact):**
    ```
    On branch cmd-compare-2
    Untracked files:
      (use "git add <file>..." to include in what will be committed)
            demo.txt
            labs/submission2.md

    nothing added to commit but untracked files present (use "git add" to track)
    ```

### Summary of Differences

*   **`git switch`**: switch between branches
*   **`git checkout`**: switch between branches and restore files (`git switch` + `git restore`)
*   **`git restore`**: restore files in the working tree or staging area
