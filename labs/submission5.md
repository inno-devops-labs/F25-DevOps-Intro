# Task

## Task 1 — VirtualBox Installation

* **Host operating system and version:** Windows 11
* **VirtualBox version number:** Version 7.1.10 r169112 (Qt6.5.3)
* **No installation issues encountered**

## Task 2 — Ubuntu VM and System Analysis

### Task 2.1 — VM configuration specifications used

- **RAM:** 8GB
- **Storage:** 25GB
- **CPU:** 2 cores

### Task 2.2 — System Information Discovery

1. **CPU Details**

    * **lscpu** - Comprehensive CPU architecture information

    * **Command and Output:**

```bash
lscpu
```
```bash
Architecture:                x86_64
  CPU op-mode(s):            32-bit, 64-bit
  Address sizes:             39 bits physical, 48 bits virtual
  Byte Order:                Little Endian
CPU(s):                      2
  On-line CPU(s) list:       0,1
Vendor ID:                   GenuineIntel
  Model name:                Intel(R) Core(TM) i5-10300H CPU @ 2.50GHz
    CPU family:              6
    Model:                   165
    Thread(s) per core:      1
    Core(s) per socket:      2
    Socket(s):               1
    Stepping:                2
    BogoMIPS:                4992.01
    Flags:                   fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ht syscall nx rdtscp lm constant_tsc rep_good nopl xtopol
                             ogy nonstop_tsc cpuid tsc_known_freq pni pclmulqdq ssse3 cx16 pcid sse4_1 sse4_2 movbe popcnt aes rdrand hypervisor lahf_lm abm 3dnowprefetch ibrs_enhanced
                              fsgsbase bmi1 bmi2 invpcid rdseed adx clflushopt arat md_clear flush_l1d arch_capabilities
Virtualization features:     
  Hypervisor vendor:         KVM
  Virtualization type:       full
Caches (sum of all):         
  L1d:                       64 KiB (2 instances)
  L1i:                       64 KiB (2 instances)
  L2:                        512 KiB (2 instances)
  L3:                        16 MiB (2 instances)
NUMA:                        
  NUMA node(s):              1
  NUMA node0 CPU(s):         0,1
Vulnerabilities:             
  Gather data sampling:      Not affected
  Ghostwrite:                Not affected
  Indirect target selection: Mitigation; Aligned branch/return thunks
  Itlb multihit:             Not affected
  L1tf:                      Not affected
  Mds:                       Not affected
  Meltdown:                  Not affected
  Mmio stale data:           Vulnerable: Clear CPU buffers attempted, no microcode; SMT Host state unknown
  Reg file data sampling:    Not affected
  Retbleed:                  Mitigation; Enhanced IBRS
  Spec rstack overflow:      Not affected
  Spec store bypass:         Vulnerable
  Spectre v1:                Mitigation; usercopy/swapgs barriers and __user pointer sanitization
  Spectre v2:                Mitigation; Enhanced / Automatic IBRS; PBRSB-eIBRS SW sequence; BHI SW loop, KVM SW loop
  Srbds:                     Unknown: Dependent on hypervisor status
  Tsx async abort:           Not affected
```

2. **Memory Information**

    * **free -h** - Human-readable memory usage
    * **Command and Output:**

```bash
free -h
```
```bash
               total        used        free      shared  buff/cache   available
Mem:           7.8Gi       1.1Gi       5.1Gi        39Mi       1.8Gi       6.6Gi
Swap:             0B          0B          0B

```

3. **Network Configuration**

    * **ifconfig** - Legacy network interface configuration
    * **Command and Output:**

```bash
ifconfig
```
```bash
enp0s3: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 10.0.2.15  netmask 255.255.255.0  broadcast 10.0.2.255
        inet6 fd17:625c:f037:2:a00:27ff:fed1:6cdb  prefixlen 64  scopeid 0x0<global>
        inet6 fd17:625c:f037:2:3fb4:bd8d:9c6b:e0b  prefixlen 64  scopeid 0x0<global>
        inet6 fe80::a00:27ff:fed1:6cdb  prefixlen 64  scopeid 0x20<link>
        ether 08:00:27:d1:6c:db  txqueuelen 1000  (Ethernet)
        RX packets 787291  bytes 959952526 (959.9 MB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 104515  bytes 6293685 (6.2 MB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 80  bytes 8661 (8.6 KB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 80  bytes 8661 (8.6 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```

4. **Storage Information**

    * **df -h** - Disk filesystem usage
    * **Command and Output:**

```bash
df -h
```
```bash
Filesystem      Size  Used Avail Use% Mounted on
tmpfs           795M  1.8M  793M   1% /run
/dev/sda2        25G  6.7G   17G  29% /
tmpfs           3.9G     0  3.9G   0% /dev/shm
tmpfs           5.0M  8.0K  5.0M   1% /run/lock
tmpfs           795M  124K  795M   1% /run/user/1000
/dev/sr0         59M   59M     0 100% /media/technomant/VBox_GAs_7.1.10

```

5. **Operating System Information**

    * **lsb_release -a** - Linux Standard Base information
    * **Command and Output:**

```bash
lsb_release -a
```
```bash
No LSB modules are available.
Distributor ID:	Ubuntu
Description:	Ubuntu 24.04.3 LTS
Release:	24.04
Codename:	noble
```

6. **Virtualization Detection**

    * **systemd-detect-virt** - Systemd virtualization detection
    * **Command and Output:**

```bash
systemd-detect-virt
```
```bash
oracle
```

**Most Useful Tools:**

* **lscpu** - Extremely comprehensive for CPU information, clearly showing virtualization support and core configuration
* **free -h** - Perfect for quick memory assessment with human-readable output