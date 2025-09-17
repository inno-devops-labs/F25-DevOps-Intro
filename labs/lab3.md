# Lab 3 — CI/CD with GitHub Actions

![difficulty](https://img.shields.io/badge/difficulty-beginner-success)
![topic](https://img.shields.io/badge/topic-GitHub%20Actions%20%26%20CI%2FCD-blue)
![points](https://img.shields.io/badge/points-10-orange)

> Goal: Build foundational CI/CD workflows in GitHub Actions: quickstart, triggers, logs, and system information.  
> Deliverable: A PR from `feature/lab3` with `labs/submission3.md` containing run links/log snippets, workflow YAML, and brief explanations for each task.

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

**Objective**: Set up a basic workflow that runs on push and prints basic info.

1. Read and follow the GitHub Actions [quickstart](https://docs.github.com/en/actions/quickstart).
2. Document all your observations, key concepts, and steps you followed in the `submission3.md` file.
3. Push a commit to trigger the workflow. Observe the run details and logs.
4. In `labs/submission3.md`, include:
- Link to the successful run (or screenshots).
- Key concepts learned (jobs, steps, runners, triggers).
- A short note on what caused the run to trigger.

---

### Task 2 — Manual Trigger + System Information (4 pts)

**Objective**: Add a manual trigger and capture system details from the runner.

1. Extend your existing GitHub Actions workflow to include a [manual trigger](https://docs.github.com/en/actions/using-workflows/triggering-a-workflow#defining-inputs-for-manually-triggered-workflows). Inputs for manually triggered workflows are not needed, so you can skip them.
2. Dispatch the workflow manually from the GitHub UI (Actions → your workflow → Run workflow).
3. Modify your workflow to include an additional step for gathering system information.
4. Use the appropriate actions and steps to collect information about the runner, hardware specifications, and operating system details.
5. Document the changes made to the workflow file and the gathered system information in the same `submission3.md` file.

---

## Acceptance Criteria

- Branch `feature/lab3` exists with the workflow file present.  
- File `labs/submission3.md` contains the required outputs/explanations for Tasks 1–2.  
- Workflow runs successfully on `push` and via `workflow_dispatch`.  
- PR from `feature/lab3` → `main` is open in your fork.

---

## How to Submit

1. Create a branch for this lab and push it.
2. Open a PR from `feature/lab3` → `main` in your fork.  
3. In the PR description, include:

    ```text
    - [x] Task 1 done
    - [x] Task 2 done
    ```

---

## Rubric (10 pts)

| Criterion                                      | Points |
| ---------------------------------------------- | -----: |
| Task 1 — First workflow setup + run            |   **6**|
| Task 2 — Manual trigger + system information   |   **4**|
| **Total**                                      |  **10**|
