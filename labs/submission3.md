# Task 1
### GitHub Actions
A CI/CD tool that allows to create **workflows** to automatically perform actions on specified events.

### Workflows
- Workflows are created under the `.github/workflows` directory and can have any names, but `.yaml`/`.yml` extension is mandatory.
- When an event occurs, all jobs hooked to it start running in a **cloud machine** (runner) provided by GitHub, performing the commands listed in the workflow configuration file.

### Workflow configuration
Referring to the [quickstart](https://docs.github.com/en/actions/get-started/quickstart), configurations have the following structure:
- name
- **event** on which the workflow is triggered (`on: [...]`)
- list of jobs, comprised of name, the **image** that the cloud machine will run (a virtual machine) and the **steps** (Linux commands to execute in order)
- There are special constructs called **Action contexts** that allow to leverage dynamic information about the current run (`${{ github.ref }}`)

### Running the workflow
Link to successful action run: https://github.com/kuliran/F25-DevOps-Intro/actions/runs/17864654293

### Key concepts
- Job is a workflow execution plan consisting of steps
- Step is a command to be executed in a job. If a step fails, **the whole job fails** and does not continue
- Runners are the machines that execute jobs in a workflow
- Triggers are events that initiate the execution of a workflow

# Task 2
### Manual trigger dispatch
It is enough to simply add a `workflow_dispatch` event into the array of events in the workflow<br>
The workflow **has to be on main** branch to be able to be manually triggered

### Printing runner's system info
To print system information, a step "SYSTEM INFO" was created consisting of the following commands:
- `${{ runner.os }}` - get the operating system
- `${{ runner.arch }}` - get hardware architecture
- `cat /etc/os-release` - detailed configuration about the operating system release<br><br>
Link to successful **manually-triggered** action run: https://github.com/kuliran/F25-DevOps-Intro/actions/runs/17867024927