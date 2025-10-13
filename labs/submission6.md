## Task 1
```sh
[rightrat@RatLaptop ~]$ docker ps -a
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```
I haven't used Docker on this machine, so the list is empty as expected.

```sh
[rightrat@RatLaptop ~]$ docker pull ubuntu:latest
latest: Pulling from library/ubuntu
4b3ffd8ccb52: Pull complete 
Digest: sha256:66460d557b25769b102175144d538d88219c077c678a49af4afca6fbfc1b5252
Status: Downloaded newer image for ubuntu:latest
docker.io/library/ubuntu:latest
[rightrat@RatLaptop ~]$ docker images ubuntu
REPOSITORY   TAG       IMAGE ID       CREATED       SIZE
ubuntu       latest    97bed23a3497   11 days ago   78.1MB
```

```sh
[rightrat@RatLaptop ~]$ docker run -it --name ubuntu_container ubuntu:latest
root@1d5fd09db104:/# cat /etc/os-release 
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
root@1d5fd09db104:/# ps aux
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root           1  0.2  0.0   4596  3992 pts/0    Ss   10:11   0:00 /bin/bash
root          10  0.0  0.0   7896  4224 pts/0    R+   10:12   0:00 ps aux
root@1d5fd09db104:/# exit
exit
```

```sh
[rightrat@RatLaptop ~]$ docker save -o ubuntu_image.tar ubuntu:latest 
[rightrat@RatLaptop ~]$ ls -lh ubuntu_image.tar 
-rw------- 1 rightrat rightrat 77M окт 13 13:13 ubuntu_image.tar
```
``docker save`` saves an image to replicate all of the chain of steps required to achieve such repo

```sh
[rightrat@RatLaptop ~]$ docker rmi ubuntu:latest 
Error response from daemon: conflict: unable to remove repository reference "ubuntu:latest" (must force) - container 1d5fd09db104 is using its referenced image 97bed23a3497
```
Docker containers rely on their images during their runtime, so that's why deleting the image first is impossible. Even if I force (-f) the removal, the image wil just be untagged, but not deleted.

```sh
[rightrat@RatLaptop ~]$ docker rm ubuntu_container 
ubuntu_container
[rightrat@RatLaptop ~]$ docker rmi ubuntu:latest 
Untagged: ubuntu:latest
Untagged: ubuntu@sha256:66460d557b25769b102175144d538d88219c077c678a49af4afca6fbfc1b5252
Deleted: sha256:97bed23a34971024aa8d254abbe67b7168772340d1f494034773bc464e8dd5b6
Deleted: sha256:073ec47a8c22dcaa4d6e5758799ccefe2f9bde943685830b1bf6fd2395f5eabc
```
## Task 2
```sh
[rightrat@RatLaptop ~]$ docker run -d -p 80:80 --name nginx_container nginx
Unable to find image 'nginx:latest' locally
latest: Pulling from library/nginx
8c7716127147: Pull complete 
250b90fb2b9a: Pull complete 
5d8ea9f4c626: Pull complete 
58d144c4badd: Pull complete 
b459da543435: Pull complete 
8da8ed3552af: Pull complete 
54e822d8ee0c: Pull complete 
Digest: sha256:3b7732505933ca591ce4a6d860cb713ad96a3176b82f7979a8dfa9973486a0d6
Status: Downloaded newer image for nginx:latest
843dcf33ffef2b6e944c7d44a7fc2ec2e9f5805c39c5899976ec3c36bebdd751
[rightrat@RatLaptop ~]$ curl http://localhost
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

```sh
[rightrat@RatLaptop ~]$ touch tmp/index.html
[rightrat@RatLaptop ~]$ micro tmp/index.html 
[rightrat@RatLaptop ~]$ cat tmp/index.html 
<html>
<head>
<title>The best</title>
</head>
<body>
<h1>website</h1>
</body>
</html>
[rightrat@RatLaptop ~]$ docker cp tmp/index.html nginx_container:/usr/share/nginx/html/
Successfully copied 2.05kB to nginx_container:/usr/share/nginx/html/
[rightrat@RatLaptop ~]$ curl http://localhost
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
[rightrat@RatLaptop ~]$ docker commit nginx_container my_website:latest
sha256:2bdd56ead48dbbf39e589d619853d78bf398a4ef33b79d5728a83c0fe770fad9
[rightrat@RatLaptop ~]$ docker images my_website
REPOSITORY   TAG       IMAGE ID       CREATED          SIZE
my_website   latest    2bdd56ead48d   13 seconds ago   160MB
```
Overall ``docker commit`` is useful for a bit of tweaking of the image for later, but as soon as versioning comes into play, one should definetly use Dockerfiles. In general I'd say that there are no real disadvantages to just sticking to Dockerfiles all the time.

```sh
[rightrat@RatLaptop ~]$ docker rm -f nginx_container 
nginx_container
[rightrat@RatLaptop ~]$ docker run -d -p 80:80 --name my_website_container my_website:latest
3dd214f82d5b48cc2c3468695ba819d87aa8a253bc6a2c6713c6209f881227db
[rightrat@RatLaptop ~]$ curl http://localhost
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
[rightrat@RatLaptop ~]$ docker diff my_website_container 
C /etc
C /etc/nginx
C /etc/nginx/conf.d
C /etc/nginx/conf.d/default.conf
C /run
C /run/nginx.pid
```
Changes that occured due to container starting

## Task 3
```sh
[rightrat@RatLaptop ~]$ docker network create lab_network
9dd4763f3ebdac90ad7011fbd40d05ee8aacb89cabd255b90289c933366870f3
[rightrat@RatLaptop ~]$ docker network ls
NETWORK ID     NAME          DRIVER    SCOPE
77c253d383af   bridge        bridge    local
d2070fb63097   host          host      local
9dd4763f3ebd   lab_network   bridge    local
b42ffffa91e7   none          null      local
```

```sh
[rightrat@RatLaptop ~]$ docker run -dit --network lab_network --name container1 alpine ash
Unable to find image 'alpine:latest' locally
latest: Pulling from library/alpine
2d35ebdb57d9: Pull complete 
Digest: sha256:4b7ce07002c69e8f3d704a9c5d6fd3053be500b7f1c69fc0d80990c2ad8dd412
Status: Downloaded newer image for alpine:latest
af79250acc477833938d5db3c93de6ced790ccfa7dd31cbf6eb3903f468ac9bf
[rightrat@RatLaptop ~]$ docker run -dit --network lab_network --name container2 alpine ash
f2f6fbc30bd309879703c3a191e614499bd69c759573c5eb9602526432e5d6ea
```

```sh
[rightrat@RatLaptop ~]$ docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED         STATUS         PORTS     NAMES
f2f6fbc30bd3   alpine    "ash"     2 minutes ago   Up 2 minutes             container2
af79250acc47   alpine    "ash"     3 minutes ago   Up 3 minutes             container1         
```

```sh
[rightrat@RatLaptop ~]$ docker exec container1 ping -c 3 container2
PING container2 (172.18.0.3): 56 data bytes
64 bytes from 172.18.0.3: seq=0 ttl=64 time=0.165 ms
64 bytes from 172.18.0.3: seq=1 ttl=64 time=0.150 ms
64 bytes from 172.18.0.3: seq=2 ttl=64 time=0.187 ms

--- container2 ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max = 0.150/0.167/0.187 ms
```
Since I explicitly created the two containers in the same network, docker automatically adds their ips to the DNS in the docker ecosystem.

```sh
[rightrat@RatLaptop ~]$ docker network inspect lab_network 
[
    {
        "Name": "lab_network",
        "Id": "9dd4763f3ebdac90ad7011fbd40d05ee8aacb89cabd255b90289c933366870f3",
        "Created": "2025-10-13T13:50:41.050065332+03:00",
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
            "af79250acc477833938d5db3c93de6ced790ccfa7dd31cbf6eb3903f468ac9bf": {
                "Name": "container1",
                "EndpointID": "c1e65fff6e90b3acca297a6e05a3046bde72640671b3b79ddcc5649d10acc11d",
                "MacAddress": "b6:66:bf:7b:24:97",
                "IPv4Address": "172.18.0.2/16",
                "IPv6Address": ""
            },
            "f2f6fbc30bd309879703c3a191e614499bd69c759573c5eb9602526432e5d6ea": {
                "Name": "container2",
                "EndpointID": "44298227fb3852561202337be076f13e2761fceef6ba8c7b54a6bc4e682bc1fe",
                "MacAddress": "da:6d:46:c3:20:3c",
                "IPv4Address": "172.18.0.3/16",
                "IPv6Address": ""
            }
        },
        "Options": {},
        "Labels": {}
    }
]
```

```sh
[rightrat@RatLaptop ~]$ docker exec container1 nslookup container2
Server:         127.0.0.11
Address:        127.0.0.11:53

** server can't find container2.example.com: NXDOMAIN

** server can't find container2.example.com: NXDOMAIN
```
The main advantage of user-defined bridges over the default ones is automatic DNS resolution. Also using defined networks one can isolate the containers better.

## Task 4
Will be using HTML test provided in the lab:
```HTML
<html><body><h1>Persistent Data</h1></body></html>
```
```sh
[rightrat@RatLaptop ~]$ docker volume create app_data
app_data
[rightrat@RatLaptop ~]$ docker volume ls
DRIVER    VOLUME NAME
local     app_data
```

```sh
[rightrat@RatLaptop ~]$ docker run -d -p 80:80 -v app_data:/usr/share/nginx/html --name web nginx
036a803c2b82cd53e09b8d64eaab765701a895017d2f7c91bb254ed8ff0eed0d
[rightrat@RatLaptop ~]$ micro tmp/index.html 
[rightrat@RatLaptop ~]$ docker cp tmp/index.html web:/usr/share/nginx/html/
Successfully copied 2.05kB to web:/usr/share/nginx/html/
[rightrat@RatLaptop ~]$ curl http://localhost
<html><body><h1>Persistent Data</h1></body></html>
```

```sh
[rightrat@RatLaptop ~]$ docker stop web && docker rm web
web
web
[rightrat@RatLaptop ~]$ docker run -d -p 80:80 -v app_data:/usr/share/nginx/html --name web_new nginx
40554d17a8cd3cc272e0411418b1cac84dd36e2b9df548e05898e5f096698019
[rightrat@RatLaptop ~]$ curl http://localhost
<html><body><h1>Persistent Data</h1></body></html>
```

```sh
[rightrat@RatLaptop ~]$ docker volume inspect app_data 
[
    {
        "CreatedAt": "2025-10-13T14:09:51+03:00",
        "Driver": "local",
        "Labels": null,
        "Mountpoint": "/var/lib/docker/volumes/app_data/_data",
        "Name": "app_data",
        "Options": null,
        "Scope": "local"
    }
]
```
Keeping data in volumes can be used for storing the media or some other invariant to containerization data (from markups to databases basically)

Bind mount _mounts_ the directory on the container, so the changes made inside that directory will remain on the host machine. 
Volumes are managed by docker. They are easier to back up, they are cross-platform, more suited for complex I/O, and the list goes on...
Container storage should be treated as a "temporary" storage since if one restarts the container, that data will be lost.
