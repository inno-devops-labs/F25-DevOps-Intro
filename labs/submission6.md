# Lab 6 — Container Fundamentals with Docker

## Task 1 — Container Lifecycle & Image Management

```bash
docker ps -a
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```

```bash
docker images ubuntu
REPOSITORY   TAG       IMAGE ID       CREATED       SIZE
ubuntu       latest    66460d557b25   12 days ago   117MB
```

```bash
docker run -it --name ubuntu_container ubuntu:latest
root@fda4202e677f:/# cat /etc/os-release
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
ps aux
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.0   4588  3840 pts/0    Ss   13:29   0:00 /bin/bash
root        10  0.0  0.0   7888  4000 pts/0    R+   13:29   0:00 ps aux
```

```bash
ls ubuntu_image.tar
Name             Size(MB)
----             --------
ubuntu_image.tar    28,36
```

```bash
docker rmi ubuntu:latest
Error response from daemon: conflict: unable to delete ubuntu:latest (must be forced) - container fda4202e677f is using its referenced image 66460d557b25
```

```bash
docker rm ubuntu_container
ubuntu_container
```

```
docker rmi ubuntu:latest
Untagged: ubuntu:latest
Deleted: sha256:66460d557b25769b102175144d538d88219c077c678a49af4afca6fbfc1b5252
```

## Task 2 — Custom Image Creation & Analysis

### Nginx

```bash
docker run -d -p 80:80 --name nginx_container nginx
docker exec -it nginx_container cat /usr/share/nginx/html/index.html

<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
...
</html>
```
```bash
docker cp index.html nginx_container:/usr/share/nginx/html/index.html
docker exec -it nginx_container cat /usr/share/nginx/html/index.html

<html>
<head>
<title>The best</title>
</head>
<body>
<h1>website</h1>
</body>
</html>
```
```bash
curl.exe http://localhost

<html>
<head>
<title>The best</title>
</head>
<body>
<h1>website</h1>
</body>
</html>
```

### Create and Test Custom Image

```bash
docker commit nginx_container my_website:latest
docker images my_website

REPOSITORY   TAG       IMAGE ID       CREATED         SIZE
my_website   latest    4ce80527b6fe   9 seconds ago   236MB
```

```bash
docker images my_website

REPOSITORY   TAG       IMAGE ID       CREATED         SIZE
my_website   latest    4ce80527b6fe   9 seconds ago   236MB
```

```bash
docker rm -f nginx_container
docker run -d -p 80:80 --name my_website_container my_website:latest

docker exec -it my_website_container cat /usr/share/nginx/html/index.html

<html>
<head>
<title>The best</title>
</head>
<body>
<h1>website</h1>
</body>
</html>
```

```bash
docker diff my_website_container

C /run
C /run/nginx.pid
C /etc
C /etc/nginx
C /etc/nginx/conf.d
C /etc/nginx/conf.d/default.conf
```
## Task 3 - Container Networking & Service Discovery

### Task 3.1 Create Custom Network

```bash
docker network create lab_network

1e3168975d31556cb7a391f1d560ac04e3b679f807e68f86dabb52850226095c
```

```bash
docker network ls

NETWORK ID     NAME          DRIVER    SCOPE
75c6ae307d30   bridge        bridge    local
4e02d5792c1c   host          host      local
1e3168975d31   lab_network   bridge    local
71aa8abc0ce9   none          null      local
```

```bash
docker run -dit --network lab_network --name container1 alpine ash

e0554f9dfd9b9eaadc57f933b9a97c56d2e140adc59cd16b5ef210a6f5298d41
```

### Task 3.2 - Test Connectivity and DNS

```bash
docker exec container1 ping -c 3 container2

PING container2 (172.18.0.3): 56 data bytes
64 bytes from 172.18.0.3: seq=0 ttl=64 time=0.205 ms
64 bytes from 172.18.0.3: seq=1 ttl=64 time=0.074 ms
64 bytes from 172.18.0.3: seq=2 ttl=64 time=0.121 ms

--- container2 ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max = 0.074/0.133/0.205 ms
```

```bash
docker network inspect lab_network

[{
    "Name": "lab_network",
    "Id": "1e3168975d31556cb7a391f1d560ac04e3b679f807e68f86dabb52850226095c",
    "Scope": "local",
    "Driver": "bridge",
    "IPAM": {
        "Config": [
            {"Subnet": "172.18.0.0/16","Gateway": "172.18.0.1"}
        ]
    },
    "Containers": {
        "060ec9ba81039b1a36fdec79c6ce83e5e01df2f55dd7f6b585ef68c756dd3683": {
            "Name": "container1",
            "IPv4Address": "172.18.0.2/16"
        },
        "e0554f9dfd9b9eaadc57f933b9a97c56d2e140adc59cd16b5ef210a6f5298d41": {
            "Name": "container2",
            "IPv4Address": "172.18.0.3/16"
        }
    }
}]
```

```bash
docker exec container1 nslookup container2

Server:         127.0.0.11
Address:        127.0.0.11:53

Non-authoritative answer:
Name:   container2
Address: 172.18.0.3
```

## Task 4 - Data Persistence with Volumes

### 4.1 - Create and Use Volume

```bash
docker volume create app_data
docker volume ls
docker run -d -p 80:80 -v app_data:/usr/share/nginx/html --name web nginx

4fee3711dc4386be9fa1c00e5dd1b85c29e738fb5f34b6cadb59fd79504bf04c
```

```bash
docker cp index.html web:/usr/share/nginx/html/

Successfully copied 2.05kB to web:/usr/share/nginx/html/
```

```bash
curl http://localhost

 <html>
 <head>
 <title>The best</title>
 </head>
 <body>
 <h1>website</h1>
 </body>
 </html>

```

### 4.2 - Verify Persistence

```bash
docker stop web
web
```

```bash
docker run -d -p 80:80 -v app_data:/usr/share/nginx/html --name web_new nginx

473344ff5b0f7025b74f90b6203bcdf5482fffa661be83610e8de9d0e1c3a35b
```

```bash
curl http://localhost

 <html>
 <head>
 <title>The best</title>
 </head>
 <body>
 <h1>website</h1>
 </body>
 </html>

```

```bash
docker volume inspect app_data

[
    {
        "CreatedAt": "2025-10-13T13:53:54Z",
        "Driver": "local",
        "Labels": null,
        "Mountpoint": "/var/lib/docker/volumes/app_data/_data",
        "Name": "app_data",
        "Options": null,
        "Scope": "local"
    }
]
```