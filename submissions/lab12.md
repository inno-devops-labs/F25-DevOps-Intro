# Lab 12 — Bonus: WebAssembly Containers — A QuickNotes Endpoint on Spin

**Author:** HNS ([@HNS2112](https://github.com/HNS2112))
**Date:** 10 August 2026
**Test rig:** MacBook Air M3 (Apple Silicon, arm64), macOS, 16 GB RAM
**Toolchain:** Spin 4.0.2, componentize-go 0.3.3, Go 1.25.12 (`GOTOOLCHAIN=local`),
wasmtime 47.0.3, hyperfine 1.20.0, Docker 29.6.2

Raw output is committed under `evidence/lab12/`; sources under `wasm/` and `wasm-cli/`.

---

## Toolchain: what the lab describes no longer exists

The lab pins **Spin 3.4 + TinyGo 0.41 + `spin-go-sdk/v2`** and was validated in
May 2026. Scaffolding with `spin new -t http-go` on Spin 4.0.2 produces something
different in three ways, and the lab's own instruction — *"Do not hand-write
`spin.toml` from an old tutorial… scaffold the canonical layout for your Spin
version"* — is exactly why this report follows the scaffold rather than the text.

| Lab says | Spin 4.0.2 scaffold produces |
|---|---|
| `tinygo build -target=wasip1 -buildmode=c-shared` | `go tool componentize-go build` |
| `github.com/spinframework/spin-go-sdk/v2` | `github.com/spinframework/spin-go-sdk/v3 v3.0.0` |
| TinyGo as the compiler | upstream Go via `componentize-go` |

**TinyGo is not used at all.** It was installed and never invoked. That
invalidates the premise of two design questions: (b) asks why the build needs
`-buildmode=c-shared`, and (d) asks which TinyGo stdlib gap was hit. Both are
answered below for what they were actually asking, with the substitution stated.

### Four failures before the first successful build

Recorded because they are the real content of "WASM tooling moves fast — pin
your versions", and because three of the four are bugs in released tooling
rather than mistakes in configuration.

**1. Windows: the installer downloads a file that does not exist.**

```
Downloading `componentize-go` binary from
https://github.com/.../v0.3.3/componentize-go-windows-amd64.tar.gz
2026/08/10 11:35:39 unexpected status for URL `...tar.gz`: 404
```

The release publishes `componentize-go-windows-amd64.zip`. The tool asks for
`.tar.gz` on every platform. Installing the binary manually to the exact cache
path it prints did not help — it re-attempts the download regardless.

**2. The scaffold ships no `wit/` directory.**

```
Error: failed to read path for WIT [wit]
Caused by: No such file or directory (os error 2)
```

Reproduced identically on Windows and macOS, so it is the template, not the
platform. Worked around by copying the `wit/` tree from `componentize-go`'s own
`examples/wasip2`.

**3. The Go linker segfaults under Go 1.26.5.**

```
runtime.wasiOnIdle.wrapinfo: missing section for relocation target
[signal SIGSEGV: segmentation violation]
cmd/link/internal/ld.(*pclntab).generateFuncdata.func2
cmd/link/internal/wasm.asmb
```

Same crash, same stack frame, on Windows/amd64 and macOS/arm64. Not a
configuration error — a linker bug hit by `componentize-go 0.3.3` on that Go
version.

**4. Downgrading Go required disabling the toolchain switcher.**

Installing Go 1.24 and putting it first in `PATH` changed nothing:

```console
$ export PATH="/opt/homebrew/opt/go@1.24/bin:$PATH" && go version
go: downloading go1.25.5 (darwin/arm64)
go version go1.25.5 darwin/arm64
```

`GOTOOLCHAIN=auto` silently fetched a newer Go because `go.mod` asked for it —
the same mechanism documented in Lab 3 §2.2, where it made a CI version matrix
test one compiler under two names. `GOTOOLCHAIN=local` pinned it. Go 1.24 was
then rejected (`componentize-go requires go >= 1.25`), so **Go 1.25.12** is the
one narrow version that works: new enough for the tool, old enough for the linker.

**And then the tool solved the problem it had been crashing on:**

```
Note: /opt/homebrew/Cellar/go@1.25/1.25.12/libexec/bin/go does not support
async operation; will use downloaded version.
See https://github.com/golang/go/pull/76775 for details.
Downloading patched Go from
https://github.com/dicej/go/releases/download/go1.25.5-wasi-on-idle-v2/...
Finished building all Spin components
```

`componentize-go` detects that the host Go lacks the `wasi-on-idle` patch and
downloads a patched fork. Under Go 1.26.5 that detection never fired and the
stock linker crashed instead — which is why the failure looked like a
configuration problem for four attempts.

---

## Task 1 — WASM Endpoint with the Spin SDK

### 1.1 `spin.toml`

```toml
spin_manifest_version = 2

[application]
name = "moscow-time"
version = "0.1.0"

[[trigger.http]]
route = "/time"
component = "moscow-time"

[component.moscow-time]
source = "main.wasm"
allowed_outbound_hosts = []
[component.moscow-time.build]
command = "go tool componentize-go build"
watch = ["**/*.go", "go.mod"]
```

Only `route` was edited (from the scaffold's `/...`). The build command is the
scaffold's own and was left alone, per requirement 1.3.

### 1.2 `main.go`

```go
package main

import (
	"encoding/json"
	"net/http"
	"time"

	spinhttp "github.com/spinframework/spin-go-sdk/v3/http"
)

// Russia abolished DST in 2011, so Moscow is a constant UTC+3 offset and needs
// no tzdata lookup — which matters because the wasip2 sandbox has no
// /usr/share/zoneinfo to read.
var moscow = time.FixedZone("MSK", 3*60*60)

type timeResponse struct {
	Unix       int64  `json:"unix"`
	ISO        string `json:"iso"`
	HourMinute string `json:"hour_minute"`
	Zone       string `json:"zone"`
}

func init() {
	spinhttp.Handle(func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodGet {
			w.Header().Set("Allow", "GET")
			http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
			return
		}

		now := time.Now().In(moscow)
		resp := timeResponse{
			Unix:       now.Unix(),
			ISO:        now.Format(time.RFC3339),
			HourMinute: now.Format("15:04"),
			Zone:       "Europe/Moscow (UTC+3)",
		}

		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		if err := json.NewEncoder(w).Encode(resp); err != nil {
			http.Error(w, "encoding failed", http.StatusInternalServerError)
		}
	})
}

// main is required by the compiler but never executed — the entry point is the
// handler registered in init().
func main() {}
```

### 1.3 Build and run

```console
$ spin build
Building component moscow-time with `go tool componentize-go build`
Using /Users/elvira/Library/Caches/componentize-go/v2/go-darwin-arm64-bootstrap/bin/go.
Finished building all Spin components

$ ls -la main.wasm
-rw-r--r--  1 elvira  staff  5242031 Aug 10 17:56 main.wasm

$ spin up
Serving http://127.0.0.1:3000
Available Routes:
  moscow-time: http://127.0.0.1:3000/time

$ curl -s http://127.0.0.1:3000/time | python3 -m json.tool
{
    "unix": 1786374003,
    "iso": "2026-08-10T18:00:03+03:00",
    "hour_minute": "18:00",
    "zone": "Europe/Moscow (UTC+3)"
}
```

**main.wasm: 5,242,031 bytes (5.24 MB).**

### 1.4 Design questions

#### a) Browser WASM vs server WASM

`GOOS=js GOARCH=wasm` targets a JavaScript host. The module cannot do anything
by itself — every capability arrives through the `syscall/js` bridge, so there is
no filesystem, no sockets, no environment, no clock except what JS hands over. It
ships alongside `wasm_exec.js`, and the browser's own sandbox is the security
boundary.

`GOOS=wasip1` (or the wasip2 component this lab builds) targets a **WASI host**.
What is gained is a real system interface: files, sockets, environment variables,
clocks, standard streams — enough to run server code without a browser. What is
missing relative to a native binary is everything the host declines to grant,
and the grant is explicit rather than assumed.

The concrete difference showed up in this lab twice. Timezone data: there is no
`/usr/share/zoneinfo` unless the host mounts it, so `time.LoadLocation` cannot
work — hence `time.FixedZone`. And networking: `allowed_outbound_hosts = []`
means the module has no way to open a socket, not that it is forbidden to.

Both targets are sandboxed. Browser WASM is sandboxed by the browser and reaches
the world through JavaScript; server WASM is sandboxed by the WASI host and
reaches the world through capabilities the host chose to pass in.

#### b) Why `-buildmode=c-shared`? — and why it is absent here

**The scaffold does not use it.** Spin 4 builds with
`go tool componentize-go build`, which produces a **wasip2 component**, not a
wasip1 module, so the flag is not part of the pipeline at all. Removing it and
observing the failure, as the question suggests, is not possible.

The reasoning the question is after still holds for the TinyGo path. A normal
executable exports `_start` and runs to completion. That is the wrong shape for
a Spin component: the host does not want to *run* the module, it wants to *call
into* it once per HTTP request, repeatedly, while the module stays instantiated.
`-buildmode=c-shared` produces a library — exported symbols and no `_start` — so
the host can invoke the registered handler. Without it, TinyGo emits a command
module, Spin finds no handler to call, and the lab's own pitfalls list records
the symptom: HTTP 500 with empty component logs.

The componentize-go path reaches the same end differently. The component's
interface is described by WIT, and the build emits exports matching
`wasi:http/incoming-handler` — the contract is declared in the type system
rather than implied by a linker flag. §B.3(h) below shows what that contract
looks like when it does not match.

#### c) `allowed_outbound_hosts = []` and capability-based security

The empty list means the component is granted **no** outbound network capability.
This is not a firewall rule evaluated when a connection is attempted — the
capability is never handed to the guest, so the code has nothing to call. There
is no socket API present to misuse.

That is the substantive difference from Docker's `--network none`. Both end with
"this workload cannot reach the network", but they get there from opposite
directions. Docker's default is full network access, narrowed by configuration;
the container still has a full syscall interface, and `--network none` removes
the interfaces and routes the kernel would otherwise offer. WASM's default is
**nothing**, widened by explicit grant; the guest has no ambient authority to
remove.

The practical consequence is what happens when the configuration is wrong. Forget
`--network none` and the container silently has full network access. Forget
`allowed_outbound_hosts` and the component has none — the failure mode is denial,
not exposure. Deny-by-default versus allow-by-default, which is the same argument
`cap_drop: ALL` makes in Lab 6, taken one level further: capabilities cannot be
dropped because they were never granted.

Docker's model is also coarse. `--network none` is all or nothing; letting a
container reach exactly one host means a custom network or an egress proxy. Spin
takes a host allowlist directly in the manifest, versioned alongside the code.

#### d) Stdlib gaps

**TinyGo was not used, so its gaps were not hit.** The build used upstream Go via
`componentize-go`, where `encoding/json` and reflection work normally — the
handler marshals a struct with `json.NewEncoder`, which the lab warns may fail
under TinyGo.

The gap that *was* hit is the sandbox's, not the compiler's: **`time.LoadLocation`
cannot work**, because the wasip2 guest has no filesystem access unless granted
and therefore no `/usr/share/zoneinfo` to read. The lab anticipates this and
prescribes the same fix used here — a fixed UTC+3 offset, valid for Moscow
because Russia abolished DST in 2011.

The distinction is worth keeping straight. A TinyGo stdlib gap is *"this Go
feature is not implemented in this compiler"*. A WASI gap is *"this call is
implemented, and the host did not grant the capability it needs"*. The first is
fixed by changing compilers; the second is the sandbox working as designed.

The other real cost is size: 5.24 MB for one endpoint, because upstream Go
brings its full runtime and GC. TinyGo's whole reason for existing on this target
is producing far smaller modules by leaving most of that out.

---

## Task 2 — Perf Comparison vs the Lab 6 Container

### 2.1 Method

Both services running simultaneously on the same machine. Warm latency via
`hyperfine --warmup 5 --runs 50` against `/time` (Spin) and `/health` (Docker).
Cold start: stop the runtime, restart it, poll until the first successful
response — five samples each, timed in Python around the loop.

### 2.2 Results

| Dimension | Lab 6 Docker | Lab 12 WASM/Spin |
|---|---|---|
| Artifact size | 16.2 MB (image) | **5.24 MB** (main.wasm) |
| Cold start (p50) | 139.9 ms | **137.2 ms** |
| Cold start (range) | 131.5 – 143.7 ms | 134.6 – 171.7 ms |
| Warm latency mean | 11.3 ± 1.1 ms | **10.5 ± 0.8 ms** |
| Warm latency range | 7.8 – 12.8 ms | 8.8 – 11.8 ms |

Raw cold-start samples:

```
docker cold-1 = 137.5 ms      spin cold-1 = 171.7 ms
docker cold-2 = 143.7 ms      spin cold-2 = 136.3 ms
docker cold-3 = 139.9 ms      spin cold-3 = 137.2 ms
docker cold-4 = 131.5 ms      spin cold-4 = 134.6 ms
docker cold-5 = 140.7 ms      spin cold-5 = 139.9 ms
```

**Cold start came out essentially identical — 137 ms against 140 ms.** That is
not the result the lab's framing predicts, and it is the most interesting number
here. §2.3(e) works through why.

Warm latency differs by 7%, within the noise. Both figures are dominated by
process-spawn overhead for `curl` rather than by either service: Lab 4 measured
QuickNotes itself at 196 microseconds on loopback, roughly fifty times less than
what `hyperfine` reports for the whole invocation. The measurement is fair —
both sides pay the same overhead — but it is measuring `curl` more than it is
measuring the runtimes.

The size difference is the one clear win: **3.1× smaller**, 5.24 MB against
16.2 MB.

### 2.3 Design questions

#### e) What dominates each cold start

The lab's expectation is *"Container: image extract + namespace init. Spin:
wasmtime instantiation + WASM module load"*, implying WASM should win. It did
not, and the reason is that the expectation describes a first-run container while
the measurement used `docker start` on an existing one.

**Docker (~140 ms):** no image extraction happens. The image was pulled and
unpacked once; `docker start` creates namespaces and cgroups, sets up the network
namespace and the port mapping, and `exec`s a statically linked binary that
serves its first request in microseconds. The dominant cost is the Docker daemon
round-trip and namespace setup — and, on Apple Silicon, that setup happens inside
the Linux VM that Docker Desktop runs, adding a hop that would not exist on Linux.

**Spin (~137 ms):** no namespaces at all. Spin reads and validates the manifest,
loads the 5.24 MB module, JIT-compiles it in wasmtime, links the wasi-http
imports, and binds an HTTP listener. Module load and compilation scale with
module size, which is where the 5.24 MB of Go runtime shows up as a cost rather
than just as disk usage.

Two different sets of work, arriving at the same wall-clock number by
coincidence. The comparison would separate them under conditions this rig did not
test: a cold image pull adds seconds to the container and nothing to Spin, while
Spin's per-*request* instantiation — the number that matters for
scale-to-zero — is microseconds against a container's ~140 ms, because a warm
Spin process instantiates a fresh module per request rather than starting a
process.

That last point reframes the whole table. Comparing *runtime startup* is
comparing the wrong thing; the WASM advantage is that after startup there is no
per-tenant process at all.

#### f) Where WASM wins, where Docker still wins

**WASM wins where the unit of work is small, short, and numerous.** Edge
functions and per-request handlers: instantiating a module per request is
microseconds, so scale-to-zero is free and there is no cold-start tax on the
first request after idle — the property that made Lab 10's Render deployment take
14 seconds to wake. Massive multi-tenancy: thousands of untrusted tenants on one
process, each in its own instance, with no per-tenant kernel object. Plugin
systems, where untrusted third-party code must run inside a host application —
Envoy filters, database UDFs, extension APIs — because a container is far too
heavy and a shared library has no boundary at all. And portability: one artifact
runs on arm64 and amd64 unchanged, which Lab 6 showed containers do not (the
image built 16.2 MB on arm64 and 9.22 MB on amd64, and needed
`platforms: linux/amd64` in Lab 10 to deploy at all).

**Docker still wins whenever the workload needs a real operating system.** Any
existing application that assumes threads, `fork`, signals, or a full filesystem
— which is most software. Anything needing native libraries, CGO, or hardware
access. Stateful services: databases and queues want persistent volumes, real
disk semantics, and a process model WASI does not fully provide. Long-running
workloads where startup cost amortises to nothing and the ecosystem — images,
registries, orchestrators, monitoring, the whole toolchain used across Labs 6,
8, 9 and 10 — is worth more than a few hundred milliseconds.

The honest summary from this lab's own numbers: for one HTTP endpoint on a
laptop, WASM is 3× smaller and otherwise indistinguishable. The interesting
differences live at scale and at the sandbox boundary, neither of which a
two-service benchmark on a MacBook can show.

#### g) What multi-tenant attack WASM makes harder

**Container escape via a kernel vulnerability.** A container is a process with
namespaces, cgroups and seccomp filters applied; it shares one kernel with the
host and every other tenant, and it reaches that kernel through hundreds of
syscalls. Escapes work by finding a bug in one of them — Dirty COW, Dirty Pipe,
the `waitid` CVE-2017-5123, io_uring bugs — and using it to break out of the
namespace into the host, and from there into other tenants.

A WASM guest has **no syscall interface to attack**. It cannot issue a syscall;
it can only call imported functions the host explicitly provided. With
`allowed_outbound_hosts = []` and no filesystem grant, the import list for this
component is close to empty. The kernel attack surface reachable from guest code
is not narrowed — it is absent, because there is no path from guest code to the
kernel that does not pass through host code the host wrote.

Memory isolation is structural too. A WASM instance's linear memory is a bounded
region with every access bounds-checked by the runtime; there are no raw pointers
into host memory to corrupt. A container shares the host's address space model
and relies on the MMU plus kernel correctness for the same guarantee.

The boundary is smaller and easier to audit, which is the real claim: not that
wasmtime has no bugs, but that its interface is a few dozen host functions
instead of a few hundred syscalls plus every kernel subsystem behind them. And a
sandbox escape in a container is a kernel exploit affecting every workload on the
machine; a sandbox escape in WASM is a runtime bug affecting that runtime.

---

## Bonus Task — Two WASM Execution Models

### B.1 The standalone WASI CLI module

`wasm-cli/main.go` implements the same Moscow-time logic in the CGI shape:
request context from environment variables, response to stdout, process exits.

```go
func main() {
	method := os.Getenv("REQUEST_METHOD")
	path := os.Getenv("PATH_INFO")
	// ... 405 / 404 guards ...
	now := time.Now().In(moscow)
	body, _ := json.Marshal(timeResponse{ /* ... */ })
	fmt.Println("Content-Type: application/json")
	fmt.Println()
	fmt.Println(string(body))
}
```

**Build** — the lab prescribes `tinygo build -target=wasi`, but TinyGo is not part
of this toolchain (see above). Upstream Go targets wasip1 directly:

```console
$ GOOS=wasip1 GOARCH=wasm go build -o main.wasm .
$ ls -la main.wasm
-rwxr-xr-x  1 elvira  staff  3184098 Aug 10 18:06 main.wasm
```

**Run:**

```console
$ wasmtime run --env REQUEST_METHOD=GET --env PATH_INFO=/time main.wasm
Content-Type: application/json

{"unix":1786374493,"iso":"2026-08-10T18:08:13+03:00","hour_minute":"18:08","zone":"Europe/Moscow (UTC+3)"}
```

### B.2 Comparison

| Dimension | Spin component (wasip2) | CLI module (wasip1) |
|---|---|---|
| Size | 5.24 MB | **3.18 MB** |
| Model | persistent wasi-http server | per-invocation process |
| Per-request cost | 10.5 ms (via curl, warm) | **20.2 ± 1.2 ms** per `wasmtime run` |
| Runtime startup | ~137 ms once | none — startup *is* the request |

The CLI module is **1.6 MB smaller** because it imports only wasi-cli, not the
wasi-http world with its types and resources.

The 20.2 ms per invocation is the whole cost of a request in this model: process
spawn, wasmtime start, module load, JIT compile, run, exit — repeated every time.
Spin pays the equivalent once at startup and then serves requests out of a warm
process.

### B.3 Design questions

#### h) Why the Spin component cannot run under bare `wasmtime run`

Because it exports the wrong thing, and `wasmtime` says so precisely:

```console
$ wasmtime run ../wasm/moscow-time/main.wasm
Error: failed to run main module `../wasm/moscow-time/main.wasm`

Caused by:
    0: component imports instance `wasi:http/types@0.3.0-rc-2026-03-15`,
       but a matching implementation was not found in the linker
    1: instance export `fields` has the wrong type
```

`wasmtime run` executes a **command**: a module exporting `_start`, which it
calls once, in a world providing wasi-cli — stdin, stdout, args, environment,
clocks. The Spin component exports no `_start`. It exports
`wasi:http/incoming-handler` and *imports* `wasi:http/types`, expecting a host
that runs an HTTP server and calls in per request. `wasmtime run` provides no
such host, so linking fails before any code executes.

The lab suggests `wasmtime serve` as the alternative, which does provide
wasi-http. That failed too, and for a sharper reason:

```console
$ wasmtime serve ../wasm/moscow-time/main.wasm
Error: component imports instance `wasi:http/types@0.3.0-rc-2026-03-15`,
       but a matching implementation was not found in the linker
Caused by:
    0: instance export `fields` has the wrong type
    1: resource implementation is missing
```

The version string is the whole story: Spin 4's SDK targets a **March 2026
release candidate of wasi-http 0.3.0**, while wasmtime 47.0.3 implements the
stable 0.2.x. Same interface name, incompatible shapes — so the mismatch is not
only between execution models but between revisions of the same interface, with
the component ahead of the general-purpose runtime that Spin itself embeds.

#### i) What Spin adds on top of wasmtime

wasmtime is an engine: it compiles and instantiates modules and provides WASI
host implementations. Everything needed to run a *web service* sits above that,
and that layer is Spin.

**A manifest and routing.** `spin.toml` declares components, HTTP routes, and
which component handles which path. Bare wasmtime has no concept of a route.

**The server loop and instance lifecycle.** Spin owns the listener, and per
request instantiates a fresh module instance, runs the handler, and discards it.
That per-request instantiation is what makes the model safe — no state carries
between requests — and it is Spin's code, not wasmtime's.

**Instance pooling.** Pre-instantiated modules and a pooling allocator turn
per-request instantiation from milliseconds into microseconds. Without it the
model would cost what §B.2 measured for `wasmtime run`: 20 ms per request.

**Capability policy.** `allowed_outbound_hosts` is a Spin construct. Spin decides
which host functions to link into each component's instance; wasmtime enforces
that only what was linked can be called.

**Toolchain and distribution.** Templates, `spin build`, plugins, packaging
components as OCI artifacts.

The relationship is close to wasmtime being to Spin what a container runtime is
to an orchestrator: the engine executes, the layer above decides what to execute,
when, with which permissions, and in response to what.

#### j) When each execution model fits

**Per-invocation (`wasmtime run`, CGI-shaped)** fits work that is genuinely
one-shot and where a cold process per unit is acceptable or desirable. A
**scheduled batch job** — a nightly report generator, a cron-triggered
transform — is the clean example: it runs once, produces output, exits, and the
20 ms of startup is irrelevant against the work. It also fits anywhere strict
isolation per invocation is worth paying for, or where the host is a CLI rather
than a server: build-tool plugins, `git` hooks, sandboxed evaluation of untrusted
scripts.

**Persistent server (Spin)** fits **any HTTP API under real traffic**. This
lab's own `/time` endpoint is the example: at any meaningful request rate,
20 ms of per-request startup against 10 ms of actual serving means over half the
budget is spent starting up. Spin amortises that to a one-time ~137 ms, then
serves from a warm process with per-request instantiation in microseconds — while
keeping the isolation, because each request still gets a fresh instance.

The dividing line is not really "batch vs web" but **how many times the same code
runs**. Once or occasionally: pay startup per invocation and keep the model
simple. Continuously: pay it once and keep the isolation without the cost, which
is exactly the trade Spin's instance pooling exists to make.

---

## Summary

| Task | Status |
|------|--------|
| Task 1 — Spin SDK component serving `/time` | Complete |
| Task 2 — Perf comparison vs Lab 6 container | Complete |
| Bonus — Two WASM execution models | Complete |

Toolchain note: completed on Spin 4.0.2 with `componentize-go` and upstream Go
1.25.12, rather than the Spin 3.4 + TinyGo stack the lab describes. The
substitution is forced by the current `spin new -t http-go` scaffold and is
documented above with the four intermediate failures.
