#!/usr/bin/env bash
set -euo pipefail

readonly GO_VERSION="1.24.5"
readonly GO_ARCHIVE="go${GO_VERSION}.linux-amd64.tar.gz"
readonly GO_SHA256="10ad9e86233e74c0f6590fe5426895de6bf388964210eac34a6d83f38918ecdc"
readonly SOURCE_DIR="/opt/quicknotes-src"
readonly RELEASE_DIR="/opt/quicknotes"
readonly DATA_DIR="/var/lib/quicknotes"

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install --yes --no-install-recommends ca-certificates curl

installed_version=""
if [[ -x /usr/local/go/bin/go ]]; then
  installed_version=$(/usr/local/go/bin/go version | awk '{print $3}')
fi

if [[ "$installed_version" != "go${GO_VERSION}" ]]; then
  archive="/tmp/${GO_ARCHIVE}"
  curl --fail --location --retry 3 \
    "https://go.dev/dl/${GO_ARCHIVE}" \
    --output "$archive"
  printf '%s  %s\n' "$GO_SHA256" "$archive" | sha256sum --check -
  rm -rf /usr/local/go
  tar -C /usr/local -xzf "$archive"
  rm -f "$archive"
fi

if ! id quicknotes >/dev/null 2>&1; then
  useradd --system \
    --home-dir "$DATA_DIR" \
    --create-home \
    --shell /usr/sbin/nologin \
    quicknotes
fi

install -d -o root -g root -m 0755 "$RELEASE_DIR"
install -d -o quicknotes -g quicknotes -m 0750 "$DATA_DIR"

# Build from a private copy so the running service is independent of the
# VirtualBox shared-folder lifecycle.
cp -a "${SOURCE_DIR}/." "${RELEASE_DIR}/"
(
  cd "$RELEASE_DIR"
  CGO_ENABLED=0 /usr/local/go/bin/go build \
    -trimpath \
    -ldflags="-s -w" \
    -o /usr/local/bin/quicknotes \
    .
)
install -o quicknotes -g quicknotes -m 0640 \
  "${RELEASE_DIR}/seed.json" \
  "${DATA_DIR}/seed.json"

cat >/etc/systemd/system/quicknotes.service <<'UNIT'
[Unit]
Description=QuickNotes lab service
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=quicknotes
Group=quicknotes
Environment=ADDR=0.0.0.0:8080
Environment=DATA_PATH=/var/lib/quicknotes/notes.json
Environment=SEED_PATH=/var/lib/quicknotes/seed.json
ExecStart=/usr/local/bin/quicknotes
Restart=on-failure
RestartSec=2s
NoNewPrivileges=true
PrivateTmp=true
ProtectHome=true
ProtectSystem=strict
ReadWritePaths=/var/lib/quicknotes

[Install]
WantedBy=multi-user.target
UNIT

systemctl daemon-reload
systemctl enable --now quicknotes.service
systemctl restart quicknotes.service

for _ in {1..20}; do
  if curl --fail --silent http://127.0.0.1:8080/health >/dev/null; then
    exit 0
  fi
  sleep 1
done

journalctl -u quicknotes.service --no-pager -n 50
exit 1
