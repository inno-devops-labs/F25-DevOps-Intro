# Lab 3 Submission

## Task 1 — First GitHub Actions Workflow (4 pts)

```bash
git switch main
git pull origin main
git switch -c feature/lab3
```
```bash
# create labs/submission3.md
mkdir -p .github/workflows
```
Create .github/workflows/github-actions-demo.yml with basic workflow from article [Quickstart for GitHub Actions](https://docs.github.com/en/actions/get-started/quickstart)

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
      - run: echo "🍏 This job's  status is ${{ job.status }}."
```
Push
```bash
git add .github/workflows/github-actions-demo.yml
git commit -m "feat: add GitHub Actions quickstart workflow"
git push origin feature/lab3
```
### Link to the successful run:
Open GitHub Actions and see `Success status`: https://github.com/Gppovrm/F25-DevOps-Intro/actions/runs/17924187144

### Key concepts learned (jobs, steps, runners, triggers):
GitHub Actions is CI/CD platform that allows to automate build, test, and deployment pipeline.
Workflows are automated processes defined in YAML files stored in the .github/workflows/ directory. Jobs arrre group steps that run on machine, while steps are individual actions like commands or pre-built tools. Runners are GitHub's servers that execute our code, (here using Ubuntu Linux). Triggers like `on: push` automatically start workflows when events happen (here it is a push commit to a repository)
### A short note on what caused the run to trigger:
The run was triggered by a push event to the feature/lab3 branch containing the new workflow file, which activated the on: [push] trigger defined in the YAML configuration.

### Analysis of workflow execution process.

The log shows how each step was processed. The workflow began with with environment setup and informational messages about the push event and Linux runner. The checkout action successfully cloned the repository to the runner's workspace. File listing step showed the repository structure containing README.md, labs, and lectures directories. All steps completed within 6 seconds


---

## Task 2 — Manual Trigger + System Information (4 pts)
