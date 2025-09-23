# Lab 3 — CI/CD with GitHub Actions

![difficulty](https://img.shields.io/badge/difficulty-beginner-success)
![topic](https://img.shields.io/badge/topic-GitHub%20Actions%20%26%20CI%2FCD-blue)
![points](https://img.shields.io/badge/points-10-orange)

> **Goal:** Build foundational CI/CD workflows in GitHub Actions: quickstart, triggers, logs, and system information.  
> **Deliverable:** A PR from `feature/lab3` to the course repo with `labs/submission3.md` containing run links/log snippets, workflow YAML, and brief explanations for each task. Submit the PR link via Moodle.

---

## Overview

In this lab you will practice:
- Creating a minimal workflow using the official quickstart.
- Triggering workflows on `push` and manually with `workflow_dispatch`.
- Viewing run logs, understanding jobs/steps, and diagnosing failures.
- Gathering runner OS/CPU/memory information from within a job.
- Documenting findings in `labs/submission3.md` with evidence (links/snippets).

---

## Tasks

### Task 1 — First GitHub Actions Workflow (4 pts)

**Objective:** Set up a basic workflow that runs on push and prints basic info.

#### 1.1: Follow GitHub Actions Quickstart

1. **Read and Implement Quickstart:**

   - Read and follow the GitHub Actions [quickstart](https://docs.github.com/en/actions/quickstart).
   - Document all your observations, key concepts, and steps you followed.

#### 1.2: Test Workflow Trigger

1. **Push Commit and Monitor:**

   - Push a commit to trigger the workflow.
   - Observe the run details and logs in the Actions tab.

In `labs/submission3.md`, document:
- Link to the successful run (or screenshots).
- Key concepts learned (jobs, steps, runners, triggers).
- A short note on what caused the run to trigger.
- Analysis of workflow execution process.

---

### Task 2 — Manual Trigger + System Information (4 pts)

**Objective:** Add a manual trigger and capture system details from the runner.

#### 2.1: Add Manual Trigger

1. **Extend Workflow with Manual Trigger:**

   - Extend your existing GitHub Actions workflow to include a [manual trigger](https://docs.github.com/en/actions/using-workflows/triggering-a-workflow#defining-inputs-for-manually-triggered-workflows).
   - Inputs for manually triggered workflows are not needed, so you can skip them.

#### 2.2: Test Manual Dispatch

1. **Dispatch Workflow Manually:**

   - Dispatch the workflow manually from the GitHub UI (Actions → your workflow → Run workflow).

#### 2.3: Gather System Information

1. **Add System Information Collection:**

   - Modify your workflow to include an additional step for gathering system information.
   - Use the appropriate actions and steps to collect information about the runner, hardware specifications, and operating system details.

In `labs/submission3.md`, document:
- Changes made to the workflow file.
- The gathered system information from runner.
- Comparison of manual vs automatic workflow triggers.
- Analysis of runner environment and capabilities.

---

## Acceptance Criteria

- ✅ Branch `feature/lab3` exists with commits for each task.
- ✅ File `labs/submission3.md` contains required outputs and analysis for Tasks 1-2.
- ✅ Workflow runs successfully on `push` and via `workflow_dispatch`.
- ✅ PR from `feature/lab3` → **course repo main branch** is open.
- ✅ PR link submitted via Moodle before the deadline.

---

## How to Submit

1. Create a branch for this lab and push it to your fork:

   ```bash
   git switch -c feature/lab3
   # create labs/submission3.md with your findings
   git add labs/submission3.md
   git commit -m "docs: add lab3 submission"
   git push -u origin feature/lab3
   ```

2. Open a PR from your fork's `feature/lab3` branch → **course repository's main branch**.

3. In the PR description, include:

   ```text
   - [x] Task 1 done
   - [x] Task 2 done
   ```

4. **Copy the PR URL** and submit it via **Moodle before the deadline**.

---

## Rubric (10 pts)

| Criterion                                      | Points |
| ---------------------------------------------- | -----: |
| Task 1 — First workflow setup + run            |   **6**|
| Task 2 — Manual trigger + system information   |   **4**|
| **Total**                                      |  **10**|

---

## Guidelines

- Use clear Markdown headers to organize sections in `submission3.md`.
- Include both command outputs and written analysis for each task.
- Document workflow setup process and system information gathering.
- Include links to successful workflow runs or screenshots as evidence.

> **GitHub Actions Notes**  
> 1. Ensure workflow files are placed in `.github/workflows/` directory.  
> 2. Verify workflow syntax using GitHub's built-in validator.  
> 3. Monitor workflow runs in the Actions tab for debugging.
