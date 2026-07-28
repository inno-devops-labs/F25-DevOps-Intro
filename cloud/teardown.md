# Teardown

- Hugging Face: open the Space settings and select **Delete this Space**.
- GHCR: keep immutable release versions for provenance; delete only through
  package settings if retention policy requires it.
- Cloudflare Quick Tunnel: stop `cloudflared`; no account-side object exists.
- Local container: `docker stop quicknotes-tunnel`.
