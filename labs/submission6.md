# Task

## Task 1 — Container Lifecycle & Image Management

### Task 1.1: Basic Container Operations

1. List Existing Containers:
  * Output:

```bash
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES

```

2. Pull Ubuntu Image:
  * Output:

```bash
latest: Pulling from library/ubuntu
4b3ffd8ccb52: Pull complete
Digest: sha256:59a458b76b4e8896031cd559576eac7d6cb53a69b38ba819fb26518536368d86
Status: Downloaded newer image for ubuntu:latest
docker.io/library/ubuntu:latest
```

```bash
REPOSITORY   TAG       IMAGE ID       CREATED       SIZE
ubuntu       latest    59a458b76b4e   10 days ago   117MB
```
3. Run Interactive Container:
  * **Inside container explore**
    * Check OS version: 
    ```bash
    PRETTY_NAME="Ubuntu 24.04.3 LTS"
    NAME="Ubuntu"
    VERSION_ID="24.04"
    VERSION="24.04.3 LTS (Noble Numbat)"
    ...
    ```
    * List processes:
    ```bash
    USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
    root         1  0.0  0.0   4588  3328 pts/0    Ss   21:55   0:00 /bin/bash
    root        10  0.0  0.0   7888  3968 pts/0    R+   21:57   0:00 ps aux
    ```

### Task 1.2: Image Export and Dependency Analysis

1. Export the image:
  * Output:
  ```bash
  -rw------- 1 user user 29M Oct 12 01:11 ubuntu_image.tar
  ```

2. Attempt image removal:
  * Output:
  ```bash
  Error response from daemon: conflict: unable to delete ubuntu:latest (must be forced) - container f9cd1b090539 is using its referenced image 59a458b76b4e
  ```

3. Remove Container and Retry:
  * Output:
  ```bash
  Untagged: ubuntu:latest
  Deleted: sha256:59a458b76b4e8896031cd559576eac7d6cb53a69b38ba819fb26518536368d86
  ```

### Analysis:
  * Why does image removal fail when a container exists?:
``` 
Docker maintains a parent-child relationship between images and containers. When a container is created from an image, Docker creates a reference that prevents the image from being deleted while containers dependent on it still exist.
```
  * What's Included in the Exported Tar File

The exported ubuntu_image.tar file contains:
1. **All image layers** - Each layer representing a filesystem change
2. **Image metadata** - Configuration, environment variables, entrypoint, and commands
3. **Manifest file** - Describes the image structure and layer order
4. **Repository tags** - Tag information and references
5. **History information** - Build history and layer creation commands

## Task 2 — Custom Image Creation & Analysis

### Task 2.1: Deploy and Customize Nginx

1. Deploy Nginx container:
  * Output:
  ```bash
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
2. Create Custom HTML
  * Commands:
  ```bash
  touch index.html
  nano index.html
  ```

3. Copy Custom Content:
  * Output:
  ```bash
  <html>
  <head>
  <title>The best</title>
  </head>
  <body>
  <h1>website</h1>
  </body>
  </html>
  ```

### Task 2.2: Create and Test Custom Image

1. Commit Container to Image:
  * Output
  ```bash
  REPOSITORY   TAG       IMAGE ID       CREATED          SIZE
  my_website   latest    5278694f513b   17 seconds ago   236MB
  ```
2. Remove Original and Deploy from Custom Image:
  * Output
  ```bash
  <html>
  <head>
  <title>The best</title>
  </head>
  <body>
  <h1>website</h1>
  </body>
  </html>
  ```
3. Analyze Filesystem Changes:
  * Output
  ```bash
  C /etc
  C /etc/nginx
  C /etc/nginx/conf.d
  C /etc/nginx/conf.d/default.conf
  C /run
  C /run/nginx.pid
  ```

### Analysis
The docker diff output shows filesystem changes using the following notation:
* A = Added (new file/directory)
* C = Changed (modified file/directory)
* D = Deleted (removed file/directory)

In our case, all entries show C, which indicates:
1. **C /etc/nginx/conf.d/default.conf** - The default nginx configuration file was changed (this happens when nginx starts and may modify the file)
2. **C /run/nginx.pid** - The nginx PID file was created/changed when the container started

Interestingly, the diff doesn't show the change to /usr/share/nginx/html/index.html that we made with docker cp. This is because:
* The ```docker commit``` captured our custom index.html in the image layers
* The ```docker diff``` shows only runtime changes from the base image state
* Our custom HTML became part of the committed image, so it's not considered a "change" from that baseline

### Reflection

While docker commit is useful for quick experiments and saving debugging states, Dockerfiles are the recommended approach for production images due to their reproducibility, transparency, and integration with modern development workflows.

## Task 3 — Container Networking & Service Discovery

### Task 3.1: Create Custom Network

1. Create Bridge Network:
  * Output
  ```bash
  NETWORK ID     NAME          DRIVER    SCOPE
  b8bb2922d3b9   bridge        bridge    local
  6aa20fdd30d1   host          host      local
  228c8f274677   lab_network   bridge    local
  e8541ca0a953   none          null      local
  ```

2. Deploy Connected Containers:

### Task 3.2: Test Connectivity and DNS

1. Test Container-to-Container Communication:
  * Output
  ```bash
  PING container2 (172.18.0.3): 56 data bytes
  64 bytes from 172.18.0.3: seq=0 ttl=64 time=0.305 ms
  64 bytes from 172.18.0.3: seq=1 ttl=64 time=0.108 ms
  64 bytes from 172.18.0.3: seq=2 ttl=64 time=0.119 ms

  --- container2 ping statistics ---
  3 packets transmitted, 3 packets received, 0% packet loss
  round-trip min/avg/max = 0.108/0.177/0.305 ms
  ```

2. Inspect Network Details:
  * Output
  ```bash
  [
      {
          "Name": "lab_network",
          "Id": "228c8f274677d82f05f89172b81a9174442551ad24e0de4bf31f93d19e885181",
          "Created": "2025-10-11T23:04:11.402636607Z",
          "Scope": "local",
          "Driver": "bridge",
          "EnableIPv4": true,
          "EnableIPv6": false,
          "IPAM": {
              "Driver": "default",
              "Options": {},
              "Config": [
                  {
                      "Subnet": "172.18.0.0/16",
                      "Gateway": "172.18.0.1"
                  }
              ]
          },
          "Internal": false,
          "Attachable": false,
          "Ingress": false,
          "ConfigFrom": {
              "Network": ""
          },
          "ConfigOnly": false,
          "Containers": {
              "00e8d25b5badff66af9b0039c8a7315cbc6dcfa7ffd3a516dc767201de929284": {
                  "Name": "container1",
                  "EndpointID": "5faeed6cd81f15fb3c66002590bbe4f7f890ac304b6b2873ffd1613ef0f0c184",
                  "MacAddress": "52:93:c3:b5:71:de",
                  "IPv4Address": "172.18.0.2/16",
                  "IPv6Address": ""
              },
              "24b02b9b02efc707af577d8f3ea9cac737cae96600ee61b7c95e76450b6834b9": {
                  "Name": "container2",
                  "EndpointID": "54ce671719562a0ddfaa7bbec3aaf20e3331fdc08bd2272c941311842f29439e",
                  "MacAddress": "fa:f0:b0:ce:08:bc",
                  "IPv4Address": "172.18.0.3/16",
                  "IPv6Address": ""
              }
          },
          "Options": {
              "com.docker.network.enable_ipv4": "true",
              "com.docker.network.enable_ipv6": "false"
          },
          "Labels": {}
      }
  ]
  ```
3. Check DNS Resolution:
  * Output
  ```bash
  Server:         127.0.0.11
  Address:        127.0.0.11:53

  Non-authoritative answer:

  Non-authoritative answer:
  Name:   container2
  Address: 172.18.0.3
  ```

### Analysis
How Docker's internal DNS enables container-to-container communication by name?

Docker's internal DNS system provides automatic service discovery by:
* **Built-in DNS Server:** Each container runs with a built-in DNS server (127.0.0.11) that handles name resolution
* **Automatic Registration:** When containers join a user-defined network, Docker automatically registers their names and IP addresses
* **Container Name Resolution:** Container names are automatically resolvable to their IP addresses within the same network
* **Network-scoped DNS:** DNS resolution works across all containers in the same user-defined network
* **Dynamic Updates:** As containers are added/removed, the DNS records are automatically updated

### Comparison
Advantages of user-defined bridge networks vs default bridge network

User-defined bridge networks provide:
* **Automatic DNS resolution** - containers can communicate by name
* **Better isolation**- isolated from other applications using the default bridge
* **Customizable network settings** - configurable subnets, gateways, and IP ranges
* **Container isolation** - can attach/detach containers without restarting them
* **Enhanced security** - isolated network segment for related containers

## Task 4 — Data Persistence with Volumes

### 4.1: Create and Use Volume

1. Create Named Volume:

  * Output
  ```bash
  DRIVER    VOLUME NAME
  local     app_data
  ```

2. Deploy Container with Volume:

3. Add Custom Content:
  * Output
  ```bash
  <html><body><h1>Persistent Data</h1></body></html>
  ```

### Task 4.2: Verify Persistence

1. Destroy and Recreate Container:
  * Output
  ```bash
  <html><body><h1>Persistent Data</h1></body></html>
  ```
2. Inspect Volume:
  * Output
  ```bash
  [
      {
          "CreatedAt": "2025-10-11T23:20:44Z",
          "Driver": "local",
          "Labels": null,
          "Mountpoint": "/var/lib/docker/volumes/app_data/_data",
          "Name": "app_data",
          "Options": null,
          "Scope": "local"
      }
  ]
  ```

### Analysis

Why data persistence is important in containerized applications

Data persistence is crucial because:
* **Stateless Containers:** Containers are inherently ephemeral and can be destroyed/recreated frequently
* **Data Survival:** Ensures application data survives container lifecycle events (updates, crashes, scaling)
* **Stateful Applications:** Databases, file storage, and user uploads require persistent storage
* **Backup and Recovery:** Persistent data can be backed up and restored independently of containers
* **Multi-container Access:** Multiple containers can share the same persistent data
* **Orchestration Compatibility:** Essential for container orchestration (Kubernetes, Swarm) that frequently reschedules containers

### Comparison

Explain the differences between volumes, bind mounts, and container storage. When would you use each?

1. Volumes:
    * **Storage:** Managed by Docker, stored in /var/lib/docker/volumes/
    * **Use Cases:** Production applications, database storage, shared data between containers
    * **Advantages:** Portable, backup/restore capabilities, Docker-managed
    * **When to Use:** Most production scenarios requiring data persistence
2. Bind Mounts:
    * **Storage:** Direct host filesystem paths
    * **Use Cases:** Development environments, configuration files, host-dependent storage
    * **Advantages:** Direct access to host files, good for development
    * **When to Use:** Development, when you need specific host file access
3. Container Storage (tmpfs mounts):
    * **Storage:** In-memory storage, non-persistent
    * **Use Cases:** Temporary files, sensitive data, cache files
    * **Advantages:** High performance, secure (data disappears with container)
    * **When to Use:** Temporary data, sensitive information that shouldn't persist

#### Summary:

* Use **volumes** for production data persistence
* Use **bind mounts** for development and host-specific configurations
* Use **container storage** for temporary, non-persistent data