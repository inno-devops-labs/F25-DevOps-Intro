# Lab 4 — OS & Networking: Trace, Debug, and Read the Substrate

- Student: Arina Nikolaeva (Nik-ari-ai)
- Fork: https://github.com/Nik-ari-ai/DevOps-Intro
- Branch: feature/lab4
- Environment: Ubuntu 24.04 (Linux) — the lab's tooling (`ss`, `ip`, `tcpdump -i lo`, `iptables`, `journalctl`) is Linux-specific, so I ran it on a Linux host rather than macOS.

## Task 1 — Trace a Request End-to-End

### 1.1 / 1.2 Packet capture of one `POST /notes`

Captured 10 packets on `lo` for `tcp port 8080` while firing one `curl -v POST /notes`. Annotated trace:

```
# --- TCP three-way handshake ---
127.0.0.1.32772 > 127.0.0.1.8080: Flags [S],  seq 1881556903            # SYN
127.0.0.1.8080  > 127.0.0.1.32772: Flags [S.], seq 1467844725, ack ...  # SYN/ACK
127.0.0.1.32772 > 127.0.0.1.8080: Flags [.],  ack 1                     # ACK  (handshake done)

# --- HTTP request (client -> server), 174 bytes ---
127.0.0.1.32772 > 127.0.0.1.8080: Flags [P.], seq 1:175   HTTP: POST /notes HTTP/1.1
    POST /notes HTTP/1.1
    Host: localhost:8080
    Content-Type: application/json
    Content-Length: 39
    {"title":"trace me","body":"in flight"}
127.0.0.1.8080  > 127.0.0.1.32772: Flags [.], ack 175                   # server ACKs request

# --- HTTP response (server -> client), 206 bytes ---
127.0.0.1.8080  > 127.0.0.1.32772: Flags [P.], seq 1:207  HTTP: HTTP/1.1 201 Created
    HTTP/1.1 201 Created
    Content-Type: application/json
    Content-Length: 93
    {"id":5,"title":"trace me","body":"in flight","created_at":"2026-09-10T21:09:55.151264629Z"}
127.0.0.1.32772 > 127.0.0.1.8080: Flags [.], ack 207                    # client ACKs response

# --- connection close (graceful FIN both ways) ---
127.0.0.1.32772 > 127.0.0.1.8080: Flags [F.], seq 175                   # client FIN
127.0.0.1.8080  > 127.0.0.1.32772: Flags [F.], seq 207, ack 176        # server FIN
127.0.0.1.32772 > 127.0.0.1.8080: Flags [.], ack 208                    # final ACK
```

`curl -v` view of the same exchange:

```
> POST /notes HTTP/1.1
> Host: localhost:8080
> Content-Type: application/json
> Content-Length: 39
< HTTP/1.1 201 Created
< Content-Type: application/json
< Content-Length: 93
{"id":5,"title":"trace me","body":"in flight","created_at":"2026-09-10T21:09:55.151264629Z"}
```

### 1.3 Five debugging commands

```
### 1. ss -tlnp | grep :8080   — what's listening?
LISTEN 0 4096 0.0.0.0:8080 0.0.0.0:* users:(("quicknotes",pid=2613,fd=3))

### 2. ip route show           — routes from the host
default via 192.0.2.1 dev eth0
192.0.2.0/24 dev eth0 proto kernel scope link src 192.0.2.2

### 3. mtr -rwc 5 localhost    — reachability on lo
HOST: vm   Loss%  Snt  Last  Avg  Best  Wrst StDev
  1.|-- localhost  0.0%   5   0.0  0.2   0.0   0.6  0.2

### 4. dig +short example.com @1.1.1.1  — DNS works
172.66.147.243
104.20.23.154

### 5. journalctl --user -u quicknotes -n 20  — service logs
No journal files were found.
-- No entries --
```

Reading: (1) `quicknotes` owns `0.0.0.0:8080`; (2) one default route via `eth0`; (3) loopback is 0% loss, sub-millisecond; (4) recursive DNS resolves through 1.1.1.1; (5) no journal entries because QuickNotes runs as a plain process here, not a systemd unit — so stdout, not `journalctl`, is where its logs are.

### 1.4 What would I check first on a 502?

A `502 Bad Gateway` means a proxy in front of QuickNotes got no valid response from it, so I'd debug from the proxy inward rather than from the browser. First, is the app process even up and bound — `ps -ef | grep quicknotes` and `ss -tlnp | grep 8080`; a crashed or unbound backend is the most common 502. If it is listening, I'd hit the app directly, bypassing the proxy: `curl -s -o /dev/null -w '%{http_code}' localhost:8080/health`. A `200` there means the fault is the proxy's upstream config or the network path between proxy and app; a refused connection or `5xx` means the app itself, so I'd read its logs (stdout / `journalctl`) for a panic or a slow handler, and the proxy's error log for the exact upstream address and timeout it used.

## Task 2 — Outside-In Debugging on a Broken Deploy

### 2.1 The broken instance

Started a second QuickNotes on `:8080` while the first still held it:

```
2026/09/10 21:10:50 quicknotes listening on :8080 (notes loaded: 5)
2026/09/10 21:10:50 listen: listen tcp :8080: bind: address already in use
```

The process exits non-zero (`Exit 1`). Root cause: **`bind: address already in use`** — the port is already owned by another listener.

### 2.2 Outside-in chain (command + output + decision)

```
1) is a process running?      ps -ef | grep -w quicknotes
   root 2613 1 ... ./quicknotes          -> yes, one instance (pid 2613) is up
2) is it listening on 8080?   ss -tlnp | grep :8080
   LISTEN 0.0.0.0:8080 users:(("quicknotes",pid=2613))  -> yes, pid 2613 holds the port
3) reachable from host?       curl -s -o /dev/null -w "%{http_code}" localhost:8080/health
   200                                    -> the running instance serves fine
4) firewall blocking?         iptables -L -n -v
   Chain INPUT/FORWARD/OUTPUT policy ACCEPT, no rules  -> not a firewall issue
5) DNS for localhost?         dig +short localhost / getent hosts localhost
   127.0.0.1  localhost                   -> name resolution is fine
```

Decision at each step: the service itself is healthy (running, listening, HTTP 200, no firewall, DNS fine). The failure is not connectivity — it is that the **port was already bound**, so the second deploy could never start. The chain rules out the network/firewall/DNS layers and points squarely at the port conflict from 2.1.

### 2.3 Repair + re-verify

```
before:  LISTEN 0.0.0.0:8080 users:(("quicknotes",pid=2613))
kill 2613
after:   8080 free
restart: quicknotes listening on :8080 (notes loaded: 5)   (new pid 2704)
health:  {"notes": 5, "status": "ok"}
```

Freeing the port (killing the stale process) and starting one clean instance restores service.

### 2.4 Blameless mini-postmortem

**What happened.** A second QuickNotes instance was started while the first still held `:8080`; the new process logged `listen tcp :8080: bind: address already in use` and exited, so the intended deploy never came up. The running instance kept serving, which masked the failed start.

**Why it is systemic, not personal.** No operator mistake is required — two processes competing for one address/port is how the OS allocates listening sockets: one bound listener per address/port. Any deploy that starts the new version before the old one releases the port hits this, especially on a single host with no orchestrator to serialize it.

**What would prevent it.** A process manager (systemd, a container runtime, an orchestrator) that treats the service as one unit and stops the old instance before starting the new one removes the race. A readiness check gates traffic until the new instance is actually listening. Tests should bind to a config-driven port (or `:0`) to avoid collisions, and a preflight `ss -tlnp | grep :8080` in the deploy script turns a silent crash into an early, readable failure.

## Bonus — Decode the TLS Handshake

Put a TLS-terminating reverse proxy (self-signed cert, `CN=localhost`) in front of QuickNotes: `:8443` (TLS) → `:8080` (plain HTTP). Captured the handshake on `lo` (`lab4-tls.pcap`, 23 packets); `curl -vk https://localhost:8443/health` returned the QuickNotes health JSON over TLS.

`curl -v` summary:

```
* SSL connection using TLSv1.3 / TLS_AES_128_GCM_SHA256 / X25519 / RSASSA-PSS
* ALPN: server accepted h2
*  subject: CN=localhost
*  issuer: CN=localhost
*  SSL certificate verify result: self-signed certificate (18), continuing anyway.
```

### ClientHello (tshark decode)

```
Server Name (SNI): localhost
Supported Versions: TLS 1.3 (0x0304), TLS 1.2 (0x0303)   # note: no TLS 1.0/1.1 offered
legacy record version:    TLS 1.0 (0x0301)               # frozen for middlebox compatibility
legacy handshake version: TLS 1.2 (0x0303)               # frozen for middlebox compatibility
Cipher suites offered (excerpt):
  TLS_AES_256_GCM_SHA384 (0x1302)
  TLS_CHACHA20_POLY1305_SHA256 (0x1303)
  TLS_AES_128_GCM_SHA256 (0x1301)
  ... plus many ECDHE/DHE/RSA TLS 1.2 suites ...
```

### ServerHello (tshark decode)

```
legacy_version field:  TLS 1.2 (0x0303)                  # frozen for compatibility
Supported Versions ext: TLS 1.3 (0x0304)                 # the REAL negotiated version
Cipher Suite chosen:    TLS_AES_128_GCM_SHA256 (0x1301)
```

### Certificate chain (`openssl s_client`)

```
subject=CN = localhost
issuer=CN = localhost
New, TLSv1.3, Cipher is TLS_AES_128_GCM_SHA256
Verify return code: 18 (self-signed certificate)
```

### Which negotiation step kills TLS 1.0 / 1.1 in 2026?

**Version negotiation via the `supported_versions` extension.** In TLS 1.3 the record-layer and handshake `legacy_version` bytes are frozen at 1.0 / 1.2 for middlebox compatibility and no longer carry the real version — you can see them say "TLS 1.0" and "TLS 1.2" in the capture even though the connection is 1.3. The actual version is chosen by the `supported_versions` extension: the ClientHello lists only 1.3 and 1.2, and the ServerHello returns 1.3. A modern client never puts 1.0/1.1 in that extension and a modern server never selects them, so 1.0/1.1 are excluded at the `supported_versions` step regardless of what the legacy version fields show.
