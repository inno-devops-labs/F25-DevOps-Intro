# Lab 2 Submission

## Task 1 - Git Object Model Exploration

### Commands Used:
- `git cat-file -p <blob_hash>` (4db373667a50f14a411bb5c7e879690fd08aacc1) - Shows file content
- `git cat-file -p <tree_hash>` (a10335e640753b2ad0258ad6a113e695ec4cf95e) - Shows directory structure
- `git cat-file -p <commit_hash>` (9815971) - Shows commit metadata

### Outputs:
1) # 🚀 DevOps Introduction Course: Principles, Practices & Tooling

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
2) 100644 blob b1f8af089a94f160ce00ed7710f07a7e9ba6c584    lab1.md
100644 blob 1468ba02d6bcacd3fee5fd378cc02717a8cb2fbc    lab2.md
100644 blob 411667d52f3cf22d20c521bf8703398134ce3d73    object-test.txt
3) tree 9058b84d819ee9fa97a5261d0560c31098861cbf
parent 9d0dbf71bf8942b39f857cb5c1714658d4ec2fa0
author Ivan Ilyichev <i.ilyichev@innopolis.university> 1757758944 +0300
committer Ivan Ilyichev <i.ilyichev@innopolis.university> 1757758944 +0300
gpgsig -----BEGIN SSH SIGNATURE-----
 U1NIU0lHAAAAAQAAADMAAAALc3NoLWVkMjU1MTkAAAAgxG9OJKNqhDWFRHA0IEFb07k4Zj
 8nyjRk1OaI1ul2yZ0AAAADZ2l0AAAAAAAAAAZzaGE1MTIAAABTAAAAC3NzaC1lZDI1NTE5
 AAAAQFOAjuqDyg7bE1hGc7xBlans35k3OhJmgj5bpbPD2pt30Xc6hTYI1FdKzrqr+J2e5j
 XbtVOHlqtLtyW47Yk6Pgs=
 -----END SSH SIGNATURE-----

feat: add second line to obejct test


### Explanation:
- **Blob**: Stores the actual file content as a binary object
- **Tree**: Represents a directory structure, listing files and subdirectories with their permissions and object hashes
- **Commit**: Contains metadata about the commit including author, date, message, and references to tree and parent commits


## Task 2 - Reset and Reflog Recovery

### Commands Used:
- `git log --oneline` - Showed commit logs
- `git status` - Showed current files status
- `git reset --soft HEAD~1` - Moved HEAD back one commit, kept changes staged
- `git status` - Showed current files status
- `git log --oneline` - Showed commit logs
- `git reset --hard HEAD~1` - Moved HEAD back one commit, discarded all changes
- `git status` - Showed current files status
- `git log --oneline` - Showed commit logs
- `git reflog` - Showed history of HEAD movements
- `git reset --hard <reflog_hash>` (97c2eb1) - Recovered to previous state
- `git log --oneline` - Showed commit logs

### Outputs, respectively:

**1) Git Log Output (Initial):**
```
107dff0 (HEAD -> git-reset-practice) Third commit
97c2eb1 Second commit
a075075 First commit
9815971 (feature/lab2) feat: add second line to obejct test
9d0dbf7 feat: add object test file
6689128 (origin/main, origin/HEAD, main) Merge branch 'inno-devops-labs:main' into main
3f80c83 (upstream/main, upstream/HEAD) feat: publish lec2
499f2ba feat: publish lab2
4d55fe8 docs: add PR template
af0da89 feat: update lab1
74a8c27 Publish lab1
f0485c0 Publish lec1
31dd11b Publish README.md
```

**2) Git Status Output (Initial):**
```
On branch git-reset-practice
Untracked files:
  (use "git add <file>..." to include in what will be committed)
        labs/submission2.md

nothing added to commit but untracked files present (use "git add" to track)

3) *Nothing*

4) On branch git-reset-practice
Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
        modified:   file.txt

Untracked files:
  (use "git add <file>..." to include in what will be committed)
        labs/submission2.md

5) 97c2eb1 (HEAD -> git-reset-practice) Second commit
a075075 First commit
9815971 (feature/lab2) feat: add second line to obejct test
9d0dbf7 feat: add object test file
6689128 (origin/main, origin/HEAD, main) Merge branch 'inno-devops-labs:main' into main
3f80c83 (upstream/main, upstream/HEAD) feat: publish lec2
499f2ba feat: publish lab2
4d55fe8 docs: add PR template
af0da89 feat: update lab1
74a8c27 Publish lab1
f0485c0 Publish lec1
31dd11b Publish README.md

6) HEAD is now at a075075 First commit 

7) On branch git-reset-practice
Untracked files:
  (use "git add <file>..." to include in what will be committed)
        labs/submission2.md

nothing added to commit but untracked files present (use "git add" to track)

8) a075075 (HEAD -> git-reset-practice) First commit
9815971 (feature/lab2) feat: add second line to obejct test
9d0dbf7 feat: add object test file
6689128 (origin/main, origin/HEAD, main) Merge branch 'inno-devops-labs:main' into main
3f80c83 (upstream/main, upstream/HEAD) feat: publish lec2
499f2ba feat: publish lab2
4d55fe8 docs: add PR template
af0da89 feat: update lab1
74a8c27 Publish lab1
f0485c0 Publish lec1
31dd11b Publish README.md

9) a075075 (HEAD -> git-reset-practice) HEAD@{0}: reset: moving to HEAD~1
97c2eb1 HEAD@{1}: reset: moving to HEAD~1
107dff0 HEAD@{2}: reset: moving to 107dff0
a075075 (HEAD -> git-reset-practice) HEAD@{3}: reset: moving to HEAD~1
97c2eb1 HEAD@{4}: reset: moving to HEAD~1
107dff0 HEAD@{5}: commit: Third commit
97c2eb1 HEAD@{6}: commit: Second commit
a075075 (HEAD -> git-reset-practice) HEAD@{7}: commit: First commit
9815971 (feature/lab2) HEAD@{8}: checkout: moving from feature/lab2 to git-reset-practice
9815971 (feature/lab2) HEAD@{9}: commit: feat: add second line to obejct test
9d0dbf7 HEAD@{10}: commit: feat: add object test file
6689128 (origin/main, origin/HEAD, main) HEAD@{11}: checkout: moving from main to feature/lab2
6689128 (origin/main, origin/HEAD, main) HEAD@{12}: checkout: moving from feature/lab1 to main
dea1838 (origin/feature/lab1, feature/lab1) HEAD@{13}: reset: moving to origin/feature/lab1
c615225 HEAD@{14}: checkout: moving from main to feature/lab1
6689128 (origin/main, origin/HEAD, main) HEAD@{15}: checkout: moving from feature/lab1 to main
c615225 HEAD@{16}: checkout: moving from main to feature/lab1
6689128 (origin/main, origin/HEAD, main) HEAD@{17}: reset: moving to origin/main
4d55fe8 HEAD@{18}: checkout: moving from feature/lab1 to main
c615225 HEAD@{19}: checkout: moving from main to feature/lab1
4d55fe8 HEAD@{20}: checkout: moving from main to main
4d55fe8 HEAD@{21}: checkout: moving from feature/lab1 to main
c615225 HEAD@{22}: commit: docs: add commit signing summary
4d55fe8 HEAD@{23}: checkout: moving from main to feature/lab1
4d55fe8 HEAD@{24}: commit: docs: add PR template
af0da89 HEAD@{25}: clone: from https://github.com/ivaniinno/F25-DevOps-Intro.git

10) HEAD is now at 97c2eb1 Second commit

11) 97c2eb1 (HEAD -> git-reset-practice) Second commit
a075075 First commit
9815971 (feature/lab2) feat: add second line to obejct test
9d0dbf7 feat: add object test file
6689128 (origin/main, origin/HEAD, main) Merge branch 'inno-devops-labs:main' into main
3f80c83 (upstream/main, upstream/HEAD) feat: publish lec2
499f2ba feat: publish lab2
4d55fe8 docs: add PR template
af0da89 feat: update lab1
74a8c27 Publish lab1
f0485c0 Publish lec1
31dd11b Publish README.md
```

### Changes Analysis:
- **Soft Reset**: HEAD moved back, index kept changes, working tree unchanged
- **Hard Reset**: HEAD moved back, index cleared, working tree reverted
- **Reflog Recovery**: Successfully restored to previous commit state


## Task 3 - Visualize Commit History

### Commands Used:
- `git switch -c side-branch` - Created and switched to side branch
- `git switch -` - Switched back to previous branch
- `git log --oneline --graph --all` - Showed visual commit graph

### Graph Output:
```
* 0cb3052 (side-branch) Side branch commit
| * 97c2eb1 (git-reset-practice) Second commit
| * a075075 First commit
|/  
* 9815971 (HEAD -> feature/lab2) feat: add second line to obejct test
* 9d0dbf7 feat: add object test file
*   6689128 (origin/main, origin/HEAD, main) Merge branch 'inno-devops-labs:main' into main
|\  
| * 3f80c83 (upstream/main, upstream/HEAD) feat: publish lec2
| * 499f2ba feat: publish lab2
| | * dea1838 (origin/feature/lab1, feature/lab1) Update README.md
| | * c615225 docs: add commit signing summary
| |/  
|/|   
* | 4d55fe8 docs: add PR template
|/  
* af0da89 feat: update lab1
* 74a8c27 Publish lab1
* f0485c0 Publish lec1
* 31dd11b Publish README.md
```

### Commit Messages:
- Side branch commit
- Second commit
- First commit
- feat: add second line to obejct test
- feat: add object test file
- Merge branch 'inno-devops-labs:main' into main
- feat: publish lec2
- feat: publish lab2
- Update README.md
- docs: add commit signing summary
- docs: add PR template
- feat: update lab1
- Publish lab1
- Publish lec1
- Publish README.md

### Reflection:
The graph visualization helps understand branch relationships and commit history by showing how branches diverge and merge, making it easier to track the development flow and identify where changes originated.


## Task 4 - Tagging Commits

### Commands Used:
- `git tag v1.0.0` - Created lightweight tag
- `git push origin v1.0.0` - Pushed tag to remote

### Tag Information:
- **v1.0.0**: 9815971 - Initial version

### Why Tags Matter:
Tags are crucial for versioning as they mark specific points in history for releases, trigger CI/CD pipelines, and help create release notes. They provide stable references to specific code states.


## Task 5 - git switch vs git checkout vs git restore

### Commands Used:
- `git switch -c cmd-compare` - Modern branch creation and switching
- `git branch` - Show all branches and point by * to the current one
- `git switch -` - Toggle between branches to the previous one
- `git branch` - Show all branches and point by * to the current one
- `git checkout -b cmd-compare-2` - Legacy branch creation
- `git branch` - Show all branches and point by * to the current one

- `echo "scratch" >> demo.txt` - Append to the "demo.txt" and create if if not yet
- `git add demo.txt` - Add "demo.txt"
- `git commit -m "feat: add demo file for testing"` - Commit "demo.txt"
- `git status` - Show the status on files after commiting "demo.txt"
- `git restore demo.txt` - Discard working tree changes
- `git status` - Show the status on files after restoring "demo.txt"
- `echo "staged content" >> demo.txt` - Append new changes
- `git add demo.txt` - Add new "demo.txt"
- `git status` - Show the status after updating "demo.txt"
- `git restore --staged demo.txt` - Unstage file
- `git status` - Show the status after unstaging
- `git restore --source=HEAD~1 demo.txt` - Restore from specific commit, i.e., delete demo.txt
- `git status` - Show final file status (deleted)

### Outputs, respectively:

**1) Git Switch Output:**
```
Switched to a new branch 'cmd-compare'
```

**2) Git Branch Output (After creating cmd-compare):**
```
* cmd-compare
  feature/lab1
  feature/lab2
  git-reset-practice
  main
  side-branch
``` 

**3) Git Switch Output (Toggle back):**
```
Switched to branch 'feature/lab2'
```

**4) Git Branch Output (After switching back to feature/lab2):**
```
  cmd-compare
  feature/lab1
* feature/lab2
  git-reset-practice
  main
  side-branch
```

**5) Git Checkout Output:**
```
Switched to a new branch 'cmd-compare-2'
```

**6) Git Branch Output (After creating cmd-compare-2):**
```
  cmd-compare
* cmd-compare-2
  feature/lab1
  feature/lab2
  git-reset-practice
  main
  side-branch
```

**7) Git Status Output (After creating demo.txt):**
```
On branch cmd-compare-2
Untracked files:
  (use "git add <file>..." to include in what will be committed)
        demo.txt
        labs/submission2.md

nothing added to commit but untracked files present (use "git add" to track)
```

**8) Git Status Output (After adding demo.txt):**
```
On branch cmd-compare-2
Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
        new file:   demo.txt

Untracked files:
  (use "git add <file>..." to include in what will be committed)
        labs/submission2.md
```

**9) Git Commit Output:**
```
[cmd-compare-2 881dc8b] feat: add demo file for testing
 1 file changed, 1 insertion(+)
 create mode 100644 demo.txt
```
**10) Git Status Output (After commit):**
```
On branch cmd-compare-2
Untracked files:
  (use "git add <file>..." to include in what will be committed)
        labs/submission2.md

nothing added to commit but untracked files present (use "git add" to track)
```

**11) Git Status Output (After git restore demo.txt):**
```
On branch cmd-compare-2
Untracked files:
  (use "git add <file>..." to include in what will be committed)
        labs/submission2.md

nothing added to commit but untracked files present (use "git add" to track)
```

**12) Git Status Output (After modifying demo.txt):**
```
On branch cmd-compare-2
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        modified:   demo.txt

Untracked files:
  (use "git add <file>..." to include in what will be committed)
        labs/submission2.md

no changes added to commit (use "git add" and/or "git commit -a")
```

**13) Git Status Output (After adding modified demo.txt):**
```
On branch cmd-compare-2
Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
        modified:   demo.txt

Untracked files:
  (use "git add <file>..." to include in what will be committed)
        labs/submission2.md
```

**14) Git Status Output (After git restore --staged demo.txt):**
```
On branch cmd-compare-2
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        modified:   demo.txt

Untracked files:
  (use "git add <file>..." to include in what will be committed)
        labs/submission2.md

no changes added to commit (use "git add" and/or "git commit -a")
```

**15) Git Status Output (After git restore --source=HEAD~1 demo.txt):**
```
On branch cmd-compare-2
Changes not staged for commit:
  (use "git add/rm <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        deleted:    demo.txt

Untracked files:
  (use "git add <file>..." to include in what will be committed)
        labs/submission2.md

no changes added to commit (use "git add" and/or "git commit -a")
```



### When to Use Each:
- **git switch**: Use for branch operations (create, switch, delete branches) - it's explicit and clear
- **git checkout**: Legacy command that's overloaded - avoid for new workflows
- **git restore**: Use for file restoration operations - it's specific and unambiguous