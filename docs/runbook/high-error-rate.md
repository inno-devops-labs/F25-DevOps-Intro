# QuickNotes high error rate

## What this alert means

More than 5% of QuickNotes requests have returned a 4xx or 5xx response
continuously for at least five minutes.

## Triage steps

1. Confirm the scope and start time in the Errors and Traffic panels. Compare
   the ratio with absolute error/request rates so low traffic is not
   misinterpreted.
2. Split failures by status:
   `sum by (code) (rate(quicknotes_http_responses_by_code_total[5m]))`.
   A 400/404 increase points toward callers or a bad route; 500 points toward
   the service/storage path.
3. Check `docker compose ps`, `docker compose logs --since=10m quicknotes`,
   Prometheus target health, and the `/health` endpoint. Correlate the first
   failure with the latest deployment or configuration change.
4. Send one known-good GET and one valid POST from inside the Compose network.
   Verify `/data` is writable and has free space before changing data.

## Mitigations

- Roll back the most recent image/configuration if the increase began with a
  deploy, then verify the error ratio falls before resolving the incident.
- If one abusive or broken caller dominates 4xx traffic, rate-limit or block
  that caller at the ingress while preserving normal traffic.
- If storage writes are failing, stop write traffic, preserve the named
  volume, restore capacity/permissions, and only then restart QuickNotes.

## Post-incident

Preserve the alert timeline, relevant logs, deployment SHA, queries, and
mitigation timestamps. Write a blameless review using the postmortem approach
from [Lecture 1](../../lectures/lec1.md), assign follow-up owners and dates,
and update this runbook if any triage step was missing or ambiguous.
