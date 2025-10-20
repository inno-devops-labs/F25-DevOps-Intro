# Task 1 — Git State Reconciliation

## Initial State

**desired-state.txt**
```text
version: 1.0
app: myapp
replicas: 3
```

**current-state.txt**
```text
version: 1.0
app: myapp
replicas: 3
```

```bash
.reconcile.sh
```

```text
✅ States synchronized
```

## Simulated Drift

```bash
echo "version: 2.0" > current-state.txt
echo "app: myapp" >> current-state.txt
echo "replicas: 5" >> current-state.txt
```

**current-state.txt**

```text
version: 2.0
app: myapp
replicas: 5
```

## Reconciliation Output
```bash
./reconcile.sh
```

```text
Mon Oct 20 19:40:45 MSK 2025 - ⚠️  DRIFT DETECTED!
Reconciling current state with desired state...
Mon Oct 20 19:40:45 MSK 2025 - ✅ Reconciliation complete
```

## After Reconciliation

**current-state.txt**

```text
version: 1.0
app: myapp
replicas: 3
```

## Continuous Loop Observation

```bash
watch -n 5 ./reconcile.sh
```

```text
Every 5.0s: ./reconcile.sh               Spectre: Mon Oct 20 19:41:51 2025
Mon Oct 20 19:41:51 MSK 2025 - ✅ States synchronized

Every 5.0s: ./reconcile.sh               Spectre: Mon Oct 20 19:42:11 2025
Mon Oct 20 19:42:11 MSK 2025 - ⚠️  DRIFT DETECTED!
Reconciling current state with desired state...
Mon Oct 20 19:42:11 MSK 2025 - ✅ Reconciliation complete
```

## Result

The reconciliation loop continuously compares the current state with the desired state.  

If they differ, it automatically corrects the drift, keeping the system aligned.  

Using a declarative approach, GitOps defines *what* the state should be rather than *how* to achieve it, simplifying automation and improving reliability.

# Task 2 — GitOps Health Monitoring

## 1. Healthcheck Script

```bash
./healthcheck.sh
cat health.log
```

```text
Mon Oct 20 19:52:16 MSK 2025 - ✅ OK: States synchronized
Mon Oct 20 19:52:16 MSK 2025 - ✅ OK: States synchronized
```

## Simulate Drift

```bash
echo "unapproved-change: true" >> current-state.txt
./healthcheck.sh
cat health.log
```

```text
Mon Oct 20 19:52:29 MSK 2025 - ❌ CRITICAL: State mismatch detected!
  Desired MD5: a15a1a4f965ecd8f9e23a33a6b543155
  Current MD5: 48168ff3ab5ffc0214e81c7e2ee356f5
```

## Drift Correction

```bash
./reconcile.sh
./healthcheck.sh
cat health.log
```

```text
Mon Oct 20 19:52:45 MSK 2025 - ⚠️  DRIFT DETECTED!
Reconciling current state with desired state...
Mon Oct 20 19:52:45 MSK 2025 - ✅ Reconciliation complete
Mon Oct 20 19:52:45 MSK 2025 - ✅ OK: States synchronized
```

## Continuous Monitoring

```bash
./monitor.sh
cat health.log
```

```text
Starting GitOps monitoring...
\n--- Check #1 ---
Mon Oct 20 19:53:20 MSK 2025 - ✅ OK: States synchronized
Mon Oct 20 19:53:20 MSK 2025 - ✅ States synchronized
\n--- Check #2 ---
Mon Oct 20 19:53:23 MSK 2025 - ✅ OK: States synchronized
Mon Oct 20 19:53:23 MSK 2025 - ✅ States synchronized
```

## Results

Health checks use MD5 checksums to detect changes in the current state.

If a mismatch is found, a critical alert is logged.

This simulates GitOps tools like ArgoCD, which continuously monitor sync status and alert on configuration drift.
