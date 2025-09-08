# Lab 1 — Introduction to DevOps & Git Workflow

![difficulty](https://img.shields.io/badge/difficulty-beginner-success)
![topic](https://img.shields.io/badge/topic-DevOps%20Basics-blue)
![points](https://img.shields.io/badge/points-10-orange)

> **Goal:** Learn the basic Git workflow (fork → branch → PR) and practice secure commit practices.  
> **Deliverable:** A PR from `feature/lab1` with all checklist items completed.

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

1. **Explore the Importance of Signed Commits**  
   - Research why commit signing is crucial for verifying the integrity and authenticity of commits.  
   - Resources:  
     - [GitHub Docs on SSH Commit Verification](https://docs.github.com/en/authentication/managing-commit-signature-verification/about-commit-signature-verification)  
     - [Atlassian Guide to SSH and Git](https://confluence.atlassian.com/bitbucketserver/sign-commits-and-tags-with-ssh-keys-1305971205.html)  
   - Create a file `labs/submission1.md` with a short summary explaining the benefits of signing commits.

2. **Set Up SSH Commit Signing**  
   - **Option 1:** Use an existing SSH key and add it to GitHub.  
   - **Option 2 (recommended):** Generate a new key (ed25519)  
     ```sh
     ssh-keygen -t ed25519 -C "your_email@example.com"
     ```  
     Then add the public key to your GitHub account.

   - Configure Git to use your SSH key for signing:  
     ```sh
     git config --global user.signingkey <YOUR_SSH_KEY>
     git config --global commit.gpgSign true
     git config --global gpg.format ssh
     ```

3. **Make a Signed Commit**  
   - Create and sign a commit with your `submission1.md` file:  
     ```sh
     git commit -S -m "docs: add commit signing summary"
     ```  
   - Push this commit to your `feature/lab1` branch.

---

### Task 2 — PR Template & Checklist (4 pts)

**Objective:** Standardize pull requests with a reusable template so reviewers see the same sections and a clear checklist every time.

> ⚠️ **One-time bootstrap:** GitHub loads PR templates from the **default branch of the base repo** (your fork’s `main`). Add the template to `main` first, then open your lab PR from `feature/lab1`.

#### Steps

1. **Create (or source) a template on `main`**  
   Path: `.github/pull_request_template.md`  
   Commit message: `docs: add PR template`  
   - **Option A (discover):** Find a concise PR template from a reputable open-source project or GitHub docs and adapt it.  
   - **Option B (write your own):** Create a minimal template with these sections and a 3-item checklist:
     - Sections: **Goal**, **Changes**, **Testing**  
     - Checklist (3 items): clear title, docs/README updated if needed, no secrets/large temp files  
   - Keep it short and practical (aim for ≤ 30 lines).

2. **Create your lab branch and open a PR**  
   ```bash
   git checkout -b feature/lab1
   # make a change (add labs/submission1.md)
   git add .
   git commit -m "docs: add lab1 submission stub"
   git push -u origin feature/lab1
   ```

Open a PR from `feature/lab1` → `main` **in your fork**.

3. **Verify the template is applied**

   * The PR **description auto-fills** with your sections and the **3-item checklist**.
   * Fill in *Goal / Changes / Testing* and tick the checkboxes.

#### Acceptance Criteria

* ✅ Branch `feature/lab1` exists with changes committed.
* ✅ `submission1.md` is present and at least one commit in the PR shows **“Verified”** (signed via SSH) on GitHub.
* ✅ File `.github/pull_request_template.md` exists on the **main** branch.
* ✅ A PR from `feature/lab1` → `main` is open and **auto-filled** with the template, including **Goal / Changes / Testing** and the **3-item checklist** (boxes ticked).

---

## How to Submit

1. Complete all tasks.
2. Push `feature/lab1` to your fork.
3. Open a PR to your fork’s `main`.
4. In the PR description, include:

   ```text
   - [x] Task 1 done
   - [x] Task 2 done
   - [x] Screenshots attached (if applicable)
   ```

---

## Rubric (10 pts)

| Criterion                                   | Points |
| ------------------------------------------- | -----: |
| Task 1 — SSH commit signing setup + summary |  **6** |
| Task 2 — PR template & checklist in effect  |  **4** |
| **Total**                                   | **10** |

---

## Hints

> 🔐 **Signed commit not showing “Verified”?** Ensure the email on your commits matches your GitHub account and that `gpg.format` is set to `ssh`.\
> 📝 **Template didn’t load?** Confirm the path is `.github\pull_request_template.md` **on `main`** before opening the PR; re-open the PR description after adding it.\
> ✂️ **Keep it short:** Reviewers read many PRs—concise templates get filled, long ones get ignored.
