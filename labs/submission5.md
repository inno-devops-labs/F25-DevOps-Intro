# Submission 5 — Virtualization & System Analysis

## VM / Host
- **VM**: Ubuntu 24.04 (guest)
- **CPU**: Intel(R) Core(TM) i5-10200H CPU @ 2.40GHz, 2 vCPU
- **Memory**: 3.8 GiB total, ~1.0 GiB used at the time of collection
- **Network**: enp0s3 → 10.0.2.15 (DHCP)
- **Storage**: root on /dev/sda2 (ext4), Guest Additions ISO mounted
- **Virtualization**: oracle (hypervisor)

---

## System report

```
=== Date ===
Sat Sep 27 12:52:47 PM MSK 2025

=== CPU ===
Architecture:                            x86_64
CPU op-mode(s):                          32-bit, 64-bit
Address sizes:                           39 bits physical, 48 bits virtual
Byte Order:                              Little Endian
CPU(s):                                  2
On-line CPU(s) list:                     0,1
Vendor ID:                               GenuineIntel
Model name:                              Intel(R) Core(TM) i5-10200H CPU @ 2.40GHz
CPU family:                              6
Model:                                   165
Thread(s) per core:                      1
Core(s) per socket:                      2
Socket(s):                               1
Stepping:                                2
BogoMIPS:                                4800.00
Flags:                                   fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ht syscall nx rdtscp lm constant_tsc rep_good nopl xtopology nonstop_tsc cpuid tsc_known_freq pni pclmulqdq ssse3 fma cx16 pcid sse4_1 sse4_2 movbe popcnt aes xsave avx f16c rdrand hypervisor lahf_lm abm 3dnowprefetch ibrs_enhanced fsgsbase bmi1 avx2 bmi2 invpcid rdseed adx clflushopt arat md_clear flush_l1d arch_capabilities
Hypervisor vendor:                       KVM
Virtualization type:                     full
L1d cache:                               64 KiB (2 instances)
L1i cache:                               64 KiB (2 instances)
L2 cache:                                512 KiB (2 instances)
L3 cache:                                16 MiB (2 instances)
NUMA node(s):                            1
NUMA node0 CPU(s):                       0,1
Vulnerability Gather data sampling:      Unknown: Dependent on hypervisor status
Vulnerability Ghostwrite:                Not affected
Vulnerability Indirect target selection: Mitigation; Aligned branch/return thunks
Vulnerability Itlb multihit:             KVM: Mitigation: VMX unsupported
Vulnerability L1tf:                      Not affected
Vulnerability Mds:                       Not affected
Vulnerability Meltdown:                  Not affected
Vulnerability Mmio stale data:           Vulnerable: Clear CPU buffers attempted, no microcode; SMT Host state unknown
Vulnerability Reg file data sampling:    Not affected
Vulnerability Retbleed:                  Mitigation; Enhanced IBRS
Vulnerability Spec rstack overflow:      Not affected
Vulnerability Spec store bypass:         Vulnerable
Vulnerability Spectre v1:                Mitigation; usercopy/swapgs barriers and __user pointer sanitization
Vulnerability Spectre v2:                Mitigation; Enhanced / Automatic IBRS; PBRSB-eIBRS SW sequence; BHI SW loop, KVM SW loop
Vulnerability Srbds:                     Unknown: Dependent on hypervisor status
Vulnerability Tsx async abort:           Not Affected
model name	: Intel(R) Core(TM) i5-10200H CPU @ 2.40GHz

=== Memory ===
               total        used        free      shared  buff/cache   available
Mem:           3.8Gi       1.0Gi       1.7Gi        34Mi       1.4Gi       2.8Gi
Swap:          3.8Gi          0B       3.8Gi
      4010564 K total memory
      1089116 K used memory
      1312548 K active memory
       653432 K inactive memory
      1734152 K free memory
        45944 K buffer memory
      1409940 K swap cache
      4009980 K total swap
            0 K used swap
      4009980 K free swap

=== Network ===
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host noprefixroute 
       valid_lft forever preferred_lft forever
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:72:fc:86 brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic noprefixroute enp0s3
       valid_lft 83762sec preferred_lft 83762sec
    inet6 fd17:625c:f037:2:b55f:782d:ceac:9fae/64 scope global temporary dynamic 
       valid_lft 86228sec preferred_lft 14228sec
    inet6 fd17:625c:f037:2:a00:27ff:fe72:fc86/64 scope global dynamic mngtmpaddr 
       valid_lft 86228sec preferred_lft 14228sec
    inet6 fe80::a00:27ff:fe72:fc86/64 scope link 
       valid_lft forever preferred_lft forever
default via 10.0.2.2 dev enp0s3 proto dhcp src 10.0.2.15 metric 100 
10.0.2.0/24 dev enp0s3 proto kernel scope link src 10.0.2.15 metric 100 
Netid State  Recv-Q Send-Q Local Address:Port  Peer Address:PortProcess
udp   UNCONN 0      0         127.0.0.54:53         0.0.0.0:*    uid:991 ino:7224 sk:1 cgroup:/system.slice/systemd-resolved.service <->      
udp   UNCONN 0      0      127.0.0.53%lo:53         0.0.0.0:*    uid:991 ino:7222 sk:2 cgroup:/system.slice/systemd-resolved.service <->      
udp   UNCONN 0      0            0.0.0.0:51913      0.0.0.0:*    uid:108 ino:10306 sk:3 cgroup:/system.slice/avahi-daemon.service <->         
udp   UNCONN 0      0            0.0.0.0:5353       0.0.0.0:*    uid:108 ino:10304 sk:4 cgroup:/system.slice/avahi-daemon.service <->         
udp   UNCONN 0      0               [::]:56862         [::]:*    uid:108 ino:10307 sk:5 cgroup:/system.slice/avahi-daemon.service v6only:1 <->
udp   UNCONN 0      0               [::]:5353          [::]:*    uid:108 ino:10305 sk:6 cgroup:/system.slice/avahi-daemon.service v6only:1 <->
tcp   LISTEN 0      4096       127.0.0.1:631        0.0.0.0:*    ino:10902 sk:7 cgroup:/system.slice/cups.service <->                          
tcp   LISTEN 0      4096      127.0.0.54:53         0.0.0.0:*    uid:991 ino:7225 sk:8 cgroup:/system.slice/systemd-resolved.service <->      
tcp   LISTEN 0      4096   127.0.0.53%lo:53         0.0.0.0:*    uid:991 ino:7223 sk:9 cgroup:/system.slice/systemd-resolved.service <->      
tcp   LISTEN 0      4096           [::1]:631           [::]:*    ino:10901 sk:a cgroup:/system.slice/cups.service v6only:1 <->                 

=== Storage ===
NAME   FSTYPE   FSVER            LABEL          UUID                                 FSAVAIL FSUSE% MOUNTPOINTS
loop0  squashfs 4.0                                                                        0   100% /snap/bare/5
loop1  squashfs 4.0                                                                        0   100% /snap/core22/2045
loop2  squashfs 4.0                                                                        0   100% /snap/firefox/6565
loop3  squashfs 4.0                                                                        0   100% /snap/firmware-updater/167
loop4  squashfs 4.0                                                                        0   100% /snap/gnome-42-2204/202
loop5  squashfs 4.0                                                                        0   100% /snap/gtk-common-themes/1535
loop6  squashfs 4.0                                                                        0   100% /snap/snapd-desktop-integration/315
loop7  squashfs 4.0                                                                        0   100% /snap/snap-store/1270
loop8  squashfs 4.0                                                                        0   100% /snap/snapd/24792
sda
в”њв”Ђsda1
в””в”Ђsda2 ext4     1.0                             c205f472-9903-47e0-b5e7-6b14e8d3ca5b   14.1G    37% /
sr0    iso9660  Joliet Extension VBox_GAs_7.2.2 2025-09-10-17-10-16-91                     0   100% /media/ilyas/VBox_GAs_7.2.2
/dev/sda2: UUID="c205f472-9903-47e0-b5e7-6b14e8d3ca5b" BLOCK_SIZE="4096" TYPE="ext4" PARTUUID="a53bb056-25cf-4a81-b6ad-f82c828a230d"
/dev/loop1: BLOCK_SIZE="131072" TYPE="squashfs"
 /dev/loop8: BLOCK_SIZE="131072" TYPE="squashfs"
 /dev/loop6: BLOCK_SIZE="131072" TYPE="squashfs"
 /dev/loop4: BLOCK_SIZE="131072" TYPE="squashfs"
 /dev/sr0: BLOCK_SIZE="2048" UUID="2025-09-10-17-10-16-91" LABEL="VBox_GAs_7.2.2" TYPE="iso9660"
 /dev/loop2: BLOCK_SIZE="131072" TYPE="squashfs"
 /dev/loop0: BLOCK_SIZE="131072" TYPE="squashfs"
 /dev/loop7: BLOCK_SIZE="131072" TYPE="squashfs"
 /dev/sda1: PARTUUID="4b9db931-d1e5-44de-ab78-5b0c28ed0e85"
 /dev/loop5: BLOCK_SIZE="131072" TYPE="squashfs"
 /dev/loop3: BLOCK_SIZE="131072" TYPE="squashfs"

=== Virtualization detection ===
oracle
```

# Issues

- **Guest Additions mount/installation problem**  
  While attempting to attach and run the Guest Additions ISO, VirtualBox reported a `VERR_PDM_MEDIA_LOCKED` error, which prevented mounting the ISO while the VM was running. The root causes and fixes are:
  - Cause: the virtual optical drive was locked because the VM or VirtualBox service was using it.
  - Fixes tried:
    1. Power off the VM and attach the ISO via *Settings → Storage* instead of the live menu.
    2. Close VirtualBox and ensure no `VBoxSVC.exe` processes are running on the host. Start VirtualBox as administrator and reattach the ISO.
    3. If attaching still fails, reboot the host to clear the lock.
    4. As an alternative to ISO installation, install guest packages inside the guest:
       ```bash
       sudo apt update
       sudo apt install -y virtualbox-guest-dkms virtualbox-guest-utils virtualbox-guest-x11
       sudo reboot
       ```
  - Secondary issue: Secure Boot on the host/guest can block unsigned kernel modules. If module build is blocked, either disable Secure Boot in BIOS/UEFI or enroll the MOK key when prompted during installation.

# Commands used to collect system information

We used the following commands in the guest to collect the report:

```bash
date
lscpu
nproc --all
grep -m1 "model name" /proc/cpuinfo

free -h
vmstat -s | head -n 10

ip addr
ip route
ss -tulpen

lsblk -f
df -hT
sudo blkid

uname -a
cat /etc/os-release
hostnamectl

systemd-detect-virt
sudo dmidecode -s system-manufacturer -s system-product-name
which virt-what || true
dmesg | grep -i -E "hypervisor|virtual" || true
```

## Reflection
Installed Ubuntu 24.04, mounted and ran Guest Additions, and collected system information. The main problem was attaching the Guest Additions ISO while VM was running which required powering off the VM and attaching the ISO via Settings, or using repository packages as a fallback.

