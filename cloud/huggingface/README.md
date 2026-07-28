---
title: QuickNotes
emoji: 🗒️
colorFrom: blue
colorTo: indigo
sdk: docker
app_port: 8080
pinned: false
---

# QuickNotes

This Docker Space runs the immutable
`ghcr.io/mimir-sma/devops-intro/quicknotes:v0.1.0` release.

Endpoints:

- `GET /health`
- `GET /notes`
- `POST /notes`
- `DELETE /notes/{id}`
- `GET /metrics`

The free Space filesystem is ephemeral. Notes are demonstration data and must
not be treated as durable storage.
