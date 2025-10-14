# Lab 4 — Operating Systems & Networking

# Task 1 — Operating System Analysis

## 1.1: Boot Performance Analysis

### 1. Analyze System Boot Time:

- **Command:** `systemd-analyze`
- **Command:** `systemd-analyze blame`
- **Output:**

```
spiriton@LAPTOP-TNLQNHEC:~$ systemd-analyze
Startup finished in 1.795s (userspace)
graphical.target reached after 1.769s in userspace

spiriton@LAPTOP-TNLQNHEC:~$ systemd-analyze blame
1.333s snapd.seeded.service
1.198s snapd.service
 337ms dev-sdd.device
 240ms networkd-dispatcher.service
 198ms systemd-resolved.service
 197ms systemd-logind.service
 126ms user@1000.service
 112ms systemd-udev-trigger.service
  90ms e2scrub_reap.service
  83ms systemd-journal-flush.service
  78ms apport.service
  55ms keyboard-setup.service
  47ms systemd-udevd.service
  46ms systemd-journald.service
  35ms rsyslog.service
  26ms dev-hugepages.mount
  25ms dev-mqueue.mount
  23ms sys-kernel-debug.mount
  22ms sys-kernel-tracing.mount
  20ms snap-bare-5.mount
  19ms systemd-tmpfiles-setup.service
  19ms systemd-sysctl.service
  19ms snap-core22-2111.mount
  18ms snap-core22-2133.mount
  18ms snap-gtk\x2dcommon\x2dthemes-1535.mount
  17ms kmod-static-nodes.service
  17ms snap-snapd-24792.mount
  16ms systemd-update-utmp.service
  15ms modprobe@drm.service
  15ms snap-snapd-25202.mount
  15ms modprobe@efi_pstore.service
  14ms modprobe@fuse.service
  14ms plymouth-read-write.service
  14ms polkit.service
  14ms systemd-tmpfiles-setup-dev.service
  13ms snap-ubuntu\x2ddesktop\x2dinstaller-1286.mount
  13ms systemd-remount-fs.service
  12ms plymouth-quit.service
  12ms systemd-sysusers.service
  11ms snap-ubuntu\x2ddesktop\x2dinstaller-967.mount
   9ms systemd-user-sessions.service
   8ms console-setup.service
   7ms user-runtime-dir@1000.service
   6ms systemd-update-utmp-runlevel.service
   5ms sys-fs-fuse-connections.mount
   5ms plymouth-quit-wait.service
   5ms rtkit-daemon.service
   4ms setvtrgb.service
   4ms snap.mount
   4ms snapd.socket
   4ms modprobe@configfs.service
   3ms ufw.service
```

- **Observations:**
The system boots very fast (~1.8s) and reaches the graphical target almost immediately. Snap-related services (snapd) dominate startup time, while most other services start almost instantly.

### 2. Check System Load:

- **Command:** `uptime`
- **Command:** `w`
- **Output:**

```
spiriton@LAPTOP-TNLQNHEC:~$ uptime
22:34:20 up 2 min,  1 user,  load average: 0.07, 0.03, 0.00

spiriton@LAPTOP-TNLQNHEC:~$ w
22:34:20 up 2 min,  1 user,  load average: 0.06, 0.03, 0.00
USER     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU WHAT
spiriton pts/1    -                22:31    2:37   0.01s  0.01s -bash
```

- **Observations:**
The system is freshly booted with very low CPU load and a single active user session.

## 1.2: Process Forensics

### 1. Identify Resource-Intensive Processes:

- **Command:** `ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 6`
- **Command:** `ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 6`
- **Output:**

```
spiriton@LAPTOP-TNLQNHEC:~$ ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 6
    PID    PPID CMD                         %MEM %CPU
    326     248 /snap/ubuntu-desktop-instal  0.8  1.2
    489     326 python3 /snap/ubuntu-deskto  0.4  0.8
    188       1 /usr/lib/snapd/snapd         0.4  0.2
    261       1 /usr/bin/python3 /usr/share  0.2  0.0
    175       1 /usr/bin/python3 /usr/bin/n  0.2  0.0

spiriton@LAPTOP-TNLQNHEC:~$ ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 6
    PID    PPID CMD                         %MEM %CPU
     98       1 snapfuse /var/lib/snapd/sna  0.1  1.1
    326     248 /snap/ubuntu-desktop-instal  0.8  1.1
      1       0 /sbin/init                   0.1  1.0
    489     326 python3 /snap/ubuntu-deskto  0.4  0.8
    104       1 snapfuse /var/lib/snapd/sna  0.1  0.4
```

- **Observations:**
The highest memory consumers are Snap-related processes and some Python instances. CPU usage is very low overall, with only Snap and Python processes briefly consuming minor CPU.
The top memory-consuming process is /snap/ubuntu-desktop-installer (PID 326).

## 1.3: Service Dependencies

### 1. Map Service Relationships:

- **Command:** `systemctl list-dependencies`
- **Command:** `systemctl list-dependencies multi-user.target`
- **Output:**

```
spiriton@LAPTOP-TNLQNHEC:~$ systemctl list-dependencies
default.target
● ├─apport.service
○ ├─display-manager.service
○ ├─systemd-update-utmp-runlevel.service
○ ├─wslg.service
● └─multi-user.target
●   ├─apport.service
●   ├─console-setup.service
●   ├─cron.service
●   ├─dbus.service
○   ├─dmesg.service
○   ├─e2scrub_reap.service
○   ├─irqbalance.service
●   ├─networkd-dispatcher.service
●   ├─plymouth-quit-wait.service
●   ├─plymouth-quit.service
●   ├─rsyslog.service
●   ├─snap-bare-5.mount
●   ├─snap-core22-2111.mount
●   ├─snap-core22-2133.mount
●   ├─snap-gtk\x2dcommon\x2dthemes-1535.mount
●   ├─snap-snapd-24792.mount
●   ├─snap-snapd-25202.mount
●   ├─snap-ubuntu\x2ddesktop\x2dinstaller-1286.mount
●   ├─snap-ubuntu\x2ddesktop\x2dinstaller-967.mount
●   ├─snap.ubuntu-desktop-installer.subiquity-server.service
○   ├─snapd.aa-prompt-listener.service
○   ├─snapd.apparmor.service
○   ├─snapd.autoimport.service
○   ├─snapd.core-fixup.service
○   ├─snapd.recovery-chooser-trigger.service
●   ├─snapd.seeded.service
●   ├─snapd.service
●   ├─systemd-ask-password-wall.path
●   ├─systemd-logind.service
●   ├─systemd-resolved.service
○   ├─systemd-update-utmp-runlevel.service
●   ├─systemd-user-sessions.service
○   ├─ua-reboot-cmds.service
○   ├─ubuntu-advantage.service
●   ├─ufw.service
●   ├─unattended-upgrades.service
●   ├─basic.target
○   │ ├─tmp.mount
●   │ ├─paths.target
○   │ │ └─apport-autoreport.path
●   │ ├─slices.target
●   │ │ ├─-.slice
●   │ │ └─system.slice
●   │ ├─sockets.target
●   │ │ ├─apport-forward.socket
●   │ │ ├─dbus.socket
●   │ │ ├─snapd.socket
●   │ │ ├─systemd-initctl.socket
●   │ │ ├─systemd-journald-audit.socket
●   │ │ ├─systemd-journald-dev-log.socket
●   │ │ ├─systemd-journald.socket
●   │ │ ├─systemd-udevd-control.socket
●   │ │ ├─systemd-udevd-kernel.socket
●   │ │ └─uuidd.socket
●   │ ├─sysinit.target
○   │ │ ├─apparmor.service
●   │ │ ├─dev-hugepages.mount
●   │ │ ├─dev-mqueue.mount
●   │ │ ├─keyboard-setup.service
●   │ │ ├─kmod-static-nodes.service
●   │ │ ├─plymouth-read-write.service
○   │ │ ├─plymouth-start.service
○   │ │ ├─proc-sys-fs-binfmt_misc.automount
●   │ │ ├─setvtrgb.service
●   │ │ ├─sys-fs-fuse-connections.mount
○   │ │ ├─sys-kernel-config.mount
●   │ │ ├─sys-kernel-debug.mount
●   │ │ ├─sys-kernel-tracing.mount
●   │ │ ├─systemd-ask-password-console.path
○   │ │ ├─systemd-binfmt.service
○   │ │ ├─systemd-boot-system-token.service
●   │ │ ├─systemd-journal-flush.service
●   │ │ ├─systemd-journald.service
○   │ │ ├─systemd-machine-id-commit.service
○   │ │ ├─systemd-modules-load.service
○   │ │ ├─systemd-pstore.service
○   │ │ ├─systemd-random-seed.service
●   │ │ ├─systemd-sysctl.service
●   │ │ ├─systemd-sysusers.service
○   │ │ ├─systemd-timesyncd.service
●   │ │ ├─systemd-tmpfiles-setup-dev.service
●   │ │ ├─systemd-tmpfiles-setup.service
●   │ │ ├─systemd-udev-trigger.service
●   │ │ ├─systemd-udevd.service
●   │ │ ├─systemd-update-utmp.service
●   │ │ ├─cryptsetup.target
●   │ │ ├─local-fs.target
●   │ │ │ └─systemd-remount-fs.service
●   │ │ ├─swap.target
●   │ │ └─veritysetup.target
●   │ └─timers.target
○   │   ├─apport-autoreport.timer
●   │   ├─apt-daily-upgrade.timer
●   │   ├─apt-daily.timer
●   │   ├─dpkg-db-backup.timer
●   │   ├─e2scrub_all.timer
○   │   ├─fstrim.timer
●   │   ├─logrotate.timer
●   │   ├─man-db.timer
●   │   ├─motd-news.timer
○   │   ├─snapd.snap-repair.timer
●   │   ├─systemd-tmpfiles-clean.timer
○   │   └─ua-timer.timer
●   ├─getty.target
●   │ ├─console-getty.service
○   │ ├─getty-static.service
●   │ └─getty@tty1.service
●   └─remote-fs.target

spiriton@LAPTOP-TNLQNHEC:~$ systemctl list-dependencies multi-user.target
multi-user.target
● ├─apport.service
● ├─console-setup.service
● ├─cron.service
● ├─dbus.service
○ ├─dmesg.service
○ ├─e2scrub_reap.service
○ ├─irqbalance.service
● ├─networkd-dispatcher.service
● ├─plymouth-quit-wait.service
● ├─plymouth-quit.service
● ├─rsyslog.service
● ├─snap-bare-5.mount
● ├─snap-core22-2111.mount
● ├─snap-core22-2133.mount
● ├─snap-gtk\x2dcommon\x2dthemes-1535.mount
● ├─snap-snapd-24792.mount
● ├─snap-snapd-25202.mount
● ├─snap-ubuntu\x2ddesktop\x2dinstaller-1286.mount
● ├─snap-ubuntu\x2ddesktop\x2dinstaller-967.mount
● ├─snap.ubuntu-desktop-installer.subiquity-server.service
○ ├─snapd.aa-prompt-listener.service
○ ├─snapd.apparmor.service
○ ├─snapd.autoimport.service
○ ├─snapd.core-fixup.service
○ ├─snapd.recovery-chooser-trigger.service
● ├─snapd.seeded.service
● ├─snapd.service
● ├─systemd-ask-password-wall.path
● ├─systemd-logind.service
● ├─systemd-resolved.service
○ ├─systemd-update-utmp-runlevel.service
● ├─systemd-user-sessions.service
○ ├─ua-reboot-cmds.service
○ ├─ubuntu-advantage.service
● ├─ufw.service
● ├─unattended-upgrades.service
● ├─basic.target
○ │ ├─tmp.mount
● │ ├─paths.target
○ │ │ └─apport-autoreport.path
● │ ├─slices.target
● │ │ ├─-.slice
● │ │ └─system.slice
● │ ├─sockets.target
● │ │ ├─apport-forward.socket
● │ │ ├─dbus.socket
● │ │ ├─snapd.socket
● │ │ ├─systemd-initctl.socket
● │ │ ├─systemd-journald-audit.socket
● │ │ ├─systemd-journald-dev-log.socket
● │ │ ├─systemd-journald.socket
● │ │ ├─systemd-udevd-control.socket
● │ │ ├─systemd-udevd-kernel.socket
● │ │ └─uuidd.socket
● │ ├─sysinit.target
○ │ │ ├─apparmor.service
● │ │ ├─dev-hugepages.mount
● │ │ ├─dev-mqueue.mount
● │ │ ├─keyboard-setup.service
● │ │ ├─kmod-static-nodes.service
● │ │ ├─plymouth-read-write.service
○ │ │ ├─plymouth-start.service
○ │ │ ├─proc-sys-fs-binfmt_misc.automount
● │ │ ├─setvtrgb.service
● │ │ ├─sys-fs-fuse-connections.mount
○ │ │ ├─sys-kernel-config.mount
● │ │ ├─sys-kernel-debug.mount
● │ │ ├─sys-kernel-tracing.mount
● │ │ ├─systemd-ask-password-console.path
○ │ │ ├─systemd-binfmt.service
○ │ │ ├─systemd-boot-system-token.service
● │ │ ├─systemd-journal-flush.service
● │ │ ├─systemd-journald.service
○ │ │ ├─systemd-machine-id-commit.service
○ │ │ ├─systemd-modules-load.service
○ │ │ ├─systemd-pstore.service
○ │ │ ├─systemd-random-seed.service
● │ │ ├─systemd-sysctl.service
● │ │ ├─systemd-sysusers.service
○ │ │ ├─systemd-timesyncd.service
● │ │ ├─systemd-tmpfiles-setup-dev.service
● │ │ ├─systemd-tmpfiles-setup.service
● │ │ ├─systemd-udev-trigger.service
● │ │ ├─systemd-udevd.service
● │ │ ├─systemd-update-utmp.service
● │ │ ├─cryptsetup.target
● │ │ ├─local-fs.target
● │ │ │ └─systemd-remount-fs.service
● │ │ ├─swap.target
● │ │ └─veritysetup.target
● │ └─timers.target
○ │   ├─apport-autoreport.timer
● │   ├─apt-daily-upgrade.timer
● │   ├─apt-daily.timer
● │   ├─dpkg-db-backup.timer
● │   ├─e2scrub_all.timer
○ │   ├─fstrim.timer
● │   ├─logrotate.timer
● │   ├─man-db.timer
● │   ├─motd-news.timer
○ │   ├─snapd.snap-repair.timer
● │   ├─systemd-tmpfiles-clean.timer
○ │   └─ua-timer.timer
● ├─getty.target
● │ ├─console-getty.service
○ │ ├─getty-static.service
● │ └─getty@tty1.service
● └─remote-fs.target
```

- **Observations:**
The multi-user target loads all essential system, Snap, and timer services required for a functional WSL environment.

## 1.4: User Sessions

### 1. Audit Login Activity:

- **Command:** `who -a`
- **Command:** `last -n 5`
- **Output:**

```
spiriton@LAPTOP-TNLQNHEC:~$ who -a
           system boot  2025-09-29 22:31
           run-level 5  2025-09-29 22:31
LOGIN      tty1         2025-09-29 22:31               271 id=tty1
LOGIN      console      2025-09-29 22:31               269 id=cons
spiriton - pts/1        2025-09-29 22:31 00:04         449

spiriton@LAPTOP-TNLQNHEC:~$ last -n 5
spiriton pts/1                         Mon Sep 29 22:31   still logged in
reboot   system boot  6.6.87.2-microso Mon Sep 29 22:31   still running
spiriton pts/1                         Mon Sep 29 22:19 - crash  (00:12)
reboot   system boot  6.6.87.2-microso Mon Sep 29 22:19   still running
spiriton pts/1                         Mon Sep 29 22:17 - crash  (00:01)

wtmp begins Mon Jun 24 14:07:11 2024
```

- **Observations:**
Shows current and past logins, including one active user (spiriton), system boot time, recent reboots, and short or crashed sessions.

## 1.5: Memory Analysis

### 1. Inspect Memory Allocation:

- **Command:** `free -h`
- **Command:** `cat /proc/meminfo | grep -e MemTotal -e SwapTotal -e MemAvailable`
- **Output:**

```
spiriton@LAPTOP-TNLQNHEC:~$ free -h
               total        used        free      shared  buff/cache   available
Mem:           7.4Gi       501Mi       6.5Gi       3.0Mi       460Mi       6.8Gi
Swap:          2.0Gi          0B       2.0Gi

spiriton@LAPTOP-TNLQNHEC:~$ cat /proc/meminfo | grep -e MemTotal -e SwapTotal -e MemAvailable
MemTotal:        7791816 kB
MemAvailable:    7122352 kB
SwapTotal:       2097152 kB
```

- **Observations:**
Memory usage is very low, with ~7.7 GiB total RAM, ~6.8–7 GiB available, and 2 GiB swap completely unused, consistent across free -h and /proc/meminfo.

# Task 2 — Networking Analysis

## 2.1: Network Path Tracing

### 1. Traceroute Execution:

- **Command:** `traceroute github.com`
- **Output:**

```
spiriton@LAPTOP-TNLQNHEC:~$ traceroute github.com
traceroute to github.com (140.82.121.3), 30 hops max, 60 byte packets
 1  LAPTOP-TNLQNHEC.mshome.net (172.30.144.1)  0.405 ms  0.387 ms  0.377 ms
 2  10.91.48.1 (10.91.48.1)  2.418 ms  2.577 ms  3.147 ms
 3  10.252.6.1 (10.252.6.1)  3.165 ms  3.148 ms  3.131 ms
 4  1.123.18.84.in-addr.arpa (84.18.123.1)  17.280 ms  15.380 ms  15.368 ms
 5  178.176.191.24 (178.176.191.24)  8.013 ms  15.313 ms  7.972 ms
 6  * * *
 7  * * *
 8  * * *
 9  * * *
10  83.169.204.78 (83.169.204.78)  54.698 ms  47.912 ms  47.873 ms
11  netnod-ix-ge-b-sth-1500.inter.link (194.68.128.180)  44.539 ms netnod-ix-ge-a-sth-1500.inter.link (194.68.123.180)  43.913 ms netnod-ix-ge-b-sth-1500.inter.link (194.68.128.180)  50.482 ms
12  * * *
13  * * *
14  * * *
15  * * *
16  * * *
17  * * *
18  r1-fra3-de.as5405.net (94.103.180.24)  66.661 ms  64.052 ms  64.191 ms
19  cust-sid435.r1-fra3-de.as5405.net (45.153.82.39)  60.718 ms  60.680 ms cust-sid436.fra3-de.as5405.net (45.153.82.37)  58.331 ms
20  * * *
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

- **Observations:**
Traceroute reveals that some hops do not respond, showing potential firewall filtering or rate-limiting along the route to GitHub.

### 2. DNS Resolution Check:

- **Command:** `dig github.com`
- **Output:**

```
spiriton@LAPTOP-TNLQNHEC:~$ dig github.com

; <<>> DiG 9.18.30-0ubuntu0.22.04.2-Ubuntu <<>> github.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 37173
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;github.com.                    IN      A

;; ANSWER SECTION:
github.com.             8       IN      A       140.82.121.3

;; Query time: 8 msec
;; SERVER: 10.255.255.254#53(10.255.255.254) (UDP)
;; WHEN: Mon Sep 29 23:22:22 MSK 2025
;; MSG SIZE  rcvd: 55

```

- **Observations:**
DNS query for github.com successfully resolved to 140.82.121.3 in 8 ms via the network's configured DNS server at 10.255.255.254.

## 2.2: Packet Capture

### 1. Capture DNS Traffic:

- **Command:** `sudo timeout 10 tcpdump -c 5 -i any 'port 53' -nn`
- **Output:**

```
spiriton@LAPTOP-TNLQNHEC:~$ sudo timeout 10 tcpdump -c 5 -i any 'port 53' -nn
tcpdump: data link type LINUX_SLL2
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on any, link-type LINUX_SLL2 (Linux cooked v2), snapshot length 262144 bytes

0 packets captured
0 packets received by filter
0 packets dropped by kernel
```

- **Observations:**
No DNS packets were captured during the 10-second tcpdump, suggesting low DNS activity or that queries were resolved by the system cache.

## 2.3: Reverse DNS

### 1. Perform PTR Lookups:

- **Command:** `dig -x 8.8.4.4`
- **Command:** `dig -x 1.1.2.2`
- **Output:**

```
spiriton@LAPTOP-TNLQNHEC:~$ dig -x 8.8.4.4

; <<>> DiG 9.18.30-0ubuntu0.22.04.2-Ubuntu <<>> -x 8.8.4.4
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 62199
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; MBZ: 0x40be, udp: 512
;; QUESTION SECTION:
;4.4.8.8.in-addr.arpa.          IN      PTR

;; ANSWER SECTION:
4.4.8.8.in-addr.arpa.   16574   IN      PTR     dns.google.

;; Query time: 83 msec
;; SERVER: 10.255.255.254#53(10.255.255.254) (UDP)
;; WHEN: Mon Sep 29 23:23:42 MSK 2025
;; MSG SIZE  rcvd: 93

spiriton@LAPTOP-TNLQNHEC:~$ dig -x 1.1.2.2

; <<>> DiG 9.18.30-0ubuntu0.22.04.2-Ubuntu <<>> -x 1.1.2.2
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NXDOMAIN, id: 5255
;; flags: qr rd ra ad; QUERY: 1, ANSWER: 0, AUTHORITY: 1, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; MBZ: 0x06f8, udp: 512
;; QUESTION SECTION:
;2.2.1.1.in-addr.arpa.          IN      PTR

;; AUTHORITY SECTION:
1.in-addr.arpa.         1784    IN      SOA     ns.apnic.net. read-txt-record-of-zone-first-dns-admin.apnic.net. 22955 7200 1800 604800 3600

;; Query time: 575 msec
;; SERVER: 10.255.255.254#53(10.255.255.254) (UDP)
;; WHEN: Mon Sep 29 23:23:46 MSK 2025
;; MSG SIZE  rcvd: 160
```

- **Observations:**
- Reverse DNS lookups show that 8.8.4.4 resolves to dns.google, while 1.1.2.2 has no PTR record, indicating that some IPs lack reverse mapping.