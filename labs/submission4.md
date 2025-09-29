# Lab 4 Submission

## Task 1 - Operating System Analysis

#### 1.1: Boot Performance Analysis

1. **Analyze System Boot Time:**

   ```sh
   systemd-analyze
   systemd-analyze blame
   ```
**Command outputs:**
```
Startup finished in 1.689s (kernel) + 14.631s (userspace) = 16.320s 
graphical.target reached after 14.586s in userspace.
```
Sys startup took 16.3 seconds overall - kernel part was fast (1.7s) but userspace and graphical stuff needed 14.6s to get ready.
```
11.520s plymouth-quit-wait.service
 8.767s vboxadd.service
 3.404s snapd.seeded.service
 3.180s snapd.service
 1.077s snapd.apparmor.service
  981ms dev-sda2.device
  976ms systemd-binfmt.service
  973ms systemd-resolved.service
  939ms systemd-oomd.service
  735ms NetworkManager.service
  466ms apport.service
  400ms dev-loop8.device
  346ms e2scrub_reap.service
  315ms packagekit.service
  273ms gnome-remote-desktop.service
  263ms upower.service
  236ms udisks2.service
  230ms systemd-timesyncd.service
  228ms accounts-daemon.service
  225ms gpu-manager.service
  221ms dev-loop3.device
  211ms rsyslog.service
  210ms power-profiles-daemon.service
  196ms polkit.service
  196ms dev-loop2.device
  178ms user@1000.service
  173ms avahi-daemon.service
  162ms dev-loop4.device
  161ms dev-loop7.device
  159ms dev-loop1.device
  159ms dev-loop5.device
  157ms dbus.service
  156ms dev-loop6.device
  153ms NetworkManager-wait-online.service
  138ms dev-loop0.device
  137ms systemd-logind.service
  136ms switcheroo-control.service
  131ms apparmor.service
  123ms systemd-udevd.service
  114ms gdm.service
  111ms grub-common.service
  102ms systemd-udev-trigger.service
  100ms ModemManager.service
   79ms keyboard-setup.service
   71ms systemd-modules-load.service
   67ms systemd-journal-flush.service
   55ms systemd-journald.service
   51ms cups.service
   49ms systemd-tmpfiles-setup-dev-early.service
   46ms plymouth-start.service
   45ms dev-hugepages.mount
   44ms dev-mqueue.mount
   43ms systemd-tmpfiles-setup.service
   42ms sys-kernel-debug.mount
   41ms colord.service
   40ms sysstat.service
   40ms wpa_supplicant.service
   39ms sys-kernel-tracing.mount
   36ms systemd-sysctl.service
   36ms grub-initrd-fallback.service
   35ms systemd-remount-fs.service
   31ms kmod-static-nodes.service
   31ms alsa-restore.service
   30ms modprobe@configfs.service
   28ms modprobe@drm.service
   25ms systemd-random-seed.service
   25ms kerneloops.service
   23ms snap-bare-5.mount
   23ms snap-firefox-6565.mount
   23ms proc-sys-fs-binfmt_misc.mount
   22ms snap-core22-2045.mount
   22ms plymouth-read-write.service
   22ms snap-firmware\x2dupdater-167.mount
   20ms systemd-update-utmp-runlevel.service
   19ms snap-gnome\x2d42\x2d2204-202.mount
   19ms modprobe@fuse.service
   17ms snapd.socket
   15ms snap-gtk\x2dcommon\x2dthemes-1535.mount
   15ms user-runtime-dir@1000.service
   14ms rtkit-daemon.service
   14ms systemd-update-utmp.service
   13ms snap-snap\x2dstore-1270.mount
   11ms snap-snapd-24792.mount
   11ms systemd-tmpfiles-setup-dev.service
   10ms systemd-user-sessions.service
   10ms console-setup.service
   10ms sys-kernel-config.mount
   10ms modprobe@loop.service
    9ms snap-snapd\x2ddesktop\x2dintegration-315.mount
    9ms setvtrgb.service
    8ms ufw.service
    8ms openvpn.service
    8ms vboxadd-service.service
    7ms modprobe@efi_pstore.service
    6ms sys-fs-fuse-connections.mount
    5ms modprobe@dm_mod.service
```
Here, we can observe the distribution of the time spent on the various processes during the boot process.

2. **Check System Load:**

   ```sh
   uptime
   w
   ```
```
 18:24:49 up 1 min,  1 user,  load average: 1.19, 0.56, 0.21
```
System just booted 1 minute ago )
```
 18:24:50 up 1 min,  1 user,  load average: 1.19, 0.56, 0.21
USER     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU  WHAT
vboxuser tty2     -                18:23    1:39   0.01s  0.01s /usr/libexec/gn
```
Only one user is logged into the graphical interface and has been idle for a minute or so.

#### 1.2: Process Forensics

1. **Identify Resource-Intensive Processes:**

   ```sh
   ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 6
   ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 6
   ```
**Command outputs:**
```
    PID    PPID CMD                         %MEM %CPU
   4292    3082 /snap/firefox/6565/usr/lib/  6.6  3.1
   3082    2841 /usr/bin/gnome-shell         5.4  6.4
   5108    4496 /snap/firefox/6565/usr/lib/  3.6  1.0
   6450    4496 /snap/firefox/6565/usr/lib/  3.5  0.6
  11859   11620 /snap/code/208/usr/share/co  2.7 12.8
```
Firefox remains the top memory consumer at 6.6% RAM
```
    PID    PPID CMD                         %MEM %CPU
  11859   11620 /snap/code/208/usr/share/co  2.7 12.8
  11878   11620 /snap/code/208/usr/share/co  2.6 10.3
  11616    2841 /snap/code/208/usr/share/co  2.2  8.8
  11941   11616 /proc/self/exe --type=utili  1.3  7.9
   3082    2841 /usr/bin/gnome-shell         5.4  6.4
```
Visual Studio Code processes now dominate the CPU usage rankings with multiple instances running.

**Observations:**

**Answer: "What is the top memory-consuming process?"** Firefox (PID 4292) is the top memory-consuming process using 6.6% of system RAM.

#### 1.3: Service Dependencies

1. **Map Service Relationships:**

   ```sh
   systemctl list-dependencies
   systemctl list-dependencies multi-user.target
   ```
**Command outputs:**
```
default.target
● ├─accounts-daemon.service
● ├─gdm.service
● ├─gnome-remote-desktop.service
● ├─power-profiles-daemon.service
● ├─switcheroo-control.service
○ ├─systemd-update-utmp-runlevel.service
● ├─udisks2.service
● └─multi-user.target
○   ├─anacron.service
●   ├─apport.service
●   ├─avahi-daemon.service
●   ├─console-setup.service
●   ├─cron.service
●   ├─cups-browsed.service
●   ├─cups.path
●   ├─cups.service
●   ├─dbus.service
○   ├─dmesg.service
○   ├─e2scrub_reap.service
○   ├─grub-common.service
○   ├─grub-initrd-fallback.service
●   ├─kerneloops.service
●   ├─ModemManager.service
○   ├─networkd-dispatcher.service
●   ├─NetworkManager.service
●   ├─openvpn.service
●   ├─plymouth-quit-wait.service
○   ├─plymouth-quit.service
●   ├─rsyslog.service
○   ├─secureboot-db.service
●   ├─snap-bare-5.mount
●   ├─snap-core22-2045.mount
●   ├─snap-firefox-6565.mount
●   ├─snap-firmware\x2dupdater-167.mount
●   ├─snap-gnome\x2d42\x2d2204-202.mount
●   ├─snap-gtk\x2dcommon\x2dthemes-1535.mount
●   ├─snap-snap\x2dstore-1270.mount
●   ├─snap-snapd-24792.mount
●   ├─snap-snapd\x2ddesktop\x2dintegration-315.mount
●   ├─snapd.apparmor.service
○   ├─snapd.autoimport.service
○   ├─snapd.core-fixup.service
○   ├─snapd.recovery-chooser-trigger.service
●   ├─snapd.seeded.service
●   ├─snapd.service
○   ├─ssl-cert.service
○   ├─sssd.service
●   ├─sysstat.service
●   ├─systemd-ask-password-wall.path
●   ├─systemd-logind.service
●   ├─systemd-oomd.service
○   ├─systemd-update-utmp-runlevel.service
●   ├─systemd-user-sessions.service
○   ├─thermald.service
○   ├─ua-reboot-cmds.service
○   ├─ubuntu-advantage.service
●   ├─ufw.service
●   ├─unattended-upgrades.service
●   ├─vboxadd-service.service
×   ├─vboxadd.service
●   ├─whoopsie.path
●   ├─wpa_supplicant.service
●   ├─basic.target
●   │ ├─-.mount
○   │ ├─tmp.mount
●   │ ├─paths.target
○   │ │ ├─apport-autoreport.path
○   │ │ └─tpm-udev.path
●   │ ├─slices.target
●   │ │ ├─-.slice
●   │ │ └─system.slice
●   │ ├─sockets.target
○   │ │ ├─apport-forward.socket
●   │ │ ├─avahi-daemon.socket
●   │ │ ├─cups.socket
●   │ │ ├─dbus.socket
●   │ │ ├─snapd.socket
●   │ │ ├─systemd-initctl.socket
●   │ │ ├─systemd-journald-dev-log.socket
●   │ │ ├─systemd-journald.socket
●   │ │ ├─systemd-oomd.socket
○   │ │ ├─systemd-pcrextend.socket
●   │ │ ├─systemd-sysext.socket
●   │ │ ├─systemd-udevd-control.socket
●   │ │ ├─systemd-udevd-kernel.socket
●   │ │ └─uuidd.socket
●   │ ├─sysinit.target
●   │ │ ├─apparmor.service
●   │ │ ├─dev-hugepages.mount
●   │ │ ├─dev-mqueue.mount
●   │ │ ├─keyboard-setup.service
●   │ │ ├─kmod-static-nodes.service
○   │ │ ├─ldconfig.service
●   │ │ ├─plymouth-read-write.service
●   │ │ ├─plymouth-start.service
●   │ │ ├─proc-sys-fs-binfmt_misc.automount
●   │ │ ├─setvtrgb.service
●   │ │ ├─sys-fs-fuse-connections.mount
●   │ │ ├─sys-kernel-config.mount
●   │ │ ├─sys-kernel-debug.mount
●   │ │ ├─sys-kernel-tracing.mount
○   │ │ ├─systemd-ask-password-console.path
●   │ │ ├─systemd-binfmt.service
○   │ │ ├─systemd-firstboot.service
○   │ │ ├─systemd-hwdb-update.service
○   │ │ ├─systemd-journal-catalog-update.service
●   │ │ ├─systemd-journal-flush.service
●   │ │ ├─systemd-journald.service
○   │ │ ├─systemd-machine-id-commit.service
●   │ │ ├─systemd-modules-load.service
○   │ │ ├─systemd-pcrmachine.service
○   │ │ ├─systemd-pcrphase-sysinit.service
○   │ │ ├─systemd-pcrphase.service
○   │ │ ├─systemd-pstore.service
●   │ │ ├─systemd-random-seed.service
○   │ │ ├─systemd-repart.service
●   │ │ ├─systemd-resolved.service
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
○   │ │ │ ├─systemd-fsck-root.service
●   │ │ │ └─systemd-remount-fs.service
●   │ │ ├─swap.target
●   │ │ └─veritysetup.target
●   │ └─timers.target
●   │   ├─anacron.timer
○   │   ├─apport-autoreport.timer
●   │   ├─apt-daily-upgrade.timer
●   │   ├─apt-daily.timer
●   │   ├─dpkg-db-backup.timer
●   │   ├─e2scrub_all.timer
●   │   ├─fstrim.timer
●   │   ├─fwupd-refresh.timer
●   │   ├─logrotate.timer
●   │   ├─man-db.timer
●   │   ├─motd-news.timer
○   │   ├─snapd.snap-repair.timer
●   │   ├─systemd-tmpfiles-clean.timer
○   │   ├─ua-timer.timer
●   │   ├─update-notifier-download.timer
●   │   └─update-notifier-motd.timer
●   ├─getty.target
○   │ ├─getty-static.service
○   │ └─getty@tty1.service
●   └─remote-fs.target
```
Shows the dependency tree of what services need to start for system to be ready
```
multi-user.target
○ ├─anacron.service
● ├─apport.service
● ├─avahi-daemon.service
● ├─console-setup.service
● ├─cron.service
● ├─cups-browsed.service
● ├─cups.path
● ├─cups.service
● ├─dbus.service
○ ├─dmesg.service
○ ├─e2scrub_reap.service
○ ├─grub-common.service
○ ├─grub-initrd-fallback.service
● ├─kerneloops.service
● ├─ModemManager.service
○ ├─networkd-dispatcher.service
● ├─NetworkManager.service
● ├─openvpn.service
● ├─plymouth-quit-wait.service
○ ├─plymouth-quit.service
● ├─rsyslog.service
○ ├─secureboot-db.service
● ├─snap-bare-5.mount
● ├─snap-core22-2045.mount
● ├─snap-firefox-6565.mount
● ├─snap-firmware\x2dupdater-167.mount
● ├─snap-gnome\x2d42\x2d2204-202.mount
● ├─snap-gtk\x2dcommon\x2dthemes-1535.mount
● ├─snap-snap\x2dstore-1270.mount
● ├─snap-snapd-24792.mount
● ├─snap-snapd\x2ddesktop\x2dintegration-315.mount
● ├─snapd.apparmor.service
○ ├─snapd.autoimport.service
○ ├─snapd.core-fixup.service
○ ├─snapd.recovery-chooser-trigger.service
● ├─snapd.seeded.service
● ├─snapd.service
○ ├─ssl-cert.service
○ ├─sssd.service
● ├─sysstat.service
● ├─systemd-ask-password-wall.path
● ├─systemd-logind.service
● ├─systemd-oomd.service
○ ├─systemd-update-utmp-runlevel.service
● ├─systemd-user-sessions.service
○ ├─thermald.service
○ ├─ua-reboot-cmds.service
○ ├─ubuntu-advantage.service
● ├─ufw.service
● ├─unattended-upgrades.service
● ├─vboxadd-service.service
× ├─vboxadd.service
● ├─whoopsie.path
● ├─wpa_supplicant.service
● ├─basic.target
● │ ├─-.mount
○ │ ├─tmp.mount
● │ ├─paths.target
○ │ │ ├─apport-autoreport.path
○ │ │ └─tpm-udev.path
● │ ├─slices.target
● │ │ ├─-.slice
● │ │ └─system.slice
● │ ├─sockets.target
○ │ │ ├─apport-forward.socket
● │ │ ├─avahi-daemon.socket
● │ │ ├─cups.socket
● │ │ ├─dbus.socket
● │ │ ├─snapd.socket
● │ │ ├─systemd-initctl.socket
● │ │ ├─systemd-journald-dev-log.socket
● │ │ ├─systemd-journald.socket
● │ │ ├─systemd-oomd.socket
○ │ │ ├─systemd-pcrextend.socket
● │ │ ├─systemd-sysext.socket
● │ │ ├─systemd-udevd-control.socket
● │ │ ├─systemd-udevd-kernel.socket
● │ │ └─uuidd.socket
● │ ├─sysinit.target
● │ │ ├─apparmor.service
● │ │ ├─dev-hugepages.mount
● │ │ ├─dev-mqueue.mount
● │ │ ├─keyboard-setup.service
● │ │ ├─kmod-static-nodes.service
○ │ │ ├─ldconfig.service
● │ │ ├─plymouth-read-write.service
● │ │ ├─plymouth-start.service
● │ │ ├─proc-sys-fs-binfmt_misc.automount
● │ │ ├─setvtrgb.service
● │ │ ├─sys-fs-fuse-connections.mount
● │ │ ├─sys-kernel-config.mount
● │ │ ├─sys-kernel-debug.mount
● │ │ ├─sys-kernel-tracing.mount
○ │ │ ├─systemd-ask-password-console.path
● │ │ ├─systemd-binfmt.service
○ │ │ ├─systemd-firstboot.service
○ │ │ ├─systemd-hwdb-update.service
○ │ │ ├─systemd-journal-catalog-update.service
● │ │ ├─systemd-journal-flush.service
● │ │ ├─systemd-journald.service
○ │ │ ├─systemd-machine-id-commit.service
● │ │ ├─systemd-modules-load.service
○ │ │ ├─systemd-pcrmachine.service
○ │ │ ├─systemd-pcrphase-sysinit.service
○ │ │ ├─systemd-pcrphase.service
○ │ │ ├─systemd-pstore.service
● │ │ ├─systemd-random-seed.service
○ │ │ ├─systemd-repart.service
● │ │ ├─systemd-resolved.service
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
○ │ │ │ ├─systemd-fsck-root.service
● │ │ │ └─systemd-remount-fs.service
● │ │ ├─swap.target
● │ │ └─veritysetup.target
● │ └─timers.target
● │   ├─anacron.timer
○ │   ├─apport-autoreport.timer
● │   ├─apt-daily-upgrade.timer
● │   ├─apt-daily.timer
● │   ├─dpkg-db-backup.timer
● │   ├─e2scrub_all.timer
● │   ├─fstrim.timer
● │   ├─fwupd-refresh.timer
● │   ├─logrotate.timer
● │   ├─man-db.timer
● │   ├─motd-news.timer
○ │   ├─snapd.snap-repair.timer
● │   ├─systemd-tmpfiles-clean.timer
○ │   ├─ua-timer.timer
● │   ├─update-notifier-download.timer
● │   └─update-notifier-motd.timer
● ├─getty.target
○ │ ├─getty-static.service
○ │ └─getty@tty1.service
● └─remote-fs.target
```
show specifically which services are required for multi-user mode\
**Observations:**
We can see how services depend on each other in a structured way
#### 1.4: User Sessions

1. **Audit Login Activity:**

   ```sh
   who -a
   last -n 5
   ```

**Command outputs:**
```
           system boot  2025-09-29 18:23
           run-level 5  2025-09-29 18:23
vboxuser ? seat0        2025-09-29 18:23   ?          2925 (login screen)
vboxuser + tty2         2025-09-29 18:23 00:10        2925 (tty2)
```
Displays currently logged-in users with their session details and connection
```
vboxuser tty2         tty2             Mon Sep 29 18:23   still logged in
vboxuser seat0        login screen     Mon Sep 29 18:23   still logged in
reboot   system boot  6.14.0-32-generi Mon Sep 29 18:23   still running
reboot   system boot  6.14.0-32-generi Mon Sep 29 18:22   still running
vboxuser tty2         tty2             Mon Sep 29 18:20 - crash  (00:01)

wtmp begins Mon Sep 29 17:04:11 2025
```
 Displays recent login activity and system boot records
#### 1.5: Memory Analysis

1. **Inspect Memory Allocation:**

   ```sh
   free -h
   cat /proc/meminfo | grep -e MemTotal -e SwapTotal -e MemAvailable
   ```

**Command outputs:**
```
               total        used        free      shared  buff/cache   available
Mem:           7.8Gi       1.6Gi       4.7Gi        52Mi       1.6Gi       6.1Gi
Swap:             0B          0B          0B
```
 Only 1.6GB of 7.8GB total memory is actively used, indicating light system load.
```
MemTotal:        8129580 kB
MemAvailable:    6401192 kB
SwapTotal:             0 kB
```
 The system has 8.1GB total RAM with 6.4GB available and nd no swap partition configured.
## Task 2 - Networking Analysis
#### 2.1: Network Path Tracing

1. **Traceroute Execution:**

   ```sh
   traceroute github.com
   ```

**Command outputs:**
```
% traceroute github.com
traceroute to github.com (140.82.121.4), 64 hops max, 40 byte packets
 1  10.91.80.1 (10.91.80.1)  7.618 ms  5.240 ms  5.296 ms
 2  10.252.6.1 (10.252.6.1)  4.617 ms  5.024 ms  4.669 ms
 3  1.123.18.84.in-addr.arpa (84.18.123.1)  15.813 ms  44.936 ms  16.681 ms
 4  178.176.191.24 (178.176.191.24)  14.671 ms  11.685 ms  11.157 ms
 5  * * *
 6  * * *
 7  * * *
 8  * * *
 9  83.169.204.78 (83.169.204.78)  57.432 ms
    83.169.204.82 (83.169.204.82)  47.643 ms
    83.169.204.78 (83.169.204.78)  45.780 ms
10  netnod-ix-ge-b-sth-1500.inter.link (194.68.128.180)  48.861 ms
    netnod-ix-ge-a-sth-1500.inter.link (194.68.123.180)  45.802 ms  45.937 ms
11  * * *
12  r3-ber1-de.as5405.net (94.103.180.2)  63.751 ms  66.635 ms  63.606 ms
13  * * *
14  * * *
15  * * *
16  * * *
17  r1-fra3-de.as5405.net (94.103.180.24)  66.251 ms  61.767 ms  65.624 ms
18  cust-sid435.r1-fra3-de.as5405.net (45.153.82.39)  70.283 ms
    cust-sid436.fra3-de.as5405.net (45.153.82.37)  110.564 ms
    cust-sid435.r1-fra3-de.as5405.net (45.153.82.39)  73.521 ms
19  * * *
20  * * *
21  * * *
```
It takes 4 hops to exit Innopolis network using ICMP probes, with the approximate route : Innopolis → Kazan/Tatarstan (Tattelecom) → Moscow (MegaFon) → Samara → Stockholm (NetNod) → Frankfurt (AS5405) → GitHub, though some intermediate hops didn't respond.
2. **DNS Resolution Check:**

   ```sh
   dig github.com
   ```
**Command outputs:**
```
; <<>> DiG 9.18.39-0ubuntu0.24.04.1-Ubuntu <<>> github.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 56569
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 65494
;; QUESTION SECTION:
;github.com.			IN	A

;; ANSWER SECTION:
github.com.		4	IN	A	140.82.121.4

;; Query time: 3 msec
;; SERVER: 127.0.0.53#53(127.0.0.53) (UDP)
;; WHEN: Mon Sep 29 18:43:25 UTC 2025
;; MSG SIZE  rcvd: 55
```
DNS resolved successfully - github.com maps to IP address 140.82.121.4

#### 2.2: Packet Capture

1. **Capture DNS Traffic:**

   ```sh
   sudo timeout 10 tcpdump -c 5 -i any 'port 53' -nn
   ```
**Command outputs:**
```
tcpdump: data link type LINUX_SLL2
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on any, link-type LINUX_SLL2 (Linux cooked v2), snapshot length 262144 bytes
18:48:37.237252 lo    In  IP 127.0.0.1.39460 > 127.0.0.53.53: 16234+ [1au] A? google.com. (51)
18:48:37.237481 lo    In  IP 127.0.0.53.53 > 127.0.0.1.39460: 16234 2/0/1 CNAME forcesafesearch.google.com., A 216.239.38.120 (85)
18:48:37.271101 lo    In  IP 127.0.0.1.45794 > 127.0.0.53.53: 7642+ A? github.com. (28)
18:48:37.271286 enp0s3 Out IP 10.0.2.15.40106 > 10.90.137.31.53: 13786+ [1au] A? github.com. (39)
18:48:37.274057 enp0s3 In  IP 10.90.137.31.53 > 10.0.2.15.40106: 13786 1/0/1 A 140.82.121.3 (55)
5 packets captured
23 packets received by filter
0 packets dropped by kernel
```
Successfully captured DNS traffic including queries to google.com and github.com,
#### 2.3: Reverse DNS

1. **Perform PTR Lookups:**

   ```sh
   dig -x 8.8.4.4
   dig -x 1.1.2.2
   ```
**Command outputs:**
```
; <<>> DiG 9.18.39-0ubuntu0.24.04.1-Ubuntu <<>> -x 8.8.4.4
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 46862
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 65494
;; QUESTION SECTION:
;4.4.8.8.in-addr.arpa.		IN	PTR

;; ANSWER SECTION:
4.4.8.8.in-addr.arpa.	6298	IN	PTR	dns.google.

;; Query time: 26 msec
;; SERVER: 127.0.0.53#53(127.0.0.53) (UDP)
;; WHEN: Mon Sep 29 18:49:52 UTC 2025
;; MSG SIZE  rcvd: 73
```
found reverse DNS: this IP belongs to dns.google (Google's DNS service)
```
; <<>> DiG 9.18.39-0ubuntu0.24.04.1-Ubuntu <<>> -x 1.1.2.2
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NXDOMAIN, id: 63438
;; flags: qr rd ra; QUERY: 1, ANSWER: 0, AUTHORITY: 1, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 65494
;; QUESTION SECTION:
;2.2.1.1.in-addr.arpa.		IN	PTR

;; AUTHORITY SECTION:
1.in-addr.arpa.		899	IN	SOA	ns.apnic.net. read-txt-record-of-zone-first-dns-admin.apnic.net. 22955 7200 1800 604800 3600

;; Query time: 850 msec
;; SERVER: 127.0.0.53#53(127.0.0.53) (UDP)
;; WHEN: Mon Sep 29 18:50:22 UTC 2025
;; MSG SIZE  rcvd: 137
```
Reverse DNS lookup for 1.1.2.2 failed with NXDOMAIN("non-existent domain") status, confirming no PTR record exists for this IP address. The query took 850ms as the system had to check with APNIC's authoritative nameserver (ns.apnic.net) which manages this IP range. The SOA record in the authority section confirms that while IP space is properly managed, this specific address simply doesn't have a reverse DNS record configured.
