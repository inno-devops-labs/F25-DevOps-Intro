# Lab 4 — Operating Systems & Networking
## Task 1 — Operating System Analysis

### 1.1 Boot Performance Analysis
**Commands:**
```bash
systemd-analyze
systemd-analyze blame
uptime
w
```

## Output:
For systemd-analyze
```bash
Startup finished in 1.625s (userspace)
graphical.target reached after 1.619s in userspace
```

Top services by time (systemd-analyze blame):
```bash
1.236s snapd.seeded.service
1.144s snapd.service
176ms dev-sdd.device
131ms networkd-dispatcher.service
106ms systemd-resolved.service
61ms systemd-journal-flush.service
58ms systemd-udev-trigger.service
43ms systemd-logind.service
36ms snapd.socket
36ms systemd-udevd.service
35ms apport.service
33ms keyboard-setup.service
32ms e2scrub_reap.service
25ms systemd-journald.service
```
uptime:
``` bash
17:49:33 up 2 min, 1 user, load average: 0.88, 0.31, 0.11
```

w:
``` bash
 18:01:05 up 13 min,  1 user,  load average: 0.15, 0.11, 0.09
USER     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU WHAT
spectre  pts/1    -                17:48   12:49   0.00s  0.00s -bash
```

### Observations:
User space load time is ≈ 1.6 seconds—fast loading.

Major delays occur when using Snap (napd.seeded.service, snapd.service).

The system has recently loaded (uptime is ~2 minutes).

Average CPU load at the time of measurement is low (0.88/0.31/0.11).

### Process Forensics
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 6:
```bash
PID PPID CMD %MEM %CPU
851 539 [vscode-server] 10.5 16.4
539 535 [vscode-server] 1.8 15.3
920 539 [vscode-server] 0.9 0.8
330 227 [ubuntu-desktop-installer] 0.8 1.7
901 539 [vscode-server] 0.7 4.1
```

ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 6
```bash
PID PPID CMD %MEM %CPU
851 539 [vscode-server] 10.5 14.2
539 535 [vscode-server] 1.8 13.4
979 851 [vscode-server] 0.4 3.7
901 539 [vscode-server] 0.7 3.5
98 1 [snapfuse] 0.1 1.7
```

### Observations:
VS Code server processes (vscode-server) are the leaders in terms of memory and CPU usage.

From time to time, several vscode processes take up a significant share of resources (example: PID 851 — ~10.5% of memory).

Overall, other system processes do not appear in the top 5—the system is not overloaded with kernel services in terms of CPU and memory.

### 1.3 Service Dependencies
systemctl list-dependencies:
```bash
default.target
├─apport.service
├─display-manager.service
├─systemd-update-utmp-runlevel.service
├─wslg.service
└─multi-user.target (first lines)
```
systemctl list-dependencies multi-user.target:
```bash
multi-user.target
├─apport.service
├─console-setup.service
├─cron.service
├─dbus.service
│ ├─dmesg.service
│ ├─e2scrub_reap.service
│ └─irqbalance.service
├─networkd-dispatcher.service
├─plymouth-quit-wait.service
├─plymouth-quit.service
├─rsyslog.service
├─snap-bare-5.mount
├─snap-core22-2045.mount
├─snap-core22-2133.mount
├─... (далее много snap- и systemd-зависимостей)
├─systemd-logind.service
├─systemd-resolved.service
├─systemd-user-sessions.service
├─ufw.service
├─unattended-upgrades.service
└─basic.target
├─sysinit.target
└─timers.target
├─apt-daily.timer
├─logrotate.timer
└─systemd-tmpfiles-clean.timer (some lines)
```

### Observations:
The multi-user.target chain includes standard system services (cron, dbus, rsyslog)

## Task 2 - Networking Analysis
### 2.1 Network Interfaces
ip addr:
```bash
- lo (loopback) — 127.0.0.1/8, ::1/128  
- lo (extra) — 10.255.255.254/32  
- eth0 — 172.27.90.150/20, fe80::215:5dff:fe1a:7087/64
```
### Observations:
The main interface is **eth0** with IP 172.27.90.150. The loopback interface is used for local connections, with an additional service address 10.255.255.254.

### 2.2 Routing Table
ip route:
```bash
- Default gateway: 172.27.80.1 via eth0  
- Local network: 172.27.80.0/20 via eth0  
```

### Observations:
All external traffic is routed through 172.27.80.1. The local subnet 172.27.80.0/20 is accessible directly via eth0.

### 2.3 Active Connections
ss -tulpn | head -n 15
```bash
- UDP 127.0.0.53:53 (local DNS)  
- UDP 10.255.255.254:53 (service DNS)  
- UDP 127.0.0.1:323 (time service)  
- TCP 127.0.0.1:34599 — process node (pid=539)  
- TCP/UDP port 53 is used by local DNS services  
```
### Observations:
The system is running a local DNS resolver (systemd-resolved) and a **node.js** process on port 34599 (local access only)

### 2.4 DNS Configuration
cat /etc/resolv.conf
```bash
nameserver 10.255.255.254 
```

### Observations:
The DNS server is set to 10.255.255.254

### 2.5 Packet Statistics
netstat -i:
```bash
- eth0 — RX: 77060, TX: 15290, no errors  
- lo — RX/TX: 20292, no errors 
```
### Observations:
No errors or dropped packets were detected, the network is stable. The main traffic goes through eth0.
