### Task 1 — Container Lifecycle & Image Management (3 pts)

 ```sh
   docker ps -a
   ```
 ```sh
CONTAINER ID   IMAGE               COMMAND                  CREATED      STATUS         PORTS                    NAMES
5e84056f4216   credit_app:latest   "streamlit run strea…"   9 days ago   Up 2 seconds   0.0.0.0:8501->8501/tcp   credit_app
2df71a6a742f   credit_api:latest   "uvicorn main:app --…"   9 days ago   Up 2 seconds   0.0.0.0:8000->8000/tcp   credit_api   
```
## 

 ```sh
 docker images ubuntu
 ```

 ```sh
REPOSITORY   TAG       IMAGE ID       CREATED      SIZE
ubuntu       latest    c3cee4aaf374   4 days ago   101MB
  ```


### Run Interactive Container:
 ```sh
 cat /etc/os-release
  ```

   ```sh
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


   ```sh
   ps aux
  ```

   ```sh
   USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.0   4296  3420 pts/0    Ss   13:39   0:00 /bin/bash
root        10 66.6  0.0   7628  3532 pts/0    R+   13:40   0:00 ps aux
  ```
## 1.2: Image Export and Dependency Analysis

   ```sh
ls -lh ubuntu_image.tar
  ```

   ```sh
-rw-------@ 1 kate  staff    98M Oct  5 16:40 ubuntu_image.tar
  ```


  docker rmi ubuntu:latest

### Attempt Image Removal:

   ```sh
   docker rmi ubuntu:latest
   ```
```sh
Error response from daemon: conflict: unable to remove repository reference "ubuntu:latest" (must force) - container 15b2a4881576 is using its referenced image c3cee4aaf374
 ```

 ### Remove Container and Retry:

 ```sh
docker rm ubuntu_container
   docker rmi ubuntu:latest
  ```


 ```sh
Untagged: ubuntu:latest
Untagged: ubuntu@sha256:728785b59223d755e3e5c5af178fab1be7031f3522c5ccd7a0b32b80d8248123
Deleted: sha256:c3cee4aaf374d53303679d87528ae4ad32df1e8d990e482599dc5646d240349e
Deleted: sha256:09f933d26ff9abea427706eebde6a8c8537cfd0c77315e562f48474e5bc068d1
  ```


## Task 1 summary 

docker images after pull 
```sh
REPOSITORY   TAG       IMAGE ID       CREATED       SIZE
ubuntu       latest    c3cee4aaf374   4 days ago    101MB
credit_api   latest    c8425c98568d   11 days ago   1.21GB
credit_app   latest    c8931191baf8   13 days ago   807MB
```
Image Size: 101MB

Layer Count: 1 visible layer 

Tar File Size: 103.2MB

Comparison: The tar file  is slightly larger than the reported image size due to metadata and packaging overhead

### Error Analysis
```sh
Error response from daemon: conflict: unable to remove repository reference "ubuntu:latest" (must force) - container 15b2a4881576 is using its referenced image c3cee4aaf374
 ```
Docker maintains a parent-child dependency relationship between images and containers. When a container is created from an image, Docker creates a reference that prevents the image from being deleted while containers dependent on it still exist.

### Tar File Contents 
The exported tar file (ubuntu_image.tar) contains:

Complete Image Layers: All filesystem layers that make up the Ubuntu image

Image Metadata:

Image configuration and history

Layer manifests and checksums

Creation timestamps and build history

Repository Tags: Reference information linking to the ubuntu:latest tag

Layer Dependencies: Information about how layers are stacked and depend on each other

# Task 2 — Custom Image Creation & Analysis 
output of original Nginx welcome page

```sh
curl http://localhost
```

```sh
<html>
   <head>
   <title>The best</title>
   </head>
   <body>
   <h1>website</h1>
   </body>
   </html>
```

   ```sh
   docker cp index.html nginx_container:/usr/share/nginx/html/
   curl http://localhost
   ```

      ```sh
<html>
   <head>
   <title>The best</title>
   </head>
   <body>
   <h1>website</h1>
   </body>
   </html>
   ```
### Commit Container to Image:

 ```sh
   docker cp index.html nginx_container:/usr/share/nginx/html/
   curl http://localhost
   ```

   
    ```sh
 docker images my_websitesha256:ac9e6c4d035a74447bd742e5185d38a3ff498e3c08765eebf6807e6d0e6f74ee
 REPOSITORY   TAG       IMAGE ID       CREATED        SIZE
my_website   latest    ac9e6c4d035a   1 second ago   198MB
   ```

### Remove Original and Deploy from Custom Image:
 ```sh
   docker rm -f nginx_container
   docker run -d -p 80:80 --name my_website_container my_website:latest
   curl http://localhost
   ```


    ```sh
nginx_container
9480f75b83fb9d8f24730f173bcbb613f2cd6e4f122eab79903de6cf4243be7a
<html>
   <head>
   <title>The best</title>
   </head>
   <body>
   <h1>website</h1>
   </body>
   </html
   ```
### Analyze Filesystem Changes:
   ```sh
   docker diff my_website_container
   ```

    ```sh
C /etc
C /etc/nginx
C /etc/nginx/conf.d
C /etc/nginx/conf.d/default.conf
C /run
C /run/nginx.pid
```

 Modified files (C = Changed):

/etc/nginx/conf.d/default.conf is the main nginx configuration file that was changed while the container was running

/etc, /etc/nginx, /etc/nginx/conf.d - Parent directories of the modified configuration file

/run/nginx.pid - The PID file of the nginx process created when starting the web server

/run is the directory containing the PID file.


# Task 3 — Container Networking & Service Discovery 
### Create Bridge Network:
```sh
   docker network create lab_network
   docker network ls
   ```

   ```sh
   docker network ls350e5678e3c853b3e55c9add39ff31ab540ce887648bc65eb92033d03df49987
NETWORK ID     NAME                               DRIVER    SCOPE
8e0bbaaa1d68   bridge                             bridge    local
fc8472f242a9   host                               host      local
8a3044476a6b   i_ivanov                           bridge    local
73d323004545   innosportnewfinalversion_default   bridge    local
090204960b0f   kind                               bridge    local
350e5678e3c8   lab_network                        bridge    local
c278df9f47fc   my_network                         bridge    local
73df25bf74d6   none                               null      local
edfe060f329c   pg-network                         bridge    local
a513ef6e8569   pmldl_v1_default                   bridge    local
6ee242ff409a   test                               bridge    local
   ```
## 3.2: Test Connectivity and DNS

### Test Container-to-Container Communication:

   ```sh
   docker exec container1 ping -c 3 container2
   ```

      ```sh
      PING container2 (172.24.0.3): 56 data bytes
64 bytes from 172.24.0.3: seq=0 ttl=64 time=0.538 ms
64 bytes from 172.24.0.3: seq=1 ttl=64 time=0.061 ms
64 bytes from 172.24.0.3: seq=2 ttl=64 time=0.242 ms

--- container2 ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max = 0.061/0.280/0.538 ms
   ```


### Inspect Network Details:


   ```sh
   docker network inspect lab_network
   ```


   ```sh
   [
    {
        "Name": "lab_network",
        "Id": "350e5678e3c853b3e55c9add39ff31ab540ce887648bc65eb92033d03df49987",
        "Created": "2025-10-05T13:55:26.690995927Z",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": {},
            "Config": [
                {
                    "Subnet": "172.24.0.0/16",
                    "Gateway": "172.24.0.1"
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
            "448bfae55834cc128d39d34e733e0bd67050629ee6ed8633266735951c80c0db": {
                "Name": "container1",
                "EndpointID": "ba2492ba9f51b25825f712d8014abf358ebbf3e495d595e31f8da41a962c8141",
                "MacAddress": "02:42:ac:18:00:02",
                "IPv4Address": "172.24.0.2/16",
                "IPv6Address": ""
            },
            "80337d7b3f958b24ef99a9f95b303ab64b37b1c3d52e35ad37f1d33881bef73d": {
                "Name": "container2",
                "EndpointID": "1916140b6f113037436a8c1892babcee71408c8c7aca43c06becc17ffda5c71d",
                "MacAddress": "02:42:ac:18:00:03",
                "IPv4Address": "172.24.0.3/16",
                "IPv6Address": ""
            }
        },
        "Options": {},
        "Labels": {}
    }
]
   ```


### Check DNS Resolution:

   ```sh
   docker exec container1 nslookup container2
   ```

   ```sh
   Server:         127.0.0.11
Address:        127.0.0.11:53

Non-authoritative answer:
Name:   container2
Address: 172.24.0.3

Non-authoritative answer:
   ```


### Analysis: Docker's Internal DNS System
Docker's internal DNS enables container-to-container communication by name through the following mechanism:

Embedded DNS Server: Each Docker container runs with an embedded DNS server at 127.0.0.11 that handles all DNS queries

Automatic Service Registration: When containers are started on a user-defined network, Docker automatically registers their names and IP addresses with the DNS service

Name Resolution: Containers can resolve other container names to their IP addresses without any manual configuration

Network Scope: DNS resolution works automatically for all containers on the same user-defined network

Dynamic Updates: As containers are added or removed from the network, the DNS records are automatically updated


## Comparison: User-Defined Bridge vs Default Bridge Networks
Advantages of User-Defined Bridge Networks:

Automatic DNS Resolution: Containers can communicate using their names without manual linking

Better Isolation: User-defined networks provide better isolation between application stacks

Customizable Configuration: Ability to configure subnets, IP ranges, and network options

Connectivity Control: Fine-grained control over which containers can communicate

Automatic Service Discovery: Built-in service discovery without extra configuration

Cleaner Architecture: Better organization of related containers

Disadvantages of Default Bridge Network:

No automatic DNS resolution between containers

All containers share the same network namespace

Less isolation between unrelated applications

Limited configuration options


# Task 4 — Data Persistence with Volumes
## 4.1: Create and Use Volume

   ```sh
   docker volume create app_data
   docker volume ls
   ```


   ```sh
DRIVER    VOLUME NAME
local     app_data
   ```
## Deploy Container with Volume:

   ```sh
   docker run -d -p 80:80 -v app_data:/usr/share/nginx/html --name web nginx
   ```

      ```sh
e8cb9747cdda2894fc169c3df252459c71112d257b0a2562c12d889283e4ad23
   ```

## Add Custom Content

 ```sh
   docker cp index.html web:/usr/share/nginx/html/
   curl http://localhost
```

    ```sh
curl http://localhostSuccessfully copied 2.05kB to web:/usr/share/nginx/html/
<html><body><h1>Persistent Data</h1></body></html>
   ```

   ## 4.2: Verify Persistence

```sh
   docker stop web && docker rm web
   docker run -d -p 80:80 -v app_data:/usr/share/nginx/html --name web_new nginx
   curl http://localhost
```

```sh
<html><body><h1>Persistent Data</h1></body></html>   
```

### Inspect Volume:
   ```sh
   docker volume inspect app_data
   ```

      ```sh
   [
    {
        "CreatedAt": "2025-10-05T13:59:44Z",
        "Driver": "local",
        "Labels": null,
        "Mountpoint": "/var/lib/docker/volumes/app_data/_data",
        "Name": "app_data",
        "Options": null,
        "Scope": "local"
    }
]
   ```

## Volume Inspection Output
The volume inspection revealed:

Mountpoint: /var/lib/docker/volumes/app_data/_data

Driver: local

Scope: local

CreatedAt: Timestamp when the volume was created

This shows that Docker manages the volume storage in the host's filesystem at the specified mountpoint, independent of any container's lifecycle.

## Analysis: Importance of Data Persistence
Data persistence is crucial in containerized applications for several reasons:

Stateful Applications: Many applications (databases, file stores, content management systems) require persistent storage to maintain their state across restarts and deployments

Container Ephemerality: Containers are designed to be ephemeral and disposable. Without persistence, all data would be lost when containers are replaced, updated, or crash

Data Backup and Recovery: Persistent volumes allow for proper backup strategies and data recovery mechanisms

Application Updates: During application updates or rolling deployments, persistent data ensures no user data is lost during container replacement

Scalability: When scaling applications horizontally, shared persistent storage can be used across multiple container instances

Development Workflow: Developers can maintain local data while iterating on containerized applications


## Comparison: Volumes vs Bind Mounts vs Container Storage
#### Docker Volumes:

What: Docker-managed storage completely separate from container lifecycle

Storage Location: /var/lib/docker/volumes/ on the host

Use Cases:

Production applications requiring data persistence

When you want Docker to manage storage completely

Backup and migration scenarios

Multiple containers sharing data

Advantages: Portable, managed by Docker, better performance on some systems

#### Bind Mounts:

What: Direct mapping of host directories/files into containers

Storage Location: Any directory on the host system

Use Cases:

Development environments where you need to sync host code with container

When you need direct access to host system files

Configuration files that need host-level management

Advantages: Direct host access, easy to modify from host system

#### Container Storage (Copy-on-Write):

What: The default writable layer in each container

Storage Location: Part of the container filesystem

Use Cases:

Temporary data that doesn't need persistence

Application runtime data that can be recreated

Log files (if not using external logging)

Advantages: Automatic cleanup, simple to use