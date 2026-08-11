# Lab 7 — Configuration Management: Deploy QuickNotes via Ansible

**Author:** HNS ([@HNS2112](https://github.com/HNS2112))
**Date:** 11 August 2026
**Control node:** Linux Mint 22 (Ubuntu 24.04 base), Ansible core 2.16.3
**Managed node:** the Lab 5 Vagrant VM (`bento/ubuntu-24.04`, 2 vCPU / 1024 MB)

Raw output is committed under `evidence/lab7/`; the play under `ansible/`.

---

## Task 1 — Idempotent Deploy to the Lab 5 VM

### 1.1 Layout

```
ansible/
├── ansible.cfg
├── inventory.ini
├── inventory-local.ini        (bonus — ansible_connection=local)
├── playbook.yaml
├── ansible-pull.service       (bonus)
├── ansible-pull.timer         (bonus)
├── files/
│   └── quicknotes             (static binary, CGO_ENABLED=0)
└── templates/
    └── quicknotes.service.j2
```

The binary is built once on the control node and shipped as a file:

```console
$ cd app && CGO_ENABLED=0 go build -trimpath -ldflags='-s -w' -o ../ansible/files/quicknotes .
$ ls -la ansible/files/
-rwxrwxr-x 1 hns hns 6127778 quicknotes
```

Same flags as Lab 6, for the same reasons: `CGO_ENABLED=0` makes it dependency-free
so it runs on the VM regardless of what libc is there, and `-s -w -trimpath` keep
it small and free of build-machine paths.

### 1.2 Inventory

```ini
[quicknotes]
lab5-vm ansible_host=127.0.0.1 ansible_port=2222 ansible_user=vagrant

[quicknotes:vars]
ansible_ssh_private_key_file=/home/hns/dev/DevOps-Intro/.vagrant/machines/default/virtualbox/private_key
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
ansible_python_interpreter=/usr/bin/python3
```

Values taken from `vagrant ssh-config`: port 2222 forwards to the guest's 22,
user `vagrant`, key generated per-machine by Vagrant.

**One thing cost time and is worth recording.** The key path was first written
relative — `../.vagrant/machines/...` — and every connection failed with:

```
no such identity: ../.vagrant/machines/default/virtualbox/private_key: No such file or directory
vagrant@127.0.0.1: Permission denied (publickey,password).
```

Relative paths in an inventory resolve against the process's working directory,
not against the inventory file. Running `ansible-playbook` from `ansible/` versus
from the repository root would silently change which file was looked for. An
absolute path removes the ambiguity.

### 1.3 The playbook

```yaml
---
- name: Deploy QuickNotes to the Lab 5 VM
  hosts: quicknotes
  become: true
  gather_facts: false

  vars:
    qn_user: quicknotes
    qn_data_dir: /var/lib/quicknotes
    qn_binary: /usr/local/bin/quicknotes
    listen_addr: ":8080"
    data_path: "{{ qn_data_dir }}/notes.json"
    seed_path: "{{ qn_data_dir }}/seed.json"

  tasks:
    - name: Create the quicknotes system user
      ansible.builtin.user:
        name: "{{ qn_user }}"
        system: true
        shell: /usr/sbin/nologin
        create_home: false

    - name: Ensure the data directory exists
      ansible.builtin.file:
        path: "{{ qn_data_dir }}"
        state: directory
        owner: "{{ qn_user }}"
        group: "{{ qn_user }}"
        mode: "0750"

    - name: Copy the QuickNotes binary
      ansible.builtin.copy:
        src: files/quicknotes
        dest: "{{ qn_binary }}"
        mode: "0755"
        owner: root
        group: root
      notify: restart quicknotes

    - name: Copy the seed file
      ansible.builtin.copy:
        src: ../app/seed.json
        dest: "{{ seed_path }}"
        owner: "{{ qn_user }}"
        group: "{{ qn_user }}"
        mode: "0640"

    - name: Render the systemd unit
      ansible.builtin.template:
        src: quicknotes.service.j2
        dest: /etc/systemd/system/quicknotes.service
        owner: root
        group: root
        mode: "0644"
      notify: restart quicknotes

    - name: Enable and start the service
      ansible.builtin.systemd_service:
        name: quicknotes
        enabled: true
        state: started
        daemon_reload: true

  handlers:
    - name: restart quicknotes
      ansible.builtin.systemd_service:
        name: quicknotes
        state: restarted
        daemon_reload: true
```

Every task uses a dedicated module. There is no `shell:` or `command:` anywhere,
which is what makes the idempotency in Task 2 possible rather than accidental.

### 1.4 The systemd template

```jinja
[Unit]
Description=QuickNotes HTTP service
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User={{ qn_user }}
Group={{ qn_user }}
WorkingDirectory={{ data_path | dirname }}
ExecStart={{ qn_binary }}
Environment=ADDR={{ listen_addr }}
Environment=DATA_PATH={{ data_path }}
Environment=SEED_PATH={{ seed_path }}
Restart=on-failure
RestartSec=3

[Install]
WantedBy=multi-user.target
```

`After` orders the start; `Wants` makes the dependency non-fatal if the target
never activates. `WorkingDirectory` is derived with `| dirname` rather than
repeating `qn_data_dir`, so the two cannot drift apart.

`Restart=on-failure` rather than `always` is deliberate: a clean exit is treated
as intentional, and only a crash triggers a restart. `RestartSec=3` keeps the
backoff short without hammering a service that is failing to start.

### 1.5 First run

```console
$ ansible-playbook -i inventory.ini playbook.yaml --syntax-check
playbook: playbook.yaml

$ ansible-playbook -i inventory.ini playbook.yaml

PLAY [Deploy QuickNotes to the Lab 5 VM] ***************************************
TASK [Create the quicknotes system user] ***  changed: [lab5-vm]
TASK [Ensure the data directory exists] ****  changed: [lab5-vm]
TASK [Copy the QuickNotes binary] **********  changed: [lab5-vm]
TASK [Copy the seed file] ******************  changed: [lab5-vm]
TASK [Render the systemd unit] *************  changed: [lab5-vm]
TASK [Enable and start the service] ********  changed: [lab5-vm]
RUNNING HANDLER [restart quicknotes] *******  changed: [lab5-vm]

PLAY RECAP *********************************************************************
lab5-vm : ok=7  changed=7  unreachable=0  failed=0  skipped=0  rescued=0  ignored=0
```

Service state on the VM:

```console
$ vagrant ssh -c "systemctl status quicknotes --no-pager"
● quicknotes.service - QuickNotes HTTP service
     Loaded: loaded (/etc/systemd/system/quicknotes.service; enabled; preset: enabled)
     Active: active (running) since Tue 2026-08-11 15:47:54 UTC
   Main PID: 2068 (quicknotes)
     Memory: 1.3M (peak: 1.5M)

Aug 11 15:47:54 quicknotes-vm quicknotes[2068]: quicknotes listening on :8080 (notes loaded: 4)
```

Reachable from the host through the Lab 5 port forward:

```console
$ curl -s http://localhost:18080/health
{"notes":4,"status":"ok"}
```

**On the `--check` run before it.** A dry run against a clean VM fails at the last
task:

```
TASK [Enable and start the service] ***
fatal: [lab5-vm]: FAILED! => {"msg": "Could not find the requested service quicknotes: host"}
PLAY RECAP: ok=5  changed=5  failed=1
```

That is check mode behaving correctly, not a bug. The template task did not
actually write the unit file, so systemd has nothing to enable. `--check` reports
what *would* change; it cannot simulate the consequences of changes it did not
make. On a host where the service already exists — every run after the first —
the same command completes cleanly, which is exactly the situation `--check`
exists for.

### 1.6 Design questions

#### a) `command:` versus the dedicated modules

`command:` and `shell:` run a process and report `changed` **every single time**,
because Ansible has no way to know whether running that process altered
anything. `useradd quicknotes` succeeds the first time and errors the second;
`echo ... > /etc/systemd/system/quicknotes.service` rewrites an identical file on
every run.

The dedicated modules — `user`, `file`, `copy`, `template`, `systemd_service` —
are **declarative**: they describe the desired end state, inspect the current
state, and act only on the difference. `user` checks `/etc/passwd` before
creating anything. `copy` compares checksums. `systemd_service` queries the unit's
current state before starting it.

Why it matters practically. Idempotency is what makes it safe to run the playbook
on a schedule, or twice by accident, or as part of the `ansible-pull` loop in the
bonus, where it runs every five minutes forever. It also makes the output
meaningful: `changed=0` is a positive statement that the host matches the
declared state. With `shell:` everywhere the recap always reads `changed=N`, and
you learn nothing from it — the signal that something actually moved is gone.

The rule this lab enforces is that `shell:` is a last resort for things no module
covers, and even then `creates:` or `changed_when:` should be added to restore
some idempotency.

#### b) When handlers fire, and when they do not

A handler fires when a task that notifies it reports `changed`, and it runs
**once**, at the end of the play, no matter how many tasks notified it. In this
playbook both the binary copy and the unit template notify `restart quicknotes`;
if both change, the service restarts once rather than twice.

It does **not** fire when the notifying task reports `ok`. Task 2 §2.2 shows this
directly: the second run changed nothing, so the handler never ran and the
service was never restarted.

Two more cases where it does not fire, both worth knowing. If an earlier task in
the play fails, the play aborts and pending handlers are skipped — which can
leave a host with a new config file and an old running process. `--force-handlers`
overrides that. And `notify:` matches handlers **by name, as a string**: a typo
produces no error, no warning, and a handler that silently never runs. That is
the pitfall the lab lists, and the reason the name appears identically in three
places here.

Why deferring to the end is the right default: a play may touch the same service
several times, and restarting after every individual change would mean multiple
restarts, multiple outage windows, and a service bounced into a half-configured
state between tasks. Batching to the end restarts once, after everything is in
place.

#### c) Where to put a variable

For this lab, in order of preference:

**1. `group_vars/quicknotes.yml`.** The variables here — `listen_addr`,
`qn_data_dir`, `qn_user` — describe *this deployment of this service*, which is
exactly what a group is. It scales to a second VM without touching the playbook,
and it separates configuration from logic so the play can be reviewed
independently of the values it is fed.

**2. Play-level `vars:`** — where they currently live. Honest about the scale of
this lab: one host, one play, six variables. Keeping them in the file makes the
playbook self-contained and reviewable in one place, and the report can quote it
whole. The cost is that they are not overridable without editing the play, which
is fine for a single VM and wrong for anything larger.

**3. `roles/quicknotes/defaults/main.yml`,** if this became a role. Defaults have
the *lowest* precedence of any variable source, which is the point: they are
sensible fallbacks that any consumer can override without forking the role.

Deliberately not used: `-e` extra-vars, which win over everything and are
therefore invisible in the repository — good for a one-off override, bad as a
place configuration lives.

#### d) Is `gather_facts` needed here?

**No, and it is turned off.** The playbook references no `ansible_*` variable —
not `ansible_os_family`, not `ansible_distribution`, nothing. Every path, user
and mode is hard-coded or comes from `vars:`. The setup module would collect
several hundred facts and none would be read.

What it saves per run: one extra module execution on the target — a full SSH
round trip, a Python interpreter start, and the collection of hardware, network,
mount and package facts, then transferring the whole structure back as JSON.
Measured in the low seconds on a single VM, which sounds trivial until it is
five minutes of `ansible-pull` runs forever (the bonus) or a play across hundreds
of hosts, where it is the single largest fixed cost.

It would be needed the moment the play branched on the target — `when:
ansible_os_family == "Debian"` to choose a package manager, or
`ansible_processor_vcpus` to size a worker pool. A middle option exists for that
case: `gather_subset: ['!all', 'min']` collects a small subset rather than
everything.

---

## Task 2 — Idempotency and Selective Re-run

### 2.1 Second run: `changed=0`

```console
$ ansible-playbook -i inventory.ini playbook.yaml

TASK [Create the quicknotes system user] ***  ok: [lab5-vm]
TASK [Ensure the data directory exists] ****  ok: [lab5-vm]
TASK [Copy the QuickNotes binary] **********  ok: [lab5-vm]
TASK [Copy the seed file] ******************  ok: [lab5-vm]
TASK [Render the systemd unit] *************  ok: [lab5-vm]
TASK [Enable and start the service] ********  ok: [lab5-vm]

PLAY RECAP *********************************************************************
lab5-vm : ok=6  changed=0  unreachable=0  failed=0  skipped=0  rescued=0  ignored=0
```

`ok=6` rather than 7 — the handler is absent from the recap entirely, because
nothing notified it.

### 2.2 One variable changed: only the template moves

`listen_addr` changed from `":8080"` to `":9090"`, nothing else touched:

```console
TASK [Create the quicknotes system user] ***  ok: [lab5-vm]
TASK [Ensure the data directory exists] ****  ok: [lab5-vm]
TASK [Copy the QuickNotes binary] **********  ok: [lab5-vm]
TASK [Copy the seed file] ******************  ok: [lab5-vm]
TASK [Render the systemd unit] *************  changed: [lab5-vm]
TASK [Enable and start the service] ********  ok: [lab5-vm]
RUNNING HANDLER [restart quicknotes] *******  changed: [lab5-vm]

PLAY RECAP *********************************************************************
lab5-vm : ok=7  changed=2  unreachable=0  failed=0  skipped=0  rescued=0  ignored=0
```

Exactly what the requirement asks for: the template task is the only `changed`
task, the handler fired, everything else reported `ok`. `changed=2` is the
template plus the handler.

Note what did *not* happen: the 6 MB binary was not re-copied, the user was not
touched, the data directory was left alone. A variable that only appears in the
template affects only the template.

### 2.3 `--check --diff`

A third change — `RestartSec` from 3 to 5 in the template:

```console
$ ansible-playbook -i inventory.ini playbook.yaml --check --diff

TASK [Render the systemd unit] *************************************************
--- before: /etc/systemd/system/quicknotes.service
+++ after: /home/hns/.ansible/tmp/.../quicknotes.service.j2
@@ -13,7 +13,7 @@
 Environment=DATA_PATH=/var/lib/quicknotes/notes.json
 Environment=SEED_PATH=/var/lib/quicknotes/seed.json
 Restart=on-failure
-RestartSec=3
+RestartSec=5

 [Install]
 WantedBy=multi-user.target

changed: [lab5-vm]
RUNNING HANDLER [restart quicknotes] *******  changed: [lab5-vm]

PLAY RECAP *********************************************************************
lab5-vm : ok=7  changed=2  unreachable=0  failed=0  skipped=0  rescued=0  ignored=0
```

One line in, one line out, and the surrounding context proves nothing else moved.

Both changes were reverted afterwards and the playbook re-run, leaving the VM
serving on `:8080`.

### 2.4 Design questions

#### e) Why the second run reports `changed=0`

Each module compares declared state against actual state before acting.

`file` stats the path and compares type, owner, group and mode against what the
task declares. All four already match, so it reports `ok` and touches nothing.

`copy` computes a checksum — SHA-1 by default — of the local source and of the
remote destination, and compares them, along with owner/group/mode. This is the
important detail: it is **content-based, not timestamp-based**. Re-running after
rebuilding the binary from unchanged source still reports `ok`, because the bytes
are the same even though the mtime moved. That is why `-trimpath` in the build
matters here too — a binary embedding a build path would differ between machines
and defeat the comparison.

`template` renders the Jinja file **locally, in memory**, then checksums the
result against the remote file. So the comparison is against the *rendered
output*, not the template source: editing a comment in the `.j2` that does not
change the output produces no change on the target, and changing a variable that
does produces one.

`systemd_service` queries the unit's `ActiveState` and `UnitFileState` and acts
only if they differ from `state: started` and `enabled: true`.

The general shape: nothing is written unless a comparison says it must be.

#### f) Using `shell:` instead of `template:`

Three failure modes, escalating.

**It reports `changed` on every run.** The shell command is opaque to Ansible; it
cannot tell whether the redirect wrote different bytes. Every run says `changed`,
which means the notify fires, which means **the service restarts every five
minutes forever** under the bonus's timer. A restart loop caused by the
configuration management, not by any actual change.

**It loses everything the module handles.** No `owner`, `group` or `mode` — the
file lands with root's umask, and if that is 0022 the mode happens to be right by
luck rather than by declaration. No atomicity: `template` writes to a temporary
file and renames it into place, so a reader never sees a half-written unit,
whereas `>` truncates the target immediately and fills it progressively. If the
play is interrupted mid-write, systemd is left with a truncated unit file.

**It cannot be previewed and cannot be diffed.** `--check` will not run it
(or worse, runs it anyway if `check_mode: false` was set), and `--diff` has
nothing to show, because there is no before-and-after content for Ansible to
compare. The safety net in §2.3 disappears entirely.

There is also quoting: building a multi-line systemd unit out of shell
redirections means escaping `$`, quotes and newlines by hand, and `Environment=`
values containing `:` or `=` are exactly where that goes wrong quietly.

#### g) The bug `--check --diff` catches that `--check` alone misses

Plain `--check` answers **"will anything change?"** — a yes/no per task.
`--diff` answers **"what exactly will change?"**.

The bug that hides in the gap is a **template task that reports `changed` for a
reason you did not intend**. Suppose a colleague edited `group_vars` and a
variable you did not expect now renders differently. Plain `--check` shows
`changed: [host]` on the template task — which is exactly what you expected to
see, because you did change something. It looks correct. You approve the deploy.

`--diff` would have shown that alongside your one intended line, three other
lines also moved: `User=` changed, an `Environment=` line vanished, a path
pointed somewhere new. The count of changed tasks is identical either way; the
content is not.

The §2.3 diff is the benign version of this — one line in, one line out, and the
unchanged context lines proving nothing else moved. That proof is the thing plain
`--check` cannot give you, and it is why the lab calls `--check --diff` before a
production deploy professional hygiene rather than optional.

---

## Bonus Task — `ansible-pull` GitOps Loop

### B.1 What was installed on the VM

`ansible/ansible-pull.service`:

```ini
[Unit]
Description=Converge this host from Git via ansible-pull
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/bin/ansible-pull -U https://github.com/HNS2112/DevOps-Intro.git -C feature/lab7 -i ansible/inventory-local.ini ansible/playbook.yaml
```

`ansible/ansible-pull.timer`:

```ini
[Unit]
Description=Run ansible-pull every 5 minutes

[Timer]
OnBootSec=1min
OnUnitActiveSec=5min
Unit=ansible-pull.service

[Install]
WantedBy=timers.target
```

`ansible/inventory-local.ini`:

```ini
[quicknotes]
localhost ansible_connection=local
```

`ansible_connection=local` is what makes this pull rather than push — Ansible
does not open an SSH connection at all, it executes modules directly on the host
it is already running on.

`Type=oneshot` is right for a converge job: systemd waits for it to finish and
does not treat exit as a failure, and `OnUnitActiveSec` measures from the last
*activation*, so runs never overlap even if one takes longer than five minutes.

The HTTPS clone URL is deliberate. The VM has none of my SSH keys, and giving it
one would be handing a deployment target credentials that can write to the
repository — the exact thing question (h) is about.

Installed with:

```console
$ vagrant ssh -c "sudo apt-get install -y ansible git"
$ vagrant ssh -c "sudo cp /vagrant/ansible/ansible-pull.{service,timer} /etc/systemd/system/ \
                 && sudo systemctl daemon-reload && sudo systemctl enable --now ansible-pull.timer"
Created symlink /etc/systemd/system/timers.target.wants/ansible-pull.timer → /etc/systemd/system/ansible-pull.timer.
```

Timer active:

```console
$ vagrant ssh -c "systemctl list-timers ansible-pull --no-pager"
NEXT                        LEFT      LAST                        PASSED       UNIT                ACTIVATES
Tue 2026-08-11 16:08:25 UTC 1min 52s  Tue 2026-08-11 16:03:25 UTC 3min 7s ago  ansible-pull.timer  ansible-pull.service
```

The first run after enabling converged with nothing to do — the host was already
in the declared state from Task 1:

```
localhost : ok=6  changed=0  unreachable=0  failed=0
```

### B.2 Convergence, observed

`listen_addr` changed from `":8080"` to `":8081"`, committed and pushed. **No
command was run against the VM from the host.**

| Event | Time (UTC) |
|---|---|
| Commit pushed to `feature/lab7` | 16:00:11 |
| Timer fired | 16:03:18 |
| Service restarted on the VM | 16:03:36 |
| Verified from the host | 16:05:15 |

**3 minutes 25 seconds** from push to applied state, inside the 5-minute window.

```console
$ vagrant ssh -c "grep ADDR /etc/systemd/system/quicknotes.service"
Environment=ADDR=:8081

$ vagrant ssh -c "sudo journalctl -u ansible-pull.service --no-pager | tail"
Aug 11 16:03:37 quicknotes-vm ansible-pull[4476]: TASK [Render the systemd unit] ***
Aug 11 16:03:37 quicknotes-vm ansible-pull[4476]: PLAY RECAP ***
Aug 11 16:03:37 quicknotes-vm ansible-pull[4476]: localhost : ok=7  changed=2  unreachable=0  failed=0
```

`changed=2` — the template and the handler, exactly as in §2.2, except that this
time the change arrived from Git instead of from a `ansible-playbook` invocation.

The revert commit converged the same way, back to `:8080`, again with no host
command. The loop runs in both directions, which is the property that makes it
reconciliation rather than deployment.

### B.3 Design questions

#### h) The security benefit of pull over push

In the push model the control node holds SSH credentials for every managed host,
and those credentials are usually privileged — this lab's own playbook runs
`become: true`, so the key on my laptop is effectively root on the VM. That
concentrates risk in one place: compromise the control node and you own the
entire fleet. It also requires every managed host to accept inbound SSH, which
means an open port and a listening daemon on each one.

Pull inverts the direction. The VM has **no inbound access at all** — it could
sit behind NAT with no port forwarding and no public address, and this would
still work, because it initiates an outbound HTTPS connection to GitHub. Nothing
holds credentials to it. Compromising my laptop gets an attacker no path to the
VM; they would have to compromise the Git repository instead, which is auditable,
versioned, and protected by the branch rules set up in Lab 1.

The trust relationship changes shape too. In push, the host trusts whoever holds
the key. In pull, the host trusts a specific repository and branch — a narrower
statement, and one that leaves a commit history of every change ever applied.

The trade-off is real and worth naming: pull gives up immediacy. There is no way
to force a converge now from the control node, and a bad commit propagates to
every host on its own schedule with no central kill switch. Push knows within
seconds whether a change landed; pull finds out when the host next reports, if it
reports at all.

#### i) The same pattern at the Kubernetes layer

**GitOps**, implemented by **ArgoCD** and **Flux**. The mechanism is identical:
an agent inside the cluster watches a Git repository, compares the declared
manifests against live state, and reconciles the difference on a loop. Git is the
single source of truth; nothing is applied by a human running `kubectl`.

`ansible-pull` is a fair simulator because it reproduces every essential property
at the VM layer. The desired state lives in Git and nowhere else. An agent on the
target pulls it rather than a controller pushing it. Convergence is a **loop**,
not an event — the timer runs every five minutes forever, so drift introduced by
hand is corrected at the next fire rather than persisting until someone notices.
And the mechanism is idempotent by construction, which is what makes running it
continuously safe at all.

What it does not reproduce: ArgoCD and Flux report status back — sync state,
drift detection, health of every managed resource, visible in one place across a
whole fleet. `ansible-pull` writes to the local journal and tells nobody. Scaling
this pattern past a handful of hosts is precisely where that gap starts to hurt,
and it is the problem the Kubernetes-layer tools were built to solve.

---

## Summary

| Task | Status |
|------|--------|
| Task 1 — Idempotent Ansible deploy to the Lab 5 VM | Complete |
| Task 2 — `changed=0`, selective handler, `--check --diff` | Complete |
| Bonus — `ansible-pull` GitOps loop, convergence in 3m 25s | Complete |
