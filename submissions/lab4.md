# Lab 4 — Task 1: Trace a Request End-to-End

## 1.1–1.2: Packet capture

Captured with:

```
sudo tcpdump -i lo -nn -s 0 -A 'tcp port 8080' -w lab4-trace.pcap
```

then decoded with:

```
sudo tcpdump -r lab4-trace.pcap -nn -A
```

Full output is in `lab4-trace.txt`. Note: on this WSL2 host, `curl` resolved
`localhost` to `::1` first, so the whole exchange happened over IPv6 loopback
rather than IPv4 — worth flagging since the lab example assumes IPv4.

Annotated highlights (11 packets total):

- **Three-way handshake** (packets 1–3):
  - `Flags [S]` — client SYN, seq 508343417
  - `Flags [S.]` — server SYN/ACK, seq 2553355680, ack 508343418
  - `Flags [.]` — client ACK, ack 1
- **HTTP request** (packet 4): `POST /notes HTTP/1.1` with headers
  (`Host`, `User-Agent: curl/8.18.0`, `Content-Type: application/json`,
  `Content-Length: 39`) and body `{"title":"trace me","body":"in flight"}`
- **HTTP response** (packet 6): `HTTP/1.1 201 Created` with
  `Content-Type: application/json`, `Content-Length: 93`, and body
  `{"id":9,"title":"trace me","body":"in flight","created_at":"2026-07-27T10:05:32.664410211Z"}`
- **Connection close** (packets 9–11): clean four-way FIN teardown —
  client `Flags [F.]` → server `Flags [F.]` → client final `Flags [.]` ACK.
  No RST, so the connection closed gracefully on both sides.

## 1.3: Five debugging commands

Full output saved in `lab4-debug-commands.txt`. Summary:

1. **`ss -tlnp | grep :8080`** — confirms `quicknotes` (pid 1360) is
   listening on `*:8080`, so the server process is up and bound correctly.
2. **`ip route show`** — shows the host's routing table. Multiple `eth*`
   interfaces here are expected; this is WSL2's virtualized network stack,
   not a physical multi-homed machine.
3. **`mtr -rwc 5 localhost`** — 5/5 packets, 0% loss, ~0.1ms latency to
   localhost. Confirms loopback reachability is fine (as expected — no
   network hop involved).
4. **`dig +short example.com @1.1.1.1`** — resolved to two A records
   (172.66.147.243, 104.20.23.154) using Cloudflare's public resolver
   directly, confirming outbound DNS resolution works independently of
   any local resolver config.
5. **`journalctl --user -u quicknotes -n 20`** — returned "No entries".
   This is expected, not an error: QuickNotes was run manually via
   `go run .`, not installed as a systemd unit, so there's no journal
   log to query.

## 1.4: What would I check first on a 502?

A 502 means the reverse proxy/gateway is up and answering, but got an
invalid or no response from the upstream (QuickNotes). So I'd start
closest to the failure and work outward: first confirm the QuickNotes
process itself is still alive and listening (`ps -ef | grep quicknotes`,
`ss -tlnp | grep 8080`) — if it crashed or never started, that's the
whole story. Next I'd check QuickNotes' own stdout/logs for a panic or
unhandled error around the request time. If the process looks healthy,
I'd verify the proxy is actually configured to point at the right
host:port (a stale or misconfigured upstream address is a classic
cause). Only after ruling those out would I look at anything
network-level (firewall rules, connection timeouts) — since on
localhost/loopback, network-layer failures are much less likely than a
crashed or misconfigured upstream.