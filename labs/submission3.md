# Lab 3 — CI/CD with GitHub Actions

Goal: Build foundational CI/CD workflows in GitHub Actions: quickstart, triggers, logs, and system information.

------------------------------------------------------------
# Task 1 — First GitHub Actions Workflow (4 pts)

## 1.1 Following GitHub Actions Quickstart

I followed the GitHub Actions Quickstart Guide and created a minimal workflow file

Key steps performed:
- Created .github/workflows/github-actions-demo.yml.
- Added on: [push] to trigger on push.
- Used actions/checkout@v5 to clone the repo.
- Added run steps to print runner and environment info.

## 1.2 Testing Workflow Trigger

Pushed a commit to the repository to trigger the workflow automatically.

Run link:
[Successful workflow run](https://github.com/spiritonchic/F25-DevOps-Intro/actions/runs/17920989838)

What I observed:
- In the Actions tab, a new run appeared automatically after push.
- Each run command prints its output in real time.

Concepts Learned:

Workflows — YAML files under .github/workflows/ describing automation.

Triggers — Events like push start workflows.

Jobs — Group of steps run on a specified runner.

Steps — Individual commands or actions executed sequentially inside a job.

Runners — Machines (GitHub-hosted or self-hosted) that execute jobs.

Cause of Run Trigger:

- The run was automatically triggered by a push event when I committed changes.

Workflow Execution Process:

1. Event (push) detected by GitHub Actions.
2. A new runner (Ubuntu VM) is allocated.
3. Jobs defined in the workflow are scheduled.
4. Steps execute one by one:
    - Initial echo commands run.
    - actions/checkout@v5 clones the repo into $GITHUB_WORKSPACE.
    - Remaining commands run inside that workspace.
5. Logs are stored and visible under each step.

# Task 2 — Manual Trigger + System Information

**Changes made to the workflow file:**  
- Added `workflow_dispatch` to enable manual runs.
- Added a step to print system information: `uname -a`, `lscpu`, `free -h`.

**Gathered system information from runner:**  
=== uname -a ===
Linux runnervmf4ws1 6.11.0-1018-azure #18~24.04.1-Ubuntu SMP Sat Jun 28 04:46:03 UTC 2025 x86_64 x86_64 x86_64 GNU/Linux
=== CPU info ===
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
BogoMIPS:                             4890.86
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
=== Memory info ===
               total        used        free      shared  buff/cache   available
Mem:            15Gi       742Mi        13Gi        39Mi       1.5Gi        14Gi
Swap:          4.0Gi          0B       4.0Gi

**Comparison of manual vs automatic workflow triggers:**  
- **Automatic (push):** starts on commit, appears in Actions tab.  
- **Manual (workflow_dispatch):** started via “Run workflow” button, same runner environment.  

**Analysis of runner environment and capabilities:**  
- GitHub-hosted Ubuntu runner on Azure.  
- 4 vCPUs, 15 GiB RAM, 4 GiB swap, AMD EPYC processor.  
- Suitable for CI/CD tasks; can run jobs with moderate CPU/memory demands.