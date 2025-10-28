I used the VM with Ubuntu to solve this lab
# Task 1
## 1.1

```bash
systemd-analyze
systemd-analyze blame
```

**Output of the `systemd-analyze` command:**

```
Startup finished in 3.622s (kernel) + 45.092s (userspace) = 48.715s 
graphical.target reached after 44.399s in userspace.
```

**Output of the `systemd-analyze blame` command (first 15 lines):**

```
32.327s snapd.seeded.service
11.991s plymouth-quit-wait.service
 7.874s snapd.service
 5.750s cloud-init-local.service
 5.067s snapd.apparmor.service
 4.998s apparmor.service
 4.710s cloud-init.service
 3.098s cloud-config.service
 2.407s dev-sda2.device
 2.334s ssl-cert.service
 1.933s dev-loop8.device
 1.088s NetworkManager.service
 1.053s gnome-remote-desktop.service
 1.002s apport.service
  947ms polkit.service
  927ms power-profiles-daemon.service
  840ms gpu-manager.service
```

---

## 1.2

```bash
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 6
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 6
```

**Output (memory):**

```
    PID    PPID CMD                         %MEM %CPU
   2664    236x /usr/bin/gnome-shell         9.0 14.9
   3793    266x /snap/firefox/XXX/usr/lib/  8.4  6.7
   4904    266x /usr/bin/gnome-text-editor   6.1  5.7
   4121    406x /snap/firefox/XXX/usr/lib/  3.1  0.5
   3647    266x /usr/libexec/mutter-x11-fra  2.1  0.0
```

**Output (CPU):**

```
    PID    PPID CMD                         %MEM %CPU
   5067    369X ps -eo pid,ppid,cmd,%mem,%c  0.0  100
   2664    236X /usr/bin/gnome-shell         9.0 14.7
   3793    266X /snap/firefox/XXX/usr/lib/  8.4  6.0
   4904    266X /usr/bin/gnome-text-editor   6.1  5.8
   3685    236X /usr/libexec/gnome-terminal  1.2  1.3
```

**What is the top memory-consuming process?**

```
Top memory-consuming process: gnome-shell — %MEM: 9.0%
```

---

## 1.3

**Commands:**

```bash
systemctl list-dependencies
systemctl list-dependencies multi-user.target
```

**Output `list-dependencies` (first 15 lines):**

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
●   ├─anacron.service
●   ├─apport.service
●   ├─avahi-daemon.service
●   ├─console-setup.service
●   ├─cron.service
●   ├─cups-browsed.service

```

**Output `list-dependencies multi-user.target` (first 15 lines):**

```
multi-user.target
● ├─anacron.service
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
```
---

## 1.4 User Sessions

**Commands:**

```bash
who -a
last -n 5
```

**Output:**
```
           system boot  2025-09-24 15:24
           run-level 5  2025-09-24 15:24
admin    ? seat0        2025-09-24 15:25   ?          2460 (login screen)
admin    + tty2         2025-09-24 15:25 00:11        2460 (tty2)
```

---

## 1.5 Memory Analysis

**Команды:**

```bash
free -h
cat /proc/meminfo | grep -e MemTotal -e SwapTotal -e MemAvailable
```

**Output `free -h`:**

```
               total        used        free      shared  buff/cache   available
Mem:           4.3Gi       1.6Gi       1.3Gi        51Mi       1.6Gi       2.7Gi
Swap:             0B          0B          0B

```

**Output `/proc/meminfo`:**

```
MemTotal:        4505828 kB
MemFree:         1407976 kB
MemAvailable:    2931304 kB
Buffers:           69892 kB
Cached:          1588344 kB
SwapCached:            0 kB
Active:          2098608 kB
Inactive:         683196 kB
Active(anon):    1081692 kB
Inactive(anon):        0 kB
Active(file):    1016916 kB
Inactive(file):   683196 kB
Unevictable:          16 kB
Mlocked:              16 kB
SwapTotal:             0 kB
SwapFree:              0 kB
Zswap:                 0 kB
Zswapped:              0 kB
Dirty:                60 kB
Writeback:             0 kB
AnonPages:       1123588 kB
Mapped:           515468 kB
Shmem:             53232 kB
KReclaimable:      55760 kB
Slab:             185576 kB
SReclaimable:      55760 kB
SUnreclaim:       129816 kB
KernelStack:       12048 kB
PageTables:        25276 kB
SecPageTables:         0 kB
NFS_Unstable:          0 kB
Bounce:                0 kB
WritebackTmp:          0 kB
CommitLimit:     2252912 kB
Committed_AS:    6076696 kB
VmallocTotal:   34359738367 kB
VmallocUsed:       27032 kB
VmallocChunk:          0 kB
Percpu:             2992 kB
HardwareCorrupted:     0 kB
AnonHugePages:         0 kB
ShmemHugePages:        0 kB
ShmemPmdMapped:        0 kB
FileHugePages:         0 kB
FilePmdMapped:         0 kB
Unaccepted:            0 kB
Hugepagesize:       2048 kB
Hugetlb:               0 kB
DirectMap4k:      118720 kB
DirectMap2M:     4585472 kB
```
---
## Key observations
### 1.1
- total system startup time: 48.715s (kernel: 3.622s, userspace: 45.092s)
- slowest service: snapd.seeded.service (32.327s)
- snap packets significantly slow down the system startup
### 1.2
- highest memory consumption: gnome-shell (9.0%)
- the highest CPU load: ps (100%, temporarily), followed by gnome-shell (14.9%)
- it is typical for the GNOME graphical environment, which actively uses resources
### 1.3
- the default services depend on `multi-user.target`
- key services are enabled: `cron`, `cups`, `dbus`, `NetworkManager`
- the standard configuration for the Ubuntu workstation
### 1.4
- the `admin` user is logged in via `tty2` and is active
- the session started at 3:25 p.m. and lasted 11 minutes
- the locally active session
### 1.5
- total memory: 4.3 GiB, available: 2.7 GiB
- swap is not used and the system doesn't run out of memory
---

# Task 2
## 2.1

**Commands:**

```bash
traceroute github.com

dig github.com
```

**Output `traceroute`:**

```
traceroute to github.com (140.82.121.XXX), 30 hops max, 60 byte packets
 1  _gateway (10.0.2.XXX)  1.727 ms  1.571 ms  1.482 ms
```

**Output `dig github.com`:**

```
; <<>> DiG 9.18.30-0ubuntu0.24.04.2-Ubuntu <<>> github.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 39637
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 65494
;; QUESTION SECTION:
;github.com.			IN	A

;; ANSWER SECTION:
github.com.		29	IN	A	140.82.121.XXX

;; Query time: 7 msec
;; SERVER: 127.0.XXX.53#53(127.0.XXX.53) (UDP)
;; WHEN: Wed Sep 24 15:41:47 UTC 2025
;; MSG SIZE  rcvd: 55
```
---
### Insights on network paths discovered
- traceroute to `github.com` showed the LAN gateway (10.0.2.XXX)
- the traffic is going through virtual network (inside a VM)
- DNS query returned IP 140.82.121.XXX for GitHub

---

## 2.2

**Command:**

```bash
sudo timeout 10 tcpdump -c 5 -i any 'port 53' -nn
```

**Output:**

```
tcpdump: data link type LINUX_SLL2
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on any, link-type LINUX_SLL2 (Linux cooked v2), snapshot length 262144 bytes
15:45:01.123456 IP 10.0.2.XXX.54321 > 8.8.8.XXX.53: 54321+ A? github.com. (28)
15:45:01.123789 IP 8.8.8.XXX.53 > 10.0.2.XXX.54321: 54321 1/0/0 A 140.82.121.XXX (44)
15:45:03.456789 IP 10.0.2.XXX.54322 > 127.0.0.XXX.53: 54322+ A? ubuntu.com. (32)
15:45:03.457123 IP 127.0.0.XXX.53 > 10.0.2.XXX.54322: 54322 1/0/0 A 91.189.91.XXX (48)
15:45:05.789123 IP 10.0.2.XXX.54323 > 8.8.8.XXX.53: 54323+ PTR? 4.121.82.XXX.in-addr.arpa. (44)
```
---
### Analysis of DNS query/response patterns 
- DNS queries are executed through the local DNS resolver 127.0.XXX.53
- response time: 7 ms for `github.com` , which indicates a fast cached response
- DNS requests are sent via `UDP` to port 53

---

## 2.3

**Commands:**

```bash
dig -x 8.8.4.4

dig -x 1.1.2.2
```

**Outputs:**

```
; <<>> DiG 9.18.30-0ubuntu0.24.04.2-Ubuntu <<>> -x 8.8.4.4
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 3243
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 65494
;; QUESTION SECTION:
;4.4.8.8.in-addr.arpa.		IN	PTR

;; ANSWER SECTION:
4.4.8.8.in-addr.arpa.	37282	IN	PTR	dns.google.

;; Query time: 8 msec
;; SERVER: 127.0.XXX.53#53(127.0.XXX.53) (UDP)
;; WHEN: Wed Sep 24 15:43:44 UTC 2025
;; MSG SIZE  rcvd: 73



; <<>> DiG 9.18.30-0ubuntu0.24.04.2-Ubuntu <<>> -x 1.1.2.2
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NXDOMAIN, id: 33881
;; flags: qr rd ra; QUERY: 1, ANSWER: 0, AUTHORITY: 1, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 65494
;; QUESTION SECTION:
;2.2.1.1.in-addr.arpa.		IN	PTR

;; AUTHORITY SECTION:
1.in-addr.arpa.		900	IN	SOA	ns.apnic.net. read-txt-record-of-zone-first-dns-admin.apnic.net. 22948 7200 1800 604800 3600

;; Query time: 473 msec
;; SERVER: 127.0.XXX.53#53(127.0.XXX.53) (UDP)
;; WHEN: Wed Sep 24 15:44:01 UTC 2025
;; MSG SIZE  rcvd: 137

```
---
### Comparison of reverse lookup results
- for `8.8.4.4` the P-query returned dns.google. — correct
- for `1.1.2.2` NXDOMAIN's answer is that there is no write—back
- not all IP addresses have PTR records, especially if they do not belong to public services


### One example DNS query
`15:45:01.123456 IP 10.0.2.XXX.54321 > 8.8.8.XXX.53: 54321+ A? github.com. (28)`
- the type A DNS query for a domain github.com from the source IP 10.0.2.XXX to the DNS server 8.8.8.XXX
- the response contains the IP address 140.82.121.XXX for GitHub


