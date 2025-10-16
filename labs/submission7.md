# Lab 7 — GitOps Fundamentals: Submission (Complete)

- **Environment:** Windows, Git Bash.
- **Note:** initial files were saved as UTF‑16 LE which caused bash warnings `ignored null byte`; after converting to UTF‑8 the warnings disappear.

---

## Task 1 — Git State Reconciliation

### 1.1 Initial `desired-state.txt` and `current-state.txt` contents
```text
version: 1.0
app: myapp
replicas: 3
```
Both files were synchronized initially.

### 1.2 Reconciliation script used
`reconcile.sh` (from the handout):
```bash
#!/bin/bash
# reconcile.sh - GitOps reconciliation loop

DESIRED=$(cat desired-state.txt 2>/dev/null)
CURRENT=$(cat current-state.txt 2>/dev/null)

if [ -z "$DESIRED" ] || [ -z "$CURRENT" ]; then
  echo "$(date) - ⚠️  Files missing. Creating baseline..."
  echo "version: 1.0" > desired-state.txt
  echo "app: myapp" >> desired-state.txt
  echo "replicas: 3" >> desired-state.txt
  cp desired-state.txt current-state.txt
  echo "$(date) - ✅ Baseline initialized"
  exit 0
fi

if [ "$DESIRED" != "$CURRENT" ]; then
    echo "$(date) - ⚠️  DRIFT DETECTED!"
    echo "Reconciling current state with desired state..."
    cp desired-state.txt current-state.txt
    echo "$(date) - ✅ Reconciliation complete"
else
    echo "$(date) - ✅ States synchronized"
fi
```

### 1.3 Screenshot or output of drift detection and reconciliation
```text
Thu Oct 16 10:44:42 RTZ 2025 - ❌ CRITICAL: State mismatch detected!
  Desired MD5: 71a29f10311a1948c950c6f5528a5937
  Current MD5: 6ed6f9d4d12daea40d2144e2e22f1914

./reconcile.sh
./reconcile.sh: line 4: warning: command substitution: ignored null byte in input
./reconcile.sh: line 5: warning: command substitution: ignored null byte in input
Thu Oct 16 10:44:53 RTZ 2025 - ⚠️  DRIFT DETECTED!
Reconciling current state with desired state...
Thu Oct 16 10:44:53 RTZ 2025 - ✅ Reconciliation complete
```

### 1.4 Output showing synchronized state after reconciliation
```text
./healthcheck.sh
Thu Oct 16 10:45:02 RTZ 2025 - ✅ OK: States synchronized
```

### 1.5 Output from continuous reconciliation loop detecting auto‑healing
`monitor.sh` run:
```text
Starting GitOps monitoring...

--- Check #1 ---
Thu Oct 16 10:45:42 RTZ 2025 - ✅ OK: States synchronized
./reconcile.sh: line 4: warning: command substitution: ignored null byte in input
./reconcile.sh: line 5: warning: command substitution: ignored null byte in input
Thu Oct 16 10:45:42 RTZ 2025 - ✅ States synchronized

--- Check #2 ---
Thu Oct 16 10:45:46 RTZ 2025 - ✅ OK: States synchronized
./reconcile.sh: line 4: warning: command substitution: ignored null byte in input
./reconcile.sh: line 5: warning: command substitution: ignored null byte in input
Thu Oct 16 10:45:46 RTZ 2025 - ✅ States synchronized

--- Check #3 ---
Thu Oct 16 10:45:49 RTZ 2025 - ✅ OK: States synchronized
./reconcile.sh: line 4: warning: command substitution: ignored null byte in input
./reconcile.sh: line 5: warning: command substitution: ignored null byte in input
Thu Oct 16 10:45:49 RTZ 2025 - ✅ States synchronized
```

### 1.6 Analysis: How the GitOps reconciliation loop prevents drift
- Controller compares **desired** state (in Git) with **current** state (runtime).
- On mismatch, it **overwrites** the current state from the desired one.
- This creates an **idempotent** feedback loop that continuously corrects configuration drift caused by manual or out‑of‑band changes.

### 1.7 Reflection: Declarative vs imperative in production
- **Declarative (GitOps):** you describe *what* the system should be. Benefits: auditability, versioning, reproducible rollbacks, automated convergence, safer collaboration via PRs.
- **Imperative:** you describe *how* to get there via mutable commands. Risks: hidden state, snowflake servers, poor audit trail, higher MTTR after incidents.

---

## Task 2 — GitOps Health Monitoring

### 2.1 Contents of `healthcheck.sh` script
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

### 2.2 Output showing **OK** when states match
```text
Thu Oct 16 10:44:16 RTZ 2025 - ✅ OK: States synchronized
```

### 2.3 Output showing **CRITICAL** when drift is detected
```text
Thu Oct 16 10:44:42 RTZ 2025 - ❌ CRITICAL: State mismatch detected!
  Desired MD5: 71a29f10311a1948c950c6f5528a5937
  Current MD5: 6ed6f9d4d12daea40d2144e2e22f1914
```

### 2.4 Complete `health.log` file showing multiple checks
```text
Thu Oct 16 10:44:16 RTZ 2025 - ✅ OK: States synchronized
Thu Oct 16 10:44:42 RTZ 2025 - ❌ CRITICAL: State mismatch detected!
  Desired MD5: 71a29f10311a1948c950c6f5528a5937
  Current MD5: 6ed6f9d4d12daea40d2144e2e22f1914
Thu Oct 16 10:45:02 RTZ 2025 - ✅ OK: States synchronized
```

### 2.5 Output from `monitor.sh` showing continuous monitoring
```text
Starting GitOps monitoring...

--- Check #1 ---
Thu Oct 16 10:45:42 RTZ 2025 - ✅ OK: States synchronized
...
--- Check #2 ---
Thu Oct 16 10:45:46 RTZ 2025 - ✅ OK: States synchronized
...
--- Check #3 ---
Thu Oct 16 10:45:49 RTZ 2025 - ✅ OK: States synchronized
```
*(trimmed for brevity; full run includes similar repeated checks)*

### 2.6 Analysis: How checksums (MD5) help detect configuration changes
- MD5 over full file content yields a **content fingerprint**.
- Any byte‑level change produces a **different hash**, allowing fast drift detection without line‑by‑line comparison.

### 2.7 Comparison: Relation to ArgoCD “Sync Status”
- ArgoCD computes desired manifests from Git and compares with live cluster state.
- **Synced** ↔ hashes/manifests match; **OutOfSync** ↔ mismatch detected; auto‑sync can reconcile to desired.
- The scripts here emulate that pattern at file level: diff via checksum, then reconcile to restore sync.


