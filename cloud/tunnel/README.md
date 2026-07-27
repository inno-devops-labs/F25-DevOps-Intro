# Cloudflare Quick Tunnel — reproducing the Bonus

Zero-account, zero-card way to hand a public URL to a container running on
this laptop. The URL is ephemeral (changes on every restart) — that's the
trade for skipping account setup.

## 1. Run QuickNotes locally

Same image the release workflow pushes to ghcr.io:

```bash
docker run --rm -d --name qn-lab10-tunnel \
  -p 8080:8080 \
  ghcr.io/grandadmiralbee/devops-intro/quicknotes:v0.10.0

curl -fsS localhost:8080/health
# {"status":"ok"}
```

## 2. Start a quick tunnel

```bash
# NixOS: nix shell nixpkgs#cloudflared -c cloudflared tunnel --url http://localhost:8080
cloudflared tunnel --url http://localhost:8080
```

`cloudflared` prints the assigned URL — copy the `https://*.trycloudflare.com`
line. Keep the terminal open; the tunnel dies with the process.

## 3. Verify from a different network

Curl from a phone on cellular (or any machine that isn't this laptop):

```bash
curl -v https://<random>.trycloudflare.com/health
curl -fsS https://<random>.trycloudflare.com/notes | head -c 200
```

If it answers, traffic is really flowing through Cloudflare's edge into the
local container.

## 4. Measure warm latency

```bash
# 50 warm runs, curl's own time (no shell overhead):
for i in $(seq 1 50); do
  curl -s -o /dev/null -w '%{time_total}\n' \
    https://<random>.trycloudflare.com/health
done | sort -n > warm-tunnel.txt

# p50 and p95:
awk 'NR==25{print "p50=" $1} NR==48{print "p95=" $1}' warm-tunnel.txt
```

Same trick against the HF Space URL gives the two rows of the Bonus table.

## 5. Tear down

```bash
# Ctrl-C the cloudflared process, then:
docker rm -f qn-lab10-tunnel
```

Nothing to delete on Cloudflare's side — quick tunnels are stateless.
