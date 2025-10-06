# Virtualization & System Analysis
### VirtualBox Installation
- Host Operating System: **Ubuntu 24.04.2 LTS**
- Virtual Box **Version 7.2.0**

### System Information Discovery
1. **CPU Details**: valid CLI tools are `ls /proc/cpuinfo` and `lscpu` (more human-readable)
- Processor Model

![cpumodel](resources/5/image.png)

- Architecture

![cpuarch](resources/5/image-1.png)

- Cores

![cpucores](resources/5/image-5.png)

- Frequency

![cpufreq](resources/5/image-2.png)

2. **Memory Information**: `free -h`
- Total RAM

![ram](resources/5/image-6.png)
- Available RAM

![availableram](resources/5/image-7.png)

3. **Network Configuration**: `ip a`
- Interfaces + IP addresses

![interface1](resources/5/image-8.png)
![interface2](resources/5/image-9.png)

4. **Storage Information**: `df -hT`
- Disk usage + Filesystem details

![df](resources/5/image-10.png)

5. **Operating System**
- Ubuntu Version: `cat /etc/os-release`

![ubuntu](resources/5/image-11.png)
- Kernel Version: `uname -rv`

![kernel](resources/5/image-12.png)

6. **Virtualization Detection**: `systemd-detect-virt`

![virtualization](resources/5/image-13.png)

- Another method: `sudo dmidecode`

![dmidecode](resources/5/image-14.png)

### Most useful tools
- `uname -a` prints detailed information on kernel version
- `free -h` allows to discover total RAM and track system load
- `ip a` is a quick way of checking internet interfaces and IP addresses