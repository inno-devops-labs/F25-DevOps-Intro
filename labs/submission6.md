# Lab 6 — Container Fundamentals with Docker

## Task 1 — Container Lifecycle & Image Management

### 1. Output of docker ps -a and docker images

**Command(s):**

- docker ps -a

- docker images ubuntu

**Output:**
```
vboxuser@devOpsUbuntu:~$ docker ps -a
CONTAINER ID   IMAGE         COMMAND    CREATED          STATUS                      PORTS     NAMES
667be56ce6d0   hello-world   "/hello"   14 seconds ago   Exited (0) 12 seconds ago             nervous_galileo
vboxuser@devOpsUbuntu:~$ docker pull ubuntu:latest
latest: Pulling from library/ubuntu
4b3ffd8ccb52: Pull complete 
Digest: sha256:66460d557b25769b102175144d538d88219c077c678a49af4afca6fbfc1b5252
Status: Downloaded newer image for ubuntu:latest
docker.io/library/ubuntu:latest

vboxuser@devOpsUbuntu:~$ docker images ubuntu
REPOSITORY   TAG       IMAGE ID       CREATED       SIZE
ubuntu       latest    97bed23a3497   12 days ago   78.1MB
```

### 2. Image size and layer count

- Image size: 78.1MB

- Layer count: 1

### 3. Tar file size comparison with image size

- File size: 77MB

### 4. Error message from the first removal attempt

**Command(s):**

- docker rmi ubuntu:latest

**Output:**
```
vboxuser@devOpsUbuntu:~$ docker rmi ubuntu:latest
Error response from daemon: conflict: unable to remove repository reference "ubuntu:latest" (must force) - container 1ad5c4cb3bac is using its referenced image 97bed23a3497
```

### 5. Analysis: Why does image removal fail when a container exists? Explain the dependency relationship.

- Containers depend on the image layers.

- Docker prevents removing an image in use to avoid breaking containers.

### 6. Explanation: What is included in the exported tar file?

- All image layers

- Image metadata

- Configuration info

## Task 2 — Custom Image Creation & Analysis

### 1. Screenshot or output of original Nginx welcome page

**Command(s):**

- curl http://localhost

**Output:**
```
vboxuser@devOpsUbuntu:~$ curl http://localhost
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

### 2. Custom HTML content and verification via curl

**Command(s):**

- curl http://localhost

**Output:**
```
<html>
<head>
<title>The best</title>
</head>
<body>
<h1>website</h1>
</body>
</html>
```

### 3. Output of docker diff my_website_container

**Command(s):**

- docker diff my_website_container

**Output:**
```
vboxuser@devOpsUbuntu:~$ docker diff my_website_container
C /etc
C /etc/nginx
C /etc/nginx/conf.d
C /etc/nginx/conf.d/default.conf
C /run
C /run/nginx.pid
```

### 4. Analysis: Explain the diff output (A=Added, C=Changed, D=Deleted)

All listed paths are marked `C` (Changed) because the container modified existing files or directories (e.g., Nginx created runtime files), and parent directories reflect these changes.

### 5. Reflection: What are the advantages and disadvantages of docker commit vs Dockerfile for image creation?

`Docker commit` is quick for prototyping but not reproducible, while a Dockerfile is maintainable, version-controlled, and ideal for automated builds.

## Task 3 — Container Networking & Service Discovery

### 1. Output of ping command showing successful connectivity

**Command(s):**

- docker exec container1 ping -c 3 container2

**Output:**
```
vboxuser@devOpsUbuntu:~$ docker exec container1 ping -c 3 container2
PING container2 (172.18.0.3): 56 data bytes
64 bytes from 172.18.0.3: seq=0 ttl=64 time=0.225 ms
64 bytes from 172.18.0.3: seq=1 ttl=64 time=0.140 ms
64 bytes from 172.18.0.3: seq=2 ttl=64 time=0.121 ms

--- container2 ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max = 0.121/0.162/0.225 ms
```

### 2. Network inspection output showing both containers' IP addresses

**Command(s):**

- docker network inspect lab_network

**Output:**
```
vboxuser@devOpsUbuntu:~$ docker network inspect lab_network
[
    {
        "Name": "lab_network",
        "Id": "6f8bffee3f08c8b3b804815158bff685dd9740bc03dde7e0a48e2b7c7186b25b",
        "Created": "2025-10-14T05:22:59.758020329Z",
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
            "1ff7b645c08cd924db172d9bc977d33f23f00f34ed6fc831dd60991c6059244d": {
                "Name": "container2",
                "EndpointID": "8e7e806e3bf359486a1d126e8ac8fd1aef0db375cd7b7c5f27fad6d767137941",
                "MacAddress": "2a:04:29:2d:bb:d0",
                "IPv4Address": "172.18.0.3/16",
                "IPv6Address": ""
            },
            "98d7b554efa483054ef0c7230c1c726fd4df73b8d61c92c60443991c2aa14451": {
                "Name": "container1",
                "EndpointID": "f43f6806492d3f2411d8c9e72a63bb2f3d4c63b65e56e8ad6f49d8e4f256124e",
                "MacAddress": "de:3c:d3:43:3f:93",
                "IPv4Address": "172.18.0.2/16",
                "IPv6Address": ""
            }
        },
        "Options": {},
        "Labels": {}
    }
]
```

### 3. DNS resolution output

**Command(s):**

- docker exec container1 nslookup container2

**Output:**
```
vboxuser@devOpsUbuntu:~$ docker exec container1 nslookup container2
Server:		127.0.0.11
Address:	127.0.0.11:53

Non-authoritative answer:
Name:	container2
Address: 172.18.0.3

Non-authoritative answer:

```

### 4. Analysis: How does Docker's internal DNS enable container-to-container communication by name?

Docker’s internal DNS automatically assigns hostnames to containers, allowing them to communicate by name instead of IP within the same user-defined network.

### 5. Comparison: What advantages does user-defined bridge networks provide over the default bridge network?

User-defined bridge networks offer automatic DNS-based name resolution, better isolation, and easier configuration, while the default bridge network requires manual linking or IP use.

## Task 4 — Data Persistence with Volumes

### 1. Custom HTML content used

**Command(s):**

- curl http://localhost

**Output:**
```
<html><body><h1>Persistent Data</h1></body></html>
```

### 2. Output of curl showing content persists after container recreation

**Command(s):**

- docker stop web && docker rm web

- docker run -d -p 80:80 -v app_data:/usr/share/nginx/html --name web_new nginx

- curl http://localhost

**Output:**
```
vboxuser@devOpsUbuntu:~$ docker stop web && docker rm web
web
web

vboxuser@devOpsUbuntu:~$ docker run -d -p 80:80 -v app_data:/usr/share/nginx/html --name web_new nginx
5f15bc57a78878733fbcc4cf52f82a851645f181fb98cfc78171be2cbb804b58

vboxuser@devOpsUbuntu:~$ curl http://localhost
<html><body><h1>Persistent Data</h1></body></html>
```

### 3. Volume inspection output showing mount point

**Command(s):**

- docker volume inspect app_data

**Output:**
```
[
    {
        "CreatedAt": "2025-10-14T05:34:56Z",
        "Driver": "local",
        "Labels": null,
        "Mountpoint": "/var/lib/docker/volumes/app_data/_data",
        "Name": "app_data",
        "Options": null,
        "Scope": "local"
    }
]
```

### 4. Analysis: Why is data persistence important in containerized applications?

Data persistence is important because container data is lost when the container is removed — persistence ensures that important files, databases, and user data survive container restarts or replacements.

### 5. Comparison: Explain the differences between volumes, bind mounts, and container storage. When would you use each?

- **Container storage**: Data exists only inside the container; deleted when the container is removed.

- **Bind mounts**: Directly map a host directory into the container — useful for development or when you need full control over file locations.

- **Volumes**: Managed by Docker and stored in `/var/lib/docker/volumes`; ideal for production because they’re portable, secure, and easy to back up.