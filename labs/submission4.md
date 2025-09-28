# Lab 4 Submission - Operating Systems & Networking

## Task 1 — Operating System Analysis

### 1.1: Boot Performance Analysis

#### System Boot Time  
Systemd-analyze is not available on macOS as it is Linux-specific, so I used equivalent commands available on macOS

```bash
# System information
system_profiler SPSoftwareDataType | grep "Boot Volume\|System Version\|Boot Mode":

    System Version: macOS 15.6.1 (24G90)
    Boot Volume: Macintosh HD
    Boot Mode: Normal

# Equivalent to systemd-analyze blame
launchctl list | head -10:

    PID     Status  Label
    44392   0       application.[SANITIZED].25249507.25249513
    -       0       com.apple.SafariHistoryServiceAgent
    86967   -9      com.apple.progressd
    14683   -9      com.apple.cloudphotod
    17472   -9      com.apple.MENotificationService
    589     0       com.apple.Finder
    729     0       com.apple.homed
    44922   -9      com.apple.dataaccess.dataaccessd
    -       0       com.apple.quicklook
```

#### Check System Load
```bash
# Check uptime
uptime:

    20:12  up 18 days, 22:12, 1 user, load averages: 4.75 5.10 5.20

# User info
w:

    20:13  up 18 days, 22:12, 1 user, load averages: 5.01 5.12 5.20
    USER       TTY      FROM    LOGIN@  IDLE WHAT
    ivanilicev console  -      07Sep25 18days -
```

#### Key Observations
- **System Uptime**: The system has been running for 18 days (without bugs) indicating excellent stability
- **Load Averages**: High load averages (4.75-5.20) suggest significant system activity, possibly due to resource-intensive applications
- **Boot Mode**: Normal boot mode indicates standard startup without recovery or safe mode
- **Service Status**: Multiple services are running with different status codes (0 = running, -9 = stopped)
- **User Activity**: Single user session with long idle time suggests the system is primarily used for development work

### 1.2: Process Forensics

#### Identifying Resource-Intensive Processes 
Use macOS-compatible process analysis commands

```bash
# Memory intensive processes
ps -eo pid,ppid,command,%mem,%cpu -m | head -n 6
    # I did not see column names, so I infered them
      PID  PPID COMMAND          %MEM  %CPU

    44392     1 /Applications/[APP1]  8.5 246.1
    29935     1 /Applications/[APP2]  3.3   0.0
      381     1 /System/Library/  2.7  39.6
    93695 93686 /Applications/[APP3]  2.5   4.8
    94644 29935 /Applications/[APP2]  1.4   0.0
    91385 29935 /Applications/[APP2]  1.2   7.0

# CPU intensive
ps -eo pid,ppid,command,%mem,%cpu | sort -k5 -nr | head -n 6:
    # I did not see column names, so I infered them
      PID  PPID COMMAND          %MEM  %CPU

    44392     1 /Applications/[APP1]  8.5 250.3
      381     1 /System/Library/  2.7  40.3
      548     1 /System/Library/  0.8   9.6
      339     1 /System/Library/  0.2   9.4
    91385 29935 /Applications/[APP2]  1.2   6.9
    97770 94669 head -n 6         0.0   0.0
```


#### Observations
- **Top Memory Consumer**: [APP1] application (PID 44392) consuming 8.5% memory and 250%+ CPU, indicating potential performance issues
- **System Processes**: Core system processes (PID 381, 548, 339) showing moderate CPU usage
- **Application Load**: Multiple instances of the same application ([APP2]) suggesting complex workflow or development environment
- **Process Hierarchy**: Clear parent-child relationships visible in PPID column, showing proper process management

### 1.3: Service Dependencies 

#### Map Service Relationships
```bash
# macOS uses launchd instead of systemd, so use it
launchctl list | head -10:

    PID     Status  Label
    44392   0       application.[SANITIZED].25249507.25249513
    -       0       com.apple.SafariHistoryServiceAgent
    86967   -9      com.apple.progressd
    14683   -9      com.apple.cloudphotod
    17472   -9      com.apple.MENotificationService
    589     0       com.apple.Finder
    729     0       com.apple.homed
    44922   -9      com.apple.dataaccess.dataaccessd
    -       0       com.apple.quicklook

launchctl print system:

    # I could not even see the beginning of the output...
                task-special ports = {
                              0x1e03 4       bootstrap  com.apple.xpc.launchd.domain.system
                              0x2303 9          access  com.apple.taskgated
            }
            attractive services = {
                    com.apple.MessagesBlastDoorService
                    com.apple.IDSBlastDoorService
            }
    
            disabled services = {
                    "com.apple.CSCSupportd" => disabled
                    "com.apple.mdmclient.daemon.runatboot" => disabled
                    "com.apple.ftpd" => disabled
                    "com.docker.socket" => enabled
                    "com.docker.vmnetd" => enabled
                    "postgresql-17" => enabled
            }
    
            properties = uncorked | audit check done | bootcache hack
    }
```

#### Observations

- **Service Status**: Mix of running (status 0) and stopped (-9) services indicates dynamic service management
- **Application Services**: Multiple application-specific services running ([APP1], [APP2], etc.)
- **System Services**: Core system services like Finder, homed, and dataaccessd are active
- **Disabled Services**: Several services are intentionally disabled for security/performance reasons


### 1.4: User Sessions

#### Audit Login Activity

Fortunately, user session analysis commands work in the same manner on macOS
```bash
who -a:

                     system boot  Sep  7 22:01 
    ivanilicev       console      Sep  7 22:01 
    ivanilicev       ttys011      Sep 11 14:10      term=0 exit=0
       .       run-level 3

last -n 5:

    ivanilicev ttys011                         Thu Sep 11 14:10 - 14:10  (00:00)
    ivanilicev console                         Sun Sep  7 22:01   still logged in
    reboot time                                Sun Sep  7 22:01
    ivanilicev ttys011                         Sat Sep  6 20:18 - 20:18  (00:00)
    ivanilicev ttys012                         Sat Sep  6 20:17 - 20:17  (00:00)
```

#### Observations

- **Login History**: System booted on September 7th with user login immediately after
- **Session Management**: Multiple terminal sessions (ttys011, ttys012) indicating active development work
- **Session Duration**: Very short session durations (00:00) suggest quick tasks or automated processes
- **Current Session**: User still logged in since September 7th
- **System Stability**: No unexpected reboots or crashes in the login history

### 1.5: Memory Analysis 

#### Inspect Memory Allocation
Again, `free -h` and `/proc/meminfo` are not available on macOS (Linux-specific). Instead I used macOS equivalent commands:

```bash
# Inspect memory allocation
vm_stat:
    Pages free:                               38937.
    Pages active:                            502069.
    Pages inactive:                          488300.
    Pages speculative:                        16185.
    Pages throttled:                              0.
    Pages wired down:                        220625.
    Pages purgeable:                          25452.
    "Translation faults":                2994163715.
    Pages copy-on-write:                   30889101.
    Pages zero filled:                   2547408130.
    Pages reactivated:                     35051776.
    Pages purged:                          14572574.
    File-backed pages:                       325537.
    Anonymous pages:                         681017.
    Pages stored in compressor:              660297.
    Pages occupied by compressor:            264477.
    Decompressions:                        17927564.
    Compressions:                          27786046.
    Pageins:                               12158257.
    Pageouts:                                250968.
    Swapins:                                      0.
    Swapouts:                                     0.

sysctl hw.memsize hw.physmem:

    hw.memsize: 25769803776
    hw.physmem: 3621502976

sysctl vm.swapusage:

    vm.swapusage: total = 0.00M  used = 0.00M  free = 0.00M  (encrypted)

top -l 1 | grep PhysMem:

    PhysMem: 23G used (3397M wired, 4124M compressor), 262M unused.

```

#### Observations

- **Memory Utilization**: System has 24GB total memory with only 262 MB available, indicating about 99% memory usage
- **Memory Pressure**: High memory usage suggests well distibution among processes
- **Swap Usage**: No swap usage (0.00M) indicates sufficient physical memory for current workload
- **Memory Compression**: 660,297 pages stored in compressor, showing macOS memory optimization
- **Page Activity**: High page fault activity (2.99 billion translation faults) indicates active memory management
- **Memory Distribution**: 23GB used with 4.1GB in compressor, showing efficient memory utilization

### Answer: "What is the top memory-consuming process?"

**Top Memory-Consuming Process**: [APP1] application (PID 44392) consuming 8.5% of system memory (approximately 2GB out of 24GB total). This is significantly higher than other processes and indicates either:
- Large media files or conversations being processed
- Memory leak or inefficient resource management
- Multiple active chat sessions with media content

### Resource Utilization Patterns Observed

Most of patterns are described above, but some more are as follows

#### Patterns
- **High Memory Usage**: 99% memory utilization indicates system is under memory pressure
- **CPU Spikes**: [APP1] showing 250%+ CPU usage suggests heavy multi-threading or inefficient processing
- **Load Averages**: Consistently high load averages (4-6) indicate sustained system activity
- **Process Distribution**: Mix of system and application processes with varying resource demands
- **Memory Compression**: Active use of memory compression to manage high memory usage

## Task 2 — Networking Analysis

### 2.1: Network Path Tracing

#### Traceroute Execution
```bash
traceroute github.com:

    traceroute to github.com (140.82.121.3), 64 hops max, 40 byte packets
     1  10.91.48.XXX (10.91.48.XXX)  3.965 ms  4.088 ms  3.820 ms
     2  10.252.6.XXX (10.252.6.XXX)  3.637 ms  3.686 ms  3.392 ms
     3  1.123.18.84.in-addr.arpa (84.18.123.1)  14.922 ms  15.032 ms  15.121 ms
     4  178.176.191.24 (178.176.191.24)  10.520 ms  11.299 ms  11.296 ms
     5  * * *
     6  * * *
     7  * * *
     8  * * *
     9  83.169.204.82 (83.169.204.82)  47.995 ms
        83.169.204.78 (83.169.204.78)  48.170 ms
        83.169.204.82 (83.169.204.82)  45.165 ms
     10  netnod-ix-ge-a-sth-1500.inter.link (194.68.123.180)  48.062 ms
         netnod-ix-ge-b-sth-1500.inter.link (194.68.128.180)  51.480 ms  47.330 ms
     11  * * *
     12  r3-ber1-de.as5405.net (94.103.180.2)  67.748 ms  69.475 ms  73.704 ms
     13  * * *
     14  * * *
     15  * * *
     16  * * *
     17  r1-fra3-de.as5405.net (94.103.180.24)  76.635 ms  69.160 ms  70.240 ms
     18  cust-sid436.fra3-de.as5405.net (45.153.82.37)  68.809 ms
         cust-sid435.r1-fra3-de.as5405.net (45.153.82.39)  62.251 ms
         cust-sid436.fra3-de.as5405.net (45.153.82.37)  63.535 ms
     19  * * *
     20  * * *
     ...
```

#### DNS Resolution Check
```bash
# DNS resolution check 
dig github.com:

    ; <<>> DiG 9.10.6 <<>> github.com
    ;; global options: +cmd
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 39448
    ;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

    ;; OPT PSEUDOSECTION:
    ; EDNS: version: 0, flags:; udp: 4096
    ;; QUESTION SECTION:
    ;github.com.                    IN      A

    ;; ANSWER SECTION:
    github.com.             25      IN      A       140.82.121.4

    ;; Query time: 4 msec
    ;; SERVER: 10.90.137.XXX#53(10.90.137.XXX)
    ;; WHEN: Fri Sep 26 20:57:45 MSK 2025
    ;; MSG SIZE  rcvd: 55

```

#### Network Path Insights

- **Network Path**: 20+ hops from local network to GitHub, indicating complex routing through multiple ISPs
- **Latency Pattern**: Initial hops show low latency (3-4ms), increasing to 40-70ms for international hops
- **Route Stability**: Consistent routing through European infrastructure (Germany)
- **Network Infrastructure**: Traversal through multiple network providers (AS5405, Netnod-IX)
- **Geographic Routing**: Path goes through Stockholm (Sweden) and Frankfurt (Germany) before reaching GitHub
- **Packet Loss**: Several hops showing asterisks (*) indicate potential network (security) filtering or ICMP blocking
- **Final Destination**: Successfully reaching GitHub infrastructure with reasonable latency

### 2.2: Packet Capture

#### Capture DNS Traffic

```bash
# DNS traffic capture (requires sudo on macOS)
sudo tcpdump -c 5 -i any 'port 53' -nn:

    tcpdump: data link type PKTAP
    tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
    listening on any, link-type PKTAP (Apple DLT_PKTAP), snapshot length 524288 bytes
    21:01:06.524635 IP 10.91.60.XXX.52960 > 10.90.137.XXX.53: 45508+ A? accounts.google.com. (37)
    21:01:06.524925 IP 10.91.60.XXX.19707 > 10.90.137.XXX.53: 47724+ Type65? accounts.google.com. (37)
    21:01:06.529207 IP 10.90.137.XXX.53 > 10.91.60.XXX.52960: 45508 1/0/0 A 64.233.165.84 (53)
    21:01:06.529210 IP 10.90.137.XXX.53 > 10.91.60.XXX.19707: 47724 0/1/0 (87)
    21:01:07.977208 IP 10.91.60.XXX.15431 > 10.90.137.XXX.53: 37964+ A? signaler-pa.clients6.google.com. (49)
    5 packets captured
    173 packets received by filter
    0 packets dropped by kernel
```

#### DNS Query/Response Patterns Analysis

- **DNS Server**: Using local DNS server (10.90.137.XXX) for resolution
- **Query Types**: Mix of A records and Type65 queries, indicating both standard and extended DNS usage
- **Response Time**: Fast DNS resolution indicating efficient local DNS infrastructure
- **Query Volume**: 173 packets received by filter shows active DNS traffic
- **Response Patterns**: Successful A record resolution for Google services

### 2.3: Reverse DNS

#### Perform PTR Lookups

```bash
dig -x 8.8.4.4:

    ; <<>> DiG 9.10.6 <<>> -x 8.8.4.4
    ;; global options: +cmd
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 19468
    ;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

    ;; OPT PSEUDOSECTION:
    ; EDNS: version: 0, flags:; udp: 4096
    ;; QUESTION SECTION:
    ;4.4.8.8.in-addr.arpa.          IN      PTR

    ;; ANSWER SECTION:
    4.4.8.8.in-addr.arpa.   5925    IN      PTR     dns.google.

    ;; Query time: 41 msec
    ;; SERVER: 10.90.137.XXX#53(10.90.137.XXX)
    ;; WHEN: Fri Sep 26 21:02:51 MSK 2025
    ;; MSG SIZE  rcvd: 73

dig -x 1.1.2.2:
    ; <<>> DiG 9.10.6 <<>> -x 1.1.2.2
    ;; global options: +cmd
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: NXDOMAIN, id: 17261
    ;; flags: qr rd ra; QUERY: 1, ANSWER: 0, AUTHORITY: 1, ADDITIONAL: 1

    ;; OPT PSEUDOSECTION:
    ; EDNS: version: 0, flags:; udp: 4096
    ;; QUESTION SECTION:
    ;2.2.1.1.in-addr.arpa.          IN      PTR

    ;; AUTHORITY SECTION:
    1.in-addr.arpa.         900     IN      SOA     ns.apnic.net. read-txt-record-of-zone-first-dns-admin.apnic.net. 22951 7200 1800 604800 3600

    ;; Query time: 29 msec
    ;; SERVER: 10.90.137.XXX#53(10.90.137.XXX)
    ;; WHEN: Fri Sep 26 21:03:56 MSK 2025
    ;; MSG SIZE  rcvd: 137
```

#### Reverse Lookup Results Comparison

- **Google DNS (8.8.4.4)**: Successfully resolved to dns.google, confirming Google's DNS infrastructure
- **Cloudflare DNS (1.1.2.2)**: NXDOMAIN response, indicating no reverse DNS record configured
- **Response Time**: Google DNS (41ms) vs Cloudflare DNS (29ms) showing slight performance difference
- **DNS Infrastructure**: Different DNS providers use different reverse DNS strategies
- **Security Implications**: Reverse DNS can reveal infrastructure details, hence some providers disable it


### One Example DNS Query from Packet Capture

#### Example DNS Transaction

```
21:01:06.524635 IP 10.91.60.XXX.52960 > 10.90.137.XXX.53: 45508+ A? accounts.google.com. (37)
21:01:06.529207 IP 10.90.137.XXX.53 > 10.91.60.XXX.52960: 45508 1/0/0 A 64.233.165.84 (53)
```

#### Analysis

- **Query Type**: A record request for accounts.google.com
- **Response**: Successful resolution to 64.233.165.84 (Google's IP)
- **Response Time**: ~4.5ms round-trip time
- **Packet Size**: 37 bytes query, 53 bytes response
- **Local DNS**: Using internal DNS server (10.90.137.XXX)

#### Security Considerations
- All IP addresses have been sanitized by replacing the last octet with XXX
- All sensitive process (application) names have been sanitized (replaced with [APP1], [APP2], [APP3], etc.)
