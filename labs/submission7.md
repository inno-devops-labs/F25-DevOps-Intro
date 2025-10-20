# Task 1 — Git State Reconciliation

## Desired vs. Current State Setup
```sh
$ echo "version: 1.0" > desired-state.txt
$ echo "app: myapp" >> desired-state.txt
$ echo "replicas: 3" >> desired-state.txt
$ cp desired-state.txt current-state.txt
Initial state synchronized
```

`desired-state.txt` after initialization:
```text
version: 1.0
app: myapp
replicas: 3
```

`current-state.txt` after the first sync:
```text
version: 1.0
app: myapp
replicas: 3
```

## Reconciliation Script
`./reconcile.sh`:
```bash
#!/bin/bash
# reconcile.sh - GitOps reconciliation loop

DESIRED=$(cat desired-state.txt)
CURRENT=$(cat current-state.txt)

if [ "$DESIRED" != "$CURRENT" ]; then
    echo "$(date) - ⚠️  DRIFT DETECTED!"
    echo "Reconciling current state with desired state..."
    cp desired-state.txt current-state.txt
    echo "$(date) - ✅ Reconciliation complete"
else
    echo "$(date) - ✅ States synchronized"
fi
```

## Manual Drift Detection
```sh
$ echo "version: 2.0" > current-state.txt
$ echo "app: myapp" >> current-state.txt
$ echo "replicas: 5" >> current-state.txt

$ ./reconcile.sh
Mon Oct 20 13:45:32 MSK 2025 - ⚠️  DRIFT DETECTED!
Reconciling current state with desired state...
Mon Oct 20 13:45:32 MSK 2025 - ✅ Reconciliation complete

$ diff desired-state.txt current-state.txt

$ cat current-state.txt
version: 1.0
app: myapp
replicas: 3
```

## Continuous Reconciliation Loop
`watch -n 5 ./reconcile.sh` excerpt:
```text
Every 5.0s: ./reconcile.sh                             MacBook-Pro-Alexander.local: 13:47:15

Mon Oct 20 13:47:15 MSK 2025 - ✅ States synchronized

Mon Oct 20 13:47:20 MSK 2025 - ⚠️  DRIFT DETECTED!
Reconciling current state with desired state...
Mon Oct 20 13:47:20 MSK 2025 - ✅ Reconciliation complete
Mon Oct 20 13:47:25 MSK 2025 - ✅ States synchronized
```

### Analysis
- `reconcile.sh` continually enforces Git as the source of truth by copying `desired-state.txt` over `current-state.txt` whenever the contents diverge.
- The manual drift scenario demonstrated self-healing behavior: after the script ran, the diff disappeared and the cluster state snapped back to the declarative spec.
- Running the script under `watch` mimics GitOps controllers (ArgoCD/Flux) that poll for drift on an interval and print surfacing events for observability.
- Declarative configurations let operators specify *what* the steady state should be, so changes are reviewable, auditable, and easy to reproduce—unlike imperative fixes that depend on tribal knowledge and are prone to snowflake drift in production.

# Task 2 — GitOps Health Monitoring

## Health Check Script
`./healthcheck.sh`:
```bash
#!/bin/bash
# healthcheck.sh - Monitor GitOps sync health

DESIRED_MD5=$(md5sum desired-state.txt | awk '{print $1}')
CURRENT_MD5=$(md5sum current-state.txt | awk '{print $1}')

if [ "$DESIRED_MD5" != "$CURRENT_MD5" ]; then
    echo "$(date) - ❌ CRITICAL: State mismatch detected!" | tee -a health.log
    echo "  Desired MD5: $DESIRED_MD5" | tee -a health.log
    echo "  Current MD5: $CURRENT_MD5" | tee -a health.log
else
    echo "$(date) - ✅ OK: States synchronized" | tee -a health.log
fi
```

## Healthy Baseline
```sh
$ ./healthcheck.sh
Mon Oct 20 13:51:14 MSK 2025 - ✅ OK: States synchronized

$ cat health.log
Mon Oct 20 13:51:14 MSK 2025 - ✅ OK: States synchronized
```

## Drift Detection
```sh
$ echo "unapproved-change: true" >> current-state.txt

$ ./healthcheck.sh
Mon Oct 20 13:51:23 MSK 2025 - ❌ CRITICAL: State mismatch detected!
  Desired MD5: a15a1a4f965ecd8f9e23a33a6b543155
  Current MD5: 48168ff3ab5ffc0214e81c7e2ee356f5
```

`health.log` after the drift check:
```text
Mon Oct 20 13:51:14 MSK 2025 - ✅ OK: States synchronized
Mon Oct 20 13:51:23 MSK 2025 - ❌ CRITICAL: State mismatch detected!
  Desired MD5: a15a1a4f965ecd8f9e23a33a6b543155
  Current MD5: 48168ff3ab5ffc0214e81c7e2ee356f5
```

## Reconciling and Verifying Recovery
```sh
$ ./reconcile.sh
Mon Oct 20 13:51:28 MSK 2025 - ⚠️  DRIFT DETECTED!
Reconciling current state with desired state...
Mon Oct 20 13:51:28 MSK 2025 - ✅ Reconciliation complete

$ ./healthcheck.sh
Mon Oct 20 13:51:31 MSK 2025 - ✅ OK: States synchronized
```

Final `health.log` (multiple checks recorded):
```text
Mon Oct 20 13:51:14 MSK 2025 - ✅ OK: States synchronized
Mon Oct 20 13:51:23 MSK 2025 - ❌ CRITICAL: State mismatch detected!
  Desired MD5: a15a1a4f965ecd8f9e23a33a6b543155
  Current MD5: 48168ff3ab5ffc0214e81c7e2ee356f5
Mon Oct 20 13:51:31 MSK 2025 - ✅ OK: States synchronized
```

## Monitoring Loop Script
`./monitor.sh`:
```bash
#!/bin/bash
# monitor.sh - Combined reconciliation and health monitoring

echo "Starting GitOps monitoring..."
for i in {1..10}; do
    echo "\n--- Check #$i ---"
    ./healthcheck.sh
    ./reconcile.sh
    sleep 3
done
```

`./monitor.sh` session:
```text
➜  F25-DevOps-Intro git:(feature/lab7) ✗ ./monitor.sh
Starting GitOps monitoring...

--- Check #1 ---
Mon Oct 20 13:58:30 MSK 2025 - ✅ OK: States synchronized
Mon Oct 20 13:58:30 MSK 2025 - ✅ States synchronized

--- Check #2 ---
Mon Oct 20 13:58:33 MSK 2025 - ✅ OK: States synchronized
Mon Oct 20 13:58:33 MSK 2025 - ✅ States synchronized

--- Check #3 ---
Mon Oct 20 13:58:36 MSK 2025 - ✅ OK: States synchronized
Mon Oct 20 13:58:36 MSK 2025 - ✅ States synchronized

--- Check #4 ---
Mon Oct 20 13:58:39 MSK 2025 - ✅ OK: States synchronized
Mon Oct 20 13:58:39 MSK 2025 - ✅ States synchronized

--- Check #5 ---
Mon Oct 20 13:58:42 MSK 2025 - ✅ OK: States synchronized
Mon Oct 20 13:58:42 MSK 2025 - ✅ States synchronized

--- Check #6 ---
Mon Oct 20 13:58:45 MSK 2025 - ✅ OK: States synchronized
Mon Oct 20 13:58:46 MSK 2025 - ✅ States synchronized
^C
```

`health.log` immediately after the monitoring loop:
```text
Mon Oct 20 13:58:30 MSK 2025 - ✅ OK: States synchronized
Mon Oct 20 13:58:33 MSK 2025 - ✅ OK: States synchronized
Mon Oct 20 13:58:36 MSK 2025 - ✅ OK: States synchronized
Mon Oct 20 13:58:39 MSK 2025 - ✅ OK: States synchronized
Mon Oct 20 13:58:42 MSK 2025 - ✅ OK: States synchronized
Mon Oct 20 13:58:45 MSK 2025 - ✅ OK: States synchronized
```

### Analysis
- Using MD5 fingerprints in `healthcheck.sh` surfaces hidden drift faster than comparing files manually, because a single checksum change signals any content difference.
- The workflow mirrors ArgoCD’s sync status: `healthcheck.sh` detects divergence, `reconcile.sh` corrects it, and `health.log` acts as a lightweight audit trail of state transitions.
- Automating the loop in `monitor.sh` provides the same assurance as GitOps controllers repeatedly running health checks and reconciliation without human intervention.
