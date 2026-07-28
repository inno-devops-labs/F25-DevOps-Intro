# Lab 10 — Cloud Computing

Branch: `feature/lab10`

## Task 1 — release to GHCR

[`release.yml`](../.github/workflows/release.yml) triggers only for `v*` tags,
rejects non-semver tag names, builds the hardened distroless image, and pushes
both the immutable version and `latest` to:

```text
ghcr.io/mimir-sma/devops-intro/quicknotes
```

It uses the repository-scoped `GITHUB_TOKEN`, grants only `contents: read` and
`packages: write`, SHA-pins its sole action, inspects the remote manifest,
pulls the version back, and smoke-tests `/health`.

The signed `v0.1.0` tag points to commit
`98476a64f0d408f076974ccbcc43460868829bdd`. The complete release succeeded in
[GitHub Actions run 30339331330](https://github.com/Mimir-sma/DevOps-Intro/actions/runs/30339331330):
both `v0.1.0` and `latest` were pushed, the remote manifest was inspected, the
image was pulled back, and `/health` passed.

An independent unauthenticated manifest request currently returns HTTP 401.
GitHub creates a personal-account GHCR package as private on first publish;
the remaining required action is the package owner choosing **Package
settings → Change visibility → Public**. This irreversible account-level UI
choice is not claimed as complete. After it is changed, this command is the
clean proof:

```console
$ docker pull ghcr.io/mimir-sma/devops-intro/quicknotes:v0.1.0
```

**a — OIDC.** `GITHUB_TOKEN` is ideal for a package owned by the same GitHub
repository. OIDC is preferable when assuming a short-lived role in AWS, GCP,
Azure, or another trust domain: the provider verifies repository/workflow
claims and issues temporary credentials, avoiding a stored long-lived cloud
secret.

**b — latest and immutable.** Automation and rollback must deploy the immutable
version or digest. `latest` remains a convenient human/default discovery tag
for local evaluation and tools that expect a channel pointer; it is an alias,
not a release identity.

**c — least privilege.** The job can read source and write packages but cannot
modify repository contents, issues, deployments, or other scopes. If a build
step is compromised, the narrow token prevents it from rewriting code/tags or
performing unrelated write actions available under `write-all`.

## Task 2 — Hugging Face Space artifacts

[`cloud/huggingface/Dockerfile`](../cloud/huggingface/Dockerfile) promotes the
same immutable GHCR image. The accompanying Space
[`README.md`](../cloud/huggingface/README.md) declares Docker SDK and
`app_port: 8080`.

A Hugging Face account/token is not available in this workspace, so no Space
URL, curl response, or cold/warm numbers are claimed. Once the GHCR package is
public, these two files can be pushed unchanged to a public Docker Space.

**d — sleep versus scale-to-zero.** Both stop idle compute, but Spaces may need
to allocate a shared builder/runtime, restore a repository/image, and start a
general interactive workload. Serverless platforms optimize a pre-integrated
request path, small instances, cached images, and rapid sandbox activation;
HF optimizes free collaborative model/app hosting.

**e — app port.** Docker Spaces assume port 7860 because Gradio and Streamlit
apps commonly listen there. QuickNotes listens on 8080, so metadata must tell
the platform which container port its proxy should route to.

**f — promote versus rebuild.** Pulling the release preserves the exact tested
digest, shortens the Space build, and centralizes provenance. Rebuilding in
the Space is easier to debug from one repository and does not depend on GHCR
visibility, but duplicates work and can drift if bases or build inputs are not
digest-pinned.

## Bonus — Cloudflare Tunnel artifacts

[`cloud/cloudflare/README.md`](../cloud/cloudflare/README.md) contains the exact
quick-tunnel procedure, and
[`cloud/measure-latency.sh`](../cloud/measure-latency.sh) calculates p50/p95
from real curl samples. This machine has no Docker/cloudflared and no second
network, so a public ephemeral URL and measurements are not fabricated.

**g — architecture.** HF runs the container in a provider datacenter;
Cloudflare only proxies to a process still running on the laptop. Both use
cloud services from the user's perspective, but ownership, availability,
power/network dependency, and operational responsibility differ materially.

**h — latency.** Warm HF latency is dominated by client-to-HF routing, proxy,
and container processing. A tunnel adds client-to-Cloudflare, Cloudflare edge
processing, the persistent tunnel path to the local ISP/laptop, and the local
service; the last-mile uplink often dominates.

**i — fit.** A tunnel fits temporary review URLs, home labs, and carefully
controlled on-prem services that must remain local. A quick tunnel is wrong
for regulated data, strong availability/SLOs, stable addressing, or any
production service dependent on a developer laptop.
