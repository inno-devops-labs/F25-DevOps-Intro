# Lab 3

## Task 1

### GitHub Actions Quickstart

1. **Branch Creation**: Created `feature/lab3` branch for this lab
2. **Workflow Directory Creation**: Created `.github/workflows/` directory structure
3. **Workflow File Creation**: Created `github-actions-demo.yml` with the provided quickstart template

```yaml
name: GitHub Actions Demo
run-name: ${{ github.actor }} is testing out GitHub Actions 🚀
on: [push]
jobs:
  Explore-GitHub-Actions:
    runs-on: ubuntu-latest
    steps:
      - run: echo "🎉 The job was automatically triggered by a ${{ github.event_name }} event."
      - run: echo "🐧 This job is now running on a ${{ runner.os }} server hosted by GitHub!"
      - run: echo "🔎 The name of your branch is ${{ github.ref }} and your repository is ${{ github.repository }}."
      - name: Check out repository code
        uses: actions/checkout@v5
      - run: echo "💡 The ${{ github.repository }} repository has been cloned to the runner."
      - run: echo "🖥️ The workflow is now ready to test your code on the runner."
      - name: List files in the repository
        run: |
          ls ${{ github.workspace }}
      - run: echo "🍏 This job's status is ${{ job.status }}."
```

#### Concepts learned from [quickstart](https://docs.github.com/en/actions/quickstart)

**Workflows**: YAML files that define automated processes, stored in `.github/workflows/` directory

**Jobs**: Units of work that run on fresh vms, can run sequentially or in parallel

**Steps**: Individual tasks within a job, can run commands or use pre-built actions

**Runners**: GitHub-hosted vms (ubuntu-latest, windows-latest, macos-latest) that execute workflows

**Triggers**: Events that start workflows (`on: [push]` means workflow runs on every push to any branch)

**Contexts**: Dynamic information available during workflow execution (e.g., `${{ github.actor }}`, `${{ runner.os }}`)

#### Workflow components

- **`name`**: Display name for the workflow in GitHub UI
- **`on: [push]`**: Trigger configuration - runs on any push event
- **`jobs`**: Contains all jobs (in this case, one job named "Explore-GitHub-Actions")
- **`runs-on`**: Specifies runner type
- **`steps`**: Sequential list of actions/commands to execute
- **`uses: actions/checkout@v5`**: Pre-built action to download repository code
- **Context variables**: `${{ github.actor }}`, `${{ runner.os }}`, etc. provides runtime information

### Analysis of [workflow](https://github.com/RailSAB/F25-DevOps-Intro/actions/runs/17894182583/job/50878574885) run

```bash
echo "🎉 The job was automatically triggered by a push event."
echo "🐧 This job is now running on a Linux server hosted by GitHub!"
echo "🔎 The name of your branch is refs/heads/feature/lab3 and your repository is RailSAB/F25-DevOps-Intro."

Run actions/checkout@v5
Syncing repository: RailSAB/F25-DevOps-Intro
Getting Git version info
  Working directory is '/home/runner/work/F25-DevOps-Intro/F25-DevOps-Intro'
  /usr/bin/git version
  git version 2.51.0
Temporarily overriding HOME='/home/runner/work/_temp/83770cb5-32d0-46c6-b20e-9439be2054cd' before making global git config changes
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
b6b118df3f3fbbd991621f42f6c9e16830eff714

echo "💡 The RailSAB/F25-DevOps-Intro repository has been cloned to the runner."
echo "🖥️ The workflow is now ready to test your code on the runner."
ls /home/runner/work/F25-DevOps-Intro/F25-DevOps-Intro
README.md
labs
lectures

echo "🍏 This job's status is success."
Post job cleanup.
```

1. **Trigger**: Push event initiates workflow
2. **Runner Allocation**: GitHub provisions fresh Ubuntu vm
3. **Job Execution**: Single job "Explore-GitHub-Actions" starts
4. **Step Execution**: Each step runs sequentially:
   - Environment information gathering
   - Repository checkout using `actions/checkout@v5`
   - File system exploration
   - Status reporting
5. **Cleanup**: Runner is destroyed after job completion

## Task 2


