# syntax=docker/dockerfile:1

FROM golang:1.26.5-bookworm AS builder
WORKDIR /src

COPY go.mod ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build \
    -trimpath -ldflags="-s -w" -o /out/quicknotes . \
 && CGO_ENABLED=0 GOOS=linux go build \
    -trimpath -ldflags="-s -w" -o /out/healthcheck ./cmd/healthcheck \
 && mkdir -p /out/data \
 && touch /out/data/.volume-initialized

FROM gcr.io/distroless/static-debian12:nonroot
WORKDIR /app
COPY --from=builder --chown=65532:65532 /out/quicknotes /quicknotes
COPY --from=builder --chown=65532:65532 /out/healthcheck /healthcheck
COPY --chown=65532:65532 seed.json /app/seed.json
COPY --from=builder --chown=65532:65532 /out/data /data

USER nonroot:nonroot
EXPOSE 8080
ENTRYPOINT ["/quicknotes"]
