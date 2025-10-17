# Lab 7 Submission

## Task 1 — Git State Reconciliation


### 1. Filling desired-state.txt and current-state.txt
```bash
echo 'version: 1.0' > labs/desired-state.txt
echo 'app: myapp' >> labs/desired-state.txt
echo 'replicas: 3' >> labs/desired-state.txt
cp labs/desired-state.txt labs/current-state.txt
```

### 2. Example of drift and reconcile
```bash
echo 'version: 2.0' > labs/current-state.txt
echo 'app: myapp' >> labs/current-state.txt
echo 'replicas: 5' >> labs/current-state.txt
cd labs; bash reconcile.sh; cat current-state.txt
# Output:
version: 1.0
app: myapp
replicas: 3
```

### 3. Reconcile-loop
```bash
cd labs; bash monitor.sh
# (stop manually with Ctrl+C)
```

## Task 2 — GitOps Health Monitoring

### 1. Healthcheck verification
```bash
cd labs; bash healthcheck.sh; cat health.log
# Output:
[Sat Oct 18 00:46:28 MSK 2025] HEALTHY: States match
```

### 2. Introducing drift and re-check
```bash
cd labs; echo 'unapproved-change: true' >> current-state.txt; bash healthcheck.sh; cat health.log
# Output:
[Sat Oct 18 00:46:33 MSK 2025] DRIFT: States differ
```

### 3. State recovery
```bash
cd labs; bash reconcile.sh; bash healthcheck.sh; cat health.log
# Output:
[Sat Oct 18 00:46:35 MSK 2025] HEALTHY: States match
```

### 4. Example of monitor.sh in action
```bash
cd labs; bash monitor.sh
# (stop manually with Ctrl+C)
cat health.log
# Output:
[Sat Oct 18 00:46:43 MSK 2025] HEALTHY: States match
[Sat Oct 18 00:46:48 MSK 2025] HEALTHY: States match
```

## Conclusion:
Thank you for the lab! That was interesting!
