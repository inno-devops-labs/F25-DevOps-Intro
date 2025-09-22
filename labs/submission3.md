# Lab 3 — CI/CD with GitHub Actions

## Task 1 — First GitHub Actions Workflow

**Run link:** [Successful workflow run](https://github.com/Spectre113/F25-DevOps-Intro/actions/runs/17924992140/job/50968753014)

**Key concepts learned:**
- **Job:** a set of steps executed on a runner.  
- **Step:** an individual command or action inside a job.  
- **Runner:** a virtual machine provided by GitHub to execute jobs.  
- **Trigger:** an event (like `push`) that starts the workflow.

**Trigger cause:**  
The workflow was triggered by a `push` event when I committed and pushed changes to the repository.

**Execution analysis:**  
The workflow ran on `ubuntu-latest`. It executed the defined steps successfully and printed the expected message to the logs.
