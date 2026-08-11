# Lab 9 — Security Scanning: Trivy and ZAP

**Author:** HNS ([@HNS2112](https://github.com/HNS2112))
**Date:** 6 August 2026
**Environment:** Ubuntu 24.04, Docker 29.1.3, Compose 2.40.3, Trivy 0.59.1, ZAP stable

Raw scanner output is committed under `security/`.

---

## Task 1 — Trivy

### 1.1 Four scans

The image under test is the one built in Lab 6: multi-stage, distroless-static,
nonroot. Built here on **amd64**, where it comes to 9.22 MB — against 16.2 MB for
the arm64 build on the same Dockerfile. The gap is architecture plus the busybox
`wget` that the macOS build carried for its healthcheck. Worth stating plainly:
an image size claim without an architecture attached does not mean much.

**`trivy image`**

```console
$ trivy image --severity HIGH,CRITICAL quicknotes:lab6

quicknotes:lab6 (debian 13.6)
Total: 0 (HIGH: 0, CRITICAL: 0)

app/quicknotes (gobinary)
Total: 15 (HIGH: 14, CRITICAL: 1)
```

**`trivy fs`** — zero findings. `app/go.mod` has no `require` block and there is
no `go.sum`, so there are no third-party dependencies to check. The scanner
detected one language-specific file and found nothing in it.

**`trivy config`**

```console
app/Dockerfile (dockerfile)
Tests: 28 (SUCCESSES: 27, FAILURES: 1)
Failures: 1 (UNKNOWN: 0, LOW: 1, MEDIUM: 0, HIGH: 0, CRITICAL: 0)

AVD-DS-0026 (LOW): Add HEALTHCHECK instruction in your Dockerfile
```

**SBOM (CycloneDX)** — 9 components:

| Type | Name | Version |
|---|---|---|
| operating-system | debian | 13.6 |
| application | app/quicknotes | — |
| library | base-files | 13.8+deb13u6 |
| library | media-types | 13.0.0 |
| library | netbase | 6.5 |
| library | tzdata-legacy | 2026b-0+deb13u1 |
| library | tzdata | 2026b-0+deb13u1 |
| library | quicknotes | — |
| library | stdlib | v1.24.6 |

### 1.2 Triage

| Finding | Severity | Verdict | Reasoning |
|---|---|---|---|
| CVE-2025-68121 — `crypto/tls` certificate validation on session resumption | CRITICAL | **Fix** | Fixed in Go 1.24.13; a toolchain bump is a one-line change with no code impact |
| 14 × DoS in `net/url`, `crypto/x509`, `net`, `net/mail`, `mime` | HIGH | **Fix where the toolchain allows, accept the rest** | Same single remediation — bump Go — but several require 1.25.x or 1.26.x, which the `go 1.24` directive in `go.mod` rules out |
| AVD-DS-0026 — no HEALTHCHECK in Dockerfile | LOW | **False positive** | See below |
| Debian base layer | — | Nothing to do | Zero findings |

**On the HEALTHCHECK finding.** Trivy is right about the file and wrong about the
system. There is no `HEALTHCHECK` instruction in the Dockerfile — but there is a
healthcheck, declared in `compose.yaml` and running `wget` against `/health`
every 10 seconds. Lab 6 verified it reporting `healthy`.

Trivy scans artifacts one at a time. It read the Dockerfile without the
compose file that deploys it, so it could not see the check that exists. This is
the structural limit of static configuration scanning: the rule is sound, the
verdict is not, and the difference is only visible to someone who knows how the
pieces are deployed together.

The fix would be to duplicate the check as a `HEALTHCHECK` instruction — but the
distroless image has no shell, so `HEALTHCHECK CMD` would need the same busybox
`wget` copied in, growing the image for a check the orchestrator already performs.
Accepted as a false positive rather than silenced with an ignore file, so the
reasoning stays visible.

**On the 15 Go stdlib findings.** The OS layer scanned clean, which is the whole
promise of a distroless base. Every finding is in the Go standard library
compiled into the binary. The base image cannot help with that: a minimal base
removes OS-layer CVEs and says nothing about what you compile into it.

Two things bound how far this can be remediated. The `go 1.24` directive in
`go.mod` caps the toolchain, and several fixes only landed in 1.25.x or later —
`CVE-2026-39822` needs 1.25.12. And most of the DoS findings are in packages
QuickNotes never calls; `net/mail` and `mime` are linked in but unreachable from
any handler. The count is an input to triage, not a verdict.

The identical 15 findings appeared on both the arm64 and amd64 builds, which
confirms the CVEs travel with the compiler rather than the platform.

### 1.3 Design questions

#### a) Why does `trivy image` find things `trivy fs` does not?

They scan different things. `trivy fs` reads the source tree: manifests such as
`go.mod`/`go.sum`, lockfiles, and files on disk. `trivy image` reads the built
artifact: OS packages installed in the image layers and — crucially here —
binaries, which it inspects for the Go build information embedded by the
compiler.

On this project the difference is stark. `fs` found nothing because the source
declares no dependencies. `image` found 15, all in `stdlib v1.24.6` — a
"dependency" that exists only after compilation and appears in no manifest. No
amount of source scanning would surface it.

#### b) What is an SBOM for, and who consumes it?

An SBOM is an inventory of what is actually inside a shipped artifact, in a
machine-readable format. The value is in answering a question that arrives
*after* the fact: when a CVE is published against some library, which of your
running services contain it?

Without an SBOM that question requires rebuilding and rescanning everything.
With one it is a query over stored documents. The consumers are incident
response during a zero-day, procurement and compliance teams who need provenance,
and downstream users who inherit your artifact's risk.

The SBOM here is instructive: of nine components, seven are distroless leftovers
(`base-files`, `tzdata`, `netbase`, `media-types`) and only two are mine —
`quicknotes` and `stdlib`. All 15 CVEs are in the latter.

#### c) Why scan configuration as well as content?

Content scanning asks "is anything in here known-vulnerable". Configuration
scanning asks "is this put together in a way that creates risk", and the two miss
completely different classes of problem.

A container running as root with a fully patched base has zero CVEs and a large
blast radius. A Dockerfile pinned to `:latest` is not vulnerable today and is
unreproducible tomorrow. Neither shows up in a vulnerability database, because
neither is a vulnerability — they are decisions. Trivy ran 28 such checks against
this Dockerfile and 27 passed, which is a statement about the Lab 6 choices
(nonroot, pinned base, no package manager) rather than about any CVE.

#### d) Why does a scan finding not automatically mean "fix it"?

Because severity is a property of the vulnerability, not of your exposure to it.
CVSS scores a worst case across all deployments; whether it applies depends on
whether the vulnerable code path is reachable, whether an attacker can reach the
input, and what the blast radius is if they do.

This lab has both cases side by side. The `crypto/tls` CRITICAL is worth fixing:
the path is real and the remedy is a toolchain bump. The `net/mail` DoS findings
are formally HIGH but unreachable — QuickNotes has no email handling — and would
be fixed only as a by-product of the same bump. The HEALTHCHECK finding should
not be actioned at all, because the premise is wrong.

Treating every finding as mandatory has a cost beyond wasted effort: it produces
alert fatigue, and a team that has learned to click through its scanner output
will click through the one that mattered.

---

## Task 2 — ZAP

### 2.1 Baseline scan

```console
$ docker run --rm --network host -v "$PWD:/zap/wrk:rw" ghcr.io/zaproxy/zaproxy:stable \
    zap-baseline.py -t http://127.0.0.1:8080/notes -r zap-report.html -J zap-report.json

WARN-NEW: X-Content-Type-Options Header Missing [10021] x 1
	http://127.0.0.1:8080/notes (200 OK)
WARN-NEW: Storable and Cacheable Content [10049] x 4
	http://127.0.0.1:8080/notes (200 OK)
	http://127.0.0.1:8080/ (404 Not Found)
	http://127.0.0.1:8080/robots.txt (404 Not Found)
	http://127.0.0.1:8080/sitemap.xml (404 Not Found)
WARN-NEW: Cross-Origin-Resource-Policy Header Missing or Invalid [90004] x 1
	http://127.0.0.1:8080/notes (200 OK)

FAIL-NEW: 0	WARN-NEW: 3	PASS: 64
```

**A note on the target URL.** The first attempt pointed at `http://127.0.0.1:8080`
and produced almost nothing — WARN 1, PASS 66. The spider got a 404 on `/` and
had nothing to crawl, so it only ever saw error pages. QuickNotes has no route on
`/`; every endpoint is under `/health`, `/notes`, `/metrics`. Re-targeting at
`/notes` gave the scanner a real 200 response to inspect and the findings
appeared.

That is worth recording as a finding about the tooling rather than the
application: a DAST scan against a URL that returns nothing useful produces a
clean report, and a clean report from a scan that never reached the application
is worse than no report at all.

Confirming what the application actually sent:

```console
$ curl -sI http://localhost:8080/notes
HTTP/1.1 200 OK
Content-Type: application/json
Date: Thu, 06 Aug 2026 16:24:23 GMT
Content-Length: 635
```

Four headers, none of them security-related.

### 2.2 Triage

| Finding | Verdict | Reasoning |
|---|---|---|
| X-Content-Type-Options Missing [10021] | **Fix** | One header, no downside; prevents MIME sniffing turning a JSON response into something executable |
| Cross-Origin-Resource-Policy Missing [90004] | **Fix** | One header; this API is not meant to be embedded cross-origin |
| Storable and Cacheable Content [10049] | **Fix, with reservations** | `/notes` is unauthenticated today, but caching note contents in a shared proxy is undesirable; see §2.4 on why this one is a judgement call |

### 2.3 The fix

All routes already pass through one wrapper, `Server.wrap`, which existed for
metrics. Three lines there cover every endpoint, present and future:

```go
func (s *Server) wrap(h http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		sw := &statusWriter{ResponseWriter: w, code: 200}
		w.Header().Set("X-Content-Type-Options", "nosniff")
		w.Header().Set("Cross-Origin-Resource-Policy", "same-origin")
		w.Header().Set("Cache-Control", "no-store")
		h(sw, r)
		s.requestsTotal.Add(1)
		if c, ok := s.requestsByCode[sw.code]; ok {
			c.Add(1)
		}
	}
}
```

Placement matters: the headers are set *before* `h(sw, r)` runs. Once a handler
calls `Write` or `WriteHeader` the header map is flushed and further changes are
silently ignored — a Go gotcha that would have produced a fix that passes review
and does nothing.

Regression test, covering two routes rather than one so that a future route added
outside `wrap` is caught:

```go
func TestSecurityHeaders_PresentOnAllRoutes(t *testing.T) {
	srv := newTestServer(t)
	for _, target := range []string{"/health", "/notes"} {
		rec := do(t, srv, http.MethodGet, target, nil)
		for header, want := range map[string]string{
			"X-Content-Type-Options":       "nosniff",
			"Cross-Origin-Resource-Policy": "same-origin",
			"Cache-Control":                "no-store",
		} {
			if got := rec.Header().Get(header); got != want {
				t.Errorf("%s on %s: got %q, want %q", header, target, got, want)
			}
		}
	}
}
```

```console
$ go test -race -count=1 ./...
ok  	quicknotes	1.015s

$ go vet ./... && gofmt -l .
(clean)
```

### 2.4 Re-scan: before and after

```console
$ curl -sI http://localhost:8080/notes
HTTP/1.1 200 OK
Cache-Control: no-store
Content-Type: application/json
Cross-Origin-Resource-Policy: same-origin
X-Content-Type-Options: nosniff
Date: Thu, 06 Aug 2026 16:33:29 GMT
Content-Length: 635
```

| Rule | Before | After |
|---|---|---|
| X-Content-Type-Options Missing [10021] | WARN | gone |
| Cross-Origin-Resource-Policy Missing [90004] | WARN | gone |
| Insufficient Site Isolation Against Spectre [90004] | WARN | **PASS** |
| Storable and Cacheable Content [10049] | WARN ×4 | replaced by *Non-Storable Content* ×4 |
| **Totals** | **WARN 3, PASS 64** | **WARN 1, PASS 66** |

**The remaining warning is the interesting one.** Rule 10049 did not disappear —
it inverted. "Storable and Cacheable Content" became "Non-Storable Content": the
same rule now reporting the opposite fact. ZAP is not complaining; it is stating
that `no-store` is in effect, and leaving the judgement to a human.

This is the clearest illustration in the lab of what a scanner can and cannot do.
It can determine that responses are not cacheable. It cannot decide whether that
is correct for this API — right for unauthenticated note contents that should not
sit in a shared proxy, wrong for public static assets where it throws away
performance for nothing. Chasing the warning count to zero would mean removing a
header that was added deliberately.

Accepted and documented rather than silenced.

---

## Bonus Task — govulncheck in CI

### B.1 The job

Added to the Lab 3 pipeline, gated by `ci-ok` alongside `vet`, `test` and `lint`:

```yaml
  govulncheck:
    runs-on: ubuntu-24.04
    steps:
      - name: Checkout repository
        uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2
        with:
          fetch-depth: 1

      - name: Run govulncheck
        uses: golang/govulncheck-action@032d45514ae346b1db93c04b0c90b841c370344f # v1.1.0
        with:
          go-version-input: '1.25'
          work-dir: app
```

`ci-ok`'s `needs` became `[vet, test, lint, govulncheck]`, so a vulnerability
finding blocks the merge the same way a failing test does.

### B.2 One failure worth recording

The first attempt specified `go-version-input: '1.24'`, matching `go.mod`, and
the job failed:

```
go: golang.org/x/vuln/cmd/govulncheck@latest: golang.org/x/vuln@v1.6.0
    requires go >= 1.25.0 (running go 1.24.13; GOTOOLCHAIN=local)
```

The scanner's own toolchain floor is higher than the application's. Notably,
`GOTOOLCHAIN=local` — added to this pipeline in the Lab 3 bonus to stop Go
silently upgrading itself — is what turned a silent auto-upgrade into a visible
error. That is the pin working correctly: the failure is loud and the cause is
in the message, rather than the build quietly running on a different compiler
than the one declared.

Bumping the input to `1.25` fixed it. The job now passes.

### B.3 The result, and why it differs from Trivy

```console
$ go run golang.org/x/vuln/cmd/govulncheck@latest ./...
No vulnerabilities found.
```

**Zero findings — against Trivy's 15 in the same binary.** The two tools are not
disagreeing; they answer different questions.

Trivy reads the Go build information embedded in the binary, sees
`stdlib v1.24.6`, and reports every CVE published against that version. That is
a question about *presence*: is vulnerable code in this artifact?

govulncheck builds a call graph from the entry points and reports a vulnerability
only when a path exists from application code to the affected symbol. That is a
question about *reachability*: can this vulnerable code actually be invoked here?

The gap is the triage argument from §1.2 made concrete. QuickNotes never calls
`net/mail`, `mime`, or the TLS session-resumption path that `CVE-2025-68121`
affects — those packages are linked into the binary but unreachable from any
handler. Trivy is right that they are present; govulncheck is right that they
cannot be exercised.

Both belong in a pipeline, for different jobs. Trivy answers "what do I need to
patch eventually" and drives the toolchain-bump decision. govulncheck answers
"what can hurt me today" and is the one that should block a merge — which is why
it, and not Trivy, is wired into `ci-ok` here.

### B.4 Evidence

- Failed run (toolchain floor): https://github.com/HNS2112/DevOps-Intro/actions/runs/31411530404
- Green run: https://github.com/HNS2112/DevOps-Intro/actions/runs/31458925656
- Local output: `security/govulncheck.txt`

---

## Summary

| Task | Status |
|------|--------|
| Task 1 — Trivy image / fs / config / SBOM, triage, design questions | Complete |
| Task 2 — ZAP baseline, triage, code fix, regression test, re-scan | Complete |
| Bonus — govulncheck in CI | Complete |
