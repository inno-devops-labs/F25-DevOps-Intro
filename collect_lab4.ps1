$ErrorActionPreference = "Stop"

$OutFile = "labs\submission4.md"
$null = New-Item -ItemType Directory -Path "labs" -Force

function Mask-IPs([string]$s) {
    # Mask last IPv4 octet -> XXX
    return ($s -replace '(\d{1,3}\.\d{1,3}\.\d{1,3}\.)\d{1,3}', '$1XXX')
}

function Append([string]$text) {
    (Mask-IPs $text) | Out-File -FilePath $OutFile -Encoding UTF8 -Append
}

# Try to locate tshark
$TsharkCmd = (Get-Command tshark -ErrorAction SilentlyContinue)
if (-not $TsharkCmd) {
    $pf = ${env:ProgramFiles}
    $cand = Join-Path $pf "Wireshark\tshark.exe"
    if (Test-Path $cand) { $TsharkCmd = $cand }
}

# Header
"# Lab 4 - Operating Systems and Networking: Submission (Windows)" | Out-File $OutFile -Encoding UTF8
Append "`nAuto-generated: $(Get-Date -Format s)"
Append "`nNote: IPv4 addresses are sanitized (last octet -> XXX).`n"

############################
# Task 1 - OS Analysis
############################
Append "## Task 1 - Operating System Analysis"

# Boot & Session Overview
Append "### 1.1 Boot and Session Overview"
try {
    $os = Get-CimInstance Win32_OperatingSystem
    Append "#### Last boot time"
    Append "$($os.LastBootUpTime)"
} catch { Append "Get-CimInstance failed: $($_.Exception.Message)" }

Append "`n#### Uptime"
try {
    $up = Get-CimInstance Win32_PerfFormattedData_PerfOS_System | Select-Object SystemUpTime | Format-List | Out-String
    Append $up
} catch { Append "N/A" }

Append "`n#### Logged-on users (query user)"
try { Append ((quser 2>&1) | Out-String) } catch { Append "N/A" }

# Process Forensics
Append "`n### 1.2 Process Forensics"
Append "#### Top by WorkingSet (MEM)"
try {
    $p = Get-Process | Sort-Object -Descending -Property WS | Select-Object -First 6 Id,ProcessName,CPU,WS | Format-Table | Out-String
    Append $p
} catch { Append "N/A" }

Append "`n#### Top by CPU (cumulative)"
try {
    $p = Get-Process | Sort-Object -Descending -Property CPU | Select-Object -First 6 Id,ProcessName,CPU,WS | Format-Table | Out-String
    Append $p
} catch { Append "N/A" }

# Running Services
Append "`n### 1.3 Running Services"
try {
    $svc = Get-Service | Where-Object {$_.Status -eq 'Running'} | Select-Object -First 60 Status,Name,DisplayName | Format-Table | Out-String
    Append $svc
} catch { Append "N/A" }

# Memory
Append "`n### 1.4 Memory Summary"
try {
    $mem = Get-CimInstance Win32_OperatingSystem
    $totalGB = [Math]::Round($mem.TotalVisibleMemorySize/1MB,2)
    $freeGB  = [Math]::Round($mem.FreePhysicalMemory/1MB,2)
    Append ("Total RAM (GB): {0}" -f $totalGB)
    Append ("Free  RAM (GB): {0}" -f $freeGB)
} catch { Append "N/A" }

Append @"
#### Answers / Observations (Task 1)
- Top memory-consuming process: <fill here>
- Patterns: <boot delays, CPU spikes, heavy services>
"@


Append "`n## Task 2 - Networking Analysis"

#Traceroute & DNS
Append "### 2.1 Network Path Tracing"
Append "#### tracert github.com"
try { Append ((tracert -d github.com 2>&1) | Out-String) } catch { Append "N/A" }

Append "`n#### nslookup github.com"
try { Append ((nslookup github.com 2>&1) | Out-String) } catch { Append "N/A" }

# Packet Capture DNS
Append "`n### 2.2 Packet Capture (DNS, tshark)"
if ($TsharkCmd) {
    try {
        $cap = & $TsharkCmd -a duration:10 -f "port 53" -c 5 -n 2>&1
        Append ($cap | Out-String)
    } catch {
        Append "tshark failed: $($_.Exception.Message)"
    }
} else {
    Append "tshark not found. Install Wireshark or capture in GUI and paste a couple of sanitized lines."
}

# Reverse DNS
Append "`n### 2.3 Reverse DNS"
Append "#### nslookup 8.8.4.4"
try { Append ((nslookup 8.8.4.4 2>&1) | Out-String) } catch { Append "N/A" }
Append "`n#### nslookup 1.1.2.2"
try { Append ((nslookup 1.1.2.2 2>&1) | Out-String) } catch { Append "N/A" }

Append @"
#### Insights (Task 2)
- Traceroute path: <ISP hops, latency trend>
- DNS records: <A/AAAA/CNAME/NS summary>
- Packet sample (sanitized):
"@
