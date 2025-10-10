# Lab 6 — Container Fundamentals with Docker

## Task 1 — Container Lifecycle & Image Management

### 1.1: Basic Container Operations

**List Existing Containers:**

```bash
> docker ps -a
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```

**Pull Ubuntu Image:**

```bash
> docker pull ubuntu:latest
latest: Pulling from library/ubuntu
b8a35db46e38: Pull complete 
Digest: sha256:59a458b76b4e8896031cd559576eac7d6cb53a69b38ba819fb26518536368d86
Status: Downloaded newer image for ubuntu:latest
docker.io/library/ubuntu:latest
```

```bash
> docker images ubuntu
REPOSITORY   TAG       IMAGE ID       CREATED      SIZE
ubuntu       latest    e149199029d1   9 days ago   101MB
```

**Run Interactive Container:**

```bash
> docker run -it --name ubuntu_container ubuntu:latest
```

**Inside the container exploration:**

```bash
> cat /etc/os-release
PRETTY_NAME="Ubuntu 24.04.3 LTS"
NAME="Ubuntu"
VERSION_ID="24.04"
VERSION="24.04.3 LTS (Noble Numbat)"
VERSION_CODENAME=noble
ID=ubuntu
ID_LIKE=debian
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
UBUNTU_CODENAME=noble
LOGO=ubuntu-logo
```

```bash
> ps aux
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.0   4296  3484 pts/0    Ss   17:45   0:00 /bin/bash
root        10  0.0  0.0   7628  3456 pts/0    R+   17:46   0:00 ps aux
```


### 1.2: Image Export and Dependency Analysis

**Export the Image:**

```bash
> docker save -o ubuntu_image.tar ubuntu:latest
> ls -lh ubuntu_image.tar
-rw-------@ 1 ivanilicev  staff    98M Oct 10 20:49 ubuntu_image.tar
```


**Attempt Image Removal:**

```bash
> docker rmi ubuntu:latest
Error response from daemon: conflict: unable to remove repository reference "ubuntu:latest" (must force) - container 6409af1e65f4 is using its referenced image e149199029d1
```


**Remove Container and Retry:**

```bash
> docker rm ubuntu_container
ubuntu_container
```

```bash
> docker rmi ubuntu:latest
Untagged: ubuntu:latest
Untagged: ubuntu@sha256:59a458b76b4e8896031cd559576eac7d6cb53a69b38ba819fb26518536368d86
Deleted: sha256:e149199029d15548c4f6d2666e88879360381a2be8a1b747412e3fe91fb1d19d
Deleted: sha256:ab34259f9ca5d315bec1b17d9f1ca272e84dedd964a8988695daf0ec3e0bbc2e
```


### Analysis

### All outputs are provided above

#### Image size and layer count

The Ubuntu image size is **101MB** as one can see in ```docker images``` output. The image was created 9 days ago. The pull output shows one layer is downloaded: b8a35db46e38, clearly demonstrating it is a single layer image.

#### Tar file size comparison

The exported tar file ```ubuntu_image.tar``` is **98MB**, which is a bit smaller than the reported Docker image size of 101MB. This difference occurs because:

- **Compression**: The tar file uses compression algorithms that can reduce the overall size
- **Metadata overhead**: Docker images include additional metadata that may not be fully compressed in the tar
- **Layer deduplication**: The tar export process may optimize layer storage
- **File system differences**: Different storage formats between Docker's internal representation and tar archive



#### Analysis: Why does image removal fail when a container exists?

The image removal fails because of Docker's **dependency management system**:

- **Container Dependency**: The container ```ubuntu_container``` is still referencing the image ```ubuntu:latest```
- **Safety Mechanism**: Docker prevents deletion of images that are actively being used by containers
- **Filesystem Sharing**: Containers share the image's filesystem layers, so deleting the image would break the container
- **Error Message**: "container 6409af1e65f4 is using its referenced image e149199029d1" clearly shows the dependency
- **Resolution**: Must remove the container first (```docker rm ubuntu_container```) before removing the image

This demonstrates Docker's **copy-on-write (COW)** filesystem where containers reference image layers rather than copying them.


#### Explanation: What is included in the exported tar file?

The exported tar file contains:

- **All Image Layers**: Every filesystem layer that makes up the Ubuntu image
- **Layer Metadata**: JSON configuration files for each layer describing changes
- **Image Manifest**: File that describes the image structure and layer relationships
- **Repository Information**: Tag information and repository references
- **Layer Archives**: Compressed tar files containing the actual filesystem changes for each layer


This tar file can be used to **restore the exact image** on another Docker host using `docker load -i ubuntu_image.tar`.



## Task 2 — Custom Image Creation & Analysis

### 2.1: Deploy and Customize Nginx

```bash
> docker run -d -p 80:80 --name nginx_container nginx
Unable to find image 'nginx:latest' locally
latest: Pulling from library/nginx
e363695fcb93: Pull complete 
f3ff5b8e6cee: Pull complete 
edd736256ac6: Pull complete 
348644581cc5: Pull complete 
e3e8c796c790: Pull complete 
54959f07be7f: Pull complete 
3766556f3395: Pull complete 
Digest: sha256:3b7732505933ca591ce4a6d860cb713ad96a3176b82f7979a8dfa9973486a0d6
Status: Downloaded newer image for nginx:latest
134f2067691fe5f1603ef0d318004e06aa3d4fb8ef660be9c4e50b4e1b897658
```

```bash
> curl http://localhost
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

**Create Custom HTML:**

Created file `index.html` with content:

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


**Copy Custom Content:**

```bash
> docker cp index.html nginx_container:/usr/share/nginx/html/
Successfully copied 2.05kB to nginx_container:/usr/share/nginx/html/
```

```bash
> curl http://localhost
<html>
<head>
<title>The best</title>
</head>
<body>
<h1>website</h1>
</body>
</html>%      
```


### 2.2: Create and Test Custom Image

**Commit Container to Image:**

```bash
> docker commit nginx_container my_website:latest
sha256:b14eae5ef16a25ca01656c29aee9ec227f0c5e10b12d5547b2844a4e63a85107
```


```bash
> docker images my_website
REPOSITORY   TAG       IMAGE ID       CREATED          SIZE
my_website   latest    b14eae5ef16a   31 seconds ago   180MB
```

**Remove Original and Deploy from Custom Image:**

```bash
> docker rm -f nginx_container
nginx_container
```

```bash
> docker run -d -p 80:80 --name my_website_container my_website:latest
946791727e41ba69b810c96576c13e32c124b78ec9e21a0cc7d59a79795f8526
```

```bash
> curl http://localhost
<html>
<head>
<title>The best</title>
</head>
<body>
<h1>website</h1>
</body>
</html>%  
```


**Analyze Filesystem Changes:**

```bash
> docker diff my_website_container
C /etc
C /etc/nginx
C /etc/nginx/conf.d
C /etc/nginx/conf.d/default.conf
C /run
C /run/nginx.pid
```


### Analysis

#### Screenshot or output of original Nginx welcome page

Demonstrated above

#### Custom HTML content and verification

**Custom HTML Content:**
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

**Verification:** Successfully copied to container and verified via curl showing the custom content replaced the default Nginx welcome page.

#### Output of docker diff analysis

Demonstrated above

#### Analysis: Explain the diff output (A=Added, C=Changed, D=Deleted)

The `docker diff` output shows:

- **C /etc**: Changed directory - likely configuration modifications
- **C /etc/nginx**: Changed nginx configuration directory
- **C /etc/nginx/conf.d**: Changed nginx configuration files directory
- **C /etc/nginx/conf.d/default.conf**: Changed the default nginx configuration file
- **C /run**: Changed runtime directory - nginx creates PID files here
- **C /run/nginx.pid**: Changed nginx process ID file

**Key Observations:**
- **No "A" (Added) entries**: The custom HTML file wasn't detected as added because it replaced an existing file
- **No "D" (Deleted) entries**: No files were deleted during the customization
- **All "C" (Changed) entries**: All changes are modifications to existing files/directories
- **Nginx-specific changes**: The diff shows nginx configuration and runtime files being modified

#### Reflection: Advantages and disadvantages of ```docker commit``` vs Dockerfile for image creation

**Advantages of `docker commit`:**
- **Quick and simple**: Fast way to create images from running containers
- **Interactive development**: Can test changes in real-time before committing
- **No Dockerfile knowledge required**: Easy for beginners to create custom images
- **Immediate results**: Can see changes instantly and commit when satisfied

**Disadvantages of `docker commit`:**
- **No version control**: Changes aren't documented or tracked
- **Not reproducible**: Can't recreate the exact same image on another system
- **Larger image size**: Includes all intermediate changes and temporary files
- **No audit trail**: Can't see what changes were made or when
- **Hard to maintain**: Difficult to update or modify the image later
- **Security concerns**: May include sensitive data or unnecessary files

**Advantages of Dockerfile:**
- **Version control**: Changes are documented and trackable
- **Reproducible**: Can create identical images on any system
- **Layered approach**: Each instruction creates a new layer for optimization
- **Automated builds**: Can be integrated into CI/CD pipelines
- **Best practices**: Enforces proper image building practices
- **Smaller images**: Can optimize layers and remove unnecessary files

**Disadvantages of Dockerfile:**
- **Learning curve**: Requires understanding Dockerfile syntax and best practices
- **Less interactive**: Can't test changes in real-time during development
- **More complex**: Requires planning and understanding of the build process

**When to use each:**
- **Use `docker commit`**: For quick prototyping, testing, or one-off customizations
- **Use Dockerfile**: For production images, team development, or when reproducibility is important



## Task 3 — Container Networking & Service Discovery

### 3.1: Create Custom Network

**Create Bridge Network:**

```bash
> docker network create lab_network
f9a9a9df29bc0a210dca704f2a5d2faf3ec67bf627afce023f78bbfdc122a313
```

```bash
> docker network ls
NETWORK ID     NAME          DRIVER    SCOPE
fd902a751df7   bridge        bridge    local
575068895c54   host          host      local
f9a9a9df29bc   lab_network   bridge    local
a6fa9e17eb3f   none          null      local
```

**Deploy Connected Containers:**

```bash
> docker run -dit --network lab_network --name container1 alpine ash
Unable to find image 'alpine:latest' locally
latest: Pulling from library/alpine
6b59a28fa201: Pull complete 
Digest: sha256:4b7ce07002c69e8f3d704a9c5d6fd3053be500b7f1c69fc0d80990c2ad8dd412
Status: Downloaded newer image for alpine:latest
fe4f5f599cfec07e5afb73f8b718bd7143874c8285a5fa5443b10caef101133f
```

```bash
> docker run -dit --network lab_network --name container2 alpine ash
e9c0b414befd5602e8ae425758c1bf63da1225f3410bd83ec7fef1b90d517616
```


### 3.2: Test Connectivity and DNS

**Test Container-to-Container Communication:**

```bash
> docker exec container1 ping -c 3 container2
PING container2 (172.18.0.3): 56 data bytes
64 bytes from 172.18.0.3: seq=0 ttl=64 time=0.160 ms
64 bytes from 172.18.0.3: seq=1 ttl=64 time=0.153 ms
64 bytes from 172.18.0.3: seq=2 ttl=64 time=0.198 ms

--- container2 ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max = 0.153/0.170/0.198 ms
```


**Inspect Network Details:**

```bash
> docker network inspect lab_network
[
    {
        "Name": "lab_network",
        "Id": "f9a9a9df29bc0a210dca704f2a5d2faf3ec67bf627afce023f78bbfdc122a313",
        "Created": "2025-10-10T18:43:28.234205509Z",
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
            "e9c0b414befd5602e8ae425758c1bf63da1225f3410bd83ec7fef1b90d517616": {
                "Name": "container2",
                "EndpointID": "c236c455195ce0427b67e6d84794e133ce38649bf6efa9e28b72ba304fc31620",
                "MacAddress": "ce:f6:55:8a:eb:53",
                "IPv4Address": "172.18.0.3/16",
                "IPv6Address": ""
            },
            "fe4f5f599cfec07e5afb73f8b718bd7143874c8285a5fa5443b10caef101133f": {
                "Name": "container1",
                "EndpointID": "4632a084df141a7e1cdd70340f39340f24a4128cda3209bf5a3f137e61fbbdf3",
                "MacAddress": "32:d3:b2:41:d8:ee",
                "IPv4Address": "172.18.0.2/16",
                "IPv6Address": ""
            }
        },
        "Options": {},
        "Labels": {}
    }
]
```


**Check DNS Resolution:**

```bash
> docker exec container1 nslookup container2
Server:         127.0.0.11
Address:        127.0.0.11:53

Non-authoritative answer:

Non-authoritative answer:
Name:   container2
Address: 172.18.0.3
```


### Task 3 Analysis

#### Output of ping command showing successful connectivity

Output shown above.
The ping command successfully connected container1 to container2:

- **Target**: container1 resolved IP address of container 2: 172.18.0.3
- **Response times**: 0.160ms, 0.153ms, 0.198ms
- **Packer loss**: 100% performance: 3 packets transmitted, 3 received, 0% packet loss
- **Network performance**: Very low latency, indicating containers are on same host


#### Network inspection output showing both containers' IP addresses

**Network Configuration Details:**
- **Network Name**: lab_network
- **Network ID**: f9a9a9df29bc0a210dca704f2a5d2faf3ec67bf627afce023f78bbfdc122a313
- **Driver**: bridge
- **Subnet**: 172.18.0.0/16
- **Gateway**: 172.18.0.1

**Container IP Addresses:**
- **container1**: 172.18.0.2/16 (MAC: 32:d3:b2:41:d8:ee)
- **container2**: 172.18.0.3/16 (MAC: ce:f6:55:8a:eb:53)

**Key Observations:**
- Both containers are on the same subnet (172.18.0.0/16)
- Each container has a unique IP address within the network
- MAC addresses are unique for each container
- Network uses bridge driver for local communication



#### DNS resolution output

Output shown above.

**DNS Resolution Results:**
- **DNS Server**: 127.0.0.11:53 (Docker's internal DNS server)
- **Query**: container2
- **Resolution**: Successfully resolved to 172.18.0.3
- **Response Type**: Non-authoritative answer

**Key Observations:**
- Docker's internal DNS server (127.0.0.11) handles name resolution
- Container names are automatically registered in DNS
- Resolution is fast and reliable within the same network


#### Analysis: How does Docker's internal DNS enable container-to-container communication by name?

**Docker's Internal DNS Mechanism:**

1. **Automatic Registration**: When containers are created, Docker automatically registers their names with the internal DNS server (127.0.0.11)

2. **Name Resolution**: Containers can resolve each other's names to IP addresses without manual configuration

3. **DNS Server Location**: Docker runs a lightweight DNS server (127.0.0.11) that all containers in the network can access

4. **Network Scope**: DNS resolution works within the same network - containers in different networks cannot resolve each other by name

5. **Dynamic Updates**: When containers start/stop, DNS records are automatically updated

**Technical Process:**
- Container queries DNS server for "container2"
- DNS server returns IP address (172.18.0.3)
- Container uses IP address for communication
- This eliminates need to hardcode IP addresses


#### Comparison: What advantages does user-defined bridge networks provide over the default bridge network?

**Advantages of User-Defined Bridge Networks:**

1. **Automatic DNS Resolution**: Containers can communicate by name without external DNS configuration

2. **Better Isolation**: Containers are isolated from other networks

3. **Automatic IP Assignment**: Docker manages IP addresses automatically

4. **Custom Network Configuration**: Can specify subnet, gateway, and other network parameters

5. **Easy Container Management**: Containers can be added/removed from network dynamically

6. **Security**: Better network segmentation


**Default Bridge Network Limitations:**
1. **No automatic DNS resolution between containers**
2. **All containers share the same network space**
3. **Harder to manage network isolation**
4. **Fixed network configuration**
5. **Potential IP conflicts with host network**

**Use Cases:**
- **Default bridge**: Simple single-container applications
- **User-defined bridge**: Multi-container applications, microservices, development environments


