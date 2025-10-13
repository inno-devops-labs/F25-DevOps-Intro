# Lab 4 Submission

## Task 1 — Operating System Analysis

### 1. System Boot Analysis
- **Command:** `systemd-analyze`
- **Command:** `systemd-analyze blame`
- **Output:**
```
egors@SHEOSK:~$ systemd-analyze
Startup finished in 1.375s (userspace)
graphical.target reached after 1.364s in userspace.

egors@SHEOSK:~$ systemd-analyze blame
759ms landscape-client.service
295ms snapd.seeded.service
205ms dev-sdc.device
188ms snapd.service
186ms wsl-pro.service
135ms dpkg-db-backup.service
122ms systemd-resolved.service
107ms rsyslog.service
104ms systemd-udev-trigger.service
103ms user@1000.service
 86ms systemd-timedated.service
 78ms logrotate.service
 77ms systemd-timesyncd.service
 71ms systemd-logind.service
 61ms systemd-udevd.service
 57ms keyboard-setup.service
 56ms systemd-journald.service
 50ms e2scrub_reap.service
 40ms systemd-journal-flush.service
 38ms dev-hugepages.mount
 37ms dev-mqueue.mount
 36ms sys-kernel-debug.mount
 35ms sys-kernel-tracing.mount
 33ms dbus.service
 29ms systemd-tmpfiles-setup.service
 28ms modprobe@configfs.service
 28ms modprobe@dm_mod.service
 26ms modprobe@drm.service
```
- **Explanation:**
The system booted in 1.375 seconds (userspace). The `systemd-analyze blame` command shows which services took the most time during startup. The top services slowing down the boot are `landscape-client.service`, `snapd.seeded.service`, and `dev-sdc.device`. These are likely related to system management, snap package initialization, and device setup. Monitoring these services can help optimize boot time if needed.

### 2. System Load Check
**Command:** `uptime`
**Command:** `w`
**Output:**
```
egors@SHEOSK:~$ uptime
21:01:36 up 1 min,  1 user,  load average: 0.13, 0.06, 0.02

egors@SHEOSK:~$ w
21:01:47 up 1 min,  1 user,  load average: 0.11, 0.06, 0.02
USER     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU  WHAT
egors    pts/1    -                21:00    1:30   0.01s  0.01s -bash
```
**Observations:**
The system has been running for 1 minute with 1 active user (egors). The load averages (0.13, 0.06, 0.02) indicate very low system load, which is typical for a freshly started system with minimal activity. The only user session is a bash shell.

### 3. Resource-Intensive Processes
**Command:** `ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 6`
**Command:** `ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 6`
**Output:**
```
egors@SHEOSK:~$ ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 6
		PID    PPID CMD                         %MEM %CPU
		245       1 /usr/bin/python3 /usr/share  0.2  0.0
		 52       1 /usr/lib/systemd/systemd-jo  0.2  0.0
		184       1 /usr/libexec/wsl-pro-servic  0.2  0.0
			1       0 /sbin/init                   0.1  0.1
		115       1 /usr/lib/systemd/systemd-re  0.1  0.0
```
**Top memory-consuming process:**
The process `/usr/bin/python3 /usr/share` (PID 245) is currently using the most memory (0.2%).
**Output (CPU):**
```
egors@SHEOSK:~$ ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 6
		PID    PPID CMD                         %MEM %CPU
			1       0 /sbin/init                   0.1  0.1
		 52       1 /usr/lib/systemd/systemd-jo  0.2  0.0
		162       1 @dbus-daemon --system --add  0.0  0.0
		184       1 /usr/libexec/wsl-pro-servic  0.2  0.0
		115       1 /usr/lib/systemd/systemd-re  0.1  0.0
```
**Top CPU-consuming process:**
The process `/sbin/init` (PID 1) is currently using the most CPU (0.1%).

### 4. Service Dependencies
**Command:** `systemctl list-dependencies`
**Command:** `systemctl list-dependencies multi-user.target`
**Output:**
```
egors@SHEOSK:~$ systemctl list-dependencies
default.target
○ ├─display-manager.service
○ ├─systemd-update-utmp-runlevel.service
○ ├─wsl-binfmt.service
● └─multi-user.target
○   ├─apport.service
●   ├─console-setup.service
●   ├─cron.service
●   ├─dbus.service
○   ├─dmesg.service
○   ├─e2scrub_reap.service
○   ├─landscape-client.service
○   ├─networkd-dispatcher.service
●   ├─rsyslog.service
○   ├─snapd.apparmor.service
○   ├─snapd.autoimport.service
○   ├─snapd.core-fixup.service
○   ├─snapd.recovery-chooser-trigger.service
●   ├─snapd.seeded.service
○   ├─snapd.service
●   ├─systemd-ask-password-wall.path
●   ├─systemd-logind.service
○   ├─systemd-update-utmp-runlevel.service
●   ├─systemd-user-sessions.service
○   ├─ua-reboot-cmds.service
○   ├─ubuntu-advantage.service
●   ├─unattended-upgrades.service
●   ├─wsl-pro.service
```
**Dependency structure notes:**
The `default.target` depends on several services, with `multi-user.target` being a key dependency. Under `multi-user.target`, there are essential services like `cron`, `dbus`, `rsyslog`, and `systemd-logind`. Some services are marked with ● (active/enabled) and others with ○ (inactive/disabled). This structure shows how system targets group and manage service dependencies, ensuring that required services are started in the correct order.
```
egors@SHEOSK:~$ systemctl list-dependencies multi-user.target
multi-user.target
○ ├─apport.service
● ├─console-setup.service
● ├─cron.service
● ├─dbus.service
○ ├─dmesg.service
○ ├─e2scrub_reap.service
○ ├─landscape-client.service
○ ├─networkd-dispatcher.service
● ├─rsyslog.service
○ ├─snapd.apparmor.service
○ ├─snapd.autoimport.service
○ ├─snapd.core-fixup.service
○ ├─snapd.recovery-chooser-trigger.service
● ├─snapd.seeded.service
○ ├─snapd.service
● ├─systemd-ask-password-wall.path
● ├─systemd-logind.service
○ ├─systemd-update-utmp-runlevel.service
● ├─systemd-user-sessions.service
○ ├─ua-reboot-cmds.service
○ ├─ubuntu-advantage.service
● ├─unattended-upgrades.service
● ├─wsl-pro.service
```

### 5. User Sessions
**Command:** `who -a`
**Command:** `last -n 5`
**Output:**
```
egors@SHEOSK:~$ who -a
		   system boot  2025-09-29 21:00
		   run-level 5  2025-09-29 21:00
LOGIN      tty1         2025-09-29 21:00               221 id=tty1
LOGIN      console      2025-09-29 21:00               200 id=cons
egors    - pts/1        2025-09-29 21:00 00:07         474

egors@SHEOSK:~$ last -n 5
reboot   system boot  5.15.167.4-micro Mon Sep 29 21:00   still running
reboot   system boot  5.15.167.4-micro Tue Sep 23 23:24   still running
reboot   system boot  5.15.167.4-micro Wed Sep 10 22:12   still running
reboot   system boot  5.15.167.4-micro Wed Sep 10 22:02   still running
reboot   system boot  5.15.167.4-micro Wed Sep 10 22:01   still running

wtmp begins Fri Apr 18 18:35:53 2025
```
**Conclusions:**
The system booted recently (Sep 29, 21:00), and the only active user session is for 'egors' on pts/1. The last logins show only system reboots, with no other user logins recorded in the last five entries. This indicates minimal user activity and a stable system state.

### 6. Memory Analysis
**Command:** `free -h`
**Command:** `cat /proc/meminfo | grep -e MemTotal -e SwapTotal -e MemAvailable`
**Output:**
```
egors@SHEOSK:~$ free -h
			   total        used        free      shared  buff/cache   available
Mem:           7.4Gi       641Mi       6.5Gi       3.2Mi       494Mi       6.8Gi
Swap:          2.0Gi          0B       2.0Gi

egors@SHEOSK:~$ cat /proc/meminfo | grep -e MemTotal -e SwapTotal -e MemAvailable
MemTotal:        7795024 kB
MemAvailable:    7139768 kB
SwapTotal:       2097152 kB
```
**Memory usage assessment:**
The system has 7.4 GiB of RAM, with only 641 MiB used and 6.8 GiB available, indicating low memory usage. Swap space is 2.0 GiB, and none is currently used. The system is running efficiently with plenty of free and available memory.

---

## Task 2 — Network Analysis

### 1. Traceroute to github.com
**Command:** `traceroute github.com`
**Output:**
```
traceroute to github.com (140.82.121.4), 30 hops max, 60 byte packets
 1  172.23.176.1 (172.23.176.1)  0.167 ms  0.262 ms  0.249 ms
 2  10.240.16.1 (10.240.16.1)  3.869 ms  3.813 ms  3.800 ms
 3  10.250.0.2 (10.250.0.2)  3.712 ms  3.667 ms  3.655 ms
 4  10.252.6.1 (10.252.6.1)  3.718 ms  3.706 ms  3.694 ms
 5  1.123.18.84.in-addr.arpa (84.18.123.1)  17.177 ms  17.164 ms  17.376 ms
 6  178.176.191.24 (178.176.191.24)  10.520 ms  9.757 ms  9.710 ms
 ...
```
**Explanation:**
Traceroute shows the path packets take to reach github.com, passing through several routers and ISPs. Some hops are hidden ("*") due to firewalls or routers not responding to ICMP. IPs are sanitized as required.

### 2. DNS Lookup for github.com
**Command:** `dig github.com`
**Output:**
```
; <<>> DiG ... <<>> github.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 39424
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; QUESTION SECTION:
;github.com.                    IN      A

;; ANSWER SECTION:
github.com.             53      IN      A       140.82.121.4
```
**Explanation:**
The DNS query returns the A record for github.com, resolving to IP 140.82.121.4. The query was successful (NOERROR).

### 3. DNS Traffic Sniffing
**Command:** `sudo timeout 10 tcpdump -c 5 -i any 'port 53' -nn`
**Output:**
```
tcpdump: data link type LINUX_SLL2
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on any, link-type LINUX_SLL2 (Linux cooked v2), snapshot length 262144 bytes

0 packets captured
0 packets received by filter
0 packets dropped by kernel
```
**Explanation:**
No DNS packets were captured during the 10-second window. This may be due to low network activity or DNS queries not occurring at that time.

### 4. Reverse DNS Lookup
**Command:** `dig -x 8.8.4.4`
**Output:**
```
; <<>> DiG ... <<>> -x 8.8.4.4
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 31522
;; QUESTION SECTION:
;4.4.8.8.in-addr.arpa.          IN      PTR

;; ANSWER SECTION:
4.4.8.8.in-addr.arpa.   3752    IN      PTR     dns.google.
```
**Command:** `dig -x 1.1.2.2`
**Output:**
```
; <<>> DiG ... <<>> -x 1.1.2.2
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NXDOMAIN, id: 55296
;; QUESTION SECTION:
;2.2.1.1.in-addr.arpa.          IN      PTR

;; AUTHORITY SECTION:
1.in-addr.arpa.         1582    IN      SOA     ns.apnic.net. ...
```
**Explanation:**
Reverse DNS for 8.8.4.4 returns "dns.google.", confirming it is a Google DNS server. Reverse DNS for 1.1.2.2 returns NXDOMAIN, meaning there is no PTR record for this IP.
