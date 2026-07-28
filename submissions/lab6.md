# Lab 6 — Containers

Branch: `feature/lab6`

The implementation is in [`app/Dockerfile`](../app/Dockerfile) and
[`compose.yaml`](../compose.yaml). The complete captured output is in
[`lab6/evidence.txt`](../lab6/evidence.txt) and the unabridged scan is in
[`lab6/trivy.txt`](../lab6/trivy.txt). All of it was produced by
[GitHub Actions run 30337069011](https://github.com/Mimir-sma/DevOps-Intro/actions/runs/30337069011)
on Ubuntu 24.04 with Docker, rather than transcribed expected output.
The builder is pinned to the last Go 1.24 patch, 1.24.13, rather than the
older point release used in the VM exercise.

## Task 1 — image

The final image is 13,533,837 bytes (13.53 MB decimal), below the 25 MB
limit. The `golang:1.24.13-bookworm` builder image is 854,104,362 bytes, so
the multi-stage build excludes about 840 MB of compiler and build
environment.

```text
User="nonroot:nonroot"
Entrypoint=["/quicknotes"]
ExposedPorts={"8080/tcp":{}}
```

The actual timing comparison was:

| Build | Naive order | Optimized order |
|---|---:|---:|
| Cold | 27,362 ms | 12,030 ms |
| After a source-only edit | 10,961 ms | 11,001 ms |

The optimized cold result benefited from already-fetched/shared base layers,
so it is not a controlled claim that ordering alone halves cold builds. The
rebuilds are essentially equal because this small module has no external
dependencies; `go mod download` has almost no work. The structural advantage
appears once dependencies exist: source edits no longer invalidate their
download layer.

The runtime health response was:

```json
{"notes":4,"status":"ok"}
```

## Design answers

**a — layer order.** Docker reuses a layer only while its instruction and
inputs are unchanged. Copying the entire tree before `go mod download` makes
any source edit invalidate the dependency layer. Copying `go.mod` first keeps
that layer reusable; this repository has no dependencies and thus no `go.sum`.
The workflow measures cold and source-only rebuilds of both an intentionally
naive Dockerfile and the submitted optimized one.

**b — static binary.** `CGO_ENABLED=0` removes the libc/dynamic-loader
dependency for this pure-Go program. Without it, a dynamically linked binary
can fail in `distroless/static` with a misleading `no such file or directory`
because the requested ELF interpreter is absent.

**c — distroless static.** The runtime contains the minimal files needed by a
static program, including certificates and basic identity data, but no shell,
package manager, compiler, or general userland. Fewer packages mean a smaller
attack surface and fewer irrelevant OS-package CVEs; application and Go
runtime vulnerabilities still matter.

**d — build flags.** `-ldflags="-s -w"` removes the symbol table and DWARF
debug data, reducing size at the cost of poorer native debugging. `-trimpath`
removes local filesystem paths from the result, improving reproducibility and
privacy, also at the cost of less specific debug paths.

**e — healthcheck.** The image includes a purpose-built static `/healthcheck`
binary, built in the same builder stage. Compose invokes it directly in exec
form, so the runtime needs neither `/bin/sh` nor curl/wget.

**f — volume lifetime.** A named volume is a Docker-managed object independent
of a particular container, so ordinary `docker compose down` removes
containers and networks but retains it. `docker compose down -v` (or an
explicit `docker volume rm`) destroys it.

**g — dependency readiness.** Plain `depends_on` controls creation/start order,
not application readiness. A dependent service can start while its dependency
is still initializing and fail its first requests; health-conditioned
dependencies or retry/backoff are needed.

## Task 2 — persistence

CI created this record:

```json
{"id":5,"title":"durable","body":"survive a restart"}
```

After `docker compose down` and `up`, `GET /notes` still contained the
`durable` record. After `docker compose down --volumes` and a new `up`, the
response contained only the four seed records. The workflow asserts both
conditions and fails if either invariant is false; the exact JSON is preserved
in `lab6/evidence.txt`.

## Security defaults

The image runs as UID/GID 65532 (`nonroot`), uses distroless, and Compose drops
all capabilities, makes the root filesystem read-only, supplies a small
`noexec,nosuid` tmpfs, and enables `no-new-privileges`. Trivy 0.59.1 runs
against the built image in CI.

Enforcement evidence:

```text
CapDrop=["ALL"]
ReadonlyRootfs=true
SecurityOpt=["no-new-privileges:true"]
exec: "sh": executable file not found in $PATH
shell_exit_status=127
```

Trivy found zero HIGH/CRITICAL vulnerabilities in the Debian distroless OS
layer. It found 12 HIGH and 0 CRITICAL findings in each Go binary's embedded
standard library. This is an important distinction: a minimal base removes
OS-package exposure but cannot patch an end-of-life language runtime. Go
1.24.13 is used here because Lab 6 explicitly requires Go 1.24; Lab 9 treats
the remaining findings as remediation input and upgrades the build toolchain.

Dropping all capabilities is the strongest security-per-line default here:
QuickNotes needs none, so one short setting removes many privileged kernel
operations even if the process is compromised. Read-only root and nonroot
execution are similarly valuable complementary boundaries; none replaces
patching the application.
