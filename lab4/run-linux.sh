#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
work_dir="${RUNNER_TEMP:-/tmp}/quicknotes-lab4"
mkdir -p "$work_dir"

app_pid=""
proxy_pid=""
cleanup() {
  if [[ -n "$proxy_pid" ]]; then
    kill "$proxy_pid" 2>/dev/null || true
    wait "$proxy_pid" 2>/dev/null || true
  fi
  if [[ -n "$app_pid" ]]; then
    kill "$app_pid" 2>/dev/null || true
    wait "$app_pid" 2>/dev/null || true
  fi
}
trap cleanup EXIT

cd "$repo_root/app"
CGO_ENABLED=0 go build -trimpath -o "$work_dir/quicknotes" .

ADDR=127.0.0.1:8080 \
DATA_PATH="$work_dir/notes.json" \
SEED_PATH="$repo_root/app/seed.json" \
  "$work_dir/quicknotes" >"$work_dir/quicknotes.log" 2>&1 &
app_pid=$!

for _ in {1..30}; do
  if curl --fail --silent http://127.0.0.1:8080/health >/dev/null; then
    break
  fi
  sleep 0.2
done
curl --fail --silent http://127.0.0.1:8080/health >/dev/null

sudo timeout --signal=INT 5 tcpdump \
  -i lo -nn -s 0 -w "$repo_root/lab4/lab4-trace.pcap" \
  'tcp port 8080' >"$work_dir/tcpdump-http.log" 2>&1 &
capture_pid=$!
sleep 0.5

curl --verbose --request POST http://127.0.0.1:8080/notes \
  --header 'Content-Type: application/json' \
  --data '{"title":"trace me","body":"in flight"}' \
  >"$work_dir/curl-post.out" 2>"$work_dir/curl-post.verbose"

wait "$capture_pid" || [[ $? -eq 124 ]]

sudo tcpdump -r "$repo_root/lab4/lab4-trace.pcap" -nn -A \
  >"$repo_root/lab4/lab4-trace.txt" 2>&1

{
  echo '$ ss -tlnp | grep :8080'
  ss -tlnp | grep :8080
  echo
  echo '$ ip route show'
  ip route show
  echo
  echo '$ mtr -rwc 5 localhost'
  mtr -rwc 5 localhost
  echo
  echo '$ dig +short example.com @1.1.1.1'
  dig +short example.com @1.1.1.1
  echo
  echo '$ journalctl --user -u quicknotes -n 20'
  journalctl --user -u quicknotes -n 20 || true
} >"$repo_root/lab4/debug-commands.txt" 2>&1

set +e
ADDR=127.0.0.1:8080 \
DATA_PATH="$work_dir/broken-notes.json" \
SEED_PATH="$repo_root/app/seed.json" \
  "$work_dir/quicknotes" >"$work_dir/qn-broken.log" 2>&1
broken_status=$?
set -e

{
  echo '$ ADDR=127.0.0.1:8080 ./quicknotes'
  echo "exit_status=$broken_status"
  cat "$work_dir/qn-broken.log"
  echo
  echo '$ ps -ef | grep quicknotes'
  ps -ef | grep '[q]uicknotes'
  echo
  echo '$ ss -tlnp | grep 8080'
  ss -tlnp | grep 8080
  echo
  echo '$ curl -s -o /dev/null -w "%{http_code}\n" http://localhost:8080/health'
  curl --silent --output /dev/null --write-out '%{http_code}\n' \
    http://localhost:8080/health
  echo
  echo '$ iptables -L -n -v || nft list ruleset'
  sudo iptables -L -n -v 2>/dev/null ||
    sudo nft list ruleset 2>/dev/null ||
    true
  echo
  echo '$ dig +short localhost'
  dig +short localhost
} >"$repo_root/lab4/outside-in.txt" 2>&1

kill "$app_pid"
wait "$app_pid" 2>/dev/null || true
app_pid=""
sleep 0.5

ADDR=127.0.0.1:8080 \
DATA_PATH="$work_dir/repaired-notes.json" \
SEED_PATH="$repo_root/app/seed.json" \
  "$work_dir/quicknotes" >"$work_dir/quicknotes-repaired.log" 2>&1 &
app_pid=$!
sleep 0.5
{
  echo '$ curl -s http://localhost:8080/health'
  curl --fail --silent http://localhost:8080/health
  echo
} >"$repo_root/lab4/repair.txt"

openssl req -x509 -newkey rsa:2048 -sha256 -nodes -days 1 \
  -subj '/CN=localhost' \
  -addext 'subjectAltName=DNS:localhost,IP:127.0.0.1' \
  -keyout "$work_dir/localhost.key" \
  -out "$work_dir/localhost.crt" >/dev/null 2>&1

cd "$repo_root"
go build -trimpath -o "$work_dir/tls-proxy" ./lab4/tls-proxy.go
"$work_dir/tls-proxy" \
  -cert "$work_dir/localhost.crt" \
  -key "$work_dir/localhost.key" \
  >"$work_dir/tls-proxy.log" 2>&1 &
proxy_pid=$!
sleep 0.5

sudo timeout --signal=INT 5 tcpdump \
  -i lo -nn -s 0 -w "$repo_root/lab4/lab4-tls.pcap" \
  'tcp port 8443' >"$work_dir/tcpdump-tls.log" 2>&1 &
tls_capture_pid=$!
sleep 0.5
curl --insecure --verbose https://localhost:8443/health \
  >"$work_dir/curl-tls.out" 2>"$work_dir/curl-tls.verbose"
wait "$tls_capture_pid" || [[ $? -eq 124 ]]

{
  echo '=== ClientHello ==='
  tshark -r "$repo_root/lab4/lab4-tls.pcap" \
    -Y 'tls.handshake.type == 1' -V
  echo '=== ServerHello ==='
  tshark -r "$repo_root/lab4/lab4-tls.pcap" \
    -Y 'tls.handshake.type == 2' -V
  echo '=== Certificate chain ==='
  openssl s_client -connect localhost:8443 -servername localhost \
    -showcerts </dev/null
} >"$repo_root/lab4/lab4-tls.txt" 2>&1

echo '=== CURL POST ==='
cat "$work_dir/curl-post.verbose"
cat "$work_dir/curl-post.out"
echo
echo '=== HTTP TRACE ==='
cat "$repo_root/lab4/lab4-trace.txt"
echo '=== DEBUG COMMANDS ==='
cat "$repo_root/lab4/debug-commands.txt"
echo '=== OUTSIDE-IN ==='
cat "$repo_root/lab4/outside-in.txt"
echo '=== REPAIR ==='
cat "$repo_root/lab4/repair.txt"
echo '=== TLS SUMMARY ==='
grep -E -m 40 \
  'Client Hello|Server Hello|Version:|Cipher Suite:|Server Name|Subject:|Issuer:' \
  "$repo_root/lab4/lab4-tls.txt" || true
