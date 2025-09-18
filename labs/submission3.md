## Task 1

**Link to a successful run:**  
https://github.com/Aleliya/F25-DevOps-Intro/actions/runs/17806765021

**Key concepts learned:**
- **Workflow (.yml file):** This is an automated process that you describe in the YAML file. It is located in the folder`.github/workflows/`.
- **Triggers (on: [push]):** Events that trigger workflow. In my case, any push code is sent to the repository.
- **Jobs:** A set of steps that are performed on the same runner. I have one job it is `explore-github-actions`.
- **Steps:** Individual commands or actions that are performed sequentially within a job. The steps can run scripts `run:` or use predefined actions `uses:`.
- **Runner:** A server provided by GitHub, on which jobs are performed. In my case, this is `ubuntu-latest`.

**What caused the run to trigger?**
The launch was triggered by a `push` event, namely by sending a commit with a new workflow file `lab3-ci.yml` to the 'feature/lab3` branch.
