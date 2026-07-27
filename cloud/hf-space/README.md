---
title: QuickNotes
emoji: 📝
colorFrom: blue
colorTo: indigo
sdk: docker
app_port: 8080
pinned: false
short_description: Tiny notes API in Go (Innopolis DevOps course Lab 10)
---

# QuickNotes on Hugging Face Spaces

A small notes API. Runs the image built by
`.github/workflows/release.yml` in the Innopolis DevOps course repo and
pushed to `ghcr.io/grandadmiralbee/devops-intro/quicknotes`.

## Endpoints

- `GET /health` — liveness probe, returns `{"status":"ok"}`
- `GET /notes` — list all notes (seeded on first boot from `/seed.json`)
- `POST /notes` — create a note; body `{"title":"...","body":"..."}`
- `GET /notes/{id}` — fetch one note
- `DELETE /notes/{id}` — remove a note

## Why `app_port: 8080`?

The HF Spaces Docker SDK defaults to `7860` (chosen for Gradio). QuickNotes
listens on `:8080` (see `ENV ADDR=:8080` in the upstream Dockerfile), so
the frontmatter has to declare the real port or HF never routes traffic to
the container.
