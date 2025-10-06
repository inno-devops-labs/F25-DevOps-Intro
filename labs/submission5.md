## Task 1 - VirtualBox Installation

HOST OS: Windows 11 24H2
VB version: 7.2.2 r170484 (Qt6.8.0)
Installation Notes: no errors

## Task 2 - Ubuntu

Name: UbuntuVM

RAM: 8GB

CPU: 2

Storage: 25 GB

## Commands and their outputs:

lscpu
```bash
Architecture:                            x86_64
CPU op-mode(s):                          32-bit, 64-bit
Address sizes:                           39 bits physical, 48 bits virtual
Byte Order:                              Little Endian
CPU(s):                                  2
On-line CPU(s) list:                     0,1
Vendor ID:                               GenuineIntel
Model name:                              12th Gen Intel(R) Core(TM) i7-12700H
CPU family:                              6
Model:                                   154
Thread(s) per core:                      1
Core(s) per socket:                      2
Socket(s):                               1
Stepping:                                3
BogoMIPS:                                5375.99
Flags:                                   fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ht syscall nx rdtscp lm constant_tsc rep_good nopl xtopology nonstop_tsc cpuid tsc_known_freq pni pclmulqdq ssse3 fma cx16 pcid sse4_1 sse4_2 movbe popcnt aes xsave avx f16c rdrand hypervisor lahf_lm abm 3dnowprefetch ibrs_enhanced fsgsbase bmi1 avx2 bmi2 invpcid rdseed adx clflushopt sha_ni arat md_clear flush_l1d arch_capabilities
Hypervisor vendor:                       KVM
Virtualization type:                     full
L1d cache:                               96 KiB (2 instances)
L1i cache:                               64 KiB (2 instances)
L2 cache:                                2.5 MiB (2 instances)
L3 cache:                                48 MiB (2 instances)
NUMA node(s):                            1
NUMA node0 CPU(s):                       0,1
Vulnerability Gather data sampling:      Not affected
Vulnerability Ghostwrite:                Not affected
Vulnerability Indirect target selection: Mitigation; Aligned branch/return thunks
Vulnerability Itlb multihit:             Not affected
Vulnerability L1tf:                      Not affected
Vulnerability Mds:                       Not affected
Vulnerability Meltdown:                  Not affected
Vulnerability Mmio stale data:           Not affected
Vulnerability Reg file data sampling:    Vulnerable: No microcode
Vulnerability Retbleed:                  Mitigation; Enhanced IBRS
Vulnerability Spec rstack overflow:      Not affected
Vulnerability Spec store bypass:         Vulnerable
Vulnerability Spectre v1:                Mitigation; usercopy/swapgs barriers and __user pointer sanitization
Vulnerability Spectre v2:                Mitigation; Enhanced / Automatic IBRS; PBRSB-eIBRS SW sequence; BHI SW loop, KVM SW loop
Vulnerability Srbds:                     Not affected
Vulnerability Tsx async abort:           Not affected
```
free -h:
``` bash
               total        used        free      shared  buff/cache   available
Mem:           8.4Gi       1.0Gi       6.8Gi        32Mi       878Mi       7.4Gi
Swap:             0B          0B          0B
```

ip a:
```bash
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host noprefixroute 
       valid_lft forever preferred_lft forever
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:b3:5c:91 brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic noprefixroute enp0s3
       valid_lft 86117sec preferred_lft 86117sec
    inet6 fd17:625c:f037:2:7e03:635f:1b35:b6ea/64 scope global temporary dynamic 
       valid_lft 86377sec preferred_lft 14377sec
    inet6 fd17:625c:f037:2:a00:27ff:feb3:5c91/64 scope global dynamic mngtmpaddr 
       valid_lft 86377sec preferred_lft 14377sec
    inet6 fe80::a00:27ff:feb3:5c91/64 scope link 
       valid_lft forever preferred_lft forever
```

df -h:
```bash
Filesystem      Size  Used Avail Use% Mounted on
tmpfs           861M  1.5M  859M   1% /run
/dev/sda2        25G  5.3G   18G  23% /
tmpfs           4.3G     0  4.3G   0% /dev/shm
tmpfs           5.0M  8.0K  5.0M   1% /run/lock
tmpfs           861M  116K  861M   1% /run/user/1000
```

lsb_release -a:
```bash
Distributor ID:	Ubuntu
Description:	Ubuntu 24.04.3 LTS
Release:	24.04
Codename:	noble
```

systemd-detect-virt:
```bash
oracle
```
## Results:
Most commands were straighforward. lscpu and free -h were the most useful. Getting system info from VM is simple and effective
