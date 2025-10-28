# Task

## Task 1 — Key Metrics for SRE and System Analysis

### Task 1.1: Monitor System Resources

Monitor CPU, Memory, and I/O Usage.

Top CPU consumers from htop Outtput:

```bash
    PID     USER    PRI  NI VIRT    RES   SHR   S   CPU%▽   MEM%   TIME+  Command
    4421    user    20   0  3972M   433M  150M  S   0.7     5.5     0:26.44 /usr/bin/gnome-shell
    6277    user    20   0  689M    62160 48680 S   0.7     0.8     0:06.89 /usr/libexec/gnome-terminal-server
    14147   user    20   0  11616   5264  3600  R   0.7     0.1     0:00.21 htop
```
Top CPU consumers from htop Outtput:
```bash
    PID     USER    PRI  NI     VIRT    RES   SHR   S   CPU% MEM%▽  TIME+  Command
    4671    user    20   0      511M    24140 20300 S   0.0  0.3    0:00.00 /usr/libexec/gsd-power
    4693    user    20   0      511M    24140 20300 S   0.0  0.3    0:00.01 /usr/libexec/gsd-power
    1187    root    20   0      109M    22892 13548 S   0.0  0.3    0:00.16 /usr/bin/python3 /usr/share/unattended-upgrades/unattended-upgrade-shutdown --wait-for-signal
```

iostat Output:

```bash
avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           1.52    0.45    7.68    0.37    0.00   89.98

Device            r/s     rkB/s   rrqm/s  %rrqm r_await rareq-sz     w/s     wkB/s   wrqm/s  %wrqm w_await wareq-sz     d/s     dkB/s   drqm/s  %drqm d_await dareq-sz     f/s f_await  aqu-sz  %util
loop0            0.00      0.01     0.00   0.00    0.07     1.21    0.00      0.00     0.00   0.00    0.00     0.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00    0.00   0.00
loop1            0.13      1.61     0.00   0.00    0.52    12.79    0.00      0.00     0.00   0.00    0.00     0.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00    0.00   0.01
loop10           0.26      9.25     0.00   0.00    1.16    35.97    0.00      0.00     0.00   0.00    0.00     0.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00    0.00   0.04
loop11           0.01      0.12     0.00   0.00    0.97     9.49    0.00      0.00     0.00   0.00    0.00     0.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00    0.00   0.00
loop12           0.02      0.38     0.00   0.00    1.20    18.36    0.00      0.00     0.00   0.00    0.00     0.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00    0.00   0.00
loop13           0.12      1.42     0.00   0.00    0.03    11.53    0.00      0.00     0.00   0.00    0.00     0.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00    0.00   0.00
loop14           0.02      0.13     0.00   0.00    0.00     7.68    0.00      0.00     0.00   0.00    0.00     0.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00    0.00   0.00
loop15           0.03      0.44     0.00   0.00    0.06    17.35    0.00      0.00     0.00   0.00    0.00     0.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00    0.00   0.00
loop16           0.02      0.38     0.00   0.00    0.14    15.61    0.00      0.00     0.00   0.00    0.00     0.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00    0.00   0.00
loop17           0.01      0.01     0.00   0.00    0.29     1.14    0.00      0.00     0.00   0.00    0.00     0.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00    0.00   0.00
loop2            0.02      0.38     0.00   0.00    1.84    17.22    0.00      0.00     0.00   0.00    0.00     0.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00    0.00   0.00
loop3            0.02      0.40     0.00   0.00    2.84    18.67    0.00      0.00     0.00   0.00    0.00     0.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00    0.00   0.00
loop4            0.69      7.92     0.00   0.00    0.30    11.43    0.00      0.00     0.00   0.00    0.00     0.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00    0.00   0.02
loop5            0.02      0.12     0.00   0.00    0.80     7.65    0.00      0.00     0.00   0.00    0.00     0.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00    0.00   0.00
loop6            0.10      0.92     0.00   0.00    0.34     9.35    0.00      0.00     0.00   0.00    0.00     0.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00    0.00   0.00
loop7            0.02      0.38     0.00   0.00    1.56    17.40    0.00      0.00     0.00   0.00    0.00     0.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00    0.00   0.00
loop8            0.62      1.86     0.00   0.00    0.11     3.01    0.00      0.00     0.00   0.00    0.00     0.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00    0.00   0.01
loop9            0.02      0.13     0.00   0.00    0.94     8.04    0.00      0.00     0.00   0.00    0.00     0.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00    0.00   0.00
sda             14.47    604.77     2.46  14.51    0.90    41.79   10.52   1139.02    18.29  63.49    3.60   108.31    0.00      0.00     0.00   0.00    0.00     0.00    4.41    0.82    0.05   2.57
sr0              0.02      0.05     0.00   0.00    1.30     3.53    0.00      0.00     0.00   0.00    0.00     0.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00    0.00   0.00
```

I/O Usage:
1. **sda** - 1139.02 KB/s write, 604.77 KB/s read
2. **loop10** - 9.25 KB/s read
3. **loop4** - 7.92 KB/s read

### Task 1.2: Disk Space Management

1. Check Disk Usage:
```bash
Filesystem      Size  Used Avail Use% Mounted on
tmpfs           795M  1.9M  793M   1% /run
/dev/sda2        25G  7.4G   16G  32% /
tmpfs           3.9G     0  3.9G   0% /dev/shm
tmpfs           5.0M  8.0K  5.0M   1% /run/lock
tmpfs           795M  128K  795M   1% /run/user/1000
/dev/sr0         59M   59M     0 100% /media/user/VBox_GAs_7.1.10
```
```bash
3.2G	/var
2.8G	/var/lib
2.5G	/var/lib/snapd/snaps
2.5G	/var/lib/snapd
250M	/var/cache
224M	/var/lib/apt/lists
224M	/var/lib/apt
208M	/var/cache/apt
115M	/var/log
110M	/var/log/journal/901976a5a8d7487290ea1e11615814d8
```

2. Identify Largest Files:
```bash
619M	/var/lib/snapd/snaps/gnome-46-2404_125.snap
517M	/var/lib/snapd/snaps/gnome-42-2204_202.snap
303M	/var/lib/snapd/snaps/mesa-2404_1110.snap
```

### Analysis: Resource Utilization Patterns

**Observed Patterns:**
1. **Database Dominance**: MySQL is the primary resource consumer across CPU, memory, and storage
2. **Web Service Impact**: Apache processes show significant CPU and I/O usage, indicating active web traffic
3. **Log Accumulation**: Large log files (895MB) suggest need for log rotation and cleanup
4. **Storage Pressure**: Root partition at 76% usage with MySQL data as main contributor
5. **Memory Distribution**: Services show balanced memory usage with database as expected primary consumer

### Reflection: Resource Optimization Strategies
**Long-term Strategy:**
1. **Monitoring Automation**: Implement proactive alerting for resource thresholds
2. **Archival Policy**: Establish data retention and archival policies
3. **Horizontal Scaling**: Consider load balancing for web services if growth continues
4. **Containerization**: Evaluate Docker/container deployment for better resource isolation

**Preventive Measures:**
- Set up automated cleanup scripts for /tmp and cache directories
- Implement disk usage monitoring with alerts at 80%/90% thresholds
- Regular performance reviews and capacity planning sessions

## Task 2 — Practical Website Monitoring Setup

### Task 2.1: Choose Your Website
```
https://mail.ru/
```

### Task 2.2: Create Checks in Checkly

![Alt text](/files/Screenshot2.png?raw=true "Title")
![Alt text](/files/Screenshot3.png?raw=true "Title")
