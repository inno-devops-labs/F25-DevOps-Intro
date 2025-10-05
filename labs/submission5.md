# Lab 5 — Virtualization & System Analysis

## Task 1 — VirtualBox Installation
- **Host OS:** MacOs Sequoia 15.3.1
- **VirtualBox version:** 7.2.2 r170484
- **Issues:** Installation completed successfully, no errors encountered


## Task 2 — Ubuntu VM and System Analysis

### VM 
 CPU Architecture Information

lscpu - Display CPU architecture information

/proc/cpuinfo - Detailed processor information

cpuid - CPU features and capabilities

nproc - Number of processing units available
```bash
lscpu 
```
```bash
Architecture:            x86_64
  CPU op-mode(s):        32-bit, 64-bit
  Address sizes:         52 bits physical, 57 bits virtual
  Byte Order:            Little Endian
CPU(s):                  4
  On-line CPU(s) list:   0-3
Vendor ID:               GenuineIntel
  Model name:            Intel(R) Xeon(R) Platinum 8575C
    CPU family:          6
    Model:               207
    Thread(s) per core:  2
    Core(s) per socket:  2
    Socket(s):           1
    Stepping:            2
    CPU max MHz:         4000.0000
    CPU min MHz:         800.0000
    BogoMIPS:            5600.00
    Flags:               fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mc
                         a cmov pat pse36 clflush mmx fxsr sse sse2 ss ht syscal
                         l nx pdpe1gb rdtscp lm constant_tsc arch_perfmon rep_go
                         od nopl xtopology nonstop_tsc cpuid aperfmperf tsc_know
                         n_freq pni pclmulqdq monitor ssse3 fma cx16 pdcm pcid s
                         se4_1 sse4_2 x2apic movbe popcnt aes xsave avx f16c rdr
                         and hypervisor lahf_lm abm 3dnowprefetch cpuid_fault in
                         vpcid_single ssbd ibrs_enhanced fsgsbase tsc_adjust bmi
                         1 hle avx2 smep bmi2 erms invpcid rtm avx512f avx512dq 
                         rdseed adx smap avx512ifma clflushopt clwb avx512cd sha
                         _ni avx512bw avx512vl xsaveopt xsavec xgetbv1 xsaves av
                         x512_bf16 wbnoinvd ida arat hwp hwp_notify hwp_act_wind
                         ow hwp_epp hwp_pkg_req avx512vbmi umip pku ospke waitpk
                         g avx512_vbmi2 gfni vaes vpclmulqdq avx512_vnni avx512_
                         bitalg avx512_vpopcntdq rdpid cldemote movdiri movdir64
                         b md_clear flush_l1d arch_capabilities
Virtualization features: 
  Hypervisor vendor:     KVM
  Virtualization type:   full
Caches (sum of all):     
  L1d:                   96 KiB (2 instances)
  L1i:                   64 KiB (2 instances)
  L2:                    4 MiB (2 instances)
  L3:                    320 MiB (1 instance)
NUMA:                    
  NUMA node(s):          1
  NUMA node0 CPU(s):     0-3
Vulnerabilities:         
  Gather data sampling:  Not affected
  Itlb multihit:         Not affected
  L1tf:                  Not affected
  Mds:                   Not affected
  Meltdown:              Not affected
  Mmio stale data:       Unknown: No mitigations
  Retbleed:              Not affected
  Spec store bypass:     Mitigation; Speculative Store Bypass disabled via prctl
                          and seccomp
  Spectre v1:            Mitigation; usercopy/swapgs barriers and __user pointer
                          sanitization
  Spectre v2:            Mitigation; Enhanced IBRS, RSB filling, PBRSB-eIBRS SW 
                         sequence
  Srbds:                 Not affected
  Tsx async abort:       Not affected
```
### Detailed CPU Information
```bash
cat /proc/cpuinfo
```
```bash
processor	: 0
vendor_id	: GenuineIntel
cpu family	: 6
model		: 207
model name	: Intel(R) Xeon(R) Platinum 8575C
stepping	: 2
microcode	: 0x1
cpu MHz		: 3199.982
cache size	: 327680 KB
physical id	: 0
siblings	: 4
core id		: 0
cpu cores	: 2
apicid		: 0
initial apicid	: 0
fpu		: yes
fpu_exception	: yes
cpuid level	: 31
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ss ht syscall nx pdpe1gb rdtscp lm constant_tsc arch_perfmon rep_good nopl xtopology nonstop_tsc cpuid aperfmperf tsc_known_freq pni pclmulqdq monitor ssse3 fma cx16 pdcm pcid sse4_1 sse4_2 x2apic movbe popcnt aes xsave avx f16c rdrand hypervisor lahf_lm abm 3dnowprefetch cpuid_fault invpcid_single ssbd ibrs_enhanced fsgsbase tsc_adjust bmi1 hle avx2 smep bmi2 erms invpcid rtm avx512f avx512dq rdseed adx smap avx512ifma clflushopt clwb avx512cd sha_ni avx512bw avx512vl xsaveopt xsavec xgetbv1 xsaves avx512_bf16 wbnoinvd ida arat hwp hwp_notify hwp_act_window hwp_epp hwp_pkg_req avx512vbmi umip pku ospke waitpkg avx512_vbmi2 gfni vaes vpclmulqdq avx512_vnni avx512_bitalg avx512_vpopcntdq rdpid cldemote movdiri movdir64b md_clear flush_l1d arch_capabilities
bugs		: spectre_v1 spectre_v2 spec_store_bypass swapgs eibrs_pbrsb mmio_unknown
bogomips	: 5600.00
clflush size	: 64
cache_alignment	: 64
address sizes	: 52 bits physical, 57 bits virtual
power management:

processor	: 1
vendor_id	: GenuineIntel
cpu family	: 6
model		: 207
model name	: Intel(R) Xeon(R) Platinum 8575C
stepping	: 2
microcode	: 0x1
cpu MHz		: 3200.000
cache size	: 327680 KB
physical id	: 0
siblings	: 4
core id		: 0
cpu cores	: 2
apicid		: 1
initial apicid	: 1
fpu		: yes
fpu_exception	: yes
cpuid level	: 31
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ss ht syscall nx pdpe1gb rdtscp lm constant_tsc arch_perfmon rep_good nopl xtopology nonstop_tsc cpuid aperfmperf tsc_known_freq pni pclmulqdq monitor ssse3 fma cx16 pdcm pcid sse4_1 sse4_2 x2apic movbe popcnt aes xsave avx f16c rdrand hypervisor lahf_lm abm 3dnowprefetch cpuid_fault invpcid_single ssbd ibrs_enhanced fsgsbase tsc_adjust bmi1 hle avx2 smep bmi2 erms invpcid rtm avx512f avx512dq rdseed adx smap avx512ifma clflushopt clwb avx512cd sha_ni avx512bw avx512vl xsaveopt xsavec xgetbv1 xsaves avx512_bf16 wbnoinvd ida arat hwp hwp_notify hwp_act_window hwp_epp hwp_pkg_req avx512vbmi umip pku ospke waitpkg avx512_vbmi2 gfni vaes vpclmulqdq avx512_vnni avx512_bitalg avx512_vpopcntdq rdpid cldemote movdiri movdir64b md_clear flush_l1d arch_capabilities
bugs		: spectre_v1 spectre_v2 spec_store_bypass swapgs eibrs_pbrsb mmio_unknown
bogomips	: 5600.00
clflush size	: 64
cache_alignment	: 64
address sizes	: 52 bits physical, 57 bits virtual
power management:

processor	: 2
vendor_id	: GenuineIntel
cpu family	: 6
model		: 207
model name	: Intel(R) Xeon(R) Platinum 8575C
stepping	: 2
microcode	: 0x1
cpu MHz		: 3200.027
cache size	: 327680 KB
physical id	: 0
siblings	: 4
core id		: 1
cpu cores	: 2
apicid		: 2
initial apicid	: 2
fpu		: yes
fpu_exception	: yes
cpuid level	: 31
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ss ht syscall nx pdpe1gb rdtscp lm constant_tsc arch_perfmon rep_good nopl xtopology nonstop_tsc cpuid aperfmperf tsc_known_freq pni pclmulqdq monitor ssse3 fma cx16 pdcm pcid sse4_1 sse4_2 x2apic movbe popcnt aes xsave avx f16c rdrand hypervisor lahf_lm abm 3dnowprefetch cpuid_fault invpcid_single ssbd ibrs_enhanced fsgsbase tsc_adjust bmi1 hle avx2 smep bmi2 erms invpcid rtm avx512f avx512dq rdseed adx smap avx512ifma clflushopt clwb avx512cd sha_ni avx512bw avx512vl xsaveopt xsavec xgetbv1 xsaves avx512_bf16 wbnoinvd ida arat hwp hwp_notify hwp_act_window hwp_epp hwp_pkg_req avx512vbmi umip pku ospke waitpkg avx512_vbmi2 gfni vaes vpclmulqdq avx512_vnni avx512_bitalg avx512_vpopcntdq rdpid cldemote movdiri movdir64b md_clear flush_l1d arch_capabilities
bugs		: spectre_v1 spectre_v2 spec_store_bypass swapgs eibrs_pbrsb mmio_unknown
bogomips	: 5600.00
clflush size	: 64
cache_alignment	: 64
address sizes	: 52 bits physical, 57 bits virtual
power management:

processor	: 3
vendor_id	: GenuineIntel
cpu family	: 6
model		: 207
model name	: Intel(R) Xeon(R) Platinum 8575C
stepping	: 2
microcode	: 0x1
cpu MHz		: 3200.042
cache size	: 327680 KB
physical id	: 0
siblings	: 4
core id		: 1
cpu cores	: 2
apicid		: 3
initial apicid	: 3
fpu		: yes
fpu_exception	: yes
cpuid level	: 31
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ss ht syscall nx pdpe1gb rdtscp lm constant_tsc arch_perfmon rep_good nopl xtopology nonstop_tsc cpuid aperfmperf tsc_known_freq pni pclmulqdq monitor ssse3 fma cx16 pdcm pcid sse4_1 sse4_2 x2apic movbe popcnt aes xsave avx f16c rdrand hypervisor lahf_lm abm 3dnowprefetch cpuid_fault invpcid_single ssbd ibrs_enhanced fsgsbase tsc_adjust bmi1 hle avx2 smep bmi2 erms invpcid rtm avx512f avx512dq rdseed adx smap avx512ifma clflushopt clwb avx512cd sha_ni avx512bw avx512vl xsaveopt xsavec xgetbv1 xsaves avx512_bf16 wbnoinvd ida arat hwp hwp_notify hwp_act_window hwp_epp hwp_pkg_req avx512vbmi umip pku ospke waitpkg avx512_vbmi2 gfni vaes vpclmulqdq avx512_vnni avx512_bitalg avx512_vpopcntdq rdpid cldemote movdiri movdir64b md_clear flush_l1d arch_capabilities
bugs		: spectre_v1 spectre_v2 spec_store_bypass swapgs eibrs_pbrsb mmio_unknown
bogomips	: 5600.00
clflush size	: 64
cache_alignment	: 64
address sizes	: 52 bits physical, 57 bits virtual
power management:
```

### Memory Information Tools

free - Memory usage statistics

/proc/meminfo - Detailed memory information

vmstat - Virtual memory statistics

```bash
free -h
```

```bash
               total        used        free      shared  buff/cache   available
Mem:            15Gi       4.6Gi       2.2Gi        74Mi       8.6Gi        10Gi
Swap:             0B          0B          0B
```

##  

```bash
cat /proc/meminfo | head -10
```
```bash
MemTotal:       16105788 kB
MemFree:         2091776 kB
MemAvailable:   10689844 kB
Buffers:          140128 kB
Cached:          7089168 kB
SwapCached:            0 kB
Active:          8991376 kB
Inactive:        2460192 kB
Active(anon):    4222464 kB
Inactive(anon):    76452 kB
```

## Network Configuration

ip - Modern network configuration tool

ifconfig - Legacy network interface config

netstat - Network connections and statistics

ss - Socket statistics

```bash
ip addr show
```

```bash
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
61053: eth0@if61054: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
    link/ether 02:42:ac:3d:01:09 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 172.61.1.9/16 brd 172.61.255.255 scope global eth0
       valid_lft forever preferred_lft forever
```


##  Storage Information Tools
df - Disk filesystem usage

lsblk - Block devices information

fdisk - Partition table manipulator

du - Directory space usage

```bash
df -h
```


```bash
Filesystem      Size  Used Avail Use% Mounted on
overlay          20G  126M   20G   1% /
tmpfs            64M     0   64M   0% /dev
tmpfs           7.7G     0  7.7G   0% /sys/fs/cgroup
shm              64M     0   64M   0% /dev/shm
/dev/nvme1n1    100G   19G   82G  19% /etc/hosts
tmpfs           7.7G     0  7.7G   0% /proc/acpi
tmpfs           7.7G     0  7.7G   0% /proc/scsi
tmpfs           7.7G     0  7.7G   0% /sys/firmware

```
```bash
lsblk
```

```bash
NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
nvme1n1     259:0    0  100G  0 disk /etc/hosts
                                     /etc/hostname
                                     /etc/resolv.conf
nvme0n1     259:1    0   40G  0 disk 
└─nvme0n1p1 259:2    0   40G  0 part 
```

## Operating System Information
lsb_release - Linux Standard Base info

uname - Kernel and system information

hostnamectl - System hostname and OS info

/etc/os-release - OS identification file

```bash
cat /etc/os-release
```

```bash
PRETTY_NAME="Ubuntu 22.04.4 LTS"
NAME="Ubuntu"
VERSION_ID="22.04"
VERSION="22.04.4 LTS (Jammy Jellyfish)"
VERSION_CODENAME=jammy
ID=ubuntu
ID_LIKE=debian
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
UBUNTU_CODENAME=jammy
```


## Virtualization Detection
systemd-detect-virt - Detect virtualization

dmidecode - DMI/system BIOS information

virt-what - Virtualization detection script

lshw - Hardware lister with system info

```bash
systemd-detect-virt
```

```bash
oracle
```

## Most Useful Tools Reflection

lscpu - Extremely valuable for quick CPU overview with clean, organized output showing architecture, cores, and model in one command.

free -h - Essential for memory analysis with human-readable format making RAM usage immediately understandable.

ip addr - Superior to ifconfig for network info, providing comprehensive interface details with modern syntax.

df -h - Indispensable for storage monitoring, offering clear disk usage percentages and available space.

lsb_release & uname - Perfect combination for OS identification, giving both distribution and kernel details quickly.

systemd-detect-virt - Most efficient for virtualization detection, providing instant, unambiguous results.

