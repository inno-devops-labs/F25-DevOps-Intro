# Lab 5

## Task 1

- Host operating system and version: `Windows 10 Pro Version 22H2`
- VirtualBox version: `VirtualBox
Version 7.2.2`
- There were **no problems** with the installation

## Task 2

**VM Configuration:**
  - RAM: 4594 MB
  - Storage: 25 GB
  - CPU Cores: 3
---
### CPU Details
- Tool: `lscpu`
- Command: 
    ```bash
    lscpu
    ```
- Output: 
    ```bash
    Architecture:                x86_64
    CPU op-mode(s):            32-bit, 64-bit
    Address sizes:             48 bits physical, 48 bits virtual
    Byte Order:                Little Endian
    CPU(s):                      3
    On-line CPU(s) list:       0-2
    Vendor ID:                   AuthenticAMD
    Model name:                AMD Ryzen 5 5500U with Radeon Graphics
        CPU family:              23
        Model:                   104
        Thread(s) per core:      1
        Core(s) per socket:      3
        Socket(s):               1
        Stepping:                1
        BogoMIPS:                4191.97
        Flags:                   fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pg
                                e mca cmov pat pse36 clflush mmx fxsr sse sse2 ht s
                                yscall nx mmxext fxsr_opt rdtscp lm constant_tsc re
                                p_good nopl nonstop_tsc cpuid extd_apicid tsc_known
                                _freq pni pclmulqdq ssse3 fma cx16 sse4_1 sse4_2 mo
                                vbe popcnt aes xsave avx f16c rdrand hypervisor lah
                                f_lm cmp_legacy cr8_legacy abm sse4a misalignsse 3d
                                nowprefetch ssbd vmmcall fsgsbase bmi1 avx2 bmi2 rd
                                seed adx clflushopt sha_ni arat
    Virtualization features:     
    Hypervisor vendor:         KVM
    Virtualization type:       full
    Caches (sum of all):         
    L1d:                       96 KiB (3 instances)
    L1i:                       96 KiB (3 instances)
    L2:                        1.5 MiB (3 instances)
    L3:                        24 MiB (3 instances)
    NUMA:                        
    NUMA node(s):              1
    NUMA node0 CPU(s):         0-2
    Vulnerabilities:             
    Gather data sampling:      Not affected
    Ghostwrite:                Not affected
    Indirect target selection: Not affected
    Itlb multihit:             Not affected
    L1tf:                      Not affected
    Mds:                       Not affected
    Meltdown:                  Not affected
    Mmio stale data:           Not affected
    Reg file data sampling:    Not affected
    Retbleed:                  Mitigation; untrained return thunk; SMT disabled
    Spec rstack overflow:      Vulnerable: Safe RET, no microcode
    Spec store bypass:         Not affected
    Spectre v1:                Mitigation; usercopy/swapgs barriers and __user poi
                                nter sanitization
    Spectre v2:                Mitigation; Retpolines; STIBP disabled; RSB filling
                                ; PBRSB-eIBRS Not affected; BHI Not affected
    Srbds:                     Not affected
    Tsx async abort:           Not affected
    ```
 
---

### Memory Information
- Tool: `free`
- Command:
    ```bash
    free -h
    ```
- Output:
    ```bash
                   total        used        free      shared  buff/cache   available
    Mem:           4.3Gi       1.3Gi       1.5Gi        34Mi       1.8Gi       3.0Gi
    Swap:             0B          0B          0B
    ```
---
### Network Configuration
- Tool: `ip`
- Command:
    ```bash
    ip addr
    ```
- Output:
    ```bash
    1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host noprefixroute 
       valid_lft forever preferred_lft forever
    2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:68:03:8c brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic noprefixroute enp0s3
    valid_lft 85724sec preferred_lft 85724sec
    inet6 fd17:625c:f037:2:91d0:511f:8ac7:dc7c/64 scope global temporary dynamic 
    valid_lft 86078sec preferred_lft 14078sec
    inet6 fd17:625c:f037:2:a00:27ff:fe68:38c/64 scope global dynamic mngtmpaddr 
    valid_lft 86078sec preferred_lft 14078sec
    inet6 fe80::a00:27ff:fe68:38c/64 scope link 
    valid_lft forever preferred_lft forever
    ```
---
### Storage Information
- Tool: `df`
- Command:
    ```bash
    df -h
    ```
- Output:
    ```bash
    Filesystem      Size  Used Avail Use% Mounted on
    tmpfs           441M  1.7M  439M   1% /run
    /dev/sda2        25G  5.4G   18G  24% /
    tmpfs           2.2G     0  2.2G   0% /dev/shm
    tmpfs           5.0M  8.0K  5.0M   1% /run/lock
    tmpfs           441M  156K  440M   1% /run/user/1000

    ```
---
### Operating System
- Tool: `lsb_release` & `uname`
- Command:
    ```bash
    lsb_release -a && uname -r
    ```
- Output:
    ```bash
    No LSB modules are available.
    Distributor ID: Ubuntu
    Description: Ubuntu 24.04.3 LTS
    Release: 24.04
    Codename: noble
    ```
    ```bash
    6.14.0-29-generic
    ```
---
### Virtualization Detection
- Tool: `systemd-detect-virt`
- Command:
    ```bash
    systemd-detect-virt
    ```
- Output:
    ```bash
    oracle
    ```
---

### Reflection
The most useful tools turned out to be: `lscpu` and `df -h`.
- `lscpu` provided comprehensive information about the processor of the virtual machine in one place
- `df -h` clearly demonstrated the use of disk space in a human-friendly format
