# Lab 3 Submission

## Task 1 — First GitHub Actions Workflow (4 pts)

```bash
git switch main
git pull origin main
git switch -c feature/lab3
# create labs/submission3.md
mkdir -p .github/workflows
```
Create .github/workflows/github-actions-demo.yml with basic workflow from offical article [Quickstart for GitHub Actions](https://docs.github.com/en/actions/get-started/quickstart)

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

### Changes made to the workflow file
Added `workflow_dispatch` to the `on` section to enable manual triggering. Created job `Extend-Workflow-with-Manual-Trigger` with system information gathering commands including `uname -a`, `free -h`, `df -h`, and `lscpu` to capture system details.
```yaml
name: GitHub Actions Demo with Manual Trigger
run-name: ${{ github.actor }} is testing out GitHub Actions 2 task 🚀
on: 
  push:
  workflow_dispatch:

jobs:
  Extend-Workflow-with-Manual-Trigger:
    runs-on: ubuntu-latest
    steps:
      - name: Task 2 Gather System information
        run: |
          echo "=== SYSTEM INFORMATION ==="
          echo "--- OS Info ---"
          uname -a
          echo "--- Memory Usage ---"
          free -h
          echo "--- Disk Space ---"
          df -h
          echo "--- CPU Details ---"
          lscpu 
```
### Link to the successful run:
https://github.com/Gppovrm/F25-DevOps-Intro/actions/runs/17925615232/job/50970883794
### The gathered system information from runner:
```bash
Run echo "=== SYSTEM INFORMATION ==="
  echo "=== SYSTEM INFORMATION ==="
  echo "--- OS Info ---"
  uname -a
  echo "--- Memory Usage ---"
  free -h
  echo "--- Disk Space ---"
  df -h
  echo "--- CPU Details ---"
  lscpu 
  shell: /usr/bin/bash -e {0}
=== SYSTEM INFORMATION ===
--- OS Info ---
Linux runnervmf4ws1 6.11.0-1018-azure #18~24.04.1-Ubuntu SMP Sat Jun 28 04:46:03 UTC 2025 x86_64 x86_64 x86_64 GNU/Linux
--- Memory Usage ---
               total        used        free      shared  buff/cache   available
Mem:            15Gi       722Mi        13Gi        35Mi       1.5Gi        14Gi
Swap:          4.0Gi          0B       4.0Gi
--- Disk Space ---
Filesystem      Size  Used Avail Use% Mounted on
/dev/root        72G   46G   27G  64% /
tmpfs           7.9G   84K  7.9G   1% /dev/shm
tmpfs           3.2G  1.1M  3.2G   1% /run
tmpfs           5.0M     0  5.0M   0% /run/lock
/dev/sda16      881M   60M  760M   8% /boot
/dev/sda15      105M  6.2M   99M   6% /boot/efi
/dev/sdb1        74G  4.1G   66G   6% /mnt
tmpfs           1.6G   12K  1.6G   1% /run/user/1001
--- CPU Details ---
Architecture:                         x86_64
CPU op-mode(s):                       32-bit, 64-bit
Address sizes:                        48 bits physical, 48 bits virtual
Byte Order:                           Little Endian
CPU(s):                               4
On-line CPU(s) list:                  0-3
Vendor ID:                            AuthenticAMD
Model name:                           AMD EPYC 7763 64-Core Processor
CPU family:                           25
Model:                                1
Thread(s) per core:                   2
Core(s) per socket:                   2
Socket(s):                            1
Stepping:                             1
BogoMIPS:                             4890.84
Flags:                                fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ht syscall nx mmxext fxsr_opt pdpe1gb rdtscp lm constant_tsc rep_good nopl tsc_reliable nonstop_tsc cpuid extd_apicid aperfmperf tsc_known_freq pni pclmulqdq ssse3 fma cx16 pcid sse4_1 sse4_2 movbe popcnt aes xsave avx f16c rdrand hypervisor lahf_lm cmp_legacy svm cr8_legacy abm sse4a misalignsse 3dnowprefetch osvw topoext vmmcall fsgsbase bmi1 avx2 smep bmi2 erms invpcid rdseed adx smap clflushopt clwb sha_ni xsaveopt xsavec xgetbv1 xsaves user_shstk clzero xsaveerptr rdpru arat npt nrip_save tsc_scale vmcb_clean flushbyasid decodeassists pausefilter pfthreshold v_vmsave_vmload umip vaes vpclmulqdq rdpid fsrm
Virtualization:                       AMD-V
Hypervisor vendor:                    Microsoft
Virtualization type:                  full
L1d cache:                            64 KiB (2 instances)
L1i cache:                            64 KiB (2 instances)
L2 cache:                             1 MiB (2 instances)
L3 cache:                             32 MiB (1 instance)
NUMA node(s):                         1
NUMA node0 CPU(s):                    0-3
Vulnerability Gather data sampling:   Not affected
Vulnerability Itlb multihit:          Not affected
Vulnerability L1tf:                   Not affected
Vulnerability Mds:                    Not affected
Vulnerability Meltdown:               Not affected
Vulnerability Mmio stale data:        Not affected
Vulnerability Reg file data sampling: Not affected
Vulnerability Retbleed:               Not affected
Vulnerability Spec rstack overflow:   Vulnerable: Safe RET, no microcode
Vulnerability Spec store bypass:      Vulnerable
Vulnerability Spectre v1:             Mitigation; usercopy/swapgs barriers and __user pointer sanitization
Vulnerability Spectre v2:             Mitigation; Retpolines; STIBP disabled; RSB filling; PBRSB-eIBRS Not affected; BHI Not affected
Vulnerability Srbds:                  Not affected
Vulnerability Tsx async abort:        Not affected
```

### Comparison of manual vs automatic workflow triggers:
Manual triggers (`workflow_dispatch`) allow on-demand execution(provide user control), while automatic triggers (`push`) run on every code commit. 
### Analysis of runner environment and capabilities::
GitHub runners provide 4-core AMD EPYC processors with 15GB RAM on Ubuntu 24.04, efficiently handling CI/CD workflows. The Azure-virtualized environment offers 72GB storage and secure isolation, ensuring reliable and consistent pipeline execution.