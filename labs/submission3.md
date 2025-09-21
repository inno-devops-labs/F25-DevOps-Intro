# Lab 3 — Submission

## Task 1 — First GitHub Actions Workflow

### Run link
- [Successful workflow run](https://github.com/belyakova-anna/F25-DevOps-Intro/actions/runs/17896049687)

### Screenshots
- Workflow run list
![Workflow run list](https://github.com/user-attachments/assets/74d5d767-a089-4d07-8b43-be28e29427d4)
- Step log output
![Step log output](https://github.com/user-attachments/assets/73e61527-119c-4b73-8fb1-f22274437aef)

### Steps I followed

1. **Create a feature branch locally**

```
git switch -c feature/lab3
```

2. **Create the workflow file locally**
```
mkdir .github\workflows
echo. > .github\workflows\github-actions-demo.yml
```

4. **Paste the Quickstart YML content to `github-actions-demo.yml`** 

5. **Commit locally**

```
git add .github/workflows/github-actions-demo.yml
git commit -m "feat: add workflow"
```

6. **Push the branch to GitHub (this push triggers the workflow)**

```
git push -u origin feature/lab3
```

7. **Verify the run on GitHub**

Open repository → Actions tab → Workflow: GitHub Actions Demo → latest run.

### Key concepts learned
- **Jobs** are groups of steps executed on a single runner.
- **Steps** are the individual commands or actions inside a job.
- **Runners** are virtual machines provided by GitHub (in this case `ubuntu-latest`) where jobs run.
- **Triggers** define when workflows start. Here, the trigger was `on: push`.

### What caused the run?
The run was automatically triggered by a **push event** when I committed and pushed changes to the repository.

### Execution analysis
1. GitHub Actions created a new Ubuntu-based runner (`ubuntu-latest`).
2. It executed the steps in order:
   - Printed messages with `echo`.
   - Checked out the repository code with `actions/checkout`.
   - Listed repository files using `ls`.
3. Each step was logged and could be expanded to see detailed output.
4. The workflow finished successfully, confirming the workflow configuration works as expected.
