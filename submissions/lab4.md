# Lab 4 — OS & Networking

Branch: `feature/lab4`  
Reproducible Linux run: [GitHub Actions run 30306253089](https://github.com/Mimir-sma/DevOps-Intro/actions/runs/30306253089) (`ubuntu-24.04`)

The capture was made on a real Linux loopback interface by
[`lab4/run-linux.sh`](../lab4/run-linux.sh). The original binary captures and
their text decodes are committed:

- [`lab4-trace.pcap`](../lab4/lab4-trace.pcap) and
  [`lab4-trace.txt`](../lab4/lab4-trace.txt);
- [`lab4-tls.pcap`](../lab4/lab4-tls.pcap) and
  [`lab4-tls.txt`](../lab4/lab4-tls.txt);
- complete command output in
  [`debug-commands.txt`](../lab4/debug-commands.txt),
  [`outside-in.txt`](../lab4/outside-in.txt), and
  [`repair.txt`](../lab4/repair.txt).

## Task 1 — one request end to end

The packet order in `lab4-trace.txt` is:

| Phase | Evidence |
|---|---|
| TCP open | `56488 > 8080 Flags [S]`, then `8080 > 56488 Flags [S.]`, then `56488 > 8080 Flags [.]` |
| Request | `Flags [P.]`, `POST /notes HTTP/1.1`, 39-byte JSON body `{"title":"trace me","body":"in flight"}` |
| Response | server `Flags [P.]`, `HTTP/1.1 201 Created`, JSON note with `id:5` |
| TCP close | client `Flags [F.]`, server `Flags [F.]`, final client ACK |

This is a complete three-way handshake, one HTTP request/response exchange,
and an orderly four-segment close. Sequence/acknowledgement numbers also show
that the server acknowledges all 174 request bytes and the client
acknowledges all 206 response bytes.

### Five-command debug snapshot

1. `ss -tlnp | grep :8080`

   ```text
   LISTEN 0 4096 127.0.0.1:8080 0.0.0.0:* users:(("quicknotes",pid=4294,fd=3))
   ```

   QuickNotes is listening, but only on loopback.

2. `ip route show`

   ```text
   default via 10.1.0.1 dev eth0 proto dhcp src 10.1.0.47 metric 100
   10.1.0.0/20 dev eth0 proto kernel scope link src 10.1.0.47 metric 100
   172.17.0.0/16 dev docker0 proto kernel scope link src 172.17.0.1 linkdown
   ```

   The host has a default route; loopback traffic does not need it.

3. `mtr -rwc 5 localhost`

   ```text
   HOST: runnervmvrwv9 Loss% Snt Last Avg Best Wrst StDev
     1.|-- localhost      0.0%   5  0.1 0.1  0.1  0.1   0.0
   ```

   Local reachability has no loss.

4. `dig +short example.com @1.1.1.1`

   ```text
   172.66.147.243
   104.20.23.154
   ```

   An explicit query to the resolver succeeds.

5. `journalctl --user -u quicknotes -n 20`

   ```text
   -- No entries --
   ```

   This run is a foreground process rather than a user systemd unit, so the
   empty journal is expected. Its process output is captured separately.

If a proxy returned 502, I would first correlate the failing request with the
proxy log, then test the configured upstream directly from the proxy's own
network namespace. I would check the upstream hostname/port, `ss` listener and
bind address, health endpoint, process logs, DNS result, route, and firewall in
that order. A healthy `localhost:8080` on the host does not prove that the same
address is reachable from a container or VM, so the test must originate at the
proxy.

## Task 2 — outside-in diagnosis

The deliberate second start failed exactly as intended:

```text
listen: listen tcp 127.0.0.1:8080: bind: address already in use
```

| Step | Command and observed result | Decision |
|---|---|---|
| Process | `ps -ef \| grep quicknotes` → one QuickNotes PID | The first instance is alive; the second exited. |
| Socket | `ss -tlnp \| grep 8080` → PID 4294 on `127.0.0.1:8080` | A listener already owns the port. |
| HTTP | `curl ... /health` → `200` | The existing listener is reachable from the host. |
| Firewall | `iptables -L -n -v` → host `INPUT`/`OUTPUT` policies are `ACCEPT` | Host filtering is not causing this bind error. |
| DNS | `dig +short localhost` → `127.0.0.1` | Name resolution agrees with the listener address. |

After stopping the conflicting process, QuickNotes started on the same port.
Re-verification returned:

```json
{"notes":4,"status":"ok"}
```

### Mini-postmortem

The failure was caused by two application instances being scheduled onto one
fixed host port. No individual action was unsafe: the application correctly
refused to steal an occupied socket, and the first process remained healthy.
The systemic gap was that startup did not reserve or validate the port before
launch and there was no supervisor policy defining whether this was a restart
or a second replica. Preventive controls include a systemd unit with explicit
restart semantics, a pre-start socket check, unique dynamically allocated
ports behind a proxy, and deployment health/readiness checks that fail before
traffic is switched. Structured startup logs and an alert on repeated restart
failure would shorten diagnosis.

## Bonus — TLS handshake

[`tls-proxy.go`](../lab4/tls-proxy.go) terminates TLS on `localhost:8443` and
proxies to QuickNotes. The decode shows:

- ClientHello SNI: `localhost`;
- ClientHello `supported_versions`: TLS 1.3 and TLS 1.2;
- ServerHello selected TLS 1.3 and
  `TLS_AES_128_GCM_SHA256`;
- certificate subject and issuer: `CN = localhost`;
- OpenSSL verify result 18, expected for this one-day self-signed lab
  certificate.

The `TLS 1.0` label on the outer ClientHello record is a compatibility record
version, not the negotiated protocol. Protocol selection happens through the
ClientHello `supported_versions` extension and the ServerHello selection.
Because the client offers only TLS 1.3/1.2, TLS 1.0 and 1.1 are eliminated at
that negotiation step; the server chooses TLS 1.3 from the intersection.
