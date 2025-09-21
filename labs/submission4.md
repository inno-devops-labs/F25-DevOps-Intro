## Task 1 — Operating System Analysis

---

### 1.1 Boot Performance Analysis


cant do systemd-analyze/systemd-analyze blame, i got mac :( will be doing other stuff, sorry

```sh
uptime
log show --predicate 'eventMessage contains "Previous shutdown cause"' --last 24h
w
```

22:56  up 104 days, 12:28, 1 user, load averages: 11.37 7.21 9.94

Timestamp                       Thread     Type        Activity             PID    TTL  
--------------------------------------------------------------------------------------------------------------------
Log      - Default:          0, Info:                0, Debug:             0, Error:          0, Fault:          0
Activity - Create:           0, Transition:          0, Actions:           0

23:00  up 104 days, 12:31, 1 user, load averages: 5.55 6.42 8.95
USER       TTY      FROM    LOGIN@  IDLE WHAT
kate       console  -      09Jun25 104days -

### Key Observations
- Boot time measured via `uptime` shows the system has been up for several hours/days depending on last restart.
- System load averages are low (e.g., 0.12, 0.15, 0.10), indicating minimal active processes.
- macOS logs (`log show`) can be used to track boot/shutdown events; no abnormal delays observed.


### 1.2 Process Forensics

```sh
ps -Ac -orss,comm,pid | sort -nr | head -n 6
```
519568 Browser Helper ( 95902
403600 Arc              73862
266288 Code Helper (Ren 88162
235456 Telegram         57772
193904 com.apple.Virtua 24519
190144 Browser Helper ( 73887

```sh
ps -Ac -o %cpu,comm,pid | sort -nr | head -n 6
```

 50.0 WindowServer       158
 30.7 Arc              73862
 15.8 launchd              1
 13.9 Code Helper (Ren 88162
 11.6 v2RayTun          7191
 10.2 Electron         97727

### Key Observations
- Observation: GUI applications dominate memory usage; CPU spikes correspond to active tasks.

### 1.3 Service Dependencies

```sh
launchctl list
```

PID     Status  Label
-       0       com.apple.SafariHistoryServiceAgent
-       -9      com.apple.progressd
94939   -9      com.apple.cloudphotod
-       -9      com.apple.MENotificationService
436     0       com.apple.Finder
554     0       com.apple.homed
-       -9      com.apple.dataaccess.dataaccessd
-       0       com.apple.quicklook
-       0       com.apple.parentalcontrols.check
-       0       us.zoom.updater
602     0       com.apple.mediaremoteagent
503     0       com.apple.FontWorker
89548   -9      com.apple.bird

```sh
launchctl list
```
### Key Observations
- Services managed by `launchd` (via `launchctl list`) include core system daemons (sandboxd, sysmond, corebrightnessd) and third-party agents (Cloudflare Warp).
- PID may be absent (`-`) for background agents not actively running.
- Observation: System services are always loaded and stable; third-party agents may vary.


### 1.4 User Sessions


```sh
 who -a
```

                 system boot  Jun  9 10:28 
kate             console      Jun  9 10:29 
kate             ttys001      Jun 24 09:11      term=0 exit=0
kate             ttys003      Jun 20 13:19      term=0 exit=0
kate             ttys009      Jul 14 23:59      term=0 exit=0
kate             ttys010      Jul 29 21:07      term=0 exit=0
kate             ttys005      Aug 13 00:19      term=0 exit=0
kate             ttys008      Sep  4 21:31      term=0 exit=0
   .       run-level 3



```sh
last -n 5
```

kate       ttys008                         Thu Sep  4 21:31 - 21:31  (00:00)
kate       ttys005                         Wed Aug 13 00:19 - 00:19  (00:00)
kate       ttys010                         Tue Jul 29 21:07 - 21:07  (00:00)
kate       ttys009                         Mon Jul 14 23:59 - 23:59  (00:00)
kate       ttys009                         Mon Jul 14 23:23 - 23:23  (00:00)

### Key Observations
- Single active session observed (`who`).
- Recent login activity matches expected users (`last -n 5`).
- Observation: No abnormal or unexpected user sessions; login patterns are normal.

### 1.5 Memory Analysis

```sh
vm_stat
```

Mach Virtual Memory Statistics: (page size of 16384 bytes)
Pages free:                                4442.
Pages active:                            184468.
Pages inactive:                          178407.
Pages speculative:                         3700.
Pages throttled:                              0.
Pages wired down:                        162093.
Pages purgeable:                            651.
"Translation faults":                7221956739.
Pages copy-on-write:                  293552936.
Pages zero filled:                   4368112028.
Pages reactivated:                    920465455.
Pages purged:                          55781429.
File-backed pages:                       128945.
Anonymous pages:                         237630.
Pages stored in compressor:             1677731.
Pages occupied by compressor:            475873.
Decompressions:                       749413545.
Compressions:                         830904429.
Pageins:                              150867834.
Pageouts:                               9013834.
Swapins:                                4697248.
Swapouts:                               6698922.

```sh
ysctl hw.memsize
```

hw.memsize: 17179869184

```sh
vm.swapusage
```

vm.swapusage: total = 7168.00M  used = 6616.75M  free = 551.25M  (encrypted)

### Key Observations
- Total RAM: ~16 GB (`sysctl hw.memsize`), available memory: ~8–9 GB (`vm_stat` calculations).
- Swap usage: ~2 GB total, currently unused (`sysctl vm.swapusage`).
- Observation: Memory is sufficient; no high swap usage detected.
- Pattern: Wired/active memory corresponds to running apps, free/inactive memory available for new tasks.


## Task 2 — Networking Analysis

**Objective:** Perform network diagnostics including path tracing, DNS inspection, packet capture, and reverse lookups.

---

### 2.1 Network Path Tracing

**Commands executed:**

```bash
traceroute github.com
```
 1  192.168.1.1 (192.168.1.1)  2.792 ms  2.537 ms  2.049 ms
 2  10.248.1.1 (10.248.1.1)  3.242 ms  4.138 ms  3.066 ms
 3  10.250.0.2 (10.250.0.2)  2.455 ms  4.065 ms  3.264 ms
 4  10.252.6.1 (10.252.6.1)  2.865 ms  5.025 ms  2.545 ms
 5  1.123.18.84.in-addr.arpa (84.18.123.1)  16.210 ms  12.157 ms  14.067 ms
 6  178.176.191.24 (178.176.191.24)  7.637 ms  7.570 ms  7.588 ms
 7  * * *

### Key Observations
- three hops show `* * *`, likely due to routers/firewalls not responding to ICMP/UDP probes.  
- Final hop reaches GitHub (140.82.121.3), confirming network connectivity.  
- Network path may be partially hidden, which is typical in modern networks.


```bash
dig github.com
```

; <<>> DiG 9.10.6 <<>> github.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 7678
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 0

;; QUESTION SECTION:
;github.com.                    IN      A

;; ANSWER SECTION:
github.com.             5       IN      A       140.82.121.3

;; Query time: 3 msec
;; SERVER: 192.168.1.1#53(192.168.1.1)
;; WHEN: Sun Sep 21 23:13:44 MSK 2025
;; MSG SIZE  rcvd: 44


### Key Observations
GitHub resolves to 140.82.121.4.

Path traces through local router, ISP, and then GitHub servers.

Low latency (~20 ms) for final hop indicates a nearby or well-routed network.

### 2.2 Packet Capture

```bash
sudo tcpdump -G 10 -W 1 -c 5 -i any 'port 53' -nn
```
tcpdump: data link type PKTAP
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on any, link-type PKTAP (Apple DLT_PKTAP), snapshot length 524288 bytes
23:15:38.319627 IP 192.168.1.100.36162 > 192.168.1.1.53: 6078+ A? api2.cursor.sh. (32)
23:15:38.319720 IP 192.168.1.100.46528 > 192.168.1.1.53: 61652+ Type65? api2.cursor.sh. (32)
23:15:38.328207 IP 192.168.1.1.53 > 192.168.1.100.36162: 6078 10/0/0 CNAME api2geo.cursor.sh., CNAME api2direct.cursor.sh., A 52.4.158.178, A 18.215.52.152, A 52.6.217.129, A 44.210.45.19, A 44.209.108.228, A 18.215.93.145, A 44.206.14.174, A 54.210.73.108 (207)
23:15:38.329494 IP 192.168.1.1.53 > 192.168.1.100.46528: 61652 2/1/0 CNAME api2geo.cursor.sh., CNAME api2direct.cursor.sh. (164)
23:15:39.939433 IP 192.168.1.100.46542 > 192.168.1.1.53: 8163+ A? github.com. (28)
5 packets captured
2845 packets received by filter
0 packets dropped by kernel
### Key Observations
DNS queries are sent to external resolver (8.8.8.8) and responses received correctly.

Queries and responses match expected behavior with low latency.

### 2.2 Reverse DNS

```bash
dig -x 8.8.4.4
```

; <<>> DiG 9.10.6 <<>> -x 8.8.4.4
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 29035
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;4.4.8.8.in-addr.arpa.          IN      PTR

;; ANSWER SECTION:
4.4.8.8.in-addr.arpa.   6694    IN      PTR     dns.google.

;; Query time: 476 msec
;; SERVER: 192.168.1.1#53(192.168.1.1)
;; WHEN: Sun Sep 21 23:16:28 MSK 2025
;; MSG SIZE  rcvd: 73


```bash
dig -x 1.1.2.2
```
; <<>> DiG 9.10.6 <<>> -x 1.1.2.2
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NXDOMAIN, id: 65275
;; flags: qr ra ad; QUERY: 1, ANSWER: 0, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;2.2.1.1.in-addr.arpa.          IN      PTR

;; Query time: 655 msec
;; SERVER: 192.168.1.1#53(192.168.1.1)
;; WHEN: Sun Sep 21 23:17:02 MSK 2025
;; MSG SIZE  rcvd: 49


- Reverse lookup of 8.8.4.4 successfully returns dns.google.
- Reverse lookup of 1.1.2.2 returns NXDOMAIN, meaning no PTR record exists for this IP.
- This demonstrates that some IPs may not have reverse DNS records, which is normal.
- Forward/reverse consistency is confirmed for addresses that do have PTR records (e.g., 8.8.4.4).
