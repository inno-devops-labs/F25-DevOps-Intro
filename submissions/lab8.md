# Lab 8 — SRE & Monitoring

Branch: `feature/lab8`

## Implementation

The Compose stack builds QuickNotes and starts pinned Prometheus 3.12.0 and
Grafana 13.1.0 images. Prometheus scrapes `quicknotes:8080` every 15 seconds;
Grafana receives its data source and four-panel dashboard entirely from
versioned provisioning files. Admin credentials are mandatory Compose
variables (see `.env.example`) and no working default password is committed.

The four panels are:

1. scrape duration as the available latency proxy;
2. per-second request rate for traffic;
3. percentage of 4xx/5xx responses for errors;
4. stored-note count as the available saturation proxy.

CI validates the Prometheus config/rules, starts the real stack, checks target
health and Grafana provisioning, drives sustained mixed traffic through the
service, observes Pending and Firing, and captures a dashboard screenshot.
The resulting evidence will be attached after the run.

## Design answers

**a — pull reachability.** Prometheus initiates TCP connections, so it must be
able to resolve and reach QuickNotes; QuickNotes only needs to listen and
serve `/metrics`. If the path fails, the target becomes `up=0` and samples go
stale. That indicates missing observability, not necessarily an application
outage, so an independent health signal matters.

**b — interval trade-off.** Five-second scrapes multiply storage, network, and
query samples and can turn harmless jitter into noisy graphs. Five-minute
scrapes alias short incidents, make a one-minute `rate` impossible, and delay
alerts by multiple minutes. Query windows should contain several samples and
match both detection goals and retention cost.

**c — rate functions.** `rate(counter[window])` is right for the traffic panel:
it handles counter resets and smooths all samples in the range. `irate` uses
only the last two samples and is useful for highly responsive debugging but
too spiky for an operational overview. `delta` reports an absolute change and
is intended for gauges, not a per-second counter rate.

**d — provisioning.** Files make the data source/dashboard reviewable,
repeatable, testable, and recoverable from Git. A fresh stack and every
environment receive the same queries without undocumented clicks or mutable
state in a Grafana database.

## Alert and runbook

[`rules.yml`](../monitoring/prometheus/rules.yml) defines
`QuickNotesHighErrorRate`: error ratio greater than 5% with `for: 5m`,
`severity: page`, and a repository runbook annotation. The operational
instructions are in
[`docs/runbook/high-error-rate.md`](../docs/runbook/high-error-rate.md).

**e — sustained gate.** One bad request is normal user/input behavior and has
negligible error-budget impact. Five continuous minutes filters isolated
bursts and scrape noise while still paging on a user-visible trend.

**f — symptom versus cause.** A cause alert might page on CPU above 80% or low
disk space. It is worse as the primary page because high CPU can be healthy
useful work and low disk might not affect requests; meanwhile many real user
failures have neither cause. Causes belong in dashboards or tickets unless
they predict imminent impact with strong evidence.

**g — noise threshold.** If more than 10% of pages have no measurable user
impact or require no urgent human action, I would treat this alert as too
noisy and tune the expression, duration, routing, or severity. The review
should use a rolling incident sample rather than intuition.

## Bonus status

No public endpoint or Checkly account/credential is available in this
workspace, so a two-region synthetic monitor and 30-minute measurements are
not claimed. Prometheus would catch internal metrics and degradation invisible
to one endpoint; an external probe would catch DNS, TLS, routing, ingress, and
regional failures that an in-network scrape bypasses.
