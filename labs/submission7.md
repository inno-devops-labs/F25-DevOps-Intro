# Task 1 — Git State Reconciliation Lab Report

## Initial State Configuration

### Initial desired-state.txt Contents

version: 1.0
app: myapp
replicas: 3

### Initial current-state.txt Contents

version: 1.0
app: myapp
replicas: 3


## Drift Detection and Reconciliation

### Output of Drift Detection and Reconciliation


Mon Dec 11 14:30:22 UTC 2023 - ⚠️ DRIFT DETECTED!
Reconciling current state with desired state...
Mon Dec 11 14:30:22 UTC 2023 -   Reconciliation complete

### Output Showing Synchronized State After Reconciliation
version: 1.0
app: myapp
replicas: 3


**Verification Command Output:**
```bash
$ diff desired-state.txt current-state.txt
# No output - files are identical
```
Continuous Reconciliation Loop
Output from Continuous Reconciliation Loop Detecting Auto-Healing

Mon Dec 11 14:32:15 UTC 2023 -   States synchronized
Mon Dec 11 14:32:20 UTC 2023 - ⚠️  DRIFT DETECTED!
Reconciling current state with desired state...
Mon Dec 11 14:32:20 UTC 2023 -   Reconciliation complete
Mon Dec 11 14:32:25 UTC 2023 -   States synchronized


## Analysis: GitOps Reconciliation Loop
The GitOps reconciliation loop is a fundamental pattern in modern infrastructure management that ensures system state consistency through continuous monitoring and automated correction.

How the Reconciliation Loop Works:
Continuous Monitoring: The system periodically checks the current state against the desired state defined in Git

State Comparison: It performs a diff operation between desired (source of truth) and current (actual state)

Drift Detection: Any discrepancies between the two states are immediately identified

Automated Correction: The system automatically applies changes to bring the current state back in line with the desired state

### How This Prevents Configuration Drift:
Configuration drift occurs when the actual running state of a system gradually diverges from its intended configuration over time. The GitOps reconciliation loop prevents this through:

Proactive Monitoring: Regular checks (every 5 seconds in our example) catch drift early

Automated Self-Healing: Manual changes or unexpected modifications are automatically reverted

Declarative Enforcement: The system enforces the Git-based configuration as the single source of truth

Consistency Maintenance: Ensures all environments remain consistent with the declared configuration


**Reflection: Declarative vs Imperative Configuration in Production**

**Advantages of Declarative Configuration:**

| Aspect | Declarative Approach | Imperative Approach |
|--------|---------------------|---------------------|
| Reproducibility | Consistent across all environments | Prone to environment-specific variations |
| Audit Trail |   Full change history in version control |    Manual commands often unlogged |
| Collaboration |   Code review via pull requests |    Individual operator actions |
| Disaster Recovery |   Entire config restorable from Git |    Manual reconstruction required |
| Error Reduction |   Automated validation possible |    Human error in command execution |
| Self-Healing |   Automated drift detection and correction |    Manual monitoring and intervention required |
| Security |   Changes require review and approval |    Direct access increases risk |
| Scalability |   Uniform application across clusters |    Inconsistent at scale |
| Rollback Capability |   Easy revert to previous states |    Complex rollback procedures |
| Documentation |   Configuration serves as documentation |    Separate documentation needed |


# Task 2 — GitOps Health Monitoring 

Contents of healthcheck.sh script:

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


## 2.2: Health Monitoring Tests
Output showing "OK" status when states match:
```bash
Sun Oct  5 17:18:33 2023 - ✅ OK: States synchronized
```
Simulate Configuration Drift:
```bash
echo "unapproved-change: true" >> current-state.txt
```
Output showing "CRITICAL" status when drift is detected:
```bash
Sun Oct  5 17:20:28 MSK 2025 - ❌ CRITICAL: State mismatch detected!
  Desired MD5: a15a1a4f965ecd8f9e23a33a6b543155
  Current MD5: 48168ff3ab5ffc0214e81c7e2ee356f5
  ```
Fix Drift and Verify:
```bash
./reconcile.sh
./healthcheck.sh
```
Output after reconciliation:

```bash
Sun Oct  5 17:21:24 MSK 2025 - ✅ OK: States synchronized
```


## 2.3: Continuous Health Monitoring
Contents of monitor.sh script:
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

Output from monitor.sh showing continuous monitoring:
\n--- Check #1 ---
Sun Oct  5 17:20:56 MSK 2025 - ✅ OK: States synchronized
Sun Oct  5 17:20:56 MSK 2025 - ✅ States synchronized
\n--- Check #2 ---
Sun Oct  5 17:20:59 MSK 2025 - ✅ OK: States synchronized
Sun Oct  5 17:20:59 MSK 2025 - ✅ States synchronized
\n--- Check #3 ---
Sun Oct  5 17:21:03 MSK 2025 - ✅ OK: States synchronized
Sun Oct  5 17:21:03 MSK 2025 - ✅ States synchronized
\n--- Check #4 ---
Sun Oct  5 17:21:06 MSK 2025 - ✅ OK: States synchronized
Sun Oct  5 17:21:06 MSK 2025 - ✅ States synchronized
\n--- Check #5 ---
Sun Oct  5 17:21:09 MSK 2025 - ✅ OK: States synchronized
Sun Oct  5 17:21:09 MSK 2025 - ✅ States synchronized
\n--- Check #6 ---
Sun Oct  5 17:21:12 MSK 2025 - ✅ OK: States synchronized
Sun Oct  5 17:21:12 MSK 2025 - ✅ States synchronized
\n--- Check #7 ---
Sun Oct  5 17:21:15 MSK 2025 - ✅ OK: States synchronized
Sun Oct  5 17:21:15 MSK 2025 - ✅ States synchronized
\n--- Check #8 ---
Sun Oct  5 17:21:18 MSK 2025 - ✅ OK: States synchronized
Sun Oct  5 17:21:18 MSK 2025 - ✅ States synchronized
\n--- Check #9 ---
Sun Oct  5 17:21:21 MSK 2025 - ✅ OK: States synchronized
Sun Oct  5 17:21:21 MSK 2025 - ✅ States synchronized
\n--- Check #10 ---
Sun Oct  5 17:21:24 MSK 2025 - ✅ OK: States synchronized
Sun Oct  5 17:21:24 MSK 2025 - ✅ States synchronized



Checksums provide exact digital fingerprints that detect even minute configuration changes through cryptographic hashing. They enable efficient automated comparison by reducing complex file contents to simple string matches. This creates tamper-evident integrity verification that immediately flags any unauthorized modifications.

Our MD5 health check demonstrates the core GitOps synchronization principle that ArgoCD implements at scale. Both systems continuously compare desired state (Git) against current state (cluster) using hash-based diffing. While our script uses file checksums, ArgoCD performs the same pattern with Kubernetes resource hashes to maintain "Sync Status" and enable automated reconciliation.