# Lab 4 — Operating Systems & Networking

## Task 1: Operating System Analysis

### Task 1.1: Boot Performance Analysis

1. Analyze System Boot Time:

systemd-analyze:
```bash
Startup finished in 1.999s (userspace)
graphical.target reached after 1.970s in userspace
```

systemd-analyze blame:
```bash
523ms dev-sdd.device
430ms landscape-client.service
293ms snapd.service
249ms user@1000.service
238ms networkd-dispatcher.service
234ms packagekit.service
160ms systemd-resolved.service
136ms systemd-udev-trigger.service
128ms systemd-timesyncd.service
110ms systemd-udevd.service
100ms keyboard-setup.service
 88ms systemd-logind.service
 55ms dev-hugepages.mount
 54ms systemd-journal-flush.service
 54ms dev-mqueue.mount
 53ms e2scrub_reap.service
 52ms sys-kernel-debug.mount
 51ms sys-kernel-tracing.mount
 50ms snapd.seeded.service
 43ms kmod-static-nodes.service
 41ms modprobe@efi_pstore.service
 41ms modprobe@fuse.service
 41ms modprobe@drm.service
 37ms systemd-remount-fs.service
 33ms systemd-sysctl.service
 32ms systemd-sysusers.service
 31ms apport.service
 30ms polkit.service
 28ms snapd.socket
 24ms systemd-journald.service
 24ms systemd-tmpfiles-setup.service
 19ms user-runtime-dir@1000.service
 17ms plymouth-read-write.service
 16ms systemd-tmpfiles-setup-dev.service
 15ms console-setup.service
 15ms plymouth-quit.service
 14ms sys-fs-fuse-connections.mount
 13ms modprobe@configfs.service
 13ms rsyslog.service
 12ms systemd-update-utmp.service
  8ms systemd-update-utmp-runlevel.service
  8ms systemd-user-sessions.service
  8ms ufw.service
  7ms plymouth-quit-wait.service
  7ms setvtrgb.service
```

**Key Observations:**

* **Fast boot time:** System boots very quickly in 1.999s total, with graphical target reached in 1.970s
* **Top boot delays:** dev-sdd.device (523ms) and landscape-client.service (430ms) are the slowest services

2. Check System Load:

Uptime:
```bash
 00:56:23 up 12 min,  1 user,  load average: 0.01, 0.14, 0.15
```

W:
```bash
 00:56:26 up 12 min,  1 user,  load average: 0.01, 0.14, 0.15
USER     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU WHAT
user     pts/1    -                00:45   11:10   0.04s  0.03s -bash
```

**Key Observations:**

* **Low system load:** Load averages of 0.01, 0.14, 0.15 indicate minimal system stress
* **Single user session:** Only one active user session running for 12 minutes
* **Efficient initialization:** Most services load quickly (<300ms), showing well-optimized startup sequence

### Task 1.2: Process Forensics

1. Identify Resource-Intensive Processes:

ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 6:
```bash
    PID    PPID CMD                         %MEM %CPU
    221       1 /usr/bin/python3 /usr/share  0.2  0.0
    715       1 /usr/libexec/packagekitd     0.2  0.0
    189       1 /usr/bin/python3 /usr/bin/n  0.2  0.0
   4206       1 /lib/systemd/systemd-resolv  0.1  0.0
   4209       1 /lib/systemd/systemd-journa  0.1  0.0
```

ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 6:
```bash
    PID    PPID CMD                         %MEM %CPU
      1       0 /lib/systemd/systemd --syst  0.1  0.6
    184       1 @dbus-daemon --system --add  0.0  0.1
      2       1 /init                        0.0  0.0
      7       2 plan9 --control-socket 7 --  0.0  0.0
    182       1 /usr/sbin/cron -f -P         0.0  0.0
```

**Key Observations:**

* **Memory-intensive processes:** Python processes and PackageKit are top memory consumers (0.2% each)
* **Low memory usage:** All processes show very low memory consumption (<0.3%)
* **CPU efficiency:** Systemd init process uses only 0.6% CPU, indicating idle system
* **Minimal resource contention:** No processes show significant CPU or memory pressure

### Task 1.3: Service Dependencies

1. Map Service Relationships:

systemctl list-dependencies
```bash
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
○   ├─landscape-client.service
●   ├─networkd-dispatcher.service
●   ├─plymouth-quit-wait.service
●   ├─plymouth-quit.service
●   ├─rsyslog.service
○   ├─snapd.apparmor.service
○   ├─snapd.autoimport.service
○   ├─snapd.core-fixup.service
○   ├─snapd.recovery-chooser-trigger.service
●   ├─snapd.seeded.service
○   ├─snapd.service
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
●   │ │ ├─systemd-timesyncd.service
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
```

systemctl list-dependencies multi-user.target
```bash
multi-user.target
● ├─apport.service
● ├─console-setup.service
● ├─cron.service
● ├─dbus.service
○ ├─dmesg.service
○ ├─e2scrub_reap.service
○ ├─irqbalance.service
○ ├─landscape-client.service
● ├─networkd-dispatcher.service
● ├─plymouth-quit-wait.service
● ├─plymouth-quit.service
● ├─rsyslog.service
○ ├─snapd.apparmor.service
○ ├─snapd.autoimport.service
○ ├─snapd.core-fixup.service
○ ├─snapd.recovery-chooser-trigger.service
● ├─snapd.seeded.service
○ ├─snapd.service
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
● │ │ ├─systemd-timesyncd.service
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

**Key Observations:**

* **Complex service hierarchy:** Multi-layered dependency tree with multiple targets
* **Systemd architecture:** Clear separation between sysinit, basic, multi-user, and graphical targets
* **Critical services:** Core services include systemd-logind, systemd-resolved, dbus, and snapd
* **Ubuntu-specific services:** Landscape client, Ubuntu Advantage, and Apport error reporting
* **Automation focus:** Multiple timer services (apt-daily, logrotate, fstrim) for system maintenance
* **Security services:** UFW firewall and AppArmor are integral parts of the service stack

### Task 1.4: User Sessions

1. Audit Login Activity:

who -a
```bash
           system boot  2025-09-29 00:45
           run-level 5  2025-09-29 00:45
LOGIN      tty1         2025-09-29 00:45               216 id=tty1
LOGIN      console      2025-09-29 00:45               212 id=cons
user       - pts/1        2025-09-29 00:45 00:19         340
           pts/2        2025-09-29 00:49              5031 id=ts/2  term=0 exit=0
```

last -n 5
```bash
user     pts/1                         Mon Sep 29 00:45   still logged in
reboot   system boot  6.6.87.2-microso Mon Sep 29 00:45   still running
root     pts/1                         Mon Sep 29 00:45 - crash  (00:00)
reboot   system boot  6.6.87.2-microso Mon Sep 29 00:44   still running
root     pts/1                         Mon Sep 29 00:44 - crash  (00:00)

wtmp begins Mon Sep 29 00:44:32 2025
```

**Key Observations:**

* **Recent boot:** System was rebooted at 00:45, with previous crashes noted
* **Single active user:** User "user" logged in via pts/1 and has been active for 12 minutes
* **Session history:** Previous sessions ended abruptly (crashes) before current stable session
* **Multiple login points:** Console, tty1, and pts sessions show different access methods
* **System stability:** Current session shows normal operation after previous instability

### Task 1.5: Memory Analysis

1. Inspect Memory Allocation:

free -h
```bash
               total        used        free      shared  buff/cache   available
Mem:           7.6Gi       337Mi       7.1Gi       3.0Mi       168Mi       7.2Gi
Swap:          2.0Gi          0B       2.0Gi
```

cat /proc/meminfo | grep -e MemTotal -e SwapTotal -e MemAvailable
```bash
MemTotal:        8014048 kB
SwapTotal:       2097152 kB
```

**Key Observations:**

* **Ample available memory:** 7.2GB available out of 7.6GB total (94% free)
* **Low memory usage:** Only 337MB used, indicating light system load
* **Unused swap:** No swap usage (0B), showing sufficient physical memory
* **Efficient caching:** 168MB used for buff/cache, optimizing disk operations
* **Healthy memory state:** High availability suggests no memory pressure or bottlenecks

### What is the top memory-consuming process?
The top memory-consuming processes are Python processes (likely system services) and PackageKit, each using 0.2% of system memory.

### Resource Utilization Patterns Observed:

* **Excellent efficiency:** System uses minimal resources with high availability
* **Stable operation:** Low load averages and ample free memory indicate healthy system state
* **Service optimization:** Fast boot times and well-managed service dependencies
* **Light workload:** Current usage patterns suggest development or light desktop environment
* **Memory management:** Efficient memory allocation with no swap usage needed

## Task 2: Networking Analysis

### Task 2.1: Network Path Tracing
1. Traceroute Execution:

traceroute github.com
```bash
traceroute to github.com (140.82.121.XXX), 64 hops max
  1   172.24.176.XXX  0.326ms  0.162ms  0.197ms
  2   10.91.0.XXX  1.592ms  1.332ms  1.343ms
  3   10.252.6.XXX  1.810ms  1.541ms  1.563ms
  4   84.18.123.XXX  13.732ms  12.970ms  13.091ms
  5   178.176.191.XXX  8.802ms  10.039ms  9.060ms
  6   *  *  *
  7   *  *  *
  8   *  *  *
  9   *  *  *
 10   83.169.204.XXX  48.909ms  48.577ms  48.759ms
 11   194.68.123.XXX  46.416ms  50.713ms  45.570ms
 12   *  *  94.103.180.XXX  678.517ms
 13   94.103.180.XXX  60.410ms  59.831ms  59.809ms
 14   *  *  *
 15   *  *  *
 16   *  *  *
 17   *  *  *
 18   94.103.180.XXX  58.090ms  57.142ms  57.797ms
 19   45.153.82.XXX  59.467ms  58.618ms  64.051ms
 20   *  *  *
 21   *  *  *
 22   *  *  *
 23   *  *  *
 24   *  *  *
 25   *  *  *
 26   *  *  *
 27   *  *  *
 28   *  *  *
 29   *  *  *
 30   *  *  *
 31   *  *  *
 32   *  *  *
 33   *  *  *
 34   *  *  *
 35   *  *  *
 36   *  *  *
 37   *  *  *
 38   *  *  *
 39   *  *  *
 40   *  *  *
 41   *  *  *
 42   *  *  *
 43   *  *  *
 44   *  *  *
 45   *  *  *
 46   *  *  *
 47   *  *  *
 48   *  *  *
 49   *  *  *
 50   *  *  *
 51   *  *  *
 52   *  *  *
 53   *  *  *
 54   *  *  *
 55   *  *  *
 56   *  *  *
 57   *  *  *
 58   *  *  *
 59   *  *  *
 60   *  *  *
 61   *  *  *
 62   *  *  *
 63   *  *  *
 64   *  *  *
```

2. DNS Resolution Check:

dig github.com
```bash
; <<>> DiG 9.18.39-0ubuntu0.22.04.1-Ubuntu <<>> github.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 48698
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;github.com.                    IN      A

;; ANSWER SECTION:
github.com.             3       IN      A       140.82.121.XXX

;; Query time: 39 msec
;; SERVER: 10.255.255.XXX#53(10.255.255.XXX) (UDP)
;; WHEN: Mon Sep 29 01:39:52 MSK 2025
;; MSG SIZE  rcvd: 55
```

**Key Observations - Network Path Tracing:**

* **Complex routing path:** Route to GitHub traverses multiple network segments with varying latency
* **Firewall filtering:** Multiple hops show no response (***), indicating firewalls or security devices blocking ICMP
* **Latency progression:** Initial hops show low latency (0.1-13ms), increasing to 45-60ms for intermediate hops
* **Network congestion:** One hop shows significant latency spike (678ms) suggesting temporary congestion
* **DNS efficiency:** GitHub resolves quickly (39ms) to 140.82.121.XXX with proper caching (3-second TTL)
* **Internal DNS:** Using internal DNS server 10.255.255.XXX for resolution


### Task 2.2: Packet Capture

1. Capture DNS Traffic:

sudo timeout 10 tcpdump -c 5 -i any 'port 53' -nn
```bash
tcpdump: data link type LINUX_SLL2
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on any, link-type LINUX_SLL2 (Linux cooked v2), snapshot length 262144 bytes

0 packets captured
0 packets received by filter
0 packets dropped by kernel
```

**Key Observations - Packet Capture:**

* **No DNS traffic captured:** During the 10-second capture window, no DNS queries were observed
* **Possible explanations:** DNS cache was populated, no active browsing during capture, or DNS uses different port
* **Network interface:** Capturing on 'any' interface using Linux cooked v2 format
* **Filter efficiency:** Properly filtered for port 53 (DNS) but no traffic matched

### Task 2.3: Reverse DNS

1. Perform PTR Lookups:

dig -x 8.8.4.4
```bash
; <<>> DiG 9.18.39-0ubuntu0.22.04.1-Ubuntu <<>> -x 8.8.4.4
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 53050
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;4.4.8.8.in-addr.arpa.          IN      PTR

;; ANSWER SECTION:
4.4.8.8.in-addr.arpa.   53556   IN      PTR     dns.google.

;; Query time: 7 msec
;; SERVER: 10.255.255.XXX#53(10.255.255.XXX) (UDP)
;; WHEN: Mon Sep 29 01:42:46 MSK 2025
;; MSG SIZE  rcvd: 73
```

dig -x 1.1.2.2
```bash
; <<>> DiG 9.18.39-0ubuntu0.22.04.1-Ubuntu <<>> -x 1.1.2.2
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NXDOMAIN, id: 21741
;; flags: qr rd ra; QUERY: 1, ANSWER: 0, AUTHORITY: 1, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;2.2.1.1.in-addr.arpa.          IN      PTR

;; AUTHORITY SECTION:
1.in-addr.arpa.         899     IN      SOA     ns.apnic.net. read-txt-record-of-zone-first-dns-admin.apnic.net. 22952 7200 1800 604800 3600

;; Query time: 113 msec
;; SERVER: 10.255.255.XXX#53(10.255.255.XXX) (UDP)
;; WHEN: Mon Sep 29 01:43:34 MSK 2025
;; MSG SIZE  rcvd: 137
```

**Key Observations:**

* **Successful PTR resolution:** 8.8.4.4 correctly resolves to dns.google (Google's DNS service)
* **Long TTL:** PTR record has 53556-second TTL (~14.8 hours) indicating stable infrastructure
* **Failed reverse lookup:** 1.1.2.2 returns NXDOMAIN (non-existent domain) with APNIC authority
* **APNIC authority:** For 1.0.0.0/8 block, APNIC (Asia-Pacific Network Information Centre) is authoritative
* **Query time difference:** Successful lookup took 7ms vs 113ms for failed lookup (authority referral)

### Network Analysis Summary
**DNS Query/Response Patterns:**

* **Efficient resolution:** Quick response times (7-113ms) for both forward and reverse lookups
* **Proper caching:** Low TTL values suggest dynamic content, while high TTLs indicate stable services
* **Authority delegation:** Proper hierarchical DNS structure with clear authority boundaries

**Reverse Lookup Comparison:**
* **Infrastructure services:** Well-known IPs like Google DNS have proper PTR records
* **Unallocated IPs:** Non-infrastructure IPs often lack reverse DNS entries
* **Regional management:** Different IP blocks managed by respective regional internet registries

**Network Path Insights:**

* **Enterprise routing:** Internal network (10.x, 172.x) routing before internet egress
* **Geographic routing:** Path suggests traffic traversing multiple ISP networks
* **Security posture:** Firewalls and security devices evident from filtered traceroute responses