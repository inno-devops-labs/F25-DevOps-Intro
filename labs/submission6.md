## **Task 1.1 — Container Lifecycle & Image Management**

**List all containers:**
```
PS C:\Users\egors\F25-DevOps-Intro> docker ps -a
CONTAINER ID   IMAGE            COMMAND                  CREATED       STATUS                     PORTS     NAMES
dafccb433139   deployment-app   "streamlit run app.p…"   2 weeks ago   Exited (137) 2 weeks ago             app
b8ae3f82d694   deployment-api   "uvicorn main:app --…"   2 weeks ago   Exited (137) 2 weeks ago             api
```

**Pull Ubuntu image:**
```
PS C:\Users\egors\F25-DevOps-Intro> docker pull ubuntu:latest
latest: Pulling from library/ubuntu
4b3ffd8ccb52: Pull complete
Digest: sha256:66460d557b25769b102175144d538d88219c077c678a49af4afca6fbfc1b5252
Status: Downloaded newer image for ubuntu:latest
docker.io/library/ubuntu:latest
```

**Show Ubuntu images:**
```
PS C:\Users\egors\F25-DevOps-Intro> docker images ubuntu
REPOSITORY   TAG       IMAGE ID       CREATED       SIZE
ubuntu       latest    66460d557b25   12 days ago   117MB
```

**Run Ubuntu container interactively:**
```
PS C:\Users\egors\F25-DevOps-Intro> docker run -it --name ubuntu_container ubuntu:latest
root@5e754e77fe5e:/# cat /etc/os-release
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
root@5e754e77fe5e:/# ps aux
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.0   4588  3976 pts/0    Ss   20:15   0:00 /bin/bash
root        10  0.0  0.0   7888  3928 pts/0    R+   20:17   0:00 ps aux
root@5e754e77fe5e:/# exit
exit
```

## **Task 1.2 — Image Save, Remove, and Explanation**

**Save image to tar:**
```
PS C:\Users\egors\F25-DevOps-Intro> docker save -o ubuntu_image.tar ubuntu:latest
```

**Check tar file size:**
```
PS C:\Users\egors\F25-DevOps-Intro> Get-Item ubuntu_image.tar | Select-Object Name,Length
Name               Length
----               ------
ubuntu_image.tar 29741056
```

**Try to remove image (expect error):**
```
PS C:\Users\egors\F25-DevOps-Intro> docker rmi ubuntu:latest
Error response from daemon: conflict: unable to delete ubuntu:latest (must be forced) - container 5e754e77fe5e is using its referenced image 66460d557b25
```

**Remove container:**
```
PS C:\Users\egors\F25-DevOps-Intro> docker rm ubuntu_container
ubuntu_container
```

**Remove image again (success):**
```
PS C:\Users\egors\F25-DevOps-Intro> docker rmi ubuntu:latest
Untagged: ubuntu:latest
Deleted: sha256:66460d557b25769b102175144d538d88219c077c678a49af4afca6fbfc1b5252
```

## **Task 2 — Custom Image Creation & Analysis**

**Run Nginx container:**
```
PS C:\Users\egors\F25-DevOps-Intro> docker run -d -p 80:80 --name nginx_container nginx
Status: Downloaded newer image for nginx:latest
3f04055aacea772d0f3dbbc0152e6a06d8b215bd169bf409e4e3b815f3fdc2dd
```

**Check default Nginx page:**
```
PS C:\Users\egors\F25-DevOps-Intro> curl http://localhost
StatusCode        : 200
StatusDescription : OK
Content           : <!DOCTYPE html> ... Welcome to nginx! ...
```

**Create and copy custom index.html:**
```
PS C:\Users\egors\F25-DevOps-Intro> echo The best website > index.html
PS C:\Users\egors\F25-DevOps-Intro> docker cp index.html nginx_container:/usr/share/nginx/html/
Successfully copied 2.05kB to nginx_container:/usr/share/nginx/html/
```

**Check updated page:**
```
PS C:\Users\egors\F25-DevOps-Intro> curl http://localhost
StatusCode        : 200
StatusDescription : OK
Content           : The best website
```

**Commit container to custom image:**
```
PS C:\Users\egors\F25-DevOps-Intro> docker commit nginx_container my_website:latest
sha256:4d79f0ea3264840849c83e9ba794ac10a6f59bce28135b42f815a613e6fe2117
```

**List custom image:**
```
PS C:\Users\egors\F25-DevOps-Intro> docker images my_website
REPOSITORY   TAG       IMAGE ID       CREATED         SIZE
my_website   latest    4d79f0ea3264   Just now        236MB
```

**Remove original container:**
```
PS C:\Users\egors\F25-DevOps-Intro> docker rm -f nginx_container
nginx_container
```

**Run new container from custom image:**
```
PS C:\Users\egors\F25-DevOps-Intro> docker run -d -p 80:80 --name my_website_container my_website:latest
6d784c89ce15b2eb8aed928067981c728ba5341aab7e464f68849382579d6fbb
```

**Check custom page again:**
```
PS C:\Users\egors\F25-DevOps-Intro> curl http://localhost
StatusCode        : 200
StatusDescription : OK
Content           : The best website
```

**Show filesystem changes:**
```
PS C:\Users\egors\F25-DevOps-Intro> docker diff my_website_container
C /etc
C /etc/nginx
C /etc/nginx/conf.d
C /etc/nginx/conf.d/default.conf
C /run
C /run/nginx.pid
```

## **Task 3 — Container Networking & Service Discovery**

**Create custom network:**
```
PS C:\Users\egors\F25-DevOps-Intro> docker network create lab_network
6ab879cd4502d69fd9c8ffc187dd3cbcca129f193cb1bb344fcd917db566ce03
```

**List networks:**
```
PS C:\Users\egors\F25-DevOps-Intro> docker network ls
NETWORK ID     NAME                 DRIVER    SCOPE
268d7f34bc15   bridge               bridge    local
87bf3597d787   deployment_default   bridge    local
e4b5d1ef0a5b   host                 host      local
6ab879cd4502   lab_network          bridge    local
4c39bbab8b71   none                 null      local
```

**Run two containers in the network:**
```
PS C:\Users\egors\F25-DevOps-Intro> docker run -dit --network lab_network --name container1 alpine ash
23654ed9934c3c62e7945322b672be0258f1b276cf198e74f7a954e0a630f877
PS C:\Users\egors\F25-DevOps-Intro> docker run -dit --network lab_network --name container2 alpine ash
505b55c858bb56fd3c660d4f9c4e01219a605ba8bb629c093ea19625c2e50da5
```

**Ping between containers:**
```
PS C:\Users\egors\F25-DevOps-Intro> docker exec container1 ping -c 3 container2
PING container2 (172.19.0.3): 56 data bytes
64 bytes from 172.19.0.3: seq=0 ttl=64 time=0.318 ms
64 bytes from 172.19.0.3: seq=1 ttl=64 time=0.075 ms
64 bytes from 172.19.0.3: seq=2 ttl=64 time=0.097 ms
--- container2 ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max = 0.075/0.163/0.318 ms
```

**Inspect network:**
```
PS C:\Users\egors\F25-DevOps-Intro> docker network inspect lab_network
...existing output...
Containers:
  container1: IPv4Address: 172.19.0.2/16
  container2: IPv4Address: 172.19.0.3/16
```

**DNS test:**
```
PS C:\Users\egors\F25-DevOps-Intro> docker exec container1 nslookup container2
Server:         127.0.0.11
Address:        127.0.0.11:53
Non-authoritative answer:
Name:   container2
Address: 172.19.0.3
```

## **Task 4 — Data Persistence with Volumes**

**Create volume:**
```
PS C:\Users\egors\F25-DevOps-Intro> docker volume create app_data
app_data
```

**List volumes:**
```
PS C:\Users\egors\F25-DevOps-Intro> docker volume ls
DRIVER    VOLUME NAME
local     app_data
```

**Run Nginx with volume:**
```
PS C:\Users\egors\F25-DevOps-Intro> docker run -d -p 80:80 -v app_data:/usr/share/nginx/html --name web nginx
7431bd5c13e94efbd9e43974e02fa127ae94b1061216d81818be3dad3b42e47e
```

**Copy custom index.html:**
```
PS C:\Users\egors\F25-DevOps-Intro> docker cp index.html web:/usr/share/nginx/html/
Successfully copied 2.05kB to web:/usr/share/nginx/html/
```

**Check page:**
```
PS C:\Users\egors\F25-DevOps-Intro> curl http://localhost
StatusCode        : 200
StatusDescription : OK
Content           : Persistent Data
```

**Stop and remove container:**
```
PS C:\Users\egors\F25-DevOps-Intro> docker stop web; docker rm web
web
web
```

**Run new container with same volume:**
```
PS C:\Users\egors\F25-DevOps-Intro> docker run -d -p 80:80 -v app_data:/usr/share/nginx/html --name web_new nginx
92ff30019201e421f5f79c83a35d01cc8cce47256248a783020f5f5d82e74a3c
```

**Check page again:**
```
PS C:\Users\egors\F25-DevOps-Intro> curl http://localhost
StatusCode        : 200
StatusDescription : OK
Content           : Persistent Data
```

**Inspect volume:**
```
PS C:\Users\egors\F25-DevOps-Intro> docker volume inspect app_data
[
    {
        "CreatedAt": "2025-10-13T20:24:20Z",
        "Driver": "local",
        "Mountpoint": "/var/lib/docker/volumes/app_data/_data",
        "Name": "app_data",
        "Scope": "local"
    }
]
```



-------
Really interesting lab, thank you!


