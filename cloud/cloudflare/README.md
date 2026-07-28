# QuickNotes through a Cloudflare Quick Tunnel

Start the same immutable image locally:

```bash
docker run --rm --name quicknotes-tunnel \
  -p 127.0.0.1:8080:8080 \
  -e ADDR=:8080 \
  -e DATA_PATH=/data/notes.json \
  -e SEED_PATH=/app/seed.json \
  ghcr.io/mimir-sma/devops-intro/quicknotes:v0.1.0
```

In another terminal:

```bash
cloudflared tunnel --url http://localhost:8080
```

Copy the generated `https://<random>.trycloudflare.com` URL and verify
`/health` from a phone on cellular data. The URL is ephemeral and changes
when cloudflared restarts. Run `../measure-latency.sh URL/health 50` from the
external client to calculate p50/p95.
