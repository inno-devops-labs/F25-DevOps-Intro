# syntax=docker/dockerfile:1

FROM golang:1.24.6-bookworm AS builder
WORKDIR /src
COPY go.mod go.su[m] ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build \
      -trimpath \
      -ldflags='-s -w' \
      -o /out/quicknotes .
RUN mkdir -p /data-empty

FROM busybox:1.37-uclibc AS busybox

FROM gcr.io/distroless/static:nonroot
WORKDIR /app
COPY --from=builder /out/quicknotes /app/quicknotes
COPY --from=builder /src/seed.json /app/seed.json
COPY --from=busybox /bin/wget /bin/wget
COPY --from=builder --chown=65532:65532 /data-empty /data
USER nonroot:nonroot
EXPOSE 8080
ENTRYPOINT ["/app/quicknotes"]
