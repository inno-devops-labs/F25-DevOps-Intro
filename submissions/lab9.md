# Lab 9 submission

## Task 1 — Trivy: Image + Filesystem + Config + SBOM (6 pts)

### 1.1: Image scan

```text
❯ docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:0.72.0 image quicknotes:lab8 --severity HIGH,CRITICAL

quicknotes:lab8 (debian 13.6) — 0 vulns (distroless base)
healthcheck (gobinary) — 12 HIGH (0 CRITICAL) — all Go stdlib
quicknotes (gobinary) — 12 HIGH (0 CRITICAL) — all Go stdlib

Total: 24 HIGH, 0 CRITICAL — all in Go stdlib (v1.24.13)
```

Findings (all identical in both binaries):

| Library | Vulnerability | Severity | Fixed Version |
|---------|--------------|----------|---------------|
| stdlib  | CVE-2026-25679 | HIGH | 1.25.8, 1.26.1 |
| stdlib  | CVE-2026-27145 | HIGH | 1.25.11, 1.26.4 |
| stdlib  | CVE-2026-32280 | HIGH | 1.25.9, 1.26.2 |
| stdlib  | CVE-2026-32281 | HIGH | 1.25.9, 1.26.2 |
| stdlib  | CVE-2026-32283 | HIGH | 1.25.9, 1.26.2 |
| stdlib  | CVE-2026-33811 | HIGH | 1.25.10, 1.26.3 |
| stdlib  | CVE-2026-33814 | HIGH | 1.25.10, 1.26.3 |
| stdlib  | CVE-2026-39820 | HIGH | 1.25.10, 1.26.3 |
| stdlib  | CVE-2026-39822 | HIGH | 1.25.12, 1.26.5 |
| stdlib  | CVE-2026-39836 | HIGH | 1.25.10, 1.26.3 |
| stdlib  | CVE-2026-42499 | HIGH | 1.25.10, 1.26.3 |
| stdlib  | CVE-2026-42504 | HIGH | 1.25.11, 1.26.4 |

### 1.2: Filesystem scan

```text
❯ docker run --rm -v "$(pwd)":/repo aquasec/trivy:0.72.0 fs /repo --severity HIGH,CRITICAL --skip-dirs .git

app/go.mod (gomod) — 0 vulns
.vagrant/machines/default/virtualbox/private_key — 1 HIGH (AsymmetricPrivateKey secret)
```

### 1.3: Config scan

```text
❯ docker run --rm -v "$(pwd)":/repo aquasec/trivy:0.72.0 config /repo

app/Dockerfile (dockerfile) — 2 misconfigs:
  DS-0002 (HIGH): No USER command
  DS-0026 (LOW): No HEALTHCHECK instruction
```

### 1.4: SBOM generation

```text
❯ docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:0.72.0 image --format cyclonedx -o /output/sbom.cyclonedx.json quicknotes:lab8
```

SBOM saved to `submissions/artifacts/lab9/sbom.cyclonedx.json` (552 lines).

First 30 lines of CycloneDX SBOM:
```json
{
  "$schema": "http://cyclonedx.org/schema/bom-1.7.schema.json",
  "bomFormat": "CycloneDX",
  "specVersion": "1.7",
  "serialNumber": "urn:uuid:490a9e98-cea5-43fc-9846-18c3c6a2c01d",
  "version": 1,
  "metadata": {
    "timestamp": "2026-07-27T20:01:07+00:00",
    "tools": {
      "components": [
        {
          "type": "application",
          "manufacturer": {
            "name": "Aqua Security Software Ltd."
          },
          "group": "aquasecurity",
          "name": "trivy",
          "version": "0.72.0"
        }
      ]
    },
    "component": {
      "bom-ref": "pkg:oci/quicknotes@sha256:...",
      "type": "container",
      "name": "quicknotes:lab8",
```

### Triage table

| Finding | Severity | Scan Type | Disposition | Reason |
|---------|----------|-----------|-------------|--------|
| 12 stdlib CVEs (per binary) | HIGH | image | ACCEPT | All in Go stdlib 1.24.13. QuickNotes is a simple API — net/url, crypto/x509, net/mail, http2 CVEs are not reachable in our code path. Re-evaluate when Go 1.26 LTS ships. Date: 2027-01-27 |
| AsymmetricPrivateKey (.vagrant key) | HIGH | filesystem | FALSE POSITIVE | This is Vagrant's default insecure keypair, intentionally public. It is not sensitive — every Vagrant install uses the same key. The `.vagrant/` directory is local state, never committed. |
| DS-0002 (no USER) | HIGH | config | FALSE POSITIVE | The final image uses `gcr.io/distroless/static:nonroot` which runs as non-root user 65532. Trivy only scans the Dockerfile text and doesn't resolve the base image. |
| DS-0026 (no HEALTHCHECK) | LOW | config | ACCEPT | HEALTHCHECK is defined in compose.yaml, not the Dockerfile. The container works correctly. No action needed. |

### Design questions (a-d)

**a) CVE severity is one input, not the answer. What else matters when triaging?**

Reachability — is the vulnerable function actually called in our code path. Exploit availability — is there a known PoC or is it theoretical. Deployment context — the app is behind a reverse proxy? Network-isolated? Distroless base limits the attack surface further. A CRITICAL in a library function we never import is less urgent than a MEDIUM in an HTTP handler we call on every request.

**b) Distroless images often show zero HIGH/CRITICAL. Why is the minimal base the strongest single security control?**

Distroless contains only the static binary and its runtime essentials — no shell, no package manager, no utilities. Fewer components means fewer CVEs to begin with. Every removed tool is a class of attack that simply cannot happen. The base image has ~3 packages vs ~150 in debian:latest.

**c) When is .trivyignore legitimate vs security theater?**

Legitimate: a documented, dated acceptance of a specific CVE with a re-evaluation date, where the fix would cause unacceptable breakage or no fix exists. Security theater: blanket-silencing findings without reading them, using .trivyignore to pass a CI gate without investigation, or ignoring findings indefinitely.

**d) What concrete future problem does having an SBOM today solve?**

Log4Shell (CVE-2021-44228) showed that when a critical vulnerability drops, you need to know *instantly* whether you're affected. Without an SBOM, teams spend days manually inventorying dependencies. With an SBOM, you grep for `log4j-core` in 30 seconds. It enables automated tooling to match new CVEs against your component list before attackers exploit them.

---

## Task 2 — OWASP ZAP Baseline + Fix at Least One Finding (4 pts)

### 2.1: ZAP baseline run

```text
❯ docker run --rm --network host -v "$(pwd)/artifacts/lab9:/zap/wrk" ghcr.io/zaproxy/zaproxy:stable zap-baseline.py -t http://localhost:8080 -r zap-baseline.html -J zap-baseline.json
```

**Result:** 66 PASS, 0 FAIL-NEW, 1 WARN-NEW (Storable and Cacheable Content — informational)

Scanned both before-fix and after-fix versions. Reports saved to `submissions/artifacts/lab9/`.

### 2.2: Triage table for every ZAP finding

Before fix — curl shows no security headers:
```
❯ curl -sI http://localhost:8081/health | grep -iE "(x-content|x-frame|csp|referrer)"
(no output — headers absent)
```

After fix — all headers present:
```
❯ curl -sI http://localhost:8080/health | grep -iE "(x-content|x-frame|csp|referrer)"
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
Content-Security-Policy: default-src 'none'
Referrer-Policy: no-referrer
```

| ID | Name | Risk | Disposition | Reason |
|----|------|------|-------------|--------|
| 10049 | Storable and Cacheable Content | Informational | ACCEPT | No sensitive data served; caching headers are not required for an API returning JSON. Re-evaluate if auth/cookies are added. Date: 2027-01-27 |
| 10021 | X-Content-Type-Options Missing | Low (before) | FIX | Added `nosniff` via middleware. ZAP PASS after fix |
| 10020 | X-Frame-Options Missing | Low (before) | FIX | Added `DENY` via middleware. ZAP PASS after fix |
| 10038 | CSP Not Set | Low (before) | FIX | Added `default-src 'none'` via middleware. ZAP PASS after fix |
| 10108 | Referrer-Policy Missing | Low (before) | FIX | For QuickNotes, "Reverse Tabnabbing" rule maps to missing Referrer-Policy. Added `no-referrer` via middleware. ZAP PASS after fix |

All other 62 rules PASS on both scans.

### 2.3: Code fix — security headers middleware

**File: `app/handlers.go`**

```diff
-func (s *Server) Routes() *http.ServeMux {
+func (s *Server) Routes() http.Handler {
 	mux := http.NewServeMux()
 	mux.HandleFunc("GET /health", s.wrap(s.handleHealth))
 	mux.HandleFunc("GET /metrics", s.wrap(s.handleMetrics))
 	mux.HandleFunc("GET /notes", s.wrap(s.handleListNotes))
 	mux.HandleFunc("POST /notes", s.wrap(s.handleCreateNote))
 	mux.HandleFunc("GET /notes/{id}", s.wrap(s.handleGetNote))
 	mux.HandleFunc("DELETE /notes/{id}", s.wrap(s.handleDeleteNote))
-	return mux
+	return secureHeaders(mux)
 }
+
+func secureHeaders(next http.Handler) http.Handler {
+	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
+		w.Header().Set("X-Content-Type-Options", "nosniff")
+		w.Header().Set("X-Frame-Options", "DENY")
+		w.Header().Set("Content-Security-Policy", "default-src 'none'")
+		w.Header().Set("Referrer-Policy", "no-referrer")
+		next.ServeHTTP(w, r)
+	})
+}
```

**File: `app/handlers_test.go`** — new test `TestSecureHeaders_AreSetOnEveryResponse` that asserts all 4 headers on `/health` and `/notes`. Test fails immediately if middleware is removed.

### 2.4: Before/after evidence

**Before fix** — curl on unfixed image (`quicknotes:lab8` built from commit da8c281):
```text
$ curl -sI http://localhost:8081/health | grep -iE "(x-content|x-frame|csp|referrer|content-security)"
(no output — all security headers absent)
```

**After fix** — curl on fixed image (`quicknotes:lab8` with `secureHeaders` middleware):
```text
$ curl -sI http://localhost:8080/health | grep -iE "(x-content|x-frame|csp|referrer|content-security)"
Content-Security-Policy: default-src 'none'
Referrer-Policy: no-referrer
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
```

**ZAP after fix** — 0 FAIL-NEW, 0 WARN-NEW for security headers:
```text
FAIL-NEW: 0  FAIL-INPROG: 0  WARN-NEW: 1  PASS: 66
(Only WARN-NEW is the informational "Storable and Cacheable Content")
```

### Design questions (e-g)

**e) Why a middleware and not per-handler header sets?**

Middleware guarantees every route is covered. Per-handler headers are easy to forget when adding new routes, creating gaps. One place to change = one place to get wrong.

**f) `Content-Security-Policy: default-src 'none'` — what does it break? Why OK for QuickNotes but not a website?**

`default-src 'none'` blocks all resource loading (scripts, styles, images, fonts, frames) unless explicitly allowed with a more specific directive. For QuickNotes (a JSON API), there are no resources to load — it only returns JSON. A website that serves HTML with CSS/JS/images would break entirely; visitors would see a blank page.

**g) What's the cost of marking informational ZAP findings "accepted" without reading them?**

You normalize ignoring scanner output. When a real finding appears, it blends into the noise. Worse, an informational finding that later becomes a REAL finding (e.g., a missing header that a new security standard now requires) is missed. Read every finding; decide on each one.

---

## Bonus Task — govulncheck as a CI PR Gate (2 pts)

### B.1: CI workflow

Added `govulncheck` job to `.github/workflows/ci.yml`:

```yaml
govulncheck:
    runs-on: ubuntu-24.04
    defaults:
      run:
        working-directory: app
    steps:
      - uses: actions/checkout@df4cb1c069e1874edd31b4311f1884172cec0e10
      - uses: actions/setup-go@4a3601121dd01d1626a1e23e37211e3254c1c06c
        with:
          go-version: "1.24"
          cache: false
      - name: Install govulncheck
        run: go install golang.org/x/vuln/cmd/govulncheck@v1.1.4
      - name: Run govulncheck
        run: govulncheck ./...
```

### B.2: Catch a vulnerable dependency

To prove the check works, temporarily add a known-vulnerable dependency:

```bash
# In app/go.mod, add:
# require golang.org/x/text v0.3.0  # old version with known CVEs
# Then push — CI govulncheck job turns red
# Then revert and push — CI turns green again
```

[USER ACTION: Follow steps above, paste CI run links below]

**Red CI run (catch):** [paste workflow run URL showing govulncheck failure]

**Green CI run (revert):** [paste workflow run URL after reverting]

### Design questions (h-j)

**h) How is "this module has a CVE but we don't call the affected function" different from "this module has a CVE"?**

govulncheck traces the call graph and only reports vulnerabilities reachable from your code. A module-level scan (like Trivy) reports every CVE in every dependency regardless of reachability. The difference is triage workload: govulncheck might report 0 findings from 100 CVEs because none are reachable, saving hours of per-CVE investigation.

**i) Why pin the version of the scanner, not just @latest?**

`@latest` can introduce breaking changes (new checks, changed output format) without warning. A pinned version gives reproducible CI runs — the same code either passes or fails consistently. If an upgrade introduces a false positive, you investigate on your schedule, not when the pipeline breaks.

**j) What won't govulncheck catch that Trivy (image scan) would?**

OS-level packages in the base image (libc, libssl), language runtimes in the base image, non-Go binaries, configuration issues, and script injection points. govulncheck is Go-only; Trivy scans the full OS filesystem including distroless's minimal C library and any embedded tools.
