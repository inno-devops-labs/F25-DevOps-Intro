# Lab 11 — Bonus: Reproducible Builds of QuickNotes with Nix

**Author:** HNS ([@HNS2112](https://github.com/HNS2112))
**Date:** 10 August 2026
**Test rig:** MacBook Air M3 (Apple Silicon), Docker 29.6.2, `nixos/nix` containers
**Pinned nixpkgs:** `fcb8fcd6bf2d0adecae5bd491afaaaf8311b758d` (Go 1.26.5)

Raw output is committed under `evidence/lab11/`.

---

## A note on the two environments

Nix was never installed on the host. `dockerTools.buildImage` produces Linux
images, and Nix on macOS cannot build Linux derivations without a VM — so both
environments are Linux containers, which is the path the lab's own guidelines
suggest.

The two environments are genuinely independent:

- **Environment A** — `nixos/nix` container with the local checkout mounted at
  `/repo`, building from the working tree
- **Environment B** — a *fresh* `nixos/nix` container with an empty store,
  building from `github:HNS2112/DevOps-Intro/feature/lab11` — source fetched
  from GitHub, nothing shared with A except the cache at `cache.nixos.org`

B pulled the entire toolchain from scratch (~195 MiB, 70 store paths) on every
run, so nothing was inherited from A's store.

---

## Task 1 — Reproducible Go Build

### 1.1 The flake

```nix
{
  description = "QuickNotes — reproducible build";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAll = f: nixpkgs.lib.genAttrs systems (s: f nixpkgs.legacyPackages.${s});
    in
    {
      packages = forAll (pkgs: rec {
        quicknotes = pkgs.buildGoModule {
          pname = "quicknotes";
          version = "0.1.0";
          src = ./app;
          vendorHash = null;
          env.CGO_ENABLED = 0;
          ldflags = [ "-s" "-w" ];
        };

        docker = pkgs.dockerTools.buildImage {
          name = "quicknotes-nix";
          tag = "latest";
          copyToRoot = pkgs.buildEnv {
            name = "image-root";
            paths = [ quicknotes ];
            pathsToLink = [ "/bin" ];
          };
          extraCommands = "mkdir -p tmp && chmod 1777 tmp";
          config = {
            Entrypoint = [ "${quicknotes}/bin/quicknotes" ];
            ExposedPorts = { "8080/tcp" = {}; };
            User = "65532:65532";
          };
        };

        default = quicknotes;
      });

      devShells = forAll (pkgs: {
        default = pkgs.mkShell {
          packages = with pkgs; [ go gopls golangci-lint ];
        };
      });
    };
}
```

`nixos-26.05` was chosen over the lab's example `nixos-25.11` for the reason the
Common Pitfalls section gives: `app/go.mod` requires Go ≥ 1.24, and the channel's
default `buildGoModule` has to ship at least that. This one ships Go 1.26.5, well
clear of the floor, so no `buildGo124Module` override or `go = pkgs.go_1_24;`
was needed.

**`vendorHash = null` is the correct value here, not a placeholder.** The lab
expects the first build to fail with a hash mismatch and hand you the right
value. It did not fail. QuickNotes has no `require` block in `go.mod` and no
`go.sum` — there are no external dependencies to vendor, so there is no vendor
directory to hash. `null` tells `buildGoModule` to skip the vendoring step
entirely. Setting a hash string instead would fail, because there would be
nothing to match it against.

### 1.2 Two independent builds — identical store hashes

```console
=== Environment A: local checkout, mounted into a nixos/nix container ===
$ nix build .#quicknotes
building '/nix/store/17f1ham94r7b7d4jabfqjgqxr5n3gmy7-quicknotes-0.1.0.drv'...
$ nix-store --query --hash $(readlink result)
sha256:05k94m87943kvs0hhdi0s7v5pw1ldnhdjivbycw7n2d196igkl0a

=== Environment B: fresh container, empty store, source from GitHub ===
$ nix build 'github:HNS2112/DevOps-Intro/feature/lab11#quicknotes'
building '/nix/store/17f1ham94r7b7d4jabfqjgqxr5n3gmy7-quicknotes-0.1.0.drv'...
$ nix-store --query --hash $(readlink result)
sha256:05k94m87943kvs0hhdi0s7v5pw1ldnhdjivbycw7n2d196igkl0a
```

**Identical.** And the *derivation path* is identical too —
`17f1ham94r7b7d4jabfqjgqxr5n3gmy7` in both — which is the stronger statement.
The store hash proves the outputs match; the matching `.drv` path proves Nix
computed the same build recipe from the same inputs *before either build ran*.
Two machines agreeing on the recipe first, then on the result, is what makes the
match evidence rather than coincidence.

Build artifact:

```console
$ ls -la result/bin/
-r-xr-xr-x 1 root root 5619248 Jan  1  1970 quicknotes
```

The `Jan 1 1970` timestamp is determinism in plain sight: Nix normalises mtimes
to the epoch so the timestamp cannot leak into any hash downstream.

### 1.3 It runs

```console
$ ADDR=0.0.0.0:8080 DATA_PATH=/tmp/n.json /repo/result/bin/quicknotes &
2026/08/10 15:40:54 quicknotes listening on 0.0.0.0:8080 (notes loaded: 4)
$ wget -qO- http://127.0.0.1:8080/health
{"notes":4,"status":"ok"}
```

### 1.4 Design questions

#### a) Why `go build` is not bit-identical across machines

Three sources of drift, none of which the Git SHA constrains.

**Absolute paths get embedded.** The compiler records the source directory in
the binary for panic traces and debug info, so building in `/home/elvira/dev`
and `/home/hns/dev` gives different bytes. Lab 6 already dealt with this via
`-trimpath`, which is a fix for exactly this class of problem — and notably a
fix you have to know to apply.

**Build IDs and toolchain identity.** Go computes a build ID from the inputs
including the compiler's own version and the exact module versions resolved. A
different Go patch release produces a different binary from identical source. On
this machine that is not hypothetical: the host Go is 1.26.5 while the
pinned nixpkgs also supplies 1.26.5 — a coincidence, not a guarantee, and Lab 12
showed what happens when the host toolchain silently differs from the intended
one.

**Dependency resolution is a moving target.** `go build` resolves modules
against the network at build time. With `go.sum` present the *contents* are
pinned, but the toolchain, the module proxy's availability, and any `go.mod`
version ranges are not. QuickNotes happens to have no dependencies, so this axis
is inert here — but it is the one that bites real projects hardest.

Nix removes all three by construction: the build runs in a sandbox with a fixed
path, a fixed compiler from a fixed nixpkgs revision, and no network access. The
inputs are the hash, so identical inputs give an identical output or the build
does not happen at all.

#### b) What `vendorHash` hashes, and what `null` does

`vendorHash` is a fixed-output hash over the **vendor directory** — the tree
`go mod vendor` produces from `go.mod` and `go.sum`. It exists because that step
is the one part of a Go build that must reach the network, and Nix's sandbox
forbids network access in ordinary derivations. Declaring the expected hash
up front lets Nix make an exception: fetch, then verify the result matches. If
it does not, the build fails rather than silently using different dependencies.

That is the security property, and it is the same one Lab 3 relied on when
pinning actions by SHA and Lab 10 relied on when pulling images by digest:
content-addressing means the name of the thing *is* a claim about its contents.

`vendorHash = null` disables vendoring entirely — it tells `buildGoModule` there
are no dependencies to fetch, so no fixed-output derivation and no network step.
For a project with dependencies that produces a build failure at compile time
when imports cannot be resolved. For QuickNotes it is correct, because there is
genuinely nothing to fetch.

#### c) Why `flake.lock` is the most important file

Because it is the only thing that makes `inputs.nixpkgs.url` mean something
fixed. `github:NixOS/nixpkgs/nixos-26.05` names a *branch*, which moves — it will
point at different commits next week, with a different Go, a different glibc, a
different gcc. The lock file resolves that branch to one commit:

```json
"rev": "fcb8fcd6bf2d0adecae5bd491afaaaf8311b758d",
"narHash": "sha256-9BG7OgUWdu0ONDO5X2q6+K4bsuBITkX/3W4nNJu1Ito="
```

The `narHash` also verifies that what gets fetched is byte-identical to what was
fetched originally, so the pin survives even a rewritten tag.

Delete it before the second build and Nix re-resolves the branch to whatever HEAD
is now. If nixpkgs happens to be unchanged the hashes still match and everything
looks fine — which is worse, because the reproducibility proof would then be
passing by luck. If anything in the transitive closure moved, the store hash
changes and the two environments disagree with no obvious cause.

This is the lock file argument that `package-lock.json`, `Cargo.lock` and
`go.sum` all make, extended to the compiler and the entire build environment
rather than just the application's own dependencies.

#### d) `buildGoModule` vs `buildGoApplication`

`buildGoModule` is the nixpkgs standard. It runs `go mod vendor` inside one
fixed-output derivation guarded by `vendorHash`, then builds from that vendored
tree. Dependencies are one opaque blob from Nix's point of view.

`buildGoApplication` comes from gomod2nix. It translates `go.mod`/`go.sum` into
a Nix expression naming each dependency as its own derivation, so every module
is a separate store path that can be cached and rebuilt independently. The cost
is a generated `gomod2nix.toml` that has to be regenerated and committed whenever
dependencies change, plus a third-party flake input.

**`buildGoModule` for QuickNotes**, and the choice is not close. The advantage of
`buildGoApplication` is finer-grained caching across many dependencies —
QuickNotes has zero. Adding an external input and a generated file to optimise
the vendoring of nothing would be pure overhead. `buildGoModule` is also in
nixpkgs, so it is covered by the same pin `flake.lock` already provides.

---

## Task 2 — Deterministic OCI Image

### 2.1 Two independent builds — identical digests

```console
=== Environment A ===
$ nix build .#docker && sha256sum result
ada0ff2f0f50d0165735c5834405cc68bc29340eb36a32b84a66c68735f78b6f  result

=== Environment B (fresh container, source from GitHub) ===
$ nix build 'github:HNS2112/DevOps-Intro/feature/lab11#docker' && sha256sum result
ada0ff2f0f50d0165735c5834405cc68bc29340eb36a32b84a66c68735f78b6f  result
```

**Identical.** The image was built entirely by Nix — no Docker daemon
participated in producing it.

### 2.2 It loads and runs

```console
$ docker load < quicknotes-nix.tar.gz
Loaded image: quicknotes-nix:latest

$ docker run -d -p 8090:8080 -e ADDR=0.0.0.0:8080 -e DATA_PATH=/tmp/n.json quicknotes-nix:latest
$ curl -s http://localhost:8090/health
{"notes":0,"status":"ok"}
```

Zero notes because `seed.json` is not copied into the Nix image — the store
starts empty, which is correct rather than a failure.

**One fix was needed to get here**, and it is the same lesson as Lab 6's volume
permissions. The first image failed at startup:

```
2026/08/10 15:55:05 seed: mkdir /tmp: permission denied
```

`dockerTools.buildImage` builds from nothing: the only content is what
`copyToRoot` puts in, which was `/bin`. There is no `/tmp`, and UID 65532 cannot
create one in a root-owned `/`. Adding
`extraCommands = "mkdir -p tmp && chmod 1777 tmp";` creates it at image-build
time with the sticky bit set. Minimal images do not come with writable
directories; if the application needs one, it has to be put there deliberately —
exactly what Lab 6 needed for `/data`, arrived at from a different direction.

### 2.3 Comparison with the Lab 6 Dockerfile build

```console
$ docker build --no-cache -t qn-lab6:run1 ./app
$ docker build --no-cache -t qn-lab6:run2 ./app
$ docker images --no-trunc qn-lab6
qn-lab6  run2  sha256:18bbcbb8a5d4f5b78a2de59cfc8d727bd2351b4759144d1ecf59198e859913fa  16.2MB
qn-lab6  run1  sha256:f887b938ba01b5f0d6a1ee1ae47ddeb94270f3ec4e61990c018f205f444d993e  16.2MB
```

**Different**, from the same Dockerfile, the same source, the same machine,
seconds apart.

| | Nix (`dockerTools`) | Docker (Lab 6 Dockerfile) |
|---|---|---|
| Build 1 | `ada0ff2f…78b6f` | `sha256:f887b938…993e` |
| Build 2 | `ada0ff2f…78b6f` | `sha256:18bbcbb8…13fa` |
| Identical? | **yes** | **no** |
| Size | **2.97 MB** | 16.2 MB |

The size gap is worth a note. Lab 6's image was already tuned — multi-stage,
distroless, `-s -w`, `CGO_ENABLED=0` — and the Nix image is still 5.5× smaller,
because `dockerTools.buildImage` ships only the store paths the binary actually
closes over, with no base image underneath. It also has no `wget`, since Lab 6
added that for a healthcheck the Nix image does not carry.

### 2.4 Design questions

#### e) What makes `docker build` non-deterministic

**Timestamps, primarily.** Every layer records a creation time, and the image
config records `created`. Two builds seconds apart differ in those fields, and
since the digest is a hash over that content, the digests differ. That alone
explains the two Lab 6 hashes above. `dockerTools.buildImage` sets all timestamps
to the epoch — the `Jan 1 1970` seen on every Nix output.

**File metadata that varies.** `COPY` preserves mtimes from the build context,
which reflect when files were checked out rather than when they were authored.
Ownership and permissions can vary with the build environment's umask. Nix
normalises all of it.

**Unpinned inputs resolved at build time.** `FROM golang:1.24.6-bookworm`
resolves a tag, not a digest, and the tag can be repointed. `RUN apt-get install`
or `go mod download` reach the network and get whatever is current. Nix forbids
network access in the build sandbox — every input is a store path fixed by
`flake.lock` before the build starts.

**Ordering and concurrency.** Parallel build steps can write files in different
orders; tar archives record entries in directory-read order unless sorted. Nix
sorts deterministically.

The pattern behind all four is that Docker's default is *"capture whatever the
environment gives you"* while Nix's is *"declare every input or the build does
not run"*. Docker can be made reproducible — `SOURCE_DATE_EPOCH`, digest pins,
`--reproducible` in BuildKit — but each of those is something you must know to
add, and forgetting any one silently reintroduces drift.

#### f) What a reproducible image proves that a signed one cannot

A signature proves **provenance**: this artifact came from whoever holds the key
and has not been altered since. That is valuable and it is not nothing — but it
says nothing whatever about the relationship between the artifact and the source
code. A signed image built from tampered source, or from clean source by a
compromised build machine, is exactly as validly signed as an honest one.

Reproducibility proves **correspondence**: this artifact is what this source
produces. An auditor can take the public source, build it independently, and get
the same digest. That converts trust in the *publisher* into a verifiable claim
about the *build*.

The concrete threat this closes is the compromised build server. If an attacker
owns CI, they can inject a backdoor into the binary and it will be signed by the
legitimate key, because signing happens after the compromise. Every downstream
check passes. With reproducible builds, any third party who rebuilds gets a
different digest, and the discrepancy is the alarm — which is the whole premise
of the Reproducible Builds project, and the reason it exists as a response to
the Ken Thompson trusting-trust problem rather than as a packaging nicety.

The two are complementary rather than alternatives: signatures tell you who
built it, reproducibility tells you what they built. An auditor wants both.

#### g) The trade-off, and why `docker build` is still the default

**The cost is the learning curve, and it is steep.** The Nix language is
functional, lazily evaluated, and unlike anything most engineers use daily.
`flake.nix` above is short, but arriving at it means understanding derivations,
fixed-output hashes, `buildEnv`, `copyToRoot` semantics, and why
`vendorHash = null` is right here — none of which transfers from Docker
knowledge. A Dockerfile can be read by anyone who knows a shell.

**The ecosystem is smaller.** Every CI system, registry, cloud platform and
monitoring tool speaks Docker natively. Nix needs a working store, a binary
cache to be tolerable, and produces something you then feed *into* the Docker
world anyway — as this lab did with `docker load`.

**Disk and first-build cost are real.** Environment B downloaded 195 MiB across
70 store paths just to build one 5 MB binary, because the store was empty.
Without a shared cache like Cachix, every fresh machine pays that.

**And the incentive is weak for most teams.** Reproducibility pays off in
supply-chain auditing, long-term reproduction of old releases, and multi-party
verification. A team shipping a web service several times a day gets little from
byte-identical images and a lot from a five-line Dockerfile everyone can edit.
The lab's own numbers make the point: the Lab 6 image took one file and worked
first try; this flake took a language, four concepts, and a permission bug —
for an artifact functionally equivalent.

Nix wins when the *provenance* is the product. Docker wins when the software is.

---

## Bonus Task — CI-Verified Reproducibility

### B.1 The workflow

```yaml
name: Nix Reproducibility

on:
  push:
  pull_request:

permissions:
  contents: read

jobs:
  build:
    strategy:
      matrix:
        replica: [a, b]
    runs-on: ubuntu-24.04
    outputs:
      digest-a: ${{ steps.digest.outputs.a }}
      digest-b: ${{ steps.digest.outputs.b }}
    steps:
      - name: Checkout repository
        uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2
        with:
          fetch-depth: 1

      - name: Install Nix
        uses: DeterminateSystems/nix-installer-action@ef8a148080ab6020fd15196c2084a2eea5ff2d25 # v22

      - name: Build the OCI image
        run: nix build .#docker

      - name: Compute digest
        id: digest
        run: |
          D=$(sha256sum result | awk '{print $1}')
          echo "replica ${{ matrix.replica }} digest: $D"
          echo "${{ matrix.replica }}=$D" >> "$GITHUB_OUTPUT"

  compare:
    needs: build
    runs-on: ubuntu-24.04
    steps:
      - name: Assert the two digests match
        run: |
          A="${{ needs.build.outputs.digest-a }}"
          B="${{ needs.build.outputs.digest-b }}"
          echo "replica a: $A"
          echo "replica b: $B"
          if [ -z "$A" ] || [ -z "$B" ]; then
            echo "one or both digests are empty"
            exit 1
          fi
          if [ "$A" != "$B" ]; then
            echo "REPRODUCIBILITY BROKEN: digests differ"
            exit 1
          fi
          echo "Digests match — build is reproducible across runners."
```

The Nix installer is SHA-pinned per the Lab 3 rule. The empty-string guard
matters more than it looks: without it, a job that fails before setting its
output would leave both variables empty, `"" != ""` would be false, and the gate
would pass while proving nothing.

### B.2 Green run

https://github.com/HNS2112/DevOps-Intro/actions/runs/31408151132

```
build (a)  replica a digest: c0b0caa46f21cbfed2e79da55db93204d974c7d67a1ed92542df7811b01aefb1
build (b)  replica b digest: c0b0caa46f21cbfed2e79da55db93204d974c7d67a1ed92542df7811b01aefb1
compare    Digests match — build is reproducible across runners.
```

### B.3 Red run — the gate fires

https://github.com/HNS2112/DevOps-Intro/actions/runs/31408954858

A step gated on `if: matrix.replica == 'a'` rewrote the image tag in `flake.nix`
from `latest` to `broken` before building, so replica a produced a different
derivation:

```
A="8a0ae6234370f59b7efb209539a79aadb4a24ddfa12b0e331b78d3a531c70c8a"   (broken)
B="c0b0caa46f21cbfed2e79da55db93204d974c7d67a1ed92542df7811b01aefb1"   (unmodified)
REPRODUCIBILITY BROKEN: digests differ
```

Reverted; green again: https://github.com/HNS2112/DevOps-Intro/actions/runs/31409241116

### B.4 A note on CI vs local digests

| Environment | Digest |
|---|---|
| GitHub runners (x86_64-linux) | `c0b0caa4…aefb1` |
| Local containers (aarch64-linux) | `ada0ff2f…78b6f` |

These differ, and that is expected rather than a failure of reproducibility. The
flake builds for whichever system it runs on, and a binary for a different
instruction set is a different artifact. Reproducibility is a claim about
identical inputs producing identical outputs, and the target architecture is an
input. The proof holds where it should: two runners of the same architecture
agree exactly, four times over.

Lab 6 and Lab 10 hit the same boundary from the other side — the Docker image
was 16.2 MB on arm64 and 9.22 MB on amd64, and Lab 10's deployment needed
`platforms: linux/amd64` set explicitly.

### B.5 Design questions

#### h) "Reproducible on my laptop" vs "reproducible in CI"

The laptop proof has a hole an auditor will find immediately: **both builds share
one machine.** Same Nix store, same kernel, same locale, same CPU, same
everything the build might accidentally depend on. Running `nix build` twice in
one shell mostly proves Nix's cache works — the second invocation may not rebuild
at all. Even two containers on one host, as used for Tasks 1 and 2 here, share a
kernel and a host filesystem.

CI removes the shared substrate. Two GitHub runners are separate VMs with empty
stores, provisioned independently, possibly on different physical hardware.
Anything that leaked in from *this particular machine* would show up as a
mismatch.

Two further properties make the CI proof load-bearing rather than
decorative. It is **continuous** — it runs on every push, so a change that
breaks reproducibility is caught at the commit that caused it, not months later
when someone tries to reproduce a release. And it is **independently
auditable**: the run logs are public, timestamped, and not something the
repository owner can quietly fake, whereas a terminal transcript in a submission
is a claim about what happened on a machine nobody else can see.

That last point is why this section exists at all. The lab's framing —
"reproducibility you can't prove in CI is folklore" — is precisely an auditor's
view: the assertion is only worth what its evidence is worth to a third party.

#### i) Why two parallel jobs rather than one job building twice

A single job building twice would share everything that matters, and would
therefore miss most of what the check is for.

**The Nix store is shared**, so the second `nix build` finds the output already
present and does not rebuild it — the comparison would be a store path against
itself. Proving a hash equals itself is not a test.

**Machine-specific state is shared.** Hostname, CPU model, kernel version,
timezone, locale, available memory, the runner's environment variables. If any
of those leaked into the build, both invocations leak it identically and the
digests match while reproducibility is broken for anyone else.

**Timing differences are invisible.** Two builds seconds apart on one machine
share a wall-clock minute; two runners may start minutes apart. A timestamp
leaking at day granularity would go unnoticed in the first case.

Two runners share only the flake and `cache.nixos.org`. Everything else is
independent, which is the only configuration where a matching digest means what
it claims.

#### j) Where a timestamp would leak, and how `dockerTools` handles it

In an ordinary Docker build, timestamps enter in three places: each layer's
creation time, the image config's `created` field, and the mtimes of files
carried in by `COPY`. All three are recorded in content that the digest hashes,
so all three make the digest move.

`dockerTools.buildImage` neutralises all three by construction rather than by
convention. Layer tarballs are built with fixed mtimes — the `Jan 1 1970` visible
on every Nix output, including `result` itself. The image config's `created`
field is pinned to the epoch by default; `dockerTools` exposes a `created`
attribute, and setting it to `"now"` is the documented way to *opt out* of
determinism, which tells you what the default is. And the file mtimes never vary
because the files come from the Nix store, where they were already normalised
when the derivation was built.

`SOURCE_DATE_EPOCH` is the cross-ecosystem convention for the same idea —
`dpkg`, `rpm`, GCC, Python's `py_compile` and BuildKit all honour it. Nix does
not need it because it does not read the clock in the first place: the sandbox
has no reason to consult wall time, and any output that depended on it would not
be a function of its declared inputs, which is the property the whole model is
built on.

That is the difference in one line. `SOURCE_DATE_EPOCH` is a request to a build
system that would otherwise use the clock. Nix's sandbox is a build system that
never had it.

---

## Summary

| Task | Status |
|------|--------|
| Task 1 — Reproducible Go build, identical store hashes in two environments | Complete |
| Task 2 — Deterministic OCI image, identical digests; Lab 6 shown to differ | Complete |
| Bonus — CI gate over two parallel runners, green and red runs | Complete |
