#!/usr/bin/env bash
set -euo pipefail

url=${1:?usage: measure-latency.sh URL [COUNT]}
count=${2:-50}

if ! [[ "$count" =~ ^[1-9][0-9]*$ ]]; then
  echo "COUNT must be a positive integer" >&2
  exit 2
fi

samples=$(mktemp)
trap 'rm -f "$samples"' EXIT

for _ in $(seq 1 "$count"); do
  curl --fail --silent --output /dev/null \
    --write-out '%{time_total}\n' \
    "$url" >>"$samples"
done

sort -n "$samples" -o "$samples"
awk -v count="$count" '
  {
    values[NR] = $1
  }
  END {
    p50 = int((count * 0.50) + 0.999999)
    p95 = int((count * 0.95) + 0.999999)
    printf "runs=%d p50_seconds=%.6f p95_seconds=%.6f\n",
      count, values[p50], values[p95]
  }
' "$samples"
