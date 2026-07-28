# Lab 9 — DevSecOps

Branch: `feature/lab9`

## Remediation

QuickNotes now applies security headers through one middleware wrapping the
entire router. The regression test checks successful and 404 responses, so
removing the wrapper fails the suite. The fixed headers include a strict API
CSP, anti-framing, no-sniff, no-referrer, permissions policy, and no-store.

The image builder was upgraded from end-of-life Go 1.24 to the current
security-patched Go 1.26.5. This deliberately deviates from the older Lab 3
toolchain: current Trivy data showed that Go 1.24 could not remediate its
remaining standard-library findings.

The security workflow pins Trivy 0.59.1, ZAP 2.16.1, and govulncheck 1.1.4.
It performs image/filesystem/config scans, generates a CycloneDX SBOM, and
runs passive ZAP baselines against both `main` (before) and this branch
(after). The complete suite passed in
[GitHub Actions run 30339421563](https://github.com/Mimir-sma/DevOps-Intro/actions/runs/30339421563).

## Trivy and SBOM evidence

All four artifacts are committed:

- [`trivy-image.txt`](../lab9/trivy-image.txt) and its
  [JSON form](../lab9/trivy-image.json);
- [`trivy-fs.txt`](../lab9/trivy-fs.txt) and its
  [JSON form](../lab9/trivy-fs.json);
- [`trivy-config.txt`](../lab9/trivy-config.txt) and its
  [JSON form](../lab9/trivy-config.json);
- [`quicknotes.sbom.cdx.json`](../lab9/quicknotes.sbom.cdx.json).

| Scan | HIGH | CRITICAL | Triage |
|---|---:|---:|---|
| Image | 0 | 0 | No HIGH/CRITICAL rows to disposition. |
| Repository filesystem | 0 | 0 | No HIGH/CRITICAL rows to disposition. |
| Docker/Compose config | 0 | 0 | No failed misconfiguration rows; both Dockerfiles passed 21 checks. |

The human filesystem/config reports are empty because the selected severities
had no results; their JSON files prove the target, timestamp, and successful
scan. The image report records `debian 12.15` and total zero.

First 30 lines of the CycloneDX 1.6 SBOM:

```json
{
  "$schema": "http://cyclonedx.org/schema/bom-1.6.schema.json",
  "bomFormat": "CycloneDX",
  "specVersion": "1.6",
  "serialNumber": "urn:uuid:8bbb84cc-1b41-4e0a-a7e4-2a89f5a00b03",
  "version": 1,
  "metadata": {
    "timestamp": "2026-07-28T07:43:14+00:00",
    "tools": {
      "components": [
        {
          "type": "application",
          "group": "aquasecurity",
          "name": "trivy",
          "version": "0.59.1"
        }
      ]
    },
    "component": {
      "bom-ref": "b895dc6b-bc01-4fd2-ae24-a429161d2dac",
      "type": "container",
      "name": "quicknotes:lab9",
      "properties": [
        {
          "name": "aquasecurity:trivy:DiffID",
          "value": "sha256:114dde0fefebbca13165d0da9c500a66190e497a82a53dcaabc3172d630be1e9"
        },
        {
          "name": "aquasecurity:trivy:DiffID",
          "value": "sha256:27cb265b6e0db3c9d3d865b51bcd6e9c83a5577482ec710f93189bd2d026f0d6"
```

The full SBOM contains 11 components, including both application binaries,
the Go standard library, Debian base metadata, CA/media types, netbase, and
timezone data.

## ZAP before/after triage

The passive reports are preserved as
[`zap-before.json`](../lab9/zap-before/zap-before.json),
[`zap-before.html`](../lab9/zap-before/zap-before.html),
[`zap-after.json`](../lab9/zap-after/zap-after.json), and
[`zap-after.html`](../lab9/zap-after/zap-after.html).

| Report | ID / finding | Risk | URL(s) | Disposition |
|---|---|---|---|---|
| Before | 10116 — ZAP is Out of Date | Low | `/sitemap.xml` | **ACCEPT** — scanner self-report, not an application flaw. Version 2.16.1 is explicitly pinned for this lab; upgrade/recheck by 2026-08-31. |
| Before | 10049 — Storable and Cacheable Content | Informational | `/robots.txt`, `/sitemap.xml` | **FIX** — middleware adds `Cache-Control: no-store` to every response in commit `6f6e79e`; regression test covers normal and 404 routes. |
| After | 10116 — ZAP is Out of Date | Low | `/robots.txt` | **ACCEPT** — same scanner-self finding and dated upgrade action as above. |
| After | 10049 — Non-Storable Content | Informational | `/`, `/robots.txt`, `/sitemap.xml` | **ACCEPT** — evidence is now `no-store`; API responses may be user-specific and the tiny demo has no cache-performance need. Re-evaluate if public immutable resources are added, by 2026-12-31. |

The before finding named **Storable and Cacheable Content** is absent after
the code change; ZAP instead confirms the intentional inverse behavior as
**Non-Storable Content**. This is the scanner-visible proof of the fix.

## Design answers

**a — severity context.** Triage also needs call-path reachability, whether
attacker-controlled input reaches the component, public exploit maturity,
required privileges, network exposure, compensating controls, data
sensitivity, and the consequence in this deployment. A critical issue in
unused build tooling can be less urgent than a medium flaw on a public,
unauthenticated request path.

**b — minimal base.** Removing packages removes code that cannot be exploited,
patched, misconfigured, or used for post-exploitation. Distroless also removes
shells and package managers, shrinking both scanner noise and attacker tools.
It does not remove vulnerabilities compiled into the application or language
runtime.

**c — ignore policy.** `.trivyignore` is justified for a specifically
identified, documented false positive or time-bounded acceptance with an
owner, expiry date, and compensating control. It is theater when it hides an
untriaged ID, lacks an expiry, or is used only to turn CI green.

**d — SBOM value.** When a new issue like Log4Shell is disclosed, the SBOM
answers which deployed artifact contains the affected component/version
without rebuilding or scanning every source tree first. It supports rapid
inventory, impact queries, customer response, and targeted rebuilds.

**e — middleware.** One wrapper covers every existing and future route,
including framework-generated 404/405 responses. Per-handler calls are easy
to omit, duplicate policy, and drift.

**f — strict CSP.** `default-src 'none'` blocks scripts, styles, images, fonts,
frames, and network fetches unless explicitly allowed. That would break most
HTML applications and Swagger UI. QuickNotes serves JSON/text only, so it
needs none of those browser capabilities.

**g — careless acceptance.** Bulk acceptance destroys the signal needed to
notice a real regression, normalizes risk without owners/expiry, and prevents
the team learning what the scanner actually observed. Informational findings
can still reveal inventory, cache, or cross-origin behavior relevant to the
deployment.

## Bonus — reachable-vulnerability gate

`govulncheck` is a separate required status job and scans `app/` with the
pinned v1.1.4 scanner. It uses Go 1.26.5 because Go 1.24 is end-of-life and a
security gate that deliberately runs a vulnerable compiler/runtime would be
self-defeating in July 2026.

**h — reachability.** A module-level CVE says vulnerable code exists in the
dependency graph; call-graph reachability says the application can invoke the
affected symbol. The latter sharply reduces urgent triage while the former
still informs inventory and future-code risk.

**i — scanner pin.** `@latest` can change rules, output, dependencies, or break
CI without a repository change. Pinning makes results reproducible and lets
scanner upgrades receive normal review.

**j — scope.** govulncheck does not inspect the distroless OS layer, container
configuration, leaked secrets, binaries from other ecosystems, or deployment
misconfigurations. Trivy covers several of those presence/configuration
classes; ZAP observes HTTP behavior.
