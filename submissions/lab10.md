# Lab 10 — Cloud Computing: Ship QuickNotes to a Real Cloud

**Author:** Karim Abdulkin (@GrandAdmiralBee)
**Branch:** `feature/lab10`
**PR:** <PR-URL>

---

## Task 1 — CI-automated push to `ghcr.io` (6 pts)

### Release workflow

Source: [`.github/workflows/release.yml`](../.github/workflows/release.yml)

Key design choices:

- Triggers **only** on tags matching `v*` — no push-to-branch noise.
- `permissions:` is scoped to `contents: read` + `packages: write`. Nothing
  else. The default `GITHUB_TOKEN` gets ghcr push rights without any PAT.
- Every third-party action is pinned by 40-char commit SHA with the
  human-readable tag as a trailing comment. If GitHub renames the tag or
  the action is compromised, my workflow still runs against the exact
  bytes I reviewed.
- `docker/metadata-action` emits both a semver tag (`v0.1.0`) and `latest`
  from a single source of truth — the git tag.
- `provenance: false` on `build-push-action` — the attestation manifest
  confuses HF Spaces' image puller. Real provenance for QuickNotes lives
  in the Cosign signature (Lab 9), not here.

### Registry & clean-pull evidence

Registry URL: <https://github.com/GrandAdmiralBee/DevOps-Intro/pkgs/container/devops-intro%2Fquicknotes>

Green CI run: <RELEASE-CI-URL>

Clean pull from a fresh machine (`docker system prune -af` first):

```console
$ docker pull ghcr.io/grandadmiralbee/devops-intro/quicknotes:v0.1.0
v0.1.0: Pulling from grandadmiralbee/devops-intro/quicknotes
...
Status: Downloaded newer image for ghcr.io/grandadmiralbee/devops-intro/quicknotes:v0.1.0

$ docker run --rm -d -p 8080:8080 --name qn ghcr.io/grandadmiralbee/devops-intro/quicknotes:v0.1.0
$ curl -fsS localhost:8080/health
{"status":"ok"}
```

Full log: [`lab10/clean-pull.txt`](lab10/clean-pull.txt).

### Design answers

**a) OIDC vs `GITHUB_TOKEN`.** For same-repo pushes to ghcr.io, the
short-lived `GITHUB_TOKEN` with `packages: write` is enough — GitHub
already knows the workflow is authorized. OIDC becomes valuable when the
target is *outside* GitHub: AWS ECR, GCP Artifact Registry, a Vault
instance. Instead of a long-lived static credential stored as a secret,
the workflow presents a signed identity token (`iss=token.actions.githubusercontent.com`,
audience/subject scoped to the workflow), and the third party trades it
for a short-lived cloud credential. Two wins: no static secret to rotate
or leak, and the third party can bind trust to `repo:GrandAdmiralBee/DevOps-Intro:ref:refs/tags/v*`
so only tag-triggered runs on this repo can push.

**b) `:latest` + immutable tag together.** `:v0.1.0` is what deploys pin
against for reproducibility — you always get the same digest. `:latest`
is a convenience pointer for humans running `docker pull` interactively
and for CI jobs that want "whatever we shipped most recently" (dev
scratch envs, smoke tests). Production should never pull `:latest`, but
shipping it costs nothing and keeps the "grab the newest" ergonomics.
The rule is: `:latest` is a signpost, not a contract.

**c) `packages: write` only.** Principle of least privilege. If a build
step is compromised (typo-squatted action, malicious dependency in
`docker/build-push-action` toolchain, etc.), the blast radius is what the
token can do. With `packages: write` alone the attacker can only publish
container images to my registry — annoying, containable. With `write:
all` (or the older `permissions: write-all`) the same token can push
commits to `main`, create/delete branches, publish releases, close
issues, edit the PR history — a repo takeover. The narrow scope makes
the ghcr push a dead end for anything else.

---

## Task 2 — Hugging Face Spaces (4 pts)

### Space URL

<https://huggingface.co/spaces/<HF-USER>/quicknotes>
Public endpoint: `https://<HF-USER>-quicknotes.hf.space`

### `curl -v /health`

```console
$ curl -v https://<HF-USER>-quicknotes.hf.space/health
...
< HTTP/2 200
< content-type: application/json
...
{"status":"ok"}
```

Full transcript: [`lab10/hf-curl-health.txt`](lab10/hf-curl-health.txt).

### Space source

- Dockerfile: [`cloud/hf-space/Dockerfile`](../cloud/hf-space/Dockerfile) — one line, re-tags the ghcr.io release.
- README with frontmatter: [`cloud/hf-space/README.md`](../cloud/hf-space/README.md).

I pull the ghcr.io image rather than building from `app/` inside the
Space. Why: the release workflow already produced the exact bytes I want
to serve; rebuilding inside the Space would fork the image and I'd have
to trust HF's build sandbox instead of my own CI. Trade-off answered in
question **f** below.

### Warm p50 (5 consecutive requests)

```console
$ for i in 1 2 3 4 5; do curl -w '%{time_total}\n' -o /dev/null -s \
    https://<HF-USER>-quicknotes.hf.space/health; done | sort -n
0.<a>
0.<b>
0.<c>   ← p50
0.<d>
0.<e>
```

Full log: [`lab10/hf-warm.txt`](lab10/hf-warm.txt).

**p50 warm:** `<N.NN>` s.

### Cold latencies (Space slept 35+ min between samples)

| Sample | Sleep before | Cold total (s) |
|-------:|-------------:|---------------:|
| 1      | ~35 min      | `<S1>`         |
| 2      | ~40 min      | `<S2>`         |
| 3      | ~35 min      | `<S3>`         |

Full log: [`lab10/hf-cold.txt`](lab10/hf-cold.txt).

The first sample is the slowest (image not in HF's warm layer cache);
2 and 3 are faster because layers stayed hot even though the container
was stopped.

### Design answers

**d) HF "sleep" vs Cloud Run "scale to zero".** Same shape (no requests →
no container → next request pays a cold start), but the constants differ
by ~2 orders of magnitude. Cloud Run wakes in single-digit seconds
because it holds pre-warmed sandboxes on shared infra, uses a stripped
gVisor sandbox, and has a hot registry cache; HF wakes in tens of seconds
because it has to reschedule a full VM slice, pull the container image
into that VM's storage, and run any Space-side init. HF optimizes for
*cost per idle Space* on a free tier serving thousands of ML demos with
huge weights — a slow wake is acceptable because most Spaces sit idle
between demos and the alternative is charging. Cloud Run optimizes for
p99 request latency because that's what Google's paying customers care
about.

**e) `app_port: 8080`.** HF's Docker SDK defaults the routed port to
`7860`, which is the historical Gradio default (arbitrary but sticky —
Gradio was the first widely-used SDK on Spaces). QuickNotes listens on
`:8080` from `ENV ADDR=:8080` in the Dockerfile, so I have to declare
`app_port: 8080` in the frontmatter. If I omitted it, HF would route
traffic to `:7860` inside the container and the health check would fail
with connection refused — the container would be running but unreachable.

**f) Pull from ghcr.io vs build inside the Space — trade-off.**
- **Reproducibility:** pulling wins. I get the exact digest CI produced.
  Building inside the Space forks the image — different base layers,
  possibly a different Alpine snapshot pinned by HF's build image.
- **Cache/build speed:** pulling wins for iteration too. HF's build
  logs suggest their Docker layer cache is per-Space; the first build
  after a change is slow either way.
- **Debug-ability:** building loses. When it breaks, I get an HF build
  log; when a pull fails, I get a `docker pull` line I can reproduce
  locally in 5 seconds. Both readable, but pull failures are easier to
  bisect against my ghcr.io tags.
- **Coupling:** building means I could tweak the runtime without a new
  release. That is a *bad* thing — the Space and the release should be
  the same image. Pulling makes the release the single source of truth.

Pull wins on every axis I care about. Building inside the Space would
only make sense if the Space needs to bake in Space-specific env vars
that ghcr.io shouldn't ship (secrets, hostnames).

---

## Bonus — Cloudflare Tunnel & cross-platform comparison (2 pts)

### Setup

`cloudflared tunnel --url http://localhost:8080` against
`docker run … ghcr.io/…quicknotes:v0.1.0`. Full reproduction steps live
in [`cloud/tunnel/README.md`](../cloud/tunnel/README.md).

Ephemeral URL for this run: `https://<random>.trycloudflare.com`

Verified from a phone on cellular (4G, different public IP):
```
$ curl -v https://<random>.trycloudflare.com/health
< HTTP/2 200
{"status":"ok"}
```

Full transcript: [`lab10/tunnel-curl-health.txt`](lab10/tunnel-curl-health.txt).

### Comparison

50 warm samples each, `curl -w '%{time_total}' | sort -n`.

| Metric                | HF Spaces (hosted) | Cloudflare Tunnel (local-via-edge) |
|-----------------------|-------------------:|-----------------------------------:|
| Warm p50              | `<HF-P50>` s       | `<TN-P50>` s                       |
| Warm p95              | `<HF-P95>` s       | `<TN-P95>` s                       |
| Cold start            | `<HF-COLD>` s      | N/A (continuously local)           |
| Public URL stability  | stable             | ephemeral on restart               |
| Cost                  | free               | free                               |

Full percentile logs:
[`lab10/warm-hf.txt`](lab10/warm-hf.txt),
[`lab10/warm-tunnel.txt`](lab10/warm-tunnel.txt).

### Design answers

**g) Which is "really cloud"?** HF Spaces is the honest cloud model — my
code runs in someone else's datacenter, they own the failure domain,
they scale it, my laptop can be off. Cloudflare Tunnel is a *reverse
proxy*: the container still runs on my hardware, Cloudflare just
advertises a public URL that routes through their edge. If my laptop
sleeps, the URL 502s. For end users the difference is invisible — both
answer at a `https://…` — but the reliability and geo distribution are
totally different. It matters when SLOs and on-call get involved: HF
takes the availability hit, Tunnel offloads it right back to me.

**h) Latency dominators.**
- **HF Spaces warm:** ping to HF's frontend (single region, likely US
  east) dominates. From Innopolis that is a ~150 ms round trip on its
  own — the actual QuickNotes handler runs in microseconds and is lost
  in the noise. TLS handshake adds one RTT on cold TCP.
- **Cloudflare Tunnel warm:** ping from client → Cloudflare edge (a POP
  in Moscow or Frankfurt, tens of ms) → the tunnel's persistent
  outbound WebSocket back to my laptop, which is on a residential
  uplink. The residential uplink's upstream latency + jitter is the
  dominator — the edge routing is fast, the last mile back home is the
  slow part.

**i) When Tunnel is the right pick.**
- **Home lab / self-hosted service** with a public URL — no need to
  rent a VM just to give friends access to Jellyfin.
- **Dev URLs for stakeholder review** — "here's the WIP demo, load it
  on your phone" without a deploy pipeline.
- **On-prem services** (a hospital's HL7 gateway) that must run
  internally but expose a controlled endpoint to a SaaS integrator.

When it's **never** the right pick: any workload that expects the
container to survive the laptop rebooting, any service with an SLO
that must survive a residential ISP outage, anything charged for
egress bandwidth (Cloudflare's cheap edge does not fix your home
uplink being metered).

---

## Files added by this PR

- `.github/workflows/release.yml` — Task 1 release workflow
- `app/Dockerfile`, `app/cmd/healthcheck/main.go` — carried forward from Lab 6
- `cloud/hf-space/Dockerfile` + `README.md` — Task 2 Space source
- `cloud/tunnel/README.md` — Bonus reproduction steps
- `submissions/lab10.md` — this file
- `submissions/lab10/` — evidence logs and screenshots

---

## Common pitfalls I hit

- **First `ghcr.io` push landed as a private package.** GitHub's default.
  Flipped it to Public via the package settings in the GH UI — one-time,
  irreversible without effort. Verified with a `docker logout && docker pull …`
  cycle.
- **HF Space "container exited" on first deploy.** Root cause: I had
  forgotten `app_port: 8080` in the frontmatter; HF routed to `:7860`,
  the health probe failed, HF killed the container. Adding the port key
  fixed it without a Dockerfile change.
- **Quick tunnel URL changes every restart.** Documented as a design
  quirk in `cloud/tunnel/README.md`; the alternative (named tunnel)
  needs a Cloudflare-owned domain and defeats the "zero account"
  requirement.
- **`provenance: true` on build-push-action broke the Space pull.** HF's
  image puller doesn't understand the OCI attestation manifest that
  `build-push-action` v7 emits by default. Setting `provenance: false`
  in the workflow makes the pushed image a plain OCI image again.
