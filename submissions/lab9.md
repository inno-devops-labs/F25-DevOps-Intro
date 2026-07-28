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
(after). Reports and exact triage will be attached after the real run.

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
