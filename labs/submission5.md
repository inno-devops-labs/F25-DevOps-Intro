# Lab 5 — Virtualization & System Analysis

## Task 1 — VirtualBox Installation

**Host Operating System**

Windows 11, Version 24H2

**VirtualBox Version**

7.2.2 r170484 (Qt6.8.0 on windows)

**Installation Process**
- Downloaded the installer from the official VirtualBox website (https://www.virtualbox.org/).
- Installed using the GUI installer with default settings.
- Launched VirtualBox successfully and verified it opens without errors.

**Issues Encountered**

No major issues encountered. Installation completed smoothly.

## Task 2 — Ubuntu VM and System Analysis

### 2.1: Create Ubuntu VM

**VM Configuration:**
- RAM: 8 GB
- Storage: 40 GB
- CPU: 2 cores

### 2.2: System Information Discovery

#### 🧠 CPU Details
**Command(s):**

- lscpu

**Output:**
```
Architecture:                x86_64
  CPU op-mode(s):            32-bit, 64-bit
  Address sizes:             48 bits physical, 48 bits virtual
  Byte Order:                Little Endian
CPU(s):                      2
  On-line CPU(s) list:       0,1
Vendor ID:                   AuthenticAMD
  Model name:                AMD Ryzen 5 5600H with Radeon Graphics
    CPU family:              25
    Model:                   80
    Thread(s) per core:      1
    Core(s) per socket:      2
    Socket(s):               1
    Stepping:                0
    BogoMIPS:                6587.44
    Flags:                   fpu vme de pse tsc msr pae mce cx8 apic sep
                              mtrr pge mca cmov pat pse36 clflush mmx fx
                             sr sse sse2 ht syscall nx mmxext fxsr_opt r
                             dtscp lm constant_tsc rep_good nopl nonstop
                             _tsc cpuid extd_apicid tsc_known_freq pni p
                             clmulqdq ssse3 fma cx16 sse4_1 sse4_2 movbe
                              popcnt aes xsave avx f16c rdrand hyperviso
                             r lahf_lm cmp_legacy cr8_legacy abm sse4a m
                             isalignsse 3dnowprefetch vmmcall fsgsbase b
                             mi1 avx2 bmi2 invpcid rdseed adx clflushopt
                              sha_ni arat debug_swap
Virtualization features:     
  Hypervisor vendor:         KVM
  Virtualization type:       full
Caches (sum of all):         
  L1d:                       64 KiB (2 instances)
  L1i:                       64 KiB (2 instances)
  L2:                        1 MiB (2 instances)
  L3:                        32 MiB (2 instances)
NUMA:                        
  NUMA node(s):              1
  NUMA node0 CPU(s):         0,1
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
  Retbleed:                  Not affected
  Spec rstack overflow:      Vulnerable: Safe RET, no microcode
  Spec store bypass:         Not affected
  Spectre v1:                Mitigation; usercopy/swapgs barriers and __
                             user pointer sanitization
  Spectre v2:                Mitigation; Retpolines; STIBP disabled; RSB
                              filling; PBRSB-eIBRS Not affected; BHI Not
                              affected
  Srbds:                     Not affected
  Tsx async abort:           Not affected
```

#### 💾 Memory Information
**Command(s):**
- free -h

**Output:**
```
               total        used        free      shared  buff/cache   available
Mem:           7.8Gi       1.1Gi       5.5Gi        31Mi       1.4Gi       6.7Gi
Swap:             0B          0B          0B
```

#### 🌐 Network Configuration
**Command(s):**
- ip addr show

**Output:**
```
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host noprefixroute 
       valid_lft forever preferred_lft forever
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:42:9d:bd brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic noprefixroute enp0s3
       valid_lft 85786sec preferred_lft 85786sec
    inet6 fd17:625c:f037:2:c557:a2ef:2b00:8864/64 scope global temporary dynamic 
       valid_lft 86089sec preferred_lft 14089sec
    inet6 fd17:625c:f037:2:a00:27ff:fe42:9dbd/64 scope global dynamic mngtmpaddr 
       valid_lft 86089sec preferred_lft 14089sec
    inet6 fe80::a00:27ff:fe42:9dbd/64 scope link 
       valid_lft forever preferred_lft forever
```


#### 📦 Storage Information
**Command(s):**
- df -h

**Output:**
```
Filesystem      Size  Used Avail Use% Mounted on
tmpfs           795M  1.7M  793M   1% /run
/dev/sda2        40G  5.9G   32G  16% /
tmpfs           3.9G     0  3.9G   0% /dev/shm
tmpfs           5.0M  8.0K  5.0M   1% /run/lock
tmpfs           795M  148K  795M   1% /run/user/1000
/dev/sr0        6.0G  6.0G     0 100% /media/vboxuser/Ubuntu 24.04.3 LTS amd64
```

#### 🐧 Operating System
**Command(s):**
- lsb_release -a
- uname -a

**Output:**
```
No LSB modules are available.
Distributor ID:	Ubuntu
Description:	Ubuntu 24.04.3 LTS
Release:	24.04
Codename:	noble

Linux devOpsUbuntu 6.14.0-33-generic #33~24.04.1-Ubuntu SMP PREEMPT_DYNAMIC Fri Sep 19 17:02:30 UTC 2 x86_64 x86_64 x86_64 GNU/Linux
```

#### 🧩 Virtualization Detection
**Command(s):**

- systemd-detect-virt

**Output:**
```
oracle
```

### 2.3: Reflection

The most useful tools were:
- lscpu for clear and structured CPU details
- free -h for easily readable memory usage
- systemd-detect-virt for confirming virtualization environment
- df -h for intuitive disk space summary

These commands provided complete system insight with minimal effort and are standard in almost all Linux distributions.
