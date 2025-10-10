# Task 1 - Container Lifecycle & Image Management

## Command Outputs

`docker ps -a`:
```text
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```

`docker images ubuntu`:
```text
REPOSITORY   TAG       IMAGE ID       CREATED      SIZE
ubuntu       latest    e149199029d1   8 days ago   101MB
```

`ls -lh ubuntu_image.tar`:
```text
-rw-------@ 1 narly  staff    98M Oct 10 14:46 ubuntu_image.tar
```

## Image Details

- **Image size:** 101MB (`docker images ubuntu`)
- **Layer count:** 1 layer (from `Layers` array in `manifest.json` inside `ubuntu_image.tar`)
- **Tar vs image size:** `ubuntu_image.tar` is 98M, slightly smaller than the uncompressed 101MB image because the archive stores the layer blob in its compressed form.

## Removal Attempt

First `docker rmi ubuntu:latest`:
```text
Error response from daemon: conflict: unable to remove repository reference "ubuntu:latest" (must force) - container 13065051b664 is using its referenced image e149199029d1
```

After removing the container:
```text
docker rm ubuntu_container
docker rmi ubuntu:latest
```
```
Untagged: ubuntu:latest
Untagged: ubuntu@sha256:59a458b76b4e8896031cd559576eac7d6cb53a69b38ba819fb26518536368d86
Deleted: sha256:e149199029d15548c4f6d2666e88879360381a2be8a1b747412e3fe91fb1d19d
Deleted: sha256:ab34259f9ca5d315bec1b17d9f1ca272e84dedd964a8988695daf0ec3e0bbc2e
```

## Analysis

- **Why removal failed:** Docker blocks image deletion while any container (even stopped) still references its layers. `ubuntu_container` depended on `ubuntu:latest`, so the daemon refused to remove the image until the container was deleted.
- **Export contents:** `docker save` bundles the image metadata (`manifest.json`, config JSON) and every layer tarball. Loading the archive with `docker load` would restore the exact image, including all filesystem layers.

# Task 2 - Custom Image Creation & Analysis

## Original Nginx Page

`curl http://localhost`:
```html
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

## Custom Content

`index.html` copied into the container:
```html
<html>
<head>
<title>The best</title>
</head>
<body>
<h1>website</h1>
</body>
</html>
```

`curl http://localhost` after replacement:
```html
<html>
<head>
<title>The best</title>
</head>
<body>
<h1>website</h1>
</body>
</html>
```

## Image & Diff Outputs

`docker images my_website`:
```text
REPOSITORY   TAG       IMAGE ID       CREATED         SIZE
my_website   latest    4c35519823d9   4 seconds ago   181MB
```

`docker diff my_website_container`:
```text
C /etc
C /etc/nginx
C /etc/nginx/conf.d
C /etc/nginx/conf.d/default.conf
C /run
C /run/nginx.pid
```

## Analysis

- **Diff explanation:** `C` marks files or directories changed from the original image. Updating the served HTML triggered config timestamps and PID file updates under `/etc/nginx` and `/run`; no new files outside those paths were added.
- **`docker commit` vs Dockerfile:** `docker commit` is quick for capturing an ad hoc container state, but it hides build steps, makes reproducing the image hard, and produces large, opaque layers. Dockerfiles provide declarative, version-controlled build instructions that are easy to reproduce, review, and automate, though they require up-front scripting effort.

# Task 3 - Container Networking & Service Discovery

## Network Creation

`docker network create lab_network`:
```text
e60b69ee8c4ce4f52fd1c333812b32dfa7cbc0ffc625a853ab80e343149bf5d9
```

`docker network ls`:
```text
NETWORK ID     NAME          DRIVER    SCOPE
65a9653688c0   bridge        bridge    local
83295ee4a7d6   host          host      local
e60b69ee8c4c   lab_network   bridge    local
c56b6b0f8d6e   none          null      local
```

## Connectivity Test

`docker exec container1 ping -c 3 container2`:
```text
PING container2 (192.168.97.3): 56 data bytes
64 bytes from 192.168.97.3: seq=0 ttl=64 time=0.140 ms
64 bytes from 192.168.97.3: seq=1 ttl=64 time=0.164 ms
64 bytes from 192.168.97.3: seq=2 ttl=64 time=0.141 ms

--- container2 ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max = 0.140/0.148/0.164 ms
```

## Network Inspect

`docker network inspect lab_network` (abridged):
```json
[
  {
    "Name": "lab_network",
    "Driver": "bridge",
    "IPAM": {
      "Config": [
        {
          "Subnet": "192.168.97.0/24",
          "Gateway": "192.168.97.1"
        }
      ]
    },
    "Containers": {
      "d08c60512f4a92729a8f8478d0bb43626ea8a69d4579c874bf5147229f66b705": {
        "Name": "container1",
        "IPv4Address": "192.168.97.2/24"
      },
      "e816812052fe249435e1be49599ff1976d00e1b0d64b7a57e7c8acd6cad7d208": {
        "Name": "container2",
        "IPv4Address": "192.168.97.3/24"
      }
    }
  }
]
```

`docker exec container1 nslookup container2`:
```text
Server:         127.0.0.11
Address:        127.0.0.11:53

Non-authoritative answer:

Non-authoritative answer:
Name:   container2
Address: 192.168.97.3
```

## Analysis

- **Bridge network behavior:** `lab_network` provides isolated Layer 2 connectivity with Docker’s embedded IPAM handing out addresses in `192.168.97.0/24`, so each container gets its own private IP (`192.168.97.2` and `.3`) behind the bridge.
- **DNS-based discovery:** Docker’s internal DNS server (`127.0.0.11`) resolves container names to their IPs on the same user-defined network, which is why `ping container2` and `nslookup container2` succeed without hardcoding addresses.
- **Use case:** Custom user-defined networks like this keep services discoverable and segregated, making it easy to scale multi-container applications while avoiding port conflicts on the host.

# Task 4 - Data Persistence with Volumes

## Volume Setup

`docker volume create app_data`:
```text
app_data
```

`docker volume ls`:
```text
DRIVER    VOLUME NAME
local     app_data
```

## Custom HTML

Persisted file content:
```html
<html><body><h1>Persistent Data</h1></body></html>
```

`curl http://localhost` (while `web` container running):
```html
<html><body><h1>Persistent Data</h1></body></html>
```

After recreating the container (`web_new`):
```html
<html><body><h1>Persistent Data</h1></body></html>
```

## Volume Inspect

`docker volume inspect app_data`:
```json
[
  {
    "CreatedAt": "2025-10-10T15:03:35+03:00",
    "Driver": "local",
    "Labels": null,
    "Mountpoint": "/var/lib/docker/volumes/app_data/_data",
    "Name": "app_data",
    "Options": null,
    "Scope": "local"
  }
]
```

## Analysis

- **Why persistence matters:** Containers are ephemeral; their writable layers disappear when the container is removed. Mounting a named volume keeps user data (like site content) alive across container restarts and replacements, enabling upgrades without data loss.
- **Storage options:** Named volumes (like `app_data`) live under Docker’s management, portable across hosts via backup/restore, and ideal for production data. Bind mounts point directly to a host path, offering full control and visibility-best for local development or when specific host directories must be shared. Container storage relies on the container’s writable layer, which is easiest for short-lived scratch data but is tied to the container lifecycle and not suited for persistence.
