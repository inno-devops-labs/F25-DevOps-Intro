## Task 1
My OS and specs:
```sh
[rightrat@RatLaptop ~]$ neofetch
                     ./o.                  rightrat@RatLaptop 
                   ./sssso-                ------------------ 
                 `:osssssss+-              OS: EndeavourOS Linux x86_64 
               `:+sssssssssso/.            Host: HP 245 G8 Notebook PC 
             `-/ossssssssssssso/.          Kernel: 6.15.9-arch1-1 
           `-/+sssssssssssssssso+:`        Uptime: 1 hour, 19 mins 
         `-:/+sssssssssssssssssso+/.       Packages: 1632 (pacman) 
       `.://osssssssssssssssssssso++-      Shell: bash 5.3.3 
      .://+ssssssssssssssssssssssso++:     Resolution: 1920x1080 
    .:///ossssssssssssssssssssssssso++:    DE: Plasma 6.4.5 
  `:////ssssssssssssssssssssssssssso+++.   WM: kwin 
`-////+ssssssssssssssssssssssssssso++++-   Theme: [Plasma], Breeze-Dark [GTK2], Breeze [GTK3] 
 `..-+oosssssssssssssssssssssssso+++++/`   Icons: [Plasma], breeze [GTK2/3] 
   ./++++++++++++++++++++++++++++++/:.     Terminal: konsole 
  `:::::::::::::::::::::::::------``       CPU: AMD Ryzen 5 3500U with Radeon Vega Mobile Gfx (8) @ 2.100GHz 
                                           GPU: AMD ATI Radeon Vega Series / Radeon Vega Mobile Series 
                                           Memory: 2406MiB / 9853MiB 
```
TL;DR: EndeavourOS x86_64 (Arch-based)

**VirtualBox version**: VirtualBox Graphical User Interface Version 7.2.2 r170484

Had no issues during downloading, but during installation and VM launch I had to restart a couple of times for an unknown to me reason, probably loading VirtualBox's kernel helped

## Task 2
### CPU
```sh
vboxuser@ubuntu:~/Desktop$ lscpu
Architecture:                x86_64
  CPU op-mode(s):            32-bit, 64-bit
  Address sizes:             48 bits physical, 48 bits virtual
  Byte Order:                Little Endian
CPU(s):                      4
  On-line CPU(s) list:       0-3
Vendor ID:                   AuthenticAMD
  Model name:                AMD Ryzen 5 3500U with Radeon Vega Mobile Gfx
    CPU family:              23
    Model:                   24
    Thread(s) per core:      1
    Core(s) per socket:      4
    Socket(s):               1
    Stepping:                1
    BogoMIPS:                4192.24
    Flags:                   fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pg
                             e mca cmov pat pse36 clflush mmx fxsr sse sse2 ht s
                             yscall nx mmxext fxsr_opt rdtscp lm constant_tsc re
                             p_good nopl nonstop_tsc cpuid extd_apicid tsc_known
                             _freq pni pclmulqdq ssse3 fma cx16 sse4_1 sse4_2 x2
                             apic movbe popcnt aes xsave avx f16c rdrand hypervi
                             sor lahf_lm cmp_legacy cr8_legacy abm sse4a misalig
                             nsse 3dnowprefetch ssbd vmmcall fsgsbase bmi1 avx2 
                             bmi2 rdseed adx clflushopt sha_ni arat
Virtualization features:     
  Hypervisor vendor:         KVM
  Virtualization type:       full
Caches (sum of all):         
  L1d:                       128 KiB (4 instances)
  L1i:                       256 KiB (4 instances)
  L2:                        2 MiB (4 instances)
  L3:                        16 MiB (4 instances)
NUMA:                        
  NUMA node(s):              1
  NUMA node0 CPU(s):         0-3
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
Here I used the famous ``lscpu`` command to list descriptive info for my VM's virtual CPU

### Disk
```sh
vboxuser@ubuntu:~/Desktop$ lsblk
NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
loop0    7:0    0     4K  1 loop /snap/bare/5
loop1    7:1    0  73.9M  1 loop /snap/core22/2045
loop2    7:2    0 245.1M  1 loop /snap/firefox/6565
loop3    7:3    0  91.7M  1 loop /snap/gtk-common-themes/1535
loop4    7:4    0   516M  1 loop /snap/gnome-42-2204/202
loop5    7:5    0  11.1M  1 loop /snap/firmware-updater/167
loop6    7:6    0  10.8M  1 loop /snap/snap-store/1270
loop7    7:7    0  49.3M  1 loop /snap/snapd/24792
loop8    7:8    0   576K  1 loop /snap/snapd-desktop-integration/315
sda      8:0    0    25G  0 disk 
├─sda1   8:1    0     1M  0 part 
└─sda2   8:2    0    25G  0 part /
sr0     11:0    1  1024M  0 rom  
```
Here I decided to use lsblk to list all mounted devices (holy cow Ubuntu is bloated)

### Memory
```sh
vboxuser@ubuntu:~/Desktop$ free -m
               total        used        free      shared  buff/cache   available
Mem:            4917        1047        3062          36        1068        3870
Swap:              0           0           0
```
RAM usage, total and free

### Network
```sh
vboxuser@ubuntu:~/Desktop$ ip route
default via 10.0.2.2 dev enp0s3 proto dhcp src 10.0.2.15 metric 100 
10.0.2.0/24 dev enp0s3 proto kernel scope link src 10.0.2.15 metric 100
```
Basic routing settings, didn't config it in any way during installation

### System info
```sh
vboxuser@ubuntu:~/Desktop$ cat /etc/os-release 
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
Here I learned a new lifehack for looking up os name (was always using neofetch :skull:)

### Proof that VM
```sh
vboxuser@ubuntu:~/Desktop$ hostnamectl 
 Static hostname: ubuntu
       Icon name: computer-vm
         Chassis: vm 🖴
      Machine ID: c50151fd36d342ebb6cf17b01ad542a4
         Boot ID: 7d0e50988dd748ce97437e3a80b8ee48
  Virtualization: oracle
Operating System: Ubuntu 24.04.3 LTS              
          Kernel: Linux 6.14.0-33-generic
    Architecture: x86-64
 Hardware Vendor: innotek GmbH
  Hardware Model: VirtualBox
Firmware Version: VirtualBox
   Firmware Date: Fri 2006-12-01
    Firmware Age: 18y 10month 5d 
```
Here it is clear from the output that we are running on ``VirtualBox``, nobody names their beloved machine like that(I didn't)