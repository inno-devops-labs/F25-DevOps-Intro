# Lab 5 — Virtualization & System Analysis

## Task 1 - VirtualBox Installation

### Host System Information

- Host OS: macOS Sequoia 15.6.1
- Architecture: Apple Silicon M4 Pro
- VirtualBox Version: 7.2.2 r170484 

### Installation Issues

- No installation issues were met


## Task 2 - Ubuntu VM and System Analysis

### 2.1: Creating Ubuntu VM

- ISO file `ubuntu-24.04.3-desktop-arm64.iso`
- Created VM with minimal setup: 4GB RAM, 2 CPU cores, 25GB Disk
- Installation: Default installation process completed successfully

### 2.2: System Information Discovery

#### CPU Details
**Tool Discovered**: lscpu, cat /proc/cpuinfo

```bash
> lscpu
Architecture:                aarch64
  CPU op-mode(s):            64-bit
  Byte Order:                Little Endian
CPU(s):                      2
  On-line CPU(s) list:       0,1
Vendor ID:                   Apple
  Model name:                -
    Model:                   0
    Thread(s) per core:      1
    Core(s) per cluster:     2
    Socket(s):               -
    Cluster(s):              1
    Stepping:                0x0
    BogoMIPS:                48.00
    Flags:                   fp asimd evtstrm aes pmull sha1 sha2 crc32 atomics 
                             fphp asimdhp cpuid asimdrdm jscvt fcma lrcpc dcpop 
                             sha3 asimddp sha512 asimdfhm dit uscat ilrcpc flagm
                              sb paca pacg dcpodp flagm2 frint bf16 afp
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
  Spec rstack overflow:      Not affected
  Spec store bypass:         Vulnerable
  Spectre v1:                Mitigation; __user pointer sanitization
  Spectre v2:                Mitigation; CSV2, but not BHB
  Srbds:                     Not affected
  Tsx async abort:           Not affected
```

```bash
> cat /proc/cpuinfo
processor : 0
BogoMIPS : 48.00
Features : fp asimd evtstrm aes pmull sha1 sha2 crc32 atomics fphp asimdhp cpuid asimdrdm jscvt fcma lrcpc dcpop sha3 asimddp sha512 asimdfhm dit uscat ilrcpc flagm sb paca pacg dcpodp flagm2 frint bf16 afp
CPU implementer : 0x61
CPU architecture: 8
CPU variant : 0x0
CPU part : 0x000
CPU revision : 0

processor : 1
BogoMIPS : 48.00
Features : fp asimd evtstrm aes pmull sha1 sha2 crc32 atomics fphp asimdhp cpuid asimdrdm jscvt fcma lrcpc dcpop sha3 asimddp sha512 asimdfhm dit uscat ilrcpc flagm sb paca pacg dcpodp flagm2 frint bf16 afp
CPU implementer : 0x61
CPU architecture: 8
CPU variant : 0x0
CPU part : 0x000
CPU revision : 0
```

**Output Analysis**:
- **Architecture**: ARM64 (Apple Silicon) with 2 CPU cores, confirming the VM is running on Apple M4 Pro host
- **CPU Features**: Comprehensive ARM64 instruction set including AES, SHA, and advanced security features
- **Virtualization**: Running with 2 cores allocated from host system
- **Security**: Multiple vulnerability mitigations present (Spectre v1/v2, etc.)
- **Performance**: BogoMIPS indicates baseline performance measurement capability



#### Memory Information

**Tool Discovered**: free -h, cat /proc/meminfo

```bash
>free -h
total        used        free      shared  buff/cache   available
Mem:           3.8Gi       1.5Gi       490Mi        58Mi       1.7Gi       2.3Gi
Swap:             0B          0B          0B
```

```bash
> cat/proc/meminfo
MemTotal:        3991328 kB
MemFree:          557712 kB
MemAvailable:    2439312 kB
Buffers:           75112 kB
Cached:          1709448 kB
SwapCached:            0 kB
Active:          2121760 kB
Inactive:         997156 kB
Active(anon):    1140096 kB
Inactive(anon):        0 kB
Active(file):     981664 kB
Inactive(file):   997156 kB
Unevictable:          16 kB
Mlocked:              16 kB
SwapTotal:             0 kB
SwapFree:              0 kB
Zswap:                 0 kB
Zswapped:              0 kB
Dirty:             10476 kB
Writeback:             0 kB
AnonPages:       1334428 kB
Mapped:           524220 kB
Shmem:             59896 kB
KReclaimable:      58064 kB
Slab:             169032 kB
SReclaimable:      58064 kB
SUnreclaim:       110968 kB
KernelStack:       12000 kB
ShadowCallStack:    3008 kB
PageTables:        28340 kB
SecPageTables:         0 kB
NFS_Unstable:          0 kB
Bounce:                0 kB
WritebackTmp:          0 kB
CommitLimit:     1995664 kB
Committed_AS:    6189400 kB
VmallocTotal:   135288315904 kB
VmallocUsed:       28248 kB
VmallocChunk:          0 kB
Percpu:             1168 kB
HardwareCorrupted:     0 kB
AnonHugePages:         0 kB
ShmemHugePages:        0 kB
ShmemPmdMapped:        0 kB
FileHugePages:         0 kB
FilePmdMapped:         0 kB
CmaTotal:          32768 kB
CmaFree:           29888 kB
HugePages_Total:       0
HugePages_Free:        0
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:       2048 kB
Hugetlb:               0 kB
```

**Output Analysis**:
- **Total Memory**: 3.8GB allocated to VM (matches 4GB configuration)
- **Memory Usage**: 1.5GB used, 2.3GB available (healthy memory utilization)
- **Swap**: No swap configured (0B), indicating sufficient physical memory
- **Memory Management**: Active caching (1.7GB buffer/cache) showing efficient memory utilization



#### Network Configuration

**Tool Discovered**: ip addr, ifconfig, ss, ip route

```bash
>ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host noprefixroute 
       valid_lft forever preferred_lft forever
2: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:7c:39:8d brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic noprefixroute enp0s8
       valid_lft 85407sec preferred_lft 85407sec
    inet6 fd17:625c:f037:2:2112:6657:161:d5b0/64 scope global temporary dynamic 
       valid_lft 86126sec preferred_lft 14126sec
    inet6 fd17:625c:f037:2:a00:27ff:fe7c:398d/64 scope global dynamic mngtmpaddr 
       valid_lft 86126sec preferred_lft 14126sec
    inet6 fe80::a00:27ff:fe7c:398d/64 scope link 
       valid_lft forever preferred_lft forever
```

```bash
> ifconfig
enp0s8: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 10.0.2.15  netmask 255.255.255.0  broadcast 10.0.2.255
        inet6 fd17:625c:f037:2:2112:6657:161:d5b0  prefixlen 64  scopeid 0x0<global>
        inet6 fd17:625c:f037:2:a00:27ff:fe7c:398d  prefixlen 64  scopeid 0x0<global>
        inet6 fe80::a00:27ff:fe7c:398d  prefixlen 64  scopeid 0x20<link>
        ether 08:00:27:7c:39:8d  txqueuelen 1000  (Ethernet)
        RX packets 45044  bytes 58203312 (58.2 MB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 15541  bytes 1608481 (1.6 MB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 1767  bytes 161209 (161.2 KB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 1767  bytes 161209 (161.2 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```

```bash
> ss
...
u_str ESTAB 0      0                @6196f830105ba0fa/bus/systemd-logind/system 10580                                     * 10583                               
u_str ESTAB 0      0               @ea379752957e5589/bus/systemd/bus-api-system 10452                                     * 9124                                
u_str ESTAB 0      0      @f3908ff3ff91b55/bus/systemd-timesyn/bus-api-timesync 10171                                     * 9113                                
u_str ESTAB 0      0      @879dbedbca483b83/bus/systemd-resolve/bus-api-resolve 10172                                     * 9114                                
u_str ESTAB 0      0                 @2fc4d82a249a9584/bus/systemd/bus-api-user 15136                                     * 15523                               
udp   ESTAB 0      0                                           10.0.2.15%enp0s8:bootpc                             10.0.2.2:bootps                              
tcp   ESTAB 0      0                                                  10.0.2.15:44752                        149.154.167.99:https                               
tcp   ESTAB 0      0                                                  10.0.2.15:44764                        149.154.167.99:https                               
tcp   ESTAB 0      0                                                  10.0.2.15:33032                         34.107.243.93:https
```

```bash
> ip route
default via 10.0.2.2 dev enp0s8 proto dhcp src 10.0.2.15 metric 100 
10.0.2.0/24 dev enp0s8 proto kernel scope link src 10.0.2.15 metric 100
```

**Output Analysis**:
- **Network Interface**: enp0s8 (VirtualBox default network adapter)
- **IP Configuration**: 10.0.2.15/24 (VirtualBox NAT network)
- **Gateway**: 10.0.2.2 (VirtualBox NAT gateway)
- **IPv6**: Dual-stack configuration with both IPv4 and IPv6 addresses
- **Connectivity**: Active connections to external services (149.154.167.99 - likely Telegram)



#### Storage Information

**Tool Discovered**: df -h, lsblk, fdisk -v

```bash
> df -h
Filesystem      Size  Used Avail Use% Mounted on
tmpfs           390M  1.5M  389M   1% /run
/dev/sda2        24G  5.5G   17G  25% /
tmpfs           2.0G     0  2.0G   0% /dev/shm
tmpfs           5.0M  8.0K  5.0M   1% /run/lock
efivarfs        256K   11K  246K   4% /sys/firmware/efi/efivars
/dev/sda1       1.1G  6.4M  1.1G   1% /boot/efi
tmpfs           390M  124K  390M   1% /run/user/1000
```

```bash
> lsblk
NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
loop0    7:0    0     4K  1 loop /snap/bare/5
loop1    7:1    0  68.9M  1 loop /snap/core22/2049
loop2    7:2    0 230.5M  1 loop /snap/firefox/6563
loop3    7:3    0 493.5M  1 loop /snap/gnome-42-2204/201
loop4    7:4    0  91.7M  1 loop /snap/gtk-common-themes/1535
loop5    7:5    0    10M  1 loop /snap/snap-store/1271
loop6    7:6    0  42.9M  1 loop /snap/snapd/24787
loop7    7:7    0   552K  1 loop /snap/snapd-desktop-integration/316
sda      8:0    0    25G  0 disk 
├─sda1   8:1    0     1G  0 part /boot/efi
└─sda2   8:2    0  23.9G  0 part /
sr0     11:0    1  1024M  0 rom
```

```bash
> fdisk -v
fdisk from util-linux 2.39.3
```

**Output Analysis**:
- **Disk Configuration**: 25GB virtual disk (sda) with EFI boot partition (1GB) and root partition (23.9GB)
- **Disk Usage**: 5.5GB used out of 24GB (25% utilization) - healthy for fresh installation
- **Filesystem**: Standard Linux filesystem with EFI boot support
- **Snap Packages**: Multiple snap packages (Firefox, GNOME, etc.) indicating modern Ubuntu installation


#### Operating System

**Tool Discovered**: uname, uname -a, hostnamectl, cat /etc/os-release

```bash
> uname 
Linux
```

```bash
> uname -a
Linux DevOpsLab5 6.14.0-33-generic #33~24.04.1-Ubuntu SMP PREEMPT_DYNAMIC Fri Sep 19 16:19:58 UTC 2 aarch64 aarch64 aarch64 GNU/Linux
```

```bash
> hostnamectl
Static hostname: DevOpsLab5
       Icon name: computer
      Machine ID: e8431955a2c14dd0904278237c69c7b9
         Boot ID: 22cf3cdb99204d6ca4a545426d22c5f4
Operating System: Ubuntu 24.04.3 LTS              
          Kernel: Linux 6.14.0-33-generic
    Architecture: arm64
```

```bash
> cat /etc/os-release
PRETTY_NAME="Ubuntu 24.04.3 LTS"
NAME="Ubuntu"
VERSION_ID="24.04"
VERSION="24.04.3 LTS (Noble Numbat)"
VERSION_CODENAME=noble
ID=ubuntu
ID_LIKE=debian
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
UBUNTU_CODENAME=noble
LOGO=ubuntu-logo
```

**Output Analysis**:
- **Operating System**: Ubuntu 24.04.3 LTS (Noble Numbat) - latest point release
- **Kernel**: Linux 6.14.0-33-generic (modern kernel with PREEMPT_DYNAMIC)
- **Architecture**: ARM64 (aarch64) confirming Apple Silicon support
- **Hostname**: DevOpsLab5 (custom hostname set during installation)
- **System Type**: LTS (Long Term Support) version with extended support

#### Virtualization Detection

**Tool Discovered**: systemd-detect-virt, sudo lshw -class system

```bash
> systemd-detect-virt
none
```

```bash
> sudo lshw -class system
[sudo] password for vboxuser: 
devopslab5                  
    description: Computer
    width: 64 bits
    capabilities: smp cp15_barrier swp tagged_addr_disabled
  *-pnp00:00
       product: PnP device PNP0c02
       physical id: a
       capabilities: pnp
       configuration: driver=system
```

**Output Analysis**:
- **Virtualization Detection**: `systemd-detect-virt` returned "none" - this is expected for VirtualBox VMs
- **Hardware Abstraction**: VirtualBox successfully abstracts hardware, making detection challenging
- **System Architecture**: 64-bit ARM system with proper hardware abstraction


#### Reflection on Tool Usefulness

**Most Useful Tools**:

1. **lscpu**: Most comprehensive CPU information in a clean, organized format - Provides architecture, cores, features, and security information

2. **hostnamectl**: Comprehensive system information - Shows OS version, kernel, architecture

3. **df -h**: Essential disk usage information - Human-readable disk space usage and critical for storage monitoring

4. **free -h**: Best for quick memory overview - Human-readable format (GB, MB) and shows total, used, available memory at a glance

5. **ip addr show**: Modern network interface information - Shows all network interfaces with detailed configuration
