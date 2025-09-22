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

## Task 2 — Manual Trigger + System Information

**Run link:** [Manual workflow run](https://github.com/Spectre113/F25-DevOps-Intro/actions/runs/17925273350)

**Workflow changes:**
- Added `workflow_dispatch` trigger for manual runs.
- Added extra step to print system information (OS, CPU, memory).

**System information (snippet from logs):**
```
OS
Linux runnervmf4ws1 6.11.0-1018-azure #18~24.04.1-Ubuntu SMP Sat Jun 28 04:46:03 UTC 2025 x86_64 x86_64 x86_64 GNU/Linux

CPU
Architecture: x86_64
CPU(s): 4
Vendor ID: AuthenticAMD
Model name: AMD EPYC 7763 64-Core Processor
Virtualization: AMD-V
Hypervisor vendor: Microsoft
Memory
total used free shared buff/cache available
Mem: 15Gi 1.1Gi 13Gi 35Mi 1.5Gi 14Gi
Swap: 4.0Gi 0B 4.0Gi
```

**Comparison of triggers:**
- **Push trigger:** runs automatically when new commits are pushed.  
- **Manual trigger:** runs only when started manually from the GitHub UI.  

**Runner environment analysis:**  
The job ran on `ubuntu-latest`, hosted by GitHub.  
It provided 4 vCPUs (AMD EPYC 7763), ~15 GiB RAM, and a Linux OS running in a Microsoft Azure VM.
