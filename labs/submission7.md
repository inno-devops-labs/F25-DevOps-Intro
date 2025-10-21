# Task

## Task 1 — Git State Reconciliation

### Task 1.1: Setup Desired State Configuration

Initial desired-state.txt:

```txt
version: 1.0
app: myapp
replicas: 3
```

Initial current-state.txt:

```txt
version: 1.0
app: myapp
replicas: 3
```

### Task 1.2: Create Reconciliation Loop

### Task 1.3: Test Manual Drift Detection

Reconciliation Output:
```bash

InputObject       SideIndicator
-----------       -------------
current-state.txt =>
desired-state.txt <=


```

Verify Drift Was Fixed:
```bash
version: 2.0
app: myapp
replicas: 5
```

### Task 1.4: Automated Continuous Reconciliation


Continuous reconciliation loop output:
```bash
./reconcile.sh: line 4: warning: command substitution: ignored null byte in input
./reconcile.sh: line 5: warning: command substitution: ignored null byte in input
Tue Oct 21 23:27:01 RTZ 2025 - ✅ States synchronized
./reconcile.sh: line 4: warning: command substitution: ignored null byte in input
./reconcile.sh: line 5: warning: command substitution: ignored null byte in input
Tue Oct 21 23:27:06 RTZ 2025 - ⚠️  DRIFT DETECTED!
Reconciling current state with desired state...
Tue Oct 21 23:27:06 RTZ 2025 - ✅ Reconciliation complete
./reconcile.sh: line 4: warning: command substitution: ignored null byte in input
./reconcile.sh: line 5: warning: command substitution: ignored null byte in input
Tue Oct 21 23:27:11 RTZ 2025 - ✅ States synchronized
```

### Analysis:

1. **Continuous Monitoring:** The loop runs at regular intervals (every 5 seconds in our simulation)
2. **State Comparison:** It compares the desired state from Git with the current cluster state
3. **Drift Detection:** Any differences between the two states are immediately detected
4. **Automatic Correction:** When drift is detected, the system automatically reconciles the current state to match the desired state
5. **Self-Healing:** This creates a closed-loop system that automatically corrects deviations without manual intervention

### Reflection: 

Advantages of declarative configuration in production:
1. **Reproducibility:** The entire system state is defined in code, making deployments consistent and repeatable across environments
2. **Auditability:** All changes are version-controlled in Git, providing a complete history of who changed what and when
3. **Self-Healing:** Automatic drift detection and correction reduces manual toil and human error
4. **Collaboration:** Multiple team members can review and approve changes through pull requests
5. **Disaster Recovery:** The entire infrastructure can be rebuilt from the Git repository

This approach significantly reduces configuration drift, improves stability, and enhances operational efficiency in production environments.

## Task 2 — GitOps Health Monitoring

### Task 2.1: Create Health Check Script

Contents of healthcheck.sh:
```
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

### Task 2.2: Test Health Monitoring

Test Healthy State Output:
```bash
Tue Oct 21 23:30:29 RTZ 2025 - ✅ OK: States synchronized
```

Health log after drift detection:
```bash
Tue Oct 21 23:30:29 RTZ 2025 - ✅ OK: States synchronized
Tue Oct 21 23:32:39 RTZ 2025 - ❌ CRITICAL: State mismatch detected!
  Desired MD5: 71a29f10311a1948c950c6f5528a5937
  Current MD5: 6ed6f9d4d12daea40d2144e2e22f1914
```

Output after reconciliation:
```bash
Tue Oct 21 23:30:29 RTZ 2025 - ✅ OK: States synchronized
Tue Oct 21 23:32:39 RTZ 2025 - ❌ CRITICAL: State mismatch detected!
  Desired MD5: 71a29f10311a1948c950c6f5528a5937
  Current MD5: 6ed6f9d4d12daea40d2144e2e22f1914
Tue Oct 21 23:34:03 RTZ 2025 - ✅ OK: States synchronized
```

### Task 2.3: Continuous Health Monitoring

Output from monitor.sh:
```bash
Starting GitOps monitoring...
\n--- Check #1 ---
Tue Oct 21 23:36:32 RTZ 2025 - ✅ OK: States synchronized
./reconcile.sh: line 4: warning: command substitution: ignored null byte in input
./reconcile.sh: line 5: warning: command substitution: ignored null byte in input
Tue Oct 21 23:36:33 RTZ 2025 - ✅ States synchronized
\n--- Check #2 ---
Tue Oct 21 23:36:36 RTZ 2025 - ✅ OK: States synchronized
./reconcile.sh: line 4: warning: command substitution: ignored null byte in input
./reconcile.sh: line 5: warning: command substitution: ignored null byte in input
Tue Oct 21 23:36:36 RTZ 2025 - ✅ States synchronized
\n--- Check #3 ---
Tue Oct 21 23:36:39 RTZ 2025 - ✅ OK: States synchronized
./reconcile.sh: line 4: warning: command substitution: ignored null byte in input
./reconcile.sh: line 5: warning: command substitution: ignored null byte in input
Tue Oct 21 23:36:39 RTZ 2025 - ✅ States synchronized
```

Complete health.log file:

```bash
Tue Oct 21 23:30:29 RTZ 2025 - ✅ OK: States synchronized
Tue Oct 21 23:32:39 RTZ 2025 - ❌ CRITICAL: State mismatch detected!
  Desired MD5: 71a29f10311a1948c950c6f5528a5937
  Current MD5: 6ed6f9d4d12daea40d2144e2e22f1914
Tue Oct 21 23:34:03 RTZ 2025 - ✅ OK: States synchronized
Tue Oct 21 23:36:32 RTZ 2025 - ✅ OK: States synchronized
Tue Oct 21 23:36:36 RTZ 2025 - ✅ OK: States synchronized
Tue Oct 21 23:36:39 RTZ 2025 - ✅ OK: States synchronized
```

### Analysis:

Checksums provide several advantages for configuration change detection:

1. **Cryptographic Integrity:** MD5 generates a unique fingerprint for file content, making it extremely unlikely for different content to produce the same hash
2. **Quick Comparison:** Comparing two 32-character strings is faster and more reliable than comparing entire file contents line by line
3. **Change Detection:** Any modification (additions, deletions, changes) to the file will result in a completely different checksum
4. **Tamper Evidence:** Unauthorized changes are immediately detectable through checksum mismatches
5. **Granular Monitoring:** Can detect even single character changes that might be visually hard to spot in large configuration files

### Comparison:

Similarities with ArgoCD:

1. **Continuous Monitoring:** Both continuously check desired vs current state
2. **Health Status Indicators:** Similar status reporting (✅ OK vs ❌ CRITICAL)
3. **Drift Detection:** Both detect configuration drift between source and deployment
4. **Automated Reconciliation:** Both can trigger automatic correction of drift
5. **Audit Logging:** Both maintain logs of synchronization events and issues

Key Differences:

1. **Scope:** Our script monitors simple text files, while ArgoCD monitors complex Kubernetes resources
2. **Intelligence:** ArgoCD understands Kubernetes semantics and resource relationships
3. **UI/Visualization:** ArgoCD provides web UI with detailed visualization of application state
4. **Multi-resource Management:** ArgoCD can manage entire application suites with dependencies
5. **Rollback Capabilities:** ArgoCD maintains revision history for easy rollbacks