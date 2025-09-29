## Task 1

### systemd-analyze
```sh
[rightrat@RatLaptop ~]$ systemd-analyze 
Startup finished in 3.065s (firmware) + 2.951s (loader) + 1.083s (kernel) + 2.279s (initrd) + 17.598s (userspace) = 26.977s 
graphical.target reached after 9.200s in userspace.
```
So, to see the login screen I had to wait approx. 10s

```sh
[rightrat@RatLaptop ~]$ systemd-analyze blame
8.547s NetworkManager-wait-online.service
5.557s firewalld.service
4.807s systemd-logind.service
2.424s dev-ttyS3.device
2.424s sys-devices-platform-serial8250-serial8250:0-serial8250:0.3-tty-ttyS3.device
2.423s sys-devices-platform-serial8250-serial8250:0-serial8250:0.2-tty-ttyS2.device
2.423s dev-ttyS2.device
2.416s sys-devices-platform-serial8250-serial8250:0-serial8250:0.1-tty-ttyS1.device
2.416s dev-ttyS1.device
2.411s sys-devices-platform-serial8250-serial8250:0-serial8250:0.0-tty-ttyS0.device
2.411s dev-ttyS0.device
2.390s sys-devices-LNXSYSTM:00-LNXSYBUS:00-MSFT0101:00-tpmrm-tpmrm0.device
2.390s dev-tpmrm0.device
2.378s sys-module-configfs.device
2.375s sys-module-fuse.device
2.148s dev-disk-by\x2dpartuuid-50182679\x2d29ea\x2d40d0\x2da4e6\x2da4f94f4d2483.device
2.148s dev-disk-by\x2ddiskseq-1\x2dpart1.device
2.148s dev-disk-by\x2did-nvme\x2dSK_hynix_BC511_HFM256GDJTNI\x2d82A0A_NY12N079710602Q38\x2dpart1.device
2.148s dev-disk-by\x2dpath-pci\x2d0000:01:00.0\x2dnvme\x2d1\x2dpart-by\x2duuid-467D\x2d50AC.device
2.148s sys-devices-pci0000:00-0000:00:01.2-0000:01:00.0-nvme-nvme0-nvme0n1-nvme0n1p1.device
2.148s dev-disk-by\x2did-nvme\x2dSK_hynix_BC511_HFM256GDJTNI\x2d82A0A_NY12N079710602Q38_1\x2dpart1.device
2.148s dev-disk-by\x2did-nvme\x2deui.ace42e001a17602b\x2dpart1.device
2.148s dev-disk-by\x2dpath-pci\x2d0000:01:00.0\x2dnvme\x2d1\x2dpart-by\x2dpartnum-1.device
2.148s dev-disk-by\x2dpath-pci\x2d0000:01:00.0\x2dnvme\x2d1\x2dpart-by\x2dpartuuid-50182679\x2d29ea\x2d40d0\x2da4e6\x2da4f94f4d2483.device
2.148s dev-nvme0n1p1.device
2.148s dev-disk-by\x2dpath-pci\x2d0000:01:00.0\x2dnvme\x2d1\x2dpart1.device
2.148s dev-disk-by\x2duuid-467D\x2d50AC.device
2.143s dev-nvme0n1.device
2.143s dev-disk-by\x2did-nvme\x2dSK_hynix_BC511_HFM256GDJTNI\x2d82A0A_NY12N079710602Q38_1.device
2.143s dev-disk-by\x2ddiskseq-1.device
2.143s dev-disk-by\x2did-nvme\x2deui.ace42e001a17602b.device
2.143s dev-disk-by\x2did-nvme\x2dSK_hynix_BC511_HFM256GDJTNI\x2d82A0A_NY12N079710602Q38.device
2.143s sys-devices-pci0000:00-0000:00:01.2-0000:01:00.0-nvme-nvme0-nvme0n1.device
2.143s dev-disk-by\x2dpath-pci\x2d0000:01:00.0\x2dnvme\x2d1.device
2.141s dev-disk-by\x2dpath-pci\x2d0000:01:00.0\x2dnvme\x2d1\x2dpart-by\x2dpartuuid-5cb2d3f8\x2df106\x2d45b2\x2daaed\x2d6b30912950dc.device
2.141s dev-disk-by\x2did-nvme\x2dSK_hynix_BC511_HFM256GDJTNI\x2d82A0A_NY12N079710602Q38_1\x2dpart2.device
2.141s dev-disk-by\x2ddiskseq-1\x2dpart2.device
2.141s dev-disk-by\x2dpath-pci\x2d0000:01:00.0\x2dnvme\x2d1\x2dpart-by\x2dpartnum-2.device
2.141s dev-disk-by\x2did-nvme\x2dSK_hynix_BC511_HFM256GDJTNI\x2d82A0A_NY12N079710602Q38\x2dpart2.device
2.141s dev-disk-by\x2duuid-f7d09170\x2dd416\x2d4d78\x2da83c\x2d6bf1c3027bc9.device
2.140s dev-disk-by\x2dpath-pci\x2d0000:01:00.0\x2dnvme\x2d1\x2dpart-by\x2dlabel-endeavouros.device
2.140s dev-disk-by\x2dpath-pci\x2d0000:01:00.0\x2dnvme\x2d1\x2dpart-by\x2dpartlabel-endeavouros.device
2.140s dev-disk-by\x2dpath-pci\x2d0000:01:00.0\x2dnvme\x2d1\x2dpart-by\x2duuid-f7d09170\x2dd416\x2d4d78\x2da83c\x2d6bf1c3027bc9.device
2.140s dev-disk-by\x2dpartuuid-5cb2d3f8\x2df106\x2d45b2\x2daaed\x2d6b30912950dc.device
2.140s dev-disk-by\x2did-nvme\x2deui.ace42e001a17602b\x2dpart2.device
2.140s dev-nvme0n1p2.device
2.140s dev-disk-by\x2dpath-pci\x2d0000:01:00.0\x2dnvme\x2d1\x2dpart2.device
2.140s sys-devices-pci0000:00-0000:00:01.2-0000:01:00.0-nvme-nvme0-nvme0n1-nvme0n1p2.device
2.140s dev-disk-by\x2dpartlabel-endeavouros.device
2.140s dev-disk-by\x2dlabel-endeavouros.device
1.307s NetworkManager.service
1.090s upower.service
 728ms initrd-switch-root.service
 552ms systemd-udev-trigger.service
 318ms systemd-battery-check.service
 299ms systemd-fsck-root.service
 248ms user@1000.service
 192ms systemd-tmpfiles-setup.service
 141ms systemd-journald.service
 132ms systemd-hostnamed.service
 129ms systemd-tmpfiles-setup-dev-early.service
 129ms systemd-journal-flush.service
 118ms systemd-boot-random-seed.service
 115ms efi.mount
 114ms dracut-cmdline.service
  99ms polkit.service
  97ms systemd-udevd.service
  90ms dracut-pre-udev.service
  88ms udisks2.service
  86ms dracut-pre-trigger.service
  86ms systemd-timesyncd.service
  84ms dev-hugepages.mount
  82ms dev-mqueue.mount
  82ms sys-kernel-debug.mount
  78ms systemd-rfkill.service
  73ms systemd-fsck@dev-disk-by\x2duuid-467D\x2d50AC.service
  73ms sys-kernel-tracing.mount
  72ms power-profiles-daemon.service
  70ms initrd-cleanup.service
  68ms tmp.mount
  68ms kmod-static-nodes.service
  67ms avahi-daemon.service
  67ms lvm2-monitor.service
  66ms modprobe@drm.service
  61ms systemd-tmpfiles-setup-dev.service
  59ms systemd-update-utmp.service
  57ms initrd-parse-etc.service
  54ms systemd-userdbd.service
  54ms systemd-vconsole-setup.service
  49ms alsa-restore.service
  49ms dbus-broker.service
  48ms systemd-modules-load.service
  47ms systemd-remount-fs.service
  46ms dracut-initqueue.service
  43ms systemd-udev-load-credentials.service
  39ms sys-fs-fuse-connections.mount
  38ms user-runtime-dir@1000.service
  36ms initrd-udevadm-cleanup-db.service
  35ms dracut-shutdown.service
  35ms rtkit-daemon.service
  34ms dracut-pre-mount.service
  34ms wpa_supplicant.service
  33ms systemd-random-seed.service
  33ms modprobe@dm_mod.service
  31ms systemd-backlight@backlight:amdgpu_bl1.service
  31ms dracut-pre-pivot.service
  28ms modprobe@loop.service
  27ms systemd-user-sessions.service
  24ms modprobe@configfs.service
  22ms systemd-sysctl.service
  22ms modprobe@fuse.service
```
Here we can see the breakdown of the times thet the processes required during boot
### Process Forensics
#### Resourse-heaviness
```sh
[rightrat@RatLaptop ~]$ ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 6
    PID    PPID CMD                         %MEM %CPU
   2144     914 /usr/lib/firefox/firefox     5.4  8.3
   1414     914 /usr/bin/Telegram -autostar  5.3  2.5
   2939     914 /opt/visual-studio-code/cod  3.9  3.0
   1180     914 /usr/bin/plasmashell --no-r  3.7  5.9
    961     956 /usr/bin/kwin_wayland --way  3.1  6.7
```

```sh
[rightrat@RatLaptop ~]$ ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 6
    PID    PPID CMD                         %MEM %CPU
   4824    4066 ps -eo pid,ppid,cmd,%mem,%c  0.0  100
   3039    2945 /opt/visual-studio-code/cod  2.7 16.8
   2144     914 /usr/lib/firefox/firefox     5.5  7.4
   2979    2942 /opt/visual-studio-code/cod  1.6  7.2
    961     956 /usr/bin/kwin_wayland --way  3.1  7.0

```
We can note that the most memory-heavy process is the Firefox process, which is expected of a browser. But VS Code is heavier on CPU (and is where I run the ps command from).

#### System Dependencies
```sh
[rightrat@RatLaptop ~]$ systemctl list-dependencies
default.target
● ├─power-profiles-daemon.service
● ├─sddm.service
● └─multi-user.target
●   ├─AmneziaVPN.service
●   ├─avahi-daemon.service
×   ├─cloudflared-proxy-dns.service
●   ├─dbus-broker.service
○   ├─dnscrypt-proxy.service
●   ├─firewalld.service
●   ├─NetworkManager.service
●   ├─systemd-ask-password-wall.path
●   ├─systemd-logind.service
●   ├─systemd-user-sessions.service
●   ├─basic.target
●   │ ├─-.mount
●   │ ├─tmp.mount
●   │ ├─paths.target
●   │ ├─slices.target
●   │ │ ├─-.slice
●   │ │ └─system.slice
●   │ ├─sockets.target
●   │ │ ├─avahi-daemon.socket
●   │ │ ├─dbus.socket
●   │ │ ├─dirmngr@etc-pacman.d-gnupg.socket
●   │ │ ├─dm-event.socket
●   │ │ ├─gpg-agent-browser@etc-pacman.d-gnupg.socket
●   │ │ ├─gpg-agent-extra@etc-pacman.d-gnupg.socket
●   │ │ ├─gpg-agent-ssh@etc-pacman.d-gnupg.socket
●   │ │ ├─gpg-agent@etc-pacman.d-gnupg.socket
●   │ │ ├─keyboxd@etc-pacman.d-gnupg.socket
●   │ │ ├─sshd-unix-local.socket
●   │ │ ├─systemd-bootctl.socket
●   │ │ ├─systemd-coredump.socket
●   │ │ ├─systemd-creds.socket
●   │ │ ├─systemd-hostnamed.socket
●   │ │ ├─systemd-importd.socket
●   │ │ ├─systemd-journald-dev-log.socket
●   │ │ ├─systemd-journald.socket
○   │ │ ├─systemd-pcrextend.socket
○   │ │ ├─systemd-pcrlock.socket
●   │ │ ├─systemd-sysext.socket
●   │ │ ├─systemd-udevd-control.socket
●   │ │ ├─systemd-udevd-kernel.socket
●   │ │ └─systemd-userdbd.socket
●   │ ├─sysinit.target
●   │ │ ├─dev-hugepages.mount
●   │ │ ├─dev-mqueue.mount
●   │ │ ├─dracut-shutdown.service
●   │ │ ├─kmod-static-nodes.service
○   │ │ ├─ldconfig.service
●   │ │ ├─lvm2-lvmpolld.socket
●   │ │ ├─lvm2-monitor.service
●   │ │ ├─proc-sys-fs-binfmt_misc.automount
●   │ │ ├─sys-fs-fuse-connections.mount
●   │ │ ├─sys-kernel-config.mount
●   │ │ ├─sys-kernel-debug.mount
●   │ │ ├─sys-kernel-tracing.mount
●   │ │ ├─systemd-ask-password-console.path
○   │ │ ├─systemd-binfmt.service
●   │ │ ├─systemd-boot-random-seed.service
○   │ │ ├─systemd-firstboot.service
○   │ │ ├─systemd-hibernate-clear.service
○   │ │ ├─systemd-hwdb-update.service
○   │ │ ├─systemd-journal-catalog-update.service
●   │ │ ├─systemd-journal-flush.service
●   │ │ ├─systemd-journald.service
○   │ │ ├─systemd-machine-id-commit.service
●   │ │ ├─systemd-modules-load.service
○   │ │ ├─systemd-pcrmachine.service
○   │ │ ├─systemd-pcrphase-sysinit.service
○   │ │ ├─systemd-pcrphase.service
●   │ │ ├─systemd-random-seed.service
○   │ │ ├─systemd-repart.service
●   │ │ ├─systemd-sysctl.service
○   │ │ ├─systemd-sysusers.service
●   │ │ ├─systemd-timesyncd.service
●   │ │ ├─systemd-tmpfiles-setup-dev-early.service
●   │ │ ├─systemd-tmpfiles-setup-dev.service
●   │ │ ├─systemd-tmpfiles-setup.service
○   │ │ ├─systemd-tpm2-setup-early.service
○   │ │ ├─systemd-tpm2-setup.service
●   │ │ ├─systemd-udev-trigger.service
●   │ │ ├─systemd-udevd.service
○   │ │ ├─systemd-update-done.service
●   │ │ ├─systemd-update-utmp.service
●   │ │ ├─cryptsetup.target
●   │ │ ├─integritysetup.target
●   │ │ ├─local-fs.target
●   │ │ │ ├─-.mount
●   │ │ │ ├─efi.mount
●   │ │ │ ├─systemd-fsck-root.service
●   │ │ │ ├─systemd-remount-fs.service
●   │ │ │ └─tmp.mount
●   │ │ ├─swap.target
●   │ │ └─veritysetup.target
●   │ └─timers.target
●   │   ├─archlinux-keyring-wkd-sync.timer
●   │   ├─fstrim.timer
●   │   ├─logrotate.timer
●   │   ├─man-db.timer
●   │   ├─plocate-updatedb.timer
●   │   ├─shadow.timer
●   │   └─systemd-tmpfiles-clean.timer
●   └─getty.target
○     └─getty@tty1.service
```

```sh
[rightrat@RatLaptop ~]$ systemctl list-dependencies multi-user.target
multi-user.target
● ├─AmneziaVPN.service
● ├─avahi-daemon.service
× ├─cloudflared-proxy-dns.service
● ├─dbus-broker.service
○ ├─dnscrypt-proxy.service
● ├─firewalld.service
● ├─NetworkManager.service
● ├─systemd-ask-password-wall.path
● ├─systemd-logind.service
● ├─systemd-user-sessions.service
● ├─basic.target
● │ ├─-.mount
● │ ├─tmp.mount
● │ ├─paths.target
● │ ├─slices.target
● │ │ ├─-.slice
● │ │ └─system.slice
● │ ├─sockets.target
● │ │ ├─avahi-daemon.socket
● │ │ ├─dbus.socket
● │ │ ├─dirmngr@etc-pacman.d-gnupg.socket
● │ │ ├─dm-event.socket
● │ │ ├─gpg-agent-browser@etc-pacman.d-gnupg.socket
● │ │ ├─gpg-agent-extra@etc-pacman.d-gnupg.socket
● │ │ ├─gpg-agent-ssh@etc-pacman.d-gnupg.socket
● │ │ ├─gpg-agent@etc-pacman.d-gnupg.socket
● │ │ ├─keyboxd@etc-pacman.d-gnupg.socket
● │ │ ├─sshd-unix-local.socket
● │ │ ├─systemd-bootctl.socket
● │ │ ├─systemd-coredump.socket
● │ │ ├─systemd-creds.socket
● │ │ ├─systemd-hostnamed.socket
● │ │ ├─systemd-importd.socket
● │ │ ├─systemd-journald-dev-log.socket
● │ │ ├─systemd-journald.socket
○ │ │ ├─systemd-pcrextend.socket
○ │ │ ├─systemd-pcrlock.socket
● │ │ ├─systemd-sysext.socket
● │ │ ├─systemd-udevd-control.socket
● │ │ ├─systemd-udevd-kernel.socket
● │ │ └─systemd-userdbd.socket
● │ ├─sysinit.target
● │ │ ├─dev-hugepages.mount
● │ │ ├─dev-mqueue.mount
● │ │ ├─dracut-shutdown.service
● │ │ ├─kmod-static-nodes.service
○ │ │ ├─ldconfig.service
● │ │ ├─lvm2-lvmpolld.socket
● │ │ ├─lvm2-monitor.service
● │ │ ├─proc-sys-fs-binfmt_misc.automount
● │ │ ├─sys-fs-fuse-connections.mount
● │ │ ├─sys-kernel-config.mount
● │ │ ├─sys-kernel-debug.mount
● │ │ ├─sys-kernel-tracing.mount
● │ │ ├─systemd-ask-password-console.path
○ │ │ ├─systemd-binfmt.service
● │ │ ├─systemd-boot-random-seed.service
○ │ │ ├─systemd-firstboot.service
○ │ │ ├─systemd-hibernate-clear.service
○ │ │ ├─systemd-hwdb-update.service
○ │ │ ├─systemd-journal-catalog-update.service
● │ │ ├─systemd-journal-flush.service
● │ │ ├─systemd-journald.service
○ │ │ ├─systemd-machine-id-commit.service
● │ │ ├─systemd-modules-load.service
○ │ │ ├─systemd-pcrmachine.service
○ │ │ ├─systemd-pcrphase-sysinit.service
○ │ │ ├─systemd-pcrphase.service
● │ │ ├─systemd-random-seed.service
○ │ │ ├─systemd-repart.service
● │ │ ├─systemd-sysctl.service
○ │ │ ├─systemd-sysusers.service
● │ │ ├─systemd-timesyncd.service
● │ │ ├─systemd-tmpfiles-setup-dev-early.service
● │ │ ├─systemd-tmpfiles-setup-dev.service
● │ │ ├─systemd-tmpfiles-setup.service
○ │ │ ├─systemd-tpm2-setup-early.service
○ │ │ ├─systemd-tpm2-setup.service
● │ │ ├─systemd-udev-trigger.service
● │ │ ├─systemd-udevd.service
○ │ │ ├─systemd-update-done.service
● │ │ ├─systemd-update-utmp.service
● │ │ ├─cryptsetup.target
● │ │ ├─integritysetup.target
● │ │ ├─local-fs.target
● │ │ │ ├─-.mount
● │ │ │ ├─efi.mount
● │ │ │ ├─systemd-fsck-root.service
● │ │ │ ├─systemd-remount-fs.service
● │ │ │ └─tmp.mount
● │ │ ├─swap.target
● │ │ └─veritysetup.target
● │ └─timers.target
● │   ├─archlinux-keyring-wkd-sync.timer
● │   ├─fstrim.timer
● │   ├─logrotate.timer
● │   ├─man-db.timer
● │   ├─plocate-updatedb.timer
● │   ├─shadow.timer
● │   └─systemd-tmpfiles-clean.timer
● └─getty.target
○   └─getty@tty1.service
```
This is the list of dependencies on my system

#### User sessions
```sh
[rightrat@RatLaptop ~]$ who -a
           system boot  2025-09-29 19:12
rightrat + tty1         2025-09-29 19:13 00:24         930
rightrat - pts/1        2025-09-29 19:20   .          4066 (:1)
```

```sh
[rightrat@RatLaptop ~]$ last -n 5
rightrat pts/1        :1               Mon Sep 29 19:20   still logged in
rightrat tty1                          Mon Sep 29 19:13   still logged in
reboot   system boot  6.15.9-arch1-1   Mon Sep 29 19:12   still running
rightrat tty1                          Tue Sep 23 11:07 - down   (01:19)
reboot   system boot  6.15.9-arch1-1   Tue Sep 23 11:07 - 12:27  (01:20)

wtmp begins Wed Mar  6 05:37:32 2024
```
As you can see, I currently use this machine only when I need Linux stuff (which explains the 1-week gap in boots)

#### Memory Analysis
```sh
[rightrat@RatLaptop ~]$ free -h
               total        used        free      shared  buff/cache   available
Mem:           9,6Gi       3,3Gi       3,7Gi       129Mi       2,8Gi       6,3Gi
Swap:             0B          0B          0B
```

```sh
[rightrat@RatLaptop ~]$ cat /proc/meminfo | grep -e MemTotal -e SwapTotal -e MemAvailable
MemTotal:       10089704 kB
MemAvailable:    6665592 kB
SwapTotal:             0 kB

```
It should be noted that I have 4+8GB of RAM installed, meaning that approx 2.4GB are taken by the integrated graphics

## Task 2

### Network Path Tracing

#### Traceroute Execution

```sh
[rightrat@RatLaptop ~]$ traceroute github.com
traceroute to github.com (140.82.121.XXX), 30 hops max, 60 byte packets
 1  _gateway (192.168.3.XXX)  1.545 ms  1.466 ms  1.432 ms
 2  10.248.1.XXX (10.248.1.XXX)  4.404 ms  5.371 ms  5.341 ms
 3  10.250.0.XXX (10.250.0.XXX)  4.305 ms  4.237 ms  4.183 ms
 4  10.252.6.XXX (10.252.6.XXX)  5.351 ms  5.315 ms  5.280 ms
 5  1.123.18.XXX.in-addr.arpa (84.18.123.XXX)  13.123 ms  13.599 ms  29.794 ms
 6  178.176.191.XXX (178.176.191.XXX)  8.873 ms  8.283 ms  8.168 ms
 7  * * *
 8  * * *
 9  * * *
10  * * *
11  83.169.204.XXX (83.169.204.XXX)  101.221 ms  101.434 ms 83.169.204.XXX (83.169.204.XXX)  101.402 ms
12  netnod-ix-ge-b-sth-1500.inter.link (194.68.128.XXX)  102.319 ms netnod-ix-ge-a-sth-1500.inter.link (194.68.123.XXX)  102.071 ms  101.727 ms
13  * * *
14  * * *
15  * * *
16  * * *
17  * * *
18  * * *
19  r1-fra3-de.as5405.net (94.103.180.XXX)  79.527 ms  76.527 ms  76.152 ms
20  cust-sid436.fra3-de.as5405.net (45.153.82.XXX)  76.719 ms  66.800 ms cust-sid435.r1-fra3-de.as5405.net (45.153.82.XXX)  56.320 ms
21  * * *
22  * * *
23  * * *
24  * * *
25  * * *
26  * * *
27  * * *
28  * * *
29  * * *
30  * * *
```
AFAIK traceroute utilizes ICMP packages with set ttl (increasing up to a number, default=30), so when the package dies, the node usually reports to the original sender of that. Here we see that it requires at least 4 hops to get out of Innopolis's subnet
#### DNS Resolution Check

```sh
[rightrat@RatLaptop ~]$ dig github.com

; <<>> DiG 9.20.11 <<>> github.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 43423
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;github.com.                    IN      A

;; ANSWER SECTION:
github.com.             31      IN      A       140.82.121.XXX

;; Query time: 43 msec
;; SERVER: 8.8.8.8#53(8.8.8.8) (UDP)
;; WHEN: Mon Sep 29 19:59:08 MSK 2025
;; MSG SIZE  rcvd: 55
```
DNS resolved successfully, nothing to add

### Packet Capture

#### Capture DNS Traffic
```sh
[rightrat@RatLaptop ~]$ sudo timeout 10 tcpdump -c 5 -i any 'port 53' -nn
tcpdump: WARNING: any: That device doesn't support promiscuous mode
(Promiscuous mode not supported on the "any" device)
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on any, link-type LINUX_SLL2 (Linux cooked v2), snapshot length 262144 bytes
20:02:07.653424 wlan0 Out IP 192.168.3.XXX.54918 > 8.8.8.XXX.53: 42842+ A? g.co. (22)
20:02:07.653452 wlan0 Out IP 192.168.3.XXX.54918 > 8.8.8.XXX.53: 17504+ AAAA? g.co. (22)
20:02:07.874892 wlan0 In  IP 8.8.8.XXX.53 > 192.168.3.XXX.54918: 42842 6/0/0 A 173.194.221.XXX, A 173.194.221.XXX, A 173.194.221.XXX, A 173.194.221.XXX, A 173.194.221.XXX, A 173.194.221.XXX (118)
20:02:07.875225 wlan0 In  IP 8.8.8.XXX.53 > 192.168.3.XXX.54918: 17504 4/0/0 AAAA 2a00:1450:4010:XXXX::8b, AAAA 2a00:1450:4010:XXXX::66, AAAA 2a00:1450:4010:XXXX::71, AAAA 2a00:1450:4010:XXXX::64 (134)
20:02:08.223663 wlan0 Out IP 192.168.3.XXX.42888 > 8.8.8.XXX.53: 48379+ A? fonts.googleapis.com. (38)
5 packets captured
8 packets received by filter
0 packets dropped by kernel
```
To capture any packet I queried g.co in Firefox, which can be seen in the output

### Reverse DNS

#### Perform PTR Lookups

```sh
[rightrat@RatLaptop ~]$ dig -x 8.8.4.4

; <<>> DiG 9.20.11 <<>> -x 8.8.4.4
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 60997
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;4.4.8.8.in-addr.arpa.          IN      PTR

;; ANSWER SECTION:
4.4.8.8.in-addr.arpa.   5428    IN      PTR     dns.google.

;; Query time: 46 msec
;; SERVER: 8.8.8.8#53(8.8.8.8) (UDP)
;; WHEN: Mon Sep 29 20:06:01 MSK 2025
;; MSG SIZE  rcvd: 73
```

```sh
[rightrat@RatLaptop ~]$ dig -x 1.1.2.2

; <<>> DiG 9.20.11 <<>> -x 1.1.2.2
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NXDOMAIN, id: 55364
;; flags: qr rd ra ad; QUERY: 1, ANSWER: 0, AUTHORITY: 1, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;2.2.1.1.in-addr.arpa.          IN      PTR

;; AUTHORITY SECTION:
1.in-addr.arpa.         2039    IN      SOA     ns.apnic.net. read-txt-record-of-zone-first-dns-admin.apnic.net. 22955 7200 1800 604800 3600

;; Query time: 553 msec
;; SERVER: 8.8.8.8#53(8.8.8.8) (UDP)
;; WHEN: Mon Sep 29 20:07:40 MSK 2025
;; MSG SIZE  rcvd: 137
```