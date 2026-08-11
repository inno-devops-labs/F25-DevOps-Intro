# Lab 4 — OS & Networking: Trace a Request, Debug a Deploy

**Author:** HNS ([@HNS2112](https://github.com/HNS2112))
**Date:** 6 August 2026
**Environment:** Ubuntu 24.04 (noble), Linux kernel with systemd-resolved, Go 1.26.5

Raw command output is committed under `evidence/lab4/`.

---

## Task 1 — Trace One Request End to End

### 1.1 Packet capture of a single POST

`tcpdump -i lo -w quicknotes.pcap 'tcp port 8080'` running while a single
`POST /notes` was issued. The capture contains the entire life of one TCP
connection in ten packets:

```console
18:50:14.556151 IP 127.0.0.1.52742 > 127.0.0.1.8080: Flags [S], seq 852912346, win 65495
18:50:14.556164 IP 127.0.0.1.8080 > 127.0.0.1.52742: Flags [S.], seq 3354113025, ack 852912347
18:50:14.556173 IP 127.0.0.1.52742 > 127.0.0.1.8080: Flags [.], ack 1
18:50:14.556203 IP 127.0.0.1.52742 > 127.0.0.1.8080: Flags [P.], length 175: HTTP: POST /notes HTTP/1.1
POST /notes HTTP/1.1
Host: localhost:8080
User-Agent: curl/8.5.0
Content-Type: application/json
Content-Length: 40
{"title":"lab4","body":"packet capture"}
18:50:14.556207 IP 127.0.0.1.8080 > 127.0.0.1.52742: Flags [.], ack 176
18:50:14.556662 IP 127.0.0.1.8080 > 127.0.0.1.52742: Flags [P.], length 207: HTTP: HTTP/1.1 201 Created
HTTP/1.1 201 Created
Content-Type: application/json
Content-Length: 94
{"id":6,"title":"lab4","body":"packet capture","created_at":"2026-08-06T15:50:14.556405793Z"}
18:50:14.556696 IP 127.0.0.1.52742 > 127.0.0.1.8080: Flags [.], ack 208
18:50:14.556827 IP 127.0.0.1.52742 > 127.0.0.1.8080: Flags [F.], seq 176
18:50:14.556994 IP 127.0.0.1.8080 > 127.0.0.1.52742: Flags [F.], seq 208
18:50:14.557066 IP 127.0.0.1.52742 > 127.0.0.1.8080: Flags [.], ack 209
```

Mapping the four required phases onto the packets:

| Phase | Packets | Flags |
|---|---|---|
| TCP three-way handshake | 1–3 | `[S]`, `[S.]`, `[.]` |
| HTTP request | 4 | `[P.]`, 175 bytes |
| HTTP response | 6 | `[P.]`, 207 bytes, `201 Created` |
| Connection teardown | 8–10 | `[F.]`, `[F.]`, `[.]` |

Timings worth noting: the handshake completed in 22 microseconds
(`.556151` → `.556173`) and the whole exchange in 915 microseconds. Nothing here
leaves the kernel — see §1.3 on why loopback numbers look like this.

The request and response each fit in a single segment. That is not luck; §1.3
explains why nothing needed fragmenting.

### 1.2 Diagnostic commands

```console
$ ss -tlnp sport = :8080
State  Recv-Q Send-Q Local Address:Port Peer Address:Port Process
LISTEN 0      4096               *:8080            *:*    users:(("quicknotes",pid=5201,fd=3))

$ ip -brief addr
lo               UNKNOWN        127.0.0.1/8
enp5s0           UP             192.168.0.123/24
wlx9ca2f49134b7  UP             192.168.0.120/24
virbr0           DOWN           192.168.122.1/24
virbr1           DOWN           192.168.100.1/24
docker0          DOWN           172.17.0.1/16
tun2             UNKNOWN        10.33.0.2/24

$ ip route | head -3
default via 192.168.0.1 dev enp5s0 proto dhcp src 192.168.0.123 metric 100
default via 192.168.0.1 dev wlx9ca2f49134b7 proto dhcp src 192.168.0.120 metric 600
127.0.0.0/8 dev lo proto kernel scope link src 127.0.0.1 metric 30

$ curl -s -o /dev/null -w "dns=%{time_namelookup} connect=%{time_connect} total=%{time_total}\n" \
    http://localhost:8080/health
dns=0.000031 connect=0.000240 total=0.000772
```

**The listener is bound to `*:8080`, not to loopback.** This machine has seven
interfaces including two with routable LAN addresses, so QuickNotes — which has
no authentication — is reachable from the local network, not just from this host.
The application reads its bind address from `ADDR`, so `ADDR=127.0.0.1:8080`
would restrict it. This is the same environment variable used to break the deploy
in Task 2, and worth remembering for the container work in Lab 6.

### 1.3 Path and transport properties

```console
$ mtr -rwc 5 localhost
HOST: hns       Loss%   Snt   Last   Avg  Best  Wrst StDev
  1.|-- localhost  0.0%     5    0.1   0.1   0.1   0.1   0.0

$ ip link show lo
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN

$ cat /proc/sys/net/ipv4/tcp_congestion_control
cubic

$ ss -tim state established dst 127.0.0.1
... cubic wscale:10,10 rto:201 rtt:0.256/0.421 mss:65483 pmtu:65535 cwnd:10
    send 20.5Gbps pacing_rate 40.9Gbps delivery_rate 105Gbps minrtt:0.005
```

Three things explain the microsecond timings in §1.1.

**MTU on `lo` is 65536**, against the 1500 typical of Ethernet. The negotiated
MSS is 65483 bytes, so the 175-byte request and 207-byte response fit in one
segment each with room to spare. There is nothing to fragment and no
path-MTU discovery to do.

**`qdisc noqueue`** — loopback has no queueing discipline at all. There is no
buffer to fill and therefore no queueing delay.

**`delivery_rate 105Gbps`** is not a network speed. It is the rate at which the
kernel copies between socket buffers in RAM; the packet never reaches a NIC
driver. `minrtt:0.005` — five microseconds — is the same fact from the latency
side.

The congestion control algorithm is `cubic`, and `cwnd:10` shows the connection
never left the initial window. On a link with no loss and no queueing, congestion
control has nothing to react to.

### 1.4 Name resolution — and a correction

```console
$ dig +short localhost
127.0.0.1

$ dig localhost | head -20
;; flags: qr aa rd ra ad; QUERY: 1, ANSWER: 1
localhost.		0	IN	A	127.0.0.1
;; Query time: 0 msec
;; SERVER: 127.0.0.53#53(127.0.0.53) (UDP)

$ getent hosts localhost
127.0.0.1       localhost
```

The expectation going in was that `dig localhost` would return nothing, on the
grounds that `localhost` is resolved from `/etc/hosts` rather than by DNS. That
turned out to be wrong on this system, and the reason is visible in the output:
`SERVER: 127.0.0.53#53` is `systemd-resolved`, which intercepts DNS on a loopback
stub address and synthesises an answer for `localhost` itself. The `aa` flag
marks it authoritative and `Query time: 0 msec` shows nothing left the machine.

So both paths work, but through different mechanisms: `getent` consults NSS
(`/etc/hosts` first, per `/etc/nsswitch.conf`), while `dig` speaks DNS to a local
stub resolver that answers from its own knowledge. `curl` uses the NSS path,
which is why `time_namelookup` was 31 microseconds.

The practical lesson is the one behind "it's never DNS": `dig` and the
application may not be asking the same question of the same resolver. Reproducing
a name-resolution problem with `dig` alone can mislead.

### 1.5 Connection refused vs. timeout

```console
$ curl -sv --max-time 3 http://localhost:9999/health
* Host localhost:9999 was resolved.
* IPv6: ::1
* IPv4: 127.0.0.1
*   Trying [::1]:9999...
* Immediate connect fail for ::1: Cannot assign requested address
*   Trying 127.0.0.1:9999...
* connect to 127.0.0.1 port 9999 from 127.0.0.1 port 58714 failed: Connection refused
* Failed to connect to localhost port 9999 after 0 ms

$ ss -tln sport = :9999
State Recv-Q Send-Q Local Address:Port Peer Address:Port
                                                          (empty)
```

The failure is immediate — "after 0 ms" — because nothing is on the wire. The
kernel knows no socket is listening on 9999 and answers the SYN with a RST
itself. `ss` confirms the port is unbound.

This is the diagnostic difference that matters in an incident. **Connection
refused means something answered and said no**: the host is up, the route works,
the process is down. **A timeout means nothing answered at all**: a firewall
dropping packets, a wrong route, a dead host, or a process too wedged to accept.
The two point at completely different parts of the stack, and confusing them
sends the investigation the wrong way.

The IPv6 attempt is a secondary detail worth noting: curl tried `::1` first and
failed differently — "cannot assign requested address" rather than "refused" —
because IPv6 is not configured on loopback here. Happy Eyeballs then fell back to
IPv4 with no measurable delay.

### 1.6 Latency under repeated requests

Twenty sequential `GET /health` calls, `connect` / `starttransfer` / `total`
in seconds:

```
0.000349 0.000828 0.000901     <- first
0.000365 0.000775 0.000841
0.000207 0.000502 0.000542
...
0.000091 0.000213 0.000233
0.000086 0.000181 0.000196     <- twentieth
```

The first request took 901 µs and the twentieth 196 µs — a 4.6× speedup with no
change to the code or the request. The warm-up is in the CPU caches, the
scheduler's picture of these two processes, and the Go runtime's own state.

This is why a single measurement of anything is untrustworthy, and it is the same
effect that produced the 18-second spread in the CI timings in Lab 3.

```console
$ ss -s
TCP:   49 (estab 10, closed 21, orphaned 0, timewait 21)
```

The 21 sockets in TIME_WAIT are the closed connections from this loop. TIME_WAIT
is the 2×MSL wait that lets late duplicate segments drain before the port pair
can be reused — the cost of the clean four-way teardown seen in §1.1.

---

## Task 2 — Debug a Broken Deploy

### 2.1 The break

A second instance was started while the first was still running:

```console
$ ADDR=:8080 go run .
2026/08/06 18:55:51 quicknotes listening on :8080 (notes loaded: 6)
2026/08/06 18:55:51 listen: listen tcp :8080: bind: address already in use
exit status 1
```

Note the ordering in the log: the application announced it was listening
*before* the bind failed. The message is emitted from the setup path, not from a
successful `Listen` call — so a log-scraping alert keyed on "listening on" would
have recorded a successful start for a process that died one line later.

### 2.2 Outside-in triage

**Step 1 — reproduce the symptom from the client's side.**

```console
$ curl -s http://localhost:8080/health
{"notes":6,"status":"ok"}
```

The service answers. This is the most important step in the whole exercise: from
outside, nothing is wrong. The old instance is serving happily. The failure is
not "the service is down" but "the deploy did not take" — a distinction invisible
to a health check.

**Step 2 — who owns the port.**

```console
$ ss -tlnp sport = :8080
LISTEN 0 4096 *:8080 *:* users:(("quicknotes",pid=5201,fd=3))
```

**Step 3 — identify the process.**

```console
$ ps -p 5201 -o pid,ppid,etime,cmd
    PID    PPID     ELAPSED CMD
   5201    5094       09:29 /tmp/go-build2908606575/b001/exe/quicknotes
```

`ELAPSED 09:29` settles it. The process holding the port has been running for
nine and a half minutes, so it is the *old* instance, not the one just launched.
`PPID 5094` is the `go run` that spawned it.

**Step 4 — where it came from.**

```console
$ ls -la /proc/5201/cwd
lrwxrwxrwx 1 hns hns 0 /proc/5201/cwd -> /home/hns/dev/DevOps-Intro/app
```

`/proc/<pid>/cwd` gives the working directory of a running process, which matters
here because QuickNotes resolves `DATA_PATH` and `SEED_PATH` relative to it.

### 2.3 The fix

```console
$ kill 5201
$ ss -tlnp sport = :8080
                                        (empty — port released)
```

The old instance logged `shutting down` rather than dying abruptly: it caught
SIGTERM and shut down gracefully. Restart:

```console
$ ss -tlnp sport = :8080
LISTEN 0 4096 *:8080 *:* users:(("quicknotes",pid=5820,fd=3))

$ curl -s http://localhost:8080/health
{"notes":6,"status":"ok"}
```

New PID, six notes intact — state survived because it lives in `data/notes.json`
on disk, not in the process.

### 2.4 Postmortem

**Summary.** A deploy of QuickNotes failed at 18:55:51 with
`bind: address already in use`. The previous instance kept serving traffic
throughout, so no user-visible outage occurred, but the new build was not running
for the six minutes until the conflict was noticed. Resolved at 18:57:51 by
stopping the old process and starting the new one; recovery took 53 seconds.

**Timeline.**

| Time | Event |
|---|---|
| 18:46:43 | instance A starts, 4 notes loaded |
| 18:55:51 | deploy attempted; instance B exits with bind error |
| 18:56:58 | instance A stopped (SIGTERM, graceful) |
| 18:57:51 | instance B starts, 6 notes loaded |

**What went wrong.** The deploy procedure starts the new process before stopping
the old one. Both bind the same port on the same host, and the second bind
necessarily fails. No data was lost and no request was dropped.

**Why it was hard to see.** Two things hid the failure. The health endpoint kept
returning 200, because the process answering it was alive — it was just the wrong
version. And the application logs `listening on :8080` before the bind succeeds,
so the last line before the crash reads like a successful start.

**What would prevent it, without blaming anyone.** The procedure, not the
operator, is at fault: any sequence that overlaps two processes on one port will
fail this way every time. Three changes address it at different levels. Stopping
the old instance before starting the new one removes the conflict outright — this
is what a systemd unit does by default and what `docker compose up` does when it
recreates a container. Binding the new instance to a different port and switching
traffic only after it reports healthy avoids the downtime the simple fix
introduces. And a deploy check that compares the running build to the intended
one — a version string on `/health`, or the PID's start time — would have
surfaced the problem in seconds instead of six minutes.

---

## Bonus Task — TLS Termination and Handshake Capture

### B.1 Setup

QuickNotes bound to `127.0.0.1:8080` with no TLS of its own; Caddy terminating
TLS on `:8443` and proxying to it.

`tls/Caddyfile`:

```
{
	auto_https disable_redirects
	admin off
}

localhost:8443 {
	tls internal
	reverse_proxy 127.0.0.1:8080
}
```

`tls internal` makes Caddy issue a certificate from its own local CA rather than
going to Let's Encrypt — the right choice for `localhost`, which no public CA
will ever certify. Caddy installs its root into the macOS keychain on first run:

```
WARN  pki.ca.local  installing root certificate (you might be prompted for password)
INFO  tls.obtain    certificate obtained successfully  {"identifier": "localhost", "issuer": "local"}
INFO  certificate installed properly in macOS keychain
```

It works end to end:

```console
$ curl -sk https://localhost:8443/health
{"notes":4,"status":"ok"}
```

### B.2 The handshake, packet by packet

Captured with `tshark -i lo0 -f "tcp port 8443"` around a single request.

```
 1  ::1 → ::1  TCP      59391 → 8443 [SYN]
 2  ::1 → ::1  TCP      8443 → 59391 [SYN, ACK]
 3  ::1 → ::1  TCP      59391 → 8443 [ACK]
 5  ::1 → ::1  TLSv1    Client Hello (SNI=localhost)
 7  ::1 → ::1  TLSv1.3  Server Hello, Change Cipher Spec, Application Data ×4
 9  ::1 → ::1  TLSv1.3  Change Cipher Spec
10  ::1 → ::1  TLSv1.3  Application Data
11  ::1 → ::1  TLSv1.3  Application Data
15  ::1 → ::1  TLSv1.3  Application Data
17  ::1 → ::1  TLSv1.3  Application Data
19  ::1 → ::1  TCP      59391 → 8443 [FIN, ACK]
```

The TCP three-way handshake of §1.1 is still there in packets 1–3 — TLS runs on
top of it, it does not replace it. The whole exchange took 31 milliseconds
against the 915 microseconds of the plaintext version in §1.1, and essentially
all of that difference is the handshake.

**ClientHello** (packet 5):

```
Version: TLS 1.2 (0x0303)                       ← legacy field
Server Name: localhost
supported_versions: 0x0304, 0x0303, 0x0302, 0x0301
Cipher Suites (49 suites):
  TLS_CHACHA20_POLY1305_SHA256 (0x1303)
  TLS_AES_256_GCM_SHA384       (0x1302)
  TLS_AES_128_GCM_SHA256       (0x1301)
  ... 46 more, down to TLS_RSA_WITH_AES_128_CBC_SHA
```

**ServerHello** (packet 7):

```
Version: TLS 1.2 (0x0303)                       ← legacy field
  [Expert Info: This legacy_version field MUST be ignored.
   The supported_versions extension is present and MUST be used instead.]
Extension: supported_versions — Supported Version: TLS 1.3 (0x0304)
Cipher Suite: TLS_CHACHA20_POLY1305_SHA256 (0x1303)
```

**Two things in that output are worth stopping on.**

The record layer claims TLS 1.2 on both sides while the connection is actually
TLS 1.3 — and Wireshark flags it as an expert note, not a bug. TLS 1.3 pins the
legacy version field at 1.2 and moves the real negotiation into the
`supported_versions` extension, specifically because middleboxes on the internet
were dropping handshakes that advertised a version they had never seen. The
protocol lies about its own version to get through hardware that predates it.

And the client offered 49 cipher suites spanning TLS 1.0 through 1.3 —
including `TLS_RSA_WITH_AES_128_CBC_SHA` and two GOST suites — while the server
picked `TLS_CHACHA20_POLY1305_SHA256`, one of the three TLS 1.3 suites. The
client's list is a compatibility net; the server's single choice is the actual
security posture. Reading a capture and seeing weak suites offered says nothing
by itself — what matters is which one came back.

### B.3 Plaintext versus ciphertext

Same application, same endpoint, two captures:

```
--- HTTP on :8080 (Task 1.1) ---
POST /notes HTTP/1.1
Content-Type: application/json
{"title":"lab4","body":"packet capture"}

--- HTTPS on :8443 (this task) ---
 10  TLSv1.3  134  Application Data
 11  TLSv1.3  181  Application Data
 15  TLSv1.3  281  Application Data
 17  TLSv1.3  100  Application Data
```

In §1.1 the request line, the headers and the JSON body were all readable
straight out of the capture. Here the same traffic is four opaque records.

What TLS does **not** hide is worth naming precisely, because it is visible in
the very capture above: the source and destination addresses, the port, the
timing and sizes of every record, and — in packet 5 — the SNI field carrying
`localhost` in cleartext. An observer learns who is talking to which host, when,
and roughly how much. They do not learn what was said. Encrypted Client Hello
exists to close the SNI gap and was not in play here.

### B.4 What this does and does not buy

The proxy pattern is worth stating plainly: **QuickNotes still speaks plain HTTP**
and knows nothing about TLS. Caddy decrypts at the edge and forwards cleartext
over loopback to `127.0.0.1:8080`, which is safe here only because that hop never
leaves the machine. In a real deployment the same arrangement across a network
segment would be a plaintext hop an attacker on that segment could read — the
thing service meshes and mTLS exist to close.

That separation is also what makes it practical. The application does not manage
certificates, renewals, cipher configuration or protocol versions; Caddy does,
and its defaults are current. Lab 6's image would need none of it, and Lab 10's
Render deployment got TLS for free from the platform for exactly the same reason
— someone else terminates it.

---

## Summary

| Task | Status |
|------|--------|
| Task 1 — packet capture, diagnostics, DNS, refused vs. timeout | Complete |
| Task 2 — broken deploy, outside-in triage, postmortem | Complete |
| Bonus — TLS proxy and handshake capture | Complete |
