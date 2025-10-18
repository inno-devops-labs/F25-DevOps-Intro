# Lab 7 — GitOps and Configuration Management

## Task 1 — Git State Reconciliation

### 1.1: Setup Desired State Configuration

**Make directory:**

```bash
> mkdir gitops-lab && cd gitops-lab
```

**Create Desired State (Source of Truth):**

```bash
> echo "version: 1.0" > desired-state.txt
> echo "app: myapp" >> desired-state.txt
> echo "replicas: 3" >> desired-state.txt
```

**Initial desired-state.txt contents:**

```txt
version: 1.0
app: myapp
replicas: 3
```


**Simulate Current Cluster State:**

```bash
> cp desired-state.txt current-state.txt
> echo "Initial state synchronized"
```


**Initial current-state.txt contents:**

```txt
version: 1.0
app: myapp
replicas: 3
```


### 1.2: Create Reconciliation Loop

**Create Reconciliation Script:**

Created file `reconcile.sh`:

```bash
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

**Make Script Executable:**

```bash
> chmod +x reconcile.sh
```



### 1.3: Test Manual Drift Detection

**Simulate Manual Drift:**


```bash
> echo "version: 2.0" > current-state.txt
> echo "app: myapp" >> current-state.txt
> echo "replicas: 5" >> current-state.txt
```


**Current state after drift:**

```txt
version: 2.0
app: myapp
replicas: 5
```

**Run Reconciliation Manually:**

```bash
> ./reconcile.sh
Sat Oct 18 21:51:25 MSK 2025 - ⚠️  DRIFT DETECTED!
Reconciling current state with desired state...
Sat Oct 18 21:51:25 MSK 2025 - ✅ Reconciliation complete
```

```bash
> diff desired-state.txt current-state.txt # No output
```


**Verify Drift Was Fixed:**

```bash
> cat current-state.txt
version: 1.0
app: myapp
replicas: 3
```

### 1.4: Automated Continuous Reconciliation

**Start Continuous Reconciliation Loop:**


```bash
> watch -n 5 ./reconcile.sh
```

**In Another Terminal, Trigger Drift:**


```bash
> cd gitops-lab
> echo "replicas: 10" >> current-state.txt
```


**Observe Auto-Healing:**

```bash
Sat Oct 18 22:01:04 MSK 2025 - ✅ States synchronized

Sat Oct 18 22:01:15 MSK 2025 - ⚠️  DRIFT DETECTED!
Reconciling current state with desired state...
Sat Oct 18 22:01:15 MSK 2025 - ✅ Reconciliation complete

Sat Oct 18 22:01:20 MSK 2025 - ✅ States synchronized
```

### Task 1 Analysis

#### Initial desired-state.txt and current-state.txt contents

**desired-state.txt:**

```txt
version: 1.0
app: myapp
replicas: 3
```

**current-state.txt (after initial sync):**

```txt
version: 1.0
app: myapp
replicas: 3
```

#### Screenshot or output of drift detection and reconciliation

**Drift Detection Output:**

```bash
Sat Oct 18 21:51:25 MSK 2025 - ⚠️  DRIFT DETECTED!
Reconciling current state with desired state...
Sat Oct 18 21:51:25 MSK 2025 - ✅ Reconciliation complete
```

#### Output showing synchronized state after reconciliation

**Synchronized State:**

```bash
version: 1.0
app: myapp
replicas: 3
```

#### Output from continuous reconciliation loop detecting auto-healing

**Auto-Healing Detection:**

```bash
Sat Oct 18 22:01:04 MSK 2025 - ✅ States synchronized

Sat Oct 18 22:01:15 MSK 2025 - ⚠️  DRIFT DETECTED!
Reconciling current state with desired state...
Sat Oct 18 22:01:15 MSK 2025 - ✅ Reconciliation complete

Sat Oct 18 22:01:20 MSK 2025 - ✅ States synchronized
```

#### Analysis: Explain the GitOps reconciliation loop. How does this prevent configuration drift?

The GitOps reconciliation loop is a continuous monitoring and correction mechanism that ensures the actual system state matches the desired state stored in Git. Here's how it works:

**1. Continuous Monitoring:**
- The system regularly compares the current state with the desired state
- This happens automatically at regular intervals (every 5 seconds in our simulation)

**2. Drift Detection:**
- When the current state differs from the desired state, drift is detected
- The system immediately identifies what needs to be corrected

**3. Automatic Correction:**
- When drift is detected, the system automatically applies the desired state
- This self-healing capability prevents manual intervention

**4. Prevention of Configuration Drift:**
- **Proactive Monitoring**: Continuously checks for unauthorized changes
- **Immediate Response**: Detects and corrects drift within seconds
- **Self-Healing**: Automatically restores the correct configuration
- **Git as Source of Truth**: All changes must go through Git, preventing ad-hoc modifications

#### Reflection: What advantages does declarative configuration have over imperative commands in production?

**Declarative Configuration Advantages:**

1. **Predictability**: You define the end state, not the steps to get there
2. **Idempotency**: Running the same configuration multiple times produces the same result
3. **Auditability**: All changes are tracked in Git with clear history
4. **Rollback Capability**: Easy to revert to previous known good states
5. **Consistency**: Same configuration across all environments (dev, staging, prod)
6. **Self-Healing**: Automatic correction of unauthorized changes
7. **Collaboration**: Multiple team members can review changes through Git
8. **Version Control**: Full history of configuration changes
9. **Compliance**: Easier to meet regulatory requirements with auditable changes
10. **Reduced Human Error**: Less manual intervention means fewer mistakes



## Task 2 — GitOps Health Monitoring

### 2.1: Create Health Check Script


**Create Health Check Script:**

Created file `healthcheck.sh`:

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

**Make Script Executable:**

```bash
> chmod +x healthcheck.sh
```


### 2.2: Test Health Monitoring

**Test Healthy State:**

```bash
> ./healthcheck.sh
Sat Oct 18 22:04:59 MSK 2025 - ✅ OK: States synchronized
```

```bash
> cat health.log
Sat Oct 18 22:04:59 MSK 2025 - ✅ OK: States synchronized
```


**Simulate Configuration Drift:**

```bash
> echo "unapproved-change: true" >> current-state.txt
```

**Run Health Check on Drifted State:**

```bash
> ./healthcheck.sh
Sat Oct 18 22:05:44 MSK 2025 - ❌ CRITICAL: State mismatch detected!
  Desired MD5: a15a1a4f965ecd8f9e23a33a6b543155
  Current MD5: 48168ff3ab5ffc0214e81c7e2ee356f5
```

```bash
> cat health.log
Sat Oct 18 22:04:59 MSK 2025 - ✅ OK: States synchronized
Sat Oct 18 22:05:44 MSK 2025 - ❌ CRITICAL: State mismatch detected!
  Desired MD5: a15a1a4f965ecd8f9e23a33a6b543155
  Current MD5: 48168ff3ab5ffc0214e81c7e2ee356f5
```

**Fix Drift and Verify:**


```bash
> ./reconcile.sh
Sat Oct 18 22:08:03 MSK 2025 - ⚠️  DRIFT DETECTED!
Reconciling current state with desired state...
Sat Oct 18 22:08:03 MSK 2025 - ✅ Reconciliation complete
```

```bash
> ./healthcheck.sh
Sat Oct 18 22:08:16 MSK 2025 - ✅ OK: States synchronized
```

```bash
> cat health.log
Sat Oct 18 22:04:59 MSK 2025 - ✅ OK: States synchronized
Sat Oct 18 22:05:44 MSK 2025 - ❌ CRITICAL: State mismatch detected!
  Desired MD5: a15a1a4f965ecd8f9e23a33a6b543155
  Current MD5: 48168ff3ab5ffc0214e81c7e2ee356f5
Sat Oct 18 22:08:16 MSK 2025 - ✅ OK: States synchronized
```


### 2.3: Continuous Health Monitoring

**Create Combined Monitoring Script:**

Created file `monitor.sh`:

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

```bash
> chmod +x monitor.sh
```

**Run Monitoring Loop:**

Command:

```bash
> ./monitor.sh
Starting GitOps monitoring...
\n--- Check #1 ---
Sat Oct 18 22:08:55 MSK 2025 - ✅ OK: States synchronized
Sat Oct 18 22:08:55 MSK 2025 - ✅ States synchronized
\n--- Check #2 ---
Sat Oct 18 22:08:58 MSK 2025 - ✅ OK: States synchronized
Sat Oct 18 22:08:58 MSK 2025 - ✅ States synchronized
\n--- Check #3 ---
Sat Oct 18 22:09:01 MSK 2025 - ✅ OK: States synchronized
Sat Oct 18 22:09:01 MSK 2025 - ✅ States synchronized
\n--- Check #4 ---
Sat Oct 18 22:09:04 MSK 2025 - ✅ OK: States synchronized
Sat Oct 18 22:09:04 MSK 2025 - ✅ States synchronized
\n--- Check #5 ---
Sat Oct 18 22:09:07 MSK 2025 - ✅ OK: States synchronized
Sat Oct 18 22:09:07 MSK 2025 - ✅ States synchronized
```


**Review Complete Health Log:**

```bash
> cat health.log
Sat Oct 18 22:04:59 MSK 2025 - ✅ OK: States synchronized
Sat Oct 18 22:05:44 MSK 2025 - ❌ CRITICAL: State mismatch detected!
  Desired MD5: a15a1a4f965ecd8f9e23a33a6b543155
  Current MD5: 48168ff3ab5ffc0214e81c7e2ee356f5
Sat Oct 18 22:08:16 MSK 2025 - ✅ OK: States synchronized
Sat Oct 18 22:08:55 MSK 2025 - ✅ OK: States synchronized
Sat Oct 18 22:08:58 MSK 2025 - ✅ OK: States synchronized
Sat Oct 18 22:09:01 MSK 2025 - ✅ OK: States synchronized
Sat Oct 18 22:09:04 MSK 2025 - ✅ OK: States synchronized
Sat Oct 18 22:09:07 MSK 2025 - ✅ OK: States synchronized
```



### Task 2 Analysis

#### Contents of healthcheck.sh script

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


#### Output showing "OK" status when states match

```bash
Sat Oct 18 22:04:59 MSK 2025 - ✅ OK: States synchronized
```


#### Output showing "CRITICAL" status when drift is detected

```bash
Sat Oct 18 22:05:44 MSK 2025 - ❌ CRITICAL: State mismatch detected!
  Desired MD5: a15a1a4f965ecd8f9e23a33a6b543155
  Current MD5: 48168ff3ab5ffc0214e81c7e2ee356f5
```


#### Complete health.log file showing multiple checks

```bash
Sat Oct 18 22:04:59 MSK 2025 - ✅ OK: States synchronized
Sat Oct 18 22:05:44 MSK 2025 - ❌ CRITICAL: State mismatch detected!
  Desired MD5: a15a1a4f965ecd8f9e23a33a6b543155
  Current MD5: 48168ff3ab5ffc0214e81c7e2ee356f5
Sat Oct 18 22:08:16 MSK 2025 - ✅ OK: States synchronized
Sat Oct 18 22:08:55 MSK 2025 - ✅ OK: States synchronized
Sat Oct 18 22:08:58 MSK 2025 - ✅ OK: States synchronized
Sat Oct 18 22:09:01 MSK 2025 - ✅ OK: States synchronized
Sat Oct 18 22:09:04 MSK 2025 - ✅ OK: States synchronized
Sat Oct 18 22:09:07 MSK 2025 - ✅ OK: States synchronized
```


#### Output from monitor.sh showing continuous monitoring

```bash
Starting GitOps monitoring...
\n--- Check #1 ---
Sat Oct 18 22:08:55 MSK 2025 - ✅ OK: States synchronized
Sat Oct 18 22:08:55 MSK 2025 - ✅ States synchronized
\n--- Check #2 ---
Sat Oct 18 22:08:58 MSK 2025 - ✅ OK: States synchronized
Sat Oct 18 22:08:58 MSK 2025 - ✅ States synchronized
\n--- Check #3 ---
Sat Oct 18 22:09:01 MSK 2025 - ✅ OK: States synchronized
Sat Oct 18 22:09:01 MSK 2025 - ✅ States synchronized
\n--- Check #4 ---
Sat Oct 18 22:09:04 MSK 2025 - ✅ OK: States synchronized
Sat Oct 18 22:09:04 MSK 2025 - ✅ States synchronized
\n--- Check #5 ---
Sat Oct 18 22:09:07 MSK 2025 - ✅ OK: States synchronized
Sat Oct 18 22:09:07 MSK 2025 - ✅ States synchronized
```


#### Analysis: How do checksums (MD5) help detect configuration changes?

Checksums (MD5) are crucial for detecting configuration changes because they provide:

**1. Integrity Verification:**
- MD5 creates a unique fingerprint (hash) of file content
- Any change to the file, no matter how small, changes the hash
- This provides a reliable way to detect modifications

**2. Efficient Change Detection:**
- Instead of comparing entire file contents, we compare short hash strings
- Much faster than line-by-line comparison for large files
- Enables quick detection of any changes

**3. Tamper Detection:**
- Unauthorized changes are immediately detectable
- Even minor modifications (like adding a space) change the hash
- Provides security against configuration tampering

**4. Version Tracking:**
- Different versions of files have different checksums
- Easy to identify which version is currently deployed
- Enables rollback to specific known good states

**5. Audit Trail:**
- Checksums provide cryptographic proof of file integrity
- Can be used for compliance and auditing purposes
- Creates immutable record of configuration states

#### Comparison: How does this relate to GitOps tools like ArgoCD's "Sync Status"?

This simulation closely mirrors how ArgoCD's "Sync Status" works in production:

**Similarities:**

1. **Continuous Monitoring**: Both continuously check state consistency
2. **Health Status Reporting**: Both report healthy/synced or unhealthy/out-of-sync states
3. **Automatic Reconciliation**: Both automatically correct drift when detected
4. **Comprehensive Logging**: Both maintain detailed logs of sync operations and health checks
5. **Alerting Capabilities**: Both can trigger alerts when drift is detected
6. **Git as Source of Truth**: Both use Git as the single source of truth
7. **Declarative Configuration**: Both work with declarative configuration files

**Key Differences:**

1. **Scale**: ArgoCD manages complex Kubernetes resources, while our simulation manages simple text files
2. **Complexity**: ArgoCD handles dependencies, resource relationships, and complex state transitions
3. **Performance**: ArgoCD is optimized for high-frequency monitoring and large-scale deployments
4. **Integration**: ArgoCD integrates with Kubernetes API, RBAC, and other enterprise systems
5. **Features**: ArgoCD provides advanced features like sync waves, hooks, and multi-cluster management

**Production Benefits:**
- **Enterprise Scale**: Handles thousands of applications across multiple clusters
- **Advanced Sync Strategies**: Supports blue-green, canary, and progressive deployments
- **Security**: Integrates with enterprise authentication and authorization systems
- **Observability**: Provides detailed metrics, dashboards, and alerting
- **Compliance**: Meets enterprise security and audit requirements

This simulation provides the fundamental understanding needed to work with production GitOps tools like ArgoCD and Flux CD.
