# Lab 4 — Submission (macOS)

> I’m working on macOS, so I swapped a few Linux-only commands for macOS equivalents.

Sanitization: process names are generalized and the last octet of IPs is replaced with `XXX`.

---

## Task 1 — Operating System Analysis

### 1.1 Boot Performance Analysis

#### Commands and outputs

```sh
# Boot time (macOS)
sysctl -n kern.boottime
```

```text
{ sec = 1758552252, usec = 973963 } Mon Sep 22 17:44:12 2025
```
---
```sh
# Recent reboot entries
last reboot -n 2 | head -n 10
```

```text
reboot time                                Mon Sep 22 17:44

wtmp begins Mon Sep 22 17:44:13 MSK 2025
```
---
```sh
# Load averages and uptime
uptime
```

```text
23:21  up 2 days,  5:37, 1 user, load averages: 4.22 2.85 2.61
```
---
```sh
# Logged-in users and system load
w
```

```text
23:21  up 2 days,  5:37, 1 user, load averages: 4.22 2.85 2.61
USER       TTY      FROM    LOGIN@  IDLE WHAT
narly      console  -      Mon17   2days -
```

#### Observations
- The machine booted on Mon Sep 22 17:44 and has been up for ~2 days, which matches all tools.
- Load is in the 2–4 range with just one user. That fits my typical dev workload (IDEs, browser, background agents).

---

### 1.2 Process Forensics

#### Commands and outputs

```sh
# Top by memory
ps -Ao pid,ppid,comm,%mem,%cpu | sort -k4 -nr | head -n 6
```

```text
33036     1 [SOME_PROCESS]  6.6  30.9
 2104     1 [SOME_PROCESS]  2.7  16.2
51038  2104 [SOME_PROCESS]  2.5   0.0
28018 27999 [SOME_PROCESS]  2.5   4.0
69394  2104 [SOME_PROCESS]  2.2  37.0
21535 38881 [SOME_PROCESS]  2.2  24.4
```
---
```sh
# Top by CPU
ps -Ao pid,ppid,comm,%mem,%cpu | sort -k5 -nr | head -n 6
```

```text
  586     1 [SOME_PROCESS]  0.9  52.5
38886 38881 [SOME_PROCESS]  0.3  42.4
33036     1 [SOME_PROCESS]  6.6  30.4
69394  2104 [SOME_PROCESS]  2.2  29.1
21535 38881 [SOME_PROCESS]  2.2  28.5
 2104     1 [SOME_PROCESS]  2.7  17.1
```

#### Observations
- A handful of GUI apps and services are doing most of the work. That’s expected while coding and running tools.
- Usage is spread across a few processes rather than one runaway task.

Top memory user: PID 33036 at 6.6% MEM.

---

### 1.3 Service Dependencies (macOS services)

```sh
launchctl list | head -n 30
```

```text
PID	Status	Label
-	0	com.apple.SafariHistoryServiceAgent
-	-9	com.apple.progressd
-	0	com.apple.enhancedloggingd
47666	-9	com.apple.cloudphotod
-	-9	com.apple.MENotificationService
2116	0	com.apple.Finder
970	0	com.apple.homed
44150	-9	com.apple.dataaccess.dataaccessd
-	0	com.apple.quicklook
-	0	com.apple.parentalcontrols.check
-	0	com.apple.mbfloagent.5FB95404-618C-4B4C-A38D-44F1A7D4D5F0
1156	0	com.apple.mediaremoteagent
1227	0	com.apple.FontWorker
1017	0	com.apple.bird
-	0	com.apple.amp.mediasharingd
-	-9	com.apple.knowledgeconstructiond
46518	-9	com.apple.inputanalyticsd
-	0	com.apple.familycontrols.useragent
-	0	com.apple.AssetCache.agent
37795	0	com.apple.GameController.gamecontrolleragentd
30362	0	com.apple.universalaccessAuthWarn
-	0	com.apple.UserPictureSyncAgent
929	0	com.apple.nsurlsessiond
-	-9	com.apple.devicecheckd
-	0	com.apple.syncservices.uihandler
61615	-9	com.apple.iconservices.iconservicesagent
-	-9	com.apple.diagnosticextensionsd
48487	-9	com.apple.intelligenceplatformd
48285	-9	com.apple.SafariBookmarksSyncAgent
```

#### Observations
- macOS relies on `launchd`/`launchctl` instead of `systemd`. The list shows a mix of active agents and ones that recently exited (-9).
- Core user-facing services (like Finder and `nsurlsessiond`) are running normally.

---

### 1.4 User Sessions

```sh
who -a
```

```text
                 system boot  Sep 22 17:44 
narly            console      Sep 22 17:45 
narly            ttys001      Sep 23 01:06 	term=0 exit=0
narly            ttys030      Sep 23 15:56 	term=0 exit=0
   .       run-level 3
```
---
```sh
last -n 5
```

```text
narly      ttys030                         Tue Sep 23 15:56 - 15:56  (00:00)
narly      ttys001                         Tue Sep 23 01:06 - 01:06  (00:00)
narly      console                         Mon Sep 22 17:45   still logged in
reboot time                                Mon Sep 22 17:44

wtmp begins Mon Sep 22 17:44:13 MSK 2025
```

#### Observations
- It’s just my local account logged in since boot. A couple of short terminal sessions came and went without issues.

---

### 1.5 Memory Analysis

```sh
sysctl -n hw.memsize
```

```text
25769803776
```

*~24.0 GiB*

---
```sh
sysctl vm.swapusage
```

```text
vm.swapusage: total = 4096.00M  used = 2694.19M  free = 1401.81M  (encrypted)
```
---
```sh
memory_pressure -Q
```

```text
The system has 25769803776 (1572864 pages with a page size of 16384).
System-wide memory free percentage: 80%
```
---
```sh
vm_stat
```

```text
Mach Virtual Memory Statistics: (page size of 16384 bytes)
Pages free:                               39656.
Pages active:                            591525.
Pages inactive:                          590748.
Pages speculative:                         5060.
Pages throttled:                              0.
Pages wired down:                        212530.
Pages purgeable:                          11333.
"Translation faults":                 593951200.
Pages copy-on-write:                   25445736.
Pages zero filled:                    238760758.
Pages reactivated:                     49451645.
Pages purged:                           7469588.
File-backed pages:                       384567.
Anonymous pages:                         802766.
Pages stored in compressor:              569463.
Pages occupied by compressor:             90849.
Decompressions:                        43797244.
Compressions:                          58803086.
Pageins:                               22978141.
Pageouts:                               1929427.
Swapins:                                 997990.
Swapouts:                               1484124.
```

#### Observations
- Plenty of free memory reported (~80%), but swap has been used (~2.6 GiB of 4 GiB). That suggests occasional pressure while juggling apps.
- Active/inactive page counts are high, which makes sense for a long-running desktop session.

---

## Task 2 — Networking Analysis

### 2.1 Network Path Tracing

```sh
traceroute github.com
```

First hops provided:

```text
1  10.240.16.XXX  4.329 ms  3.704 ms  3.502 ms
2  10.250.0.XXX   3.495 ms  3.406 ms  3.329 ms
3  10.252.6.XXX   3.842 ms  3.720 ms  3.433 ms
4  84.18.123.XXX  16.460 ms  17.217 ms  15.438 ms
5  178.176.191.XXX 10.569 ms  10.311 ms  10.715 ms
```

#### Insight
- The path starts in RFC1918 space and then exits to the public internet—classic NAT through an upstream router/ISP.

### 2.2 DNS Resolution Check

```sh
dig github.com
```

```text
;; ->>HEADER<<- opcode: QUERY, status: NOERROR
;; QUESTION SECTION:
;github.com.                        IN      A

;; ANSWER SECTION:
github.com.             47      IN      A       140.82.121.XXX

;; SERVER: 77.88.8.XXX#53
;; WHEN: Wed Sep 24 23:46:29 MSK 2025
```

#### Insight
- Direct A record to GitHub’s front door. My resolver is an external DNS.

### 2.3 Packet Capture (DNS)

```sh
sudo tcpdump -c 5 -i any 'port 53' -nn
```

```text
00:02:12.639520 IP 10.240.19.XXX.51528 > 77.88.8.XXX.53: 53095+ A? api2direct.cursor.sh. (38)
00:02:12.728434 IP 77.88.8.XXX.53 > 10.240.19.XXX.51528: 53095 8/0/0 A 44.198.218.XXX, A 23.20.71.XXX, A 3.211.1.XXX, A 54.211.28.XXX, A 18.213.49.XXX, A 23.21.91.XXX, A 34.201.227.XXX, A 98.83.44.XXX (166)
00:02:22.111357 IP 10.240.19.XXX.60970 > 77.88.8.XXX.53: 55838+ Type65? cdn-settings.segment.com. (42)
00:02:22.111534 IP 10.240.19.XXX.49907 > 77.88.8.XXX.53: 19450+ A? cdn-settings.segment.com. (42)
00:02:22.187695 IP 77.88.8.XXX.53 > 10.240.19.XXX.49907: 19450 1/0/0 A 99.86.8.XXX (58)
```

#### Analysis
- I see standard UDP DNS A lookups and responses. The `api2direct.cursor.sh` response returns multiple A records (load-balanced/anycast frontends).
- There’s also a `Type65` query, which corresponds to SVCB/HTTPS records on modern resolvers. The A record for `cdn-settings.segment.com` came back as a single IP.

### 2.4 Reverse DNS

```sh
dig -x 8.8.4.4
```

```text
;; status: NOERROR
;; ANSWER SECTION:
4.4.8.8.in-addr.arpa.  5225    IN      PTR     dns.google.
```

```sh
dig -x 1.1.2.2
```

```text
;; status: NXDOMAIN
;; AUTHORITY SECTION:
1.in-addr.arpa. 2084 IN SOA ns.apnic.net. read-txt-record-of-zone-first-dns-admin.apnic.net. ...
```

#### Comparison
- Public resolver `8.8.4.4` has a PTR record mapping to `dns.google.`; address `1.1.2.2` lacks a PTR (NXDOMAIN), which is common.
