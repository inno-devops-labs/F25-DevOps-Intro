# Lab 4 Submission - Operating Systems & Networking

## Task 1 — Operating System Analysis

### 1.1: Boot Performance Analysis

#### System Boot Time Analysis

**Note:** Running on macOS (Darwin), systemd commands not available. Using macOS equivalents.

**Command:** `system_profiler SPSoftwareDataType | grep "Boot Volume\|System Version\|Time since boot"`
```
System Version: macOS 15.6.1 (24G90)
Boot Volume: Macintosh HD
Time since boot: 16 days, 7 hours
```

**Analysis:** System has been running for 16 days without restart, indicating stable operation.

#### System Load Check

**Command:** `uptime`
```
0:59  up 16 days, 7 hrs, 1 user, load averages: 5.31 4.67 4.10
```

**Command:** `w`
```
0:59  up 16 days, 7 hrs, 1 user, load averages: 5.21 4.66 4.10
USER       TTY      FROM    LOGIN@  IDLE WHAT
theother_a console  -      21Sep25 16days -
```

**Analysis:** High load averages (5.31, 4.67, 4.10) indicate system under heavy load. Single user logged in via console since September 21st.

### 1.2: Process Forensics

#### Memory-Intensive Processes

**Command:** `ps -eo pid,ppid,comm,%mem,%cpu | sort -k4 -nr | head -n 6`
```
45156     1 /Applications/Te  5.2  14.6
45462 45451 /Applications/Cu  4.2  37.9
  803     1 /Applications/Go  2.2   0.3
51819   803 /Applications/Go  1.8   0.0
51764   803 /Applications/Go  1.5   1.5
45099   803 /Applications/Go  1.5   0.1
```

#### CPU-Intensive Processes

**Command:** `ps -eo pid,ppid,comm,%mem,%cpu | sort -k5 -nr | head -n 6`
```
45462 45451 /Applications/Cu  4.2 191.9
30819     1 /System/Library/  0.3  65.2
  168     1 /System/Library/  1.4  46.1
45459 45451 /Applications/Cu  0.6  38.9
45156     1 /Applications/Te  5.2  17.7
  805     1 /System/Library/  0.5   7.3
```

**Analysis:** 
- Top memory consumer: Process 45156 (Application) using 5.2% memory
- Top CPU consumer: Process 45462 (Application) using 191.9% CPU (multi-core usage)
- Several system processes and applications are actively running

### 1.3: Service Dependencies

#### System Dependencies

**Note:** macOS uses launchd instead of systemd. Using launchctl to list services.

**Command:** `launchctl list | head -10`
```
PID	Status	Label
-	0	com.apple.SafariHistoryServiceAgent
-	-9	com.apple.progressd
-	-9	com.apple.cloudphotod
65769	-9	com.apple.MENotificationService
869	0	com.apple.Finder
83519	-9	com.apple.homed
73669	-9	com.apple.dataaccess.dataaccessd
-	0	com.apple.quicklook
-	0	com.apple.parentalcontrols.check
```

#### Apple System Services

**Command:** `launchctl list | grep -E "com.apple" | head -8`
```
-	0	com.apple.SafariHistoryServiceAgent
-	-9	com.apple.progressd
-	-9	com.apple.cloudphotod
65769	-9	com.apple.MENotificationService
869	0	com.apple.Finder
83519	-9	com.apple.homed
73669	-9	com.apple.dataaccess.dataaccessd
-	0	com.apple.quicklook
```

**Analysis:** 
- Status -9 indicates services that have exited
- Status 0 indicates successfully running services
- PID shows process ID for running services
- Various Apple system services are managed by launchd

### 1.4: User Sessions

#### Current Login Activity

**Command:** `who -a`
```
[Output will be added here]
```

#### Recent Login History

**Command:** `last -n 5`
```
[Output will be added here]
```

### 1.5: Memory Analysis

#### Memory Allocation Overview

**Command:** `free -h`
```
[Output will be added here]
```

#### Detailed Memory Information

**Command:** `cat /proc/meminfo | grep -e MemTotal -e SwapTotal -e MemAvailable`
```
[Output will be added here]
```

## Task 2 — Networking Analysis

### 2.1: Network Path Tracing

#### Traceroute to GitHub

**Command:** `traceroute github.com`
```
[Output will be added here]
```

#### DNS Resolution Check

**Command:** `dig github.com`
```
[Output will be added here]
```

### 2.2: Packet Capture

#### DNS Traffic Capture

**Command:** `sudo timeout 10 tcpdump -c 5 -i any 'port 53' -nn`
```
[Output will be added here]
```

### 2.3: Reverse DNS

#### PTR Lookup for 8.8.4.4

**Command:** `dig -x 8.8.4.4`
```
[Output will be added here]
```

#### PTR Lookup for 1.1.2.2

**Command:** `dig -x 1.1.2.2`
```
[Output will be added here]
```

## Analysis and Observations

### Key Findings

- **Top Memory-Consuming Process:** [To be determined]
- **Boot Performance:** [To be analyzed]
- **Network Path Insights:** [To be documented]
- **DNS Patterns:** [To be analyzed]

### Resource Utilization Patterns

[Analysis will be added after collecting all data]

### Security Considerations

All sensitive information has been sanitized according to security best practices:
- IP addresses have last octet replaced with XXX where appropriate
- Sensitive process names have been generalized
- Internal network topology details have been omitted
