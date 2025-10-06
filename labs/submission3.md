## Task 1 — First GitHub Actions Workflow 

### Task 1.1
### Key Concepts Learned:

* **Workflows:** Automated procedures defined in YAML files stored in .github/workflows/
* **Jobs:** Sets of steps that execute on the same runner
* **Steps:** Individual tasks that can run commands or actions
* **Runners:** Servers that run workflows
* **Triggers:** Events that cause workflows to run (push, pull_request, etc.)

### Steps Followed:

1. Created .github/workflows/ directory in repository
2. Created basic workflow YAML file
3. Defined workflow triggers and steps
4. Committed and pushed to trigger workflow

### Task 1.2

**link to succesfull run:** https://github.com/Tehnomant/F25-DevOps-Intro/actions/runs/17926565018/job/50973957961

**What caused the run to trigger:** Pushing commits to the feature/lab3 branch

### Workflow Execution Process Analysis:

1. Commit push detected by GitHub
2. Workflow triggered based on on.push configuration
3. GitHub allocates a runner with specified OS (ubuntu-latest)
4. Steps execute sequentially:

    * Code checkout using official action

    * Shell commands to print system information
5. Each step's output logged in real-time
6. Workflow completes with success/failure status

## Task 2 — Manual Trigger + System Information

### Key Changes Made:

* **Enhanced trigger configuration:** Added workflow_dispatch with input parameters
* **Specified branches:** Limited push triggers to main and feature/lab3 branches
* **Added system information step:** Comprehensive hardware and environment data collection
* **Input parameters for manual trigger:** Environment selection and debug mode options

```text
=== SYSTEM INFORMATION REPORT ===

--- Operating System ---
OS: Linux
Kernel: 6.11.0-1018-azure
Architecture: x86_64
Hostname: runnervmf4ws1

--- Hardware Specifications ---
CPU Cores: 4
CPU Model: AMD EPYC 7763 64-Core Processor
Total Memory: 15Gi
Available Memory: 14Gi

--- Disk Usage ---
Filesystem      Size  Used Avail Use% Mounted on
/dev/root        72G   46G   27G  64% /
tmpfs           7.9G   84K  7.9G   1% /dev/shm
tmpfs           3.2G  1.1M  3.2G   1% /run
tmpfs           5.0M     0  5.0M   0% /run/lock
/dev/sda16      881M   60M  760M   8% /boot
/dev/sda15      105M  6.2M   99M   6% /boot/efi
/dev/sdb1        74G   73G     0 100% /mnt
tmpfs           1.6G   12K  1.6G   1% /run/user/1001

--- Runner Environment ---
Runner OS: Linux
Runner Name: GitHub Actions 1000000008
Workspace: /home/runner/work/F25-DevOps-Intro/F25-DevOps-Intro
GitHub API URL: https://api.github.com

--- Network Information ---
IP Address: 10.1.0.77 172.17.0.1 

--- Environment Variables ---
PATH: /snap/bin:/home/runner/.local/bin:/opt/pipx_bin:/home/runner/.cargo/bin:/home/runner/.config/composer/vendor/bin:/usr/local/.ghcup/bin:/home/runner/.dotnet/tools:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin
USER: runner
Home: /home/runner

--- GitHub Context ---
Event: workflow_dispatch
SHA: bb17ddf0dac56a4fb00562a41b91034882880994
Ref: refs/heads/main
Actor: Tehnomant
Repository: Tehnomant/F25-DevOps-Intro
Workflow: GitHub Actions Demo
```

### Comparison of Manual vs Automatic Workflow Triggers
**Manual Trigger (workflow_dispatch):**	
1. User-initiated via GitHub UI/API
2. Control	Full user control over timing
3. Supports customizable inputs
4. Testing, deployments, maintenance

**Automatic Trigger (push):**
1. Event-driven 
2. Automated based on repository events
3. Uses event context data only
4. CI/CD, automated testing, quality gates

### Performance Characteristics
* Multi-core Processing: 4 CPU cores enable true parallel task execution
* Ample Memory: 15GB RAM supports memory-intensive applications (containers, large builds)
* Fast Storage: SSD-based storage with 27GB available space
* Modern Kernel: Linux 6.11.0

### Capabilities Assessment

* **Build Performance:** Capable of handling large codebases and complex dependency trees
* **Container Support:** Sufficient resources for Docker and containerized workflows
* **Parallel Testing:** 4 cores enable efficient parallel test execution
* **Memory-Intensive Tasks:** Can run databases, services, or large applications during testing

