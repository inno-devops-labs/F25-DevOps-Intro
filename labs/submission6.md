# Lab 6 — Docker Fundamentals


## Task 1 — Container Lifecycle & Image Management

### 1.1 Basic Operations

```powershell
docker ps -a
docker pull ubuntu:latest
docker run -it --name ubuntu_container ubuntu:latest
```

**Output of `docker ps -a`:**
```
CONTAINER ID   IMAGE                                           COMMAND                  CREATED        STATUS                        PORTS
66258e4b6d3a   wine_quality_predoction_app-app                 "streamlit run app.p…"   2 weeks ago    Exited (255) 24 seconds ago   0.0.0.0:8501->8501/tcp
dee6e23b1fd9   wine_quality_predoction_app-airflow-scheduler   "/usr/bin/dumb-init …"   2 weeks ago    Exited (255) 24 seconds ago   8080/tcp
...
0235b04ba684   mongo                                           "docker-entrypoint.s…"   5 months ago   Exited (0) 5 months ago
```

**Output of `docker images ubuntu`:**
```
REPOSITORY   TAG       IMAGE ID       CREATED       SIZE
ubuntu       latest    97bed23a3497   10 days ago   78.1MB
```

**Inside the container:**
```
PRETTY_NAME="Ubuntu 24.04.3 LTS"
NAME="Ubuntu"
VERSION_ID="24.04"
VERSION="24.04.3 LTS (Noble Numbat)"
...
LOGO=ubuntu-logo

USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.0   4588  3712 pts/0    Ss   08:04   0:00 /bin/bash
root        10  0.0  0.0   7888  4096 pts/0    R+   08:05   0:00 ps aux
```

**Explanation:**  
Container `ubuntu_container` was successfully launched. The image `ubuntu:latest` consists of several layers with a total size of about 78 MB.

---

### 1.2 Export and Remove Image

```powershell
docker save -o ubuntu_image.tar ubuntu:latest
Get-ChildItem .\ubuntu_image.tar
docker rmi ubuntu:latest
docker rm ubuntu_container
docker rmi ubuntu:latest
```

**Output:**
```
Get-ChildItem : Parameter not found: "lh".
```
(In PowerShell, use simply `Get-ChildItem .\ubuntu_image.tar`)

**Image removal output:**
```
Referenced image 97bed23a3497
Untagged: ubuntu:latest
Deleted: sha256:97bed23a34971024aa8d254abbe67b7168772340d1f494034773bc464e8dd5b6
```

**Explanation:**  
Docker didn’t allow image deletion while a container was referencing it.  
After removing the container, deletion succeeded.  
`ubuntu_image.tar` contains all layers and the image manifest.

---

## Task 2 — Custom Image Creation

### 2.1 Customize Nginx

```powershell
docker run -d -p 80:80 --name nginx_container nginx
curl http://localhost
```

**Default page:**
```
Welcome to nginx!
```

**Created `index.html`:**
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

**After copying:**
```
StatusCode        : 200
Content           : <html>
                    <head>
                    <title>The best</title>
                    </head>
                    <body>
                    <h1>website</h1>
                    </body>
                    </html>
```

**Explanation:**  
Replacing `/usr/share/nginx/html/index.html` worked correctly — the page updated successfully.

---

### 2.2 Commit Container to a New Image

```powershell
docker commit nginx_container my_website:latest
docker images my_website
docker rm -f nginx_container
docker run -d -p 80:80 --name my_website_container my_website:latest
curl http://localhost
docker diff my_website_container
```

**Output `docker images my_website`:**
```
REPOSITORY   TAG       IMAGE ID       CREATED          SIZE
my_website   latest    ec200da1e4d0   4 seconds ago    160MB
```

**`curl http://localhost`:**
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

**`docker diff my_website_container`:**
```
C /run
C /run/nginx.pid
C /etc
C /etc/nginx
C /etc/nginx/conf.d
C /etc/nginx/conf.d/default.conf
```

**Explanation:**  
A new image `my_website:latest` (160 MB) was created.  
Change type `C` means a modified file.  
`docker commit` saves the current state of the container but lacks build reproducibility (no Dockerfile).

---

## Task 3 — Networking & DNS

```powershell
docker network create lab_network
docker run -dit --network lab_network --name container1 alpine ash
docker run -dit --network lab_network --name container2 alpine ash
docker exec container1 ping -c 3 container2
docker exec container1 nslookup container2
docker network inspect lab_network
```

**Ping:**
```
PING container2 (172.21.0.3): 56 data bytes
64 bytes from 172.21.0.3: seq=0 ttl=64 time=0.116 ms
64 bytes from 172.21.0.3: seq=1 ttl=64 time=0.075 ms
64 bytes from 172.21.0.3: seq=2 ttl=64 time=0.066 ms
--- container2 ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
```

**Inspect:**
```
"Subnet": "172.21.0.0/16",
"Gateway": "172.21.0.1",
"Containers": {
  "container1": "172.21.0.2",
  "container2": "172.21.0.3"
}
```

**nslookup:**
```
Address: 127.0.0.11:53
Name:   container2
Address: 172.21.0.3
```

**Explanation:**  
Docker created a bridge network with its own DNS (127.0.0.11).  
Containers inside a user-defined network can communicate via names.  
Useful for microservice environments.

---

## Task 4 — Volumes & Data Persistence

```powershell
docker volume create app_data
docker run -d -p 80:80 -v app_data:/usr/share/nginx/html --name web nginx
docker cp index2.html web:/usr/share/nginx/html/
curl http://localhost
docker stop web; docker rm web
docker run -d -p 80:80 -v app_data:/usr/share/nginx/html --name web_new nginx
curl http://localhost
docker volume inspect app_data
```

**Volume creation:**
```
local     app_data
```

**First run (curl):**
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

**After recreation (curl):**
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

**`docker volume inspect app_data`:**
```
"Mountpoint": "/var/lib/docker/volumes/app_data/_data",
"Name": "app_data",
"Driver": "local"
```

**Explanation:**  
Data inside the volume `app_data` persists between container recreations.  
Unlike bind mounts, volumes are managed by Docker and stored under `/var/lib/docker/volumes`.