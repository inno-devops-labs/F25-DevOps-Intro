# Lab 7 — GitOps Fundamentals

## Task 1 — Git State Reconciliation

### Test Manual Drift Detection

**Command(s):**
- echo "version: 2.0" > current-state.txt
- echo "app: myapp" >> current-state.txt
- echo "replicas: 5" >> current-state.txt
- ./reconcile.sh

**Output:**
```
spiriton@LAPTOP-TNLQNHEC:~$ ./reconcile.sh
Tue Oct 28 02:47:46 MSK 2025 - ⚠️  DRIFT DETECTED!
Reconciling current state with desired state...
Tue Oct 28 02:47:46 MSK 2025 - ✅ Reconciliation complete
```

**Command(s):**
- diff desired-state.txt current-state.txt

**Output:**

No output

### Automated Continuous Reconciliation

**Start continuous loop**
- watch -n 5 ./reconcile.sh

**Observed output**
```
Tue Oct 28 03:16:13 MSK 2025 - ✅ States synchronized
```

**In another terminal, simulate drift**
- echo "replicas: 10" >> current-state.txt

**Observed output**
```
Tue Oct 28 03:16:33 MSK 2025 - ⚠️  DRIFT DETECTED!
Reconciling current state with desired state...
Tue Oct 28 03:16:33 MSK 2025 - ✅ Reconciliation complete

Tue Oct 28 03:16:43 MSK 2025 - ✅ States synchronized
```

**Analysis:** The GitOps reconciliation loop continuously compares the current system state with the desired state stored in Git. When drift is detected, it automatically restores the system to match Git, ensuring consistency, traceability, and self-healing.

**Reflection:** Declarative configuration defines what the system should look like rather than how to achieve it, enabling automation, predictability, easier auditing, and prevention of drift, unlike imperative commands which are manual and error-prone.

## Task 2 — GitOps Health Monitoring

### Health Check Script

**healthcheck.sh**
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

### Test Health Monitoring

**Healthy state check**

**Command(s):**
- ./healthcheck.sh
- cat health.log

**Output:**
```
spiriton@LAPTOP-TNLQNHEC:~$ ./healthcheck.sh
Tue Oct 28 03:27:15 MSK 2025 - ✅ OK: States synchronized

spiriton@LAPTOP-TNLQNHEC:~$ cat health.log
Tue Oct 28 03:27:15 MSK 2025 - ✅ OK: States synchronized
```

**Simulate configuration drift**

**Command(s):**
- echo "unapproved-change: true" >> current-state.txt
- ./healthcheck.sh
- cat health.log

**Output:**
```
spiriton@LAPTOP-TNLQNHEC:~$ echo "unapproved-change: true" >> current-state.txt

spiriton@LAPTOP-TNLQNHEC:~$ ./healthcheck.sh
Tue Oct 28 03:27:38 MSK 2025 - ❌ CRITICAL: State mismatch detected!
  Desired MD5: a15a1a4f965ecd8f9e23a33a6b543155
  Current MD5: 48168ff3ab5ffc0214e81c7e2ee356f5
  
spiriton@LAPTOP-TNLQNHEC:~$ cat health.log
Tue Oct 28 03:27:15 MSK 2025 - ✅ OK: States synchronized
Tue Oct 28 03:27:38 MSK 2025 - ❌ CRITICAL: State mismatch detected!
  Desired MD5: a15a1a4f965ecd8f9e23a33a6b543155
  Current MD5: 48168ff3ab5ffc0214e81c7e2ee356f5
```

**Fix drift and verify**

**Command(s):**
- ./reconcile.sh
- ./healthcheck.sh
- cat health.log

**Output:**
```
spiriton@LAPTOP-TNLQNHEC:~$ ./reconcile.sh
Tue Oct 28 03:28:28 MSK 2025 - ⚠️  DRIFT DETECTED!
Reconciling current state with desired state...
Tue Oct 28 03:28:28 MSK 2025 - ✅ Reconciliation complete
spiriton@LAPTOP-TNLQNHEC:~$ ./healthcheck.sh
Tue Oct 28 03:28:35 MSK 2025 - ✅ OK: States synchronized
spiriton@LAPTOP-TNLQNHEC:~$ cat health.log
Tue Oct 28 03:27:15 MSK 2025 - ✅ OK: States synchronized
Tue Oct 28 03:27:38 MSK 2025 - ❌ CRITICAL: State mismatch detected!
  Desired MD5: a15a1a4f965ecd8f9e23a33a6b543155
  Current MD5: 48168ff3ab5ffc0214e81c7e2ee356f5
Tue Oct 28 03:28:35 MSK 2025 - ✅ OK: States synchronized
```

---

### Continuous Health Monitoring

**Command(s):**
- ./monitor.sh
- cat health.log

**Output:**
```
spiriton@LAPTOP-TNLQNHEC:~$ ./monitor.sh
Starting GitOps monitoring...
\n--- Check #1 ---
Tue Oct 28 03:30:23 MSK 2025 - ✅ OK: States synchronized
Tue Oct 28 03:30:23 MSK 2025 - ✅ States synchronized
\n--- Check #2 ---
Tue Oct 28 03:30:26 MSK 2025 - ✅ OK: States synchronized
Tue Oct 28 03:30:26 MSK 2025 - ✅ States synchronized
\n--- Check #3 ---
Tue Oct 28 03:30:29 MSK 2025 - ✅ OK: States synchronized
Tue Oct 28 03:30:29 MSK 2025 - ✅ States synchronized
\n--- Check #4 ---
Tue Oct 28 03:30:32 MSK 2025 - ✅ OK: States synchronized
Tue Oct 28 03:30:32 MSK 2025 - ✅ States synchronized
\n--- Check #5 ---
Tue Oct 28 03:30:35 MSK 2025 - ✅ OK: States synchronized
Tue Oct 28 03:30:35 MSK 2025 - ✅ States synchronized
\n--- Check #6 ---
Tue Oct 28 03:30:38 MSK 2025 - ✅ OK: States synchronized
Tue Oct 28 03:30:38 MSK 2025 - ✅ States synchronized
\n--- Check #7 ---
Tue Oct 28 03:30:41 MSK 2025 - ✅ OK: States synchronized
Tue Oct 28 03:30:41 MSK 2025 - ✅ States synchronized
\n--- Check #8 ---
Tue Oct 28 03:30:44 MSK 2025 - ✅ OK: States synchronized
Tue Oct 28 03:30:44 MSK 2025 - ✅ States synchronized
\n--- Check #9 ---
Tue Oct 28 03:30:47 MSK 2025 - ✅ OK: States synchronized
Tue Oct 28 03:30:47 MSK 2025 - ✅ States synchronized
\n--- Check #10 ---
Tue Oct 28 03:30:50 MSK 2025 - ✅ OK: States synchronized
Tue Oct 28 03:30:50 MSK 2025 - ✅ States synchronized

spiriton@LAPTOP-TNLQNHEC:~$ cat health.log
Tue Oct 28 03:27:15 MSK 2025 - ✅ OK: States synchronized
Tue Oct 28 03:27:38 MSK 2025 - ❌ CRITICAL: State mismatch detected!
  Desired MD5: a15a1a4f965ecd8f9e23a33a6b543155
  Current MD5: 48168ff3ab5ffc0214e81c7e2ee356f5
Tue Oct 28 03:28:35 MSK 2025 - ✅ OK: States synchronized
Tue Oct 28 03:30:23 MSK 2025 - ✅ OK: States synchronized
Tue Oct 28 03:30:26 MSK 2025 - ✅ OK: States synchronized
Tue Oct 28 03:30:29 MSK 2025 - ✅ OK: States synchronized
Tue Oct 28 03:30:32 MSK 2025 - ✅ OK: States synchronized
Tue Oct 28 03:30:35 MSK 2025 - ✅ OK: States synchronized
Tue Oct 28 03:30:38 MSK 2025 - ✅ OK: States synchronized
Tue Oct 28 03:30:41 MSK 2025 - ✅ OK: States synchronized
Tue Oct 28 03:30:44 MSK 2025 - ✅ OK: States synchronized
Tue Oct 28 03:30:47 MSK 2025 - ✅ OK: States synchronized
Tue Oct 28 03:30:50 MSK 2025 - ✅ OK: States synchronized
```

**Analysis:** MD5 checksums detect configuration changes by producing a unique fingerprint for each file, so any modification immediately shows a mismatch.

**Comparison:** This is similar to GitOps tools like ArgoCD, where the sync status indicates whether the cluster state matches the desired state in Git and triggers reconciliation if not.