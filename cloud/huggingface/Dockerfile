# The immutable release is built and scanned by GitHub Actions once, then
# promoted unchanged to Hugging Face Spaces.
FROM ghcr.io/mimir-sma/devops-intro/quicknotes:v0.1.0

ENV ADDR=:8080 \
    DATA_PATH=/data/notes.json \
    SEED_PATH=/app/seed.json

EXPOSE 8080
