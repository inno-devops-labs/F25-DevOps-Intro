# Lab 5 — Virtualization

Branch: `feature/lab5`

## Implementation

The root [`Vagrantfile`](../Vagrantfile) uses:

- `bento/ubuntu-24.04`, hostname `quicknotes-lab5`;
- Vagrant's default NAT network;
- host `127.0.0.1:18080` forwarded to guest `:8080`;
- `./app` mounted at `/opt/quicknotes-src` using the VirtualBox provider;
- exactly 2 vCPU and 1024 MiB RAM;
- an idempotent shell provisioner in
  [`vagrant/provision.sh`](../vagrant/provision.sh).

The provisioner installs the pinned Go 1.24.5 archive only after checking its
official SHA-256, builds a static stripped binary, creates an unprivileged
`quicknotes` account, installs a hardened systemd unit, and waits for the
guest health endpoint. Re-running `vagrant provision` rebuilds the application
and restarts the same service.

The configuration has been checked with `ruby -c`, `vagrant validate`,
`bash -n`, ShellCheck, and `go test` in the branch workflow. A hosted CI runner
cannot start a nested VirtualBox VM, and this workstation has neither Vagrant
nor VirtualBox/WSL installed. Therefore the VM-only output fields below are
intentionally not fabricated; they are an exact capture checklist for a host
with hardware virtualization.

## Task 1 — boot and verification

Run from the repository root:

```console
$ vagrant up
$ vagrant ssh -c 'go version'
$ vagrant ssh -c 'systemctl is-active quicknotes'
$ vagrant ssh -c 'curl -s http://127.0.0.1:8080/health'
$ curl -s http://127.0.0.1:18080/health
```

Expected version is `go version go1.24.5 linux/amd64`; the two curls address
the same service from inside the guest and through the loopback-only NAT
forward. The requested first ten `vagrant up` lines and actual curl responses
remain environment-dependent evidence to capture when VirtualBox is
available.

### Design decisions

**a — synced folder.** I selected `virtualbox` because the required provider
already supplies it and changes from the host are immediately visible without
an extra `rsync` command. Its trade-off is provider coupling and slower
metadata-heavy I/O than a native guest filesystem. The provisioner therefore
copies source into `/opt/quicknotes` before building.

**b — networking.** The VM uses the default NAT adapter with one explicit
forward. A bridged adapter would put the guest directly on the LAN, where
other machines could discover and reach it. Binding the host side to
`127.0.0.1` limits access to this workstation while still demonstrating a
host-to-guest path.

**c — provisioning.** A shell provisioner is sufficient for installing one
toolchain and service, has no guest-side configuration-management dependency,
and keeps Lab 5 focused. Its operations are guarded or naturally repeatable.
Lab 7 replaces this with Ansible when the configuration grows.

**d — point pin.** `1.24` is a moving selector, so two provisions can receive
different compilers and security fixes. `1.24.5` plus the archive checksum
makes the toolchain bytes deterministic and detects a corrupted or replaced
download.

## Task 2 — snapshot lifecycle

Use this exact sequence after `vagrant up`:

```console
$ vagrant snapshot save quicknotes-working-go1.24.5
$ vagrant snapshot list
$ vagrant ssh -c 'sudo rm -rf /usr/local/go'
$ vagrant ssh -c 'go version'
bash: go: command not found
$ Measure-Command { vagrant snapshot restore quicknotes-working-go1.24.5 }
$ vagrant ssh -c 'go version'
$ vagrant ssh -c 'curl -s http://127.0.0.1:8080/health'
```

On Bash hosts, use
`time vagrant snapshot restore quicknotes-working-go1.24.5` instead of
`Measure-Command`. An actual restore duration is not claimed here because no
VirtualBox VM was available.

**e — snapshots are not backups.** A snapshot normally shares the same host,
base image, and storage as the VM. It is useless if that disk is lost,
corrupted, encrypted by malware, or if the snapshot chain itself is deleted;
an independent, tested backup has a separate failure domain.

**f — copy-on-write.** Each snapshot initially records metadata and reuses
unchanged base blocks. New differencing images then store blocks changed
after each snapshot, so ten idle snapshots are cheap but ten snapshots around
large updates can approach the size of all changed data and add chain
overhead.

**g — antipattern.** Long-lived or deeply chained snapshots complicate
recovery, grow unpredictably, slow I/O, and make the VM a pet. Rebuilding from
versioned provisioning plus restoring application data is safer for routine
deployment; snapshots are best kept short-lived around a bounded experiment.

## Bonus status

The VM-versus-container table is not populated: meaningful values require
both workloads on the same physical host in the same session. Inventing CI or
cross-machine numbers would invalidate the comparison. The commands in the
lab specification can be run unchanged once VirtualBox and Docker are
available.
