# Lab 5 — Virtualization & System Analysis

## Task 1 — VirtualBox Installation (5 pts)

### 1.1: Install VirtualBox

**Installation:**
- Downloaded and installed VirtualBox with default settings
- VirtualBox launches successfully
- Version: **7.2.2**

**System Info:**
- Host OS: Windows 11 Home 24H2

**Issues:**
- No installation issues encountered

<img width="802" height="672" alt="image" src="https://github.com/user-attachments/assets/0cb5efac-97f7-4438-9edb-e062aab08efe" />

---

### Task 2 — Ubuntu VM and System Analysis (5 pts)

#### 2.1: Create Ubuntu VM

# Lab 5 — Virtualization & System Analysis

## Task 2 — Ubuntu VM Deployment

### 2.1: Create Ubuntu VM

- Downloaded `ubuntu-24.04.3-desktop-amd64.iso` from official Ubuntu website

**VM Configuration:**
- **Name:** lab456
- **OS:** Ubuntu (64-bit)
- **RAM:** 8192 MB
- **CPU:** 12 cores
- **Storage:** 32.00 GB
- **Graphics:** VBoxSVGA (128 MB)

<img width="1147" height="864" alt="image" src="https://github.com/user-attachments/assets/c1722c7c-6c87-4ab1-94da-ca0661420946" />

#### 2.2: System Information Discovery

 - **CPU Details**: Processor model, architecture, cores, frequency

```
lscpu
```

<img width="494" height="718" alt="image" src="https://github.com/user-attachments/assets/8b224c46-eb4b-4811-a3e3-59e3c0b89f0a" />

**Required Parameters:**
✅ Processor Model: 12th Gen Intel(R) Core(TM) i7-12780H
✅ Architecture: x86_64
✅ Cores: 12 cores (1 thread per core)

**For frequency:**

```
cat /proc/cpuinfo
```

<img width="1311" height="645" alt="image" src="https://github.com/user-attachments/assets/470ebeb1-e6ac-4923-83f1-1d454b2d3e6c" />

Frequency Found:

✅cpu MHz : 2687.994

---

   - **Memory Information**: Total RAM, available memory

```
free -h
```

<img width="818" height="92" alt="image" src="https://github.com/user-attachments/assets/beccc9b4-1743-4eac-85b4-2eca81a80dda" />

**Required Parameters:**
- ✅ **Total RAM:** 7.8 GiB
- ✅ **Available Memory:** 6.6 GiB

---
   - **Network Configuration**: IP addresses, network interfaces

```
ip addr
```

<img width="1029" height="384" alt="image" src="https://github.com/user-attachments/assets/c4b5e5a1-6368-47f1-a7ac-7cee61a232fa" />

OR

```
sudo apt install net-tools
ifconfig
```

<img width="895" height="450" alt="image" src="https://github.com/user-attachments/assets/cc5cf2df-2ed8-41a9-bb73-de54e48f7fb8" />

Both commands show **Required Parameters:**
- ✅ IP Addresses: 10.0.2.15 (IPv4), multiple IPv6 addresses
- ✅ Network Interfaces: lo, enp0s3

---
   - **Storage Information**: Disk usage, filesystem details

```
df -h
```

<img width="767" height="629" alt="image" src="https://github.com/user-attachments/assets/380648d5-fad0-4e10-b1c2-dd9ac94151f6" />

**Storage Analysis:**
- `df -h` - Disk usage and filesystem capacity
- `lsblk` - Partition hierarchy and device mapping
- **Finding:** 32GB disk with 23% usage, proper filesystem structure

---
   - **Operating System**: Ubuntu version, kernel information

```
lsb_release -a
```

<img width="1271" height="173" alt="image" src="https://github.com/user-attachments/assets/26bc1102-c697-477c-a595-428c570d62ae" />

**OS Analysis:**
- `lsb_release -a` - Ubuntu distribution details
- `uname -a` - Kernel version and architecture
- **Finding:** Ubuntu 24.04 LTS with Linux kernel 6.8.0-31

---
   - **Virtualization Detection**: Confirmation system is running in a VM

```
systemd-detect-virt
```

<img width="447" height="49" alt="image" src="https://github.com/user-attachments/assets/bb0d4fdb-63a8-4d0d-9e98-bb601955749e" />

**Virtualization Detection:**
- `systemd-detect-virt` - Direct virtualization identification
- **Finding:** Confirmed Oracle VirtualBox environment

---
