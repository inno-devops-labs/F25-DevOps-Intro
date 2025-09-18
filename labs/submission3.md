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

## Task 2

**Changes made to the workflow file:**
-  To the `on:` block the `workflow_dispatch:` trigger has been added to enable manual triggering.
-  Added a new step `Gather System Information` for task 2.
- This step uses Linux commands (`uname -a`, `lscpu`, `free -h`, `df -h`) to collect detailed information about the runner's system.

**Collected information about the system (logs from "Gather System Information"):**
```
--- OS Information ---
Linux runnervmf4ws1 6.11.0-1018-azure #18~24.04.1-Ubuntu SMP Sat Jun 28 04:46:03 UTC 2025 x86_64 x86_64 x86_64 GNU/Linux
--- CPU Information ---
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
BogoMIPS:                             4890.85
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
--- Memory Information ---
               total        used        free      shared  buff/cache   available
Mem:            15Gi       791Mi        13Gi        39Mi       1.5Gi        14Gi
Swap:          4.0Gi          0B       4.0Gi
--- Disk Usage ---
Filesystem      Size  Used Avail Use% Mounted on
/dev/root        72G   46G   27G  64% /
tmpfs           7.9G   84K  7.9G   1% /dev/shm
tmpfs           3.2G  1.1M  3.2G   1% /run
tmpfs           5.0M     0  5.0M   0% /run/lock
/dev/sdb16      881M   60M  760M   8% /boot
/dev/sdb15      105M  6.2M   99M   6% /boot/efi
/dev/sda1        74G  4.1G   66G   6% /mnt
tmpfs           1.6G   12K  1.6G   1% /run/user/1001
```