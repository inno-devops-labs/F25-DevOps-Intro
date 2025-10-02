# Task 1

## Installation
- OS: MacOS Tahoe 26.0.1 (25A362)
- VirtualBox: Version 7.2.2 r170484 (Qt6.8.0 on cocoa)
- No issues were encountered at this stage

# Task 2

I have encountered a problem, that Intel/AMD 64 Bit images weren't possible to run on my mac even through virtualization. To resolve this, I have installed [Ubuntu 24.04.3 (Noble Numbat)](https://cdimage.ubuntu.com/releases/noble/release/)

## VM Configuration
- *RAM*: 6144 MB (6GB)
- *CPUs*: 4
- *Disk*: 25 GB

## System Information Discovery
### CPU
```sh
$ lscpu
```
```
Architecture:                aarch64
  CPU op-mode(s):            64-bit
  Byte Order:                Little Endian
CPU(s):                      4
  On-line CPU(s) list:       0-3
Vendor ID:                   Apple
  Model name:                -
    Model:                   0
    Thread(s) per core:      1
    Core(s) per cluster:     4
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
  Retbleed:                  Not affected
  Spec rstack overflow:      Not affected
  Spec store bypass:         Vulnerable
  Spectre v1:                Mitigation; __user pointer sanitization
  Spectre v2:                Mitigation; CSV2, but not BHB
  Srbds:                     Not affected
  Tsx async abort:           Not affected

```
### Memory
```sh
$ free -h
```
```
               total        used        free      shared  buff/cache   available
Mem:           5.8Gi       969Mi       4.1Gi        33Mi       888Mi       4.8Gi
Swap:             0B          0B          0B
```

```sh
$ vmstat -s
```
```
      6045012 K total memory
       984584 K used memory
      1254912 K active memory
       202272 K inactive memory
      4335188 K free memory
        35476 K buffer memory
       876396 K swap cache
            0 K total swap
            0 K used swap
            0 K free swap
         1023 non-nice user cpu ticks
           64 nice user cpu ticks
          983 system cpu ticks
       121898 idle cpu ticks
          237 IO-wait cpu ticks
            0 IRQ cpu ticks
           42 softirq cpu ticks
            0 stolen cpu ticks
            0 non-nice guest cpu ticks
            0 nice guest cpu ticks
       723544 K paged in
        24205 K paged out
            0 pages swapped in
            0 pages swapped out
       156836 interrupts
       279755 CPU context switches
   1759397297 boot time
         3060 forks
```
### Network
```sh
$ ip addr show
```
```
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host noprefixroute 
       valid_lft forever preferred_lft forever
2: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:8b:3d:7f brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic noprefixroute enp0s8
       valid_lft 86057sec preferred_lft 86057sec
    inet6 fd17:625c:f037:2:525a:20a:32d9:b08b/64 scope global temporary dynamic 
       valid_lft 86058sec preferred_lft 14058sec
    inet6 fd17:625c:f037:2:a00:27ff:fe8b:3d7f/64 scope global dynamic mngtmpaddr 
       valid_lft 86058sec preferred_lft 14058sec
    inet6 fe80::a00:27ff:fe8b:3d7f/64 scope link 
       valid_lft forever preferred_lft forever
```

```sh
$ hostname -I
```
```
10.0.2.15 fd17:625c:f037:2:525a:20a:32d9:b08b fd17:625c:f037:2:a00:27ff:fe8b:3d7f 
```
### Storage
```sh
$ df -h
```
```
Filesystem      Size  Used Avail Use% Mounted on
tmpfs           591M  1.5M  589M   1% /run
/dev/sda2        24G  5.7G   17G  26% /
tmpfs           2.9G     0  2.9G   0% /dev/shm
tmpfs           5.0M  8.0K  5.0M   1% /run/lock
efivarfs        256K  102K  155K  40% /sys/firmware/efi/efivars
/dev/sda1       1.1G  6.4M  1.1G   1% /boot/efi
tmpfs           591M  120K  591M   1% /run/user/1000
/dev/sr0         51M   51M     0 100% /media/user/VBox_GAs_7.2.21
```
```sh
$ lsblk -f
```
```
NAME FSTYPE FSVER LABEL          UUID                                 FSAVAIL FSUSE% MOUNTPOINTS
loop0
     squash 4.0                                                             0   100% /snap/bare/5
loop1
     squash 4.0                                                             0   100% /snap/core22/2049
loop2
     squash 4.0                                                             0   100% /snap/gnome-42-2204/201
loop3
     squash 4.0                                                             0   100% /snap/firefox/6563
loop4
     squash 4.0                                                             0   100% /snap/gtk-common-themes/1535
loop5
     squash 4.0                                                             0   100% /snap/snap-store/1271
loop6
     squash 4.0                                                             0   100% /snap/snapd/24787
loop7
     squash 4.0                                                             0   100% /snap/snapd-desktop-integration/316
sda                                                                                  
├─sda1
│    vfat   FAT32                88AB-6AA2                                 1G     1% /boot/efi
└─sda2
     ext4   1.0                  119f9ec7-15a8-418a-a66e-d41c3b42d3d3   16.5G    24% /
sr0  iso966 Jolie VBox_GAs_7.2.2 2025-09-10-17-10-16-91                     0   100% /media/user/VBox_GAs_7.2.21
```
### OS Information
```sh
$ hostnamectl
```
```
 Static hostname: ItDO-VM
       Icon name: computer
      Machine ID: 9d7e238a29cb4326ad7f1067a9d5fca8
         Boot ID: 2fa763d28eaf47dd9d3d3aeb537d29bf
Operating System: Ubuntu 24.04.3 LTS              
          Kernel: Linux 6.14.0-33-generic
    Architecture: arm64
```
```sh
$ uname -a
```
```
Linux ItDO-VM 6.14.0-33-generic #33~24.04.1-Ubuntu SMP PREEMPT_DYNAMIC Fri Sep 19 16:19:58 UTC 2 aarch64 aarch64 aarch64 GNU/Linux
```
```sh
$ lsb_release -a
```
```
No LSB modules are available.
Distributor ID:	Ubuntu
Description:	Ubuntu 24.04.3 LTS
Release:	24.04
Codename:	noble
```
### Virtualization Detection
I have encountered a problem: standard VM detection commands misbehave on VM running inside VirtualBox on Apple Silicon: `systemd-detect-virt` returns “none”, `virt-what` returns nothing, and `dmidecode` fails due to missing SMBIOS/DMI tables. As I found on internet, this is a known limitation of VirtualBox’s ARM port, not a configuration error.

So I have used other commands to provide evidence that the system is running on a VM.
```sh
$ sudo dmesg | grep -i virtual
```
```
[    0.446990] usb 1-1: Manufacturer: VirtualBox
[    0.683089] usb 1-2: Manufacturer: VirtualBox
[    0.691243] input: VirtualBox USB Keyboard as /devices/pci0000:00/0000:00:06.0/usb1/1-1/1-1:1.0/0003:80EE:0010.0001/input/input0
[    0.742844] hid-generic 0003:80EE:0010.0001: input,hidraw0: USB HID v1.10 Keyboard [VirtualBox USB Keyboard] on usb-0000:00:06.0-1/input0
[    0.743045] input: VirtualBox USB Tablet as /devices/pci0000:00/0000:00:06.0/usb1/1-2/1-2:1.0/0003:80EE:0021.0002/input/input1
[    0.743348] hid-generic 0003:80EE:0021.0002: input,hidraw1: USB HID v1.10 Mouse [VirtualBox USB Tablet] on usb-0000:00:06.0-2/input0
[    2.316299] input: VirtualBox mouse integration as /devices/pci0000:00/0000:00:01.0/input/input2
```
```sh
$ lsmod | grep vbox
```
```
vboxguest             507904  4
```
```sh
$ lspci | grep -i virtualbox
```
```
00:01.0 System peripheral: InnoTek Systemberatung GmbH VirtualBox Guest Service
```

## Reflection

- lscpu and hostnamectl provided quick, high-signal CPU and OS details without extra packages.
- ip addr and hostname -I were the most reliable for network configuration.
- df -h and lsblk -f complemented each other for storage usage versus device layout.
- For virtualization on Apple Silicon, dmesg, lsmod, and lspci gave conclusive proof when systemd-detect-virt/virt-what did not.

Overall, built-in tools covered everything needed; I would start with them first.