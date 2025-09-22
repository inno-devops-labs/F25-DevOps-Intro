# Lab 1 — Introduction to DevOps & Git Workflow

![difficulty](https://img.shields.io/badge/difficulty-beginner-success)
![topic](https://img.shields.io/badge/topic-DevOps%20Basics-blue)
![points](https://img.shields.io/badge/points-10-orange)

> **Goal:** Learn the basic Git workflow (fork → branch → PR) and practice secure commit practices.  
> **Deliverable:** A PR from `feature/lab1` to the course repo with `labs/submission1.md` containing all checklist items completed. Submit the PR link via Moodle.

---

## Overview

In this lab you will practice:
- Verifying commit authenticity with **SSH commit signing**.  
- Standardizing collaboration with a **PR template & checklist**.  

These are the foundation of collaboration and trust in DevOps teams.

---

## Tasks

### Task 1 — SSH Commit Signature Verification (6 pts)

**Objective:** Understand the importance of signed commits and set up SSH commit signature verification.

#### 1.1: Explore the Importance of Signed Commits

1. **Research Commit Signing Benefits:**

   - Research why commit signing is crucial for verifying the integrity and authenticity of commits.
   - Resources:
     - [GitHub Docs on SSH Commit Verification](https://docs.github.com/en/authentication/managing-commit-signature-verification/about-commit-signature-verification)
     - [Atlassian Guide to SSH and Git](https://confluence.atlassian.com/bitbucketserver/sign-commits-and-tags-with-ssh-keys-1305971205.html)

#### 1.2: Set Up SSH Commit Signing

1. **Generate SSH Key (Option A - Recommended):**

   ```sh
   ssh-keygen -t ed25519 -C "your_email@example.com"
   ```

2. **Use Existing SSH Key (Option B):**

   - Use an existing SSH key and add it to GitHub.

3. **Configure Git for SSH Signing:**

   ```sh
   git config --global user.signingkey <YOUR_SSH_KEY>
   git config --global commit.gpgSign true
   git config --global gpg.format ssh
   ```

#### 1.3: Make a Signed Commit

1. **Create and Sign Commit:**

   ```sh
   git commit -S -m "docs: add commit signing summary"
   ```

In `labs/submission1.md`, document:
- A short summary explaining the benefits of signing commits.
- Evidence of successful SSH key setup and signed commit.
- Answer: "Why is commit signing important in DevOps workflows?"
- Screenshots or verification of the "Verified" badge on GitHub.

---

### Task 2 — PR Template & Checklist (4 pts)

**Objective:** Standardize pull requests with a reusable template so reviewers see the same sections and a clear checklist every time.

> ⚠️ **One-time bootstrap:** GitHub loads PR templates from the **default branch of the base repo** (your fork’s `main`). Add the template to `main` first, then open your lab PR from `feature/lab1`.

#### 2.1: Create PR Template

1. **Template Location and Setup:**

   ```bash
   # Path: .github/pull_request_template.md
   # Commit message: docs: add PR template
   ```

2. **Template Options:**

   - **Option A (discover):** Find a concise PR template from a reputable open-source project or GitHub docs and adapt it.
   - **Option B (write your own):** Create a minimal template with these sections and a 3-item checklist:
     - Sections: **Goal**, **Changes**, **Testing**
     - Checklist (3 items): clear title, docs/README updated if needed, no secrets/large temp files
   - Keep it short and practical (aim for ≤ 30 lines).

#### 2.2: Create Lab Branch and Open PR

1. **Branch Creation:**

   ```bash
   git checkout -b feature/lab1
   git add .
   git commit -m "docs: add lab1 submission stub"
   git push -u origin feature/lab1
   ```

#### 2.3: Verify Template Application

1. **Template Verification:**

   - Open a PR from `feature/lab1` → `main` **in your fork**.
   - The PR **description auto-fills** with your sections and the **3-item checklist**.
   - Fill in *Goal / Changes / Testing* and tick the checkboxes.

In `labs/submission1.md`, document:
- Screenshot of PR template auto-filling the description.
- Evidence that `.github/pull_request_template.md` exists on main branch.
- Analysis of how PR templates improve collaboration.
- Note any challenges encountered during setup.

## Acceptance Criteria

- ✅ Branch `feature/lab1` exists with commits for each task.
- ✅ File `labs/submission1.md` contains required outputs and analysis for Tasks 1-2.
- ✅ At least one commit shows **"Verified"** (signed via SSH) on GitHub.
- ✅ File `.github/pull_request_template.md` exists on the **main** branch.
- ✅ PR from `feature/lab1` → **course repo main branch** is open.
- ✅ PR link submitted via Moodle before the deadline.

---

## How to Submit

1. Create a branch for this lab and push it to your fork:

   ```bash
   git switch -c feature/lab1
   # create labs/submission1.md with your findings
   git add labs/submission1.md
   git commit -m "docs: add lab1 submission"
   git push -u origin feature/lab1
   ```

2. Open a PR from your fork's `feature/lab1` branch → **course repository's main branch**.

3. In the PR description, include:

   ```text
   - [x] Task 1 done
   - [x] Task 2 done
   ```

4. **Copy the PR URL** and submit it via **Moodle before the deadline**.

---

## Rubric (10 pts)

| Criterion                                   | Points |
| ------------------------------------------- | -----: |
| Task 1 — SSH commit signing setup + summary |  **6** |
| Task 2 — PR template & checklist in effect  |  **4** |
| **Total**                                   | **10** |

---

## Guidelines

- Use clear Markdown headers to organize sections in `submission1.md`.
- Include both command outputs and written analysis for each task.
- Document template setup process and verification steps.
- Ensure commit signing is working correctly with verification screenshots.

> **Security Notes**  
> 1. Ensure the email on your commits matches your GitHub account for proper verification.  
> 2. Keep SSH keys secure and never commit private keys to repositories.  
> 3. Verify `gpg.format` is set to `ssh` for proper signing configuration.

> **Template Notes**  
> 1. Confirm the path is `.github/pull_request_template.md` **on `main`** before opening the PR.  
> 2. Re-open the PR description after adding the template if it didn't auto-fill.  
> 3. Keep templates short—reviewers read many PRs, concise templates get filled, long ones get ignored.
