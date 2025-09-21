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

