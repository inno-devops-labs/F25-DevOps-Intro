# Lab 10 — Cloud Computing: Ship QuickNotes to a Real Cloud

**Author:** HNS ([@HNS2112](https://github.com/HNS2112))
**Date:** 10 August 2026
**Host:** Windows 11, Go 1.26.5, cloudflared 2026.7.3

Raw output is committed under `evidence/lab10/`; deployment config under `cloud/`.

---

## A note on the platform substitution

The lab specifies Hugging Face Spaces with the Docker SDK, on the explicit
grounds that it is *"truly free, no card required"*. **That is no longer true.**

The current Spaces documentation states plainly that Gradio and Docker Spaces run
on compute and require a paid plan to create — PRO for personal accounts, Team or
Enterprise for organizations — while only Static Spaces remain free for everyone.
Attempting to create a Space confirms it: the Docker SDK tile is marked **Paid**,
with the message *"Gradio and Docker Spaces require a paid plan. Static Spaces
stay free for everyone. To create a Space that runs on compute, subscribe to
PRO."* PRO is $9/month.

The change appears to have landed around July 2026 with no announcement — a
Hugging Face forum thread from 8 July records users noticing the Docker SDK newly
marked as Paid and finding no changelog entry or documentation update explaining
it. Static Spaces are still free but cannot run a compiled Go binary, so there is
no free path to the lab's stated goal on that platform.

**Substitute chosen: Render.com free web service.** It preserves everything Task 2
actually tests:

| Lab 2 requirement | Render equivalent |
|---|---|
| Docker SDK, runs a container | Deploys directly from an OCI registry |
| Public HTTPS URL | `https://quicknotes-e5cq.onrender.com` |
| No card required | Confirmed — signup via GitHub, no payment details |
| Sleeps after ~30 min idle | Spins down after ~15 min idle |
| Cold start on wake | 14–25 s measured, see §2.3 |

The substitution is arguably closer to the lab's spirit than the original: Render
pulls the *same* ghcr.io image built in Task 1, so Tasks 1 and 2 are genuinely
chained rather than two independent builds of the same source.

---

## Task 1 — CI-Automated Push to `ghcr.io`

### 1.1 The release workflow

`.github/workflows/release.yml`:

```yaml
name: Release

on:
  push:
    tags:
      - 'v*'

permissions:
  contents: read
  packages: write

jobs:
  publish:
    runs-on: ubuntu-24.04
    steps:
      - name: Checkout repository
        uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2
        with:
          fetch-depth: 1

      - name: Log in to GitHub Container Registry
        uses: docker/login-action@9780b0c442fbb1117ed29e0efdff1e18412f7567 # v3.3.0
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build and push image
        uses: docker/build-push-action@ca877d9245402d1537745e0e356eab47c3520991 # v6.13.0
        with:
          context: ./app
          push: true
          platforms: linux/amd64
          tags: |
            ghcr.io/hns2112/devops-intro/quicknotes:${{ github.ref_name }}
            ghcr.io/hns2112/devops-intro/quicknotes:latest
```

All three actions are SHA-pinned with the tag in a trailing comment, carrying
forward the Lab 3 convention and the tj-actions reasoning behind it.

`platforms: linux/amd64` is explicit rather than inherited. The image was
previously built on Apple Silicon in Lab 6, where it came out as arm64; Render's
free instances are amd64, and an architecture mismatch here produces a container
that pulls successfully and then fails to execute.

### 1.2 The release

```console
$ git tag -a -s v0.1.0 -m "Lab 10 release"
$ git push origin v0.1.0
 * [new tag]         v0.1.0 -> v0.1.0

$ gh run list --repo HNS2112/DevOps-Intro --workflow Release --limit 2
STATUS  TITLE                        WORKFLOW  BRANCH  EVENT  ID           ELAPSED
✓       ci(lab10): add release w...  Release   v0.1.0  push   31361528580  1m12s
```

Green run: https://github.com/HNS2112/DevOps-Intro/actions/runs/31361528580

Image URL: `ghcr.io/hns2112/devops-intro/quicknotes:v0.1.0` (and `:latest`)

### 1.3 Evidence of an unauthenticated pull

Docker is not installed on this Windows host, so the pull was verified against
the registry API directly — which is a stronger demonstration, because it shows
the *anonymous* token path explicitly rather than relying on a cached login:

```console
$ $t = (Invoke-RestMethod "https://ghcr.io/token?scope=repository:hns2112/devops-intro/quicknotes:pull").token
$ Invoke-RestMethod -Uri "https://ghcr.io/v2/hns2112/devops-intro/quicknotes/manifests/v0.1.0" `
    -Headers @{Authorization="Bearer $t"; Accept="application/vnd.oci.image.index.v1+json,..."}

schemaVersion : 2
mediaType     : application/vnd.docker.distribution.manifest.v2+json
config        : digest sha256:4a8ed45d3d35ac26ed9b4eea769c86f12035e155ffa585a7e6bb39fc7184ef85
layers        : 18 layers, ~4.07 MB total
```

The token endpoint was called with no credentials whatsoever and returned a valid
pull token; the manifest then fetched successfully. That is the definition of
publicly pullable.

An amusing corroboration: `gh api users/HNS2112/packages/container/...` returned
**403 — "You need at least read:packages scope"**, because the authenticated CLI
token lacks that scope. So the *authenticated* path failed while the *anonymous*
one worked. The package metadata API and the registry API have entirely separate
authorization models, and only the latter governs whether `docker pull` works.

Render subsequently pulled the same image with no credentials configured, which
is the practical confirmation.

### 1.4 Design questions

#### a) OIDC vs `GITHUB_TOKEN`

For pushing to ghcr.io from the same repository that owns the package,
`GITHUB_TOKEN` with `packages: write` is sufficient and is what this workflow
uses. The token is minted per-run, scoped to this repository, and expires when the
job ends — there is no secret to rotate and nothing to leak beyond the run.

OIDC becomes necessary the moment the destination is **outside GitHub's trust
boundary**: pushing to AWS ECR, GCP Artifact Registry, Azure ACR, or
authenticating to any cloud provider to deploy. Without OIDC that means storing a
long-lived access key as a repository secret — a credential that works from
anywhere, forever, until someone remembers to rotate it, and that is present in
every fork-triggered discussion about secret exfiltration.

OIDC replaces that with a short-lived token exchanged at run time: GitHub signs a
JWT asserting *this repository, this workflow, this branch or tag*, and the cloud
provider's trust policy decides whether to issue temporary credentials. What it
gives that `GITHUB_TOKEN` cannot is **cross-provider identity with no stored
secret** — plus the ability to write conditions like "only from `refs/tags/v*` on
this repo", which is finer-grained than any static key can express.

For this lab, reaching for OIDC would be complexity with no gain. Same-registry,
same-repo, ephemeral token — `GITHUB_TOKEN` is already the smaller attack surface.

#### b) Why ship `:latest` alongside an immutable tag?

Lab 6 established that `:latest` is a mutable pointer, and that pinning by digest
or exact version is what makes builds reproducible. Both remain true. `:latest`
still ships for a different audience.

The immutable tag is what **deployments** reference. `v0.1.0` names exactly one
image forever, so a rollback is a redeploy of a known artifact rather than a
gamble on what the tag points at today. Render's configuration in this lab uses
`:v0.1.0` for precisely that reason.

`:latest` is what **humans and tooling that don't care about versions** reference:
`docker run ghcr.io/.../quicknotes` in a README, a smoke test that wants the
newest build, a colleague trying the project for the first time. Making them look
up the current version number to try the thing is friction with no safety benefit
for that use.

The distinction is between *identifying an artifact* and *finding the newest one*.
Shipping both means each need is served by a tag whose semantics match it. The
antipattern is not publishing `:latest` — it is *deploying* `:latest`, where the
running version becomes whatever the last push happened to be.

#### c) `packages: write` and nothing else

The principle is least privilege, and the specific version of it that matters in
CI: the workflow's token should be able to do exactly the job's task and nothing
adjacent to it. This workflow publishes an image, so it gets `packages: write`
and `contents: read`.

The concrete attack the narrow scope prevents is **compromised-dependency
escalation**. A release workflow runs third-party actions and, in the general
case, project build tooling — any of which executes with the job's token. With
`write: all`, code running inside that job can push commits to the default
branch, alter the workflow files themselves, create or close issues and pull
requests, publish releases, and modify repository settings. A malicious or
compromised action would not need to attack the registry at all; it could rewrite
`.github/workflows/` and make every future run hostile, quietly and durably.

With `packages: write` plus `contents: read`, the worst outcome from that same
compromise is a bad image published under a tag. That is serious, and it is
detectable, revocable, and does not persist into the repository itself. The scope
does not prevent compromise — it bounds the blast radius, which is the same
argument as `cap_drop: ALL` in Lab 6 applied to a CI token instead of a container.

---

## Task 2 — Deploy to a Real Cloud (Render)

### 2.1 Configuration

Deployed **from the registry**, not from source — Render's "Existing image" path
pointed at `ghcr.io/hns2112/devops-intro/quicknotes:v0.1.0`.

| Setting | Value |
|---|---|
| Image | `ghcr.io/hns2112/devops-intro/quicknotes:v0.1.0` |
| Region | Frankfurt (EU Central) |
| Instance | Free — 512 MB RAM, 0.1 CPU |
| Health check path | `/health` |

| Env var | Value | Why |
|---|---|---|
| `ADDR` | `0.0.0.0:10000` | Render's expected port; `0.0.0.0` so the platform proxy can reach the listener |
| `DATA_PATH` | `/tmp/notes.json` | the Lab 6 image runs nonroot with a read-only root filesystem |
| `SEED_PATH` | `/app/seed.json` | absolute, independent of working directory |

All three environment variables are the same ones that had to be set explicitly
in Lab 5's VM and Lab 6's container, for the same reasons. The bind address and
the writable data path are not platform quirks — they are properties of the
application that every deployment target surfaces differently.

Setting the health check path to `/health` matters because QuickNotes has no
route on `/`. Left at the default, Render would probe the root, receive 404, and
conclude the service is unhealthy — the identical trap that made the first ZAP
scan in Lab 9 return an almost empty report.

Full config and rationale: [`cloud/render.md`](../cloud/render.md).

### 2.2 It works

```console
$ curl -s https://quicknotes-e5cq.onrender.com/health
{"notes":4,"status":"ok"}

$ curl -s https://quicknotes-e5cq.onrender.com/notes
[{"id":4,"title":"Endpoint cheat-sheet",...},{"id":1,"title":"Welcome to QuickNotes",...},
 {"id":2,"title":"Read app/main.go first",...},{"id":3,"title":"DevOps mantra",...}]
```

Public URL: **https://quicknotes-e5cq.onrender.com**

`GET /` returns `404 page not found`, which is correct — the application defines
no root route.

### 2.3 Scale-to-zero: warm vs cold

Render's dashboard states the behaviour up front: *"Your free instance will spin
down with inactivity, which can delay requests by 50 seconds or more."*

**Warm** — five consecutive requests (`time_total`, seconds):

```
1.252934
1.156695
1.150823
1.144736
1.165416
```

**p50 = 1.157 s**

**Cold** — three measurements, each after >15 minutes of no traffic:

| Measurement | Total | vs warm p50 |
|---|---|---|
| cold-1 | 25.264 s | 21.8× |
| cold-2 | 14.207 s | 12.3× |
| cold-3 | 14.270 s | 12.3× |

The spread between the first and the other two is the interesting part.
`cold-1` was measurably slower, and `cold-2`/`cold-3` agree with each other to
within 63 milliseconds. The most likely explanation is image locality: the first
wake had to pull the image onto whichever node Render scheduled it to, while
later wakes started a container from an image already cached there. That would
also mean the ~14.2 s figure is the steady-state cold start, and the 25.3 s
figure is the *first-deploy-to-that-node* cost — two different numbers that a
single measurement would have conflated.

**Latency breakdown of a warm request:**

```
dns=0.000000 connect=0.056976 tls=0.902002 ttfb=1.209832 total=1.209883
```

| Phase | Cumulative | Cost |
|---|---|---|
| DNS | 0.000 s | cached |
| TCP connect | 0.057 s | 57 ms |
| **TLS handshake** | 0.902 s | **845 ms** |
| First byte | 1.210 s | 308 ms |

TLS is **70% of the total**. The application itself — which Lab 4 measured at
under 300 microseconds on loopback — is nowhere near the dominant cost.

### 2.4 Design questions

#### d) Platform sleep vs Cloud Run scale-to-zero

Both stop charging for idle capacity by stopping the workload, but they are
optimising for different things and the order-of-magnitude gap follows from that.

Cloud Run wakes in the low hundreds of milliseconds because everything is
pre-positioned for it: the image is already resident in Google's registry on the
same infrastructure, the sandbox is a gVisor microVM designed to start fast, and
the platform keeps warm capacity because request-serving latency is the product.
Cloud Run is sold to people running production traffic, so a slow wake would be a
defect.

A free tier on Render or HF is optimising for **cost per idle tenant**, not wake
latency. Free instances are packed densely, given a fraction of a CPU — 0.1 CPU
here — and reclaimed aggressively. A wake means scheduling onto a node, possibly
pulling the image (the 25 s vs 14 s difference above), starting the container, and
waiting for the health check to pass, all on a tenth of a core. There is no
incentive to keep anything warm, because the tier exists to host demos that are
idle almost all the time.

The 14 s figure is the honest price of the free tier, and the platform says so on
the dashboard rather than hiding it.

#### e) Why the port has to be set explicitly

Because the platform cannot know which port the container listens on, and every
platform picks a different default. HF Spaces defaults to **7860** — the Gradio
convention, which makes sense given that the overwhelming majority of Spaces are
Gradio ML demos and defaulting to their port means most users configure nothing.
Render expects **10000**. QuickNotes listens on whatever `ADDR` says, defaulting
to 8080.

The platform's proxy has to route inbound HTTPS to *some* container port, and it
either scans for an open one or trusts a declared value. Getting it wrong
produces the same symptom on both: the container is running, the logs look
healthy, and every request from the outside times out or 502s — because the proxy
is knocking on a port nobody is listening to.

The lab's guidance not to change QuickNotes itself is the right instinct. The
port is deployment configuration, and the application already exposes it as
`ADDR`. Editing the source to match each platform's default would be hard-coding
an environment into the artifact — the opposite of what the twelve-factor
argument, and Lab 6's environment-variable design, are for.

#### f) Pulling the image vs building inside the platform

This deployment pulls the pre-built image, and the trade-off is real in both
directions.

**Pulling wins on reproducibility and on trust in what is running.** The bytes
serving traffic are byte-identical to the bytes CI built, scanned in Lab 9, and
tagged `v0.1.0`. There is exactly one build, so there is no possibility of the
deployed artifact differing from the tested one because the platform's build
environment resolved a dependency differently or used another base image
revision. It is also much faster — Render had nothing to compile, so the deploy
was a pull and a start.

**Building in the platform wins on debuggability and on coupling.** Build logs
live next to runtime logs in one dashboard, so a failure is diagnosed in one
place rather than by correlating a CI run with a deploy event. There is no
registry in the middle to configure, authenticate against, or have go down. And
a source-connected build redeploys automatically on push, which is the workflow
most people actually want for a demo.

The deciding argument for pulling here is that it makes Task 1 and Task 2 a
single pipeline rather than two. The tag triggers the build, the build produces
the artifact, the artifact is what deploys — which is the shape the lab's own
guideline describes as production rehearsal. Building twice from the same source
would have produced two images that are *probably* the same, and "probably" is
what the immutable tag exists to eliminate.

---

## Bonus Task — Cloudflare Tunnel

### B.1 Setup

QuickNotes running locally via `go run` on Windows, bound to `127.0.0.1:8080`,
exposed with a quick tunnel:

```console
$ cloudflared tunnel --url http://localhost:8080
INF |  Your quick Tunnel has been created! Visit it at:                |
INF |  https://subsequent-workstation-foster-again.trycloudflare.com   |
INF Registered tunnel connection connIndex=0 location=dfw11 protocol=quic

|  COMPONENT         TARGET                     STATUS  DETAILS                       |
|  DNS Resolution    region1.v2.argotunnel.com  PASS    DNS Resolved successfully     |
|  UDP Connectivity  region1.v2.argotunnel.com  PASS    QUIC connection successful    |
|  TCP Connectivity  region1.v2.argotunnel.com  PASS    HTTP/2 connection successful  |
|  Cloudflare API    api.cloudflare.com:443     PASS    API is reachable              |
|  SUMMARY: Environment is healthy. cloudflared will use 'quic' as primary protocol.  |
```

No Cloudflare account, no domain, no card. The edge that accepted the connection
is `dfw11` — Dallas — which matters for the latency analysis below.

### B.2 Verified from outside

```console
$ curl -s https://subsequent-workstation-foster-again.trycloudflare.com/health
{"notes":4,"status":"ok"}
```

Also opened on an Android phone, which returned the same JSON.

**Stated plainly:** the lab asks for verification from cellular data. Cellular was
unavailable, so the phone used the same Wi-Fi as the host — but without the VPN
the host routes through, so the request left from a different public IP and took
a different path.

That still demonstrates public routability rather than LAN reachability, and the
reason is architectural: a quick tunnel has **no LAN path by construction**.
`cloudflared` holds an outbound QUIC connection to a Cloudflare edge, and the
public hostname resolves to Cloudflare's anycast addresses. Nothing on the local
network can reach the origin through that hostname without traversing the edge —
there is no route that stays inside the house.

### B.3 Comparison

| Metric | Render (hosted) | Cloudflare Tunnel (local-via-edge) |
|---|---|---|
| Warm p50 | 1.157 s | 1.417 s |
| Warm p95 | not sampled (n=5) | 2.431 s |
| Warm min / max | 1.145 / 1.253 s | 1.374 / 2.910 s |
| Cold start | 14.2 s steady, 25.3 s first | N/A — continuously local |
| TLS handshake | 845 ms (70% of total) | 814 ms (59% of total) |
| Public URL stability | stable | ephemeral, changes on restart |
| Cost | free | free |

Tunnel measurements are 50 requests; Render's are 5, per the respective task
specs. The tunnel's much wider spread — 1.37 s to 2.91 s against Render's 1.14 s
to 1.25 s — is itself a finding, and §B.4(h) explains why.

### B.4 Design questions

#### g) Which one is "really cloud"?

By any infrastructure definition, only Render is. The container runs in someone
else's datacenter on someone else's hardware, scheduled by a platform that will
restart it, scale it to zero, and keep serving if the laptop it was deployed from
falls into a lake. With the tunnel, the workload runs on a Windows laptop in a
flat in Kazan; Cloudflare provides routing and TLS termination, not compute.

**To users, the distinction is invisible and mostly irrelevant** — both are
HTTPS URLs returning the same JSON, and no client can tell where the process
lives. It becomes visible only through availability, and then decisively: the
tunnel's uptime is the laptop's uptime, its capacity is one laptop, and its URL
dies with the `cloudflared` process. The Render deployment survives a closed lid.

The useful framing is that "cloud" describes an operational property — someone
else runs it, it outlives your session, capacity is not yours to run out of —
rather than a network topology. The tunnel is a *public URL*, which is a genuinely
useful thing and not the same thing.

#### h) What dominates latency in each

**Render: TLS, at 845 ms of a 1210 ms request — 70%.** The application is
answering in well under a millisecond; the connection setup to Frankfurt, over a
VPN, is the whole cost. Both the 57 ms TCP connect and the 845 ms handshake are
round-trip time multiplied by the number of round trips, and the VPN inflates
each one.

**Tunnel: TLS again (814 ms, 59%), but the tail is what distinguishes it.**
p95 is 2.43 s against a 1.42 s p50 — a 1 second spread, where Render's five
samples fell within 110 ms of each other. The path explains it: client → VPN
exit → Cloudflare edge in Dallas → QUIC tunnel back to a laptop in Kazan → and
the whole way back. Two intercontinental crossings per request instead of one,
and the return leg terminates on a consumer connection with no SLA, competing
with whatever else that link is doing.

So the same component dominates the median in both cases, but for different
reasons — Render's is distance plus VPN, the tunnel's is distance plus VPN plus
a second hop — and only the tunnel has a tail driven by a residential uplink.

Worth naming what this measurement does *not* show: neither number says anything
about how fast QuickNotes is. Lab 4 measured it at 196 microseconds on loopback.
Everything here is network.

#### i) When is Cloudflare Tunnel the right production pick?

It is right whenever the workload genuinely has to run somewhere you control and
the problem is only reaching it. **Home labs and self-hosted services** are the
canonical case — the compute already exists and is paid for, and the tunnel
replaces port forwarding, dynamic DNS, and exposing an IP. **On-prem services**
that must stay on-prem for data residency or licensing, but need external access,
are the enterprise version of the same shape; a named tunnel with Cloudflare
Access in front is a legitimate architecture, not a hack. **Sharing work in
progress** — a stakeholder demo, a webhook endpoint a third party must reach
during development, testing an OAuth callback — is where quick tunnels shine
precisely because they are ephemeral.

The security property that makes it defensible is that the origin opens an
**outbound** connection. No inbound firewall rule, no exposed port, no public IP,
and the origin's address is never revealed.

It is **never** the right pick when the thing being solved is availability or
scale. If the requirement is "this must stay up when my machine does not", the
tunnel is a single point of failure with a human attached — and a quick tunnel's
URL changing on every restart makes it unusable for anything another system
depends on. It is equally wrong as a way to dodge hosting costs for a real
service: the compute did not become free, it moved onto hardware with no
redundancy, no monitoring, and an electricity bill.

---

## Teardown

Documented in [`cloud/teardown.md`](../cloud/teardown.md). Both the Render
service and the ghcr.io package cost $0 if left in place; the runbook covers
removing them anyway, along with the Git tag.

---

## Summary

| Task | Status |
|------|--------|
| Task 1 — tag → CI → ghcr.io, publicly pullable | Complete |
| Task 2 — public cloud deployment, scale-to-zero measured | Complete (Render, substituting for the now-paid HF Docker Spaces) |
| Bonus — Cloudflare Tunnel, comparison table | Complete |
