# GitHub Actions Quickstart Submission

## Link to Successful Run

- [Example of a successful workflow run](https://github.com/Clothj/F25-DevOps-Intro/actions/runs/17924869008)  
(or insert a screenshot if required)

## Key Concepts
- **Jobs**: independent tasks executed within a workflow.
- **Steps**: individual actions within a job, such as checking out the repository or running a script.
- **Runners**: virtual machines where jobs are executed (e.g., Ubuntu).
- **Triggers**: events that start a workflow (in this case — any push to any branch).

## What Triggered the Workflow
The workflow was triggered by a push commit to the repository. In the `.github/workflows/main.yml` file, the following is specified:
```yaml
on:
  push:
    branches:
      - '**'
```
This means the workflow runs on any push to any branch.

## Workflow Execution Analysis
- The runner starts a virtual machine with the Ubuntu image.
- The repository is checked out using the `actions/checkout@v4` action.
- The command `echo "Hello!"` is executed, and the result is visible in the logs.
- After all steps are completed, the runner performs cleanup.

### Successful Run Logs
```
Current runner version: '2.328.0'
Runner Image Provisioner
Operating System
Runner Image
GITHUB_TOKEN Permissions
Secret source: Actions
Prepare workflow directory
Prepare all required actions
Getting action download info
Download action repository 'actions/checkout@v4' (SHA:08eba0b27e820071cde6df949e0beb9ba4906955)
Complete job name: build
Run actions/checkout@v4
Syncing repository: Clothj/F25-DevOps-Intro
Getting Git version info
Temporarily overriding HOME='/home/runner/work/_temp/7a0947db-8c52-4e28-ac14-b400a1680c9a' before making global git config changes
Adding repository directory to the temporary git global config as a safe directory
/usr/bin/git config --global --add safe.directory /home/runner/work/F25-DevOps-Intro/F25-DevOps-Intro
Deleting the contents of '/home/runner/work/F25-DevOps-Intro/F25-DevOps-Intro'
Initializing the repository
Disabling automatic garbage collection
Setting up auth
Fetching the repository
Determining the checkout info
/usr/bin/git sparse-checkout disable
/usr/bin/git config --local --unset-all extensions.worktreeConfig
Checking out the ref
/usr/bin/git log -1 --format=%H
97b5bf7c9a9aca809be47b9a6c0a1a81008eaf71
Run echo "Hello!"
Hello!
Post job cleanup.
/usr/bin/git version
git version 2.51.0
Temporarily overriding HOME='/home/runner/work/_temp/9a11cc62-a616-44b2-8dad-543e99566c8e' before making global git config changes
Adding repository directory to the temporary git global config as a safe directory
/usr/bin/git config --global --add safe.directory /home/runner/work/F25-DevOps-Intro/F25-DevOps-Intro
/usr/bin/git config --local --name-only --get-regexp core\.sshCommand
/usr/bin/git submodule foreach --recursive sh -c "git config --local --name-only --get-regexp 'core\.sshCommand' && git config --local --unset-all 'core.sshCommand' || :"
/usr/bin/git config --local --name-only --get-regexp http\.https\://github\.com/\.extraheader
http.https://github.com/.extraheader
/usr/bin/git config --local --unset-all http.https://github.com/.extraheader
/usr/bin/git submodule foreach --recursive sh -c "git config --local --name-only --get-regexp 'http\.https\://github\.com/\.extraheader' && git config --local --unset-all 'http.https://github.com/.extraheader' || :"
Cleaning up orphan processes
```
