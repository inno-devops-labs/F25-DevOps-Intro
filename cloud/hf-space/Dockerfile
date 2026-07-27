# Re-tag the immutable ghcr.io release as the Space's runtime.
# Multi-stage FROM copies nothing, so no rebuild — HF just re-serves the
# already-built image referenced by digest-equivalent tag.
FROM ghcr.io/grandadmiralbee/devops-intro/quicknotes:v0.10.0

# HF Spaces mounts a writable /data at runtime; QuickNotes already writes
# there (see app/Dockerfile ENV DATA_PATH=/data/notes.json).
EXPOSE 8080
