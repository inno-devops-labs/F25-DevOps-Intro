# Lab 7

## Task 1

### 1.1
**Initial `desired-state.txt` and `current-state.txt` contents:**

`desired-state.txt` and `current-state.txt` files content the same:
```
version: 1.0
app: myapp
replicas: 3
```

---
### 1.3

```bash
echo "version: 2.0" > current-state.txt
echo "app: myapp" >> current-state.txt
echo "replicas: 5" >> current-state.txt
```

`current-state.txt` after drift:

```
version: 2.0
app: myapp
replicas: 5
```

`diff desired-state.txt current-state.txt`

output:

```bash
Sat Oct 18 11:54:32 AM UTC 2025 - ⚠️  DRIFT DETECTED!
Reconciling current state with desired state...
Sat Oct 18 11:54:32 AM UTC 2025 - ✅ Reconciliation complete
```

`cat current-state.txt`

output:
```
version: 1.0
app: myapp
replicas: 3
```
---
### 1.4

`watch -n 5 ./reconcile.sh`

in another terminal (trigger drift):

`echo "replicas: 10" >> current-state.txt`


output from continuous reconciliation loop:

```bash
Sat Oct 18 12:07:47 PM UTC 2025 - ✅ States synchronized
Sat Oct 18 12:08:30 PM UTC 2025 - ⚠️  DRIFT DETECTED!
Reconciling current state with desired state...
Sat Oct 18 12:08:30 PM UTC 2025 - ✅ Reconciliation complete
Sat Oct 18 12:08:35 PM UTC 2025 - ✅ States synchronized
```

---
**Explain the GitOps reconciliation loop. How does this prevent configuration drift?**

GitOps reconciliation loop is an endless process that is constantly:

1. сompares the desired state (from Git) with the current state of the system
2. detects discrepancies (configuration drift)
3. automatically corrects them, bringing the system to the desired state

How does this prevent configuration drift?

- constant monitoring — the system is checked every few seconds/minutes
- instant response — any manual change outside of Git is immediately detected
- automatic recovery — no manual intervention is needed to fix

---
**What advantages does declarative configuration have over imperative commands in production?**

- Focus on the result, not the process: the system itself determines the order of actions to achieve the final state
- Simpler and more readable code: declarative code is often shorter because you don't have to write a lot of instructions
- Simplified debugging and testing: the system itself is responsible for matching the current state to the desired one, which reduces the likelihood of errors
- Resilience to change: declarative configuration does a better job of managing dynamic environments by automatically handling changes (creation, update, deletion)


## Task 2

### 2.1
**Contents of `healthcheck.sh` script:**

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

### 2.2
```bash
./healthcheck.sh
cat health.log
```

output:

```bash
Sat Oct 18 03:27:08 PM UTC 2025 - ✅ OK: States synchronized
Sat Oct 18 03:27:08 PM UTC 2025 - ✅ OK: States synchronized
```
---
`echo "unapproved-change: true" >> current-state.txt`

---
```bash
./healthcheck.sh
cat health.log
```

output:

```bash
Sat Oct 18 03:28:04 PM UTC 2025 - ❌ CRITICAL: State mismatch detected!
  Desired MD5: a15a1a4f965ecd8f9e23a33a6b543155
  Current MD5: 48168ff3ab5ffc0214e81c7e2ee356f5
Sat Oct 18 03:27:08 PM UTC 2025 - ✅ OK: States synchronized
Sat Oct 18 03:28:04 PM UTC2025 - ❌ CRITICAL: State mismatch detected!
  Desired MD5: a15a1a4f965ecd8f9e23a33a6b543155
  Current MD5: 48168ff3ab5ffc0214e81c7e2ee356f5
```


### 2.3

`./monitor.sh`

output:

```bash
Starting GitOps monitoring...
\n--- Check #1 ---
Sat Oct 18 03:35:10 PM UTC 2025 - ❌ CRITICAL: State mismatch detected!
  Desired MD5: a15a1a4f965ecd8f9e23a33a6b543155
  Current MD5: 48168ff3ab5ffc0214e81c7e2ee356f5
Sat Oct 18 03:35:10 PM UTC 2025 - ⚠️  DRIFT DETECTED!
Reconciling current state with desired state...
Sat Oct 18 03:35:11 PM UTC 2025 - ✅ Reconciliation complete
\n--- Check #2 ---
Sat Oct 18 03:35:14 PM UTC 2025 - ✅ OK: States synchronized!
Sat Oct 18 03:35:14 PM UTC 2025 - ✅ States synchronized
\n--- Check #3 ---
Sat Oct 18 03:35:17 PM UTC 2025 - ✅ OK: States synchronized!
Sat Oct 18 03:35:17 PM UTC 2025 - ✅ States synchronized
\n--- Check #4 ---
Sat Oct 18 03:35:20 PM UTC 2025 - ✅ OK: States synchronized!
Sat Oct 18 03:35:20 PM UTC 2025 - ✅ States synchronized
\n--- Check #5 ---
Sat Oct 18 03:35:24 PM UTC 2025 - ✅ OK: States synchronized!
Sat Oct 18 03:35:24 PM UTC 2025 - ✅ States synchronized
\n--- Check #6 ---
Sat Oct 18 03:35:27 PM UTC 2025 - ✅ OK: States synchronized!
Sat Oct 18 03:35:27 PM UTC 2025 - ✅ States synchronized
\n--- Check #7 ---
Sat Oct 18 03:35:30 PM UTC 2025 - ✅ OK: States synchronized!
Sat Oct 18 03:35:30 PM UTC 2025 - ✅ States synchronized
\n--- Check #8 ---
Sat Oct 18 03:35:33 PM UTC 2025 - ✅ OK: States synchronized!
Sat Oct 18 03:35:33 PM UTC 2025 - ✅ States synchronized
\n--- Check #9 ---
Sat Oct 18 03:35:36 PM UTC 2025 - ✅ OK: States synchronized!
Sat Oct 18 03:35:36 PM UTC 2025 - ✅ States synchronized
\n--- Check #10 ---
Sat Oct 18 03:35:39 PM UTC 2025 - ✅ OK: States synchronized!
Sat Oct 18 03:35:39 PM UTC 2025 - ✅ States synchronized
```

---
`cat health.log`

output:

```bash
Sat Oct 18 03:27:08 PM UTC 2025 - ✅ OK: States synchronized!
Sat Oct 18 03:28:04 PM UTC 2025 - ❌ CRITICAL: State mismatch detected!
  Desired MD5: a15a1a4f965ecd8f9e23a33a6b543155
  Current MD5: 48168ff3ab5ffc0214e81c7e2ee356f5
Sat Oct 18 03:35:10 PM UTC 2025 - ❌ CRITICAL: State mismatch detected!
  Desired MD5: a15a1a4f965ecd8f9e23a33a6b543155
  Current MD5: 48168ff3ab5ffc0214e81c7e2ee356f5
Sat Oct 18 03:35:14 PM UTC 2025 - ✅ OK: States synchronized!
Sat Oct 18 03:35:17 PM UTC 2025 - ✅ OK: States synchronized!
Sat Oct 18 03:35:20 PM UTC 2025 - ✅ OK: States synchronized!
Sat Oct 18 03:35:24 PM UTC 2025 - ✅ OK: States synchronized!
Sat Oct 18 03:35:27 PM UTC 2025 - ✅ OK: States synchronized!
Sat Oct 18 03:35:30 PM UTC 2025 - ✅ OK: States synchronized!
Sat Oct 18 03:35:33 PM UTC 2025 - ✅ OK: States synchronized!
Sat Oct 18 03:35:36 PM UTC 2025 - ✅ OK: States synchronized!
Sat Oct 18 03:35:39 PM UTC 2025 - ✅ OK: States synchronized!
```

---
**How do checksums (MD5) help detect configuration changes?**

MD5 checksums detect configuration changes by generating a unique 128-bit hash (a 32-digit hexadecimal number) for the configuration file. If the file is changed, even slightly, the new hash will be completely different. By comparing the current hash with the reference hash, you can instantly determine if an unauthorized change has been made or if the file has been corrupted.

---
**How does this relate to GitOps tools like ArgoCD's "Sync Status"?**

1. **The same principle of comparison** - ArgoCD constantly compares:
    - The desired state (manifests in Git)
    - The actual state (deployed in Kubernetes)

2. **Checksums and Hashes** - ArgoCD uses a similar mechanism, computing configuration hashes for quick comparison

3. **Sync statuses** are similar to our health checks:
    - `Synced` = OK (the states are synchronized)
   - `OutOfSync` = CRITICAL (drift detected)

4. **Automatic correction** - similar to our script `reconcile.sh`, ArgoCD automatically applies changes from Git when discrepancies are found.

5. **Logging and Monitoring** - ArgoCD keeps detailed logs of all synchronization operations, similar to our `health.log`