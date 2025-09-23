# Task 1

## Run evidence
- Link to successful run: https://github.com/n4rly-boop/F25-DevOps-Intro/actions/runs/17854829307

## Key concepts learned
- **Jobs**: A job is a set of steps that run on the same runner. In this quickstart, there is one job named `Explore-GitHub-Actions` that executes some steps on an Ubuntu runner.
- **Steps**: Individual actions executed within a job. They can be created or found on the github marketplace. The demo uses `actions/checkout@v5` and multiple `run` steps to echo info and list files.
- **Runners**: Virtual machines that execute jobs. Demo used a GitHub-hosted `ubuntu-latest` runner.
- **Triggers**: Define when workflows run. Demo workflow uses `on: [push]`, so any push to the repository triggers a run.

## What caused this run to trigger?
- The run was triggered by a `push` of [this commit](https://github.com/n4rly-boop/F25-DevOps-Intro/commit/dc75ed0f776fd4b7e96a45a7b74bebf6bc66b71e).

## Steps I followed
1. Created `.github/workflows/github-actions-demo.yml` with the quickstart workflow from GitHub Docs.
2. Committed and pushed the file to the `feature/lab3` branch to trigger `on: push`.
3. Viewed the run under the repository's Actions tab, opened the job, and expanded steps to see the [logs](https://github.com/n4rly-boop/F25-DevOps-Intro/actions/runs/17854829307/job/50771363081).

# Task 2

## Changes made to the workflow
- Added manual trigger support by changing the `on` section to include:
  ```yaml
  on:
    push:
    workflow_dispatch:
  ```
- Added a new step `Gather system information` that prints runner context and basic system details.

## Manual run evidence
- Run link: https://github.com/n4rly-boop/F25-DevOps-Intro/actions/runs/17857769756
- To enable manual trigger I needed to merge the workflow into main: https://github.com/n4rly-boop/F25-DevOps-Intro/pull/3

## Gathered system information (from logs)
```
Runner OS: Linux
Workflow: GitHub Actions Demo
Job: Explore-GitHub-Actions
Actor: n4rly-boop
Ref: refs/heads/main
SHA: 931692cfd4b3fc5532cba67ee3eb5482ceee7ed2
```
