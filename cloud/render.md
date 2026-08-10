# Cloud deployment — Render (substitute for Hugging Face Spaces)

## Why not Hugging Face

The lab specifies Hugging Face Spaces with the Docker SDK, on the stated grounds
that it is "truly free, no card required". That is no longer true. As of
approximately July 2026 the Spaces documentation states:

> Gradio and Docker Spaces run on compute and require a paid plan to create:
> PRO for personal accounts, Team or Enterprise for organizations.
> Static Spaces are free for everyone.

Creating a Docker Space now requires PRO at $9/month. Static Spaces remain free
but cannot run a compiled Go binary.

## What was used instead

Render.com free web service:

- Deploys directly from an OCI registry — the same ghcr.io image built in Task 1
- Public HTTPS URL, no credit card
- Free instances spin down after ~15 minutes of inactivity and take 50+ seconds
  to wake, which is the same scale-to-zero behaviour Task 2.2 asks to measure

## Configuration

| Setting | Value |
|---|---|
| Image | `ghcr.io/hns2112/devops-intro/quicknotes:v0.1.0` |
| Region | Frankfurt (EU Central) |
| Instance | Free — 512 MB RAM, 0.1 CPU |
| Health check path | `/health` |

Environment variables:

| Key | Value | Why |
|---|---|---|
| `ADDR` | `0.0.0.0:10000` | Render expects the service on port 10000; binding to `0.0.0.0` is required for the platform proxy to reach it |
| `DATA_PATH` | `/tmp/notes.json` | the image runs as nonroot with a read-only root filesystem |
| `SEED_PATH` | `/app/seed.json` | absolute path, independent of working directory |

Public URL: https://quicknotes-e5cq.onrender.com
