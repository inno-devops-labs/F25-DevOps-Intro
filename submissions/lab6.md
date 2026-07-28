# Lab 6 — Containers

Branch: `feature/lab6`

The implementation is in [`app/Dockerfile`](../app/Dockerfile) and
[`compose.yaml`](../compose.yaml). Automated Docker, Compose, persistence,
hardening, and Trivy evidence will be committed with the final lab update.

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

## Security defaults

The image runs as UID/GID 65532 (`nonroot`), uses distroless, and Compose drops
all capabilities, makes the root filesystem read-only, supplies a small
`noexec,nosuid` tmpfs, and enables `no-new-privileges`. Trivy 0.59.1 runs
against the built image in CI.

Dropping all capabilities is the strongest security-per-line default here:
QuickNotes needs none, so one short setting removes many privileged kernel
operations even if the process is compromised. Read-only root and nonroot
execution are similarly valuable complementary boundaries; none replaces
patching the application.
