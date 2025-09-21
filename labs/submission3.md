# Lab 3 Submission

## Task 1 — First GitHub Actions Workflow

**Objective:** Set up a basic workflow that runs on push and prints basic info.

### 1.1 Quickstart Implementation

**Steps Followed:**
1. Navigated to the GitHub repository and clicked on the **Actions** tab.
2. Selected the suggested workflow template (Quickstart) for Node.js (or minimal workflow).
3. Copied the example workflow YAML to `.github/workflows/lab3.yml`.
4. Committed the workflow file to the branch `feature/lab3`.

**Key Concepts:**
- **Jobs:** Units of work; a workflow can have multiple jobs that run sequentially or in parallel.
- **Steps:** Individual commands or actions executed within a job.
- **Runners:** Machines that execute jobs; can be GitHub-hosted or self-hosted.
- **Triggers:** Events that start the workflow, `push`, `pull_request`, `workflow_dispatch`.

### 1.2 Test Workflow Trigger

**Actions Taken:**
1. Pushed a commit to the `feature/lab3` branch (or main branch if testing).
2. Observed the workflow execution in the **Actions** tab.
3. Clicked on the run to see job logs and step outputs.

**Workflow Run Link:**  
https://github.com/vougeress/F25-DevOps-Intro/actions/runs/17898134839

**Observation of Trigger:**
- Workflow was triggered automatically because of the `push` event.
- Each step executed sequentially, starting from `Checkout repo` to printing system info.

**Analysis of Workflow Execution:**
- **Process:** GitHub detected the push → workflow triggered → jobs executed on runner → logs collected.
- **Logs:** Useful for diagnosing failures and verifying outputs.
- **Environment:** Runner OS, CPU cores, and memory can be accessed via environment variables and commands.


## Task 2 — Manual Trigger + System Information

**Objective:** Extend the workflow with a manual trigger and collect system details from the runner.

---

### Changes Made to the Workflow File

- Added `workflow_dispatch` to the `on:` section to allow manual execution:

```yaml
on:
  push:
    branches:
      - feature/lab3
  workflow_dispatch:
```

Added a step to gather more system information: 
```yaml
      - name: Show Runner Info
        run: |
          echo "OS: $RUNNER_OS"
          echo "CPU cores: $(nproc)"
          echo "Memory: $(free -h)"
          echo "GitHub Job: $GITHUB_JOB"
          echo "Workflow triggered by: $GITHUB_EVENT_NAME"
          echo "User: $(whoami)"
          echo "Disk usage:"
          df -h
          echo "Environment variables:"
          printenv | sort
```